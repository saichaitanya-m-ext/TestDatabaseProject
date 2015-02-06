

/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserObstetricalConditions_Update   
Description   : This procedure is used to Update record into UserObstetricalConditions table
Created By    : udaykumar    
Created Date  : 6-July-2011   
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
20-Mar-2013 P.V.P.Mohan modified UserObstetricalConditions table 
			and modified columns.   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserObstetricalConditions_Update]  
(  
 @i_AppUserId KeyID,  
 @i_ObstetricalConditionsID KeyID,  
 @i_UserID KeyID,  
 @d_StartDate UserDate,
 @d_EndDate userdate =NULL,   
 @v_Comments LongDescription =NULL,  
 @v_StatusCode StatusCode,
 @i_UserObstetricalConditionsID KeyID  ,
 @i_DataSourceId KeyId 
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

	 UPDATE UserObstetricalConditions
	    SET	ObstetricalConditionsID = @i_ObstetricalConditionsID,
	        StartDate = @d_StartDate,
	        EndDate = @d_EndDate,
	        Comments = @v_Comments,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			StatusCode = @v_StatusCode,
			DataSourceId = @i_DataSourceId
	  WHERE UserObstetricalConditionsID = @i_UserObstetricalConditionsID 
			AND PatientID = @i_UserID

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update UserObstetricalConditions'  
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserObstetricalConditions_Update] TO [FE_rohit.r-ext]
    AS [dbo];

