-- (a) Titles of all books by Pratchett that cost less than $10
SELECT b.title
FROM   BOOK b
JOIN   BOOK_AUTHOR ba ON b.book_id   = ba.book_id
JOIN   AUTHOR      a  ON ba.author_id = a.author_id
WHERE  (a.first_name || ' ' || a.last_name) LIKE '%Pratchett%'
  AND  b.price < 10.00
ORDER  BY b.title;

-- (b) Titles and purchase dates for Alice Morgan
SELECT b.title,
       o.order_date AS purchase_date
FROM   ORDERS     o
JOIN   ORDER_ITEM oi ON o.order_id    = oi.order_id
JOIN   BOOK       b  ON oi.book_id    = b.book_id
JOIN   CUSTOMER   c  ON o.customer_id = c.customer_id
WHERE  c.first_name = 'Alice'
  AND  c.last_name  = 'Morgan'
ORDER  BY o.order_date;

-- (c) Titles and ISBNs for books with fewer than 5 copies in stock
SELECT b.title,
       b.isbn,
       i.stock_count
FROM   BOOK      b
JOIN   INVENTORY i ON b.book_id = i.book_id
WHERE  i.stock_count < 5
ORDER  BY i.stock_count, b.title;

-- (d) Customers who purchased Pratchett books and the titles they bought
SELECT DISTINCT c.first_name, c.last_name, b.title
FROM CUSTOMER c
JOIN ORDERS o ON c.customer_id = o.customer_id
JOIN ORDER_ITEM oi ON o.order_id = oi.order_id
JOIN BOOK b ON oi.book_id = b.book_id
JOIN BOOK_AUTHOR ba ON b.book_id = ba.book_id
JOIN AUTHOR a ON ba.author_id = a.author_id
WHERE a.first_name LIKE '%Pratchett%'
ORDER BY c.last_name, b.title;

-- (e) Total books purchased by Alice Morgan
SELECT c.first_name, c.last_name, SUM(oi.quantity) AS total_books
FROM CUSTOMER c
JOIN ORDERS o ON c.customer_id = o.customer_id
JOIN ORDER_ITEM oi ON o.order_id = oi.order_id
WHERE c.customer_id = 1;

-- (f) Customer who purchased the most books
SELECT c.first_name, c.last_name, SUM(oi.quantity) AS total_books
FROM CUSTOMER c
JOIN ORDERS o ON c.customer_id = o.customer_id
JOIN ORDER_ITEM oi ON o.order_id = oi.order_id
GROUP BY c.customer_id
ORDER BY total_books DESC
LIMIT 1;