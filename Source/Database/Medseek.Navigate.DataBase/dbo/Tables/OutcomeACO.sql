CREATE TABLE [dbo].[OutcomeACO] (
    [OutcomeACOID] INT           IDENTITY (1, 1) NOT NULL,
    [Outcome]      VARCHAR (100) NULL,
    [Met]          INT           NULL,
    [NotMet]       INT           NULL,
    [Count]        INT           NULL
);

