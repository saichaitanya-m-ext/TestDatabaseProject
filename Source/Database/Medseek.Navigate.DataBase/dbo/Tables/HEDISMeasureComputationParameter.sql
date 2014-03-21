CREATE TABLE [dbo].[HEDISMeasureComputationParameter] (
    [HEDISMeasureComputationParameterID] [dbo].[KeyID]       NOT NULL,
    [HEDISMeasureComputationID]          [dbo].[KeyID]       NOT NULL,
    [HEDISMeasureQueryParameterCode]     VARCHAR (10)        NULL,
    [HEDISMeasureQueryParameterName]     VARCHAR (30)        NOT NULL,
    [HEDISMeasureQueryParameterLongName] VARCHAR (150)       NULL,
    [ParameterDescription]               VARCHAR (255)       NULL,
    [DataTypeID]                         [dbo].[KeyID]       NOT NULL,
    [SystemDefaultValue]                 VARCHAR (1000)      NOT NULL,
    [IsDisplayEnabled]                   [dbo].[IsIndicator] CONSTRAINT [DF_HEDISMeasureComputationParameter_IsDisplayEnabled] DEFAULT ('1') NOT NULL,
    [IsUIDisplayEnabled]                 [dbo].[IsIndicator] CONSTRAINT [DF_HEDISMeasureComputationParameter_IsUIDisplayEnabled] DEFAULT ('1') NOT NULL,
    [DisplaySortOrder]                   [dbo].[KeyID]       CONSTRAINT [DF_HEDISMeasureComputationParameter_DisplaySortOrder] DEFAULT ('1') NOT NULL,
    [StatusCode]                         VARCHAR (1)         CONSTRAINT [DF_HEDISMeasureComputationParameter_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]                    [dbo].[KeyID]       NOT NULL,
    [CreatedDate]                        [dbo].[UserDate]    CONSTRAINT [DF_HEDISMeasureComputationParameter_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserID]               [dbo].[KeyID]       NULL,
    [LastModifiedDate]                   [dbo].[UserDate]    NULL,
    CONSTRAINT [PK_HEDISMeasureComputationParameter] PRIMARY KEY CLUSTERED ([HEDISMeasureComputationParameterID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_HEDISMeasureComputationParameter_HEDISMeasureComputation] FOREIGN KEY ([HEDISMeasureComputationID]) REFERENCES [dbo].[HEDISMeasureComputation] ([HEDISMeasureComputationID]),
    CONSTRAINT [FK_HEDISMeasureComputationParameter_LkUpDataType] FOREIGN KEY ([DataTypeID]) REFERENCES [dbo].[LkUpDataType] ([DataTypeID])
);


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputationParameter_HEDISMeasureQueryParameterCode]
    ON [dbo].[HEDISMeasureComputationParameter]([HEDISMeasureQueryParameterCode] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputationParameter_HEDISMeasureQueryParameterName]
    ON [dbo].[HEDISMeasureComputationParameter]([HEDISMeasureQueryParameterName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];


GO
CREATE NONCLUSTERED INDEX [UQ_HEDISMeasureComputationParameter_HEDISMeasureQueryParameterLongName]
    ON [dbo].[HEDISMeasureComputationParameter]([HEDISMeasureQueryParameterLongName] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

