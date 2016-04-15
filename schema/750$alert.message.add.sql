CREATE PROCEDURE [alert].[message.add]
	@port nvarchar(255),
	@address nvarchar(255),
	@content nvarchar(max),
	@executeOn datetimeoffset,
	@priority int = 0,
	@meta [core].[metaDataTT] READONLY
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		IF (@port IS NULL OR LEN(@port) = 0)
			RAISERROR(N'Missing delivery port', 16, 1);
		IF (@address IS NULL OR LEN(LTRIM(RTRIM(@address))) = 0)
			RAISERROR(N'Missing destination address', 16, 1);
		IF (@content IS NULL OR LEN(@content) = 0)
			RAISERROR(N'Missing message content', 16, 1);
		DECLARE @statusId int;
		DECLARE @actorId bigint;
		DECLARE @statusName nvarchar(255);

		IF (@executeOn IS NULL OR @executeOn <= CURRENT_TIMESTAMP)
		BEGIN
			SET @executeOn = NULL;
		    SET @statusName = 'QUEUED';
		END
		ELSE
		    SET @statusName = 'REQUESTED';

		SELECT @statusId = id FROM [alert].[status] WHERE [name] = @statusName;

		IF @statusId IS NULL
			RAISERROR(N'Missing statusId for "%s" status', 17, 1, @statusName);

		SELECT @actorId = [actorId] FROM @meta;
		IF @actorId IS NULL
			RAISERROR(N'Authentication required', 16, 1);

		INSERT INTO [alert].[message]
			([port], [address], [content], [createdBy], [createdOn], [executeOn], [statusId], [priority])
		OUTPUT
		    INSERTED.*
		VALUES
			(@port, LTRIM(RTRIM(@address)), @content, @actorId, CURRENT_TIMESTAMP, @executeOn, @statusId, @priority);

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		DECLARE
            @errorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @errorSeverity INT = ERROR_SEVERITY(),
            @errorState INT = ERROR_STATE()
        RAISERROR(@errorMessage, @errorSeverity, @errorState);
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
        RAISERROR('%s', @errorSeverity, @errorState, @errorMessage);
	END CATCH
END
