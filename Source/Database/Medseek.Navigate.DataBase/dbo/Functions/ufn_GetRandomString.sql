CREATE FUNCTION [dbo].[ufn_GetRandomString] (@i_Length int) 
RETURNS varchar(100)
WITH EXECUTE AS CALLER
AS
BEGIN
  DECLARE @v_Result Varchar(100)
  SET @v_Result = ''
  DECLARE @i_Counter int
  SET @i_Counter = 0
  WHILE @i_Counter <= @i_Length
  BEGIN
     SET @v_Result = @v_Result + Char(Ceiling((select RandomNumber from vw_RandomHelper) * 26) + 64)       
     SET @i_Counter = @i_Counter + 1   
  END
  DECLARE @v_Numbers VARCHAR(5)
  select @v_Numbers = substring(convert(varchar,RandomNumber),3,4) from vw_RandomHelper
  set @v_Result =  @v_Numbers + ' '+ SUBSTRING(@v_Result,1,10) + '@' + SUBSTRING(@v_Result,11,20) + '.com'
  RETURN(lower(@v_Result))
END