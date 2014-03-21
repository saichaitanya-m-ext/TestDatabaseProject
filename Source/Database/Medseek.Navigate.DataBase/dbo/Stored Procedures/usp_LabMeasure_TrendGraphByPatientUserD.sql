/*
--------------------------------------------------------------------------------
Procedure Name: [usp_LabMeasure_TrendGraphByPatientUserD]
Description	  : This procedure is used to get the values of over rides for that particular measure
Created By    :	Rathnam
Created Date  : 29-Aug-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
16-Nov-2011 Rathnam added Organization level & modified the program level conditions
                    and commented the startdate and enddate variables while getting the usermeasures
22-Nov-2011 NagaBabu Added @i_LabMeasureId as input parameter                     
---------------------------------------------------------------------------------
*/  
CREATE PROCEDURE [dbo].[usp_LabMeasure_TrendGraphByPatientUserD]
(
	@i_AppUserId KeyId,
	@i_PatientUserID Keyid,
	@i_MeasureId KeyId ,
	@i_ProgramId KeyId = NULL,
	@i_LabMeasureId KEYID 
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
------------------------------------------------------------------------------------------------
	--DECLARE @d_StartDate DATETIME,
	--		@d_EndDate DATETIME
		
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
		StartDate,
		LabMeasure.EndDate 
	FROM
		LabMeasure 
	WHERE MeasureId = @i_MeasureId 
	  AND PatientUserID = @i_PatientUserId
	  AND ProgramId IS NULL
	  AND StartDate IS NOT NULL
	  AND LabMeasureId = @i_LabMeasureId
	  
	IF @@ROWCOUNT =0
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
			 LabMeasure
		 INNER JOIN UserPrograms
			 ON UserPrograms.ProgramId = LabMeasure.ProgramId
		 WHERE LabMeasure.MeasureId = @i_MeasureId 
		   AND UserPrograms.UserId = @i_PatientUserId
		   AND LabMeasure.ProgramId IS NOT NULL
		   AND LabMeasure.PatientUserID IS NULL
		   AND LabMeasure.StartDate IS NOT NULL
		   AND LabMeasureId = @i_LabMeasureId
		   
		 IF @@ROWCOUNT =0
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
					 LabMeasure
				 WHERE LabMeasure.MeasureId = @i_MeasureId 
				   AND LabMeasure.PatientUserID IS NULL
				   AND LabMeasure.ProgramId IS NULL
				   AND LabMeasureId = @i_LabMeasureId
				   
			   
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
        INNER JOIN Measure
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
		/*
		SELECT @d_StartDate = MIN(StartDate) FROM #tblMeasureRange	
		
		SELECT @d_EndDate = ISNULL(MAX(EndDate),GETDATE()) FROM #tblMeasureRange	
		*/
	    SELECT 
			MeasureId,
			PatientUserId,
			ISNULL(MeasureValueNumeric,MeasureValueText) MeasureValue,
			DateTaken 
	    FROM 
			UserMeasure 
		WHERE 
			PatientUserId = @i_PatientUserId
		AND MeasureID = @i_MeasureID	
		--AND DateTaken BETWEEN @d_StartDate AND @d_EndDate
		AND StatusCode = 'A' 
		
	    
END TRY
--------------------------------------------------------------------------------------------------
BEGIN CATCH

    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LabMeasure_TrendGraphByPatientUserD] TO [FE_rohit.r-ext]
    AS [dbo];

