DROP TABLE IF EXISTS `pharmacy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;

DROP TABLE IF EXISTS `medicine`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `medicine` (
  `ref` int NOT NULL,
  `MedicineName` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`ref`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `medicine`
--

LOCK TABLES `medicine` WRITE;
/*!40000 ALTER TABLE `medicine` DISABLE KEYS */;
INSERT INTO `medicine` VALUES (1020,'VitaminD'),(1021,'DM'),(1022,'Acetaminophen'),(1023,'MDs'),(1024,'Tx_Iron'),(1245,'Eye'),(2154,'Cipla'),(5478,'Novel'),(8145,'NovelPrice'),(789425,'Alexa');
/*!40000 ALTER TABLE `medicine` ENABLE KEYS */;
UNLOCK TABLES;

/*...*/
-- Create two separate tables
CREATE TABLE `pharmacy_part1` (
  `Ref` int NOT NULL,
  `CompanyName` varchar(45) DEFAULT NULL,
  `TypeOfMedicine` varchar(45) DEFAULT NULL,
  `medname` varchar(45) DEFAULT NULL,
  `lot` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Ref`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `pharmacy_part2` (
  `Ref` int NOT NULL,
  `issuedate` varchar(45) DEFAULT NULL,
  `expdate` varchar(45) DEFAULT NULL,
  `uses` varchar(45) DEFAULT NULL,
  `sideeffect` varchar(45) DEFAULT NULL,
  `warning` varchar(45) DEFAULT NULL,
  `dosage` varchar(45) DEFAULT NULL,
  `price` varchar(45) DEFAULT NULL,
  `product` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`Ref`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Copy data from the original pharmacy table to the new tables
-- Part 1: Columns common to all rows
INSERT INTO `pharmacy_part1` (`Ref`, `CompanyName`, `TypeOfMedicine`, `medname`, `lot`)
VALUES 
  (1020, 'Kiran Pharma Ind.Ltd', 'Tablet', 'VitaminD', '1026'),
  (1021, 'Kiran Pharma', 'Tablet', 'DM', '2458'),
  (1022, 'Sun Pharmacitical Ind.Ltd', 'Injection', 'Acetaminophen', '1003'),
  (1024, 'Kiran Pharma Ind.Ltd', 'Tablet', 'Tx_Iron', '1004'),
  (2154, 'Cipla Pharma', 'Tablet', 'Cipla', '1025'),
  (5478, 'pharmaciytical', 'Tablet', 'novel', '2154'),
  (8956, 'Indu Pharma', 'Drops', 'EyeDrops', '5479');

-- Part 2: Columns specific to certain rows
INSERT INTO `pharmacy_part2` (`Ref`, `issuedate`, `expdate`, `uses`, `sideeffect`, `warning`, `dosage`, `price`, `product`)
VALUES 
  (1020, '07/02/2020', '07/02/2022', 'Skin', 'allergic reaction', 'Dr.consultant', '2', '750', '12'),
  (1021, '23/12/2020', '23/12/2022', 'cold,flue', 'allegies reaction', 'before takinkig this prod tell u are dr', '2', '450', '6'),
  (1022, '07/02/2020', '07/02/2022', 'pain & fever', 'itching', 'Dr.consultant', '1', '1200', '1'),
  (1024, '07/02/2020', '07/02/2022', 'poor diet', 'allergic reaction', 'Dr.consultant', '3', '1400', '12'),
  (2154, '12/12/2020', '12/12/2022', 'Headeck', 'No', 'Bef use tell u are Dr', '2', '45', '6'),
  (5478, '12/12/2020', '12/12/2022', 'fever', 'no', 'Dr.const', '3', '4500', '12'),
  (8956, '07/02/2020', '07/02/2021', 'Eye', 'Eye reaction', 'No', '3', '150', '1');

-- Join the two new tables into a single table
CREATE TABLE `pharmacy` AS
SELECT p1.`Ref`, p1.`CompanyName`, p1.`TypeOfMedicine`, p1.`medname`, p1.`lot`,
       p2.`issuedate`, p2.`expdate`, p2.`uses`, p2.`sideeffect`, p2.`warning`, p2.`dosage`, p2.`price`, p2.`product`
FROM `pharmacy_part1` p1
JOIN `pharmacy_part2` p2 ON p1.`Ref` = p2.`Ref`;

-- Drop the original pharmacy table if needed
DROP TABLE IF EXISTS `pharmacy_part1`, `pharmacy_part2`;

DELIMITER //
-- Create the Users table
CREATE TABLE Users (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    UserName VARCHAR(50) NOT NULL,
    Password VARCHAR(50) NOT NULL
);

-- Insert users into the table
INSERT INTO Users (UserName, Password) VALUES
    ('root', 'sql123'),
    ('leaf', 'sql123'),
    ('branch', 'sql123');

CREATE TRIGGER trg_login_validation
BEFORE INSERT ON your_login_table
FOR EACH ROW
BEGIN
    DECLARE user_count INT;
    
    -- Check if the username exists in the table
    SELECT COUNT(*) INTO user_count
    FROM users
    WHERE username = NEW.username;
    
    IF user_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Login fail';
    ELSE
        -- Check if the password matches the username
        IF (SELECT password FROM users WHERE username = NEW.username) != NEW.password THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Login fail';
        END IF;
    END IF;
END;


CREATE PROCEDURE UpdateMedicineName(IN pRef INT, IN pNewname VARCHAR(45))
BEGIN
    UPDATE medicine
    SET  MedicineName = pNewname
    WHERE ref = pRef;
END //

DELIMITER ;

CALL UpdateMedicinePrice(1020, '800');

DELIMITER //

CREATE PROCEDURE DeletePharmacy(IN RefParam INT)
BEGIN
    DECLARE msg VARCHAR(255);

    -- Connect to the database
    START TRANSACTION;
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET msg = 'Error occurred while deleting the record';
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = msg;
    END;

    -- Delete the record
    DELETE FROM pharmacy WHERE Ref = RefParam;

    -- Commit the transaction
    COMMIT;

    SET msg = 'Medicine Information has been deleted successfully';
    SELECT msg AS Message;
END //

DELIMITER ;

--
-- Dumping data for table `pharmacy`
--
/*DELIMITER //

CREATE TRIGGER SetExpDate
BEFORE INSERT ON pharmacy
FOR EACH ROW
SET NEW.expdate = DATE_ADD(NEW.issuedate, INTERVAL 1 YEAR);

CREATE TRIGGER UpdateExpDate
BEFORE UPDATE ON pharmacy
FOR EACH ROW
SET NEW.expdate = DATE_ADD(NEW.issuedate, INTERVAL 1 YEAR);

//

DELIMITER ;*/
DELIMITER //

CREATE PROCEDURE LogInUser(IN pUsername VARCHAR(255), IN pPassword VARCHAR(255))
BEGIN
    DECLARE userExists INT;

    -- Check if the username and password match
    SELECT COUNT(*) INTO userExists
    FROM users
    WHERE username = pUsername AND password = pPassword;

    IF userExists = 1 THEN
        -- Successful login, log the login information
        INSERT INTO login_log (username, login_time)
        VALUES (pUsername, NOW());
        SELECT 'Login successful' AS message;
    ELSE
        -- Failed login
        SELECT 'Login fail' AS message;
    END IF;
END //

DELIMITER ;
DELIMITER //

CREATE TRIGGER PreventDuplicateMedicine
BEFORE INSERT ON pharmacy
FOR EACH ROW
BEGIN
    DECLARE existingCount INT;

    -- Check if a record with the same Ref already exists
    SELECT COUNT(*) INTO existingCount
    FROM pharmacy
    WHERE Ref = NEW.Ref;

    IF existingCount > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = ' Duplicate entry  for key ';
    END IF;
END //

DELIMITER ; 

LOCK TABLES `pharmacy` WRITE;

INSERT INTO `pharmacy` VALUES (1020,'Kiran Pharma Ind.Ltd','Tablet','VitaminD','1026','07/02/2020','07/02/2022','Skin','allergic reaction','Dr.consultant','2','750','12'),(1021,'Kiran Pharma','Tablet','DM','2458','23/12/2020','23/12/2022','cold,flue','allegies reaction','before takinkig this prod tell u are dr','2','450','6'),(1022,'Sun Pharmacitical Ind.Ltd','Injection','Acetaminophen','1003','07/02/2020','07/02/2022','pain & fever','itching','Dr.consultant','1','1200','1'),(1024,'Kiran Pharma Ind.Ltd','Tablet','Tx_Iron','1004','07/02/2020','07/02/2022','poor diet','allergic reaction','Dr.consultant','3','1400','12'),(2154,'Cipla Pharma','Tablet','Cipla','1025','12/12/2020','12/12/2022','Headeck','No','Bef use tell u are Dr','2','45','6'),(5478,'pharmaciytical','Tablet','novel','2154','12/12/2020','12/12/2022','fever','no','Dr.const','3','4500','12'),(8956,'Indu Pharma','Drops','EyeDrops','5479','07/02/2020','07/02/2021','Eye','Eye reaction','No','3','150','1');

UNLOCK TABLES;
SELECT * FROM pharmacy;