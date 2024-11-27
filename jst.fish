source "$(status dirname)/mfa.fish"
source "$(status dirname)/complete.fish"
# Todo: jst configuration file in ~/.config
alias alias_editor=nvim
set -gx EDITOR nvim

function __jst.bac
    mkdir -p ~/bac
    mv $argv ~/bac
end

# [config end, func start]
function __jst.last
    __mfa.one-from-list (eval "$(history --max=1)") | xargs $argv
end

function __jst.find3
    # set matching_directories (command find . -type d -iname "*" -not -path "*/.*" -not -name ".*" 2>/dev/null)
    # set res (command find . -iname "*" -not -path "*/.*" -not -name ".*" -printf "%P\n" 2>/dev/null)
    set res (find . -iname "*" -not -path "*/.*" -not -name ".*" 2>/dev/null | awk '{sub(/^\.\//, ""); print}')
    for a in $argv
        set res (__mfa.echo-list-as-file $res | grep $a)
    end
    if test -z "$res"
        echo (__mfa.err)No matching files.(__mfa.off)
        return 1
    end
    set file (realpath (__mfa.one-from-list $res))
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
        set res (__mfa.echo-list-as-file $res | grep $a)
    end
    __mfa.echo-list-as-file $res
end

function __jst.haya
    jps > $MFA_CACHE_HOME/__disk.bib
    hayagriva $MFA_CACHE_HOME/__disk.bib >> $argv
end

# (-i --inter 1) (-O 2) (-r) # (*=*)
function __jst.ltr
    # use tac to reverse
    set ltr (ls -ltr | awk 'NR>1 {print substr($0, index($0,$9))}' | tail -$argv | tac)
    # no!
    __mfa.one-from-list $ltr
end

function __jst.hows -d "How-to website"
    set link (string split . -r -m1 (__mfa.git-rel-link $argv[1]))[1]
    __mfa.open-link "https://how-to.fun/$link"
end

function __jst.upa
    __mfa.upload-a-message $argv
end

function __jst.dla
    __mfa.download-a-message $argv
end

function __jst.cpa
    __mfa.copy-a-message $argv
end

function __jst.ups
    __mfa.upload-screenshot $argv
end

function __jst.up
    __mfa.upload $argv
end

function __mfa.contains-options -d "(option_to_find, params..)"
    set option $argv[1]
    for p in $argv[2..-1]
        if test $p = -$option
            echo 1
            return
        end
    end
    echo 0
end

function __jst.dl.ls -d "(path, tailnum)"
    set res (__mfa.eval "ls -ltr \$HOME/"(__mfa.user-rel $MFA_CACHE_HOME)"/$argv[1]")
    if test -z $argv[2]
        __mfa.echo-list-as-file $res | awk 'NR>1 {print substr($0, index($0,$9))}'
    else
        __mfa.echo-list-as-file $res | awk 'NR>1 {print substr($0, index($0,$9))}' | tail -$argv[2] | tac
    end
end

function __jst.dl
    __mfa.try-sub __jst.dl $argv
    if test $status -eq 0
        return 0
    end
    if test (__mfa.contains-options i $argv) -eq 1
        set yours (__mfa.one-from-list (jst dl ls . 20))
        if test $status -eq 0
            echo Downloading $yours...
            __mfa.download $yours
            return
        end
    end
    __mfa.download $argv
end

function __jst.dll
    __mfa.download-latest $argv
end

function __jst.md.tb -d "Generate markdown table"
    __mfa.md.tb $argv | jcp
end

function __mfa.md.tb -d "Generate markdown table"
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
    echo -n $tb | jcp
end

function __jst.md
    __mfa.sub __jst.md $argv
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
    alias_editor $cut_title.md
end

function __jst.cprt -d "Copy root file (template) here"
    set -l root (command git rev-parse --show-toplevel)
    if test -z "$argv"
        echo (__mfa.ok)Repo root files loaded.(__mfa.off)
        __mfa.complete-d "jst cprt" "$root"
        return 1
    end
    cp -r "$root/$argv[1]" "./$argv[2]"
end

# finally works!
# __mfa.complete-runtime "jst cprt" '__mfa.complete-d "jst cprt" "$(command git rev-parse --show-toplevel)"'
__mfa.complete-runtime-list-cmd "jst cprt" 'ls (git rev-parse --show-toplevel)'

