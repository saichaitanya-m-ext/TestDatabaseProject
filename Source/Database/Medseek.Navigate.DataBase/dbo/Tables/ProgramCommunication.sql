CREATE TABLE [dbo].[ProgramCommunication] (
    [ProgramId]           [dbo].[KeyID]      NOT NULL,
    [CommunicationTypeId] [dbo].[KeyID]      NOT NULL,
    [TemplateId]          [dbo].[KeyID]      NOT NULL,
    [StatusCode]          [dbo].[StatusCode] CONSTRAINT [DF_ProgramCommunication_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]     [dbo].[KeyID]      NOT NULL,
    [CreatedDate]         [dbo].[UserDate]   CONSTRAINT [DF_ProgramCommunication_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProgramCommunication] PRIMARY KEY CLUSTERED ([ProgramId] ASC, [CommunicationTypeId] ASC, [TemplateId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_programCommunication_CommunicationTemplate] FOREIGN KEY ([TemplateId]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_programCommunication_CommunicationType] FOREIGN KEY ([CommunicationTypeId]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_programCommunication_program] FOREIGN KEY ([ProgramId]) REFERENCES [dbo].[Program] ([ProgramId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCommunication', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProgramCommunication', @level2type = N'COLUMN', @level2name = N'CreatedDate';

