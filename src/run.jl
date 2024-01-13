using ArgParse

include("MarkdownReader.jl")
import .MarkdownReader: read_markdown_file

include("MarkdownParser.jl")
import .MarkdownParser: Parser, parse

function main()
    # Read the markdown file
    md_content = read_markdown_file("README.md")

    # If the flag --config is not present, throw an error
    if findfirst(x->x=="--config", ARGS) == nothing
        error("The flag --config is required")
    end

    # Get the config file after the --config flag
    config_file = ARGS[findfirst(x->x=="--config", ARGS)+1]

    println(config_file)

    # Parse the content
    mdParser = Parser(md_content)
    json_content = parse(mdParser)

    # Print the parsed content
    println(json_content)
end

main()