# [constants]
# maybe used by python env, so use -gx
set -gx JST_DATA_HOME "$HOME/.local/share/jst"
set -gx JST_CACHE_HOME "$HOME/.cache/jst"
set -gx JST_CONFIG_HOME "$HOME/.config/jst"

set -g JST_MESSAGE_FILE "$JST_CACHE_HOME/__m.txt"
set -g JST_MESSAGE_CMP_FILE "$JST_CACHE_HOME/__m_cmp.txt"

set -gx JST_CONFIG_FILE "$HOME/.config/jst/config.fish"
set -g JST_DOWNLOADS_DIR "$JST_DATA_HOME/dl"

set -g JST_VER "0.2.0"
set -g JST_PATH "$(status dirname)"
set -g JST_FISH_CONFIG_FILE "$HOME/.config/fish/config.fish"

function __jst.user-rel
    string replace -- "$HOME/" "" $argv
end

function __jst.try-mkdir
    if not test -e "$argv"; command mkdir -p "$argv"; end
end

function __jst.init-homes
    __jst.try-mkdir $JST_DATA_HOME
    __jst.try-mkdir $JST_CACHE_HOME
    __jst.try-mkdir $JST_CONFIG_HOME
    __jst.try-mkdir $JST_DOWNLOADS_DIR
    if not test -e "$JST_CONFIG_FILE"
        command touch "$JST_CONFIG_FILE"
        echo "set -g JST_USER_HOST julyfun@47.103.61.134" >> $JST_CONFIG_FILE
        echo "set -g JST_EDITORS nvim vim vi code cursor zed" >> $JST_CONFIG_FILE
    end
end

function __jst.get-editor
    for x in $JST_EDITORS
        command -q $x
        and echo $x && return
    end
    echo (__jst.err)None of `$JST_EDITORS` exists.(__jst.off)
end

__jst.init-homes

function __jst.dist
end

function __jst.try-load-config
    if test -e "$JST_CONFIG_FILE"
        source "$JST_CONFIG_FILE"
    end
end

__jst.try-load-config

# usage: echo (__jst.err)"error:"(__jst.off)
function __jst.ok
    set_color green --bold 2> /dev/null
end

function __jst.err
    set_color red --bold 2> /dev/null
end

function __jst.off
    set_color normal 2> /dev/null
end

function __jst.under
    set_color --underline 2> /dev/null
end

function __jst.yellow
    set_color yellow 2> /dev/null
end

function __jst.green
    set_color green 2> /dev/null
end

function __jst.gray
    set_color brwhite 2> /dev/null
end

function __jst.dim
    set_color -d 2> /dev/null
end

function __jst.no-subcommand
    echo (__jst.err)"error:"(__jst.off)\
        unrecognized subcommand \'(__jst.yellow)$argv[1](__jst.off)\'
end

function __jst.parent-no-sub
    echo (__jst.err)"error:"(__jst.off)\
        unrecognized subcommand \'(__jst.yellow)$argv[2](__jst.off)\'
end

# [base and math]
function __jst.length-of-longest-line
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

function __jst.git-log-graph-merge-layer-char
    # [todo] limit depth to avoid too deep merge layer
    __jst.length-of-longest-line (git --no-pager log --graph --format=format:'' --all)
end

# [utils function]
function __jst.os
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

function __jst.os-releases -d '[todo]'
end

function __jst.copy
    switch (__jst.os)
    case Linux
        xclip -se c
    case WSL
        powershell.exe -c '$input | Set-Clipboard'
    case Darwin
        pbcopy
    end
end

function __jst.paste
    switch (__jst.os)
    case Linux
        xclip -o -se c
    case WSL
        powershell.exe -c Get-Clipboard
    case Darwin
        pbpaste
    end
end

function __jst.stat-y
    switch (uname)
    case Linux
        stat -c "%Y" $argv[1]
    case Darwin
        stat -f "%m" $argv[1]
    end
end

function __jst.file-eq
    if test ! -e $argv[1] -o ! -e $argv[2]
        echo 0
    else if test (__jst.stat-y $argv[1]) -eq (__jst.stat-y $argv[2])
        echo 1
    else
        echo 0
    end
