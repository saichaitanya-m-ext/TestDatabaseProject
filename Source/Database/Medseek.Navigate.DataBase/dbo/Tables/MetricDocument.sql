CREATE TABLE [dbo].[MetricDocument] (
    [MetricDocumentId]     INT             IDENTITY (1, 1) NOT NULL,
    [MetricId]             INT             NULL,
    [FileName]             VARCHAR (500)   NULL,
    [eDocument]            VARBINARY (MAX) NULL,
    [MimeType]             VARCHAR (20)    NULL,
    [CreatedByUserId]      INT             NOT NULL,
    [CreatedDate]          DATETIME        CONSTRAINT [DF_MetricDocument_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT             NULL,
    [LastModifiedDate]     DATETIME        NULL,
    CONSTRAINT [PK_MetricDocument] PRIMARY KEY CLUSTERED ([MetricDocumentId] ASC),
    CONSTRAINT [FK_MetricDocument_Metrics] FOREIGN KEY ([MetricId]) REFERENCES [dbo].[Metric] ([MetricId])
);

