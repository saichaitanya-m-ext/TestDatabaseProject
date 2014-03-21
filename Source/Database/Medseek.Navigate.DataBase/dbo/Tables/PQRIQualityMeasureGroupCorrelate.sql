CREATE TABLE [dbo].[PQRIQualityMeasureGroupCorrelate] (
    [PQRIQualityMeasureGroupCorrelateID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PQRIQualityMeasureGroupID]          [dbo].[KeyID]    NOT NULL,
    [PQRIQualityMeasureCorrelateIDList]  VARCHAR (500)    NOT NULL,
    [AgeFrom]                            SMALLINT         NULL,
    [AgeTo]                              SMALLINT         NULL,
    [Gender]                             [dbo].[Unit]     NULL,
    [BMIFrom]                            DECIMAL (5, 3)   NULL,
    [BMITo]                              DECIMAL (5, 3)   NULL,
    [CreatedByUserId]                    [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                        [dbo].[UserDate] CONSTRAINT [DF_PQRIQualityMeasureGroupCorrelate_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]               [dbo].[KeyID]    NULL,
    [LastModifiedDate]                   [dbo].[UserDate] NULL,
    CONSTRAINT [PK_PQRIQualityMeasureGroupCorrelate] PRIMARY KEY CLUSTERED ([PQRIQualityMeasureGroupCorrelateID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PQRIQualityMeasureGroupCorrelate_PQRIQualityMeasureGroup] FOREIGN KEY ([PQRIQualityMeasureGroupID]) REFERENCES [dbo].[PQRIQualityMeasureGroup] ([PQRIQualityMeasureGroupID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupCorrelate', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupCorrelate', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupCorrelate', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupCorrelate', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

