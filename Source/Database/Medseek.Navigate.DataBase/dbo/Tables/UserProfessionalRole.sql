CREATE TABLE [dbo].[UserProfessionalRole] (
    [UserProfessionalRoleId] INT      IDENTITY (1, 1) NOT NULL,
    [PatientId]              INT      NOT NULL,
    [ProfessionalRoleId]     INT      NOT NULL,
    [CreatedByUserId]        INT      NOT NULL,
    [CreatedDate]            DATETIME CONSTRAINT [DF_UserProfessionalRole_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_UserProfessionalRole] PRIMARY KEY CLUSTERED ([UserProfessionalRoleId] ASC),
    CONSTRAINT [FK_UserProfessionalRole_Patient] FOREIGN KEY ([PatientId]) REFERENCES [dbo].[Patient] ([PatientID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_UserId_ProfessionalRoleId]
    ON [dbo].[UserProfessionalRole]([PatientId] ASC, [ProfessionalRoleId] ASC) WITH (FILLFACTOR = 100)
    ON [FG_Transactional_NCX];

