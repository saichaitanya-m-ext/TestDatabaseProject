/*
---------------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_Communication_MessageContent_Template]
Description	  : This procedure is used to get the message content for particular user
Created By    :	Santosh
Created Date  : 08-August-2013
----------------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY	BY	    DESCRIPTION
   [usp_Communication_MessageContent_Template] 2,349,4010,null,null,null
----------------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_Communication_MessageContent_Template]
(
 @i_AppUserId KEYID
,@i_CommunicationTemplateId KEYID
,@i_UserID KEYID
,@v_EmailIdPrimary EMAILID OUT
,@v_SubjectText VARCHAR(200) OUT
,@v_CommunicationText NVARCHAR(MAX) OUT

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
           --SELECT @v_TokenString

                  IF ( CHARINDEX(@v_TokenString , @v_CommunicationText , 1) >= 1 )
                  OR @v_TokenString = '[Email ID Primary]'
                     BEGIN
         

                           IF CHARINDEX('*' , @v_SQLString) = 0
                              BEGIN  
                              
                                    SET @v_SQLString = REPLACE(@v_SQLString , '?' , CONVERT(VARCHAR , @i_UserId))   

                                    INSERT INTO
                                        @tblToken
                                       --SELECT @v_SQLString 
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

     SELECT @v_CommunicationText AS CommunicationText
      
END TRY
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Communication_MessageContent_Template] TO [FE_rohit.r-ext]
    AS [dbo];

