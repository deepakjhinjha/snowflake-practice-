create database hospitaldb;
use hospitaldb;

CREATE TABLE doctors
(
    doctor_id INT PRIMARY KEY,
    doctor_name VARCHAR(50),
    specialty VARCHAR(30),
    supervisor_id INT,
    salary DECIMAL(10,2),
    join_date DATE
);
INSERT INTO doctors
VALUES
(1,'Dr. Ahuja','Cardiology',4,180000,'2018-03-10'),
(2,'Dr. Bose','Cardiology',4,165000,'2019-07-22'),
(3,'Dr. Chopra','Neurology',5,175000,'2017-11-05'),
(4,'Dr. Dixit','Cardiology',NULL,200000,'2015-06-01'),
(5,'Dr. Eapen','Neurology',NULL,210000,'2014-09-15'),
(6,'Dr. Farooq','Orthopedics',7,155000,'2020-02-28'),
(7,'Dr. Gupta','Orthopedics',NULL,195000,'2016-04-12'),
(8,'Dr. Hora','Neurology',5,160000,'2021-08-19'),
(9,'Dr. Iyer','Orthopedics',7,148000,'2022-01-30'),
(10,'Dr. Joshi','Cardiology',4,170000,'2020-05-14');

CREATE TABLE patients
(
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(50),
    age INT,
    doctor_id INT,
    admit_date DATE,
    discharge_date DATE,
    ward VARCHAR(20),

    FOREIGN KEY (doctor_id)
    REFERENCES doctors(doctor_id)
);
INSERT INTO patients
VALUES
(101,'Ramesh K.',45,1,'2024-01-05','2024-01-12','Cardiac'),
(102,'Sunita M.',60,2,'2024-01-08','2024-01-20','Cardiac'),
(103,'Priya N.',35,3,'2024-01-15','2024-01-22','Neuro'),
(104,'Anil S.',70,1,'2024-02-01','2024-02-10','Cardiac'),
(105,'Kavita R.',50,5,'2024-02-05','2024-02-18','Neuro'),
(106,'Manoj T.',55,6,'2024-02-12','2024-02-25','Ortho'),
(107,'Deepa V.',40,3,'2024-03-01','2024-03-08','Neuro'),
(108,'Suresh P.',65,7,'2024-03-05','2024-03-20','Ortho'),
(109,'Anita L.',48,2,'2024-03-10','2024-03-22','Cardiac'),
(110,'Vikram D.',58,8,'2024-03-18','2024-03-30','Neuro'),
(111,'Geeta W.',42,9,'2024-04-02','2024-04-15','Ortho'),
(112,'Rajan H.',52,6,'2024-04-08','2024-04-18','Ortho'),
(113,'Meena C.',38,10,'2024-04-15','2024-04-25','Cardiac'),
(114,'Harish B.',63,1,'2024-05-01','2024-05-14','Cardiac'),
(115,'Lata F.',47,5,'2024-05-06','2024-05-20','Neuro');

CREATE TABLE treatments
(
    treat_id INT PRIMARY KEY,
    patient_id INT,
    treatment VARCHAR(50),
    treat_date DATE,
    cost DECIMAL(10,2),

    FOREIGN KEY (patient_id)
    REFERENCES patients(patient_id)
);
INSERT INTO treatments
VALUES
(1,101,'Angioplasty','2024-01-06',85000),
(2,101,'ECG','2024-01-08',2000),
(3,102,'Echocardiogram','2024-01-09',12000),
(4,102,'Medication','2024-01-12',5000),
(5,104,'Bypass Surgery','2024-02-03',150000),
(6,104,'ECG','2024-02-05',2000),
(7,105,'EEG','2024-02-06',8000),
(8,105,'MRI Brain','2024-02-10',18000),
(9,106,'Knee Replacement','2024-02-13',120000),
(10,107,'CT Scan','2024-03-02',9000),
(11,108,'Hip Replacement','2024-03-07',130000),
(12,109,'Angioplasty','2024-03-12',85000),
(13,111,'Arthroscopy','2024-04-04',45000),
(14,112,'Knee Replacement','2024-04-10',120000),
(15,113,'ECG','2024-04-16',2000),
(16,113,'Medication','2024-04-18',3500),
(17,114,'Bypass Surgery','2024-05-03',150000),
(18,114,'ECG','2024-05-05',2000),
(19,115,'MRI Brain','2024-05-08',18000),
(20,115,'EEG','2024-05-12',8000);

SELECT * FROM doctors;

SELECT * FROM patients;

SELECT * FROM treatments;
with cte as (
select distinct(specialty) , count(doctor_id)over(partition by specialty) as counts, avg(salary) over(partition by specialty ) as avged , sum(salary) over(partition by specialty) as totals from doctors )
select * from cte where avged>170000 order by avged desc ;

-- 2
select d.doctor_name ,d.specialty, S.doctor_name as superviser_name 
from doctors as d left join doctors as S on 
d.supervisor_id = s.doctor_id order by d.doctor_id;

--3
SELECT 
    d.doctor_id,
    d.doctor_name,
    d.specialty,
    COUNT(DISTINCT t.patient_id) AS distinct_patients,
    COALESCE(SUM(t.cost),0) AS total_cost
FROM doctors d left join patients as p on d.doctor_id = p.doctor_id 
LEFT JOIN treatments t 
ON p.patient_id = t.patient_id
GROUP BY d.doctor_id, d.doctor_name, d.specialty
ORDER BY d.doctor_id;

select distinct p.patient_name , p.age , p.ward from patients as p 
join treatments as t on p.patient_id = t.patient_id 
where t.cost > 50000 order by p.patient_name ;


select c.doctor_name , c.specialty, c.salary , (select round(avg(salary),2) from doctors as d where d.specialty=c.specialty ) as avged from doctors as c
where c.salary > (select avg(d.salary) from doctors as d
where c.specialty=d.specialty ) order by c.specialty , c.salary desc ;

select doctor_name , specialty , salary , rank()over(paRTITION BY SPECIALTY order by salary desc) as ranks 
from doctors order by specialty , ranks ;

select p.patient_name , t.treatment , t.treat_date , t.cost , sum(cost)over(partition by p.patient_name order by t.treat_date rows between unbounded preceding and current row) as ruuning from patients as p join treatments as t 
on p.patient_id  = t.patient_id order by p.patient_name , t.treat_date;

SELECT
    patient_name,
    ward,
    admit_date
FROM patients
WHERE patient_id NOT IN
(
    SELECT patient_id
    FROM treatments
)
ORDER BY patient_name;


with cte as (select * , rank()over(partition by ward order by cost desc) as costing from treatments )
select p.ward , c.treatment , c.cost from patients as p join cte as c 
on p.patient_id = c.patient_id where costing = 1;






