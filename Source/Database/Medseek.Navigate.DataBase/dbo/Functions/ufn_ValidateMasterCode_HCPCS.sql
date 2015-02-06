

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_HCPCS]
(
	@HCPCSCode varchar(10)
)
RETURNS varchar(5)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @HCPCSCode = The HCPCS Procedure Code to be formatted.

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
   WHERE [CodeTypeCode] = 'HCPCS'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @HCPCSCode = RTRIM(LTRIM(@HCPCSCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @HCPCSCode = ''
	  SET @HCPCSCode = NULL;


   /* Checks and verifies that the Code meets the 'FIRST-Digit' coding requirement of the type of
	  the Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   IF (SUBSTRING(@HCPCSCode, 1, 1) NOT LIKE '[A-V]')
	  SET @HCPCSCode = NULL;


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@HCPCSCode);

   SET @StrChr = SUBSTRING(@HCPCSCode, 2, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @HCPCSCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@HCPCSCode) < @MinimumNumDigits) OR (LEN(@HCPCSCode) > @MaximumNumDigits)
	  SET @HCPCSCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@HCPCSCode);

END;

