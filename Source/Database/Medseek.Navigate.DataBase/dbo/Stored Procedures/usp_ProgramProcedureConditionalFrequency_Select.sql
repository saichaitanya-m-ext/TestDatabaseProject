/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_ProgramProcedureConditionalFrequency_Select]
Description   : This procedure is used to select data from ProgramProcedureConditionalFrequency
Created By    : NagaBabu
Created Date  : 08-Aug-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION   
10-Aug-2011 NagaBabu Added @i_ProcedureID as input parameter 
11-Aug-2011 NagaBabu Removed Existing fields and Added new fields in select statement 
22-Aug-2011 NagaBabu replaced INNER JOIN by LEFT OUTER JOIN with Measure table    
------------------------------------------------------------------------------      
*/    
CREATE PROCEDURE [dbo].[usp_ProgramProcedureConditionalFrequency_Select]
(    
 @i_AppUserId KeyID , 
 @i_ProgramId KeyID ,
 @i_ProcedureID KeyID
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
 -------------------------------------------------------------------------------  
  
    SELECT
		--PPCF.ProgramProcedureMeasureConditionID ,
		--PPCF.MeasureID ,
		ISNULL(Measure.Name,'__') AS Name,
		ISNULL(ISNULL((PPCF.FromOperatorforMeasure + '' + CAST(PPCF.FromValueforMeasure AS VARCHAR) 
				+ ' ' + ISNULL(PPCF.ToOperatorforMeasure,'') + '' + 
				ISNULL(CAST(PPCF.ToValueforMeasure AS VARCHAR),'')),PPCF.MeasureTextValue),'__') AS MeasureCondition ,
		ISNULL((PPCF.FromOperatorforAge + '' + CAST(PPCF.FromValueforAge AS VARCHAR) 
				+ ' ' + ISNULL(PPCF.ToOperatorforAge,'') + '' + 
				ISNULL(CAST(PPCF.ToValueforAge AS VARCHAR),'')),'__') AS AgeCondition ,		
		CAST(PPCF.Frequency AS VARCHAR) + ' ' + (CASE PPCF.FrequencyUOM 
													 WHEN 'D' THEN 'Day(s)'
													 WHEN 'W' THEN 'Week(s)'
													 WHEN 'M' THEN 'Month(s)'
													 WHEN 'Y' THEN 'Year(s)'
												 END ) AS FrequencyUOM 	 
	FROM 
		ProgramProcedureConditionalFrequency PPCF WITH(NOLOCK)
	INNER JOIN Program WITH(NOLOCK)
		ON Program.ProgramId = PPCF.ProgramId
	INNER JOIN CodeSetProcedure WITH(NOLOCK)
		ON CodeSetProcedure.ProcedureCodeID = PPCF.ProcedureID
	LEFT OUTER JOIN Measure WITH(NOLOCK)
		ON Measure.MeasureID = PPCF.MeasureID	
	WHERE
		PPCF.ProgramID = @i_ProgramId
	AND PPCF.ProcedureID =@i_ProcedureID	
				 		
END TRY      
--------------------------------------------------------       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException     
     @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramProcedureConditionalFrequency_Select] TO [FE_rohit.r-ext]
    AS [dbo];

