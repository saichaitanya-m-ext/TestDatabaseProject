CREATE TABLE [dbo].[UserActivityLog] (
    [ActivityID]         INT           IDENTITY (1, 1) NOT NULL,
    [UserID]             INT           NULL,
    [UserLoginIPAddress] VARCHAR (200) NULL,
    [DateTime]           DATETIME      NOT NULL,
    [PageName]           VARCHAR (200) NOT NULL,
    [ControlType]        VARCHAR (50)  NULL,
    [ActivityType]       VARCHAR (50)  NOT NULL,
    [ActivityDetails]    VARCHAR (MAX) NULL,
    [PatientID]          [dbo].[KeyID] NULL,
    [MRNNumber]          VARCHAR (80)  NULL,
    [RowID]              VARCHAR (10)  NULL,
    [GridDetails]        VARCHAR (100) NULL,
    CONSTRAINT [PK_UserActivityLog] PRIMARY KEY CLUSTERED ([ActivityID] ASC, [DateTime] ASC)
);

