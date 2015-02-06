/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserFamilyMedicalHistory_InsertUpdate   
Description   : This procedure is used to insert/update the data into UserFamilyMedicalHistory 
Created By    : Rathnam    
Created Date  : 7-July-2011    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
20-Mar-2013 P.V.P.Mohan modified UserFamilyMedicalHistory to PatientFamilyMedicalHistory
			and modified columns.
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserFamilyMedicalHistory_InsertUpdate]  
(  
	@i_AppUserId KeyId, 
	@i_UserId KeyId ,
	@d_StartDate UserDate ,
	@d_EndDate UserDate = NULL,
	@i_DiseaseId KeyId ,  
	@i_RelationId KeyId,  
	@v_Comments LongDescription = NULL,
	@v_StatusCode StatusCode ,
	@i_UserFamilyMedicalHistoryID KEYID = NULL,
	@o_UserFamilyMedicalHistoryID KeyID OUT,
	@i_DataSourceId KeyId
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
    IF @i_UserFamilyMedicalHistoryID IS NULL
		BEGIN 
			INSERT INTO PatientFamilyMedicalHistory
			   (
				PatientID,
				StartDate,
				EndDate,
				DiseaseId,  
				RelationId,  
				Comments ,
				StatusCode ,
				CreatedByUserId,
				DataSourceId
			   )
			VALUES
			   (
				@i_UserId,  
				@d_StartDate ,
				@d_EndDate ,
				@i_DiseaseId ,  
				@i_RelationId,  
				@v_Comments ,
				@v_StatusCode ,
				@i_AppUserId,
				@i_DataSourceId
				)
				   	
			SELECT @l_numberOfRecords = @@ROWCOUNT
				  ,@o_UserFamilyMedicalHistoryID = SCOPE_IDENTITY()
		      
			IF @l_numberOfRecords <> 1          
			BEGIN          
				RAISERROR      
					(  N'Invalid row count %d in Insert UserFamilyMedicalHistory'
						,17      
						,1      
					,@l_numberOfRecords                 
				)              
			END
		END
	ELSE
		BEGIN
			UPDATE PatientFamilyMedicalHistory
			SET PatientID = @i_UserId,
				StartDate = @d_StartDate,
				EndDate = @d_EndDate,
				DiseaseId = @i_DiseaseId,
				RelationId = @i_RelationId,
				Comments = @v_Comments,
				StatusCode = @v_StatusCode ,
				LastModifiedByUserId = @i_AppUserId,
				LastModifiedDate = GETDATE(),
				DataSourceId = @i_DataSourceId
			WHERE 
			    PatientFamilyMedicalHistoryID = @i_UserFamilyMedicalHistoryID
	   
	   	
			SET @l_numberOfRecords = @@ROWCOUNT
		     
			IF @l_numberOfRecords <> 1          
			BEGIN          
				RAISERROR      
					(  N'Invalid row count %d in Update UserFamilyMedicalHistory'
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
    ON OBJECT::[dbo].[usp_UserFamilyMedicalHistory_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

