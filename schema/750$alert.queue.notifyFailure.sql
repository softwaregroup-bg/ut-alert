ALTER PROCEDURE [alert].[queue.notifyFailure] -- used by port to report failure on sending
    @messageId int, -- the ID of the message to report
    @errorMessage nvarchar(max), -- the error to report
    @errorCode nvarchar(64) -- the error code to report
AS
BEGIN TRY
    DECLARE @statusProcessing int = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    DECLARE @statusFailed int = (SELECT id FROM [alert].[status] WHERE [name] = 'FAILED')
    DECLARE @messageStatus int;

    SELECT @messageStatus = [statusId] FROM [alert].[messageQueue]
    WHERE [id] = @messageId;

    IF @messageStatus IS NULL
        RAISERROR(N'alert.message.not.exists', 16, 1);

    IF @messageStatus != @statusProcessing AND @messageStatus != @statusFailed
        RAISERROR(N'alert.message.invalid.status', 16, 1);

    SELECT 'updated' resultSetName, 1 single;

    UPDATE m
    SET [statusId] = @statusFailed
    OUTPUT INSERTED.id as [messageId], 'FAILED' as [status]
    FROM [alert].[messageQueue] m
    WHERE m.[id] = @messageId;
END TRY
BEGIN CATCH
	exec core.error
END CATCH