CREATE TABLE [dbo].[PatientPhysicianAttribution] (
    [PhysicianAttributionHistoryID] INT              IDENTITY (1, 1) NOT NULL,
    [PatientId]                     [dbo].[KeyID]    NOT NULL,
    [ProviderId]                    [dbo].[KeyID]    NOT NULL,
    [PhysicianExternalProviderId]   [dbo].[KeyID]    NULL,
    [PhysicianSystem]               VARCHAR (50)     NULL,
    [AttributionTypeID]             [dbo].[KeyID]    NOT NULL,
    [DiseaseId]                     [dbo].[KeyID]    NOT NULL,
    [AttributionMethodID]           [dbo].[KeyID]    NOT NULL,
    [DataSourceID]                  [dbo].[KeyID]    NULL,
    [DataSourceFileID]              [dbo].[KeyID]    NULL,
    [CareBeginDate]                 DATE             NOT NULL,
    [CareEndDate]                   DATE             CONSTRAINT [DF_PatientPhysicianAttribution_CareEndDate] DEFAULT ('01-01-2100') NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                   [dbo].[UserDate] CONSTRAINT [DF_PatientPhysicianAttribution_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          [dbo].[KeyID]    NULL,
    [LastModifiedDate]              [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PatientPhysicianAttribution] PRIMARY KEY CLUSTERED ([PatientId] ASC, [ProviderId] ASC, [CareBeginDate] ASC, [CareEndDate] ASC),
    CONSTRAINT [FK_PatientPhysicianAttribution_AttributionMethod] FOREIGN KEY ([AttributionMethodID]) REFERENCES [dbo].[AttributionMethod] ([AttributionMethodID]),
    CONSTRAINT [FK_PatientPhysicianAttribution_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientPhysicianAttribution_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientPhysicianAttribution_Disease] FOREIGN KEY ([DiseaseId]) REFERENCES [dbo].[Disease] ([DiseaseId]),
    CONSTRAINT [FK_PatientPhysicianAttribution_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientPhysicianAttribution_Provider] FOREIGN KEY ([ProviderId]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [IX_PatientPhysicianAttribution] UNIQUE NONCLUSTERED ([PatientId] ASC, [ProviderId] ASC, [PhysicianExternalProviderId] ASC) WITH (FILLFACTOR = 100) ON [FG_Transactional_NCX],
    CONSTRAINT [UQ_CareBeginEndDate] UNIQUE NONCLUSTERED ([CareBeginDate] ASC, [CareEndDate] ASC) WITH (FILLFACTOR = 100) ON [FG_Transactional_NCX]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'The "Primary Key" of the table in the database; the column uniquely identifies the record in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'PhysicianAttributionHistoryID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); is the "User ID" of the Patient in the System.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'PatientId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); is the "User ID" of the Attribution physician of the Insured Member in the System.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'ProviderId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "ExternalCareProvider" table (column "ExternalProviderId"); is the System-internal  "Provider ID" of the Attribution physician of the Insured Member in the System.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'PhysicianExternalProviderId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientPhysicianAttribution', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

