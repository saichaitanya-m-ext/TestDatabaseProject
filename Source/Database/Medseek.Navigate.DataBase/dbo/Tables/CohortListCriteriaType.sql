CREATE TABLE [dbo].[CohortListCriteriaType] (
    [CohortListCriteriaTypeId] INT          IDENTITY (1, 1) NOT NULL,
    [CriteriaTypeName]         VARCHAR (50) NOT NULL,
    [CreatedByUserId]          INT          NOT NULL,
    [CreatedDate]              DATETIME     CONSTRAINT [DF_CohortListCriteriaType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]     INT          NULL,
    [LastModifiedDate]         DATETIME     NULL,
    CONSTRAINT [PK_CohortListCriteriaType] PRIMARY KEY CLUSTERED ([CohortListCriteriaTypeId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CohortListCriteriaType_CriteriaTypeName]
    ON [dbo].[CohortListCriteriaType]([CriteriaTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Category for Cohort list criteria statements', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key to the CohortCriteriaType Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'CohortListCriteriaTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'name of the Cohort Type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'CriteriaTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CohortListCriteriaType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

