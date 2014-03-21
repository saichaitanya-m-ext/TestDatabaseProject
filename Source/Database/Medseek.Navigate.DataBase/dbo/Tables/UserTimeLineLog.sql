CREATE TABLE [dbo].[UserTimeLineLog] (
    [UserTimeLinelogID]     [dbo].[KeyID]           IDENTITY (1, 1) NOT NULL,
    [PatientID]             [dbo].[KeyID]           NULL,
    [Comments]              [dbo].[LongDescription] NULL,
    [TimelineDate]          [dbo].[UserDate]        NULL,
    [SubjectText]           [dbo].[LongDescription] NULL,
    [TimelineTypeID]        [dbo].[KeyID]           NULL,
    [CreatedByUserId]       [dbo].[KeyID]           NOT NULL,
    [CreatedDate]           [dbo].[UserDate]        CONSTRAINT [DF_UserTimelineLog_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]  [dbo].[KeyID]           NULL,
    [LastModifiedDate]      [dbo].[UserDate]        NULL,
    [MeasureValueNumeric]   DECIMAL (10, 2)         NULL,
    [UOMText]               [dbo].[SourceName]      NULL,
    [UserHealthStatusScore] DECIMAL (10, 2)         NULL,
    [HealthRiskType]        VARCHAR (120)           NULL,
    CONSTRAINT [PK_UserTimelineLog_1] PRIMARY KEY CLUSTERED ([UserTimeLinelogID] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A listing of medical events for a patients, a summary of all medical events by type and date.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserTimelineLog table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'UserTimeLinelogID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table (Patient User ID)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'PatientID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comments', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'Comments';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the Medical Event took place', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'TimelineDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Subject comment for the Medical Event', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'SubjectText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the TimeLineType table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'TimelineTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The measure value when numeric', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'MeasureValueNumeric';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Unit of measure for the measure value', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'UOMText';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'the Score for the health Risk teas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'UserHealthStatusScore';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The Type for the Health Risk Test - using this can get you to the Health Risk Score organization', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserTimeLineLog', @level2type = N'COLUMN', @level2name = N'HealthRiskType';

