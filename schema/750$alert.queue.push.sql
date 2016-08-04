ALTER PROCEDURE [alert].[queue.push]
    @port varchar(255),
    @channel varchar(128),
    @recipient [core].[arrayList] READONLY,
    @content nvarchar(max),
    @priority int = 0,
    @meta [core].[metaDataTT] READONLY
AS
BEGIN
    BEGIN TRY
        DECLARE @statusName nvarchar(255) = 'QUEUED'
        DECLARE @statusId int = (select id from [alert].[status] where name = @statusName)
        DECLARE @actorId bigint = (select [auth.actorId] from @meta)

        IF @actorId IS NULL
            RAISERROR(N'alert.systemMessage.add.missingCreatorId', 16, 1);

        SELECT 'inserted' resultSetName;

        INSERT INTO [alert].[messageQueue](port, channel, recipient, content, createdBy, createdOn, statusId, priority)
        OUTPUT INSERTED.id, INSERTED.port, INSERTED.channel, INSERTED.recipient, INSERTED.content, INSERTED.createdBy, INSERTED.createdOn,
                @statusName as status, INSERTED.priority
        SELECT @port, @channel, LTRIM(RTRIM([value])), @content, @actorId, SYSDATETIMEOFFSET(), @statusId, @priority
        FROM @recipient
    END TRY
    BEGIN CATCH
         EXEC [core].[error]
    END CATCH
END
