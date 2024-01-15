using ArgParse

module JuliaMarkdownJoy

include("ReaderWriter.jl")
import .ReaderWriter: read_markdown_file, write_json_file, read_json_config_file

include("MarkdownParser.jl")
import .MarkdownParser: Parser, parseFiles, parse

include("Extractor.jl")
import .Extractor: ExtractorManager, extract, SEARCH_FIELDS, FORMAT

include("Tools.jl")
import .Tools: get_dead_links

const MAIN_ARGUMENTS = ["extract", "parse", "convert", "help", "test-dead-links"]
const FLAGS = ["config", "input", "output"]
const FLAGS_SHORT = ["c", "i", "o"]

"""
============ MAIN FUNCTION ============
"""
# Main function to handle the command line arguments
function main()
    if length(ARGS) == 0
        error("You must provide at least one argument")
    end
    if ARGS[1] ∉ MAIN_ARGUMENTS
        error("The first argument must be one of the following: $(join(MAIN_ARGUMENTS, ", "))")
    end
    if ARGS[1] == "parse"
        parseCLI()
    elseif ARGS[1] == "extract"
        extractCLI()
    elseif ARGS[1] == "test-dead-links"
        test_dead_links()
    elseif ARGS[1] == "convert"
        println("NOT_IMPLEMENTED")
    elseif ARGS[1] == "help"
        println("NOT_IMPLEMENTED")
    end
end

"""
============ METHODS CLI ============
"""
# Function to handle the parse command
function parseCLI()
    input, output = getInputOutput()
    files = getFiles(input)
    parsed_array = parseFiles(files)
    write_json_file(output, parsed_array)
    println("🎉 $(length(files)) Markdown files parsed successfully in $(output) !")
    exit(0)
end


# Function to handle the extract command
function extractCLI()
    input, output = getInputOutput()
    configLong = getFlagValue(ARGS, "--config")
    config = configLong !== nothing ? configLong : getFlagValue(ARGS, "-c")

    if config === nothing error("The config flag is required") end
    
    files = getFiles(input)
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

function test_dead_links()
    input, output = getInputOutput()

    files = getFiles(input)
    parsed_array = parseFiles(files)
    dead_links = []
    n = 1
    for parsed in parsed_array
        _dead_links = get_dead_links(parsed["_content"])
        if length(_dead_links) > 0
            println("🚨 $(length(_dead_links)) dead links found in $(files[n])")
            println("Dead links:")
            for dead_link in _dead_links
                push!(dead_links, dead_link)
                println("  - $dead_link")
            end
        end
        n += 1
    end

    if length(dead_links) > 0
        println("🚨 $(length(dead_links)) dead links found in $(length(files)) files")
        exit(1)
    else
        println("🎉 No dead links found in $(length(files)) files")
        exit(0)
    end

end

"""
============ UTILS METHODS ============
"""
# Function to get the value of a flag
function getFlagValue(args::Array{String,1}, flag::String)
    index = findfirst(args .== flag)
    if index === nothing
        return nothing
    end
    return args[index + 1]
end

# Function to get the input and output flags
function getInputOutput()
    inputLong = getFlagValue(ARGS, "--input")
    input = inputLong !== nothing ? inputLong : getFlagValue(ARGS, "-i")
    if input === nothing error("The input flag is required") end

    outputLong = getFlagValue(ARGS, "--output")
    output = outputLong !== nothing ? outputLong : getFlagValue(ARGS, "-o")
    if output === nothing output = "output.json" end

    return input, output
end

# Function to get the list of files from the input
function getFiles(input::String)
    if endswith(input, "/")
        files = readdir(input)
        files = filter(x -> endswith(x, ".md"), files)
        # Remove the one that start with a _
        files = filter(x -> !startswith(x, "_"), files)
        return map(x -> input * x, files)
    else
        return [input]
    end
end

    export getFlagValue
    export main

end