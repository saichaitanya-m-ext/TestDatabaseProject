
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_TaskBundlePatientEducationMaterial_Select]  1,1      
Description   : This procedure is used to get the library document for the taskbundle    
Created By    : Rathnam       
Created Date  : 22-Dec-2011
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
12/19/2013 prathyusha added lastmodified date column to the result set
------------------------------------------------------------------------------        
*/
CREATE PROCEDURE [dbo].[usp_TaskBundlePatientEducationMaterial_Select]
(
 @i_AppUserId KEYID
,@i_TaskBundleEducationMaterialID KEYID = NULL
,@i_TaskBundleId KEYID = NULL
)
AS
BEGIN
      BEGIN TRY
            SET NOCOUNT ON
       
           
 -- Check if valid Application User ID is passed        
            IF ( @i_AppUserId IS NULL )
            OR ( @i_AppUserId <= 0 )
               BEGIN
                     RAISERROR ( N'Invalid Application User ID %d passed.'
                     ,17
                     ,1
                     ,@i_AppUserId )
               END

            SELECT
                TaskBundleEducationMaterialId
               ,EducationMaterial.EducationMaterialID
               ,EducationMaterial.Name EducationMaterialName
               ,TaskBundleEducationMaterial.Comments AS Description
               ,TaskBundleEducationMaterial.StatusCode
               ,TaskBundleEducationMaterial.LastModifiedDate
            FROM
                TaskBundleEducationMaterial WITH(NOLOCK)
            INNER JOIN EducationMaterial WITH(NOLOCK)
                ON EducationMaterial.EducationMaterialID = TaskBundleEducationMaterial.EducationMaterialID
            WHERE
                TaskBundleEducationMaterialId = @i_TaskBundleEducationMaterialID



            SELECT DISTINCT
                l.LibraryId
               ,l.Name
            FROM
                TaskBundleEducationMaterial tbem WITH(NOLOCK)
            INNER JOIN EducationMaterialLibrary eml WITH(NOLOCK)
                ON eml.EducationMaterialID = tbem.EducationMaterialID
               AND eml.TaskBundleID = tbem.TaskBundleId 
            INNER JOIN Library l WITH(NOLOCK)
                ON l.LibraryId = eml.LibraryId
            WHERE
                tbem.TaskBundleEducationMaterialId = @i_TaskBundleEducationMaterialID
                AND tbem.TaskbundleId = @i_TaskBundleId
      END TRY        
--------------------------------------------------------         
      BEGIN CATCH        
    -- Handle exception        
            DECLARE @i_ReturnedErrorID INT
            EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

            RETURN @i_ReturnedErrorID
      END CATCH
END


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_TaskBundlePatientEducationMaterial_Select] TO [FE_rohit.r-ext]
    AS [dbo];

