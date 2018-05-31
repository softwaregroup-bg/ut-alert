ALTER PROCEDURE [alert].[queueIn.pop] -- returns the specified count of messages ordered by the priority from the biggest to the lowest
    @port NVARCHAR(255)
AS
BEGIN TRY
    DECLARE @statusQueued TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'QUEUED')
    DECLARE @statusProcessing TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')

    DECLARE @messageIn TABLE(id BIGINT, port VARCHAR(255), channel VARCHAR(100), sender VARCHAR(255), content VARCHAR(MAX))

    SELECT 'messages' resultSetName;

    UPDATE m
    SET [statusId] = @statusProcessing
    OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.sender, INSERTED.content
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

    SELECT id, port, channel, sender, content
    FROM @messageIn

END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
