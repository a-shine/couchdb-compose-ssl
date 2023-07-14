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
4. Create a `docker-compose.secret.yml` file. This file is ignored by Git and
   should never be committed to the repository. The file should contain the
   following:

   ```yaml
   # docker-compose.secret.yml
   version: "3"
   services:
      couchdb:
         environment:
            - COUCHDB_USER=[ADMIN_USERNAME]
            - COUCHDB_PASSWORD=[ADMIN_PASSWORD]
      
      # Optionally configure a backup folder for Google Drive if you wish to use
      # the couchdb-backup service (see Configuring backups with Google Drive 
      # below)
      couchdb-backup:
         environment:
            - DRIVE_FOLDER_ID=[FOLDER_ID]
   ```

5. Start the services using the following command:

   ```bash
   docker compose -f docker-compose.yml -f docker-compose.oolong.yml -f docker-compose.secret.yml up -d
   ```

   The `-d` flag will run the services in the background. To see the logs, omit
   the flag.

### Configuring backups with Google Drive

If you do not wish to use the backup service, you can skip this section *and*
comment out the `couchdb-backup` service in the `docker-compose.oolong yml`
file.

1. Create a new project in the [Google Cloud
   Console](https://console.cloud.google.com/).
2. Activate the Google Drive API for the project by navigating to the API
   Library and searching for "Google Drive API".
3. Create a service account for the project by navigating to the Service
   Accounts page and clicking on "Create Service Account". Give the account a
   name and click on "Create".
4. Create a key for the service account by clicking on "Create Key" and
   selecting "JSON" as the key type. Save the key file in the root of the
   repository as `credentials.json`.
5. **Share the Google Drive folder in your account, where you would like to
   store the backups with the email address of the service account.** By
   default, any file uploaded using the service account will be owned by the
   service account and not visible to your account.
6. Copy the ID of the shared folder and add it to the
   `docker-compose.secrets.yml` file. The URL of the shared folder shows the ID
   and should look like this:
   `https://drive.google.com/drive/folders/[FOLDER_ID]`

### Setting up a new user

Run the following interactive script to create a new user:

```bash
./create-user.sh
```
