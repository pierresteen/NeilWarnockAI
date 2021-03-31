### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 6a5733b0-9258-11eb-1cb3-732a72a6ef6f
begin
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
"""

# ╔═╡ 37b3c95a-925b-11eb-2562-437d30d936f1
gw1_frame = CSV.File("./data/2018-19/gws/gw1.csv") |> DataFrame

# ╔═╡ 558d9dd6-925b-11eb-2850-4b491faa5441
begin
	gw1_cleaned = select(gw1_frame, Not([:kickoff_time,
										:kickoff_time_formatted,
										:name,
										:total_points]))
	gw1_scores = select(gw1_frame, :total_points) #total player point dataframe column
	gw1_sorted = hcat(gw1_scores, gw1_cleaned)
end;

# ╔═╡ 2b2b410c-925f-11eb-24aa-afcf04826510
begin
	gw1_cor = gw1_sorted |> Tables.matrix |> cor
	heatmap(gw1_cor)
end

# ╔═╡ 67c7e9be-9262-11eb-3f3d-7902775cedab


# ╔═╡ Cell order:
# ╠═6a5733b0-9258-11eb-1cb3-732a72a6ef6f
# ╟─ac577590-9258-11eb-3064-0dfac1dbecf1
# ╠═37b3c95a-925b-11eb-2562-437d30d936f1
# ╠═558d9dd6-925b-11eb-2850-4b491faa5441
# ╠═2b2b410c-925f-11eb-24aa-afcf04826510
# ╠═67c7e9be-9262-11eb-3f3d-7902775cedab
