CREATE TABLE [dbo].[ProcessACO] (
    [ProcessACOID] INT           IDENTITY (1, 1) NOT NULL,
    [Process]      VARCHAR (100) NULL,
    [Tested]       INT           NULL,
    [Nottested]    INT           NULL,
    [Count]        INT           NULL
);

