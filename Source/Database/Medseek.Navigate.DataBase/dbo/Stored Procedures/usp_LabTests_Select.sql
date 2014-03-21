/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_LabTests_Select]
Description	  : This procedure is used to select the details from LabTests table.
Created By    :	NagaBabu
Created Date  : 26-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY	DESCRIPTION
29-Apr-2011 NagaBabu Changed where clause
06-May-2011 Rathnam remove the ProcedureID column from select statement.
---------------------------------------------------------------------------------
*/
   
CREATE PROCEDURE [dbo].[usp_LabTests_Select]
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
			LabTests.LabTestId ,
			LabTests.LabTestName ,
			LabTests.LabTestDesc ,
			CASE LabTests.StatusCode 
		       WHEN 'A' THEN 'Active'
		       WHEN 'I' THEN 'InActive'
		       ELSE ''
		    END AS StatusCode ,
			LabTests.CreatedByUserId ,
			LabTests.CreatedDate ,
			LabTests.LastModifiedByUserId ,
			LabTests.LastModifiedDate
		FROM
            LabTests
	    WHERE 
			((LabTests.StatusCode = 'A' AND @v_StatusCode = 'A') OR @v_StatusCode = 'I')
	    ORDER BY
		    LabTests.LabTestName
		  
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
    ON OBJECT::[dbo].[usp_LabTests_Select] TO [FE_rohit.r-ext]
    AS [dbo];

