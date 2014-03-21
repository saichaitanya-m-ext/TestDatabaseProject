/*            
------------------------------------------------------------------------------            
Procedure Name: usp_UserProcedureCodes_Select            
Description   : This procedure is used to get the records from UserProcedureCodes          
    table          
Created By    : Aditya            
Created Date  : 07-Apr-2010            
------------------------------------------------------------------------------            
Log History   :             
DD-MM-YYYY  BY   DESCRIPTION            
16-June-2010 NagaBabu  Added PatientUserID perameter 
27-July-2010 NagaBabu  Added ProcedureLeadtime field in select Statement   
19-Jan-2011  Rama added ProcedureCodeModifierId column 
09-May-2011  Rathnam added Labtestid column to the select statement.
06-Jun-2011  Rathnam added DiseaseName to the select statement    
09-Nov-2011 NagaBabu Added ProgramName to the select statement
25-Jan-2012 NagaBabu Added ClaimNumber field to the select statement
12-07-2014   Sivakrishna added SourceName column to 
			 the Existing Select statement.   
17-07-2014   Sivakrishna added DataSourceId column to  existing the Select statement. 
21-Mar-2013	 P.V.P.Mohan modified UserProcedureCodes to PatientProcedure,DataSource to CodesetDataSource and Columns
------------------------------------------------------------------------------            
*/          
CREATE PROCEDURE [dbo].[usp_UserProcedureCodes_Select]     
(          
 @i_AppUserId KeyID,          
 @i_UserProcedureId KeyID = NULL,        
 @v_StatusCode StatusCode = NULL,
 @i_PatientUserID KEYID = NULL,
 @b_ShowLastOneYearData BIT = 0          
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
          
    SELECT PatientProcedure.PatientProcedureID UserProcedureId,        
		   PatientProcedure.PatientID UserId,        
		   PatientProcedure.ProcedureCodeID ProcedureId,        
		   CodeSetProcedure.ProcedureCode,        
		   CodeSetProcedure.ProcedureName,        
		   PatientProcedure.Commments,        
		   PatientProcedure.DueDate,        
		   PatientProcedure.CreatedByUserId,        
		   PatientProcedure.CreatedDate,        
		   PatientProcedure.LastModifiedByUserId,        
		   PatientProcedure.LastModifiedDate,        
		   PatientProcedure.ProcedureCompletedDate,        
		   CASE PatientProcedure.StatusCode           
		       WHEN 'A' THEN 'Active'          
			   WHEN 'I' THEN 'InActive'          
		   ELSE ''          
		   END AS StatusDescription ,
		   PatientProcedure.ProcedureLeadtime ,  
		   PatientProcedure.ProcedureCodeModifierId,
		   PatientProcedure.LabtestID,
		   LabTests.LabTestName,
		   Disease.Name,
		   PatientProcedure.IsPreventive ,
		   Program.ProgramId ,
		   Program.ProgramName ,
		   ClaimInfo.ClaimNumber    ,
		   PatientProcedure.DataSourceID,
		   CodeSetDataSource.SourceName
	  FROM PatientProcedure		WITH(NOLOCK)       
	  INNER JOIN CodeSetProcedure   WITH(NOLOCK)       
		   ON CodeSetProcedure.ProcedureCodeID = PatientProcedure.ProcedureCodeID        
	  LEFT OUTER JOIN LabTests		WITH(NOLOCK)
	       ON PatientProcedure.LabtestID = LabTests.LabtestID 
	  LEFT OUTER JOIN Disease       WITH(NOLOCK)
	       ON PatientProcedure.DiseaseId = Disease.DiseaseId     	   
	  LEFT OUTER JOIN Program       WITH(NOLOCK)
		   ON Program.ProgramId = PatientProcedure.ProgramId 
	  LEFT OUTER JOIN ClaimLine     WITH(NOLOCK)
		   ON ClaimLine.ClaimLineID = PatientProcedure.ClaimLineID
	  LEFT OUTER JOIN ClaimInfo     WITH(NOLOCK)
		   ON ClaimInfo.ClaimInfoId = ClaimLine.ClaimInfoID		
    LEFT JOIN CodeSetDataSource 
        ON CodeSetDataSource.DataSourceId = PatientProcedure.DataSourceID   		       
	 WHERE ( PatientProcedure.PatientProcedureID = @i_UserProcedureId OR @i_UserProcedureId IS NULL )          
	   AND ( PatientProcedure.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )     
	   AND ( PatientProcedure.PatientID = @i_PatientUserID OR @i_PatientUserID IS NULL )
	   AND ( @b_ShowLastOneYearData = 0 OR
				( @b_ShowLastOneYearData = 1 AND
				  PatientProcedure.ProcedureCompletedDate > DATEADD(YEAR, -1, GETDATE())
				)  
			)
  ORDER BY    
		  PatientProcedure.DueDate DESC,CodeSetProcedure.ProcedureName          
END TRY            
--------------------------------------------------------             
BEGIN CATCH            
    -- Handle exception            
      DECLARE @i_ReturnedErrorID INT          
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId          
          
      RETURN @i_ReturnedErrorID          
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserProcedureCodes_Select] TO [FE_rohit.r-ext]
    AS [dbo];

