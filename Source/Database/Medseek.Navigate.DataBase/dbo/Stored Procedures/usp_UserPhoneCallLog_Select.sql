/*        
------------------------------------------------------------------------------        
Procedure Name: usp_UserPhoneCallLog_Select        
Description   : This procedure is used to get the records from UserPhoneCallLog table.    
Created By    : Aditya        
Created Date  : 5-Apr-2010        
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
14-Oct-2010 Rathnam modified the careprovider column.        
21-Oct-10 Pramod Included new parameter @i_UserId and included in where clause
29-Dec-10 Rathnam added @b_IsCallPage parameter and added select statement with that condition.
20-Mar-2013 P.V.P.Mohan modified UserPhoneCallLog to PatientPhoneCallLog
			and modified columns.
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_UserPhoneCallLog_Select]
       (
        @i_AppUserId KEYID
       ,@i_CareProviderUserId KEYID = NULL
       ,@i_UserPhoneCallId KEYID = NULL
       ,@v_StatusCode STATUSCODE = NULL
       ,@i_UserId KEYID = NULL
       ,@b_IsCallPage ISINDICATOR = 0
       )
AS
BEGIN TRY
      SET NOCOUNT ON         
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )
      OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END
      IF (@b_IsCallPage = 0)
      SELECT
          PatientPhoneCallLog.PatientPhoneCallId UserPhoneCallId
         ,PatientPhoneCallLog.PatientId UserId
         ,PatientPhoneCallLog.CallDate
         ,PatientPhoneCallLog.Comments
         ,PatientPhoneCallLog.CareProviderUserId
         ,Patient.LastName + ' ' + Patient.FirstName AS CareProvider
         ,PatientPhoneCallLog.CreatedByUserId
         ,PatientPhoneCallLog.CreatedDate
         ,PatientPhoneCallLog.LastModifiedByUserId
         ,PatientPhoneCallLog.LastModifiedDate
         ,CASE PatientPhoneCallLog.StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
            ELSE ''
          END AS StatusDescription
         ,PatientPhoneCallLog.DueDate
      FROM
          PatientPhoneCallLog WITH(NOLOCK)
      INNER JOIN Patient WITH(NOLOCK)
          ON Patient.PatientID = PatientPhoneCallLog.CareProviderUserId
      WHERE
          (PatientPhoneCallLog.CareProviderUserId = @i_CareProviderUserId OR @i_CareProviderUserId IS NULL)
      AND ( PatientPhoneCallLog.PatientId = @i_UserId )
      AND (PatientPhoneCallLog.PatientPhoneCallId = @i_UserPhoneCallId OR @i_UserPhoneCallId IS NULL)
      AND (@v_StatusCode IS NULL OR PatientPhoneCallLog.StatusCode = @v_StatusCode)
      ORDER BY
          PatientPhoneCallLog.PatientPhoneCallId DESC
             --UserPhoneCallLog.CallDate DESC  


      IF ( @b_IsCallPage = 1 )

         SELECT TOP 10
             PatientPhoneCallLog.PatientPhoneCallId UserPhoneCallId
            ,PatientPhoneCallLog.PatientId UserId
            ,PatientPhoneCallLog.CallDate
            ,PatientPhoneCallLog.Comments
            ,PatientPhoneCallLog.CareProviderUserId
            ,Patient.LastName + ' ' + Patient.FirstName AS CareProvider
            ,PatientPhoneCallLog.CreatedByUserId
            ,PatientPhoneCallLog.CreatedDate
            ,PatientPhoneCallLog.LastModifiedByUserId
            ,PatientPhoneCallLog.LastModifiedDate
            ,CASE PatientPhoneCallLog.StatusCode
               WHEN 'A' THEN 'Active'
               WHEN 'I' THEN 'InActive'
               ELSE ''
             END AS StatusDescription
            ,PatientPhoneCallLog.DueDate
         FROM
             PatientPhoneCallLog WITH(NOLOCK)
         INNER JOIN Patient WITH(NOLOCK)
             ON Patient.UserId = PatientPhoneCallLog.CareProviderUserId
         WHERE
             (PatientPhoneCallLog.CareProviderUserId = @i_CareProviderUserId OR @i_CareProviderUserId IS NULL)
         AND (PatientPhoneCallLog.PatientId = @i_UserId )
         AND (PatientPhoneCallLog.PatientPhoneCallId = @i_UserPhoneCallId OR @i_UserPhoneCallId IS NULL)
         AND (@v_StatusCode IS NULL OR PatientPhoneCallLog.StatusCode = @v_StatusCode)
         AND PatientPhoneCallLog.CallDate IS NOT NULL
         ORDER BY
             PatientPhoneCallLog.PatientPhoneCallId DESC
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
    ON OBJECT::[dbo].[usp_UserPhoneCallLog_Select] TO [FE_rohit.r-ext]
    AS [dbo];

