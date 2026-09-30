using Test
using History

@testset "history" begin
    @static if VERSION < v"1.13"
        History.redefine_basehist!(() -> (; modes=[:history], history=["using History"]))
    else
        History.redefine_basehist!(() -> (; history=[(; index=1, mode=:history, content="using History")]))
    end

    @test history() == [1 :history "using History"]
end

