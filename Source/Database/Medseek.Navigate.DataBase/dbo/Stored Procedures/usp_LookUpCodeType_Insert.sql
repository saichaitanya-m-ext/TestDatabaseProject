
/*    
------------------------------------------------------------------------------    
Procedure Name: [[usp_LookUpCodeType_Insert]]    
Description   : This procedure is used to insert record into LkUpCodeType_Test table (Node)
Created By    : Rama Krishna PRasad    
Created Date  : 05-Dec-2013    
------------------------------------------------------------------------------    
 
*/ 
CREATE PROCEDURE [dbo].[usp_LookUpCodeType_Insert]  --1,null,'test28','test','test','test',null
(  
	@i_AppUserId KeyID,
	@i_CodeTypeID KeyID,
	@vc_CodeTypeCode VARCHAR(150) ,
	@vc_CodeTypeName VARCHAR(300) ,
	@vc_TypeDescription VARCHAR(4000) ,
	@vc_CodeTableName VARCHAR(300) ,
	@o_CodeTypeId KeyID OUTPUT 
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

	INSERT INTO LkUpCodeType_Test
		( 
			CodeTypeCode,
			CodeTypeName,
			TypeDescription,
			CodeTableName
	   )
	VALUES
	   ( 
			@vc_CodeTypeCode,
			@vc_CodeTypeName,
			@vc_TypeDescription,
			@vc_CodeTableName
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_CodeTypeId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert Activity Type'
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
    ON OBJECT::[dbo].[usp_LookUpCodeType_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

