	CREATE PROCEDURE [dbo].spc_TrackDependencies      
	    (    @ObjectName SYSNAME,       
	        @ObjectType VARCHAR(5) = NULL       
	)       
	AS       
	BEGIN       
	    DECLARE @ObjectID AS BIGINT        
	       
 	        SELECT TOP(1) @ObjectID = object_id       
 	          FROM sys.objects       
 	         WHERE name = @ObjectName       
 	           AND type = ISNULL(@ObjectType, type)        
 	       
 	    SET NOCOUNT ON ;        
 	       
 	      WITH DependentObjectCTE (     
 	                                DependentObjectID     
 	                              , DependentObjectName     
 	                              , ReferencedObjectName     
 	                              , ReferencedObjectID     
 	                              )       
 	        AS       
 	        (       
 	          SELECT DISTINCT  sd.object_id     
 	               , OBJECT_NAME(sd.object_id)     
 	               , ReferencedObject = OBJECT_NAME(sd.referenced_major_id)     
 	               , ReferencedObjectID = sd.referenced_major_id       
 	            FROM sys.sql_dependencies sd       
 	            JOIN sys.objects so      
 	              ON sd.referenced_major_id = so.object_id       
 	           WHERE sd.referenced_major_id = @ObjectID       
 	       UNION ALL       
 	             
 	          SELECT sd.object_id     
 	               , OBJECT_NAME(sd.object_id)     
 	               , OBJECT_NAME(referenced_major_id)     
 	               , object_id       
 	            FROM sys.sql_dependencies sd       
 	            JOIN DependentObjectCTE do      
 	              ON sd.referenced_major_id = do.DependentObjectID              
 	           WHERE sd.referenced_major_id <> sd.object_id            
 	        )       
 	        SELECT DISTINCT       
 	               DependentObjectName       
 	        FROM          
 	               DependentObjectCTE c       
 	END    
 	 
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[spc_TrackDependencies] TO [FE_rohit.r-ext]
    AS [dbo];

