

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_UBTypeOfBill]
(
	@TypeOfBillCode varchar(10)
)
RETURNS varchar(3)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @TypeOfBillCode = The "Type of Bill" Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,

			@StrLen int,
			@CurrentPtr int,
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'TOB'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @TypeOfBillCode = RTRIM(LTRIM(@TypeOfBillCode));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @TypeOfBillCode = ''
	  SET @TypeOfBillCode = NULL;


   /* Checks and verifies that the Code meets the 'Numeric Digits' requirement of the type of the
	  Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrLen = LEN(@TypeOfBillCode);

   SET @StrChr = SUBSTRING(@TypeOfBillCode, 1, @StrLen - 1);

   IF (ISNUMERIC(@StrChr) = 0) OR (@StrChr LIKE '%.%')
	  SET @TypeOfBillCode = NULL;


   /* Checks and verifies that the Code meets the 'LAST-Digit' coding requirement of the type of
	  the Formatted Code.  Otherwise, no Code (NULL) is outputed. */
   SET @StrChr = SUBSTRING(@TypeOfBillCode, @StrLen, 1);

   -- Sets the value of the Code to NULL, if the Formatted Code DOES NOT meets the 'LAST-Digit' --
   -- requirements of the Code. --
   IF (ISNUMERIC(@StrChr) = 0) AND (@StrChr NOT LIKE '[a-z]')
	  SET @TypeOfBillCode = NULL;


   /* Verifies that the code being formatted code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type. */
   IF (LEN(@TypeOfBillCode) < @MinimumNumDigits) OR (LEN(@TypeOfBillCode) > @MaximumNumDigits)
	  SET @TypeOfBillCode = NULL;


   -- Outputs the Successfully-Validate Code, or NULL. --
   RETURN (@TypeOfBillCode);

END;

