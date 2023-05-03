--Import CSV file named 'books'
CREATE TABLE books(
		   id     INT,
   		   title  TEXT,
		   author TEXT,
		   year   INT,
		   genre  TEXT);

COPY books FROM 'F:\Books.csv'
DELIMITER ','
CSV HEADER;


/* From above query received following error
ERROR:  syntax error at or near ","
LINE 2: ALTER COLUMN id, year TYPE text;*/

 ALTER TABLE books
ALTER COLUMN id TYPE text,
ALTER COLUMN year TYPE text;

SELECT * FROM books;

-- Checked information_schema of table books here.
SELECT table_schema, 
	   table_name, 
	   column_name, 
	   data_type 
      FROM information_schema.columns
     WHERE table_name = 'books';

--Checked the names of the constraints in the table student.
SELECT table_name,
       constraint_type,
       constraint_name
  FROM information_schema.table_constraints
 WHERE table_name = 'books';

/* Analysis of each column. */

SELECT COUNT(DISTINCT id) -- Count distinct id to check for any duplicates in column.
  FROM books;

SELECT * -- Checked for null in the id column.
  FROM books
 WHERE id IS NULL;

SELECT COUNT(DISTINCT title) -- Count distinct title to check for any duplicates in the column.
  FROM books;

SELECT COUNT(DISTINCT author) -- Count unique author in the column.
  FROM books;

SELECT * 
  FROM books
 WHERE author IS NULL
    OR author IN ('Fiction', 'Non Fiction');-- Checked for Null/type of genre in the author column.

SELECT COUNT(DISTINCT year) AS total_years --Count total years.
  FROM books;

SELECT * 
  FROM books
 WHERE year IS NULL;-- Checked for Null in the year column.

SELECT * 
  FROM books
 WHERE genre IS NULL;--Checked for Null in the genre column

  SELECT genre, COUNT(genre) AS no_of_genre, LENGTH(genre) AS length_of_genre
    FROM books
GROUP BY genre; --Group by genre to count no of categories

SELECT * 
  FROM books
 WHERE genre LIKE '';--Checked for Blank in the genre column


/*Detail analysis description as per bwlow.
There are total 352 rows and 5 columns in the books table, which is database for this analysis.
There are no constraints in the table books.
1. id: There are 350 rows. 2 Rows are null.
2. title: There are 352 rows. But when we analyzed 'null' for id column, we observed '2016 & 2018' years mentioned in the column.
3. author: There total 246 unique authors. But when we analyzed 'null' for id column, we observed 'Non fiction' genre mentioned in the column.
4. year: There are 4 null in the column.
5. genre: Firstly, checked for null but rows returned 0. Hence investigated more, found that there are 4 blank rows.*/

--Removed null from id
DELETE FROM books
      WHERE id IS NULL;

SELECT MAX(LENGTH(author)) 
  FROM books;--Checked for max characters in author column

--Change data type of author column to VARCHAR
 ALTER TABLE books
ALTER COLUMN author TYPE VARCHAR(50);

SELECT DISTINCT year 
           FROM books; --Checked unique years

UPDATE books
   SET year = NULL
 WHERE year ILIKE 'Null'; -- Replaced null which are in text formed null to nulls.

--Change data type of year & genre to integer & varchar respectively.
 ALTER TABLE books
ALTER COLUMN year TYPE INT USING year :: INTEGER,
ALTER COLUMN genre TYPE VARCHAR(15);

--id column made as a Primary Key
    ALTER TABLE books
ADD PRIMARY KEY (id);

--Display everthing from table book
SELECT * FROM books;

--Write a query to display Total no of books as total number of books.
SELECT COUNT(id) AS total_number_of_books
  FROM books;

--Write a query to display title & auhor of the book.
SELECT title AS book_title,
       author
  FROM books;

--Write a query to display the no of books released per year and order it by year in asceding order.
  SELECT year AS released_year,
	 COUNT(title) AS no_of_books
    FROM books
GROUP BY year
ORDER BY year ASC;

--Write a query to display the total books release in Fiction genre.
SELECT COUNT(title) AS total_released_books
  FROM books
 WHERE genre = 'Fiction';

--Write a query to display the no of books as per genre category and order it by no of books in asceding order.
  SELECT genre, 
 	 COUNT (title) AS total_no_of_books
    FROM books
GROUP BY genre
ORDER BY total_no_of_books;

