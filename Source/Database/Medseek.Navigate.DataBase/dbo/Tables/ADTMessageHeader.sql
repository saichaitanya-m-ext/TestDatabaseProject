CREATE TABLE [dbo].[ADTMessageHeader] (
    [MessageHeaderSegmentID] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [FieldSeparator]         VARCHAR (50)     NULL,
    [EncodingCharacters]     VARCHAR (50)     NULL,
    [SendingApplication]     VARCHAR (50)     NULL,
    [SendingFacility]        VARCHAR (50)     NULL,
    [ReceivingApplication]   VARCHAR (50)     NULL,
    [ReceivingFacility]      VARCHAR (50)     NULL,
    [MessageDatetime]        [dbo].[UserDate] NULL,
    [MessageType]            VARCHAR (50)     NULL,
    [MessageControlID]       VARCHAR (50)     NULL,
    [ProcessingID]           VARCHAR (50)     NULL,
    [VersionID]              VARCHAR (50)     NULL,
    [CreatedDate]            [dbo].[UserDate] CONSTRAINT [DF_ADTMessageHeader_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ADTMessageHeader] PRIMARY KEY CLUSTERED ([MessageHeaderSegmentID] ASC)
);

