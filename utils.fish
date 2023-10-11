function jc --description 'just commit'
    # non-empty
    if test -z "$argv"
        set commit "just commit"
    else
        set commit "$argv"
    end
    set top_dir (git rev-parse --show-toplevel)
    git add "$top_dir" \
    && git commit -m "$commit"
end

function jp --description 'just push'
    git pull && jc "$argv" && git push
end

alias fn=functions

# cmake make test
function cmt --description 'cmake make test'
    cmake ..
    make -j8
    if test (count $argv) -ge 1
        ./$argv[1]
    else
        ./demo
    end
end

function jwhich
    cd (dirname (which $argv[1]))
end

function just.find
    find . -name "*"$argv"*"
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

function hp.git-commit
    mfa.open-link 'https://developer.aliyun.com/article/770277'
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
