#!/bin/bash
# Send the front-most draft (compose window) in Apple Mail
# Usage: ./send-draft.sh
# Output: Success or error message

TIMEOUT_SECONDS="${OSA_TIMEOUT_SECONDS:-20}"

osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    try
        set outgoingCount to count of outgoing messages
        if outgoingCount is 0 then
            return "ERROR:No draft message found. Create a draft first using create-draft.sh or create-reply-draft.sh."
        end if

        set theDraft to outgoing message 1
        send theDraft

        return "Draft sent successfully"
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after $TIMEOUT_SECONDS seconds"
        end if
        return "ERROR:" & errMsg
    end try
end tell
end timeout
EOF
