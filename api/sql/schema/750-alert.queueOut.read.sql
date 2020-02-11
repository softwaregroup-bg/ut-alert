ALTER PROCEDURE [alert].[queueOut.read] -- returns decrypted last message for a specified recipient
    @recipient NVARCHAR(255), -- recipient
    @statusId TINYINT = 2 -- status of messages (default status is QUEUED)
AS
BEGIN TRY
    DECLARE @sql NVARCHAR(2000) = 'OPEN SYMMETRIC KEY MessageOutContent_Key DECRYPTION BY CERTIFICATE MessageOutContent'
    EXEC sp_executesql @sql

    SELECT 'message' AS resultSetName, 1 AS single
    SELECT TOP 1 CONVERT(NVARCHAR(1000), DECRYPTBYKEY(m.content, 1 , HASHBYTES('SHA1', CONVERT(VARBINARY, m.id)))) AS 'message'
    FROM alert.messageOut m
    WHERE m.recipient = @recipient
        AND m.statusId = @statusId
    ORDER BY id DESC

END TRY
BEGIN CATCH
    IF @@trancount > 0
        ROLLBACK TRANSACTION
    EXEC core.error
    RETURN 55555
END CATCH
