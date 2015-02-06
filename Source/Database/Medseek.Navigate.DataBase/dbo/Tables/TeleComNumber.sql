CREATE TABLE [dbo].[TeleComNumber] (
    [TeleComNumberID] INT          IDENTITY (1, 1) NOT NULL,
    [UseCode]         VARCHAR (10) NULL,
    [EquipmentType]   INT          NULL,
    [CommAddress]     VARCHAR (50) NULL,
    [CountryCode]     VARCHAR (5)  NULL,
    [AreaCode]        VARCHAR (5)  NULL,
    [LocalNumber]     VARCHAR (11) NULL,
    [Extension]       VARCHAR (10) NULL,
    CONSTRAINT [PK_TeleComNumber] PRIMARY KEY CLUSTERED ([TeleComNumberID] ASC),
    CONSTRAINT [FK_TeleComNumber_TeleComEquipType] FOREIGN KEY ([EquipmentType]) REFERENCES [dbo].[TeleComEquipType] ([TeleComEquipTypeID])
);

