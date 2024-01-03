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

-- Use the database subsequently
USE twitter_trivial_db;

-- Create a table to store companies details
-- From the sample code, he provided, I could make out that companies will have at least 3 columns
CREATE TABLE IF NOT EXISTS companies (
    id VARCHAR(12) PRIMARY KEY, -- assuming a country initials may be 2 or 3 lettters gives a max of 12 characters
    `name` VARCHAR(128) UNIQUE NOT NULL,
    country_code VARCHAR(3) NOT NULL -- assume a max of 3 letters
)ENGINE=InnoDB, CHARSET="utf8mb4";

-- Create the before_insert trigger
DELIMITER $$

CREATE TRIGGER before_companies_insert
BEFORE INSERT 
ON companies 
FOR EACH ROW
BEGIN
    -- Create variables
    DECLARE trimmed_company_name VARCHAR(128);
    DECLARE space_count INT;
    -- First remove leading and trailing spaces in the name if there are
    SET trimmed_company_name = TRIM(NEW.name);
    -- Next, count the number of spaces in between words, if the name 
    -- of the company has more than one word
    -- Number of spaces in between words will be 0 if company name is just one word
    
    -- The idea is to remove the number of spaces in between the words 
    -- and then subtract the the length of the company name with spaces in between words removed
    -- from the length of the company name having those spaces
    SET space_count = LENGTH(trimmed_company_name) - LENGTH(REPLACE(trimmed_company_name, " ", ""));

    -- this generates a 4-digit number from 0000 - 9999 randomly
    SET @random_number = LPAD(FLOOR(RAND() * (9999 - 0 + 1) + 0), 4, '0');

    CASE space_count
        WHEN 0 THEN -- i.e, the company name has a single word
            SET @generated_letters = UPPER(SUBSTRING(trimmed_company_name FROM 1 FOR 3));
            -- Set the new id
            SET NEW.id = CONCAT(NEW.country_code, "-", @generated_letters, "-", @random_number);
        WHEN 1 THEN -- i.e two words in the company name
            -- First, get the first word
            SET @first_word = SUBSTRING_INDEX(trimmed_company_name, " ", 1);
            -- Then, the first letter
            SET @first_word_first_letter = SUBSTRING(@first_word FROM 1 FOR 1);
            -- Then, get the second word
            SET @second_word = REPLACE(trimmed_company_name, CONCAT(@first_word, " "), "");
            -- Get the first two letters of the second word
            SET @second_word_first_two_letters = SUBSTRING(@second_word FROM 1 FOR 2);
            -- Concatenate first letter in first word with first two letters in second word
            SET @generated_letters = UPPER(CONCAT(@first_word_first_letter, @second_word_first_two_letters));
            -- Set the new id
            SET NEW.id = CONCAT(NEW.country_code, "-", @generated_letters, "-", @random_number);
        WHEN 2 THEN -- i.e three words in the company name
            -- similar steps to get the first letter in the first word as above and also the second word
            SET @first_word = SUBSTRING_INDEX(trimmed_company_name, " ", 1);
            SET @first_word_first_letter = SUBSTRING(@first_word FROM 1 FOR 1);
            SET @second_word = REPLACE(trimmed_company_name, CONCAT(@first_word, " "), "");
            -- Get the first letter of the second word
            SET @second_word_first_letter = SUBSTRING(@second_word FROM 1 FOR 1);
            -- Get the third word
            SET @third_word = REPLACE(trimmed_company_name, CONCAT(SUBSTRING_INDEX(trimmed_company_name, " ", 2), " "), "");
            -- Get the first letter of the third word
            SET @third_word_first_letter = SUBSTRING(@third_word FROM 1 FOR 1);
            -- Concatenate the three letters
            SET @generated_letters = UPPER(CONCAT(@first_word_first_letter, @second_word_first_letter, @third_word_first_letter));
            -- Set the new id
            SET NEW.id = CONCAT(NEW.country_code, "-", @generated_letters, "-", @random_number);
        ELSE
            BEGIN
            -- What do you want to do if the company name has more than three words?
            -- For now, this just helps to prevent an error
            END;
        END CASE;
END $$

DELIMITER ;