set -g fish_config_path $HOME/.config/fish/config.fish
# Todo: configuration file
alias alias_editor=nvim

function __jst.commit -d "Simple commit with simple message"
    # non-empty
    if test -z "$argv"
        set commit "just commit"
    else
        set commit "$argv"
    end
    set top_dir (command git rev-parse --show-toplevel)
    command git add "$top_dir" \
    && command git commit -m "$commit"
end

alias jm="jst commit"

function __jst.commit-file -d "Simple commit message for file"
    jm (__mfa.git-rel-link "$argv")
end

alias jmf="jst commit-file"

function __jst.push -d "Pull, simple commit and push"
    command git pull # may fail
    jm "$argv" && command git push -u
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
    echo $output | __mfa.copy
    echo $output
end

function jwhich
    cd (command dirname (command which $argv[1]))
end

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

function baidu
    __mfa.open-link "https://www.baidu.com/s?wd=$argv"
end

function baidu.ip
    baidu ip
end

# [jst]
function __jst.how -d "Create a how-to article"
    set title "$argv" # 不加引号则带分隔符（echo 之就是 \n）
    set link_title (jst title "$title")
    if test -z "$link_title"
        echo "Please provide a valid title for the article."
        return 1
    end
    set date (date "+%Y-%m-%d")
    set language Chinese
    set os (uname -a)
    set git_config_user_name (command git config user.name)
    # see: https://stackoverflow.com/help/how-to-answer
    # - question: asked how-to
    # - draft: a brief answer without reliable reference or enough environment information
    # - essay: a reliable answer, providing context for links and information for reproduction
    #   but may be only useful for people familiar with the relevant fields
    # - course: a detailed answer with step-by-step instructions, friendly to newcomers,
    #   low threshold for reading and reproducing
    # - Good Article - Featured Content
    set type draft
    # yml format
    set head \
---\n\
type: $type\n\
date: $date\n\
language: \"$language\"\n\
os: \"$os\"\n\
author: \"$git_config_user_name\"\n\
suppose-you-know: [computer]\n\
---\n\
\n\
\# $title\n\
\n\
\n
    command touch $link_title.md
    echo -e $head > $link_title.md
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

function __jst.dir -d "Jump to subdir or fil (jd)"
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
            return 0
        end
        echo Matching file: $matching_files
        cd (command dirname $matching_files)
        alias_editor (command basename $matching_files)
        return 0
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
        return 0
    else if test "$chosen_number" -gt $dir_cnt; and test "$chosen_number" -le $tot_cnt  
        set -l idx (math $chosen_number - $dir_cnt)
        set -l file_name $matching_files[$idx]
        cd (command dirname $file_name)
        alias_editor (command basename $file_name)
        return 0
    else
        echo (__mfa.err)Invalid selection.(__mfa.off)
        return 1
    end
end

alias jd="jst dir"

# cmake make test
function __jst.cmt -d 'Cmake make test'
    command cmake ..
    command make -j8
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

function __jst.dl.autojump
    command git clone git@github.com:wting/autojump.git --depth=1 $HOME/$MFA_DOWNLOADS_DIR/autojump
    command echo "source $HOME/$MFA_DOWNLOADS_DIR/autojump/bin/autojump.fish" >> $fish_config_path
end

function __jst.dl -d "Download and configure tools auto"
    __jst.dl.$argv[1] $argv[2..-1]
end

function __jst.new-c -d "Initialize an empty c project"
    command touch .gitignore
    command echo -e ".vscode\n.DS_Store\n" \
".nvimlog\n*.swp\nbuild/\n" > .gitignore
    command mkdir build
    command mkdir src
    command touch src/main.c
    command touch src/lib.c
    command mkdir include
    command touch include/lib.h
end

function __jst.cmm -d "Git commit message help"
    set commit \
"<head>(, <options>): <content>\n"\
"example: feat, run: 添加核心模块\n"\
"<head>\n"\
"  feat      功能    添加 / 更改主要功能\n"\
"  fix       修复    修复运行的问题或 bug\n"\
"  comment   注释\n"\
"  doc       文档\n"\
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
"  书写 commit 的具体信息"
    echo -e $commit
end

function __jst.git.c
    command git clone git@github.com:"$argv[1]".git $argv[2..-1]
end

function __jst.git.o
    __mfa.open-link (__mfa.github-link "$argv")
end

function __jst.git.log
    command git log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" --date=short  
end

function __jst.git.ig
    command touch .gitignore
    set content \
".vscode\n"\
".DS_Store\n"\
".nvimlog\n"\
"*.swp\n"
    echo -e "$content" > .gitignore
end

function __jst.git -d "Quick subcommands for git"
    if not type -q __jst.git.$argv[1] # 该函数是否存在
        __mfa.no-subcommand $argv[1]
        return 1
    end
    __jst.git.$argv[1] $argv[2..-1]
        # echo (__mfa.err)"error:"(__mfa.off)\
        #     \'jst git (__mfa.yellow)(__mfa.under)$argv[1](__mfa.off)\'\
        #     does not exist.
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

function __jst.r -d "alias: ret"
    __jst.ret $argv[2..-1]
end

function __jst.ret -d "Return to git repo root (jst r)"
    cd (command git rev-parse --show-toplevel)
end

function __jst.title -d "Get a Stackoverflow-style title"
    set low (command echo $argv | command tr '[:upper:]' '[:lower:]') # 小写
    set no_single_quote (string replace -r -a -- "'" "" $low) # 删除单引号
    set sub (command echo $no_single_quote | command tr -c '[:alnum:]' '-' | string sub -e -1) # 将所有符号换为 -
    set rep (string replace -r -a -- '(-)+' '-' $sub) # 处理重复 -
    set tri (string trim --chars='-' $rep) # 删两边
    echo $tri
    # echo $tri | __mfa.copy
    # -c is complement 补集 
end

function __jst.comp -d "Compile a cpp file using c++17"
    command g++ $argv -o 1 -std=c++17 -Wall
end

function __jst.run -d "Comp & run a cpp file using c++17"
    __jst.comp $argv && command echo "Comp done." && ./1
end


function jst -d "Just do something"
    __jst.$argv[1] $argv[2..-1]
end

# [automatically set jst subcommands completions]
for func in (string match '__jst.*' (functions --all))
    set -l remove_underscore (string sub -s 3 $func)
    set -l splited (string split . -m1 $remove_underscore)
    if string match -rq '\.' $splited[2] # 存在点，不是一个直接子命令
        continue
    end
    set desc (__mfa.get-func-desc $func)
    # echo $func
    # 字符串长度为 0
    # if test -z $desc
    #     continue
    # end
    complete -c jst -f -a $splited[2] -n "__fish_use_subcommand" -d $desc
end

