source "$(status dirname)/utils.fish"
source "$(status dirname)/complete.fish"
source "$(status dirname)/jst.get.fish"
source "$(status dirname)/jst.w.fish"
# Todo: jst configuration file in ~/.config
set -gx EDITOR (__jst.get-editor)

function __jst.source
    echo "source $(jst pwd-path $argv)" >> $JST_FISH_CONFIG_FILE
end

function __jst.typ.slds
    echo \
"#slide["\n\
"```cpp"\n\
"```"\n\
"]["\n\
"```cpp"\n\
"```"\n\
"]" | __jst.copy
end

function __jst.typ
    __jst.sub __jst.typ $argv
end

function __jst.pm.f
    echo -e "```$argv\n$(cat $argv)\n```" | __jst.copy
end

function __jst.file-ext
    echo (string split . $argv)[-1]
end

function __jst.git.b
    git branch $argv && git switch $argv[1]
end

function __jst.pm.mature
    echo "保证代码简洁优雅，方案成熟，性能较优。" | __jst.copy
end

function __jst.pm.perplexity
    echo "Search in English, answer in Chinese." | __jst.copy
end

function __jst.st
    tmux start
    tmux new-session -d -s $argv[1] \
    && tmux send-keys -t $argv[1]:0 "$argv" C-m
end

function __jst.ed
    tmux kill-session -t $argv
end

# Usage:
# #!/usr/bin/fish
# SUDO_ASKPASS=~/Desktop/pass.sh jst ubuntu bt

function __jst.ubuntu.bt
    sudo -A rmmod btusb
    sleep 1
    sudo -A modprobe btusb
end

function __jst.ubuntu
    __jst.sub __jst.ubuntu $argv
end

function __jst.pm
    __jst.sub __jst.pm $argv
end


function __jst.bin
    set -l bin
    for dir in $PATH
        set -a bin (find $dir -maxdepth 1 -executable -type f -name $argv[1] 2>/dev/null)
    end
    __jst.echo-list-as-file $bin
end

function __jst.is-git-diffable -d "is not bin file"
    if string match -rq "^text/|^inode/" (file -b --mime-type $argv[1])
        echo 1
    else
        echo 0
    end
end

function __jst.open
    switch (__jst.os)
    case WSL
        powershell.exe -c 'explorer.exe \\\\wsl.localhost\\Ubuntu'(string replace -a '/' '\\' -- (realpath $argv))
    case '*'
        open $argv
    end
end

function __jst.today
    set d (date +%y%m%d)
    mkdir $d
    cd $d
    nvim note.md
end

# [only for test]
function __jst.cancel-pl
    functions -e __jst.pl
end

# [only for test]
function __jst.pl
    function __jst.pl --on-event fish_postexec
        pwd
        ls
    end
end

function __jst.sys.mem
    switch (uname)
    case Darwin
        top -l 1 | grep -E "^CPU|^Phys" && sysctl vm.swapusage
    case Linux
    end
end

function __jst.sys
    __jst.sub __jst.sys $argv
end

function __jst.grep2
    echo [matched]
    grep $argv
    echo [unmatched]
    grep -v $argv
end

function __jst.bac
    mkdir -p ~/bac
    mv $argv ~/bac
end

# [config end, func start]
function __jst.last
    __jst.one-from-list (eval "$(history --max=1)") | xargs $argv
end

function __jst.find4
    argparse f d o -- $argv
    if not set -ql _flag_f; and not set -ql _flag_d
        set _flag_f
        set _flag_d
    end
    if test -z "$argv"
        set argv .
    end
    set -l res
    if set -ql _flag_f
        set -a res (command find "$argv" -type f | awk -v prefix="$argv/" '{ sub(prefix, ""); print }')
    end
    if set -ql _flag_d
        set -a res (command find "$argv" -type d | awk -v prefix="$argv/" '{ sub(prefix, ""); print }')
    end
    set preview_cmd \
