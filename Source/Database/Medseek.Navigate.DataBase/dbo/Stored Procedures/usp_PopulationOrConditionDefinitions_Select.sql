/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_PopulationOrConditionDefinitions_Select] 23,1  
Description   : This procedure is used to get the list of all Metric related reports
Created By    : Siva krishna
Created Date  : 28-Sep-2012 
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_PopulationOrConditionDefinitions_Select]-- 23,1,NULL
(
 @i_AppUserId KeyId,
 @b_Filter BIT
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

		IF @b_Filter = 0 
			BEGIN
				SELECT DISTINCT
					  PopulationDefinitionID,
					  PopulationDefinitionName
				FROM
					  PopulationDefinition WITH(NOLOCK)
				WHERE  StatusCode = 'A'
				AND DefinitionType = 'P'
			      
				SELECT DISTINCT
				      PopulationId ,
					  (SELECT 
							PopulationDefinitionName
						FROM 
							PopulationDefinition WITH(NOLOCK)
						WHERE PopulationDefinitionID  = rfc.PopulationId AND DefinitionType = 'P') AS PopulationDefinitionName
				FROM
				   ReportFilterConfiguration rfc
				WHERE PopulationId IS NOT NULL
				  AND StatusCode = 'A'
			END	
		     ELSE 
		       BEGIN
				  SELECT DISTINCT
					  PopulationDefinitionID,
					  PopulationDefinitionName
		    	  FROM
					  PopulationDefinition WITH(NOLOCK)
				  WHERE StatusCode = 'A'
				  AND DefinitionType = 'C'
			      
				  SELECT DISTINCT
					  ConditionID AS PopulationId,
					   (SELECT 
							PopulationDefinitionName
						FROM 
							PopulationDefinition WITH(NOLOCK)
						WHERE PopulationDefinitionID  = rfc.ConditionId AND DefinitionType = 'C') AS PopulationDefinitionName
				  FROM
				    ReportFilterConfiguration rfc
				 WHERE StatusCode = 'A' AND rfc.ConditionID IS NOT NULL
    			END

			   select * from ReportFilterConfiguration
					

END TRY  
----------------------------------------------------------   
BEGIN CATCH  
    -- Handle exception  
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH



				

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationOrConditionDefinitions_Select] TO [FE_rohit.r-ext]
    AS [dbo];

