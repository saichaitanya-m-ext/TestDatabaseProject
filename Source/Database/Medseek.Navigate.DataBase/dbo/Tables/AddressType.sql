CREATE TABLE [dbo].[AddressType] (
    [AddressTypeID] INT           IDENTITY (1, 1) NOT NULL,
    [Value]         VARCHAR (100) NULL,
    CONSTRAINT [PK_AddressType] PRIMARY KEY CLUSTERED ([AddressTypeID] ASC)
);

