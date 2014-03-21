/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_MetricFrequencyUpdate]  
Description   : This proc is used to extract the data from CodeGroupers OR Hedis tables 
Created By    : Rathnam  
Created Date  : 28-June-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_MetricFrequencyUpdate] --1,20121130
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8) = NULL
	,@i_MetricID KEYID = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	-- Check if valid Application User ID is passed  
	IF (@i_AppUserId IS NULL)
		OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR (
				N'Invalid Application User ID %d passed.'
				,17
				,1
				,@i_AppUserId
				)
	END

	/*	
	UPDATE PatientNr
SET AggregationType = 'MX'
FROM (	

SELECT metricid,PatientID,DateKey,LastValue,LastValueDate FROM (
SELECT nc.metricid, nc.PatientID, nc.DateKey,LastValue,LastValueDate,
 ROW_NUMBER() OVER (
				PARTITION BY nc.metricid, nc.PatientID, nc.DateKey ORDER BY nc.LastValueDate DESC
 ) sno


  FROM PatientNr nc
  where nrtype = 'v'
) t
WHERE t.sno= 1 ) t
WHERE t.metricid = Patientnr.MetricId
AND t.PatientID = patientnr.PatientID
AND t.DateKey = patientnr.DateKey
AND t.LastValue = patientnr.LastValue
AND t.LastValueDate = patientnr.LastValueDate 
AND patientnr.NrType = 'V'
*/
	CREATE TABLE #PatientNr (
		MetricID INT
		,PatientID INT
		,DateKey INT
		,MetricNumeratorFrequencyId INT
		)

	INSERT INTO #PatientNr
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN PatientNr bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE bpn.NrType = 'V'
		AND
	(
		(bmnf.FromOperator = '=' AND bmnf.ToOperator IS NULL AND bpn.LastValue = bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator IS NULL AND bpn.LastValue < bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator IS NULL AND bpn.LastValue <= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>' AND bpn.LastValue < bmnf.FromFrequency  AND bpn.LastValue > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>=' AND bpn.LastValue <= bmnf.FromFrequency  AND bpn.LastValue >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>=' AND bpn.LastValue < bmnf.FromFrequency  AND bpn.LastValue >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>' AND bpn.LastValue <= bmnf.FromFrequency  AND bpn.LastValue > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator IS NULL AND bpn.LastValue > bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator IS NULL AND bpn.LastValue >= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<' AND bpn.LastValue > bmnf.FromFrequency  AND bpn.LastValue < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<=' AND bpn.LastValue >= bmnf.FromFrequency  AND bpn.LastValue <= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<' AND bpn.LastValue >= bmnf.FromFrequency  AND bpn.LastValue < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<=' AND bpn.LastValue > bmnf.FromFrequency  AND bpn.LastValue <= bmnf.ToFrequency)	
	)
	AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
	AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)
	
	INSERT INTO #PatientNr
	
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN PatientNr bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE bpn.NrType = 'V'
		AND bmnf.Label = 'NC'
		AND NOT EXISTS (
			SELECT 1
			FROM #PatientNr n
			WHERE n.PatientID = bpn.PatientID
				AND n.MetricID = bpn.MetricId
				AND n.DateKey = bpn.DateKey
		)
		AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)

	UPDATE PatientNr
	SET FrequencyID = t.MetricNumeratorFrequencyId
	FROM #PatientNr t
	WHERE t.MetricId = patientnr.MetricId
		AND t.PatientID = PatientNr.PatientID
		AND t.DateKey = PatientNr.DateKey
		AND PatientNr.NrType = 'V'
		AND (PatientNr.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (PatientNr.DateKey = @v_DateKey OR @v_DateKey IS NULL)

	DELETE
	FROM #PatientNr

	INSERT INTO #PatientNr
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN PatientNr bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE bpn.NrType = 'C'
	AND
	(
		(bmnf.FromOperator = '=' AND bmnf.ToOperator IS NULL AND bpn.Cnt = bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator IS NULL AND bpn.Cnt < bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator IS NULL AND bpn.Cnt <= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>' AND bpn.Cnt < bmnf.FromFrequency  AND bpn.Cnt > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>=' AND bpn.Cnt <= bmnf.FromFrequency  AND bpn.Cnt >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>=' AND bpn.Cnt < bmnf.FromFrequency  AND bpn.Cnt >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>' AND bpn.Cnt <= bmnf.FromFrequency  AND bpn.Cnt > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator IS NULL AND bpn.Cnt > bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator IS NULL AND bpn.Cnt >= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<' AND bpn.Cnt > bmnf.FromFrequency  AND bpn.Cnt < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<=' AND bpn.Cnt >= bmnf.FromFrequency  AND bpn.Cnt <= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<' AND bpn.Cnt >= bmnf.FromFrequency  AND bpn.Cnt < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<=' AND bpn.Cnt > bmnf.FromFrequency  AND bpn.Cnt <= bmnf.ToFrequency)	
	)
	AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
	AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)
	
	INSERT INTO #PatientNr
	
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN PatientNr bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE bpn.NrType = 'C'
		AND bmnf.Label = 'NC'
		AND NOT EXISTS (
			SELECT 1
			FROM #PatientNr n
			WHERE n.PatientID = bpn.PatientID
				AND n.MetricID = bpn.MetricId
				AND n.DateKey = bpn.DateKey
		)
		AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)

	UPDATE PatientNr
	SET FrequencyID = t.MetricNumeratorFrequencyId
	FROM #PatientNr t
	WHERE t.MetricId = patientnr.MetricId
		AND t.PatientID = PatientNr.PatientID
		AND t.DateKey = PatientNr.DateKey
		AND PatientNr.NrType = 'C'
		AND (PatientNr.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (PatientNr.DateKey = @v_DateKey OR @v_DateKey IS NULL)
		
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH
