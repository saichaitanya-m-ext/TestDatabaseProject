CREATE TABLE [dbo].[TaskAttemptsStatus] (
    [TaskAttemptsStatusId]  [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [Description]           [dbo].[ShortDescription] NOT NULL,
    [CallSequence]          TINYINT                  NULL,
    [DaysBeforeTermination] TINYINT                  NULL,
    [StatusCode]            [dbo].[StatusCode]       CONSTRAINT [DF_TaskAttemptsStatus_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]       [dbo].[KeyID]            NOT NULL,
    [CreatedDate]           DATETIME                 CONSTRAINT [DF_TaskAttemptsStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK__TaskAtte__C6BF122C0A14514D] PRIMARY KEY CLUSTERED ([TaskAttemptsStatusId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TaskAttemptsStatus.Description]
    ON [dbo].[TaskAttemptsStatus]([Description] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttemptsStatus', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttemptsStatus', @level2type = N'COLUMN', @level2name = N'CreatedDate';

