#=
Data import module testing.
=#

# using .Extractor # why does importing custom module not work?
# include("../src/extractor.jl")
import ..Extractor

#=
Path directories.
=#

DATA_PATH = "data/"
PATH_1617 = "2016-17/"
PATH_1718 = "2017-18/"
PATH_1819 = "2018-19/"
PATH_1920 = "2019-20/"
PATH_2021 = "2020-21/"
PLYR_PATH = "players/"
GWTP_PATH = "gws/"


#=
Player data import test:
=#

test_players = [
	"Aaron_Cresswell",
	"Aaron_Lennon",
	"Alfred_N'Diaye"
]
test_players = extractallplayers("data/2016-17/", test_players)
