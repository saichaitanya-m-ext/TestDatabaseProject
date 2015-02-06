/*
---------------------------------------------------------------------------------
Procedure Name: [usp_UserSpeciality_Select_DD]
Description	  : This Procedure is used to give PCPName list in the system
Created By    :	NagaBabu
Created Date  : 24-Aug-2011
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_UserSpeciality_Select_DD] 
(
	@i_AppUserId KEYID
)	
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
--------------------------------------------------------------------------------------

		SELECT DISTINCT
			UserSpeciality.UserId AS PCPId,
			COALESCE(ISNULL(Users.LastName , '') + ', '     
			   + ISNULL(Users.FirstName , '') + '. '     
			   + ISNULL(Users.MiddleName , '') + ' '  
			   + ISNULL(Users.UserNameSuffix ,'')    
			,'') AS PCPName   
		FROM 
			UserSpeciality WITH(NOLOCK)
		INNER JOIN Users   WITH(NOLOCK)
			ON UserSpeciality.UserId = Users.UserId
		INNER JOIN Speciality WITH(NOLOCK)
			ON Speciality.SpecialityId = UserSpeciality.SpecialityId
		WHERE 
			SpecialityName IN('Internal Medicine','Family Medicine','Pediatricians','Obs & Gyn') 	
		AND	Speciality.StatusCode = 'A'
		AND Users.UserStatusCode = 'A'
		AND Users.IsPhysician = 1

END TRY
--------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserSpeciality_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

