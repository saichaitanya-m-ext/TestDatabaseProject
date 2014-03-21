/*  
--------------------------------------------------------------------------------------  
Procedure Name: usp_OrganizationStatus_Select_DD  
Description   : This procedure is used to select all the organizations Status codes from   
				the OrganizationStatus table.  
Created By    : Aditya   
Created Date  : 09-Jan-2010  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
14-July-2010 NagaBabu Added 'NotRegistered' value in CASE statement for OrganizationStatusCode field 
08-June-2011 Gurumoorthy added Retired Status
---------------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_OrganizationStatus_Select_DD] @i_AppUserId KEYID  
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
  
------------ Selection from OrganizationStatus table table starts here ------------  
      SELECT  
          OrganizationStatusId,  
          Description,
          CASE OrganizationStatusCode
			   WHEN 'A' THEN 'Active'
		       WHEN 'I' THEN 'InActive'
		       WHEN 'U' THEN 'NotRegistered'
		       WHEN 'R' THEN 'Retired' 
		  END  AS OrganizationStatusCode
      FROM  
          OrganizationStatus 
      WHERE IsActive = 1
      ORDER BY Description
       
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_OrganizationStatus_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

