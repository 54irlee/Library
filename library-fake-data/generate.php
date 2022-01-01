<?php

require "vendor/autoload.php";

if (count($argv) < 8) {
    echo "Missing args, php generate.php [num_of_branches] [num_of_staff_per_branch] [num_of_members] [num_of_publishers] [num_of_books] [num_of_historic_loans] [num_of_current_loans]";
    exit(1);
}

$faker = \Faker\Factory::create();
$db = new PDO("mysql:host=192.168.0.130;dbname=library_shirlee", "shirlee", "p8C5w3DD54QuRYgnePyC", [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
]);

$numOfBranches = $argv[1];
$numOfStaffPerBranch = $argv[2];
$numOfMembers = $argv[3];
$numOfPublishers = $argv[4];
$numOfBooks = $argv[5];
$numberOfHistoricLoans = $argv[6];
$numberOfCurrentLoans = $argv[7];

echo sprintf(
    "number of branches %s
number of staff per branch %s
number of members %s
number of publishers %s
number of books %s
number of historic loans %s
number of current loans %s\n
",
    number_format($numOfBranches),
    number_format($numOfStaffPerBranch),
    number_format($numOfMembers),
    number_format($numOfPublishers),
    number_format($numOfBooks),
    number_format($numberOfHistoricLoans),
    number_format($numberOfCurrentLoans)
);

echo "Cleaning current data" . PHP_EOL;
$db->query("DELETE FROM staff_working");
$db->query("DELETE FROM members_branches");
$db->query("DELETE FROM branches");
$db->query("DELETE FROM staffs");

echo "Creating $numOfBranches branches, each with $numOfStaffPerBranch staff members" . PHP_EOL;
$staffBranchIds = [];
for ($i = 1; $i <= $numOfBranches; $i++) {
    $branchName = $faker->company;
    echo "\tBranch $branchName" . PHP_EOL;
    $branchStmt = $db->prepare(
        "INSERT INTO branches (name, address1, town, postcode, phone_number) VALUES (:name, :address1, :town, :postcode, :phone_number)"
    );
    $branchStmt->bindValue("name", $branchName);
    $branchStmt->bindValue("address1", $faker->streetAddress);
    $branchStmt->bindValue("town", $faker->city);
    $branchStmt->bindValue("postcode", $faker->postcode);
    $branchStmt->bindValue("phone_number", $faker->numerify("01#########"));
    $branchStmt->execute();
    $branchId = $db->lastInsertId();
    $staffBranchIds[$branchId] = [];

    $staffIds = [];
    for ($l = 1; $l <= $numOfStaffPerBranch; $l++) {
        $staffStmt = $db->prepare(
            "INSERT INTO staffs (designation, first_name, middle_name, last_name, start_date) values (:designation, :first_name, :middle_name, :last_name, :start_date);"
        );
        $staffStmt->bindValue("designation", $faker->boolean(10) ? "manager" : "staff", PDO::PARAM_STR);
        $staffStmt->bindValue("first_name", $faker->firstName, PDO::PARAM_STR);
        $staffStmt->bindValue("middle_name", $faker->boolean(30) ? $faker->firstName : null, PDO::PARAM_STR);
        $staffStmt->bindValue("last_name", $faker->lastName);
        $staffStmt->bindValue("start_date", $faker->dateTimeBetween->format("Y-m-d"), PDO::PARAM_STR);
        $staffStmt->execute();

        $staffBranchIds[$branchId][] = $db->lastInsertId();
    }

    foreach ($staffBranchIds[$branchId] as $staffId) {
        $staffWorkingStmt = $db->prepare(
            "INSERT INTO staff_working (staff_id, branch_id) VALUES (:staff_id, :branch_id)"
        );
        $staffWorkingStmt->bindValue("staff_id", $staffId);
        $staffWorkingStmt->bindValue("branch_id", $branchId);
        $staffWorkingStmt->execute();
    }
}

