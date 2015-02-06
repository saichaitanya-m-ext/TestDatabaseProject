

CREATE FUNCTION [dbo].[ufn_FormatMasterCode_LOINC]
(
	@LOINCCode varchar(10)
)
RETURNS varchar(7)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @LOINCCode = The "LOINC" Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveDashes = Indicator of whether to remove or filter-out Dashes from the LOINC Code to be formatted.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the LOINC Code to be formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the ICD-10-CM Procedure Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the ICD-10-CM Procedure Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,

			@RemoveDashes bit,
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int,
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveDashes = [RemoveDashes], @RemoveALLBlanks = [RemoveALLBlanks],
		  @RemoveLeadingZeros = [RemoveLeadingZeros], @RemoveTrailingZeros = [RemoveTrailingZeros]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'LOINC'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @LOINCCode = RTRIM(LTRIM(@LOINCCode));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @LOINCCode = REPLACE(@LOINCCode, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @LOINCCode = ''
	  SET @LOINCCode = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@LOINCCode);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE (@CurrentPtr < @StrLen)
   	  BEGIN
		 IF SUBSTRING(@LOINCCode, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @LOINCCode = SUBSTRING(@LOINCCode, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@LOINCCode);

	  WHILE (@StrLen > 1)
	  BEGIN
		 IF SUBSTRING(@LOINCCode, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;

	  END

	  SET @LOINCCode = SUBSTRING(@LOINCCode, 1, @StrLen);
   END


   /* Checks if the Code meets the Code Digits requirement for Code of its Code Type, Numeric
	  Characters ONLY.  If not, no Code (NULL) will be outputed. */
   IF (@LOINCCode LIKE '%[a-z]%') OR (@LOINCCode LIKE '%.%')
	  SET @LOINCCode = NULL;


   /* Checks if the Formatted Code has a 'Dash' (-).  If No, no Code (NULL) is outputed. */
   
   -- Formatted Code does not have a 'Dash'; no Code (NULL) is outputed. --
   IF @LOINCCode NOT LIKE '%-%'
	  SET @LOINCCode = NULL
   ELSE
   BEGIN  -- Formatted Code has a 'Dash'; further processing and checks will be performed. --

	  /* Checks if the Formatted Code meets the Code requirement for Code of its Code Type, the Number
		 of Numeric Characters BEFORE and AFTER the 'Dash in the Code.  If not, no Code (NULL) will be
		 outputed. */
	  SET @CurrentPtr = CHARINDEX('-', @LOINCCode, 1);

	  SET @StrChr = SUBSTRING(@LOINCCode, 1, @CurrentPtr - 1);

	  IF (LEN(@StrChr) < 1) OR (LEN(@StrChr) > 5)
		 SET @LOINCCode = NULL
	  ELSE
	  BEGIN
		 SET @StrChr = SUBSTRING(@LOINCCode, (@CurrentPtr + 1), LEN(@LOINCCode));
		 
		 IF LEN(@StrChr) > 1
			SET @LOINCCode = NULL
	  END
   END


   /* Removes 'Dashes' from the Formatted Code.  And, output the Formatted Code. */
   IF @RemoveDashes = 1
	  SET @LOINCCode = REPLACE(@LOINCCode, '-', '');


   /* Verifies that the code being formatted code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
	  of its Code Type. */
   IF (LEN(@LOINCCode) < @MinimumNumDigits) OR (LEN(@LOINCCode) > @MaximumNumDigits)
	  SET @LOINCCode = NULL;


   -- Outputs the Formatted Code, or no code (NULL). --
   RETURN (@LOINCCode);

END;

