
CREATE FUNCTION [dbo].[udf_dbAdmin_CaseFixString]
(
	@InputString VARCHAR(MAX)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @Index INT
	DECLARE @Char CHAR(1)
	DECLARE @OutputString VARCHAR(MAX)
	
	
	SET @OutputString = LOWER(@InputString)
	SET @Index = 2
	SET @OutputString = STUFF(@OutputString ,1 ,1 ,UPPER(SUBSTRING(@InputString ,1 ,1)))
	WHILE @Index <= LEN(@InputString)
	BEGIN
	    SET @Char = SUBSTRING(@InputString ,@Index ,1)
	    IF @Char IN (' ',';',':','!','?',',','.','_','-','/','&','''','(','[',']')
	        IF @Index + 1 <= LEN(@InputString)
	        BEGIN
	            IF @Char != ''''
	            OR UPPER(SUBSTRING(@InputString ,@Index + 1 ,1)) != 'S'
	                SET @OutputString = STUFF	(
												@OutputString
											   ,@Index + 1
											   ,1
											   ,UPPER(SUBSTRING(@InputString ,@Index + 1 ,1)))
	        END
	    
	    SET @Index = @Index + 1
	END
	IF CHARINDEX(' i',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' i',' I')
	END
	IF CHARINDEX(' ii',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' ii',' II')
	END
	IF CHARINDEX(' iii',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' iii',' III')
	END
	IF CHARINDEX(' vi',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' vi',' VI')
	END
	IF CHARINDEX(' v',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' v',' V')
	END
	IF CHARINDEX('-i',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, '-i','-I')
	END
	IF CHARINDEX('-ii',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, '-ii','-II')
	END
	IF CHARINDEX('-iii',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, '-iii','-III')
	END
	IF CHARINDEX('-vi',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, '-vi','-VI')
	END
	IF CHARINDEX('-v',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, '-v','-V')
	END
	IF CHARINDEX(' usa ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' usa ',' USA ')
	END
	IF CHARINDEX(' or ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' or ',' or ')
	END
	IF CHARINDEX(' of ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' of ',' of ')
	END
	IF CHARINDEX(' an ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' an ',' an ')
	END
	IF CHARINDEX(' in ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' in ',' in ')
	END
	IF CHARINDEX(' in ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' on ',' on ')
	END
	IF CHARINDEX(' by ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' by ',' by ')
	END
	IF CHARINDEX(' the ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' the ',' the ')
	END
	IF CHARINDEX(' and ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' and ',' and ')
	END
	IF CHARINDEX(' for ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' for ',' for ')
	END
	IF CHARINDEX(' to ',@OutputString)>0 
	BEGIN
		SET @OutputString = REPLACE(@OutputString, ' to ',' to ')
	END
	
	IF CHARINDEX(' ',@OutputString)=0 and LEN(@OutputString)<7
	BEGIN
		SET @OutputString = UPPER(@OutputString)
	END
	
	IF LEN(@OutputString)=0
	BEGIN
		SET @OutputString = NULL
	END
	
	RETURN @OutputString
END 