end

function __jst.get-latest-file
    ls -t $argv[1] | head -n 1
end

function __jst.default-pic-dir
    echo ~/Pictures/Screenshots
end

function __jst.eval
    ssh $JST_USER_HOST "eval $argv"
end

function __jst.fish
    echo "$argv"
    ssh $JST_USER_HOST "fish -c \"$argv\""
end

function __jst.upload
    if test -z $argv[2]
        # -p to preserve time
        scp -pr $argv[1] $JST_USER_HOST:"~/$(__jst.user-rel $JST_CACHE_HOME)"
    else
        scp -pr $argv[1] $JST_USER_HOST:"~/$(__jst.user-rel $JST_CACHE_HOME)/$argv[2]"
    end
end

function __jst.download
    if test -z $argv[2]
        scp -pr $JST_USER_HOST:"~/$(__jst.user-rel $JST_CACHE_HOME)/$argv[1]" .
    else
        scp -pr $JST_USER_HOST:"~/$(__jst.user-rel $JST_CACHE_HOME)/$argv[1]" $argv[2]
    end
end

function __jst.echo-list-as-file
    for i in $argv
        echo $i
    end
end

function __jst.upload-a-message
    if test -z $argv
        # this will be a list
        set msg (__jst.paste)
    else
        set msg $argv
    end
    __jst.echo-list-as-file $msg
    __jst.echo-list-as-file $msg > $JST_MESSAGE_FILE
    scp -p $JST_MESSAGE_FILE {$JST_USER_HOST}:"~/$(__jst.user-rel $JST_MESSAGE_FILE)"
end

function __jst.download-a-message
    scp -p {$JST_USER_HOST}:"~/$(__jst.user-rel $JST_MESSAGE_FILE)" $JST_MESSAGE_CMP_FILE
     command mv "$JST_MESSAGE_CMP_FILE" "$JST_MESSAGE_FILE"
     __jst.copy-a-message
    # if test ! (__jst.file-eq ~/{$JST_MESSAGE_FILE} ~/$JST_MESSAGE_CMP_FILE ) -eq 1
    #     command mv ~/$JST_MESSAGE_CMP_FILE ~/$JST_MESSAGE_FILE
    #     __jst.copy-a-message
    # else
    #     echo "No new message. Stop copying." >&2
    # end
end

function __jst.copy-a-message
    cat $JST_MESSAGE_FILE
    cat $JST_MESSAGE_FILE | __jst.copy
end


function __jst.upload-screenshot
    set latest_screenshot (__jst.get-latest-file (__jst.default-pic-dir))
    __jst.upload (__jst.default-pic-dir)/{$latest_screenshot} .
end

function __jst.download-latest
    set latest_file (__jst.eval '__jst.get-latest-file \$JST_CACHE_HOME')
    __jst.download $latest_file $argv[1]
end

# [network]
function __jst.open-link
    switch (__jst.os)
    case Darwin
        command open "$argv"
    case Linux
        command xdg-open "$argv"
    case WSL
        cmd.exe /c start $argv
    end
end

function __jst.git-branch
    echo (command git rev-parse --abbrev-ref HEAD)
end

function __jst.git-rel-link
    set pwd (pwd)
    set root (command git rev-parse --show-toplevel)
    set branch (__jst.git-branch)
    # 一个 +1 是 `/` 还有一个是因为 string sub -s 下标从 1 而不是 0 开始
    set relative (string sub -s (math (string length $root) + 2) $pwd)
    set relative_arg (string join -n '/' $relative "$argv")
    echo $relative_arg
end

function __jst.get-last-word
    set -l input_str $argv
    set -l last_word (string match -ra '[a-zA-Z]+' -- $input_str)[-1]
    echo $last_word
end

# too slow
function __jst.git-remote-default-branch
    set show (git remote show origin)
    __jst.get-last-word $show[4]
end

function __jst.github-link
    # 都没空格
    set branch (__jst.git-branch)
    set relative_arg (__jst.git-rel-link "$argv")
    if test \( -z $relative_arg \) -a \( $branch = main -o $branch = master \)
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
