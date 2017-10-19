ALTER PROCEDURE [alert].[queueOut.notifyFailure] -- used by port to report failure on sending
    @messageId int, -- the ID of the message to report
    @errorMessage nvarchar(max), -- the error to report
    @errorCode nvarchar(64) -- the error code to report
AS
BEGIN TRY
    DECLARE @statusProcessing tinyint = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    DECLARE @statusFailed tinyint = (SELECT id FROM [alert].[status] WHERE [name] = 'FAILED')
    DECLARE @messageStatus tinyint;

    SELECT @messageStatus = [statusId] FROM [alert].[messageOut]
    WHERE [id] = @messageId;

    IF @messageStatus IS NULL
        RAISERROR(N'alert.messageNotExists', 16, 1);

    IF @messageStatus != @statusProcessing AND @messageStatus != @statusFailed
        RAISERROR(N'alert.messageInvalidStatus', 16, 1);

    declare @tmpMessage table(messageId bigint, status varchar(20))
    
    SELECT 'updated' resultSetName, 1 single;

    UPDATE m
    SET [statusId] = @statusFailed
    OUTPUT INSERTED.id as [messageId], 'FAILED' as [status] into @tmpMessage(messageId, status)
    FROM [alert].[messageOut] m
    WHERE m.[id] = @messageId;

    select messageId, status
    from @tmpMessage
END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