function __jst.f -d "Create file with standard title"
    set -l suf $argv[1]
    set -l name $argv[2..-1]
    echo $name | jcp
    command touch (jst title "$name").$suf
end

function __jst.mi.pip
    cpit "pip install -i https://pypi.tuna.tsinghua.edu.cn/simple"
end

function __jst.mi -d "Mirrors command prefix"
    __mfa.sub __jst.mi $argv
end

function __mfa.git-pull-check-ver
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
    cd "$MFA_JST_PATH"
    __mfa.git-pull-check-ver
    set st $status
    cd "$here"
    if test $st -eq 0
    else if test $st -eq 128
        echo git pull failed
    else
        echo (__mfa.green)Congrats!(__mfa.off) "You're already on the latest version of Jst" (__mfa.dim)"(which is v$MFA_JST_VER)"(__mfa.off)
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

function __mfa.tqdm-test
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
    if not test -e "$MFA_JST_PATH/t/$argv[1]"
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
    cp -r "$MFA_JST_PATH/t/$argv[1]" "./$name"
end

function __mfa.cargo-run-compiling
    echo (__mfa.pad-to-terminal-width (__mfa.ok)(__mfa.cargo-run-left "Compiling")(__mfa.off) $argv)
end

function __mfa.cargo-run-finished
    echo (__mfa.pad-to-terminal-width (__mfa.ok)(__mfa.cargo-run-left "Finished")(__mfa.off) $argv)
end

function __mfa.cargo-run-running
    echo (__mfa.pad-to-terminal-width (__mfa.ok)(__mfa.cargo-run-left "Running")(__mfa.off) $argv)
end

function __mfa.cargo-run-left
    set input_string "$argv"
    string pad -w 12 $input_string
end

function __mfa.pad-to-terminal-width
    set -l input_string "$argv"
    set -l terminal_width $COLUMNS
    string pad --right --char=' ' --width=$terminal_width "$input_string"
end

function __jst.fmt.cpp
    set dst "$MFA_CACHE_HOME/fmt/cpp"
    if not test -e "$dst"
        git clone --depth=1 git@github.com:SJTU-RoboMaster-Team/style-team.git "$dst"
    end
    cp "$dst/.clang-format" "$dst/.clang-tidy" .
end

function __mfa.try-sub
    if test -z $argv[2]
        return 1
    end
    if not type -q $argv[1].$argv[2] # 该函数是否存在
        return 1
    end
    $argv[1].$argv[2] $argv[3..-1] # don't know whether return 0
end

function __mfa.sub -d "(parent, sub [, options])"
    # [todo] options -q
    if test -z $argv[2]
        return 1
    end
    if not type -q $argv[1].$argv[2] # 该函数是否存在
        # if test (__mfa.contains-options q $argv[3..-1]) -eq 0
        __mfa.no-subcommand $argv[2]
        # end
        return 1
    end
    $argv[1].$argv[2] $argv[3..-1] # don't know whether return 0
end

function __jst.fmt -d "Add fmt file here"
    __mfa.sub __jst.fmt $argv
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
    echo "set PATH \"\$PATH:$where\"" >> ~/.config/fish/config.fish
    echo "export PATH=\"\$PATH:$where\"" >> ~/.bashrc
end

function __jst.sc -d  "Just source"
    switch $argv[1]
    case fish
        source ~/.config/fish/config.fish
    end
end

function __mfa.show-and-cp
    echo $argv && echo $argv | jcp
end

function __mfa.one-from-list
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
        echo (__mfa.err)Invalid selection.(__mfa.off)
        return 1
    end
end

function __mfa.cp-one-from-list
    set out (__mfa.one-from-list $argv)
    if test $status -eq 0
        __mfa.show-and-cp $out
    end
end

function __jst.his -d "Copy recent history"
    if test -z $argv[1]
        set num 10
    else
        set num $argv[1]
    end
    set his (history --max $num)
    __mfa.cp-one-from-list $his
end

function __jst.fr -d "Translate french word"
    __mfa.open-link "https://www.frdic.com/dicts/fr/$argv"
end

