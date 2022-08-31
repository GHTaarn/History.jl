using ReplMaker

@async initrepl(prompt_text="History> ", start_key='!', mode_name=:history) do inputstr
    println("hi story")
    Main.eval(Meta.parse(inputstr))
end

