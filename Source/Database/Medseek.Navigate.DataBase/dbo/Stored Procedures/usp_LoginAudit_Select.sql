/*  
---------------------------------------------------------------------------------  
Procedure Name: [usp_LoginAudit_Select] 23
Description   : This procedure is used to get data from LoginAudit Table 
Created By    : NagaBabu
Created Date  : 21-July-2011
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
22-July-2011 NagaBabu Added order by clause
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_LoginAudit_Select]  
(
	@i_AppUserId KEYID
)
AS  
BEGIN TRY
      SET NOCOUNT ON   
-- Check if valid Application User ID is passed  
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END  
               
   SELECT   
            AuditId,
            LoginName,
            IPAddress,
            CASE LoginStatus
				WHEN 'S' THEN 'Success'
				WHEN 'L' THEN 'Lock'
				WHEN 'F' THEN 'Fail'
			END AS LoginStatus,
            LoginDate,
            L.Userid,
            P.LastName,
            P.FirstName,
            Logoutdate,
            Timeduration,
            Logouttype
        FROM  
            LoginAudit L
           LEFT JOIN Users U
            ON U.Userloginname = L.loginname 
           INNER JOIN UserGroup UG
            ON U.UserId = UG.UserID
           LEFT JOIN Provider P
            ON P.ProviderID = UG.ProviderID 
                  ORDER BY AuditId DESC   
      
END TRY
-----------------------------------------------------------------------------------------------------
BEGIN CATCH
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LoginAudit_Select] TO [FE_rohit.r-ext]
    AS [dbo];

