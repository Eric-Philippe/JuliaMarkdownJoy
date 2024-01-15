module HtmlConverter

export convert

function html_convert(parsed_array::Vector{Any})
    html_content = ""
    index = 1
    in_table = false
    for parsed in parsed_array
        type = parsed["type"]
        if type == "p"
            html_content *= get_paragraph_html(String(parsed["content"]))
        elseif startswith(type, "h")
            html_content *= get_title_html(String(parsed["type"]), String(parsed["content"]))
        elseif type == "separator"
            html_content *= "<hr>"
        elseif type == "image"
            html_content *= get_image_html(String(parsed["content"][2]), String(parsed["content"][1]))
        elseif type == "link"
            html_content *= get_link_html(String(parsed["content"][2]), String(parsed["content"][1]))
        elseif type == "quote"
            html_content *= get_quote_html(String(parsed["content"]))
        elseif type == "list"
            string_list = []
            for item in parsed["content"]
                push!(string_list, String(item))
            end            
            html_content *= get_list_html(string_list)
        elseif type == "code_block"
            html_content *= get_code_blocks_html(String(parsed["content"][1]), String(parsed["content"][2]))
        elseif type == "table_row"
            # Take the next n elements that are table_row and put them in a table
            table_rows = []
            for i in index:length(parsed_array)
                if parsed_array[i]["type"] == "table_row"
                    push!(table_rows, parsed_array[i]["content"])
                    index += 1
                else
                    break
                end
            end

            html_content *= get_table_html(table_rows)
        end
        
        index += 1
    end

    return html_content
end

function get_paragraph_html(content::String)
    # Return the p but also replace any ** with <strong> and * with <em>
    content = replace(content, r"\*\*(.*?)\*\*" => "<strong>\\1</strong>")
    content = replace(content, r"\_(.*?)\_" => "<em>\\1</em>")
    return "<p>$(content)</p>"
end

function get_title_html(type::String, title::String)
    return "<$(type)>$(title)</$(type)>"
end

function get_image_html(src::String, alt::String)
    return "<img src=\"$(src)\" alt=\"$(alt)\">"
end

function get_link_html(href::String, content::String)
    return "<a href=\"$(href)\">$(content)</a>"
end

function get_quote_html(content::String)
    return "<blockquote>$(content)</blockquote>"
end

function get_list_html(content::Vector{Any})
    list_html = "<ul>"
    for item in content
        list_html *= "<li>$(item)</li>"
    end
    list_html *= "</ul>"
    return list_html
end

function get_code_blocks_html(language::String, content::String)
    return "<pre><code class=\"language-$(language)\">$(content)</code></pre>"
end

function get_table_html(table_rows:: Vector{Any})
    table_html = "<table>"
    # if table_head !== nothing
    #     table_html *= "<thead><tr>"
    #     for head in table_head
    #         table_html *= "<th>$(head)</th>"
    #     end
    #     table_html *= "</tr></thead>"
    # end
    table_html *= "<tbody>"
    for row in table_rows
        table_html *= "<tr>"
        for cell in row
            table_html *= "<td>$(cell)</td>"
        end
        table_html *= "</tr>"
    end
    table_html *= "</tbody></table>"
    return table_html
end



end # module HtmlConverter