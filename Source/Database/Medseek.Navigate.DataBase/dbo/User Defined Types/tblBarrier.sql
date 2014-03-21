CREATE TYPE [dbo].[tblBarrier] AS TABLE (
    [PatientBarrierId] [dbo].[KeyID]           NULL,
    [BarrierID]        [dbo].[KeyID]           NULL,
    [Comments]         VARCHAR (500)           NULL,
    [ReferralID]       [dbo].[KeyID]           NULL,
    [ReportedDate]     [dbo].[UserDate]        NULL,
    [StatusCode]       VARCHAR (1)             NULL,
    [OtherBarrier]     [dbo].[LongDescription] NULL);

