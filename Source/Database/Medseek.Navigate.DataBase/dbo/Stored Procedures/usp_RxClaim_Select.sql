/*        
-----------------------------------------------------------------------------------       
Procedure Name: usp_RxClaim_Select        
Description   : This procedure is used to select the data from Rx Claim table.        
Created By    : Aditya         
Created Date  : 05-Apr-2010        
-----------------------------------------------------------------------------------     
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION        
   
-----------------------------------------------------------------------------------        
*/  
  
CREATE PROCEDURE [dbo].[usp_RxClaim_Select]
(  
	@i_AppUserId KEYID,  
	@i_UserId KEYID = NULL,
	@v_StatusCode StatusCode = NULL
) 
AS  
BEGIN TRY         
        
 -- Check if valid Application User ID is passed        
      IF ( @i_AppUserId IS NULL )  
      OR ( @i_AppUserId <= 0 )  
         BEGIN  
               RAISERROR ( N'Invalid Application User ID %d passed.' ,  
               17 ,  
               1 ,  
               @i_AppUserId )  
         END        
        
           
---------Selection starts here -------------------      
  
      SELECT 
			UserRxClaim.UserId,
			RxClaim.RxClaimId,
			RxClaim.RxClaimNum,
			RxClaim.MemberNum,
			RxClaim.BrandName,
			RxClaim.DateFilled,
			RxClaim.DaysSupply,
			RxClaim.Formulary,
			RxClaim.Generic,
			RxClaim.NDC,
			RxClaim.NDCLabel,
			RxClaim.QuantityDispensed,
			RxClaim.TherapyClassSpecific,
			RxClaim.TherapyClassStandard,
			RxClaim.Pharamacy,
			RxClaim.PharmacyName,
			RxClaim.Prescriber,
			RxClaim.DrugCodeId,
			CASE RxClaim.StatusCode  
				WHEN 'A' THEN 'Active'  
				WHEN 'I' THEN 'InActive'  
			END AS Status,
			RxClaim.CreatedByUserId,
			RxClaim.CreatedDate,
			RxClaim.LastModifiedByUserId,
			RxClaim.LastModifiedDate  
      FROM  
		  RxClaim with (nolock) 
		  INNER JOIN UserRxClaim with (nolock)
				ON UserRxClaim.RxClaimId = RxClaim.RxClaimId
      WHERE  
          ( UserRxClaim.UserId = @i_UserId OR @i_UserId IS NULL ) 
		  AND  ( RxClaim.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
		  
	 ORDER BY RxClaim.DateFilled DESC  
                         
END TRY  
BEGIN CATCH        
        
    -- Handle exception        
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_RxClaim_Select] TO [FE_rohit.r-ext]
    AS [dbo];

