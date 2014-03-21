CREATE TABLE [dbo].[PatientInternalIdentifier] (
    [PatientInternalIdentifierId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [PatientID]                   [dbo].[KeyID]    NOT NULL,
    [SSN]                         VARCHAR (12)     NULL,
    [Dep_Seq]                     VARCHAR (2)      NOT NULL,
    [StatusCode]                  VARCHAR (1)      CONSTRAINT [DF_PatientInternalIdentifier_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserID]             [dbo].[KeyID]    NOT NULL,
    [CreatedDate]                 [dbo].[UserDate] CONSTRAINT [DF_PatientInternalIdentifier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK__PatientI__8F7DE80471B9128F] PRIMARY KEY CLUSTERED ([PatientInternalIdentifierId] ASC),
    CONSTRAINT [FK_PatientInternalIdentifier_PatientId] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID])
);

