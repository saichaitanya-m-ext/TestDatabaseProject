CREATE TABLE [dbo].[PatientInsurance] (
    [PatientInsuranceID]     [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PatientID]              [dbo].[KeyID]      NOT NULL,
    [InsuranceGroupPlanId]   [dbo].[KeyID]      NULL,
    [SuperGroupCategory]     [dbo].[SourceName] NULL,
    [EmployerGroupID]        [dbo].[KeyID]      NULL,
    [StatusCode]             [dbo].[StatusCode] CONSTRAINT [DF_PatientInsurance_StatusCode] DEFAULT ('A') NOT NULL,
    [MemberID]               VARCHAR (80)       NOT NULL,
    [PolicyNumber]           VARCHAR (80)       NULL,
    [SecondaryPolicyNumber]  VARCHAR (80)       NULL,
    [GroupNumber]            VARCHAR (80)       NULL,
    [DependentSequenceNo]    VARCHAR (2)        NULL,
    [SequenceNo]             [dbo].[KeyID]      NULL,
    [PolicyHolderPatientID]  [dbo].[KeyID]      NULL,
    [PolicyHolderRelationID] [dbo].[KeyID]      NULL,
    [DataSourceID]           [dbo].[KeyID]      NULL,
    [DataSourceFileID]       [dbo].[KeyID]      NULL,
    [RecordTag_FileID]       VARCHAR (30)       NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NOT NULL,
    [CreatedDate]            [dbo].[UserDate]   CONSTRAINT [DF_PatientInsurance_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]      NULL,
    [LastModifiedDate]       [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_PatientInsurance] PRIMARY KEY CLUSTERED ([PatientInsuranceID] ASC),
    CONSTRAINT [FK_PatientInsurance_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_PatientInsurance_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_PatientInsurance_EmployerGroup] FOREIGN KEY ([EmployerGroupID]) REFERENCES [dbo].[EmployerGroup] ([EmployerGroupID]),
    CONSTRAINT [FK_PatientInsurance_InsuranceGroupPlan] FOREIGN KEY ([InsuranceGroupPlanId]) REFERENCES [dbo].[InsuranceGroupPlan] ([InsuranceGroupPlanId]),
    CONSTRAINT [FK_PatientInsurance_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientInsurance_PatientHolder] FOREIGN KEY ([PolicyHolderPatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_PatientID_PatientInsurance]
    ON [dbo].[PatientInsurance]([PatientID] ASC)
    INCLUDE([PatientInsuranceID]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_PatientInsuranceID_PatientInsurance]
    ON [dbo].[PatientInsurance]([PatientInsuranceID] ASC, [InsuranceGroupPlanId] ASC, [PolicyNumber] ASC, [GroupNumber] ASC, [EmployerGroupID] ASC, [PatientID] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_PolicyHolderPatientID_PatientInsurance]
    ON [dbo].[PatientInsurance]([InsuranceGroupPlanId] ASC, [PolicyNumber] ASC, [GroupNumber] ASC, [PatientID] ASC, [PolicyHolderPatientID] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_StatusCode_PatientInsurance]
    ON [dbo].[PatientInsurance]([InsuranceGroupPlanId] ASC, [StatusCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_PatientInsurance_PatientInsuranceID_InsuranceGroupPlanId_PatientID]
    ON [dbo].[PatientInsurance]([PatientInsuranceID], [InsuranceGroupPlanId], [PatientID]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of the insurance policys for a patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserInsurance table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'PatientInsuranceID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Super Group Category of the insurance policy', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'SuperGroupCategory';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientInsurance', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

