/*          
----------------------------------------------------------------------------------------          
Procedure Name: usp_QuestionSet_Select_DD          
Description   : This procedure is used for the QuestionSet dropdown from the QuestionSet         
       table.          
Created By    : Aditya           
Created Date  : 11-Jan-2010          
-----------------------------------------------------------------------------------------          
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
          
-----------------------------------------------------------------------------------------          
*/        
        
CREATE PROCEDURE [dbo].[usp_QuestionSet_Select_DD]        
(        
 @i_AppUserId KEYID,    
 @i_QuestionSetId KEYID = NULL    
 )        
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
          
------------ Selection from QuestionSet table starts here ------------          
      SELECT        
          QuestionSetId,        
          QuestionSetName,        
          Description,  
          SortOrder       
      FROM        
          QuestionSet        
      WHERE        
          ( StatusCode = 'A')    
          AND ( QuestionSetId = @i_QuestionSetId or @i_QuestionSetId IS NULL )          
      ORDER BY        
          SortOrder,      
          QuestionSetName      
             
             
END TRY        
BEGIN CATCH          
          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT        
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException         
     @i_UserId = @i_AppUserId        
        
      RETURN @i_ReturnedErrorID        
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_QuestionSet_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

