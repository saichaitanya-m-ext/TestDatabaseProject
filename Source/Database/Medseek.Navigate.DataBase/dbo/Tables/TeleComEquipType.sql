CREATE TABLE [dbo].[TeleComEquipType] (
    [TeleComEquipTypeID] INT          IDENTITY (1, 1) NOT NULL,
    [Value]              VARCHAR (50) NULL,
    CONSTRAINT [PK_TeleComEquipType] PRIMARY KEY CLUSTERED ([TeleComEquipTypeID] ASC)
);

