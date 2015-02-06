CREATE TYPE [dbo].[TaskAttempts] AS TABLE (
    [TaskId]                  INT           NULL,
    [TasktypeCommunicationID] INT           NULL,
    [AttemptedContactDate]    DATETIME      NULL,
    [Comments]                VARCHAR (500) NULL,
    [NextContactDate]         DATETIME      NULL,
    [TaskTerminationDate]     DATETIME      NULL,
    [CommunicationTemplateID] INT           NULL,
    [AttemptStatus]           BIT           NULL,
    [CommunicationSequence]   INT           NULL,
    [CommunicationTypeId]     INT           NULL);

