CREATE TABLE [dbo].[CodeSetDrugLabeler] (
    [LabelerID]      INT             IDENTITY (1, 1) NOT NULL,
    [LabelerCode]    VARCHAR (7)     NOT NULL,
    [FirmName]       VARCHAR (200)   NULL,
    [AddressHeading] [dbo].[Address] NULL,
    [Street]         [dbo].[Address] NULL,
    [PostBox]        VARCHAR (9)     NULL,
    [ForiegnAddress] [dbo].[Address] NULL,
    [City]           [dbo].[City]    NULL,
    [State]          [dbo].[State]   NULL,
    [ZipCode]        [dbo].[ZipCode] NULL,
    [Province]       [dbo].[City]    NULL,
    [Country]        [dbo].[Country] NULL,
    CONSTRAINT [PK_CodeSetDrugLabeler] PRIMARY KEY CLUSTERED ([LabelerID] ASC) ON [FG_Codesets]
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FDA Drug Schema Table -', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primary Key for the Firms table', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'LabelerID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'FDA generated identification number for each firm. The number is padded to the left with zeroes to fill out to length 6.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'LabelerCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Firm name as reported by the firm.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'FirmName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Address Heading as reported by the firm.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'AddressHeading';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The street address for a drug manufacturer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'Street';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Post office box number as reported by firm.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'PostBox';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Address information report by firm for foreign countries that does not fit the U.S. Postal service configuration.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'ForiegnAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Drug Manufacturer City', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'City';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'The state for a drug manufacturer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'State';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Zip Code for Drug manufacturer', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'ZipCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Province of Foreign country if appropriate.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'Province';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Country name for the firm', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodeSetDrugLabeler', @level2type = N'COLUMN', @level2name = N'Country';

