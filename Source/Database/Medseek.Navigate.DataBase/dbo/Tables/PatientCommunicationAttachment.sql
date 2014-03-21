CREATE TABLE [dbo].[PatientCommunicationAttachment] (
    [LibraryId]              [dbo].[KeyID]    NOT NULL,
    [PatientCommunicationID] [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]        [dbo].[KeyID]    NOT NULL,
    [CreatedDate]            [dbo].[UserDate] CONSTRAINT [DF_PatientCommunicationAttachment_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_PatientCommunicationAttachment] PRIMARY KEY CLUSTERED ([LibraryId] ASC, [PatientCommunicationID] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_PatientCommunicationAttachment_Library] FOREIGN KEY ([LibraryId]) REFERENCES [dbo].[Library] ([LibraryId]),
    CONSTRAINT [FK_PatientCommunicationAttachment_PatientCommunication] FOREIGN KEY ([PatientCommunicationID]) REFERENCES [dbo].[PatientCommunication] ([PatientCommunicationId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunicationAttachment', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PatientCommunicationAttachment', @level2type = N'COLUMN', @level2name = N'CreatedDate';

