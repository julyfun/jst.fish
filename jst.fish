# 就不重构了，多重方式都尝试一下

function jc --description 'just commit'
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

function jcf
    jc (mfa.git-rel-link "$argv")
end

function jp --description 'just push'
    command git pull && jc "$argv" && command git push
end

function jpf
    jp (mfa.git-rel-link "$argv")
end

alias fn=functions

# cmake make test
function cmt --description 'cmake make test'
    command cmake ..
    command make -j8
    if test (count $argv) -ge 1
        ./$argv[1]
    else
        ./demo
    end
end

function jwhich
    cd (command dirname (command which $argv[1]))
end

function just.find
    command find . -name "*"$argv"*"
end

function just
    switch $argv[1]
    case find
        just.find $argv[2..-1]
    end
end

function hp.vim
    mfa.open-link 'https://www.runoob.com/w3cnote/all-vim-cheatsheat.html'
end

function hp.re
    mfa.open-link "https://www.runoob.com/regexp/regexp-syntax.html"
end

function hp.re.meta
    mfa.open-link "https://www.runoob.com/regexp/regexp-metachar.html"
end

function hp.en
    mfa.open-link "https://www.youdao.com/result?word="$argv"&lang=en"
end

function hp.fr
    mfa.open-link "https://www.frdic.com/dicts/fr/$argv"
end

function hp.latex
    mfa.open-link "https://latex.guide/"
end

function hp.latex.2
    mfa.open-link "https://detexify.kirelabs.org/classify.html"
end

function baidu
    mfa.open-link "https://www.baidu.com/s?wd=$argv"
end

function baidu.ip
    baidu ip
end

function git-new
    mfa.open-link "https://github.com/new" 
end

function git.o
    mfa.open-link (mfa.github-link "$argv")
end

function jst.battery
    command system_profiler SPPowerDataType | command grep "State of Charge" | string trim -l
end

function jst.i
    command date
    jst.battery
end

function __jst.new-c
    touch .gitignore
    echo -e ".vscode\n.DS_Store\n" \
".nvimlog\n*.swp\nbuild/\n" > .gitignore
    mkdir build
    mkdir src
    touch src/main.c
    touch src/lib.c
    mkdir include
    touch include/lib.h
end

function jst
    function commit
        set commit \
"[<head>(, <options>)] <content>\n" \
"example: [feat, run] 添加核心模块\n" \
"<head>\n" \
"feat      功能    添加 / 更改主要功能\n" \
"fix       修复    修复运行的问题或 bug\n" \
"comment   注释\n" \
"doc       文档\n" \
"test      测试    添加 / 更改测试行的功能\n" \
"style     格式    规范代码风格, 调整代码顺序, 修改变量名等提升可读性的修改\n" \
"refactor  重构    不是新增功能、修改 bug 的代码变动\n" \
"perf      优化    提升性能、体验等\n" \
"config    配置    配置文件、资源文件相关的改动\n" \
"tools     工具    构建过程或辅助工具的变动\n" \
"revert    回滚    撤销 commit，回滚版本等\n" \
"merge     合并    合并分支, 在两个分支都有修改时使用\n" \
"sync      同步    同步分支, 在分支落后于另一分支时使用\n" \
"others    其它    一般在测试仓库功能的时候使用, 正常写代码不建议使用\n" \
"\n" \
"<options>\n" \
"run       在生产环境上运行代码\n" \
"to        只产生 diff 而不保证可用性, 适合于多次提交, 最后完善时移除 option\n" \
"\n" \
"<content>\n" \
"书写 commit 的具体信息\n"
        echo -e $commit
    end

    function git
        function o
            mfa.open-link (mfa.github-link "$argv")
        end
        function log
            command git log --pretty="%C(Yellow)%h  %C(reset)%ad (%C(Green)%cr%C(reset))%x09 %C(Cyan)%an: %C(reset)%s" --date=short  
        end
        $argv
        functions -e o
        functions -e log
    end

    function new-c
        __jst.new-c $argv
    end

    function find
        just.find "$argv"
    end

    function grep
        # -r: 查找所有文件夹
        # -i: 忽略大小写
        # -n: 输出行号
        command grep -nri "$argv" --exclude-dir=".git"
    end
    
    $argv
    functions -e commit
    functions -e git
    functions -e new-c
    functions -e find
    functions -e grep
end

function jst.resize-jpg
    mfa.open-link https://www.iloveimg.com/zh-cn/resize-image/resize-jpg
end

