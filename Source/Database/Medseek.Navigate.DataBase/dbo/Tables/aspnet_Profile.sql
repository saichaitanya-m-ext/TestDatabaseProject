CREATE TABLE [dbo].[aspnet_Profile] (
    [UserId]               UNIQUEIDENTIFIER NOT NULL,
    [PropertyNames]        NTEXT            NOT NULL,
    [PropertyValuesString] NTEXT            NOT NULL,
    [PropertyValuesBinary] IMAGE            NOT NULL,
    [LastUpdatedDate]      DATETIME         NOT NULL,
    CONSTRAINT [PK__aspnet_Profile__29572725] PRIMARY KEY CLUSTERED ([UserId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK__aspnet_Pr__UserI__2A4B4B5E] FOREIGN KEY ([UserId]) REFERENCES [dbo].[aspnet_Users] ([UserId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Profile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID of the user to which this profile data pertains', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Profile', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Names of all property values stored in this profile', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Profile', @level2type = N'COLUMN', @level2name = N'PropertyNames';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'values of properties that could be persisted as text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Profile', @level2type = N'COLUMN', @level2name = N'PropertyValuesString';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Values of properties that were configured to use binary serialization', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Profile', @level2type = N'COLUMN', @level2name = N'PropertyValuesBinary';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time this profile was last updated', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_Profile', @level2type = N'COLUMN', @level2name = N'LastUpdatedDate';

