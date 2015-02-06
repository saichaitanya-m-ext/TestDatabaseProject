CREATE TABLE [dbo].[MeasureOption] (
    [MeasureOptionId]     [dbo].[KeyID]    IDENTITY (1, 1) NOT NULL,
    [MeasureText]         VARCHAR (50)     NOT NULL,
    [MeasureTextOptionId] [dbo].[KeyID]    NOT NULL,
    [CreatedByUserId]     [dbo].[KeyID]    NOT NULL,
    [CreatedDate]         [dbo].[UserDate] CONSTRAINT [DF_MeasureOption_CreatedDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_MeasureOption] PRIMARY KEY CLUSTERED ([MeasureOptionId] ASC),
    CONSTRAINT [FK_MeasureOption_MeasureTextOption] FOREIGN KEY ([MeasureTextOptionId]) REFERENCES [dbo].[MeasureTextOption] ([MeasureTextOptionId])
);


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Foreign key to the "Users" table (column "UserId"); defaults to the <User ID> of the System User that inserted the data in the table.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MeasureOption', @level2type = N'COLUMN', @level2name = N'CreatedByUserId';


GO
EXECUTE sp_addextendedproperty @name = N'Description', @value = 'Date/Time on which the row of data was inserted in the table; defaults to the Current Date/Time at which the data was inserted.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MeasureOption', @level2type = N'COLUMN', @level2name = N'CreatedDate';

