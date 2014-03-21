
/*
----------------------------------------------------------------------------------------
Procedure Name:[usp_HealthStatusScoreType_Insert]
Description	  :This Procedure is used to Insert values to HealthStatusScoreType table 
Created By    :NagaBabu	
Created Date  :13-Jan-2011 
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
-----------------------------------------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[usp_HealthStatusScoreType_Insert]
( 
	@i_AppUserId KeyID ,
	@vc_Name SourceName ,
	@i_HealthStatusScoreOrgId KeyID = NULL,
	@vc_Description VARCHAR(500) ,
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
	--@o_HealthStatusScoreId KeyID OUTPUT
) 
AS
BEGIN TRY 
	SET NOCOUNT ON    
    DECLARE @l_numberOfRecordsInserted INT    	
	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

------------ Insertion HealthStatusScoreType table starts here ------------
      INSERT INTO HealthStatusScoreType
		  (
		    Name ,
			HealthStatusScoreOrgId ,
			Description ,
			SortOrder ,
			StatusCode ,
			Operator1forGoodScore ,
			Operator1Value1forGoodScore ,
			Operator1Value2forGoodScore ,
			Operator2forGoodScore ,
			Operator2Value1forGoodScore ,
			Operator2Value2forGoodScore ,
			TextValueforGoodScore ,
			Operator1forFairScore ,
			Operator1Value1forFairScore ,
			Operator1Value2forFairScore ,
			Operator2forFairScore ,
			Operator2Value1forFairScore ,
			Operator2Value2forFairScore ,
			TextValueforFairScore ,
			Operator1forPoorScore ,
			Operator1Value1forPoorScore ,
			Operator1Value2forPoorScore ,
			Operator2forPoorScore ,
			Operator2Value1forPoorScore ,
			Operator2Value2forPoorScore ,
			TextValueforPoorScore ,
			CreatedByUserId
		  )
	  VALUES
		  (
			@vc_Name ,
			@i_HealthStatusScoreOrgId ,
			@vc_Description ,
			@i_SortOrder ,
			@vc_StatusCode ,
			@i_Operator1forGoodScore ,
			@d_Operator1Value1forGoodScore ,
			@d_Operator1Value2forGoodScore ,
			@i_Operator2forGoodScore ,
			@d_Operator2Value1forGoodScore ,
			@d_Operator2Value2forGoodScore ,
			@vc_TextValueforGoodScore ,
			@i_Operator1forFairScore ,
			@d_Operator1Value1forFairScore ,
			@d_Operator1Value2forFairScore ,
			@i_Operator2forFairScore ,
			@d_Operator2Value1forFairScore ,
			@d_Operator2Value2forFairScore ,
			@vc_TextValueforFairScore ,
			@i_Operator1forPoorScore ,
			@d_Operator1Value1forPoorScore ,
			@d_Operator1Value2forPoorScore ,
			@i_Operator2forPoorScore ,
			@d_Operator2Value1forPoorScore ,
			@d_Operator2Value2forPoorScore ,
			@vc_TextValueforPoorScore ,
			@i_AppUserId
		  )
		  	
	  SELECT @l_numberOfRecordsInserted = @@ROWCOUNT 
			 --@o_HealthStatusScoreId = SCOPE_IDENTITY()
	
	  IF @l_numberOfRecordsInserted <> 1            
		BEGIN            
		    RAISERROR        
		     (  N'Invalid row count %d in insert HealthStatusScoreType Table'        
			   ,17        
			   ,1        
			   ,@l_numberOfRecordsInserted                   
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
    ON OBJECT::[dbo].[usp_HealthStatusScoreType_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

