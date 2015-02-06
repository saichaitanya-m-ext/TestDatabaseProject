/*
----------------------------------------------------------------------------------------
Procedure Name:[usp_HealthStatusScoreType_Select_ByHealthStatusScoreType]
Description	  :This Procedure is used to get values from HealthStatusScoreType By HealthStatusScoreType
Created By    :NagaBabu	
Created Date  :24-Jan-2011 
-----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
-----------------------------------------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[usp_HealthStatusScoreType_Select_ByHealthStatusScoreType]
( 
	@i_AppUserId KeyID ,
	@i_HealthStatusScoreId KeyID
) 
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.' ,
               17 ,
               1 ,
               @i_AppUserId )
         END

------------ Selection from HealthStatusScoreType table starts here ------------
      SELECT
		  HealthStatusScoreId ,
		  Name AS 'Health Risk Score Type',
		  HealthStatusScoreOrgId ,
		  Description ,
		  SortOrder ,
		  CASE StatusCode 
			  WHEN 'A' THEN 'Active'
			  WHEN 'I' THEN 'InActive'
		  END AS StatusCode ,
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
		  CreatedByUserId ,
		  CreatedDate ,
		  LastModifiedByUserId ,
		  LastModifiedDate
	  FROM
          HealthStatusScoreType
      WHERE 
		  HealthStatusScoreId = @i_HealthStatusScoreId
	            
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
    ON OBJECT::[dbo].[usp_HealthStatusScoreType_Select_ByHealthStatusScoreType] TO [FE_rohit.r-ext]
    AS [dbo];

