/*      
------------------------------------------------------------------------------      
Procedure Name: usp_LabMeasure_ProcedureDiseaseProgram_Select
Description   : This procedure is used to get all the detais from the     
                    LabMeasure, procedure,disease,program table based on MeasureId

Created By    : Pramod
Created Date  : 23-Apr-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY		BY		  DESCRIPTION      
27-04-2010    Aditya    Added Case to Status
02-Aug-2010	 NagaBabu  Added StatusCode perameter and in where condition of ProcedureMeasure
13-Oct-2010  NagaBabu  Added StatusCode perameter and in where condition of Programs related Measure,
						  Disease Related measure
16-May-2011  Rathnam  Added IsPrimaryMeasure column to the DiseaseMeasure select statement
12-July-2011 NagaBabu Concatenated Procedurecode,name as ProcedureName	
24-Aug-2011 NagaBabu Added ReminderDaysBeforeEnddate,StartDate,EndDate fields
25-Mar-2013 P.V.P.MOhan Modified ProcedureCodeID in place of ProcedureID for CodeSetProcedure table					    
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_LabMeasureProcedureDiseaseProgram_Select]
(    
	@i_AppUserId KeyId,   
	@i_MeasureID KeyID,
	@v_StatusCode StatusCode = NULL 
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

/* Organization Goal : Lab measure related data for the specific measure ID */    
	 SELECT LabMeasure.LabMeasureId,
			LabMeasure.MeasureId,
			LabMeasure.IsGoodControl,
			LabMeasure.Operator1forGoodControl,
			LabMeasure.Operator1Value1forGoodControl,
			LabMeasure.Operator1Value2forGoodControl,
			LabMeasure.Operator2forGoodControl,
			LabMeasure.Operator2Value1forGoodControl,
			LabMeasure.Operator2Value2forGoodControl,
			LabMeasure.TextValueForGoodControl,
		    COALESCE
			 (( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'') 
				+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')
			   ),''
			  ) AS GoodRange,		    
			LabMeasure.IsFairControl ,
			LabMeasure.Operator1forFairControl,
			LabMeasure.Operator1Value1forFairControl,
			LabMeasure.Operator1Value2forFairControl,
			LabMeasure.Operator2forFairControl,
			LabMeasure.Operator2Value1forFairControl,
			LabMeasure.Operator2Value2forFairControl,
			LabMeasure.TextValueForFairControl,
			COALESCE
			 (( ISNULL(LabMeasure.Operator1forFairControl,'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'') 
				+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')
			   ),''
			  ) AS FairRange,
			LabMeasure.IsPoorControl,
			LabMeasure.Operator1forPoorControl,
			LabMeasure.Operator1Value1forPoorControl,
			LabMeasure.Operator1Value2forPoorControl,
			LabMeasure.Operator2forPoorControl,
			LabMeasure.Operator2Value1forPoorControl,
			LabMeasure.Operator2Value2forPoorControl,
			LabMeasure.TextValueForPoorControl,
			COALESCE
			 (( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'') 
				+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' ' 
				+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')
			   ),''
			  ) AS PoorRange,		
			LabMeasure.MeasureUOMId,
			LabMeasure.ProgramId,
			LabMeasure.PatientUserID,
			LabMeasure.CreatedByUserId,
			LabMeasure.CreatedDate,
			LabMeasure.LastModifiedByUserId,
			LabMeasure.LastModifiedDate,
			MeasureUOM.UOMText,
			MeasureUOM.UOMDescription,
			CONVERT(VARCHAR,LabMeasure.StartDate,101) AS StartDate,
			CONVERT(VARCHAR,LabMeasure.EndDate,101) AS EndDate,
			LabMeasure.ReminderDaysBeforeEnddate 
	   FROM   
		    LabMeasure WITH (NOLOCK) 
			LEFT OUTER JOIN MeasureUOM WITH (NOLOCK) 
			    ON MeasureUOM.MeasureUOMId = LabMeasure.MeasureUOMId
	  WHERE   
		    LabMeasure.MeasureId = @i_MeasureID
		AND LabMeasure.PatientUserID IS NULL
		AND LabMeasure.ProgramId IS NULL
     
     /* Procedures related to Measure */
	 SELECT ProcedureMeasure.ProcedureMeasureId,
			ProcedureMeasure.ProcedureId,
			CodeSetProcedure.ProcedureCode + ' - ' + CodeSetProcedure.ProcedureName AS ProcedureName,
			CASE ProcedureMeasure.StatusCode   
						WHEN 'A' THEN 'Active'    
						WHEN 'I' THEN 'InActive'    
			END AS StatusCode
	   FROM ProcedureMeasure WITH (NOLOCK) 
			INNER JOIN CodeSetProcedure WITH (NOLOCK) 
				ON CodeSetProcedure.ProcedureCodeID = ProcedureMeasure.ProcedureId
	  WHERE ProcedureMeasure.MeasureId = @i_MeasureID
			AND( ProcedureMeasure.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
	  ORDER BY CodeSetProcedure.ProcedureName

	/* Disease Related to measure */
	 SELECT DiseaseMeasure.DiseaseMeasureId,
			DiseaseMeasure.DiseaseId,
			Disease.Name,
			DiseaseMeasure.Prioritization,
			CASE DiseaseMeasure.StatusCode   
						WHEN 'A' THEN 'Active'    
						WHEN 'I' THEN 'InActive'    
			END AS StatusCode,
			CASE WHEN IsPrimaryMeasure = 0 THEN 'False'
			     WHEN IsPrimaryMeasure = 1 THEN 'True'
			     ELSE NULL
			END AS IsPrimaryMeasure    
	   FROM DiseaseMeasure WITH (NOLOCK) 
			INNER JOIN Disease WITH (NOLOCK) 
				ON DiseaseMeasure.DiseaseId = Disease.DiseaseId
	  WHERE DiseaseMeasure.MeasureId = @i_MeasureID
		AND ( DiseaseMeasure.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
	  ORDER BY Disease.SortOrder,
			   Disease.Name

	/* Programs related to Measure */
	 SELECT Program.ProgramId,
			Program.ProgramName,
			CASE Program.StatusCode   
						WHEN 'A' THEN 'Active'    
						WHEN 'I' THEN 'InActive'    
			END AS StatusCode
	   FROM LabMeasure WITH (NOLOCK) 
			INNER JOIN Program WITH (NOLOCK) 
				ON Program.ProgramId = LabMeasure.ProgramId
	  WHERE   
		    LabMeasure.MeasureId = @i_MeasureID
		AND LabMeasure.ProgramId IS NOT NULL
		AND ( Program.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
      ORDER BY Program.ProgramName
      
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
    ON OBJECT::[dbo].[usp_LabMeasureProcedureDiseaseProgram_Select] TO [FE_rohit.r-ext]
    AS [dbo];

