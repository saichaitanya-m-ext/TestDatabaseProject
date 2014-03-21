CREATE  PROCEDURE [dbo].[sproc_Insertusers]  
(  
	@id INT OUT,  
	@uname NVARCHAR(50),  
	@pwd NVARCHAR(50)  
)  
AS INSERT INTO tbl_register  
(  
	[uname],  
	[pwd]  
)  
VALUES  
(  
	@uname,  
	@pwd  
)  
  
SET @id = @@identity  
RETURN @id

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[sproc_Insertusers] TO [FE_rohit.r-ext]
    AS [dbo];

