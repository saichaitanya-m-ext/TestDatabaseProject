CREATE TABLE [dbo].[Time] (
    [PK_Date]                  DATETIME      NOT NULL,
    [Date_Name]                NVARCHAR (50) NULL,
    [Month]                    DATETIME      NULL,
    [Month_Name]               NVARCHAR (50) NULL,
    [Day_Of_Month]             INT           NULL,
    [Day_Of_Month_Name]        NVARCHAR (50) NULL,
    [Fiscal_Month]             DATETIME      NULL,
    [Fiscal_Month_Name]        NVARCHAR (50) NULL,
    [Fiscal_Day]               DATETIME      NULL,
    [Fiscal_Day_Name]          NVARCHAR (50) NULL,
    [Fiscal_Day_Of_Month]      INT           NULL,
    [Fiscal_Day_Of_Month_Name] NVARCHAR (50) NULL,
    CONSTRAINT [PK_Time] PRIMARY KEY CLUSTERED ([PK_Date] ASC) ON [FG_Library]
);


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'CONSTRAINT', @level2name = N'PK_Time';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'DSVTable', @value = N'Time', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'Project', @value = N'539477c9-d1aa-4de4-8382-1f8559e51f86', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'PK_Date';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Date', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'PK_Date';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Date_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Date_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Date_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Month';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Month';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Month_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Month';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Day_Of_Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Month';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Day_Of_Month_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Day_Of_Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Month';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Fiscal_Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Month';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Fiscal_Month_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Fiscal_Day', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Fiscal_Day_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day_Name';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day_Of_Month';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Fiscal_Day_Of_Month', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day_Of_Month';


GO
EXECUTE sp_addextendedproperty @name = N'AllowGen', @value = N'True', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day_Of_Month_Name';


GO
EXECUTE sp_addextendedproperty @name = N'DSVColumn', @value = N'Fiscal_Day_Of_Month_Name', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Time', @level2type = N'COLUMN', @level2name = N'Fiscal_Day_Of_Month_Name';

