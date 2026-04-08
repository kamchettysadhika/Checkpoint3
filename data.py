import pandas as pd
import sqlite3

# Load CSV
df = pd.read_csv("Proj Data Unix.csv", encoding="latin1", header=0)

df.columns = ["isbn", "title", "authors", "publisher", "year", "price", "category", "c8", "c9", "c10"]

df['title']     = df['title'].ffill()
df['isbn']      = df['isbn'].ffill()        # ← added: forward-fill isbn
df['category']  = df['category'].ffill()    # ← added: forward-fill category
df['publisher'] = df['publisher'].ffill()
df['year']      = df['year'].ffill()
df['price']     = df['price'].ffill()

df = df[df['title'].notna()]

df['price'] = df['price'].replace(r'[\$,]', '', regex=True)
df['price'] = pd.to_numeric(df['price'], errors='coerce').fillna(0)

df['authors'] = df.groupby('title')['authors'].transform(lambda x: ', '.join(x.dropna()))
df = df.drop_duplicates(subset=['title'])

# Connect to DB
conn = sqlite3.connect("database.sqlite")
cursor = conn.cursor()

# -------------------
# PUBLISHERS
# -------------------
publishers = {}

for _, row in df.iterrows():
    name = row.get("publisher")

    if pd.notna(name) and name not in publishers:
        cursor.execute(
            "INSERT INTO PUBLISHER (name) VALUES (?)",
            (name,)
        )
        publishers[name] = cursor.lastrowid

# -------------------
# BOOKS + AUTHORS
# -------------------
authors = {}

for _, row in df.iterrows():

    # Insert book
    pub_id = publishers.get(row.get("publisher"))

    cursor.execute("""
        INSERT INTO BOOK (title, isbn, price, year_published, publisher_id, genre)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        row.get("title"),
        row.get("isbn"),
        row.get("price", 0),
        row.get("year"),
        pub_id,
        row.get("category")
    ))

    book_id = cursor.lastrowid

    # Handle authors
    author_list = list(set(
        author.strip()
        for author in str(row.get("authors")).split(",")
        if author.strip()
    ))

    for author in author_list:
        author = author.strip()

        if not author:
            continue

        if author not in authors:
            cursor.execute("""
                INSERT INTO AUTHOR (first_name, last_name)
                VALUES (?, ?)
            """, (author, ""))

            authors[author] = cursor.lastrowid

        cursor.execute("""
            INSERT INTO BOOK_AUTHOR (book_id, author_id)
            VALUES (?, ?)
        """, (book_id, authors[author]))

# Save changes
conn.commit()
conn.close()