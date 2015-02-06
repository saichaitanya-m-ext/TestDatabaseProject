CREATE TYPE [dbo].[CodeSetDrug] AS TABLE (
    [DrugCodeId]        INT                     NULL,
    [DrugCode]          [dbo].[DrugCode]        NULL,
    [DrugCodeType]      [dbo].[SType]           NULL,
    [DrugName]          [dbo].[SourceName]      NULL,
    [DrugDescription]   [dbo].[LongDescription] NULL,
    [ListingSequenceNo] INT                     NULL,
    [StatusCode]        [dbo].[StatusCode]      NULL);

