/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Labs_Select]
Description	  : This procedure is used to select the details from Labs table.
Created By    :	NagaBabu
Created Date  : 26-Apr-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
29-Apr-2011 NagaBabu Changed where clause
---------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_Labs_Select]
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
			LabId ,
			LabName ,
			CASE StatusCode 
		       WHEN 'A' THEN 'Active'
		       WHEN 'I' THEN 'InActive'
		       ELSE ''
		    END AS StatusCode ,
			CreatedByUserId,
			CreatedDate,
			LastModifiedByUserId,
			LastModifiedDate
		FROM
            Labs WITH (NOLOCK) 
	    WHERE 
			((StatusCode = 'A' AND @v_StatusCode = 'A') OR @v_StatusCode = 'I')
	    ORDER BY
		    LabName
		  
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
    ON OBJECT::[dbo].[usp_Labs_Select] TO [FE_rohit.r-ext]
    AS [dbo];

