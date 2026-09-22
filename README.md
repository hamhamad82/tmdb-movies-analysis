# Hollywood Economics

An analysis of ~4,800 films from the TMDB 5000 dataset, exploring the relationship 
between genre, critical reception, and box office return.

## The Question

Which film genres are the best *business*? And does critical reception actually 
correlate with financial performance — or are the most profitable genres also the 
most critically reviled?

## Data

- **Source:** [TMDB 5000 Movies](https://www.kaggle.com/datasets/tmdb/tmdb-movie-metadata) (Kaggle)
- **Size:** 4,803 films, 20 columns
- **Scope:** films with a recorded runtime and user rating; financial analysis limited 
  to films with a reported budget and revenue above $100K

## Process

1. **Cleaned** the raw CSV in Python/pandas — dropped duplicate IDs, coerced numeric 
   types, converted missing budget/revenue from `0` to `NULL` (TMDB uses `0` as a 
   placeholder for "unknown," not literal zero), and dropped rows with no rating or runtime.
2. **Normalized** the nested `genres` JSON field into a junction table (`movie_genres`), 
   one row per (movie, genre) pair — enabling genre-level aggregation via JOIN.
3. **Loaded** into MySQL and analyzed with SQL.

Script: [`CleanMovies.py`](CleanMovies.py) · Queries: [`queries.sql`](queries.sql)

## Key Findings

### 1. Horror is cinema's highest-variance genre
Horror has the **highest critical failure rate of any genre (39.1%** of films rated 
below 5.5) and the **lowest acclaim rate (2.5%)** — yet it ranks among the best 
performers on return on investment. The mean/median ROI gap confirms it: Horror's 
average ROI is roughly [X]× its median, meaning the genre's returns are carried by a 
small number of outliers while the typical film is unremarkable.

**Interpretation:** Horror operates like a portfolio strategy, not a per-film one. 
Cheap productions + frequent critical misses + occasional massive hits = a structure 
where a few winners subsidize many losers.

### 2. Every genre's mean ROI beats its median — the whole industry is outlier-driven
Across all genres, mean ROI is roughly **2× the median**. The typical film returns 
~2.3× its budget; the *average* film returns far more, because a handful of blockbusters 
pull the mean upward.

### 3. "Profitable" and "efficient" are different questions
- By **absolute profit**, Animation, Adventure, and Fantasy lead — big-budget genres 
  that make the most total money.
- By **ROI**, Documentary and Horror lead — cheap genres with high returns per dollar.

A genre can win one ranking and lose the other. Animation is both highly profitable 
*and* efficient; Horror is efficient but not exceptionally profitable in absolute terms.

## Methods & Caveats

- "Failing" = average user rating < 5.5; "acclaimed" = ≥ 7.5. These thresholds are 
  judgment calls and are stated explicitly for reproducibility.
- **Placeholder data:** TMDB contains rows with implausibly small budgets (e.g. `$1`), 
  which inflate ROI to absurd levels. Initial results showed Comedy returning 7,663× — 
  clearly wrong. I filtered to budgets/revenues > $100K to remove these.
- **Survivorship bias:** ratings reflect *current* TMDB users, not reception at release. 
  Older films that survive to be rated skew higher, which likely explains any 
  "films were better back then" patterns.
- **Small samples:** genres with fewer than 20 qualifying films are excluded from 
  aggregate results.

## Stack

Python (pandas) · MySQL 8 · SQL (joins, CTEs, window functions)