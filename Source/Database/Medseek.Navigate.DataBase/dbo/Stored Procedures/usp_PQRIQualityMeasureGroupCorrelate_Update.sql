/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasureGroupCorrelate_Update]    
Description   : This procedure is used to Update values into PQRIQualityMeasureGroupCorrelate table
Created By    : NagaBabu
Created Date  : 03-Jan-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
   
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupCorrelate_Update]
(  
	@i_AppUserId KEYID ,
	@i_PQRIQualityMeasureGroupCorrelateID KEYID ,
	@i_PQRIQualityMeasureGroupID KEYID ,
	@vc_PQRIQualityMeasureCorrelateIDList LongDescription ,
	@i_AgeFrom SMALLINT ,
	@i_AgeTo SMALLINT ,
	@c_Gender UNIT ,
	@d_BMIFrom DECIMAL(5,3) ,
	@d_BMITo DECIMAL(5,3) 
)  
AS  
BEGIN TRY

	SET NOCOUNT ON  
	-- Check if valid Application User ID is passed  
	DECLARE @i_numberOfRecordsUpdated INT  
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  
	     UPDATE
			 PQRIQualityMeasureGroupCorrelate
	     SET 
			 PQRIQualityMeasureCorrelateIDList = @vc_PQRIQualityMeasureCorrelateIDList ,
			 BMIFrom = @d_BMIFrom ,
			 BMITo = @d_BMITo ,
			 LastModifiedByUserId = @i_AppUserId ,
			 LastModifiedDate = GETDATE()
		 WHERE 
		     PQRIQualityMeasureGroupCorrelateID = @i_PQRIQualityMeasureGroupCorrelateID
		 
		 SET @i_numberOfRecordsUpdated = @@ROWCOUNT

		 IF @i_numberOfRecordsUpdated <> 1
			RAISERROR ( N'Update of PQRIQualityMeasureGroupCorrelate table experienced invalid row count of %d' ,
			17 ,
			1 ,
			@i_numberOfRecordsUpdated )     
				 
			 
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupCorrelate_Update] TO [FE_rohit.r-ext]
    AS [dbo];

