using Test
using History

@testset "History" begin
    @testset "history" begin
        History.redefine_basehist!(() -> (; modes=[:history], history=["using History"]))

        @test history() == [1 :history "using History"]
    end
end

