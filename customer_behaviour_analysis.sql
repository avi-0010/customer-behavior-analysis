SELECT current_database();
SELECT * FROM customer_behaviour_analysis
LIMIT(10);
ALTER TABLE customer_behaviour_analysis
ALTER COLUMN purchase_amount TYPE numeric;
ALTER TABLE customer_behaviour_analysis
ALTER COLUMN review_rating TYPE numeric;

-------Business Insight Questions------------

--Which Category Generates Highest Revenue

SELECT category,ROUND(sum(purchase_amount),2) as highest_rev
FROM customer_behaviour_analysis
GROUP BY category
ORDER BY highest_rev DESC;

--? Business Problem - Company doesnt know which category which category contributes the most
-- Impact 
	--Helps identify top-performing categories
	--Supports inventory planning
	--Improves Marketing ROI

---------------------------------------------------------------------------------------------------------

--Are discount acutally increasing purchase value?
SELECT discount_applied,
		ROUND(SUM(purchase_amount),2) as highest_rev,
		ROUND(AVG(purchase_amount),2) as average_rev
FROM customer_behaviour_analysis
GROUP BY discount_applied;

--Business Problem - Discount may reduce profit without increasing sales
--Impact  	-- Identify effectiveness of discounts
		 	-- Reduce unnecessary discounts
			--Improve Profit Margins 

------------------------------------------------------------------------------------------------------------
-- What is the total revenue genarated by male and female
SELECT gender,ROUND(SUM(purchase_amount),2) as Total_rev
FROM customer_behaviour_analysis
GROUP BY gender 
ORDER BY Total_rev DESC;

-- Business Problem - Lack of understanding of revenue contribution by gender segment
--Impact	--Helps design targeted marketing campaigns
			--improves customer segmentation statergy 
			--Enhances personalization efforts

-------------------------------------------------------------------------------------------------------------
-- which customer used discount but still spent more than the average purchase amount
SELECT 
		customer_id,
		purchase_amount,
		discount_applied
FROM 	customer_behaviour_analysis
WHERE discount_applied = 'Yes' AND purchase_amount > (SELECT AVG(purchase_amount)FROM customer_behaviour_analysis)
ORDER BY purchase_amount DESC
LIMIT 10;
-- Business Problem -- company cannot identify high-spending customers who are also discount users 
--Impact	--identifies premium discount-sensitive customers
			-- Enables targeted discount campaigns
			-- Improves customer retention and revenue

--------------------------------------------------------------------------------------------------------------
-- which are the top/bottom 5 product with higesht avg review rating
--Top 5

SELECT 	item_purchased,
		ROUND(AVG(review_rating),2) as avg_rev_ratings
FROM	customer_behaviour_analysis
GROUP BY item_purchased
ORDER BY avg_rev_ratings DESC
LIMIT 5;

--Bottom 5

SELECT 	item_purchased,
		ROUND(AVG(review_rating),2) as avg_rev_ratings
FROM	customer_behaviour_analysis
GROUP BY item_purchased
ORDER BY avg_rev_ratings ASC
LIMIT 5;
-- Business Problem	--No visibility into product performance based on customerr satisfaction
-- Impact		--Promotes high-performing products
				--improves low-rated products
				--Enhances customer satisfaction

-----------------------------------------------------------------------------------------------------------------
--  Average purchase: standard vs Express shipping

SELECT	shipping_type,
		COUNT(customer_id) as order_placed,
		ROUND(AVG(purchase_amount),2) as avg_purchase,
		ROUND(SUM(purchase_amount),2) as total_rev
FROM	customer_behaviour_analysis
WHERE 	shipping_type IN ('Standard','Express')
GROUP BY shipping_type
ORDER BY total_rev DESC;

--Business Problem	--unclear if faster shipment leads to higher spending.
--Impact		--Helps optimise shipping pricing statergy
				--Encourages premium shipping adoption
				--Increases average order value

---------------------------------------------------------------------------------------------------------------

 --Do subscribed customers spend more ? compare average spent and total revenue between subscribed and non-subscribed?

