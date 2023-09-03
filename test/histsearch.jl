using Test
using History

@testset "histsearch" begin
    modes = Symbol.('a':'z')
    h = string.('a':'z')
    History.redefine_basehist!(() -> (; modes=modes, history=h))

    @test histsearch(s -> s > "x") == [25 :y "y"; 26 :z "z"]
    @test histsearch("b") == [2 :b "b"]
    @test histsearch(r"^[ce]") == [3 :c "c"; 5 :e "e"]
    @test size(histsearch(r"^ce"), 1) == 0
#    @test histsearch(r"^ce") == Matrix{Any}(fill(nothing,0,3))
end

