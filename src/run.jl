include("JuliaMarkdownJoy.jl")
import .JuliaMarkdownJoy: main

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
