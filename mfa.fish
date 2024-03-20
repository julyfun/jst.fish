# [constants]
set -g MFA_TMP_DIR .mfa/tmp
set -g MFA_MESSAGE_PATH .mfa/tmp/message 
set -g MFA_MESSAGE_CMP_PATH .mfa/tmp/message_cmp
set -g MFA_USER_HOST julyfun@mfans.fans
set -g MFA_DOWNLOADS_DIR .mfa/dl

function __mfa.err
    set_color red --bold 2> /dev/null
end

function __mfa.off
    set_color normal 2> /dev/null
end

# [utils function]
function __mfa.copy
    switch (uname)
    case Linux
        xclip -selection clipboard
    case Darwin
        pbcopy
    end
end

function __mfa.paste
    switch (uname)
    case Linux
        xclip -o
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
function __mfa.init
    command mkdir -p $HOME/.mfa
    command mkdir -p $HOME/.mfa/tmp
    command mkdir -p $HOME/$MFA_DOWNLOADS_DIR
end

function __mfa.cmd
    echo (ssh $MFA_USER_HOST "eval $argv")
end

function __mfa.home
    echo (ssh $MFA_USER_HOST 'eval echo ~$USER')
end

function __mfa.path
    set remote_path (string replace -a ' ' '\\ ' -- (__mfa.home)/$MFA_TMP_DIR/$argv[1])
    echo {$MFA_USER_HOST}:"$remote_path"
end

function __mfa.upload
    if test -z $argv[2]
        scp -p $argv[1] (__mfa.path .) 
    else
        scp -p $argv[1] (__mfa.path $argv[2])
    end
end

function __mfa.download
    if test -z $argv[2]
        scp -p (__mfa.path $argv[1]) .
    else
        scp -p (__mfa.path $argv[1]) $argv[2]
    end
end

function __mfa.upload-a-message
    __mfa.paste > ~/$MFA_MESSAGE_PATH 
    scp -p ~/$MFA_MESSAGE_PATH {$MFA_USER_HOST}:(__mfa.home)/{$MFA_MESSAGE_PATH}
end

function __mfa.download-a-message
    scp -p {$MFA_USER_HOST}:(__mfa.home)/{$MFA_MESSAGE_PATH} ~/$MFA_MESSAGE_CMP_PATH
    if test ! (__mfa.file-eq ~/{$MFA_MESSAGE_PATH} ~/$MFA_MESSAGE_CMP_PATH ) -eq 1
        command mv ~/$MFA_MESSAGE_CMP_PATH ~/$MFA_MESSAGE_PATH
        __mfa.copy-a-message
    else
        echo "No new message. Stop copying." >&2
    end
end

function __mfa.copy-a-message
    command cat ~/$MFA_MESSAGE_PATH | __mfa.copy
end


function __mfa.upload-screenshot
    set latest_screenshot (__mfa.get-latest-file (__mfa.default-pic-dir))
    __mfa.upload (__mfa.default-pic-dir)/{$latest_screenshot} .
end

function __mfa.download-latest
    set latest_file (__mfa.cmd '__mfa.get-latest-file ~/$MFA_TMP_DIR')
    __mfa.download $latest_file $argv[1] 
end

# [network]
function __mfa.open-link
    switch (uname)
    case Darwin
        command open -a "Google Chrome" "$argv"
    case Linux
        command xdg-open "$argv"
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

function __mfa.github-link
    # 都没空格
    set branch (__mfa.git-branch) 
    set relative_arg (__mfa.git-rel-link "$argv") 
    if test -z $relative_arg
        set remote_relative_arg ""
    else
        set remote_relative_arg "tree/$branch/$relative_arg"
    end
    # 避免和 fish 内定义的临时 git 名冲突
    command git remote -v | string match -rq 'github\.com:(?<user_repo>[\S]+)\.git'
    if test -z $user_repo
        command git remote -v | string match -rq 'github\.com:(?<user_repo>[\S]+)\s'
    end
    echo (string join -n '/' "https://github.com" $user_repo $remote_relative_arg)
end

function __mfa.get-func-desc -d "Get the description of a function"
    string match -rq -- '--description [\'"](?<desc>[^\'"]+)' (functions $argv[1])
    echo $desc
end

function mfa
    switch $argv[1]
    case upa
        __mfa.upload-a-message $argv[2..-1]
    case dla
        __mfa.download-a-message $argv[2..-1]
    case cpa
        __mfa.copy-a-message $argv[2..-1]
    case init
        __mfa.init $argv[2..-1]
    case ups
        __mfa.upload-screenshot $argv[2..-1]
    case dll
        __mfa.download-latest $argv[2..-1]
    case up
        __mfa.upload $argv[2..-1]
    case dl
        __mfa.download $argv[2..-1]
    case '*'
        echo mfa: \'$argv\' is not a mfa command.
        functions mfa
    end
end

