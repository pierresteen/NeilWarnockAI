### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 6a5733b0-9258-11eb-1cb3-732a72a6ef6f
begin
	using StringEncodings
	using Statistics
	using DataFrames
	using PlutoUI
	using Plots
	using Flux
	using CSV
	TableOfContents()
end

# ╔═╡ ac577590-9258-11eb-3064-0dfac1dbecf1
md"""
# Player Gameweek Points Predictor

__This is the first component of our FPL *NeilWarnockAI* system.__

This model should be able to predict a player's total _Fantasy League_ points haul for a single gameweek.

## Overall Project Structure

The *`NeilWarnockAI`* system will then use the `PlayerPointsPredictor` to predict the points haul for every single player in league. Next we will employ a [bin-packing optimisation algorithm](https://en.wikipedia.org/wiki/Bin_packing_problem) to choose a squad made up of 11 starting players and 4 benched players, the total cost of which should not exceed £100m as per the FPL rules.

---

> __This proof-of-concept will focus on the 2018/2019 season dataset, seeing as there were rather skewed odds due to the *loss of home advantage* in the 2019/2020 season end and 2020/2021 full season.__

"""

# ╔═╡ f1382ba4-9281-11eb-1245-a339d8a4b42d
md"""
## Data Processing & Feature Engineering
"""

# ╔═╡ b5a32468-94d9-11eb-21dd-39a1df333ce5
"""
	getplayerid(string_in::String)

Takes a string corresponding to a player's name and id mashed togther in the follwing format:

	string_in = "firtsname_secondname_id"

**We only need the `"id"`.**

This function isolates the player identifier and returns it, parsing it to `Int` type.
"""
function getplayerid(string_in::String)::Int
	let
		chash = ""
		cnums = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
		for char in string_in
			if in(char, cnums) == true
				chash *=  char
			else
				continue
			end
		end
		
		return parse(Int, chash)
	end
end

# ╔═╡ 825a0948-928c-11eb-24c9-6775293f69cf
"""
	collect_stats(DATA_PATH::String,  target_gw::Int, lookback::Int)

Calculates the average performance of players, based on the player gameweek stats stored in the directory:

```julia
PLAYER_GWS_PATH = "./data/20**-**/gws/gw**.csv"
```
This function will average the stats over a number of previous gameweek statistics, the depth of which is determined by the `lookback::Int` parameter.

It returns the average gameweek performance statistics as `pp_average::DataFrame`.
"""
function getframes(DATA_PATH::String,  target_gw::Int, lookback::Int)
	frames = Array{DataFrame, 1}()
	
	for i in (target_gw - lookback):target_gw
		file = CSV.File(
			open(
				read,
				DATA_PATH * "gw" * string(i) * ".csv",
				enc"LATIN1"
			)
		) |> DataFrame
		push!(
			frames,
			select(
				file,
				Not(
					[:kickoff_time, :kickoff_time_formatted, :total_points]
				)
			)
		)
	end
	
	return frames
end

# ╔═╡ 64a440a2-94dd-11eb-2157-71ae7c817126
"""
	cleanframes(frames)

__Takes:__
```julia
frames::Vector{Any}
```
This is a vector of gameweek player performance stats DataFrames.

__Returns:__
```julia
clean_output::Vector{Any}
```
This is still a list of gameweek player performance stats, however the players' names have been replaced with their IDs and ordered accordingly, ready for averaging and summing operations.
"""
function idcleanframes(frames)
	clean_output = []
	
	for frame in frames
		frame_names = first(
			eachcol(frame)
		)
		array_ids = map(
			getplayerid,
			frame_names
		)
		frame_ids = DataFrame(
			:id => array_ids
		)
		frame_dat = select(
			frame,
			Not(:name)
		)
		push!(
			clean_output,
			sort!(
				hcat(
					frame_ids,
					frame_dat,
					makeunique = true
				),
				:id
			)
		)
	end
	
	return clean_output
end

# ╔═╡ 368f90fe-94dd-11eb-0681-13a581ed9466
test_frames = getframes("./data/2018-19/gws/", 5, 4)

# ╔═╡ a4f323de-94de-11eb-1bb8-97a7678f3f0a
clean_frames = idcleanframes(test_frames)

# ╔═╡ 728494fd-1c1d-48e7-b3c5-f3ccd9e519c1
typeof(clean_frames)

# ╔═╡ e061b752-389b-494b-9908-d4c04b05f27a
function pastperformance(id_frames, frame_count, opt=:average)
	id_matrices = vcat(id_frames...)	# stack all gameweek dataframes
	sort!(id_matrices, :id)				# sort by player :id
	unique_ids = unique(id_matrices[!, :id]) # extract array of unique player :id

	# create zero matrix for comp. storage and convert stacked frames to matrix
	ids_matrix = id_matrices |> Tables.matrix
	comp_matrix = zeros(Float64, length(unique_ids), size(id_matrices)[2])
	
	for i in 1:length(unique_ids)
		comp_matrix[i, 1] = unique_ids[i]
		count = 0
		for j in 1:size(ids_matrix)[1]
			if ids_matrix[j, 1] == unique_ids[i]
				count += 1
				comp_matrix[i, 2:end] += ids_matrix[j, 2:end]
			end
		end
		if opt == :weightedaverage
			comp_matrix[i, 2:end] = comp_matrix[i, 2:end] ./ count
		end
	end
	if opt == :average
		comp_matrix[:, 2:end] = comp_matrix[:, 2:end] ./ frame_count
	end
	
	return comp_matrix
end

