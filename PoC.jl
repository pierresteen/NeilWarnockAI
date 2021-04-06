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

# ╔═╡ ebf77642-299c-480b-a079-271a8c5ad0fa
md"""
## Data Processing Testing
"""

# ╔═╡ f1382ba4-9281-11eb-1245-a339d8a4b42d
md"""
## Data Processing Functions
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
	collect_stats(DATA_PATH::String,  target_gw::Int, scope::Int)

Calculates the average performance of players, based on the player gameweek stats stored in the directory:

```julia
PLAYER_GWS_PATH = "./data/20**-**/gws/gw**.csv"
```
This function will average the stats over a number of previous gameweek statistics, the depth of which is determined by the `scope::Int` parameter.

It returns the average gameweek performance statistics as `pp_average::DataFrame`.
"""
function getframes(DATA_PATH::String,  target_gw::Int, scope::Int)
	frames = Array{DataFrame, 1}()
	
	for i in (target_gw - scope):target_gw
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

# ╔═╡ 368f90fe-94dd-11eb-0681-13a581ed9466
test_frames = getframes("./data/2018-19/gws/", 5, 4);

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

# ╔═╡ a4f323de-94de-11eb-1bb8-97a7678f3f0a
clean_frames = idcleanframes(test_frames);

# ╔═╡ e061b752-389b-494b-9908-d4c04b05f27a
"""
	pastperformance(id_frames, frame_count, opt=:weightedaverage)
	pastperformance(id_frames, frame_count, opt=:average)
	pastperformance(id_frames, frame_count, opt=:total)

__Takes:__

`id_frames::DataFrame`, an array of type `Any` and length `frame_count` in reverse-chronological order of past gameweek player performances and processes them according to the `opt` parameter.

__Returns:__
```julia
opt = :weightedaverage
```
Computes a matrix of combined `id_frames` with each player's stats averaged over the __gameweeks they feature in__ over the target range.

```julia
opt = :average
```
Computes a matrix of combined `id_frames` with each player's stats averaged over the __entire__ target range.

```julia
opt = :total
```
Computes a matrix of combined `id_frames` with each player's stats __summed__ over the target range.

"""
function pastperformance(id_frames, frame_count, opt=:average)
	id_matrices = vcat(id_frames...)	# stack all gameweek dataframes
	sort!(id_matrices, :id)				# sort by player :id
	unique_ids = unique(id_matrices[!, :id]) # extract array of unique player :id

	# create zero matrix for comp. storage and convert stacked frames to matrix
	ids_matrix = id_matrices |> Tables.matrix
	cmp_matrix = zeros(
		Float64,
		length(unique_ids),
		size(id_matrices)[2]
	)
	
	for i in 1:length(unique_ids)
		cmp_matrix[i, 1] = unique_ids[i]
		count = 0
	
		for j in 1:size(ids_matrix)[1]
			if ids_matrix[j, 1] == unique_ids[i]
				count += 1
				cmp_matrix[i, 2:end] += ids_matrix[j, 2:end]
			end
		end
	
		if opt == :weightedaverage
			cmp_matrix[i, 2:end] = cop_matrix[i, 2:end] ./ count
		end
	end
	
	if opt == :average
		cmp_matrix[:, 2:end] = cmp_matrix[:, 2:end] ./ frame_count
	end
	
	return cmp_matrix
end

# ╔═╡ b9c6cf5e-8412-4976-8cc4-5137fac01ee3
test_matrix = pastperformance(clean_frames, 5, :average)

# ╔═╡ 4175c783-792c-4ef9-9804-2ce22d92e9be
function gwtomatrix(DATA_PATH, target_gw, scope, opt=:average)
	# fetch dataframe array and clean to :id indexer form
	gw_frames = getframes(
		DATA_PATH,
		target_gw,
		scope
	) |> idcleanframes 
	
	# convert frames to combined & averaged matrix form
	gw_matrix = pastperformance(
		gw_frames,
		(scope + 1), 
		opt
	)
	
	return gw_matrix
end

# ╔═╡ 9bb35d3e-7868-4ebc-b9bb-d14e28132a9d
size(gwtomatrix("./data/2018-19/gws/", 10, 4))

# ╔═╡ 8b12751d-2b3e-45a4-8934-0a586af5da18
function databasebuild(GWS_PATH, total_gws, scope, opt=:average)
	# take:
	#	stem PATH for season gw files
	#	number of previous gw stats to combine
	season_data = []
	
	for i in 1:total_gws
		if (scope + 1) > i
			edge_scope = i - 1
		else
			edge_scope = scope
		end
			
		gw_data = gwtomatrix(
			GWS_PATH,
			i,
			edge_scope,
			opt
		)
		
		push!(season_data, gw_data)
	end
	
	return vcat(season_data...)
end

# ╔═╡ a219f3f8-a0f5-4fee-8404-83a48e666ec5
season_player_performance = databasebuild("./data/2018-19/gws/", 38, 5, :average)

# ╔═╡ 913b9fbb-5619-4403-9423-44681587c7ea
length(unique(season_player_performance[:, 1]))

# ╔═╡ ee1b14e9-c458-4703-8479-74477af1b02f
md"""
### Training Data

The variable `season_player_performance` represents the entire known model inputs for the `2018-19` season.

---

__Remains to be done:__

Find a way to extract the next gameweek's `:total_points` field for each player at each `target_gw`.

"""

# ╔═╡ 2de8f8bc-690e-4ec6-b516-d7e8cdeab38b
md"""
## Feature Engineering
"""

# ╔═╡ 37b3c95a-925b-11eb-2562-437d30d936f1
gw1_frame = CSV.File(open(read, "./data/2018-19/gws/gw1.csv", enc"LATIN1")) |> DataFrame;

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
# ╟─ebf77642-299c-480b-a079-271a8c5ad0fa
# ╠═a4f323de-94de-11eb-1bb8-97a7678f3f0a
# ╠═368f90fe-94dd-11eb-0681-13a581ed9466
# ╠═b9c6cf5e-8412-4976-8cc4-5137fac01ee3
# ╟─f1382ba4-9281-11eb-1245-a339d8a4b42d
# ╠═b5a32468-94d9-11eb-21dd-39a1df333ce5
# ╠═825a0948-928c-11eb-24c9-6775293f69cf
# ╠═64a440a2-94dd-11eb-2157-71ae7c817126
# ╠═e061b752-389b-494b-9908-d4c04b05f27a
# ╠═4175c783-792c-4ef9-9804-2ce22d92e9be
# ╠═9bb35d3e-7868-4ebc-b9bb-d14e28132a9d
# ╠═8b12751d-2b3e-45a4-8934-0a586af5da18
# ╠═a219f3f8-a0f5-4fee-8404-83a48e666ec5
# ╠═913b9fbb-5619-4403-9423-44681587c7ea
# ╟─ee1b14e9-c458-4703-8479-74477af1b02f
# ╟─2de8f8bc-690e-4ec6-b516-d7e8cdeab38b
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
