SELECT branches.name AS branch_name, COUNT(books.no_of_actual_copies) AS total_of_books
FROM branches
INNER JOIN shelf
ON branches.id = shelf.branch_id
INNER JOIN book_shelf_link
ON shelf.id = book_shelf_link.shelf_id
INNER JOIN books
ON books.id = book_shelf_link.book_id
GROUP BY branches.name
ORDER BY branches.name;