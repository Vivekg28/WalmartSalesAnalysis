SET AUTOCOMMIT = OFF;
COMMIT;
ROLLBACK;

CREATE DATABASE IF NOT EXISTS walmart_sales;
CREATE TABLE sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12,2) NOT NULL,
    date DATE NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct DOUBLE(11,9) NOT NULL,
    gross_income DECIMAL(10,2) NOT NULL,
    rating FLOAT(2,1)
);
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
SELECT * FROM sales;

# ADDING NEW FEATURES 
# 1) time_of_day 
SELECT  time,(CASE
 			WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
 			WHEN `time` BETWEEN "12:01:00" AND "15:00:00" THEN "AFTERNOON"
 			ELSE "EVENING"
 		END
        ) AS time_of_date
FROM sales;

ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(15) NOT NULL; 

UPDATE sales
SET time_of_day = (
	CASE
		WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "MORNING"
		WHEN `time` BETWEEN "12:01:00" AND "15:00:00" THEN "AFTERNOON"
		ELSE "EVENING"
		END
);

# 2) day_name
SELECT date,dayname(date) FROM sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(15) NOT NULL;

UPDATE sales
SET day_name =(dayname(date));

# 3) month_name
SELECT date,monthname(date) FROM sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(15);

UPDATE sales 
SET month_name = (monthname(date)); 
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

# Generic Ques 
-- How many unique cities does the data have?
SELECT * FROM sales;
SELECT DISTINCT city  FROM sales;  #Yangon,Naypyitaw,Mandalay

-- In which city is each branch?
SELECT DISTINCT branch, city
FROM sales;  #Yangon = A, Naypyitaw = C, Mandalay = B

# Product related Ques
-- How many unique product lines does the data have?
SELECT COUNT(DISTINCT product_line) FROM sales;  # 6

-- What is the most common payment method?
SELECT payment_method, COUNT(payment_method) 
FROM sales
GROUP BY payment_method;  # Cash

-- What is the most selling product line?
SELECT product_line, COUNT(product_line)
FROM sales
GROUP BY product_line;  # Fashion accessories

-- What is the total revenue by month?
SELECT  month_name, SUM(total) AS revenue_generated 
FROM sales 
GROUP BY month_name
ORDER BY revenue_generated DESC;  # January

-- What month had the largest COGS?
SELECT month_name, SUM(cogs)
FROM sales
GROUP BY month_name; # Jan

-- What product line had the largest revenue?
SELECT product_line,SUM(total) AS total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;  # Food and beverages

-- What is the city with the largest revenue?
SELECT city, SUM(total) AS total_revenue
FROM sales
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1; # Naypyitaw

-- What product line had the largest VAT?
SELECT product_line, AVG(VAT) AS avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC
LIMIT 1; # Home and lifestyle

-- Fetch each product line and add a column to those product line showing "Good", "Bad".
-- Good if its greater than average sales
SELECT AVG(total) AS avg_sales
FROM sales; # 322.499568

SELECT product_line, AVG(total) AS sales, (SELECT AVG(total) AS avg_sales FROM sales) AS avg_sales
FROM sales
GROUP BY product_line
HAVING sales > avg_sales;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS qty
FROM sales
GROUP BY branch
HAVING SUM(quantity)> (SELECT AVG(quantity) FROM sales); # A>C>B

-- What is the most common product line by gender?
SELECT product_line,gender,COUNT(gender) AS cnt
FROM sales
GROUP BY product_line, gender
ORDER BY cnt DESC; # Fashion accessories(F)

-- What is the average rating of each product line?
SELECT product_line, ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY  product_line
ORDER BY avg_rating DESC;

# Sales related Ques
-- Number of sales made in each time of the day per weekday?
SELECT time_of_day, COUNT(*) AS no_of_sales
FROM sales
WHERE day_name = 'sunday'
GROUP BY time_of_day;

-- Which of the customer types brings the most revenue?
SELECT customer_type, AVG(total) AS avg_revenue
FROM sales
GROUP BY customer_type; # Member

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, SUM(VAT) AS total_tax
FROM sales
GROUP BY city
ORDER BY total_tax DESC; # Naypyitaw

-- Which customer type pays the most in VAT?
SELECT customer_type, AVG(VAT) AS avg_tax
FROM sales
GROUP BY customer_type
ORDER BY avg_tax DESC
LIMIT 1; # Member
COMMIT;

# Customer related Ques
-- How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM sales; # 2

-- How many unique payment methods does the data have?
SELECT DISTINCT payment_method FROM sales;

-- What is the most common customer type?
SELECT customer_type, COUNT(customer_type) AS cnt
FROM sales
GROUP BY customer_type
ORDER BY cnt DESC
LIMIT 1; # Member

-- Which customer type buys the most?
SELECT customer_type, count(*) AS cnt
FROM sales
GROUP BY customer_type;

-- What is the gender of most of the customers?
 SELECT gender, COUNT(gender) AS gender_cnt 
 FROM sales
 GROUP BY gender; # Male
 
 -- What is the gender distribution per branch?
 SELECT gender, COUNT(gender) AS gender_cnt 
 FROM sales
 WHERE branch = 'A'
 GROUP BY gender;

-- Which time of the day do customers give most ratings?
SELECT AVG(rating) AS avg_rating , time_of_day
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC; # AFTERNOON

-- Which time of the day do customers give most ratings per branch?
SELECT AVG(rating) AS avg_rating , time_of_day
FROM sales
WHERE branch = 'B'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating DESC; # MONDAY

-- Which day of the week has the best average ratings per branch?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'A'
GROUP BY day_name
ORDER BY avg_rating DESC;
COMMIT;
-- ------------------------- END ------------------------------

