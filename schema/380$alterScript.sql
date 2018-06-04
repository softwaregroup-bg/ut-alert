IF NOT EXISTS
(
    SELECT *
    FROM sys.columns c
    JOIN sys.types y ON y.system_type_id = c.system_type_id
    WHERE c.Name = 'content'
        AND Object_ID = OBJECT_ID(N'alert.messageOut')
        AND y.name = 'varbinary'
)
AND NOT EXISTS
(
    SELECT *
    FROM sys.columns c
    JOIN sys.types y ON y.system_type_id = c.system_type_id
    WHERE c.Name = 'content_Encrypted'
        AND Object_ID = OBJECT_ID(N'alert.messageOut')
)
BEGIN
    -- Create a column in which to store the encrypted data.
    ALTER TABLE [alert].[messageOut]
        ADD content_Encrypted VARBINARY(MAX)
END

IF NOT EXISTS
(
    SELECT *
    FROM sys.columns c
    JOIN sys.types y ON y.system_type_id = c.system_type_id
    WHERE c.Name = 'content'
        AND Object_ID = OBJECT_ID(N'alert.messageIn')
        AND y.name = 'varbinary'
)
AND NOT EXISTS
(
    SELECT *
    FROM sys.columns c
    JOIN sys.types y ON y.system_type_id = c.system_type_id
    WHERE c.Name = 'content_Encrypted'
        AND Object_ID = OBJECT_ID(N'alert.messageIn')
)
BEGIN
    -- Create a column in which to store the encrypted data.
    ALTER TABLE [alert].[messageIn]
        ADD content_Encrypted VARBINARY(MAX)
END
