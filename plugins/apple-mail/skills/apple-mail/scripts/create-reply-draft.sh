#!/bin/bash
# Create a draft reply to an existing email
# Usage: ./create-reply-draft.sh <message_id> <body> [reply_all] [account] [mailbox]
# Output: Success or error message

MESSAGE_ID="${1:-}"
BODY="${2:-}"
REPLY_ALL="${3:-false}"
ACCOUNT="${4:-}"
MAILBOX="${5:-INBOX}"
TIMEOUT_SECONDS="${OSA_TIMEOUT_SECONDS:-20}"

if [ -z "$MESSAGE_ID" ]; then
    echo "ERROR:Message ID is required"
    exit 1
fi

if [ -z "$BODY" ]; then
    echo "ERROR:Reply body is required"
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

# Build reply command
if [ "$REPLY_ALL" = "true" ]; then
    REPLY_COMMAND="reply theMessage with opening window and reply to all"
else
    REPLY_COMMAND="reply theMessage with opening window"
fi

# Escape the body for AppleScript - handle quotes and newlines
ESCAPED_BODY=$(echo "$BODY" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' '\r' | sed 's/\r/" \& return \& "/g')

osascript -e "
with timeout of $TIMEOUT_SECONDS seconds
tell application \"Mail\"
    try
        set theMailbox to $ACCOUNT_PART
        set theMessage to (first message of theMailbox whose id is $MESSAGE_ID)

        set replyMessage to $REPLY_COMMAND

        -- Set the reply body content (the quoted original will appear below in the compose window)
        set content of replyMessage to \"$ESCAPED_BODY\"

        return \"Draft reply created successfully\"
    on error errMsg number errNum
        if errNum is -1712 then
            return \"ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds\"
        end if
        return \"ERROR:\" & errMsg
    end try
end tell
end timeout
"
