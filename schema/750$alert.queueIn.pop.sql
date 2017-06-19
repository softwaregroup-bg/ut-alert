ALTER PROCEDURE [alert].[queueIn.pop] -- returns the specified count of messages ordered by the priority from the biggest to the lowest
    @port nvarchar(255)
AS
BEGIN TRY
    DECLARE @statusQueued int = (Select id FROM [alert].[status] WHERE [name] = 'QUEUED')
    DECLARE @statusProcessing int = (Select id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    
    IF OBJECT_ID('tempdb..#messageIn') IS NOT NULL
        DROP TABLE #messageIn

    CREATE TABLE #messageIn(id BIGINT, port VARCHAR(255), channel VARCHAR(100), sender VARCHAR(255), content VARCHAR(MAX))
    

    SELECT 'messages' resultSetName;

    UPDATE m
    SET [statusId] =  @statusProcessing
    OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.sender, INSERTED.content
    INTO #messageIn ()
    FROM
    (
        SELECT TOP 1 [id]
        FROM [alert].[messageIn] m
        WHERE m.[port] = @port AND m.[statusId] = @statusQueued
        ORDER BY m.[priority] DESC
    ) s
    JOIN [alert].[messageIn] m on s.Id = m.id
    
    SELECT id, port, channel, sender, content
    FROM #messageIn

    DROP TABLE #messageIn
    
END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
