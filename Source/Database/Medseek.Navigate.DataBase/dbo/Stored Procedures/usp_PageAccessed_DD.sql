  
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PageAccessed_DD]  
Description   : This procedure is used to get the details of pages accessed by the patient  
Created By    : Chaitanya  
Created Date  : 12-Dec-2013  
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION     
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_PageAccessed_DD] (@i_AppUserId KEYID)  
AS  
BEGIN TRY  
 SET NOCOUNT ON  
  
 -- Check if valid Application User ID is passed      
 IF (@i_AppUserId IS NULL)  
  OR (@i_AppUserId <= 0)  
 BEGIN  
  RAISERROR (  
    N'Invalid Application User ID %d passed.'  
    , 17  
    , 1  
    , @i_AppUserId  
    )  
 END  
  
 SELECT DISTINCT PageName AS PGValue  
  , PageName AS PGText  
 FROM UserActivityLog  
 WHERE PatientID IS NOT NULL AND ActivityType <> '' and PageName <>'ErrorPage'  
 ORDER BY PGText
  
 SELECT DISTINCT ActivityType AS ActivityValue  
  , ActivityType AS ActivityText  
 FROM UserActivityLog  
 WHERE ActivityType <> '' and PageName <>'ErrorPage' and PatientID IS NOT NULL  
 ORDER BY ActivityText   
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
    ON OBJECT::[dbo].[usp_PageAccessed_DD] TO [FE_rohit.r-ext]
    AS [dbo];

