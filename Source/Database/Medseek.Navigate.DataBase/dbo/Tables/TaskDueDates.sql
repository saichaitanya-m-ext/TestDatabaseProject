CREATE TABLE [dbo].[TaskDueDates] (
    [TaskDueDateId]   [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [Description]     VARCHAR (100)      NOT NULL,
    [Value]           VARCHAR (5)        NULL,
    [StatusCode]      [dbo].[StatusCode] CONSTRAINT [DF_TaskDueDates_StatusCode] DEFAULT ('A') NULL,
    [CreatedByUserId] [dbo].[KeyID]      NULL,
    [CreatedDate]     [dbo].[UserDate]   CONSTRAINT [DF_TaskDueDates_CreatedDate] DEFAULT (getdate()) NULL,
    [TaskStatus]      VARCHAR (1)        NULL,
    CONSTRAINT [PK_TaskDueDates] PRIMARY KEY CLUSTERED ([TaskDueDateId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TaskDueDates_Description]
    ON [dbo].[TaskDueDates]([Description] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskDueDates', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskDueDates', @level2type = N'COLUMN', @level2name = N'CreatedDate';

