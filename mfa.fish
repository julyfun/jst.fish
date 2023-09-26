# [constants]
set -g mfa_tmp_dir .mfa/tmp
set -g mfa_message_path .mfa/tmp/message 
set -g mfa_message_cmp_path .mfa/tmp/message_cmp
set -g mfa_user_host julyfun@mfans.fans

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

function mfa.stat-y
    switch (uname)
    case Linux
        stat -c "%Y" $argv[1]
    case Darwin
        stat -f "%m" $argv[1]
    end
end

function mfa.file-eq
    if test ! -e $argv[1] -o ! -e $argv[2]
        echo 0
    else if test (mfa.stat-y $argv[1]) -eq (mfa.stat-y $argv[2])
        echo 1
    else
        echo 0
    end
end

function mfa.get-latest-file
    ls -t $argv[1] | head -n 1
end

function mfa.default-pic-dir
    echo ~/Pictures/Screenshots
end

# [mfans function]
function mfa.init
    command mkdir -p $HOME/.mfa
    command mkdir -p $HOME/.mfa/tmp
end

function mfa.cmd
    echo (ssh $mfa_user_host "eval $argv")
end

function mfa.home
    echo (ssh $mfa_user_host 'eval echo ~$USER')
end

function mfa.path
    set remote_path (string replace -a ' ' '\\ ' -- (mfa.home)/$mfa_tmp_dir/$argv[1])
    echo {$mfa_user_host}:"$remote_path"
end

function mfa.upload
    if test -z $argv[2]
        scp -p $argv[1] (mfa.path .) 
    else
        scp -p $argv[1] (mfa.path $argv[2])
    end
end

function mfa.download
    if test -z $argv[2]
        scp -p (mfa.path $argv[1]) .
    else
        scp -p (mfa.path $argv[1]) $argv[2]
    end
end

function mfa.upload-a-message
    mfa.paste > ~/$mfa_message_path 
    scp -p ~/$mfa_message_path {$mfa_user_host}:(mfa.home)/{$mfa_message_path}
end

function mfa.download-a-message
    scp -p {$mfa_user_host}:(mfa.home)/{$mfa_message_path} ~/$mfa_message_cmp_path
    if test ! (mfa.file-eq ~/{$mfa_message_path} ~/$mfa_message_cmp_path ) -eq 1
        command mv ~/$mfa_message_cmp_path ~/$mfa_message_path
        cat ~/$mfa_message_path | mfa.copy
    else
        echo "No new message. Stop copying." >&2
    end
end

function mfa.upload-screenshot
    set latest_screenshot (mfa.get-latest-file (mfa.default-pic-dir))
    mfa.upload (mfa.default-pic-dir)/{$latest_screenshot} .
end

function mfa.download-latest
    set latest_file (mfa.cmd 'mfa.get-latest-file ~/$mfa_tmp_dir')
    mfa.download $latest_file $argv[1] 
end

# [network]
function mfa.open-link
    switch (uname)
    case Darwin
        open -a "Google Chrome" $argv
    case Linux
        xdg-open $argv
    end
end

function mfa.github-link
    git remote -v | string match -rq 'github\.com:(?<remote>[\S]+)\.git'
    string join '' "https://github.com/" $remote
end

function mfa
    switch $argv[1]
    case upa
        mfa.upload-a-message $argv[2..-1]
    case dla
        mfa.download-a-message $argc[2..-1]
    case init
        mfa.init $argv[2..-1]
    case ups
        mfa.upload-screenshot $argv[2..-1]
    case dll
        mfa.download-latest $argv[2..-1]
    case up
        mfa.upload $argv[2..-1]
    case dl
        mfa.download $argv[2..-1]
    case '*'
        echo mfa: \'$argv\' is not a mfa command.
        functions mfa
    end
end

