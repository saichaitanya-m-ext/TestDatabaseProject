CREATE TABLE [dbo].[CodeGroupingType] (
    [CodeGroupingTypeID]   [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [CodeGroupType]        VARCHAR (20)  NOT NULL,
    [StatusCode]           VARCHAR (20)  CONSTRAINT [DF_CCodeGroupType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      [dbo].[KeyID] NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_CodeGroupType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] [dbo].[KeyID] NULL,
    [LastModifiedDate]     DATETIME      NULL,
    CONSTRAINT [CodeGroupType_PK] PRIMARY KEY CLUSTERED ([CodeGroupingTypeID] ASC) ON [FG_Library]
);

