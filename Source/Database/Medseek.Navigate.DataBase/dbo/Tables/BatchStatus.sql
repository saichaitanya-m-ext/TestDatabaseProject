CREATE TABLE [dbo].[BatchStatus] (
    [BatchStatusId]  INT              IDENTITY (1, 1) NOT NULL,
    [BatchType]      VARCHAR (15)     NULL,
    [BatchStatus]    VARCHAR (1000)   NULL,
    [NoofTotalCodes] INT              NOT NULL,
    [StartDate]      [dbo].[UserDate] NOT NULL,
    [EndDate]        [dbo].[UserDate] NULL,
    [NoOfProcessed]  INT              NULL,
    CONSTRAINT [PK_BatchStatus] PRIMARY KEY CLUSTERED ([BatchStatusId] ASC)
);

