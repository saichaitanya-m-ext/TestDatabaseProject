CREATE TYPE [dbo].[TaskAttemptsStatus] AS TABLE (
    [TaskId]        INT           NULL,
    [Comments]      VARCHAR (500) NULL,
    [AttemptStatus] BIT           NULL);

