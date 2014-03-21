CREATE TABLE [dbo].[CommunicationIVRPhoneCallStatus] (
    [CommunicationIVRCallStatusId] [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [PatientCommunicationId]       [dbo].[KeyID]      NULL,
    [PhoneNumber]                  [dbo].[Phone]      NULL,
    [PatientName]                  VARCHAR (200)      NULL,
    [PatientInformation]           NVARCHAR (MAX)     NULL,
    [ProviderName]                 VARCHAR (200)      NULL,
    [AppointmentDate]              DATE               NULL,
    [CallStatus]                   [dbo].[StatusCode] NULL,
    [CreatedByUserId]              [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                  [dbo].[UserDate]   CONSTRAINT [DF_IVRPhoneCallStatus_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CommunicationIVRPhoneCallStatus] PRIMARY KEY CLUSTERED ([CommunicationIVRCallStatusId] ASC),
    CONSTRAINT [FK_CommunicationIVRPhoneCallStatus_UserCommunication] FOREIGN KEY ([PatientCommunicationId]) REFERENCES [dbo].[PatientCommunication] ([PatientCommunicationId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationIVRPhoneCallStatus', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CommunicationIVRPhoneCallStatus', @level2type = N'COLUMN', @level2name = N'CreatedDate';

