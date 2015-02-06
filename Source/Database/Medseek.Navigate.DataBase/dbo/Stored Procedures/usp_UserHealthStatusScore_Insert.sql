--[usp_UserHealthStatusScore_Insert]    33,33,'55','ghjghj','4/22/2010 12:00:00 AM',6,'4/22/2010 12:00:00 AM','A',null  
  
  
/*        
------------------------------------------------------------------------------        
Procedure Name: usp_UserHealthStatusScore_Insert        
Description   : This procedure is used to insert record into UserHealthStatusScore table    
Created By    : Aditya        
Created Date  : 22-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
03-feb-2011 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  UserHealthStatusScore table  
------------------------------------------------------------------------------        
*/      
CREATE PROCEDURE [dbo].[usp_UserHealthStatusScore_Insert]      
(      
 @i_AppUserId KeyId,      
 @i_UserId KeyId,    
 @vc_Score Varchar(100),    
 --@vc_ScoreText ShortDescription,    
 @vc_Comments varchar(200),     
 @dt_DateDetermined UserDate,    
 @i_HealthStatusScoreId KeyID,    
 @dt_DateDue UserDate,    
 @vc_StatusCode StatusCode,    
 @o_UserHealthStatusId KeyID OUTPUT  ,
 @b_IsAdhoc  BIT = 0
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
	    
	 INSERT INTO PatientHealthStatusScore    
		(     
		   PatientID,    
		   Score,    
		   ScoreText,    
		   Comments,    
		   DateDetermined,    
		   HealthStatusScoreId,    
		   DateDue,    
		   StatusCode,    
		   IsAdhoc ,
		   CreatedByUserId    
		)    
	 VALUES    
		(       
		   @i_UserId,    
		   CASE ISNUMERIC(@vc_Score) WHEN 1 THEN  @vc_Score ELSE NULL END,    
		   CASE ISNUMERIC(@vc_Score) WHEN 0 THEN  @vc_Score ELSE NULL END,    
		   @vc_Comments,     
		   @dt_DateDetermined,    
		   @i_HealthStatusScoreId,    
		   @dt_DateDue,    
		   @vc_StatusCode, 
		   @b_IsAdhoc  ,   
		   @i_AppUserId    
		)    
	         
	 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT    
		   ,@o_UserHealthStatusId = SCOPE_IDENTITY()    
	          
	 IF @l_numberOfRecordsInserted <> 1              
	 BEGIN              
		  RAISERROR          
		   (  N'Invalid row count %d in insert UserHealthStatusScore Table'          
			,17          
			,1          
			,@l_numberOfRecordsInserted                     
		   )                  
	 END      
	    
	 RETURN 0     
      
END TRY        
--------------------------------------------------------         
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT      
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId      
      
      RETURN @i_ReturnedErrorID      
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserHealthStatusScore_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

