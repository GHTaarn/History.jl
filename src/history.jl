using ReplMaker

history() = nothing

@async initrepl(prompt_text="History> ", start_key='!', mode_name=:history) do inputstr
    println("hi story")
    if inputstr == "!"
        history()
    else
        Main.eval(Meta.parse(inputstr))
    end
end

