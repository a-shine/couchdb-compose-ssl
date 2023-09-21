#!/bin/bash

# Make sure to use route domain as the script appends the /couch path!
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

# Ask user for insecure mode setting with a default to secure
read -p "Do you want to use insecure mode? (y/N): " INSECURE_MODE
INSECURE_FLAG=""
if [[ "$INSECURE_MODE" == "y" ]]; then
  INSECURE_FLAG="--insecure"
fi
echo

USER_METADATA='{"first_name": "'$FIRST_NAME'", "last_name": "'$LAST_NAME'"}'

# Create the user document
USER_DOC='{"_id": "org.couchdb.user:'$USERNAME'", "name": "'$USERNAME'", "password": "'$PASSWORD'", "roles": [], "type": "user", "metadata": '$USER_METADATA'}'


# Send a POST request to create the user document
echo "$COUCHDB_HOST/couch/_users"
curl $INSECURE_FLAG -X POST -H "Content-Type: application/json" -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" -d "$USER_DOC" "$COUCHDB_HOST/couch/_users"

# Create user tasks database
USER_TASK_DATABASE="userdb-$(echo -n "$USERNAME" | xxd -p)-tasks"
curl $INSECURE_FLAG -X PUT -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" "$COUCHDB_HOST/couch/$USER_TASK_DATABASE"

# Create user workspace database
USER_WORKSPACE_DATABASE="userdb-$(echo -n "$USERNAME" | xxd -p)-workspaces"
curl $INSECURE_FLAG -X PUT -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" "$COUCHDB_HOST/couch/$USER_WORKSPACE_DATABASE"

# Assign user as a member and administrator of the user's task database
MEMBER_DOC='{"admins": {"names": ["'$USERNAME'"], "roles": ["_admin"]}, "members": {"names": ["'$USERNAME'"], "roles": []}}'
curl $INSECURE_FLAG -X PUT -H "Content-Type: application/json" -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" -d "$MEMBER_DOC" "$COUCHDB_HOST/couch/$USER_TASK_DATABASE/_security"

# Assign user as a member and administrator of the user's workspace database
MEMBER_DOC='{"admins": {"names": ["'$USERNAME'"], "roles": ["_admin"]}, "members": {"names": ["'$USERNAME'"], "roles": []}}'
curl $INSECURE_FLAG -X PUT -H "Content-Type: application/json" -u "$ADMIN_USERNAME:$ADMIN_PASSWORD" -d "$MEMBER_DOC" "$COUCHDB_HOST/couch/$USER_WORKSPACE_DATABASE/_security"
