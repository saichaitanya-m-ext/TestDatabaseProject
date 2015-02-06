CREATE TABLE [dbo].[EducationMaterialLibrary] (
    [EducationMaterialID] [dbo].[KeyID]    NOT NULL,
    [LibraryId]           [dbo].[KeyID]    NOT NULL,
    [TaskBundleID]        [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]     [dbo].[KeyID]    NULL,
    [CreatedDate]         [dbo].[UserDate] CONSTRAINT [DF_EducationMaterialLibrary_CreatetdDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_EducationMaterialLibrary] PRIMARY KEY CLUSTERED ([EducationMaterialID] ASC, [LibraryId] ASC, [TaskBundleID] ASC),
    CONSTRAINT [FK_EducationMaterialLibrary_LibraryId] FOREIGN KEY ([LibraryId]) REFERENCES [dbo].[Library] ([LibraryId]),
    CONSTRAINT [FK_EducationMaterialLibrary_TaskBundleID] FOREIGN KEY ([TaskBundleID]) REFERENCES [dbo].[TaskBundle] ([TaskBundleId])
);


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Insert_EducationMaterialLibrary]
Description: This trigger is used to track the history of a Library modifications from the EducationMaterialLibrary table.                 
When   Who   Action                    
---------------------------------------------------------------------    
14-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Insert_EducationMaterialLibrary] ON [dbo].[EducationMaterialLibrary]
       AFTER INSERT
AS
BEGIN
      SET NOCOUNT ON


      UPDATE
          TaskBundleHistory
      SET
          PEMList = 
          --ISNULL(PEMList , '') +
           STUFF(( SELECT 
                          '$$' +CONVERT(VARCHAR , i.LibraryId)+ '-' + CONVERT(VARCHAR , i.EducationMaterialID) + '*I '
                      
      
          FROM inserted i
          WHERE i.EducationMaterialID = inserted.EducationMaterialID
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
          
      FROM
          EducationMaterial
          INNER JOIN inserted
          ON inserted.EducationMaterialID = EducationMaterial.EducationMaterialID
          INNER JOIN TaskBundle
          ON TaskBundle.TaskBundleId = inserted.TaskBundleID
      WHERE
          TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1) 
          
      
END








GO
DISABLE TRIGGER [dbo].[tr_Insert_EducationMaterialLibrary]
    ON [dbo].[EducationMaterialLibrary];


GO


/*                    
---------------------------------------------------------------------    
Trigger Name: [dbo].[tr_Delete_EducationMaterialLibrary]
Description: This trigger is used to track the history of a Library modifications from the EducationMaterialLibrary table.                 
When   Who   Action                    
---------------------------------------------------------------------    
14-Sep-2012  Rathnam Created                    
            
---------------------------------------------------------------------    
*/
CREATE TRIGGER [dbo].[tr_Delete_EducationMaterialLibrary] ON [dbo].[EducationMaterialLibrary]
       AFTER DELETE
AS
BEGIN
      SET NOCOUNT ON


      UPDATE
          TaskBundleHistory
      SET
          PEMList = 
          --ISNULL(PEMList , '') +
           STUFF(( SELECT 
                          '$$' +CONVERT(VARCHAR , i.LibraryId)+ '-' + CONVERT(VARCHAR , i.EducationMaterialID) + '*D '
                      
      
          FROM deleted i
          WHERE i.EducationMaterialID = deleted.EducationMaterialID
                      FOR
                          XML PATH('') ) , 1 , 0 , '') 
          
      FROM
           deleted
          INNER JOIN TaskBundle
          ON TaskBundle.TaskBundleId = deleted.TaskBundleID
          INNER JOIN EducationMaterial
          ON EducationMaterial.EducationMaterialID = deleted.EducationMaterialID
      WHERE
          TaskBundleHistory.TaskBundleId = TaskBundle.TaskBundleId
          AND TaskBundleHistory.DefinitionVersion = CONVERT(VARCHAR , CONVERT(DECIMAL(10,1) , TaskBundle.DefinitionVersion) - .1) 
          
      
END








GO
DISABLE TRIGGER [dbo].[tr_Delete_EducationMaterialLibrary]
    ON [dbo].[EducationMaterialLibrary];


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EducationMaterialLibrary', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'EducationMaterialLibrary', @level2type = N'COLUMN', @level2name = N'CreatedDate';

