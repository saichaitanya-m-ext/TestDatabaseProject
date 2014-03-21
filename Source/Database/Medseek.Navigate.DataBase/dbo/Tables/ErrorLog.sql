CREATE TABLE [dbo].[ErrorLog] (
    [ErrorLogId]       [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [UserId]           [dbo].[KeyID]    NULL,
    [ErrorCodeId]      [dbo].[KeyID]    NULL,
    [CurrentUser]      NVARCHAR (128)   NULL,
    [SystemUser]       NVARCHAR (128)   NULL,
    [ErrorDate]        [dbo].[UserDate] NOT NULL,
    [ErrorNumber]      [dbo].[KeyID]    NULL,
    [ErrorMessage]     NVARCHAR (1024)  NULL,
    [ErrorSeverity]    [dbo].[KeyID]    NULL,
    [ErrorState]       [dbo].[KeyID]    NULL,
    [ErrorLine]        [dbo].[KeyID]    NULL,
    [ErrorProcedure]   NVARCHAR (128)   NULL,
    [TransactionCount] [dbo].[KeyID]    NULL,
    [ErrorPage]        VARCHAR (200)    NULL,
    CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED ([ErrorLogId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_ErrorLog_ErrorCode] FOREIGN KEY ([ErrorCodeId]) REFERENCES [dbo].[ErrorCode] ([ErrorCodeId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Log of error codes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the users table indicates the user that received the error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'UserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the ErrorCode table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorCodeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The User ID of the current user', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'CurrentUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the error occurred', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of the error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The error message text', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Error Severity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorSeverity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Line in the code that triggered the error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorLine';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Code procedure that triggered the error', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorProcedure';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Number of DB transactions that were open when the error occurred', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'TransactionCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Page that triggered the code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ErrorLog', @level2type = N'COLUMN', @level2name = N'ErrorPage';

