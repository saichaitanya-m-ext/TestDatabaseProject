CREATE TABLE [dbo].[CodeSetTypeOfBill] (
    [TypeOfBillCodeID]     [dbo].[KeyID]      IDENTITY (1, 1) NOT NULL,
    [TypeOfBillCode]       VARCHAR (10)       NOT NULL,
    [ShortDescription]     VARCHAR (1000)     NULL,
    [LongDescription]      VARCHAR (4000)     NULL,
    [BeginDate]            DATE               NOT NULL,
    [EndDate]              DATE               CONSTRAINT [DF_CodeSetTypeOfBill_EndDate] DEFAULT ('01-01-2100') NOT NULL,
    [DataSourceID]         [dbo].[KeyID]      NULL,
    [DataSourceFileID]     [dbo].[KeyID]      NULL,
    [StatusCode]           [dbo].[StatusCode] CONSTRAINT [DF_CodeSetTypeOfBill_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]      INT                NOT NULL,
    [CreatedDate]          DATETIME           CONSTRAINT [DF_CodeSetTypeOfBill_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                NULL,
    [LastModifiedDate]     DATETIME           NULL,
    CONSTRAINT [PK_CodeSetTypeOfBill] PRIMARY KEY CLUSTERED ([TypeOfBillCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetTypeOfBill_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID]),
    CONSTRAINT [UQ_CodeSetTypeOfBill_TypeOfBillCode] UNIQUE NONCLUSTERED ([TypeOfBillCode] ASC) WITH (FILLFACTOR = 100) ON [FG_Codesets_NCX]
);

