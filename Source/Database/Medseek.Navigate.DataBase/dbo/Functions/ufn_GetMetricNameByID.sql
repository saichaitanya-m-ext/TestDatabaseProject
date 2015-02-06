  
  
  
/*                  
------------------------------------------------------------------------------                  
Function Name: [ufn_GetMetricNameByID]  
Description   : This Function is used to get Metric for a particular ID.  
Created By    : Gurumoorthy
Created Date  : 17-Dec-2010  
------------------------------------------------------------------------------  
Log History :  
DD-MM-YYYY     BY      DESCRIPTION  
------------------------------------------------------------------------------                  
*/  
  
CREATE FUNCTION [dbo].[ufn_GetMetricNameByID]  
     (  
        @i_MetricId KEYID  
     )  
RETURNS VARCHAR(150)  
AS  
BEGIN  
      DECLARE @v_MetricName VARCHAR(150)  
      SELECT @v_MetricName = name  
   FROM   
       Metric   
   WHERE  
       MetricId = @i_MetricId  
      RETURN @v_MetricName  
END  
  
  