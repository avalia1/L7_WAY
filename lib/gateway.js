/**
 * L7 Gateway - Route tool calls to MCP servers
 *
 * Supports multiple execution modes:
 * - http: Call MCP gateway via HTTP (default)
 * - spawn: Spawn MCP server process directly
 * - mock: Return mock data for testing
 */

const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const TOOLS_DIR = path.join(L7_DIR, 'tools');

// Gateway configuration
const config = {
  mode: process.env.L7_MODE || 'http',
  gatewayUrl: process.env.MCP_GATEWAY_URL || 'http://localhost:8765',
  mcpConfigPath: process.env.MCP_CONFIG || path.join(process.env.HOME, 'avli_cloud', '.mcp.json'),
  timeout: parseInt(process.env.L7_TIMEOUT || '30000', 10)
};

// Cache for loaded tools and MCP config
let mcpConfig = null;
const toolCache = new Map();

/**
 * Load MCP configuration from .mcp.json
 */
function loadMcpConfig() {
  if (mcpConfig) return mcpConfig;

  if (!fs.existsSync(config.mcpConfigPath)) {
    console.warn(`MCP config not found: ${config.mcpConfigPath}`);
    mcpConfig = { mcpServers: {} };
    return mcpConfig;
  }

  mcpConfig = JSON.parse(fs.readFileSync(config.mcpConfigPath, 'utf8'));
  return mcpConfig;
}

/**
 * Load a tool definition
 */
function loadTool(name) {
  if (toolCache.has(name)) {
    return toolCache.get(name);
  }

  const toolPath = path.join(TOOLS_DIR, `${name}.tool`);
  if (!fs.existsSync(toolPath)) {
    return null;
  }

  const yaml = require('js-yaml');
  const tool = yaml.load(fs.readFileSync(toolPath, 'utf8'));
  toolCache.set(name, tool);
  return tool;
}

/**
 * Get the full MCP tool name
 * e.g., send_sms -> mcp__dialpad__dialpad_send_sms
 */
function getMcpToolName(tool) {
  const server = tool.server;
  const mcpTool = tool.mcp_tool || tool.name;
  return `mcp__${server}__${mcpTool}`;
}

/**
 * Execute via HTTP gateway
 */
