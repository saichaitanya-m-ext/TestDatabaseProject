﻿/*    
------------------------------------------------------------------------------    
Procedure Name: usp_OrganizationContactsTypes_Insert    
Description   : This procedure is used to insert record into OrganizationType table
Created By    : Pramod    
Created Date  : 24-Feb-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_OrganizationContactsTypes_Insert]  
(  
	@i_AppUserId INT,  
	@v_Name VARCHAR(100), 
	@v_StatusCode StatusCode,
	@o_ContactTypeId KeyID OUTPUT
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

	INSERT INTO OrganizationContactsType
	   ( Name
	    ,CreatedByUserId
	    ,StatusCode
	   )
	VALUES
	   ( @v_Name
	    ,@i_AppUserId
	    ,@v_StatusCode
	   )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_ContactTypeId = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert Organization Contact Type'
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
    ON OBJECT::[dbo].[usp_OrganizationContactsTypes_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

