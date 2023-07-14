import os
import datetime
import tarfile
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload
from google.oauth2 import service_account


# Set the path to the folder you want to back up
SOURCE_DATA = "/opt/couchdb/data"

# Set the path to the temporary backup directory
BACKUP_DIR = "/opt/couchdb_bk"

# Set the ID of the folder in Google Drive where you want to upload the backup
DRIVE_FOLDER_ID = os.getenv("DRIVE_FOLDER_ID")

# Set the path to your Google Drive API credentials file (JSON format)
SERVICE_ACCOUNT_CREDENTIALS_FILE = "/app/credentials.json"

# Define the required OAuth scope(s)
SCOPES = ["https://www.googleapis.com/auth/drive"]


def get_or_create_backup_dir():
    os.makedirs(BACKUP_DIR, exist_ok=True)
    return BACKUP_DIR


def authenticate():
    # Load the service account credentials
    credentials = service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_CREDENTIALS_FILE, scopes=SCOPES
    )
    return credentials


def create_compressed_backup(backup_dir, source_data_path):
    timestamp = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
    bk_name = f"backup_{timestamp}"

    # Create a tar.gz archive of the folder
    archive_path = os.path.join(backup_dir, f"{bk_name}.tar.gz")
    with tarfile.open(archive_path, "w:gz") as tar:
        tar.add(source_data_path, arcname=os.path.basename(source_data_path))

    return archive_path


def upload_to_google_drive(file_path):
    credentials = authenticate()

    # Load Google Drive API credentials
    creds = build("drive", "v3", credentials=credentials)

    # Create a media upload instance
    media = MediaFileUpload(file_path, mimetype="application/gzip")

    # Create a file metadata with the name and parent folder ID
    file_metadata = {"name": os.path.basename(file_path), "parents": [DRIVE_FOLDER_ID]}

    # Upload the file to Google Drive
    creds.files().create(body=file_metadata, media_body=media).execute()


def cleanup_local(backup_dir):
    # Remove the any files in the backup folder older than 3 days
    for f in os.listdir(backup_dir):
        f_path = os.path.join(backup_dir, f)
        if os.stat(f_path).st_mtime < datetime.datetime.now().timestamp() - 3 * 86400:
            os.remove(f_path)


def cleanup_drive():
    credentials = authenticate()

    # Load Google Drive API credentials
    creds = build("drive", "v3", credentials=credentials)

    # List all files in the folder
    files = (
        creds.files()
        .list(
            q=f"'{DRIVE_FOLDER_ID}' in parents and trashed=false",
            fields="files(id, name, modifiedTime)",
        )
        .execute()
    )

    # Delete any files older than 3 days
    for f in files["files"]:
        modified_time = datetime.datetime.fromisoformat(f["modifiedTime"][:-1])
        if modified_time < datetime.datetime.now() - datetime.timedelta(days=3):
            creds.files().delete(fileId=f["id"]).execute()


def main():
    start_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{start_time}] Starting backup...")

    backup_dir = get_or_create_backup_dir()

    try:
        # Backup the folder
        archive_path = create_compressed_backup(backup_dir, SOURCE_DATA)

        # Upload the backup to Google Drive
        upload_to_google_drive(archive_path)
    except Exception as e:
        print(f"An error occurred during backup: {str(e)}")
        return

    print("Backup uploaded successfully.")

    print("Cleaning up old backups...")
    cleanup_local(backup_dir)
    cleanup_drive()

    end_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{end_time}] Done.")


if __name__ == "__main__":
    main()
