/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PatientDiagnosis_Select]
Description	  : This procedure is used to select the details from PatientDiagnosis table.
Created By    :	Rama 
Created Date  : 19-Jan-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
01-Feb-2011  NagaBabu  Added @i_PatientUserID parameter as well as in where condition 
02-Feb-2011  NagaBabu  Added ICDCode field to the select statement
03-Feb-2011  NagaBabu  Converted DateDiagnosed to 101 datetype 
14-Apr-2011  NagaBabu  CodeSetICDGroups table was joined with CodeSetICDDiagnosis table to get the ICDGroupName field 
25-Jan-2012  NagaBabu Added ClaimNumber field to the select statement
08-Feb-2012  Rathnam corrected the select statement 
22-Mar-2012  Gurumoorthy Commented DateDiagnosed Convertion,Getting error in application
12-07-2014   Sivakrishna Added DataSourceName Column to existing select statement.
17-07-2014   Sivakrishna Added DataSourceId Column to existing select statement.
---------------------------------------------------------------------------------
*/

CREATE PROCEDURE [dbo].[usp_UserDiagnosisCodes_Select]
(
	@i_AppUserId KEYID,
	@i_PatientUserID KEYID = NULL,  
	@i_UserDiagnosisCodeID KEYID = NULL,
    @v_StatusCode STATUSCODE = NULL
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
----------- Select all the PatientDiagnosis details ---------------
      SELECT TOP 500
			PatientDiagnosis.PatientICDDiagnosisID,
			PatientDiagnosis.PatientID,
			PatientDiagnosis.DiagnosisCodeID,
			CodeSetICDDiagnosis.DiagnosisCode ,
			CodeSetICDDiagnosis.DiagnosisDescription ,
			DateDiagnosed,
			PatientDiagnosis.Comments,
			CASE PatientDiagnosis.StatusCode
				WHEN 'A' THEN 'Active'
				WHEN 'I' THEN 'InActive'
			END AS StatusCode,
			PatientDiagnosis.CreatedByUserId,
			PatientDiagnosis.CreatedDate,
			PatientDiagnosis.LastModifiedByUserId,
			PatientDiagnosis.LastModifiedDate ,
			CodeSetICDDiagnosis.ICDGroupId ,
			CodeSetICDGroups.ICDGroupName ,
			'' AS ClaimNumber ,
			PatientDiagnosis.DataSourceID,
			CodeSetDataSource.SourceName
			
	    FROM
			PatientDiagnosis
        INNER JOIN CodeSetICDDiagnosis 
			ON PatientDiagnosis.DiagnosisCodeID = CodeSetICDDiagnosis.DiagnosisCodeID  
		LEFT JOIN CodeSetDataSource 
		   ON CodeSetDataSource.DataSourceId = PatientDiagnosis.DataSourceID
		LEFT OUTER JOIN CodeSetICDGroups
			ON CodeSetICDDiagnosis.ICDGroupId = CodeSetICDGroups.ICDCodeGroupId
		--LEFT OUTER JOIN ClaimInfo
		--	ON ClaimInfo.ClaimInfoId = PatientDiagnosis.ClaimInfoID	  
	    WHERE
		    ( PatientICDDiagnosisID = @i_UserDiagnosisCodeID OR @i_UserDiagnosisCodeID IS NULL )
       	 AND( PatientDiagnosis.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
       	 AND( PatientDiagnosis.PatientID = @i_PatientUserID OR @i_PatientUserID IS NULL )

END TRY
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH




GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserDiagnosisCodes_Select] TO [FE_rohit.r-ext]
    AS [dbo];

