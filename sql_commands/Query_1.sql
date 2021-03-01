BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Procedures';
    EXECUTE IMMEDIATE 'DROP TABLE Visit';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

/* tables needed */
CREATE TABLE Procedures (
    procedure_id                NUMBER,   
    procedure_type              VARCHAR2(50) NOT NULL,   
    total_cost                  NUMBER NOT NULL,   
    total_duration              NUMBER NOT NULL,
    CONSTRAINT pk_procedures PRIMARY KEY (procedure_id)   
);

CREATE TABLE Visit (
    visit_id                                NUMBER,
    visit_date                              DATE NOT NULL,
    start_time                              TIMESTAMP NOT NULL,
    end_time                                TIMESTAMP NOT NULL,
    procedure_id			                NUMBER,
    CONSTRAINT pk_visit PRIMARY KEY (visit_id),
    CONSTRAINT fk_visit_procedure_id FOREIGN KEY (procedure_id) REFERENCES Procedures (procedure_id) 
);

/* triggers to populate pks, automatically dropped when binding tables are dropped */
create or replace trigger Visit_BIU 
    before insert or update on Visit 
    for each row 
begin 
    if inserting and :new.visit_id is null then 
        :new.visit_id := to_number(sys_guid(),  
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'); 
    end if; 
end; 
/

create or replace trigger Procedures_BIU 
    before insert or update on Procedures 
    for each row 
begin 
    if inserting and :new.procedure_id is null then 
        :new.procedure_id := to_number(sys_guid(),  
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'); 
    end if; 
end; 
/

/* insert data into both tables */
INSERT INTO Procedures (procedure_type, total_cost, total_duration)
    VALUES ('Fill', 80, 0.5);
INSERT INTO Procedures (procedure_type, total_cost, total_duration)
    VALUES ('Polish', 120, 0.3);
INSERT INTO Procedures (procedure_type, total_cost, total_duration)
    VALUES ('Root Canal', 250, 1.5);

INSERT INTO Visit (visit_date, start_time, end_time, procedure_id)
    VALUES ('02-FEB-21', '02-FEB-21 09.00.00 AM', '02-FEB-21 09.30.00 AM', (SELECT procedure_id FROM Procedures WHERE procedure_type = 'Fill'));
INSERT INTO Visit (visit_date, start_time, end_time, procedure_id)
    VALUES ('03-FEB-21', '03-FEB-21 09.00.00 AM', '03-FEB-21 09.30.00 AM', (SELECT procedure_id FROM Procedures WHERE procedure_type = 'Fill'));
INSERT INTO Visit (visit_date, start_time, end_time, procedure_id)
    VALUES ('04-FEB-21', '04-FEB-21 09.00.00 AM', '04-FEB-21 09.30.00 AM', (SELECT procedure_id FROM Procedures WHERE procedure_type = 'Fill'));
INSERT INTO Visit (visit_date, start_time, end_time, procedure_id)
    VALUES ('04-FEB-21', '04-FEB-21 10.00.00 AM', '04-FEB-21 10.30.00 AM', (SELECT procedure_id FROM Procedures WHERE procedure_type = 'Polish'));
INSERT INTO Visit (visit_date, start_time, end_time, procedure_id)
    VALUES ('04-FEB-21', '04-FEB-21 01.00.00 PM', '04-FEB-21 02.30.00 PM', (SELECT procedure_id FROM Procedures WHERE procedure_type = 'Root Canal'));
INSERT INTO Visit (visit_date, start_time, end_time, procedure_id)
    VALUES ('05-FEB-21', '05-FEB-21 09.00.00 AM', '05-FEB-21 09.45.00 AM', (SELECT procedure_id FROM Procedures WHERE procedure_type = 'Polish'));

/* view tables and query */
SELECT * FROM Procedures;
SELECT * FROM Visit;

/* given time range (4 FEB 2021 to 5 FEB 2021) what are the procedures and duration and cost? */
CREATE VIEW Procedures_between AS
SELECT (v.end_time - v.start_time) AS procedure_interval,
        pr.procedure_type AS procedure_type,
        pr.total_cost AS procedure_cost
FROM Visit v, Procedures pr
WHERE v.procedure_id = pr.procedure_id AND (v.visit_date BETWEEN '04-FEB-21' AND '05-FEB-21');

SELECT * FROM Procedures_between;

/* given time range (4 FEB 2021 to 5 FEB 2021) what is the average amount a procedure cost (GROUP BY PROCEDURE) and how long did it take on the average? */
SELECT  AVG(60*EXTRACT(HOUR FROM procedure_interval)+EXTRACT(MINUTE FROM procedure_interval)) AS AVG_procedure_duration,
        AVG(procedure_cost) AS AVG_procedure_cost,
        procedure_type AS procedure_type,
        COUNT(procedure_type) AS procedure_type_count
FROM Procedures_between
GROUP BY procedure_type;

/* given time range (4 FEB 2021 to 5 FEB 2021) what is the average amount procedures cost (ALL PROCEDURES) and how long did ALL PROCEDURES take on the average? */
SELECT  AVG(60*EXTRACT(HOUR FROM procedure_interval)+EXTRACT(MINUTE FROM procedure_interval)) AS AVG_procedure_duration,
        AVG(procedure_cost) AS AVG_procedure_cost,
        COUNT(procedure_type) AS all_procedures_type_count
FROM Procedures_between;

DROP TABLE Visit;
DROP TABLE Procedures;
DROP VIEW Procedures_between;