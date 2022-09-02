using ReplMaker

basehist() = Base.active_repl.mistate.current_mode.hist

"""
    history()

Return the REPL history. This a `Matrix` containing one row for each command
and where the first column is the line number, the second column is the REPL
mode and the third column is the command as a `String`.
"""
history() = hcat(1:length(basehist().history), basehist().modes, basehist().history)

"""
    histexec(i::Integer)

Execute line number `i` from REPL history.

See also `history`.
"""
histexec(i::Integer) = Main.eval(Meta.parse(basehist().history[i]))

"""
    histsave(fname::AbstractString)

Save the REPL history in a file named `fname`.

See also `history`.
"""
function histsave(fname::AbstractString)
    n = 0
    open(fname, "w") do f
        foreach(history()[:,3]) do y
            n += write(f, y*"\n")
        end
    end
    "$n bytes written to $fname"
end

function substitution(istr::AbstractString)
    substr = split(istr, "!")
    if length(substr) == 1
        return istr
    else
        ostr = substr[1]
        for str in substr[2:end]
            m = match(r"^[-]?[0-9]+", str)
            ostr *=
                    if m == nothing
                        "!" * str
                    else
                        i = parse(Int64, m.match)
                        history()[(i>0 ? i : end+i),3] * str[length(m.match)+1:end]
                    end
        end
        return ostr
    end
end

function input_handler(inputstr)
    if inputstr == "!"
        linestoshow = max(2, displaysize(stdout)[1] - 5)
        history()[end-linestoshow:end,:]
    else
        Main.eval(Meta.parse(substitution(inputstr)))
    end
end

function __init__()
    initrepl(input_handler;
             prompt_text="History> ",
             prompt_color=166,
             start_key='!',
             mode_name=:history)
end

