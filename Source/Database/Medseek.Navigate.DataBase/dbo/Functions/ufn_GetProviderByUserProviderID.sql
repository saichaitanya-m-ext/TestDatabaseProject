CREATE FUNCTION [dbo].[ufn_GetProviderByUserProviderID]
(
  @i_UserProviderID KeyID
)
RETURNS VARCHAR(150)
AS
BEGIN
      DECLARE @v_Name VARCHAR(150),
			  @v_InternalProviderName VARCHAR(150),
			  @v_ExternalProviderName VARCHAR(150)
  
      SELECT @v_InternalProviderName =
			 (SELECT COALESCE(ISNULL(Users.FirstName,'') + ' ' + ISNULL(Users.MiddleName,'') + ' ' 
					  + ISNULL(Users.LastName,''),'')
			    FROM Users
			   WHERE Users.UserId = UserProviders.ProviderUserId
			     AND Users.IsProvider = 1
			 ), 
			 @v_ExternalProviderName =
			 (SELECT COALESCE(ISNULL(ExternalCareProvider.FirstName,'') + ' ' 
					  + ISNULL(ExternalCareProvider.MiddleName,'') + ' ' 
					  + ISNULL(ExternalCareProvider.LastName,''),'') 
			    FROM ExternalCareProvider
			   WHERE ExternalCareProvider.ExternalProviderId = UserProviders.ExternalProviderId
			 ) 
        FROM UserProviders
       WHERE UserProviders.UserProviderId = @i_UserProviderID

	  IF @v_InternalProviderName <> ''
	     SET @v_Name = @v_InternalProviderName
	  ELSE
	     SET @v_Name = @v_ExternalProviderName

      RETURN ISNULL(@v_Name,'')
END
