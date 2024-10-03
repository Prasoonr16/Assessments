-- Tasks:

-- 1. Provide a SQL script that initializes the database for the Job Board scenario “CareerHub”.

if not exists (select * from sys.databases where name = 'CareerHub')
begin
    create database CareerHub;
end;

use CareerHub;

-- 2. Create tables for Companies, Jobs, Applicants and Applications
-- 3. Define appropriate primary keys, foreign keys, and constraints. 
-- 4. Ensure the script handles potential errors, such as if the database or tables already exis

-- Queries no. 2,3,4 are solved in the below queries :

-- 1. Companies Table
if not exists (select * from sys.objects where object_id = OBJECT_ID(N'dbo.Companies') and type = N'U')
begin
	create table Companies(
		CompanyID int identity(1,1) primary key,
		CompanyName varchar(100),
		Location varchar(100) 
	);
end;

-- 2. Jobs Table
if not exists (select * from sys.objects where object_id = OBJECT_ID(N'dbo.Jobs') and type = N'U')
begin
	create table Jobs (
		JobID int identity(1,1) primary key,
		CompanyID int ,
    	JobTitle varchar(100),
		JobDescription text, 
		JobLocation varchar(100),
		Salary decimal(10, 2),
		JobType varchar(50),
		PostedDate datetime default CURRENT_TIMESTAMP,
		foreign key (CompanyID) references Companies(CompanyID)
	);
end;

-- 3. Applicants Table
if not exists (select * from sys.objects where object_id = OBJECT_ID(N'dbo.Applicants') and type = N'U')
begin
	create table Applicants (
		ApplicantID int identity(1,1) primary key,
		FirstName varchar(50),
		LastName varchar(50),
		Email varchar(100) unique,
		Phone varchar(20),
		Resume text
	);
end;

-- 4. Applications Table
if not exists (select * from sys.objects where object_id = OBJECT_ID(N'dbo.Applications') and type = N'U')
begin
	create table Applications (
		ApplicationID int identity(1,1) primary key,
		JobID int,
		ApplicantID int,
		ApplicationDate datetime default current_timestamp,
		CoverLetter text,
		foreign key (JobID) references Jobs(JobID),
		foreign key (ApplicantID) references Applicants(ApplicantID)
	);
end;

-- Insert data into Jobs table
insert into Companies (CompanyName, Location) 
values 
('TechCorp', 'San Francisco'),
('InnovateX', 'New York'),
('Green Energy Solutions', 'Seattle'),
('FinTech Hub', 'Chicago'),
('HealthCare Plus', 'Boston');

-- Insert data into Jobs table
INSERT INTO Jobs (CompanyID, JobTitle, JobDescription, JobLocation, Salary, JobType, PostedDate) 
VALUES
(1, 'Software Engineer', 'Develop and maintain web applications.', 'San Francisco', 90000, 'Full-time', '2024-09-20'),
(2, 'Data Analyst', 'Analyze business data to extract insights.', 'New York', 70000, 'Full-time', '2024-09-25'),
(3, 'Project Manager', 'Manage team and project deliverables.', 'Seattle', 85000, 'Full-time', '2024-09-28'),
(4, 'UX Designer', 'Design and improve user interfaces.', 'Chicago', 75000, 'Contract', '2024-10-01'),
(5, 'DevOps Engineer', 'Build and maintain CI/CD pipelines.', 'Boston', 95000, 'Full-time', '2024-08-30');

-- Insert data into Applicants table
INSERT INTO Applicants (FirstName, LastName, Email, Phone, Resume) 
VALUES
('John', 'Doe', 'john.doe@example.com', '1234567890', 'John Doe Resume'),
('Jane', 'Smith', 'jane.smith@example.com', '2345678901', 'Jane Smith Resume'),
('Michael', 'Brown', 'michael.brown@example.com', '3456789012', 'Michael Brown Resume'),
('Emily', 'Davis', 'emily.davis@example.com', '4567890123', 'Emily Davis Resume'),
('Daniel', 'Wilson', 'daniel.wilson@example.com', '5678901234', 'Daniel Wilson Resume');

-- Insert data into Applications table
INSERT INTO Applications (JobID, ApplicantID, ApplicationDate, CoverLetter) 
VALUES
(1, 1, '2024-09-20', 'Cover letter for Software Engineer position.'),
(2, 2, '2024-09-26', 'Cover letter for Data Analyst position.'),
(3, 3, '2024-09-30', 'Cover letter for Project Manager position.'),
(4, 4, '2024-10-01', 'Cover letter for UX Designer position.'),
(5, 5, '2024-09-01', 'Cover letter for DevOps Engineer position.');

-- 5. Write an SQL query to count the number of applications received for each job listing in the 
--    "Jobs" table. Display the job title and the corresponding application count. Ensure that it lists all 
--    jobs, even if they have no applications.

select j.JobTitle, COUNT(a.ApplicationID) as ApplicationCount
from Jobs j
left join Applications a
on j.JobID = a.ApplicationID
group by j.JobTitle;

