/*    
------------------------------------------------------------------------------    
Procedure Name: usp_LabMeasureRangeHierarchy_Select    
Description   : This procedure is used to get the LabMeasureRanges by Hierarchy
Created By    : Rathnam
Created Date  : 08-05-2011 
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
25-Mar-2013 P.V.P.MOhan Modified PatientID in place of UserID 
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_LabMeasureRangeHierarchy_Select] 
(  
	@i_AppUserId KeyID,
	@i_PatientUserID KEYID,
	@tblMeasureID ttypeKeyID READONLY
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  
    
	CREATE TABLE #tblLabMeasureRange
			(
				LabMeasureId INT,
				MeasureId INT,
				ProgramId INT,
				PatientUserID INT,
				GoodRange VARCHAR(50),
				FairRange VARCHAR(50),
				PoorRange VARCHAR(50),
				StartDate DATETIME,
				EndDate DATETIME
			)
    DECLARE @tablMeasures TABLE
    (
    MeasureID1 INT
    )
    
    INSERT INTO @tablMeasures
    SELECT tkeyid FROM @tblMeasureID
    
	INSERT INTO #tblLabMeasureRange 
	SELECT 
		LabMeasureId,
		MeasureId,
		ProgramId,
		PatientUserID,
		COALESCE    
		((      
		  ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' - '     
		+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'&')     
		+ ' * '     
		+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' - '     
		+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
		  ),''    
		 ),
		COALESCE    
		((     
		  ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' - '     
		+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'&')     
		+  ' * '     
		+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' - '     
		+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
		  ),''    
		 ),
		COALESCE    
		((     
		  ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' - '     
		+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'&')     
		+  ' * '     
		+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' - '     
		+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
		  ),''    
		 ),
		LabMeasure.StartDate,
		LabMeasure.EndDate			  
	FROM
		LabMeasure  WITH (NOLOCK) 
	INNER JOIN @tablMeasures tblM
	ON tblM.MeasureID1 = LabMeasure.MeasureID
	WHERE PatientUserID = @i_PatientUserId
	  AND ProgramId IS NULL
	  AND LabMeasure.StartDate IS NOT NULL
	
	DELETE FROM @tablMeasures WHERE MeasureID1 IN (SELECT DISTINCT MeasureID FROM #tblLabMeasureRange)  
	IF EXISTS (SELECT TOP 1 1 FROM @tablMeasures)
	BEGIN    
		 INSERT INTO #tblLabMeasureRange 
		 SELECT 
			LabMeasure.LabMeasureId,
			LabMeasure.MeasureId,
			LabMeasure.ProgramId,
			LabMeasure.PatientUserID,
			COALESCE    
			((      
			  ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' - '     
			+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'&')     
			+ ' * '     
			+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' - '     
			+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
			  ),''    
			 ),
			COALESCE    
			((     
			  ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' - '     
			+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'&')     
			+  ' * '     
			+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' - '     
			+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
			  ),''    
			 ),
			COALESCE    
			((     
			  ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' - '     
			+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'&')     
			+  ' * '     
			+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' - '     
			+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
			  ),''    
			 ),
			 LabMeasure.StartDate,
			 LabMeasure.EndDate			  
		 FROM 
			 LabMeasure WITH (NOLOCK) 
		 INNER JOIN @tablMeasures tblM
			 ON tblM.MeasureID1 = LabMeasure.MeasureID	 
		 INNER JOIN Patients WITH (NOLOCK) 
			 ON LabMeasure.PatientUserID = Patients.PatientID
		 INNER JOIN PatientProgram WITH (NOLOCK) 
			 ON PatientProgram.PatientID = Patients.PatientID
		 WHERE 
			   PatientProgram.PatientID = @i_PatientUserId
		   AND LabMeasure.ProgramId IS NOT NULL
		   AND LabMeasure.PatientUserID IS NULL
		   AND PatientProgram.StatusCode = 'A'
		   AND LabMeasure.StartDate IS NOT NULL
		 
		 DELETE FROM @tablMeasures WHERE MeasureID1 IN (SELECT DISTINCT MeasureID FROM #tblLabMeasureRange)  
		 IF EXISTS (SELECT TOP 1 1 FROM @tablMeasures)
			BEGIN
				  INSERT INTO #tblLabMeasureRange 
				  SELECT 
						LabMeasureId,
						MeasureId,
						ProgramId,
						PatientUserID,
						COALESCE    
						((      
						  ISNULL(CAST(LabMeasure.Operator1Value1forGoodControl AS VARCHAR(20)),'') + ' - '     
						+ ISNULL(CAST(LabMeasure.Operator1Value2forGoodControl AS VARCHAR(20)),'&')     
						+ ' * '     
						+ ISNULL(CAST(LabMeasure.Operator2Value1forGoodControl AS VARCHAR(20)),'') + ' - '     
						+ ISNULL(CAST(LabMeasure.Operator2Value2forGoodControl AS VARCHAR(20)),'')    
						  ),''    
						 ),
						COALESCE    
						((     
						  ISNULL(CAST(LabMeasure.Operator1Value1forFairControl AS VARCHAR(20)),'') + ' - '     
						+ ISNULL(CAST(LabMeasure.Operator1Value2forFairControl AS VARCHAR(20)),'&')     
						+  ' * '     
						+ ISNULL(CAST(LabMeasure.Operator2Value1forFairControl AS VARCHAR(20)),'') + ' - '     
						+ ISNULL(CAST(LabMeasure.Operator2Value2forFairControl AS VARCHAR(20)),'')    
						  ),''    
						 ),
						COALESCE    
						((     
						  ISNULL(CAST(LabMeasure.Operator1Value1forPoorControl AS VARCHAR(20)),'') + ' - '     
						+ ISNULL(CAST(LabMeasure.Operator1Value2forPoorControl AS VARCHAR(20)),'&')     
						+  ' * '     
						+ ISNULL(CAST(LabMeasure.Operator2Value1forPoorControl AS VARCHAR(20)),'') + ' - '     
						+ ISNULL(CAST(LabMeasure.Operator2Value2forPoorControl AS VARCHAR(20)),'')    
						  ),''    
						 ),
					  LabMeasure.StartDate,
					  LabMeasure.EndDate	 			  
				  FROM 
					  LabMeasure WITH (NOLOCK) 
				  INNER JOIN @tablMeasures tblM
					  ON tblM.MeasureID1 = LabMeasure.MeasureID	  
				  WHERE 
					    LabMeasure.PatientUserID IS NULL
					AND LabMeasure.ProgramId IS NULL
					AND LabMeasure.StartDate IS NOT NULL
				END 
		END			    
        
        CREATE TABLE #tblMeasureRange
        (
			LabMeasureId INT,
			MeasureId INT,
			ProgramId INT,
			PatientUserID INT,
			MinValue VARCHAR(50),
			MaxValue VARCHAR(50),
			MeasureRange VARCHAR(5),
			StartDate DATETIME,
			EndDate DATETIME
        )
       
	   INSERT INTO #tblMeasureRange
	   SELECT 
	        LabMeasureId,
	        MeasureId,
			ProgramId,
			PatientUserID,
			CASE WHEN CHARINDEX ('&',GoodRange,1) <> 0 
			     THEN SUBSTRING(GoodRange,1,CHARINDEX('*',GoodRange,1)-1)
			     ELSE SUBSTRING(GoodRange,1,CHARINDEX('-',GoodRange,1)-1) END,
			CASE WHEN CHARINDEX('&',GoodRange,1) <> 0 
			     THEN REPLACE(SUBSTRING(GoodRange,CHARINDEX('*',GoodRange,1),LEN(GoodRange)),'*','')
			     ELSE SUBSTRING(GoodRange,CHARINDEX('-',GoodRange,1),LEN(GoodRange)) END,
			'Good',
			StartDate ,
			EndDate 
	   FROM #tblLabMeasureRange
	   WHERE GoodRange IS NOT NULL
	   UNION ALL
	   SELECT 
	        LabMeasureId,
	        MeasureId,
			ProgramId,
			PatientUserID,
			CASE WHEN CHARINDEX ('&',FairRange,1) <> 0 
			     THEN SUBSTRING(FairRange,1,CHARINDEX('*',FairRange,1)-1)
			     ELSE SUBSTRING(FairRange,1,CHARINDEX('-',FairRange,1)-1) END,
			CASE WHEN CHARINDEX('&',FairRange,1) <> 0 
			     THEN REPLACE(SUBSTRING(FairRange,CHARINDEX('*',FairRange,1),LEN(FairRange)),'*','')
			     ELSE SUBSTRING(FairRange,CHARINDEX('-',FairRange,1),LEN(FairRange)) END,
			'Fair',
			StartDate ,
			EndDate 
		FROM #tblLabMeasureRange
		WHERE FairRange IS NOT NULL
		UNION ALL
		SELECT 
	        LabMeasureId,
	        MeasureId,
			ProgramId,
			PatientUserID,
			CASE WHEN CHARINDEX ('&',PoorRange,1) <> 0 
			     THEN SUBSTRING(PoorRange,1,CHARINDEX('*',PoorRange,1)-1)
			     ELSE SUBSTRING(PoorRange,1,CHARINDEX('-',PoorRange,1)-1) END,
			CASE WHEN CHARINDEX('&',PoorRange,1) <> 0 
			     THEN REPLACE(SUBSTRING(PoorRange,CHARINDEX('*',PoorRange,1),LEN(PoorRange)),'*','')
			     ELSE SUBSTRING(PoorRange,CHARINDEX('-',PoorRange,1),LEN(PoorRange)) END,
			'Poor',		
  			StartDate ,
			EndDate 
		FROM #tblLabMeasureRange
		WHERE PoorRange IS NOT NULL    
				
        
        ;WITH cteMeasure AS (
        SELECT 
			MR.LabMeasureId ,
			MR.MeasureId ,
			MR.ProgramId ,
			MR.PatientUserID ,
			CASE WHEN REPLACE(REPLACE(REPLACE(MinValue,'-',''),'*',''),'&','') = '' 
			     THEN NULL 
			     ELSE REPLACE(REPLACE(REPLACE(MinValue,'-',''),'*',''),'&','')
		    END AS MinValue,
			CASE WHEN REPLACE(REPLACE(REPLACE(MaxValue,'-',''),'*',''),'&','') = ''
			     THEN NULL
			     ELSE REPLACE(REPLACE(REPLACE(MaxValue,'-',''),'*',''),'&','')
			END AS MaxValue,
			MR.MeasureRange,
			Measure.Name,
			StartDate ,
			EndDate  
        FROM #tblMeasureRange MR
        INNER JOIN Measure WITH (NOLOCK) 
              ON Measure.MeasureId = MR.MeasureId)
        
        SELECT 
			LabMeasureId ,
			MeasureId ,
			ProgramId ,
			PatientUserID ,
			MinValue,
			MaxValue,
			MeasureRange,
			Name,
			StartDate ,
			EndDate 
        FROM cteMeasure
        WHERE MinValue IS NOT NULL OR MaxValue IS NOT NULL
        
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
    ON OBJECT::[dbo].[usp_LabMeasureRangeHierarchy_Select] TO [FE_rohit.r-ext]
    AS [dbo];

