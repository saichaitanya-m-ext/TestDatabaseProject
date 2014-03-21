CREATE TABLE [dbo].[ADT_ExtendedData] (
    [ADTExtendedDataID] INT           IDENTITY (1, 1) NOT NULL,
    [Patient_SetID]     VARCHAR (100) NULL,
    [ExtendedSource]    VARCHAR (150) NULL,
    [ExtendedKey]       VARCHAR (150) NULL,
    [Data]              VARCHAR (150) NULL,
    [OnDemand]          VARCHAR (150) NULL
);

