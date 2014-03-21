
--select * from CodeSetProcedure

--select * from LkUpCodeType

/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_CodeSetProcedure_SelectByProcedureCode]2
Description   : This procedure is used for drop down from CodeSetProcedure table    
Created By    : NagaBabu
Created Date  : 02-May-2011
------------------------------------------------------------------------------      
Log History   :      
DD-MM-YYYY  BY   DESCRIPTION 
11-Dec-2012 Mohan Removed statuscode 
20-Mar-2013 P.V.P.Mohan modified  CodeSetProcedure table and userProcedureFrequency to PatientProcedureFrequency
			and modified columns.
21-MAy-2013 P.V.P.Mohan modified   CodeSetProcedure(CodeTypeID) initially it was  ProcedureCodeType.
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_CodeSetProcedure_SelectByProcedureCode]
(
  @i_AppUserId KEYID,
  @i_ProcedureCodeType INT = NULL,
  @vc_CPTCoderORDescription SHORTDESCRIPTION = NULL ,
  @i_PatientUserId KEYID = NULL
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
          CSP.ProcedureCodeID ProcedureId
         ,CSP.ProcedureCode 
         ,CSP.ProcedureName AS ProcedureDescription 
         ,CSP.LeadtimeDays
         ,UPF.ExclusionReason
      FROM
          CodeSetProcedure CSP  WITH (NOLOCK) 
      LEFT OUTER JOIN PatientProcedureFrequency UPF  WITH (NOLOCK) 
		  ON CSP.ProcedureCodeID = UPF.ProcedureId 
		  AND ( UPF.PatientId = @i_PatientUserId OR @i_PatientUserId IS NULL )    
      WHERE
           --CSP.StatusCode = 'A'       
       --AND 
       (CodeTypeID = @i_ProcedureCodeType OR @i_ProcedureCodeType IS NULL)	   
       AND 
       (ProcedureCode + ' - ' + ProcedureName LIKE '%' + @vc_CPTCoderORDescription + '%' OR @vc_CPTCoderORDescription IS NULL)
          
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
    ON OBJECT::[dbo].[usp_CodeSetProcedure_SelectByProcedureCode] TO [FE_rohit.r-ext]
    AS [dbo];

