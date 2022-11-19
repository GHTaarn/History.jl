"""
    histsave(fname::AbstractString, indices::Union{Symbol,AbstractVector{<:Integer}}=:all)
    histsave(fname::AbstractString, nitems::Integer)

Save the REPL history in a file named `fname`. You can optionally restrict
the output to the `nitems` most recent items in the REPL history or specify
`indices` as the specific indices of the items to be output to the file.

See also [`history`](@ref).
"""
function histsave(fname::AbstractString, itemspec::Union{Symbol,Integer,AbstractVector{<:Integer}}=:all)
    @assert itemspec == :all || itemspec isa AbstractVector{<:Integer} || itemspec >= 0
    n = 0
    open(fname, "w") do f
        foreach(history()[(itemspec isa AbstractVector ? itemspec : ((itemspec == :all ? 1 : end+1-itemspec):end)),3]) do str
            n += write(f, str * "\n")
        end
    end
    "$n bytes written to $fname"
end