$db->query("DELETE FROM members");
echo "Creating $numOfMembers members" . PHP_EOL;
$branchMemberIds = [];
for ($i = 1; $i <= $numOfMembers; $i++) {
    $memberStmt = $db->prepare(
        "INSERT INTO members (first_name, middle_name, last_name, address_line1, town, postcode, phone_number, member_since) VALUES (:first_name, :middle_name, :last_name, :address_line1, :town, :postcode, :phone_number, :member_since)"
    );
    $memberStmt->bindValue("first_name", $faker->firstName, PDO::PARAM_STR);
    $memberStmt->bindValue("middle_name", $faker->boolean(30) ? $faker->firstName : null, PDO::PARAM_STR);
    $memberStmt->bindValue("last_name", $faker->firstName, PDO::PARAM_STR);
    $memberStmt->bindValue("address_line1", $faker->streetAddress, PDO::PARAM_STR);
    $memberStmt->bindValue("town", $faker->city, PDO::PARAM_STR);
    $memberStmt->bindValue("postcode", $faker->postcode, PDO::PARAM_STR);
    $memberStmt->bindValue("phone_number", $faker->numerify("07########"));
    $memberStmt->bindValue("member_since", $faker->dateTimeBetween->format("Y-m-d"));
    $memberStmt->execute();

    $memberId = $db->lastInsertId();

    $numOfMemberBranches = $faker->numberBetween(1, 3);

    $usedBranchIds = [];
    for ($l = 0; $l < $numOfMemberBranches; $l++) {
        $memberBranchStmt = $db->prepare(
            "INSERT INTO members_branches (member_id, branch_id) VALUES (:member_id, :branch_id)"
        );

        do {
            $branchId = $faker->randomElement(array_keys($staffBranchIds));
        } while (in_array($branchId, $usedBranchIds));
        $usedBranchIds[] = $branchId;

        $memberBranchStmt->bindValue("member_id", $memberId);
        $memberBranchStmt->bindValue("branch_id", $branchId);
        $memberBranchStmt->execute();

        $branchMemberIds[$branchId][] = $memberId;
    }
}

$db->query("DELETE FROM book_genre");
$db->query("DELETE FROM genres");
$genres = json_decode(file_get_contents(__DIR__ . "/genres.json"), true, 512, JSON_THROW_ON_ERROR);
echo sprintf("Creating %d genres", count($genres)) . PHP_EOL;
$genreIds = [];
foreach ($genres as $genre) {
    echo "\tGenre {$genre["name"]}" . PHP_EOL;
    $genreStmt = $db->prepare("INSERT INTO genres (id, name) VALUES (:id, :name)");
    $genreStmt->bindValue("id", $genre["id"]);
    $genreStmt->bindValue("name", $genre["name"], PDO::PARAM_STR);
    $genreStmt->execute();
    $genreIds[] = $genre["id"];
}

$db->query("DELETE FROM books_publishers_link");
$db->query("DELETE FROM publishers");
echo "Creating $numOfPublishers publishers" . PHP_EOL;
$publisherIds = [];
for ($i = 0; $i < $numOfPublishers; $i++) {
    $publisherName = $faker->company;
    echo "\tPublisher $publisherName" . PHP_EOL;
    $publisherStmt = $db->prepare("INSERT INTO publishers (name) VALUES (:name)");
    $publisherStmt->bindValue("name", $publisherName, PDO::PARAM_STR);
    $publisherStmt->execute();
    $publisherIds[] = $db->lastInsertId();
}

