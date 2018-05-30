ALTER PROCEDURE [alert].[queueOut.read] -- returns decrypted last message to a specified recipient
    @recipient NVARCHAR(255), -- recipient 
    @statusId TINYINT = 2 -- status of messages (default status is QUEUED)
AS
BEGIN TRY
    DECLARE @sql NVARCHAR(2000) = 'OPEN SYMMETRIC KEY MessageOutContent_Key DECRYPTION BY CERTIFICATE MessageOutContent'
    EXEC sp_executesql @sql

    SELECT TOP 1 CONVERT(NVARCHAR(1000), DECRYPTBYKEY(m.content, 1 , HASHBYTES('SHA1', CONVERT(VARBINARY, m.id)))) 
    FROM alert.messageOut m
    WHERE m.recipient = @recipient
        AND m.statusId = @statusId
    ORDER BY id DESC

END TRY
BEGIN CATCH
    EXEC core.error
END CATCH
