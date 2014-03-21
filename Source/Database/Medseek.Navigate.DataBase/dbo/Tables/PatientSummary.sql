CREATE TABLE [dbo].[PatientSummary] (
    [PatientSummaryId] INT             IDENTITY (1, 1) NOT NULL,
    [PatientUserId]    INT             NOT NULL,
    [LastVisit]        DATE            NULL,
    [CPTs]             VARCHAR (MAX)   NULL,
    [ICDs]             VARCHAR (MAX)   NULL,
    [NextVisit]        DATE            NULL,
    [Conditions]       VARCHAR (MAX)   NULL,
    [ConditionsCnt]    INT             NULL,
    [Populations]      VARCHAR (MAX)   NULL,
    [RiskScore]        DECIMAL (10, 2) NULL,
    [YTDUtilization]   MONEY           NULL,
    [ERVisits]         INT             NULL,
    [ERAmount]         MONEY           NULL,
    [RxUtilization]    DECIMAL (10, 2) NULL,
    [CreatedDate]      DATETIME        CONSTRAINT [DF_PatientSummary_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedDate] DATETIME        NULL,
    [PopulationCnt]    INT             NULL,
    CONSTRAINT [PK_PatientSummary] PRIMARY KEY CLUSTERED ([PatientSummaryId] ASC) ON [FG_Library]
);

