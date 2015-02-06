/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ImmunizationSchedule_Select
Description   : This procedure is used to Select ImmunizationSchedule details
Created By    : NagaBabu
Created Date  : 16-Aug-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
19-Aug-2011 NagaBabu Added Cast operator for FrequenceNumber in ScheduleFromBirthdate
29--SEP-2011 Rathnam added @c_StatusCode parameter
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ImmunizationSchedule_Select]
(  
	@i_AppUserId KeyID ,
	@c_StatusCode CHAR(1) = NULL
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
--------------------------------------------------------------------------------------------------  
		SELECT 
			IMS.ImmunizationScheduleId ,
			IMS.ImmunizationId ,
			Immunizations.Name ,
			CAST(IMS.FrequenceNumber AS VARCHAR) + ' ' + CASE IMS.Frequence 
											WHEN 'D' THEN 'Day(s)'
											WHEN 'W' THEN 'Week(s)'
											WHEN 'M' THEN 'Month(s)'
											WHEN 'Y' THEN 'Year(s)'
										END AS ScheduleFromBirthdate ,
			CASE IMS.StatusCode	
				WHEN 'A' THEN 'Active'
				WHEN 'I' THEN 'InActive'
				ELSE ''
			END AS StatusCode ,
			IMS.CreatedByUserId ,
			IMS.CreatedDate ,
			IMS.LastModifiedByUserId ,
			IMS.LastModifiedDate	
		FROM 
			ImmunizationSchedule IMS  WITH (NOLOCK) 
		INNER JOIN Immunizations  WITH (NOLOCK) 
			ON IMS.ImmunizationId = Immunizations.ImmunizationId
		WHERE (ims.StatusCode = @c_StatusCode OR @c_StatusCode IS NULL)
	   
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
    ON OBJECT::[dbo].[usp_ImmunizationSchedule_Select] TO [FE_rohit.r-ext]
    AS [dbo];

