#!/bin/bash
# List mailboxes/folders for a specific account or all accounts
# Usage: ./list-mailboxes.sh [account]
# Output: account:mailbox1, mailbox2|||account2:mailbox1, mailbox2|||...

ACCOUNT="${1:-}"
TIMEOUT_SECONDS="${OSA_TIMEOUT_SECONDS:-20}"

if [ -n "$ACCOUNT" ]; then
    osascript <<EOF
with timeout of $TIMEOUT_SECONDS seconds
tell application "Mail"
    set results to {}
    try
        set acc to account "$ACCOUNT"
        set mailboxList to {}
        repeat with mb in mailboxes of acc
            set end of mailboxList to name of mb
        end repeat
        return mailboxList
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
    osascript <<'EOF'
set timeoutSeconds to system attribute "OSA_TIMEOUT_SECONDS"
if timeoutSeconds is "" then set timeoutSeconds to "20"
with timeout of (timeoutSeconds as integer) seconds
tell application "Mail"
    set results to ""
    try
        repeat with acc in accounts
            set accName to name of acc
            set mailboxList to {}
            try
                repeat with mb in mailboxes of acc
                    set end of mailboxList to name of mb
                end repeat
            on error
                set mailboxList to {}
            end try
            set results to results & accName & ":" & (mailboxList as string) & "|||"
        end repeat
    on error errMsg number errNum
        if errNum is -1712 then
            return "ERROR:Apple Mail request timed out after " & timeoutSeconds & " seconds"
        end if
        return "ERROR:" & errMsg
    end try
    return results
end tell
end timeout
EOF
fi
