CREATE TABLE [dbo].[LoginAudit] (
    [AuditId]      [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [LoginName]    VARCHAR (50)     NULL,
    [IPAddress]    VARCHAR (50)     NULL,
    [LoginStatus]  VARCHAR (6)      NULL,
    [LoginDate]    [dbo].[UserDate] CONSTRAINT [DF_LoginAudit_LoginDate] DEFAULT (getutcdate()) NOT NULL,
    [Userid]       INT              NULL,
    [Logoutdate]   DATETIME         NULL,
    [Timeduration] VARCHAR (50)     NULL,
    [Logouttype]   VARCHAR (50)     NULL,
    CONSTRAINT [PK_LoginAudit] PRIMARY KEY CLUSTERED ([AuditId] ASC) ON [FG_Library]
);

