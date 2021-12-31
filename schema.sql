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
