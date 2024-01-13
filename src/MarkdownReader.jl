module MarkdownReader

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

export read_markdown_file

end