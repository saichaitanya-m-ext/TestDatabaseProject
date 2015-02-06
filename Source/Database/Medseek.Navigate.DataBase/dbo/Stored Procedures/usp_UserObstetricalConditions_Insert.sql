/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserObstetricalConditions_Insert      
Description   : This procedure is used to insert record into UserObstetricalConditions table  
Created By    : Udaykumar      
Created Date  : 6-July-2011      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
20-Mar-2013 P.V.P.Mohan modified UserObstetricalConditions columns.     
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_UserObstetricalConditions_Insert]    
(    
 @i_AppUserId KeyID,  
 @i_ObstetricalConditionsID KeyID,  
 @i_UserID KeyID,  
 @d_StartDate UserDate,
 @d_EndDate userdate =NULL,     
 @v_Comments LongDescription =NULL,  
 @v_StatusCode StatusCode,
 @o_UserObstetricalConditionsID KeyID OUTPUT  ,
 @i_DataSourceId KeyId
) 
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
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
--------- Insert Operation into UserObstetricalConditions Table starts here ---------  
   
 INSERT INTO UserObstetricalConditions  
    (   
      ObstetricalConditionsID  
     ,PatientID 
     ,StartDate
     ,EndDate  
     ,Comments  
     ,CreatedByUserId  
     ,StatusCode
     ,DataSourceId
    )  
 VALUES
	(  
		 @i_ObstetricalConditionsID
		,@i_UserID 
		,@d_StartDate
        ,@d_EndDate 
		,@v_Comments  
		,@i_AppUserId  
		,@v_StatusCode
		,@i_DataSourceId
     )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_UserObstetricalConditionsID = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert UserObstetricalConditions'
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
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserObstetricalConditions_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

