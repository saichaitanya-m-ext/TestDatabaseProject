/*    
--------------------------------------------------------------------------------    
Procedure Name: [dbo].[Usp_InlineMeasure_Select]    
Description   : This procedure is used to select  all active records from Measure table.    
Created By    : NagaBabu  
Created Date  : 27-July-2011    
---------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
---------------------------------------------------------------------------------    
*/    
    
CREATE PROCEDURE [dbo].[Usp_InlineMeasure_Select] 
(  
  @i_AppUserId KEYID ,  
  @v_Measure VARCHAR(10) = NULL   
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
----------- Select all the active Measure details ---------------    
      SELECT    
          CAST(MeasureId AS VARCHAR) + ' - ' + CAST(IsTextValueForControls AS VARCHAR) AS TextValueForControls,    
          Name   
      FROM    
          Measure    
      WHERE    
			Measure.StatusCode = 'A'   
		AND IsSynonym = 0
		AND IsVital = 0
		AND (Name LIKE @v_Measure + '%'  
				OR @v_Measure IS NULL  
				OR @v_Measure = ''
			)      
      ORDER BY
          Measure.SortOrder,  
          Measure.Name  
  

END TRY    
BEGIN CATCH    
    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT    
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId    
    
      RETURN @i_ReturnedErrorID    
END CATCH  
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[Usp_InlineMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

