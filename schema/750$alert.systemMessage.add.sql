ALTER PROCEDURE [alert].[systemMessage.add]
	@port varchar(255),
    @channel varchar(128),
	@recipient nvarchar(255),
    @subject nvarchar(255),
	@content nvarchar(max),	
	@priority int = 0,
	@meta [core].[metaDataTT] READONLY
AS
BEGIN
	BEGIN TRY
		DECLARE @statusName nvarchar(255) = 'QUEUED'
        DECLARE @statusId int = (select id from [alert].[status] where name = @statusName)
		DECLARE @actorId bigint = (select actorId from @meta)

		IF @priority IS NULL
		    SET @priority = 0;
		
		IF @actorId IS NULL
			RAISERROR(N'alert.systemMessage.add.missingCreatorId', 16, 1);

        if @channel = 'email' and @subject is null
            RAISERROR(N'alert.systemMessage.add.missingEmailSubject', 16, 1);

		INSERT INTO [alert].[messageQueue](port, channel, recipient, subject, content, createdBy, createdOn, statusId, priority)
		OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.recipient, INSERTED.subject, INSERTED.content, INSERTED.createdBy, INSERTED.createdOn, 
                INSERTED.statusId, @statusName as statusName, INSERTED.priority
		VALUES (@port, @channel, LTRIM(RTRIM(@recipient)), @subject, @content, @actorId, SYSDATETIMEOFFSET(), @statusId, @priority)
	END TRY
	BEGIN CATCH
		 EXEC [core].[error]
	END CATCH
END
