CREATE TABLE [dbo].[Pharmacy] (
    [PharmacyId]      [dbo].[KeyID]            IDENTITY (1, 1) NOT NULL,
    [PharmacyName]    [dbo].[ShortDescription] NOT NULL,
    [CreatedByUserId] [dbo].[KeyID]            NOT NULL,
    [CreatedDate]     DATETIME                 CONSTRAINT [DF_CodeSetPharmacy_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CodeSetPharmacy] PRIMARY KEY CLUSTERED ([PharmacyId] ASC) ON [FG_Library]
);

