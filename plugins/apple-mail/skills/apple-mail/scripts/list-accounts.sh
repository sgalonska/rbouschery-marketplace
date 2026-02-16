#!/bin/bash
# List all email accounts configured in Apple Mail
# Usage: ./list-accounts.sh
# Output: Comma-separated list of account names

TIMEOUT_SECONDS="${OSA_TIMEOUT_SECONDS:-20}"

osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    set accountList to {}
    try
        repeat with acc in accounts
            set end of accountList to name of acc
        end repeat
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
    return accountList
end tell
end timeout
EOF
