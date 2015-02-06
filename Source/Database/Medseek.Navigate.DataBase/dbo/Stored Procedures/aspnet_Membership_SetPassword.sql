--sp_helptext aspnet_Membership_GetUserByName
--sp_helptext aspnet_Membership_SetPassword
--sp_helptext aspnet_Membership_ResetPassword

CREATE PROCEDURE [dbo].[aspnet_Membership_SetPassword]  
       @ApplicationName NVARCHAR(256) ,  
       @UserName NVARCHAR(256) ,  
       @NewPassword NVARCHAR(128) ,  
       @PasswordSalt NVARCHAR(128) ,  
       @CurrentTimeUtc DATETIME ,  
       @PasswordFormat INT = 0  
AS  
BEGIN  
      DECLARE @UserId UNIQUEIDENTIFIER  
      SELECT  
          @UserId = NULL  
      SELECT  
          @UserId = u.UserId  
      FROM  
          dbo.aspnet_Users u ,  
          dbo.aspnet_Applications a ,  
          dbo.aspnet_Membership m  
      WHERE  
          LoweredUserName = LOWER(@UserName) AND u.ApplicationId = a.ApplicationId AND LOWER(@ApplicationName) = a.LoweredApplicationName AND u.UserId = m.UserId  
  
      IF ( @UserId IS NULL )  
         RETURN ( 1 )  
  
      UPDATE  
          dbo.aspnet_Membership  
      SET  
          Password = @NewPassword ,  
          PasswordFormat = @PasswordFormat ,  
          PasswordSalt = @PasswordSalt ,  
          LastPasswordChangedDate = @CurrentTimeUtc , 
          IsUserGeneratedPassword = 1
          
      WHERE  
          @UserId = UserId  
      RETURN ( 0 )  
END  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[aspnet_Membership_SetPassword] TO [FE_rohit.r-ext]
    AS [dbo];

