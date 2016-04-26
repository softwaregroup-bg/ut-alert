ALTER PROCEDURE [alert].[queue.pop] -- returns the specified count of messages ordered by the priority from the biggest to the lowest
    @port nvarchar(255), -- the port
    @count int -- the number of the messages that should be returned
AS
BEGIN TRY
    DECLARE @statusQueued int = (Select id FROM [alert].[status] WHERE [name] = 'QUEUED')
    DECLARE @statusProcessing int = (Select id FROM [alert].[status] WHERE [name] = 'PROCESSING')

    update m
    set [statusId] =  @statusProcessing
    OUTPUT INSERTED.id, inserted.port, inserted.recipient, inserted.subject, inserted.content
    from 
    (
        SELECT TOP (@count) [id]
        FROM [alert].[messageQueue] m
        WHERE m.[port] = @port AND m.[statusId] = @statusQueued
        ORDER BY m.[priority] DESC
    ) s
    join [alert].[messageQueue] m on s.Id = m.id
END TRY
BEGIN CATCH
	exec core.error
END CATCH