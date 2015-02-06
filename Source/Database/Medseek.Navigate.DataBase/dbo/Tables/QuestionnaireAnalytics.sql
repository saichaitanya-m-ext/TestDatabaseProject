CREATE TABLE [dbo].[QuestionnaireAnalytics] (
    [QuestionnaireAnalyticsID] [dbo].[KeyID] IDENTITY (1, 1) NOT NULL,
    [Name]                     VARCHAR (150) NULL,
    [Type]                     CHAR (1)      NULL,
    [M<18]                     INT           NULL,
    [M18TO25]                  INT           NULL,
    [M25TO35]                  INT           NULL,
    [M35TO50]                  INT           NULL,
    [M>50]                     INT           NULL,
    [F<18]                     INT           NULL,
    [F18TO25]                  INT           NULL,
    [F25TO35]                  INT           NULL,
    [F35TO50]                  INT           NULL,
    [F>50]                     INT           NULL,
    CONSTRAINT [PK_QuestionnaireAnalyticsID] PRIMARY KEY CLUSTERED ([QuestionnaireAnalyticsID] ASC) ON [FG_Library]
);

