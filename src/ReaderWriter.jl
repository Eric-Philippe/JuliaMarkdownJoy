module ReaderWriter

using JSON

include("Extractor.jl")
import .Extractor: SEARCH_FIELDS, FORMAT

function read_markdown_file(filename)
    # If the filename does't end with .md, throw an error
    if !endswith(filename, ".md")
        error("The file must be a markdown file (.md)")
    end

    # If the file doesn't exist, throw an error
    if isfile(filename) == false
        error("The file doesn't exist")
    end

    # If the file is empty, throw an error
    if filesize(filename) == 0
        error("The file is empty")
    end

    # Read the file
    md_content = read(filename, String)

    return md_content
end

function write_json_file(filename, json_content)
    # If the filename does't end with .json, throw an error
    if !endswith(filename, ".json")
        error("The file must be a json file (.json)")
    end

    open(filename, "w") do file
        write(file, JSON.json(json_content, 4))
    end
end

function read_json_config_file(filename)::Vector{Dict{String, Any}}
    # If the filename does't end with .json, throw an error
    if !endswith(filename, ".json")
        error("The file must be a json file (.json)")
    end

    # If the file doesn't exist, throw an error
    if isfile(filename) == false
        error("The file doesn't exist")
    end

    # If the file is empty, throw an error
    if filesize(filename) == 0
        error("The file is empty")
    end

    # Read the file
    json_content = JSON.parsefile(filename)

    return json_content["fields"]
end

function check_json_config_validity(json_content)
    """
    json must be at that format:
    {
        fields: [
            {
                find_property_: "property_name", // Mandatory
                after_a_: "after_a", // Mandatory
                named_: "named", // Mandatory
                take_everything_after_: "take_everything_after", // Optional
                format: "format", // Optional
            }
        ]
    }
    """
    if !haskey(json_content, "fields")
        error("The json config file must have a fields key")
    end

    for field in json_content["fields"]
        if !haskey(field, "find_property_")
            error("The field must have a find_property_ key")
        end
        if !haskey(field, "after_a_")
            error("The field must have a after_a_ key")
        end
        if field["after_a_"] ∉ SEARCH_FIELDS
            error("The value of the field after_a_ must be one of the following: $(join(SEARCH_FIELDS, ", "))")
        end
        if !haskey(field, "named_")
            error("The field must have a named_ key")
        end
        if haskey(field, "format")
            if field["format"] ∉ FORMAT
                error("The value of the field format must be one of the following: $(join(FORMAT, ", "))")
            end
        end
    end

    return true
end

export read_markdown_file
export write_json_file
export read_json_config_file

end