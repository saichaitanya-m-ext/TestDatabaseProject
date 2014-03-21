CREATE TYPE [dbo].[AttachmentTbl] AS TABLE (
    [AttachmentName]      VARCHAR (100)   NOT NULL,
    [AttachmentExtension] VARCHAR (5)     NOT NULL,
    [AttachmentBody]      VARBINARY (MAX) NULL,
    [FileType]            VARCHAR (100)   NULL,
    [MimeType]            VARCHAR (100)   NULL,
    [FileSizeInBytes]     INT             NULL);

