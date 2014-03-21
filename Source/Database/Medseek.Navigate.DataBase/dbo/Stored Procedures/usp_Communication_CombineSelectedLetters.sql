/*      
------------------------------------------------------------------------------      
Procedure Name: usp_Communication_CombineSelectedLetters
Description   : This procedure is used to get the communication details for
    particular messges and corresponding letters
Created By    : Pramod  
Created Date  : 11-Aug-10  
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION 
23-Aug-2010 NagaBabu Added StatusCode = 'A' in  where clause to each select statement AND added MimeType      
10-Nov-10 Modified the SP to replace UNION ALL with UNION and changed the Select
9-March-11 Rathnam commented the UCM.CommunicationId IS NULL from 1st select statement.
22-Mar-2011 NagaBabu Deleted UNION and the next select statement as part of getting communicationtext and added  
						distinct key word to the select statement
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_Communication_CombineSelectedLetters]  
(
   @i_AppUserId KeyId,
   @i_UserId KeyId,
   @t_UserCommunicationId ttypeKeyID READONLY,
   @t_CommunicationId ttypeKeyID  READONLY
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

	DECLARE 
		@v_FullName VARCHAR(100),
		@v_EmailIdPrimary EmailId,
		@v_AddressLine1 Address,
		@v_AddressLine2 Address,
		@v_City City,
		@v_State State,
		@v_Last3AvgBloodPressure VARCHAR(120) = '',
		@v_LastA1C VARCHAR(120) = ''
		
	  SELECT @v_FullName = ISNULL(FullName,''),
			 @v_EmailIdPrimary = ISNULL(PrimaryEmailAddress,''),
			 @v_AddressLine1 = ISNULL(AddressLine1,''),
			 @v_AddressLine2 = ISNULL(AddressLine2,''),
			 @v_City = ISNULL(City,''),
			 @v_State = ISNULL(StateCode,'')
		FROM Patients 
       WHERE UserId = @i_UserId

	  SELECT TOP 1
			 @v_LastA1C = 
			 CASE
				WHEN PatientMeasure.MeasureValueText IS NULL 
					THEN CAST(PatientMeasure.MeasureValueNumeric AS VARCHAR(30)) 
							+ MeasureUOM.uomtext + ' Taken on ' 
							+ CONVERT(VARCHAR(10) , PatientMeasure.Datetaken , 101)
				ELSE PatientMeasure.MeasureValueText + ' Taken on ' 
					 + CONVERT(varchar(10) , PatientMeasure.Datetaken , 101)
			 END
	    FROM
		     PatientMeasure 
		      LEFT OUTER JOIN MeasureUOM
				 ON  PatientMeasure.MeasureUOMId = MeasureUOM.MeasureUOMId
	   WHERE
		     PatientMeasure.PatientID = @i_UserId
		 AND PatientMeasure.MeasureId 
		      = ( SELECT MeasureId
					FROM Measure
				   WHERE Name = 'A1C'
				 )
		 AND PatientMeasure.StatusCode = 'A' 		 
	  ORDER BY
		  PatientID,
		  DateTaken DESC
		  
	  -- Set to '' if it is NULL
	  SET @v_LastA1C = ISNULL(@v_LastA1c,'')

	SELECT DISTINCT UCM.CommunicationText
	  FROM PatientCommunication UCM
			INNER JOIN @t_UserCommunicationId TUCM
				ON UCM.PatientCommunicationId = TUCM.tKeyId
	 WHERE UCM.CommunicationState = 'Ready To Print'
	   AND UCM.StatusCode = 'A'
	   --AND UCM.CommunicationId IS NULL
	--UNION 
	--SELECT --CTM.CommunicationText
	--		REPLACE(
	--				   REPLACE(
	--					 REPLACE(
	--					   REPLACE(
	--						 REPLACE(
	--			 			   REPLACE(
	--							 REPLACE(
	--							   REPLACE(CTM.CommunicationText, 
	--							   '[FullName]', @v_FullName),
	--							 '[AddressLine1]',@v_AddressLine1),
	--						   '[AddressLine2]',@v_AddressLine2),
	--						 '[City]',@v_City),
	--					   '[State]',@v_State),
	--					 '[EmailIdPrimary]',@v_EmailIdPrimary),
	--				   '[LastA1C]',@v_LastA1C),
	--				 '[Last3AvgBloodPressure]',@v_Last3AvgBloodPressure)
	--  FROM Communication CM
	--		INNER JOIN @t_CommunicationId TCM
	--			ON CM.CommunicationId = TCM.tKeyId
	--		INNER JOIN CommunicationTemplate CTM
	--			ON CTM.CommunicationTemplateId = CM.CommunicationTemplateId
	-- WHERE CM.ApprovalState = 'Ready To Print'
	--   AND CM.StatusCode = 'A'
	--   AND CTM.StatusCode = 'A'	  

	-- List of attachments
	SELECT CTA.LibraryId,
		   LIB.Name,
		   LIB.MimeType
	  FROM PatientCommunication UCM
			INNER JOIN @t_UserCommunicationId TUCM
				ON UCM.PatientCommunicationId = TUCM.tKeyId
			INNER JOIN CommunicationTemplate CTM
				ON UCM.CommunicationTemplateId = CTM.CommunicationTemplateId
			INNER JOIN CommunicationTemplateAttachments CTA
				ON CTA.CommunicationTemplateId = CTM.CommunicationTemplateId
			INNER JOIN Library LIB
				ON LIB.LibraryId = CTA.LibraryId
	 WHERE UCM.CommunicationState = 'Ready To Print'
	   AND LIB.StatusCode = 'A'
	   AND UCM.StatusCode = 'A'
	   AND CTM.StatusCode = 'A'
	   AND UCM.CommunicationId IS NULL
	UNION
	SELECT CTA.LibraryId,
		   LIB.Name,
		   LIB.MimeType
	  FROM Communication CM
			INNER JOIN @t_CommunicationId TCM
				ON CM.CommunicationId = TCM.tKeyId
			INNER JOIN CommunicationTemplate CTM
				ON CTM.CommunicationTemplateId = CM.CommunicationTemplateId
			INNER JOIN CommunicationTemplateAttachments CTA
				ON CTA.CommunicationTemplateId = CTM.CommunicationTemplateId
			INNER JOIN Library LIB
				ON LIB.LibraryId = CTA.LibraryId
	 WHERE CM.ApprovalState = 'Ready To Print'
	   AND LIB.StatusCode = 'A'
	   AND CTM.StatusCode = 'A'  

END TRY  
--------------------------------------------------------       
BEGIN CATCH      
    -- Handle exception      
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_CombineSelectedLetters] TO [FE_rohit.r-ext]
    AS [dbo];

