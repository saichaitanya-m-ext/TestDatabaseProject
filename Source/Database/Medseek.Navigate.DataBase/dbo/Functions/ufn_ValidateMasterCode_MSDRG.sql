

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_MSDRG]
(
	@MSDRGCode varchar(10)
)
RETURNS varchar(3)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @MSDRGCode = The MSDRG Code to be formatted.

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
   WHERE [CodeTypeCode] = 'MSDRG'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @MSDRGCode = RTRIM(LTRIM(@MSDRGCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @MSDRGCode = ''
	  SET @MSDRGCode = NULL;


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@MSDRGCode);

   SET @StrChr = SUBSTRING(@MSDRGCode, 1, @StrLen);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @MSDRGCode = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@MSDRGCode) < @MinimumNumDigits) OR (LEN(@MSDRGCode) > @MaximumNumDigits)
	  SET @MSDRGCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@MSDRGCode);

END;