$db->query("DELETE FROM book_shelf_link");
$db->query("DELETE FROM shelf");
echo "Creating shelves" . PHP_EOL;
$branchShelfIds = [];
foreach ($staffBranchIds as $branchId => $_) {
    $branchShelfIds[$branchId] = [];
    $numFloors = $faker->numberBetween(1, 5);
    echo "\tBranch $branchId has $numFloors floors" . PHP_EOL;
    for ($i = 0; $i < $numFloors; $i++) {
        $floorNum = $i + 1;
        $numShelves = $faker->numberBetween(5, 20);
        echo "\t\tBranch $branchId floor $floorNum has $numShelves shelves" . PHP_EOL;
        for ($l = 0; $l < $numShelves; $l++) {
            $sectionNum = $l + 1;
            $shelfStmt = $db->prepare(
                "INSERT INTO shelf (floor, section, branch_id) VALUES (:floor, :section, :branch_id)"
            );
            $shelfStmt->bindValue("floor", sprintf("Floor_%d", $floorNum), PDO::PARAM_STR);
            $shelfStmt->bindValue("section", sprintf("Section_%d", $sectionNum), PDO::PARAM_STR);
            $shelfStmt->bindValue("branch_id", $branchId);
            $shelfStmt->execute();

            $branchShelfIds[$branchId][] = $db->lastInsertId();
        }
    }
}

$db->query("DELETE FROM books");
echo "Creating $numOfBooks books" . PHP_EOL;
$bookIds = [];
for ($i = 0; $i < $numOfBooks; $i++) {
    $numOfActualCopies = $faker->numberBetween(1, 20);
    $bookStmt = $db->prepare(
        "INSERT INTO books (title, isbn, author_name, category, year, no_of_actual_copies, no_of_current_available_copies) VALUES (:title, :isbn, :author_name, :category, :year, :no_of_actual_copies, :no_of_current_available_copies)"
    );
    $bookStmt->bindValue("title", $faker->slug, PDO::PARAM_STR);
    $bookStmt->bindValue("isbn", $faker->isbn10(), PDO::PARAM_STR);
    $bookStmt->bindValue("author_name", $faker->name, PDO::PARAM_STR);
    $bookStmt->bindValue("category", $faker->randomElement(["fiction", "non-fiction"]), PDO::PARAM_STR);
    $bookStmt->bindValue("year", $faker->year);
    $bookStmt->bindValue("no_of_actual_copies", $numOfActualCopies);
    $bookStmt->bindValue("no_of_current_available_copies", $faker->numberBetween(1, $numOfActualCopies));
    $bookStmt->execute();

    $bookIds[] = $db->lastInsertId();
}

echo "Linking books to shelves and genres" . PHP_EOL;
$branchIds = array_keys($staffBranchIds);
$shelfBookIds = [];
foreach ($bookIds as $bookId) {
    $branchId = $faker->randomElement($branchIds);
    $shelfId = $faker->randomElement($branchShelfIds[$branchId]);

    $bookShelfStmt = $db->prepare("INSERT INTO book_shelf_link (book_id, shelf_id) VALUES (:book_id, :shelf_id)");
    $bookShelfStmt->bindValue("book_id", $bookId);
    $bookShelfStmt->bindValue("shelf_id", $shelfId);
    $bookShelfStmt->execute();

    if (!isset($shelfBookIds[$shelfId])) {
        $shelfBookIds[$shelfId] = [];
    }
    $shelfBookIds[$shelfId][] = $bookId;

    $numOfGenres = $faker->numberBetween(1, 3);
    $usedGenres = [];
    for ($i = 0; $i < $numOfGenres; $i++) {
        $bookGenreStmt = $db->prepare("INSERT INTO book_genre (book_id, genre_id) VALUES (:book_id, :genre_id)");
        $bookGenreStmt->bindValue("book_id", $bookId);

        do {
            $genreId = $faker->randomElement($genreIds);
        } while (in_array($genreId, $usedGenres));
        $usedGenres[] = $genreId;

        $bookGenreStmt->bindValue("genre_id", $genreId);
        $bookGenreStmt->execute();
    }

    $numOfBookPublishers = $faker->boolean(5) ? 2 : 1;
    $usedPublishers = [];
    for ($i = 0; $i < $numOfBookPublishers; $i++) {
        $publisherBookStmt = $db->prepare(
            "INSERT INTO books_publishers_link (book_id, publisher_id) VALUES (:book_id, :publisher_id)"
        );
        $publisherBookStmt->bindValue("book_id", $bookId);

        do {
            $publisherId = $faker->randomElement($publisherIds);
        } while (in_array($publisherId, $usedPublishers));
        $usedPublishers[] = $publisherId;
        $publisherBookStmt->bindValue("publisher_id", $publisherId);
        $publisherBookStmt->execute();
    }
}

