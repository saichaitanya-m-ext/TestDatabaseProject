/*
--------------------------------------------------------------------------------
Procedure Name: [dbo].[usp_PatientEducationMaterial_Select]
Description	  : This procedure is used to get the details of PatientEducationMaterial.
Created By    :	Rathnam 
Created Date  : 24-May-2011
---------------------------------------------------------------------------------
Log History   : 
DD-MM-YYYY		BY			DESCRIPTION
31-May-2011		Gurumoorthy Added Case statement for status code Active/Inactive
10-Dec-2012 Rathnam removed the disease id 
25-Mar-2013 P.V.P.MOhan Modified PatientID in place of PatientUserID for PatientEducationMaterial table
			and Users table to Pateint table.
---------------------------------------------------------------------------------
*/
CREATE PROCEDURE [dbo].[usp_PatientEducationMaterial_Select]
       (
        @i_AppUserId KEYID
       ,@i_PatientUserID KeyID  
       ,@i_PatientEducationMaterialID KEYID = NULL
       ,@v_StatusCode StatusCode = NULL
       )
       
AS
BEGIN TRY 

	-- Check if valid Application User ID is passed
      IF ( @i_AppUserId IS NULL ) OR ( @i_AppUserId <= 0 )
         BEGIN
               RAISERROR ( N'Invalid Application User ID %d passed.'
               ,17
               ,1
               ,@i_AppUserId )
         END

      SELECT
		  pem.PatientEducationMaterialID,
		  em.Name PEMTaskName,
		  pem.PatientID PatientUserID,
		  pem.DueDate,
		  pem.IsPatientViewable,
		  pem.Comments,
		  CASE pem.StatusCode
            WHEN 'A' THEN 'Active'
            WHEN 'I' THEN 'InActive'
          END AS StatusCode,
		  pem.ProviderID ProviderUserID,
		  (
		   SELECT COALESCE(ISNULL(provider.LastName , '') + ', '   
				+ ISNULL(provider.FirstName , '') + '. '   
				+ ISNULL(provider.MiddleName , '') ,'')
		   FROM
		   provider 
		   WHERE ProviderID = pem.ProviderID
		   )AS ProviderName ,
		  pem.CreatedByUserId,
		  pem.CreatedDate,
		  pem.LastModifiedByUserId,
		  pem.LastModifiedDate,
		  pem.DateSent,		  
		  p.ProgramName,
		  p.ProgramId
      FROM
          PatientEducationMaterial pem WITH(NOLOCK)
      INNER JOIN EducationMaterial em WITH(NOLOCK)
          ON pem.EducationMaterialID = em.EducationMaterialID 
      INNER JOIN Program p WITH(NOLOCK)
          ON p.ProgramId = pem.ProgramID       
      WHERE
          pem.PatientID = @i_PatientUserID
      AND (pem.PatientEducationMaterialID = @i_PatientEducationMaterialID OR @i_PatientEducationMaterialID IS NULL)    
      AND (pem.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)  
      AND ((IsPatientViewable = 1  AND @i_AppUserId = @i_PatientUserID) OR @i_AppUserId <> @i_PatientUserID)
      
      IF (@i_PatientEducationMaterialID IS NOT NULL)
      BEGIN
	             
		  SELECT
		      peml.PatientEducationMaterialID,
		      peml.LibraryId AS ID,
		      --NULL AS DocumentID,
		      l.Name,
		      NULL AS Content,
		      'Library' AS 'Type',
		      l.MimeType
		  FROM
		      PatientEducationMaterial pem WITH(NOLOCK)
		  INNER JOIN PatientEducationMaterialLibrary peml WITH(NOLOCK)
		      ON pem.PatientEducationMaterialID = peml.PatientEducationMaterialID    
		  INNER JOIN Library l WITH(NOLOCK)
		      ON l.LibraryId = peml.LibraryId
		  WHERE pem.PatientEducationMaterialID = @i_PatientEducationMaterialID
		    AND pem.PatientID = @i_PatientUserID
		    AND (pem.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)
		  UNION        
		  SELECT
			  pemd.PatientEducationMaterialID,
			  --NULL AS LibraryID,
			  pemd.PatientEducationMaterialDocumentsID AS ID,
			  pemd.DcoumentName,
			  pemd.Content,
			  'Document' AS 'Type',
			  pemd.MimeType
		  FROM
		      PatientEducationMaterial pem WITH(NOLOCK)
		  INNER JOIN PatientEducationMaterialDocuments pemd WITH(NOLOCK)
		      ON pem.PatientEducationMaterialID = pemd.PatientEducationMaterialID    
		  WHERE
			  pem.PatientEducationMaterialID = @i_PatientEducationMaterialID
		  AND pem.PatientID = @i_PatientUserID	  
		  AND (pem.StatusCode = @v_StatusCode  OR @v_StatusCode IS NULL)
		  
		  SELECT
		      peml.PatientEducationMaterialID,
		      peml.LibraryId ,
		      l.Name,
		      l.MimeType
		  FROM
		      PatientEducationMaterial pem WITH(NOLOCK)
		  INNER JOIN PatientEducationMaterialLibrary peml WITH(NOLOCK)
		      ON pem.PatientEducationMaterialID = peml.PatientEducationMaterialID    
		  INNER JOIN Library l WITH(NOLOCK)
		      ON l.LibraryId = peml.LibraryId
		  WHERE pem.PatientEducationMaterialID = @i_PatientEducationMaterialID
		    AND pem.PatientID = @i_PatientUserID
		    AND (pem.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL )
		          
		  SELECT
			  pemd.PatientEducationMaterialID,
			  pemd.PatientEducationMaterialDocumentsID ,
			  pemd.DcoumentName,
			  pemd.Content,
			  pemd.MimeType
		  FROM
		      PatientEducationMaterial pem WITH(NOLOCK)
		  INNER JOIN PatientEducationMaterialDocuments pemd WITH(NOLOCK)
		      ON pem.PatientEducationMaterialID = pemd.PatientEducationMaterialID    
		  WHERE
			  pem.PatientEducationMaterialID = @i_PatientEducationMaterialID
		  AND pem.PatientID = @i_PatientUserID	  
		  AND (pem.StatusCode = @v_StatusCode OR @v_StatusCode IS NULL)     
     END
    			  
END TRY
---------------------------------------------------------------------------------------------------------------
BEGIN CATCH
    -- Handle exception
      DECLARE @i_ReturnedErrorID INT
      EXECUTE @i_ReturnedErrorID = dbo.usp_HandleException @i_UserId = @i_AppUserId

      RETURN @i_ReturnedErrorID
END CATCH



GO
GRANT EXECUTE
    ON OBJECT::[dbo].[usp_PatientEducationMaterial_Select] TO [FE_rohit.r-ext]
    AS [dbo];

