using ReplMaker
import REPL
import REPL.LineEdit.complete_line
import REPL.LineEdit.CompletionProvider

struct HistoryCompletionProvider <: CompletionProvider
    repl_completion_provider::CompletionProvider
end

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

function substitution(istr::AbstractString; mode=:eval)
    @assert mode in [:eval, :tab]
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
                        if mode == :tab && i == 0
                            istr
                        else
                            if mode == :tab && i < 0
                                i += 1
                            end
                            history()[(i>0 ? i : end+i),3] * str[length(m.match)+1:end]
                        end
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

function complete_line(x::HistoryCompletionProvider, s)
    firstpart = String(s.input_buffer.data[1:s.input_buffer.ptr-1])
    firstpartsub = substitution(firstpart; mode=:tab)
    if firstpart != firstpartsub
        return ([firstpartsub], firstpart, true)
    else
        return complete_line(x.repl_completion_provider, s)
    end
end

function __init__()
    initrepl(input_handler;
             prompt_text="History> ",
             prompt_color=166,
             start_key='!',
             mode_name=:history,
             completion_provider=HistoryCompletionProvider(REPL.REPLCompletionProvider()))
end

