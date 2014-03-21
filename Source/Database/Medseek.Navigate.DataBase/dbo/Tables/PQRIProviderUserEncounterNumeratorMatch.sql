CREATE TABLE [dbo].[PQRIProviderUserEncounterNumeratorMatch] (
    [PQRIProviderUserEncounterNumeratorMatchID] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [PQRIProviderUserEncounterID]               [dbo].[KeyID]       NOT NULL,
    [PQRIQualityMeasureID]                      [dbo].[KeyID]       NULL,
    [IsMeetPerformance]                         [dbo].[IsIndicator] NULL,
    [MEPCPTCodeAndModifierList]                 VARCHAR (200)       NULL,
    [IsMedicalPerformanceExclusion]             [dbo].[IsIndicator] NULL,
    [MPExCPTCodeAndModifierList]                VARCHAR (200)       NULL,
    [IsPatientPerformanceExclusion]             [dbo].[IsIndicator] NULL,
    [PPExCPTCodeAndModifierList]                VARCHAR (200)       NULL,
    [IsSystemPerformanceExclusion]              [dbo].[IsIndicator] NULL,
    [SPExCPTCodeAndModifierList]                VARCHAR (200)       NULL,
    [IsOtherPerformanceExclusion]               [dbo].[IsIndicator] NULL,
    [OPExCPTCodeAndModifierList]                VARCHAR (200)       NULL,
    [IsPerformanceNotMet]                       [dbo].[IsIndicator] NULL,
    [PNMCPTCodeAndModifierList]                 VARCHAR (200)       NULL,
    [CreatedByUserId]                           [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                               [dbo].[UserDate]    CONSTRAINT [DF_PQRIProviderUserEncounterNumeratorMatch_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                      [dbo].[KeyID]       NULL,
    [LastModifiedDate]                          [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_PQRIProviderUserEncounterNumeratorMatch] PRIMARY KEY CLUSTERED ([PQRIProviderUserEncounterNumeratorMatchID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PQRIProviderUserEncounterNumeratorMatch_PQRIProviderUserEncounter] FOREIGN KEY ([PQRIProviderUserEncounterID]) REFERENCES [dbo].[PQRIProviderUserEncounter] ([PQRIProviderUserEncounterID]),
    CONSTRAINT [FK_PQRIProviderUserEncounterNumeratorMatch_PQRIQualityMeasure] FOREIGN KEY ([PQRIQualityMeasureID]) REFERENCES [dbo].[PQRIQualityMeasure] ([PQRIQualityMeasureID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PQRIProviderUserEncounterNumeratorMatch_EncounterIDAndMeasureID]
    ON [dbo].[PQRIProviderUserEncounterNumeratorMatch]([PQRIProviderUserEncounterID] ASC, [PQRIQualityMeasureID] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounterNumeratorMatch', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounterNumeratorMatch', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounterNumeratorMatch', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderUserEncounterNumeratorMatch', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