'if test -f {}'\n\
    'if test (__jst.is-git-diffable {}) -eq 1; head -n 100 {}; else; file {}; end'\n\
'else'\n\
    'tree -C {}'\n\
'end'
    set -l file (__jst.echo-list-as-file $res | fzf --preview "fish -c \"$preview_cmd\"")
    or return
    
    if set -ql _flag_o
        open "$argv/$file"
        return
    end

    if test -f "$argv/$file"
        eval $EDITOR "$argv/$file"
    else
        cd "$argv/$file"
    end
end

function __jst.find3
    argparse f d -- $argv
    if not set -ql _flag_f; and not set -ql _flag_d
        set _flag_f
        set _flag_d
    end
    # set matching_directories (command find . -type d -iname "*" -not -path "*/.*" -not -name ".*" 2>/dev/null)
    # set res (command find . -iname "*" -not -path "*/.*" -not -name ".*" -printf "%P\n" 2>/dev/null)
    set -l resd
    if set -ql _flag_d
        set resd (find . -iname "*" -type d -not -path "*/.*" -not -name ".*" 2>/dev/null)
    end
    # 检查开头的 ./ 并删除
    # alter: | string replace -r "^\.\/" ""
    set -l resf
    if set -ql _flag_f
        set resf (find . -iname "*" -type f -not -path "*/.*" -not -name ".*" 2>/dev/null | awk '{sub(/^\.\//, ""); print}')
    end

    set res $resd $resf # 这里会正确合并列表，中间无空格
    for a in $argv
        set res (__jst.echo-list-as-file $res | grep $a)
    end
    if test -z "$res"
        echo (__jst.err)No matching files.(__jst.off)
        return 1
    end
    set file (realpath (__jst.one-from-list $res))
    # cd (dirname $file)
    if test -f "$file"
        eval $EDITOR $file
    else
        cd $file
    end
end

function __jst.find2
    set res (git ls-files)
    for a in $argv
        set res (__jst.echo-list-as-file $res | grep $a)
    end
    __jst.echo-list-as-file $res
end

function __jst.haya
    __jst.paste > $JST_CACHE_HOME/__disk.bib
    hayagriva $JST_CACHE_HOME/__disk.bib >> $argv
end

# (-i --inter 1) (-O 2) (-r) # (*=*)
function __jst.ltr
    # use tac to reverse
    set ltr (ls -ltr | awk 'NR>1 {print substr($0, index($0,$9))}' | tail -$argv | tac)
    # no!
    __jst.one-from-list $ltr
end

function __jst.hows -d "How-to website"
    set link (string split . -r -m1 (__jst.git-rel-link $argv[1]))[1]
    __jst.open-link "https://how-to.fun/$link"
end

function __jst.upa
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

function __jst.dla
    __jst.download-a-message $argv
end

function __jst.cpa
    __jst.copy-a-message $argv
end

function __jst.ups
    __jst.upload-screenshot $argv
end

function __jst.up
    __jst.upload $argv
end

function __jst.contains-options -d "(option_to_find, params..)"
    set option $argv[1]
    for p in $argv[2..-1]
        if test $p = -$option
            echo 1
            return
        end
    end
    echo 0
end

function __jst.dl
    argparse 'i' 'l/list=?' -- $argv
    # fzf
    if set -ql _flag_l
        set res (__jst.eval "ls -ltr \$HOME/"(__jst.user-rel $JST_CACHE_HOME)"/$argv[1]")
        if test -z $argv[2]
            __jst.echo-list-as-file $res | awk 'NR>1 {print substr($0, index($0,$9))}'
        else
            __jst.echo-list-as-file $res | awk 'NR>1 {print substr($0, index($0,$9))}' | tail -$argv[2] | tac
        end
        return
    end
    if set -ql _flag_i
        command -q fzf
        or echo (__jst.err)Install fzf first.(__jst.off) && return
        # set yours (__jst.one-from-list (jst dl ls . 20))
        set yours (__jst.echo-list-as-file (jst dl -l) | fzf --height=20 --preview 'echo {}')
        if test $status -eq 0
            echo Downloading $yours...
            __jst.download $yours
            return
        end
    end
    __jst.download $argv
