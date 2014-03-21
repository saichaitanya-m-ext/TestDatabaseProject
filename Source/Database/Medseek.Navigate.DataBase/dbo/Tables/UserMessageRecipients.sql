CREATE TABLE [dbo].[UserMessageRecipients] (
    [UserMessageRecipientID] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [UserMessageID]          [dbo].[KeyID] NOT NULL,
    [PatientID]              [dbo].[KeyID] NULL,
    [ProviderID]             [dbo].[KeyID] NULL,
    [CreatedByUserId]        INT           NOT NULL,
    [CreatedDate]            DATETIME      CONSTRAINT [DF_UserMessageRecipients_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [MessageState]           CHAR (1)      CONSTRAINT [DF_UserMessageRecipients_MessageState] DEFAULT ('N') NOT NULL,
    CONSTRAINT [PK_UserMessageRecipients_1] PRIMARY KEY CLUSTERED ([UserMessageRecipientID] ASC),
    CONSTRAINT [FK_UserMessageRecipients_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_UserMessageRecipients_UserMessages] FOREIGN KEY ([UserMessageID]) REFERENCES [dbo].[UserMessages] ([UserMessageId])
);

