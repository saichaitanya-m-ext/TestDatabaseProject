CREATE TABLE [dbo].[PatientPCP] (
    [PCPHistoryID]         INT                 IDENTITY (1, 1) NOT NULL,
    [PatientId]            [dbo].[KeyID]       NOT NULL,
    [ProviderID]           [dbo].[KeyID]       NOT NULL,
    [PCPSystem]            VARCHAR (50)        NULL,
    [CareBeginDate]        DATE                NOT NULL,
    [CareEndDate]          DATE                CONSTRAINT [DF_PatientPCP_CareEndDate] DEFAULT ('01-01-2100') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]       NULL,
    [DataSourceFileID]     [dbo].[KeyID]       NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_PatientPCP_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [IslatestPCP]          [dbo].[IsIndicator] NULL,
    CONSTRAINT [PK_PatientPCP] PRIMARY KEY CLUSTERED ([PatientId] ASC, [ProviderID] ASC, [CareBeginDate] ASC, [CareEndDate] ASC),
    CONSTRAINT [FK_PatientPCP_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientPCP_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientPCP_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientPCP_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientPCP]
    ON [dbo].[PatientPCP]([PatientId] ASC, [ProviderID] ASC, [CareBeginDate] ASC, [CareEndDate] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_PatientPCP_CareBeginDate_PatientId]
    ON [dbo].[PatientPCP]([CareBeginDate], [PatientId]);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'The "Primary Key" of the table in the database; the column uniquely identifies the record in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'PCPHistoryID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); is the "User ID" of the Patient in the System.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Medical System/Health Network that the PCP physician is associated with or is a part of.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'PCPSystem';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'First Date on which the Physician commenced serving as the PCP of the Insured Member.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'CareBeginDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Last Date on which the Physician served as the PCP of the Insured Member.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'CareEndDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPCP', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

