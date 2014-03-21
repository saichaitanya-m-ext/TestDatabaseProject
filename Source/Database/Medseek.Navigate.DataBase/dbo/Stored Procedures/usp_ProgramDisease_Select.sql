/*        
---------------------------------------------------------------------------------------        
Procedure Name: [dbo].[Usp_ProgramDisease_Select]        
Description   : This procedure is used to select the data from ProgramDisease table         
    based on the  DiseaseId.         
Created By    : Aditya        
Created Date  : 21-Jan-2010        
----------------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
04-June-2010 NagaBabu added StatusCode field in select statement        
08-July-2010 Rathnam added ProgramDisease.StatusCode in select statement.    
27-July-2010 NagaBabu added CASE statement to the StatusCode field   
30-July-2010 NagaBabu Replaced Disease.StatusCode by ProgramDisease.StatusCode in Where clause
28-Sep-2011  Rathnam added LastModifiedby & LastModifiedDate column to the select statement      
----------------------------------------------------------------------------------------        
*/

CREATE PROCEDURE [dbo].[usp_ProgramDisease_Select]
(
 @i_AppUserId KEYID
,@i_ProgramId KEYID
,@i_ProgramDiseaseId KEYID = NULL
,@v_StatusCode STATUSCODE = NULL
)
AS
BEGIN TRY

      SET NOCOUNT ON         
 -- Check if valid Application User ID is passed        

      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )

         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      SELECT
          ProgramDisease.ProgramDiseaseId
         ,ProgramDisease.ProgramId
         ,ProgramDisease.DiseaseId
         ,CASE ProgramDisease.StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
            ELSE ' '
          END AS StatusCode
         ,Disease.Name AS DiseaseName
         ,Disease.Description
         ,ProgramDisease.CreatedByUserId
         ,ProgramDisease.CreatedDate
         ,CASE Disease.Statuscode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
            ELSE ' '
          END AS StatusDescription
         ,ProgramDisease.LastModifiedByUserId
         ,ProgramDisease.LastModifiedDate
      FROM
          ProgramDisease WITH(NOLOCK)
      INNER JOIN Disease WITH(NOLOCK)
          ON Disease.DiseaseId = ProgramDisease.DiseaseId
      WHERE
          ProgramId = @i_ProgramId
          AND ( ProgramDiseaseId = @i_ProgramDiseaseId
                OR @i_ProgramDiseaseId IS NULL
              )
          AND ( @v_StatusCode IS NULL
                OR ProgramDisease.StatusCode = @v_StatusCode
              )
END TRY
--------------------------------------------------------------------------------------------------
BEGIN CATCH        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_ProgramDisease_Select] TO [FE_rohit.r-ext]
    AS [dbo];

