-- ============================================
-- Day 6 Assignment: School Database
-- Compatible with SQLite (sqliteonline.com)
-- ============================================

-- Drop tables if they exist (for clean re-runs)
DROP TABLE IF EXISTS enrolments;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS courses;

-- ============================================
-- CREATE TABLE STATEMENTS
-- ============================================

CREATE TABLE students (
    student_id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name  TEXT NOT NULL,
    email      TEXT NOT NULL UNIQUE,
    enrolled_date DATE NOT NULL DEFAULT (date('now'))
);

CREATE TABLE courses (
    course_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    course_code TEXT NOT NULL UNIQUE,
    title       TEXT NOT NULL,
    credits     INTEGER NOT NULL CHECK (credits > 0)
);

CREATE TABLE enrolments (
    enrolment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id   INTEGER NOT NULL,
    course_id    INTEGER NOT NULL,
    grade        TEXT,
    enrolled_on  DATE NOT NULL DEFAULT (date('now')),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (course_id)  REFERENCES courses(course_id),
    UNIQUE (student_id, course_id)  -- prevents same student enrolling on same course twice
);

-- ============================================
-- INSERT SAMPLE DATA
-- ============================================

-- Students (at least 3)
INSERT INTO students (first_name, last_name, email) VALUES
    ('Alice',   'Johnson',  'alice.johnson@school.edu'),
    ('Bob',     'Smith',    'bob.smith@school.edu'),
    ('Charlie', 'Williams', 'charlie.williams@school.edu'),
    ('Diana',   'Brown',    'diana.brown@school.edu');

-- Courses (at least 3)
INSERT INTO courses (course_code, title, credits) VALUES
    ('CS101', 'Introduction to Computer Science', 3),
    ('MATH201', 'Linear Algebra', 4),
    ('ENG102', 'English Literature', 3),
    ('PHY101', 'Physics Fundamentals', 4);

-- Enrolments (at least 5)
INSERT INTO enrolments (student_id, course_id, grade) VALUES
    (1, 1, 'A'),    -- Alice -> CS101
    (1, 2, 'B+'),   -- Alice -> MATH201
    (2, 1, 'A-'),   -- Bob -> CS101
    (2, 3, 'B'),    -- Bob -> ENG102
    (3, 2, NULL),   -- Charlie -> MATH201 (no grade yet)
    (3, 4, NULL),   -- Charlie -> PHY101 (no grade yet)
    (1, 4, 'A');    -- Alice -> PHY101

-- ============================================
-- QUERY 1: All courses for one student (by name)
-- ============================================
SELECT c.course_code, c.title, c.credits, e.grade
FROM students s
JOIN enrolments e ON s.student_id = e.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.first_name = 'Alice' AND s.last_name = 'Johnson';

-- ============================================
-- QUERY 2: All students on one course
-- ============================================
SELECT s.first_name, s.last_name, s.email, e.grade
FROM courses c
JOIN enrolments e ON c.course_id = e.course_id
JOIN students s ON e.student_id = s.student_id
WHERE c.course_code = 'CS101';

-- ============================================
-- QUERY 3: Number of students per course
-- ============================================
SELECT c.course_code, c.title, COUNT(e.student_id) AS student_count
FROM courses c
LEFT JOIN enrolments e ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.title
ORDER BY student_count DESC;

-- ============================================
-- QUERY 4: Students who have no enrolments
-- ============================================
SELECT s.first_name, s.last_name, s.email
FROM students s
LEFT JOIN enrolments e ON s.student_id = e.student_id
WHERE e.enrolment_id IS NULL;

-- ============================================
-- QUERY 5: Update one enrolment's grade
-- ============================================
UPDATE enrolments
SET grade = 'A-'
WHERE student_id = 3 AND course_id = 2;

-- Verify the update
SELECT s.first_name, s.last_name, c.title, e.grade
FROM enrolments e
JOIN students s ON e.student_id = s.student_id
JOIN courses c ON e.course_id = c.course_id
WHERE s.first_name = 'Charlie' AND c.course_code = 'MATH201';
