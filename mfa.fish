# [constants]
# maybe used by python env, so use -gx
set -gx MFA_DATA_HOME "$HOME/.local/share/mfa"
set -gx MFA_CACHE_HOME "$HOME/.cache/mfa"
set -gx MFA_CONFIG_HOME "$HOME/.config/mfa"
set -gx MFA_CONFIG_FILE "$HOME/.config/mfa/config.fish"

set -g MFA_MESSAGE_FILE "$MFA_CACHE_HOME/__m.txt"
set -g MFA_MESSAGE_CMP_FILE "$MFA_CACHE_HOME/__m_cmp.txt"
set -g MFA_DOWNLOADS_DIR "$MFA_DATA_HOME/dl"

set -g MFA_JST_VER "0.2.0"
set -g MFA_JST_PATH "$(status dirname)"
set -g MFA_FISH_CONFIG_PATH "$HOME/.config/fish/config.fish"

function __mfa.user-rel
    string replace -- "$HOME/" "" $argv
end

function __mfa.try-mkdir
    if not test -e "$argv"; command mkdir -p "$argv"; end
end

function __mfa.init-homes
    __mfa.try-mkdir $MFA_DATA_HOME
    __mfa.try-mkdir $MFA_CACHE_HOME
    __mfa.try-mkdir $MFA_CONFIG_HOME
    __mfa.try-mkdir $MFA_DOWNLOADS_DIR
    if not test -e "$MFA_CONFIG_FILE"
        command touch "$MFA_CONFIG_FILE"
        echo "set -g MFA_USER_HOST julyfun@47.103.61.134" >> $MFA_CONFIG_FILE
        echo "set -g MFA_EDITORS nvim vim vi code cursor zed" >> $MFA_CONFIG_FILE
    end
end

function __mfa.get-editor
    for x in $MFA_EDITORS
        command -q $x
        and echo $x && return
    end
    echo (__mfa.err)None of `$MFA_EDITORS` exists.(__mfa.off)
end

__mfa.init-homes

function __mfa.try-load-config
    if test -e "$MFA_CONFIG_FILE"
        source "$MFA_CONFIG_FILE"
    end
end

__mfa.try-load-config

# usage: echo (__mfa.err)"error:"(__mfa.off)
function __mfa.ok
    set_color green --bold 2> /dev/null
end

function __mfa.err
    set_color red --bold 2> /dev/null
end

function __mfa.off
    set_color normal 2> /dev/null
end

function __mfa.under
    set_color --underline 2> /dev/null
end

function __mfa.yellow
    set_color yellow 2> /dev/null
end

function __mfa.green
    set_color green 2> /dev/null
end

function __mfa.gray
    set_color brwhite 2> /dev/null
end

function __mfa.dim
    set_color -d 2> /dev/null
end

function __mfa.no-subcommand
    echo (__mfa.err)"error:"(__mfa.off)\
        unrecognized subcommand \'(__mfa.yellow)$argv[1](__mfa.off)\'
end

function __mfa.parent-no-sub
    echo (__mfa.err)"error:"(__mfa.off)\
        unrecognized subcommand \'(__mfa.yellow)$argv[2](__mfa.off)\'
end

# [base and math]
function __mfa.length-of-longest-line
    set lines (string split \n $argv)
    set len 0
    for line in $lines
        set str_len (string length $line)
        if test $str_len -gt $len
            set len $str_len
        end
    end
    echo $len
end

function __mfa.git-log-graph-merge-layer-char
    # [todo] limit depth to avoid too deep merge layer
    __mfa.length-of-longest-line (git --no-pager log --graph --format=format:'' --all)
end

# [utils function]
function __mfa.os
    switch (uname)
    case Linux
        if grep -qEi "(wsl|microsoft)" /proc/version
            echo WSL
        else
            echo Linux
        end
    case Darwin
        echo Darwin
    end
end

function __mfa.os-releases -d '[todo]'
end

function __mfa.copy
    switch (__mfa.os)
    case Linux
        xclip -selection clipboard
    case WSL
        powershell.exe -c '$input | Set-Clipboard'
    case Darwin
        pbcopy
    end
end

function __mfa.paste
    switch (__mfa.os)
    case Linux
        xclip -o
    case WSL
        powershell.exe -c Get-Clipboard
    case Darwin
        pbpaste
    end
end

function __mfa.stat-y
    switch (uname)
    case Linux
        stat -c "%Y" $argv[1]
    case Darwin
        stat -f "%m" $argv[1]
    end
end

function __mfa.file-eq
    if test ! -e $argv[1] -o ! -e $argv[2]
        echo 0
    else if test (__mfa.stat-y $argv[1]) -eq (__mfa.stat-y $argv[2])
        echo 1
    else
        echo 0
    end
end

