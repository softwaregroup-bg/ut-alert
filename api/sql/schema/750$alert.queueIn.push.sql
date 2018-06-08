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

        DECLARE @tmp [alert].[messageInTT]
        -- Open the symmetric key with which to encrypt the data.
        DECLARE @sql NVARCHAR(2000) = 'OPEN SYMMETRIC KEY MessageOutContent_Key DECRYPTION BY CERTIFICATE MessageOutContent'
        EXEC sp_executesql @sql

        INSERT INTO [alert].[messageIn]
            (port, channel, sender, content, createdOn, statusId, priority)
        OUTPUT
            inserted.id,
            inserted.port,
            inserted.channel,
            inserted.sender,
            inserted.content,
            inserted.createdOn,
            inserted.statusId,
            inserted.priority
        INTO @tmp
            (id, port, channel, sender, content, createdOn, statusId, priority)
        SELECT
            @port, @channel, @sender, CONVERT(VARBINARY, @content), SYSDATETIMEOFFSET(), @statusId, @priority

        UPDATE messIn
        SET content = EncryptByKey(Key_GUID('MessageOutContent_Key'), @content, 1, HashBytes('SHA1', CONVERT(VARBINARY, messIn.id)))
        FROM @tmp t
        JOIN [alert].[messageIn] messIn ON messIn.id = t.id

        SELECT 'inserted' resultSetName;
        SELECT
            id, port, channel, sender, @content AS content, createdOn, @statusName AS [status], priority
        FROM @tmp
    END TRY
    BEGIN CATCH
        EXEC [core].[error]
    END CATCH
END
