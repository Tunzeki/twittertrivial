-- @joebasshd posted on twitter a SQL trigger problem he was trying to solve
-- Here is the description he gave:
-- The goal is to use Triggers to get auto-generated primary keys for the company table. 
-- It follows a format - 
-- the initials of the country the company is registered in 
-- followed by a dash, 
-- three letters depending on the name of the company, 
-- another dash, 
-- then random numbers.
-- The problem is the middle part of the auto-generated key - 
-- which is the three letters depending on the count of words in name of the company.
-- i) If the company name is one word, then it's supposed to extract the first 3 letters of the word
-- ii) if the company name is 2 words, it's supposed to extract the first letter of the first word, 
-- then the first two letters of the second word (this is where the problem is)
-- iii) if it's 3 words, it extract the first letter from each word.

-- Here is how I approached the problem

-- First, create a database
CREATE DATABASE IF NOT EXISTS twitter_trivial_db;