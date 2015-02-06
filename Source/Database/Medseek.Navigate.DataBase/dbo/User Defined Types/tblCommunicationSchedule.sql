CREATE TYPE [dbo].[tblCommunicationSchedule] AS TABLE (
    [TaskTypeID]                         INT                NULL,
    [CommunicationSequence]              INT                NULL,
    [CommunicationTypeID]                INT                NULL,
    [CommunicationAttemptDays]           INT                NULL,
    [NoOfDaysBeforeTaskClosedIncomplete] INT                NULL,
    [CommunicationTemplateID]            INT                NULL,
    [TaskTypeGeneralizedID]              INT                NULL,
    [StatusCode]                         [dbo].[StatusCode] NULL);

