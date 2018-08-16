ALTER PROCEDURE [alert].[queueIn.notifyFailure] -- used by port to report success after sending
    @messageId INT -- the ID of the message to report
AS
BEGIN TRY
    DECLARE @statusProcessing TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    DECLARE @statusFailed TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'FAILED')
    DECLARE @messageStatus TINYINT;

    SELECT @messageStatus = [statusId]
    FROM [alert].[messageIn]
    WHERE [id] = @messageId;

    IF @messageStatus IS NULL
        RAISERROR(N'alert.messageNotExists', 16, 1);

    IF @messageStatus != @statusProcessing AND @messageStatus != @statusFailed
        RAISERROR(N'alert.messageInvalidStatus', 16, 1);

    DECLARE @tmpMessage TABLE(
        messageId BIGINT,
        [status] NVARCHAR(64)
    )

    UPDATE m
    SET
        [statusId] = @statusFailed
    OUTPUT
        INSERTED.id AS [messageId],
        'FAILED' AS [status]
    INTO @tmpMessage(messageId, [status])
    FROM [alert].[messageIn] m
    WHERE m.[id] = @messageId

    SELECT 'updated' AS resultSetName, 1 AS single
    SELECT messageId, [status]
    FROM @tmpMessage
END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
