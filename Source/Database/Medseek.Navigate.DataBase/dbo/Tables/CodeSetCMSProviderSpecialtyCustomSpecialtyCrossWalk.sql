CREATE TABLE [dbo].[CodeSetCMSProviderSpecialtyCustomSpecialtyCrossWalk] (
    [CustomProviderSpecialtyCodeID] [dbo].[KeyID]    NOT NULL,
    [CMSProviderSpecialtyCodeID]    [dbo].[KeyID]    NOT NULL,
    [CreatedByUserID]               [dbo].[KeyID]    NULL,
    [CreatedDate]                   [dbo].[UserDate] NULL,
    [LastModifiedByUserID]          [dbo].[KeyID]    NULL,
    [LastModifiedDate]              [dbo].[UserDate] NULL,
    CONSTRAINT [PK_CodeSetCMSProviderSpecialtyCustomSpecialtyCrossWalk] PRIMARY KEY CLUSTERED ([CustomProviderSpecialtyCodeID] ASC, [CMSProviderSpecialtyCodeID] ASC) ON [FG_Codesets],
    CONSTRAINT [FK_CodeSetCMSProviderSpecialtyCustomSpecialtyCrossWalk_CodeSetSpecialty] FOREIGN KEY ([CustomProviderSpecialtyCodeID]) REFERENCES [dbo].[CodeSetCustomProviderSpecialty] ([CustomProviderSpecialtyCodeID]),
    CONSTRAINT [FK_CodeSetCMSProviderSpecialtyCustomSpecialtyCrossWalk_CodesSetCMSProviderSpecialty] FOREIGN KEY ([CMSProviderSpecialtyCodeID]) REFERENCES [dbo].[CodeSetCMSProviderSpecialty] ([CMSProviderSpecialtyCodeID])
);

