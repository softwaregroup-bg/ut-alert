ALTER PROCEDURE [alert].[queueIn.notifySuccess] -- used by port to report success after sending
    @messageId INT -- the ID of the message to report
AS
BEGIN TRY
    DECLARE @statusProcessing TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    DECLARE @statusDelivered TINYINT = (SELECT id FROM [alert].[status] WHERE [name] = 'DELIVERED')
    DECLARE @messageStatus TINYINT;

    SELECT @messageStatus = [statusId]
    FROM [alert].[messageIn]
    WHERE [id] = @messageId;

    IF @messageStatus IS NULL
        RAISERROR(N'alert.messageNotExists', 16, 1);

    IF @messageStatus != @statusProcessing AND @messageStatus != @statusDelivered
        RAISERROR(N'alert.messageInvalidStatus', 16, 1);

    DECLARE @tmpMessage TABLE(messageId BIGINT, status VARCHAR(20))

    SELECT 'updated' resultSetName, 1 single;

    UPDATE m
    SET [statusId] = @statusDelivered
    OUTPUT INSERTED.id AS [messageId], 'DELIVERED' AS [status]
    INTO @tmpMessage(messageId, status)
    FROM [alert].[messageIn] m
    WHERE m.[id] = @messageId

    SELECT messageId, status
    FROM @tmpMessage
END TRY
BEGIN CATCH
    IF @@trancount > 0
        ROLLBACK TRANSACTION
    EXEC core.error
    RETURN 55555
END CATCH
