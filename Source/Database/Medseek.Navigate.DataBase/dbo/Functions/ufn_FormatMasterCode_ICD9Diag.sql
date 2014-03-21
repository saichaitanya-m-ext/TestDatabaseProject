
CREATE FUNCTION [dbo].[ufn_FormatMasterCode_ICD9Diag]
(
	@ICD9Code varchar(10)
)
RETURNS varchar(5)
AS

BEGIN

	/************************************************************ INPUT PARAMETERS ************************************************************

	 @ICD9Code = The ICD-9-CM Diagnosis Code to be formatted.

	 @MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.

	 @MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.

	 @RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the ICD-9-CM Diagnosis Code to be
						formatted.

	 @RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the ICD-9-CM Diagnosis Code to be formatted.

	 @RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the ICD-9-CM Diagnosis Code to be formatted.
	 
	 @PadWithLeadingZeros = Indicator of whether to pad or fill-in Leading Zeros (0's) from the ICD-9-CM Diagnosis Code to be formatted.

	 @PadWithTrailingZeros = Indicator of whether to pad or fill-in Trailing Zeros (0's) from the ICD-9-CM Diagnosis Code to be formatted.

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
	
			@RemoveALLBlanks bit,
			@RemoveLeadingZeros bit,
			@RemoveTrailingZeros bit,
			@PadWithLeadingZeros bit,
			@PadWithTrailingZeros bit,

			@StrLen int,
			@CurrentPtr int,
			@StrChr varchar(10)


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits],
		  @RemoveALLBlanks = [RemoveALLBlanks], @RemoveLeadingZeros = [RemoveLeadingZeros],
		  @RemoveTrailingZeros = [RemoveTrailingZeros], @PadWithLeadingZeros = [PadWithLeadingZeros],
		  @PadWithTrailingZeros = [PadWithTrailingZeros]

   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'ICD-9-CM-Diag'


   /* Removes Blanks (" ") from the Code to be formatted. */

   -- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
   SET @ICD9Code = RTRIM(LTRIM(@ICD9Code));

   -- Removes ALL Other Blanks (" ") from the Code to be formatted. --
   IF @RemoveALLBlanks = 1
	  SET @ICD9Code = REPLACE(@ICD9Code, ' ', '');


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @ICD9Code = ''
	  SET @ICD9Code = NULL;


   /* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	  formatted code (RemoveLeadingZeros = 1). */
   IF @RemoveLeadingZeros = 1
   BEGIN
   	  SET @StrLen = LEN(@ICD9Code);
   	  
   	  SET @CurrentPtr = 1;
   	  
   	  WHILE @CurrentPtr < @StrLen
   	  BEGIN
		 IF SUBSTRING(@ICD9Code, @CurrentPtr, 1) <> '0'
			BREAK;

		 SET @CurrentPtr = @CurrentPtr + 1
	  END

	  SET @ICD9Code = SUBSTRING(@ICD9Code, @CurrentPtr, @StrLen);
   END


   /* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	  formatted code (RemoveTrailingZeros = 1). */
   IF @RemoveTrailingZeros = 1
   BEGIN
	  SET @StrLen = LEN(@ICD9Code);

	  WHILE @StrLen > 1
	  BEGIN
		 IF SUBSTRING(@ICD9Code, @StrLen, 1) <> '0'
			BREAK;

		 SET @StrLen = @StrLen - 1;
	  END

	  SET @ICD9Code = SUBSTRING(@ICD9Code, 1, @StrLen);
   END
   
   
   /* Checks if the Code includes a digit that is an alphabetic character.  And, if Yes, additional
	  processing will be performed to ensure that the Code meets the 'Alphabetic Character in Code'
	  rule -- Maximum of 1 Alphabetic character, Alphabetic Character is the 1st digit, AND the
	  alphabetic character is either "E" or "V". */
   IF @ICD9Code LIKE '%[a-z]%'
   BEGIN
	  -- Checks if the FIRST digit of the Code is an Alphabet Character -- either "E" or "V". --
	  IF SUBSTRING(@ICD9Code, 1, 1) NOT IN ('E', 'V')
		 SET @ICD9Code = NULL;
	  ELSE
	  BEGIN
		 -- Checks if any other Digit of the Code is an Alphabet Character; if Yes, NULL value is returned. --
		 SET @StrLen = LEN(@ICD9Code);

		 IF (@StrLen > 1) AND (SUBSTRING(@ICD9Code, 2, @StrLen - 1) LIKE '%[a-z]%')
			SET @ICD9Code = NULL;
	  END
   END


   /* The Code includes a Decimal Point '.'.  And, if Yes, additional processing will be performed to
	  ensure that the Code meets the 'Code with Decimal Point' requirement -- Number of Digits (a
	  Minimum of THREE (3)) BEFORE the Decimal Point, PLUS optional FOURTH and FIFTH numeric digits
	  after the Decimal Point. */
   IF (LEN(@ICD9Code) >= 2) AND (@ICD9Code LIKE '%.%')
   BEGIN
	  /* Checks the Code for the Number of Digits it has BEFORE the Decimal Point.  The Code is PADDED
		 with Leading Zeros, if necessary, to meet the 'Minimum 3 Digits' BEFORE the Decimal Point.
		 But, if the Number of Digits is GREATER THAN 3, the function returns a NULL value. */
	  SET @CurrentPtr = CHARINDEX('.', @ICD9Code, 1);

	  SET @StrChr = SUBSTRING(@ICD9Code, 1, @CurrentPtr - 1);
	  IF LEN(@StrChr) <> 4 AND LEFT(@ICD9Code,1) = 'E' --Added to include E codes
		 SET @ICD9Code = NULL;
	  ELSE
		
	  IF LEN(@StrChr) > 3 AND LEFT(@ICD9Code,1) <> 'E'
		 SET @ICD9Code = NULL;
	  ELSE
	  BEGIN
		 IF @PadWithLeadingZeros = 1
			SET @ICD9Code = REPLICATE('0', 3 - LEN(@StrChr)) + @ICD9Code;
	  END

	  /* Checks the Code for the Number of Optional Digits it has AFTER the Decimal Point.  If the
		 Number of Digits is GREATER THAN 2, the function returns a NULL value.  And, if required,
		 the Code is PADDED with a Trailing Zero. */
	  SET @CurrentPtr = CHARINDEX('.', @ICD9Code, 1);

	  SET @StrChr = SUBSTRING(@ICD9Code, @CurrentPtr + 1, LEN(@ICD9Code));

	  IF LEN(@StrChr) > 2
		 SET @ICD9Code = NULL;
	  ELSE
	  BEGIN
		 IF (@PadWithTrailingZeros = 1) AND (LEN(@StrChr) < 1)
			SET @ICD9Code = @ICD9Code + '0';
	  END
   END
   ELSE
   BEGIN
	  /* Checks that the Code meets the 'Minimum 3-Digits' length requirement BEFORE the (non-existent)
		 Decimal Point. */
	  IF (LEN(@ICD9Code) >= 1) AND (LEN(@ICD9Code) <= @MinimumNumDigits)
	  BEGIN
		 IF @PadWithLeadingZeros = 1
			SET @ICD9Code = REPLICATE('0', @MinimumNumDigits - LEN(@ICD9Code)) + @ICD9Code;
	  END
	  ELSE
		 SET @ICD9Code = NULL;

	  /* Optionally, PAD the Code with 1 Trailing Zero. */
	  IF @PadWithTrailingZeros = 1
		 SET @ICD9Code = @ICD9Code + '0';
   END


   /* Removes the Decimal Point (.) from the Code being formatted. */
   SET @ICD9Code = REPLACE(@ICD9Code, '.', '');


   /* Outputs the formatted code, if it meets the 'Code Length' requirements -- both MINIMUM and
	  MAXIMUM -- of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@ICD9Code) < @MinimumNumDigits) OR (LEN(@ICD9Code) > @MaximumNumDigits)
	  SET @ICD9Code = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@ICD9Code);

END;

