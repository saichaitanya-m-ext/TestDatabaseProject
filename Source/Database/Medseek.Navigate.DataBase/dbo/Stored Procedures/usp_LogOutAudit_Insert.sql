

CREATE PROCEDURE [dbo].[usp_LogOutAudit_Insert]  
( 
	@AppUserId INT,
	@v_IPAddress VARCHAR(50)
	
)  
AS  
BEGIN 
INSERT INTO LogOutAudit
(
  AppUserId,
  IPAddress
)
VALUES
(
  @AppUserId, 
  @v_IPAddress
)
END 

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LogOutAudit_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

