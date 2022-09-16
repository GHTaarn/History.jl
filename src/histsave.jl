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

