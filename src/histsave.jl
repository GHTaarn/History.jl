"""
    histsave(fname::AbstractString, nitems::Union{Symbol,Integer}=:all)

Save the REPL history in a file named `fname`. You can optionally restrict
the output to the `nitems` most recent items in the REPL history.

See also [`history`](@ref).
"""
function histsave(fname::AbstractString, nitems::Union{Symbol,Integer}=:all)
    @assert nitems == :all || nitems >= 0
    n = 0
    open(fname, "w") do f
        foreach(history()[(nitems == :all ? 1 : end+1-nitems):end,3]) do y
            n += write(f, y*"\n")
        end
    end
    "$n bytes written to $fname"
end

