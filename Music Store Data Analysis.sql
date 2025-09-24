-- CREATING A DATABASE 
create database music_store;
use music_store;


-- TABLE CREATION

-- 1. Genre and MediaType
CREATE TABLE Genre (
	genre_id INT PRIMARY KEY,
	name VARCHAR(120)
);
select * from Genre limit 5;

CREATE TABLE MediaType (
	media_type_id INT PRIMARY KEY,
	name VARCHAR(120)
);
select * from MediaType;

-- 2. Employee
CREATE TABLE Employee (
	employee_id INT PRIMARY KEY,
	last_name VARCHAR(120),
	first_name VARCHAR(120),
	title VARCHAR(120),
	reports_to VARCHAR(5),
    levels VARCHAR(255),
	birthdate DATE,
	hire_date DATE,
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100)
);

-- Convert empty strings to NULL
update Employee
set reports_to = NULL       
where trim(coalesce(reports_to, '')) = '';

-- coalesce(reports_to, '')  --> if reports_to is null, it replaces the null value with an empty string ''
-- trim() = '' --> removes any whitespaces and checks if result is empty string

-- Change the column type to INT and allow NULLs
ALTER TABLE Employee
MODIFY COLUMN reports_to INT NULL;

select * from employee;

-- 3. Customer
CREATE TABLE Customer (
	customer_id INT PRIMARY KEY,
	first_name VARCHAR(120),
	last_name VARCHAR(120),
	company VARCHAR(120),
	address VARCHAR(255),
	city VARCHAR(100),
	state VARCHAR(100),
	country VARCHAR(100),
	postal_code VARCHAR(20),
	phone VARCHAR(50),
	fax VARCHAR(50),
	email VARCHAR(100),
	support_rep_id INT,
	FOREIGN KEY (support_rep_id) REFERENCES Employee(employee_id)
);
select * from Customer;

-- 4. Artist
CREATE TABLE Artist (
	artist_id INT PRIMARY KEY,
	name VARCHAR(120)
);
select * from Artist limit 5;

-- 5. Album
CREATE TABLE Album (
	album_id INT PRIMARY KEY,
	title VARCHAR(160),
	artist_id INT,
	FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);
select * from Album limit 5;

-- 6. Track
CREATE TABLE Track (
	track_id INT PRIMARY KEY,
	name VARCHAR(200),
	album_id INT,
	media_type_id INT,
	genre_id INT,
	composer VARCHAR(220),
	milliseconds INT,
	bytes INT,
	unit_price DECIMAL(10,2),
	FOREIGN KEY (album_id) REFERENCES Album(album_id),
	FOREIGN KEY (media_type_id) REFERENCES MediaType(media_type_id),
	FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
);

SHOW VARIABLES LIKE 'secure_file_priv';

-- Loading Data FROM track.csv file into track table
LOAD DATA INFILE  "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/track.csv"
INTO TABLE  track
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(track_id, name, album_id, media_type_id, genre_id, composer, milliseconds, bytes, unit_price);

select * from Track limit 5;

-- 7. Invoice
CREATE TABLE Invoice (
	invoice_id INT PRIMARY KEY,
	customer_id INT,
	invoice_date DATE,
	billing_address VARCHAR(255),
	billing_city VARCHAR(100),
	billing_state VARCHAR(100),
	billing_country VARCHAR(100),
	billing_postal_code VARCHAR(20),
	total DECIMAL(10,2),
	FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
);
select * from Invoice limit 5;

