    
    
CREATE FUNCTION [dbo].[Decrypt]    
(     
 @v_Value VARCHAR(MAX)    
)     
RETURNS VARCHAR(300)    
AS     
BEGIN     
    DECLARE @v_Result VARCHAR(300)    
        
    DECLARE @SaltKey VARCHAR(100)    
    SET @SaltKey = (    
    SELECT  BulkColumn     
        FROM OPENROWSET (BULK 'D:\SQL2008_Other_Backups\DBTracking\Ram\abcd.txt', SINGLE_CLOB) MyFile )     
    
      
    SELECT @v_Result = DECRYPTBYPASSPHRASE(@SaltKey, @v_Value )    
      
    RETURN @v_Result     
END     
    
