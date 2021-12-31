SELECT ROUND(AVG(DATEDIFF(return_date,loan_date))) AS average_loan_period
FROM loans_history;