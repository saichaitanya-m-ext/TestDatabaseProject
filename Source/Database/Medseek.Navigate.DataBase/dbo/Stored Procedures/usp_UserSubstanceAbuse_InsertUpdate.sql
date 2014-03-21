/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserSubstanceAbuse_InsertUpdate   
Description   : This procedure is used to insert/update the data into UserSubstanceAbuse 
Created By    : NagaBabu    
Created Date  : 26-July-2011
------------------------------------------------------------------------------    
Log History   :  
DD-MM-YYYY  BY   DESCRIPTION 
12-07-2014   Sivakrishna Added @i_DataSourceId parameter and added DataSourceId column
			 the insert and update statements.
------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_UserSubstanceAbuse_InsertUpdate]  
(  
	@i_AppUserId KeyId, 
	@i_SubstanceAbuseId KeyId,
	@i_PatientUserId KeyId,
	@v_SubstanceUse CHAR(1) = NULL,
	@i_NoOfYears SMALLINT = NULL,
	@v_StatusCode StatusCode ,
	@v_Comments ShortDescription = NULL,
	@o_UserSubstanceAbuseId KeyId OUTPUT,
	@i_UserSubstanceAbuseId KeyId = NULL,
	@i_DataSourceId KeyId = NULL
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
		
	IF @i_UserSubstanceAbuseId IS NULL
		BEGIN
			INSERT INTO UserSubstanceAbuse
			(
				SubstanceAbuseId,
				PatientId,
				SubstanceUse,
				NoOfYears,
				Comments,
				CreatedByUserId,
				StatusCode,
				DataSourceId
			)
			VALUES
			(
				@i_SubstanceAbuseId,
				@i_PatientUserId,
				@v_SubstanceUse,
				@i_NoOfYears,
				@v_Comments,
				@i_AppUserId,
				@v_StatusCode,
				@i_DataSourceId
			)		
				   	
			SELECT @l_numberOfRecords = @@ROWCOUNT
				  ,@o_UserSubstanceAbuseId = SCOPE_IDENTITY()
		      
			IF @l_numberOfRecords <> 1          
			BEGIN          
				RAISERROR      
					(  N'Invalid row count %d in Insert UserSubstanceAbuse'
						,17      
						,1      
					,@l_numberOfRecords                 
				)              
			END
		END
	ELSE
		BEGIN
			UPDATE UserSubstanceAbuse
			SET SubstanceAbuseId = @i_SubstanceAbuseId,
				PatientId = @i_PatientUserId,
				SubstanceUse = @v_SubstanceUse,
				NoOfYears = @i_NoOfYears,
				Comments = @v_Comments,
				LastModifiedByUserId = @i_AppUserId,
				LastModifiedDate = GETDATE(),
				StatusCode = @v_StatusCode,
				DataSourceId = @i_DataSourceId
			WHERE 
			    UserSubstanceAbuseId = @i_UserSubstanceAbuseId
	   
	   	
			SET @l_numberOfRecords = @@ROWCOUNT
		     
			IF @l_numberOfRecords <> 1          
			BEGIN          
				RAISERROR      
					(  N'Invalid row count %d in Update UserSubstanceAbuse'
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
    ON OBJECT::[dbo].[usp_UserSubstanceAbuse_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

