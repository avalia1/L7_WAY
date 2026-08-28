# Empire (frozen UI)

Empire is not a product HTTP server. The control plane is `npm start` (`serve.js` on `127.0.0.1:18793`).

`empire/public/` remains as a frozen client. The former listener is `archive/empire/server.js` — do not run it as a gateway. If this UI is revived, it should call `http://127.0.0.1:18793`, not bind a second port.
