# Neil-Warnock AI (nwai v2)

Working with modern statistical learning techniques to "solve" the game of [*Fantasy Premier League*](https://fantasy.premierleague.com).


## Methodology

**Two-layer system.**

Layer 1:

	scoreline_predictor( gameweek fixtures ) -> predcited scores (club level)

Layer 2:

	player_points_predictor( historical player data ) \| predicted scores -> predicted points (player level)


### Layer 1 detailed description

We will begin by attempting to predict high level outcomes of a football match, in other words, the expected scoreline given a *home* and *away* team pair.
For this, we shall train, validate and compare the accuracy of several different statistical models on Premier League data ranging over the 2016-2017 to 2020-2021 seasons.

