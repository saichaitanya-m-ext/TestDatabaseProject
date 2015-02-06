/*      
------------------------------------------------------------------------------      
Procedure Name: [usp_ACGConditions_Insert]   
Description   : This Procedure is used to insert data from 'ACGPharmacySpansPatientBulk'table which is from 'CSV' File
					and inserts into ACGConditions Table
Created By    : NagaBabu
Created Date  : 03-Feb-2011
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION 
16-Feb-2011 NagaBabu Replaced 'NOT IN' by 'NOT EXISTS' in where clause And Added Alias names to tables		     
------------------------------------------------------------------------------      
*/   
CREATE PROCEDURE [dbo].[usp_ACGConditions_Insert]    
(    
	 @i_AppUserId KEYID  
)    
AS    
BEGIN TRY  
	 SET NOCOUNT ON    
	 DECLARE @l_numberOfRecordsInserted INT     
	 -- Check if valid Application User ID is passed      
	 IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )    
	 BEGIN    
		 RAISERROR ( N'Invalid Application User ID %d passed.' ,    
		 17 ,    
		 1 ,    
		 @i_AppUserId )    
	 END    
-----------------------------------------------------------------------------------------------------	 
	 
	INSERT INTO ACGConditions
		(
			ACGConditionName ,
			CreatedByUserID
		)
	SELECT DISTINCT
		ACGPSPB.condition_name ,
		@i_AppUserId
	FROM
		ACGPharmacySpansPatientBulk ACGPSPB
	WHERE
		NOT EXISTS ( SELECT	
						 1
					 FROM
						 ACGConditions ACGC
					 WHERE 
						 ACGC.ACGConditionName = ACGPSPB.condition_name	 
				   )
	GROUP BY
		ACGPSPB.condition_name
		
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
    ON OBJECT::[dbo].[usp_ACGConditions_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

