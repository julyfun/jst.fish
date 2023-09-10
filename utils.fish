function jp --description 'just push'
    git pull \
    && git add . \
    && git commit -m "just push" \
    && git push
end

function jc --description 'just commit'
    git add . && git commit -m $argv[1]
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
    grep -r $argv[1] --include $argv[2]
end

function just
    switch $argv[1]
    case find
        just.find $argv[2..-1]
    end
end

function mfa.open-link
    switch (uname)
    case Darwin
        open -a "Google Chrome" $argv
    case Linux
    end
end

function hp.vim
    mfa.open-link 'https://www.runoob.com/w3cnote/all-vim-cheatsheat.html'
end

function hp.git-commit
    mfa.open-link 'https://developer.aliyun.com/article/770277'
end

function hp.fr
    mfa.open-link "https://www.frdic.com/dicts/fr/$argv"
end

function baidu
    mfa.open-link "https://www.baidu.com/s?wd=$argv"
end

function baidu.ip
    baidu ip地址
end

