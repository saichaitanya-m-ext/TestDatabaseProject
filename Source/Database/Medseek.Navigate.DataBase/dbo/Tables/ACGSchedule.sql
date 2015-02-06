CREATE TABLE [dbo].[ACGSchedule] (
    [ACGScheduleID]        [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [ACGType]              VARCHAR (1)        NOT NULL,
    [ACGSubTypeID]         [dbo].[KeyID]      NULL,
    [Frequency]            VARCHAR (1)        NOT NULL,
    [StartDate]            [dbo].[UserDate]   NOT NULL,
    [DateOfLastExport]     [dbo].[UserDate]   NULL,
    [DateOfLastImport]     [dbo].[UserDate]   NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_ACGSchedule_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserid]      INT                NOT NULL,
    [CreatedDate]          [dbo].[UserDate]   CONSTRAINT [DF_ACGSchedule_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserid] INT                NULL,
    [LastModifiedDate]     [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_ACGSchedule] PRIMARY KEY CLUSTERED ([ACGScheduleID] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGSchedule', @level2type = N'COLUMN', @level2name = N'CreatedByUserid';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGSchedule', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGSchedule', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserid';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ACGSchedule', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

