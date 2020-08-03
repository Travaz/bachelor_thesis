-- Create a new database called 'Thesis'
-- Connect to the 'master' database to run this snippet
USE master
GO
-- Create the new database if it does not exist already
IF NOT EXISTS (
    SELECT name
        FROM sys.databases
        WHERE name = N'Thesis'
)
CREATE DATABASE Thesis
GO

-- Switch to Thesis database
USE Thesis

-- Create the appropriate tables!

-- (1) Counterparty table
-- Create a new table called 'Counterparty' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.Counterparty', 'U') IS NOT NULL
DROP TABLE dbo.Counterparty
GO
-- Create the table in the specified schema
CREATE TABLE dbo.Counterparty
(
    cp_id INT NOT NULL PRIMARY KEY, -- primary key column
    cp_age INT,
    cp_income [NVARCHAR](50),
    cp_home_ownership [NVARCHAR](50),
    cp_emp_length [NVARCHAR](100),
    cb_person_default_on_file [NVARCHAR](5),
    cb_person_cred_hist_length INT
);
GO

    -- Columns description:
        -- cp_id                        -> unique identifier for the counterparty
        -- cp_age                       -> age
        -- cp_income                    -> annual income (in $)
        -- cp_home_ownership            -> home ownership 
        -- cp_emp_length                -> employment length (in years)
        -- cb_person_default_on_file    -> historical default
        -- cb_person_cred_hist_length   -> credit history length


-- Create a new table called 'Counterparty_loan' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.Counterparty_loan', 'U') IS NOT NULL
DROP TABLE dbo.Counterparty_loan
GO
-- Create the table in the specified schema
CREATE TABLE dbo.Counterparty_loan
(
    loan_id INT NOT NULL PRIMARY KEY, -- primary key column
    loan_intent [NVARCHAR](50),
    loan_grade [NVARCHAR](50),
    loan_amount INT,
    loan_int_rate DECIMAL,
    loan_status [NVARCHAR](50),
    loan_percent_income DECIMAL,
    fk_cp INT NOT NULL FOREIGN KEY REFERENCES Counterparty(cp_id)
);
GO

    -- Columns description:
        -- loan_id                  -> unique identifier for the loans 
        -- loan_intent              -> intent of the cp to get the loan
        -- loan_grade               -> grade 
        -- loan_amount              -> total amount
        -- loan_int_rate            -> interest rate applied
        -- loan_status              -> loan status (0 -> NON-DEFAULT, 1 -> DEFAULT)
        -- loan_percent_income      -> loan-percent-income 
        -- fk_cp                    -> FK to associate each loan to a CP

-- Load the data in the tables

-- Inspecting tables structure
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
GO;

-- Loading counterparties
BULK INSERT dbo.Counterparty
    FROM 'C:\Users\trava\source\repos\bachelor_thesis\03_code\data\counterparty.csv'
    WITH
    (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',  --CSV field delimiter
        ROWTERMINATOR = '\n',   --Use to shift the control to next row
        ERRORFILE = 'C:\Users\trava\OneDrive\Desktop\CounterpartyErrorsRows.csv',
        TABLOCK
    )

-- Loading loans for counterparties
BULK INSERT dbo.Counterparty_loan
    FROM 'C:\Users\trava\source\repos\bachelor_thesis\03_code\data\counterparty_loans.csv'
    WITH
    (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',  --CSV field delimiter
        ROWTERMINATOR = '\n',   --Use to shift the control to next row
        ERRORFILE = 'C:\Users\trava\OneDrive\Desktop\CounterpartyLoansErrorsRows.csv',
        TABLOCK
    )


-- Perform preliminary analysis

-- Inspect first few rows
select top 5 * 
from dbo.Counterparty cp
where (cp.cp_income < 50000) and (cp.cp_age > 25)
order by cp.cp_income desc 

-- Aggregating based on ownership
select cp_home_ownership, count(*) as 'count'
from dbo.Counterparty cp
group by cp.cp_home_ownership
order by 2 desc

-- Join the two tables
select cp.cp_age, cp.cp_income,cp.cb_person_cred_hist_length,cpl.loan_amount
from dbo.Counterparty cp
join dbo.Counterparty_loan cpl 
on cp.cp_id = cpl.fk_cp
where cpl.loan_amount > 20000

-- Randomly selecting people
select top 5 *
from dbo.Counterparty cp 
order by NEWID()

-- See whether there are null values
select * 
from dbo.Counterparty cp
where cp.cp_emp_length is null

-- select @@SERVERNAME