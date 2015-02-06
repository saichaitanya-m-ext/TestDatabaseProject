/*      
------------------------------------------------------------------------------      
Procedure Name: usp_LabMeasure_Select_ByPatientUserId      
Description   : This procedure is used to get the list of all the detais from the 
    LabMeasure table for a patient userid 
Created By    : Pramod
Created Date  : 14-Jun-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
19-Aug-2010 NagaBabu Added StatusDescription field to the second select statement  
29-Aug-2011 NagaBabu Changed the functionality in first result set  as requirement changed to override 
05-Sep-2011 NagaBabu Changed Query for getting distinct program,measures 
06-Sep-2011 NagaBabu  Added CASE statements GoodRange,FairRange,PoorRange fields  
08-Sep-2011 NagaBabu modified functionality for override count 
28-Oct-2011 NagaBabu Added Union and next select statement for the purpose of getting programlevel and patient level
						data for the given user
17-Nov-2011 NagaBabu Added 'AND PopulationLabMeasure.LabMeasureId = CurrentLabMeasure.LabMeasureId' in Second select list						   
22-Nov-2011 NagaBabu Added 'NOT IN' condition in CurrentLabMeasure inner table
28-Nov-2011 NagaBabu Removed ISNULL condition for OverRideStartDate,OverRideEndDate fields in CurrentLabMeasure TableSet  
------------------------------------------------------------------------------      
*/   --[usp_LabMeasure_Select_ByPatientUserId]23,145882
CREATE PROCEDURE [dbo].[usp_LabMeasure_Select_ByPatientUserId]
( 
  @i_AppUserId KeyId, 
  @i_PatientUserID KeyID
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

     DECLARE @tbl_ProgramList TABLE (ProgramId KeyID)

	 INSERT INTO @tbl_ProgramList (ProgramId)
	 SELECT DISTINCT ProgramId
	   FROM PatientProgram
	  WHERE PatientID = @i_PatientUserID
	    AND StatusCode = 'A'

	SELECT 
		LabMeasure.LabMeasureId,    
		LabMeasure.MeasureId,    
		LabMeasure.IsGoodControl,    
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
		END AS DerivedGoodValue, 
		LabMeasure.IsFairControl ,    
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
		CASE WHEN LabMeasure.TextValueForFairControl IS NULL OR LabMeasure.TextValueForFairControl = '' THEN
				   COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
					  ),''    
					 ) 
			   ELSE
					LabMeasure.TextValueForFairControl 
		END AS DerivedFairValue,
		LabMeasure.IsPoorControl,    
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
		CASE 
			WHEN LabMeasure.TextValueForPoorControl IS NULL OR LabMeasure.TextValueForPoorControl = '' THEN
			   COALESCE    
				(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
				  ),''    
				 ) 				  
			ELSE LabMeasure.TextValueForPoorControl 
		END AS DerivedPoorValue,
		LabMeasure.MeasureUOMId,    
		LabMeasure.ProgramId,    
		LabMeasure.PatientUserID,    
		LabMeasure.CreatedByUserId,    
		LabMeasure.CreatedDate,    
		LabMeasure.LastModifiedByUserId,    
		LabMeasure.LastModifiedDate,    
		Measure.Name as MeasureName,      
		Program.ProgramName,    
		CASE Measure.StatusCode       
		  WHEN 'A' THEN 'Active'     
		  WHEN 'I' THEN 'InActive'        
		END AS StatusDescription,    
		MeasureUOM.UOMText,    
		MeasureUOM.UOMDescription,    
		Measure.IsTextValueForControls    
    FROM      
	    LabMeasure   WITH (NOLOCK)    
	INNER JOIN Measure  WITH (NOLOCK)   
		ON LabMeasure.MeasureId = Measure.MeasureId    
	INNER JOIN @tbl_ProgramList tProgram     
		ON tProgram.ProgramId = LabMeasure.ProgramId    
	INNER JOIN Program    WITH (NOLOCK) 
		ON Program.ProgramId = LabMeasure.ProgramId    
	   AND Program.StatusCode = 'A'  
	LEFT OUTER JOIN MeasureUOM   WITH (NOLOCK)  
		ON MeasureUOM.MeasureUOMId = LabMeasure.MeasureUOMId    
	   AND MeasureUOM.StatusCode = 'A'
    WHERE LabMeasure.PatientUserID IS NULL
     AND LabMeasure.ProgramId IS NOT NULL
     AND Measure.StatusCode = 'A'    
	
	
	SELECT DISTINCT
		CurrentLabMeasure.LabMeasureId AS LabMeasureId,
		PopulationLabMeasure.ProgramId ,
		PopulationLabMeasure.ProgramName ,
		ISNULL(PopulationLabMeasure.MeasureId,CurrentLabMeasure.MeasureId) AS MeasureId ,
		ISNULL(PopulationLabMeasure.Name,CurrentLabMeasure.Name) AS MeasureName ,
		PopulationLabMeasure.GoodRange ,
		PopulationLabMeasure.FairRange ,
		PopulationLabMeasure.PoorRange ,
		CONVERT(VARCHAR,PopulationLabMeasure.StartDate ,101)AS StartDate ,
		PopulationLabMeasure.CreatedByUserId,    
		PopulationLabMeasure.CreatedDate,    
		PopulationLabMeasure.LastModifiedByUserId,    
		PopulationLabMeasure.LastModifiedDate,   
		ISNULL(PopulationLabMeasure.DefinedAt,CurrentLabMeasure.DefinedAt) AS DefinedAt ,
		CurrentLabMeasure.OverRideGoodRange ,
		CurrentLabMeasure.OverRideFairRange ,
		CurrentLabMeasure.OverRidePoorRange ,
		CONVERT(VARCHAR,CurrentLabMeasure.OverRideStartDate ,101)AS OverRideStartDate ,
		CONVERT(VARCHAR,CurrentLabMeasure.OverRideEndDate ,101)AS OverRideEndDate ,
		OverRideDetails.OverRideCount ,
		CurrentLabMeasure.[Status]
	FROM (				
			SELECT
				LabMeasure.LabMeasureId ,
				tProgram.ProgramId ,
				Program.ProgramName , 
				LabMeasure.MeasureId ,
				LabMeasure.CreatedByUserId,    
				LabMeasure.CreatedDate,    
				LabMeasure.LastModifiedByUserId,    
				LabMeasure.LastModifiedDate,    
				Measure.Name ,
				CASE 
					WHEN LabMeasure.ProgramId IS NOT NULL THEN 'Program'
					WHEN LabMeasure.PatientUserID IS NOT NULL THEN 'Patient'
				END AS DefinedAt ,
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForGoodControl 
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),'') END  AS GoodRange,
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForFairControl
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
					  ),'') END  AS FairRange, 
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForPoorControl
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
					  ),'') END  AS PoorRange ,
				LabMeasure.StartDate
			FROM  
				LabMeasure    WITH (NOLOCK) 
			INNER JOIN Measure   WITH (NOLOCK)  
				ON LabMeasure.MeasureId = Measure.MeasureId    
			INNER JOIN @tbl_ProgramList tProgram    
				ON tProgram.ProgramId = LabMeasure.ProgramId    
			INNER JOIN Program   WITH (NOLOCK)   
				ON Program.ProgramId = LabMeasure.ProgramId    
			   AND Program.StatusCode = 'A'  
			WHERE LabMeasure.PatientUserID IS NULL
			  AND LabMeasure.ProgramId IS NOT NULL
			  AND Measure.StatusCode = 'A'
			  AND StartDate IS NOT NULL    
	   ) PopulationLabMeasure 
	RIGHT OUTER JOIN 
			(
			SELECT 
				LabMeasure.LabMeasureId,
				LabMeasure.MeasureId ,
				Measure.Name ,
				CASE 
					WHEN LabMeasure.ProgramId IS NOT NULL THEN 'Program'
					WHEN LabMeasure.PatientUserID IS NOT NULL THEN 'Patient'
				END AS DefinedAt ,
				CASE WHEN GETDATE() < LabMeasure.EndDate-ReminderDaysBeforeEnddate THEN 'Green'
					 WHEN GETDATE() BETWEEN LabMeasure.EndDate-ReminderDaysBeforeEnddate AND LabMeasure.EndDate THEN 'Orange'
					 WHEN GETDATE() > LabMeasure.EndDate THEN 'Red'
				END AS [Status] ,	 
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForGoodControl 
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),'') END  AS OverRideGoodRange,
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForFairControl
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
					  ),'') END  AS OverRideFairRange, 
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForPoorControl
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
					  ),'') END  AS OverRidePoorRange,
				LabMeasure.StartDate AS OverRideStartDate,
				LabMeasure.EndDate AS OverRideEndDate
			FROM
				LabMeasure WITH (NOLOCK) 
			INNER JOIN Measure  WITH (NOLOCK) 
				ON Measure.MeasureId = LabMeasure.MeasureId	
			LEFT OUTER JOIN (SELECT 
							MeasureId ,
							MAX(Startdate) Startdate ,
							MAX(EndDate) EndDate
						FROM LabMeasure WITH (NOLOCK) 
						INNER JOIN @tbl_ProgramList tProgram    
							ON tProgram.ProgramId = LabMeasure.ProgramId    
						INNER JOIN Program   WITH (NOLOCK)   
							ON Program.ProgramId = LabMeasure.ProgramId    
						   AND Program.StatusCode = 'A' 	
						--WHERE LabMeasure.MeasureId = @i_PatientUserID 
						GROUP BY MeasureId)LabMeasureDetails
				ON LabMeasure.MeasureId = LabMeasureDetails.MeasureId
				--AND LabMeasure.StartDate  = LabMeasureDetails.StartDate	
				--AND LabMeasure.EndDate  = LabMeasureDetails.EndDate
				WHERE LabMeasure.PatientUserID = @i_PatientUserID 
				--AND NOT EXISTS (SELECT
				--					1
				--				FROM
				--					LabMeasure
				--				WHERE LabMeasure.PatientUserID = @i_PatientUserID)	
				
			  
 			UNION 
 			SELECT 
				LabMeasure.LabMeasureId,
				LabMeasure.MeasureId ,
				Measure.Name ,
				CASE 
					WHEN LabMeasure.ProgramId IS NOT NULL THEN 'Program'
					WHEN LabMeasure.PatientUserID IS NOT NULL THEN 'Patient'
				END AS DefinedAt ,
				CASE WHEN GETDATE() < LabMeasure.EndDate-ReminderDaysBeforeEnddate THEN 'Green'
					 WHEN GETDATE() BETWEEN LabMeasure.EndDate-ReminderDaysBeforeEnddate AND LabMeasure.EndDate THEN 'Orange'
					 WHEN GETDATE() > LabMeasure.EndDate THEN 'Red'
				END AS [Status] ,	 
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForGoodControl 
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
					  ),'') END  AS OverRideGoodRange,
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForFairControl
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forFairControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
					  ),'') END  AS OverRideFairRange, 
				CASE WHEN COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
					  ),'') = '' THEN TextValueForPoorControl
					ELSE COALESCE    
					(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
					+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
					+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
					  ),'') END  AS OverRidePoorRange,
				LabMeasure.StartDate AS OverRideStartDate,
				LabMeasure.EndDate AS OverRideEndDate
			FROM
				LabMeasure WITH (NOLOCK) 
			INNER JOIN Measure  WITH (NOLOCK) 
				ON Measure.MeasureId = LabMeasure.MeasureId	
			INNER JOIN @tbl_ProgramList tProgram    
				ON tProgram.ProgramId = LabMeasure.ProgramId    
			INNER JOIN Program    WITH (NOLOCK) 
				ON Program.ProgramId = LabMeasure.ProgramId    
			   AND Program.StatusCode = 'A' 
			--WHERE LabMeasure.PatientUserID = @i_PatientUserID 
			  --AND ((GETDATE() BETWEEN StartDate AND EndDate)
					--OR GETDATE() > EndDate)
			   AND LabMeasure.MeasureId NOT IN (SELECT LabMeasure.MeasureId
												 FROM LabMeasure
												 WHERE LabMeasure.PatientUserID = @i_PatientUserID)		 								
					) CurrentLabMeasure
		ON PopulationLabMeasure.MeasureId = CurrentLabMeasure.MeasureId
		--AND PopulationLabMeasure.LabMeasureId = CurrentLabMeasure.LabMeasureId   
	LEFT OUTER JOIN 
			(SELECT MeasureId ,
				COUNT(MeasureId) AS OverRideCount
			 FROM 
				 LabMeasureHistory WITH (NOLOCK) 	
			 WHERE
				 (StartDate IS NOT NULL) 
			 AND (PatientUserID = @i_PatientUserID )
			 
			 GROUP BY MeasureId,ProgramId
			) OverRideDetails
		ON OverRideDetails.MeasureId = CurrentLabMeasure.MeasureId
		--AND PopulationLabMeasure.ProgramId = OverRideDetails.ProgramId 
	ORDER BY PopulationLabMeasure.ProgramId,
			 ISNULL(PopulationLabMeasure.MeasureId,CurrentLabMeasure.MeasureId)
	--ORDER BY ISNULL(PopulationLabMeasure.LabMeasureId,CurrentLabMeasure.LabMeasureId)		 		  

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
    ON OBJECT::[dbo].[usp_LabMeasure_Select_ByPatientUserId] TO [FE_rohit.r-ext]
    AS [dbo];

