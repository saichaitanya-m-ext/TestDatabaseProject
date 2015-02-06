CREATE TABLE [dbo].[PQRIProviderPersonalization] (
    [PQRIProviderPersonalizationID]      [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [ProviderUserID]                     [dbo].[KeyID]       NULL,
    [ReportingYear]                      SMALLINT            NULL,
    [ReportingPeriod]                    VARCHAR (1)         NULL,
    [SubmissionMethod]                   VARCHAR (2)         NULL,
    [QualityMeasureReportingMethod]      VARCHAR (20)        NULL,
    [QualityMeasureGroupReportingMethod] VARCHAR (50)        NULL,
    [IsAllowEdit]                        [dbo].[IsIndicator] CONSTRAINT [DF_PQRIProviderPersonalization_IsAllowEdit] DEFAULT ((1)) NOT NULL,
    [StatusCode]                         [dbo].[StatusCode]  CONSTRAINT [DF_PQRIProviderPersonalization_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                    [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                        [dbo].[UserDate]    CONSTRAINT [DF_PQRIProviderPersonalization_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]               [dbo].[KeyID]       NULL,
    [LastModifiedDate]                   [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_PQRIProviderPersonalization] PRIMARY KEY CLUSTERED ([PQRIProviderPersonalizationID] ASC) ON [FG_Library],
    CONSTRAINT [CK_PQRIProviderPersonalization_QualityMeasureGroupReportingMethod] CHECK ([QualityMeasureGroupReportingMethod]='30 Head Count' OR [QualityMeasureGroupReportingMethod]='80% Total Patients' OR [QualityMeasureGroupReportingMethod]='80% Total Patients,30 Head Count'),
    CONSTRAINT [CK_PQRIProviderPersonalization_QualityMeasureReportingMethod] CHECK ([QualityMeasureReportingMethod]='80% Total Patients'),
    CONSTRAINT [CK_PQRIProviderPersonalization_ReportingPeriod] CHECK ([ReportingPeriod]='H' OR [ReportingPeriod]='Y'),
    CONSTRAINT [CK_PQRIProviderPersonalization_SubmissionMethod] CHECK ([SubmissionMethod]='CR' OR [SubmissionMethod]='RY' OR [SubmissionMethod]='CS')
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PQRIProviderPersonalization_ProviderUserId_ReportingYear]
    ON [dbo].[PQRIProviderPersonalization]([ProviderUserID] ASC, [ReportingYear] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderPersonalization', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderPersonalization', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderPersonalization', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIProviderPersonalization', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

