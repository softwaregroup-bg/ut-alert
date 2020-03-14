ALTER PROCEDURE [alert].[queueOut.pop] -- returns the specified count of messages ordered by the priority from the biggest to the lowest
    @port NVARCHAR(255), -- the port
    @count INT -- the number of the messages that should be returned
AS
BEGIN TRY
    DECLARE @statusQueued TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'QUEUED')
    DECLARE @statusProcessing TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')

    DECLARE @messageOut TABLE(id BIGINT, port VARCHAR(255), channel VARCHAR(100), recipient VARBINARY(512), content NVARCHAR(MAX))


    SELECT 'messages' resultSetName;

    DECLARE @sql NVARCHAR(2000) = 'OPEN SYMMETRIC KEY MessageOutContent_Key DECRYPTION BY CERTIFICATE MessageOutContent'
    EXEC sp_executesql @sql

    UPDATE m
    SET [statusId] = @statusProcessing
    OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.recipient, DecryptByKey(INSERTED.content, 1, HashBytes('SHA1', CONVERT(VARBINARY, INSERTED.id)))
    INTO @messageOut (id, port, channel, recipient, content)
    FROM
    (
        SELECT TOP (@count) [id]
        FROM [alert].[messageOut] m
        WHERE m.[port] = @port AND m.[statusId] = @statusQueued
        ORDER BY m.[priority] DESC
    ) s
    JOIN [alert].[messageOut] m ON s.Id = m.id

    SELECT id, port, channel, recipient, content
    FROM @messageOut
END TRY
BEGIN CATCH
    IF @@trancount > 0
        ROLLBACK TRANSACTION
    EXEC core.error
    RETURN 55555
END CATCH
