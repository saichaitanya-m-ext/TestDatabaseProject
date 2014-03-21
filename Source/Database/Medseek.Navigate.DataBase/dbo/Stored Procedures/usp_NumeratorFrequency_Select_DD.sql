/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_NumeratorFrequency_Select_DD]
Description   : This Procedure used to provide NumeratorFrequencyName,NumeratorFrequencyNumber  for dropdown
Created By    : P.V.P.Mohan
Created Date  : 22-Nov-2012
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------        
*/  
CREATE PROCEDURE [dbo].[usp_NumeratorFrequency_Select_DD]--23,'T'
(  
 @i_AppUserId KEYID,
 @vc_Frequency varchar(1)
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
--------------------------------------------------------------------

 IF @vc_Frequency = 'F'
 BEGIN
	  SELECT  
           NumeratorFrequencyId,  
		   Description
      FROM  
          NumeratorFrequency  
    
      WHERE  Frequency = @vc_Frequency
	       

END
ELSE IF @vc_Frequency = 'T'	
		 BEGIN
      SELECT  
           NumeratorFrequencyId,  
		   Description
      FROM  
           NumeratorFrequency  

      WHERE  Frequency = @vc_Frequency

END
			
		
END TRY        
---------------------------------------------------------------------   
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_NumeratorFrequency_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

