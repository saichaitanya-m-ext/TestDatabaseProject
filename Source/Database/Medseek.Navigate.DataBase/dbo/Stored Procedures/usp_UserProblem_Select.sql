/*        
---------------------------------------------------------------------------------        
Procedure Name: [dbo].[usp_UserProblem_Select]        
Description   : This procedure is used to get the records from UserProblem table        
Created By    : NagaBabu        
Created Date  : 18-May-2010        
----------------------------------------------------------------------------------        
Log History   :         
DD-Mon-YYYY  BY        DESCRIPTION     
    
20-May-2010  NagaBabu  Added the condition [AND (UserProblem.UserId = @i_UserId     
                        OR @i_UserId IS NULL)] in WHERE class       
14-June-2010 NagaBabu Added ORDERBY clause     
13-Aug-2010  Rathnam   Added Rule patient Viewable Case statement in whereclause as per document   
19-Feb-2011  Rathnam   added status code for MedicalProblemClassification in the select statement  
                       and MedicalProblemClassificationId taken from MedicalProblemClassification table.  
25-Feb-2011 Pramod Join to userproblem is corrected
12-07-2014   Sivakrishna added SourceName column to 
			 the Existing Select statement.   
17-07-2014   Sivakrishna added DataSourceId column to  existing the Select statement.
20-Mar-2013 P.V.P.Mohan modified UserProblem to PatientProblem
			and modified columns. 
----------------------------------------------------------------------------------        
*/ -- DROP PROC _Obsolete_usp_UserProblem_Select
CREATE PROCEDURE [dbo].[usp_UserProblem_Select]  
(  
 @i_AppUserId KEYID ,  
 @i_UserProblemId KEYID = NULL ,  
 @i_UserId KEYID = NULL ,  
 @v_StatusCode STATUSCODE = NULL )  
AS  
BEGIN TRY         
        
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END        
---------------- Records from UserProblem,MedicalProblem,MedicalProblemClassification are retrieved here--------    
  
      DECLARE @b_Patient BIT  
      SET @b_Patient = ( SELECT  
                           1  
                       FROM  
                           Patients  
                       WHERE  
                           Patients.PatientID = @i_AppUserId )  
      SELECT  
          PatientProblem.PatientProblemID UserProblemId ,  
          PatientProblem.MedicalProblemClassificationId ,  
          --MedicalProblemClassification.MedicalProblemClassificationId,  
          PatientProblem.ProblemStartDate AS StartDate ,  
          PatientProblem.ProblemEndDate AS EndDate ,  
          MedicalProblemClassification.ProblemClassName AS ClassificationName ,  
          MedicalProblem.ProblemName AS MedicalProblemName ,  
          PatientProblem.Comments ,  
          CASE PatientProblem.StatusCode  
            WHEN 'A' THEN 'Active'  
            WHEN 'I' THEN 'InActive'  
            ELSE ''  
          END AS StatusDescription ,  
          PatientProblem.CreatedByUserId ,  
          PatientProblem.CreatedDate ,  
          PatientProblem.LastModifiedByUserId ,  
          PatientProblem.LastModifiedDate  ,
          PatientProblem.DataSourceId,
          CodeSetDataSource.SourceName
      FROM  
          PatientProblem  WITH(NOLOCK)
      INNER JOIN MedicalProblem   WITH(NOLOCK)
      ON  MedicalProblem.MedicalProblemId = PatientProblem.MedicalProblemId  
      INNER JOIN MedicalProblemClassification  WITH(NOLOCK) 
      ON  MedicalProblemClassification.MedicalProblemClassificationId = PatientProblem.MedicalProblemClassificationId  
      LEFT JOIN CodeSetDataSource WITH(NOLOCK)
         ON CodeSetDataSource.DataSourceId = PatientProblem.DataSourceId
      WHERE  
          ( PatientProblem.PatientProblemID = @i_UserProblemId OR @i_UserProblemId IS NULL )  
          AND ( PatientProblem.PatientID = @i_UserId OR @i_UserId IS NULL )  
          AND ( @v_StatusCode IS NULL OR PatientProblem.StatusCode = @v_StatusCode )  
          AND (@v_StatusCode IS NULL OR MedicalProblemClassification.StatusCode = @v_StatusCode)  
          AND ( @b_Patient IS NULL OR ( MedicalProblemClassification.isPatientViewable = 1 AND @b_Patient = 1))                                                       
      ORDER BY  
          PatientProblem.ProblemStartDate DESC  
END TRY  
BEGIN CATCH        
        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserProblem_Select] TO [FE_rohit.r-ext]
    AS [dbo];

