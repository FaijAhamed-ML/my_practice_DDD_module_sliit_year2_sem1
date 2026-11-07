CREATE DATABASE LibraryDB;
GO
USE LibraryDB;
GO

-- 1. Create Tables
CREATE TABLE Book (
    bookId INT PRIMARY KEY,
    title VARCHAR(100),
    author VARCHAR(100),
    isbn VARCHAR(20),
    publicationYear INT,
    genre VARCHAR(50),
    availableCopies INT
);

CREATE TABLE Member (
    memberId INT PRIMARY KEY,
    firstName VARCHAR(50),
    lastName VARCHAR(50),
    email VARCHAR(50),
    phone INT,
    address VARCHAR(100)
);

CREATE TABLE Loan (
    loanId INT PRIMARY KEY,
    bookId INT FOREIGN KEY REFERENCES Book(bookId),
    memberId INT FOREIGN KEY REFERENCES Member(memberId),
    loanDate DATE,
    dueDate DATE,
    returnDate DATE -- NULL means the book is currently on loan
);

CREATE TABLE Fine (
    fineId INT PRIMARY KEY,
    memberId INT FOREIGN KEY REFERENCES Member(memberId),
    amount REAL,
    paymentStatus VARCHAR(50) -- e.g., 'Overdue', 'Partial', 'Paid', 'Unpaid'
);

CREATE TABLE Librarian (
    librarianId INT PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(50),
    phone INT,
    address VARCHAR(100)
);
GO

-- 2. Insert Dummy Data
INSERT INTO Book VALUES 
(1, 'The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 1925, 'Classic', 3),
(2, '1984', 'George Orwell', '9780451524935', 1949, 'Dystopian', 5),
(3, 'To Kill a Mockingbird', 'Harper Lee', '9780061120084', 1960, 'Classic', 2),
(4, 'The Hobbit', 'J.R.R. Tolkien', '9780547928227', 1937, 'Fantasy', 4);

INSERT INTO Member VALUES 
(101, 'Kasun', 'Perera', 'kasun@email.com', 771234567, '123 Galle Rd, Colombo'),
(102, 'Nimali', 'Silva', 'nimali@email.com', 712345678, '45 Kandy Rd, Malabe'),
(103, 'Ruwan', 'Fernando', 'ruwan@email.com', 763456789, '78 Main St, Negombo');

-- Note: NULL returnDate indicates the book has not been returned yet (currently on loan)
INSERT INTO Loan VALUES 
(1001, 1, 101, '2026-01-10', '2026-01-24', '2026-01-20'), -- Returned
(1002, 2, 102, '2026-02-01', '2026-02-15', NULL),         -- Currently on loan
(1003, 1, 103, '2026-02-05', '2026-02-19', NULL),         -- Currently on loan ('The Great Gatsby')
(1004, 3, 101, '2026-02-10', '2026-02-24', NULL);         -- Currently on loan

INSERT INTO Fine VALUES 
(501, 101, 200.0, 'Overdue'),
(502, 101, 100.0, 'Partial'),
(503, 102, 500.0, 'Overdue'),
(504, 102, 300.0, 'Unpaid'),
(505, 103, 150.0, 'Paid');

INSERT INTO Librarian VALUES 
(1, 'Sunil Jayasinghe', 'sunil@library.com', 112233445, '10 Park St, Colombo');
GO

select * from Librarian;
select * from Loan;
select * from Fine;
select * from Member;
select * from Book;


--i. Find the member’s name and phone number who borrowed a book with the title 'The Great Gatsby'.
SELECT M.firstName, M.lastName, M.phone
FROM Member M INNER JOIN Loan L ON M.memberId = L.memberId INNER JOIN Book B ON L.bookId = B.bookId
WHERE B.title = 'The Great Gatsby';

--ii. Find the member who has the highest total amount of fines than all the other total fine amounts. Find the member’s id and address.
SELECT M.memberId, M.address
FROM Member M
INNER JOIN Fine F ON M.memberId = F.memberId
GROUP BY M.memberId, M.address
HAVING SUM(F.amount) >= ALL (
    SELECT SUM(amount) 
    FROM Fine 
    GROUP BY memberId
);

--iii. Find the book titles, authors, and member names of books currently on loan.
SELECT B.title, B.author, M.firstName, M.lastName FROM Book B INNER JOIN Loan L ON B.bookId=L.bookId INNER JOIN Member M ON M.memberId=L.memberId WHERE L.returnDate IS NULL;

--b) Create a function to calculate the total fine amount for a given member. This function should
--account for fines with a late penalty of 10% applied to those marked as 'overdue' payment status.

CREATE FUNCTION calcTotalFinalAmount (@member int)
returns real as
begin 
    DECLARE @AMOUNTFINAL real;
    select @AMOUNTFINAL = SUM(
        CASE 
            WHEN F.paymentStatus = 'Overdue' THEN F.amount * 1.10 
            ELSE F.amount 
        END
    )
    FROM Fine F where F.memberId=@member;

    RETURN @AMOUNTFINAL;
end;

calcTotalFinalAmount '101';

--c) Create a trigger that automatically updates the 'TotalFineAmount' column in the 'Members' table
-- whenever a new fine is added, or an existing fine is updated. The 'TotalFineAmount' column
-- should contain the total fine amount for each member. Ensure the trigger adjusts the
-- 'TotalFineAmount' column accurately to reflect any partial payments made by members. The
-- member pays only 50% of the total fine amount as an initial payment when the payment status is
-- marked as ‘Partial’.

ALTER TABLE Member
ADD TotalFineAmount REAL DEFAULT 0;

CREATE TRIGGER trg_UpdateMemberTotalFine
ON Fine
AFTER INSERT, UPDATE AS
BEGIN
    UPDATE M SET M.TotalFineAmount = ISNULL((
        SELECT SUM(
            CASE 
                WHEN F.paymentStatus = 'Partial' THEN F.amount * 0.50
                WHEN F.paymentStatus = 'Paid' THEN 0
                ELSE F.amount
            END
        )
        FROM Fine F
        WHERE F.memberId = M.memberId
    ), 0)
    FROM Member M
    INNER JOIN (
        SELECT DISTINCT memberId FROM inserted
    ) I ON M.memberId = I.memberId;
END;

UPDATE Fine 
SET paymentStatus = 'Partial' 
WHERE fineId = 504;

SELECT memberId, firstName, TotalFineAmount 
FROM Member;