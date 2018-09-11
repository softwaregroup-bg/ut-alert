IF NOT EXISTS (SELECT * FROM sys.columns c
                JOIN sys.types y ON y.system_type_id = c.system_type_id
                WHERE c.Name = 'modifiedOn' AND Object_ID = Object_ID(N'alert.messageOut'))
BEGIN
    -- Create a column in which to store the encrypted data.  
    ALTER TABLE [alert].[messageOut]
        ADD modifiedOn datetimeoffset(7)
END