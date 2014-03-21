/*    
------------------------------------------------------------------------------    
Procedure Name: usp_ProcedureMeasure_Select    
Description   : This procedure is used to get the list of all the details from the   
				ProcedureMeasure table based on ProcedureMeasureId or dispalys all records 
				when passed NULL.
Created By    : Aditya    
Created Date  : 15-Apr-2010    
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION    
29-02-2012 P.V.PMohan Modified column for CodeSetProcedure
------------------------------------------------------------------------------    
*/  
CREATE PROCEDURE [dbo].[usp_ProcedureMeasure_Select]  
(  
	@i_AppUserId KeyId, 
	@i_ProcedureMeasureId KeyId = NULL,
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
		ProcedureMeasure.ProcedureMeasureId,
		ProcedureMeasure.MeasureId,
		ProcedureMeasure.ProcedureId,
		CodeSetProcedure.ProcedureCode,
		CodeSetProcedure.ProcedureName,
		ProcedureMeasure.CreatedByUserId,
		ProcedureMeasure.CreatedDate,
		ProcedureMeasure.LastModifiedByUserId,
		ProcedureMeasure.LastModifiedDate,
		CASE ProcedureMeasure.StatusCode
			 WHEN 'A' THEN 'Active'
			 WHEN 'I' THEN 'InActive'
		END as StatusDescription
   FROM 
		ProcedureMeasure WITH(NOLOCK)
		INNER JOIN CodeSetProcedure WITH(NOLOCK)
				ON CodeSetProcedure.ProcedureCodeID = ProcedureMeasure.ProcedureId
		 
  WHERE 
		( ProcedureMeasureId = @i_ProcedureMeasureId OR @i_ProcedureMeasureId IS NULL )
		--AND ( @v_StatusCode IS NULL OR CodeSetProcedure.StatusCode = @v_StatusCode )
		 
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
    ON OBJECT::[dbo].[usp_ProcedureMeasure_Select] TO [FE_rohit.r-ext]
    AS [dbo];

