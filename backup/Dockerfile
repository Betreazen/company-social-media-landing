FROM mariadb:11.7-noble

# Upgrade system packages and install required packages
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y cron gzip && \
    rm -rf /var/lib/apt/lists/*

# Copy backup scripts from backup directory
COPY backup/backup.sh /usr/local/bin/backup.sh
RUN chmod +x /usr/local/bin/backup.sh

# Copy entrypoint script
COPY backup/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Create backup directory
RUN mkdir -p /backups

ENTRYPOINT ["/entrypoint.sh"]
CMD ["crond", "-f", "-l", "2"]
