CREATE TABLE [dbo].[ReportFrequency] (
    [ReportFrequencyId]    INT                 IDENTITY (1, 1) NOT NULL,
    [ReportID]             [dbo].[KeyID]       NOT NULL,
    [Frequency]            VARCHAR (1)         NULL,
    [FrequencyEndDate]     DATE                NULL,
    [StartDate]            DATETIME            NULL,
    [DateKey]              [dbo].[KeyID]       NULL,
    [ReportStatus]         VARCHAR (30)        NULL,
    [IsReadyForETL]        [dbo].[IsIndicator] CONSTRAINT [DF_ReportFrequency_IsReadyForETL] DEFAULT ((0)) NULL,
    [LastETLDate]          DATETIME            NULL,
    [CreatedByUserId]      INT                 NOT NULL,
    [CreatedDate]          DATETIME            CONSTRAINT [DF_ReportFrequency_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId] INT                 NULL,
    [LastModifiedDate]     DATETIME            NULL,
    CONSTRAINT [PK_ReportFrequency] PRIMARY KEY CLUSTERED ([ReportFrequencyId] ASC),
    CONSTRAINT [FK_ReportFrequency_ReportID] FOREIGN KEY ([ReportID]) REFERENCES [dbo].[Report] ([ReportId])
);

