/*    
------------------------------------------------------------------------------    
Procedure Name: [usp_LoginAudit_Insert]
Description   : This Procedure is used to insert values into LoginAudit 
Created By    : NagaBabu
Created Date  : 21-July-2011
------------------------------------------------------------------------------    
Log History   :     
DD-MM-YYYY  BY   DESCRIPTION   
Santosh :added Userid Insert 
------------------------------------------------------------------------------    
*/  


--SELECT * FROM LOGINAUDIT order by 1 desc
--exec usp_LoginAudit_Insert 'admin1','192.168.10.57','S',''
CREATE PROCEDURE [dbo].[usp_LoginAudit_Insert]  
(  
	@v_LoginName VARCHAR(50),
	@v_IPAddress VARCHAR(50),
	@v_LoginStatus VARCHAR(6),
	@o_AuditId KEYID
	
)  
AS  
	SET NOCOUNT ON  
	DECLARE @l_numberOfRecordsInserted INT
	DECLARE @index1 INT
	
	DECLARE @ID INT
	
	 SELECT @ID = P.ProviderID FROM Users U
	  INNER JOIN UserGroup UG 
       ON U.UserId = UG.UserID
	  INNER JOIN Provider P
	   ON UG.ProviderID = P.ProviderID
   WHERE UserLoginName = @v_LoginName
        
			
	INSERT INTO LoginAudit
	(
		LoginName,
		IPAddress,
		LoginStatus,
		Userid
	)
	VALUES
	(
		@v_LoginName,
		@v_IPAddress,
		@v_LoginStatus,
		@ID
	)	
		
    SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
          ,@o_AuditId = SCOPE_IDENTITY()
          
          SELECT  @index1 = @o_AuditId
          SELECT @index1  
   
          


    IF @l_numberOfRecordsInserted <> 1          
	BEGIN          
		RAISERROR      
			(  N'Invalid row count %d in insert LoginAudit table'
				,17      
				,1      
				,@l_numberOfRecordsInserted                 
			)              
	END  

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_LoginAudit_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

