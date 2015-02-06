--select * from aspnet_Membership where Email ='venugopalrao.gone@symphonycorp.com'  
  
  
CREATE procedure [dbo].[usp_Expirydate_Update]  
(  
@PasswordExpiryDate datetime,  
@PrimaryEmailid varchar(100)  
)  
as begin  
update aspnet_Membership set [passwordExpireDate] = convert(date,@PasswordExpiryDate) where [Email] = @PrimaryEmailid  
END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Expirydate_Update] TO [FE_rohit.r-ext]
    AS [dbo];

