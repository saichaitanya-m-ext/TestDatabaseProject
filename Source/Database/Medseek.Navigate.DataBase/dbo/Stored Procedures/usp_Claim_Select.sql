/*          
-----------------------------------------------------------------------------------         
Procedure Name: usp_Claim_Select          
Description   : This procedure is used to select the data from Claim, UserrClaim   
    and CodeSetICD table.          
Created By    : Aditya           
Created Date  : 05-Apr-2010          
-----------------------------------------------------------------------------------       
Log History   :           
DD-MM-YYYY  BY   DESCRIPTION          
15-Apr-2011 NagaBabu Modified field names in resultset   
03-May-2011 Rathnam Removed the ICDCode & CPTCode their descriptions columns according   
                    to claim table  Modifications.  
04-April-2012 Rathnam removed the Claim table and modified the storedprocedure  
25-Mar-2013 P.V.P.MOhan Modified PatientID in place of UserID                  
-----------------------------------------------------------------------------------          
*/

CREATE PROCEDURE [dbo].[usp_Claim_Select]
(
 @i_AppUserId KEYID
,@i_UserId KEYID = NULL
,@v_StatusCode STATUSCODE = NULL
)
AS
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
          
             
---------Selection starts here -------------------        

      SELECT
          ci.ClaimInfoId ClaimId
         ,ci.ClaimNumber ClaimNum
         ,u.MedicalRecordNumber MemberNum
         ,ci.DateOfAdmit DateAdmit
         ,ci.DateOfDischarge DateOfService
         ,'' AS "Days"
         ,'' AS DRG
         ,ci.NoOfServices NumOfServices
         ,'' AS Provider
         ,CASE ci.StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
          END AS StatusDescription
      FROM
          ClaimInfo ci  WITH (NOLOCK) 
      INNER JOIN Patient u  WITH (NOLOCK) 
          ON u.PatientID = ci.PatientID
      WHERE
          ( ci.PatientID = @i_UserId
          OR @i_UserId IS NULL
          )
          AND ( ci.StatusCode = @v_StatusCode
                OR @v_StatusCode IS NULL
              )
      ORDER BY
          ci.DateOfDischarge DESC
END TRY
BEGIN CATCH          
          
    -- Handle exception          
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Claim_Select] TO [FE_rohit.r-ext]
    AS [dbo];

