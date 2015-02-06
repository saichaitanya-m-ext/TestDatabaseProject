CREATE TABLE [dbo].[ADTEventType] (
    [EventTypeID]      [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [EventTypeCode]    VARCHAR (50)     NULL,
    [RecordedDatetime] [dbo].[UserDate] NULL,
    [EventFacility]    VARCHAR (50)     NULL,
    [CreatedDate]      [dbo].[UserDate] CONSTRAINT [DF_ADTEventType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ADTEventType] PRIMARY KEY CLUSTERED ([EventTypeID] ASC)
);

