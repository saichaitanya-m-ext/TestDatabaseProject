/*
-----------------------------------------------------------------------------
Procedure Name: Usp_Library_Insert
Description	  : This procedure is used to insert the data in Library table. 
Created By    : Aditya
Created Date  : 12-Jan-2010
-----------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
28-June-2010  NagaBabu	Added WebSiteURLLink to the INSERT statement
01-feb-2012 Sivakrishna added @b_IsMarkAsEvidence  as per sage requirement
03-feb-2012 NagaBabu Removed Library.IsMarkAsEvidence column and Related Input parameter as per dev
22-Aug-2012 P.V.P.Mohan added @b_IsPEM as per sage requirement
------------------------------------------------------------------------------
*/


CREATE PROCEDURE [dbo].[usp_Library_Insert]     
(
	@i_AppUserId  KeyID,	
	@i_DocumentTypeId KeyID,
	@vc_Name ShortDescription,
	@vc_Description LongDescription,
	@vc_PhysicalFileName LongDescription, 
	@vc_DocumentNum VARCHAR(15),
	@vc_DocumentLocation ShortDescription,
	@vc_eDocument VARBINARY(MAX),
	@vc_DocumentSourceCompany VARCHAR (100),
	@vc_StatusCode StatusCode,
	@vc_MimeType VARCHAR(20),
	@vc_WebSiteURLLink VARCHAR(200), 
	@b_IsPEM BIT = 0 , 
	@o_LibraryID KeyId OUTPUT
)

AS

BEGIN TRY 
	SET NOCOUNT ON	
	DECLARE @l_numberOfRecordsInserted INT
	-- Check if valid Application User ID is passed
	IF(@i_AppUserId IS NULL) OR (@i_AppUserId <= 0)
	BEGIN
		RAISERROR
		(	 N'Invalid Application User ID %d passed.'
			,17
			,1
			,@i_AppUserId
		)
	END
	--------- Insert Operation into Library Table starts here ------------------------

	INSERT INTO Library
			(	
				DocumentTypeId,
				Name,
				Description,
				PhysicalFileName,
				DocumentNum,
				DocumentLocation,
				eDocument,
				DocumentSourceCompany,
				StatusCode,
				MimeType,
				WebSiteURLLink,
				IsPEM,
				CreatedByUserId
      		)
		VALUES
			(
			 	@i_DocumentTypeId,
				@vc_Name,
				@vc_Description,
				@vc_PhysicalFileName,
				@vc_DocumentNum,
				@vc_DocumentLocation,
				@vc_eDocument,
				@vc_DocumentSourceCompany,
				@vc_StatusCode,
				@vc_MimeType,
				@vc_WebSiteURLLink,
				@b_IsPEM ,
				@i_AppUserId
				
			)

	 SELECT @l_numberOfRecordsInserted = @@ROWCOUNT
		   ,@o_LibraryID = SCOPE_IDENTITY()
				
		    IF @l_numberOfRecordsInserted <> 1          
			BEGIN          
				RAISERROR      
					(  N'Invalid row count %d in insert into Library Table'
						,17      
						,1      
						,@l_numberOfRecordsInserted                 
					)              
			 END  

	      RETURN  0 
	
END TRY 
BEGIN CATCH
    -- Handle exception
    DECLARE @i_ReturnedErrorID	INT
    
    EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException
				@i_UserId = @i_AppUserId
                        
    RETURN @i_ReturnedErrorID
    
END CATCH

GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_Library_Insert] TO [FE_rohit.r-ext]
    AS [dbo];

