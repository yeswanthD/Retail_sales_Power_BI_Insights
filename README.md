# Maven Roasters Sales Analysis | Python, SQL Server & Power BI

An end-to-end retail sales analytics project using the Maven Roasters coffee shop dataset. The project explores transaction-level sales data with Python, SQL Server, and Power BI to understand revenue performance, product demand, store performance, and purchasing patterns.

> **Project focus:** Retail sales analytics · Exploratory Data Analysis · SQL querying · Business Intelligence

## Project Overview

The goal of this project is to transform raw coffee shop transaction data into meaningful business insights. The analysis covers data validation and preparation, exploratory analysis, feature engineering, SQL-based business analysis, KPI calculations, and Power BI reporting.

The dataset contains **149,116 transaction records** covering **January–June 2023**, across **3 store locations**, **9 product categories**, and approximately **80 distinct products**.

## Business Objectives

- Evaluate overall sales and transaction performance.
- Compare revenue across store locations.
- Identify high-performing product categories and products.
- Understand sales patterns by month, weekday, and hour.
- Examine quantity sold and average revenue per transaction.
- Translate analysis into KPIs that support operational and commercial decisions.

## Dataset

The repository includes the following data files:

| File | Description |
|---|---|
| `coffee-shop-sales-revenue.csv` | Source transaction dataset (pipe-delimited) |
| `maven_roasters_cleaned.csv.xlsx` | Cleaned and prepared dataset workbook |
| `Maven_roasters.ipynb` | Python analysis notebook |
| `SQL/retail_sales_analysis.sql` | SQL Server analysis script with 20 business and data-validation queries |\n| `PowerBI/DAX_Measures.md` | DAX reference for KPIs, time intelligence, ranking, and filter context |

The dataset includes transaction date/time, store, product details, quantity, and unit price. Revenue is calculated as `transaction_qty * unit_price`; it is not assumed to be a separate source column.

## Tools & Technologies

- **Python:** Pandas, NumPy
- **Visualization:** Matplotlib, Seaborn
- **Database:** Microsoft SQL Server
- **Business Intelligence:** Microsoft Power BI
- **Data preparation:** Excel / Power Query
- **Analytics:** Exploratory Data Analysis (EDA), feature engineering, KPI analysis, DAX, CTEs, and window functions

## Project Workflow

### 1. Data loading and validation

- Loaded the source data for analysis.
- Checked dataset dimensions, column types, and data consistency.
- Reviewed missing values, duplicate records, and potential outliers.
- Validated revenue and quantity calculations.

### 2. Data cleaning and feature engineering

- Prepared date and time fields for time-based analysis.
- Created useful date/time attributes for month, weekday, and hour analysis.
- Derived revenue-related metrics and supporting analytical fields.
- Prepared a cleaned dataset for downstream reporting.

### 3. Exploratory Data Analysis with Python

The notebook investigates:

- Overall revenue, quantity, and transaction performance.
- Store-level revenue comparison.
- Product category and product-level performance.
- Monthly sales trends.
- Weekday versus weekend patterns.
- Hourly sales distribution.
- Summary statistics, group-by analysis, and pivot tables.
- Outlier assessment using the IQR method.
- Revenue reconciliation and validation checks.

### 4. SQL Server business analysis

The SQL script in `SQL/retail_sales_analysis.sql` contains 20 commented queries organized into practical analysis sections:

- Data validation: row counts, null checks, duplicate checks, and invalid values.
- Business KPIs: total revenue, quantity sold, transaction counts, and average revenue per transaction.
- Store performance: revenue comparison and contribution percentage.
- Product analysis: category performance, top products, and quantity rankings.
- Time analysis: monthly revenue, month-over-month change, weekday/weekend performance, and peak sales hours.
- Advanced SQL: CTEs, `LAG()`, `DENSE_RANK()`, `ROW_NUMBER()`, and running totals.

**Import note:** The source CSV is pipe-delimited (`|`). When importing it into SQL Server, select the pipe character as the column delimiter and use the table name `dbo.MavenRoastersSales`, as expected by the script. Review the imported data types before running the queries.

### 5. Power BI analysis

The Power BI work focuses on turning the prepared data into an interactive business reporting experience. The analysis includes a date dimension and time-intelligence measures, along with KPI and comparative calculations such as:

- Total Revenue
- Total Quantity
- Total Transactions
- Month-to-Date (MTD), Quarter-to-Date (QTD), and Year-to-Date (YTD)
- Running Total
- Ranking analysis using `RANKX`
- Filter-aware analysis using `ALL`, `ALLSELECTED`, and `REMOVEFILTERS`\n\nSee [`PowerBI/DAX_Measures.md`](PowerBI/DAX_Measures.md) for the documented DAX formulas, model assumptions, and validation checklist.

*Note: The repository currently contains the Python notebook, data files, and SQL script. The Power BI report file (`.pbix`) and dashboard screenshots are not included in the current repository contents.*

## Key Findings

The completed exploratory analysis for January–June 2023 produced the following high-level results:

| Metric | Result |
|---|---:|
| Total records | 149,116 |
| Total revenue | $698,812.33 |
| Total quantity sold | 214,470 |
| Store locations | 3 |
| Product categories | 9 |

### Store revenue comparison

| Store | Revenue |
|---|---:|
| Hell's Kitchen | $236,511.17 |
| Astoria | $232,243.91 |
| Lower Manhattan | $230,057.25 |

Coffee was the leading product category by revenue in the completed exploratory analysis.

These findings provide a starting point for investigating store contribution, category mix, peak trading periods, and product demand.

## Repository Structure

```text
Retail_sales_Power_BI_Insights/
├── Maven_roasters.ipynb
├── coffee-shop-sales-revenue.csv
├── maven_roasters_cleaned.csv.xlsx
├── SQL/
│   └── retail_sales_analysis.sql
├── PowerBI/
│   └── DAX_Measures.md
└── README.md
```

## How to Explore the Project

### Python analysis

1. Clone or download this repository.
2. Open `Maven_roasters.ipynb` in Jupyter Notebook, JupyterLab, or Google Colab.
3. Install the required Python packages:

   ```bash
   pip install pandas numpy matplotlib seaborn openpyxl
   ```

4. Update the dataset file path in the notebook if necessary.
5. Run the notebook cells in sequence.

### SQL Server analysis

1. Open SQL Server Management Studio (SSMS).
2. Create or select a practice database.
3. Import `coffee-shop-sales-revenue.csv` using the Import Flat File wizard.
4. Set the delimiter to `|` and name the table `MavenRoastersSales`.
5. Open `SQL/retail_sales_analysis.sql` and run the queries section by section.

## Skills Demonstrated

- Data cleaning and validation
- Exploratory data analysis
- Data transformation and feature engineering
- SQL querying, aggregation, CTEs, and window functions
- Revenue analysis and business KPI calculations
- Statistical summaries and outlier detection
- Data visualization and business insight generation
- Power BI KPI development and DAX time intelligence
- Translating analytical results into business-focused reporting

## Future Enhancements

- Add the final Power BI `.pbix` report and dashboard screenshots.
- Include a dedicated data dictionary and reproducible data model documentation.
- Expand the analysis with product mix, basket, and store-level performance comparisons.
- Add an executive summary of recommendations based on the dashboard.

## Author

**Yeswanth Doppalapudi**

- GitHub: [@yeswanthD](https://github.com/yeswanthD)

---

If you find this project useful, feel free to explore the notebook and share feedback.
