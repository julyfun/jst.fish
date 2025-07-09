function printtime --on-event fish_postexec
    set duration (echo "$CMD_DURATION 1000" | awk '{printf "%.3fs", $1 / $2}')
    echo ⏰ $duration\t📅 (date "+%y-%m-%d %H:%M:%S")
end

# Use ctrl + o to `cd ..`
bind \co 'cd ..; commandline -f repaint'

alias l='ls -ltr'

function cp-file
    cat $argv | __jst.copy
end

function cpwd
    set output (jst pwd-path $argv)
    echo -n $output | __jst.copy
    echo $output
end

function cpit
    echo -n "$argv" | jcp
end

function fn
    if contains "$argv" (functions --all)
        functions $argv
        return
    end
    functions (string join . __$argv[1] $argv[2..-1])
end

function jwhich
    cd (dirname (which $argv))
end

alias ja="jst commit" # atomic commit
alias jp="jst push"

alias jcp="__jst.copy"
alias jps="__jst.paste"

function jlast
    set res (ls -tr)
    echo $res[-1]
end

