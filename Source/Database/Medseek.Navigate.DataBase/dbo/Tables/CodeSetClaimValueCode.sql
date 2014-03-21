CREATE TABLE [dbo].[CodeSetClaimValueCode] (
    [ClaimValueCodeID]     INT          IDENTITY (1, 1) NOT NULL,
    [ClaimInfoID]          INT          NOT NULL,
    [ValueCodeID]          INT          NOT NULL,
    [AmountValue]          NUMERIC (18) NOT NULL,
    [DataSourceID]         INT          NULL,
    [DataSourceFileID]     INT          NULL,
    [RecordTag_FileID]     VARCHAR (30) NULL,
    [StatusCode]           VARCHAR (1)  CONSTRAINT [DF_CodeSetClaimValueCode_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]      INT          NOT NULL,
    [CreatedDate]          DATETIME     CONSTRAINT [DF_CodeSetClaimValueCode_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID] INT          NULL,
    [LastModifiedDate]     DATETIME     NULL,
    CONSTRAINT [PK_CodeSetClaimValueCode] PRIMARY KEY CLUSTERED ([ClaimInfoID] ASC, [ValueCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetClaimValueCode_CodeSetValueCode] FOREIGN KEY ([ValueCodeID]) REFERENCES [dbo].[CodeSetValueCode] ([ValueCodeID]),
    CONSTRAINT [FK_CodeSetClaimValueCode_DataSourceFile] FOREIGN KEY ([DataSourceFileID]) REFERENCES [dbo].[DataSourceFile] ([DataSourceFileID])
);

