/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_HealthCareQualityMeasure_GenerateCustomNrDr]  
Description   : This procedure is used to Calculate the NrDr values and   
                update the NrDr values in HealthCareQualityMeasure.  
Created By    : Rathnam   
Created Date  : 25-Aug-2010  
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
26-Aug-2010 Rathnam Enhanced the update statement.
11-Nov-2010 Rathnam added NULLIF functions while caliculating the @d_NrPercent, @d_DrPercent
22-Nov-10 Pramod Modified the NumeratorCriteriaSQL to append the DenominatorCriteriaSQL also
			as Nr data is always part of Dr data
09-Dev-2011 Rathnam added HealthCareQualityMeasureNumeratorUser,HealthCareQualityMeasureNumeratorUser tables
                    and their functionality	
09-dec-2011  sivakrishna changed the condition for restrict the duplicate Nrdr Records	
19-Jan-2012 NagaBabu Modified derivation of @nv_FullNrSQL,@nv_FullDrSQL Variables as per the changes in
						HealthCareQualityMeasureNrDrDefinition table.
30-Jan-2012 NagaBabu Modofoed Where clause for @nv_DrWhereClause,@nv_NrWhereClause variables
20-Feb-2012 NagaBabu Changed @nv_FullNrSQL Concatanate querry
21-Mar-2012 NagaBabu removed @nv_PrefixNrSQL,@nv_PrefixDrSQL  variables and dependent Querries
------------------------------------------------------------------------------------------- 
*/  
CREATE PROCEDURE [dbo].[usp_HealthCareQualityMeasure_GenerateCustomNrDr]--23,180
(
 @i_AppUserId KEYID ,
 @i_HealthCareQualityMeasureID KEYID )
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

      IF
      ( SELECT
            IsCustom
        FROM
            HealthCareQualityMeasure
        WHERE
            HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID ) = 1
         BEGIN
               CREATE TABLE #tmpUserNrCount
               (
                 NCount INT )
               CREATE TABLE #tmpUserDrCount
               (
                 DCount INT )
                 
               CREATE TABLE #tmpUserNrUsers
               (
               PatientUserID INT
               )
			   CREATE TABLE #tmpUserDrUsers
               (
               PatientUserID INT
               )
			   
               DECLARE
                       --@nv_PrefixNrSQL NVARCHAR(500) = 'INSERT INTO #tmpUserNrCount(NCount)  SELECT COUNT(Patients.UserId) FROM Patients ' ,
                       --@nv_PrefixDrSQL NVARCHAR(500) = 'INSERT INTO #tmpUserDrCount(DCount)  SELECT COUNT(Patients.UserId) FROM Patients ' ,
                       @nv_PrefixNrUsersSQL NVARCHAR(500) = 'INSERT INTO #tmpUserNrUsers(PatientUserID)  SELECT Patients.UserId FROM Patients ' ,
                       @nv_PrefixDrUsersSQL NVARCHAR(500) = 'INSERT INTO #tmpUserDrUsers(PatientUserID)  SELECT Patients.UserId FROM Patients ' ,
                       @nv_CriteriaNrSQL NVARCHAR(MAX) = '' ,
                       @nv_CriteriaDrSQL NVARCHAR(MAX) = '' ,
                       @nv_FullNrSQL NVARCHAR(MAX) = '' ,
                       @nv_FullDrSQL NVARCHAR(MAX) = '' ,
                       @nv_FullNrSQL1 NVARCHAR(MAX) = '' ,
                       @i_NrCount INT ,
                       @I_DrCount INT ,
                       @d_NrPercent DECIMAL(10,2) ,
                       @d_DrPercent DECIMAL(10,2)

               DECLARE @nv_DrJoinAndOnclause NVARCHAR(MAX) = '' ,
					   @nv_DrWhereClause  NVARCHAR(MAX) = '' ,
					   @nv_DrConditionalStatement NVARCHAR(MAX) = ''
						
			  SELECT
				  @nv_DrJoinAndOnclause = @nv_DrJoinAndOnclause + ' ' + ISNULL(JoinType , '') + ISNULL(JoinStatement , '') + ISNULL(OnClause , ''),
				  @nv_DrWhereClause = rtrim(ltrim(@nv_DrWhereClause + CASE
														 WHEN WhereClause IS NULL  THEN ''
														 WHEN WhereClause = '' THEN ''
														 ELSE 'AND ' + WhereClause
														 END + ' '))
			  FROM
				  HealthCareQualityMeasureNrDrDefinition
			  WHERE
				  HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
			  AND NrDrIndicator = 'D'	
			  
			  IF @nv_DrJoinAndOnclause IS NOT NULL OR @nv_DrJoinAndOnclause <> ''
			  	  SELECT
					  --@nv_DrConditionalStatement = @nv_DrJoinAndOnclause + ' ' + CASE WHEN LEN(@nv_DrWhereClause) > 0  THEN ' WHERE ' + SUBSTRING(REPLACE(@nv_DrWhereClause , ' WHERE ' , '') , 5 , LEN(@nv_DrWhereClause)) ELSE '' END
					   @nv_DrConditionalStatement = @nv_DrJoinAndOnclause + ' ' + CASE WHEN LEN(@nv_DrWhereClause) > 0  THEN ' WHERE ' + SUBSTRING(@nv_DrWhereClause , 5 , LEN(@nv_DrWhereClause)) ELSE '' END
			  ELSE 
				  
			  
			  IF (@nv_DrConditionalStatement IS NOT NULL OR @nv_DrConditionalStatement <> '')
				 BEGIN
					   SET @nv_FullDrSQL = @nv_CriteriaDrSQL + ' ' + @nv_PrefixDrUsersSQL + ' ' + @nv_DrConditionalStatement
					   PRINT @nv_FullDrSQL
					   EXEC ( @nv_FullDrSQL )
				 END  
			  
	   --------------------------------------------------------------------------------------------------------
              DECLARE @nv_NrJoinAndOnclause NVARCHAR(MAX) = '' ,
					   @nv_NrWhereClause  NVARCHAR(MAX) = '' ,
					   @nv_NrConditionalStatement NVARCHAR(MAX) = ''
						
			  SELECT
				  @nv_NrJoinAndOnclause = @nv_NrJoinAndOnclause + ' ' + ISNULL(JoinType , '') + ISNULL(JoinStatement , '') + ISNULL(OnClause , ''),
				  @nv_NrWhereClause = rtrim(ltrim(@nv_NrWhereClause + CASE
														 WHEN WhereClause IS NULL  THEN ''
														 WHEN WhereClause = '' THEN ''
														 ELSE 'AND ' + WhereClause
														 END + ' '))
			  FROM
				  HealthCareQualityMeasureNrDrDefinition 
			  WHERE
				  HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
			  AND NrDrIndicator = 'N'	   
               
              SELECT
				  --@nv_NrConditionalStatement = @nv_NrJoinAndOnclause + ' ' + CASE WHEN LEN(@nv_NrWhereClause) > 0  THEN ' WHERE ' + SUBSTRING(REPLACE(@nv_NrWhereClause , ' WHERE ' , '') , 5 , LEN(@nv_NrWhereClause)) ELSE '' END
				  @nv_NrConditionalStatement = @nv_NrJoinAndOnclause + ' ' + CASE WHEN LEN(@nv_NrWhereClause) > 0  THEN ' WHERE ' + SUBSTRING(@nv_NrWhereClause, 5 , LEN(@nv_NrWhereClause)) ELSE '' END
			  
			  IF (@nv_NrConditionalStatement IS NOT NULL OR @nv_NrConditionalStatement <> '')
				 BEGIN
					   SET @nv_FullNrSQL = @nv_CriteriaNrSQL + ' ' + @nv_PrefixNrUsersSQL + ' ' + @nv_NrConditionalStatement
					   PRINT @nv_FullNrSQL
					   EXEC ( @nv_FullNrSQL )
				 END  
			  
			
			IF (@nv_DrConditionalStatement IS NOT NULL OR @nv_DrConditionalStatement <> '')
				   BEGIN
					   SET @nv_FullDrSQL = @nv_CriteriaDrSQL + ' ' + @nv_PrefixDrUsersSQL + ' ' + @nv_DrConditionalStatement
					   PRINT @nv_FullDrSQL
					   EXEC ( @nv_FullDrSQL )
				   END	   
			
			
			CREATE TABLE #NumeratorUsers
            (
			  PatientUserID INT
            )				
			
			INSERT INTO #NumeratorUsers
			SELECT TDU.PatientUserID
			FROM #tmpUserNrUsers TNU
			INNER JOIN #tmpUserDrUsers TDU
				ON TNU.PatientUserID = TDU.PatientUserID
			SELECT * FROM 	#NumeratorUsers
               SELECT
                   @i_NrCount = COUNT(PatientUserID)
               FROM
                   #NumeratorUsers
               SELECT
                   @i_DrCount = COUNT(PatientUserID)
               FROM
                   #tmpUserDrUsers

               SET @d_NrPercent = ( @i_NrCount * 100.00 ) / ( NULLIF((@i_NrCount + @i_DrCount),0) )
               SET @d_DrPercent = ( @i_DrCount * 100.00 ) / ( NULLIF((@i_NrCount + @i_DrCount),0) )  
