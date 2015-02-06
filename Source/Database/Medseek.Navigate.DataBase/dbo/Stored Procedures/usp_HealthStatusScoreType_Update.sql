/*
----------------------------------------------------------------------------------------
Procedure Name:[usp_HealthStatusScoreType_Update]
Description	  :This Procedure is used to Update values to HealthStatusScoreType table 
Created By    :NagaBabu	
Created Date  :13-Jan-2011 
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
-----------------------------------------------------------------------------------------
*/   

CREATE PROCEDURE [dbo].[usp_HealthStatusScoreType_Update]
( 
	@i_AppUserId KeyID ,
	@i_HealthStatusScoreId KeyID ,
	@vc_Name SourceName ,
	@i_HealthStatusScoreOrgId KeyID = NULL,
	@vc_Description ShortDescription ,
	@i_SortOrder KeyID ,
	@vc_StatusCode StatusCode ,
	@i_Operator1forGoodScore VARCHAR(20) = NULL,
	@d_Operator1Value1forGoodScore DECIMAL(10,2) = NULL,
	@d_Operator1Value2forGoodScore DECIMAL(10,2) = NULL,
	@i_Operator2forGoodScore VARCHAR(20) = NULL,
	@d_Operator2Value1forGoodScore DECIMAL(10,2) = NULL,
	@d_Operator2Value2forGoodScore DECIMAL(10,2) = NULL,
	@vc_TextValueforGoodScore SourceName = NULL,
	@i_Operator1forFairScore VARCHAR(20) = NULL,
	@d_Operator1Value1forFairScore DECIMAL(10,2) = NULL,
	@d_Operator1Value2forFairScore DECIMAL(10,2) = NULL,
	@i_Operator2forFairScore VARCHAR(20) = NULL,
	@d_Operator2Value1forFairScore DECIMAL(10,2) = NULL,
	@d_Operator2Value2forFairScore DECIMAL(10,2) = NULL,
	@vc_TextValueforFairScore SourceName = NULL,
	@i_Operator1forPoorScore VARCHAR(20) = NULL,
	@d_Operator1Value1forPoorScore DECIMAL(10,2) = NULL,
	@d_Operator1Value2forPoorScore DECIMAL(10,2) = NULL,
	@i_Operator2forPoorScore VARCHAR(20) = NULL,
	@d_Operator2Value1forPoorScore DECIMAL(10,2) = NULL,
	@d_Operator2Value2forPoorScore DECIMAL(10,2) = NULL,
	@vc_TextValueforPoorScore SourceName = NULL
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

------------ Insertion HealthStatusScoreType table starts here ------------
      UPDATE HealthStatusScoreType
		 SET Name = @vc_Name ,
			HealthStatusScoreOrgId = @i_HealthStatusScoreOrgId ,
			Description = @vc_Description ,
			SortOrder = @i_SortOrder ,
			StatusCode = @vc_StatusCode ,
			Operator1forGoodScore = @i_Operator1forGoodScore ,
			Operator1Value1forGoodScore = @d_Operator1Value1forGoodScore ,
			Operator1Value2forGoodScore = @d_Operator1Value2forGoodScore ,
			Operator2forGoodScore = @i_Operator2forGoodScore ,
			Operator2Value1forGoodScore = @d_Operator2Value1forGoodScore ,
			Operator2Value2forGoodScore = @d_Operator2Value2forGoodScore ,
			TextValueforGoodScore = @vc_TextValueforGoodScore ,
			Operator1forFairScore = @i_Operator1forFairScore ,
			Operator1Value1forFairScore = @d_Operator1Value1forFairScore ,
			Operator1Value2forFairScore = @d_Operator1Value2forFairScore ,
			Operator2forFairScore = @i_Operator2forFairScore ,
			Operator2Value1forFairScore = @d_Operator2Value1forFairScore ,
			Operator2Value2forFairScore = @d_Operator2Value2forFairScore ,
			TextValueforFairScore = @vc_TextValueforFairScore ,
			Operator1forPoorScore = @i_Operator1forPoorScore ,
			Operator1Value1forPoorScore = @d_Operator1Value1forPoorScore ,
			Operator1Value2forPoorScore = @d_Operator1Value2forPoorScore ,
			Operator2forPoorScore = @i_Operator2forPoorScore ,
			Operator2Value1forPoorScore = @d_Operator2Value1forPoorScore ,
			Operator2Value2forPoorScore = @d_Operator2Value2forPoorScore ,
			TextValueforPoorScore = @vc_TextValueforPoorScore ,
			LastModifiedByUserId = @i_AppUserId ,
			LastModifiedDate = GETDATE()
	  WHERE	HealthStatusScoreId = @i_HealthStatusScoreId
		  	
	  SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT 			 	
	  IF @l_numberOfRecordsUpdated  <> 1            
		BEGIN            
		    RAISERROR        
		     (  N'Invalid row count %d in Update HealthStatusScoreType Table'        
			   ,17        
			   ,1        
			   ,@l_numberOfRecordsUpdated                      
		     )                
		END    
  
    RETURN 0  			    
		        
END TRY
-----------------------------------------------------------------------
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthStatusScoreType_Update] TO [FE_rohit.r-ext]
    AS [dbo];

