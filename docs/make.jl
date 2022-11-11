using CoolWalkUtils
using Documenter

DocMeta.setdocmeta!(CoolWalkUtils, :DocTestSetup, :(using CoolWalkUtils); recursive=true)

makedocs(;
    modules=[CoolWalkUtils],
    authors="Henrik Wolf <henrik-wolf@freenet.de> and contributors",
    repo="https://github.com/SuperGrobi/CoolWalkUtils.jl/blob/{commit}{path}#{line}",
    sitename="CoolWalkUtils.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://SuperGrobi.github.io/CoolWalkUtils.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/SuperGrobi/CoolWalkUtils.jl",
    devbranch="main",
)
