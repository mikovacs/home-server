# Home Server

Docker alapú otthoni szerver stack Ubuntu szerverre, Cloudflare Tunnel hozzáféréssel és Traefik belső routinggal.

## Szolgáltatások

| Szolgáltatás | Cél |
| --- | --- |
| Cloudflare Tunnel | Publikus, port forward nélküli hozzáférés |
| Traefik | Belső HTTP routing hostnév alapján |
| Portainer | Konténerek kezelése |
| File Browser | Fájlkezelés böngészőből |
| qBittorrent | Letöltések |
| Plex | Média megosztás |
| Sonarr | Sorozat automatizálás |
| Radarr | Film automatizálás |
| whoami | Traefik routing teszt |

## Lemezkiosztás

| Lemez | Path | Használat |
| --- | --- | --- |
| Belső SSD | rendszerlemez | Ubuntu és Docker |
| Belső HDD | `/mnt/appdata` | app config, konténer state, letöltések |
| Külső HDD | `/mnt/plex-media` | Plex media |

Elvárt média mappák:

```text
/mnt/plex-media/movies
/mnt/plex-media/series
```

## Gyors indítás

```bash
cp .env.EXAMPLE .env
nano .env
./scripts/bootstrap.sh
```

Cloudflare Tunnel létrehozása indítás előtt:

```bash
cloudflared tunnel login
./scripts/cloudflare-tunnel-create.sh
```

A script létrehozza a `config/cloudflared/credentials.json` fájlt. Ez titok, ezért nincs verziózva. A létrejött tunnel ID-t írd be a `.env` fájl `CLOUDFLARE_TUNNEL_ID` értékéhez.

DNS route-ok létrehozása:

```bash
./scripts/cloudflare-dns-route.sh
```

Stack indítása:

```bash
./scripts/start.sh
```

Állapot:

```bash
./scripts/status.sh
```

Leállítás:

```bash
./scripts/stop.sh
```

## Fontos első beállítások

Traefik dashboard jelszó:

```bash
htpasswd -nbB admin 'change-this-password' | sed -e 's/\$/\$\$/g'
```

Az eredményt tedd a `.env` fájl `TRAEFIK_DASHBOARD_AUTH` értékébe.

Plex első beállítás:

1. Indítsd el a stacket.
2. Nyisd meg a Plex webes felületét a beállított `PLEX_HOST` címen, vagy helyi hálóról: `http://<server-ip>:32400/web`.
3. Jelentkezz be a Plex fiókoddal, majd a webes varázslóban add hozzá a szervert.

## Hasznos dokumentáció

- [Ubuntu setup](docs/ubuntu-server-setup.md)
- [Cloudflare Tunnel](docs/cloudflare-tunnel.md)
- [Saját appok hostolása](docs/custom-apps.md)

## Biztonsági megjegyzések

- A `config/cloudflared/credentials.json` és a `.env` ne kerüljön GitHubra.
- A Portainer, Sonarr, Radarr, qBittorrent és File Browser saját belépési védelmét első indítás után állítsd be.
- A Traefik dashboard basic auth mögött van.
- Publikus internetre csak azokat a hostneveket route-old, amelyeket tényleg el akarsz érni.
