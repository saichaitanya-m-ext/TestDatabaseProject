CREATE TABLE [dbo].[CodeSetRxSubmissionClarification] (
    [RxSubmissionClarificationID]   [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [RxSubmissionClarification]     VARCHAR (5)             NOT NULL,
    [RxSubmissionClarificationName] VARCHAR (30)            NOT NULL,
    [CodeDescription]               [dbo].[LongDescription] NULL,
    [DataSourceID]                  [dbo].[KeyID]           NULL,
    [DataSourceFileID]              [dbo].[KeyID]           NULL,
    [StatusCode]                    [dbo].[StatusCode]      CONSTRAINT [DF_CodeSetRxSubmissionClarification_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]               INT                     NOT NULL,
    [CreatedDate]                   DATETIME                CONSTRAINT [DF_CodeSetRxSubmissionClarification_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]          INT                     NULL,
    [LastModifiedDate]              DATETIME                NULL,
    CONSTRAINT [PK_CodeSetRxSubmissionClarification] PRIMARY KEY CLUSTERED ([RxSubmissionClarificationID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetRxSubmissionClarification_CodeSetDataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [dbo].[CodeSetDataSource] ([DataSourceId]),
    CONSTRAINT [FK_CodeSetRxSubmissionClarification_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxSubmissionClarification_RxSubmissionClarification]
    ON [dbo].[CodeSetRxSubmissionClarification]([RxSubmissionClarification] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_CodeSetRxSubmissionClarification_RxSubmissionClarificationName]
    ON [dbo].[CodeSetRxSubmissionClarification]([RxSubmissionClarificationName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Codesets_NCX];

