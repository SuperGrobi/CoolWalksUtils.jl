# Testing
## Introduction
Here we have a little macro to rerun arbitrary code multiple times in case it
failes for some reason. It is used to retry testing of downloading from osm,
since the server often is not willing to serve a request on the first try.

## API
```@index
Pages = ["Testing.md"]
```

```@autodocs
Modules = [CoolWalksUtils]
Pages = ["Testing.jl"]
```