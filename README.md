# NeilWarnockAI

Premier League analysis and FPL (Fanstasy Premier League) autonomous agent project.

## Objectives

### FPL

Build, train and test an autonomous agent whose primary goal is to maximise FPL points return over an entire season of FPL play.

This should achievable by leveraging a large dataset of past gameweek player performances and scripts that allow a specific manager's season data to be downloaded and stored in `.csv` format (credit to [Vaastav Anand](https://github.com/vaastav) for this work.)

#### Problems to Solve:
- Can we succesfully predict the score that a team (15 players) will produce for a gameweek?
- Can we succesfully predict the points total that will be scored by an individual player for a gameweek?
	- Does this methods lend itself well to a next step that would consist of a "bin-packing" optimisation problem?
	- 

## Method
- Bin packing method:
	- 2D optimisation
		- limited cost (100m), limited space (15 player slots)
	- to be run at each gameweek (time step)
	- how to enforce constraints (ie. not allow choosing algorithm
