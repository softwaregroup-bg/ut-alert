CREATE PROCEDURE [alert].[queue.pop]
    @port nvarchar(255)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

        DECLARE @statusRequested int, @statusQueued int, @statusFailed int;

        SELECT @statusRequested = id FROM [alert].[status] WHERE [name] = 'REQUESTED';
        SELECT @statusQueued = id FROM [alert].[status] WHERE [name] = 'QUEUED';

        DECLARE @messageId int;

        -- TODO: Request @count messages with status "QUEUED" for the @port.

		-- TODO: Change status of the returned messages to "PROCESSING"
		
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
