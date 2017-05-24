#! /bin/sh

####
# DB Connection
##
# DB Username
DB_USER=""
# DB Password
DB_PASS=""

####
# DB Dump
##
# Dir where all DB dumps will be saved
DB_DUMP_DIR="/root/dbdumps"
# Suffix for saved dump file
DB_DUMP_FILE_SUFFIX="database.sql"
# Time in days how long dumps should be saved
DB_DUMP_SAVE_TIME="7"

# Create SQL Dump
mysqldump -u ${DB_USER} -p${DB_PASS} --all-databases > /tmp/${DB_DUMP_FILE_SUFFIX}

# create DB_DUMP_DIR if not exists
mkdir -p ${DB_DUMP_DIR}

# Compess with XZ
tar -cJf ${DB_DUMP_DIR}/`date +%Y%m%d_%H%M%S`_${DB_DUMP_FILE_SUFFIX}.tar.xz /tmp/${DB_DUMP_FILE_SUFFIX}

# Remove uncompressed file
rm -f /tmp/${DB_DUMP_FILE_SUFFIX}

# Remove compressed db dumps (older than)
find ${DB_DUMP_DIR} -name "*${DB_DUMP_FILE_SUFFIX_SUFFIX}.tar.xz" -mtime +${DB_DUMP_SAVE_TIME} -type f -delete
