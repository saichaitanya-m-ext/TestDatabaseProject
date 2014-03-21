

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_NPI]
(
	@NPICode varchar(20)
)
RETURNS varchar(20)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @NPICode = The "National Provider Identifier (NPI)" Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,

			@StrLen int,
			@StrChr varchar(20)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'NPI'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @NPICode = RTRIM(LTRIM(@NPICode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @NPICode = ''
	  SET @NPICode = NULL;


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@NPICode);

   SET @StrChr = SUBSTRING(@NPICode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @NPICode = NULL;


   /* Verifies that the code being formatted code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type. */
   IF (LEN(@NPICode) < @MinimumNumDigits) OR (LEN(@NPICode) > @MaximumNumDigits)
	  SET @NPICode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@NPICode);

END;

