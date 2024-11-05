#!/bin/bash

# Define directories and files
REPORT_DIR="report"
LOG_DIR="/home/dgct/public_html/sites/default"
SUMMARY_FILE="$REPORT_DIR/summary_report.txt"
SSH_LOG_FILE="$REPORT_DIR/ssh_log.txt"
FILE_CHANGE_LOG="$REPORT_DIR/file_changes_log.txt"

# Create the report directory if it doesn't exist
mkdir -p "$REPORT_DIR"

# 1. Collect SSH Logs from the Last 2 Weeks for All Users using journalctl
echo "Collecting SSH login logs for all users from the last 2 weeks..."
sudo journalctl -u ssh --since "2 weeks ago" > "$SSH_LOG_FILE"
echo "SSH logs for all users from the last 2 weeks collected in $SSH_LOG_FILE."

# 2. Analyze SSH Logs for Summary
# Count successful and failed login attempts
SUCCESSFUL_LOGINS=$(grep "Accepted" "$SSH_LOG_FILE" | wc -l)
FAILED_LOGINS=$(grep "Failed" "$SSH_LOG_FILE" | wc -l)

# Extract unique IP addresses from the SSH logs
IP_ADDRESSES=$(grep -Eo "([0-9]{1,3}\.){3}[0-9]{1,3}" "$SSH_LOG_FILE" | sort -u)

# 3. Find Files Changed in the Last 2 Weeks in the Target Directory
echo "Finding files modified in the last 2 weeks in $LOG_DIR..."
find "$LOG_DIR" -type f -mtime -14 -ls > "$FILE_CHANGE_LOG"
echo "File changes from the last 2 weeks recorded in $FILE_CHANGE_LOG."

# 4. Generate Summary Report
echo "Generating summary report..."

# Write SSH login summary to the summary file
echo "SSH Login Summary (Last 2 Weeks):" > "$SUMMARY_FILE"
echo "---------------------------------" >> "$SUMMARY_FILE"
echo "Total SSH Login Attempts: $((SUCCESSFUL_LOGINS + FAILED_LOGINS))" >> "$SUMMARY_FILE"
echo "Successful SSH Logins: $SUCCESSFUL_LOGINS" >> "$SUMMARY_FILE"
echo "Failed SSH Logins: $FAILED_LOGINS" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# List unique IP addresses from SSH logs
echo "IP Addresses (Last 2 Weeks):" >> "$SUMMARY_FILE"
echo "---------------------------" >> "$SUMMARY_FILE"
if [ -z "$IP_ADDRESSES" ]; then
    echo "No IP addresses found in SSH logs." >> "$SUMMARY_FILE"
else
    echo "$IP_ADDRESSES" >> "$SUMMARY_FILE"
fi
echo "" >> "$SUMMARY_FILE"

# Count the number of file changes recorded in the last 2 weeks
FILE_CHANGE_COUNT=$(wc -l < "$FILE_CHANGE_LOG")
echo "File Changes Summary (Last 2 Weeks):" >> "$SUMMARY_FILE"
echo "-----------------------------------" >> "$SUMMARY_FILE"
echo "Total Files Modified: $FILE_CHANGE_COUNT" >> "$SUMMARY_FILE"

echo "Detailed logs can be found in the report directory."

# 5. Display summary
cat "$SUMMARY_FILE"

echo "Report generation completed. Summary available in $SUMMARY_FILE."