end

function __jst.dll
    __jst.download-latest $argv
end

function __jst.md.tb -d "Generate markdown table"
    # by gpt-4o
    if test (count $argv) -ne 2
        echo "Usage: generate_md_table n m"
        return 1
    end

    set -l n $argv[1]
    set -l m $argv[2]

    # Validate input
    if not string match -qr '^\d+$' -- $n $m
        echo "Error: Both arguments must be positive integers."
        return 1
    end

    # Generate Header
    set -l header "|"
    set -l separator "|"
    for i in (seq $m)
        set header "$header      |"
        set separator "$separator ---- |"
    end

    # Print Header and Separator
    echo $header
    echo $separator

    # Generate and Print Body
    if test $n -ge 2
        for row in (seq 1 1 (math $n - 1))
            set -l body "|"
            for col in (seq $m)
                set body "$body      |"
            end
            echo $body
        end
    end
end

function __jst.md.tb1 -d "Markdown table template"
    set tb \
'|      |      |      |'\n\
'| ---- | ---- | ---- |'\n\
'|      |      |      |'\n
    echo -n $tb | __jst.copy
end

function __jst.md
    __jst.sub __jst.md $argv
end

function __jst.how -d "Create a how-to article"
    set title "$argv" # 不加引号则带分隔符（echo 之就是 \n）
    set link_title (jst title "$title")
    set cut_title (string trim (string sub --end=80 "$link_title") --chars='-')
    if test -z "$link_title"
        echo "Please provide a valid title for the article."
        return 1
    end
    set date (date "+%Y-%m-%d")
    set language zh-hans
    set os (uname -a)
    set git_config_user_name (command git config user.name)
    set reliability "20% (author)"
    # yml format
    set head \
- reliability: \"$reliability\"\n\
- date: $date\n\
- os: \"$os\"\n\
- author: \"$git_config_user_name\"\n\
- assume-you-know: [computer]\n\
\n\
\# $title\n
    command touch $cut_title.md
    echo "$head" > $cut_title.md # command echo 不行
    $EDITOR $cut_title.md
end

function __jst.cprt -d "Copy root file (template) here"
    set -l root (command git rev-parse --show-toplevel)
    if test -z "$argv"
        echo (__jst.ok)Repo root files loaded.(__jst.off)
        __jst.complete-d "jst cprt" "$root"
        return 1
    end
    cp -r "$root/$argv[1]" "./$argv[2]"
end

# finally works!
# __jst.complete-runtime "jst cprt" '__jst.complete-d "jst cprt" "$(command git rev-parse --show-toplevel)"'
__jst.complete-runtime-list-cmd "jst cprt" 'ls (git rev-parse --show-toplevel)'

function __jst.f -d "Create file with standard title"
    set -l suf $argv[1]
    set -l name $argv[2..-1]
    echo $name | __jst.copy
    if test $suf = dir
        command mkdir (jst title "$name")
    else
        command touch (jst title "$name").$suf
    end
end

function __jst.mi.pip
    echo "-i https://pypi.tuna.tsinghua.edu.cn/simple" | jcp
end

function __jst.mi -d "Mirrors command prefix"
    __jst.sub __jst.mi $argv
end

function __jst.git-pull-check-ver
    set -l before_pull (git rev-parse HEAD)
    command git pull
    if test $status -ne 0
        return 128
    end
    set -l after_pull (git rev-parse HEAD)
    if test "$before_pull" != "$after_pull"
        return 0
    else
        return 1
    end
end

function __jst.upgrade
    set -l here (pwd)
    cd "$JST_PATH"
    __jst.git-pull-check-ver
    set st $status
    cd "$here"
    if test $st -eq 0
    else if test $st -eq 128
        echo git pull failed
    else
        echo (__jst.green)Congrats!(__jst.off) "You're already on the latest version of Jst" (__jst.dim)"(which is v$JST_VER)"(__jst.off)
    end

    if test $st -eq 0
        exec fish
    end
