# https://stackoverflow.com/questions/37458287/how-to-run-a-cron-job-inside-a-docker-container

# Base image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Install cron
RUN apt-get update && apt-get -y install cron

# Copy the cron file to the cron.d directory
COPY backup-cron /etc/cron.d/backup-cron

# Copy and install the requirements
COPY requirements.txt /app/
RUN pip install -r requirements.txt

# Copy the program files to the container
COPY main.py /app/
COPY run_backup_job.sh /app/
RUN chmod +x /app/run_backup_job.sh

# Give execution rights to the cron job
RUN chmod 0644 /etc/cron.d/backup-cron

# Apply the cron job
RUN crontab /etc/cron.d/backup-cron

# Create the log file to be able to run tail
RUN touch /var/log/cron.log

# Run cron in the foreground
CMD printenv > /etc/environment && cron && tail -f /var/log/cron.log
