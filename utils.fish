
function jp
    git add .
    git commit -m "just push"
    git push
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

