CREATE TABLE [dbo].[ADT_General] (
    [ADTGeneralID]         INT           IDENTITY (1, 1) NOT NULL,
    [Patient_SetID]        VARCHAR (100) NULL,
    [SendingApplication]   VARCHAR (100) NULL,
    [SendingFacility]      VARCHAR (100) NULL,
    [ReceivingApplication] VARCHAR (100) NULL,
    [ReceivingFacility]    VARCHAR (100) NULL,
    [MsgDateTime]          VARCHAR (100) NULL,
    [MsgType]              VARCHAR (100) NULL,
    [MsgEvent]             VARCHAR (100) NULL,
    [MessageControlId]     VARCHAR (150) NULL,
    [ProcessingId]         VARCHAR (150) NULL,
    [VersionId]            VARCHAR (150) NULL,
    [SequenceNumber]       VARCHAR (150) NULL,
    [EventDateTime]        VARCHAR (100) NULL,
    [EventFacility]        VARCHAR (100) NULL
);

