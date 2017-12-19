docker-reposado
===============

Docker container to run reposado and margarita to serve softwareupdates using nginx.

sample usage.

```
docker run --rm -i -t sphen/reposado python /reposado/code/repoutil --help
```

To have persistent storage, use a volume container. Example:

```
docker run --rm -i -t --volumes-from reposado sphen/reposado python /reposado/code/repo_sync
```

You can schedule the above command via cron/systemd or run it manually.

### Environment Variables

Variable | Default | Note
--- | --- | ---
LOCALCATALOGURLBASE | http://reposado:8080 | Base URL for repo
MINOSVERSION | | Minimum minor OS version to mirror updates for. _(ie. 10.12.X = 12)_
USERNAME | admin | Margarita username
PASSWORD | password | Margarita password

## Margarita
[Margarita](https://github.com/jessepeterson/margarita) is also bundled in but is not accessible unless you do a port-mapping.

Within the container, port 80 is listening for margarita and port 8080 is listening for reposado.  Margarita can be accessible on any port you choose depending on your port mapping.

You can serve both reposado and margarita with something like:
```
docker run -d --name reposado \
    -v /var/docker/reposado/html:/reposado/html \
    -v /var/docker/reposado/metadata:/reposado/metadata \
    -p 80:80 \
    -p 8080:8080 \
    sphen/reposado
```

You can simply only serve reposado by excluding `-p 8080:8080`.  You may also serve on a different port than 80 for margarita by chnanging `-p 80:80` to `-p 8089:80` for example.
