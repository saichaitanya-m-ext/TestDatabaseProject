CREATE TABLE [dbo].[UserSMS] (
    [UserSMSId]          [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [SMSContent]         VARCHAR (250)    NOT NULL,
    [SentReceivedStatus] VARCHAR (25)     NULL,
    [DateSentReceived]   [dbo].[UserDate] NULL,
    [SMSFrom]            VARCHAR (15)     NULL,
    [SMSTo]              VARCHAR (15)     NULL,
    [MessageSID]         VARCHAR (50)     NULL,
    [StatusCode]         VARCHAR (20)     DEFAULT ('A') NULL,
    [CreatedByUserId]    [dbo].[KeyID]    NOT NULL,
    [CreatedDate]        [dbo].[UserDate] CONSTRAINT [DF_UserSMS_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_UserSMS] PRIMARY KEY CLUSTERED ([UserSMSId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSMS', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSMS', @level2type = N'COLUMN', @level2name = N'CreatedDate';

