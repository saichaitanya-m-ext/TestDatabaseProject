/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Communication_MessageContent]
Description	  : This procedure is used to get the message content for particular user
Created By    :	Pramod
Created Date  : 14-May-2010
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY	BY	    DESCRIPTION
26-May-2010 Pramod  Separated the Email notification subject and content
				   Included logic for A1c
21-Nov-2011 Rathnam commented the existing comment and implemented dynamic tokens
22-Nov-2011 NagaBabu Added IF CHARINDEX(@v_CommunicationText, @v_TokenString) >= 1	
22-Nov-2011 Rathnam corrected the charindex function written by nagababu	
28-Nov-2011 NagaBabu Added IF (CHARINDEX(@v_TokenString,@v_CommunicationText,1) >= 1 OR @v_TokenString = '[Email ID Primary]')		   
----------------------------------------------------------------------------------------
*/--[usp_Communication_MessageContent_Siva] 23,122,367682,null,null,null,null,nullALTER PROCEDURE [dbo].[usp_Communication_MessageContent]
CREATE PROCEDURE [dbo].[usp_Communication_MessageContent]
(
 @i_AppUserId KEYID
,@i_CommunicationTemplateId KEYID
,@i_UserID KEYID
,@v_EmailIdPrimary EMAILID OUT
,@v_SubjectText VARCHAR(200) OUT
,@v_CommunicationText NVARCHAR(MAX) OUT
,@v_NotifySubjectText VARCHAR(200) OUT
,@v_NotifyCommunicationText NVARCHAR(MAX) OUT
)
AS
BEGIN TRY
      SET NOCOUNT ON
      DECLARE 
		--@v_SqlString VARCHAR(2000),
              @v_FullName VARCHAR(100)
             ,@v_AddressLine1 ADDRESS
             ,@v_AddressLine2 ADDRESS
             ,@v_City CITY
             ,@v_State STATE
             ,@v_Last3AvgBloodPressure VARCHAR(120) = ''
             ,@v_LastA1C VARCHAR(120) = ''

	-- Check if valid Application User ID is passed

      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

