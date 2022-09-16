"""
    histexec(i::Integer)

Execute line number `i` from REPL history.

See also [`history`](@ref).
"""
histexec(i::Integer) = Main.eval(Meta.parse(basehist().history[i]))

