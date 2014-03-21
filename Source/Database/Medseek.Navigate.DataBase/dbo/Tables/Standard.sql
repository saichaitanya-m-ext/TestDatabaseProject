CREATE TABLE [dbo].[Standard] (
    [StandardId]             INT           IDENTITY (1, 1) NOT NULL,
    [Name]                   VARCHAR (100) NOT NULL,
    [Description]            VARCHAR (100) NULL,
    [StatusCode]             VARCHAR (1)   DEFAULT ('A') NOT NULL,
    [CreatedByUserId]        INT           NOT NULL,
    [CreatedDate]            DATETIME      DEFAULT (getdate()) NOT NULL,
    [StandardOrganizationId] INT           NULL,
    PRIMARY KEY CLUSTERED ([StandardId] ASC) ON [FG_Library],
    CONSTRAINT [IX_Standard] UNIQUE NONCLUSTERED ([Name] ASC) WITH (FILLFACTOR = 100) ON [FG_Library_NCX]
);

