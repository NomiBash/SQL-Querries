USE [FNI_TF_OSP]
GO
/****** Object:  StoredProcedure [dbo].[PCC Dashboard Data Update Tabels]    Script Date: 10/17/2021 12:23:37 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




ALTER PROCEDURE [dbo].[PCC Dashboard Data Update Tabels]
AS
BEGIN

	SET NOCOUNT ON;
	---------------////////////////////////////////-----------------tblPurchaseOrder---------////////////////////////////////-------------------------

	IF EXISTS(SELECT TOP 10 * FROM [FNI_TF_OSP].[dbo].[V.NI_FinaicalGAPs_ActivePOs_WithOSP])

	Begin

	Select *,getdate() as Refresh_Date into #T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp
	from [FNI_TF_OSP].[dbo].[V.NI_FinaicalGAPs_ActivePOs_WithOSP]

	End

	IF EXISTS (SELECT TOP 10 * FROM #T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp)
	BEGIN
		DROP TABLE	 T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp

		SELECT *INTO T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp
		FROM		 #T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp

		DROP TABLE  #T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp
	END
---------------////////////////////////////////-----------------Quick WIN---------////////////////////////////////-------------------------

---------------////////////////////////////////-----------------tblPurchaseOrder---------////////////////////////////////-------------------------

	IF EXISTS(SELECT TOP 10 * FROM nfts.nfts.dbo.tblPurchaseOrder)

	Begin

	Select *,getdate() as Refresh_Date into #tblPurchaseOrder
	from nfts.nfts.dbo.tblPurchaseOrder

	End

	IF EXISTS (SELECT TOP 10 * FROM tblPurchaseOrder)
	BEGIN
		DROP TABLE	 tblPurchaseOrder

		SELECT *INTO tblPurchaseOrder
		FROM		 #tblPurchaseOrder

		DROP TABLE  #tblPurchaseOrder
	END
---------------////////////////////////////////-----------------Quick WIN---------////////////////////////////////-------------------------

	IF EXISTS(SELECT TOP 10 * FROM [10.21.35.167,1467].[CRDB].[vw].[QuickWinFiltered_Temp])

	Begin

	Select *,getdate() as Refresh_Date into #QuickWIN
	from [10.21.35.167,1467].[CRDB].[vw].[QuickWinFiltered_Temp]

	End

	IF EXISTS(SELECT TOP 10 * FROM #QuickWIN)

	Begin

	Drop Table Infra_Quick_WIn

	Select * into Infra_Quick_WIn
	from #QuickWIN

	Drop Table #QuickWIN

	End
---------------////////////////////////////////-----------------[FirstExpiredMilestoneflag]---------////////////////////////////////-------------------------

	IF EXISTS(SELECT TOP 10 * FROM [10.21.35.167,1467].[CRDB].[vw].[FirstExpiredMilestoneflag])

	Begin

	Select *,getdate() as Refresh_Date into #Infra_FirstExpiredMilestoneflag
	from [10.21.35.167,1467].[CRDB].[vw].[FirstExpiredMilestoneflag]

	End

	Begin

	IF EXISTS(SELECT TOP 10 * FROM #Infra_FirstExpiredMilestoneflag)

	Drop Table Infra_FirstExpiredMilestoneflag

	Select * into Infra_FirstExpiredMilestoneflag
	from #Infra_FirstExpiredMilestoneflag

	Drop Table #Infra_FirstExpiredMilestoneflag
	
	End

---------------////////////////////////////////-----------------[CNI Data Transmission]---------////////////////////////////////-------------------------

IF EXISTS(SELECT TOP 10 * FROM [10.21.35.167,1467].[PMCSv2].[Transmission].[TransmissionJobViewAll])

Begin

Select *,getdate() as Refresh_Date into #Infra_TransmissionJobViewAll
from [10.21.35.167,1467].[PMCSv2].[Transmission].[TransmissionJobViewAll]

End

IF EXISTS(SELECT TOP 10 * FROM #Infra_TransmissionJobViewAll)

Begin

Drop Table Infra_TransmissionJobViewAll

Select * into Infra_TransmissionJobViewAll
from #Infra_TransmissionJobViewAll

Drop Table #Infra_TransmissionJobViewAll

End



---------------////////////////////////////////-----------------[CNI Data IGW]---------////////////////////////////////-------------------------

IF EXISTS(SELECT TOP 10 * FROM [10.21.35.167,1467].[PMCSv2].IPMPLS.IPMPLSMasterSheetView )


Begin

Select 
Jobnumber,
sitenumber
,    [DependencyRemarks],  [DesignMOPTechnicaStatus],[DesignMOPTechnicalStatusDate]
,[ImplementationActualDate]
,[DesignMOPSubmission]
,[PATApprovedFromDCCDate]
,getdate() as Refresh_Date into #IPMPLSMasterSheetView
from [10.21.35.167,1467].[PMCSv2].IPMPLS.IPMPLSMasterSheetView 

End

IF EXISTS(SELECT TOP 10 * FROM #IPMPLSMasterSheetView)

Begin

Drop Table Infra_IPMPLSMasterSheetView

Select * into Infra_IPMPLSMasterSheetView
from #IPMPLSMasterSheetView

Drop Table #IPMPLSMasterSheetView

End





---------------////////////////////////////////-----------------[FNI Telecom Data]---------////////////////////////////////-------------------------

IF EXISTS(SELECT TOP 10 * FROM [NPTS].[ISOW].[dbo].[ALLFNIView])

Begin

select *,getdate() as Refresh_Date into #Infra_All_FNI_View
from [NPTS].[ISOW].[dbo].[ALLFNIView] 
where [job number] Collate database_Default not in (select distinct [job number] from InfraGlobalLegacy) --Added to remove UNG Duplicates as per agreement with Abu Ayesha

End

IF EXISTS(SELECT TOP 10 * FROM #Infra_All_FNI_View)

Begin

Drop Table Infra_All_FNI_View

select * into Infra_All_FNI_View
from #Infra_All_FNI_View

Drop Table #Infra_All_FNI_View

End

---------------////////////////////////////////-----------------[As-Built Under Approval]---------////////////////////////////////-------------------------

IF EXISTS(SELECT TOP 10 * FROM NFTS.NFTS.NFTS_Views.VImplementPATEAPPROVAL_AsbuiltApprovalReport)

Begin

select *,getdate() as Refresh_Date into #Infra_AsbuiltApprovalReport
from NFTS.NFTS.NFTS_Views.VImplementPATEAPPROVAL_AsbuiltApprovalReport

End

IF EXISTS(SELECT TOP 10 * FROM #Infra_AsbuiltApprovalReport)

Begin

Drop Table Infra_AsbuiltApprovalReport

select * into Infra_AsbuiltApprovalReport
from #Infra_AsbuiltApprovalReport

Drop Table #Infra_AsbuiltApprovalReport

End



---------------////////////////////////////////-----------------[FNIClassMapping]---------////////////////////////////////-------------------------

IF EXISTS(SELECT TOP 10 * FROM [10.21.35.167,1467].[CRDB].[dbo].[FNIClassMapping])

Begin

select *,getdate() as Refresh_Date into #Infra_FNI_Class_Mapping
from [10.21.35.167,1467].[CRDB].[dbo].[FNIClassMapping]

End

IF EXISTS(SELECT TOP 10 * FROM #Infra_FNI_Class_Mapping)

Begin

Drop Table Infra_FNI_Class_Mapping

select * into Infra_FNI_Class_Mapping
from #Infra_FNI_Class_Mapping

Drop Table #Infra_FNI_Class_Mapping

End


---------------////////////////////////////////-----------------[PCC Target Data]---------////////////////////////////////-------------------------

IF EXISTS(SELECT TOP 10 * FROM [10.21.35.167,1467].CRDB.[dbo].[PCC_Revised_Target_Updated])

Begin

select *,getdate() as Refresh_Date into #Infra_PCC_Revised_Target_Updated
from [10.21.35.167,1467].CRDB.[dbo].[PCC_Revised_Target_Updated]

End

IF EXISTS(SELECT TOP 10 * FROM #Infra_PCC_Revised_Target_Updated)

Begin

Drop Table Infra_PCC_Revised_Target_Updated

select * into Infra_PCC_Revised_Target_Updated
from #Infra_PCC_Revised_Target_Updated

Drop Table #Infra_PCC_Revised_Target_Updated

End

---------------////////////////////////////////-----------------[DWO Data]---------////////////////////////////////-------------------------

IF EXISTS(SELECT TOP 10 * FROM [NFTS].[NFTS_OSPREPORTS].[dbo].[OSPJobWORecWithStatusRep])

Begin

select *,getdate() as Refresh_Date into #Infra_OSPJobWORecWithStatusRep
from [NFTS].[NFTS_OSPREPORTS].[dbo].[OSPJobWORecWithStatusRep]

End

IF EXISTS(SELECT TOP 10 * FROM #Infra_OSPJobWORecWithStatusRep)

Begin

Drop Table Infra_OSPJobWORecWithStatusRep

select * into Infra_OSPJobWORecWithStatusRep
from #Infra_OSPJobWORecWithStatusRep

Drop Table #Infra_OSPJobWORecWithStatusRep

End

-----------------------------------------------//////////////// Design Data ///////////////--------------------------------------------


if exists (select top 10 * from [NPTS].[NPT].[WNI].[TelecomView] )

BEGIN

drop table [dbo].[Design_Tracker_NPTS]

select * into [Design_Tracker_NPTS] from (
Select
		[ID],

			[FntActivityType],
			[NFTSTelecomPONumber],
			[WNIActivityID],
			LTRIM(RTRIM([SiteSiteID])) [SiteSiteID],
			case [TelecomProject] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TelecomProject]) end AS [TelecomProject],
			case [TelecomVendor] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TelecomVendor])end AS [TelecomVendor],
			case [TelecomScope] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TelecomScope])end AS [TelecomScope],
			case [BasicWorkType] when 0 then NULL else (Select l.[Description] from [NPTS].NPT.Config.Lookup as l where l.Id = [BasicWorkType])end AS [BasicWorkType], --[Description]
			case [TelecomWorkType] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TelecomWorkType])end AS [TelecomWorkType],
			case [BTSType] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [BTSType])end AS [BTSType],
			case [SubWorkType] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [SubWorkType])end AS [SubWorkType],
			case [IMPProject] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [IMPProject]) end AS [IMPProject],
			case [TelecomPriority] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TelecomPriority]) end AS [TelecomPriority],

			case [CivilScope] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CivilScope]) end AS [CivilScope],
			case [HandoverToCivilActual] when '2400-01-01' then null else [HandoverToCivilActual] end AS [HandoverToCivilActual],
			case [SHOReceivedActual] when '2400-01-01' then null else [SHOReceivedActual] end AS [SHOReceivedActual],
			case [CivilStartedActual] when '2400-01-01' then null else [CivilStartedActual] end AS [CivilStartedActual],
			case [CivilCompletedActual] when '2400-01-01' then null else [CivilCompletedActual] end AS [CivilCompletedActual],
			case [TechBHOwner] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TechBHOwner]) end AS [TechBHOwner],
			case [SiteInstalledActual] when '2400-01-01' then null else [SiteInstalledActual] end AS [SiteInstalledActual],
			case [IntegrationAccessStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [IntegrationAccessStatus])end AS [IntegrationAccessStatus],
			case [SiteIntegratedActual] when '2400-01-01' then null else [SiteIntegratedActual] end AS [SiteIntegratedActual],
			case [SiteOnAirPlanned] when '2400-01-01' then null else [SiteOnAirPlanned] end AS [SiteOnAirPlanned],
			case [SiteOnAirActual] when '2400-01-01' then null else [SiteOnAirActual] end AS [SiteOnAirActual],
			case [SiteOnAirStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [SiteOnAirStatus]) end AS [SiteOnAirStatus],
			case [TelecomPATStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TelecomPATStatus])end AS [TelecomPATStatus],
			case [TelecomPATStatusDate] when '2400-01-01' then null else [TelecomPATStatusDate] end AS [TelecomPATStatusDate],
			case [TelecomFieldPATStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TelecomFieldPATStatus]) end AS [TelecomFieldPATStatus],
			case [TelecomFieldPATStatusDate] when '2400-01-01' then null else TelecomFieldPATStatusDate end AS [TelecomFieldPATStatusDate],
			case [HandoverStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [HandoverStatus])end AS [HandoverStatus],
			case [HandoverStatusDate] when '2400-01-01' then null else HandoverStatusDate end AS [HandoverStatusDate],
			[VendorPATStatus],
			case [VendorPATStatusDate] when '2400-01-01' then null else [VendorPATStatusDate] end AS [VendorPATStatusDate],
			case [TechnologyBand] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [TechnologyBand])end AS [TechnologyBand],
			[SiteName],
			[City],
			[District],
			[Region],
			case SiteAcquisitionTeamLeader when 0 then NULL else (Select M.[EnglishName] FROM [NPTS].NPT.Manpower.employee as M where M.Id = SiteAcquisitionTeamLeader) end AS SiteAcquisitionTeamLeader,
			case [HandoverToCivilForecast] when '2400-01-01' then null else [HandoverToCivilForecast] end AS [HandoverToCivilForecast],
		
			case [CivilStartedForecast] when '2400-01-01' then null else [CivilStartedForecast] end AS [CivilStartedForecast],
			case [CivilCompletedForecast] when '2400-01-01' then null else [CivilCompletedForecast] end AS [CivilCompletedForecast],
		
			case [CivilFieldPATStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CivilFieldPATStatus])end AS [CivilFieldPATStatus],
			case [CivilFieldPATStatusDate] when '2400-01-01' then null else [CivilFieldPATStatusDate] end AS [CivilFieldPATStatusDate],
			case [PowerFieldPATStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [PowerFieldPATStatus])end AS [PowerFieldPATStatus],
			case [PowerFieldPATStatusDate] when '2400-01-01' then null else [PowerFieldPATStatusDate] end AS [PowerFieldPATStatusDate],
			[TelecomJobNumber],	
			[TelecomPO],

			case [SSOReceivedActual] when '2400-01-01' then null else [SSOReceivedActual] end AS [SSOReceivedActual],
			case [InitialSiteSurveyActual] when '2400-01-01' then null else [InitialSiteSurveyActual] end AS [InitialSiteSurveyActual],
			[OwnerStatus],
			case [SurveyReportIssuedActual] when '2400-01-01' then null else [SurveyReportIssuedActual] end AS [SurveyReportIssuedActual],
			case [ContractApproveActual] when '2400-01-01' then null else [ContractApproveActual] end AS [ContractApproveActual],
			case [BaladiyahPermitReceivedActual] when '2400-01-01' then null else [BaladiyahPermitReceivedActual] end AS [BaladiyahPermitReceivedActual],
			case [SAFReceivedActual] when '2400-01-01' then null else [SAFReceivedActual] end AS [SAFReceivedActual],
			case [GTACStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [GTACStatus])end AS [GTACStatus],
			case [OptimisationStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [OptimisationStatus])end AS [OptimisationStatus],

			case [PowerConnectedActual] when '2400-01-01' then null else [PowerConnectedActual] end AS [PowerConnectedActual],
			case [PowerConnectedForecast] when '2400-01-01' then null else [PowerConnectedForecast] end AS [PowerConnectedForecast],
			case [CWPATActual] when '2400-01-01' then null else [CWPATActual] end AS [CWPATActual],
			case [CivilPATForecast] when '2400-01-01' then null else [CivilPATForecast] end AS [CivilPATForecast],

			case [GTACStatusDate] when '2400-01-01' then null else [GTACStatusDate] end AS [GTACStatusDate],
			case [OptimisationStatusDate] when '2400-01-01' then null else [OptimisationStatusDate] end AS [OptimisationStatusDate],
			case [MWStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [MWStatus])end AS [MWStatus],
			case [MWStatusDate] when '2400-01-01' then null else [MWStatusDate] end AS [MWStatusDate],
			case [CWOStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CWOStatus])end AS [CWOStatus], 
			case [CWOStatusDate] when '2400-01-01' then null else [CWOStatusDate] end AS [CWOStatusDate], 
			case [VLANStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [VLANStatus])end AS [VLANStatus],
			case [VLANStatusDate] when '2400-01-01' then null else [VLANStatusDate] end AS [VLANStatusDate],
			case [IUBStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [IUBStatus])end AS [IUBStatus],
			case [IUBStatusDate] when '2400-01-01' then null else [IUBStatusDate] end AS [IUBStatusDate],
			case [label] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [label])end AS [label],
			case [LockStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [LockStatus])end AS [LockStatus],
			case [LockDate] when '2400-01-01' then null else [LockDate] end AS [LockDate],
			[HandoverModule],
			case [PISMStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [PISMStatus])end AS [PISMStatus],
			case [PISMAcceptedActual] when '2400-01-01' then null else [PISMAcceptedActual] end AS [PISMAcceptedActual],
			[ISOWActivityID],
			case [PowerStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [PowerStatus])end AS [PowerStatus],
			case [PowerSource] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [PowerSource])end AS [PowerSource],
			case [CAPEXBOQWorkType] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CAPEXBOQWorkType])end AS [CAPEXBOQWorkType],
			[SiteSummary] ,
			[TelecomMOPStatus],
			case [CivilStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CivilStatus])end AS [CivilStatus],
			case [SHOStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [SHOStatus])end AS [SHOStatus],
			case [SiteInstalledForecast] when '2400-01-01' then null else [SiteInstalledForecast] end AS [SiteInstalledForecast],
			case [SiteIntegratedForecast] when '2400-01-01' then null else [SiteIntegratedForecast] end AS [SiteIntegratedForecast],
			case [SiteOnAirForecast] when '2400-01-01' then null else [SiteOnAirForecast] end AS [SiteOnAirForecast],
			case [SiteOwnership] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [SiteOwnership])end AS [SiteOwnership]
			
			,[isowJISOWStatus]
			,case [ClusterID] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [ClusterID] ) end AS [ClusterID]
			,[ClusterDescription]
			,case [SSOIssuedForecast] when '2400-01-01' then null else [SSOIssuedForecast] end AS [SSOIssuedForecast]
			,case [SSOIssuedActual] when '2400-01-01' then null else [SSOIssuedActual] end As [SSOIssuedActual]
			,case [ISSReportIssuedForecast] when '2400-01-01' then null else  [ISSReportIssuedForecast] end As [ISSReportIssuedForecast]
			,case [ISSReportIssuedActual] when '2400-01-01' then null else [ISSReportIssuedActual] end As [ISSReportIssuedActual]
			,case [SAFIssuedActual] when '2400-01-01' then null else [SAFIssuedActual] end As [SAFIssuedActual]
			,case [TCCIssuedActual] when '2400-01-01' then null else  [TCCIssuedActual] end As [TCCIssuedActual]
			,case [BaladiyahApplicationSubmittedForecast] when '2400-01-01' then null else [BaladiyahApplicationSubmittedForecast] end As [BaladiyahApplicationSubmittedForecast]
			,case [BaladiyahApplicationSubmittedActual] when '2400-01-01' then null else [BaladiyahApplicationSubmittedActual] end As [BaladiyahApplicationSubmittedActual]
			,case [BaladiyahPermitReceivedForecast] when '2400-01-01' then null else [BaladiyahPermitReceivedForecast] end As [BaladiyahPermitReceivedForecast]
			,case [SHOReceivedForecast] when '2400-01-01' then null else  [SHOReceivedForecast] end As[SHOReceivedForecast] 
			,case [BasicSiteType] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [BasicSiteType] )end AS [BasicSiteType]
			,case [PowerType] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [PowerType] )end AS [PowerType]
			,case [TDIssuedToVendorActual] when '2400-01-01' then null else [TDIssuedToVendorActual] end As [TDIssuedToVendorActual]
			,case [NEDesignApprovalCivil] when '2400-01-01' then null else [NEDesignApprovalCivil] end As [NEDesignApprovalCivil]
			,case [CivilDesignMOPSubmittal] when '2400-01-01' then null else [CivilDesignMOPSubmittal] end As [CivilDesignMOPSubmittal]
			,case [CivilDesignMOPApprovalDate] when '2400-01-01' then null else [CivilDesignMOPApprovalDate] end As [CivilDesignMOPApprovalDate]
			,case [CivilDesignMOPStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CivilDesignMOPStatus] )end AS [CivilDesignMOPStatus]
			,case [CivilPATStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CivilPATStatus] )end AS [CivilPATStatus]
			,case [CivilPATStatusDate] when '2400-01-01' then null else [CivilPATStatusDate] end As [CivilPATStatusDate]
			,[CWORemarks]
			,case [ADMSOverall] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [ADMSOverall])end AS [ADMSOverall]
			,case [ADMSOverallDate] when '2400-01-01' then null else [ADMSOverallDate] end As [ADMSOverallDate]
			,case [NEDesignApprovalTelecom] when '2400-01-01' then null else  [NEDesignApprovalTelecom] end As [NEDesignApprovalTelecom]
			,[isowBackhaulingType]
			,[ActiveBHType]
			,case [SitePreIntegratedForecast] when '2400-01-01' then null else [SitePreIntegratedForecast] end As [SitePreIntegratedForecast] 
			,case [SitePreIntegratedActual] when '2400-01-01' then null else [SitePreIntegratedActual] end As [SitePreIntegratedActual]
			,case [CWOStatus2] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [CWOStatus2] )end AS [CWOStatus2]
			,[TelecomMOPNumber]
			,case [TelecomMopSubmittal] when '2400-01-01' then null else [TelecomMopSubmittal] end As [TelecomMopSubmittal]
			,case [TelecomMopApproval] when '2400-01-01' then null else [TelecomMopApproval] end As [TelecomMopApproval]
			,case [TelecomPATForecast] when '2400-01-01' then null else [TelecomPATForecast] end As [TelecomPATForecast]
			,case [WNIPATActualDate] when '2400-01-01' then null else [WNIPATActualDate] end As [WNIPATActualDate]
			
			,[NFTSTelecomPATStatus]
			,[TelecomRemarks]
			,case [WNIDismantlingStatus] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id = [WNIDismantlingStatus] )end AS [WNIDismantlingStatus]
			,[isowPlanningStatus]
			,[isowTD]
			,[isowTDStatus]

			,case [ADMSCivilStage] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id =  [ADMSCivilStage]) end AS [ADMSCivilStage] 
			,case [ADMSTelecomRDPStage] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id =  [ADMSTelecomRDPStage]) end AS [ADMSTelecomRDPStage] 
			,case [ADMSTelecomDISMStage] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id =  [ADMSTelecomDISMStage]) end AS [ADMSTelecomDISMStage]
			,case [ADMSMWStage] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id =  [ADMSMWStage]) end AS [ADMSMWStage]
			,case [TelecomDependency] when 0 then NULL else (Select l.Code from [NPTS].NPT.Config.Lookup as l where l.Id =  [TelecomDependency]) end AS [TelecomDependency]


		from [NPTS].[NPT].[WNI].[TelecomView] 
		where btstype = '3365' --and [TelecomScope] = '1264'
		) Main
	End

	if exists (select top 10 * from [Design_Tracker_NPTS])

	Begin

	Drop Table [dbo].[Infra_Design_Tracker_NPTS]


	Select * into [Infra_Design_Tracker_NPTS] from (
	select PONumber,SiteID,jobnumber,Element,ProjectName,VendorName,ectc_f,[TelecomScope],
	case 
	when a.milestone <> 'TBD' then a.milestone
	when element = 'OS' then 'Others'
	when b.SiteSiteID is null then 'TBD' 
		  else b.Milestone end as Milestone
	from 
	(Select * from PCC_Dashboard_Data_BI
	where jobnumber is not null and (year(stagedate)= 2021 or stagedate is null) and oldAchFlag = 'No' and department = 'Design') A
	left join
	 (
		Select sitesiteid ,[NFTSTelecomPONumber],[TelecomScope],
		case when Min_Milestone = 0 then 'TBD'
		 when Min_Milestone = 1 then 'Others'
		 when Min_Milestone = 1.5 then 'Under MOP'
		 when Min_Milestone = 1.8 then 'Under Permit'
		 when Min_Milestone = 2 then 'Under Civil'
		 when Min_Milestone = 3 then 'Under Installation'
		 when Min_Milestone = 4 then 'Under Integration'
		 when Min_Milestone = 5 then 'Integrated Not On-Air'
		 when Min_Milestone = 6 then 'Under PAT'
		 when Min_Milestone = 7 then 'Under Asbuilt'
	end as Milestone
	from (	
		Select sitesiteid ,[NFTSTelecomPONumber],min([TelecomScope]) [TelecomScope] ,min(Milstone_Order) Min_Milestone 	
		from (
				select sitesiteid ,[NFTSTelecomPONumber],[TelecomScope],[BasicWorkType],[MOP Status - Design],[SOW Completion Date],[HandoverToCivilActual],
				[CivilStartedActual],[PISMAcceptedActual],[SiteInstalledActual],[SiteIntegratedActual],[SiteOnAirActual],[WNIPATActualDate],
						case
						when [NFTSTelecomPONumber] is null or [NFTSTelecomPONumber] = ''  or sitesiteid is null then 'TBD'
						when [WNIPATActualDate] is not null then 'Under Asbuilt'
						when [WNIPATActualDate] is null and [SiteOnAirActual] IS NOT NULL THEN 'Under PAT' 
						when [SiteIntegratedActual] is not null AND [SiteOnAirActual] is null THEN 'Integrated Not On-Air' 
						When [SiteInstalledActual] is not null AND [SiteIntegratedActual] is null THEN 'Under Integration' 
						When [PISMAcceptedActual] is not null AND [SiteInstalledActual] is null THEN 'Under Installation' 
						When [CivilStartedActual] is not null AND [PISMAcceptedActual] is null THEN 'Under Civil'
						When  ( [MOP Status - Design]='Approved'  and [CivilStartedActual] is null  and [BasicWorkType]<>'New Sites') THEN 'Under Civil'
						when [BasicWorkType]='New Sites'  and [HandoverToCivilActual] is null  THEN 'Under Permit' 
						WHEN s.[SOW Completion Date] IS NOT NULL AND isnull([MOP Status - Design],'')<>'Approved' THEN 'Under MOP'
						when  [CivilStartedActual] is null then 'Others'
						end as Milestones
						,case
						when [NFTSTelecomPONumber] is null or [NFTSTelecomPONumber] = ''  or sitesiteid is null then 0
						when [WNIPATActualDate] is not null then 7
						when [WNIPATActualDate] is null and [SiteOnAirActual] IS NOT NULL THEN 6 
						when [SiteIntegratedActual] is not null AND [SiteOnAirActual] is null THEN 5 
						When [SiteInstalledActual] is not null AND [SiteIntegratedActual] is null THEN 4 
						When [PISMAcceptedActual] is not null AND [SiteInstalledActual] is null THEN 3 
						When [CivilStartedActual] is not null AND [PISMAcceptedActual] is null THEN 2
						When  ( [MOP Status - Design]='Approved'  and [CivilStartedActual] is null  and [BasicWorkType]<>'New Sites') THEN 2
						when [BasicWorkType]='New Sites'  and [HandoverToCivilActual] is null  THEN 1.8
						WHEN s.[SOW Completion Date] IS NOT NULL AND isnull([MOP Status - Design],'')<>'Approved' THEN 1.5
						when  [CivilStartedActual] is null then 1
						end as Milstone_Order
				from [Design_Tracker_NPTS] A
				left join T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp S on a.[NFTSTelecomPONumber] = s.ponumber collate database_default and a.sitesiteid = s.sitenumber collate database_default
				
			  ) X
			  group by sitesiteid ,[NFTSTelecomPONumber]
		)Y	 
	) B 
on b.[NFTSTelecomPONumber] = a.PONumber Collate database_default and b.SiteSiteID = a.SiteID Collate database_default

) Z



	END



END
