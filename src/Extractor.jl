#=
Data extracting functions.
Dependencies:
	using StringEncodings
	using DataFrames
	using CSV
=#

# module Extractor
# export extractgw, extractallgws
# export extractplayerdf, extractallplayers
# export spliceunderscore, splicename, playernames

# using StringEncodings
# using CSV
# using DataFrames

#=
Gameweek data extractor functions.
Data stored at `data/<season_id>/gws/`.
=#

function extractgw(data_path, gw_id)
	data_path *= "gws/gw" * string(gw_id) * ".csv"
	gw_file = CSV.File(open(data_path, enc"windows-1252"))

	return DataFrame(gw_file)
end

function extractallgws(data_path, season_length)
	all_gameweeks = [extractgw(data_path, 1),] # first gw ::df
	for i in 2:season_length
		push!(all_gameweeks, extractgw(data_path, i))
	end

	return all_gameweeks
end

# Example:
# all_gameweek = extractallgws("data/<season>/", 38)


#=
Player data extractor functions.
Data stored at `data/<season_id>/players/<player_name`.
=#

function extractplayerdf(data_path, player_name, file)
	data_path *= "players/" * string(player_name) * file
	pl_file = CSV.File(open(data_path, enc"windows-1252"))

	return DataFrame(pl_file)
end

function extractallplayers(data_path, player_names)
	all_players = [extractplayerdf(data_path, player_names[1], "/gw.csv"),]
	for i in 2:length(player_names)
		push!(all_players, extractplayerdf(data_path, player_names[i], "/gw.csv"))
	end

	return all_players
end

# Example:
# player_names = [...]::Array{String, 1}
# all_players = extractallplayers("data/<season>/", player_names)


function playerhistories(data_path, player_names)
	all_histories = [extractplayerdf(data_path, player_names[1], "/history.csv"),]
	for i in 2:length(player_names)
		push!(all_histories, extractplayerdf(data_path, player_names[i], "/history.csv"))
	end

	return all_histories
end

#=
Player names extractor function.
Fetch a dataframe of player names, surnames and ids from the season data path, found at: `data/<season>/player_idlist.csv`
=#

function spliceunderscore(string1, string2)
	return string1 * "_" * string2
end

function playernames(data_path)
	data_path *= "player_idlist.csv"
	names = CSV.File(open(data_path)) |> DataFrame

	# splice together firstname_surname for compatibility with data dirs
	spliced_names = map(
		spliceunderscore,
		names[!, :first_name],
		names[!, :second_name]
	)

	return DataFrame(Name = spliced_names, ID = names[!, :id])
end

# end