async function executeViaHttp(mcpToolName, params) {
  const url = `${config.gatewayUrl}/call`;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), config.timeout);

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        tool: mcpToolName,
        arguments: params
      }),
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Gateway error: ${response.status} - ${text}`);
    }

    const result = await response.json();
    return normalizeResult(result);
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      throw new Error(`Gateway timeout after ${config.timeout}ms`);
    }
    throw err;
  }
}

/**
 * Execute via spawning MCP server process
 * (stdio-based communication)
 */
async function executeViaSpawn(tool, params) {
  const mcp = loadMcpConfig();
  const serverConfig = mcp.mcpServers[tool.server];

  if (!serverConfig) {
    throw new Error(`MCP server not configured: ${tool.server}`);
  }

  return new Promise((resolve, reject) => {
    // Expand environment variables in command/args
    const expandEnv = (str) => {
      if (!str) return str;
      return str.replace(/\$\{([^}]+)\}/g, (_, key) => process.env[key] || '');
    };

    const command = expandEnv(serverConfig.command);
    const args = (serverConfig.args || []).map(expandEnv);

    // Merge environment
    const env = { ...process.env };
    if (serverConfig.env) {
      for (const [k, v] of Object.entries(serverConfig.env)) {
        env[k] = expandEnv(v);
      }
    }

    const proc = spawn(command, args, { env, stdio: ['pipe', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    proc.stdout.on('data', (data) => { stdout += data; });
    proc.stderr.on('data', (data) => { stderr += data; });

    // Send MCP tool call request via stdin
    const mcpRequest = {
      jsonrpc: '2.0',
      id: 1,
      method: 'tools/call',
      params: {
        name: tool.mcp_tool || tool.name,
        arguments: params
      }
    };

    proc.stdin.write(JSON.stringify(mcpRequest) + '\n');
    proc.stdin.end();

    const timeout = setTimeout(() => {
      proc.kill();
      reject(new Error(`Spawn timeout after ${config.timeout}ms`));
    }, config.timeout);

    proc.on('close', (code) => {
      clearTimeout(timeout);

      if (code !== 0 && !stdout) {
        reject(new Error(`MCP process exited with code ${code}: ${stderr}`));
        return;
      }

      try {
        // Parse the last JSON line from stdout (MCP response)
        const lines = stdout.trim().split('\n');
        const lastJson = lines.filter(l => l.startsWith('{') || l.startsWith('[')).pop();

        if (!lastJson) {
          reject(new Error(`No valid JSON response from MCP server`));
          return;
        }

        const response = JSON.parse(lastJson);

        if (response.error) {
          reject(new Error(response.error.message || JSON.stringify(response.error)));
          return;
        }

        resolve(normalizeResult(response.result));
      } catch (err) {
        reject(new Error(`Failed to parse MCP response: ${err.message}`));
      }
    });

    proc.on('error', (err) => {
      clearTimeout(timeout);
      reject(new Error(`Failed to spawn MCP server: ${err.message}`));
    });
  });
}

/**
 * Return mock data for testing
 */
function executeViaMock(toolName, params) {
  // Generate reasonable mock data based on tool name
  const mockData = {
    // Communication tools
    send_sms: { ok: true, message_id: `msg_${Date.now()}`, sent_at: new Date().toISOString() },
    dialpad_send_sms: { ok: true, message_id: `msg_${Date.now()}` },
    gv_send_sms: { ok: true, message_id: `gv_${Date.now()}` },

    // Query tools
    query_participants: {
      ok: true,
      count: 42,
      results: [
        { id: 1, name: 'Test Person 1', phone: '555-0001', consent: true, opted_out: false },
        { id: 2, name: 'Test Person 2', phone: '555-0002', consent: true, opted_out: false },
        { id: 3, name: 'Test Person 3', phone: '555-0003', consent: false, opted_out: true }
      ]
    },

    // Campaign tools
    start_campaign: { ok: true, campaign_id: `camp_${Date.now()}`, status: 'started' },
    get_responses: { ok: true, count: 15, responses: [] },
    log_campaign: { ok: true, logged_at: new Date().toISOString() }
  };

  return {
    ok: true,
    ...(mockData[toolName] || { result: 'success' })
  };
}

/**
 * Normalize result to standard format { ok, ...data }
 */
function normalizeResult(result) {
  if (result === null || result === undefined) {
    return { ok: true };
  }

  if (typeof result !== 'object') {
    return { ok: true, result };
  }

  // If result has content array (MCP standard), extract it
  if (Array.isArray(result.content)) {
    const textContent = result.content.find(c => c.type === 'text');
    if (textContent) {
      try {
        const parsed = JSON.parse(textContent.text);
        return { ok: true, ...parsed };
      } catch {
        return { ok: true, result: textContent.text };
      }
    }
  }

  // Already has ok field
  if ('ok' in result) {
    return result;
  }

  // Wrap in ok
  return { ok: true, ...result };
}

/**
 * Execute a tool by name with parameters
 *
 * @param {string} toolName - The L7 tool name (e.g., 'send_sms')
 * @param {object} params - Parameters to pass to the tool
 * @param {object} options - Execution options
 * @returns {Promise<object>} Result object with { ok, ...data }
 */
async function execute(toolName, params = {}, options = {}) {
  const mode = options.mode || config.mode;
  const tool = loadTool(toolName);

  if (!tool) {
    // Try calling without tool definition (direct MCP call)
    console.warn(`No tool definition for ${toolName}, attempting direct call`);

    if (mode === 'mock') {
      return executeViaMock(toolName, params);
    }

    // Assume the tool name IS the MCP tool name
    const mcpToolName = toolName.includes('__') ? toolName : `mcp__unknown__${toolName}`;
    return executeViaHttp(mcpToolName, params);
  }

  const mcpToolName = getMcpToolName(tool);

  switch (mode) {
    case 'mock':
      return executeViaMock(toolName, params);

    case 'spawn':
      return executeViaSpawn(tool, params);

    case 'http':
    default:
      return executeViaHttp(mcpToolName, params);
  }
}

/**
 * List available tools from tool definitions
 */
function listTools() {
  if (!fs.existsSync(TOOLS_DIR)) {
    return [];
  }

  return fs.readdirSync(TOOLS_DIR)
    .filter(f => f.endsWith('.tool'))
    .map(f => {
      const name = path.basename(f, '.tool');
      const tool = loadTool(name);
      return {
        name,
        description: tool?.description,
        server: tool?.server,
        does: tool?.does
      };
    });
}

/**
 * Check gateway health
 */
async function checkHealth() {
  try {
    const response = await fetch(`${config.gatewayUrl}/health`, {
      method: 'GET',
      signal: AbortSignal.timeout(5000)
    });
    return response.ok;
  } catch {
    return false;
  }
}

module.exports = {
  execute,
  loadTool,
  getMcpToolName,
  listTools,
  checkHealth,
  config
};
