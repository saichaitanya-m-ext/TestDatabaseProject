CREATE TABLE [dbo].[TaskTypeCommunications] (
    [TaskTypeCommunicationID]            [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [TaskTypeID]                         [dbo].[KeyID]      NOT NULL,
    [CommunicationSequence]              [dbo].[KeyID]      NOT NULL,
    [CommunicationTypeID]                [dbo].[KeyID]      NULL,
    [CommunicationAttemptDays]           INT                NULL,
    [NoOfDaysBeforeTaskClosedIncomplete] INT                NULL,
    [CreatedByUserId]                    [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                        [dbo].[UserDate]   CONSTRAINT [DF_TaskTypeCommunications_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]               [dbo].[KeyID]      NULL,
    [LastModifiedDate]                   [dbo].[UserDate]   NULL,
    [CommunicationTemplateID]            INT                NULL,
    [TaskTypeGeneralizedID]              INT                NULL,
    [StatusCode]                         [dbo].[StatusCode] CONSTRAINT [DF_TaskTypeCommunications_StatusCode] DEFAULT ('A') NOT NULL,
    [RemainderState]                     VARCHAR (1)        NULL,
    CONSTRAINT [PK_TaskTypeCommunications] PRIMARY KEY CLUSTERED ([TaskTypeCommunicationID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_TaskTypeCommunications_CommunicationTemplate] FOREIGN KEY ([CommunicationTemplateID]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_TaskTypeCommunications_CommunicationType] FOREIGN KEY ([CommunicationTypeID]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_TaskTypeCommunications_TaskType] FOREIGN KEY ([TaskTypeID]) REFERENCES [dbo].[TaskType] ([TaskTypeId])
);


GO
CREATE NONCLUSTERED INDEX [IX_TaskTypeCommunications_TaskTypeGeneralizedID]
    ON [dbo].[TaskTypeCommunications]([TaskTypeGeneralizedID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The media for a specific Task and attempt instance (phone Call, email, letter, SMS, Fax,…)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the TaskType Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'TaskTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Attempt sequence number 1st, 2nd, 3rd, 4th, … attempt to contact the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'CommunicationSequence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the CommunicationType Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'CommunicationTypeID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of days between tacks contact attempts are made to the patient', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'CommunicationAttemptDays';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The number of days the task will remain open after the last attempt to contact the patient is made.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'NoOfDaysBeforeTaskClosedIncomplete';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskTypeCommunications', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

