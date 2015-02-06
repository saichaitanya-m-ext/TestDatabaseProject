CREATE TABLE [dbo].[LkUpCodeType] (
    [CodeTypeID]                      INT                IDENTITY (1, 1) NOT NULL,
    [CodeTypeCode]                    VARCHAR (20)       NOT NULL,
    [CodeTypeName]                    VARCHAR (150)      NOT NULL,
    [IsShow]                          BIT                NULL,
    [TypeDescription]                 VARCHAR (4000)     NULL,
    [CodeTableName]                   VARCHAR (128)      NOT NULL,
    [IsCodeSet]                       BIT                NOT NULL,
    [IsNumericCode]                   BIT                NOT NULL,
    [MinimumNumDigits]                TINYINT            NOT NULL,
    [MaximumNumDigits]                TINYINT            NOT NULL,
    [RemoveDashes]                    BIT                NOT NULL,
    [RemoveALLBlanks]                 BIT                NOT NULL,
    [PadWithLeadingBlanks]            BIT                NULL,
    [MaximumNumLeadingBlanksPadding]  TINYINT            NULL,
    [PadWithTrailingBlanks]           BIT                NULL,
    [MaximumNumTrailingBlanksPadding] TINYINT            NULL,
    [RemoveLeadingZeros]              BIT                NOT NULL,
    [PadWithLeadingZeros]             BIT                NULL,
    [MaximumNumLeadingZerosPadding]   TINYINT            NULL,
    [RemoveTrailingZeros]             BIT                NOT NULL,
    [PadWithTrailingZeros]            BIT                NULL,
    [MaximumNumTrailingZerosPadding]  TINYINT            NULL,
    [StatusCode]                      [dbo].[StatusCode] CONSTRAINT [DF_LkUpCodeType_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                 [dbo].[KeyID]      CONSTRAINT [DF_LkUpCodeType_CreatedByUserID] DEFAULT ((1)) NOT NULL,
    [CreatedDate]                     [dbo].[UserDate]   CONSTRAINT [DF_LkUpCodeType_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]            [dbo].[KeyID]      NULL,
    [LastModifiedDate]                [dbo].[UserDate]   NULL,
    CONSTRAINT [PK_LkUpCodeType] PRIMARY KEY CLUSTERED ([CodeTypeID] ASC) ON [FG_Codesets]
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_LkUpCodeType]
    ON [dbo].[LkUpCodeType]([CodeTypeCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Codesets_NCX];

