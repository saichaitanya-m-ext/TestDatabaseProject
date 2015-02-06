

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_CPT_HCPCS_Modifier]
(
	@CPT_HCPCS_ModifierCode varchar(10)
)
RETURNS varchar(2)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @CPT_HCPCS_ModifierCode = The CPT/HCPCS Modifier Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'CPT_HCPCS_Modifier'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @CPT_HCPCS_ModifierCode = RTRIM(LTRIM(@CPT_HCPCS_ModifierCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @CPT_HCPCS_ModifierCode = ''
	  SET @CPT_HCPCS_ModifierCode = NULL;


   /* Checks and verifies that the Code does not contain a Decimal Point. */
   IF @CPT_HCPCS_ModifierCode LIKE '%.%'
	  SET @CPT_HCPCS_ModifierCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@CPT_HCPCS_ModifierCode) < @MinimumNumDigits) OR (LEN(@CPT_HCPCS_ModifierCode) > @MaximumNumDigits)
	  SET @CPT_HCPCS_ModifierCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@CPT_HCPCS_ModifierCode);

END;

