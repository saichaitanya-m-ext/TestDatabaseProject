CREATE TYPE [dbo].[tblTaskRemainders] AS TABLE (
    [TypeID]                             INT           NULL,
    [CommunicationSequence]              INT           NULL,
    [CommunicationTypeID]                INT           NULL,
    [ContactType]                        VARCHAR (200) NULL,
    [TemplateNameID]                     INT           NULL,
    [TemplateName]                       VARCHAR (200) NULL,
    [CommunicationAttemptDays]           INT           NULL,
    [NoOfDaysBeforeTaskClosedIncomplete] INT           NULL,
    [RemainderState]                     VARCHAR (1)   NULL);

