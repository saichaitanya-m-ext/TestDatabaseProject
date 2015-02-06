CREATE TABLE [dbo].[ProviderSpecialty] (
    [ProviderSpecialtyID]        INT                IDENTITY (1, 1) NOT NULL,
    [ProviderID]                 INT                NOT NULL,
    [CMSProviderSpecialtyCodeID] INT                NOT NULL,
    [DataSourceID]               [dbo].[KeyID]      NULL,
    [DataSourceFileID]           [dbo].[KeyID]      NULL,
    [StatusCode]                 [dbo].[StatusCode] CONSTRAINT [DF_ProviderSpecialty_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]            [dbo].[KeyID]      NULL,
    [CreatedDate]                DATETIME           CONSTRAINT [DF_ProviderSpecialty_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProviderSpecialty] PRIMARY KEY CLUSTERED ([ProviderID] ASC, [CMSProviderSpecialtyCodeID] ASC),
    CONSTRAINT [FK_ProviderSpecialty_CodeSetCMSProviderSpecialty] FOREIGN KEY ([CMSProviderSpecialtyCodeID]) REFERENCES [dbo].[CodeSetCMSProviderSpecialty] ([CMSProviderSpecialtyCodeID]),
    CONSTRAINT [FK_ProviderSpecialty_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ProviderSpecialty_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ProviderSpecialty_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserId_ProviderSpecialty]
    ON [dbo].[ProviderSpecialty]([ProviderID] ASC, [CMSProviderSpecialtyCodeID] ASC)
    INCLUDE([ProviderSpecialtyID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_ProviderSpecialty_UserId]
    ON [dbo].[ProviderSpecialty]([ProviderID] ASC) WITH (FILLFACTOR = 80)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Table not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty', @level2type = N'COLUMN', @level2name = N'ProviderSpecialtyID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Table not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty', @level2type = N'COLUMN', @level2name = N'ProviderID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Table not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CMSProviderSpecialtyCodeID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProviderSpecialty', @level2type = N'COLUMN', @level2name = N'CreatedDate';

