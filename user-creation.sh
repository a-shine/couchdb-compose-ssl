#!/bin/bash

read -p "CouchDB host (e.g., http://localhost:5984): " COUCHDB_HOST
read -p "Admin username: " ADMIN_USERNAME
read -s -p "Admin password: " ADMIN_PASSWORD
echo

read -p "New user email: " USERNAME
read -s -p "New user password: " PASSWORD
echo

read -p "New user first name: " FIRST_NAME
read -p "New user last name: " LAST_NAME
echo

USER_METADATA='{"first_name": "'$FIRST_NAME'", "last_name": "'$LAST_NAME'"}'

# Create the user document
USER_DOC='{"_id": "org.couchdb.user:'$USERNAME'", "name": "'$USERNAME'", "password": "'$PASSWORD'", "roles": [], "type": "user", "metadata": '$USER_METADATA'}'

# Send a POST request to create the user document
echo "$COUCHDB_HOST/couch/_users"
curl --insecure -X POST -H "Content-Type: application/json" -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" -d "$USER_DOC" "$COUCHDB_HOST/couch/_users"

# Create user tasks database
USER_DATABASE="userdb-$(echo -n "$USERNAME" | xxd -p)-tasks"
curl --insecure -X PUT -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" "$COUCHDB_HOST/couch/$USER_DATABASE"

# Assign user as a member and administrator of the user database
MEMBER_DOC='{"admins": {"names": ["'$USERNAME'"], "roles": ["_admin"]}, "members": {"names": ["'$USERNAME'"], "roles": []}}'
curl --insecure -X PUT -H "Content-Type: application/json" -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" -d "$MEMBER_DOC" "$COUCHDB_HOST/couch/$USER_DATABASE/_security"
