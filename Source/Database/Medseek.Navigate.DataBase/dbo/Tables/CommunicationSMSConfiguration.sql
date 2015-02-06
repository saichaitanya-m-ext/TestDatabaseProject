CREATE TABLE [dbo].[CommunicationSMSConfiguration] (
    [CommunicationSMSConfigurationId] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [SMSUserLogin]                    NVARCHAR (50) NULL,
    [SMSUserPassword]                 NVARCHAR (50) NULL,
    [SMSCompression]                  VARCHAR (50)  NULL,
    CONSTRAINT [PK_CommunicationSMSConfiguration] PRIMARY KEY CLUSTERED ([CommunicationSMSConfigurationId] ASC) ON [FG_Library]
);

