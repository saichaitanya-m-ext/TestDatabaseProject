CREATE TYPE [dbo].[PregnancyOutComeDetails] AS TABLE (
    [TypeofDeliveryId]  INT             NULL,
    [TypeofDelivery]    VARCHAR (100)   NULL,
    [ModeofDeliveryId]  INT             NULL,
    [ModeofDelivery]    VARCHAR (100)   NULL,
    [BirthDate]         DATE            NULL,
    [BirthTime]         TIME (7)        NULL,
    [Gender]            CHAR (1)        NULL,
    [BabyStatus]        VARCHAR (20)    NULL,
    [Weight]            DECIMAL (10, 2) NULL,
    [Height]            DECIMAL (10, 2) NULL,
    [HeadCircumference] DECIMAL (10, 2) NULL,
    [NICUadminssion]    CHAR (4)        NULL,
    [Comments]          VARCHAR (500)   NULL);

