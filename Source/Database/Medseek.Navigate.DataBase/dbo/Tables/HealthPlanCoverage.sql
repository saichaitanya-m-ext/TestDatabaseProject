CREATE TABLE [dbo].[HealthPlanCoverage] (
    [HealthPlanCoverageID] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [Name]                 VARCHAR (100) NOT NULL,
    [CreatedByUserId]      INT           NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_HealthPlanCoverage_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_HealthPlanCoverage] PRIMARY KEY CLUSTERED ([HealthPlanCoverageID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_HealthPlanCoverage.Name]
    ON [dbo].[HealthPlanCoverage]([Name] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_HealthPlanCoverage_Name]
    ON [dbo].[HealthPlanCoverage]([HealthPlanCoverageID] ASC, [Name] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthPlanCoverage', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'HealthPlanCoverage', @level2type = N'COLUMN', @level2name = N'CreatedDate';

