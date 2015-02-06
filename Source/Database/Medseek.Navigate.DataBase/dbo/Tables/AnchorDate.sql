CREATE TABLE [dbo].[AnchorDate] (
    [DateKey]          [dbo].[KeyID] NOT NULL,
    [AnchorDate]       DATE          NOT NULL,
    [CalendarQuarter]  VARCHAR (9)   NULL,
    [CalendarSemester] VARCHAR (9)   NULL,
    [EnglishMonthName] VARCHAR (50)  NULL,
    [CalenderYear]     INT           NULL,
    CONSTRAINT [PK_AnchorDate] PRIMARY KEY CLUSTERED ([DateKey] ASC)
);

