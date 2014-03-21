CREATE TABLE [dbo].[TaskType] (
    [TaskTypeId]             [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [TaskTypeName]           [dbo].[SourceName]       NOT NULL,
    [Description]            [dbo].[ShortDescription] NULL,
    [StatusCode]             [dbo].[StatusCode]       CONSTRAINT [DF_TaskType_IsActive] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]            NOT NULL,
    [CreatedDate]            [dbo].[UserDate]         CONSTRAINT [DF_TaskType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]            NULL,
    [LastModifiedDate]       [dbo].[UserDate]         NULL,
    [ScheduledDays]          INT                      NULL,
    [DestinationPage]        VARCHAR (200)            NULL,
    [AllowSpecificSchedules] BIT                      NULL,
    CONSTRAINT [PK_TaskType] PRIMARY KEY CLUSTERED ([TaskTypeId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TaskType_TaskTypeName]
    ON [dbo].[TaskType]([TaskTypeName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The list of taks types (Schedule Appointment, Schedule Procedure, Evaluate Lab Results,…)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the TaskType Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'TaskTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the Task type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'TaskTypeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Description for TaskType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Status Code Valid values are I = Inactive, A = Active', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'StatusCode';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of days before a task moves from scheduled to open status', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'ScheduledDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The physical page in the application that creates and resolves the specific task type', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskType', @level2type = N'COLUMN', @level2name = N'DestinationPage';

