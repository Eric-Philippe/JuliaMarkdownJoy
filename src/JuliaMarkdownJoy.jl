using ArgParse

module JuliaMarkdownJoy

include("ReaderWriter.jl")
import .ReaderWriter: read_markdown_file, write_json_file, read_json_config_file

include("MarkdownParser.jl")
import .MarkdownParser: Parser, parse

include("Extractor.jl")
import .Extractor: ExtractorManager, extract, SEARCH_FIELDS, FORMAT

const MAIN_ARGUMENTS = ["extract", "parse", "convert", "help"]
const FLAGS = ["config", "input", "output"]
const FLAGS_SHORT = ["c", "i", "o"]

function getFlagValue(args::Array{String,1}, flag::String)
    index = findfirst(args .== flag)
    if index === nothing
        return nothing
    end
    return args[index + 1]
end

function parseCLI()
    inputLong = getFlagValue(ARGS, "--input")
    input = inputLong !== nothing ? inputLong : getFlagValue(ARGS, "-i")
    if input === nothing error("The input flag is required") end

    outputLong = getFlagValue(ARGS, "--output")
    output = outputLong !== nothing ? outputLong : getFlagValue(ARGS, "-o")
    if output === nothing output = "output.json" end

    # If the input ends with a /, it's a directory, so we fill a list with all the md files in it
    if endswith(input, "/")
        files = readdir(input)
        files = filter(x -> endswith(x, ".md"), files)
        files = map(x -> input * x, files)
    else
        files = [input]
    end
    
    parsed_array = []
    for file in files
        mdParser = Parser(read_markdown_file(file))

        json = parse(mdParser)

        push!(parsed_array, json)
    end

    write_json_file(output, parsed_array)

    println("🎉 $(length(files)) Markdown files parsed successfully in $(output) !")

    exit(0)
end

function extractCLI()
    inputLong = getFlagValue(ARGS, "--input")
    input = inputLong !== nothing ? inputLong : getFlagValue(ARGS, "-i")
    if input === nothing error("The input flag is required") end

    outputLong = getFlagValue(ARGS, "--output")
    output = outputLong !== nothing ? outputLong : getFlagValue(ARGS, "-o")
    if output === nothing output = "output.json" end

    configLong = getFlagValue(ARGS, "--config")
    config = configLong !== nothing ? configLong : getFlagValue(ARGS, "-c")
    if config === nothing error("The config flag is required") end

    if endswith(input, "/")
        files = readdir(input)
        files = filter(x -> endswith(x, ".md"), files)
        files = map(x -> input * x, files)
    else
        files = [input]
    end

    extracted_array = []
    for file in files
        mdParser = Parser(read_markdown_file(file))

        json = parse(mdParser)

        extractor = ExtractorManager(json, read_json_config_file(config))

        extracted = extract(extractor)

        push!(extracted_array, extracted)
    end

    write_json_file(output, extracted_array)

    println("🎉 $(length(files)) Markdown files extracted successfully in $(output) !")

    exit(0)
end

function main()
    # If there are no arguments, throw an error
    if length(ARGS) == 0
        error("You must provide at least one argument")
    end
    # If the next argument is not one of these, throw an error
    if ARGS[1] ∉ MAIN_ARGUMENTS
        error("The first argument must be one of the following: $(join(MAIN_ARGUMENTS, ", "))")
    end
    
    if ARGS[1] == "parse"
        parseCLI()
    elseif ARGS[1] == "extract"
        extractCLI()
    elseif ARGS[1] == "convert"
        println("NOT_IMPLEMENTED")
    elseif ARGS[1] == "help"
        println("NOT_IMPLEMENTED")
    end
end

    export getFlagValue
    export main

end