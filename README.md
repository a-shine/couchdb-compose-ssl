# Hosting Oolong

This repository contains a Docker Compose configuration to serve and self-host
the [a-shine/oolong](https://github.com/a-shine/oolong) application.

This configuration:

- Provides a CLI tool to easily configure a custom domain
- Automatically obtains and renews Let's Encrypt SSL/TLS certificates for the
  domain
- Configures an NGINX server to be used as a reverse proxy for the Oolong
  frontend and CouchDB backend (all orchestrated by Docker Compose)

The repository is built on the fantastic work published at:
[evgeniy-khist/letsencrypt-docker-compose](https://github.com/evgeniy-khist/letsencrypt-docker-compose).

## Setup

1. Clone this repository on the server where you want to host Oolong (usually a
   VPS with a static hostname/IP).
2. Create and configure DNS records to associate the domain name with your
   machine (typically using `A` records to associate domain hostname with an
   IPv4 address or `CNAME` to alias the custom domain to the current hostname of
   the machine).
3. Run through the configuration CLI tool by executing the following command at
   the root of the repo:

   ```bash
    docker compose run --rm cli
   ```

   This will allow you to configure the domain name and email address to use for
   the Let's Encrypt certificates.
4. Create a `docker-compose.secret.yml` file to store the secrets used by the
   configuration. This file is ignored by Git and should never be committed to
   the repository. The file should contain the following:

   ```yaml
    # docker-compose.secret.yml
    version: "3"
    services:
     couchdb:
       environment:
         - COUCHDB_USER=[ADMIN_USERNAME]
         - COUCHDB_PASSWORD=[ADMIN_PASSWORD]
   ```

5. Start the services using the following command:

   ```bash
    docker-compose -f docker-compose.yml -f docker-compose.oolong.yml -f docker-compose.secret.yml up -d
   ```

   The `-d` flag will run the services in the background. To see the logs, omit
   the flag.
