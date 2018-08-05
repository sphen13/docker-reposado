## docker-reposado

Docker container to run [Reposado][1] and [Margarita][2] to serve softwareupdates using nginx.

### Supported tags

- `latest`
- `saml`
  - Will include SAML enabled margarita

### Environment Variables

Variable | Default | Note
--- | --- | ---
LOCALCATALOGURLBASE | http://reposado:8080 | Base URL for repo
MINOSVERSION | | Minimum minor OS version to mirror updates for. _(ie. 10.12.X = 12)_
USERNAME | admin | Margarita username
PASSWORD | password | Margarita password
PORT | 8080 | Port reposado listens on
LISTEN_PORT | 8089 | Port margarita listens on
HUMANREADABLESIZES | False |
ONLYHOSTDEPRECATED | False | Only host deprecated items, point current updates directly to apple
ALWAYSREWRITEDISTRIBUTIONURLS | False | 

### Volumes

Path | Note
--- | ---
/reposado/html | Reposado html folder
/reposado/metadata | Reposado metadata folder
/app/saml | SAML configuration folder _(saml tag only)_

### Sample Usage

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

> **Note:** _the instructions below rely on you naming your docker container "reposado" specifically.  If not, linking your temporary containers to the master will not reference the configuration variables properly._

Nothing is in it! (in our example) so now we just interact with `repoutil` or `repo_sync` in a linked container.  You can schedule the command via cron/systemd or run it manually.  For example:

```
docker run --rm -it --volumes-from reposado --link reposado sphen/reposado python /reposado/code/repoutil --help
```

Or to actually trigger a mirror/update:

```
docker run --rm -it --volumes-from reposado --link reposado sphen/reposado python /reposado/code/repo_sync
```

By using `--volumes-from` and `--link` we are able to take and use settings from our master container.  Please take care that if you name your master container something other than **reposado** you will need to update these commands.

### SAML

The [Python SAML Toolkit][5] from OneLogin has been implemented for margarita if you pull the `saml` tag.  As margarita does not have a permissions structure built in, we are just looking for a valid SAML assertion for access (no attributes needed).

I am not going to walkthrough configuration here as it is very popular among other apps that implement SAML and the configuration is beyond the scope here.  If you want to use SAML you must take over the configuration within the `/app/saml` directory within the container.  The easiest would be to provide a mapped folder for this location and populate with your configuration.  The expected and example structure for this folder can be seen [at this link][4].

### What Else is There?

Well - if you are versed in docker you are on your way - but as a hint, if you want you can only serve reposado by excluding `-p 8089:8089` from the run command.  You may also serve on a different port than 8089 for margarita by changing `-p 8089:8089` to `-p 80:8089` for example.  There are other **environment variables** listed above that may help you tweak things.

### But I want HTTPS!!!!

Well, have fun tweaking the container within nginx and certs - or better yet maybe use something like [caddy-docker][3] in front of it all with automatic lets-encrypt.

**Push Requests and feedback welcome!**

[1]: https://github.com/wdas/reposado
[2]: https://github.com/jessepeterson/margarita
[3]: https://github.com/abiosoft/caddy-docker
[4]: https://github.com/sphen13/margarita/tree/6ef24b12892def6c7e3a77e302fce5d27a421c2d/saml
[5]: https://github.com/onelogin/python-saml
