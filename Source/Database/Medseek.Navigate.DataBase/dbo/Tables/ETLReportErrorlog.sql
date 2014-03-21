CREATE TABLE [dbo].[ETLReportErrorlog] (
    [ETLReportErrorlogId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [DenominatorId]       [dbo].[KeyID]    NOT NULL,
    [MetricId]            [dbo].[KeyID]    NULL,
    [ErrorQuerry]         VARCHAR (1000)   NULL,
    [ErrorMessage]        VARCHAR (1000)   NULL,
    [CreatedDate]         [dbo].[UserDate] CONSTRAINT [DF_ETLReportErrorlog_CreatedDate] DEFAULT (getdate()) NULL,
    [DateKey]             INT              NULL,
    CONSTRAINT [PK_ETLReportErrorlog] PRIMARY KEY CLUSTERED ([ETLReportErrorlogId] ASC) ON [FG_Library]
);

