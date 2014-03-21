/*    
---------------------------------------------------------------------------------------    
Procedure Name:  [usp_ValidateSQL_Statement] 
Description   :  This procedure is used for validate the sql statement
Created By    :  Rathnam
Created Date  :  07-June-2011
---------------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
    
---------------------------------------------------------------------------------------    
*/
CREATE PROCEDURE [dbo].[usp_ValidateSQL_Statement]
(
 @i_AppUserId KeyID ,
 @v_SqlStatement NVARCHAR(MAX)
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
    
     DECLARE @v_Sql NVARCHAR(MAX) = 'SELECT TOP 1  1 FROM patients ' + @v_SqlStatement
     EXEC (@v_Sql)
  
    
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    ---- Handle exception    
     SELECT ERROR_MESSAGE() AS ErrorMessage
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ValidateSQL_Statement] TO [FE_rohit.r-ext]
    AS [dbo];

