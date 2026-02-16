#!/bin/bash
# Get recent emails from a mailbox
# Usage: ./get-emails.sh [account] [mailbox] [limit] [include_content] [unread_only]
# Output: id<<>>subject<<>>sender<<>>to<<>>cc<<>>bcc<<>>dateSent<<>>isRead<<>>content|||...

ACCOUNT="${1:-}"
MAILBOX="${2:-INBOX}"
LIMIT="${3:-10}"
INCLUDE_CONTENT="${4:-false}"
UNREAD_ONLY="${5:-false}"
TIMEOUT_SECONDS="${OSA_TIMEOUT_SECONDS:-20}"

# Build the AppleScript dynamically
if [ "$INCLUDE_CONTENT" = "true" ]; then
    CONTENT_PART='set msgContent to content of msg'
else
    CONTENT_PART='set msgContent to ""'
fi

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

if [ "$UNREAD_ONLY" = "true" ]; then
    MESSAGE_FILTER="(messages of theMailbox whose read status is false)"
else
    MESSAGE_FILTER="messages of theMailbox"
fi

osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    set results to ""
    try
        set theMailbox to $ACCOUNT_PART
        set msgList to $MESSAGE_FILTER
        set msgCount to count of msgList
        if msgCount > $LIMIT then set msgCount to $LIMIT

        repeat with i from 1 to msgCount
            set msg to item i of msgList
            set msgId to id of msg
            set msgSubject to subject of msg
            set msgSender to sender of msg
            set msgDate to date sent of msg
            set msgRead to read status of msg
            $CONTENT_PART

            -- Get recipients
            set toList to ""
            repeat with r in to recipients of msg
                set toList to toList & address of r & ","
            end repeat
            if toList is not "" then set toList to text 1 thru -2 of toList

            set ccList to ""
            repeat with r in cc recipients of msg
                set ccList to ccList & address of r & ","
            end repeat
            if ccList is not "" then set ccList to text 1 thru -2 of ccList

            set bccList to ""
            repeat with r in bcc recipients of msg
                set bccList to bccList & address of r & ","
            end repeat
            if bccList is not "" then set bccList to text 1 thru -2 of bccList

            set results to results & msgId & "<<>>" & msgSubject & "<<>>" & msgSender & "<<>>" & toList & "<<>>" & ccList & "<<>>" & bccList & "<<>>" & (msgDate as string) & "<<>>" & msgRead & "<<>>" & msgContent & "|||"
        end repeat
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
    return results
end tell
end timeout
EOF
