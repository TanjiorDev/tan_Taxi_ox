INSERT INTO `addon_account` (name, label, shared) VALUES
	('society_taxi', 'taxi', 1)
;

INSERT INTO `datastore` (name, label, shared) VALUES
	('society_taxi', 'taxi', 1)
;

INSERT INTO `addon_inventory` (name, label, shared) VALUES
	('society_taxi', 'taxi', 1)
;

INSERT INTO `jobs` (name, label) VALUES
	('taxi', 'TAXI')
;

INSERT INTO `job_grades` (job_name, grade, name, label, salary, skin_male, skin_female) VALUES
	('taxi',0,'recruit','Recrue',20,'{}','{}'),
	('taxi',1,'officer','Officier',40,'{}','{}'),
	('taxi',2,'sergeant','Sergent',60,'{}','{}'),
	('taxi',3,'lieutenant','Lieutenant',85,'{}','{}'),
	('taxi',4,'boss','Commandant',100,'{}','{}')
;
