# Samples queries for the DBMS of a dental practice

## Query 1
**Link** : https://livesql.oracle.com/apex/livesql/s/lfxtuorap4wsqhcyetclbp3vx
Note that `AVG_PROCEDURE_DURATION` is in minutes and `AVG_PROCEDURE_COST` is in dollars. Assume that each visit is for a procedure with a fixed overall price - not a bad assumption since hospital charges you even for things you don't use - and you will only find out if you ask for an itemized billing! Also, the averages are given for the entire time range for all procedures, as well as grouped by procedures since the question was vague.

## Query 2
**Link** : https://livesql.oracle.com/apex/livesql/s/lfxtrplsv8zo75q0v6ps8sey3
Note that `SUM_PROCEDURE_COST` is in dollars and the income is calculated as billable service, regardless whether the patient has paid for it or not. For multiple days, simply specify date range in Statement 18 and the query will group by `visit_date`!

## Query 3
**Link** : https://livesql.oracle.com/apex/livesql/s/lfxyjik1mfquvaiqrfdhbx02o
Note that `Capabilities` has only two foreign keys `employee_id` and `skill_id`. The list of tasks is given as a table/list and we check the database for staff that has ALL the skills in the list.

## Query 4
**Link** : https://livesql.oracle.com/apex/livesql/s/lfxolppf5cdypu34kiu6mx0lu
We select patients that have unpaid bills from 2020 and the years before. Patients that have settled their bills are not selected. The amount owed (i.e. `debt`) is also calculated and listed.