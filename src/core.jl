using ReplMaker
import REPL
import REPL.LineEdit.complete_line
import REPL.LineEdit.CompletionProvider

struct HistoryCompletionProvider <: CompletionProvider
    repl_completion_provider::CompletionProvider
end

basehist = () -> Base.active_repl.mistate.current_mode.hist
prompt_text() = get(ENV, "HISTORY_PROMPT", "history> ")
separator() = get(ENV, "HISTORY_HINT_SEPARATOR", "  👉  ")

function redefine_basehist!(f::Function)
    isinteractive() && error("This function may not be used in interactive sessions")
    # The above restriction was made in order to prevent accidentally using
    # this in interactive sessions. I am open to removing it if there is a
    # sufficiently important use case. The function was mainly created in order
    # to facilitate automatic testing.
    global basehist = f
end

"""
    history()

Return the REPL history. This a `Matrix` containing one row for each command
and where the first column is the line number, the second column is the REPL
mode and the third column is the command as a `String`.
"""
history() = @static if VERSION < v"1.13"
    hcat(1:length(basehist().history), basehist().modes, basehist().history)
else
    [(Int64(x.index), x.mode, x.content) for x in basehist().history] |> stack |> permutedims
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
                            remainder = str[length(m.match)+1:end]
                            istr * remainder
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
        history()[max(1,end-linestoshow):end,:]
    elseif match(r"(^/.+)", inputstr) != nothing
        histsearch(inputstr[2:end])
    elseif match(r"(^\^.+)", inputstr) != nothing
        histsearch(s->startswith(s, inputstr[2:end]))
    else
        Main.eval(Meta.parse(substitution(inputstr)))
    end
end

function complete_line(x::HistoryCompletionProvider, s; hint::Any=:no_hint)
    firstpart = String(s.input_buffer.data[1:s.input_buffer.ptr-1])
    firstpartsub = substitution(firstpart; mode=:tab)
    if firstpart != firstpartsub
        if hint == true
            incomplete_end =  "  ⃨"
            w = displaysize(stdout)[2] - sum((prompt_text(), firstpart, separator(), incomplete_end) .|> length) - 1 # The final -1 helps in situations where emojis take up extra space
            hintstr = if contains("\n")(firstpartsub) || length(firstpartsub) > w
                split(firstpartsub, "\n")[1][1:min(end,w)] * incomplete_end
            else
                firstpartsub
            end
            return ([firstpart * separator() * hintstr ], firstpart, true)
        end
        return ([firstpartsub], firstpart, true)
    elseif VERSION <= v"1.9-"
        return complete_line(x.repl_completion_provider, s)
    else
        return complete_line(x.repl_completion_provider, s, Main)
    end
end

function __init__()
    if !isinteractive()
        @info "Session is not interactive"
        return
    end
    initrepl(input_handler;
             prompt_text=prompt_text,
             prompt_color=166,
             start_key='!',
             mode_name=:history,
             completion_provider=HistoryCompletionProvider(REPL.REPLCompletionProvider()))
end

