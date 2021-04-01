# NeilWarnockAI

Premier League analysis and FPL (Fanstasy Premier League) autonomous agent project.

## TODO:

1. data pipelines and automated database update:
	- in prototype -> static database
		* data cleaning still necessary?
		* formatting?
		* feature engineering as part of data pre-processing? ( !◮ WARNING !◮ )
			- gameweek player stats files aren't homologous in axis: `gw*.csv`
			- the order ofthe players changes and possibly even the total group of players
	- in operation -> automated retrieval and storage
		* APIs?
		* are vaastav's scripts useful?
	- 
2. player gameweek points haul predictor model

===

## Objectives:

Build, train and test an autonomous agent whose primary goal is to maximise FPL points return over an entire season
of FPL play.

This should achievable by leveraging a large dataset of past gameweek player performances and scripts that allow
a specific manager's season data to be downloaded and stored in `.csv` format, credit to
[Vaastav Anand](https://github.com/vaastav) for this work.

## Overview:

__For each gameweek, the following system will run:__

1. Model (algorithm + NN classifier) will predict the points haul of each player in the league
	- input:
		1. fixture stats (ie. team match-up statistics and 'likely-to-win' analysis)
		2. prior stats (ie. cummulative stats for the season so far or some normalised average of these)
		3. logical factors (ie. is the player injured at the moment? is he eligible to play? (red car ban) etc.)
	- output:
		1. dictionary of (players => predicted points)

2. _Bin-packing_ optimisation will create team using the data points from the player points predictor
	- domain constraints include:
		1. squad count:
			* 15 players total
			* 11 players in the point scoring team selection
			* 4 players benched not scoring points (only point scoring IFF bench-boost token used for gameweek)
		2. total squad cost:
			* £100 million price cap
		3. transfer costs and allowances:
			* +1 free transfer every gameweek (roll over to next week when unused)
			* -4 gameweek points for non-free transfer
		4. additional tokens allowances:
			* triple captain
			* bench boost
			* wildcards - entire squad overhaul, lasts a single gameweek (within £100 million price cap)
				1. played before Dec 29th
				2. played after Dec 29th
			* free hit
	- input:
		1. dictionary containing players and predicted scores
		2. current squad
		3. team allowances:
			* money in bank
			* tokens left
			* free transfers
	- output:
		1. catalog of top scoring teams that are possible to make using current squad
		(ie. teams that have a high predicted score but are different to current squad by 1 or 2 players)
		(the algorithm for deciding whether a transfer is made will involve further cost-benefit computation)
3. edge case decisions
	- __when to play tokens?__
	[reference guide on token use](https://www.premierleague.com/news/790143)
		* does this need to be included in the _bin-packing_ search algorithm?
		* _how do we assess when a token play is worth it?_
	- __how to address double gameweeks?__
	- __first gameweek__

## Implementation:

### Player Points Predictor

__Data Pipelines:__

The pipeline is in charge of making sure that the data presented to the model, for both training purposes and
live predictions, is: __well formatted__, __clean__ and __up-to-date__.
This is especially critical to our model since it will rely on data from the short-term past as a key input feature!

The backend data structure should be able to run autonomously, scraping the necessary data once it has been published
to endpoints such as the FPL api.
More research needs to be done to better understand how this can be achieved.

[FPL API guide](https://medium.com/@frenzelts/fantasy-premier-league-api-endpoints-a-detailed-guide-acbd5598eb19)

---

__Predictive Model:__

The aim is to predict a player's future gameweek points haul based on input features that are unique to each player at
each gameweek.

So far the input data categories are:
- past performance items:
	- short term (form)
	- long term (cummulative/normalised)
- gameweek data:
	- match fixture
	- away/home
- othern (tbd)
