CREATE TABLE [dbo].[Inventory] (
    [InventoryID]    INT           IDENTITY (1, 1) NOT NULL,
    [Product]        VARCHAR (150) NULL,
    [InventoryDate]  DATETIME      NULL,
    [InventoryCount] INT           NULL,
    PRIMARY KEY CLUSTERED ([InventoryID] ASC) ON [FG_Library]
);

