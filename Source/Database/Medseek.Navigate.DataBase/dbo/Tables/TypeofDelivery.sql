CREATE TABLE [dbo].[TypeofDelivery] (
    [TypeofDeliveryId] INT           IDENTITY (1, 1) NOT NULL,
    [TypeofDelivery]   VARCHAR (100) NOT NULL,
    [CreatedDate]      DATETIME      DEFAULT (getdate()) NOT NULL,
    [CreatedByUserId]  INT           NOT NULL,
    [ModifiedDate]     DATETIME      NULL,
    [ModifiedByUserId] [dbo].[KeyID] NULL,
    [StatusCode]       VARCHAR (1)   DEFAULT ('A') NOT NULL,
    CONSTRAINT [PK_TypeofDelivery] PRIMARY KEY CLUSTERED ([TypeofDeliveryId] ASC) ON [FG_Library]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TypeofDelivery.TypeofDelivery]
    ON [dbo].[TypeofDelivery]([TypeofDelivery] ASC) WITH (FILLFACTOR = 25)
    ON [FG_Library_NCX];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeofDelivery', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TypeofDelivery', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';

