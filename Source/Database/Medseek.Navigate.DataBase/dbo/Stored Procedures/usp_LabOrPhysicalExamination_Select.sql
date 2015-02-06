/*
---------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_LabOrPhysicalExamination_Select]1
Description	  : This procedure is used to select all the LabOrPhysicalExamination records.
Created By    :	Gurumoorthy.V
Created Date  : 06-07-2011
----------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
----------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_LabOrPhysicalExamination_Select]
(	
	@i_AppUserId KEYID,
	@v_StatusCode StatusCode = NULL
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
---------------- All the PreviousExaminationLabFindings records are retrieved --------
      SELECT
          LabOrPhysicalExaminationID,
		  Name,
		  CASE StatusCode
			 WHEN 'A' THEN 'Active'
			 WHEN 'I' THEN 'InActive'
		END as StatusCode,
		  dbo.ufn_GetUserNameByID (CreatedByUserId)AS CreatedByUserName,
		  CreatedByUserId,
		  CreatedDate
      FROM
          LabOrPhysicalExamination WITH (NOLOCK) 
      WHERE
      ( @v_StatusCode IS NULL OR StatusCode = @v_StatusCode )
      ORDER BY
          Name
        
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabOrPhysicalExamination_Select] TO [FE_rohit.r-ext]
    AS [dbo];

