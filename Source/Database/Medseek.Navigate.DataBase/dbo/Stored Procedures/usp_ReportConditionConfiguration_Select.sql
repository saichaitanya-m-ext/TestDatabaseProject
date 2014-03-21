/*  
------------------------------------------------------------------------------  
Procedure Name: [usp_ReportConditionConfiguration_Select] 2,8 
Description   : This procedure is used to get the list of all Metric related reports
Created By    : Siva krishna
Created Date  : 28-Sep-2012 
------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION 
------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_ReportConditionConfiguration_Select] --23,1
(
 @i_AppUserId KeyId,
 @i_ReportId KeyId
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
			IF(@i_ReportId=6) --HEDIS
				BEGIN
					  SELECT DISTINCT
					  PopulationDefinitionID,
					  PopulationDefinitionName
		    		  FROM
						  PopulationDefinition
					  WHERE StatusCode = 'A'
					  AND StandardsId = 1 
					  AND ProductionStatus='F' 
					  AND StatusCode='A' 
					  AND ConditionId IS NOT NULL 
					  ORDER BY PopulationDefinitionName
    			END
			ELSE IF(@i_ReportId=8) --Care Management Metric
			BEGIN
				  SELECT DISTINCT
					 ProgramId PopulationDefinitionID,
					 ProgramName AS PopulationDefinitionName
	    		  FROM
					  Program 
				  WHERE StatusCode = 'A'
				  ORDER BY PopulationDefinitionName
			END
    		ELSE
    			BEGIN
					  SELECT DISTINCT
					  PopulationDefinitionID,
					  PopulationDefinitionName
		    		  FROM
						  PopulationDefinition
					  WHERE StatusCode = 'A'
					  AND ProductionStatus='F' 
					  AND StatusCode='A' 
					  AND ConditionId IS NOT NULL
    			END
    		
    		-- Selected Conditions
    		IF(@i_ReportId=8) --Care Management Metric
    			BEGIN
    				SELECT DISTINCT
						  ConditionID ,
						   (SELECT 
								ProgramName
							FROM 
								Program
							WHERE ProgramId  = rcc.ConditionId AND StatusCode='A') AS ConditionName
					  FROM
						ReportConditionConfiguration rcc
					  WHERE ReportId = @i_ReportId
					  AND StatusCode = 'A'
					  ORDER BY ConditionName
    			END
    		ELSE
    			BEGIN
    				SELECT DISTINCT
						  ConditionID ,
						   (SELECT 
								PopulationDefinitionName
							FROM 
								PopulationDefinition
							WHERE PopulationDefinitionID  = rcc.ConditionId AND DefinitionType <> 'N') AS ConditionName
					  FROM
						ReportConditionConfiguration rcc
					  WHERE ReportId = @i_ReportId
					  AND StatusCode = 'A'
					  ORDER BY ConditionName
				END
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
    ON OBJECT::[dbo].[usp_ReportConditionConfiguration_Select] TO [FE_rohit.r-ext]
    AS [dbo];

