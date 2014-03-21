


CREATE FUNCTION [dbo].[ufn_FormatMasterCode_NDC]
(
	@NDCCode VARCHAR(20)
)
RETURNS VARCHAR(11)
AS
BEGIN
	/************************************************************ INPUT PARAMETERS ************************************************************
	
	@NDCCode = The "NDC" Code to be formatted.
	
	@MinimumNumDigits = Minimum Number of Digits/Characters that make up a properly-formatted Code.
	
	@MaximumNumDigits = Maximum Number of Digits/Characters that make up a properly-formatted Code.
	
	@RemoveDashes = Indicator of whether to remove or filter-out Dashes (-) from the NDC Code to be formatted.
	
	@RemoveALLBlanks = Indicator of whether to remove or filter-out ALL Blanks or Empty String (" ") from the NDC Code to be formatted.
	
	@RemoveLeadingZeros = Indicator of whether to remove or filter-out Leading Zeros (0's) from the CMS Place of Service Code to be formatted.
	
	@RemoveTrailingZeros = Indicator of whether to remove or filter-out Trailing Zeros (0's) from the CMS Place of Service Code to be formatted.
	
	@PadWithLeadingZeros = Indicator of whether to pad or fill-in Leading Zeros (0's) from the MSDRG Code to be formatted.
	
	*********************************************************************************************************************************************/
	
	
	DECLARE @MinimumNumDigits        TINYINT
	       ,@MaximumNumDigits        TINYINT
	       ,@RemoveDashes            BIT
	       ,@RemoveALLBlanks         BIT
	       ,@RemoveLeadingZeros      BIT
	       ,@RemoveTrailingZeros     BIT
	       ,@PadWithLeadingZeros     BIT
	       ,@NDCCode_NEW             VARCHAR(20)
	       ,@StrLen                  INT
	       ,@CurrentPtr              INT
	       ,@PreviousPtr             INT
	       ,@StrChr                  VARCHAR(10)
	
	
	/* Retrieve Code-Formatting Parameters for the Code to be Formatted. */
	SELECT @MinimumNumDigits = [MinimumNumDigits]
	      ,@MaximumNumDigits        = [MaximumNumDigits]
	      ,@RemoveDashes            = [RemoveDashes]
	      ,@RemoveALLBlanks         = [RemoveALLBlanks]
	      ,@RemoveLeadingZeros      = [RemoveLeadingZeros]
	      ,@RemoveTrailingZeros     = [RemoveTrailingZeros]
	      ,@PadWithLeadingZeros     = [PadWithLeadingZeros]
	FROM   [dbo].[LkUpCodeType]
	WHERE  [CodeTypeCode]           = 'NDC'
	
	
	/* Removes Blanks (" ") from the Code to be formatted. */
	
	-- Removes both 'Leading' and 'Trailing' Blanks (" ") from the Code to be formmated. --
	SET @NDCCode = RTRIM(LTRIM(@NDCCode));
	
	-- Removes ALL Other Blanks (" ") from the Code to be formatted. --
	IF @RemoveALLBlanks = 1
	    SET @NDCCode = REPLACE(@NDCCode ,' ' ,'');
	
	
	/* Checks if the Code is an EMPTY string ("").  If the Code is an EMPTY string, no Code (NULL) is
	outputed. */
	IF @NDCCode = ''
	    SET @NDCCode = NULL;
	
	
	/* Removes 'Leading Zeros' from the Code being formatted, if 'Leading Zeros' are to be removed from the
	formatted code (RemoveLeadingZeros = 1). */
	IF @RemoveLeadingZeros = 1
	BEGIN
	    SET @StrLen = LEN(@NDCCode);
	    
	    SET @CurrentPtr = 1;
	    
	    WHILE (@CurrentPtr < @StrLen)
	    BEGIN
	        IF SUBSTRING(@NDCCode ,@CurrentPtr ,1) <> '0'
	            BREAK;
	        
	        SET @CurrentPtr = @CurrentPtr + 1
	    END
	    
	    SET @NDCCode = SUBSTRING(@NDCCode ,@CurrentPtr ,@StrLen);
	END
	
	
	/* Removes 'Trailing Zeros' from the Code being formatted, if 'Trailing Zeros' are to be removed from the
	formatted code (RemoveTrailingZeros = 1). */
	IF @RemoveTrailingZeros = 1
	BEGIN
	    SET @StrLen = LEN(@NDCCode);
	    
	    WHILE (@StrLen > 1)
	    BEGIN
	        IF SUBSTRING(@NDCCode ,@StrLen ,1) <> '0'
	            BREAK;
	        
	        SET @StrLen = @StrLen - 1;
	    END
	    
	    SET @NDCCode = SUBSTRING(@NDCCode ,1 ,@StrLen);
	END
	
	
	/* Checks if the Formatted Code has a 'Dash'.  If No, no Code (NULL) is outputed. */
	
	-- Formatted Code does not have a 'Dash'; no Code (NULL) is outputed. --
	IF (@NDCCode NOT LIKE '%-%')
	    SET @NDCCode = NULL
	ELSE
	BEGIN
	    -- Formatted Code has a 'Dash'; further processing and checks will be performed. --
	    
	    /* Checks if the Formatted Code meets the Code requirement for Code of its Code Type, the Number of Numeric Characters
	    BEFORE and AFTER the 'Dash in the Code, otherwise no Code (NULL) is outputed.  Also, along with the checks, padding
	    of Leading Zeros (as necessary) will be performed for the Numbers in each of the 3 segments that make up an NDC code
	    to conform to the '5-4-2' Code-Format. */
	    
	    -- Checks the format of the First-Segment of the Code. --
	    SET @CurrentPtr = CHARINDEX('-' ,@NDCCode ,1);
	    
	    SET @StrChr = SUBSTRING(@NDCCode ,1 ,@CurrentPtr - 1);
	    
	    SET @StrLen = LEN(@StrChr);
	    
	    IF (@StrLen < 4)
	    OR (@StrLen > 5)
	        --OR (@StrChr LIKE '[a-z]')
	        SET @NDCCode = NULL
	    ELSE
	    BEGIN
	        IF @StrLen = 4
	            SET @NDCCode_NEW = '0' + @StrChr;
	        ELSE
	        SET @NDCCode_NEW = @StrChr;
	    
	    -- Checks the format of the Second-Segment of the Code. --
	    SET @PreviousPtr = @CurrentPtr;
	    
	    SET @CurrentPtr = CHARINDEX('-' ,@NDCCode ,@CurrentPtr + 1);
	    
	    SET @StrChr = SUBSTRING(@NDCCode ,@PreviousPtr + 1 ,@CurrentPtr - @PreviousPtr - 1);
	    
	    SET @StrLen = LEN(@StrChr);
	    
	    IF (@StrLen < 3)
	    OR (@StrLen > 4)
	        --OR (@StrChr LIKE '[a-z]')
	        SET @NDCCode = NULL
	    ELSE
	    BEGIN
	        IF @StrLen = 3
	            SET @NDCCode_NEW = @NDCCode_NEW + '-' + '0' + @StrChr;
	        ELSE
	        SET @NDCCode_NEW = @NDCCode_NEW + '-' + @StrChr;
	    
	    -- Checks the format of the Third-Segment of the Code. --
	    SET @StrChr = SUBSTRING(@NDCCode ,@CurrentPtr + 1 ,LEN(@NDCCode) - @PreviousPtr);
	    
	    SET @StrLen = LEN(@StrChr);
	    
	    IF (@StrLen < 1)
	    OR (@StrLen > 2)
	        --OR (@StrChr LIKE '[a-z]')
	        SET @NDCCode = NULL
	    ELSE
	    BEGIN
	        IF @StrLen = 1
	            SET @NDCCode_NEW = @NDCCode_NEW + '-' + '0' + @StrChr;
	        ELSE
	        SET @NDCCode_NEW = @NDCCode_NEW + '-' + @StrChr;
	END
END
END
END


/* Sets the Code to the Formatted version of the Code. */
SET @NDCCode = @NDCCode_NEW;


/* Removes 'Dashes' from the Formatted Code. */
IF @RemoveDashes = 1
    SET @NDCCode = REPLACE(@NDCCode ,'-' ,'');


/* Verifies that the code being formatted code meets the 'Code Length' requirements -- both MINIMUM and MAXIMUM -- of Codes
of its Code Type. */
IF (LEN(@NDCCode) < @MinimumNumDigits)
OR (LEN(@NDCCode) > @MaximumNumDigits)
    SET @NDCCode = NULL;


-- Outputs the Formatted Code, or NULL. --
RETURN REPLACE(LTRIM(RTRIM((UPPER(@NDCCode)))) ,'*' ,'0');

END;
