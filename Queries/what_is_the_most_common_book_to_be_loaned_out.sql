SELECT books.title, ROUND((COUNT(current_loans.book_id) + COUNT(loans_history.book_id))) AS Most_loaned_book
FROM books
LEFT JOIN current_loans
ON books.id = current_loans.book_id
LEFT JOIN loans_history
ON books.id = loans_history.book_id
GROUP BY books.title
ORDER BY ROUND((COUNT(current_loans.book_id) + COUNT(loans_history.book_id))) DESC
LIMIT 10;