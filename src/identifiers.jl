#=
	team and player identifiers
=#

# placeholder
# all historically present teams in the english premier league (2016-2021)

using CSV
using DataFrames

DATA_PATH = "./data/"
SEASON_PATH = [
	"2016-17/",
	"2017-18/",
	"2018-19/",
	"2019-20/",
	"2020-21/"
]
FOOTBALL_DATA_PATH = "footballdata.csv"

function read_teams(season_df)
	home = season_df[!, :HomeTeam][1:10]
	away = season_df[!, :AwayTeam][1:10]


	return cat(home, away; dims=1)
end

function all_teams(data_path, seasons, file; team_count=20)
	seasons_df = []
	for season in seasons
		push!(seasons_df, CSV.File(data_path * season * file) |> DataFrame)
	end

	return read_teams.(seasons_df) |> x -> cat(x...; dims=1) |> unique
end

teams_df = DataFrame(Teams = all_teams(DATA_PATH, SEASON_PATH, FOOTBALL_DATA_PATH))

CSV.write("./data/teams_ids.csv", teams_df)
