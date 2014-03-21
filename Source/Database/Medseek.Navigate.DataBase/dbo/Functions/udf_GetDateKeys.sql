
/*  
---------------------------------------------------------------------------------  
Function Name: [dbo].[udf_GetDateKeys]  
Description   : 
Created By    : Rathnam  
Created Date  : 16-Oct-2013
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
----------------------------------------------------------------------------------  
*/
CREATE FUNCTION [dbo].[udf_GetDateKeys] (
	@StartDate DATE
	,@EndDate DATE
	,@Period CHAR(1)
	)
RETURNS @output TABLE (DateKey INT)

BEGIN
	DECLARE @StartLoop INT = 1
		,@EndLoop INT
		,@ResultSet BIT = 0
		,@InsertDate DATE
	DECLARE @DateKeys TABLE (
		ID INT IDENTITY(1, 1) PRIMARY KEY
		,[Date] DATE
		,DateKey CHAR(8)
		)
	DECLARE @DateKeysResult TABLE (
		ID INT IDENTITY(1, 1) PRIMARY KEY
		,DateKey CHAR(8)
		)

	SET @InsertDate = CAST(YEAR(@StartDate) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(@StartDate) AS VARCHAR(2)), 2) + '01'

	WHILE @InsertDate <= @EndDate
	BEGIN
		DECLARE @ResultDate DATE

		SET @ResultDate = DATEADD(D, - 1, DATEADD(m, 1, @InsertDate))

		INSERT INTO @DateKeys (
			DATE
			,DateKey
			)
		SELECT @ResultDate
			,CAST(YEAR(@ResultDate) AS VARCHAR(4)) + RIGHT('0' + CAST(MONTH(@ResultDate) AS VARCHAR(2)), 2) + + RIGHT('0' + CAST(DAY(@ResultDate) AS VARCHAR(2)), 2)

		SET @InsertDate = DATEADD(M, 1, @InsertDate)
	END

	IF @Period = 'M'
		OR @Period IS NULL
	BEGIN
		INSERT INTO @DateKeysResult (DateKey)
		SELECT DateKey
		FROM @DateKeys dk

		SET @EndLoop = @@identity
	END

	IF @Period = 'Q'
	BEGIN
		INSERT INTO @DateKeysResult (DateKey)
		SELECT DateKey
		FROM @DateKeys dk
		WHERE month(dk.DATE) IN (
				3
				,6
				,9
				,12
				)

		SET @EndLoop = @@identity
	END

	IF @Period = 'H'
	BEGIN
		INSERT INTO @DateKeysResult (DateKey)
		SELECT DateKey
		FROM @DateKeys dk
		WHERE month(dk.DATE) IN (
				6
				,12
				)

		SET @EndLoop = @@identity
	END

	IF @Period = 'Y'
	BEGIN
		INSERT INTO @DateKeysResult (DateKey)
		SELECT DateKey
		FROM @DateKeys dk
		WHERE month(dk.DATE) = 12

		SET @EndLoop = @@identity
	END

	INSERT INTO @output
	SELECT DateKey
	FROM @DateKeysResult

	RETURN
END
