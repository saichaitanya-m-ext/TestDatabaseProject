CREATE TABLE [dbo].[UserGroup] (
    [UserGroupId]     [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [UserID]          [dbo].[KeyID]    NOT NULL,
    [ProviderID]      [dbo].[KeyID]    NULL,
    [CreatedByUserId] [dbo].[KeyID]    NOT NULL,
    [CreatedDate]     [dbo].[UserDate] CONSTRAINT [DF_UserGroup_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_UserGroup] PRIMARY KEY CLUSTERED ([UserGroupId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_UserGroup_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_UserGroup_Users] FOREIGN KEY ([UserID]) REFERENCES [dbo].[Users] ([UserId])
);

