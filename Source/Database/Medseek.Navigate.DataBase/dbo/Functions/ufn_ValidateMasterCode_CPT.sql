

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_CPT]
(
	@CPTCode varchar(10)
)
RETURNS varchar(5)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @CPTCode = The CPT Procedure Code (CPT-I, CPT-II, and CPT-III) to be formatted.

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
   WHERE [CodeTypeCode] = 'CPT'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @CPTCode = RTRIM(LTRIM(@CPTCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @CPTCode = ''
	  SET @CPTCode = NULL;


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@CPTCode);

   SET @StrChr = SUBSTRING(@CPTCode, 1, @StrLen - 1);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @CPTCode = NULL;


   /* Checks and verifies that the Code meets the 'LAST-Digit' coding requirement of the type of
	  the Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrChr = SUBSTRING(@CPTCode, @StrLen, 1);

   -- Sets the value of the Code to NULL, if the Formatted Code DOES NOT meets the 'LAST-Digit' --
   -- requirements of the Code. --
   IF (ISNUMERIC(@StrChr) = 0) AND (@StrChr <> 'F') AND (@StrChr <> 'T')
	  SET @CPTCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@CPTCode) < @MinimumNumDigits) OR (LEN(@CPTCode) > @MaximumNumDigits)
	  SET @CPTCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@CPTCode);

END;

