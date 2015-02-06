

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_LOINC]
(
	@LOINCCode varchar(10)
)
RETURNS varchar(7)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @LOINCCode = The "LOINC" Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'LOINC'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @LOINCCode = RTRIM(LTRIM(@LOINCCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @LOINCCode = ''
	  SET @LOINCCode = NULL;


   /* Checks if the Code meets the Code Digits requirement for Code of its Code Type, Numeric
	  Characters ONLY.  If not, no Code (NULL) will be outputed. */
   IF (@LOINCCode LIKE '%[a-z]%') OR (@LOINCCode LIKE '%.%')
	  SET @LOINCCode = NULL;


   /* Verifies that the Code does not include Dashes ("-") within its digits.  Otherwise, no Code (NULL) is outputed. */
   IF @LOINCCode LIKE '%-%'
	  SET @LOINCCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@LOINCCode) < @MinimumNumDigits) OR (LEN(@LOINCCode) > @MaximumNumDigits)
	  SET @LOINCCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@LOINCCode);

END;

