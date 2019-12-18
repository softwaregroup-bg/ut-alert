ALTER PROCEDURE [alert].[queueOut.push]
    @port VARCHAR(255),
    @channel VARCHAR(100),
    @recipient [core].[arrayList] READONLY,
    @content NVARCHAR(MAX),
    @priority SMALLINT = 0,
    @messageInId BIGINT = NULL,
    @statusName NVARCHAR(255) = 'QUEUED',
    @meta [core].[metaDataTT] READONLY
AS
BEGIN
    BEGIN TRY
        DECLARE @statusId TINYINT = (SELECT id FROM [alert].[status] WHERE name = @statusName)
        DECLARE @actorId BIGINT = (SELECT [auth.actorId] FROM @meta)

        IF @actorId IS NULL
            RAISERROR(N'alert.missingCreatorId', 16, 1);

        DECLARE @insertedIds core.arrayNumberList
        -- Open the symmetric key with which to encrypt the data.
        DECLARE @sql NVARCHAR(2000) = 'OPEN SYMMETRIC KEY MessageOutContent_Key DECRYPTION BY CERTIFICATE MessageOutContent'
        EXEC sp_executesql @sql

        SELECT 'inserted' resultSetName;

		DECLARE @mobileNumber NVARCHAR(255)
		SELECT TOP 1 @mobileNumber=[value] FROM @recipient
        INSERT INTO [alert].[messageOut](port, channel, recipient, content, createdBy, createdOn, statusId, priority, messageInId)
        OUTPUT inserted.id INTO @insertedIds(value)
        SELECT @port, @channel, LTRIM(RTRIM(@mobileNumber)), CONVERT(VARBINARY, @content), @actorId, SYSDATETIMEOFFSET(), @statusId, @priority, @messageInId


        UPDATE mOut
        SET content = EncryptByKey(Key_GUID('MessageOutContent_Key'), @content, 1, HashBytes('SHA1', CONVERT(VARBINARY, mOut.id)))
        FROM @insertedIds
        JOIN [alert].[messageOut] mOut ON mOut.id = value

        SELECT id, port, channel, recipient, @content AS content, createdBy, createdOn, @statusName AS status, priority, messageInId
        FROM @insertedIds
        JOIN [alert].[messageOut] mOut ON mOut.id = value
    END TRY
    BEGIN CATCH
        IF @@trancount > 0
            ROLLBACK TRANSACTION
DECLARE @CORE_ERROR_FILE_42 sysname='C:\JoboStuff\AgencyTribe\IBLAgency\impl-agency\node_modules\ut-alert\api\sql\schema\750$alert.queueOut.push.sql' DECLARE @CORE_ERROR_LINE_42 int='43' EXEC [core].[errorStack] @procid=@@PROCID, @file=@CORE_ERROR_FILE_42, @fileLine=@CORE_ERROR_LINE_42, @params = NULL
        RETURN 55555
    END CATCH
END