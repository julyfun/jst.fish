function __mfa.get-func-desc -d "Get the description of a function"
    string match -rq -- '--description [\'"](?<desc>[^\'"]+)' (functions $argv[1])
    echo $desc
end

function __mfa.subcommand-chain-string
    # set -l cmd (commandline -poc)
    set -l cmd (string split " " -- $argv) # don't pass -* to split!
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

function __mfa.cur-command-chain-is -d "(cmd_str)"
    set -l real_cmd_chain (string split ' ' -- (__mfa.subcommand-chain-string (commandline -poc)))
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

function __mfa.complete -d "(cur_cmd_str, subcmds, desc)"
    # __mfa.complete "jst git add" "template" "Add a template file"
    set -l cmd_arr (string split ' ' -- $argv[1])
    # can be subcommand or param
    set -l sub_arr (string split ' ' -- $argv[2])
    for sub in $sub_arr
        complete -c $cmd_arr[1] -n "__mfa.cur-command-chain-is $argv[1]" -f -a "$sub" -d "$argv[3]"
    end
end

# [automatically set jst subcommands completions]
# this has no subcommand
# -r means rename, recursively, regex...
function __mfa.complete-r
    set -l start $argv[1]
    set -l renamed_start $argv[2]
    if test -z $argv[2]
        set -l renamed_start $start
    end
    # 从原始名词映射到目标名字
    # argv: __jst.git.add.
    # __jst.git.add.a => jst git add a (and continue with __jst.git.add.a)
    # __jst.git.add.b => jst git add b
    set match (string match -r "^$start\..*\$" (functions --all))
    for func in $match
        set -l desc (__mfa.get-func-desc $func)
        # __jst.a.b.c => jst.a.b.c
        set -l renamed (string join '' $renamed_start (string sub -s (math (string length $start) + 1) $func))
        # => [jst a b c]
        set -l split (string split . $renamed)
        # => [jst a b]
        set -l parent (string join ' ' $split[1..-2])
        # => [c]
        set -l me $split[-1]
        __mfa.complete "$parent" "$me" "$desc"
    end
end

function __mfa.complete-d -d "(cur_cmd_str, dir_to_complete)"
    set -l cmd $argv[1]
    set -l dir $argv[2]
    for f in (ls $dir)
        __mfa.complete "$cmd" "$f" ""
    end
end

# 目前无法 late-run
# function __mfa.complete-runtime -d "(cur_cmd_str, execution)"
#     set -l cur_cmd -- "$argv[1]"
#     # can be subcommand or param
#     set -l execution "$argv[2]"
#     complete -c $cur_cmd[1] -n "__mfa.cur-command-chain-is $cur_cmd; and $execution" -f
# end

# [Example]
# __mfa.complete "jst complete" add1 "Add a template file"
# __mfa.complete "jst complete" add2 "Add a template file"

# complete all functions that start with __jst with their `-d` option, and rename completions to jst
# __mfa.complete-r __jst jst
