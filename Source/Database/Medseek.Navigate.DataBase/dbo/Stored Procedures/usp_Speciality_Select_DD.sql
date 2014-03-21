/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_Speciality_Select_DD  
Description   : This procedure is used to get the list of all Speciality for the Dropdown
Created By    : Ramachandra
Created Date  : 01-Mar-2011  
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
03-Mar-2011 NagaBabu Added SpecialityId to select statement  
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_Speciality_Select_DD]
(
 @i_AppUserId INT )
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
-------------------------------------------------------- 
      SELECT TOP 50
          CMSProviderSpecialtyCodeID SpecialityId ,
          ProviderSpecialtyName SpecialityName 
      FROM
          CodeSetCMSProviderSpecialty
      WHERE
          StatusCode = 'A'
      
END TRY  
--------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Speciality_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

