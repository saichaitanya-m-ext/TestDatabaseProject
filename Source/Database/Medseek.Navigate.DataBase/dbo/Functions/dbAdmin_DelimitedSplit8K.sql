




CREATE FUNCTION [dbo].[dbAdmin_DelimitedSplit8K]
(
	@pString         VARCHAR(7999),
	@pDelimiter1     CHAR(1),
	@pDelimiter2     CHAR(1)
)
RETURNS TABLE
WITH SCHEMABINDING
AS



RETURN
--===== "Inline" CTE Driven "Tally Table” produces values up to
-- 10,000... enough to cover VARCHAR(8000)
WITH E1(N) 
AS (
       --=== Create Ten 1's
       SELECT 1 UNION ALL SELECT 1 
       UNION ALL
       SELECT 1 UNION ALL SELECT 1 
       UNION ALL
       SELECT 1 UNION ALL SELECT 1 
       UNION ALL
       SELECT 1 UNION ALL SELECT 1 
       UNION ALL
       SELECT 1 UNION ALL SELECT 1 --10
   ),
      E2(N) AS (
                   SELECT 1
                   FROM   E1     a,
                          E1     b
               ),   --100
      E4(N) AS (
                   SELECT 1
                   FROM   E2     a,
                          E2     b
               ),   --10,000
cteTally(N) AS (
                   SELECT ROW_NUMBER() OVER(
                              ORDER BY(
                                  SELECT N
                              )
                          )
                   FROM   E4
               )  
--===== Do the split
,Result(ItemNumber, item) AS (
                                 SELECT ROW_NUMBER() OVER(ORDER BY N) AS 
                                        ItemNumber,
                                        SUBSTRING(
                                            @pString,
                                            N,
                                            CHARINDEX(@pDelimiter1, @pString + @pDelimiter1, N) 
                                            - N
                                        ) AS Item
                                 FROM   cteTally
                                 WHERE  N < LEN(@pString) + 2
                                        AND SUBSTRING(@pDelimiter1 + @pString, N, 1) = 
                                            @pDelimiter1
                                 UNION 
                                 SELECT ROW_NUMBER() OVER(ORDER BY N) AS 
                                        ItemNumber,
                                        SUBSTRING(
                                            @pString,
                                            N,
                                            CHARINDEX(@pDelimiter2, @pString + @pDelimiter2, N) 
                                            - N
                                        ) AS Item
                                 FROM   cteTally
                                 WHERE  N < LEN(@pString) + 2
                                        AND SUBSTRING(@pDelimiter2 + @pString, N, 1) = 
                                            @pDelimiter2
                             )
SELECT MAX(ItemNumber) AS ItemNumber,
       MIN(LTRIM(RTRIM(Item))) AS Item
FROM   result
GROUP BY ItemNumber
/* 
WHERE  @pString <> CASE 
                        WHEN (
                                 CHARINDEX(@pDelimiter1, @pString) = 0
                                 OR CHARINDEX(@pDelimiter2, @pString) = 0
                             ) THEN '1900BC'
                        ELSE Item
                   END */
 ;

