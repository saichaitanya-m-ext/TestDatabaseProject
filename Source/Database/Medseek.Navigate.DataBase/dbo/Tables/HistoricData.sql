CREATE TABLE [dbo].[HistoricData] (
    [ActivityID]         INT            NOT NULL,
    [UserID]             INT            NULL,
    [UserLoginIPAddress] VARCHAR (20)   NOT NULL,
    [DateTime]           DATETIME       NOT NULL,
    [PageName]           VARCHAR (200)  NOT NULL,
    [ControlType]        VARCHAR (50)   NULL,
    [ActivityType]       VARCHAR (50)   NOT NULL,
    [ActivityDetails]    VARCHAR (1000) NULL,
    [PatientID]          [dbo].[KeyID]  NULL,
    [MRNNumber]          VARCHAR (80)   NULL,
    [RowID]              VARCHAR (10)   NULL,
    [GridDetails]        VARCHAR (100)  NULL,
    CONSTRAINT [PK_HistoricData] PRIMARY KEY CLUSTERED ([ActivityID] ASC, [DateTime] ASC)
);

