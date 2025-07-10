# walmart_sales

This project is an end-to-end data analysis solution designed to extract critical business insights from Walmart sales data. We utilize Python for data processing and analysis, SQL for advanced querying, and structured problem-solving techniques to solve key business questions. The project is ideal for data analysts looking to develop skills in data manipulation, SQL querying, and data pipeline creation.

Project Steps
1. Set Up the Environment
Tools Used: Visual Studio Code (VS Code), Python, SQL (MySQL)
Goal: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.
2. Set Up Kaggle API
API Setup: Obtain your Kaggle API token from Kaggle by navigating to your profile settings and downloading the JSON file.
Configure Kaggle:
Place the downloaded kaggle.json file in your local .kaggle folder.
Use the command kaggle datasets download -d <dataset-path> to pull datasets directly into your project.
3. Download Walmart Sales Data
Data Source: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
Dataset Link: Walmart Sales Dataset
Storage: Save the data in the data/ folder for easy reference and access.
4. Install Required Libraries and Load Data
Libraries: Install necessary Python libraries using:
pip install pandas numpy sqlalchemy mysql-connector-python
Loading Data: Read the data into a Pandas DataFrame for initial analysis and transformations.
5. Explore the Data
Goal: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
Analysis: Use functions like .info(), .describe(), and .head() to get a quick overview of the data structure and statistics.
6. Data Cleaning
Remove Duplicates: Identify and remove duplicate entries to avoid skewed results.
Handle Missing Values: Drop rows or columns with missing values if they are insignificant; fill values where essential.
Fix Data Types: Ensure all columns have consistent data types (e.g., dates as datetime, prices as float).
Currency Formatting: Use .replace() to handle and format currency values for analysis.
Validation: Check for any remaining inconsistencies and verify the cleaned data.
7. Feature Engineering
Create New Columns: Calculate the Total Amount for each transaction by multiplying unit_price by quantity and adding this as a new column.
Enhance Dataset: Adding this calculated field will streamline further SQL analysis and aggregation tasks.
8. Load Data into MySQL
Set Up Connections: Connect to MySQL using sqlalchemy and load the cleaned data into each database.
Table Creation: Set up tables in both MySQL using Python SQLAlchemy to automate table creation and data insertion.
Verification: Run initial SQL queries to confirm that the data has been loaded accurately.
9. SQL Analysis: Complex Queries and Business Problem Solving
Business Problem-Solving: Write and execute complex SQL queries to answer critical business questions, such as:
Revenue trends across branches and categories.
Identifying best-selling product categories.
Sales performance by time, city, and payment method.
Analyzing peak sales periods and customer buying patterns.
Profit margin analysis by branch and category.
10. On project.ipynb make your visulaizations using matplotlib and seaborn libraries, and make your insights and recomendations.
Documentation: Keep clear notes of each query's objective, approach, and results.

-- Business Problms

-- Q1  find the different payment method and the number of transactions, number of qty sold
```sq
select payment_method, count(*) as no_payments,sum(quantity) as no_qty_sold
 from walmart
group by payment_method;
```

-- Q2 Identify the highest rated category in each branch display the branch the category
-- and the average rating
```sq
SELECT *
FROM (
    SELECT 
        branch,
        category,
        avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY avg_rating DESC) AS ranking
    FROM (
        SELECT 
            branch,
            category,
            AVG(rating) AS avg_rating
        FROM walmart
        GROUP BY branch, category
    ) AS subquery
) AS ranked
WHERE ranking = 1;
```

-- Q3  Identify the busiest day for each branch based on the number of transactions 

```sq
select * from walmart;

SELECT
    branch,
    day_name,
    no_transactions,
    ranking
FROM (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
) AS ranked_days
WHERE ranking = 1
ORDER BY branch;
```
-- Q4: calculate the total quantity of item sold per payment method list the payment 
-- method and the total quantity sold
```sq
select * from walmart;
select payment_method, sum(quantity) as no_qty_sold
 from walmart
group by payment_method;
```