/*	  SELECT DISTINCT @v_SqlString = SQLString
	    FROM CommunicationTemplateToken
	   WHERE TagNameInTemplate = 'Patient'

	  IF @@ROWCOUNT > 0 
		  SET @v_SqlString
			 = @v_SqlString + ' @i_AppUserId = ' + CAST(@i_AppUserId AS VARCHAR(20))
			   + ' @i_UserId = ' + CAST(@i_UserId AS VARCHAR(20))
	  ELSE
		  SET @v_SqlString = ''

	  EXECUTE(@v_SqlString)
	  Need to convert the below code into dynamic SQL
	  
	  SELECT @v_FullName = COALESCE(ISNULL(FirstName,'') + ' ' + ISNULL(MiddleName,'') + ' ' + ISNULL(LastName,''), '') ,
			 @v_EmailIdPrimary = ISNULL(EmailIdPrimary,''),
			 @v_AddressLine1 = ISNULL(AddressLine1,''),
			 @v_AddressLine2 = ISNULL(AddressLine2,''),
			 @v_City = ISNULL(City,''),
			 @v_State = ISNULL(State,'')
		FROM Users 
       WHERE Users.UserId = @i_UserId

	  SELECT TOP 1
			 @v_LastA1C = 
			 CASE
				WHEN UserMeasure.MeasureValueText IS NULL 
					THEN CAST(UserMeasure.MeasureValueNumeric AS VARCHAR(30)) 
							+ MeasureUOM.uomtext + ' Taken on ' 
							+ CONVERT(VARCHAR(10) , UserMeasure.Datetaken , 101)
				ELSE UserMeasure.MeasureValueText + ' Taken on ' 
					 + CONVERT(varchar(10) , UserMeasure.Datetaken , 101)
			 END
	    FROM
		     UserMeasure 
		      LEFT OUTER JOIN MeasureUOM
				 ON  UserMeasure.MeasureUOMId = MeasureUOM.MeasureUOMId
	   WHERE
		     UserMeasure.PatientUserId = @i_UserId
		 AND UserMeasure.MeasureId 
		      = ( SELECT MeasureId
					FROM Measure
				   WHERE Name = 'A1c' 
				 )
	  ORDER BY
		  PatientUserId,
		  DateTaken DESC
		  
	  -- Set to '' if it is NULL
	  SET @v_LastA1C = ISNULL(@v_LastA1c,'')
*/
      SELECT
          @v_SubjectText = ISNULL(CommunicationTemplate.SubjectText , '')
         ,@v_CommunicationText = ISNULL(CommunicationTemplate.CommunicationText , '')
      FROM
          CommunicationTemplate
      WHERE
          CommunicationTemplate.CommunicationTemplateId = @i_CommunicationTemplateId
          AND CommunicationTemplate.StatusCode = 'A'

      DECLARE
              @v_SQLString VARCHAR(MAX)
             ,@v_TokenString VARCHAR(2000)

      DECLARE @tblToken TABLE
     (
        TokenString VARCHAR(1000)
     )


      DECLARE curHtmlText CURSOR
              FOR SELECT
                      TokenString
                     ,SQLString
                  FROM
                      CommunicationTemplateToken
                  WHERE
                      StatusCode = 'A'



      OPEN curHtmlText
      FETCH NEXT FROM curHtmlText INTO @v_TokenString,@v_SQLString
      
      WHILE @@FETCH_STATUS = 0
            BEGIN  -- Begin for cursor curHtmlText  


                  IF ( CHARINDEX(@v_TokenString , @v_CommunicationText , 1) >= 1 )
                  OR @v_TokenString = '[Email ID Primary]'
                     BEGIN
         

                           IF CHARINDEX('*' , @v_SQLString) = 0
                              BEGIN  
                                    SET @v_SQLString = REPLACE(@v_SQLString , '?' , CONVERT(VARCHAR , @i_UserId))   

                                    INSERT INTO
                                        @tblToken
                                        EXEC ( @v_SQLString )
                                    IF EXISTS ( SELECT
                                                    1
                                                FROM
                                                    @tblToken )
                                       BEGIN
                                             SET @v_CommunicationText = REPLACE(@v_CommunicationText , @v_TokenString , ( SELECT
                                                                                                                              ISNULL(TokenString , '')
                                                                                                                          FROM
                                                                                                                              @tblToken ))
                                       END
                                    ELSE
                                       BEGIN
                                             SET @v_CommunicationText = REPLACE(@v_CommunicationText , @v_TokenString , '')
                                       END
                                    IF @v_TokenString = '[Email ID Primary]'
                                       BEGIN

                                             SELECT
                                                 @v_EmailIdPrimary = TokenString
                                             FROM
                                                 @tblToken
                                       END
                              END
                     END
                  SET @v_SQLString = ''
                  DELETE  FROM
                          @tblToken

                  FETCH NEXT FROM curHtmlText INTO @v_TokenString,@v_SQLString
            END
      CLOSE curHtmlText
      DEALLOCATE curHtmlText

      SELECT
          @v_NotifySubjectText = ISNULL(NotifCommTemplate.SubjectText , '')
         ,@v_NotifyCommunicationText = ISNULL(NotifCommTemplate.CommunicationText , '')
      FROM
          CommunicationTemplate
      LEFT OUTER JOIN CommunicationTemplate NotifCommTemplate
          ON NotifCommTemplate.CommunicationTemplateId = CommunicationTemplate.NotifyCommunicationTemplateId
      WHERE
          CommunicationTemplate.CommunicationTemplateId = @i_CommunicationTemplateId
          AND CommunicationTemplate.StatusCode = 'A'
      
END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_MessageContent] TO [FE_rohit.r-ext]
    AS [dbo];

