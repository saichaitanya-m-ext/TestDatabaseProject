﻿CREATE TABLE [dbo].[Allergies] (
    [AllergiesID]          [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [Name]                 [dbo].[ShortDescription] NOT NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_Allergies_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_Allergies_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID]            NULL,
    [LastModifiedDate]     [dbo].[UserDate]         NULL,
    CONSTRAINT [PK_Allergies] PRIMARY KEY CLUSTERED ([AllergiesID] ASC) ON [FG_Library],
    CONSTRAINT [Name] UNIQUE NONCLUSTERED ([Name] ASC) WITH (FILLFACTOR = 100) ON [FG_Library_NCX]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Allergies', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Allergies', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Allergies', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Allergies', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

