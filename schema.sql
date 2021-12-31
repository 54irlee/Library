CREATE TABLE staffs (
    staff_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    designation VARCHAR(50) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    start_date DATE
    );

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    book_title VARCHAR(100) NOT NULL,
    isbn VARCHAR(50) NOT NULL,
    author_name VARCHAR(50) NOT NULL,
    category VARCHAR(50) NOT NULL
    );

CREATE TABLE books_publisher (
    book_id INTEGER,
    publisher_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    publisher VARCHAR(50) NOT NULL,
    publish_year VARCHAR(50) NOT NULL,
    no_of_actual_copies INTEGER,
    no_of_available_copies INTEGER,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
    );

CREATE TABLE genre(
    genre_id INTEGER PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL
    );

CREATE TABLE book_genre(
    book_id INTEGER,
    genre_id INTEGER,
    PRIMARY KEY (book_id, genre_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id) ON DELETE CASCADE
    );

CREATE TABLE shelf_table(
    id INTEGER UNIQUE PRIMARY KEY,
    floor VARCHAR(50),
    section VARCHAR(50),
    branch_id INTEGER
    );

CREATE TABLE book_shelf_link (
    book_id INTEGER,
    shelf_id INTEGER
    );

CREATE TABLE members(
    member_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    last_name VARCHAR(50) NOT NULL,
    address_line1 VARCHAR(50) NOT NULL,
    address_line2 VARCHAR(50),
    town VARCHAR(50) NOT NULL,
    postcode VARCHAR(50) NOT NULL,
    phone_number INTEGER NOT NULL,
    member_since DATE NOT NULL
    );

CREATE TABLE current_loan(
    member_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    staff_id INTEGER NOT NULL,
    loan_date DATE NOT NULL,
    return_date DATE NOT NULL,
    status VARCHAR(50) NOT NULL,
    outstanding_payment DECIMAL (10,2),
    PRIMARY KEY (member_id,book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
    );

CREATE TABLE loan_history(
    member_id INTEGER,
    book_id INTEGER,
    staff_id INTEGER,
    loan_date DATE,
    return_date DATE,
    PRIMARY KEY (member_id, book_id, staff_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    FOREIGN KEY (staff_id) REFERENCES staffs(staff_id) ON DELETE CASCADE
    );

CREATE TABLE branches(
    branch_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    branch_name VARCHAR(50) NOT NULL,
    branch_address1 VARCHAR(50) NOT NULL,
    branch_address2 VARCHAR(50),
    town VARCHAR(50) NOT NULL,
    postcode VARCHAR(50) NOT NULL,
    phone_number INTEGER NOT NULL
    );

CREATE TABLE staff_working(
    staff_id INTEGER,
    branch_id INTEGER,
    PRIMARY KEY (staff_id,branch_id),
    FOREIGN KEY (staff_id) REFERENCES staffs(staff_id) ON DELETE CASCADE,
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id) ON DELETE CASCADE
    );

ALTER TABLE shelf_table
ADD FOREIGN KEY (branch_id)
REFERENCES branches(branch_id) ON DELETE SET NULL;

ALTER TABLE book_shelf_link
ADD FOREIGN KEY (book_id)
REFERENCES books(book_id) ON DELETE SET NULL;

ALTER TABLE book_shelf_link
ADD FOREIGN KEY (shelf_id)
REFERENCES shelf_table(id) ON DELETE SET NULL;

CREATE TABLE members_branches (
    member_id INTEGER,
    branch_id INTEGER,
    PRIMARY KEY (member_id,branch_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
    );

CREATE TABLE books_publishers_link (
    book_id INTEGER,
    publisher_id INTEGER,
    PRIMARY KEY (book_id, publisher_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (publisher_id) REFERENCES books_publisher(publisher_id)
    );

ALTER TABLE branches RENAME COLUMN branch_id TO id;

ALTER TABLE branches RENAME COLUMN branch_name TO name;

ALTER TABLE branches RENAME COLUMN branch_address1 TO address1;

ALTER TABLE branches RENAME COLUMN branch_address2 TO address2;

ALTER TABLE genre RENAME COLUMN genre_id to id;

ALTER TABLE books RENAME COLUMN book_id TO id;

ALTER TABLE books RENAME COLUMN book_title TO title;

ALTER TABLE members RENAME COLUMN member_id to id;

ALTER TABLE staffs RENAME COLUMN staff_id TO id;

ALTER TABLE books_publisher RENAME COLUMN publisher_id to id;

ALTER TABLE publishers RENAME COLUMN publish_year to year;

RENAME TABLE books_publisher TO publishers;

RENAME TABLE genre TO genres;

ALTER TABLE current_loan DROP COLUMN status;

RENAME TABLE shelf_table to shelf;

ALTER TABLE current_loan
ADD FOREIGN KEY (staff_id)
REFERENCES staffs(id) ON DELETE CASCADE;

ALTER TABLE loan_history RENAME COLUMN staff_id TO loan_staff_id;

ALTER TABLE loan_history
ADD COLUMN return_staff_id INTEGER NOT NULL,
ADD FOREIGN KEY (return_staff_id) REFERENCES staffs(id) ON DELETE CASCADE;

RENAME TABLE current_loan TO current_loans;

RENAME TABLE loan_history to loans_history;

ALTER TABLE publishers
DROP COLUMN year;

ALTER TABLE publishers
DROP COLUMN no_of_actual_copies;

ALTER TABLE publishers
DROP COLUMN no_of_available_copies;

ALTER TABLE books
ADD year VARCHAR(50);

ALTER TABLE books
ADD no_of_actual_copies INTEGER;

ALTER TABLE books
ADD no_of_current_available_copies INTEGER;

ALTER TABLE publishers
DROP FOREIGN KEY publishers_ibfk_1;

ALTER TABLE publishers
DROP COLUMN book_id;

ALTER TABLE publishers
RENAME COLUMN publisher TO name;

ALTER TABLE book_shelf_link
DROP FOREIGN KEY book_shelf_link_ibfk_2;

ALTER TABLE shelf
MODIFY COLUMN id INTEGER NOT NULL AUTO_INCREMENT;

ALTER TABLE book_shelf_link
ADD FOREIGN KEY (shelf_id) REFERENCES shelf(id);

SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE loans_history
DROP PRIMARY KEY ;
SET FOREIGN_KEY_CHECKS=1;

ALTER TABLE loans_history
ADD COLUMN id INTEGER NOT NULL AUTO_INCREMENT PRIMARY KEY;

ALTER TABLE loans_history
ADD FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE;

ALTER TABLE loans_history
ADD FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE;

ALTER TABLE loans_history
ADD FOREIGN KEY (loan_staff_id) REFERENCES staffs(id) ON DELETE CASCADE;

ALTER TABLE genres
RENAME COLUMN genre_name TO name;