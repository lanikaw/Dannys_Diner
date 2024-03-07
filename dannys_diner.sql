-- Danny's Diner --

-- 1. What is the total amount each customer spent at the restaurant?

SELECT Distinct(customer_id), SUM(price)
FROM dannys_diner.sales
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY customer_id

-- 2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT (DISTINCT order_date) days
FROM dannys_diner.sales
GROUP BY customer_id

-- 3. What was the first item from the menu purchased by each customer?

SELECT sales.customer_id, menu.product_name, MIN(sales.order_date)
FROM dannys_diner.sales
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY  sales.customer_id, menu.product_name, sales.order_date
ORDER BY sales.order_date

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT menu.product_id, menu.product_name, COUNT(sales.product_id) num_times
FROM dannys_diner.sales
JOIN dannys_diner.menu
ON sales.product_id = menu.product_id
GROUP BY sales.product_id, menu.product_id, menu.product_name
ORDER BY num_times DESC

-- 5. Which item was the most popular for each customer?

SELECT s.customer_id, m.product_name, COUNT(s.product_id) purchase_count
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY purchase_count DESC

-- 6. Which item was purchased first by the customer after they became a member?

SELECT 
	s.customer_id, 
    s.order_date, 
    mem.join_date, 
    m.product_name, 
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) 
    AS rank
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members mem
ON s.customer_id = mem.customer_id
WHERE s.order_date >= join_date

-- 7. Which item was purchased just before the customer became a member?

SELECT 
	s.customer_id, 
    s.order_date, 
    mem.join_date, 
    m.product_name, 
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) 
    AS rank
FROM dannys_diner.sales s
JOIN dannys_diner.menu m
ON s.product_id = m.product_id
JOIN dannys_diner.members mem
ON s.customer_id = mem.customer_id
WHERE s.order_date < join_date

-- 8. What is the total items and amount spent for each member before they became a member?

SELECT 
	s.customer_id, 
    COUNT(*) total_items, 
    SUM(m.price) total_spent
FROM dannys_diner.sales s
JOIN dannys_diner.menu m 
ON s.product_id = m.product_id
JOIN dannys_diner.members mem
ON s.customer_id = mem.customer_id
WHERE s.order_date < join_date
GROUP BY s.customer_id,  
    mem.join_date
ORDER BY s.customer_id

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT 
	s.customer_id,
    SUM(CASE WHEN m.product_name='sushi' THEN 2 * 10 * m.price ELSE 10 * 		m.price END) total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m 
ON s.product_id = m.product_id
GROUP BY s.customer_id

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT 
	s.customer_id, 
    SUM(CASE WHEN s.order_date between mem.join_date AND 					mem.join_date+ INTERVAL '6 days' THEN m.price *2 * 10 END) 			total_points
FROM dannys_diner.sales s
JOIN dannys_diner.menu m 
ON s.product_id = m.product_id
JOIN dannys_diner.members mem
ON s.customer_id = mem.customer_id
WHERE s.order_date >= join_date
GROUP BY s.customer_id,  
    mem.join_date
ORDER BY s.customer_id
