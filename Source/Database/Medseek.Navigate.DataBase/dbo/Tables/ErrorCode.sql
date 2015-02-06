CREATE TABLE [dbo].[ErrorCode] (
    [ErrorCodeId]          [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [ErrorCode]            VARCHAR (20)            NOT NULL,
    [Description]          VARCHAR (200)           NOT NULL,
    [ErrorSeverity]        TINYINT                 NULL,
    [ErrorCause]           [dbo].[LongDescription] NULL,
    [ErrorAction]          VARCHAR (800)           NULL,
    [CreatedByUserId]      [dbo].[KeyID]           NOT NULL,
    [CreatedDate]          [dbo].[UserDate]        CONSTRAINT [DF_ErrorCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]           NULL,
    [LastModifiedDate]     [dbo].[UserDate]        NULL,
    [StatusCode]           [dbo].[StatusCode]      CONSTRAINT [DF_ErrorCode_StatusCode] DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_ErrorCode] PRIMARY KEY CLUSTERED ([ErrorCodeId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_ErrorCode_ErrorCode]
    ON [dbo].[ErrorCode]([ErrorCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Library_NCX];