--Write a query to display all books in Non Fiction genre.
SELECT title
  FROM books
 WHERE genre = 'Non Fiction';

--Write a query that shows max books released in which year.
  SELECT year,
	 COUNT(title) AS no_of_books_released
    FROM books
GROUP BY year -- Group the result set by year
-- The result is filtered by the HAVING clause to show only the years with the maximum number of books.
  HAVING COUNT(title) = (SELECT MAX(no_of_books) -- Maximum number of books across all years
	  		   FROM (
				 SELECT year, COUNT(title) AS no_of_books  -- Count the number of books for each year
				   FROM books
			       GROUP BY year) AS subquery);--Subquery for Max no of books


--Writr a query that shows row number as per no of books per year
SELECT year AS released_year,
       COUNT(title) AS no_of_books,
       ROW_NUMBER() OVER(ORDER BY COUNT(title) DESC) AS row_number
  FROM books
 GROUP BY year;

--Write a query that shows top 3 authors and their no of books
  SELECT author,
	 COUNT(title) AS no_of_books
    FROM books
GROUP BY author
ORDER BY no_of_books DESC
LIMIT 3;

--Write a query that shows a book that contains numeric in its title
SELECT *
  FROM books
 WHERE title ~ '[0-9]';

--Write a query that shows a book that contains numeric in the end of the title
SELECT *
  FROM books
 WHERE title ~ '[0-9]$';

--Write a query that shows a book that contains numeric in the start of the title
SELECT *
  FROM books
 WHERE title ~ '^[0-9]';

SELECT *
  FROM books
 WHERE title ILIKE 'A%';--ILIKE is not case sensitive
 
 
 --Write a query to create a column email id of author with @gmail.com domain
ALTER TABLE books
 ADD COLUMN email_id varchar(100);

UPDATE books
   SET email_id = CONCAT(LOWER(REPLACE(REPLACE(author, ' ', ''),'.','')), '@gmail.com');

SELECT * FROM books;

--Write a query that shows the distribution of the number of books written by each author among the given 
ranges (bins) of 0-5, 6-10, 11-15, and 16-20, and how many authors fall into each range

WITH bins AS(SELECT GENERATE_SERIES(0,20,5)+1 AS lower,--Lower bins created
		    GENERATE_SERIES(5,25,5) AS upper), --upper bins created
     authors AS(SELECT author, 
	   	       COUNT(title) AS no_of_books -- No of books written by author
		  FROM books
	      GROUP BY author)
   SELECT b.lower,
	  b.upper,
	  COUNT(a.no_of_books) AS no_of_authors
     FROM bins AS b
LEFT JOIN authors AS a
	  ON a.no_of_books >= b.lower  --First cndition that it should be grater than or equal to lower
	  AND a.no_of_books <= b.upper   --Second condition that it should be less than or equal to upper
 GROUP BY b.lower, b.upper
 ORDER BY b.lower ASC;

-- Write a query to pivot the 'books' table by year and genre, and showing the count of books released in each 
genre for the years 2017, 2018, and 2019 in the output table (In the form of Pivot table)

CREATE EXTENSION IF NOT EXISTS tablefunc;
  
  SELECT * FROM CROSSTAB ($$
  SELECT genre,
 	 year,  
    	 COUNT(title)::INT AS no_of_released_books
    FROM books
   WHERE year IN(2017,2018,2019)
GROUP BY genre, year
ORDER BY genre, year;
$$) AS ct (genre  VARCHAR,
		   "2017" INT,
		   "2018" INT,
		   "2019" INT)
ORDER BY genre;
		   
--Write a query to show who has written the most books, and then concatenate their names into a single comma-separated string.

WITH top_three AS(SELECT author,
			 COUNT(title) AS no_of_books -- No of books written by author
			 FROM books
		GROUP BY author
		ORDER BY no_of_books DESC
		   LIMIT 3)

SELECT STRING_AGG(author, ', ') AS top_3_authors
  FROM top_three;
  
--Write a query to find the author who wrote the most number of books in each year, along with the number of books they wrote
  WITH max_author AS(SELECT year, author, 
			    COUNT(author) AS no_of_books
		       FROM books
		   GROUP BY year, author),
          row_num AS(SELECT year, author, no_of_books, 
			    ROW_NUMBER() OVER(PARTITION BY year ORDER BY no_of_books DESC, author) AS rn
		       FROM max_author)
SELECT year, 
       author, 
       no_of_books
  FROM row_num
 WHERE rn=1;
 
 

  