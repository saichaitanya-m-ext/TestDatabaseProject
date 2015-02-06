/*
-----------------------------------------------------------------------------------------------
Procedure Name: usp_CodeSetDrug_Select
Description	  : This procedure is used to select the data from the CodeSetDrug table based on 
				the DrugCodeId or to dispaly all the data when passed NULL.
Created By    :	Aditya 
Created Date  : 09-Jan-2010
-----------------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY	 BY	 DESCRIPTION
30-Jun-10 Pramod Included parameter @v_DrugCode and in the where clause
09-July-2011 NagaBabu Added MedicationId Field as new field added to table
11-Dec-2012  Mohan Removed statuscode 
-----------------------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_CodeSetDrug_Select] 
(
	@i_AppUserId KEYID,
	@i_DrugCodeId KEYID = NULL,
    @v_StatusCode StatusCode = NULL,
    @v_DrugCode VARCHAR(13) = NULL
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

------------ Selection from Code Set Drug table starts here ------------
      SELECT
		  DrugCodeId,
          DrugCode ,
          DrugCodeType ,
          DrugName ,
          DrugDescription ,
          CreatedByUserId ,
          '' StatusCode ,
          MedicationId
      FROM
          CodeSetDrug
      WHERE
		   ( DrugCodeId = @i_DrugCodeId OR @i_DrugCodeId IS NULL )
	   AND ( DrugCode = @v_DrugCode OR @v_DrugCode IS NULL )
      -- AND ( @v_StatusCode IS NULL or StatusCode = @v_StatusCode )
       		  
END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CodeSetDrug_Select] TO [FE_rohit.r-ext]
    AS [dbo];

