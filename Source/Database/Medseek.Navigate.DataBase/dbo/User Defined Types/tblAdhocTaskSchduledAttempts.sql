CREATE TYPE [dbo].[tblAdhocTaskSchduledAttempts] AS TABLE (
    [CommunicationSequence]              [dbo].[KeyID] NULL,
    [CommunicationTypeID]                [dbo].[KeyID] NULL,
    [ContactType]                        VARCHAR (200) NULL,
    [TemplateNameID]                     [dbo].[KeyID] NULL,
    [TemplateName]                       VARCHAR (200) NULL,
    [CommunicationAttemptDays]           INT           NULL,
    [NoOfDaysBeforeTaskClosedIncomplete] INT           NULL);

