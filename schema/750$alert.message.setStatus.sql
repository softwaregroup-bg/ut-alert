CREATE PROCEDURE [alert].[message.setStatus]
    @port nvarchar(255)
AS
BEGIN
	BEGIN TRY
		DECLARE @TranCounter INT;
        SET @TranCounter = @@TRANCOUNT;

        IF @TranCounter > 0
            SAVE TRANSACTION alert_message_setStatus;
        ELSE
            BEGIN TRANSACTION;

        DECLARE @statusRequested int, @statusQueued int, @statusFailed int;

        SELECT @statusRequested = id FROM [alert].[status] WHERE [name] = 'REQUESTED';
        SELECT @statusQueued = id FROM [alert].[status] WHERE [name] = 'QUEUED';

        DECLARE @messageId int;

        SELECT TOP 1 @messageId = [id]
        FROM [alert].[message] m
        WHERE
        	m.[port] = @port
        	AND (
        		(m.[statusId] = @statusQueued)
        		OR
        		(m.[statusId] = @statusRequested AND m.[executeOn] < CURRENT_TIMESTAMP)
        	)
        ORDER BY
        	m.[priority] DESC,
        	CASE m.[statusId]
        		WHEN @statusRequested THEN m.[executeOn]
        		WHEN @statusQueued THEN m.[createdOn]
        	END ASC;

		EXEC [alert].[message.setStatus]
			@messageId = @messageId,
			@status = 'PROCESSING';

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		DECLARE
            @errorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @errorSeverity INT = ERROR_SEVERITY(),
            @errorState INT = ERROR_STATE()
        IF @TranCounter = 0
            ROLLBACK TRANSACTION;
        ELSE IF @@TRANCOUNT > 0 and XACT_STATE() <> -1
            ROLLBACK TRANSACTION alert_message_setStatus;
        RAISERROR('%s', @errorSeverity, @errorState, @errorMessage);
	END CATCH
END
