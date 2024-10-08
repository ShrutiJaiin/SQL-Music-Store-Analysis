--1. Who is the senior most employee based on job title?

select * 
from employee
order by levels desc
limit 1;

--2. Which countries have the most Invoices?
select count (*) as country_cnt, billing_country 
from invoice
group by billing_country
order by country_cnt desc;

--3. What are top 3 values of total invoice?
select total
from invoice
order by total desc
limit 3;

--4. Which city has the best customers? We would like to throw a promotional Music
--Festival in the city we made the most money. Write a query that returns one city that
--has the highest sum of invoice totals. Return both the city name & sum of all invoice
--totals

select billing_city as city_name , sum(total) as invoice_total
from invoice
group by city_name
order by invoice_total desc
limit 1;

--5. Who is the best customer? The customer who has spent the most money will be
--declared the best customer. Write a query that returns the person who has spent the
--most money

select c.customer_id, c.first_name, c.last_name, sum(i.total) as invoice_total
from customer c
join invoice i using (customer_id)
group by c.customer_id
order by invoice_total desc
	limit 1;	

--6. Write query to return the email, first name, last name, & Genre of all Rock Music
--listeners. Return your list ordered alphabetically by email starting with A

select distinct c.first_name, c.last_name, c.email
from customer c
join invoice i using (customer_id)
join Invoice_line il using (invoice_id)
where track_id in ( select track_id from track
					join genre g using (genre_id)
					where g.name = 'Rock')
order by c.email asc;

--7. Let's invite the artists who have written the most rock music in our dataset. Write a
--query that returns the Artist name and total track count of the top 10 rock bands

select a.artist_id, a.name, count(a.artist_id) as num_of_songs
from track t 
join album al using (album_id)
join artist a using (artist_id)
join genre g using (genre_id)
where g.name = 'Rock'	
group by a.artist_id
order by num_of_songs desc	
limit 10;

--8. Return all the track names that have a song length longer than the average song length.
--Return the Name and Milliseconds for each track. Order by the song length with the
--longest songs listed first

select name, milliseconds
from track	
where milliseconds > (select avg(milliseconds) as avg_song_length from track)
order by milliseconds desc;

--9. Find how much amount spent by each customer on artists? Write a query to return
--customer name, artist name and total spent

with best_selling_artist as 
	(select a.artist_id as artist_id, a.name as artist_name,
	sum(il.unit_price * il.quantity) as total_spent
from invoice_line il
join track t using (track_id)
join album al using (album_id)
join artist a using (artist_id)	
group by 1
order by total_spent desc
limit 1)
		
select c.customer_id, c.first_name, c.last_name, bsa.artist_name, sum(il.unit_price * il.quantity) as total_spent
from invoice i
join customer c using (customer_id)
join invoice_line il using (invoice_id)
join track t using (track_id)
join album al using (album_id)
join best_selling_artist bsa using (artist_id)	
group by c.customer_id, c.first_name, c.last_name, bsa.artist_name
order by total_spent desc;


--10. We want to find out the most popular music Genre for each country. We determine the
--most popular genre as the genre with the highest amount of purchases. Write a query
--that returns each country along with the top Genre. For countries where the maximum
--number of purchases is shared return all Genres

with popular_genre as
	(select count(*) as purchases, c.country, g.name, g.genre_id,
	row_number() over (partition by c.country order by count(*) desc) as RowNo
	from invoice_line il
	join invoice i using (invoice_id)
	join customer c using (customer_id)
	join track t using (track_id)
	join genre g using (genre_id)
	group by 2,3,4
	order by 2 asc, 1 desc)

select *
from popular_genre
where RowNo <=1;

--11. Write a query that determines the customer that has spent the most on music for each
--country. Write a query that returns the country along with the top customer and how
--much they spent. For countries where the top amount spent is shared, provide all
--customers who spent this amount

WITH customer_with_country as
(select c.customer_id, first_name, last_name, billing_country, sum(total) as total_spending,
  row_number() over (partition by billing_country order by sum(total) desc) as RowNo
	from invoice
	join customer c using (customer_id)
	group by 1,2,3,4
	order by 4 asc, 5 desc)
select *
from customer_with_country 
where RowNo <= 1;