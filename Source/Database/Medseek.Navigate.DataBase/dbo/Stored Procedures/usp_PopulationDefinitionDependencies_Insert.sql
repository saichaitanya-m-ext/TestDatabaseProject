
/*        
------------------------------------------------------------------------------        
Procedure Name: [usp_PopulationDefinitionDependencies_Insert]        
Description   : 
Created By    : Rathnam       
Created Date  : 22-Aug-12
------------------------------------------------------------------------------        
Log History   :         
DD-MM-YYYY  BY   DESCRIPTION 
07-Nov-2012 P.V.P.Mohan changes the name of Procedure and changed parameters and added PopulationDefinition & ConditionDefinition
------------------------------------------------------------------------------        
*/
--select * from PopulationDefinition
CREATE PROCEDURE [dbo].[usp_PopulationDefinitionDependencies_Insert] (
	@i_AppUserId KEYID
	,@i_PopulationDefinitionID KEYID
	,@b_IsDraft ISINDICATOR
	,@t_InhertiedCohortListID TYPEIDANDNAME READONLY
	)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		-- Check if valid Application User ID is passed        
		IF (@i_AppUserId IS NULL)
			OR (@i_AppUserId <= 0)
		BEGIN
			RAISERROR (
					N'Invalid Application User ID %d passed.'
					,17
					,1
					,@i_AppUserId
					)
		END

		DELETE
		FROM CohortListDependencies
		WHERE IncludedCohortListId NOT IN (
				SELECT cld.TypeId
				FROM @t_InhertiedCohortListID cld
				)
			AND PopulationDefinitionID = @i_PopulationDefinitionID

		INSERT INTO CohortListDependencies (
			PopulationDefinitionID
			,IncludedCohortListId
			,CreatedByUserId
			,Type
			,IsDraft
			)
		SELECT @i_PopulationDefinitionID
			,cld.TypeId
			,@i_AppUserId
			,CASE 
				WHEN cld.NAME = 'Copy'
					THEN 'C'
				ELSE 'I'
				END
			,@b_IsDraft
		FROM @t_InhertiedCohortListID cld
		WHERE NOT EXISTS (
				SELECT 1
				FROM CohortListDependencies cld1
				WHERE cld.TypeId = cld1.IncludedCohortListId
					AND cld1.PopulationDefinitionID = @i_PopulationDefinitionID
				)
	END TRY

	--------------------------------------------------------         
	BEGIN CATCH
		-- Handle exception        
		DECLARE @i_ReturnedErrorID INT

		EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

		RETURN @i_ReturnedErrorID
	END CATCH
END

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PopulationDefinitionDependencies_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

