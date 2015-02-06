CREATE TABLE [dbo].[aspnet_PersonalizationAllUsers] (
    [PathId]          UNIQUEIDENTIFIER NOT NULL,
    [PageSettings]    IMAGE            NOT NULL,
    [LastUpdatedDate] DATETIME         NOT NULL,
    CONSTRAINT [PK__aspnet_Personali__4BAC3F29] PRIMARY KEY CLUSTERED ([PathId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK__aspnet_Pe__PathI__4CA06362] FOREIGN KEY ([PathId]) REFERENCES [dbo].[aspnet_Paths] ([PathId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationAllUsers';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID of the virtual path to which this state pertains', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationAllUsers', @level2type = N'COLUMN', @level2name = N'PathId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serialized personalization state', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationAllUsers', @level2type = N'COLUMN', @level2name = N'PageSettings';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time state was saved', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationAllUsers', @level2type = N'COLUMN', @level2name = N'LastUpdatedDate';

