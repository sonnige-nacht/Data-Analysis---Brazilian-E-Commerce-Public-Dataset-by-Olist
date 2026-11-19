# Brazilian E-Commerce Data Analysis

An end-to-end analysis of the Brazilian E-Commerce Public Dataset by Olist. This project explores the source data with Python, prepares it in SQL, builds a dimensional data warehouse, and presents the results in a Power BI dashboard.

## Project objectives

- Inspect the structure and quality of the source tables.
- Prepare order, customer, seller, product, payment, review, and location data for analysis.
- Build a star-schema data warehouse and analytical views.
- Explore customer and seller geography, product categories, orders, delivery, revenue, payments, and satisfaction.

## Tools and technologies

- **Python:** pandas, NumPy, SQLAlchemy, psycopg2, and tqdm
- **Database and analysis:** PostgreSQL and SQL
- **Visualization:** Power BI Desktop
- **Exploration:** Jupyter Notebook

## Dataset

The project uses the [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). The raw data is not included in this repository because of its size. Download the dataset from Kaggle and extract the nine CSV files directly into `datasets/raw/`. See [datasets/DATASET.txt](datasets/DATASET.txt).

## Workflow

1. **Explore:** Inspect table shapes, data types, missing values, duplicate rows, and samples in `python/_data_exploration.ipynb`.
2. **Load:** Use `python/_load_to_database.py` to load the CSV files into PostgreSQL in chunks.
3. **Prepare:** Use the SQL scripts to transfer data into raw and staging schemas, inspect data quality, and clean the staging tables.
4. **Model:** Build dimension and fact tables in the `dw` schema and apply further cleaning.
5. **Analyze and visualize:** Explore the analytical view scripts and open the Power BI dashboard. A PDF export is also available.

## Dashboard

The Power BI report is available in [powerbi/08_Dashboard_PowerBI.pbix](powerbi/08_Dashboard_PowerBI.pbix). For a static view, open the [dashboard PDF](reports/08_Dashboard_PowerBI.pdf). The report's color theme is stored alongside the PBIX file.

The SQL views cover customer and seller distribution, product categories, order status, delivery and transit times, revenue, payment methods, and satisfaction. See `sql/views/` for the individual queries.

## Repository structure

```text
.
├── datasets/
│   ├── DATASET.txt                 # Dataset source and download instructions
│   └── raw/                        # Place the downloaded CSV files here
├── python/
│   ├── _data_exploration.ipynb     # Initial data exploration
│   └── _load_to_database.py        # CSV-to-PostgreSQL loader
├── sql/
│   ├── 00_set_user.sql             # Example database role setup
│   ├── 01_multi_table_data_transfer.sql
│   ├── 02_setup_schemas_and_transfer_tables_to_raw_schema_for_dwh.sql
│   ├── 03_raw_schema_data_quality_check.sql
│   ├── 04_transfer_tables_to_staging_schema.sql
│   ├── 05_stg_schema_clean_data.sql
│   ├── 06_create_dw_star_schema.sql
│   ├── 07_cleaning_after_datawarehouse_creation.sql
│   └── views/                      # Analytical SQL views
├── powerbi/
│   ├── 08_Dashboard_PowerBI.pbix
│   └── Power BI Color Theme - University of Melbourne.json
├── reports/
│   ├── 08_Dashboard_PowerBI.pdf
│   └── insights/                   # Data-quality outputs and screenshots
├── .gitignore
├── FILE_STRUCTURE.txt
└── README.md
```

## Getting started

1. Download and extract the dataset as described above.
2. Install Python dependencies in a virtual environment:

   ```bash
   pip install pandas numpy sqlalchemy psycopg2-binary tqdm jupyter
   ```

3. Create the PostgreSQL source and warehouse databases, and configure the connection settings in `python/_load_to_database.py`. The SQL setup and foreign-data-wrapper scripts also contain local example connection settings that must be adapted to your environment. Replace the example credentials before use and avoid publishing real passwords.
4. Run the exploration notebook and then the loader:

   ```bash
   python python/_load_to_database.py
   ```

5. Review the scripts in `sql/` before executing them. Their numbered names describe the original workflow, but they are not a fully automated migration: schemas and destination tables must exist before the corresponding `INSERT` statements, and some scripts contain statements for different stages of the workflow. Adapt their order and setup to your database. Some view scripts use SQL Server syntax, so they require adaptation before running on PostgreSQL. Several scripts create existing objects or modify data and should not be rerun blindly.
6. Open the PBIX file in Power BI Desktop. To refresh its data, configure the data source and credentials for your own database.

## Notes

- The data-quality outputs and screenshots are in `reports/insights/`.
- The loader replaces destination tables; use it only with a suitable database.
- The raw dataset and local Python environments are excluded by `.gitignore`.
