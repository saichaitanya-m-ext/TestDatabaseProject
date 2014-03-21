CREATE TABLE [dbo].[CodeGrouping] (
    [CodeGroupingID]          INT                IDENTITY (1, 1) NOT NULL,
    [CodeGroupingCode]        VARCHAR (4)        NULL,
    [CodeGroupingName]        VARCHAR (500)      NULL,
    [CodeGroupingDescription] VARCHAR (500)      NULL,
    [CodeTypeGroupersID]      [dbo].[KeyID]      NOT NULL,
    [NonModifiable]           BIT                CONSTRAINT [DF_CodeGroupingName_NonModifiable] DEFAULT ((1)) NULL,
    [IsPrimary]               BIT                NOT NULL,
    [ProductionStatus]        [dbo].[StatusCode] NULL,
    [DefinitionVersion]       VARCHAR (5)        CONSTRAINT [DF_CodeGroupingName_DefinitionVersion] DEFAULT ('1.0') NULL,
    [DisplayStatus]           BIT                NULL,
    [StatusCode]              [dbo].[StatusCode] CONSTRAINT [DF_CodeGroupingName_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]         [dbo].[KeyID]      NOT NULL,
    [CreatedDate]             DATETIME           CONSTRAINT [DF_CodeGroupingName_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]    [dbo].[KeyID]      NULL,
    [LastModifiedDate]        DATETIME           NULL,
    [SourceCodGroupingName]   VARCHAR (500)      NULL,
    CONSTRAINT [CodeGroupingName_PK] PRIMARY KEY CLUSTERED ([CodeGroupingID] ASC),
    CONSTRAINT [FK_CodeGrouping_CodeTypeGroupers] FOREIGN KEY ([CodeTypeGroupersID]) REFERENCES [dbo].[CodeTypeGroupers] ([CodeTypeGroupersID])
);


GO
CREATE NONCLUSTERED INDEX [IX_CodeGrouping_CodeTypeGroupersID]
    ON [dbo].[CodeGrouping]([CodeTypeGroupersID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeGrouping_CodeTypeGroupersID_CodeGroupingID]
    ON [dbo].[CodeGrouping]([CodeTypeGroupersID] ASC, [CodeGroupingID] ASC)
    INCLUDE([CodeGroupingName]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeGrouping_CodeTypeGroupersID_CodeGroupingID_CodeGroupingCode]
    ON [dbo].[CodeGrouping]([CodeTypeGroupersID] ASC, [CodeGroupingID] ASC, [CodeGroupingCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [IX_CodeGrouping_CodeTypeGroupersID_CodeGroupingID_CodeGroupingName]
    ON [dbo].[CodeGrouping]([CodeTypeGroupersID] ASC, [CodeGroupingID] ASC, [CodeGroupingName] ASC)
    INCLUDE([CodeGroupingDescription]) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE STATISTICS [stat_CodeGrouping_CodeGroupingID_CodeGroupingCode]
    ON [dbo].[CodeGrouping]([CodeGroupingID], [CodeGroupingCode]);


GO
CREATE STATISTICS [stat_CodeGrouping_CodeGroupingID_CodeGroupingName]
    ON [dbo].[CodeGrouping]([CodeGroupingID], [CodeGroupingName]);


GO
CREATE STATISTICS [stat_CodeGrouping_CodeGroupingID_CodeTypeGroupersID_CodeGroupingName]
    ON [dbo].[CodeGrouping]([CodeGroupingID], [CodeTypeGroupersID], [CodeGroupingName]);


GO
CREATE STATISTICS [stat_CodeGrouping_CodeTypeGroupersID_CodeGroupingCode_CodeGroupingID]
    ON [dbo].[CodeGrouping]([CodeTypeGroupersID], [CodeGroupingCode], [CodeGroupingID]);

