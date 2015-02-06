/*  
--------------------------------------------------------------------------------    
Procedure Name: [dbo].[Usp_Measure_PatientQuickEntry_Select]    
Description   : This procedure is used to select all the relevant measures for a patient from labmeasure, 
			   proceduremeasure, diseasemeasure, Patient measure etc
Created By    : Pramd
Created Date  : 22-Apr-2011
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
16-Aug-2011 NagaBabu Added MeasureTextOptionId,MeasureTextOption fields in resultset 
19-aUG-2011 NagaBabu Added isnull condition for IsTextValueForControls field
---------------------------------------------------------------------------------    
*/    
    
CREATE PROCEDURE [dbo].[Usp_Measure_PatientQuickEntry_Select]
	( @i_AppUserId KEYID,
	  @i_PatientUserID KEYID
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
-----------  ---------------    
	  DECLARE @t_MeasureID TABLE (MeasureID INT)
	  
	  INSERT INTO @t_MeasureID (MeasureID)
	  SELECT LabMeasure.MeasureId
		FROM PatientProgram WITH (NOLOCK) 
			 INNER JOIN Program  WITH (NOLOCK) 
				ON Program.ProgramId = PatientProgram.ProgramId
				   AND Program.StatusCode = 'A'
				   AND PatientProgram.IsPatientDeclinedEnrollment = 0
			 INNER JOIN LabMeasure WITH (NOLOCK) 
				ON LabMeasure.ProgramId = PatientProgram.ProgramId
				AND LabMeasure.PatientUserID IS NULL
				AND LabMeasure.ProgramId IS NOT NULL
	   WHERE PatientProgram.PatientID = @i_PatientUserID
	  UNION
	  SELECT LabMeasure.MeasureId
	    FROM LabMeasure WITH (NOLOCK) 
	   WHERE LabMeasure.PatientUserID = @i_PatientUserID
	     AND LabMeasure.ProgramId IS NULL
	     AND LabMeasure.PatientUserID IS NOT NULL
	  UNION
	  SELECT PatientMeasure.MeasureId
	    FROM PatientMeasure WITH (NOLOCK) 
	   WHERE PatientID = @i_PatientUserID
	     AND StatusCode = 'A'
	  UNION
	  SELECT ProcedureMeasure.MeasureId
	    FROM PatientProcedureGroup WITH (NOLOCK) 
			 INNER JOIN ProcedureMeasure WITH (NOLOCK) 
				ON PatientProcedureGroup.PatientProcedureGroupID = ProcedureMeasure.ProcedureId
	   WHERE PatientProcedureGroup.PatientID = @i_PatientUserID
	     AND PatientProcedureGroup.StatusCode = 'A'
	     AND ProcedureMeasure.StatusCode = 'A'

      SELECT    
          Measure.MeasureId ,    
          Measure.Name,  
          Measure.RealisticMin ,  
          Measure.RealisticMax ,  
          Measure.StandardMeasureUOMId AS MeasureUOMID,  
          MeasureUOM.UOMText AS UOM,  
          ISNULL(Measure.IsTextValueForControls,0)AS IsTextValueForControls,
          Measure.MeasureTextOptionId,
          MeasureTextOption.MeasureTextOption   
      FROM    
          Measure WITH (NOLOCK) 
		  INNER JOIN @t_MeasureID TMSR
			ON Measure.MeasureId = TMSR.MeasureID 
		  LEFT OUTER JOIN MeasureUOM   WITH (NOLOCK) 
			ON MeasureUOM.MeasureUOMId = Measure.StandardMeasureUOMId  
		  INNER JOIN MeasureType  WITH (NOLOCK) 
			ON Measure.MeasureTypeId = MeasureType.MeasureTypeId
		  LEFT OUTER JOIN MeasureTextOption WITH (NOLOCK) 	
			ON MeasureTextOption.MeasureTextOptionId = Measure.MeasureTextOptionId	
     WHERE Measure.StatusCode = 'A'    
     ORDER BY Measure.SortOrder,
			  Measure.Name  
  
END TRY    
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Usp_Measure_PatientQuickEntry_Select] TO [FE_rohit.r-ext]
    AS [dbo];

