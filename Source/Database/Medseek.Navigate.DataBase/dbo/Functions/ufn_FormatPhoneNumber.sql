--DROP FUNCTION [ufn.FormatPhoneNumber]

CREATE FUNCTION [dbo].[ufn_FormatPhoneNumber] 
(
    @Number money
)
RETURNS varchar(25)
AS
BEGIN

    -- Declare the return variable here
    DECLARE @Formatted varchar(25)  -- Formatted number to return
    DECLARE @CharNum varchar(18)    -- Character type of phone number
    DECLARE @Extension int         -- Phone extesion
    DECLARE @Numerator bigint         -- Working number variable

    IF @Number IS NULL 
    BEGIN
        --Just return NULL if input string is NULL
        RETURN NULL
    END

    -- Just enough room, since max phone number
    -- digits is 14 + 4 for extension is 18

    -- Get rid of the decimal
    SET @Numerator = CAST(@Number * 10000 AS bigint)
    -- Cast to int to strip off leading zeros
    SET @Extension = CAST(RIGHT(@Numerator, 4) AS int)
    -- Strip off the extension
    SET @CharNum = CAST(LEFT(@Numerator , LEN(@Numerator) - 4) 
        AS varchar(18))

    IF LEN(@CharNum) = 10    -- Full phone number, return (905) 555-1212
      BEGIN
                
        SET @Formatted = '(' + LEFT(@CharNum, 3) + ') ' + 
            SUBSTRING(@CharNum,4,3) + '' + RIGHT(@CharNum, 4)

        IF @Extension > 0    -- Add Extension
        BEGIN
            SET @Formatted = @Formatted +  ' ext '+ 
                             CAST(@Extension AS varchar(4))
        END

        RETURN @Formatted
      END

    IF LEN(@CharNum) = 7    -- No Area Code, return 555-1212
      BEGIN
        SET @Formatted = LEFT(@CharNum, 3) + '' + RIGHT(@CharNum, 4)
        IF @Extension > 0    -- Add Extension
        BEGIN
            SET @Formatted = @Formatted +  ' ext '+ 
                             CAST(@Extension AS varchar(6))
        END

        RETURN @Formatted
      END

    IF LEN(@CharNum) = 11
    -- Full phone number with access code,
    -- return  1 (905) 555-1212  (19055551212)
      BEGIN
                
        SET @Formatted = LEFT(@CharNum, 1) + ' (' + SUBSTRING(@CharNum, 2, 3) + ') ' + 
                         SUBSTRING(@CharNum,4,3) + '' + RIGHT(@CharNum, 4)

        IF @Extension > 0    -- Add Extension
        BEGIN
            SET @Formatted = @Formatted +  ' ext '+ CAST(@Extension AS varchar(4))
        END

        RETURN @Formatted
      END

    
    -- Last case, just return the number unformatted (unhandled format)
    SET @Formatted = @CharNum
    IF @Extension > 0    -- Just the Extension
      BEGIN
        SET @Formatted = @Formatted +  ' ext '+ CAST(@Extension AS varchar(4))
        RETURN 'ext '+ CAST(@Extension AS varchar(4))
        
      END

    RETURN @Formatted

END
