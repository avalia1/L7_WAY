const catalogEl = document.getElementById('catalog');
const legionsEl = document.getElementById('legions');
const launchersEl = document.getElementById('launchers');
const titleEl = document.getElementById('citizen-title');
const titleSecondaryEl = document.getElementById('citizen-title-secondary');
const renderedEl = document.getElementById('rendered');
const rawEl = document.getElementById('raw');
const tabs = document.querySelectorAll('.tab');
const graphEl = document.getElementById('graph');
const legionMapEl = document.getElementById('legion-map');
const sidecarListEl = document.getElementById('sidecar-list');
const sidecarContentEl = document.getElementById('sidecar-content');
const commandInput = document.getElementById('command-input');
const commandResponse = document.getElementById('command-response');
const auditFeedEl = document.getElementById('audit-feed');
const auditTabs = document.querySelectorAll('.audit-tab');

async function loadCitizens() {
  const res = await fetch('/api/citizens');
  const data = await res.json();
  return data.citizens || [];
}

async function loadLegions() {
  const res = await fetch('/api/legions');
  const data = await res.json();
  legionsEl.innerHTML = '';
  data.legions.forEach((legion) => {
    const btn = document.createElement('button');
    btn.className = 'citizen';
    btn.textContent = legion.id;
    btn.addEventListener('click', () => selectItem('legion', legion, btn));
    legionsEl.appendChild(btn);
  });
}

async function loadLaunchers() {
  const res = await fetch('/api/launchers');
  const data = await res.json();
  launchersEl.innerHTML = '';
  data.launchers.forEach((launcher) => {
    const btn = document.createElement('button');
    btn.className = 'citizen';
    btn.textContent = launcher.id;
    btn.addEventListener('click', () => selectItem('launcher', launcher, btn));
    launchersEl.appendChild(btn);
  });
}

async function loadAuditEntries(type) {
  const endpoint = type === 'transitions' ? '/api/transitions' : '/api/audit';
  const res = await fetch(`${endpoint}?limit=140`);
  const data = await res.json();
  return data.entries || [];
}

function renderAudit(entries, type) {
  if (!auditFeedEl) return;
  auditFeedEl.innerHTML = '';
  if (!entries.length) {
    auditFeedEl.innerHTML = '<div class="keyline">No audit entries yet.</div>';
    return;
  }

  entries.slice().reverse().forEach((entry) => {
    const item = document.createElement('div');
    item.className = 'audit-entry';
    if (type === 'transitions') {
      const when = entry.when || '';
      item.innerHTML = `
        <div><strong>${entry.entity_id || 'unknown'}</strong> ${entry.from_state || ''} → ${entry.to_state || ''}</div>
        <div class="keyline">${entry.reason || ''}</div>
        <div class="keyline">${when}</div>
      `;
    } else {
      const tool = entry.what?.tool || entry.tool || 'unknown';
      const result = entry.what?.result || 'unknown';
      const when = entry.when || '';
      const who = entry.who?.entity_id || entry.who || 'unknown';
      item.innerHTML = `
        <div><strong>${tool}</strong> · ${result}</div>
        <div class="keyline">${who}</div>
        <div class="keyline">${when}</div>
      `;
    }
    auditFeedEl.appendChild(item);
  });
}

function extractField(content, key) {
  const match = content.split('\n').find((line) => line.trim().startsWith(`${key}:`));
  if (!match) return '';
  return match.split(':').slice(1).join(':').trim();
}

function extractListField(content, key) {
  const value = extractField(content, key);
  if (!value) return [];
  return value.split(',').map((item) => item.trim()).filter(Boolean);
}

function extractIndentedList(content, key) {
  const lines = content.split('\n');
  const startIndex = lines.findIndex((line) => line.trim() === `${key}:`);
  if (startIndex === -1) return [];
  const items = [];
  for (let i = startIndex + 1; i < lines.length; i += 1) {
    const line = lines[i];
    if (!line.startsWith('  -')) break;
    items.push(line.replace('  -', '').trim());
  }
  return items;
}

