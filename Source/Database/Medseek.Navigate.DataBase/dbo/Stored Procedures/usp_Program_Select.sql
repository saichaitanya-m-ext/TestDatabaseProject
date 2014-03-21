
/*      
------------------------------------------------------------------------------      
Procedure Name: usp_Program_Select  23,227  
Description   : This procedure is used to get the details from Program table    
    or a complete list of all the Programs    
Created By    : Aditya      
Created Date  : 23-Mar-2010      
------------------------------------------------------------------------------      
Log History   :       
DD-MM-YYYY  BY   DESCRIPTION      
13-Sep-2011 NagaBabu Added ORDER BY clause 
17-Aug-2012 Rathnam added Programname, programtypeid and description  
27-Sep-2012 Rathnam added columns as per assignment requirement. 
19-Nov-2012 P.V.P.Mohan changed parameters and added PopulationDefinitionID in 
            the place of CohortListID and PopulationDefinitionUsers    
------------------------------------------------------------------------------      
*/
CREATE PROCEDURE [dbo].[usp_Program_Select] (
	@i_AppUserId KeyID
	,@i_ProgramId KeyID
	)
AS
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

	SELECT Program.ProgramId
		,Program.ProgramName
		,Program.Description
		,CASE Program.AllowAutoEnrollment
			WHEN 1
				THEN 'Yes'
			WHEN 0
				THEN 'No'
			END AS AllowAutoEnrollment
		,CONVERT(VARCHAR(10), Program.CreatedDate, 101) CreatedOn
		,CASE Program.StatusCode
			WHEN 'A'
				THEN 'Active'
			WHEN 'I'
				THEN 'InActive'
			ELSE ''
			END AS StatusDescription
		,Program.PopulationDefinitionID
		,PopulationDefinition.PopulationDefinitionName
		,PopulationDefinition.ConditionID
		,dbo.ufn_GetDiseaseNameByID(PopulationDefinition.ConditionID) AS DiseaseName
		,dbo.ufn_GetUserNameByID(Program.CreatedByUserId) CreatedBy
		,CASE Program.IsAutomaticTermination
			WHEN 1
				THEN 'Yes'
			WHEN 0
				THEN 'No'
			END AS IsAutomaticTermination
		,Program.ConflictType
		,Program.DefinitionVersion
		,Program.LastModifiedDate
	FROM Program WITH (NOLOCK)
	LEFT OUTER JOIN PopulationDefinition WITH (NOLOCK) ON PopulationDefinition.PopulationDefinitionId = Program.PopulationDefinitionId
	LEFT OUTER JOIN Condition WITH (NOLOCK) ON Condition.ConditionID = PopulationDefinition.ConditionID
	WHERE (
			Program.ProgramId = @i_ProgramId
			OR @i_ProgramId IS NULL
			)
	ORDER BY ProgramName
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
    ON OBJECT::[dbo].[usp_Program_Select] TO [FE_rohit.r-ext]
    AS [dbo];

