/*    
------------------------------------------------------------------------------    
Procedure Name: usp_BloodTypes_Insert    
Description   : This procedure is used to insert record into BloodTypes table
Created By    : NagaBabu
Created Date  : 12-July-2011  
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
18-Mar-2013 P.V.P.Mohan Modified Table Name from BloodTypes to CodeSetBloodType.
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_BloodTypes_Insert]  
(  
	@i_AppUserId KeyID,
	@v_BloodType SourceName,
	@v_StatusCode StatusCode,
	@o_BloodTypeId KeyID OUTPUT
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

	INSERT INTO CodeSetBloodType
		( 
			BloodType,
			CreatedByUserId,
			StatusCode
	   )
	VALUES
	   ( 
			@v_BloodType,
			@i_AppUserId,
			@v_StatusCode
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_BloodTypeId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert BloodType'
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
    ON OBJECT::[dbo].[usp_BloodTypes_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

