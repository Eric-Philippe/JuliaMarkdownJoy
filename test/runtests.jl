using Test
include("../src/JuliaMarkdownJoy.jl")
import .JuliaMarkdownJoy: getFlagValue

include("../src/Extractor.jl")
import .Extractor: ExtractorManager, extract
@testset "JuliaMarkdownJoy CLI Tests" begin
    @test getFlagValue(["--input", "input.md"], "--input") == "input.md"
    @test getFlagValue(["--output", "output.md"], "--output") == "output.md"
    @test getFlagValue(["--input", "input.md", "--output", "output.md"], "--input") == "input.md"
    @test getFlagValue(["--input", "input.md", "--output", "output.md"], "--output") == "output.md"
end

@testset "Extractor Tests" begin
    @testset "extract_from_title" begin
        json_md_parsed = Dict("_content" => [Dict("type" => "h1", "content" => "Title"), Dict("type" => "p", "content" => "Paragraph")])
        conf = [Dict("find_property_" => "title", "after_a_" => "title", "named_" => ["Title"])]
        extractor = ExtractorManager(json_md_parsed, conf)
        @test extract(extractor) == Dict("title" => "Paragraph")
    end
end