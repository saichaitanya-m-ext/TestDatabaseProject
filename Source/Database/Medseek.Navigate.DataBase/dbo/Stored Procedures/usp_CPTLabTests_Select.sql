/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_CPTLabTests_Select] 
Description	  : This procedure is used to select the details from CPTLabTests table for given LabTest.
Created By    :	Rathnam
Created Date  : 06-May-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
---------------------------------------------------------------------------------
*/   
   
CREATE PROCEDURE [dbo].[usp_CPTLabTests_Select]
(
	@i_AppUserId KEYID ,
	@i_LabTestId KEYID = NULL,
	@i_ProcedureId KEYID = NULL,
	@v_StatusCode StatusCode = 'A'
)
AS
BEGIN TRY 
      SET NOCOUNT ON 
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
			CPTLabTests.LabTestId ,
			LabTests.LabTestName ,
			CPTLabTests.ProcedureID ,
			CodeSetProcedure.ProcedureCode,
			CodesetProcedure.ProcedureName AS ProcedureName , 
			CASE CPTLabTests.StatusCode 
		       WHEN 'A' THEN 'Active'
		       WHEN 'I' THEN 'InActive'
		       ELSE ''
		    END AS StatusCode ,
		    CPTLabTests.CreatedByUserId ,
			CPTLabTests.CreatedDate ,
			CPTLabTests.LastModifiedByUserId ,
			CPTLabTests.LastModifiedDate
		FROM
            CPTLabTests  WITH (NOLOCK) 
        INNER JOIN CodesetProcedure    WITH (NOLOCK) 
			ON CPTLabTests.ProcedureId = CodesetProcedure.ProcedureCodeID
		INNER JOIN LabTests  WITH (NOLOCK) 
			ON CPTLabTests.LabTestId = LabTests.LabTestId	  
	    WHERE 
			(CPTLabTests.LabTestId = @i_LabTestId OR @i_LabTestId IS NULL) 
		AND	(CPTLabTests.ProcedureID = @i_ProcedureId OR @i_ProcedureId IS NULL)
		AND ((CPTLabTests.StatusCode ='A' AND @v_StatusCode ='A') OR @v_StatusCode ='I')		
	    		  
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
    ON OBJECT::[dbo].[usp_CPTLabTests_Select] TO [FE_rohit.r-ext]
    AS [dbo];

