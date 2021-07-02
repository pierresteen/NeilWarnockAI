#=
Main NeilWarnockAI system script.
=#


# package dependencies
# custom module dependencies

include("./src/Extractor.jl")
include("./src/For matter.jl")

# using .Extractor
# using .Formatter


# main script

# test_players = [
	# "Aaron_Cresswell",
	# "Aaron_Lennon",
	# "Alfred_N'Diaye"
# ]
#
# test_players = extractallplayers("data/2016-17/", test_players)


names_list = playernames("./data/2016-17/")
player_gw_df = ioseparate("./data/2016-17/", (names_list[!, :Name])[2])
