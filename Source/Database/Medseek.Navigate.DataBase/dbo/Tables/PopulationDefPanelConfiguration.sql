﻿CREATE TABLE [dbo].[PopulationDefPanelConfiguration] (
    [PopulationDefPanelConfigurationID] INT           IDENTITY (1, 1) NOT NULL,
    [PanelorGroupName]                  VARCHAR (100) NULL,
    [PanelDescription]                  VARCHAR (200) NULL,
    [IsShow]                            BIT           NULL,
    [PanelorGroupHeader]                VARCHAR (1)   NOT NULL,
    [ParentPanelID]                     INT           NULL,
    [UserControlName]                   VARCHAR (100) NULL,
    [CreatedBy]                         INT           NOT NULL,
    [CreatedDate]                       DATETIME      NOT NULL,
    [LastModifiedByUserId]              INT           NULL,
    [LastModifiedDate]                  DATETIME      NULL,
    [PopulationType]                    VARCHAR (50)  NULL,
    [SortOrder]                         INT           NULL,
    CONSTRAINT [PK_PopulationDefPanelConfiguration] PRIMARY KEY CLUSTERED ([PopulationDefPanelConfigurationID] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefPanelConfiguration', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); the <User ID> of the System User that last modified the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefPanelConfiguration', @level2type = N'COLUMN', @level2name = N'LastModifiedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data in the table was last modified.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PopulationDefPanelConfiguration', @level2type = N'COLUMN', @level2name = N'LastModifiedDate';

