function __jst.get-func-desc -d "Get the description of a function"
    string match -rq -- '--description [\'"](?<desc>[^\'"]+)' (functions $argv[1])
    echo $desc
end

function __jst.subcommand-chain-string
    # set -l cmd (commandline -poc)
    set -l cmd (string split " " -- $argv) # `--` is to not pass -* to split
    if test (count $cmd) -le 1
        echo $cmd
        return 0
    end
    set -l res $cmd[1]
    for c in $cmd[2..-1]
        switch $c
            case '*=*'
                continue
            case '-*' # do not try to complete options as commands
                continue
            case '*'
                set res $res $c
        end
    end
    echo $res
end

function __jst.cur-command-chain-is -d "(cmd_str)"
    set -l real_cmd_chain (string split ' ' -- (__jst.subcommand-chain-string (commandline -poc)))
    set -l expected_cmd_chain (string split ' ' -- $argv)
    if test (count $real_cmd_chain) -ne (count $expected_cmd_chain)
        return 1
    end
    for i in (seq (count $real_cmd_chain))
        if test $real_cmd_chain[$i] != $expected_cmd_chain[$i]
            return 1
        end
    end
    return 0
end

# append completion
function __jst.complete -d "(cur_cmd_str, subcmds, desc)"
    # __jst.complete "jst git add" "template" "Add a template file"
    set -l cmd_arr (string split ' ' -- $argv[1])
    # can be subcommand or param
    set -l sub_arr (string split ' ' -- $argv[2])
    for sub in $sub_arr
        complete -c $cmd_arr[1] -n "__jst.cur-command-chain-is $argv[1]" -f -a "$sub" -d "$argv[3]"
    end
end

# [recursively set jst subcommands completions]
# this has no subcommand
# -r means rename, recursively, regex...
function __jst.complete-r
    set -l start $argv[1]
    set -l renamed_start $argv[2]
    # 从原始名词映射到目标名字
    # argv: __jst.git.add.
    # __jst.git.add.a => jst git add a (and continue with __jst.git.add.a)
    set match (string match -r "^$start\..*\$" (functions --all))
    for func in $match
        set -l desc (__jst.get-func-desc $func)
        # __jst.a.b.c => jst.a.b.c
        set -l renamed (string join '' $renamed_start (string sub -s (math (string length $start) + 1) $func))
        # => [jst a b c]
        set -l split (string split . $renamed)
        # => [jst a b]
        set -l parent (string join ' ' $split[1..-2])
        # => [c]
        set -l me $split[-1]
        __jst.complete "$parent" "$me" "$desc"
    end
end

function __jst.complete-d -d "(cur_cmd_str, dir_to_complete)"
    set -l cmd $argv[1]
    set -l dir $argv[2]
    for f in (ls $dir)
        __jst.complete "$cmd" "$f" ""
    end
end

# function __jst.complete-runtime -d "(cur_cmd_str, execution)"
#     # never `set -l -- a`
#     set -l cur_cmd_arr (string split ' ' -- "$argv[1]")
#     # can be subcommand or param
#     set -l execution "$argv[2]"
#     # echo "__jst.cur-command-chain-is $cur_cmd_arr; and eval $execution"
#     # don't forget eval and single quotes
#     complete -c $cur_cmd_arr[1] -n "__jst.cur-command-chain-is $cur_cmd_arr; and eval '$execution'" -f
# end

function __jst.complete-list -d "(cur_cmd_str, x1, x2...)"
    set -l cur_cmd_str $argv[1]
    for x in $argv[2..-1]
        __jst.complete "$cur_cmd_str" "$x" ""
    end
end

function __jst.complete-runtime-list-cmd -d "(cur_cmd_str, list_cmd)"
    # Be sure that the list_cmd works iff the cur_cmd works!
    set -l cur_cmd_str $argv[1]
    set -l cur_cmd_arr (string split ' ' -- "$argv[1]")
    set -l list_cmd "$argv[2]" # later eval
    # [todo] remove previous completions
    complete -c $cur_cmd_arr[1] -n "__jst.cur-command-chain-is \"$cur_cmd_str\"; and __jst.complete-list \"$cur_cmd_str\" (eval $list_cmd); and commandline -f complete" -f
end

# __jst.complete-runtime "jst cprt" '__jst.complete-d "jst cprt" "$(command git rev-parse --show-toplevel)"'
# __jst.complete-runtime-list-cmd "jst cprt" 'ls ..'
__jst.complete-runtime-list-cmd "docker attach" 'docker ps -aq'
# __jst.complete-runtime "docker attach" '__jst.complete-d "jst cprt" "$(command git rev-parse --show-toplevel)"'

# [Example]
# __jst.complete "jst complete" add1 "Add a template file"
# __jst.complete "jst complete" add2 "Add a template file"

# complete all functions that start with __jst with their `-d` option, and rename completions to jst
# __jst.complete-r __jst jst
