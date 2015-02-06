/*    
------------------------------------------------------------------------------    
Procedure Name: usp_UserImmunizations_Update   
Description   : This procedure is used to Update record into UserImmunizations table
Created By    : Aditya    
Created Date  : 18-Mar-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
10-Nov-2011 NagaBabu Added @b_IsPreventive as input parameter          
07-Jan-2013 Praveen Added ProgramID as parameter and updating to immunization table for Patient Specific Managed Population
20-Mar-2013 P.V.P.Mohan modified UserImmunizations to PatientImmunizations
			and modified columns.
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_UserImmunizations_Update]  
(  
 @i_AppUserId KeyID,  
 @i_ImmunizationID KeyID,  
 @i_UserID KeyID,  
 @dt_ImmunizationDate UserDate,   
 @vc_Comments LongDescription,  
 @i_IsPatientDeclined IsIndicator,    
 @vc_AdverseReactionComments LongDescription,  
 @vc_StatusCode StatusCode,
 @dt_DueDate userdate,
 @i_UserImmunizationID KeyID,
 @b_IsPreventive IsIndicator ,
 @i_DataSourceID INT  = NULL   ,
 @i_ManagedPopulationID KeyID = NULL,
 @i_AssignedCareProviderID KeyID=NULL
)  
AS  
BEGIN TRY

	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsUpdated INT   
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

	 UPDATE PatientImmunizations
	    SET	ImmunizationID = @i_ImmunizationID,
	        ImmunizationDate = @dt_ImmunizationDate,
	        Comments = @vc_Comments,
	        IsPatientDeclined = @i_IsPatientDeclined,
			AdverseReactionComments = @vc_AdverseReactionComments,
			LastModifiedByUserId = @i_AppUserId,
			LastModifiedDate = GETDATE(),
			DueDate = @dt_DueDate,
			StatusCode = @vc_StatusCode,
			IsPreventive = @b_IsPreventive,
			DataSourceID = @i_DataSourceID,
			ProgramID=@i_ManagedPopulationID,
			AssignedCareProviderId = @i_AssignedCareProviderID
	  WHERE PatientImmunizationID = @i_UserImmunizationID 
			AND PatientID = @i_UserID

    SELECT @l_numberOfRecordsUpdated = @@ROWCOUNT
      
	IF @l_numberOfRecordsUpdated <> 1
		BEGIN      
			RAISERROR  
			(  N'Invalid Row count %d passed to update UserImmunizations'  
				,17  
				,1 
				,@l_numberOfRecordsUpdated            
			)          
		END  
		
    RETURN 0 
  
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
    ON OBJECT::[dbo].[usp_UserImmunizations_Update] TO [FE_rohit.r-ext]
    AS [dbo];

