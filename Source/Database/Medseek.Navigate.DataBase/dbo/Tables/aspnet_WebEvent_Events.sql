CREATE TABLE [dbo].[aspnet_WebEvent_Events] (
    [EventId]                CHAR (32)       NOT NULL,
    [EventTimeUtc]           DATETIME        NOT NULL,
    [EventTime]              DATETIME        NOT NULL,
    [EventType]              NVARCHAR (256)  NOT NULL,
    [EventSequence]          DECIMAL (19)    NOT NULL,
    [EventOccurrence]        DECIMAL (19)    NOT NULL,
    [EventCode]              INT             NOT NULL,
    [EventDetailCode]        INT             NOT NULL,
    [Message]                NVARCHAR (1024) NULL,
    [ApplicationPath]        NVARCHAR (256)  NULL,
    [ApplicationVirtualPath] NVARCHAR (256)  NULL,
    [MachineName]            NVARCHAR (256)  NOT NULL,
    [RequestUrl]             NVARCHAR (1024) NULL,
    [ExceptionType]          NVARCHAR (256)  NULL,
    [Details]                NTEXT           NULL,
    CONSTRAINT [PK__aspnet_WebEvent___619B8048] PRIMARY KEY CLUSTERED ([EventId] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'MS .NET 2.9 Security Table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Event ID (from WebBaseEvent.EventId)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'UTC time at which the event was fired (from WebBaseEvent.EventTimeUtc)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventTimeUtc';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Local time at which the event was fired (from WebBaseEvent.EventTime)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Event type (for example, WebFailureAuditEvent)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Event sequence number (from WebBaseEvent.EventSequence)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventSequence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Event occurrence count (from WebBaseEvent.EventOccurrence)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventOccurrence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Event code (from WebBaseEvent.EventCode)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Event detail code (from WebBaseEvent.EventDetailCode)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'EventDetailCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Event message (from WebBaseEvent.EventMessage)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'Message';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Physical path of the application that generated the Web event (for example, C:\Websites\MyApp)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'ApplicationPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Virtual path of the application that generated the event (for example, /MyApp)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'ApplicationVirtualPath';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Name of the machine on which the event was generated', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'MachineName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL of the request that generated the Web event', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'RequestUrl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'If the Web event is a WebBaseErrorEvent, type of exception recorded in the ErrorException property; otherwise, DBNull', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'ExceptionType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Text generated by calling ToString on the Web event', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'aspnet_WebEvent_Events', @level2type = N'COLUMN', @level2name = N'Details';

