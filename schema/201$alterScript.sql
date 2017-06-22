if exists (SELECT * FROM sys.columns c
                JOIN sys.types y ON y.system_type_id = c.system_type_id
                WHERE c.Name = 'content_Encrypted' AND Object_ID = Object_ID(N'alert.messageOut') and y.name = 'varbinary')
BEGIN
        -- Open the symmetric key with which to encrypt the data.  
    OPEN SYMMETRIC KEY MessageOutContent_Key  
       DECRYPTION BY CERTIFICATE MessageOutContent

    EXEC sp_executesql N'UPDATE [alert].[messageOut] SET content_Encrypted = EncryptByKey(Key_GUID(''MessageOutContent_Key''), content, 1, HashBytes(''SHA1'', CONVERT( varbinary  , id)))'

    ALTER TABLE [alert].[messageOut] DROP COLUMN content

    EXEC sp_RENAME '[alert].[messageOut].content_Encrypted' , 'content', 'COLUMN'
END