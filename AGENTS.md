# Agent notes

## Gateway vs Founder Loop

- **Gateway** is `npm start` / `scripts/run-gateway.sh` → `serve.js` on `127.0.0.1:18793`. No Tailscale, SSH, or workers.
- **Founder Loop** is `scripts/run-founder-loop.sh`. It is operator plumbing, not the gateway.
- `./start.sh` calls both for the founder. It is not the architecture.

Do not start `~/avli_cloud/start.sh`. Workers only via `~/avli_cloud/workers/start.sh` if that file exists. Do not Tailscale-serve `:18792`, `:18798`, or forge `:7378`. Do not grow tunnel/n8n/Tailscale code in `serve.js`. Do not invent `lib/avli-worker-client.js` if it is not already in the tree.

Loop smoke: `./scripts/founder-loop-smoke.sh`. Gateway tests: `test/server-v1.test.js`, `test/one-listener.test.js`.