end

function __jst.git.rcn
    if test -z $argv[1]
        set num 30
    else
        set num $argv[1]
    end
    for i in (seq $num)
        git diff --name-only HEAD~$i..HEAD~(math $i - 1)
    end
end

function __jst.tqdm-test
end

function __jst.bs -d "bash source"
    #     set cmd \
        # source $argv\n\
        # 'if [ $? -eq 0 ]; then'\n\
        # exec fish\n\
        # else\n\
        # exit\n\
        # fi
    exec bash -c "source $argv; exec fish"
end

function __jst.tp -d "Personalized templates"
end

function __jst.t -d "Template files"
    if not test -e "$JST_PATH/t/$argv[1]"
        echo "No template called `$argv[1]`"
        return 1
    end
    if test -z $argv[2]
        set name $argv[1]
    else
        set name $argv[2]
    end
    if test -e "$name"
        echo "Error! `$name` already exists"
        return 1
    end
    cp -r "$JST_PATH/t/$argv[1]" "./$name"
end

function __jst.cargo-run-compiling
    echo (__jst.pad-to-terminal-width (__jst.ok)(__jst.cargo-run-left "Compiling")(__jst.off) $argv)
end

function __jst.cargo-run-finished
    echo (__jst.pad-to-terminal-width (__jst.ok)(__jst.cargo-run-left "Finished")(__jst.off) $argv)
end

function __jst.cargo-run-running
    echo (__jst.pad-to-terminal-width (__jst.ok)(__jst.cargo-run-left "Running")(__jst.off) $argv)
end

function __jst.cargo-run-left
    set input_string "$argv"
    string pad -w 12 $input_string
end

function __jst.pad-to-terminal-width
    set -l input_string "$argv"
    set -l terminal_width $COLUMNS
    string pad --right --char=' ' --width=$terminal_width "$input_string"
end

function __jst.fmt.cpp
    set dst "$JST_CACHE_HOME/fmt/cpp"
    if not test -e "$dst"
        git clone --depth=1 git@github.com:SJTU-RoboMaster-Team/style-team.git "$dst"
    end
    cp "$dst/.clang-format" "$dst/.clang-tidy" .
end

function __jst.try-sub
    if test -z $argv[2]
        return 1
    end
    if not type -q $argv[1].$argv[2] # 该函数是否存在
        return 1
    end
    $argv[1].$argv[2] $argv[3..-1] # don't know whether return 0
end

function __jst.sub -d "(parent, sub [, options])"
    # [todo] options -q
    if test -z $argv[2]
        return 1
    end
    if not type -q $argv[1].$argv[2] # 该函数是否存在
        # if test (__jst.contains-options q $argv[3..-1]) -eq 0
        __jst.no-subcommand $argv[2]
        # end
        return 1
    end
    $argv[1].$argv[2] $argv[3..-1] # don't know whether return 0
end

function __jst.fmt -d "Add fmt file here"
    __jst.sub __jst.fmt $argv
end

function __jst.m -d "mkdir and cd"
    mkdir $argv
    cd $argv
end

function __jst.path -d "Add current dir to path"
    if test -z $argv[1]
        set where .
    else
        set where $argv[1]
    end
    set where (realpath $where) # can't be empty on linux
    if not contains "$where" $PATH
        echo "set PATH \"\$PATH:$where\"" >> ~/.config/fish/config.fish
        echo "export PATH=\"\$PATH:$where\"" >> ~/.bashrc
    end
end

function __jst.sc -d  "Just source"
    switch $argv[1]
    case fish
        source ~/.config/fish/config.fish
    end
end

function __jst.show-and-cp
    echo $argv && echo $argv | __jst.copy
end

