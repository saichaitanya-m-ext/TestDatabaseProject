CREATE TABLE [dbo].[MetricNumeratorRange] (
    [MetricNumeratorRangeId] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [MetricId]               [dbo].[KeyID]      NOT NULL,
    [FromOperator]           VARCHAR (20)       NULL,
    [FromRange]              SMALLINT           NULL,
    [ToOperator]             VARCHAR (20)       NULL,
    [ToRange]                SMALLINT           NULL,
    [EntityType]             VARCHAR (2)        NULL,
    [Goal]                   SMALLINT           NULL,
    [StatusCode]             [dbo].[StatusCode] NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]      NOT NULL,
    [CreatedDate]            [dbo].[UserDate]   NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]      NULL,
    [LastModifiedDate]       [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_MetricNumeratorRange] PRIMARY KEY CLUSTERED ([MetricNumeratorRangeId] ASC) ON [FG_Library]
);

