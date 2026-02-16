#!/bin/bash
# Mark an email as unread
# Usage: ./mark-unread.sh <message_id> [account] [mailbox]
# Output: Success or error message

MESSAGE_ID="${1:-}"
ACCOUNT="${2:-}"
MAILBOX="${3:-INBOX}"
TIMEOUT_SECONDS="${OSA_TIMEOUT_SECONDS:-20}"

if [ -z "$MESSAGE_ID" ]; then
    echo "ERROR:Message ID is required"
    exit 1
fi

# Build the account/mailbox part
if [ -n "$ACCOUNT" ]; then
    if [ "$MAILBOX" = "INBOX" ]; then
        ACCOUNT_PART="inbox of account \"$ACCOUNT\""
    else
        ACCOUNT_PART="mailbox \"$MAILBOX\" of account \"$ACCOUNT\""
    fi
else
    if [ "$MAILBOX" = "INBOX" ]; then
        ACCOUNT_PART="inbox"
    else
        ACCOUNT_PART="mailbox \"$MAILBOX\""
    fi
fi

osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    try
        set theMailbox to $ACCOUNT_PART
        set theMessage to (first message of theMailbox whose id is $MESSAGE_ID)
        set read status of theMessage to false
        return "Message marked as unread"
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
end tell
end timeout
EOF