-- 6. Develop an SQL query that retrieves job listings from the "Jobs" table within a specified salary 
--	  range. Allow parameters for the minimum and maximum salary values. Display the job title, 
--	  company name, location, and salary for each matching job.

select j.JobTitle, c.CompanyName, j.JobLocation, j.Salary
from Jobs j
join Companies c on j.CompanyID = c.CompanyID
where j.Salary between 50000.00 and 100000.00;

--7. Write an SQL query that retrieves the job application history for a specific applicant. Allow a 
--   parameter for the ApplicantID, and return a result set with the job titles, company names, and 
--   application dates for all the jobs the applicant has applied to.

select j.JobTitle, c.CompanyName, a.ApplicationDate
from Applications a
join Jobs j on a.JobID = j.JobID
join Companies c on j.CompanyID = c.CompanyID
where a.ApplicantID = 2;

--8. Create an SQL query that calculates and displays the average salary offered by all companies for 
--   job listings in the "Jobs" table. Ensure that the query filters out jobs with a salary of zero.

select AVG(Salary) as AverageSalary
from Jobs
where Salary > 0;

--9. Write an SQL query to identify the company that has posted the most job listings. Display the 
--	 company name along with the count of job listings they have posted. Handle ties if multiple 
--	 companies have the same maximum count

with JobCounts as (
    select c.CompanyName, COUNT(j.JobID) as JobCount
    from Jobs j
    join Companies c ON j.CompanyID = c.CompanyID
    group by c.CompanyName
)
select CompanyName, JobCount
from JobCounts
where JobCount = (
    select MAX(JobCount) from JobCounts
);

-- 10. Find the applicants who have applied for positions in companies located in 'CityX' and have at 
--     least 3 years of experience

-- There is no ExprienceYears Column in Applicants table so first we add ExperienceColumn on Applicants table
alter table Applicants
add ExperienceYears int;

select a.FirstName, a.LastName, a.Email, ap.JobID, c.CompanyName, c.Location, a.ExperienceYears
from Applicants a
join Applications ap on a.ApplicantID = ap.ApplicantID
join Jobs j ON ap.JobID = j.JobID
join Companies c ON j.CompanyID = c.CompanyID
where c.Location = 'CityX'
and a.ExperienceYears >= 3;

-- 11. Retrieve a list of distinct job titles with salaries between $60,000 and $80,000

select distinct JobTitle
from Jobs
where Salary between 60000 and 80000;

-- 12. Find the jobs that have not received any applications

select j.JobID, j.JobTitle, j.Salary, j.JobLocation
from Jobs j
left join Applications a on j.JobID = a.JobID
where a.ApplicationID IS NULL;

-- 13. Retrieve a list of job applicants along with the companies they have applied to and the positions 
--     they have applied for.

select a.FirstName, a.LastName, a.Email, c.CompanyName, j.JobTitle
from Applicants a
join Applications ap on a.ApplicantID = ap.ApplicantID
join Jobs j on ap.JobID = j.JobID
join Companies c on j.CompanyID = c.CompanyID;

-- 14. Retrieve a list of companies along with the count of jobs they have posted, even if they have not 
--     received any applications

select c.CompanyName, COUNT(j.JobID) as JobCount
from Companies c
left join Jobs j on c.CompanyID = j.CompanyID
group by c.CompanyName;

-- 15. List all applicants along with the companies and positions they have applied for, including those 
--     who have not applied

select a.FirstName, a.LastName, a.Email, c.CompanyName, j.JobTitle
from Applicants a
left join Applications ap on a.ApplicantID = ap.ApplicantID
left join Jobs j on ap.JobID = j.JobID
left join Companies c on j.CompanyID = c.CompanyID;

-- 16. Find companies that have posted jobs with a salary higher than the average salary of all jobs.

select distinct c.CompanyName
from Companies c
join Jobs j on c.CompanyID = j.CompanyID
where j.Salary > (select AVG(Salary) from Jobs);

-- 17. Display a list of applicants with their names and a concatenated string of their city and state.
-- There are no city and state columns in Applicants table so we need to add the columns first.
alter table Applicants
add City varchar(100),
    State varchar(100);

select a.FirstName, a.LastName, a.City + ', ' + a.State as Location
from Applicants a;

-- 18. Retrieve a list of jobs with titles containing either 'Developer' or 'Engineer'.
select JobID, JobTitle, JobDescription, JobLocation, Salary, JobType, PostedDate
from Jobs
where JobTitle like '%Developer%' or JobTitle like '%Engineer%';

-- 19. Retrieve a list of applicants and the jobs they have applied for, including those who have not 
--	   applied and jobs without applicants.

select a.FirstName, a.LastName, a.Email, j.JobTitle, c.CompanyName
from Applicants a
left join Applications ap on a.ApplicantID = ap.ApplicantID
left join Jobs j on ap.JobID = j.JobID
left join Companies c on j.CompanyID = c.CompanyID;

-- 20. List all combinations of applicants and companies where the company is in a specific city and the 
--     applicant has more than 2 years of experience. For example: city=Chennai

select a.FirstName, a.LastName, c.CompanyName
from Applicants a
cross join Companies c
where c.Location = 'Chhenai' 
and a.ExperienceYears > 2;




