### A Pluto.jl notebook ###
# v0.12.21

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
"""

# ╔═╡ f1382ba4-9281-11eb-1245-a339d8a4b42d
md"""
## Data & Feature Engineering
"""

# ╔═╡ 825a0948-928c-11eb-24c9-6775293f69cf
"""
	collect_stats()

Sums and averages a player's stats over the season so that a good correlation analysis between features and points total can be performed.
"""
function collect_stats()
	
end

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

# ╔═╡ Cell order:
# ╠═6a5733b0-9258-11eb-1cb3-732a72a6ef6f
# ╟─ac577590-9258-11eb-3064-0dfac1dbecf1
# ╟─f1382ba4-9281-11eb-1245-a339d8a4b42d
# ╠═825a0948-928c-11eb-24c9-6775293f69cf
# ╠═37b3c95a-925b-11eb-2562-437d30d936f1
# ╠═558d9dd6-925b-11eb-2850-4b491faa5441
# ╟─de38a0ca-928a-11eb-0994-d3e566c40381
# ╠═2b2b410c-925f-11eb-24aa-afcf04826510
# ╟─7db1e45e-929a-11eb-1c6d-53bcd4d8b1e4
# ╟─67f8afee-929a-11eb-1db8-a9b5f9899449
# ╠═67c7e9be-9262-11eb-3f3d-7902775cedab
# ╠═8e3dc728-927e-11eb-2609-212b30036d55
