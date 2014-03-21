CREATE TABLE [dbo].[ApplicationErrorLog] (
    [ErrorID]          [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [UserID]           [dbo].[KeyID]            NULL,
    [IpAddress]        NVARCHAR (20)            NULL,
    [ErrorDescription] NVARCHAR (1000)          NULL,
    [PageName]         [dbo].[ShortDescription] NULL,
    [TraceDescription] NVARCHAR (1000)          NULL,
    [Status]           VARCHAR (15)             CONSTRAINT [DF_ApplicationErrorLog_StatusCode] DEFAULT ('Open') NULL,
    [CreatedByUserID]  [dbo].[KeyID]            NOT NULL,
    [CreatedDate]      [dbo].[UserDate]         CONSTRAINT [DF_ApplicationErrorLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [UpdatedByUserID]  [dbo].[KeyID]            NULL,
    [UpdatedDate]      NCHAR (10)               NULL,
    [Remarks]          NVARCHAR (1000)          NULL,
    CONSTRAINT [PK_ApplicationErrorLog] PRIMARY KEY CLUSTERED ([ErrorID] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ApplicationErrorLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ApplicationErrorLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';

