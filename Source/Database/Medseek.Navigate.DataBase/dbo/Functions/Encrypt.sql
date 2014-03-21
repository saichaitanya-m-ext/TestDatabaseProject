    
      
CREATE FUNCTION [dbo].[Encrypt]      
(       
 @v_Value VARCHAR(200)      
)       
RETURNS VARBINARY(MAX)      
AS       
BEGIN       
    DECLARE @v_Result VARBINARY(MAX)      
          
    DECLARE @SaltKey VARCHAR(max)      
    SET @SaltKey = (      
    SELECT  BulkColumn       
        FROM OPENROWSET (BULK 'd:\SQL2008_Other_Backups\DBTracking\Ram\abcd.txt', SINGLE_CLOB) MyFile )       
      
        
    SELECT @v_Result = ENCRYPTBYPASSPHRASE(@SaltKey, @v_Value )      
        
    RETURN @v_Result       
END       
      
      
--select [dbo].[Encrypt]('xxx')      