CREATE TABLE [dbo].[PatientBarrier] (
    [PatientBarrierId]     INT           IDENTITY (1, 1) NOT NULL,
    [PatientId]            INT           NOT NULL,
    [BarrierID]            INT           NULL,
    [Comments]             VARCHAR (500) NULL,
    [ReferralID]           INT           NULL,
    [ReportedDate]         DATETIME      NULL,
    [CreatedByUserId]      INT           NOT NULL,
    [CreatedDate]          DATETIME      CONSTRAINT [DF_PatientBarrier_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [StatusCode]           VARCHAR (1)   CONSTRAINT [DF_PatientBarrier_StatusCode] DEFAULT ('A') NOT NULL,
    [LastModifiedByUserId] INT           NULL,
    [LastModifiedDate]     DATETIME      NULL,
    [OtherBarrier]         VARCHAR (500) NULL,
    CONSTRAINT [PK_PatientBarrier] PRIMARY KEY CLUSTERED ([PatientBarrierId] ASC),
    CONSTRAINT [FK_PatientBarrier_Barrier] FOREIGN KEY ([BarrierID]) REFERENCES [dbo].[Barrier] ([BarrierID]),
    CONSTRAINT [FK_PatientBarrier_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_PatientBarrier_Referral] FOREIGN KEY ([ReferralID]) REFERENCES [dbo].[Referral] ([ReferralId])
);

