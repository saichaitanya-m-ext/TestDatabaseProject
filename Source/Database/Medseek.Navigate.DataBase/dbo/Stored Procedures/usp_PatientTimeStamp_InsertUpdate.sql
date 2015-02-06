/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PatientTimeStamp_InsertUpdate]
Description   : This procedure is used to insert or update data into PatientTimeStamp
Created By    : NagaBabu
Created Date  : 21-July-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
22-July-2011 NagaBabu replaced clientIPAddress by SystemGUID  
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PatientTimeStamp_InsertUpdate]  
(  
	@i_AppUserId KeyId, 
	@i_PatientUserID KeyId,
	@v_SystemGUID VARCHAR(150) = NULL,
	@o_DashboardTimestampId KeyId OUTPUT,
	@v_DashboardTimestampId VARCHAR(150) = NULL
)  
AS    
BEGIN TRY  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecords SMALLINT
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR ( N'Invalid Application User ID %d passed.' ,  
		   17 ,  
		   1 ,  
		   @i_AppUserId )  
	END  
    IF @v_DashboardTimestampId IS NULL
		BEGIN 
			INSERT INTO PatientTimeStamp
			   (
					CareProviderid,
					PatientUserID,
					SystemGUID
			   )
			VALUES
			   (  
				    @i_AppUserId ,
					@i_PatientUserID,
					@v_SystemGUID
			   )
				   	
			SELECT @l_numberOfRecords = @@ROWCOUNT
				  ,@o_DashboardTimestampId = SCOPE_IDENTITY()
		      
			IF @l_numberOfRecords <> 1          
			BEGIN          
				RAISERROR      
					(  N'Invalid row count %d in Insert PatientTimeStamp'
						,17      
						,1      
					,@l_numberOfRecords                 
				)              
			END
		END
	ELSE
		BEGIN
			UPDATE PatientTimeStamp
			SET OutDateTime = GETDATE()
			WHERE
				SystemGUID = @v_DashboardTimestampId	
						
			SET @l_numberOfRecords = @@ROWCOUNT
		     
			IF @l_numberOfRecords <> 1          
			BEGIN          
				RAISERROR      
					(  N'Invalid row count %d in Update PatientTimeStamp'
						,17      
						,1      
						,@l_numberOfRecords                 
					)              
			END  
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
    ON OBJECT::[dbo].[usp_PatientTimeStamp_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

