# 🌐 Configuring Proxy in NPM

After logging into the NPM dashboard:

1. Go to the **"Proxy Hosts"** tab
2. Click **"Add Proxy Host"**
3. Fill in the following:

   **Domain Names:**
   ```
   example.com
   ```

   or some ip, for example:

   ```
   129.1.2.3
   ```

   **Forward Hostname / IP:**
   ```
   <DocumentServer address, in this docker-compose stand that should be 'onlyoffice-documentserver'>
   ```

   **Forward Port:**
   ```
   80
   ```

   Optional Settings:
   - **Enable Websockets Support** — Should be enabled! ONLYOFFICE DocumentServer use websocket
   - **Block Common Exploits** — recommended

   Video manual:

   https://github.com/user-attachments/assets/53c80c5f-bbb6-4dec-b455-c0da2d7e6dfc

4. Go to the **SSL** tab:

   - Choose **"Request a new SSL Certificate"**
   - Enable the following:
     - **Force SSL**
     - **HTTP/2 Support**
     - **HSTS Enabled**
   - Accept the Let's Encrypt Terms of Service

5. Click **Save**

   Video manual:

   https://github.com/user-attachments/assets/4ee1e11e-123a-4b73-91d5-52b7d23c3c66

---

## ✅ Benefits of Using Nginx Proxy Manager

- 📋 **User-friendly web UI** — no need to edit configs manually
- 🔐 **HTTPS support (Let's Encrypt)** — automatic and free SSL certificates
- 🔁 **Flexible proxying** — by IP, domain, WebSocket-ready
- 📈 **Logging and monitoring** — built-in request logs
- 💡 **Minimal setup effort** — ideal for quick dev/test deployment