function extractWikiLinks(content) {
  const matches = content.match(/\[\[([^\]]+)\]\]/g) || [];
  return matches.map((m) => m.replace('[[', '').replace(']]', '').trim());
}

function parseCapability(content) {
  const lines = content.split('\n');
  const l7Index = lines.findIndex((line) => line.trim() === 'L7:');
  if (l7Index === -1) return 'other';
  for (let i = l7Index + 1; i < lines.length; i += 1) {
    const line = lines[i].trim();
    if (!line) continue;
    if (line.startsWith('capability:')) {
      return line.split(':').slice(1).join(':').trim() || 'other';
    }
    if (!line.startsWith('capability') && !line.startsWith('data') && !line.startsWith('policy')) {
      break;
    }
  }
  return 'other';
}

let graphDriftTimer = null;
let showRelations = false;
let lastCitizen = null;

function buildGraph(content, includeRelations) {
  const entityId = extractField(content, 'entity_id') || 'unknown';
  const lineage = extractField(content, 'lineage');
  const composes = extractListField(content, 'composes');
  const dependsOn = extractListField(content, 'depends_on');
  const legion = extractField(content, 'legion');
  const wikiLinks = extractWikiLinks(content);

  const l7Nodes = [
    { index: 1, icon: '🔧', text: 'Capability' },
    { index: 2, icon: '📦', text: 'Data' },
    { index: 3, icon: '🧭', text: 'Policy/Intent' },
    { index: 4, icon: '🧩', text: 'Presentation' },
    { index: 5, icon: '🔗', text: 'Orchestration' },
    { index: 6, icon: '🕒', text: 'Time/Versioning' },
    { index: 7, icon: '🛡️', text: 'Identity/Security' },
  ];

  const nodes = [{ id: entityId, label: entityId, type: 'core' }];
  const links = [];

  l7Nodes.forEach((node) => {
    const label = `L${node.index}.${node.icon}.${node.text}`;
    nodes.push({ id: label, label, type: 'l7' });
    links.push({ source: entityId, target: label });
  });

  if (includeRelations) {
    if (lineage) {
      const id = `Lineage: ${lineage}`;
      nodes.push({ id, label: id, type: 'relation' });
      links.push({ source: entityId, target: id });
    }

    composes.forEach((entry) => {
      const id = `Composes: ${entry}`;
      nodes.push({ id, label: id, type: 'relation' });
      links.push({ source: entityId, target: id });
    });

    dependsOn.forEach((entry) => {
      const id = `Depends on: ${entry}`;
      nodes.push({ id, label: id, type: 'relation' });
      links.push({ source: entityId, target: id });
    });

    if (legion) {
      const id = `Legion: ${legion}`;
      nodes.push({ id, label: id, type: 'relation' });
      links.push({ source: entityId, target: id });
    }

    wikiLinks.forEach((link) => {
      const id = `Link: ${link}`;
      nodes.push({ id, label: id, type: 'relation' });
      links.push({ source: entityId, target: id });
    });
  }

  return { nodes, links };
}

