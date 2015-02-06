CREATE TABLE [dbo].[TaskAttemptsCommunicationLog] (
    [TaskAttemptsCommunicationLogId] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [CommunicationTypeID]            [dbo].[KeyID]      NULL,
    [NoOfCommunication]              [dbo].[KeyID]      NULL,
    [FilePath]                       VARCHAR (200)      NULL,
    [StatusCode]                     [dbo].[StatusCode] CONSTRAINT [DF_TaskAttemptsCommunicationLog_StatusCode] DEFAULT ('P') NOT NULL,
    [CreatedByUserId]                [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                    [dbo].[UserDate]   CONSTRAINT [DF_TaskAttemptsCommunicationLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedDate]               [dbo].[UserDate]   NULL,
    [LastModifiedByUserId]           [dbo].[KeyID]      NULL,
    CONSTRAINT [PK_TaskAttemptsCommunicationLog] PRIMARY KEY CLUSTERED ([TaskAttemptsCommunicationLogId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttemptsCommunicationLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttemptsCommunicationLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttemptsCommunicationLog', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskAttemptsCommunicationLog', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';

