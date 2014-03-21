CREATE TABLE [dbo].[PQRIQualityMeasureNumerator] (
    [PQRIQualityMeasureID] [dbo].[KeyID]      NOT NULL,
    [PerformanceType]      VARCHAR (3)        NOT NULL,
    [CriteriaText]         VARCHAR (MAX)      NOT NULL,
    [CriteriaSQL]          VARCHAR (MAX)      NOT NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_PQRIQualityMeasureNumerator_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_PQRIQualityMeasureNumerator_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]      NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_PQRIQualityMeasureNumerator] PRIMARY KEY CLUSTERED ([PQRIQualityMeasureID] ASC, [PerformanceType] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [CK_PQRIQualityMeasureNumerator_PerformanceType] CHECK ([PerformanceType]='PNM' OR [PerformanceType]='OPE' OR [PerformanceType]='SPE' OR [PerformanceType]='PPE' OR [PerformanceType]='MPE' OR [PerformanceType]='MEP'),
    CONSTRAINT [FK_PQRIQualityMeasureNumerator_PQRIQualityMeasure] FOREIGN KEY ([PQRIQualityMeasureID]) REFERENCES [dbo].[PQRIQualityMeasure] ([PQRIQualityMeasureID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureNumerator', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureNumerator', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureNumerator', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureNumerator', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

