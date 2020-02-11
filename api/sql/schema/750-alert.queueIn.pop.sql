ALTER PROCEDURE [alert].[queueIn.pop] -- returns the specified count of messages ordered by the priority from the biggest to the lowest
    @port NVARCHAR(255)
AS
BEGIN TRY
    DECLARE @statusQueued TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'QUEUED')
    DECLARE @statusProcessing TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')

    DECLARE @messageIn TABLE(id BIGINT, port VARCHAR(255), channel VARCHAR(100), sender VARCHAR(255), content NVARCHAR(MAX))

    DECLARE @sql NVARCHAR(2000) = 'OPEN SYMMETRIC KEY MessageOutContent_Key DECRYPTION BY CERTIFICATE MessageOutContent'
    EXEC sp_executesql @sql

    UPDATE m
    SET [statusId] = @statusProcessing
    OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.sender, DecryptByKey(INSERTED.content, 1, HashBytes('SHA1', CONVERT(VARBINARY, INSERTED.id)))
    INTO @messageIn (id, port, channel, sender, content)
    FROM
    (
        SELECT TOP 1 [id]
        FROM [alert].[messageIn] m
        WHERE m.[port] = @port
            AND m.[statusId] = @statusQueued
        ORDER BY m.[priority] DESC
    ) s
    JOIN [alert].[messageIn] m ON s.Id = m.id

    SELECT 'messages' resultSetName;

    SELECT id, port, channel, sender, content
    FROM @messageIn

END TRY
BEGIN CATCH
    IF @@trancount > 0
        ROLLBACK TRANSACTION
    EXEC core.error
    RETURN 55555
END CATCH
