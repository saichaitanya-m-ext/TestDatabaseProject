/*          
------------------------------------------------------------------------------          
Procedure Name: [usp_CareProviderDashBoard_MyPatients_DiseaseView_TrendGraph]
Description   : This Procedure is used to get Trend values for aspecific Disease and Measure
Created By    : NagaBabu
Created Date  : 14-June-2011
------------------------------------------------------------------------------          
Log History   :   
16-June-2011 NagaBabu  Added MeasureName Field in Resultset and added @i_Measure as variable 
17-June-2011 NagaBabu  Added secound Resultset for getting MeasureIds, MeasureNames For a particular Disease 
28-June-2011 NagaBabu Added 'WHERE DateTaken IS NOT NULL' in secound select statement  
19-July-2011 Rathnam implimented the my patients logic and removed the userdisease table join  
27-July-2011 NagaBabu Added statuscode = 'A' in first select statement  
31-Oct-2011 Rathnam added @v_TimePeriod parameter and added fromdate and todate for datetaken    
14-Nov-2011 Rathnam CAST ( CONVERT (VARCHAR(10), DateTaken,  121)  AS DATE) AS DateTaken added condition
			while caliculating the range values
14-Dec-2011 NagaBabu Added @b_IsCareProvider Parameter for differenciating data for CareProvider,Admin levels			
------------------------------------------------------------------------------
*/ 

