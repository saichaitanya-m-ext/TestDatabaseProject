/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CodeSetLoincCode_Update
Description   : This Procedure is used to Update data into CodeSetLoincCode table  
Created By    : P.V.P.MOHAN
Created Date  : 15-Oct-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
11-Dec-2012 Mohan Removed statuscode  
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CodeSetLoincCode_Update]  
(  
	
	@i_AppUserId KeyId,  
	@v_LoincCode VARCHAR(20), 
	@v_ShortDescription VARCHAR(100),
	@v_LongDescription VARCHAR(500),
	@v_Component VARCHAR(500),
	@v_Property VARCHAR(500),
	@v_TimeAspect VARCHAR(25),
	@v_System VARCHAR(100),
	@v_ScaleType VARCHAR(10),
	@v_MethodType VARCHAR(100),
	@v_Class VARCHAR(25),
	@v_StatusCode StatusCode,
	@i_LoincCodeId KeyId     
)  
AS  
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  

	UPDATE CodeSetLoincCode
	   SET   
			LoincCode =  @v_LoincCode , 
			ShortDescription = @v_ShortDescription ,
			LongDescription = @v_LongDescription ,
			Component = @v_Component ,
			Property = @v_Property ,
			TimeAspect = @v_TimeAspect ,
			System =@v_System ,
			ScaleType = @v_ScaleType ,
			MethodType = 	@v_MethodType ,
			Class = 	@v_Class ,
			--StatusCode = 	@v_StatusCode ,
			LastModifiedByUserId = @i_AppUserId ,
		    LastModifiedDate = GETDATE()
	 WHERE LoincCodeId = @i_LoincCodeId
	 
    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
       
    IF @l_numberOfRecordsUpdated <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Update CodeSetICD'
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
    ON OBJECT::[dbo].[usp_CodeSetLoincCode_Update] TO [FE_rohit.r-ext]
    AS [dbo];

