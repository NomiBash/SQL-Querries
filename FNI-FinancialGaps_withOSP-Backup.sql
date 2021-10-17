USE [FNI_TF_OSP]
GO

/****** Object:  View [dbo].[V.NI_FinaicalGAPs_ActivePOs_WithOSP]    Script Date: 10/5/2021 9:28:24 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





 CREATE View [dbo].[V.NI_FinaicalGAPs_ActivePOs_WithOSP] AS
	 SELECT [UpdatedDep] COLLATE DATABASE_DEFAULT Department
           ,[PONumber] COLLATE DATABASE_DEFAULT PONumber
		   ,ProjectName COLLATE DATABASE_DEFAULT ProjectName
           ,[ElementGroupCode_F] COLLATE DATABASE_DEFAULT Element
		   ,[ElementGroupCode_Drill] COLLATE DATABASE_DEFAULT Element_Drill
		   ,[Element Code]
		   ,[SOW Work Type]
           ,[JobNumber] COLLATE DATABASE_DEFAULT JobNumber
		   ,sitenumber
           ,[StageDate] 
           ,[AsBuiltCost_SR]
           ,[ECTC]
           ,[Invoice Approved Net]
           ,[EBNetAmount_SR]
		   ,ContractorName COLLATE DATABASE_DEFAULT VendorName
           ,case when [ElementGroupDepartment] = 'WNI' then ElementGroupCode else ContractorName end COLLATE DATABASE_DEFAULT VendorName_Drill
           ,[As-Built Approval] COLLATE DATABASE_DEFAULT AsB_Status
		   ,MoPIssueDate
		   ,[SOW Completion Date]
		   ,NPTWNIActivityId -- added NPTWNIActivityId by Said on 2020-02-16
		   ,MoPNumber -- added MoPNumber by Said on 2020-02-16
		   ,[PAC Date] -- added [PAC Date] by Said on 2020-02-16
		   ,[PAT End] -- added [PAT End] by Said on 2020-02-16
		   ,[MOP Status - Design]

     FROM (Select *,case when ElementGroupDepartment = 'CNI' then isnull(section,ElementGroupCode) else ElementGroupCode end as [ElementGroupCode_F]
				   ,case when ElementGroupDepartment = 'CNI' then isnull(section,ElementGroupCode) else ElementGroupCode end as [ElementGroupCode_Drill]
						  
			FROM (
					Select ECTC_ALL.[SOW Work Type],[MOP Status - Design] ,ECTC.*,[SOW Completion Date], [Element Code],section   FROM [NI_AsBuilt].[dbo].[V.NI_FinaicalGAPs_ActivePOs] ECTC
					left join [dbo].[Infra_CNI_Section_Mapping] CNI on ECTC.PONumber = CNI.PONumber and ECTC.ElementGroupCode = CNI.Element
					JOIN [FNI_TF_OSP].[dbo].[T_ISP_POs] PO ON ECTC.PoNumber = CONVERT(VARCHAR ,PO.Po_Number)  
					left join (Select JobNumber,[SOW Completion Date] , [Element Code] ,[SOW Work Type], [MOP Status - Design] from [FNI_TF_OSP].[dbo].T_vECTCJobLevel_Active_POs) ECTC_ALL on ECTC.JobNumber = ECTC_ALL.JobNumber 
					WHERE PO.Budget2019  = 'Yes' AND ECTC.[UpdatedDep] <> 'FNI_OSP' 
				  ) v
			) ECTC     ---'Design','Cloud','Planning' added
     UNION
     
     SELECT 'OSP ' + QW.Region AS Region
                   ,QW.PONumber
				   ,QW.ProjectName
                   ,FinalClass
				   ,FinalClass
				   ,FinalClass
				   ,NULL as [SOW Work Type]
                   ,CASE WHEN QW.jobworkorder IS NULL THEN DWO.JobNumber ELSE QW.jobworkorder END AS JobNumber
				   ,DWO.Origin_Number
                   ,QW.[As-Built PCC Out]
                   ,CASE WHEN QW.[As-Built PCC Out] IS NULL THEN 0 ELSE QW.JobAsBuiltCost END AS JobAsBuiltCost
                   ,QW.ReconciledCost
                   ,CASE WHEN QW.[As-Built PCC Out] IS NULL THEN 0 ELSE InvoiceNetValue END AS InvoiceNetValue
                   ,null as EBNET --QW.ReconciledCost
				   ,QW.ContractorName
                   ,QW.ContractorName
                   ,CASE WHEN QW.[As-Built PCC Out] IS NOT NULL THEN AsBuiltCurrentStatus ELSE 'NULL' END AS [AsB_Status]
				   ,null as MoPIssueDate
				   ,QW.IssueDate 
				   ,null as NPTWNIActivityId -- added NPTWNIActivityId by Said on 2020-02-16
				   ,null as MoPNumber -- added MoPNumber by Said on 2020-02-16
				   ,null as [PAC Date] -- added [PAC Date] by Said on 2020-02-16
				   ,null as [PAT End] -- added [PAT End] by Said on 2020-02-16
				   ,null as [MOP Status - Design]-- added mop status Abu Ayesha 8/23/21
	 FROM [10.21.35.167,1467].[CRDB].[vw].[QuickWinFiltered_Temp] QW
     LEFT JOIN [FNI_TF_OSP].[dbo].T_OSPJobWORecWithStatusRep DWO ON QW.JobWorkOrder = DWO.JobWorkOrder COLLATE DATABASE_DEFAULT
     --WHERE  ActiveProjects = 1  /* HZB Instruction

	-- UNION -- Adding FNI Material DATA /* Wael & HZB agreement

	-- SELECT 'FNI_Material' DEP 
 --      ,mat.[PONumber],
	--   mat.[ProjectName] PROJ_SH_NAME,
 --      'Material' ELEMENT,
	--   'Material' ELEMENT
 --      ,case when mat.JobNumber is null then mat.InstSOWNumber else mat.JobNumber end as JobNumber --Wael email request to add SOW Number for tracking purpose.
	--   ,case when mat.JobNumber is null then mat.InstSOWNumber else mat.JobNumber end as JobNumber 
 --      ,IIF( [InstAsBStage]='PCC' and [InstAsBStatus]='Approved',[InstAsBStageDate],NULL) StageDate
 --      ,Case When [ContractorName] in ('Corning Optical Communications GmbH & Co','Commscope EMEA Limited')  
	--		Then (IIF( [InstAsBStage]='PCC' and [InstAsBStatus]='Approved',[InstAsBGrossAmt],NULL) * 3.756 )
	--		Else (IIF( [InstAsBStage]='PCC' and [InstAsBStatus]='Approved',[InstAsBGrossAmt],NULL) )
	--	End as AsB_Cost
 --      ,case when [ContractorName] in ('Corning Optical Communications GmbH & Co','Commscope EMEA Limited')  
	--   Then [InstSowGrossAmt]*3.756 else [InstSowGrossAmt] end as  ECTC
 --      ,IIF( [InstAsBStage]='PCC' and [InstAsBStatus]='Approved',[InstAsBGrossAmt],NULL) as  Invoice
 --      ,null as EBNET,
 --      mat.[ContractorName] VENDOR_NAME,
	--   mat.[ContractorName] VENDOR_NAME,
 --      [InstAsBStatus] as AsB_Status,
 --      [PMApprovalDate] as MoPIssueDate,
	--   [PMApprovalDate] as SoWDate,
 --      null as NPTWNIActivityId, -- added NPTWNIActivityId by Said on 2020-02-16
 --      null as MoPNumber, -- added MoPNumber by Said on 2020-02-16
 --      null as [PAC Date], -- added [PAC Date] by Said on 2020-02-16
 --      [PMApprovalDate] as [PAT End] -- added [PAT End] by Said on 2020-02-16

	--   --select Distinct   mat.[ContractorName]
	--FROM [FNI_TF_OSP].[dbo].[v.OSPMaterialJobDetailRpt] Mat
	--where  mat.[ContractorName] <>'STC Warehouse - Materials'
	----INNER JOIN (Select PONumber,MAX(EBNetAmount) EBNetAmount,MAX(EBNetAmount_SR) EBNetAmount_SR FROM [NI_AsBuilt].[dbo].[V.NI_FinaicalGAPs_ActivePOs] ECTC
 ----            inner JOIN [FNI_TF_OSP].[dbo].[T_ISP_POs] PO 
	----		 ON ECTC.PoNumber = CONVERT(VARCHAR ,PO.Po_Number)  and Budget2019  = 'Yes' 
	----		 Group by  PONumber) EB 
	----ON MAT.PONumber = EB.PONumber

GO


