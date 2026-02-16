#!/bin/bash
# Get unread email count
# Usage: ./get-unread-count.sh [account] [mailbox]
# Output: Number of unread emails

ACCOUNT="${1:-}"
MAILBOX="${2:-}"
TIMEOUT_SECONDS="${OSA_TIMEOUT_SECONDS:-20}"

if [ -n "$ACCOUNT" ] && [ -n "$MAILBOX" ]; then
    osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    try
        return unread count of mailbox "$MAILBOX" of account "$ACCOUNT"
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
end tell
end timeout
EOF
elif [ -n "$ACCOUNT" ]; then
    osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    try
        set total to 0
        repeat with mb in mailboxes of account "$ACCOUNT"
            set total to total + (unread count of mb)
        end repeat
        return total
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
end tell
end timeout
EOF
elif [ -n "$MAILBOX" ]; then
    osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    try
        set total to 0
        repeat with acc in accounts
            try
                set total to total + (unread count of mailbox "$MAILBOX" of acc)
            end try
        end repeat
        return total
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
end tell
end timeout
EOF
else
    osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    try
        set total to 0
        repeat with acc in accounts
            repeat with mb in mailboxes of acc
                set total to total + (unread count of mb)
            end repeat
        end repeat
        return total
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
end tell
end timeout
EOF
fi
