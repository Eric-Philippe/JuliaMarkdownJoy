module Tools

using HTTP

export has_any_dead_link

function check_link(url)
    try
        response = HTTP.request("GET", url)
        if response.status != 200
            return true
        end
    catch e
        if isa(e, HTTP.Exceptions.StatusError) && e.status == 500
            return false
        end
        return true
    end
    return false
end

function get_dead_links(parsed_md)
    dead_links = []
    tasks = []
    for el in parsed_md
        if el["type"] == "link" || el["type"] == "image"
            url = el["content"][2]
            task = @async (url, check_link(url))
            push!(tasks, task)
        end
    end

    for task in tasks
        url, is_dead = fetch(task)
        if is_dead
            push!(dead_links, url)
        end
    end

    return dead_links
end

end # module Tools