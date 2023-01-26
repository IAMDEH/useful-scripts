USE test

DELIMITER //

DROP PROCEDURE IF EXISTS UpdateColumns //
CREATE PROCEDURE UpdateColumns(
    IN databaseName VARCHAR(50),
    IN tableName VARCHAR(50),
    IN findText VARCHAR(250),
    IN replaceWith VARCHAR(250))
BEGIN
  DECLARE updateDone INT;
  DECLARE columnName VARCHAR(50);  

  DECLARE columnNames CURSOR FOR  SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = tableName;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET updateDone = 1;

  OPEN columnNames;

  SET updateDone = 0;

  REPEAT
    FETCH columnNames INTO columnName;
    
    SET @SQL = CONCAT('UPDATE `',tableName,'` SET `',columnName,'` = REPLACE(`',columnName,'`,\'',findText,'\',\'',replaceWith,'\')');  
    PREPARE statement FROM @SQL;
    EXECUTE statement;
    DEALLOCATE PREPARE statement; 

  UNTIL updateDone END REPEAT;

  CLOSE columnNames;

END; //

DROP PROCEDURE IF EXISTS UpdateDatabaseURLs //
CREATE PROCEDURE UpdateDatabaseURLs(
    IN databaseName VARCHAR(50),
    IN findText VARCHAR(250),
    IN replaceWith VARCHAR(250))
BEGIN
  DECLARE updateDone INT;
  DECLARE tableName VARCHAR(50);  

  DECLARE tableNames CURSOR FOR  SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = databaseName;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET updateDone = 1;
  
  OPEN tableNames;

  SET updateDone = 0;
  
  REPEAT
    FETCH tableNames INTO tableName;
    
    CALL UpdateColumns(databaseName, tableName, findText, replaceWith);

  UNTIL updateDone END REPEAT;

  CLOSE tableNames;

END; //

DELIMITER ;

CALL UpdateDatabaseURLs('test', 'text-to-be-replaced', 'new-text');
