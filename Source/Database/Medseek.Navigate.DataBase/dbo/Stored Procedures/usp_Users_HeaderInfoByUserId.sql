/*  
---------------------------------------------------------------------------------  
Procedure Name: [Usp_Users_HeaderInfoByUserId]  23,64
Description   : This procedure is used to select users header info based on userid  
Created By    : Pramod   
Created Date  : 21-Apr-2010  
---------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
14-Oct-10 Pramod modified the fullname to show last name, first name and middle name
01-Mar-2011 NagaBabu Added UPPER Funtionality to UserName and added UserNameSuffix,'. ',', ' to the UserName field
---------------------------------------------------------------------------------  
*/  
CREATE PROCEDURE [dbo].[usp_Users_HeaderInfoByUserId]
       @i_AppUserId KEYID ,  
       @i_UserId KEYID = NULL  
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
   
-------- Select the details from Users table --------------------------  
  
      SELECT  
          Users.FullName UserLoginName,  
          UPPER(COALESCE(ISNULL(Users.LastName , '') + ', '     
			+ ISNULL(Users.FirstName , '') + '. '     
			+ ISNULL(Users.MiddleName , '') + ' '
			+ ISNULL(Users.NameSuffix , '' )    
			 ,'')) AS FullName,  
		  GETDATE() StartDate,
          Users.Gender,  
          DATEDIFF( YEAR, Users.DateOfBirth, GETDATE()) AS Age,  
          Users.MemberNum ,
          Users.PrimaryPhoneNumber PhoneNumberPrimary,
		  Users.PrimaryPhoneNumberExtension PhoneNumberExtensionPrimary ,
		  Users.DateOfBirth,
		  Users.SecondaryPhoneNumber PhoneNumberAlternate,
		  Users.PrimaryEmailAddress EmailIdPrimary,
		  '' AS IPA,
		  '' AS Verisk
      FROM  
          Patients  Users
      WHERE  
          Users.PatientID = @i_UserId  
  
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Users_HeaderInfoByUserId] TO [FE_rohit.r-ext]
    AS [dbo];

