

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_UBTypeOfBill]
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

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the Type of Bill Code to be formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the Type of Bill Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the Type of Bill Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int,
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'TOB'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @TypeOfBillCode = RTRIM(LTRIM(@TypeOfBillCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @TypeOfBillCode = REPLACE(@TypeOfBillCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @TypeOfBillCode = ''
	  SET @TypeOfBillCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@TypeOfBillCode);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@TypeOfBillCode, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @TypeOfBillCode = SUBSTRING(@TypeOfBillCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@TypeOfBillCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF SUBSTRING(@TypeOfBillCode, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;

	  END

	  SET @TypeOfBillCode = SUBSTRING(@TypeOfBillCode, 1, @StrLen);
   END


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


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@TypeOfBillCode);

END;

