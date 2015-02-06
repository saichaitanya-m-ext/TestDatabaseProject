CREATE TYPE [dbo].[PatientGoalProgress] AS TABLE (
    [PatientActivityId]  [dbo].[KeyID] NULL,
    [ProgressPercentage] CHAR (1)      NULL);

