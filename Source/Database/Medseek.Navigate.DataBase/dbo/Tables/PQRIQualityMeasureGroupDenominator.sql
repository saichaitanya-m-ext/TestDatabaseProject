CREATE TABLE [dbo].[PQRIQualityMeasureGroupDenominator] (
    [PQRIQualityMeasureGroupDenominatorID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PQRIQualityMeasureGroupID]            [dbo].[KeyID]      NOT NULL,
    [Operator1]                            VARCHAR (3)        NULL,
    [ICDCodeList]                          VARCHAR (MAX)      NULL,
    [Operator2]                            VARCHAR (3)        NULL,
    [CPTCodeList]                          VARCHAR (MAX)      NULL,
    [CriteriaSQL]                          VARCHAR (MAX)      NOT NULL,
    [StatusCode]                           [dbo].[StatusCode] CONSTRAINT [DF_PQRIQualityMeasureGroupDenominator_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]                      [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                          [dbo].[UserDate]   CONSTRAINT [DF_PQRIQualityMeasureGroupDenominator_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]                 [dbo].[KeyID]      NULL,
    [LastModifiedDate]                     [dbo].[UserDate]   NULL,
    [AgeFrom]                              SMALLINT           NULL,
    [AgeTo]                                SMALLINT           NULL,
    [Gender]                               [dbo].[Unit]       NULL,
    [CriteriaText]                         VARCHAR (MAX)      NOT NULL,
    CONSTRAINT [PK_PQRIQualityMeasureGroupDenominator] PRIMARY KEY CLUSTERED ([PQRIQualityMeasureGroupDenominatorID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [CK_PQRIQualityMeasureGroupDenominator_Operator1] CHECK ([Operator1]='OR' OR [Operator1]='AND'),
    CONSTRAINT [CK_PQRIQualityMeasureGroupDenominator_Operator2] CHECK ([Operator2]='OR' OR [Operator2]='AND'),
    CONSTRAINT [FK_PQRIQualityMeasureGroupDenominator_PQRIQualityMeasureGroup] FOREIGN KEY ([PQRIQualityMeasureGroupID]) REFERENCES [dbo].[PQRIQualityMeasureGroup] ([PQRIQualityMeasureGroupID])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupDenominator', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupDenominator', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupDenominator', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureGroupDenominator', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

