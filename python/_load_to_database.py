import os
from pathlib import Path
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL
from tqdm import tqdm

try:
    from IPython.display import display
except ImportError:
    display = print

print("Libraries loaded")


# PostgreSQL connection settings.

DB_USER = "iman"
DB_PASSWORD = "1234"
DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "olist_db"

DATABASE_URL = URL.create(
    "postgresql+psycopg2",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database=DB_NAME,
)

engine = create_engine(DATABASE_URL)

print(f"Engine created for PostgreSQL database: {DB_NAME}")

# Test the connection and print the server version.

try:
    with engine.connect() as conn:

        result = conn.execute(
            text("SELECT version();")
        )

        version = result.fetchone()[0]

        print(
            f"Connection successful!\n"
            f"PostgreSQL Version:\n{version}"
        )

except Exception as e:
    print(f"Connection error: {e}")


# Raw CSV directory, relative to the working directory.

CSV_FOLDER = Path(__file__).resolve().parent.parent / "datasets" / "raw"

if CSV_FOLDER.exists():

    csv_files = list(CSV_FOLDER.glob("*.csv"))

    print("Folder found")
    print(f"Number of CSV files: {len(csv_files)}")

    for f in csv_files:
        print(f"  - {f.name}")

else:

    print(f"Folder not found: {CSV_FOLDER}")


# Map CSV files to table names.

FILE_TABLE_MAPPING = {

    "olist_customers_dataset.csv": "customers",

    "olist_geolocation_dataset.csv": "geolocation",

    "olist_order_items_dataset.csv": "order_items",

    "olist_order_payments_dataset.csv": "order_payments",

    "olist_order_reviews_dataset.csv": "order_reviews",

    "olist_orders_dataset.csv": "orders",

    "olist_products_dataset.csv": "products",

    "olist_sellers_dataset.csv": "sellers",

    "product_category_name_translation.csv":
        "product_category_translation",
}

print("Mapping defined")


# Load one CSV at a time in chunks to limit memory use.

def load_csv_to_postgresql(
    csv_path,
    table_name,
    engine,
    if_exists="replace",
    chunksize=10000
):
    """
    Load CSV chunks and return (row count, error).
    """

    try:

        # -------------------------------------------------
        # Estimate rows from lines; multiline fields affect accuracy.
        # -------------------------------------------------

        with open(
            csv_path,
            "r",
            encoding="utf-8"
        ) as f:

            total_rows = sum(
                1 for _ in f
            ) - 1


        # -------------------------------------------------
        # Read CSV in chunks.
        # -------------------------------------------------

        chunks = pd.read_csv(
            csv_path,
            chunksize=chunksize
        )


        first_chunk = True
        loaded_rows = 0


        # -------------------------------------------------
        # Show loading progress.
        # -------------------------------------------------

        with tqdm(
            total=total_rows,
            desc=f"Loading {table_name}",
            unit="rows",
            leave=True
        ) as progress_bar:


            for chunk in chunks:


                # -----------------------------------------
                # Apply the policy once, then append remaining chunks.
                # -----------------------------------------

                if first_chunk:

                    current_if_exists = if_exists

                    first_chunk = False

                else:

                    current_if_exists = "append"


                # -----------------------------------------
                # Write the chunk without the pandas index.
                # -----------------------------------------

                chunk.to_sql(
                    name=table_name,
                    con=engine,
                    if_exists=current_if_exists,
                    index=False
                )


                # -----------------------------------------
                # Count and display rows after a successful write.
                # -----------------------------------------

                loaded_rows += len(chunk)

                progress_bar.update(
                    len(chunk)
                )


        return loaded_rows, None


    except Exception as e:

        return 0, str(e)


print("Loading function ready")


# Load mapped files and collect results.

print("\nStarting data load...\n")

results = []


for csv_file, table_name in FILE_TABLE_MAPPING.items():

    csv_path = CSV_FOLDER / csv_file


    # -------------------------------------------------
    # Skip and record missing files.
    # -------------------------------------------------

    if not csv_path.exists():

        print(
            f"File not found: {csv_file}"
        )

        results.append({

            "file": csv_file,

            "table": table_name,

            "rows": 0,

            "status": "NOT_FOUND"
        })

        continue


    print(
        f"\nLoading: {csv_file} -> {table_name}"
    )


    # -------------------------------------------------
    # Replace the table, then append chunks.
    # -------------------------------------------------

    row_count, error = load_csv_to_postgresql(

        csv_path=csv_path,

        table_name=table_name,

        engine=engine,

        if_exists="replace",

        chunksize=10000
    )


    # -------------------------------------------------
    # Record the result; errors may leave partial data.
    # -------------------------------------------------

    if error:

        print(
            f"   Error: {error}\n"
        )

        results.append({

            "file": csv_file,

            "table": table_name,

            "rows": 0,

            "status": f"ERROR: {error}"
        })


    else:

        print(
            f"   Success! "
            f"{row_count:,} rows loaded\n"
        )

        results.append({

            "file": csv_file,

            "table": table_name,

            "rows": row_count,

            "status": "SUCCESS"
        })


# Summarize successful loads and reported row counts.

df_results = pd.DataFrame(
    results
)

print("\nLoading Summary:")

display(
    df_results
)


total_rows = df_results[
    "rows"
].sum()


success_count = (
    df_results["status"] == "SUCCESS"
).sum()


print(
    f"\n{success_count}/"
    f"{len(FILE_TABLE_MAPPING)} "
    f"tables loaded successfully"
)


print(
    f"Total rows loaded: "
    f"{total_rows:,}"
)


# List all base tables in public.

with engine.connect() as conn:

    result = conn.execute(
        text(
            """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = 'public'
              AND table_type = 'BASE TABLE'
            ORDER BY table_name;
            """
        )
    )

    tables = [
        row[0]
        for row in result
    ]


print(
    f"\nTables in database "
    f"({len(tables)} tables):"
)


for table in tables:

    print(
        f"  - {table}"
    )


# Count rows in each public table.

print("\nDatabase row counts:")


for table in sorted(tables):

    with engine.connect() as conn:

        quoted_table = engine.dialect.identifier_preparer.quote(table)
        result = conn.execute(
            text(
                f"""
                SELECT COUNT(*)
                FROM public.{quoted_table};
                """
            )
        )

        count = result.fetchone()[0]

        print(
            f"{table:.<40} "
            f"{count:>10,}"
        )


print(
    "\nAll set! "
    "Data loaded into PostgreSQL."
)