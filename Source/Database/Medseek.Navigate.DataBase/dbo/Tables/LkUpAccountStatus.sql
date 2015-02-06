CREATE TABLE [dbo].[LkUpAccountStatus] (
    [AccountStatusCode]    VARCHAR (20)             NOT NULL,
    [AccountStatusName]    [dbo].[ShortDescription] NOT NULL,
    [StatusDescription]    [dbo].[LongDescription]  NULL,
    [DataSourceID]         [dbo].[KeyID]            NULL,
    [DataSourceFileID]     [dbo].[KeyID]            NULL,
    [IsActive]             [dbo].[IsIndicator]      CONSTRAINT [DF_LkUpAccountStatus_IsActive] DEFAULT ((1)) NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_LkUpAccountStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_LkUpAccountStatus] PRIMARY KEY CLUSTERED ([AccountStatusCode] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_LkUpAccountStatus_LastProvider] FOREIGN KEY ([LastModifiedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_LkUpAccountStatus_Provider] FOREIGN KEY ([CreatedByUserID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_LkUpAccountStatus_StatusDescription]
    ON [dbo].[LkUpAccountStatus]([StatusDescription] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code of the Account Status.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'AccountStatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the Account Status.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'AccountStatusName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description of the Account Status.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'StatusDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicator of whether the Account Status entry is Active.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'IsActive';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LkUpAccountStatus', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

