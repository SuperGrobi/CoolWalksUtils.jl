using CoolWalksUtils
using Documenter

DocMeta.setdocmeta!(CoolWalksUtils, :DocTestSetup, :(using CoolWalksUtils); recursive=true)

makedocs(;
    modules=[CoolWalksUtils],
    authors="Henrik Wolf <henrik-wolf@freenet.de> and contributors",
    repo="https://github.com/SuperGrobi/CoolWalksUtils.jl/blob/{commit}{path}#{line}",
    sitename="CoolWalksUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SuperGrobi.github.io/CoolWalksUtils.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Sun Position" => "SunPosition.md",
        "Projection" => "Projection.md",
        "Bounding Box" => "BoundingBox.md",
        "Maths" => "Maths.md",
        "Testing" => "Testing.md"
    ],
)

deploydocs(;
    repo="github.com/SuperGrobi/CoolWalksUtils.jl",
    devbranch="main",
)
