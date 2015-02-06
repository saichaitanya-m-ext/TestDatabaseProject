/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_UserProcedureFrequencyOverride_Select]26,48,1  
Description   : This procedure is used for getting the UserProcedureFrequencyOverride
Created By    : Rathnam  
Created Date  : 24-Mar-2011  
----------------------------------------------------------------------------------  
Log History   : 
DD-Mon-YYYY  BY  DESCRIPTION 
2011-10-04 	Sivakrishna   Changed Case function  Day to Day(s),Week to week(s),month to Month(s),
07-Dec-2011 NagaBabu Added @b_NeverSchedule as input parameter and added this insert statements of UserProcedureFrequencyOverride
20-Mar-2013 P.V.P.Mohan modified UserProcedureFrequencyOverride to PatientProcedureFrequencyOverride
			and modified columns.
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_UserProcedureFrequencyOverride_Select] --42,1,26,230,null,null,null,'Day(s)',6,'6/25/2013'
	( 
	  @i_AppUserId KEYID,  
	  @i_UserID KEYID,  
	  @i_ProcedureID KEYID,
	  @i_ProgramID KeyID = NULL,
	  @v_ProgramFrequency VARCHAR(10) = NULL,
	  @i_ProgramFrequencyNumber KeyID = NULL,
	  @d_ProgramEffectiveStartDate UserDate = NULL,
	  @v_PatientProcFrequency VARCHAR(10) = NULL,
	  @i_PatientProcFrequencyNumber KEYID = NULL,
	  @d_PatientProcEffectiveStartDate UserDate = NULL,
	  @b_NeverSchedule BIT = 0
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
     
     DECLARE @v_GetPatientFequency VARCHAR(1)
     SET  @v_GetPatientFequency = CASE @v_PatientProcFrequency  
									WHEN  'Day(s)'   THEN 'D'
									WHEN  'Week(s)'  THEN 'W'
									WHEN  'Month(s)' THEN 'M' 
									WHEN  'Year(s)'  THEN 'Y'
								  END
								 
     IF @i_ProgramID IS NOT NULL 
		 BEGIN
		     IF NOT EXISTS (
		                    SELECT 
		                        1 
		                    FROM 
		                        PatientProcedureGroupFrequencyOverride 
		                    WHERE 
		                        PatientID = @i_UserID
		                    AND CodeGroupingID = @i_ProcedureID
		                    AND ProgramID = @i_ProgramID
		                    )
				 BEGIN   
				 
					 INSERT INTO 
						   PatientProcedureGroupFrequencyOverride
								   (
									PatientID
								   ,ProgramID
								   ,CodeGroupingID
								   ,FrequencyNumber
								   ,Frequency
								   ,EffectiveDate
								   ,CreatedByUserId
								   ,CreatedDate
								   ,StatusCode
								   ,ChangeType
								   ,NeverSchedule
			  					   )
							SELECT
								  @i_UserID,
								  @i_ProgramID,
								  @i_ProcedureID,
								  @i_ProgramFrequencyNumber,
								  CASE @v_ProgramFrequency  
									WHEN  'Day(s)'   THEN 'D'
									WHEN  'Week(s)'  THEN 'W'
									WHEN  'Month(s)' THEN 'M' 
									WHEN  'Year(s)'  THEN 'Y'
								  END AS Frequency,  
								  @d_ProgramEffectiveStartDate,
								  @i_AppUserId,
								  GETDATE(),
								  'A',
								  'Program',
								  @b_NeverSchedule
				END		
		END		      
		
		IF NOT EXISTS (
	                    SELECT 
	                        1 
	                    FROM 
	                        PatientProcedureGroupFrequencyOverride 
	                    WHERE 
	                        PatientID = @i_UserID
	                    AND CodeGroupingID = @i_ProcedureID
	                    AND FrequencyNumber = @i_PatientProcFrequencyNumber
	                    AND Frequency = @v_GetPatientFequency
	                  )
				 BEGIN  
					 INSERT INTO 
						   PatientProcedureGroupFrequencyOverride
								   (
									PatientID
								   ,CodeGroupingID
								   ,FrequencyNumber
								   ,Frequency
								   ,EffectiveDate
								   ,CreatedByUserId
								   ,CreatedDate
								   ,StatusCode
								   ,ChangeType
								   ,NeverSchedule
			  					   )
							SELECT
								  @i_UserID,
								  @i_ProcedureID,
								  @i_PatientProcFrequencyNumber,
								  @v_GetPatientFequency,  
								  @d_PatientProcEffectiveStartDate,
								  @i_AppUserId,
								  GETDATE(),
								  'A',
								  'Patient',
								  @b_NeverSchedule
				END	
		
		
			
      SELECT
          ROW_NUMBER() OVER (ORDER BY EffectiveDate)AS ProcOverride,   
		  upfo.CodeGroupingID ProcedureID,
		  upfo.PatientID UserID,
		  upfo.FrequencyNumber,
		  upfo.Frequency,
		  upfo.EffectiveDate,
		  upfo.ChangeType,
		  CASE upfo.ExclusionReason
				WHEN '' THEN 'Override'
				ELSE
				upfo.ExclusionReason
		  END AS ExclusionReason
      INTO #TEMP1		  
	  FROM  
		  PatientProcedureGroupFrequencyOverride upfo
	  WHERE   
		  upfo.PatientID = @i_UserID  
	  AND upfo.CodeGroupingID= @i_ProcedureID
	  
	  
	  SELECT 
          t1.ProcOverride, 
          t1.ProcedureID as CodeGroupingID,
		  t1.UserID,
		  t1.FrequencyNumber,
		  CASE t1.Frequency  
					WHEN 'D' THEN 'Day(s)'  
					WHEN 'W' THEN 'Week(s)'  
					WHEN 'M' THEN 'Month(s)'  
					WHEN 'Y' THEN 'Year(s)'
		  END AS Frequency,
		  CONVERT(VARCHAR,t1.EffectiveDate,101) AS EffectiveDate,
          ISNULL(DATEDIFF(DAY,t1.EffectiveDate, t2.EffectiveDate),0) AS ElapsedDays, 
          t1.ChangeType,t1.ExclusionReason
      
      FROM 
         #TEMP1 t1  
      LEFT OUTER JOIN #TEMP1 t2  
      ON t1.ProcOverride = t2.ProcOverride - 1 
      ORDER BY 1 DESC
     
END TRY  
-------------------------------------------------------------------------------------------------------
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_UserProcedureFrequencyOverride_Select] TO [FE_rohit.r-ext]
    AS [dbo];

