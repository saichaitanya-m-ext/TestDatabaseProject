

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_NDC]
(
	@NDCCode varchar(20)
)
RETURNS varchar(11)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @NDCCode = The "NDC" Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'NDC'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @NDCCode = RTRIM(LTRIM(@NDCCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @NDCCode = ''
	  SET @NDCCode = NULL;


   /* Verifies that the Code does not include Dashes ("-") within its digits.  Otherwise, no Code (NULL) is outputed. */
   IF @NDCCode LIKE '%-%'
	  SET @NDCCode = NULL;


   /* Verifies that the Code does not include non-Numeric digits.  Otherwise, no Code (NULL) is outputed. */
   IF (@NDCCode LIKE '%[a-z]%') OR (@NDCCode LIKE '%.%')
	  SET @NDCCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@NDCCode) < @MinimumNumDigits) OR (LEN(@NDCCode) > @MaximumNumDigits)
	  SET @NDCCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@NDCCode);

END;

