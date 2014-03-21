CREATE TABLE [dbo].[HEDISMeasureComputation] (
    [HEDISMeasureComputationID]       [dbo].[KeyID]       NOT NULL,
    [HEDISMeasureID]                  [dbo].[KeyID]       NOT NULL,
    [VersionYear]                     SMALLINT            NOT NULL,
    [HEDISMeasureComputationCode]     VARCHAR (10)        NULL,
    [HEDISMeasureComputationName]     VARCHAR (60)        NOT NULL,
    [HEDISMeasureComputationLongName] VARCHAR (300)       NULL,
    [ComputationDescription]          VARCHAR (4000)      NULL,
    [HEDISComputationTypeID]          [dbo].[KeyID]       NOT NULL,
    [IsSystemDefault]                 [dbo].[IsIndicator] CONSTRAINT [DF_HEDISMeasureComputation_IsSystemDefault] DEFAULT ('1') NOT NULL,
    [IsDisplayEnabled]                [dbo].[IsIndicator] CONSTRAINT [DF_HEDISMeasureComputation_IsDisplayEnabled] DEFAULT ('1') NOT NULL,
    [IsUIDisplayEnabled]              [dbo].[IsIndicator] CONSTRAINT [DF_HEDISMeasureComputation_IsUIDisplayEnabled] DEFAULT ('1') NOT NULL,
    [DisplaySortOrder]                [dbo].[KeyID]       CONSTRAINT [DF_HEDISMeasureComputation_DisplaySortOrder] DEFAULT ('1') NOT NULL,
    [StatusCode]                      VARCHAR (1)         CONSTRAINT [DF_HEDISMeasureComputation_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                 [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                     [dbo].[UserDate]    CONSTRAINT [DF_HEDISMeasureComputation_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]            [dbo].[KeyID]       NULL,
    [LastModifiedDate]                [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_HEDISMeasureComputation] PRIMARY KEY CLUSTERED ([HEDISMeasureComputationID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_HEDISMeasureComputation_CodeSetECTHedisMeasure] FOREIGN KEY ([HEDISMeasureID]) REFERENCES [dbo].[CodeSetECTHedisMeasure] ([ECTHedisMeasureID]),
    CONSTRAINT [FK_HEDISMeasureComputation_LkUpHEDISComputationType] FOREIGN KEY ([HEDISComputationTypeID]) REFERENCES [dbo].[LkUpHEDISComputationType] ([HEDISComputationTypeID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputation_HEDISMeasureID]
    ON [dbo].[HEDISMeasureComputation]([HEDISMeasureID] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputation_VersionYear]
    ON [dbo].[HEDISMeasureComputation]([VersionYear] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputation_HEDISMeasureComputationCode]
    ON [dbo].[HEDISMeasureComputation]([HEDISMeasureComputationCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputation_HEDISMeasureComputationName]
    ON [dbo].[HEDISMeasureComputation]([HEDISMeasureComputationName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputation_HEDISMeasureComputationLongName]
    ON [dbo].[HEDISMeasureComputation]([HEDISMeasureComputationLongName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

