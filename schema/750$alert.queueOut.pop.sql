ALTER PROCEDURE [alert].[queueOut.pop] -- returns the specified count of messages ordered by the priority from the biggest to the lowest
    @port nvarchar(255), -- the port
    @count int -- the number of the messages that should be returned
AS
BEGIN TRY
    DECLARE @statusQueued tinyint = (Select id FROM [alert].[status] WHERE [name] = 'QUEUED')
    DECLARE @statusProcessing tinyint = (Select id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    
    DECLARE @messageOut TABLE(id BIGINT, port VARCHAR(255), channel VARCHAR(100), recipient VARCHAR(255), content NVARCHAR(MAX))
    

    SELECT 'messages' resultSetName;

    declare @sql nvarchar(2000) = 'OPEN SYMMETRIC KEY MessageOutContent_Key DECRYPTION BY CERTIFICATE MessageOutContent'
    exec sp_executesql @sql

    UPDATE m
    SET [statusId] =  @statusProcessing
    OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.recipient,  DecryptByKey(INSERTED.content, 1 ,  HashBytes('SHA1', CONVERT(varbinary, INSERTED.id)))
    INTO @messageOut (id, port, channel, recipient, content)
    FROM
    (
        SELECT TOP (@count) [id]
        FROM [alert].[messageOut] m
        WHERE m.[port] = @port AND m.[statusId] = @statusQueued
        ORDER BY m.[priority] DESC
    ) s
    JOIN [alert].[messageOut] m on s.Id = m.id
    
    SELECT id, port, channel, recipient, content
    FROM @messageOut
END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
