/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_LabTests_Search] 2
Description	  : This procedure is used to search the details from LabTestMeasure,LabTests,CodesetProcedure tables 
					for given Inputs.
Created By    :	NagaBabu
Created Date  : 27-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
03-May-2011 Rathnam added LabTestDesc column to select statement
04-May-2011 NagaBabu Replaced INNER JOIN with LEFT OUTER JOIN to the tables LabTestMeasure and Measure
						and added @v_StatusCode Parameter as well as in where clause
09-May-2011 Rathnam added join with CPTLABTest table	
11-May-2011 Rathnam added audit columns to the select statement.					
---------------------------------------------------------------------------------
*/ 
	
CREATE PROCEDURE [dbo].[usp_LabTests_Search]
(
	@i_AppUserId KEYID ,
	@v_LabTestName ShortDescription = NULL ,
	@v_ProcedureCode VARCHAR(5) = NULL ,
	@v_MeasureName ShortDescription = NULL ,
	@v_LabTestNameOption VARCHAR(20) = NULL ,
	@v_MeasureNameOption VARCHAR(20) = NULL ,
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

		DECLARE @v_LabTest ShortDescription = CASE @v_LabTestNameOption
												  WHEN 'Starts With' THEN @v_LabTestName + '%'
												  WHEN 'Contains' THEN '%' + @v_LabTestName + '%'
												  ELSE NULL
											  END ,
				@v_Measure ShortDescription = CASE @v_MeasureNameOption 
												  WHEN 'Starts With' THEN @v_MeasureName + '%'
												  WHEN 'Contains' THEN '%' + @v_MeasureName + '%'
												  ELSE NULL
											  END 
											  
        SELECT DISTINCT
			LabTests.LabTestId ,
			LabTests.LabTestName ,
			LabTests.LabTestDesc,
			CASE LabTests.StatusCode 
		       WHEN 'A' THEN 'Active'
		       WHEN 'I' THEN 'InActive'
		       ELSE ''
		    END AS StatusCode,
		    LabTests.CreatedByUseriD,
		    LabTests.CreatedDate,
		    LabTests.LastModifiedByUserId,
		    LabTests.LastModifiedDate 
		FROM
			LabTests
	    LEFT OUTER JOIN CPTLabTests
	        ON CPTLabTests.LabTestID = LabTests.LabTestId		
		LEFT OUTER JOIN CodeSetProcedure
			ON CodeSetProcedure.ProcedureCodeID = CPTLabTests.ProcedureID		  	
		LEFT OUTER JOIN LabTestMeasure	
			ON LabTestMeasure.LabTestId = LabTests.LabTestId
        LEFT OUTER JOIN Measure  
			ON LabTestMeasure.MeasureId = Measure.MeasureId
	    WHERE 
			( LabTests.LabTestName LIKE  @v_LabTest OR @v_LabTest IS NULL )
		 AND( Measure.Name Like @v_Measure OR @v_Measure IS NULL )
		 AND( CodeSetProcedure.ProcedureCode = @v_ProcedureCode OR @v_ProcedureCode IS NULL ) 
		 AND((LabTests.StatusCode = 'A' AND @v_StatusCode = 'A') OR @v_StatusCode = 'I')	
	    		  
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
    ON OBJECT::[dbo].[usp_LabTests_Search] TO [FE_rohit.r-ext]
    AS [dbo];

