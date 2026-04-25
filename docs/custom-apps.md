# Hosting Custom Apps

Add a service to `docker-compose.yml` on the `proxy` network and expose it with Traefik labels.

Example:

```yaml
  myapp:
    image: ghcr.io/your-user/myapp:latest
    container_name: myapp
    restart: unless-stopped
    networks:
      - proxy
    labels:
      - traefik.enable=true
      - traefik.http.routers.myapp.rule=Host(`myapp.example.com`)
      - traefik.http.routers.myapp.entrypoints=web
      - traefik.http.routers.myapp.middlewares=security-headers@file
      - traefik.http.services.myapp.loadbalancer.server.port=3000
```

If the app needs persistent state, store it below `/mnt/appdata/<app-name>` and add the matching bind mount.