function __jst.shs -d "Turn string into shell string"
    set str (jps)
    set res ""
    for i in $str
        set s1 (string replace -a \\ \\\\ $i)
        set s2 (string replace -a \' \\\' $s1)
        echo $s2
        set res "$res'$s2'\\n\\"\n
    end
    echo -n $res | jcp
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
    echo $cmd | jcp
end

function __jst.pyc.mat
    set cmd \
'import numpy as np'\n\
'def mat(*arg):'\n\
    'return np.array(arg)'
    echo $cmd | jcp
end

function __jst.pyc -d "Quick python code"
    __mfa.sub __jst.pyc $argv
end

function __jst.rn -d "Replace newline, for PDF copy"
    echo (__mfa.paste) | tr '\n' ' ' | __mfa.copy
end

alias jcp="__mfa.copy"
alias jps="__mfa.paste"

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
    case fish
        alias_editor ~/.config/fish/config.fish
    case nvim
        alias_editor ~/.config/nvim/init.vim
    case nvimlua
        alias_editor ~/.config/nvim/init.lua
    case bash
        alias_editor ~/.bashrc
    case ssh
        alias_editor ~/.ssh/config
    case tmux
        alias_editor ~/.tmux.conf
    end
end

function __jst.commit -d "Atomic commit simple message (ja)"
    # non-empty
    # show diff
    # command git status
    # read -P "Are you sure to commit? " p
    # if test $p -eq "y"
    # return
    if test -z "$argv"
        set commit (string sub -e 100 (string join ' | ' (string trim (git status --porcelain))))
    else
        set commit "$argv"
    end
    set top_dir (command git rev-parse --show-toplevel)
    command git add "$top_dir" \
    && command git commit -m "$commit"
end

alias ja="jst commit" # atomic commit

function __jst.commit-file -d "Simple commit message for file"
    # 不要和 autojump 发生冲突
    # https://github.com/wting/autojump
    ja (__mfa.git-rel-link "$argv")
end

alias jaf="jst commit-file"

function __jst.push -d "Pull, simple commit and push"
    # 远程修改是不可逆的
    command git status --porcelain # show unstaged too.
    echo ---
    command git diff --stat
    if not command git pull
        return
    end
    ja "$argv"
    command git push -u
end

alias jp="jst push"

function __jst.push-file -d "Pull, simple commit and push file"
    jp (__mfa.git-rel-link "$argv")
end

alias jpf="jst push-file"

function cpwd
    if test -z "$argv"
        set slash ""
    else
        set slash "/"
    end
    set output (string join '' (pwd) $slash "$argv")
    echo -n $output | __mfa.copy
    echo $output
end

function cpit
    echo -n "$argv" | jcp
end

# function jwhich
# cd (command dirname (command which $argv[1]))
# end

alias fn=functions

# function hp.vim
#     __mfa.open-link 'https://www.runoob.com/w3cnote/all-vim-cheatsheat.html'
# end

# function hp.re
#     __mfa.open-link "https://www.runoob.com/regexp/regexp-syntax.html"
# end

# function hp.re.meta
#     __mfa.open-link "https://www.runoob.com/regexp/regexp-metachar.html"
# end

# function hp.en
#     __mfa.open-link "https://www.youdao.com/result?word="$argv"&lang=en"
# end

# function hp.fr
#     __mfa.open-link "https://www.frdic.com/dicts/fr/$argv"
# end

# function hp.latex
#     __mfa.open-link "https://latex.guide/"
# end

# function hp.latex.2
#     __mfa.open-link "https://detexify.kirelabs.org/classify.html"
# end

function __jst.baidu
    __mfa.open-link "https://www.baidu.com/s?wd=$argv"
end

function __jst.baidu.ip
    baidu ip
end

# [jst]
function __jst.tl -d "Translate"
    set str (string replace -a '\n' ' ' "$argv")
    __mfa.open-link "https://translate.google.com.hk/?sl=auto&tl=zh-CN&text=$str&op=translate"
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
    set search_string $argv[1]

    # Use find to search for directories with similar names
    set matching_directories (command find . -type d -iname "*$search_string*" -not -path "*/.*" -not -name ".*" 2>/dev/null)
    set matching_files (command find . -type f -iname "*$search_string*" -not -path "*/.*" -not -name ".*" 2>/dev/null)
    set dir_cnt (count $matching_directories)
    set file_cnt (count $matching_files)
    set tot_cnt (math $dir_cnt + $file_cnt)

    # Check if any matching directories were found
    if test $tot_cnt -eq 0
        echo (__mfa.err)"No matching directories or files found."(__mfa.off)
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
        alias_editor (command basename $matching_files)
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
        alias_editor (command basename $file_name)
        return
    else
        echo (__mfa.err)Invalid selection.(__mfa.off)
        return 1
    end
end

alias jd="jst find3"

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

function __jst.get.omf
    curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
    omf install l
    exec fish
end

function __jst.get.neovim
    set where $HOME/$MFA_DOWNLOADS_DIR/neovim
    set here (pwd)
    __mfa.try-mkdir $where
    cd $where
    switch (uname)
    case Linux
        jst git dl https://github.com/neovim/neovim/releases/download/nightly/nvim.appimage
        mv nvim.appimage nvim
        chmod +x ./nvim
        jst path
    case Darwin
        if test -e $where/nvim-macos-arm64.tar.gz
            rm $where/nvim-macos-arm64.tar.gz
        end
        jst git dl https://github.com/neovim/neovim/releases/download/nightly/nvim-macos-arm64.tar.gz
        xattr -c ./nvim-macos-arm64.tar.gz
        tar xzvf nvim-macos-arm64.tar.gz
        rm nvim-macos-arm64.tar.gz
        jst path ./nvim-macos-arm64/bin
    end
    cd $here
    exec fish
end

function __jst.get.autojump
    command git clone git@github.com:wting/autojump.git --depth=1 $HOME/$MFA_DOWNLOADS_DIR/autojump
    command echo "source $HOME/$MFA_DOWNLOADS_DIR/autojump/bin/autojump.fish" >> $MFA_FISH_CONFIG_PATH
end

function __jst.get.pip
    python3 "$MFA_JST_PATH/a/get-pip.py"
end

function __jst.get -d "Download and configure tools auto"
    __jst.get.$argv[1] $argv[2..-1]
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

function __jst.cmm -d "Git commit message help"
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
    __mfa.open-link (__mfa.github-link "$argv")
end

function __jst.git.log
    command git log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" --date=short
end

function __jst.git.log1
    command git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)'
