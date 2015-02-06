
/*          
------------------------------------------------------------------------------          
Procedure Name: usp_MedseekID_Select          
Description   : This procedure is used to get PatientPrimaryId based on PatientId  
Created By    : Rohith          
Created Date  : 17-Feb-2014          
------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          

------------------------------------------------------------------------------          
*/    
CREATE PROCEDURE [dbo].[usp_MedseekID_Select]  
(    
 @i_AppUserId KEYID ,
 @i_PatientUserId KEYID
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
             
----------- Select CareTeam details -------------------    
    
      SELECT    
		  PatientPrimaryId          
      FROM    
          Patient     WITH (NOLOCK) 
      WHERE  
      PatientID = @i_PatientUserId 
END TRY          
     
BEGIN CATCH          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH  
  