CREATE TABLE [dbo].[CodeSetDisabilityType] (
    [DisabilityTypeCodeID] [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [DisabilityTypeCode]   VARCHAR (2)              NOT NULL,
    [Description]          [dbo].[ShortDescription] NOT NULL,
    [StatusCode]           [dbo].[StatusCode]       CONSTRAINT [DF_CodeSetDisabilityType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      [dbo].[KeyID]            NOT NULL,
    [CreatedDate]          [dbo].[UserDate]         CONSTRAINT [DF_CodeSetDisabilityType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CodeSetDisabilityType] PRIMARY KEY CLUSTERED ([DisabilityTypeCodeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UK_DisabilityTypeCode_DisabilityType]
    ON [dbo].[CodeSetDisabilityType]([DisabilityTypeCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDisabilityType', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = N'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDisabilityType', @level2type = N'COLUMN', @level2name = N'CreatedDate';

