SELECT books.title, genres.name AS most_loaned_genre, ROUND((COUNT(current_loans.book_id) + COUNT(loans_history.book_id)))
FROM books
LEFT JOIN book_genre
ON books.id = book_genre.book_id
LEFT JOIN genres
ON book_genre.genre_id = genres.id
LEFT JOIN current_loans
ON books.id = current_loans.book_id
LEFT JOIN loans_history
ON books.id = loans_history.book_id
GROUP BY books.title
ORDER BY ROUND((COUNT(current_loans.book_id) + COUNT(loans_history.book_id))) DESC
LIMIT 10;