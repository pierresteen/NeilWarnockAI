# Fantasy Premier League -- Data Mining

Mining data from about fpl managers, players performances and general game information will require navigating the official API.

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

## Authentification & Issues

To be able to access individual manager selections, it looks like you first need to authenticate