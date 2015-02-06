
/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_MedicalConditionHistory_Insert] 
Description	  : This procedure is used to Insert the data into UserMedicalConditionHistory table.
Created By    :	Rama Krishna Prasad B
Created Date  : 07/06/2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
07-July-2011 NagaBabu Added @d_StartDate,@d_EndDate as input parameters 
20-Mar-2013 P.V.P.Mohan modified UserMedicalConditionHistory to PatientMedicalConditionHistory
			and modified columns.     
------------------------------------------------------------------------------    
*/
  
CREATE PROCEDURE [dbo].[usp_MedicalConditionHistory_Insert] 
(
	@i_AppUserId KEYID ,
	@i_PatientUserId KEYID ,
	@i_MedicalConditionID KEYID ,
	@s_Comments ShortDescription = NULL,
	@s_RecommendationsConsultation ShortDescription = NULL,
	@v_StatusCode StatusCode ,
	@d_StartDate USERDATE ,
	@d_EndDate USERDATE = NULL,
	@o_UserMedicalConditionID  KEYID OUT
)
AS  
BEGIN TRY  
      SET NOCOUNT ON  
      DECLARE @l_numberOfRecordsInserted INT
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END    
    
---------insert operation into UserMedicalConditionHistory table-----       
         INSERT INTO PatientMedicalConditionHistory   
             (  
               MedicalConditionID ,
               Comments,
               RecommendationsConsultation, 
               StatusCode ,
               CreatedByUserId,
               PatientID ,
               StartDate,
			   EndDate
             )  
         VALUES  
             ( 
			   @i_MedicalConditionID ,
			   @s_Comments,
			   @s_RecommendationsConsultation,
               @v_StatusCode ,
               @i_AppUserId,
               @i_PatientUserId,
               @d_StartDate,
			   @d_EndDate
              )  
                 
		 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT,
				@o_UserMedicalConditionID = SCOPE_IDENTITY()
		 IF @l_numberOfRecordsInserted <> 1          
		 BEGIN          
			 RAISERROR      
				 (  N'Invalid row count %d in insert UserMedicalConditionHistory'
					 ,17      
					 ,1      
					 ,@l_numberOfRecordsInserted                 
				 )              
		 END                 
  
    RETURN 0

END TRY        
------------------------------------------------------         
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MedicalConditionHistory_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

