# Archive (frozen, not product)

These files are not the live L7 gateway. Do not npm-start them. Do not compile them as the control plane.

- `empire/server.js` — former second HTTP listener on EMPIRE_PORT 7377
- `host/gateway-server.swift` — former native listener on 18789 (OpenClaw owns that port)

Product boot: `npm start` → `serve.js` → `127.0.0.1:18793`.