# ╔═╡ c4f53067-f641-4baf-9605-9788f8e1db75
md"""
__Design question?__

Should we average a player's performance stats over the number of games he featured in the `lookback` scope?

_OR_

Should we average a player's performance stats over the number of games in the `lookback` scope for every player, regardless of whether the player is included in the other gameweek statistic dataframes? 
"""

# ╔═╡ b9c6cf5e-8412-4976-8cc4-5137fac01ee3
xx = pastperformance(clean_frames, 5, :average)

# ╔═╡ 1ef2af7c-6673-4ce6-895f-8309cf7fd7f8


# ╔═╡ 37b3c95a-925b-11eb-2562-437d30d936f1
gw1_frame = CSV.File(open(read, "./data/2018-19/gws/gw1.csv", enc"LATIN1")) |> DataFrame

# ╔═╡ 558d9dd6-925b-11eb-2850-4b491faa5441
begin
	gw1_cleaned = select(gw1_frame, Not([:kickoff_time,
										:kickoff_time_formatted,
										:name,
										:total_points]))
	gw1_scores = select(gw1_frame, :total_points) #total player point dataframe column
	gw1_sorted = hcat(gw1_scores, gw1_cleaned)
end;

# ╔═╡ de38a0ca-928a-11eb-0994-d3e566c40381
md"""
### Correlation Analysis

How well do the features in the gameweek player database correlate to total points haul for players?

Below is a heatmap of the correlation matrix, in the first row & column is the total points and the correlation to the other features is along the axes.
"""

# ╔═╡ 2b2b410c-925f-11eb-24aa-afcf04826510
begin
	gw1_mat = gw1_sorted |> Tables.matrix
	gw1_cor = cor(gw1_mat)
	heatmap(gw1_cor)
end

# ╔═╡ 7db1e45e-929a-11eb-1c6d-53bcd4d8b1e4
md"↓ labels corresponding to axis on heatmap ↑"

# ╔═╡ 67f8afee-929a-11eb-1db8-a9b5f9899449
names(gw1_sorted)

# ╔═╡ 67c7e9be-9262-11eb-3f3d-7902775cedab
"""
	sortbycorrelation(feature_matrix, feature_dframe)

Index feature dataframe `feature_dframe` according to which gameweek data features have a positive correlation to the player's points haul next gameweek.
"""
function sortbycorrelation(feature_matrix, feature_dframe)
	correlation = cor(feature_matrix)

	sorted_features = []
	for i in 1:size(correlation)[1]
		if correlation[i, 1] > 0
			push!(sorted_features, feature_matrix[:, i])
		end
	end
	
	return hcat(sorted_features...)
end

# ╔═╡ 8e3dc728-927e-11eb-2609-212b30036d55
gw1_sorted_features = sortbycorrelation(gw1_mat, gw1_sorted)

# ╔═╡ 52f92c04-92fe-11eb-1611-73cddd45e5ef
md"""
## Neural Network Model

The neural network predicts the points haul: `pp_predicted` for a player at a gameweek `n`.

To make this prediction the classifier model takes input categories:
  - `stats_performance` -- the player's performance stats up to that gameweek
  - `stats_fixture` -- the gameweek specific features

These input features will always be considered to be _one gameweek behind_.
If the gameweek is indexed as `n`, the input features are labelled `n-1` and will be used in the follwing way:

```math
\text{pp\_predicted}_{\ n}
\longleftarrow
\text{NN}\left[
	(\text{stats\_performance},\ \text{stats\_fixture})_{\ n-1}
\right] 
```

Both `stats_performance` and `stats_fixture` are comprised of many sub-features.
"""

# ╔═╡ 9f6ef4c8-93b3-11eb-0254-cbbdfa5b8f1f


# ╔═╡ 64ab0486-93df-11eb-2ed9-015b811e9abd


# ╔═╡ Cell order:
# ╠═6a5733b0-9258-11eb-1cb3-732a72a6ef6f
# ╟─ac577590-9258-11eb-3064-0dfac1dbecf1
# ╟─f1382ba4-9281-11eb-1245-a339d8a4b42d
# ╠═b5a32468-94d9-11eb-21dd-39a1df333ce5
# ╠═825a0948-928c-11eb-24c9-6775293f69cf
# ╠═64a440a2-94dd-11eb-2157-71ae7c817126
# ╠═a4f323de-94de-11eb-1bb8-97a7678f3f0a
# ╠═728494fd-1c1d-48e7-b3c5-f3ccd9e519c1
# ╠═368f90fe-94dd-11eb-0681-13a581ed9466
# ╠═e061b752-389b-494b-9908-d4c04b05f27a
# ╟─c4f53067-f641-4baf-9605-9788f8e1db75
# ╠═b9c6cf5e-8412-4976-8cc4-5137fac01ee3
# ╟─1ef2af7c-6673-4ce6-895f-8309cf7fd7f8
# ╠═37b3c95a-925b-11eb-2562-437d30d936f1
# ╠═558d9dd6-925b-11eb-2850-4b491faa5441
# ╟─de38a0ca-928a-11eb-0994-d3e566c40381
# ╠═2b2b410c-925f-11eb-24aa-afcf04826510
# ╟─7db1e45e-929a-11eb-1c6d-53bcd4d8b1e4
# ╠═67f8afee-929a-11eb-1db8-a9b5f9899449
# ╠═67c7e9be-9262-11eb-3f3d-7902775cedab
# ╠═8e3dc728-927e-11eb-2609-212b30036d55
# ╟─52f92c04-92fe-11eb-1611-73cddd45e5ef
# ╟─9f6ef4c8-93b3-11eb-0254-cbbdfa5b8f1f
# ╟─64ab0486-93df-11eb-2ed9-015b811e9abd
