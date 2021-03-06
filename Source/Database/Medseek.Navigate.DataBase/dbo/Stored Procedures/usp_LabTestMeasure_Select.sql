﻿/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_LabTestMeasure_Select]
Description	  : This procedure is used to select the details from LabTestMeasure table.
Created By    :	NagaBabu
Created Date  : 27-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
29-Apr-2011 NagaBabu Changed where clause
---------------------------------------------------------------------------------
*/
   
CREATE PROCEDURE [dbo].[usp_LabTestMeasure_Select] 
(
	@i_AppUserId KEYID ,
	@v_StatusCode StatusCode = 'A'
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
----------- Select all the Activity details ---------------
        SELECT
			LabTestMeasure.LabTestId ,
			LabTests.LabTestName ,
			LabTestMeasure.MeasureId ,
			Measure.Name AS MeasureName , 
			CASE LabTestMeasure.StatusCode 
		       WHEN 'A' THEN 'Active'
		       WHEN 'I' THEN 'InActive'
		       ELSE ''
		    END AS StatusCode ,
		    LabTestMeasure.CreatedByUserId ,
			LabTestMeasure.CreatedDate ,
			LabTestMeasure.LastModifiedByUserId ,
			LabTestMeasure.LastModifiedDate
		FROM
            LabTestMeasure WITH (NOLOCK) 
        INNER JOIN Measure   WITH (NOLOCK) 
			ON LabTestMeasure.MeasureId = Measure.MeasureId
		INNER JOIN LabTests WITH (NOLOCK) 
			ON LabTestMeasure.LabTestId = LabTests.LabTestId	  
	    WHERE 
			((LabTestMeasure.StatusCode = 'A' AND @v_StatusCode = 'A') OR @v_StatusCode = 'I') 	
	    		  
END TRY
-------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabTestMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

