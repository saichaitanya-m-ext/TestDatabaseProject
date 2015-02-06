

CREATE FUNCTION [dbo].[ufn_ValidateMasterCode_ICD9Diag]
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

	 *********************************************************************************************************************************************/


   DECLARE	@MinimumNumDigits tinyint,
			@MaximumNumDigits tinyint,
			
			@StrLen int


   /* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
   SELECT @MinimumNumDigits = [MinimumNumDigits], @MaximumNumDigits = [MaximumNumDigits]
   FROM [dbo].[LkUpCodeType]
   WHERE [CodeTypeCode] = 'ICD-9-CM-Diag'


   /* Removes Blanks (" ") -- both 'Leading' and 'Trailing' -- from the Code being validated.
	  Otherwise, no Code (NULL) is outputed. */
   SET @ICD9Code = RTRIM(LTRIM(@ICD9Code));


   /* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	  outputed. */
   IF @ICD9Code = ''
	  SET @ICD9Code = NULL;


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


   /* Verifies that the Code meets the 'NO-Decimal Point' requirement.  Otherwise, no Code (NULL) is outputed. */
   IF @ICD9Code LIKE '%.%'
	  SET @ICD9Code = NULL;


   /* Verifies that the Code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM --
	  of Codes of its Code Type.  Otherwise, no Code (NULL) is outputed. */
   IF (LEN(@ICD9Code) < @MinimumNumDigits) OR (LEN(@ICD9Code) > @MaximumNumDigits)
	  SET @ICD9Code = NULL;


   -- Outputs the Formatted Code, or NULL. --
   RETURN (@ICD9Code);

END;

