/*
--------------------------------------------------------------------------------
Procedure Name: [usp_ProgramProcedureTherapeuticDrugFrequency_Select]
Description	  : This procedure is used to get the data from ProgramProcedureTherapeuticDrugFrequency
Created By    :	NagaBabu
Created Date  : 26-Aug-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
29-Aug-2011 NagaBabu Deleted programid,programname,procedureid,procedurename,TherapeuticID,drugcodeid fields 
---------------------------------------------------------------------------------
*/  
CREATE PROCEDURE [dbo].[usp_ProgramProcedureTherapeuticDrugFrequency_Select]--23,2,5951
(
	@i_AppUserId KeyId,
	@i_ProgramId KeyId,
	@i_ProcedureId KeyId
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
------------------------------------------------------------------------------------------------
		SELECT
			ISNULL(TherapeuticClass.Name,'') AS TherapeuticName , 
			ISNULL(CodeSetDrug.DrugName,'') AS DrugName ,
			ISNULL(CONVERT(VARCHAR,PPTDF.Duration),'') + ' ' + CASE PPTDF.DurationType 
																   WHEN 'D' THEN 'Day(s)'
																   WHEN 'W' THEN 'Week(s)'
																   WHEN 'M' THEN 'Month(s)'
																   WHEN 'Y' THEN 'Year(s)'
															   END AS DurationAndType ,
			ISNULL(CONVERT(VARCHAR,PPTDF.Frequency),'') + ' ' + CASE PPTDF.FrequencyUOM
																    WHEN 'D' THEN 'Day(s)'
																    WHEN 'W' THEN 'Week(s)'
																    WHEN 'M' THEN 'Month(s)'
																    WHEN 'Y' THEN 'Year(s)'
															    END AS FrequencyAndUOM 									  														 	 
	    FROM
            ProgramProcedureTherapeuticDrugFrequency PPTDF
        INNER JOIN ProgramProcedureFrequency with (nolock) 
			ON ProgramProcedureFrequency.ProgramId = PPTDF.ProgramId
			AND ProgramProcedureFrequency.ProcedureId = PPTDF.ProcedureId
		LEFT OUTER JOIN TherapeuticClass with (nolock) 
			ON TherapeuticClass.TherapeuticID = PPTDF.TherapeuticID
		LEFT OUTER JOIN CodeSetDrug with (nolock) 
			ON CodeSetDrug.DrugCodeId = PPTDF.DrugCodeId			
	    WHERE
		    PPTDF.ProgramId = @i_ProgramId
		AND PPTDF.ProcedureId = @i_ProcedureId   
		--AND ProgramProcedureFrequency.StatusCode = 'A'
		
		   
END TRY
--------------------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramProcedureTherapeuticDrugFrequency_Select] TO [FE_rohit.r-ext]
    AS [dbo];

