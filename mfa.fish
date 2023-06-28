# [utils function]
function mfa.copy
    switch (uname)
    case Linux
        xclip -selection clipboard
    case Darwin
        pbcopy
    end
end


function mfa.paste
    switch (uname)
    case Linux
        xclip -o
    case Darwin
        pbpaste
    end
end

# [mfans function]
set -g mfa_message_path ~/.mfa/tmp/message 

function mfa.upload-a-message
    mfa.paste > $mfa_message_path 
    scp $mfa_message_path julyfun@mfans.fans:{$mfa_message_path}
end

function mfa.download-a-message
    scp julyfun@mfans.fans:{$mfa_message_path} $mfa_message_path
    cat $mfa_message_path | mfa.copy
end

function mfa.init
    mkdir -p $HOME/.mfa
    mkdir -p $HOME/.mfa/tmp
end

function mfa
    switch $argv[1]
    case upa
        mfa.upload-a-message $argv[2..-1]
    case dla
        mfa.download-a-message $argc[2..-1]
    case init
        mfa.init $argv[2..-1]
    end
end

