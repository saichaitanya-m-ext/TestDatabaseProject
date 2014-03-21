/*    
------------------------------------------------------------------------------    
Procedure Name: usp_CodeSetLoincCode_Insert
Description   : This Procedure is used to Insert data into CodeSetLoincCode table  
Created By    : P.V.P.MOHAN
Created Date  : 15-Oct-2012
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION  
11-Dec-2012 Mohan Removed statuscode   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_CodeSetLoincCode_Insert]  
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
		@o_LoincCodeId KeyId OUTPUT        
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

	INSERT INTO CodeSetLoincCode
	   ( 
		LoincCode , 
		ShortDescription ,
		LongDescription ,
		Component ,
		Property ,
		TimeAspect ,
		System ,
		ScaleType ,
		MethodType ,
		Class ,
		--StatusCode ,
		CreatedByUserId 
	
	   )
	VALUES
	   (	
		@v_LoincCode , 
		@v_ShortDescription ,
		@v_LongDescription ,
		@v_Component ,
		@v_Property ,
		@v_TimeAspect ,
		@v_System ,
		@v_ScaleType ,
		@v_MethodType ,
		@v_Class ,
		--@v_StatusCode ,
		@i_AppUserId 
	   )	 	
		   
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_LoincCodeId  = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in Insert CodeSetICD'
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
    ON OBJECT::[dbo].[usp_CodeSetLoincCode_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

