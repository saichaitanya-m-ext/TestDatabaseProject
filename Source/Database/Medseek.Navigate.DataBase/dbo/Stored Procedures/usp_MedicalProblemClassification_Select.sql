/*  
---------------------------------------------------------------------------------  
Procedure Name: [dbo].[usp_MedicalProblemClassification_Select]  
Description   : This procedure is used to get the records from MedicalProblemClassification table  
Created By    : NagaBabu  
Created Date  : 18-May-2010  
----------------------------------------------------------------------------------  
Log History   :   
DD-Mon-YYYY  BY  DESCRIPTION  
05-Aug-2010 NagaBabu Added isPatientViewable field in the Select statement 
27-Sep-2010 NagaBabu Added ORDER BY clause to this sp
----------------------------------------------------------------------------------  
*/  
  
CREATE PROCEDURE [dbo].[usp_MedicalProblemClassification_Select]
( @i_AppUserId KEYID,  
  @i_MedicalProblemClassificationId KEYID = NULL,  
  @v_StatusCode StatusCode = NULL  
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
---------------- All the MedicalProblemClassification records are retrieved here--------  
      SELECT   
		  MedicalProblemClassificationId,
		  ProblemClassName,
		  Description,
		  CASE StatusCode 
		      WHEN 'A' THEN 'Active'
		      WHEN 'I' THEN 'InActive'
		      ELSE ''
		  END AS StatusDescription,
		  CreatedByUserId,
		  CreatedDate,
		  LastModifiedByUserId,
		  LastModifiedDate,
		  isPatientViewable
      FROM  
          MedicalProblemClassification
      WHERE   
          ( MedicalProblemClassificationId = @i_MedicalProblemClassificationId OR @i_MedicalProblemClassificationId IS NULL)  
      AND ( StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )  
      ORDER BY
           CreatedDate DESC
       
END TRY  
BEGIN CATCH  
  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_MedicalProblemClassification_Select] TO [FE_rohit.r-ext]
    AS [dbo];

