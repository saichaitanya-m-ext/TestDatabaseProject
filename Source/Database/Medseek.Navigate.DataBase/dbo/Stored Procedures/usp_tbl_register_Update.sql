
create PROCEDURE [dbo].[usp_tbl_register_Update]  
(  
	@i_Id KeyID,
	@vc_Name ShortDescription, 
	@vc_PW ShortDescription
)  
AS  
begin 
	
	 UPDATE tbl_register
	    SET	uname = @vc_Name,
	        pwd = @vc_PW
			
			
	  WHERE id = @i_Id
      
    SELECT @i_Id 
 end 
   

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_tbl_register_Update] TO [FE_rohit.r-ext]
    AS [dbo];

