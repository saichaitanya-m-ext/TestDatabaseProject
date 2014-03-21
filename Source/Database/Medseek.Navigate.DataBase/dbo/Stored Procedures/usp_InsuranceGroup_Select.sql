/*    
------------------------------------------------------------------------------    
Procedure Name: usp_InsuranceGroup_Select    
Description   : This procedure is used to get the details from InsuranceGroup table   
Created By    : Aditya    
Created Date  : 25-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
19-Aug-2010 NagaBabu  Added ORDER BY clause to the select statement    
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_InsuranceGroup_Select]  
(  
	@i_AppUserId KeyID,
	@i_InsuranceGroupID KeyID = NULL,
	@vc_GroupName SourceName = NULL,
	@v_StatusCode StatusCode = NULL
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
  
	SELECT  
		InsuranceGroupID,  
		GroupName,  
		AddressLine1,  
		AddressLine2,  
		City,  
		StateCode,
		ZipCode,  
		ContactName,
		ContactPhoneNumber,
		ContactPhoneNumberExtension,
		Website,  
		PhoneNumber,  
		PhoneNumberExtension,  
		Fax,  
		CreatedByUserId,  
		CreatedDate,  
		LastModifiedByUserId,  
		LastModifiedDate,  
		CASE StatusCode   
		  WHEN 'A' THEN 'Active'  
		  WHEN 'I' THEN 'InActive'  
		  ELSE ''  
		END AS StatusDescription  
    FROM 
		InsuranceGroup  
    WHERE 
		( InsuranceGroupID = @i_InsuranceGroupID OR @i_InsuranceGroupID IS NULL )
         AND ( GroupName LIKE '%' + @vc_GroupName + '%' OR @vc_GroupName = '' OR @vc_GroupName IS NULL )
         AND ( StatusCode = @v_StatusCode OR @v_StatusCode IS NULL   )
    ORDER BY
		GroupName
			  
                
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
    ON OBJECT::[dbo].[usp_InsuranceGroup_Select] TO [FE_rohit.r-ext]
    AS [dbo];

