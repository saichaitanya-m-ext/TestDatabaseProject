
/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_UserMedicalConditionHistory_Update]
Description   : This procedure used to update data into UserMedicalConditionHistory table
Created By    : Rama Krishna Prasad
Created Date  : 07/07/2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
07-July-2011 NagaBabu Added @d_StartDate,@d_EndDate as input parameters   
20-Mar-2013 P.V.P.Mohan modified UserMedicalConditionHistory to PatientMedicalConditionHistory
			and modified columns.   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserMedicalConditionHistory_Update]  
(  
	@i_AppUserId KeyID ,
	@i_PatientUserId KeyID ,
	@i_MedicalConditionID KeyID,
	@v_Comments ShortDescription = NULL,
	@v_Recommendations_consultation ShortDescription = NULL,
	@v_StatusCode StatusCode ,
	@i_UserMedicalConditionID KeyID,
	@d_StartDate USERDATE ,
	@d_EndDate USERDATE = NULL
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  

	 UPDATE PatientMedicalConditionHistory
	    SET PatientID = @i_PatientUserId,
			MedicalConditionID = @i_MedicalConditionID,
			Comments  = @v_Comments,
			RecommendationsConsultation = @V_Recommendations_consultation,
			StatusCode = @v_StatusCode ,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StartDate = @d_StartDate ,
			EndDate = @d_EndDate
	 WHERE PatientMedicalConditionID = @i_UserMedicalConditionID
	   
	   	
    SET @l_numberOfRecordsUpdated = @@ROWCOUNT
     
    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update UserMedicalCondition'
				,17      
				,1      
				,@l_numberOfRecordsUpdated                 
			)              
	END  

	RETURN 0 
  
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserMedicalConditionHistory_Update] TO [FE_rohit.r-ext]
    AS [dbo];

