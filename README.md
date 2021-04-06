<img src="./assets/daddyNeil.png" height="250" align="left"></img>

# ⚽️ NeilWarnockAI ⚽️

Premier League analysis and FPL (Fanstasy Premier League) autonomous agent project, with the aim of __running riot__ in
the 2021/2022 FPL season.

🚀 Top 🏅 1% here we come! 🚀

🙌 Let's make 👑 Neil proud! 🙌

---

### 🏆️ Some of Neil's best quotes for the reader's enjoyment 🏆

> When I pass away, I don't want clapping or a minute's silence, I want a minute's booing at Bristol City.

> Matches don't come any bigger the FA cup quarter-finals.

Inspiring words from one of the truly great wordsmiths of our time.

---

## Questions & Design Decisions:

1. __Feature engineering approach__

	__QUESTION:__

	Which of these 'feature engineering' design choices should we go with?

	1. average a player's performance stats over the number of games he featured in the `scope`?
	2. average a player's performance stats over the number of games in the `scope` for every player, regardless of whether the player is included in all the gameweek dataframes? 

	__ANSWER:__

	An option was included in the data fetching and processing function to determine this behaviour:
	- `opt = :average` -> the player's average stats are calculated over the entire `scope`.
	- `opt = :weightedaverage` -> the player's stats are averaged only over the gameweeks they feature in.
	- `opt = :total` -> no average is taken, instead the stats are simply summed over the `scope` gameweek range.

__@Noah:__

See `devlog.md` for a more detailed description of the current approach.

## TODO:

- [x] Choose predictive strategy
- [x] Start on proof-of-concept (PoC.jl)
- [x] Filter incoming model inputs
- [ ] Extract model outputs for training and validation
- [ ] Working player gameweek points prediction `pp_prediction`
- [ ] Autonomously updating gameweek data fetching
