CREATE TABLE [dbo].[MetricNumeratorFrequency] (
    [MetricNumeratorFrequencyId] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [MetricId]                   [dbo].[KeyID]      NOT NULL,
    [FromOperator]               VARCHAR (20)       NULL,
    [FromFrequency]              VARCHAR (6)        NULL,
    [ToOperator]                 VARCHAR (20)       NULL,
    [ToFrequency]                VARCHAR (6)        NULL,
    [EntityType]                 VARCHAR (2)        NULL,
    [Goal]                       INT                NULL,
    [StatusCode]                 [dbo].[StatusCode] CONSTRAINT [DF_MetricNumerator_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]            [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                [dbo].[UserDate]   CONSTRAINT [DF_MetricNumerator_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]       [dbo].[KeyID]      NULL,
    [LastModifiedDate]           [dbo].[UserDate]   NULL,
    [Label]                      VARCHAR (2)        NULL,
    CONSTRAINT [PK_MetricNumerator] PRIMARY KEY CLUSTERED ([MetricNumeratorFrequencyId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_MetricNumerator_Metrics] FOREIGN KEY ([MetricId]) REFERENCES [dbo].[Metric] ([MetricId])
);

