docker-reposado
===============

Docker container to run [Reposado](https://github.com/wdas/reposado) and [Margarita](https://github.com/jessepeterson/margarita) to serve softwareupdates using nginx.

### Environment Variables

Variable | Default | Note
--- | --- | ---
LOCALCATALOGURLBASE | http://reposado:8080 | Base URL for repo
MINOSVERSION | | Minimum minor OS version to mirror updates for. _(ie. 10.12.X = 12)_
USERNAME | admin | Margarita username
PASSWORD | password | Margarita password
PORT | 8080 | Port reposado listens on
LISTEN_PORT | 8089 | Port margarita listens on

## Sample Usage

First we would want to set up a persistent storage location for reposado, for example:

```
mkdir -p /var/docker/reposado/html /var/docker/reposado/metadata
chmod -R 777 /var/docker/reposado
```

We can now setup the master container that runs both margarita and hosts reposado.  For example:

```
docker run -d --name reposado \
    -v /var/docker/reposado/html:/reposado/html \
    -v /var/docker/reposado/metadata:/reposado/metadata \
    -e USERNAME=admin \
    -e PASSWORD='password' \
    -p 8080:8080 \
    -p 8089:8089 \
    --restart always \
    sphen/reposado
```

Nothing is in it! (in our example) so now we just interact with `repoutil` or `repo_sync` in a linked container.  You can schedule the command via cron/systemd or run it manually.  For example:

```
docker run --rm -it --volumes-from reposado --link reposado sphen/reposado python /reposado/code/repoutil --help
```

Or to actually trigger a mirror/update:

```
docker run --rm -it --volumes-from reposado --link reposado sphen/reposado python /reposado/code/repo_sync
```

By using `--volumes-from` and `--link` we are able to take and use settings from our master container.  Please take care that if you name your master container something other than **reposado** you will need to update these commands.

## What Else is There?

Well - if you are versed in docker you are on your way - but as a hint, if you want you can only serve reposado by excluding `-p 8089:8089` from the run command.  You may also serve on a different port than 8089 for margarita by changing `-p 8089:8089` to `-p 80:8089` for example.  There are other **environment variables** listed above that may help you tweak things.

### But I want HTTPS!!!!

Well, have fun tweaking the container within nginx and certs - or better yet maybe use something like [caddy-docker](https://github.com/abiosoft/caddy-docker) in front of it all with automatic lets-encrypt.

**Push Requests and feedback welcome!**
