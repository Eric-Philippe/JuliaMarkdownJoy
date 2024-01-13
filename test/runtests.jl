using Test
include("../src/JuliaMarkdownJoy.jl")
import .JuliaMarkdownJoy: getFlagValue

@testset "JuliaMarkdownJoy CLI Tests" begin
    @test getFlagValue(["--input", "input.md"], "--input") == "input.md"
    @test getFlagValue(["--output", "output.md"], "--output") == "output.md"
    @test getFlagValue(["--input", "input.md", "--output", "output.md"], "--input") == "input.md"
    @test getFlagValue(["--input", "input.md", "--output", "output.md"], "--output") == "output.md"
end