SELECT 
		subscription_status,
		COUNT(customer_id) as users,
		ROUND(AVG(purchase_amount),2) as avg_spent,
		ROUND(SUM(purchase_amount),2) as total_rev
FROM	customer_behaviour_analysis
GROUP BY subscription_status 
ORDER BY total_rev DESC;

--Business Problem	--The effectiveness of subscription program is unknown
--impact		--validate subscription model performance 
				--improves customer loyalty promgram
				--Increases customer lifetime value (CLV)

------------------------------------------------------------------------------------------------------------------

--Top 5 products with highest discount usage

SELECT	item_purchased,
		COUNT(item_purchased) as total_no_of_times_sold,
		COUNT(CASE WHEN discount_applied ='Yes' THEN 1 END ) as total_no_of_times_sold_on_discount,
		ROUND(COUNT(CASE WHEN discount_applied ='Yes' THEN 1 END ) * 100.0/ COUNT(*),2) as discount_percent
FROM	customer_behaviour_analysis
GROUP BY item_purchased 
ORDER BY  discount_percent DESC
LIMIT 5;
--Business Problem	--some products may be overly dependent on discounts
--impact		--identifies  discount driven products
				--helps optimise pricing statergy 
				--Reduce profit Margin loss 

-----------------------------------------------------------------------------------------------------------------

--Segment customer into new, returning and loyal bas on their total number of previous purchase 

SELECT 
    CASE 
        WHEN previous_purchases = 0 THEN 'New customers'
        WHEN previous_purchases BETWEEN 1 AND 15 THEN 'Returning customers'
        ELSE 'Loyal customers'
    END AS customer_segment,
    COUNT(*) AS customer_count
FROM customer_behaviour_analysis
GROUP BY customer_segment
ORDER BY customer_count DESC;

--Business Problem	Lack of customer segmentation leads to generic statergies
--Impact		--Enables personlized marketing
				--improves retention strategies
				--Increases conversion rate

----------------------------------------------------------------------------------------------------------------

--Which are top 3 most purchased within the category?

WITH CTE as 
(
SELECT 	category,
		item_purchased,
		COUNT(item_purchased) as most_purchased,
		RANK()OVER(PARTITION BY category ORDER by COUNT(item_purchased)DESC) AS RNK
FROM 	customer_behaviour_analysis
GROUP BY category,item_purchased
)
SELECT *
FROM	CTE
WHERE RNK <=3;

-----------------------------------------------------------------------------------------------------------------

-- Are customers who are repeat buyers (more than 5 previous purchase ) also likely to subscribe

WITH CTE AS (
SELECT 
		CASE 
		WHEN previous_purchases >= 5 THEN 'Repeat Buyers'
		ELSE 'Normal Buyers'
		END as customer_type,
		subscription_status
	FROM 	customer_behaviour_analysis )

SELECT	customer_type,
		subscription_status,
		COUNT(*) AS customer_count,
		ROUND(COUNT(*) * 100.0 / SUM(COUNT(*))OVER(PARTITION BY customer_type),2) AS percents
FROM	CTE 	
GROUP BY customer_type,subscription_status;

--Business Problem	--unclear relation between loyalty and subscription 
--Impact		--improves subscription targeting
				--Increases conversion to paid programs
				--increase customer retention statergy

-----------------------------------------------------------------------------------------------------------------

--what is the revenue contribution of each age group

SELECT	CASE
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 51 THEN '36-51'
		ELSE '51+' 
		END AS age_group,
		ROUND(SUM(purchase_amount),2) as total_rev
FROM	customer_behaviour_analysis
GROUP BY CASE
		WHEN age BETWEEN 18 AND 25 THEN '18-25'
		WHEN age BETWEEN 26 AND 35 THEN '26-35'
		WHEN age BETWEEN 36 AND 51 THEN '36-51'
		ELSE '51+' 
		END  
ORDER BY total_rev DESC;

--Business Problem -- No visibility which age-group contributes most to the revenue.

--Impact		--Enables age based targeting
				--Enhances marketing efficiency

---------------------------------------------------------------------------------------------------------------
	
