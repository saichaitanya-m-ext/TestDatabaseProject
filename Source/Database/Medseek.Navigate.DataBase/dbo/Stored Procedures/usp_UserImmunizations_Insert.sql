/*      
------------------------------------------------------------------------------      
Procedure Name: usp_UserImmunizations_Insert      
Description   : This procedure is used to insert record into UserImmunizations table  
Created By    : Aditya      
Created Date  : 17-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
10-Nov-2011 NagaBabu Added @b_IsPreventive as input parameter  
03-feb-2011 Sivakrishna Added @b_IsAdhoc paramete  to maintain the adhoc task records in  UserImmunization table  
05-Jan-2013 Added ProgramID as parameter and inserting to immunization table for Patient Specific Managed Population
20-Mar-2013 P.V.P.Mohan modified UserImmunizations to PatientImmunizations
			and modified columns.
------------------------------------------------------------------------------      
*/  
CREATE PROCEDURE [dbo].[usp_UserImmunizations_Insert]    
(    
 @i_AppUserId KeyID,  
 @i_ImmunizationID KeyID,  
 @i_UserID KeyID,  
 @dt_ImmunizationDate UserDate,   
 @vc_Comments LongDescription,  
 @i_IsPatientDeclined IsIndicator,    
 @vc_AdverseReactionComments LongDescription,  
 @vc_StatusCode StatusCode,
 @dt_DueDate UserDate,
 @o_UserImmunizationID KeyID OUTPUT,
 @b_IsPreventive IsIndicator  ,
 @b_IsAdhoc  BIT = 0,
 @i_DataSourceID INT = NULL,
 @i_ManagedPopulationID KeyID = NULL,
 @i_AssignedCareProviderID KeyID=NULL
) 
AS  
BEGIN TRY
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT   
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
--------- Insert Operation into UserImmunizations Table starts here ---------  
   
	 INSERT INTO PatientImmunizations  
		(   
		  ImmunizationID  
		 ,PatientID  
		 ,ImmunizationDate  
		 ,IsPatientDeclined  
		 ,Comments  
		 ,AdverseReactionComments  
		 ,CreatedByUserId  
		 ,StatusCode
		 ,DueDate 
		 ,IsPreventive
		 ,IsAdhoc 
		 ,DataSourceID
		 ,ProgramID
		 ,AssignedCareProviderId
		)  
	 VALUES
		(  
			 @i_ImmunizationID
			,@i_UserID 
			,@dt_ImmunizationDate  
			,@i_IsPatientDeclined  
			,@vc_Comments  
			,@vc_AdverseReactionComments  
			,@i_AppUserId  
			,@vc_StatusCode
			,@dt_DueDate
			,@b_IsPreventive
			,@b_IsAdhoc  
			,@i_DataSourceID
			,@i_ManagedPopulationID
			,@i_AssignedCareProviderID
		 )
	   	
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_UserImmunizationID = SCOPE_IDENTITY()
      
    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert UserImmunizations'
				,17      
				,1      
				,@l_numberOfRecordsInserted                 
			)              
	END  

	RETURN 0 
  
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
    ON OBJECT::[dbo].[usp_UserImmunizations_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

