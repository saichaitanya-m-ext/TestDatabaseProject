CREATE TYPE [dbo].[tblDocument] AS TABLE (
    [DocumentName]    [dbo].[LongDescription] NULL,
    [DocumentContent] VARBINARY (MAX)         NULL,
    [MimeType]        VARCHAR (20)            NULL);

