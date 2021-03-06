﻿CREATE PROCEDURE [dbo].[aspnet_WebEvent_LogEvent]
       @EventId CHAR(32) ,
       @EventTimeUtc DATETIME ,
       @EventTime DATETIME ,
       @EventType NVARCHAR(256) ,
       @EventSequence DECIMAL(19,0) ,
       @EventOccurrence DECIMAL(19,0) ,
       @EventCode INT ,
       @EventDetailCode INT ,
       @Message NVARCHAR(1024) ,
       @ApplicationPath NVARCHAR(256) ,
       @ApplicationVirtualPath NVARCHAR(256) ,
       @MachineName NVARCHAR(256) ,
       @RequestUrl NVARCHAR(1024) ,
       @ExceptionType NVARCHAR(256) ,
       @Details NTEXT
AS
BEGIN
      INSERT
          dbo.aspnet_WebEvent_Events
          (
            EventId ,
            EventTimeUtc ,
            EventTime ,
            EventType ,
            EventSequence ,
            EventOccurrence ,
            EventCode ,
            EventDetailCode ,
            Message ,
            ApplicationPath ,
            ApplicationVirtualPath ,
            MachineName ,
            RequestUrl ,
            ExceptionType ,
            Details )
      VALUES
          (
            @EventId ,
            @EventTimeUtc ,
            @EventTime ,
            @EventType ,
            @EventSequence ,
            @EventOccurrence ,
            @EventCode ,
            @EventDetailCode ,
            @Message ,
            @ApplicationPath ,
            @ApplicationVirtualPath ,
            @MachineName ,
            @RequestUrl ,
            @ExceptionType ,
            @Details )
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_WebEvent_LogEvent] TO [FE_rohit.r-ext]
    AS [dbo];