function __mfa.get-latest-file
    ls -t $argv[1] | head -n 1
end

function __mfa.default-pic-dir
    echo ~/Pictures/Screenshots
end

# [mfans function]
function __mfa.eval
    ssh $MFA_USER_HOST "eval $argv"
end

function __mfa.fish
    echo "$argv"
    ssh $MFA_USER_HOST "fish -c \"$argv\""
end

function __mfa.upload
    if test -z $argv[2]
        # -p to preserve time
        scp -pr $argv[1] $MFA_USER_HOST:"~/$(__mfa.user-rel $MFA_CACHE_HOME)"
    else
        scp -pr $argv[1] $MFA_USER_HOST:"~/$(__mfa.user-rel $MFA_CACHE_HOME)/$argv[2]"
    end
end

function __mfa.download
    if test -z $argv[2]
        scp -pr $MFA_USER_HOST:"~/$(__mfa.user-rel $MFA_CACHE_HOME)/$argv[1]" .
    else
        scp -pr $MFA_USER_HOST:"~/$(__mfa.user-rel $MFA_CACHE_HOME)/$argv[1]" $argv[2]
    end
end

function __mfa.echo-list-as-file
    for i in $argv
        echo $i
    end
end

function __mfa.upload-a-message
    if test -z $argv
        # this will be a list
        set msg (__mfa.paste)
    else
        set msg $argv
    end
    __mfa.echo-list-as-file $msg
    __mfa.echo-list-as-file $msg > $MFA_MESSAGE_FILE
    scp -p $MFA_MESSAGE_FILE {$MFA_USER_HOST}:"~/$(__mfa.user-rel $MFA_MESSAGE_FILE)"
end

function __mfa.download-a-message
    scp -p {$MFA_USER_HOST}:"~/$(__mfa.user-rel $MFA_MESSAGE_FILE)" $MFA_MESSAGE_CMP_FILE
     command mv "$MFA_MESSAGE_CMP_FILE" "$MFA_MESSAGE_FILE"
     __mfa.copy-a-message
    # if test ! (__mfa.file-eq ~/{$MFA_MESSAGE_FILE} ~/$MFA_MESSAGE_CMP_FILE ) -eq 1
    #     command mv ~/$MFA_MESSAGE_CMP_FILE ~/$MFA_MESSAGE_FILE
    #     __mfa.copy-a-message
    # else
    #     echo "No new message. Stop copying." >&2
    # end
end

function __mfa.copy-a-message
    cat $MFA_MESSAGE_FILE
    cat $MFA_MESSAGE_FILE | __mfa.copy
end


function __mfa.upload-screenshot
    set latest_screenshot (__mfa.get-latest-file (__mfa.default-pic-dir))
    __mfa.upload (__mfa.default-pic-dir)/{$latest_screenshot} .
end

function __mfa.download-latest
    set latest_file (__mfa.eval '__mfa.get-latest-file \$MFA_CACHE_HOME')
    __mfa.download $latest_file $argv[1]
end

# [network]
function __mfa.open-link
    switch (__mfa.os)
    case Darwin
        command open "$argv"
    case Linux
        command xdg-open "$argv"
    case WSL
        cmd.exe /c start $argv
    end
end

function __mfa.git-branch
    echo (command git rev-parse --abbrev-ref HEAD)
end

function __mfa.git-rel-link
    set pwd (pwd)
    set root (command git rev-parse --show-toplevel)
    set branch (__mfa.git-branch)
    # 一个 +1 是 `/` 还有一个是因为 string sub -s 下标从 1 而不是 0 开始
    set relative (string sub -s (math (string length $root) + 2) $pwd)
    set relative_arg (string join -n '/' $relative "$argv")
    echo $relative_arg
end

function __mfa.get-last-word
    set -l input_str $argv
    set -l last_word (string match -ra '[a-zA-Z]+' -- $input_str)[-1]
    echo $last_word
end

# too slow
function __mfa.git-remote-default-branch
    set show (git remote show origin)
    __mfa.get-last-word $show[4]
end

function __mfa.github-link
    # 都没空格
    set branch (__mfa.git-branch)
    set relative_arg (__mfa.git-rel-link "$argv")
    if test \( -z $relative_arg \) -a \( $branch = main -o $branch = master \)
        set remote_relative_arg ""
    else
        set remote_relative_arg (string join -n '/' tree "$branch" "$relative_arg")
    end
    # 避免和 fish 内定义的临时 git 名冲突
    command git remote -v | string match -rq 'github\.com:(?<user_repo>[\S]+)\.git'
    if test -z $user_repo
        command git remote -v | string match -rq '.*:(?<user_repo>[\S]+)\s'
    end
    echo (string join -n '/' "https://github.com" $user_repo $remote_relative_arg)
end
