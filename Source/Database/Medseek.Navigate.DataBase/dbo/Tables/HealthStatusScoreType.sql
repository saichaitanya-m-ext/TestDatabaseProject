CREATE TABLE [dbo].[HealthStatusScoreType] (
    [HealthStatusScoreId]         [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [Name]                        [dbo].[ShortDescription] NOT NULL,
    [HealthStatusScoreOrgId]      [dbo].[KeyID]            NULL,
    [Description]                 VARCHAR (500)            NULL,
    [SortOrder]                   [dbo].[KeyID]            CONSTRAINT [DF_HealthStatusScoreType_SortOrder] DEFAULT ((1)) NULL,
    [StatusCode]                  [dbo].[StatusCode]       CONSTRAINT [DF_HealthStatusScoreType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]             [dbo].[KeyID]            NOT NULL,
    [CreatedDate]                 [dbo].[UserDate]         CONSTRAINT [DF_HealthStatusScoreType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]        [dbo].[KeyID]            NULL,
    [LastModifiedDate]            [dbo].[UserDate]         NULL,
    [Operator1forGoodScore]       VARCHAR (20)             NULL,
    [Operator1Value1forGoodScore] DECIMAL (10, 2)          NULL,
    [Operator1Value2forGoodScore] DECIMAL (10, 2)          NULL,
    [Operator2forGoodScore]       VARCHAR (20)             NULL,
    [Operator2Value1forGoodScore] DECIMAL (10, 2)          NULL,
    [Operator2Value2forGoodScore] DECIMAL (10, 2)          NULL,
    [TextValueforGoodScore]       [dbo].[SourceName]       NULL,
    [Operator1forFairScore]       VARCHAR (20)             NULL,
    [Operator1Value1forFairScore] DECIMAL (10, 2)          NULL,
    [Operator1Value2forFairScore] DECIMAL (10, 2)          NULL,
    [Operator2forFairScore]       VARCHAR (20)             NULL,
    [Operator2Value1forFairScore] DECIMAL (10, 2)          NULL,
    [Operator2Value2forFairScore] DECIMAL (10, 2)          NULL,
    [TextValueforFairScore]       [dbo].[SourceName]       NULL,
    [Operator1forPoorScore]       VARCHAR (20)             NULL,
    [Operator1Value1forPoorScore] DECIMAL (10, 2)          NULL,
    [Operator1Value2forPoorScore] DECIMAL (10, 2)          NULL,
    [Operator2forPoorScore]       VARCHAR (20)             NULL,
    [Operator2Value1forPoorScore] DECIMAL (10, 2)          NULL,
    [Operator2Value2forPoorScore] DECIMAL (10, 2)          NULL,
    [TextValueforPoorScore]       [dbo].[SourceName]       NULL,
    CONSTRAINT [PK_HealthStatusScoreType] PRIMARY KEY CLUSTERED ([HealthStatusScoreId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_HealthStatusScoreType_HealthStatusScoreOrganization] FOREIGN KEY ([HealthStatusScoreOrgId]) REFERENCES [dbo].[HealthStatusScoreOrganization] ([HealthStatusScoreOrgId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_HealthStatusScoreType_Name_ScoreOrgID]
    ON [dbo].[HealthStatusScoreType]([Name] ASC, [HealthStatusScoreOrgId] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Health Risk formula category', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the HealthStatusScoreType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'HealthStatusScoreId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'HealthStatusScoreType Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the HealthStatusScoreOrganization table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'HealthStatusScoreOrgId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for HealthStatusScoreType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alternate Sort order for HealthStatusScoreType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'SortOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthStatusScoreType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

