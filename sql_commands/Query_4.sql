BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW Visits_2020';
    EXECUTE IMMEDIATE 'DROP TABLE Bill';
    EXECUTE IMMEDIATE 'DROP TABLE Visit';
    EXECUTE IMMEDIATE 'DROP TABLE Patient';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

/* tables needed */
CREATE TABLE Patient (
    patient_id                  NUMBER,   
    patient_first_name          VARCHAR2(50) NOT NULL,   
    patient_last_name           VARCHAR2(50) NOT NULL,   
    address                     VARCHAR2(50),
    CONSTRAINT pk_patients PRIMARY KEY (patient_id)   
);

CREATE TABLE Visit (
    visit_id                                NUMBER,
    visit_date                              DATE NOT NULL,
    start_time                              TIMESTAMP NOT NULL,
    end_time                                TIMESTAMP NOT NULL,
    patient_id			                    NUMBER,
    CONSTRAINT pk_visit PRIMARY KEY (visit_id),
    CONSTRAINT fk_visit_patient_id FOREIGN KEY (patient_id) REFERENCES Patient (patient_id)
);

CREATE TABLE Bill (
    bill_id                             NUMBER,
    total_charged                       NUMBER NOT NULL,
    total_paid_patient                  NUMBER NOT NULL,
    total_paid_insurance                NUMBER NOT NULL,
    visit_id			                NUMBER,
    CONSTRAINT pk_bill PRIMARY KEY (bill_id),
    CONSTRAINT fk_bill_visit_id FOREIGN KEY (visit_id) REFERENCES Visit (visit_id)
);

/* triggers to populate pks, automatically dropped when binding tables are dropped */
create or replace trigger Patient_BIU 
    before insert or update on Patient 
    for each row 
begin 
    if inserting and :new.patient_id is null then 
        :new.patient_id := to_number(sys_guid(),  
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'); 
    end if; 
end; 
/
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
create or replace trigger Bill_BIU 
    before insert or update on Bill 
    for each row 
begin 
    if inserting and :new.bill_id is null then 
        :new.bill_id := to_number(sys_guid(),  
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'); 
    end if; 
end; 
/

/* insert data into both tables */
INSERT INTO Patient (patient_first_name, patient_last_name, address)
    VALUES ('Julia', 'Roberts', '642, Notting Hill, London');
INSERT INTO Patient (patient_first_name, patient_last_name)
    VALUES ('Hugh', 'Grant');
INSERT INTO Patient (patient_first_name, patient_last_name, address)
    VALUES ('Margaret', 'Thatcher', '10, Downing St, London');
INSERT INTO Patient (patient_first_name, patient_last_name)
    VALUES ('Alexander', 'McQueen');
INSERT INTO Patient (patient_first_name, patient_last_name)
    VALUES ('Harry', 'Potter');
INSERT INTO Patient (patient_first_name, patient_last_name)
    VALUES ('Moby', 'Dick');
INSERT INTO Patient (patient_first_name, patient_last_name)
    VALUES ('Jules', 'Verne');
    
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('02-FEB-20', '02-FEB-20 09.00.00 AM', '02-FEB-20 09.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Potter'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('03-OCT-20', '03-OCT-20 09.00.00 AM', '03-OCT-20 09.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Dick'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('03-MAR-20', '03-MAR-20 10.00.00 AM', '03-MAR-20 11.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Verne'));

INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('02-FEB-21', '02-FEB-21 09.00.00 AM', '02-FEB-21 09.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Roberts'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('03-FEB-21', '03-FEB-21 09.00.00 AM', '03-FEB-21 09.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'McQueen'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('03-FEB-21', '03-FEB-21 10.00.00 AM', '03-FEB-21 11.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Grant'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('04-FEB-21', '04-FEB-21 09.00.00 AM', '04-FEB-21 09.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Roberts'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('04-FEB-21', '04-FEB-21 10.00.00 AM', '04-FEB-21 10.30.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Grant'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('04-FEB-21', '04-FEB-21 01.00.00 PM', '04-FEB-21 02.30.00 PM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'McQueen'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('05-FEB-21', '05-FEB-21 09.00.00 AM', '05-FEB-21 09.45.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Grant'));
INSERT INTO Visit (visit_date, start_time, end_time, patient_id)
    VALUES ('06-FEB-21', '06-FEB-21 09.00.00 AM', '06-FEB-21 09.45.00 AM', (SELECT patient_id FROM Patient WHERE patient_last_name = 'Verne'));

/* assume that a patient only visit once on any given date */
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (100, 15, 85, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Potter' AND vs.visit_date = '02-FEB-20' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (200, 120, 30, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Dick' AND vs.visit_date = '03-OCT-20' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (220, 150, 50, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Verne' AND vs.visit_date = '03-MAR-20' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (110, 10, 100, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Roberts' AND vs.visit_date = '02-FEB-21' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (200, 80, 120, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'McQueen' AND vs.visit_date = '03-FEB-21' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (210, 150, 60, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Grant' AND vs.visit_date = '03-FEB-21' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (120, 110, 5, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Roberts' AND vs.visit_date = '04-FEB-21' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (200, 120, 60, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Grant' AND vs.visit_date = '04-FEB-21' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (220, 150, 20, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'McQueen' AND vs.visit_date = '04-FEB-21' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (200, 150, 50, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Grant' AND vs.visit_date = '05-FEB-21' AND pt.patient_id = vs.patient_id));
INSERT INTO Bill (total_charged, total_paid_patient, total_paid_insurance, visit_id)
    VALUES (200, 150, 50, (SELECT vs.visit_id FROM Visit vs, Patient pt WHERE pt.patient_last_name = 'Verne' AND vs.visit_date = '06-FEB-21' AND pt.patient_id = vs.patient_id));

/* view tables and query */
SELECT * FROM Patient;
SELECT * FROM Visit;
SELECT * FROM Bill;

/* query patient who still owes money from 2020 and before!*/
CREATE VIEW Visits_2020 AS
SELECT * FROM Visit WHERE visit_date <= '01-JAN-21';

SELECT * 
FROM    (SELECT      pt.patient_last_name as patient_last_name,
                    (b.total_charged - (b.total_paid_patient + b.total_paid_insurance)) as debt
        FROM Visits_2020 vs, Patient pt, Bill b
        WHERE vs.patient_id = pt.patient_id AND vs.visit_id = b.visit_id) temp
WHERE temp.debt > 0;

DROP VIEW Visits_2020;
DROP TABLE Bill;
DROP TABLE Visit;
DROP TABLE Patient;