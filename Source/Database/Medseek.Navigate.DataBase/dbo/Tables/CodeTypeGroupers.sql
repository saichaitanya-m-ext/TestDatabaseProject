CREATE TABLE [dbo].[CodeTypeGroupers] (
    [CodeTypeGroupersID]       [dbo].[KeyID]  IDENTITY (1, 1) NOT NULL,
    [CodeGroupingTypeID]       [dbo].[KeyID]  NOT NULL,
    [CodeTypeGroupersName]     VARCHAR (100)  NOT NULL,
    [CodeTypeShortDescription] VARCHAR (500)  NULL,
    [RoutineName]              VARCHAR (1500) NULL,
    [StatusCode]               VARCHAR (20)   NOT NULL,
    [CreatedByUserID]          [dbo].[KeyID]  NOT NULL,
    [CreatedDate]              DATETIME       NOT NULL,
    [LastModifiedByUserId]     [dbo].[KeyID]  NULL,
    [LastModifiedDate]         DATETIME       NULL,
    CONSTRAINT [CodeTypeGroupers_PK] PRIMARY KEY CLUSTERED ([CodeTypeGroupersID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_CodeGroupingType_CodeTypeGroupers] FOREIGN KEY ([CodeGroupingTypeID]) REFERENCES [dbo].[CodeGroupingType] ([CodeGroupingTypeID])
);

