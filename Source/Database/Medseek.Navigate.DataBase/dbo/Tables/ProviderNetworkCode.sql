CREATE TABLE [dbo].[ProviderNetworkCode] (
    [ProviderNetworkCodeId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [NetWorkCodeId]         [dbo].[KeyID]    NOT NULL,
    [ProviderId]            [dbo].[KeyID]    NOT NULL,
    [EffectiveDate]         [dbo].[UserDate] NULL,
    [TerminationDate]       [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ProviderNetworkCode] PRIMARY KEY CLUSTERED ([ProviderNetworkCodeId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_ProviderNetworkCode_NetWorkCode] FOREIGN KEY ([NetWorkCodeId]) REFERENCES [dbo].[NetWorkCodes] ([NetworkCodeId])
);


GO
CREATE NONCLUSTERED INDEX [IX_ProviderNetworkCode.NetworkCodeID,ProviderID ]
    ON [dbo].[ProviderNetworkCode]([NetWorkCodeId] ASC, [ProviderId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

