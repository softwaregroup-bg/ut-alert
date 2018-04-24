CREATE TABLE [alert].[deliveryChannel] ( -- List of supported deliver channels by ut-alert module
    [id] INT IDENTITY(1, 1) NOT NULL, -- The PK of the channel
    [name] NVARCHAR(255) NOT NULL, -- Unique name of the channel
    CONSTRAINT [pk_alert_deliveryChannel_id] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_alert_deliveryChannel_name] UNIQUE ([name])
)
