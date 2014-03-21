CREATE TABLE [dbo].[PatientCommunicationText] (
    [PatientCommunicationId] INT            NOT NULL,
    [CommunicationText]      NVARCHAR (MAX) NULL,
    [SubjectText]            VARCHAR (200)  NULL,
    CONSTRAINT [PK_PatientCommunicationText] PRIMARY KEY CLUSTERED ([PatientCommunicationId] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_PatientCommunicationText_PatientCommunicationId] FOREIGN KEY ([PatientCommunicationId]) REFERENCES [dbo].[PatientCommunication] ([PatientCommunicationId])
);

