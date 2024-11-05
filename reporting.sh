#!/bin/bash

# Define directories and files
REPORT_DIR="report"
LOG_DIR="/home/dgct/public_html/sites/default"
SUMMARY_FILE="$REPORT_DIR/summary_report.txt"
SSH_LOG_FILE="$REPORT_DIR/ssh_log.txt"
FILE_CHANGE_LOG="$REPORT_DIR/file_changes_log.txt"

# Create the report directory if it doesn't exist
mkdir -p "$REPORT_DIR"

# 1. Collect SSH Logs from the Last 2 Weeks
echo "Collecting SSH login logs from the last 2 weeks..."
last -a | grep "ssh" | awk -v date="$(date --date='14 days ago' '+%Y-%m-%d')" '$NF >= date' > "$SSH_LOG_FILE"
echo "SSH logs from the last 2 weeks collected in $SSH_LOG_FILE."

# 2. Find Files Changed in the Last 2 Weeks in the Target Directory
echo "Finding files modified in the last 2 weeks in $LOG_DIR..."
find "$LOG_DIR" -type f -mtime -14 -ls > "$FILE_CHANGE_LOG"
echo "File changes from the last 2 weeks recorded in $FILE_CHANGE_LOG."

# 3. Generate Summary Report
echo "Generating summary report..."

# Count the number of SSH logins recorded in the last 2 weeks
SSH_LOG_COUNT=$(wc -l < "$SSH_LOG_FILE")
echo "SSH Logins Recorded in Last 2 Weeks: $SSH_LOG_COUNT" > "$SUMMARY_FILE"

# Count the number of file changes recorded in the last 2 weeks
FILE_CHANGE_COUNT=$(wc -l < "$FILE_CHANGE_LOG")
echo "File Changes Recorded in Last 2 Weeks: $FILE_CHANGE_COUNT" >> "$SUMMARY_FILE"

echo "Detailed logs can be found in the report directory."

# 4. Display summary
cat "$SUMMARY_FILE"

echo "Report generation completed. Summary available in $SUMMARY_FILE."
