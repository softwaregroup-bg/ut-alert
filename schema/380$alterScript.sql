if not exists (SELECT * FROM sys.columns c
                JOIN sys.types y ON y.system_type_id = c.system_type_id
                WHERE c.Name = 'content' AND Object_ID = Object_ID(N'alert.messageOut') and y.name = 'varbinary')
 and 
  not exists (SELECT * FROM sys.columns c
                JOIN sys.types y ON y.system_type_id = c.system_type_id
                WHERE c.Name = 'content_Encrypted' AND Object_ID = Object_ID(N'alert.messageOut'))
BEGIN
    -- Create a column in which to store the encrypted data.  
    ALTER TABLE [alert].[messageOut]
        ADD content_Encrypted varbinary(max)
END