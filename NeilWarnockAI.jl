#=
Main NeilWarnockAI system script.
=#

include("./src/Extractor.jl")
include("./src/Formatter.jl")

# main script

names_list = playernames("./data/2016-17/")
player_gw = ioseparate("./data/2016-17/", (names_list[!, :Name])[2])
