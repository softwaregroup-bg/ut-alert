ALTER PROCEDURE [alert].[queueOut.pop] -- returns the specified count of messages ordered by the priority from the biggest to the lowest
    @port nvarchar(255), -- the port
    @count int -- the number of the messages that should be returned
AS
BEGIN TRY
    DECLARE @statusQueued int = (Select id FROM [alert].[status] WHERE [name] = 'QUEUED')
    DECLARE @statusProcessing int = (Select id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    
    IF OBJECT_ID('tempdb..#messageOut') IS NOT NULL
        DROP TABLE #messageOut

    CREATE TABLE #messageOut(id BIGINT, port VARCHAR(255), channel VARCHAR(100), recipient VARCHAR(255), content VARCHAR(MAX))
    

    SELECT 'messages' resultSetName;

    UPDATE m
    SET [statusId] =  @statusProcessing
    OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.recipient, INSERTED.content
    INTO #messageOut
    FROM
    (
        SELECT TOP (@count) [id]
        FROM [alert].[messageOut] m
        WHERE m.[port] = @port AND m.[statusId] = @statusQueued
        ORDER BY m.[priority] DESC
    ) s
    JOIN [alert].[messageOut] m on s.Id = m.id
    
    SELECT id, port, channel, recipient, content
    FROM #messageOut

    DROP TABLE #messageOut
    
END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
