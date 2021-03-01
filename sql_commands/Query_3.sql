BEGIN
    EXECUTE IMMEDIATE 'DROP VIEW Tasks_matching_count';
    EXECUTE IMMEDIATE 'DROP VIEW Tasks_matching';
    EXECUTE IMMEDIATE 'DROP TABLE Capabilities';
    EXECUTE IMMEDIATE 'DROP TABLE Employees';
    EXECUTE IMMEDIATE 'DROP TABLE Skills';
    EXECUTE IMMEDIATE 'DROP TABLE Tasks';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

/* tables needed for original db */
CREATE TABLE Employees (
    employee_id                 NUMBER,   
    employee_first_name         VARCHAR2(50) NOT NULL,   
    employee_last_name          VARCHAR2(50) NOT NULL,   
    address                     VARCHAR2(50),
    CONSTRAINT pk_employees PRIMARY KEY (employee_id)   
);

CREATE TABLE Skills (
    skill_id                    NUMBER,   
    skill_name                  VARCHAR2(50) NOT NULL,   
    CONSTRAINT pk_skills PRIMARY KEY (skill_id)   
);

/* triggers to populate pks, automatically dropped when binding tables are dropped */
create or replace trigger Employees_BIU 
    before insert or update on Employees 
    for each row 
begin 
    if inserting and :new.employee_id is null then 
        :new.employee_id := to_number(sys_guid(),  
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'); 
    end if; 
end; 
/

create or replace trigger Skills_BIU 
    before insert or update on Skills 
    for each row 
begin 
    if inserting and :new.skill_id is null then 
        :new.skill_id := to_number(sys_guid(),  
            'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'); 
    end if; 
end; 
/

/* insert data into both original tables */
INSERT INTO Employees (employee_first_name, employee_last_name, address)
    VALUES ('Julia', 'Roberts', '642, Notting Hill, London');
INSERT INTO Employees (employee_first_name, employee_last_name)
    VALUES ('Hugh', 'Grant');
INSERT INTO Employees (employee_first_name, employee_last_name, address)
    VALUES ('Margaret', 'Thatcher', '10, Downing St, London');
INSERT INTO Employees (employee_first_name, employee_last_name)
    VALUES ('Alexander', 'McQueen');
    
INSERT INTO Skills (skill_name)
    VALUES ('File taxes');
INSERT INTO Skills (skill_name)
    VALUES ('Meet the press');
INSERT INTO Skills (skill_name)
    VALUES ('Organize spring cleaning');
INSERT INTO Skills (skill_name)
    VALUES ('Do teeth cleaning');
INSERT INTO Skills (skill_name)
    VALUES ('Reorder inventory');
INSERT INTO Skills (skill_name)
    VALUES ('Service equipment');
INSERT INTO Skills (skill_name)
    VALUES ('Tooth extraction');
INSERT INTO Skills (skill_name)
    VALUES ('Backflip');

/* view tables and query */
SELECT * FROM Employees;
SELECT * FROM Skills;

/* two additional tables as requested */
CREATE TABLE Tasks (task VARCHAR2(50));
INSERT INTO Tasks (task) VALUES ('File taxes');
INSERT INTO Tasks (task) VALUES ('Meet the press');
INSERT INTO Tasks (task) VALUES ('Organize spring cleaning');
INSERT INTO Tasks (task) VALUES ('Do teeth cleaning');
INSERT INTO Tasks (task) VALUES ('Reorder inventory');

CREATE TABLE Capabilities (
    employee_id                 NUMBER,   
    skill_id                    NUMBER,   
    CONSTRAINT fk_capabilities_employee_id FOREIGN KEY (employee_id) REFERENCES Employees (employee_id),
    CONSTRAINT fk_capabilities_skill_id FOREIGN KEY (skill_id) REFERENCES Skills (skill_id)
);

INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Grant' AND employee_first_name = 'Hugh')), (SELECT skill_id FROM Skills WHERE skill_name = 'File taxes'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Grant' AND employee_first_name = 'Hugh')), (SELECT skill_id FROM Skills WHERE skill_name = 'Meet the press'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Grant' AND employee_first_name = 'Hugh')), (SELECT skill_id FROM Skills WHERE skill_name = 'Organize spring cleaning'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Grant' AND employee_first_name = 'Hugh')), (SELECT skill_id FROM Skills WHERE skill_name = 'Do teeth cleaning'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Grant' AND employee_first_name = 'Hugh')), (SELECT skill_id FROM Skills WHERE skill_name = 'Reorder inventory'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Grant' AND employee_first_name = 'Hugh')), (SELECT skill_id FROM Skills WHERE skill_name = 'Backflip'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Roberts' AND employee_first_name = 'Julia')), (SELECT skill_id FROM Skills WHERE skill_name = 'File taxes'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Roberts' AND employee_first_name = 'Julia')), (SELECT skill_id FROM Skills WHERE skill_name = 'Meet the press'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Roberts' AND employee_first_name = 'Julia')), (SELECT skill_id FROM Skills WHERE skill_name = 'Organize spring cleaning'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Roberts' AND employee_first_name = 'Julia')), (SELECT skill_id FROM Skills WHERE skill_name = 'Do teeth cleaning'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Roberts' AND employee_first_name = 'Julia')), (SELECT skill_id FROM Skills WHERE skill_name = 'Reorder inventory'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Thatcher' AND employee_first_name = 'Margaret')), (SELECT skill_id FROM Skills WHERE skill_name = 'Meet the press'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'Thatcher' AND employee_first_name = 'Margaret')), (SELECT skill_id FROM Skills WHERE skill_name = 'Organize spring cleaning'));
INSERT INTO Capabilities (employee_id, skill_id)
    VALUES ((SELECT employee_id FROM Employees WHERE (employee_last_name = 'McQueen' AND employee_first_name = 'Alexander')), (SELECT skill_id FROM Skills WHERE skill_name = 'Backflip'));
    
/* view tables and query */
SELECT * FROM Tasks;
SELECT * FROM Capabilities;

/* pick employees that can do EVERYYY tasks in Tasks table*/
CREATE VIEW Tasks_matching AS
SELECT  sk.skill_id AS skill_id,
        sk.skill_name AS skill_name
FROM Tasks ta, Skills sk
WHERE ta.task = sk.skill_name;

CREATE VIEW Tasks_matching_count AS
SELECT      tm.skill_id AS skill_id,
            cp.employee_id AS employee_id
FROM Tasks_matching tm RIGHT OUTER JOIN Capabilities cp ON cp.skill_id = tm.skill_id
WHERE tm.skill_id IS NOT NULL;

SELECT  temp.employee_id AS employee_id,
        emp.employee_last_name AS employee_last_name,
        emp.employee_first_name AS employee_first_name
FROM Employees emp, (SELECT  tmc.employee_id AS employee_id
                    FROM Tasks_matching_count tmc
                    GROUP BY tmc.employee_id
                    HAVING COUNT(tmc.skill_id) = (SELECT COUNT(*) FROM Tasks)) temp
WHERE temp.employee_id = emp.employee_id;

DROP VIEW Tasks_matching_count;
DROP VIEW Tasks_matching;
DROP TABLE Capabilities;
DROP TABLE Employees;
DROP TABLE Skills;
DROP TABLE Tasks;
