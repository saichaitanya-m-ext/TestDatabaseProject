CREATE TABLE [dbo].[ProviderClinicInternalIdentifier] (
    [ProviderClinicInternalIdentifierId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ProviderID]                         [dbo].[KeyID]    NOT NULL,
    [InternalIdentifierID]               VARCHAR (10)     NOT NULL,
    [StatusCode]                         VARCHAR (1)      CONSTRAINT [DF_ProviderClinicInternalIdentifier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                    [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                        [dbo].[UserDate] CONSTRAINT [DF_ProviderClinicInternalIdentifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [TaxId]                              VARCHAR (15)     NULL,
    [NPINumber]                          VARCHAR (30)     NULL,
    CONSTRAINT [PK_ProviderClinicInternalIdentifier] PRIMARY KEY CLUSTERED ([ProviderClinicInternalIdentifierId] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ProviderClinicInternalIdentifier_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);

