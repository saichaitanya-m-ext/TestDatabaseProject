CREATE TABLE [dbo].[GridResolution] (
    [GridResolutionID] [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [ModuleName]       [dbo].[ShortDescription] NULL,
    [PageName]         [dbo].[ShortDescription] NULL,
    [GridName]         [dbo].[ShortDescription] NULL,
    [ResolutionFrom]   SMALLINT                 NULL,
    [ResolutionTo]     SMALLINT                 NULL,
    [ScrollHeight]     SMALLINT                 NULL,
    [CreatedDate]      [dbo].[UserDate]         CONSTRAINT [DF_GridResolution_CreatedDate] DEFAULT (getdate()) NULL,
    [CreatedByUserID]  [dbo].[KeyID]            NULL,
    CONSTRAINT [PK_GridResolution] PRIMARY KEY CLUSTERED ([GridResolutionID] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_GridResolution_ModulePageGridnameResolutionFrom]
    ON [dbo].[GridResolution]([ModuleName] ASC, [PageName] ASC, [GridName] ASC, [ResolutionFrom] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GridResolution', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GridResolution', @level2type = N'COLUMN', @level2name = N'CreatedByUserID';

