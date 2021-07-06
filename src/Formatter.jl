#=
Data formatting module.
Splits the data imported with `Extractor.jl` into workable chunks for future manipulation (training/validation/analysis).
Dependencies:
	using DataFrames
=#


include("./Extractor.jl")

function ioseparate(data_path, player_name)
	player_data = extractplayerdf(data_path, player_name, "/gw.csv")

	total_points = player_data[!, :total_points] # get fpl gameweek points
	total_inputs = select!(
		player_data,
		Not([:total_points, :kickoff_time, :kickoff_time_formatted])
	)

	return (total_inputs, total_points)
end
