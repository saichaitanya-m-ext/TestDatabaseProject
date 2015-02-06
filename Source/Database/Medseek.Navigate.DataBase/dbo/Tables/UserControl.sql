CREATE TABLE [dbo].[UserControl] (
    [UserControlId]          [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [UserControlName]        [dbo].[SourceName]       NOT NULL,
    [DataSourceName]         VARCHAR (1000)           NULL,
    [DataSourceType]         VARCHAR (30)             NULL,
    [UserControlDescription] [dbo].[ShortDescription] NULL,
    [CreatedByUserId]        [dbo].[KeyID]            NOT NULL,
    [CreatedDate]            [dbo].[UserDate]         CONSTRAINT [DF_UserControl_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]   [dbo].[KeyID]            NULL,
    [LastModifiedDate]       [dbo].[UserDate]         NULL,
    [ControlType]            VARCHAR (30)             NULL,
    CONSTRAINT [PK_UserControl] PRIMARY KEY CLUSTERED ([UserControlId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserControl_UserControlName]
    ON [dbo].[UserControl]([UserControlName] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The userControls used by Questionnaires to perform Medical Titration', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UserControl table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'UserControlId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'name of the user control', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'UserControlName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Data source for the user control', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'DataSourceName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Type for the user control', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'DataSourceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Free Form description for the control', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'UserControlDescription';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the User Table indicating the user that last modified the record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was last modified', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'This field is going to be used for storing the type of control such as  Measure, Disease, Procedure, Diagnosis etc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserControl', @level2type = N'COLUMN', @level2name = N'ControlType';

