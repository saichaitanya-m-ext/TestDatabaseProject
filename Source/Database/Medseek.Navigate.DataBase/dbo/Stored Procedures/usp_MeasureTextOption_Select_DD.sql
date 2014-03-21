/*          
----------------------------------------------------------------------------------          
Procedure Name: [usp_MeasureTextOption_Select_DD]  
Description   : This Procedure is used to select MeasureTextOption values
Created By    : NagaBabu
Created Date  : 25-July-2011
----------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
----------------------------------------------------------------------------------          
*/      
      
create PROCEDURE [dbo].[usp_MeasureTextOption_Select_DD]  
( 
    @i_AppUserId KEYID
)
AS      
BEGIN TRY      
      SET NOCOUNT ON      
      DECLARE @i_numberOfRecordsSelected INT           
                
      ----- Check if valid Application User ID is passed--------------          
      IF ( @i_AppUserId IS NULL )      
      OR ( @i_AppUserId <= 0 )      
         BEGIN      
               RAISERROR ( N'Invalid Application User ID %d passed.' ,      
               17 ,      
               1 ,      
               @i_AppUserId )      
         END          
   --------- Selecting data from the MeasureText ----------------          
   
    SELECT 
		MeasureTextOptionId,
		MeasureTextOption
	FROM 
		MeasureTextOption
	WHERE
		StatusCode = 'A'	 
		
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
    ON OBJECT::[dbo].[usp_MeasureTextOption_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

