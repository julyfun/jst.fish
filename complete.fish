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

function __mfa.cur-command-chain-is
    set -l cmd_chain (string split ' ' (__mfa.subcommand-chain-string (commandline -poc)))
    if test (count $cmd_chain) -ne (count $argv)
        return 1
    end
    for i in (seq (count $cmd_chain))
        if test $cmd_chain[$i] != $argv[$i]
            return 1
        end
    end
    return 0
end

function __mfa.complete
    # __mfa.complete "jst git add" "template" "Add a template file"
    set -l cmd (string split ' ' $argv[1])
    complete -c $cmd[1] -n "__mfa.cur-command-chain-is $cmd" -f -a "$argv[2]"  -d "$argv[3]"
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

# [Example]
# __mfa.complete "jst complete" add1 "Add a template file"
# __mfa.complete "jst complete" add2 "Add a template file"
# __mfa.complete-r __jst jst # complete all functions that start with __jst (and rename completion to jst)
