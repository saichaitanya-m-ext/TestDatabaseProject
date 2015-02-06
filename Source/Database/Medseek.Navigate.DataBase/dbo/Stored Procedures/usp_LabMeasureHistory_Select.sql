/*        
------------------------------------------------------------------------------        
Procedure Name: usp_LabMeasureHistory_Select
Description   : This procedure is used to get data from LabMeasureHistory Table  
Created By    : Rathnam
Created Date  : 12-Sep-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION  
12-Sep-2011 NagaBabu Added @t_LabMeasureValues for getting DefinedAt,[Override] fields 
28-Nov-2011 NagaBabu Added @i_ProgramId as input parameter and added select statement with UNION keyword for getting 
						program level goals
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_LabMeasureHistory_Select]--318061,197
(
  @i_AppUserId KEYID
 ,@i_LabMeasureID KEYID
 ,@i_ProgramId KEYID = NULL
)
AS
BEGIN TRY
      SET NOCOUNT ON         
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

----------- Select EDCCodes details -------------------  
	DECLARE @i_MeasureId KEYID = (SELECT MeasureId 
								  FROM LabMeasure
								  WHERE LabMeasureId = @i_LabMeasureID)
	
	DECLARE @t_LabMeasureValues TABLE
	(
		[Override] Keyid IDENTITY(0,1) ,
		DefinedAt VARCHAR(15) ,
		LabMeasureHistoryID INT ,
		GoodRange VARCHAR(60) ,
		FairRange VARCHAR(60) ,
		PoorRange VARCHAR(60) ,
		StartDate DATE ,
		EndDate DATE ,
		Duration INT ,
		ReminderDaysBeforeEnddate INT
	)
	
	INSERT INTO @t_LabMeasureValues
	(
		DefinedAt ,
		LabMeasureHistoryID ,
		GoodRange ,
		FairRange ,
		PoorRange ,
		StartDate ,
		EndDate ,
		Duration ,
		ReminderDaysBeforeEnddate
	)	 
      
      SELECT
			CASE 
				WHEN LabMeasure.ProgramId IS NOT NULL THEN 'Program'
				WHEN LabMeasure.PatientUserID IS NOT NULL THEN 'Patient'
			END AS DefinedAt ,
			LabMeasureID,
			CASE WHEN COALESCE    
				(( ISNULL(LabMeasure.Operator1forGoodControl,'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasure.Operator2forGoodControl,'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
				  ),'') = '' THEN LabMeasure.TextValueForGoodControl 
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
				  ),'') = '' THEN LabMeasure.TextValueForFairControl
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
				  ),'') = '' THEN LabMeasure.TextValueForPoorControl
				ELSE COALESCE    
				(( ISNULL(LabMeasure.Operator1forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasure.Operator2forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
				  ),'') END  AS PoorRange ,
			CONVERT(VARCHAR,LabMeasure.StartDate,101) AS StartDate ,
			ISNULL(CONVERT(VARCHAR,LabMeasure.EndDate,101),'') AS EndDate ,
			DATEDIFF(DAY,LabMeasure.StartDate,LabMeasure.EndDate) AS Duration,
		   LabMeasure.ReminderDaysBeforeEnddate
      FROM
         LabMeasure WITH (NOLOCK) 
	  WHERE LabMeasure.ProgramId = @i_ProgramId
		AND LabMeasure.MeasureId = @i_MeasureId
		AND @i_ProgramId IS NOT NULL
      UNION 
      SELECT
			CASE 
				WHEN LabMeasureHistory.ProgramId IS NOT NULL THEN 'Program'
				WHEN LabMeasureHistory.PatientUserID IS NOT NULL THEN 'Patient'
			END AS DefinedAt ,
			LabMeasureHistoryID,
			CASE WHEN COALESCE    
				(( ISNULL(LabMeasureHistory.Operator1forGoodControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasureHistory.Operator2forGoodControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
				  ),'') = '' THEN LabMeasureHistory.TextValueForGoodControl 
				ELSE COALESCE    
				(( ISNULL(LabMeasureHistory.Operator1forGoodControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value2forGoodControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasureHistory.Operator2forGoodControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
				  ),'') END  AS GoodRange,
			CASE WHEN COALESCE    
				(( ISNULL(LabMeasureHistory.Operator1forFairControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value2forFairControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasureHistory.Operator2forFairControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value2forFairControl AS VARCHAR(20)),'')    
				  ),'') = '' THEN LabMeasureHistory.TextValueForFairControl
				ELSE COALESCE    
				(( ISNULL(LabMeasureHistory.Operator1forFairControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value2forFairControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasureHistory.Operator2forFairControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value2forFairControl AS VARCHAR(20)),'')    
				  ),'') END  AS FairRange, 
			CASE WHEN COALESCE    
				(( ISNULL(LabMeasureHistory.Operator1forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasureHistory.Operator2forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
				  ),'') = '' THEN LabMeasureHistory.TextValueForPoorControl
				ELSE COALESCE    
				(( ISNULL(LabMeasureHistory.Operator1forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator1Value2forPoorControl AS VARCHAR(20)),'')     
				+ ISNULL(LabMeasureHistory.Operator2forPoorControl,'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' '     
				+ ISNULL(CAST(LabMeasureHistory.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
				  ),'') END  AS PoorRange ,
			CONVERT(VARCHAR,LabMeasureHistory.StartDate,101) AS StartDate ,
			ISNULL(CONVERT(VARCHAR,LabMeasureHistory.EndDate,101),'') AS EndDate ,
			DATEDIFF(DAY,LabMeasureHistory.StartDate,LabMeasureHistory.EndDate) AS Duration,
		   LabMeasureHistory.ReminderDaysBeforeEnddate
      FROM
          LabMeasureHistory WITH (NOLOCK) 
      INNER JOIN LabMeasure WITH (NOLOCK) 
		  ON LabMeasureHistory.LabMeasureId = LabMeasure.LabMeasureId    
      WHERE 
		  LabMeasureHistory.LabMeasureId = @i_LabMeasureID
		  
	SELECT
		[Override] ,
		DefinedAt ,
		LabMeasureHistoryID ,
		GoodRange ,
		FairRange ,
		PoorRange ,
		CONVERT(VARCHAR,StartDate,101) AS StartDate ,
		CONVERT(VARCHAR,EndDate,101) AS EndDate ,
		Duration ,
		ReminderDaysBeforeEnddate
	FROM
		@t_LabMeasureValues
	ORDER BY 
		[Override] DESC			  
		 
END TRY        
--------------------------------------------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabMeasureHistory_Select] TO [FE_rohit.r-ext]
    AS [dbo];

