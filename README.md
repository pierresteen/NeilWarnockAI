# Neil-Warnock AI

[<img src="./assets/misc/NeilAI.png" height="300"></img>](https://youtu.be/Xd6gmlXPU48)

Working with modern statistical learning techniques to "solve" the game of [*Fantasy Premier League*](https://fantasy.premierleague.com).

## Methodology

The approach used can be resumed as a two-layer prediction system feeding an constrained optimiser.

**USE ONLY NORMALISED PERFORMANCE METRICS!**

This will allow us to treat edge cases where there is not enough data about a team's, player's or manager's past performance.
This is problem that is especially poignant in football; players can be transfered from abroad, teams can be promoted from lower leagues, posing a challenge to our data-hungry classifier algorithms.
However; if we treat every performance metric as a distribution, we are able to fill in the blanks and guess that an entity's missing metric will satisfy the average, this plugs the hole in our predictive raft (and there will be **lots** of holes to plug in future also).

### Prediction

**See `predictor.jl` for a thorough functionality description.**

Layer 1:
```
scoreline_predictor( gameweek fixtures ) -> predcited scores (club level)
```

Layer 2:
```
player_points_predictor( historical player data ) | predicted scores -> predicted points (player level)
```

#### Layer 1 detailed description

We will begin by attempting to predict high level outcomes of a football match, in other words, the expected scoreline given a *home* and *away* team pair.
For this, we shall train, validate and compare the accuracy of several different statistical models on Premier League data ranging over the 2016-2017 to 2020-2021 seasons.

The outcome of this process will be a 'universal approximator' function which maps an input:
```
fixture = (<home team>, <away team>)
```
to an output:
```
predicted_scoreline = (<home goals>, <away goals>, <uncertainty>)
```

However, it is clear that simply passing the fixture data, most likely in the form of team-identifying symbols (e.g `:arsenal` and `:tottenham`), will not be enough features to train the model (in the example it should be plain to see that the correct outcome will be `(5, 1, 0%)`).
We therefore require more features, engineered and raw, to qualify the likelihood of a scoreline outcome.

Using data from the [football-data](https://www.football-data.co.uk/) database should provide us with a good foundation for this type of event prediction.

#### Layer 2 detailed description



### Optimisation

Having predicted the gameweek points haul for the entire cohort of players (or those within a reasonable expected accuracy window)*, we now turn to choosing which of the players to use to fill our **15** available spaces.

## Investigate potential α

- use fpl-twitter and sentiment analysis to take inspiration from 'experts'
	- include this as a weighted parameter
- use betting odds data to tune scoreline prediction
	- build api to fetch data and update weekly?
- [were in *lundun* aren't weh?](https://youtu.be/Xd6gmlXPU48)
