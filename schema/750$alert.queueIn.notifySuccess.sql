ALTER PROCEDURE [alert].[queueIn.notifySuccess] -- used by port to report success after sending
    @messageId int -- the ID of the message to report
AS
BEGIN TRY
    DECLARE @statusProcessing int = (SELECT id FROM [alert].[status] WHERE [name] = 'PROCESSING')
    DECLARE @statusDelivered int = (SELECT id FROM [alert].[status] WHERE [name] = 'DELIVERED')
    DECLARE @messageStatus int;

    SELECT @messageStatus = [statusId] FROM [alert].[messageIn]
    WHERE [id] = @messageId;

    IF @messageStatus IS NULL
        RAISERROR(N'alert.messageNotExists', 16, 1);

    IF @messageStatus != @statusProcessing AND @messageStatus != @statusDelivered
        RAISERROR(N'alert.messageInvalidStatus', 16, 1);

    declare @tmpMessage table(messageId bigint, status varchar(20))

    SELECT 'updated' resultSetName, 1 single;

    UPDATE m
    SET [statusId] = @statusDelivered
    OUTPUT INSERTED.id as [messageId], 'DELIVERED' as [status]  into @tmpMessage(messageId, status)
    FROM [alert].[messageIn] m
    WHERE m.[id] = @messageId

    select messageId, status
    from @tmpMessage
END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
