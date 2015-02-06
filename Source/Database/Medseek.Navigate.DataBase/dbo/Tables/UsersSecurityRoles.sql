CREATE TABLE [dbo].[UsersSecurityRoles] (
    [UsersSecurityRoleId] [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [SecurityRoleId]      [dbo].[KeyID]    NOT NULL,
    [ProviderID]          [dbo].[KeyID]    NULL,
    [PatientID]           [dbo].[KeyID]    NULL,
    [CreatedByUserId]     [dbo].[KeyID]    NULL,
    [CreatedDate]         [dbo].[UserDate] CONSTRAINT [DF_UsersSecurityRoles_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_UsersSecurityRoles] PRIMARY KEY CLUSTERED ([UsersSecurityRoleId] ASC) WITH (FILLFACTOR = 25),
    CONSTRAINT [FK_UsersSecurityRoles_Patient] FOREIGN KEY ([PatientID]) REFERENCES [dbo].[Patient] ([PatientID]),
    CONSTRAINT [FK_UsersSecurityRoles_Provider] FOREIGN KEY ([ProviderID]) REFERENCES [dbo].[Provider] ([ProviderID]),
    CONSTRAINT [FK_UsersSecurityRoles_SecurityRole] FOREIGN KEY ([SecurityRoleId]) REFERENCES [dbo].[SecurityRole] ([SecurityRoleId])
);


GO
/*                          
---------------------------------------------------------------------          
Trigger Name: [dbo].[tr_Delete_UsersSecurityRoles]     
Description:                         
When   Who    Action                          
---------------------------------------------------------------------          
12-Aug-2010  NagaBabu  Created                          
24-Sep-10 Pramod Removed the aspnet delete and included direct delete
30-Sep-2010 Rathnam Enhanced the entire trigger to support multi delete.
---------------------------------------------------------------------          
*/
CREATE TRIGGER [dbo].[tr_Delete_UsersSecurityRoles] ON dbo.UsersSecurityRoles
       AFTER DELETE
AS
BEGIN

      DECLARE @t_UsersSecurityRoles TABLE
     (
        UserId UNIQUEIDENTIFIER
       ,RoleId UNIQUEIDENTIFIER
     )


      DECLARE @v_SecurityRoleName VARCHAR(500)
      SELECT
          @v_SecurityRoleName = s.RoleName
      FROM
          SecurityRole s
      INNER JOIN inserted i
          ON i.SecurityRoleId = S.SecurityRoleId

      IF @v_SecurityRoleName <> 'Patient'
         BEGIN

               INSERT
                   @t_UsersSecurityRoles
                   SELECT
                       aspnet_Users.UserId
                      ,aspnet_Roles.RoleId
                   FROM
                       Deleted
                   INNER JOIN Provider
                       ON Deleted.ProviderID = Provider.ProviderID
                   INNER JOIN SecurityRole
                       ON SecurityRole.SecurityRoleId = Deleted.SecurityRoleId
                   INNER JOIN Users
                       ON Users.UserId = Provider.UserID
                   INNER JOIN aspnet_Users
                       ON aspnet_Users.UserName = Users.UserLoginName
                   INNER JOIN aspnet_Roles
                       ON aspnet_Roles.RoleName = SecurityRole.RoleName
         END
      ELSE
         BEGIN
               INSERT
                   @t_UsersSecurityRoles
                   SELECT
                       aspnet_Users.UserId
                      ,aspnet_Roles.RoleId
                   FROM
                       Deleted
                   INNER JOIN Patient
                       ON Deleted.PatientID = Patient.PatientID
                   INNER JOIN SecurityRole
                       ON SecurityRole.SecurityRoleId = Deleted.SecurityRoleId
                   INNER JOIN Users
                       ON Users.UserId = Patient.UserID
                   INNER JOIN aspnet_Users
                       ON aspnet_Users.UserName = Users.UserLoginName
                   INNER JOIN aspnet_Roles
                       ON aspnet_Roles.RoleName = SecurityRole.RoleName
         END

      DELETE
              aspnet_UsersInRoles
      FROM
              @t_UsersSecurityRoles UR
      WHERE
              aspnet_UsersInRoles.UserId = UR.UserId
              AND aspnet_UsersInRoles.RoleId = UR.RoleId

END

GO
/*                        
---------------------------------------------------------------------        
Trigger Name: [dbo].[tr_Insert_UsersSecurityRoles]   
Description: On Insert of a record in SecurityRole call the aspnet SP
			 to insert into aspnet security tables
When   Who    Action                        
---------------------------------------------------------------------        
12-Aug-2010 NagaBabu  Created                        
30-Sep-2010 Rathnam Enhanced the entire trigger to support multi inserts                
---------------------------------------------------------------------        
*/
CREATE TRIGGER [dbo].[tr_Insert_UsersSecurityRoles] ON dbo.UsersSecurityRoles
       AFTER INSERT
AS
BEGIN

      DECLARE @t_UsersSecurityRoles TABLE
     (
        UserId UNIQUEIDENTIFIER
       ,RoleId UNIQUEIDENTIFIER
     )

      DECLARE @v_SecurityRoleName VARCHAR(500)
      SELECT
          @v_SecurityRoleName = s.RoleName
      FROM
          SecurityRole s
      INNER JOIN inserted i
          ON i.SecurityRoleId = S.SecurityRoleId

      IF @v_SecurityRoleName <> 'Patient'
         BEGIN
               INSERT
                   @t_UsersSecurityRoles
                   SELECT
                       aspnet_Users.UserId
                      ,aspnet_Roles.RoleId
                   FROM
                       Inserted
                   INNER JOIN Provider
                       ON Inserted.ProviderID = Provider.ProviderID
                   INNER JOIN SecurityRole
                       ON SecurityRole.SecurityRoleId = INSERTED.SecurityRoleId
                   INNER JOIN Users
                       ON Users.UserId = Provider.UserID
                   INNER JOIN aspnet_Users
                       ON aspnet_Users.UserName = Users.UserLoginName
                   INNER JOIN aspnet_Roles
                       ON aspnet_Roles.RoleName = SecurityRole.RoleName
         END
      ELSE
         BEGIN
               INSERT
                   @t_UsersSecurityRoles
                   SELECT
                       aspnet_Users.UserId
                      ,aspnet_Roles.RoleId
                   FROM
                       Inserted
                   INNER JOIN Patient
                       ON Inserted.PatientID = Patient.PatientID
                   INNER JOIN SecurityRole
                       ON SecurityRole.SecurityRoleId = INSERTED.SecurityRoleId
                   INNER JOIN Users
                       ON Users.UserId = Patient.UserID
                   INNER JOIN aspnet_Users
                       ON aspnet_Users.UserName = Users.UserLoginName
                   INNER JOIN aspnet_Roles
                       ON aspnet_Roles.RoleName = SecurityRole.RoleName


         END
      INSERT INTO
          aspnet_UsersInRoles
          (
            UserId
          ,RoleId
          )
          SELECT
              UserId
             ,RoleId
          FROM
              @t_UsersSecurityRoles UR
          WHERE
              NOT EXISTS ( SELECT
                               1
                           FROM
                               aspnet_UsersInRoles
                           WHERE
                               UserId = UR.UserId
                               AND RoleId = UR.RoleId )

END

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Not used in the application', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the UsersSecurityRoles Table - Identity', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles', @level2type = N'COLUMN', @level2name = N'UsersSecurityRoleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the SecurityRole table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles', @level2type = N'COLUMN', @level2name = N'SecurityRoleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table - indicates the user that was granted the specific security role', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles', @level2type = N'COLUMN', @level2name = N'ProviderID';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foreign key to the Users table indicating the user that created the Record', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles', @level2type = N'COLUMN', @level2name = N'CreatedDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Date the record was created', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UsersSecurityRoles', @level2type = N'COLUMN', @level2name = N'CreatedDate';