function renderGraph(content, type) {
  const { nodes, links } = buildGraph(content, showRelations);
  if (type !== 'citizen') {
    graphEl.innerHTML = '<div class=\"keyline\">No graph for this item.</div>';
    return;
  }
  const width = graphEl.clientWidth || 600;
  const height = 220;
  const centerX = Math.min(width / 2, 320);
  const centerY = height / 2;
  const radius = 80;

  const l7Nodes = nodes.filter((n) => n.type === 'l7');
  const relationNodes = nodes.filter((n) => n.type === 'relation');

  const positions = {};
  const velocities = {};
  positions[nodes[0].id] = { x: centerX, y: centerY };
  velocities[nodes[0].id] = { x: 0, y: 0 };

  l7Nodes.forEach((node, idx) => {
    const angle = (Math.PI * 2 * idx) / l7Nodes.length;
    positions[node.id] = {
      x: centerX + Math.cos(angle) * radius,
      y: centerY + Math.sin(angle) * radius,
    };
    velocities[node.id] = { x: 0, y: 0 };
  });

  relationNodes.forEach((node, idx) => {
    positions[node.id] = {
      x: centerX + radius + 120,
      y: 20 + idx * 24,
    };
    velocities[node.id] = { x: 0, y: 0 };
  });

  graphEl.innerHTML = '';
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('viewBox', `0 0 ${width} ${height}`);
  svg.setAttribute('role', 'img');
  svg.setAttribute('aria-label', 'Citizen graph');

  const lineEls = new Map();
  links.forEach((link) => {
    const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    line.setAttribute('stroke', '#2a3b46');
    line.setAttribute('stroke-width', '1');
    svg.appendChild(line);
    lineEls.set(`${link.source}->${link.target}`, line);
  });

  const nodeEls = new Map();
  nodes.forEach((node) => {
    const group = document.createElementNS('http://www.w3.org/2000/svg', 'g');
    const circle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    const fill = node.type === 'core' ? '#f2c94c' : node.type === 'l7' ? '#1f8ea3' : '#314352';
    const radiusValue = node.type === 'core' ? (showRelations ? 12 : 9) : 8;

    circle.setAttribute('r', String(radiusValue));
    circle.setAttribute('fill', fill);
    circle.dataset.nodeId = node.id;
    circle.style.cursor = 'grab';

    text.textContent = node.label || node.id;
    group.appendChild(circle);
    group.appendChild(text);
    svg.appendChild(group);

    nodeEls.set(node.id, { group, circle, text });
  });

  graphEl.appendChild(svg);

  function updatePositions() {
    links.forEach((link) => {
      const from = positions[link.source];
      const to = positions[link.target];
      if (!from || !to) return;
      const line = lineEls.get(`${link.source}->${link.target}`);
      if (!line) return;
      line.setAttribute('x1', String(from.x));
      line.setAttribute('y1', String(from.y));
      line.setAttribute('x2', String(to.x));
      line.setAttribute('y2', String(to.y));
    });

    nodes.forEach((node) => {
      const pos = positions[node.id];
      if (!pos) return;
      const nodeEl = nodeEls.get(node.id);
      if (!nodeEl) return;
      nodeEl.circle.setAttribute('cx', String(pos.x));
      nodeEl.circle.setAttribute('cy', String(pos.y));
      nodeEl.text.setAttribute('x', String(pos.x + 12));
      nodeEl.text.setAttribute('y', String(pos.y + 4));
    });
  }

  updatePositions();

  let draggingId = null;
  svg.addEventListener('pointerdown', (event) => {
    const target = event.target;
    if (target && target.dataset && target.dataset.nodeId) {
      draggingId = target.dataset.nodeId;
      target.setPointerCapture(event.pointerId);
    }
  });
  svg.addEventListener('pointerup', (event) => {
    if (!draggingId) return;
    const target = event.target;
    if (target && target.releasePointerCapture) {
      target.releasePointerCapture(event.pointerId);
    }
    draggingId = null;
  });
  svg.addEventListener('pointermove', (event) => {
    if (!draggingId) return;
    const rect = svg.getBoundingClientRect();
    positions[draggingId] = {
      x: Math.max(20, Math.min(width - 20, event.clientX - rect.left)),
      y: Math.max(20, Math.min(height - 20, event.clientY - rect.top)),
    };
    updatePositions();
  });

  svg.addEventListener('click', (event) => {
    const target = event.target;
    if (!target || !target.dataset || !target.dataset.nodeId) return;
    const nodeId = target.dataset.nodeId;
    if (nodeId === nodes[0].id) {
      showRelations = !showRelations;
      renderGraph(content, type);
    }
  });

  if (graphDriftTimer) {
    clearInterval(graphDriftTimer);
  }

  const coreId = nodes[0].id;
  const repulsion = 1800;
  const springL7 = 0.02;
  const springRelation = 0.01;
  const damping = 0.85;
  const similarityPull = 0.008;

  graphDriftTimer = setInterval(() => {
    nodes.forEach((node, idx) => {
      if (node.id === coreId) return;
      if (draggingId === node.id) return;

      const pos = positions[node.id];
      const vel = velocities[node.id];
      if (!pos || !vel) return;

      let fx = 0;
      let fy = 0;

      // Attraction to core (stronger for L7 nodes)
      const corePos = positions[coreId];
      if (corePos) {
        const dx = corePos.x - pos.x;
        const dy = corePos.y - pos.y;
        const dist = Math.max(1, Math.hypot(dx, dy));
        const spring = node.type === 'relation' ? springRelation : springL7;
        fx += (dx / dist) * spring * (dist - radius);
        fy += (dy / dist) * spring * (dist - radius);
      }

      // Similarity pull between neighboring L7 nodes
      if (node.type === 'l7') {
        const prev = l7Nodes[(idx - 1 + l7Nodes.length) % l7Nodes.length];
        const next = l7Nodes[(idx + 1) % l7Nodes.length];
        [prev, next].forEach((neighbor) => {
          if (!neighbor || neighbor.id === node.id) return;
          const npos = positions[neighbor.id];
          if (!npos) return;
          const dx = npos.x - pos.x;
          const dy = npos.y - pos.y;
          const dist = Math.max(1, Math.hypot(dx, dy));
          fx += (dx / dist) * similarityPull;
          fy += (dy / dist) * similarityPull;
        });
      }

      // Repulsion from other nodes
      nodes.forEach((other) => {
        if (other.id === node.id) return;
        const opos = positions[other.id];
        if (!opos) return;
        const dx = pos.x - opos.x;
        const dy = pos.y - opos.y;
        const dist = Math.max(1, Math.hypot(dx, dy));
        const force = repulsion / (dist * dist);
        fx += (dx / dist) * force;
        fy += (dy / dist) * force;
      });

      vel.x = (vel.x + fx) * damping;
      vel.y = (vel.y + fy) * damping;
      pos.x += vel.x;
      pos.y += vel.y;
      pos.x = Math.max(20, Math.min(width - 20, pos.x));
      pos.y = Math.max(20, Math.min(height - 20, pos.y));
    });

    updatePositions();
  }, 60);
}

