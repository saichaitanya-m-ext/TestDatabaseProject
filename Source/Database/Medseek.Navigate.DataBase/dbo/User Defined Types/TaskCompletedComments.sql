CREATE TYPE [dbo].[TaskCompletedComments] AS TABLE (
    [TaskID]        INT           NULL,
    [GeneralizedId] INT           NULL,
    [CompletedDate] DATETIME      NULL,
    [Comments]      VARCHAR (500) NULL,
    [TaskTypeName]  VARCHAR (500) NULL);

