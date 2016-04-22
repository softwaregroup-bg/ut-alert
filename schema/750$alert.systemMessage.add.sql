ALTER PROCEDURE [alert].[systemMessage.add] -- inserts the message with the given parameters for sending
	@port varchar(255), -- the port that is used for sending the message
    @channel varchar(128), -- the channel, can be "email" or "sms"
	@receipient nvarchar(255), -- who should receive the message
    @subject nvarchar(255), -- the subject if it is an email
	@content nvarchar(max),	-- the content of the message
	@priority int = 0, -- what priority has the message
	@meta core.metaDataTT READONLY -- information for the user that makes the operation
AS
BEGIN
	BEGIN TRY
		DECLARE @statusName nvarchar(255) = 'QUEUED'
        DECLARE @statusId int = (select id from [alert].[status] where name = @statusName)
		DECLARE @actorId bigint = (select actorId from @meta)
		
		IF @actorId IS NULL
			RAISERROR(N'alert.systemMessage.add.missingCreatorId', 16, 1);

        if @channel = 'email' and @subject is null
            RAISERROR(N'alert.systemMessage.add.missingEmailSubject', 16, 1);

		INSERT INTO [alert].[messageQueue](port, channel, receipient, subject, content, createdBy, createdOn, statusId, priority)
		OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.receipient, INSERTED.subject, INSERTED.content, INSERTED.createdBy, INSERTED.createdOn, 
                INSERTED.executeOn, INSERTED.statusId, @statusName as statusName, INSERTED.priority 
		VALUES (@port, @channel, LTRIM(RTRIM(@receipient)), @subject, @content, @actorId, SYSDATETIMEOFFSET(), @statusId, @priority)
	END TRY
	BEGIN CATCH
		 EXEC [core].[error]
	END CATCH
END