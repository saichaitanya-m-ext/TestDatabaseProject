CREATE TABLE [dbo].[PQRIQualityMeasureDenominator] (
    [PQRIQualityMeasureDenominatorID] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PQRIQualityMeasureID]            [dbo].[KeyID]      NOT NULL,
    [AgeFrom]                         SMALLINT           NULL,
    [AgeTo]                           SMALLINT           NULL,
    [Gender]                          [dbo].[Unit]       NULL,
    [Operator1]                       VARCHAR (3)        NULL,
    [ICDCodeList]                     VARCHAR (MAX)      NULL,
    [Operator2]                       VARCHAR (3)        NULL,
    [CPTCodeList]                     VARCHAR (MAX)      NULL,
    [CriteriaSQL]                     VARCHAR (MAX)      NULL,
    [StatusCode]                      [dbo].[StatusCode] CONSTRAINT [DF_PQRIQualityMeasureDenominator_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId]                 [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                     [dbo].[UserDate]   CONSTRAINT [DF_PQRIQualityMeasureDenominator_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]            [dbo].[KeyID]      NULL,
    [LastModifiedDate]                [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_PQRIQualityMeasureDenominator] PRIMARY KEY CLUSTERED ([PQRIQualityMeasureDenominatorID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [CK_PQRIQualityMeasureDenominator_Gender] CHECK ([Gender]='B' OR [Gender]='F' OR [Gender]='M'),
    CONSTRAINT [CK_PQRIQualityMeasureDenominator_Operator1] CHECK ([Operator1]='OR' OR [Operator1]='AND'),
    CONSTRAINT [CK_PQRIQualityMeasureDenominator_Operator2] CHECK ([Operator2]='OR' OR [Operator2]='AND'),
    CONSTRAINT [FK_PQRIQualityMeasureDenominator_PQRIQualityMeasure] FOREIGN KEY ([PQRIQualityMeasureID]) REFERENCES [dbo].[PQRIQualityMeasure] ([PQRIQualityMeasureID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PQRIQualityMeasureDenominator_PQRIQualityMeasureID]
    ON [dbo].[PQRIQualityMeasureDenominator]([PQRIQualityMeasureID] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureDenominator', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureDenominator', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureDenominator', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PQRIQualityMeasureDenominator', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

