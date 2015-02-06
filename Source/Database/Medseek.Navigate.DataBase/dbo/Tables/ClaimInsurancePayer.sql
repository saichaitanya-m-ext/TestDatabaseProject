CREATE TABLE [dbo].[ClaimInsurancePayer] (
    [ClaimInsurancePayerID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]           [dbo].[KeyID]    NOT NULL,
    [InsuranceGroupID]      [dbo].[KeyID]    NOT NULL,
    [InsuranceGroupPlanID]  [dbo].[KeyID]    NULL,
    [PolicyNumber]          VARCHAR (80)     NULL,
    [GroupNumber]           VARCHAR (80)     NULL,
    [RankOrderOfLiability]  [dbo].[KeyID]    NOT NULL,
    [DataSourceID]          [dbo].[KeyID]    NULL,
    [DataSourceFileID]      [dbo].[KeyID]    NULL,
    [RecordTagFileID]       VARCHAR (30)     NULL,
    [StatusCode]            VARCHAR (1)      CONSTRAINT [DF_ClaimInsurancePayer_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]       [dbo].[KeyID]    NOT NULL,
    [CreatedDate]           [dbo].[UserDate] CONSTRAINT [DF_ClaimInsurancePayer_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]  [dbo].[KeyID]    NULL,
    [LastModifiedDate]      [dbo].[UserDate] NULL,
    CONSTRAINT [PK_ClaimInsurancePayers] PRIMARY KEY CLUSTERED ([ClaimInfoID] ASC, [InsuranceGroupID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_ClaimInsurancePayer_ClaimInfo] FOREIGN KEY ([ClaimInfoID]) REFERENCES [dbo].[ClaimInfo] ([ClaimInfoId]),
    CONSTRAINT [FK_ClaimInsurancePayer_CodesetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_ClaimInsurancePayer_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [FK_ClaimInsurancePayer_InsuranceGroup] FOREIGN KEY ([InsuranceGroupID]) REFERENCES [dbo].[InsuranceGroup] ([InsuranceGroupID]),
    CONSTRAINT [FK_ClaimInsurancePayer_InsuranceGroupPlan] FOREIGN KEY ([InsuranceGroupPlanID]) REFERENCES [dbo].[InsuranceGroupPlan] ([InsuranceGroupPlanId])
);

