

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_MDC]
(
	@MDCCode varchar(10)
)
RETURNS varchar(2)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @MDCCode = The MDC Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,

			@StrLen int,
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'MDC'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @MDCCode = RTRIM(LTRIM(@MDCCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @MDCCode = ''
	  SET @MDCCode = NULL;


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@MDCCode);

   SET @StrChr = SUBSTRING(@MDCCode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @MDCCode = NULL;


   /* Checks if the Formatted Code exceeds the MAXIMUM 'Code Length' requirement of its Code Type.  If Yes, not Code (NULL)
	  is outputed. */
   IF (LEN(@MDCCode) < @MinimumNumDigits) OR (LEN(@MDCCode) > @MaximumNumDigits)
	  SET @MDCCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@MDCCode);

END;

