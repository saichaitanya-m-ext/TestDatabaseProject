CREATE TABLE [dbo].[ADTGeneral] (
    [Patient_PrimaryId_Id] UNIQUEIDENTIFIER NULL,
    [SendingApplication]   VARCHAR (200)    NULL,
    [SendingFacility]      VARCHAR (200)    NULL,
    [ReceivingApplication] VARCHAR (200)    NULL,
    [ReceivingFacility]    VARCHAR (200)    NULL,
    [MsgDateTime]          VARCHAR (200)    NULL,
    [MessageType_MsgType]  VARCHAR (200)    NULL,
    [MessageType_Event]    VARCHAR (200)    NULL,
    [MessageControlId]     VARCHAR (200)    NULL,
    [ProcessingId]         VARCHAR (200)    NULL,
    [VersionId]            VARCHAR (200)    NULL,
    [SequenceNumber]       VARCHAR (200)    NULL,
    [EventDateTime]        VARCHAR (200)    NULL,
    [EventFacility]        VARCHAR (200)    NULL
);

