/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserMeasure_Update    
Description   : This procedure is used to Update record into UserMeasure table
Created By    : Aditya    
Created Date  : 16-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
04-APR-2013 P.V.P.MOHAN modified UserMeasure Table to PatientMeasure and Columns of that Table .     
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserMeasure_Update]  
(  
	@i_AppUserId KeyID,  
	@i_PatientUserId	KeyID,
	@i_MeasureId	KeyID,
	@i_MeasureUOMId	KeyID,
	@vc_MeasureValue VARCHAR(200),
	--@vc_MeasureValueText	varchar(200) ,
	--@i_MeasureValueNumeric	decimal(10,2) ,
	@vc_Comments	varchar(200),
	@i_isPatientAdministered	IsIndicator,
	@dt_DateTaken	UserDate,
	@dt_DueDate	UserDate,
	
	@vc_StatusCode	StatusCode,
	@i_UserMeasureId	KeyID ,
	@i_DataSourceId KeyId
)  
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
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

	 UPDATE PatientMeasure
	    SET	PatientID = @i_PatientUserId,
			MeasureId = @i_MeasureId,
			MeasureUOMId = @i_MeasureUOMId,
			MeasureValueText = CASE ISNUMERIC(@vc_MeasureValue) WHEN 0 THEN  @vc_MeasureValue ELSE NULL END,
			MeasureValueNumeric = CASE ISNUMERIC(@vc_MeasureValue) WHEN 1 THEN  @vc_MeasureValue ELSE NULL END,
			Comments = @vc_Comments,
			isPatientAdministered = @i_isPatientAdministered,
			DateTaken = @dt_DateTaken,
			DueDate = @dt_DueDate,
			StatusCode = @vc_StatusCode,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			DataSourceId = @i_DataSourceId
	  WHERE PatientMeasureID = @i_UserMeasureId

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update UserMeasure'  
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
    ON OBJECT::[dbo].[usp_UserMeasure_Update] TO [FE_rohit.r-ext]
    AS [dbo];