$db->query("DELETE FROM loans_history");
echo "Creating $numberOfHistoricLoans historic loans" . PHP_EOL;
for ($i = 0; $i < $numberOfHistoricLoans; $i++) {
    $branchId = $faker->randomElement($branchIds);
    $shelfId = $faker->randomElement($branchShelfIds[$branchId]);
    $bookId = $faker->randomElement($shelfBookIds[$shelfId]);
    $memberId = $faker->randomElement($branchMemberIds[$branchId]);
    $loanStaffId = $faker->randomElement($staffBranchIds[$branchId]);
    $returnStaffId = $faker->randomElement($staffBranchIds[$branchId]);

    $loanDate = $faker->dateTimeBetween;
    $loanDays = DateInterval::createFromDateString($faker->numberBetween(1, 360) . " day");
    $returnDate = clone $loanDate;
    $returnDate = $returnDate->add($loanDays);

    $historicLoanStmt = $db->prepare(
        "INSERT INTO loans_history (member_id, book_id, loan_staff_id, loan_date, return_date, return_staff_id) VALUES (:member_id, :book_id, :loan_staff_id, :loan_date, :return_date, :return_staff_id)"
    );
    $historicLoanStmt->bindValue("member_id", $memberId);
    $historicLoanStmt->bindValue("book_id", $bookId);
    $historicLoanStmt->bindValue("loan_staff_id", $loanStaffId);
    $historicLoanStmt->bindValue("loan_date", $loanDate->format("Y-m-d"), PDO::PARAM_STR);
    $historicLoanStmt->bindValue("return_date", $returnDate->format("Y-m-d"), PDO::PARAM_STR);
    $historicLoanStmt->bindValue("return_staff_id", $returnStaffId);
    $historicLoanStmt->execute();
}

$db->query("DELETE FROM current_loans");
echo "Creating $numberOfCurrentLoans current loans" . PHP_EOL;
for ($i = 0; $i < $numberOfCurrentLoans; $i++) {
    $branchId = $faker->randomElement($branchIds);
    $shelfId = $faker->randomElement($branchShelfIds[$branchId]);
    $bookId = $faker->randomElement($shelfBookIds[$shelfId]);
    $memberId = $faker->randomElement($branchMemberIds[$branchId]);
    $loanStaffId = $faker->randomElement($staffBranchIds[$branchId]);

    $loanDate = $faker->dateTimeBetween("-1 years");
    $loanDays = DateInterval::createFromDateString($faker->numberBetween(30, 60) . " day");
    $returnDate = clone $loanDate;
    $returnDate = $returnDate->add($loanDays);

    $currentLoanStmt = $db->prepare(
        "INSERT INTO current_loans (member_id, book_id, staff_id, loan_date, return_date, outstanding_payment) VALUES (:member_id, :book_id, :staff_id, :loan_date, :return_date, :outstanding_payment)"
    );
    $currentLoanStmt->bindValue("member_id", $memberId);
    $currentLoanStmt->bindValue("book_id", $bookId);
    $currentLoanStmt->bindValue("staff_id", $loanStaffId);
    $currentLoanStmt->bindValue("loan_date", $loanDate->format("Y-m-d"), PDO::PARAM_STR);
    $currentLoanStmt->bindValue("return_date", $returnDate->format("Y-m-d"), PDO::PARAM_STR);
    $currentLoanStmt->bindValue("outstanding_payment", $faker->randomFloat(2, 0, 10));
    $currentLoanStmt->execute();
}
