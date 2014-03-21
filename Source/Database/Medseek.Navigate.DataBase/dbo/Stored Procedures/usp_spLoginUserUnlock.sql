/*    
------------------------------------------------------------------------------    
Procedure Name: [dbo].[usp_spLoginUserUnlock]
Description   : This procedure is used to Unlock the loginuser 
Created By    : NagaBabu
Created Date  : 20-July-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    

------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_spLoginUserUnlock]
(  
	@i_AppUserId KeyId,
	@v_UserName VARCHAR(50) 
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
	
	IF NOT EXISTS ( SELECT 
						1
					FROM
						aspnet_Users
					WHERE UserName = @v_UserName )
					
		PRINT 'Given Login User does not exist'							
	ELSE
		BEGIN
			UPDATE aspnet_Membership
			SET IsLockedOut = 0
			FROM aspnet_Membership AM
			INNER JOIN aspnet_Users AU
				ON AU.UserId = AM.UserId 
			WHERE AU.UserName = @v_UserName	

			SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
				 
				 IF @l_numberOfRecordsUpdated <> 1          
					 BEGIN          
						 RAISERROR      
							 (  N'Invalid row count %d in Update aspnet_Membership'
								 ,17      
								 ,1      
								 ,@l_numberOfRecordsUpdated                 
							 )              
					 END  
				ELSE
					PRINT 'Given LoginUser Unlocked Successfully'		                
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
    ON OBJECT::[dbo].[usp_spLoginUserUnlock] TO [FE_rohit.r-ext]
    AS [dbo];

