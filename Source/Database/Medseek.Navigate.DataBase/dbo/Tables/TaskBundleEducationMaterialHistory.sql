CREATE TABLE [dbo].[TaskBundleEducationMaterialHistory] (
    [TaskBundleEducationMaterialId] INT                NOT NULL,
    [DefinitionVersion]             VARCHAR (5)        NOT NULL,
    [TaskBundleId]                  [dbo].[KeyID]      NOT NULL,
    [EducationMaterialID]           [dbo].[KeyID]      NOT NULL,
    [Name]                          VARCHAR (500)      NULL,
    [LibraryIDList]                 VARCHAR (250)      NULL,
    [StatusCode]                    [dbo].[StatusCode] NOT NULL,
    [CreatedByUserId]               [dbo].[KeyID]      NOT NULL,
    [CreatedDate]                   [dbo].[UserDate]   CONSTRAINT [DF_TaskBundleEducationMaterialHistory_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [Comments]                      VARCHAR (500)      NULL,
    CONSTRAINT [PK_TaskBundleEducationMaterialHistory] PRIMARY KEY CLUSTERED ([TaskBundleEducationMaterialId] ASC, [DefinitionVersion] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_TaskBundleEducationMaterialHistory_EducationMaterial] FOREIGN KEY ([EducationMaterialID]) REFERENCES [dbo].[EducationMaterial] ([EducationMaterialID]),
    CONSTRAINT [FK_TaskBundleEducationMaterialHistory_TaskBundle] FOREIGN KEY ([TaskBundleId]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleEducationMaterialHistory', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TaskBundleEducationMaterialHistory', @level2type = N'COLUMN', @level2name = N'CreatedDate';

