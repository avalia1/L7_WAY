#!/usr/bin/env node
/**
 * Compatibility launcher for the L7 control plane.
 *
 * The product HTTP gateway is serve.js (`npm start`) on 127.0.0.1:18793.
 * `l7 gateway` means that process, not archive/host/gateway-server.swift
 * and not ~/.l7/l7-gateway (Mac egress valve; Phase 3).
 */
require('./serve').start().catch((err) => {
  console.error('FATAL:', err.message);
  console.error(err.stack);
  process.exit(1);
});
