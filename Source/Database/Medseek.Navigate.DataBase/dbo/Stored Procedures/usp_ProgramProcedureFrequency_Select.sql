/*               
------------------------------------------------------------------------------                
Procedure Name: usp_ProgramProcedureFrequency_Select                
Description   : This procedure is used to get the records from ProgramProcedureFrequency table          
                based on ProgramID and ProcedureId is optional.             
Created By    : Aditya                
Created Date  : 30-Mar-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY  BY   DESCRIPTION                
26-Apr-2011    RamaChandra Added two column NeverSchedule and  ExclusionReason in the select statement 
11-May-2011    Rathnam added labtestid column to the select statement.  
24-May-2011    Rathnam added EffectiveStartDate one more column to the select statement. 
06-Jun-2011    Rathnam added DiseaseName, Ispreventive columns to the select statement  
10-Aug-2011 NagaBabu Modified Frequency field by applying CASE statement 
11-Aug-2011 NagaBabu Modified Frequency Field getting values from ProgramProcedureConditionalFrequency table 
16-Aug-2011 NagaBabu Modified CASE statement for the field Frequency
18-Aug-2011 NagaBabu Added NeverSchedule condition in case sttement for Frequency field 
------------------------------------------------------------------------------                
*/          
CREATE PROCEDURE [dbo].[usp_ProgramProcedureFrequency_Select]
(          
 @i_AppUserId KEYID ,          
 @i_ProgramId KEYID = NULL,          
 @i_ProcedureId KEYID = NULL,
 @vc_StatusCode  StatusCode = null         
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
                   
          
		SELECT       
			ProgramProcedureFrequency.ProgramId,      
			ProgramProcedureFrequency.ProcedureId,      
			CodeSetProcedure.ProcedureCode + ' ' + CodeSetProcedure.ProcedureName AS 'ProcedureCodeandName',  
			ProgramProcedureFrequency.FrequencyCondition ,        
			CASE ProgramProcedureFrequency.FrequencyCondition 
				WHEN 'None' THEN CASE NeverSchedule WHEN 1 THEN ' - ' 
													ELSE CAST(ProgramProcedureFrequency.FrequencyNumber AS VARCHAR) + ' ' + CASE ProgramProcedureFrequency.Frequency      
																										WHEN 'D' THEN 'Day(s)'      
																										WHEN 'W' THEN 'Week(s)'      
																										WHEN 'M' THEN 'Month(s)'      
																								        WHEN 'Y' THEN 'Year(s)'      
																								    END 
								     
							     END	  																     
				--ELSE (SELECT TOP 1 CAST(Frequency AS VARCHAR) + '/' + CASE FrequencyUOM
				--													WHEN 'D' THEN 'Day'      
				--													WHEN 'W' THEN 'Week'      
				--													WHEN 'M' THEN 'Month'      
				--													WHEN 'Y' THEN 'Year'
				--												END FROM ProgramProcedureConditionalFrequency PPCF
				--													WHERE PPCF.ProgramId = ProgramProcedureFrequency.ProgramId
				--												      AND PPCF.ProcedureId = ProgramProcedureFrequency.ProcedureId)
			END AS Frequency,	
			ProgramProcedureFrequency.CreatedByUserId,          
			ProgramProcedureFrequency.CreatedDate,          
			ProgramProcedureFrequency.LastModifiedByUserId,          
			ProgramProcedureFrequency.LastModifiedDate,        
			CASE ProgramProcedureFrequency.StatusCode        
			WHEN 'A' THEN 'Active'        
			WHEN 'I' THEN 'InActive'        
			END AS StatusDescription ,
			ProgramProcedureFrequency.NeverSchedule,
			ProgramProcedureFrequency.ExclusionReason,
			ProgramProcedureFrequency.LabTestId ,
			LabTests.LabTestName,
			ProgramProcedureFrequency.EffectiveStartDate,
			Disease.Name,
			ProgramProcedureFrequency.IsPreventive    
		FROM          
			ProgramProcedureFrequency  with (nolock)        
		INNER JOIN CodeSetProcedure with (nolock)          
			ON CodeSetProcedure.ProcedureCodeID = ProgramProcedureFrequency.ProcedureId
	    LEFT OUTER JOIN LabTests with (nolock) 
	        ON LabTests.LabTestId = ProgramProcedureFrequency.LabTestId
	    LEFT OUTER JOIN Disease with (nolock) 
	        ON ProgramProcedureFrequency.DiseaseId = Disease.DiseaseId    		            
		WHERE          
			(ProgramProcedureFrequency.ProgramId = @i_ProgramId OR @i_ProgramId IS NULL)      
		AND (ProgramProcedureFrequency.ProcedureId = @i_ProcedureId OR @i_ProcedureId IS NULL)  
		AND ( ProgramProcedureFrequency.StatusCode   = 'A' OR @vc_StatusCode IS NULL or ProgramProcedureFrequency.StatusCode = @vc_StatusCode )           
          
END TRY                
           
BEGIN CATCH                
    -- Handle exception                
      DECLARE @i_ReturnedErrorID INT          
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId          
          
      RETURN @i_ReturnedErrorID          
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramProcedureFrequency_Select] TO [FE_rohit.r-ext]
    AS [dbo];

