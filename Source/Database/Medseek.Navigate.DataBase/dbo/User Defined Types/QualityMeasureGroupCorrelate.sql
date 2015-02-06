CREATE TYPE [dbo].[QualityMeasureGroupCorrelate] AS TABLE (
    [PQRIQualityMeasureGroupCorrelateID] [dbo].[KeyID]           NOT NULL,
    [PQRIQualityMeasureGroupID]          [dbo].[KeyID]           NOT NULL,
    [PQRIQualityMeasureCorrelateIDList]  [dbo].[LongDescription] NOT NULL,
    [AgeFrom]                            INT                     NOT NULL,
    [AgeTo]                              INT                     NOT NULL,
    [Gender]                             [dbo].[Unit]            NOT NULL,
    [BMIFrom]                            DECIMAL (5, 3)          NOT NULL,
    [BMITo]                              DECIMAL (5, 3)          NOT NULL);

