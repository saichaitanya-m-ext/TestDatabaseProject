CREATE TABLE [dbo].[InsuranceGroupPlan] (
    [InsuranceGroupPlanId] [dbo].[KeyID]       IDENTITY (1, 1) NOT NULL,
    [InsuranceGroupId]     [dbo].[KeyID]       NOT NULL,
    [PlanName]             [dbo].[SourceName]  NOT NULL,
    [ProductType]          CHAR (1)            NULL,
    [IsMedicaid]           [dbo].[IsIndicator] NULL,
    [StatusCode]           [dbo].[StatusCode]  CONSTRAINT [DF_InsuranceGroupPlan_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]       NOT NULL,
    [CreatedDate]          [dbo].[UserDate]    CONSTRAINT [DF_InsuranceGroupPlan_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]       NULL,
    [LastModifiedDate]     [dbo].[UserDate]    NULL,
    [HealthPlanCoverageID] [dbo].[KeyID]       NULL,
    CONSTRAINT [PK_InsuranceGroupPlan] PRIMARY KEY CLUSTERED ([InsuranceGroupPlanId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_InsuranceGroupPlan_HealthPlanCoverage] FOREIGN KEY ([HealthPlanCoverageID]) REFERENCES [dbo].[HealthPlanCoverage] ([HealthPlanCoverageID]),
    CONSTRAINT [FK_InsuranceGroupPlan_InsuranceGroup] FOREIGN KEY ([InsuranceGroupId]) REFERENCES [dbo].[InsuranceGroup] ([InsuranceGroupID])
);


GO
CREATE NONCLUSTERED INDEX [IX_InsuranceGroupPlan_CoveringIndex]
    ON [dbo].[InsuranceGroupPlan]([InsuranceGroupPlanId] ASC, [InsuranceGroupId] ASC, [PlanName] ASC, [ProductType] ASC, [HealthPlanCoverageID] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_InsuranceGroupPlan_ProductType_StatusCode]
    ON [dbo].[InsuranceGroupPlan]([InsuranceGroupId] ASC, [ProductType] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_InsuranceGroupPlan_ProductType_PlanCoverageID_StatusCode]
    ON [dbo].[InsuranceGroupPlan]([InsuranceGroupPlanId] ASC, [ProductType] ASC, [HealthPlanCoverageID] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_InsuranceGroupPlan_PlanName]
    ON [dbo].[InsuranceGroupPlan]([PlanName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Insurance Group Plan name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the InsuranceGroupPlan table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'InsuranceGroupPlanId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the InsuranceGroup Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'InsuranceGroupId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Insurance group Plan Name (PPO, HMO, …)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'PlanName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Alter the column by adding foreign key to the "HealthPlanCoverage" table (column ''HealthPlanCoverageID'').  And also, alter column to not permit NULL values.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InsuranceGroupPlan', @level2type = N'COLUMN', @level2name = N'HealthPlanCoverageID';