function renderSidecar(files, sourceFile) {
  sidecarListEl.innerHTML = '';
  sidecarContentEl.style.display = 'none';
  sidecarContentEl.textContent = '';

  if (!files || files.length === 0) {
    sidecarListEl.innerHTML = '<span class="keyline">No sidecar files.</span>';
    return;
  }

  files.forEach((file) => {
    const btn = document.createElement('button');
    btn.className = 'sidecar-item';
    btn.textContent = file;
    btn.addEventListener('click', async () => {
      const res = await fetch(`/api/sidecar?file=${encodeURIComponent(sourceFile)}&item=${encodeURIComponent(file)}`);
      const data = await res.json();
      sidecarContentEl.textContent = data.content || '';
      sidecarContentEl.style.display = 'block';
    });
    sidecarListEl.appendChild(btn);
  });
}

function parseL7(content) {
  const lines = content.split('\n');
  const fragments = lines.map((line) => {
    if (!line.trim()) return '<br />';
    if (line.startsWith('#')) {
      const depth = line.match(/^#+/)[0].length;
      const text = line.replace(/^#+\s*/, '');
      return `<h${Math.min(depth + 1, 4)}>${text}</h${Math.min(depth + 1, 4)}>`;
    }
    if (line.startsWith('- ')) {
      const item = line.replace('- ', '');
      const withLinks = item.replace(/\[\[([^\]]+)\]\]/g, '<span class="wikilink">[[$1]]</span>');
      return `<li>${withLinks}</li>`;
    }
    if (line.includes(':')) {
      const [key, ...rest] = line.split(':');
      const value = rest.join(':').trim();
      const withLinks = value.replace(/\[\[([^\]]+)\]\]/g, '<span class="wikilink">[[$1]]</span>');
      return `<div><span class="keyline">${key.trim()}:</span> ${withLinks}</div>`;
    }
    const withLinks = line.replace(/\[\[([^\]]+)\]\]/g, '<span class="wikilink">[[$1]]</span>');
    return `<div>${withLinks}</div>`;
  });

  return fragments.join('');
}

