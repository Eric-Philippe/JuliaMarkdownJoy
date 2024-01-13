module Extractor

SEARCH_FIELDS = ["title", "link", "image"]
FORMAT = ["uppercase", "array"]
# a take_everything_after_ will auto format to html, also the only way to keep the alt from the images

export ExtractorManager
export extract
export SEARCH_FIELDS, FORMAT

"""
ExtractorManager is the main struct of the Extractor module. It contains the parsed markdown and the config.

json_md_parsed: Dict{String, Any} - The intermediate JSON parsed from the markdown
conf: Dict{String, Any} - The config that tells us what to extract

---

"""
struct ExtractorManager
    json_md_parsed::Dict{String, Any}
    conf::Dict{String, Any}

    function ExtractorManager(json_md_parsed::Dict{String, Any}, conf::Dict{String, Any})
        new(json_md_parsed, conf)
    end
end

"""
extractor = ExtractorManager(json_md_parsed, conf)
extract(extractor)

---

Extract the content from the markdown file using the config.
"""
function extract(self::ExtractorManager)
    fields = self.conf["fields"]
    final_content = Dict()
    for field in fields
        final_content[field["find_property_"]] = extract_from_field(self, field)
    end

    return final_content
end

function extract_from_field(self::ExtractorManager, field::Dict{String, Any})
    after_a = field["after_a_"]
    named = field["named_"]
    take_everything_after_ = haskey(field, "take_everything_after_") ? field["take_everything_after_"] : false
    format = haskey(field, "format") ? field["format"] : nothing

    if after_a == "title"
        return extract_from_title(self, named, take_everything_after_, format)
    elseif after_a == "link"
        return extract_from_link(self, named)
    elseif after_a == "image"
        return extract_from_image(self, named)
    elseif after_a == "table"
        return extract_from_table(self, named, after_a == "table_headers_included")
    else
        return "NOT_FOUND"
    end
end

function extract_from_title(self::ExtractorManager, named::Vector{Any}, take_everything_after_::Bool, format::Union{String, Nothing})
    if format == "array" return extract_table_from_title(self, named, take_everything_after_, format) end

    _content = self.json_md_parsed["_content"]
    index = findfirst(i -> startswith(i["type"], "h") && i["content"] in named, _content)

    if index == 0 return "NOT_FOUND" end

    content = []
    i = index + 1
    while i <= length(_content) && _content[i]["type"] == "p"
        push!(content, _content[i]["content"])
        i += 1
    end
    
    if format == "uppercase"
        return isempty(content) ? "EMPTY" : uppercase(join(content, "\n"))
    else
        return isempty(content) ? "EMPTY" : join(content, "\n")
    end
end

function extract_table_from_title(self::ExtractorManager, named::Vector{Any}, take_everything_after_::Bool, format::Union{String, Nothing})
    _content = self.json_md_parsed["_content"]
    index = findfirst(i -> startswith(i["type"], "h") && i["content"] in named, _content)
    if index == 0 return "NOT_FOUND" end

    content = []
    i = index + 1
    while i <= length(_content) && _content[i]["type"] == "table_row"
        push!(content, _content[i]["content"])
        i += 1
    end
    
    return isempty(content) ? "EMPTY" : content
end

"""
extract the text inside the parenthesis of a link
[link](https://example.com) -> https://example.com
"""
function extract_from_link(self::ExtractorManager, named::Vector{Any})
    _content = self.json_md_parsed["_content"]
    index = findfirst(i -> i["type"] == "link" && i["content"][1] in named, _content)

    if index == 0 || index === nothing return "NOT_FOUND" end

    return _content[index]["content"][2]
end

function extract_from_image(self::ExtractorManager, named::Vector{Any})
    _content = self.json_md_parsed["_content"]
    index = findfirst(i -> i["type"] == "image" && i["content"][1] in named, _content)

    if index == 0 || index === nothing return "NOT_FOUND" end

    return _content[index]["content"][2]
end

"""
 Return true if the line is a section end (title or separator)
"""
function is_section_end(line)
    line_type = line["type"]
    if line_type == "title" || line_type == "separator"
        return true
    end
end

end