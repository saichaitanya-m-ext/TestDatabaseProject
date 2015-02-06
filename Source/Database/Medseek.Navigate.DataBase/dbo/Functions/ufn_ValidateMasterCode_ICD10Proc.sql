

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_ICD10Proc]
(
	@ICD10Code varchar(10)
)
RETURNS varchar(7)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ICD10Code = The ICD-10-CM Procedure Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'ICD-10-CM-Proc'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @ICD10Code = RTRIM(LTRIM(@ICD10Code));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @ICD10Code = ''
	  SET @ICD10Code = NULL;


   /* Verifies that the Code meets the 'NO-Decimal Point' requirement.  Otherwise, no Code (NULL) is outputed. */
   IF @ICD10Code LIKE '%.%'
	  SET @ICD10Code = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@ICD10Code) < @MinimumNumDigits) OR (LEN(@ICD10Code) > @MaximumNumDigits)
	  SET @ICD10Code = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@ICD10Code);

END;

