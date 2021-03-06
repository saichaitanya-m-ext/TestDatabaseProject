﻿CREATE TABLE [dbo].[RX_IN_PROD_MBR] (
    [MBR_KEY]          VARCHAR (50) NULL,
    [RX_SERV_DT]       VARCHAR (50) NULL,
    [RX_NDC]           VARCHAR (50) NULL,
    [RX_DAYS_SUPP]     VARCHAR (50) NULL,
    [RX_INGR_COST]     VARCHAR (50) NULL,
    [RX_DISCOUNT]      VARCHAR (50) NULL,
    [RX_DISP_FEE]      VARCHAR (50) NULL,
    [RX_ADMIN_FEE]     VARCHAR (50) NULL,
    [RX_MEM_COST]      VARCHAR (50) NULL,
    [RX_TOT_COST]      VARCHAR (50) NULL,
    [RX_SUPPLY]        VARCHAR (50) NULL,
    [AGE_SERV_DT]      VARCHAR (50) NULL,
    [CLAIM_DEN]        VARCHAR (50) NULL,
    [RX_CLAIM_ID]      VARCHAR (50) NOT NULL,
    [PROV_NBR]         VARCHAR (50) NULL,
    [EMP_NBR]          VARCHAR (50) NULL,
    [MED_ELIG_CAT_ID]  VARCHAR (50) NULL,
    [PRODUCT_ID]       VARCHAR (50) NULL,
    [RX_METR_QTY]      VARCHAR (50) NULL,
    [FILE_ID]          VARCHAR (50) NULL,
    [SRC_LOAD_DTM]     VARCHAR (50) NULL,
    [CLM_ADJSTMNT_KEY] VARCHAR (50) NULL,
    [QTY_DISP]         VARCHAR (50) NULL
);

