 
 Declare @TableID AS INT 
 Set @TableID=1

      -- Get a list of the "Field Value" (Rows) 
      BEGIN try 
          DROP TABLE ##dataquery 
      END try 

      BEGIN catch 
      END catch 

      CREATE TABLE ##dataquery 
        ( 
           id         INT NOT NULL, 
           tablename  VARCHAR(50) NOT NULL, 
           fieldname  VARCHAR(50) NOT NULL, 
           fieldvalue VARCHAR(50) NOT NULL 
        ); 

      INSERT INTO ##dataquery 
      SELECT Row_number() 
               OVER ( 
                 partition BY (fields.fieldname) 
                 ORDER BY fieldvalue.fieldvalue) ID, 
             tables.tablename, 
             fields.fieldname, 
             fieldvalue.fieldvalue 
      FROM   tables 
             INNER JOIN fields 
                     ON tables.tid = fields.tid 
             INNER JOIN fieldvalue 
                     ON fields.fid = fieldvalue.fid 
      WHERE  tables.tid = @TableID 

      --Get a list of the "Fields" (Columns) 
      DECLARE @DynamicColumns AS VARCHAR(max) 

      SELECT @DynamicColumns = COALESCE(@DynamicColumns + ', ', '') 
                               + Quotename(fieldname) 
      FROM   (SELECT DISTINCT fieldname 
              FROM   fields 
              WHERE  fields.tid = @TableID) AS FieldList 

 
      --Build the Dynamic Pivot Table Query  
      DECLARE @FinalTableStruct AS NVARCHAR(max) 

      SET @FinalTableStruct = 'SELECT ' + @DynamicColumns 
                              + 
      ' from ##DataQuery x pivot ( max( FieldValue ) for FieldName in (' 
                              + @DynamicColumns + ') ) p ' 

      EXECUTE(@FinalTableStruct) 
