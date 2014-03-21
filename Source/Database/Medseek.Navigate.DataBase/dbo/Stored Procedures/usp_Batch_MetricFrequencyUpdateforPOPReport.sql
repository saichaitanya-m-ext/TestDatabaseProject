/*  
---------------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_Batch_MetricFrequencyUpdateforPOPReport]  
Description   : This proc is used to extract the data from CodeGroupers OR Hedis tables 
Created By    : Rathnam  
Created Date  : 24-Dec-2013
----------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY DESCRIPTION  
----------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Batch_MetricFrequencyUpdateforPOPReport] --1,20121130
	(
	@i_AppUserId KEYID
	,@v_DateKey VARCHAR(8) = NULL
	,@i_MetricID KEYID = NULL
	)
AS
BEGIN TRY
	SET NOCount ON

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
	/*
	CREATE TABLE #NRPatientValue (
		MetricID INT
		,PatientID INT
		,DateKey INT
		,Value DECIMAL(10,2)
		,LastValueDate DATE
	)
	
	INSERT INTO #NRPatientValue
	SELECT Metricid,PatientID,DateKey,[Value],ValueDate FROM (
	SELECT  nv.metricid, nv.PatientID, nv.DateKey , nv.[Value], nv.ValueDate, ROW_NUMBER() OVER (
				PARTITION BY nv.metricid, nv.PatientID, nv.DateKey ORDER BY nv.ValueDate DESC
 ) sno FROM NRPatientValue nv
	WHERE (nv.DateKey = @v_DateKey OR @v_DateKey IS NULL)
	OR (nv.MetricID = @i_MetricID OR @i_MetricID IS NULL )
	) t WHERE t.sno=1
	*/
	
	CREATE TABLE #PatientNr (
		MetricID INT
		,PatientID INT
		,DateKey INT
		,MetricNumeratorFrequencyId INT
		,Value DECIMAL(10,2)
		,LastValueDate DATE
	)
	INSERT INTO #PatientNr
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
		,bpn.Value
		,bpn.ValueDate
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN NRPatientValue bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE 
	(
		(bmnf.FromOperator = '=' AND bmnf.ToOperator IS NULL AND bpn.Value = bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator IS NULL AND bpn.Value < bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator IS NULL AND bpn.Value <= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>' AND bpn.Value < bmnf.FromFrequency  AND bpn.Value > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>=' AND bpn.Value <= bmnf.FromFrequency  AND bpn.Value >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>=' AND bpn.Value < bmnf.FromFrequency  AND bpn.Value >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>' AND bpn.Value <= bmnf.FromFrequency  AND bpn.Value > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator IS NULL AND bpn.Value > bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator IS NULL AND bpn.Value >= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<' AND bpn.Value > bmnf.FromFrequency  AND bpn.Value < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<=' AND bpn.Value >= bmnf.FromFrequency  AND bpn.Value <= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<' AND bpn.Value >= bmnf.FromFrequency  AND bpn.Value < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<=' AND bpn.Value > bmnf.FromFrequency  AND bpn.Value <= bmnf.ToFrequency)	
	)
	AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
	AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)
	
	
	INSERT INTO #PatientNr
	
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
		,bpn.Value
		,bpn.ValueDate
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN NRPatientValue bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE 
		 bmnf.Label = 'NC'
	AND NOT EXISTS (
			SELECT 1
			FROM #PatientNr n
			WHERE n.PatientID = bpn.PatientID
				AND n.MetricID = bpn.MetricId
				AND n.DateKey = bpn.DateKey
				AND n.[Value] = bpn.[Value]
				AND n.LastValueDate = bpn.ValueDate
				
		)
		AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)
	

	UPDATE NRPatientValue
	SET FrequencyID = t.MetricNumeratorFrequencyId
	FROM #PatientNr t
	WHERE t.MetricId = NRPatientValue.MetricId
		AND t.PatientID = NRPatientValue.PatientID
		AND t.DateKey = NRPatientValue.DateKey
		AND (t.[Value] = NRPatientValue.[Value] OR NRPatientValue.[Value] IS NULL)
		AND t.LastValueDate = NRPatientValue.ValueDate 
		AND (NRPatientValue.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (NRPatientValue.DateKey = @v_DateKey OR @v_DateKey IS NULL)

	DELETE
	FROM #PatientNr

	
	CREATE TABLE #PatientNrCnt (
		MetricID INT
		,PatientID INT
		,DateKey INT
		,MetricNumeratorFrequencyId INT
		)
	
	INSERT INTO #PatientNrCnt
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN NRPatientCount bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE 
	(
		(bmnf.FromOperator = '=' AND bmnf.ToOperator IS NULL AND bpn.[Count] = bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator IS NULL AND bpn.[Count] < bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator IS NULL AND bpn.[Count] <= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>' AND bpn.[Count] < bmnf.FromFrequency  AND bpn.[Count] > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>=' AND bpn.[Count] <= bmnf.FromFrequency  AND bpn.[Count] >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<' AND bmnf.ToOperator = '>=' AND bpn.[Count] < bmnf.FromFrequency  AND bpn.[Count] >= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '<=' AND bmnf.ToOperator = '>' AND bpn.[Count] <= bmnf.FromFrequency  AND bpn.[Count] > bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator IS NULL AND bpn.[Count] > bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator IS NULL AND bpn.[Count] >= bmnf.FromFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<' AND bpn.[Count] > bmnf.FromFrequency  AND bpn.[Count] < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<=' AND bpn.[Count] >= bmnf.FromFrequency  AND bpn.[Count] <= bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>=' AND bmnf.ToOperator = '<' AND bpn.[Count] >= bmnf.FromFrequency  AND bpn.[Count] < bmnf.ToFrequency)
	OR	(bmnf.FromOperator = '>' AND bmnf.ToOperator = '<=' AND bpn.[Count] > bmnf.FromFrequency  AND bpn.[Count] <= bmnf.ToFrequency)	
	)
	AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
	AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)
	
	INSERT INTO #PatientNrCnt
	
	SELECT bpn.MetricId
		,bpn.PatientID
		,bpn.DateKey
		,bmnf.MetricNumeratorFrequencyId
	FROM MetricNumeratorFrequency bmnf
	INNER JOIN NRPatientCount bpn
		ON bmnf.MetricId = bpn.MetricId
	WHERE 
		 bmnf.Label = 'NC'
		AND NOT EXISTS (
			SELECT 1
			FROM #PatientNrCnt n
			WHERE n.PatientID = bpn.PatientID
				AND n.MetricID = bpn.MetricId
				AND n.DateKey = bpn.DateKey
		)
		AND (bpn.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (bpn.DateKey = @v_DateKey OR @v_DateKey IS NULL)

	UPDATE NRPatientCount
	SET FrequencyID = t.MetricNumeratorFrequencyId
	FROM #PatientNrCnt t
	WHERE t.MetricId = NRPatientCount.MetricId
		AND t.PatientID = NRPatientCount.PatientID
		AND t.DateKey = NRPatientCount.DateKey
		AND (NRPatientCount.MetricId = @i_MetricID OR @i_MetricID IS NULL)
		AND (NRPatientCount.DateKey = @v_DateKey OR @v_DateKey IS NULL)
		
		
END TRY

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------      
BEGIN CATCH
	-- Handle exception  
	DECLARE @i_ReturnedErrorID INT

	EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Batch_MetricFrequencyUpdateforPOPReport] TO [FE_rohit.r-ext]
    AS [dbo];

