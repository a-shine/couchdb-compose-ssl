# CouchDB compose configuration with automated SSL certificates

This repository contains a Docker Compose configuration, which automatically
obtains and renews Let's Encrypt SSL/TLS certificates for a CouchDB instance.

The repository is a fork of [evgeniy-khist/letsencrypt-docker-compose](https://github.com/evgeniy-khist/letsencrypt-docker-compose).

## Usage

1. Clone this repository on the server where you want to run CouchDB.
2. Add CouchDB override configuration and docker-compose.secret.yml (storing production secrets).
3. Setup SLL certificates with NGINx and Let's Encrypt using the instructions below.
4. Run CouchDB with SSL

   ```bash
    docker-compose -f docker-compose.yml -f docker-compose.secret.yml up -d
   ```

```conf
    # https://docs.couchdb.org/en/stable/best-practices/reverse-proxies.html#reverse-proxying-couchdb-in-a-subdirectory-with-nginx
    # https://github.com/apache/couchdb-fauxton/issues/1199
    location /couch {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_pass http://couchdb$uri;

        rewrite ^ $request_uri;
        rewrite ^/couch/(.*) /$1 break;
        proxy_redirect off;
        proxy_buffering off;
    }

     location /_session {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_pass http://couchdb/_session;

        proxy_redirect off;
        proxy_buffering off;
    }
```
