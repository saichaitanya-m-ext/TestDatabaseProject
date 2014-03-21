/*
------------------------------------------------------------------------------    
Procedure Name: [usp_PQRIQualityMeasureGroupCorrelate_InsertUpdate]    
Description   : This procedure used to insert  and update the records into PQRIQualityMeasureGroupCorrelate
Created By    : Rama
Created Date  : 29-Dec-2010
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION 
30-Dec-2010 NagaBabu Replaced some input parameters by a table variable and modified Update,Insert Querries 
------------------------------------------------------------------------------    
*/     
CREATE PROCEDURE [dbo].[usp_PQRIQualityMeasureGroupCorrelate_InsertUpdate]
       (
        @i_AppUserId KEYID
       ,@t_PQRIQualityMeasureGroupCorrelate QualityMeasureGroupCorrelate READONLY
       ,@o_PQRIQualityMeasureGroupCorrelateID KEYID OUTPUT
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

      DECLARE
              @i_numberOfRecordsInserted INT
             ,@i_numberOfRecordsUpdated INT
             

               UPDATE
                   PQRIQualityMeasureGroupCorrelate
               SET
                   PQRIQualityMeasureGroupID = PQRIQMGC.PQRIQualityMeasureGroupID
                  ,PQRIQualityMeasureCorrelateIDList = PQRIQMGC.PQRIQualityMeasureCorrelateIDList
                  ,AgeFrom = PQRIQMGC.AgeFrom
                  ,AgeTo = PQRIQMGC.AgeTo
                  ,Gender = PQRIQMGC.Gender
                  ,BMIFrom = PQRIQMGC.BMIFrom
                  ,BMITo = PQRIQMGC.BMITo
                  ,LastModifiedByUserId = @i_AppUserId
                  ,LastModifiedDate = GETDATE()
               FROM
				   PQRIQualityMeasureGroupCorrelate	QMGC	
			   INNER JOIN @t_PQRIQualityMeasureGroupCorrelate PQRIQMGC
				   ON QMGC.PQRIQualityMeasureGroupCorrelateID = PQRIQMGC.PQRIQualityMeasureGroupCorrelateID
				   
		 	   SELECT @i_numberOfRecordsUpdated = @@ROWCOUNT
         
         
               INSERT INTO
                   PQRIQualityMeasureGroupCorrelate
                   (
                    PQRIQualityMeasureGroupID
                   ,PQRIQualityMeasureCorrelateIDList
                   ,AgeFrom
                   ,AgeTo
                   ,Gender
                   ,BMIFrom
                   ,BMITo
                   ,CreatedByUserId
                   )
              SELECT
				   PQRIQMGC.PQRIQualityMeasureGroupID ,
				   PQRIQMGC.PQRIQualityMeasureCorrelateIDList ,
				   PQRIQMGC.AgeFrom ,
				   PQRIQMGC.AgeTo ,
				   PQRIQMGC.Gender ,
				   PQRIQMGC.BMIFrom ,
				   PQRIQMGC.BMITo ,
				   @i_AppUserId
			   FROM	
				   @t_PQRIQualityMeasureGroupCorrelate PQRIQMGC	
			   WHERE
				   PQRIQMGC.PQRIQualityMeasureGroupCorrelateID = 0	      
				   
               SELECT
                  -- @o_PQRIQualityMeasureGroupCorrelateID = SCOPE_IDENTITY()
					@i_numberOfRecordsInserted = @@ROWCOUNT
                  
 
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
    ON OBJECT::[dbo].[usp_PQRIQualityMeasureGroupCorrelate_InsertUpdate] TO [FE_rohit.r-ext]
    AS [dbo];

