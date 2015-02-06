CREATE TABLE [dbo].[Report] (
    [ReportId]             INT                     IDENTITY (1, 1) NOT NULL,
    [ReportName]           [dbo].[LongDescription] NOT NULL,
    [StatusCode]           VARCHAR (1)             CONSTRAINT [DF_Reports_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                     NOT NULL,
    [CreatedDate]          DATETIME                CONSTRAINT [DF_Reports_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                     NULL,
    [LastModifiedDate]     DATETIME                NULL,
    [AliasName]            VARCHAR (100)           NULL,
    [IsProcessing]         BIT                     CONSTRAINT [DF_Report_IsProcessing] DEFAULT ((0)) NULL,
    [IsMetric]             BIT                     NULL,
    [IsStrategic]          BIT                     NULL,
    CONSTRAINT [PK_Reports] PRIMARY KEY CLUSTERED ([ReportId] ASC) ON [FG_Library]
);

