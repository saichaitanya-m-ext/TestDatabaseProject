/*    
--------------------------------------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_CareProviderDashBoard_PatientDetailByDisease]  
Description   : This procedure is used for getting the patient detail specific to a disease
Created By    : Pramod  
Created Date  : 3-Jun-2010
---------------------------------------------------------------------------------------------------------------    
Log History   :     
DD-Mon-YYYY  BY  DESCRIPTION    
   
---------------------------------------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_PatientDetailByDisease]
( @i_AppUserId KEYID,  
  @i_DiseaseId KeyID
)    
AS    
BEGIN TRY     
   SET NOCOUNT ON
-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
	BEGIN    
	   RAISERROR ( N'Invalid Application User ID %d passed.' ,
	   17 ,
	   1 ,
	   @i_AppUserId )
	END

	DECLARE
		@tblPatients UserIdTblType --TABLE (PatientUserId KeyID)

	INSERT INTO @tblPatients
	SELECT UserId
	  FROM UserDisease
	 WHERE DiseaseID = @i_DiseaseId
	   AND UserDisease.StatusCode = 'A'
	   
	EXEC usp_CareProviderDashBoard_PatientDetail
		@i_AppUserId = @i_AppUserId,
		@t_tblPatientUserId = @tblPatients

END TRY    
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_PatientDetailByDisease] TO [FE_rohit.r-ext]
    AS [dbo];

