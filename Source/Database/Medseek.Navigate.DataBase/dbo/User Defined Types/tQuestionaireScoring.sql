CREATE TYPE [dbo].[tQuestionaireScoring] AS TABLE (
    [RangeStartScore]  SMALLINT      NULL,
    [RangeEndScore]    SMALLINT      NULL,
    [RangeName]        VARCHAR (100) NULL,
    [RangeDescription] VARCHAR (MAX) NULL);