----------------- Update Operation Takes place-------------------------------------  
				
			   DECLARE @l_TranStarted BIT = 0
			   IF( @@TRANCOUNT = 0 )  
			   BEGIN
					BEGIN TRANSACTION
					SET @l_TranStarted = 1  -- Indicator for start of transactions
			   END
			   ELSE
					SET @l_TranStarted = 0  
			   
			 UPDATE
                   HealthCareQualityMeasure
               SET
                   NumeratorCount = @i_NrCount ,
                   DenominatorCount = @i_DrCount ,
                   NumeratorValue = @d_NrPercent ,
                   DenominatorValue = @d_DrPercent
               WHERE
                   HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
                   
               DELETE FROM HealthCareQualityMeasureNumeratorUser
               WHERE HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
               
               DELETE FROM HealthCareQualityMeasureDenominatorUser
               WHERE HealthCareQualityMeasureID = @i_HealthCareQualityMeasureID
               
                            
               INSERT INTO HealthCareQualityMeasureDenominatorUser
					   (
						HealthCareQualityMeasureID,
						PatientUserID,
						ProviderUserID,
						CreatedByUserId,
						CreatedDate
					   )
					   SELECT 
						   @i_HealthCareQualityMeasureID,
						   dr.PatientUserID,
						    (SELECT TOP 1 ISNULL(Users.DefaultTaskCareProviderId,CareTeamMembers.UserId)   
							 FROM CareTeamMembers  
							 INNER JOIN Users  
							  ON CareTeamMembers.CareTeamId = Users.CareTeamId  
							 WHERE Users.UserId = dr.PatientUserID  
							 AND CareTeamMembers.IsCareTeamManager = 1   
							 AND CareTeamMembers.StatusCode = 'A' ), 
						   @i_AppUserId,
						   GETDATE()
					   FROM #tmpUserDrUsers dr
				   
                INSERT INTO HealthCareQualityMeasureNumeratorUser
					   (
						HealthCareQualityMeasureID,
						PatientUserID,
						ProviderUserID,
						CreatedByUserId,
						CreatedDate
					   )
					   SELECT 
						   @i_HealthCareQualityMeasureID,
						   nr.PatientUserID,
						   (SELECT TOP 1 ISNULL(Users.DefaultTaskCareProviderId,CareTeamMembers.UserId)   
							 FROM CareTeamMembers  
							 INNER JOIN Users  
							  ON CareTeamMembers.CareTeamId = Users.CareTeamId  
							 WHERE Users.UserId = nr.PatientUserID  
							 AND CareTeamMembers.IsCareTeamManager = 1   
							 AND CareTeamMembers.StatusCode = 'A' ),
						   @i_AppUserId,
						   GETDATE()
					   FROM #NumeratorUsers nr
					  
				 IF( @l_TranStarted = 1 )  -- If transactions are there, then commit
					BEGIN
	   				   SET @l_TranStarted = 0
					   COMMIT TRANSACTION 
					END
                  
         END
END TRY
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthCareQualityMeasure_GenerateCustomNrDr] TO [FE_rohit.r-ext]
    AS [dbo];

