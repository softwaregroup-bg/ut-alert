CREATE PROCEDURE [alert].[systemMessage.add]
	@port nvarchar(255),
	@address nvarchar(255),
	@subject nvarchar(1024),
	@content nvarchar(max),
	@priority int = 0,
	@meta [core].[metaDataTT] READONLY
AS
BEGIN
	BEGIN TRY

	    SELECT 1 AS [id];
	    RETURN;

        DECLARE @TranCounter INT;
        SET @TranCounter = @@TRANCOUNT;
        IF @TranCounter > 0
            SAVE TRANSACTION alert_systemMessage_add;
        ELSE
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

		SET @statusName = 'QUEUED';

		SELECT @statusId = id FROM [alert].[status] WHERE [name] = @statusName;

		IF @statusId IS NULL
			RAISERROR(N'Missing statusId for "%s" status', 17, 1, @statusName);

		SELECT @actorId = [actorId] FROM @meta;
		IF @actorId IS NULL
			RAISERROR(N'Authentication required', 16, 1);

        -- TODO: Put table storage SQL here.

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		DECLARE
            @errorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @errorSeverity INT = ERROR_SEVERITY(),
            @errorState INT = ERROR_STATE();
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF @@TRANCOUNT > 0 and XACT_STATE() <> -1
            ROLLBACK TRANSACTION alert_systemMessage_add;
        RAISERROR('%s', @errorSeverity, @errorState, @errorMessage);
	END CATCH
END
