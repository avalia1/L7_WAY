/**
 * L7 Gateway - Route tool calls to MCP servers
 *
 * Supports multiple execution modes:
 * - mcp: Use MCP SDK with stdio transport (default)
 * - mock: Return mock data for testing
 */

const fs = require('fs');
const path = require('path');
const { Client } = require('@modelcontextprotocol/sdk/client/index.js');
const { StdioClientTransport } = require('@modelcontextprotocol/sdk/client/stdio.js');

const L7_DIR = process.env.L7_DIR || path.join(process.env.HOME, '.l7');
const TOOLS_DIR = path.join(L7_DIR, 'tools');

// Gateway configuration
const config = {
  mode: process.env.L7_MODE || 'mcp',
  mcpConfigPath: process.env.MCP_CONFIG || path.join(process.env.HOME, 'avli_cloud', '.mcp.json'),
  timeout: parseInt(process.env.L7_TIMEOUT || '30000', 10)
};

// Cache for loaded tools, MCP config, and active clients
let mcpConfig = null;
const toolCache = new Map();
const clientCache = new Map();

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
 * Expand environment variables in a string
 */
function expandEnv(str) {
  if (!str) return str;
  return str.replace(/\$\{([^}]+)\}/g, (_, key) => process.env[key] || '');
}

/**
 * Get or create an MCP client for a server
 */
async function getClient(serverName) {
  // Check if we have a cached, connected client
  if (clientCache.has(serverName)) {
    const cached = clientCache.get(serverName);
    if (cached.connected) {
      return cached.client;
    }
    // Client disconnected, remove from cache
    clientCache.delete(serverName);
  }

  const mcp = loadMcpConfig();
  const serverConfig = mcp.mcpServers[serverName];

  if (!serverConfig) {
    throw new Error(`MCP server not configured: ${serverName}`);
  }

  const command = expandEnv(serverConfig.command);
  const args = (serverConfig.args || []).map(expandEnv);

  // Merge environment
  const env = { ...process.env };
  if (serverConfig.env) {
    for (const [k, v] of Object.entries(serverConfig.env)) {
      env[k] = expandEnv(v);
    }
  }

  console.log(`  [gateway] Starting MCP server: ${serverName}`);
  console.log(`  [gateway] Command: ${command} ${args.join(' ')}`);

  // Create transport and client
  const transport = new StdioClientTransport({
    command,
    args,
    env
  });

  const client = new Client({
    name: 'l7-gateway',
    version: '1.0.0'
  });

  // Connect
  await client.connect(transport);

  // Cache the client
  clientCache.set(serverName, { client, connected: true, transport });

  // Handle disconnection
  transport.onclose = () => {
    console.log(`  [gateway] MCP server disconnected: ${serverName}`);
    const cached = clientCache.get(serverName);
    if (cached) {
      cached.connected = false;
    }
  };

  console.log(`  [gateway] Connected to: ${serverName}`);
  return client;
}

/**
 * Execute via MCP SDK
 */
async function executeViaMcp(tool, params) {
  const client = await getClient(tool.server);
  const toolName = tool.mcp_tool || tool.name;

  console.log(`  [gateway] Calling tool: ${toolName}`);

  const result = await client.callTool({
    name: toolName,
    arguments: params
  });

  return normalizeResult(result);
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
    console.warn(`  [gateway] No tool definition for ${toolName}`);

    if (mode === 'mock') {
      return executeViaMock(toolName, params);
    }

    throw new Error(`Unknown tool: ${toolName}`);
  }

  switch (mode) {
    case 'mock':
      return executeViaMock(toolName, params);

    case 'mcp':
    default:
      return executeViaMcp(tool, params);
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
 * Check if MCP servers are healthy
 */
async function checkHealth() {
  // In MCP mode, we're always "ready" - connections are made on demand
  return config.mode === 'mcp' || config.mode === 'mock';
}

/**
 * Close all active MCP connections
 */
async function shutdown() {
  for (const [name, cached] of clientCache) {
    try {
      if (cached.connected) {
        console.log(`  [gateway] Closing connection: ${name}`);
        await cached.transport.close();
      }
    } catch (err) {
      console.error(`  [gateway] Error closing ${name}:`, err.message);
    }
  }
  clientCache.clear();
}

module.exports = {
  execute,
  loadTool,
  listTools,
  checkHealth,
  shutdown,
  config
};
