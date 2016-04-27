ALTER PROCEDURE [alert].[systemMessage.add]
	@port varchar(255),
    @channel varchar(128),
	@recipient nvarchar(255),
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

        SELECT 'inserted' resultSetName, 1 single;

		INSERT INTO [alert].[messageQueue](port, channel, recipient, content, createdBy, createdOn, statusId, priority)
		OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.recipient, INSERTED.content, INSERTED.createdBy, INSERTED.createdOn,
                @statusName as status, INSERTED.priority
		VALUES (@port, @channel, LTRIM(RTRIM(@recipient)), @content, @actorId, SYSDATETIMEOFFSET(), @statusId, @priority)
	END TRY
	BEGIN CATCH
		 EXEC [core].[error]
	END CATCH
END
