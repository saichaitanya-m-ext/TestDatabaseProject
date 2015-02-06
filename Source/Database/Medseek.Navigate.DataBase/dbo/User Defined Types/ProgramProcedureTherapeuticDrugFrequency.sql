CREATE TYPE [dbo].[ProgramProcedureTherapeuticDrugFrequency] AS TABLE (
    [TherapeuticID]   [dbo].[KeyID]            NULL,
    [TherapeuticName] [dbo].[SourceName]       NULL,
    [DrugCodeId]      [dbo].[KeyID]            NULL,
    [DrugCodeName]    [dbo].[ShortDescription] NULL,
    [DurationAndType] VARCHAR (15)             NULL,
    [FrequencyAndUOM] VARCHAR (15)             NULL);

