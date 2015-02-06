CREATE TABLE [dbo].[PatientTimeStamp] (
    [DashboardTimestampId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [CareProviderid]       [dbo].[KeyID]    NOT NULL,
    [PatientUserID]        [dbo].[KeyID]    NOT NULL,
    [InDateTime]           [dbo].[UserDate] CONSTRAINT [DF_PatientTimeStamp_InDateTime] DEFAULT (getdate()) NOT NULL,
    [OutDateTime]          [dbo].[UserDate] NULL,
    [SystemGUID]           VARCHAR (150)    NULL,
    CONSTRAINT [PK_PatientTimeStamp] PRIMARY KEY CLUSTERED ([DashboardTimestampId] ASC) ON [FG_Library]
);

