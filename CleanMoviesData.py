import pandas as pd, json

# load raw TMDB export
df = pd.read_csv('/home/mohammed/datasets/tmdb_5000_movies.csv')

# sanity check: any duplicate movie ids?
print("dupes by id:", df['id'].duplicated().sum())
df = df.drop_duplicates(subset='id')

# force numeric cols — some come in as strings, and blanks need to become NaN
num_cols = ['runtime','vote_average','vote_count','popularity','budget','revenue']
for c in num_cols:
    df[c] = pd.to_numeric(df[c], errors='coerce')

# can't analyze movies without a runtime or a rating — drop those rows
df = df.dropna(subset=['runtime','vote_average'])

# TMDB stores unknown budget/revenue as 0, which is a lie — 0 means "free".
# convert to NULL so money queries don't get polluted by fake zeros
df['budget']  = df['budget'].replace(0, pd.NA)
df['revenue'] = df['revenue'].replace(0, pd.NA)

# write the cleaned movies table
df[['id','title','release_date','runtime','vote_average','vote_count',
    'popularity','original_language','budget','revenue']] \
  .to_csv('/var/lib/mysql-files/movies_clean.csv', index=False)

# genres are nested JSON in one cell — explode into a junction table (one row per movie/genre)
rows = []
for _, r in df.iterrows():
    for g in json.loads(r['genres']):
        rows.append({'movie_id': r['id'], 'genre': g['name']})
pd.DataFrame(rows).to_csv('/var/lib/mysql-files/movie_genres.csv', index=False)

print("movies:", len(df))