function __jst.one-from-list
    set cnt (count $argv)
    if test $cnt -eq 1
        echo $argv[1]
        return 0
    end
    for i in (seq (count $argv))
        echo " $i." "$argv[$i]" >&2
    end
    set -l chosen_number
    # 这 read 看起来是 stderr 的
    read -P "Enter the number to select: " chosen_number
    if test "$chosen_number" -gt 0; and test "$chosen_number" -le $cnt
        echo $argv[$chosen_number]
        return 0
    else
        echo (__jst.err)Invalid selection.(__jst.off)
        return 1
    end
end

function __jst.cp-one-from-list
    set out (__jst.one-from-list $argv)
    if test $status -eq 0
        __jst.show-and-cp $out
    end
end

function __jst.his -d "Copy recent history"
    if test -z $argv[1]
        set num 10
    else
        set num $argv[1]
    end
    set his (history --max $num)
    __jst.cp-one-from-list $his
end

function __jst.fr -d "Translate french word"
    __jst.open-link "https://www.frdic.com/dicts/fr/$argv"
end

function __jst.shs -d "Turn string into shell string"
    set str (__jst.paste)
    set res ""
    for i in $str
        set s1 (string replace -a \\ \\\\ $i)
        set s2 (string replace -a \' \\\' $s1)
        echo $s2
        set res "$res'$s2'\\n\\"\n
    end
    echo -n $res | __jst.copy
end

function __jst.py -d "Python with conda env"
    if test -z $argv[1]
        python3
    end
    conda activate $argv[1] && python3
end

function __jst.pyc.frac -d "Fraction"
    set cmd \
'from fractions import Fraction'\n\
'import numpy as np'\n\
'np.set_printoptions(formatter={\'all\':lambda x: str(Fraction(x).limit_denominator())})'\n # ' comment
    echo $cmd | __jst.copy
end

function __jst.pyc.mat
    set cmd \
'import numpy as np'\n\
'def mat(*arg):'\n\
    'return np.array(arg)'
    echo $cmd | __jst.copy
end

function __jst.pyc -d "Quick python code"
    __jst.sub __jst.pyc $argv
end

function __jst.rn -d "Replace newline, for PDF copy"
    echo (__jst.paste) | tr '\n' ' ' | __jst.copy
end


function __jst.cd -d "cd to common dir like .ssh"
    switch $argv[1]
    case fish
        cd ~/.config/fish
    case nvim
        cd ~/.config/nvim
    case ssh
        cd ~/.ssh
    end
end

function __jst.e -d "Edit common config files"
    switch $argv[1]
    case jst
        $EDITOR $JST_PATH/jst.fish
    case fish
        $EDITOR ~/.config/fish/config.fish
    case nvim
        $EDITOR ~/.config/nvim/init.vim
    case nvimlua
        $EDITOR ~/.config/nvim/init.lua
    case bash
        $EDITOR ~/.bashrc
    case ssh
        $EDITOR ~/.ssh/config
    case tmux
        $EDITOR ~/.tmux.conf
    end
end

function __jst.git.status.simple
    string sub -e 100 (string join ' | ' (string trim (git status -u --porcelain $argv)))
end

function __jst.commit -d "Atomic commit simple message (ja)"
    # non-empty
    # show diff
    # command git status
    # read -P "Are you sure to commit? " p
    # if test $p -eq "y"
    # return
    if test -z "$argv"
        set commit (__jst.git.status.simple)
    else
        set commit "$argv"
    end
    set top_dir (command git rev-parse --show-toplevel)
    command git add "$top_dir" \
    && command git commit -m "$commit"
end

function __jst.commit-file -d "Simple commit message for file"
    # 不要和 autojump 发生冲突
    # https://github.com/wting/autojump
    git add $argv
    git commit -m "$(__jst.git.status.simple $argv)"
end

function __jst.remove-git-merge-conflict-markers -d "(filename)"
    command grep -v '^\(<<<<<<<\|=======\|>>>>>>> \)' $argv > .jsttmp && command mv .jsttmp $argv
end

function __jst.push -d "Pull, simple commit and push"
    # 远程修改是不可逆的
    command git status -u --porcelain # show unstaged too.
    echo ---
    command git diff --stat

    command git pull
    if test $status -ne 0
        command git stash
        command git pull
        command git stash pop
    end

    set conflicted (git diff --name-only --diff-filter=U)
    if not test -z $conflicted
        echo (__jst.err)Conflicted files $conflicted. Will start merging insertion in 3s.(__jst.off)
        command sleep 3
    end
    for file in $conflicted
        __jst.remove-git-merge-conflict-markers $file
    end
    ja "$argv"
    command git push -u
end

function __jst.push-file -d "Pull, simple commit and push file"
    jaf $argv
    git push -u
end

function __jst.pwd-path
    if test -z "$argv"
        set slash ""
    else
        set slash "/"
    end
    string join '' (pwd) $slash "$argv"
end


# function hp.vim
#     __jst.open-link 'https://www.runoob.com/w3cnote/all-vim-cheatsheat.html'
# end

# function hp.re
#     __jst.open-link "https://www.runoob.com/regexp/regexp-syntax.html"
# end

# function hp.re.meta
#     __jst.open-link "https://www.runoob.com/regexp/regexp-metachar.html"
# end

# function hp.en
#     __jst.open-link "https://www.youdao.com/result?word="$argv"&lang=en"
# end

# function hp.fr
#     __jst.open-link "https://www.frdic.com/dicts/fr/$argv"
# end

# function hp.latex
#     __jst.open-link "https://latex.guide/"
# end

# function hp.latex.2
#     __jst.open-link "https://detexify.kirelabs.org/classify.html"
# end

function __jst.baidu
    __jst.open-link "https://www.baidu.com/s?wd=$argv"
end

function __jst.baidu.ip
    baidu ip
end

# [jst]
function __jst.tl -d "Translate"
    set str (string replace -a '\n' ' ' "$argv")
    __jst.open-link "https://translate.google.com.hk/?sl=auto&tl=zh-CN&text=$str&op=translate"
end

function __jst.d.f
    watch -n 0.5 df -h
end

function __jst.d.u
    # switch (uname)
    # case Linux
    #     command du -h --max-depth=1 * | sort -hr
    # case Darwin
    #     command du -h -d 0 * | sort -hr
    # end
    command du -d 0 -h * | sort -hr
end

function __jst.d
    __jst.d.$argv[1] $argv[2..-1]
end

function __jst.dir -d "Jump to subdir or file (jd)"
    argparse f d -- $argv
    if not set -ql _flag_f; and not set -ql _flag_d
        set -f _flag_f
        set -f _flag_d
    end

    set search_string $argv[1]

    # Use find to search for directories with similar names
    set -l matching_directories
    if set -ql _flag_d
        set matching_directories (command find . -type d -iname "*$search_string*" -not -path "*/.*" -not -name ".*" 2>/dev/null)
    end
    set -l matching_files
    if set -ql _flag_f
        set matching_files (command find . -type f -iname "*$search_string*" -not -path "*/.*" -not -name ".*" 2>/dev/null)
    end

    set -l dir_cnt (count $matching_directories)
    set -l file_cnt (count $matching_files)
    set -l tot_cnt (math $dir_cnt + $file_cnt)

    # Check if any matching directories were found
    if test $tot_cnt -eq 0
        echo (__jst.err)"No matching directories or files found."(__jst.off)
        return 1
    end
    if test $tot_cnt -eq 1
        if test $dir_cnt -eq 1
            echo Matching directory: $matching_directories
            cd $matching_directories[1]
            return
        end
        echo Matching file: $matching_files
        cd (command dirname $matching_files)
        $EDITOR (command basename $matching_files)
        return
    end
    # If multiple matches, prompt the user to choose one
    echo "Multiple matching found:"
    if test $dir_cnt -gt 0
        echo "[Directories]"
        for i in (seq (count $matching_directories))
            echo " $i." (string sub -s 3 "$matching_directories[$i]")
        end
        echo
    end
    if test $file_cnt -gt 0
        echo "[Files]"
        for i in (seq (count $matching_files))
            set -l idx (math $i + $dir_cnt)
            echo " $idx." (string sub -s 3 "$matching_files[$i]")
        end
        echo
    end
    set -l chosen_number
    read -P "Enter the number of the directory to jump to or file to edit: " chosen_number
    if test "$chosen_number" -gt 0; and test "$chosen_number" -le $dir_cnt
        cd $matching_directories[$chosen_number]
        return
    else if test "$chosen_number" -gt $dir_cnt; and test "$chosen_number" -le $tot_cnt
        set -l idx (math $chosen_number - $dir_cnt)
        set -l file_name $matching_files[$idx]
        cd (command dirname $file_name)
        $EDITOR (command basename $file_name)
        return
    else
        echo (__jst.err)Invalid selection.(__jst.off)
        return 1
    end
end

alias jd="jst find4"

# cmake make test
function __jst.crun -d 'cmake make run'
    command cmake .. &&\
        command make -j8 &&\
        if test (count $argv) -ge 1
            ./$argv[1]
        else
            ./1
        end
end

function __jst.battery
    command system_profiler SPPowerDataType | command grep "State of Charge" | string trim -l
end

function __jst.i -d "Useful information of your system"
    command date
    __jst.battery
end

function __jst.new-c -d "Initialize an empty c project"
    command touch .gitignore
    echo -e ".vscode\n.DS_Store\n" \
".nvimlog\n*.swp\nbuild/\n" > .gitignore
    command mkdir build
    command mkdir src
    command touch src/main.c
    command touch src/lib.c
    command touch src/lib.h
    touch CMakeLists.txt
end

function __jst.git.mes -d "Git commit message help"
    set commit \
"<head>(, <options>): <content>\n"\
"example: feat, run: 添加核心模块\n"\
"<head>\n"\
"  feat      功能    添加 / 更改主要功能\n"\
"  fix       修复    修复运行的问题或 bug\n"\
"  comment   注释\n"\
"  docs      文档\n"\
"  test      测试    添加 / 更改测试行的功能\n"\
"  style     格式    规范代码风格, 调整代码顺序, 修改变量名等提升可读性的修改\n"\
"  refactor  重构    不是新增功能、修改 bug 的代码变动\n"\
"  perf      优化    提升性能、体验等\n"\
"  config    配置    配置文件、资源文件相关的改动\n"\
"  tools     工具    构建过程或辅助工具的变动\n"\
"  revert    回滚    撤销 commit，回滚版本等\n"\
"  merge     合并    合并分支, 在两个分支都有修改时使用\n"\
"  sync      同步    同步分支, 在分支落后于另一分支时使用\n"\
"  others    其它    一般在测试仓库功能的时候使用, 正常写代码不建议使用\n"\
"\n"\
"<options>\n"\
"  run       在生产环境上运行代码\n"\
"  to        只产生 diff 而不保证可用性, 适合于多次提交, 最后完善时移除 option\n"\
"\n"\
"<content>\n"\
"  书写 commit 的具体信息，应在 50 字符以内，并使用一般时态动词 + 宾语进行描述"
    echo -e $commit
end

function __jst.git.dl -d "Download from github mirror ghps.cc"
    wget https://mirror.ghproxy.com/$argv
end

function __jst.git.c1 -d "git clone --depth=1"
    command git clone --depth=1 git@github.com:"$argv[1]".git $argv[2..-1]
end

function __jst.git.c10 -d "git clone --depth=10"
    command git clone --depth=10 git@github.com:"$argv[1]".git $argv[2..-1]
end

function __jst.git.c -d "Clone from github with ssh"
    command git clone git@github.com:"$argv[1]".git $argv[2..-1]
end

function __jst.git.o
    __jst.open-link (__jst.github-link "$argv")
end

function __jst.git.log
    command git log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" --date=short
end

function __jst.git.log1
    command git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'
end

function __jst.git.log2
    set layer (math (__jst.git-log-graph-merge-layer-char))
    set layer2 (math $layer + 50)
    command git log --graph --abbrev-commit --decorate --date=format:"%y-%m-%d %H:%I" --format=format:"%<|($layer)%>|(1)%C(auto)%d%C(reset) %C(white)%<|($layer2,trunc)%s%C(reset) %C(bold green)%ad%C(reset) %C(bold blue)%h%C(reset) %C(dim white)%an%C(reset)" --all
end

function __jst.git.ig
    command touch .gitignore
    set content \
.vscode\n\
.DS_Store\n\
.nvimlog\n\
"*.swp"\n\
.zed\n\
__pycache__
    echo -e "$content" > .gitignore
end

function __jst.git -d "[subcommands] for git"
    __jst.sub __jst.git $argv
end

function __jst.find
    command find . -iname "*"$argv"*"
end

function __jst.grep
    # -r: 查找所有文件夹
    # -i: 忽略大小写
    # -n: 输出行号
    command grep -nri "$argv" --exclude-dir=".git"
end

function __jst.gf -d "Search via title and contents"
    __jst.grep "$argv"
    __jst.find "$argv"
end

function __jst.r -d "Return to git repo root"
    # yield
    cd (command git rev-parse --show-toplevel)
end

function __jst.repod -d "Subdir in the repo (jdr)"
    jd (command git rev-parse --show-toplevel) $argv
end

alias jdr="jst repod"

function __jst.title -d "Get a Stackoverflow-style title"
    set low (echo -- $argv | command tr '[:upper:]' '[:lower:]') # 小写
    set no_single_quote (string replace -r -a -- "'" "" $low) # 删除单引号
    # set sub (command echo $no_single_quote | command tr -c '[:alnum:]' '-' | string sub -e -1) # 将所有符号换为 -
    set sub (string replace -r -a -- '[\x00-\x2F\x3A-\x40\x5B-\x60\x7B-\x7F]' '-' $no_single_quote)
    set rep (string replace -r -a -- '(-)+' '-' $sub) # 处理重复 -
    set tri (string trim --chars='-' $rep) # 删两边
    echo -n $tri
    # echo $tri | __jst.copy
    # -c is complement 补集
end

function __jst.comp -d "Compile a cpp file using c++17"
    if string match -q "*.c" $argv
        command gcc $argv -o 1 -std=c11 -Wall
        return 0
    end
    g++ $argv -o 1 -std=c++17 -Wall
end

function __jst.run -d "Comp & run a cpp file using c++17"
    echo -ne (__jst.cargo-run-compiling $argv)
    __jst.comp $argv
    if test $status -ne 0
        return
    end
    echo -e \r(__jst.cargo-run-finished $argv)
    echo -e (__jst.cargo-run-running $argv)
    ./1
end

function __jst.get-hide-chain-from-func -d "(func_name) -> chain: []"
    string split '.' (string sub -s 3 $argv)
end

function __jst.get-hide-chain-from-cmd -d "(cmd_chain..) -> chain: []"
    # jst -h git c --depth=10 julyfun/assd
    # __jst => ignore -h => __jst.git? =yes=> __jst.git.c? =yes=> ignore -- => ..
    set func_name __$argv[1]
    for a in $argv[2..-1]
        switch $a
            case '*=*'
                continue
            case '-*' # do not try to complete options as commands
                continue
            case '*'
                if functions -q $func_name.$a
                    set func_name $func_name.$a
                end
        end
    end
    __jst.get-hide-chain-from-func $func_name
end

function __jst.usage-count
    cat $JST_DATA_HOME/usage_count.json
end

function jst -d "Just do something"
    # __jst.$argv[1] $argv[2..-1]
    __jst.sub __jst $argv # this should be in comptime, in fact
    # count the time it is used
    if test $status -eq 0
        /usr/bin/env python3 "$JST_PATH/usage_count.py" (__jst.get-hide-chain-from-cmd jst $argv)
    end
end

__jst.complete-r __jst jst
__jst.complete-d "jst t" "$JST_PATH/t"
