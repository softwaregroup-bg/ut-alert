ALTER PROCEDURE [alert].[queueOut.notifyFailure] -- used by port to report failure on sending
    @messageId INT, -- the ID of the message to report
    @errorMessage NVARCHAR(MAX), -- the error to report
    @errorCode NVARCHAR(64) -- the error code to report
AS
BEGIN TRY
    DECLARE @statusProcessing TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    DECLARE @statusFailed TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'FAILED')
    DECLARE @messageStatus TINYINT;

    SELECT @messageStatus = [statusId]
    FROM [alert].[messageOut]
    WHERE [id] = @messageId;

    IF @messageStatus IS NULL
        RAISERROR(N'alert.messageNotExists', 16, 1);

    IF @messageStatus != @statusProcessing AND @messageStatus != @statusFailed
        RAISERROR(N'alert.messageInvalidStatus', 16, 1);

    DECLARE @tmpMessage TABLE(messageId BIGINT, status VARCHAR(20))

    SELECT 'updated' resultSetName, 1 single;

    UPDATE m
    SET [statusId] = @statusFailed
    OUTPUT INSERTED.id AS [messageId], 'FAILED' AS [status]
    INTO @tmpMessage(messageId, status)
    FROM [alert].[messageOut] m
    WHERE m.[id] = @messageId;

    SELECT messageId, status
    FROM @tmpMessage
END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
