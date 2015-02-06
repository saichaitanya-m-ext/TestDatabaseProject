/*
---------------------------------------------------------------------------------
Procedure Name: [usp_UserSpeciality_SearchBySpecialityId]
Description	  : This procedure is used to select all the Provider Details based on SpecialityId. 
Created By    :	NagaBabu 
Created Date  : 04-May-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_UserSpeciality_SearchBySpecialityId]
       @i_AppUserId KEYID ,
       @tblSpecialityId ttypeKeyID READONLY
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
    IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
    BEGIN
        RAISERROR ( N'Invalid Application User ID %d passed.' ,
        17 ,
        1 ,
        @i_AppUserId )
    END
      
  ---------------Getting data from UserSpeciality table----------------------
	  
	  SELECT DISTINCT
		  UserSpeciality.UserId ,
		  COALESCE(ISNULL(Users.LastName , '') + ', '   
			+ ISNULL(Users.FirstName , '') + '. '   
			+ ISNULL(Users.MiddleName , '') + ' '
			+ ISNULL(Users.UserNameSuffix ,'')  
		  ,'') AS UserName 
	  FROM
	      @tblSpecialityId tblSpecialityId
	  INNER JOIN UserSpeciality with (nolock)
	      ON tblSpecialityId.tKeyId = UserSpeciality.SpecialityId
	  INNER JOIN Users with (nolock)
		  ON UserSpeciality.UserId = Users.UserId	  

END TRY
------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserSpeciality_SearchBySpecialityId] TO [FE_rohit.r-ext]
    AS [dbo];

