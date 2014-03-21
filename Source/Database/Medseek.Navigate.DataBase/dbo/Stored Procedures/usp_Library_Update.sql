/*  
-----------------------------------------------------------------------------------------------  
Procedure Name: [dbo].[Usp_Library_Update]  
Description   : This procedure is used to update the data from Library based on the LibraryId.   
Created By    : Aditya  
Created Date  : 12-Jan-2010  
------------------------------------------------------------------------------------------------  
Log History   :   
DD-MM-YYYY  BY   DESCRIPTION  
28-June-2010  NagaBabu	Added WebSiteURLLink to the update statement  
29-Sep-10 Pramod Used ISNULL for eDocument, Documentlocation and physical file name
01-feb-2012 Sivakrishna added @b_IsMarkAsEvidence  as per sage requirement
03-feb-2012 NagaBabu Removed Library.IsMarkAsEvidence column and Related Input parameter as per dev
22-Aug-2012 P.V.P.Mohan added @b_IsPEM as per sage requirement
------------------------------------------------------------------------------------------------  
*/  

CREATE PROCEDURE [dbo].[usp_Library_Update]  
(  
  
 @i_AppUserId  KeyID,   
 @i_DocumentTypeId KeyID,  
 @vc_Name ShortDescription,  
 @vc_Description LongDescription,  
 @vc_PhysicalFileName LongDescription,   
 @vc_DocumentNum VARCHAR (15),  
 @vc_DocumentLocation ShortDescription,  
 @vc_eDocument VARBINARY(MAX),  
 @vc_DocumentSourceCompany VARCHAR(100),  
 @vc_StatusCode StatusCode,  
 @vc_MimeType VARCHAR(20),  
 @i_LibraryID KeyID ,
 @b_IsPEM BIT = 0 ,
 @vc_WebSiteURLLink VARCHAR(200) 
)  
      
AS  
BEGIN TRY   
  
	 SET NOCOUNT ON   
	 -- Check if valid Application User ID is passed  
	 DECLARE @i_numberOfRecordsUpdated INT  
	 IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)  
	  
	 BEGIN  
	     RAISERROR  
	     (  N'Invalid Application User ID %d passed.'  
	         ,17  
	         ,1  
	         ,@i_AppUserId  
	     )  
	 END  
	------------    Updation operation takes place   --------------------------  
	     
	 UPDATE 
		Library  
	 SET 
		DocumentTypeId = @i_DocumentTypeId ,  
		Name = @vc_Name ,  
		Description = @vc_Description ,  
		PhysicalFileName = ISNULL(@vc_PhysicalFileName, PhysicalFileName) ,   
		DocumentNum = @vc_DocumentNum ,  
		DocumentLocation = ISNULL(@vc_DocumentLocation, DocumentLocation) ,  
		eDocument = ISNULL(@vc_eDocument, eDocument) , 
		DocumentSourceCompany = @vc_DocumentSourceCompany ,  
		MimeType = @vc_MimeType,  
		LastModifiedByUserId = @i_AppUserId,  
		LastModifiedDate = GETDATE(),  
		StatusCode = @vc_StatusCode ,
		WebSiteURLLink = @vc_WebSiteURLLink,
		IsPEM  = @b_IsPEM 
	WHERE   
		LibraryId = @i_LibraryId       
	         
	   SET @i_numberOfRecordsUpdated = @@ROWCOUNT  
	     
	   IF @i_numberOfRecordsUpdated <> 1   
		RAISERROR  
			(  N'Update of Library table experienced invalid row count of %d'  
			    ,17  
			    ,1  
			    ,@i_numberOfRecordsUpdated           
			)          
	     
	 RETURN 0  
      
   
END TRY   
------------ Exception Handling --------------------------------  
BEGIN CATCH  
    DECLARE @i_ReturnedErrorID INT  
      
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException  
    @i_UserId = @i_AppUserId  
                          
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Library_Update] TO [FE_rohit.r-ext]
    AS [dbo];

