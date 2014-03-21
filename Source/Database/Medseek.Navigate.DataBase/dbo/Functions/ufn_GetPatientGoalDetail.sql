/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetPatientGoalDetail           
Description   : This Function is used to get the MeasureValue for patient
Created By    : Pramod                
Created Date  : 24-June-2010                
------------------------------------------------------------------------------                
Log History   :                 
DD-MM-YYYY     BY      DESCRIPTION                

------------------------------------------------------------------------------                
*/    
CREATE FUNCTION [dbo].[ufn_GetPatientGoalDetail]
(
  @i_MeasureId KeyID ,
  @i_PatientUserId KeyID
)
RETURNS VARCHAR(500)
AS

BEGIN
	DECLARE @vc_MeasureValue VARCHAR(500)

	-- Patient Level measure value calculation
	SELECT @vc_MeasureValue =
			CASE 
	           WHEN LabMeasure.TextValueForGoodControl IS NULL OR LabMeasure.TextValueForGoodControl = '' THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),''    
					 )			  
	           ELSE
				   LabMeasure.TextValueForGoodControl
			END
	  FROM LabMeasure
	 WHERE MeasureId = @i_MeasureId
	   AND PatientUserID = @i_PatientUserId
	   AND ProgramId IS NULL

	IF @@ROWCOUNT = 0
	BEGIN
		-- Program Level measure value calculation
		SELECT TOP 1 @vc_MeasureValue =
			   CASE 
	             WHEN LabMeasure.TextValueForGoodControl IS NULL OR LabMeasure.TextValueForGoodControl = '' THEN
					COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),''    
					 )			  
	             ELSE
				   LabMeasure.TextValueForGoodControl
			   END
		  FROM LabMeasure
			   INNER JOIN UserPrograms 
				   ON UserPrograms.ProgramId = LabMeasure.ProgramId
		 WHERE LabMeasure.MeasureId = @i_MeasureId
		   AND UserPrograms.UserId = @i_PatientUserId
		   AND LabMeasure.PatientUserID IS NULL
	-- Organization Level measure value calculation
		IF @@ROWCOUNT = 0
		BEGIN
			SELECT TOP 1 @vc_MeasureValue =
				   CASE 
					 WHEN LabMeasure.TextValueForGoodControl IS NULL OR LabMeasure.TextValueForGoodControl = '' THEN
						COALESCE    
						(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
						+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
						+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
						+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
						+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
						+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
						  ),''    
						 )			  
					 ELSE
					   LabMeasure.TextValueForGoodControl
				   END
			  FROM LabMeasure
			 WHERE MeasureId = @i_MeasureId
			   AND ProgramId IS NULL
			   AND PatientUserID IS NULL
		END	
	END	
	RETURN @vc_MeasureValue
END
