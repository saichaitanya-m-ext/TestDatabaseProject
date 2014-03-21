

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_CMS_POS]
(
	@CMS_POSCode varchar(10)
)
RETURNS varchar(2)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @CMS_POSCode = The CMS Place of Service Code to be formatted.

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
   WHERE [CodeTypeCode] = 'CMS_POS'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @CMS_POSCode = RTRIM(LTRIM(@CMS_POSCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @CMS_POSCode = ''
	  SET @CMS_POSCode = NULL;


   /* Checks if the Code meets the 'Numeric Digits' requirement of the type of the Formatted Code.
	  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@CMS_POSCode);

   SET @StrChr = SUBSTRING(@CMS_POSCode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @CMS_POSCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@CMS_POSCode) < @MinimumNumDigits) OR (LEN(@CMS_POSCode) > @MaximumNumDigits)
	  SET @CMS_POSCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@CMS_POSCode);

END;

