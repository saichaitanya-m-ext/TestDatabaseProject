/*  
---------------------------------------------------------------------------------------  
Procedure Name: usp_ACGSchedule_Select_DD 
Description   : This procedure is used to get subtypes for types in ACGSchedule
Created By    : NagaBabu
Created Date  : 03-Mar-2011
---------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers	
---------------------------------------------------------------------------------------  
*/
CREATE PROCEDURE [dbo].[usp_ACGSchedule_Select_DD]
(
	@i_AppUserId KEYID,
	@vc_Type VARCHAR(1)
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
-------------------------------------------------------- 
	IF @vc_Type = 'F'
		SELECT ''
		
	IF @vc_Type = 'P'
		SELECT
			ProgramId ,
			ProgramName
		FROM
			Program
		WHERE
			StatusCode = 'A'
		ORDER BY 
			ProgramName	
			
	IF @vc_Type = 'C'	
		SELECT
			PopulationDefinitionId ,
			PopulationDefinitionName
		FROM
			PopulationDefinition
		WHERE
			StatusCode = 'A'
		ORDER BY 
			PopulationDefinitionName					

	IF @vc_Type = 'T'	
		SELECT
			CareTeamId ,
			CareTeamName
		FROM
			CareTeam
		WHERE
			StatusCode = 'A'
		ORDER BY 
			CareTeamName					

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
    ON OBJECT::[dbo].[usp_ACGSchedule_Select_DD] TO [FE_rohit.r-ext]
    AS [dbo];