-- 8. InvoiceLine
CREATE TABLE InvoiceLine (
	invoice_line_id INT PRIMARY KEY,
	invoice_id INT,
	track_id INT,
	unit_price DECIMAL(10,2),
	quantity INT,
	FOREIGN KEY (invoice_id) REFERENCES Invoice(invoice_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- Loading Data FROM invoice_line.csv file into InvoiceLine table
LOAD DATA INFILE  "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/invoice_line.csv"
INTO TABLE  InvoiceLine
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(invoice_line_id,invoice_id,track_id,unit_price,quantity);

select * from InvoiceLine;

-- 9. Playlist
CREATE TABLE Playlist (
 	playlist_id INT PRIMARY KEY,
	name VARCHAR(255)
);
select * from Playlist;

-- 10. PlaylistTrack
CREATE TABLE PlaylistTrack (
	playlist_id INT,
	track_id INT,
	PRIMARY KEY (playlist_id, track_id),
	FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
	FOREIGN KEY (track_id) REFERENCES Track(track_id)
);

-- Loading Data FROM playlist_track.csv file into PlaylistTrack table
LOAD DATA INFILE  "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/playlist_track.csv"
INTO TABLE  PlaylistTrack
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(playlist_id,track_id);

select * from PlaylistTrack limit 5;


-- TASK QUESTIONS

-- 1. Who is the senior most employee based on job title? 

select employee_id, concat(first_name, ' ', last_name) as Employee_Name,title, levels, reports_to
from Employee
order by cast(substring(levels, 2) as unsigned integer) DESC      
limit 1;

-- Explanation:
-- substring(levels, 2) --> Extracts the number for example '7' which is at position 2 (which is still in string format) from 'L7'
-- cast(..  --> converts the string '7' to numeric 7 for correct sorting
-- order by --> sorts the level numbers in descending order, so that the highest level comes first
-- limit 1 --> limits the output to top 1 row after sorting, there by it returns the details of senior most employee based on job title

-- 2. Which countries have the most Invoices?
select billing_country,count(*) as number_of_invoices		-- retrives the billing_country and count of the number of invoices from that country from Invoice table
from Invoice
group by billing_country									-- groups all rows by unique billing_country, this ensures count(*) is calculated per country
order by number_of_invoices desc							-- sorts the countries in descending order of number_of_invoices
limit 5;													-- returns the top 5 countries with most number of invoices


-- 3. What are the top 3 values of total invoice?
select * from Invoice
order by total desc 		-- sorting the 'total' in descending order 
limit 3;					-- returns only the top 3 values


-- 4. Which city has the best customers? - We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals
select billing_city, sum(total)	as total_per_city		-- retrieves billing_city and the total amount earned from that city by summing up the 'total' column
from Invoice
group by billing_city									-- groups the invoices by billing_city, so that we get sum(total) per city
order by total_per_city desc							-- sorts the total_per_city in descending order 
limit 1;												-- returns the top 1 city with highest total invoice

-- 5. Who is the best customer? - The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money
select c.customer_id,
concat(c.first_name,' ',c.last_name) as Customer_Name,
c.country,
sum(i.total) as total_spent                                 -- total amount spent by the customer
from customer c
join Invoice i on												
c.customer_id = i.customer_id								-- joining the tables Customer and Invoice to connect customers with their invoices
group by c.customer_id, c.first_name, c.last_name			-- grouping by each customer to calculate their total spending
order by total_spent desc									-- sorting the total_spent by each customer in descending order
limit 1;													-- returns the details of top customer who spent the most money

-- 6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A
select distinct c.email,c.first_name,c.last_name,g.name as genre
from customer c 
join invoice i 															-- performing a series of joins to get a connection between customer table and genre table
	on c.customer_id = i.customer_id									-- Match customer to their invoices
join invoiceline il
	on i.invoice_id = il.invoice_id										-- Match invoice to invoice line (individual tracks)
join track t 
	on il.track_id = t.track_id											-- Match invoice line items to tracks purchased
join genre g
	on t.genre_id = g.genre_id											-- Match tracks to their genre
where g.name = 'Rock'													-- Filter for only Rock music listeners
order by email;															-- Sort results alphabetically by email

-- 7. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands 

select a.name as Artist_name, 													-- Artist's name
	   count(t.track_id) as rock_track_count					-- Total number of Rock tracks by the artist					
from artist a 
	join album al												-- performing a series of joins to get the connection between artists and the genre
		on a.artist_id = al.artist_id							-- Join artist to their albums
	join track t
		on al.album_id = t.album_id								-- Join albums to their tracks
	join genre g
		on t.genre_id = g.genre_id								-- Join tracks to their genre
where g.name = 'Rock'											-- Filter only tracks belonging to the 'Rock' genre
group by a.artist_id,a.name										-- Group results by artist to count the number of Rock tracks written by them
order by rock_track_count desc									-- Sort the artists by track count in descending order
limit 10;														-- Return the top 10 Rock Artists

-- 8. Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length, with the longest songs listed first

select track_id,name,milliseconds as song_length,(select avg(milliseconds) from track) as Avg_Length
from track 
where milliseconds > (select avg(milliseconds) from track)												-- Filter the songs that are longer than average song length
order by song_length desc;																				-- Sort the songs in descending order of their length
																			

-- 9. Find how much amount is spent by each customer on artists? Write a query to return customer name, artist name and total spent 
select c.customer_id, concat(c.first_name,' ',c.last_name) as Customer_name,
	   a.name as Artist_name, 
	   sum(il.unit_price*il.quantity) as total_spent							-- Total money spent by the customer on that artist
from customer c 
	join invoice i 																-- performing a series of joins to get a connection between customer and the artist
		on c.customer_id = i.customer_id										-- Link customer to their invoices
	join invoiceline il
		on i.invoice_id = il.invoice_id											-- Link invoices to the invoiceline  (individual tracks)
	join track t
		on il.track_id = t.track_id												-- Link each invoice line item to a track
	join album al
		on t.album_id = al.album_id												-- Link each track to its album
	join artist a
		on al.artist_id = a.artist_id											-- Link each album to its artist
group by c.customer_id,c.first_name,c.last_name,a.artist_id,a.name				-- Group by both customer and artist to calculate total spent per each customer artist pair
order by total_spent desc;														-- Sorting the total spent in descending order to show highest spending combinations first

-- 10. We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases.
-- Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared, return all Genres

-- Creating a CTE to count how many times each genre was purchased in each country
with GenrePurchaseCounts as(
	select c.country,g.name as genre,count(*) as purchase_count			-- number of times this genre is purchases in a country
	from customer c
	join invoice i on
		c.customer_id = i.customer_id									-- Link customers to their invoices
	join invoiceline il on
		i.invoice_id = il.invoice_id									-- Link invoices to invoice line items
	join track t on
		il.track_id = t.track_id										-- Link invoice lines to tracks
	join genre g on
		t.genre_id = g.genre_id											-- Link tracks to their genre
group by c.country,g.name,g.genre_id									-- Grouping by country and genre to get purchase_count of each genre for each country
),
MaxGenreCount as(														-- Creating a CTE to find the maximum purchase count per country
	select country, max(purchase_count) as Max_Count					-- Retrieving Country name and Max Purchase Count i.e. highest number of purchases
	from GenrePurchaseCounts
	group by country													-- grouping by country
)
select gpc.country,														-- Country name
	   gpc.genre,														-- Genre
       mgc.Max_count													-- Highest number of purchases in that country
from GenrePurchaseCounts gpc
join MaxGenreCount mgc
	on gpc.country = mgc.country 										-- Match by Country
	and gpc.purchase_count = mgc.Max_count								-- Selecting country and genre with Highest number of purchases
																		-- This takes care when maximum number of purchases is shared and returns all those genres 
order by mgc.Max_count desc;


-- 11. Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount

-- Creating a CTE to calculate total amount spent by each customer
with CustomerTotalSpent as(
	select c.customer_id,concat(c.first_name,' ',last_name) as Customer,c.country,
		   sum(i.total) as total_spent 													-- total money spent by the customer
	from customer c
	join invoice i 
		on c.customer_id = i.customer_id												-- Join the customers to their invoice
	group by c.customer_id,c.first_name,c.last_name,c.country							-- group by customer and their country to get total money spent by customer 
),
MaxTotalSpent as(
	select country,max(total_spent) as Max_total_spent									-- Maximum spending value per country
	from CustomerTotalSpent
	group by country
)
select cts.customer_id,cts.Customer,cts.country,mts.Max_total_spent
from CustomerTotalSpent cts
join MaxTotalSpent mts 
	on cts.country = mts.country 														-- Match by country
	and cts.total_spent = mts.Max_total_spent											-- Selecting the customer who spent the most
order by mts.Max_total_spent desc;														-- Sort results by total spent in descending order










