# Fantasy Premier League - Data Mining

Mining data from about FPL managers, players performances and general game information will require navigating the official API.
It will also require web-scraping the offical FPL website for data not available via the public API, i.e. manager team data ([see](https://github.com/zceepst/NeilWarnockAI/blob/master/src/mining/README.md#web-scraping))



## References

[API DOCS](https://fpl.readthedocs.io/en/latest/classes/fpl.html#fpl.fpl.FPL)

## Endpoints

- [generic game information](https://fantasy.premierleague.com/api/bootstrap-static/)
	- <https://fantasy.premierleague.com/api/bootstrap-static/>
	- contains:
		- brief summary of all 38 gameweeks
		- # of FPL managers
		- game settings
		- phases of the season
		- basic info about all 20 PL teams
		- basic info about about all PL players
		- stats that the FPL game tracks
		- different FPL positions(?)
- [fixture stats](https://fantasy.premierleague.com/api/fixtures/)
 - <https://fantasy.premierleague.com/api/fixtures/>
 - contains:
 	- info & stats for all gameweek fixtures (entire season)
 		- elements get filled weekly
 	- 379 "events" => fixtures
- [overall league](https://fantasy.premierleague.com/api/leagues-classic/314/standings/)
	- <https://fantasy.premierleague.com/api/leagues-classic/314/standings/>
	- contains:
		- *Overall* league standings
		- FPL managers info (ordered)
			- **manager ID** (important for later collecting their team selection and points tally information)
	- **ISSUE:** only returns the top 49 entries
		- how do we access what the *Next Page* button provides?
		- is there another league ID which returns a league JSON which includes the information about all/top 100k managers?

## Web Scraping

There does not appear to be a way to download and store information about FPL manager's team choices at a gameweek by gameweek level.

Information such as:

- team selection
	- total 15 players:
		* 2 goalkeepers
		* 5 defenders
		* 5 midfielders
		* 3 attackers
- token usage
	- *single* use token choices:
		* triple captain (captain score multiplier x3 instead of x2)
		* bench boost (benched players contribute to gameweek points)
		* free hit (vaild for single gameweek, ability to change entire lineup)
		* wildcard (free transfer, available *twice*, once in both season halves)
- player transfers
	- this can be determined by comparing previous gameweek choice with succeeding gameweek team

... can be obtained and used to extract patterns of play

