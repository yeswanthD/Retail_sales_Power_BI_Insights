# Power BI DAX Measures – Maven Roasters Sales

This reference documents the core DAX measures and filter-context concepts used in the Maven Roasters sales analysis (January–June 2023).

> **Model assumptions:** The examples use a fact table named `MavenRoastersSales` and a date table named `DimDate`. Rename these references if your Power BI model uses different names. The source data does not contain a revenue column, so revenue is calculated as quantity multiplied by unit price.

## 1. Recommended data model

- **Fact table:** `MavenRoastersSales`
- **Date table:** `DimDate`
- Create a one-to-many relationship from `DimDate[Date]` (one side) to `MavenRoastersSales[transaction_date]` (many side).
- Ensure both relationship columns use the Date data type.
- Mark `DimDate` as the model's date table using `DimDate[Date]`.

A continuous date table is important for reliable time-intelligence calculations.

## 2. Base KPI measures

### Total Revenue

```dax
Total Revenue =
SUMX(
    'MavenRoastersSales',
    'MavenRoastersSales'[transaction_qty]
        * 'MavenRoastersSales'[unit_price]
)
```

### Total Quantity

```dax
Total Quantity =
SUM('MavenRoastersSales'[transaction_qty])
```

### Total Transactions

```dax
Total Transactions =
DISTINCTCOUNT('MavenRoastersSales'[transaction_id])
```

### Average Revenue per Transaction

```dax
Average Revenue per Transaction =
DIVIDE([Total Revenue], [Total Transactions])
```

Use `DIVIDE` rather than the division operator when a denominator could be zero or blank.

## 3. Time-intelligence measures

These measures rely on the active relationship between `DimDate[Date]` and the fact table's transaction date.

### Month-to-Date (MTD)

```dax
Revenue MTD =
TOTALMTD(
    [Total Revenue],
    'DimDate'[Date]
)
```

### Quarter-to-Date (QTD)

```dax
Revenue QTD =
TOTALQTD(
    [Total Revenue],
    'DimDate'[Date]
)
```

### Year-to-Date (YTD)

```dax
Revenue YTD =
TOTALYTD(
    [Total Revenue],
    'DimDate'[Date]
)
```

### Previous Month Revenue

```dax
Revenue Previous Month =
CALCULATE(
    [Total Revenue],
    DATEADD('DimDate'[Date], -1, MONTH)
)
```

### Month-over-Month (MoM) Change

```dax
Revenue MoM Change =
[Total Revenue] - [Revenue Previous Month]
```

### Month-over-Month (MoM) Growth %

```dax
Revenue MoM Growth % =
DIVIDE(
    [Revenue MoM Change],
    [Revenue Previous Month]
)
```

Format the growth measure as Percentage.

### Previous Year Revenue

```dax
Revenue Previous Year =
CALCULATE(
    [Total Revenue],
    SAMEPERIODLASTYEAR('DimDate'[Date])
)
```

### Year-over-Year (YoY) Growth %

```dax
Revenue YoY Growth % =
DIVIDE(
    [Total Revenue] - [Revenue Previous Year],
    [Revenue Previous Year]
)
```

**Data limitation:** The supplied dataset covers January–June 2023 only. YoY measures need comparable prior-year data to return meaningful comparisons; with this dataset alone, prior-year values will generally be blank.

## 4. Running total

### Revenue Running Total

```dax
Revenue Running Total =
CALCULATE(
    [Total Revenue],
    FILTER(
        ALLSELECTED('DimDate'[Date]),
        'DimDate'[Date] <= MAX('DimDate'[Date])
    )
)
```

This accumulates revenue up to the current date while retaining the date selections made by the report user.

## 5. Ranking measures

### Store Revenue Rank

```dax
Store Revenue Rank =
RANKX(
    ALL('MavenRoastersSales'[store_location]),
    [Total Revenue],
    ,
    DESC,
    DENSE
)
```

- `DESC` ranks the highest revenue as 1.
- `DENSE` gives the next distinct value the next rank (1, 2, 2, 3).
- `SKIP` leaves a gap after ties (1, 2, 2, 4).

Use the store field in the visual alongside this measure.

## 6. Filter-context measures

### Revenue Across All Stores

```dax
Revenue All Stores =
CALCULATE(
    [Total Revenue],
    REMOVEFILTERS('MavenRoastersSales'[store_location])
)
```

This removes the store filter while retaining other applicable filters, such as date or product category.

### Revenue % of Selected Stores

```dax
Revenue % of Selected Stores =
DIVIDE(
    [Total Revenue],
    CALCULATE(
        [Total Revenue],
        ALLSELECTED('MavenRoastersSales'[store_location])
    )
)
```

This compares the current store's revenue with the total for the stores remaining in the user's selection.

### Understanding the filter functions

| Function | Typical purpose |
|---|---|
| `ALL()` | Removes filters from the specified table or columns. |
| `ALLSELECTED()` | Retains external selections while removing the current visual grouping filter. |
| `REMOVEFILTERS()` | Explicitly clears filters from specified tables or columns. |
| `CALCULATE()` | Evaluates an expression in a modified filter context. |
| `RANKX()` | Evaluates an expression over a table and assigns a rank. |

The exact result depends on which columns are used in the visual, slicers, relationships, and the scope of the filter removal.

## 7. Top N analysis

For a Top 5 stores or products visual, the simplest approach is usually:

1. Add the store or product field to the visual.
2. Add `Total Revenue` to the visual's values.
3. In the visual-level Filters pane, change the field filter type to **Top N**.
4. Enter `5`, select `Total Revenue` as **By value**, and apply the filter.

This keeps the Top N selection tied to the visual and avoids treating a table expression as if it were a scalar measure.

## 8. Validation checklist

Before relying on the report, verify:

- [ ] Revenue is calculated as quantity × unit price.
- [ ] Total quantity reconciles to the source data.
- [ ] Total transactions use the intended transaction identifier.
- [ ] `DimDate` contains a continuous range of dates.
- [ ] The date relationship is active and has the correct direction/cardinality.
- [ ] MTD, QTD, and YTD respond correctly to date filters.
- [ ] MoM and YoY measures are checked only where comparison periods exist.
- [ ] Ranking changes as expected with report filters.
- [ ] Percentage measures are formatted as percentages.

## 9. Notes

- Measures are evaluated dynamically in the current filter context; they are not stored row-by-row like calculated columns.
- Use a dedicated date table for time-intelligence calculations.
- Format revenue measures as currency and growth measures as percentages in Power BI.
- The examples are a reusable reference. Validate each measure against the actual model and expected business definition before publishing.

---

**Project:** Maven Roasters Sales Analysis  
**Tools:** Power BI, DAX, Power Query, Python, SQL Server  
