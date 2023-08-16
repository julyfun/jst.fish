function jp
    git pull \
    && git add . \
    && git commit -m "just push" \
    && git push
end

function cmt
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