function renderCatalog(citizensWithMeta) {
  const groups = {};
  citizensWithMeta.forEach((citizen) => {
    const category = citizen.capability || 'other';
    if (!groups[category]) groups[category] = [];
    groups[category].push(citizen);
  });

  catalogEl.innerHTML = '';
  Object.keys(groups).sort().forEach((category) => {
    const groupEl = document.createElement('div');
    groupEl.className = 'catalog-group';
    const title = document.createElement('div');
    title.className = 'catalog-title';
    title.textContent = category;
    groupEl.appendChild(title);

    groups[category].forEach((citizen) => {
      const btn = document.createElement('button');
      btn.className = 'citizen';
      btn.textContent = citizen.id;
      btn.addEventListener('click', () => selectItem('citizen', citizen, btn));
      groupEl.appendChild(btn);
    });
    catalogEl.appendChild(groupEl);
  });
}

function renderLegionMap(legions, citizensById) {
  if (!legions || legions.length === 0) {
    legionMapEl.innerHTML = '<div class="keyline">No legions defined.</div>';
    return;
  }

  const width = legionMapEl.clientWidth || 600;
  const height = 260;
  const svg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('viewBox', `0 0 ${width} ${height}`);
  svg.setAttribute('role', 'img');
  svg.setAttribute('aria-label', 'Legion map');

  const legionSpacing = Math.max(160, width / (legions.length + 1));
  legions.forEach((legion, index) => {
    const centerX = legionSpacing * (index + 1);
    const centerY = height / 2;
    const group = document.createElementNS('http://www.w3.org/2000/svg', 'g');

    const core = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
    core.setAttribute('cx', String(centerX));
    core.setAttribute('cy', String(centerY));
    core.setAttribute('r', '14');
    core.setAttribute('fill', '#8dd3ff');
    group.appendChild(core);

    const label = document.createElementNS('http://www.w3.org/2000/svg', 'text');
    label.setAttribute('x', String(centerX + 18));
    label.setAttribute('y', String(centerY + 4));
    label.textContent = legion.id;
    group.appendChild(label);

    const members = legion.entities || [];
    members.forEach((member, idx) => {
      const angle = (Math.PI * 2 * idx) / Math.max(1, members.length);
      const radius = 60;
      const mx = centerX + Math.cos(angle) * radius;
      const my = centerY + Math.sin(angle) * radius;
      const node = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
      node.setAttribute('cx', String(mx));
      node.setAttribute('cy', String(my));
      node.setAttribute('r', '7');
      node.setAttribute('fill', '#314352');
      group.appendChild(node);

      const memberLabel = document.createElementNS('http://www.w3.org/2000/svg', 'text');
      memberLabel.setAttribute('x', String(mx + 10));
      memberLabel.setAttribute('y', String(my + 4));
      memberLabel.textContent = member;
      group.appendChild(memberLabel);

      const link = document.createElementNS('http://www.w3.org/2000/svg', 'line');
      link.setAttribute('x1', String(centerX));
      link.setAttribute('y1', String(centerY));
      link.setAttribute('x2', String(mx));
      link.setAttribute('y2', String(my));
      link.setAttribute('stroke', '#2a3b46');
      link.setAttribute('stroke-width', '1');
      svg.appendChild(link);

      const pulse = document.createElementNS('http://www.w3.org/2000/svg', 'line');
      pulse.setAttribute('x1', String(centerX));
      pulse.setAttribute('y1', String(centerY));
      pulse.setAttribute('x2', String(mx));
      pulse.setAttribute('y2', String(my));
      pulse.setAttribute('class', 'pulse');
      svg.appendChild(pulse);
    });

    svg.appendChild(group);
  });

  legionMapEl.innerHTML = '';
  legionMapEl.appendChild(svg);
}

function suggestLegions(citizensMeta) {
  const groups = {};
  citizensMeta.forEach((citizen) => {
    const key = citizen.capability || 'other';
    if (!groups[key]) groups[key] = [];
    groups[key].push(citizen.id);
  });
  return Object.keys(groups).sort().map((key) => ({
    id: `${key}-legion`,
    entities: groups[key].slice(0, 5),
  }));
}

