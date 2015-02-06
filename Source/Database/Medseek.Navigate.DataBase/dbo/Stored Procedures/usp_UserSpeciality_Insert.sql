/*
------------------------------------------------------------------------------      
Procedure Name: usp_UserSpeciality_Insert      
Description   : This procedure is used to insert record into UserSpeciality table  
Created By    : Ramachandra     
Created Date  : 01-Mar-2011    
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
03-Mar-2011 NagaBabu Added where condition to select statement 
04-Mar-2011 NagaBabu Added DELETE Statement and Deleted Where clause in select statement      
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_UserSpeciality_Insert]    
(    
 @i_AppUserID KeyID, 
 @i_UserID KeyID, 
 @t_UserspeacialityID ttypeKeyID READONLY
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
--------- Insert Operation into UserSpeciality Table starts here ---------  
    DELETE FROM	
		UserSpeciality
	WHERE
		EXISTS (SELECT	
					1
				FROM
					UserSpeciality
				WHERE
					UserId = @i_UserID
			   )				     

	
	INSERT INTO UserSpeciality
     (   
		UserId,
		SpecialityId,
		CreatedByUserId 
     )  
    
	SELECT
        @i_UserID ,
		UserSpecial.tKeyId,
		@i_AppUserId
    FROM
        @t_UserspeacialityID UserSpecial
  --  WHERE
		--NOT EXISTS (SELECT	
		--				1
		--			FROM
		--				UserSpeciality
		--			WHERE
		--				UserId = @i_UserID
		--			AND SpecialityId = UserSpecial.tKeyId
		--		   )				     
   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          
    IF @l_numberOfRecordsInserted < 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert UserSpeciality'
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
    ON OBJECT::[dbo].[usp_UserSpeciality_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

