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
set -g mfa_message_path .mfa/tmp/message 
set -g mfa_user_host julyfun@mfans.fans

function mfa.home
    echo (ssh $mfa_user_host 'eval echo ~$USER')
end

function mfa.upload-a-message
    mfa.paste > ~/$mfa_message_path 
    scp ~/$mfa_message_path {$mfa_user_host}:(mfa.home)/{$mfa_message_path}
end

function mfa.download-a-message
    scp {$mfa_user_host}:(mfa.home)/{$mfa_message_path} ~/$mfa_message_path
    cat ~/$mfa_message_path | mfa.copy
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