end

function __jst.git.log2
    set layer (math (__mfa.git-log-graph-merge-layer-char))
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
    __mfa.sub __jst.git $argv
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

function __jst.y -d "Return to git repo root"
    # yield
    cd (command git rev-parse --show-toplevel)
end

function __jst.repod -d "Subdir in the repo (jdr)"
    jst y && jd $argv
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
    # echo $tri | __mfa.copy
    # -c is complement 补集
end

function __jst.comp -d "Compile a cpp file using c++17"
    if string match -q "*.c" $argv
        command gcc $argv -o 1 -Wall
        return 0
    end
    command g++ $argv -o 1 -std=c++17 -Wall
end

function __jst.run -d "Comp & run a cpp file using c++17"
    echo -ne (__mfa.cargo-run-compiling $argv)
    __jst.comp $argv
    if test $status -ne 0
        return
    end
    echo -e \r(__mfa.cargo-run-finished $argv)
    echo -e (__mfa.cargo-run-running $argv)
    ./1
end

function __mfa.get-hide-chain-from-func -d "(func_name) -> chain: []"
    string split '.' (string sub -s 3 $argv)
end

function __mfa.get-hide-chain-from-cmd -d "(cmd_chain..) -> chain: []"
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
    __mfa.get-hide-chain-from-func $func_name
end

function __jst.usage-count
    cat $MFA_DATA_HOME/usage_count.json
end

function jst -d "Just do something"
    # __jst.$argv[1] $argv[2..-1]
    __mfa.sub __jst $argv # this should be in comptime, in fact
    # count the time it is used
    if test $status -eq 0
        /usr/bin/env python3 "$MFA_JST_PATH/usage_count.py" (__mfa.get-hide-chain-from-cmd jst $argv)
    end
end

__mfa.complete-r __jst jst
# __mfa.complete-r __mfa
__mfa.complete-d "jst t" "$MFA_JST_PATH/t"