function applyIntent(query, citizensMeta) {
  const tokens = query.toLowerCase().split(/\s+/).filter(Boolean);
  if (tokens.length === 0) {
    commandResponse.textContent = '';
    document.querySelectorAll('.citizen').forEach((b) => b.classList.remove('highlight'));
    return;
  }

  const matches = citizensMeta.filter((citizen) => {
    const haystack = `${citizen.id} ${citizen.content}`.toLowerCase();
    return tokens.some((token) => haystack.includes(token));
  });

  document.querySelectorAll('.citizen').forEach((b) => b.classList.remove('highlight'));
  matches.forEach((citizen) => {
    const btn = [...document.querySelectorAll('.citizen')].find((b) => b.textContent === citizen.id);
    if (btn) btn.classList.add('highlight');
  });

  if (matches[0]) {
    const btn = [...document.querySelectorAll('.citizen')].find((b) => b.textContent === matches[0].id);
    if (btn) btn.click();
    commandResponse.textContent = `Gateway suggests: ${matches[0].id}`;
  } else {
    commandResponse.textContent = 'No matching citizen.';
  }
}

async function selectItem(type, item, button) {
  document.querySelectorAll('.citizen').forEach((b) => b.classList.remove('active'));
  button.classList.add('active');
  button.scrollIntoView({ block: 'nearest' });

  const endpoint = type === 'launcher' ? 'launcher' : type;
  const res = await fetch(`/api/${endpoint}?file=${encodeURIComponent(item.file)}`);
  const data = await res.json();
  titleSecondaryEl.textContent = item.id;
  rawEl.textContent = data.content || '';
  renderedEl.innerHTML = parseL7(data.content || '');
  renderGraph(data.content || '', type);
  renderSidecar(data.sidecar || [], item.file);
}

tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    tabs.forEach((t) => t.classList.remove('active'));
    tab.classList.add('active');
    const target = tab.dataset.tab;
    document.querySelectorAll('.view').forEach((view) => view.classList.remove('view-active'));
    document.getElementById(target).classList.add('view-active');
  });
});

Promise.all([loadCitizens(), loadLegions(), loadLaunchers()]).then(async ([citizens]) => {
  const citizenMeta = await Promise.all(citizens.map(async (citizen) => {
    const res = await fetch(`/api/citizen?file=${encodeURIComponent(citizen.file)}`);
    const data = await res.json();
    return {
      ...citizen,
      capability: parseCapability(data.content || ''),
      content: data.content || '',
      links: extractWikiLinks(data.content || ''),
    };
  }));
  renderCatalog(citizenMeta);

  const legionsRes = await fetch('/api/legions');
  const legionsData = await legionsRes.json();
  const legions = await Promise.all((legionsData.legions || []).map(async (legion) => {
    const res = await fetch(`/api/legion?file=${encodeURIComponent(legion.file)}`);
    const data = await res.json();
    return {
      id: legion.id,
      entities: extractIndentedList(data.content || '', 'entities'),
    };
  }));

  const existingLegions = legions.length > 0 ? legions : suggestLegions(citizenMeta);

  renderLegionMap(existingLegions, citizenMeta.reduce((acc, item) => {
    acc[item.id] = item;
    return acc;
  }, {}));

  const firstCitizen = catalogEl.querySelector('.citizen');
  if (firstCitizen) {
    firstCitizen.click();
  }

  commandInput.addEventListener('input', (event) => {
    applyIntent(event.target.value, citizenMeta);
  });
});

let activeAuditTab = 'audit';

if (auditTabs.length) {
  auditTabs.forEach((tab) => {
    tab.addEventListener('click', async () => {
      auditTabs.forEach((t) => t.classList.remove('active'));
      tab.classList.add('active');
      activeAuditTab = tab.dataset.audit || 'audit';
      const entries = await loadAuditEntries(activeAuditTab);
      renderAudit(entries, activeAuditTab);
    });
  });
}

async function refreshAudit() {
  const entries = await loadAuditEntries(activeAuditTab);
  renderAudit(entries, activeAuditTab);
}

refreshAudit();
setInterval(refreshAudit, 5000);
