module MarkdownParser

import JSON

TYPES = ["h1", "h2", "h3", "h4", "h5", "h6", "p", "quote", "separator", "table_headers", "table_row", "code_block", "list", "link", "image"]

mutable struct Parser
    md_content::String
    json_content::Dict{String, Any}
    function Parser(md_content::String)
        html_tag_regex = r"<.*>"
        if occursin(html_tag_regex, md_content)
            error("HTML tags are not allowed in the content")
        end
        new(md_content, Dict("_content" => []))
    end
end

function add_to_json(parser::Parser, type::String, content::Any)
    push!(parser.json_content["_content"], Dict("type" => type, "content" => content))
end

function parse(parser::Parser) :: Dict{String, Any}
    lines = split(parser.md_content, "\n")
    index = 1
    while index <= length(lines)
        line = lines[index]
        if line == ""
            index += 1
            continue
        end
        if startswith(line, "#")
            parse_title(parser, String(line))
        elseif startswith(line, "|")
            end_index = index
            while end_index <= length(lines) && strip(lines[end_index]) != ""
                end_index += 1
            end
            parse_table(parser, Vector{String}(lines[index:end_index]))
            index = end_index - 1
        elseif startswith(line, "```")
            code_block_lines = [line]
            index += 1
            while !startswith(lines[index], "```")
                push!(code_block_lines, lines[index])
                index += 1
            end
            parse_code_block(parser, Vector{String}(code_block_lines))
        elseif startswith(line, "- ")
            parse_list(parser, Vector{String}([lines[i] for i in index:length(lines) if startswith(lines[i], "- ")]))
            while startswith(lines[index], "- ")
                index += 1
            end
            index -= 1
        elseif occursin(r"\[.*\]\(http.*\)", line)
            parse_link(parser, String(line))
        elseif occursin(r"\!\[.*\]\(.*\)", line)
            parse_image(parser, String(line))
        elseif startswith(line, "---")
            add_to_json(parser, "separator", "")
        elseif startswith(line, "> ")
            quote_lines = [line]
            index += 1
            while index <= length(lines) && startswith(lines[index], "> ")
                push!(quote_lines, lines[index])
                index += 1
            end
            parse_quote(parser, quote_lines)
            index -= 1
        else
            parse_paragraph(parser, String(line))
        end
        index += 1
    end
    return parser.json_content
end

function parse_title(parser::Parser, title::String)
    hashtag_count = length(collect(eachmatch(r"#", title)))
    after_hashtag = strip(title[hashtag_count+1:end])
    add_to_json(parser, "h$hashtag_count", after_hashtag)
end

function parse_paragraph(parser::Parser, paragraph::String)
    add_to_json(parser, "p", paragraph)
end

function parse_quote(parser::Parser, quote_lines::Array{String,1})
    add_to_json(parser, "quote", join(quote_lines, "\n"))
end

function parse_table(parser::Parser, lines::Array{String,1})
    headers = strip.(split(lines[1], "|")[2:end-1])
    add_to_json(parser, "table_headers", headers)
    for line in lines[3:end - 1]
        row = strip.(split(line, "|")[2:end-1])
        add_to_json(parser, "table_row", row)
    end
end

function parse_code_block(parser::Parser, lines::Array{String,1})
    language = strip(lines[1][4:end]) != "" ? strip(lines[1][4:end]) : "unknown"
    add_to_json(parser, "code_block", [language, join(lines[2:end], "\n")])
end

function parse_list(parser::Parser, lines::Array{String,1})
    add_to_json(parser, "list", strip.(lines) .|> line -> line[3:end])
end

function parse_link(parser::Parser, line::String)
    line = line[2:end-1]
    add_to_json(parser, "link", split(line, "]("))
end

function parse_image(parser::Parser, line::String)
    add_to_json(parser, "image", split(line[3:end-1], "]("))
end

# Get the content of the test.md file
# md_content = read("test.md", String)

# # Parse the content
# parser = Parser(md_content)
# json_content = parse(parser)

# println(json_content)

# # Save the parsed content to a JSON file
# open("testJulia.json", "w") do f
#     JSON.print(f, json_content)
# end

export Parser
export parse
export TYPES

end