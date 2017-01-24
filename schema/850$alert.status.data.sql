MERGE INTO [alert].[status] AS target
USING
    (VALUES
        (N'REQUESTED'),
        (N'QUEUED'),
        (N'PROCESSING'),
        (N'DELIVERED'),
        (N'FAILED'),
        (N'CANCELED'),
        (N'RESUBMITTED'),
        (N'UNAPPROVED')
    ) AS source ([name])
ON target.[name] = source.[name]
WHEN NOT MATCHED BY TARGET THEN
INSERT ([name])
VALUES ([name]);