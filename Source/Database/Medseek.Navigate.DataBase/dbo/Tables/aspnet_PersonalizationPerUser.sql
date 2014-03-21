CREATE TABLE [dbo].[aspnet_PersonalizationPerUser] (
    [Id]              UNIQUEIDENTIFIER CONSTRAINT [DF__aspnet_Perso__Id__4F7CD00D] DEFAULT (newid()) NOT NULL,
    [PathId]          UNIQUEIDENTIFIER NULL,
    [UserId]          UNIQUEIDENTIFIER NULL,
    [PageSettings]    IMAGE            NOT NULL,
    [LastUpdatedDate] DATETIME         NOT NULL,
    CONSTRAINT [PK__aspnet_Personali__4E88ABD4] PRIMARY KEY NONCLUSTERED ([Id] ASC) WITH (FILLFACTOR = 25) ON [FG_Transactional_NCX],
    CONSTRAINT [FK__aspnet_Pe__PathI__5070F446] FOREIGN KEY ([PathId]) REFERENCES [dbo].[aspnet_Paths] ([PathId]),
    CONSTRAINT [FK__aspnet_Pe__UserI__5165187F] FOREIGN KEY ([UserId]) REFERENCES [dbo].[aspnet_Users] ([UserId])
);


GO
CREATE UNIQUE CLUSTERED INDEX [aspnet_PersonalizationPerUser_index1]
    ON [dbo].[aspnet_PersonalizationPerUser]([PathId] ASC, [UserId] ASC) WITH (FILLFACTOR = 25);


GO
CREATE UNIQUE NONCLUSTERED INDEX [aspnet_PersonalizationPerUser_ncindex2]
    ON [dbo].[aspnet_PersonalizationPerUser]([UserId] ASC, [PathId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationPerUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID of this record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationPerUser', @level2type = N'COLUMN', @level2name = N'Id';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID of the virtual path to which this state pertains', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationPerUser', @level2type = N'COLUMN', @level2name = N'PathId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID of the user to which this state pertains', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationPerUser', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serialized personalization state', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationPerUser', @level2type = N'COLUMN', @level2name = N'PageSettings';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date and time state was saved', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_PersonalizationPerUser', @level2type = N'COLUMN', @level2name = N'LastUpdatedDate';

