ALTER PROCEDURE [alert].[queueOut.push]
    @port varchar(255),
    @channel varchar(128),
    @recipient [core].[arrayList] READONLY,
    @content nvarchar(max),
    @priority int = 0,
    @messageInId BIGINT = NULL,
    @statusName nvarchar(255) = 'QUEUED',
    @meta [core].[metaDataTT] READONLY
AS
BEGIN
    BEGIN TRY
        DECLARE @statusId int = (select id from [alert].[status] where name = @statusName)
        DECLARE @actorId bigint = (select [auth.actorId] from @meta)

		IF @actorId IS NULL
			RAISERROR(N'alert.missingCreatorId', 16, 1);
        
        declare @insertedIds core.arrayNumberList
        -- Open the symmetric key with which to encrypt the data.  
        OPEN SYMMETRIC KEY MessageOutContent_Key  
            DECRYPTION BY CERTIFICATE MessageOutContent;  
        

        SELECT 'inserted' resultSetName;

        INSERT INTO [alert].[messageOut](port, channel, recipient, content, createdBy, createdOn, statusId, priority, messageInId)       
        OUTPUT inserted.id into @insertedIds(value)
        SELECT @port, @channel, LTRIM(RTRIM([value])), convert(varbinary, @content), @actorId, SYSDATETIMEOFFSET(), @statusId, @priority, @messageInId
        FROM @recipient

        UPDATE mOut
        SET content = EncryptByKey(Key_GUID('MessageOutContent_Key'), @content, 1, HashBytes('SHA1', CONVERT( varbinary, mOut.id)))
        FROM @insertedIds
        JOIN [alert].[messageOut] mOut on mOut.id = value

        SELECT id, port, channel, recipient, @content as content, createdBy, createdOn, @statusName as status, priority, messageInId
        FROM @insertedIds
        JOIN [alert].[messageOut] mOut on mOut.id = value        
    END TRY
    BEGIN CATCH
         EXEC [core].[error]
    END CATCH
END