CREATE TABLE [dbo].[PQRIQualityMeasure] (
    [PQRIQualityMeasureID]         [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PQRIMeasureID]                [dbo].[KeyID]           NOT NULL,
    [Name]                         VARCHAR (200)           NOT NULL,
    [Description]                  [dbo].[LongDescription] NOT NULL,
    [StatusCode]                   [dbo].[StatusCode]      CONSTRAINT [DF_PQRIQualityMeasure_StatusCode] DEFAULT ('A') NOT NULL,
    [ReportingYear]                SMALLINT                NULL,
    [ReportingPeriod]              SMALLINT                NULL,
    [ReportingPeriodType]          VARCHAR (1)             NULL,
    [PerformancePeriod]            SMALLINT                NULL,
    [PerformancePeriodType]        VARCHAR (1)             NULL,
    [IsBFFS]                       [dbo].[IsIndicator]     NOT NULL,
    [DocumentLibraryID]            [dbo].[KeyID]           NULL,
    [DocumentStartPage]            INT                     NULL,
    [SubmissionMethod]             VARCHAR (2)             NULL,
    [ReportingMethod]              VARCHAR (20)            NULL,
    [Note]                         VARCHAR (200)           NULL,
    [CreatedByUserId]              [dbo].[KeyID]           NOT NULL,
    [CreatedDate]                  [dbo].[UserDate]        CONSTRAINT [DF_PQRIQualityMeasure_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]         [dbo].[KeyID]           NULL,
    [LastModifiedDate]             [dbo].[UserDate]        NULL,
    [MigratedPQRIQualityMeasureID] [dbo].[KeyID]           NULL,
    [IsAllowEdit]                  [dbo].[IsIndicator]     CONSTRAINT [DF_PQRIQualityMeasure_IsAllowEdit] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_PQRIQualityMeasure] PRIMARY KEY CLUSTERED ([PQRIQualityMeasureID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [CK_PQRIQualityMeasure_PerformancePeriodType] CHECK ([PerformancePeriodType]='Y' OR [PerformancePeriodType]='M'),
    CONSTRAINT [CK_PQRIQualityMeasure_ReportingMethod] CHECK ([ReportingMethod]='Both' OR [ReportingMethod]='30 Head Count' OR [ReportingMethod]='80% Total Patients'),
    CONSTRAINT [CK_PQRIQualityMeasure_ReportingPeriodType] CHECK ([ReportingPeriodType]='Y' OR [ReportingPeriodType]='M'),
    CONSTRAINT [CK_PQRIQualityMeasure_SubmissionMethod] CHECK ([SubmissionMethod]='CR' OR [SubmissionMethod]='RY' OR [SubmissionMethod]='CS'),
    CONSTRAINT [FK_PQRIQualityMeasure_Library] FOREIGN KEY ([DocumentLibraryID]) REFERENCES [dbo].[Library] ([LibraryId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PQRIQualityMeasure_PQRIMeasureIDReportingYear]
    ON [dbo].[PQRIQualityMeasure]([PQRIMeasureID] ASC, [ReportingYear] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasure', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasure', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasure', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

