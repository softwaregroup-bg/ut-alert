ALTER PROCEDURE [alert].[queueIn.push]
    @port VARCHAR(255),
    @channel VARCHAR(100),
    @sender NVARCHAR(255),
    @content NVARCHAR(MAX),
    @priority INT = 0,
    @messageInId BIGINT = NULL,
    @meta [core].[metaDataTT] READONLY
AS
BEGIN
    BEGIN TRY
        DECLARE @statusName NVARCHAR(255) = 'QUEUED'
        DECLARE @statusId TINYINT = (SELECT id FROM [alert].[status] WHERE name = @statusName)

        SELECT 'inserted' resultSetName;

        DECLARE @tmp [alert].[messageInTT]

        INSERT INTO [alert].[messageIn](port, channel, sender, content, createdOn, statusId, priority)
            OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.sender, INSERTED.content,
                INSERTED.createdOn, @statusName AS status, INSERTED.priority
            INTO @tmp(id, port, channel, sender, content, createdOn, statusId, priority)
        SELECT @port, @channel, @sender, @content, SYSDATETIMEOFFSET(), @statusId, @priority

        SELECT id, port, channel, sender, content, createdOn, statusId AS status, priority
        FROM @tmp

    END TRY
    BEGIN CATCH
        EXEC [core].[error]
    END CATCH
END
