# sql_remove_duplicate_data
 SQL- Multiple of ways to remove duplicate data. Here i have used 6 ways of deleting multiple recored from tables.

   <<<<>>>> Scenario 1: Data duplicated based on SOME of the columns <<<<>>>>
 -- Requirement: Delete duplicate data from cars table. Duplicate record is identified based on the model and brand name.
 
1. Delete using Unique identifier.
2. Using SELF join.
3. Using Window function.
4. Using MIN function. This delete even multiple duplicate records.
5. Using backup table.
6. Using backup table without dropping the original table.

<<<<>>>> Scenario 2: Data duplicated based on ALL of the columns <<<<>>>>
-- Requirement: Delete duplicate entry for a car in the CARS table.

1. Delete using CTID / ROWID (in Oracle).
2. By creating a temporary unique id column alter table cars add column row_num int generated always as identity.
3. By creating a backup table.
4. By creating a backup table without dropping the original table.
