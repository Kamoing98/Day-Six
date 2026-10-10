# School Database Design

## Table Descriptions

### students
Stores information about each student in the system. Each student has a unique ID (auto-incremented), a first name, last name, and a unique email address that serves as their identifier for communications. The `enrolled_date` tracks when they joined the school.

### courses
Represents the catalogue of courses available at the school. Each course has a unique course code (e.g., "CS101"), a descriptive title, and a credit value indicating how much the course is worth toward a degree.

### enrolments
This is the **join table** that records the relationship between students and courses. It holds the student ID, course ID, the grade achieved (nullable since a student may still be taking the course), and the date they enrolled. The `UNIQUE(student_id, course_id)` constraint ensures a student cannot enrol in the same course more than once.

## Relationships

- **Students to Enrolments: One-to-Many** — One student can have many enrolments (they take multiple courses), but each enrolment belongs to exactly one student.
- **Courses to Enrolments: One-to-Many** — One course can have many enrolments (many students take it), but each enrolment is for exactly one course.
- **Students to Courses: Many-to-Many** — A student can take many courses, and a course can have many students. This many-to-many relationship **requires a join table** (`enrolments`) because relational databases cannot directly represent many-to-many relationships. The join table also holds additional data about the relationship itself (the grade and enrolment date), which would have nowhere to live if we tried to put foreign keys directly in the students or courses tables.

## Suggested Index

```sql
CREATE INDEX idx_enrolments_student_id ON enrolments(student_id);
```

**Reason:** The most common queries will look up all enrolments for a given student (e.g., "show me all of Alice's courses") or all enrolments for a given course (e.g., "show me all students in CS101"). Adding an index on `student_id` in the `enrolments` table speeds up these JOIN and WHERE lookups significantly as the table grows. Without it, the database would need to scan every row in the enrolments table to find matches. A similar index on `course_id` would also be beneficial, but `student_id` is chosen first because student-lookup queries tend to be more frequent in a school management context (student portals, transcript generation, etc.).

## SQL vs NoSQL

For this school enrolment system, **SQL is the clear choice**. The data is highly structured with well-defined entities (students, courses, enrolments) and strict relationships between them. We need referential integrity — a student cannot enrol in a non-existent course, and we must prevent duplicate enrolments — which SQL enforces naturally through foreign keys and unique constraints. The queries we need (JOINs across students and courses, GROUP BY for counting students per course, finding students with no enrolments) are exactly what relational databases excel at. A NoSQL database (like MongoDB) would require us to either duplicate data across documents or perform expensive application-level joins, and it would offer no built-in way to enforce that a student can't enrol twice in the same course. The data volume for a school system is moderate and predictable, so there is no scaling advantage to justify the loss of ACID guarantees and schema enforcement that NoSQL would bring. SQL provides the consistency, integrity, and query flexibility this system demands.