CREATE PROCEDURE [dbo].[usp_CareProviderDashBoard_MyPatients_DiseaseView_TrendGraph]
(
   @i_AppUserId KeyId ,
   @i_DiseaseId KeyId ,
   @i_MeasureId KeyId = NULL ,
   @v_TimePeriod VARCHAR(3) = 'All' , ----> All,1-Y, 6-M, 1-M,1-W 
   @b_IsCareProvider BIT = 0
   
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
	DECLARE @d_FromDate DATETIME,
			@d_ToDate DATETIME 
			
	SELECT @d_ToDate = CASE @v_TimePeriod WHEN  'All' THEN NULL ELSE GETDATE() END	
    SELECT @d_FromDate = CASE @v_TimePeriod WHEN  'All' THEN NULL 
						                    WHEN  '1-Y' THEN DATEADD(YY,-1,GETDATE()) 
											WHEN  '6-M' THEN DATEADD(MM,-6,GETDATE())
											WHEN  '1-M' THEN DATEADD(MM,-1,GETDATE())
											WHEN  '1-W' THEN DATEADD(WK,-1,GETDATE())
                         END			
	CREATE TABLE #PatientMeasures
	(
		PatientUserId INT ,
		DateTaken DATETIME ,
		MeasureRange VARCHAR(20) ,
		MeasureId INT ,
		MeasureName VARCHAR(100)
	)
	
	DECLARE @i_Measure KeyId = (SELECT SUBSTRING([dbo].[ufn_GetPrimaryMeasure](@i_DiseaseId),1,CHARINDEX('*',[dbo].[ufn_GetPrimaryMeasure](@i_DiseaseId))-1))
	IF @b_IsCareProvider = 0
		INSERT INTO #PatientMeasures
		(
			PatientUserId ,
			DateTaken ,
			MeasureRange ,
			MeasureId ,
			MeasureName
		)
		SELECT 
			UserMeasure.PatientUserId ,
			UserMeasure.DateTaken ,
			UserMeasureRange.MeasureRange,
			UserMeasure.MeasureId,
			Measure.Name AS MeasureName
		FROM
			DiseaseMeasure
		INNER JOIN UserMeasure
			ON UserMeasure.MeasureId = DiseaseMeasure.MeasureId
			AND DiseaseMeasure.StatusCode = 'A'
		INNER JOIN UserMeasureRange
			ON UserMeasureRange.UserMeasureID = UserMeasure.UserMeasureID 
		INNER JOIN Measure
			ON UserMeasure.MeasureId = Measure.MeasureId
			AND Measure.StatusCode ='A'
		INNER JOIN Patients
			ON Patients.UserID = UserMeasure.PatientUserId
		INNER JOIN CareTeam
			ON CareTeam.CareTeamID = Patients.CareTeamID
			AND CareTeam.StatusCode = 'A' 
		INNER JOIN CareTeamMembers
			ON CareTeamMembers.CareTeamID = CareTeam.CareTeamID 
			AND CareTeamMembers.StatusCode = 'A'       	 		
		WHERE 
			CareTeamMembers.UserId = @i_AppUserId
		AND	DiseaseMeasure.DiseaseID = @i_DiseaseId 
		AND ( UserMeasure.MeasureId = @i_MeasureId OR ( @i_MeasureId IS NULL AND UserMeasure.MeasureId = @i_Measure ))
		AND (
				(
					( UserMeasure.DateTaken BETWEEN @d_FromDate AND @d_ToDate )
					AND (
						  @d_FromDate IS NOT NULL
						  AND @d_ToDate IS NOT NULL
						)
				)
				OR (
					 @d_FromDate IS NULL
					 AND @d_ToDate IS NULL
				   )
			  )
	ELSE 
		INSERT INTO #PatientMeasures
		(
			PatientUserId ,
			DateTaken ,
			MeasureRange ,
			MeasureId ,
			MeasureName
		)
		SELECT 
			UserMeasure.PatientUserId ,
			UserMeasure.DateTaken ,
			UserMeasureRange.MeasureRange,
			UserMeasure.MeasureId,
			Measure.Name AS MeasureName
		FROM
			DiseaseMeasure
		INNER JOIN UserMeasure
			ON UserMeasure.MeasureId = DiseaseMeasure.MeasureId
			AND DiseaseMeasure.StatusCode = 'A'
		INNER JOIN UserMeasureRange
			ON UserMeasureRange.UserMeasureID = UserMeasure.UserMeasureID 
		INNER JOIN Measure
			ON UserMeasure.MeasureId = Measure.MeasureId
			AND Measure.StatusCode ='A'
		INNER JOIN Patients
			ON Patients.UserID = UserMeasure.PatientUserId
		WHERE 
			DiseaseMeasure.DiseaseID = @i_DiseaseId 
		AND ( UserMeasure.MeasureId = @i_MeasureId OR ( @i_MeasureId IS NULL AND UserMeasure.MeasureId = @i_Measure ))
		AND (
				(
					( UserMeasure.DateTaken BETWEEN @d_FromDate AND @d_ToDate )
					AND (
						  @d_FromDate IS NOT NULL
						  AND @d_ToDate IS NOT NULL
						)
				)
				OR (
					 @d_FromDate IS NULL
					 AND @d_ToDate IS NULL
				   )
			)
			  
	SELECT
		MeasureId ,
		MeasureName ,
		CAST ( CONVERT (VARCHAR(10), DateTaken,  121)  AS DATE) AS DateTaken ,
		SUM(CASE WHEN MeasureRange = 'Good'
					 THEN 1
				 ELSE 0
			END) AS Good ,
		SUM(CASE WHEN MeasureRange = 'Fair'
					 THEN 1
				 ELSE 0
			END) AS Fair ,    	 	
		SUM(CASE WHEN MeasureRange = 'Poor'
					 THEN 1
				 ELSE 0
			END) AS Poor ,
		SUM(CASE WHEN MeasureRange = 'Undefined'
					 THEN 1
				 ELSE 0
			END) AS Undefined 
	FROM 
		#PatientMeasures
	WHERE DateTaken IS NOT NULL	
	GROUP BY 
		CAST ( CONVERT (VARCHAR(10), DateTaken,  121)  AS DATE),
		MeasureId,
		MeasureName
	ORDER BY 3 DESC	
	
	
	SELECT 
		MeasureId,
		MeasureName
	FROM
		#PatientMeasures
	UNION 
	SELECT DISTINCT
		Measure.MeasureId ,
		Measure.Name AS MeasureName
	FROM 
		DiseaseMeasure
	INNER JOIN Disease
		ON DiseaseMeasure.DiseaseId = Disease.DiseaseId
	INNER JOIN Measure
		ON DiseaseMeasure.MeasureId = Measure.MeasureId 
	WHERE
		Disease.DiseaseId = @i_DiseaseId
	AND DiseaseMeasure.StatusCode = 'A'	
    AND Measure.StatusCode ='A'
END TRY
------------------------------------------------------------------------------------------------------------------------- 
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID 
END CATCH
		
	                  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_CareProviderDashBoard_MyPatients_DiseaseView_TrendGraph] TO [FE_rohit.r-ext]
    AS [dbo];

