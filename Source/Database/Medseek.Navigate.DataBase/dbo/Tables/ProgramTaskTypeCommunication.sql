﻿CREATE TABLE [dbo].[ProgramTaskTypeCommunication] (
    [ProgramTaskTypeCommunicationID]     INT         IDENTITY (1, 1) NOT NULL,
    [ProgramTaskBundleID]                INT         NOT NULL,
    [ProgramID]                          INT         NOT NULL,
    [TaskTypeID]                         INT         NOT NULL,
    [GeneralizedID]                      INT         NOT NULL,
    [CommunicationSequence]              INT         NOT NULL,
    [CommunicationTypeID]                INT         NULL,
    [CommunicationAttemptDays]           INT         NULL,
    [NoOfDaysBeforeTaskClosedIncomplete] INT         NULL,
    [CommunicationTemplateID]            INT         NULL,
    [StatusCode]                         VARCHAR (1) CONSTRAINT [DF_ProgramTaskTypeCommunication_StatusCode] DEFAULT ('A') NOT NULL,
    [CreatedByUserId]                    INT         NOT NULL,
    [CreatedDate]                        DATETIME    CONSTRAINT [DF_ProgramTaskTypeCommunication_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModifiedByUserId]               INT         NULL,
    [LastModifiedDate]                   DATETIME    NULL,
    [RemainderState]                     VARCHAR (1) NULL,
    CONSTRAINT [PK_ProgramTaskTypeCommunication] PRIMARY KEY CLUSTERED ([ProgramTaskTypeCommunicationID] ASC),
    CONSTRAINT [FK_ProgramTaskTypeCommunication_CommunicationTemplate] FOREIGN KEY ([CommunicationTemplateID]) REFERENCES [dbo].[CommunicationTemplate] ([CommunicationTemplateId]),
    CONSTRAINT [FK_ProgramTaskTypeCommunication_CommunicationType] FOREIGN KEY ([CommunicationTypeID]) REFERENCES [dbo].[CommunicationType] ([CommunicationTypeId]),
    CONSTRAINT [FK_ProgramTaskTypeCommunication_Program] FOREIGN KEY ([ProgramID]) REFERENCES [dbo].[Program] ([ProgramId]),
    CONSTRAINT [FK_ProgramTaskTypeCommunication_ProgramTaskBundle] FOREIGN KEY ([ProgramTaskBundleID]) REFERENCES [dbo].[ProgramTaskBundle] ([ProgramTaskBundleID]),
    CONSTRAINT [FK_ProgramTaskTypeCommunications_TaskType] FOREIGN KEY ([TaskTypeID]) REFERENCES [dbo].[TaskType] ([TaskTypeId])
);

