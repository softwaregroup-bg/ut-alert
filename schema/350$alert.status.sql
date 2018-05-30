CREATE TABLE [alert].[status] -- table that stores the statuses of the meassages
(
    [id] TINYINT IDENTITY(1, 1) NOT NULL, -- the PK of the status
    [name] NVARCHAR(64) NOT NULL, -- the name of the status
    CONSTRAINT [pk_alert_status_id] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_alert_status_name] UNIQUE ([name])
)
