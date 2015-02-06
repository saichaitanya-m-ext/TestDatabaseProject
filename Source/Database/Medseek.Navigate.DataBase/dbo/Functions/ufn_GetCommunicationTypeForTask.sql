/*                
------------------------------------------------------------------------------                
Function Name: ufn_GetCommunicationTypeForTask
Description   : This Function Returns measure trend Value for patient
Created By    : Pramod
Created Date  : 29-June-2010
------------------------------------------------------------------------------
Log History :
DD-MM-YYYY     BY      DESCRIPTION
11-Aug-10 Pramod Query for getting the communicationsequence is changed to
include join of TaskTypeCommunications since the communicationsequence field
is removed as part of db design
12-Oct-2010 NagaBabu Added TaskTypeCommunications.TaskTypeID in Where clause in first select Statement
15-Oct-2010 Rathnam second select statement communication sequence order by changed as asc
29-Nov-2010 Rathnam added Exist Clause and @i_TaskTypeGeneralizedID,@v_TaskTypeName Two parameters 
                    & ufn_GetTypeIDByTaskGeneralizedId function for getting typeid.
23-Dec-2010 Rathnam  Removed the Attemptedcontactdate and place 
                     TaskTypeCommunications.CommunicationSequence added in where clause.                   
------------------------------------------------------------------------------                
*/

CREATE FUNCTION [dbo].[ufn_GetCommunicationTypeForTask]
     (
        @i_TaskId KEYID
       ,@i_TasktypeId KEYID
       ,@i_TaskTypeGeneralizedID KEYID
       ,@v_TaskTypeName SOURCENAME
     )
RETURNS VARCHAR(50)
AS
BEGIN
      DECLARE
              @v_CommunicationType SOURCENAME
             ,@i_CommunicationSequence INT
             ,@i_TypeID KEYID
             
      SELECT @i_TypeID = dbo.ufn_GetTypeIDByTaskGeneralizedId(@v_TaskTypeName , @i_TaskTypeGeneralizedID)

      IF NOT EXISTS ( SELECT
                          1
                      FROM
                          TaskTypeCommunications
                      WHERE
                          TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
                          AND (
                                TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID OR @i_TypeID IS NULL
                              ) 
                    )
         BEGIN
         -------------------------Getting Next Communication Type for Default ---------------------
               SELECT TOP 1
                   @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence
               FROM
                   TaskAttempts
               INNER JOIN TaskTypeCommunications
                   ON TaskTypeCommunications.TasktypeCommunicationID = TaskAttempts.TasktypeCommunicationID
               WHERE
                   TaskAttempts.TaskId = @i_TaskId
               AND TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
               AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence  DESC

               SELECT TOP 1
                   @v_CommunicationType = CommunicationType.CommunicationType
               FROM
                   TaskTypeCommunications
               INNER JOIN CommunicationType
                   ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
               WHERE
                   TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
               AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_CommunicationSequence , 0)
               AND TaskTypeCommunications.TaskTypeGeneralizedID IS NULL
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence ASC

         END
      ELSE
         BEGIN
         ----------------Getting Next CommunicationType for Specific ---------------------
               SELECT TOP 1
                   @i_CommunicationSequence = TaskTypeCommunications.CommunicationSequence
               FROM
                   TaskAttempts
               INNER JOIN TaskTypeCommunications
                   ON TaskTypeCommunications.TasktypeCommunicationID = TaskAttempts.TasktypeCommunicationID
               WHERE
                   TaskAttempts.TaskId = @i_TaskId
               AND TaskTypeCommunications.TaskTypeID = @i_TaskTypeID
               AND (
                    TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID OR @i_TypeID IS NULL
                   )
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence  DESC
               SELECT TOP 1
                   @v_CommunicationType = CommunicationType.CommunicationType
               FROM
                   TaskTypeCommunications
               INNER JOIN CommunicationType
                   ON CommunicationType.CommunicationTypeId = TaskTypeCommunications.CommunicationTypeID
               WHERE
                   TaskTypeCommunications.TaskTypeID = @i_TaskTypeId
               AND TaskTypeCommunications.CommunicationSequence > ISNULL(@i_CommunicationSequence , 0)
               AND (
                    TaskTypeCommunications.TaskTypeGeneralizedID = @i_TypeID OR @i_TypeID IS NULL
                   )
               ORDER BY
                   TaskTypeCommunications.CommunicationSequence ASC
         END

      RETURN @v_CommunicationType
END
