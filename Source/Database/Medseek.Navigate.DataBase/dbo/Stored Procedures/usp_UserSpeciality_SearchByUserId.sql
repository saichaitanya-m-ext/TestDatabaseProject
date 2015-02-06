/*
---------------------------------------------------------------------------------
Procedure Name: [usp_UserSpeciality_SearchByUserId]
Description	  : This procedure is used to select all the SpecialityName based on userid. 
Created By    :	NagaBabu 
Created Date  : 03-Mar-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_UserSpeciality_SearchByUserId]
       @i_AppUserId KEYID ,
       @i_UserId KEYID = NULL
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
	  
	  SELECT
		  ProviderSpecialty.ProviderID UserId ,	
		  CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID SpecialityId ,
		  CodeSetCMSProviderSpecialty.ProviderSpecialtyName SpecialityName
	  FROM
		  ProviderSpecialty WITH(NOLOCK)
	  INNER JOIN CodeSetCMSProviderSpecialty	  WITH(NOLOCK) 	           
		  ON ProviderSpecialty.CMSProviderSpecialtyCodeID = CodeSetCMSProviderSpecialty.CMSProviderSpecialtyCodeID
	  WHERE
		  ( ProviderSpecialty.ProviderID = @i_UserId OR @i_UserId IS NULL ) 

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
    ON OBJECT::[dbo].[usp_UserSpeciality_SearchByUserId] TO [FE_rohit.r-ext]
    AS [dbo];

