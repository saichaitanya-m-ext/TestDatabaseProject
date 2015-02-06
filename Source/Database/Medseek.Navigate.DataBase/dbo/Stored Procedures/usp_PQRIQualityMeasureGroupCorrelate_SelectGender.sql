/*  
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PQRIQualityMeasureGroupCorrelate_SelectGender] 
Description	  : This procedure is used to get the details of  PQRIQualityMeasureGroupCorrelate.
Created By    :	Rama 
Created Date  : 30-Dec-2010
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupCorrelate_SelectGender] 
       (
        @i_AppUserId KEYID
       ,@i_PQRIQualityMeasureGroupID KEYID
       )
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
----------- Select all the PQRIQualityMeasureGroupCorrelate  details ---------------

      SELECT  
			PQRIQualityMeasureGroupID,
			AgeFrom,
			AgeTo,
			MAX( CASE 
				WHEN Gender = 'M' THEN PQRIQualityMeasureCorrelateIDList
				ELSE ''
			END) AS MalePQRIQualityMeasureCorrelateIDList,
			MAX(CASE 
				WHEN Gender = 'F' THEN PQRIQualityMeasureCorrelateIDList
				ELSE ''
			END) AS FemalePQRIQualityMeasureCorrelateIDList,
			MAX(CASE 
				WHEN Gender = 'M' THEN PQRIQualityMeasureGroupCorrelateID
				ELSE ''
			END) AS MalePQRIQualityMeasureGroupCorrelateID,
			MAX(CASE 
				WHEN Gender = 'F' THEN PQRIQualityMeasureGroupCorrelateID
				ELSE ''
			END) AS FemalePQRIQualityMeasureGroupCorrelateID
      FROM  
          PQRIQualityMeasureGroupCorrelate 
		  WHERE PQRIQualityMeasureGroupID = @i_PQRIQualityMeasureGroupID  
          GROUP BY PQRIQualityMeasureGroupID,
			AgeFrom,
			AgeTo
              
END TRY
---------------------------------------------------------------------------------------------------------------
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupCorrelate_SelectGender] TO [FE_rohit.r-ext]
    AS [dbo];

