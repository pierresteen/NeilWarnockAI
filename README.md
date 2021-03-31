# NeilWarnockAI

Premier League analysis and FPL (Fanstasy Premier League) autonomous agent project.

## Objectives

### FPL

Build, train and test an autonomous agent whose primary goal is to maximise FPL points return over an entire season of FPL play.
This should achievable by leveraging a large dataset of past gameweek player performances and scripts that allow a specific manager's season data to be downloaded and stored in `.csv` format (credit to [Vaastav Anand](https://github.com/vaastav) for this work).

- Can we predict the score of a selection of players (15 man team)?
	- What training data do we need for an NN classifier?
		* Example gameweek team selections
		* Gameweek fixtures

## Method

- Bin packing method:
	- 2D optimisation
		- limited cost (100m), limited space (15 player slots)
	- to be run at each gameweek (time step)
	- how to enforce constraints (ie. not allow choosing algorithm)
- 
