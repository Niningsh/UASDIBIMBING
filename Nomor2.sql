--DATA
-- Create raw tables
CREATE TABLE raw_users (
user_id INT,
user_name VARCHAR(100),
country VARCHAR(50)
);
CREATE TABLE raw_posts (
post_id INT,
post_text VARCHAR(500),
post_date DATE,
user_id INT
);
CREATE TABLE raw_likes (
like_id INT,
user_id INT,
post_id INT,
like_date DATE
);
-- Insert sample data
INSERT INTO raw_users
VALUES
(1, 'john_doe', 'Canada'),
(2, 'jane_smith', 'USA'),
(3, 'bob_johnson', 'UK');
INSERT INTO raw_posts
VALUES
(101, 'My first post!', '2020-01-01', 1),
(102, 'Having fun learning SQL', '2020-01-02', 2),
(103, 'Big data is cool', '2020-01-03', 1),
(104, 'Just joined this platform', '2020-01-04', 3),
(105, 'Whats everyone up to today?', '2020-01-05', 2),
(106, 'Data science is the future', '2020-01-06', 1),
(107, 'Practicing my SQL skills', '2020-01-07', 2),
(108, 'Hows the weather where you are?', '2020-01-08', 3),
(109, 'TGI Friday!', '2020-01-09', 1),
(110, 'Any big plans for the weekend?', '2020-01-10', 2);
INSERT INTO raw_likes
VALUES
(1001, 1, 101, '2020-01-01'),
(1002, 3, 101, '2020-01-02'),
(1003, 2, 102, '2020-01-03'),
(1004, 1, 103, '2020-01-04'),
(1005, 3, 104, '2020-01-05'),
(1006, 2, 104, '2020-01-06'),
(1007, 1, 105, '2020-01-07'),
(1008, 2, 106, '2020-01-08'),
(1009, 3, 107, '2020-01-09'),
(1010, 1, 108, '2020-01-10'),
(1011, 2, 109, '2020-01-11'),
(1012, 3, 110, '2020-01-12');

--Nomor1
-- Create dimension tables
CREATE TABLE dim_user (
    user_id INT PRIMARY KEY,
    user_name VARCHAR(100),
    country VARCHAR(50)
);

CREATE TABLE dim_post (
    post_id INT PRIMARY KEY,
    post_text VARCHAR(500),
    post_date DATE,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id)
);

CREATE TABLE dim_date (
    date_id DATE PRIMARY KEY
);

--Nomor2
-- Populate dimension tables
INSERT INTO dim_user (user_id, user_name, country)
SELECT DISTINCT user_id, user_name, country FROM raw_users;

INSERT INTO dim_post (post_id, post_text, post_date, user_id)
SELECT DISTINCT post_id, post_text, post_date, user_id FROM raw_posts;

INSERT INTO dim_date (date_id)
SELECT DISTINCT post_date FROM raw_posts;

--Nomor 3
-- Populate fact table fact_post_performance
INSERT INTO fact_post_performance (post_id, user_id, date_id, post_views, likes)
SELECT
    p.post_id,
    p.user_id,
    p.post_date,
    COUNT(l.like_id) AS post_views,
    COUNT(l.like_id) AS likes
FROM
    raw_posts p
LEFT JOIN
    raw_likes l ON p.post_id = l.post_id
GROUP BY
    p.post_id, p.user_id, p.post_date;

--Nomor 4
  -- Populate fact table fact_post_performance
INSERT INTO fact_post_performance (post_id, user_id, date_id, post_views, likes)
SELECT
    p.post_id,
    p.user_id,
    p.post_date,
    COUNT(l.like_id) AS post_views,
    SUM(CASE WHEN l.like_id IS NOT NULL THEN 1 ELSE 0 END) AS likes
FROM
    raw_posts p
LEFT JOIN
    raw_likes l ON p.post_id = l.post_id
GROUP BY
    p.post_id, p.user_id, p.post_date;

--Nomor 5
-- Create fact table fact_daily_posts
CREATE TABLE fact_daily_posts (
    user_id INT,
    date_id DATE,
    num_posts INT,
    PRIMARY KEY (user_id, date_id),
    FOREIGN KEY (user_id) REFERENCES dim_user(user_id),
    FOREIGN KEY (date_id) REFERENCES dim_date(date_id)
);
-- Populate fact table fact_daily_posts
INSERT INTO fact_daily_posts (user_id, date_id, num_posts)
SELECT
    p.user_id,
    p.post_date,
    COUNT(p.post_id) AS num_posts
FROM
    raw_posts p
GROUP BY
    p.user_id, p.post_date;
  
 
 --Nomor 6
 INSERT INTO fact_daily_posts (user_id, post_date, total_posts)
SELECT
    u.user_id,
    DATE(p.post_date) AS post_date,
    COUNT(*) AS total_posts
FROM
    raw_users u
JOIN
    raw_posts p ON u.user_id = p.user_id
GROUP BY
    u.user_id,
    DATE(p.post_date);