-- Q5: determine the average, minimum and the maximum rating of product for each City. list the
-- city average rating minimum rating and the maximum rating 
```sq
select city, category, min(rating) as min_rating,max(rating) as max_rating,
Round(avg(rating),2) as avg_rating from walmart
group by 1,2;
```
-- Q6: calculate the total profit for each category by considering
-- the total profit as unit price times quantity times profit margin
-- ist the category and the total profit and the ordered 
-- from highest to lowest profit 
```sq
select * from walmart;
select 
	category,
    round(sum(total),2) as Revenue,
	round(sum(total*profit_margin),2) as Profit
from walmart
group by 1;
```

-- Q7:  determine the most common payment method for each each
-- branch. display the branch and the preferred method.
```sq
with cte as
(SELECT 
    branch, 
    payment_method, 
    COUNT(*) AS total_transactions,
    RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
FROM walmart
GROUP BY 1,2)
select * from cte
where ranking =1;
```

-- categorize sales into three group morning afternoon and the evening
-- find out which of this shift and the number of the invoices 

```sq
SELECT
  branch,
  CASE
    WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN '05:00:00' AND '11:59:59' THEN 'Morning'
    WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN '12:00:00' AND '16:59:59' THEN 'Afternoon'
    ELSE 'Evening'
  END AS shift,
  COUNT(DISTINCT invoice_id) AS no_of_invoices
FROM walmart
GROUP BY branch,shift
order by 1,3 DESC;
```


-- Q9: Identify the five branchs with the highest decrease ratio in Revenue
-- compared to the last year so the current year is 2023 the last year was 2022

-- To make it simple to learn:: 
```sq
SELECT branch, sum(total) as revenue FROM walmart
group by 1;
```
-- The answer:

```sq
SELECT
  branch,
  revenue_2022,
  revenue_2023,
  ROUND(
    ((revenue_2022 - revenue_2023) / revenue_2022) * 100, 
    2
  ) AS decrease_ratio_percent
FROM (
  SELECT
    branch,
    SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022 THEN total ELSE 0 END) AS revenue_2022,
    SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023 THEN total ELSE 0 END) AS revenue_2023
  FROM walmart
  GROUP BY branch
) AS yearly_revenue
ORDER BY decrease_ratio_percent DESC
LIMIT 5;
```
-- And more advanced queries in : walmart-sql file

11. Project Publishing and Documentation
Documentation: Maintain well-structured documentation of the entire process in Markdown or a Jupyter Notebook.
Project Publishing: Publish the completed project on GitHub or any other version control platform, including:
The README.md file (this document).
Jupyter Notebooks (if applicable).
SQL query scripts.
Data files (if possible) or steps to access them.
Requirements
Python 3.8+
SQL Databases: MySQL, PostgreSQL
Python Libraries:
pandas, numpy, sqlalchemy, mysql-connector-python, psycopg2
Kaggle API Key (for data downloading)
Getting Started
Clone the repository:
git clone <repo-url>
Install Python libraries:
pip install -r requirements.txt
Set up your Kaggle API, download the data, and follow the steps to load and analyze.
Project Structure
|-- data/                     # Raw data and transformed data
|-- sql_queries/              # SQL scripts for analysis and queries
|-- notebooks/                # Jupyter notebooks for Python analysis
|-- README.md                 # Project documentation
|-- requirements.txt          # List of required Python libraries
|-- main.py                   # Main script for loading, cleaning, and processing data
Results and Insights
This section will include your analysis findings:

Sales Insights: Key categories, branches with highest sales, and preferred payment methods.
Profitability: Insights into the most profitable product categories and locations.
Customer Behavior: Trends in ratings, payment preferences, and peak shopping hours.
Future Enhancements
Possible extensions to this project:

Integration with a dashboard tool (e.g., Power BI or Tableau) for interactive visualization.
Additional data sources to enhance analysis depth.
Automation of the data pipeline for real-time data ingestion and analysis.
License
This project is licensed under the MIT License.

Acknowledgments
Data Source: Kaggle’s Walmart Sales Dataset
Inspiration: Walmart’s business case studies on sales and supply chain optimization.
