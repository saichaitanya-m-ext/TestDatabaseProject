CREATE TYPE [dbo].[SMSDetails] AS TABLE (
    [SMSContent]         VARCHAR (250)    NULL,
    [SentReceivedStatus] VARCHAR (25)     NULL,
    [DateSentReceived]   [dbo].[UserDate] NULL,
    [SMSFrom]            VARCHAR (15)     NULL,
    [SMSTo]              VARCHAR (15)     NULL,
    [StatusCode]         VARCHAR (20)     NULL,
    [MessageSID]         VARCHAR (50)     NULL);

