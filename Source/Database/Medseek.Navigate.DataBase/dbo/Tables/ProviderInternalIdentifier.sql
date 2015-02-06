CREATE TABLE [dbo].[ProviderInternalIdentifier] (
    [ProviderInternalIdentifierId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ProviderID]                   [dbo].[KeyID]    NOT NULL,
    [InternalIdentifierID]         VARCHAR (10)     NOT NULL,
    [StatusCode]                   VARCHAR (1)      CONSTRAINT [DF_ProviderInternalIdentifier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]              [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                  [dbo].[UserDate] CONSTRAINT [DF_ProviderInternalIdentifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [NPINumber]                    VARCHAR (15)     NULL,
    [TaxId]                        VARCHAR (20)     NULL,
    CONSTRAINT [PK_ProviderInternalIdentifier] PRIMARY KEY CLUSTERED ([ProviderInternalIdentifierId] ASC),
    CONSTRAINT [FK_ProviderInternalIdentifier_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);

