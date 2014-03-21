/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_HealthIndicatorsAndBarriers_Select]
Description   : This procedure is used to Get data from HealthIndicatorsAndBarriers
Created By    : NagaBabu
Created Date  : 09-Sep-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
16-Sep-2011 NagaBabu Added @c_Type as input Perameter 
28-Sep-2011 Rathnam added @c_StatusCode
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_HealthIndicatorsAndBarriers_Select]
(  
	@i_AppUserId KeyID ,
	@c_Type CHAR(1) = NULL,
	@c_StatusCode CHAR(1) = NULL
)  
AS  
BEGIN TRY
	SET NOCOUNT ON  
	-- Check if valid Application User ID is passed    
	IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )  
	BEGIN  
		   RAISERROR 
		   ( N'Invalid Application User ID %d passed.' ,  
		     17 ,  
		     1 ,  
		     @i_AppUserId
		   )  
	END  
	
	SELECT 
		HealthIndicatorsAndBarriersId ,
		Name ,
		[Description] ,
		CASE StatusCode
			WHEN 'A' THEN 'Active'
			WHEN 'I' THEN 'InActive'
		END AS StatusCode ,
		CASE [Type]
			WHEN 'H' THEN 'Health Indicator'
			WHEN 'B' THEN 'Barrier'
		END AS [Type] ,
		CreatedByUserId ,
		CreatedDate ,
		LastModifiedByUserId ,
		LastModifiedDate
	FROM 
		HealthIndicatorsAndBarriers WITH(NOLOCK)
	WHERE ([Type] = @c_Type OR @c_Type IS NULL )
	AND (StatusCode = @c_StatusCode OR @c_StatusCode IS NULL)		 
	
END TRY    
--------------------------------------------------------     
BEGIN CATCH    
    -- Handle exception    
      DECLARE @i_ReturnedErrorID INT  
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException 
			  @i_UserId = @i_AppUserId  
  
      RETURN @i_ReturnedErrorID  
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_HealthIndicatorsAndBarriers_Select] TO [FE_rohit.r-ext]
    AS [dbo];

