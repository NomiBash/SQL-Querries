USE [FNI_TF_OSP]
GO
/****** Object:  StoredProcedure [dbo].[PCC Dashboard Data Update]    Script Date: 10/17/2021 12:21:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










ALTER PROCEDURE [dbo].[PCC Dashboard Data Update]
AS
BEGIN

	SET NOCOUNT ON;

--------------//////////////////////////////////////////////////////////////////////////////////////////////////------------------------


---------------------------- Fourth Change --------------------------


BEGIN 
                                Select * into [#PCC_Dashboard_Data_BI] from (
                                SELECT 
                        M.Department
                       ,M.PONumber
                       ,po.POYear
                       ,M.ProjectName
                       ,M.Element
                       ,case when M.Department = 'Wni' THEN M.VendorName else M.Element end as Element_Drill
					   ,m.nfts_element
                       ,M.JobNumber
					   ,M.[NPTWNIActivityId] /*this was inserted by Abbas on 12  Dec 20*/ 
                       ,isnull(JobNFTS,M.JobNumber)JobNFTS
                       ,M.StageDate
                       ,M.AsBuiltCost_SR
                       ,M.ECTC
                       ,M.[Invoice Approved Net]
                       ,M.EBNetAmount_SR
                       , case when M.VendorName  	IN (	
						'Nokia Solution and Network Branch Operation OY' 
						, 'Nokia Arabia Limited','Nokia Arabia Limited.')
						then 'Nokia' else M.VendorName end  VendorName
						,case when M.Department = 'Wni' THEN M.Element else M.VendorName  end as VendorName_Drill
                       ,M.AsB_Status
                       ,M.MoPIssueDate
                       ,M.[SOW Completion Date]
                       ,case 
                                    when X.SiteID is not null and M.Department in ('CNI','FNI_Telecom','WNI','OSP Central','OSP Eastern','OSP Southern','OSP Western') then X.SiteID
                                    else M.sitenumber
                                    end as SiteID
                       ,Asb.APPR_ASB
                       ,asb.PREVIOUS_ASB_UR
                       ,YEAR(M.Stagedate) AS AsB_Year
                       ,FORMAT(M.Stagedate, 'MMM', 'en-US') AS AsB_Month
                       ,DATEPART( wk, M.Stagedate) as AsB_Week
                       ,MONTH(M.Stagedate) AS AsB_Order
                       ,FORMAT([SOW Completion Date], 'MMM') AS SoW_Month
                       ,MONTH([SOW Completion Date]) AS SoW_Order
                       ,CASE WHEN isnull( M.[AsBuiltCost_SR],0) < 1 THEN M.ECTC ELSE M.[AsBuiltCost_SR] END AS ECTC_F
                       ,CASE WHEN  M.Stagedate IS NULL and M.[SOW Completion Date] is not null THEN 'GAP 2'---- Chaged to Status Date Arsalan (HBZ 3/28/2020) ---SOW to Remove GAP1
                        WHEN M.[AsBuiltCost_SR] IS NOT NULL AND (M.[Invoice Approved Net] IS NULL OR M.[Invoice Approved Net] < 1) THEN 'GAP 3'
                        ELSE 'Invoiced' END AS GAP_Status
                       ,                    CASE WHEN M.Stagedate IS NULL Then GETDATE() - [SOW Completion Date] END AS GAP2_Age ---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                       ,case when M.[SOW Completion Date] is not null then --- Removing GAP1
                                                                                                CASE WHEN   (CASE WHEN M.Stagedate IS NULL  Then GETDATE() - [SOW Completion Date] END) between 0   and 30  THEN '< 1 Month'---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                               WHEN (CASE WHEN M.Stagedate IS NULL  Then GETDATE() - [SOW Completion Date] END) between 30  and 60  THEN '1 - 2 Months'---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                               WHEN (CASE WHEN M.Stagedate IS NULL  Then GETDATE() - [SOW Completion Date] END) between 60  and 90  THEN '2 - 3 Months'---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                               WHEN (CASE WHEN M.Stagedate IS NULL  Then GETDATE() - [SOW Completion Date] END) between 90  and 180 THEN '3 - 6 Months'---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                               WHEN (CASE WHEN M.Stagedate IS NULL  Then GETDATE() - [SOW Completion Date] END) between 180 and 365 THEN '6 - 12 Months' ---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                               WHEN (CASE WHEN M.Stagedate IS NULL  Then GETDATE() - [SOW Completion Date] END) between 365 and 730 THEN '1 - 2 Years'  ---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                               WHEN (CASE WHEN M.Stagedate IS NULL  Then GETDATE() - [SOW Completion Date] END) > 730 THEN '> 2 Years' ---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                       END END AS GAP2_AGE_Cat
                
                       ,CASE WHEN M.Stagedate IS not NULL THEN 'As-Built Done' ---- Chaged to Status Date Arsalan (HBZ 3/28/2020) 
                                  when PPCAppRep.JobNumber is not null or QWM.[As-Built Current Stage] is not null then 'Asbuilt Under Approval' 
								  when X.Milestone IS NOT NULL THEN X.Milestone
                                  WHEN M.[AsBuiltCost_SR] < 1 AND X.Milestone IS NULL AND M.Department like 'OSP%' THEN 'Under Design'
								  when m.Department = 'FNI_Material' and x.Milestone is null then 'Under Job Creation'
								  when m.Department = 'CNI'  and x.Milestone is null then 'TBD'
								   when m.Department = 'UNG'  and x.Milestone is null then 'TBD'
								  when m.Department = 'PCC' then 'Under Design'
								 ELSE 'TBD' END AS Milestone

                       ,CASE  WHEN M.Stagedate IS not NULL THEN 12 ---- Chaged to Status Date Arsalan (HBZ 3/28/2020)
                                  when PPCAppRep.JobNumber is not null  or QWM.[As-Built Current Stage] is not null then 11
								  when X.Milestone IS NOT NULL THEN X.MilestoneOrder
                                  WHEN M.[AsBuiltCost_SR] < 1 AND X.Milestone IS NULL AND M.Department like 'OSP%' THEN 2
								  when m.Department = 'FNI_Material' and x.Milestone is null then 5.5
								  when m.Department = 'CNI' and x.Milestone is null then 0.1
								  when m.Department = 'UNG'  and x.Milestone is null then 0.1
								  when m.Department = 'PCC' then 2
                                  ELSE 0.1 END AS MilestoneOrder
                   ,X.CivilDependency
                   ,case      
                                   when X.CivilDependency in ('SSO Not Submitted','CW not Completed','Civil HO','Civil in progress','Pending HO to O&M','Pending Civil PAT','Pending RFI','Site not Ready','Depend on Other Contractor') then 'CW Issue'
                                   when X.CivilDependency in ('FDED issue','FDED Not Approved','NE Not submitted','NE Not Approved','Pending DC Power Upgrade','ISR not Approved') then 'Design Issue'
                                   when X.CivilDependency in ('Delay in PAT') then 'Impl / ADMS / Acceptance issue'
                                   when X.CivilDependency in ('Owner Issue','Access Issue','Access issue','Baladiya Permit') then 'Owner / Access Issue'
                                   when X.CivilDependency in ('ISOW/WO cancelled/Revision','Not in Scope','On Hold by STC') then 'Scope Issue'
                                   when X.CivilDependency in ('Pending HOC','Sharing site','Pending Igate approval','MOU Not Signed','Contract Not Signed','FBP Not submitted','Legal Issue','SAQ / SHO','FBP Not Approved') then 'SHO / Contract issue'
                                   when X.CivilDependency in ('Wrong Location','Re-Design') then 'SOW / Design Issue'
                                   when X.CivilDependency is not null then 'Others'
                                   else null
                   end as CivilDependencyCat
                   ,X.TelecomDependency
                   ,case
                                   when X.TelecomDependency in ('Interference issue','MW_Tx','BH Issue / Not Ready','Link upgrade','Frequency Issue','Transmission Design') then 'BH  / RF / Tx issue'
                                   when X.TelecomDependency in ('Site not Ready','Depend on Other Contractor','CableTray, IndirectDC','DC','EBUCustomerDC','IndirectDC','TieCable, FiberSplicing','CableTray',
                                                                                                                                                   'CableTray, DC','CableTray, TieCable, MDT','DC, FiberUnderImplementationFNI','DC, FP','DC, FP, FiberUnderImplementationFNI','DCN','DCN, ProtectionRoute',
                                                                                                                                                   'EBUCustomerBuildingNotReady, FiberNotHandedOver','EBUCustomerBuildingNotReady, SOWUnderRevision, UnderCancellation','EBUCustomerFS','EBUCustomerFS, InProgress','FP') then 'CW issue'
                                   when X.TelecomDependency in ('ADMS Approval','Acceptance criteria','Soft PAT delay','Dismantled / To be Dismantled','Temp BH','Impl Issue on Previous Job','Re-farming',
                                                                                                                                                   'COW Movement / Off-air','OILs Clearance','Pending HO to O&M','Materials Issue','Under Health Check','IN_PRG','Delay in PAT','MDT','MDT, Material',
                                                                                                                                                   'MDT, IndirectMigration') then 'Impl / ADMS / Acceptance issue'
                                   when X.TelecomDependency in ('Material','Material, InProgress') then 'Material'
                                   when X.TelecomDependency in ('Restricted Area','Access Issue','Access') then 'Owner / Access Issue'
                                   when X.TelecomDependency in ('FTK site not ready','Critical Tower','To Start CW','Pending SCECO Power','CW not Completed','Civil in progress','Power Issue','Pending Civil PAT','Pending RFI','Under Civil Work') then 'Pending Civil / Power'
                                   when X.TelecomDependency in ('ISOW/WO cancelled/Revision','Not in Scope','On Hold by STC') then 'Scope Issue'
                                   when X.TelecomDependency in ('Pending HOC','Sharing site','SCO / SAF not Issued','Legal Issue','SAQ / SHO','Not SHO') then 'SHO / Contract issue'
                                   when X.TelecomDependency in ('SOW  / JISOW Issue','FDED issue','Design / MOP Issue','NE Not submitted','Delay in NE','Wrong Location','Re-Design','UnderCancellation, IndirectMigration','SOWUnderRevision, UnderCancellation',
                                                                                                                                                   'UnderCancellation','SOWUnderRevision') then 'SOW / Design Issue'
                                   when X.TelecomDependency in ('FiberMigration','FiberUnderImplementationFNI','FiberUnderImplementationFNI, IndirectFiber','FiberUnderJV','IndirectFiber','Access, FiberNotHandedOver','ADMS, FiberUnderImplementationFNI','FiberCutUnderOperation',
                                                                                                                                                   'FiberCutUnderOperation, InProgress','FiberCutUnderOperation, UnderCancellation','FiberNotHandedOver, SOWUnderRevision, UnderCancellation','FiberNotHandedOver, UnderCancellation','FiberUnderImplementationFNI, IndirectFP, IndirectDC',
                                                                                                                                                   'Material, IndirectFiber','PATed, IndirectFiber','TieCable','TieCable, FiberCutUnderOperation','TieCable, FiberCutUnderOperation, FiberUnderImplementationFNI','TieCable, FiberUnderImplementationFNI','TieCable, IndirectFP, IndirectDC, IndirectFiber',
                                                                                                                                                   'TieCable, PATed') then 'Fiber'
                                   when X.TelecomDependency is not null then 'Others'
                                   else null
                   end as TelecomDependencyCat
                   ,X.M1_In
                   ,X.M1_Out
                   ,X.M2_In
                   ,X.M2_Out
                   ,X.M3_In
                  ,X.M3_Out
                  ,X.M4_In
                  ,X.M4_Out
                  ,X.[M4.5_In]
                  ,X.[M4.5_Out]
                  ,X.M5_In
                  ,X.M5_Out
                  ,X.M6_In
                  ,X.M6_Out
                  ,X.M7_In
                  ,X.M7_Out
                  ,X.M8_In
                  ,X.M8_Out
                  ,X.PlannedSites
                  ,X.PlannedCost
                  ,X.ForecastSites
                  ,X.ForecastCost
                  ,[DP Date]
                  ,[OSP PD Cost]
                  , iif(oldach.JOB_NO is null, 'No','Yes') oldAchFlag--------------------PCC requirement for Old ACH
              FROM  dbo.T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp M --Add MOP Approval Date
              LEFT JOIN 

              (SELECT Job_no,SUM(APPR_ASB) AS APPR_ASB, SUM(PREVIOUS_ASB_UR) AS PREVIOUS_ASB_UR FROM [FNI_TF_OSP].[dbo].[T_PC_V_JOB_DETAILS_ACHIEV_VIEW2]
              GROUP BY Job_no) AsB on M.[JobNumber] = AsB.Job_no
              left join [FNI_TF_OSP].[dbo].tblPurchaseOrder PO on M.PONumber = PO.PONumber 
              LEFT JOIN (   
                          
SELECT
                            'WNI' AS Department ,
                              S.Jobnumber,
                              S.JobNumber JobNFTS,
                              case when M.[Site ID] is not null then M.[Site ID]
							  when N.[Site ID] is not null then N.[Site ID] collate database_default
							 -- else S.JobNumber
                              end as SiteID          
                              ,CASE  
							    WHEN S.StageDate is not null Then 'As-Built Done' --Excluding Asbuilt
								When ePAT.Stage in ('Assign PAT Reviewer',
														'Assign Reviewer; Handover Completed;',
														'Assign Reviewer; Telecom District Completed; Civil District Rejected; Power District Rejected;',
														'Assign Reviewer; Telecom District Completed; Civil District; Power District;',
														'Assign Reviewer; Telecom District Completed; Civil Field; Power Field;',
														'Assign Reviewer; Telecom Handover Completed; Civil District; Power District;',
														'Assign Reviewer; Telecom Handover Completed; Civil Field; Power Field;',
														'Assign Reviewer; Telecom Handover Completed; Schedule Civil; Schedule Power;') then 'Under As-Built (WNI Inbox)'
								When ePAT.Stage in ('PAT',
														'Review PAT',
														'Review PAT; Telecom District Completed; Civil Field; Power Field;',
														'Review PAT; Telecom Handover Completed; Civil District; Power District;',
														'Review PAT; Telecom Handover Completed; Civil Field; Power Field;',
														'Review PAT; Telecom Handover Completed; Schedule Civil; Power Field;',
														'Review PAT; Telecom Handover Completed; Schedule Civil; Schedule Power;') then 'Under As-Built (NRT)'
								WHEN S.Element ='MTX' and S.StageDate is null and (S.[PAT End] is not null or N.[PAT Status] = 'Accepted') THEN 'Under As-Built (Vendor)' -- For MTX & CW
								
								when S.Element ='MTX' and S.[SOW Work Type]  in (
								
																					'Dismantling'
																					,'Dismantling – Write-Off'
																					,'Dismantling with Relocation'
																					,'Dismantling with Temporary Warehouse Storage'
								
																					) and (isnull([MOP Status - Design],'')<>'Approved'  )

								THEN  'Under MOP'
								when S.Element ='MTX' and S.[SOW Work Type]  in (
								
																					'Dismantling'
																					,'Dismantling – Write-Off'
																					,'Dismantling with Relocation'
																					,'Dismantling with Temporary Warehouse Storage'
								
																					) and [MOP Status - Design]='Approved'    Then 'Dismantling'
								



								when S.Element ='MTX' and S.[PAT End] is null and [Submit Request Date] IS NOT NULL THEN 'Under PAT' -- For MTX & CW
								-- WHEN S.Element ='MTX' and N.[Submit Request Date] IS NOT NULL and N.[MW Status] in('Accepted', 'N/A') THEN 'Under Integration'  -- For MTX & CW




								WHEN S.Element ='MTX' and N.[Submit Request Date] is NULL and [MOP Status - Design]='Approved'  THEN 'Under Integration'  -- For MTX & CW -- mOp status  appoved then under design 

								WHEN S.Element ='MTX' and N.[Submit Request Date] is NULL and  (isnull([MOP Status - Design],'')<>'Approved'  ) THEN  'Under MOP'  -- For MTX & CW

					

								---where element in CWEC , Rest in NFTS  as Per Abu Ayesha 8/22/2021

								WHEN S.Element ='CW' and S.[element Code]='CWEC' and S.StageDate is null and (S.[PAT End] is not null or N.[PAT Status] = 'Accepted') THEN 'Under As-Built (Vendor)' -- For MTX & CW
								when S.Element ='CW' and S.[element Code]='CWEC' and S.[PAT End] is null and [Submit Request Date] IS NOT NULL THEN 'Under PAT' -- For MTX & CW
							---	WHEN S.Element ='CW' and S.[element Code]='CWEC' and N.[Submit Request Date] IS NOT NULL and N.[MW Status] in('Accepted', 'N/A') THEN 'Under Integration'  -- For MTX & CW
								
								WHEN S.Element ='CW' and S.[element Code]='CWEC' and  [MOP Status - Design]='Approved'   and N.[Submit Request Date] is NULL THEN 'Under Integration'  -- For MTX & CW

								WHEN S.Element ='CW' and S.[element Code]='CWEC' and  (isnull([MOP Status - Design],'')<>'Approved'  ) and N.[Submit Request Date] is NULL THEN  'Under MOP'  -- For MTX & CW



								WHEN S.StageDate is null and (S.[PAT End] is not null or M.[Telecom PAT] is not null) THEN 'Under As-Built (Vendor)'--'Pated Not As-Builted'
                                when S.[PAT End] is null and [Site On Air Actual] IS NOT NULL THEN 'Under PAT' --'On-Air Not Pated'
                                when [Site Integrated Actual] is not null AND [Site On Air Actual] is null THEN 'Integrated Not On-Air' --'Integ Not On-Air'
								when  Element in ('SW - CNI','SW - WNI') or Element like '%SBS%'  then 'Others'
                                When [Site Installed Actual] is not null AND [Site Integrated Actual] is null THEN 'Under Integration' --'Installed Not Integration'
                                When [PISM Accepted Actual] is not null AND [Site Installed Actual] is null THEN 'Under Installation' --'RFI Not Installation'
                                When [CW Start Actual] is not null AND [PISM Accepted Actual] is null THEN 'Under Civil' --'Designed Not RFI'
								When  ( [MOP Status - Design]='Approved'  and [CW Start Actual] is null  and [Basic Work Type]<>'New Sites') THEN 'Under Civil' --under civil for old sites Abu Ayesha 8/22/21

								-----When M.[WNI Activity ID] is null and N.[Telecom Job Number] collate database_default is null then 'Others' ---- Removed as its undetermeined conditon as no WNI ID or JobNumber
                                When  
								----[SAF Received Actual] is not null  and [CW Start Actual] is null  and 
								
								[Basic Work Type]='New Sites'  and [Handover To Civil Actual] is null  THEN 'Under Permit' --Not Acquired --Added filter for new sites as Per Abu Ayesha 8/22/21
								
								
								
								When   [MOP Status - Design] ='Approved'  and [CW Start Actual] is null  and [Basic Work Type]='New Sites'  and [Handover To Civil Actual] is not null  THEN 'Under Civil' --Not Acquired --Added filter for new sites as Per Abu Ayesha 8/22/21


                                WHEN s.[SOW Completion Date] IS NOT NULL AND isnull([MOP Status - Design],'')<>'Approved' THEN 'Under MOP' --Acquired not designed
								else 'TBD'
                                END AS Milestone
                               , 	CASE  
							    WHEN S.StageDate is not null Then 12 --Excluding Asbuilt
								When ePAT.Stage in ('Assign PAT Reviewer',
														'Assign Reviewer; Handover Completed;',
														'Assign Reviewer; Telecom District Completed; Civil District Rejected; Power District Rejected;',
														'Assign Reviewer; Telecom District Completed; Civil District; Power District;',
														'Assign Reviewer; Telecom District Completed; Civil Field; Power Field;',
														'Assign Reviewer; Telecom Handover Completed; Civil District; Power District;',
														'Assign Reviewer; Telecom Handover Completed; Civil Field; Power Field;',
														'Assign Reviewer; Telecom Handover Completed; Schedule Civil; Schedule Power;') then 10.5
								When ePAT.Stage in ('PAT',
														'Review PAT',
														'Review PAT; Telecom District Completed; Civil Field; Power Field;',
														'Review PAT; Telecom Handover Completed; Civil District; Power District;',
														'Review PAT; Telecom Handover Completed; Civil Field; Power Field;',
														'Review PAT; Telecom Handover Completed; Schedule Civil; Power Field;',
														'Review PAT; Telecom Handover Completed; Schedule Civil; Schedule Power;') then 10.6
								WHEN S.Element ='MTX' and S.StageDate is null and (S.[PAT End] is not null or N.[PAT Status] = 'Accepted') THEN 10 -- For MTX & CW
								
								
								when S.Element ='MTX' and S.[SOW Work Type]  in (
								
																					'Dismantling'
																					,'Dismantling – Write-Off'
																					,'Dismantling with Relocation'
																					,'Dismantling with Temporary Warehouse Storage'
								
																					) and (isnull([MOP Status - Design],'')<>'Approved'  )

								THEN  1.02
								when S.Element ='MTX' and S.[SOW Work Type]  in (
								
																					'Dismantling'
																					,'Dismantling – Write-Off'
																					,'Dismantling with Relocation'
																					,'Dismantling with Temporary Warehouse Storage'
								
																					) and [MOP Status - Design]='Approved'    Then 1.03
								
								
								
								
								
								when S.Element ='MTX' and S.[PAT End] is null and [Submit Request Date] IS NOT NULL THEN 9 -- For MTX & CW
								-- WHEN S.Element ='MTX' and N.[Submit Request Date] IS NOT NULL and N.[MW Status] in('Accepted', 'N/A') THEN 'Under Integration'  -- For MTX & CW

								WHEN S.Element ='MTX' and N.[Submit Request Date] is NULL and [MOP Status - Design]='Approved'  THEN 7  -- For MTX & CW -- mOp status  appoved then under design 

								WHEN S.Element ='MTX' and N.[Submit Request Date] is NULL and  (isnull([MOP Status - Design],'')<>'Approved'  ) THEN 1.02  -- For MTX & CW

					

								---where element in CWEC , Rest in NFTS  as Per Abu Ayesha 8/22/2021

								WHEN S.Element ='CW' and S.[element Code]='CWEC' and S.StageDate is null and (S.[PAT End] is not null or N.[PAT Status] = 'Accepted') THEN 10 -- For MTX & CW
								when S.Element ='CW' and S.[element Code]='CWEC' and S.[PAT End] is null and [Submit Request Date] IS NOT NULL THEN 9 -- For MTX & CW
							---	WHEN S.Element ='CW' and S.[element Code]='CWEC' and N.[Submit Request Date] IS NOT NULL and N.[MW Status] in('Accepted', 'N/A') THEN 'Under Integration'  -- For MTX & CW
								WHEN S.Element ='CW' and S.[element Code]='CWEC' and  [MOP Status - Design]='Approved'   and N.[Submit Request Date] is NULL THEN 7  -- For MTX & CW

								WHEN S.Element ='CW' and S.[element Code]='CWEC' and  (isnull([MOP Status - Design],'')<>'Approved'  ) and N.[Submit Request Date] is NULL THEN 1.02  -- For MTX & CW




								WHEN S.StageDate is null and (S.[PAT End] is not null or M.[Telecom PAT] is not null) THEN 10--'Pated Not As-Builted'
                                when S.[PAT End] is null and [Site On Air Actual] IS NOT NULL THEN 9 --'On-Air Not Pated'
                                when [Site Integrated Actual] is not null AND [Site On Air Actual] is null THEN 8 --'Integ Not On-Air'
								when  Element in ('SW - CNI','SW - WNI') or Element like '%SBS%'  then 1
                                When [Site Installed Actual] is not null AND [Site Integrated Actual] is null THEN 7 --'Installed Not Integration'
                                When [PISM Accepted Actual] is not null AND [Site Installed Actual] is null THEN 6 --'RFI Not Installation'
                                When [CW Start Actual] is not null AND [PISM Accepted Actual] is null THEN 4 --'Designed Not RFI'
								When  ( [MOP Status - Design]='Approved'  and [CW Start Actual] is null  and [Basic Work Type]<>'New Sites') THEN 4 --under civil for old sites Abu Ayesha 8/22/21

						-----		When M.[WNI Activity ID] is null and N.[Telecom Job Number] collate database_default is null then 1
                                When   [Basic Work Type]='New Sites'  and [Handover To Civil Actual] is null  THEN 3 --Not Acquired --Added filter for new sites as Per Abu Ayesha 8/22/21
								
								
								
								When   [MOP Status - Design]='Approved'  and [CW Start Actual] is null  and [Basic Work Type]='New Sites'  and [Handover To Civil Actual] is not null  THEN 4 --Not Acquired --Added filter for new sites as Per Abu Ayesha 8/22/21


                                WHEN s.[SOW Completion Date] IS NOT NULL AND isnull([MOP Status - Design],'')<>'Approved' THEN 1.02 --Acquired not designed
								else 0.1
                               






                                END AS MilestoneOrder                                                                               ,
                            [Civil Dependency] [CivilDependency],
                            [Telecom Dependency] [TelecomDependency],
                            s.[SOW Completion Date] as M1_In,
                            S.MoPIssueDate as M1_Out,
                            [SAF Received Actual] as M2_In,
                            [Civil Design MOP Approval Date] as M2_Out,
                            [CW Start Actual] as M3_In,
                            [PISM Accepted Actual] as M3_Out,
                            null as M4_In,
                            null as M4_Out,
                            [PISM Accepted Actual] as [M4.5_In],
                            [Site Installed Actual] as [M4.5_Out],
                            [Site Installed Actual] as M5_In,
                            [Site Integrated Actual] as M5_Out,
                            [Site Integrated Actual] as M6_In,
                            [Site On Air Actual] as M6_Out,
                            [Site On Air Actual] as M7_In,
                            [PAT_Completion_Date] as M7_Out,
                            null as M8_In,
                            null as M8_Out,
                            [Site On Air Planned] as PlannedSites, --Same Date for Planned Sites/Cost in WNI
                            [Site On Air Planned] as PlannedCost,           --Same Date for Planned Sites/Cost in WNI
                            [Site On Air Forecast] as ForecastSites, --Same Date for Forecast Sites/Cost in WNI
                            [Site On Air Forecast] as ForecastCost, --Same Date for Forecast Sites/Cost in WNI
                            null as [DP Date],
                            null as [OSP PD Cost]

						

							FROM dbo.T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp S -- Add the rest of dates for WNI
                            LEFT JOIN [WNI_Audit].[dbo].[vWNI_Master_Tracker] M ON M.[WNI Activity ID] = S.[NPTWNIActivityId]
							left join 
							(select 
							[MW Handover ID], [MW Activity ID], [Site ID], [CLLI (Site)], [District], [MW Activity Type], [Sub Activity Type], [Submit For Integration]
							,case when  [Submit Request Date]='2400-01-01 00:00:00.000' then NULL else [Submit Request Date] end as [Submit Request Date]
							, [MW Status],
							[MW Status Date],
						
							[Optimisation Status], [Optimisation Date], [PAT Forecast Date], [Field PAT Status], [Field PAT Status Date], [Civil Field PAT Status], [Civil Field PAT Status Date], [Civil Field PAT Remarks], [Power Field PAT Status], [Power Field PAT Status Date], [Power Field PAT Remarks], [Soft PAT Status], [Soft PAT Status Date], [TTAC Status], [TTAC Status Date], [PAT Status], [PAT Status Date], [PAT Remarks], [Handover Status], [Handover Status Date], [Added To WFMS], [Added To WFMS Date], [Added To RTTS], [Added To RTTS Date], [Handover Module], [Site Status], [Job Status], [inboxTelecomPM], [MW Visibility], [MW Not Visible], [Optimisation], [Optimisation Rejected], [Telecom PAT], [Telecom Field PAT], [PAT Rejected], [Soft PAT], [FTTx NOC Rejected], [TTAC], [TTAC Rejected], [RTTS], [WFMS Transport], [WFMS Fixed], [Handed Over], [PM - Ready for PAT (NSAI OIL)], [PM - Rejected PAT (NSAI OIL)], [NRT - Schedule PAT (NSAI OIL)], [NRT - PAT (NSAI OIL)], [District - Field PAT (NSAI OIL)], [PAT Completed (NSAI OIL)], [Contractor Name], [Contractor Code], [SOW Number], [MOP Number], [Telecom Job Number], [PAT Notification Is Partial PAT], [PAT Notification Is Final PAT], [Job Is Non PATable], [PO Value], [Project Name], [SOW PM Approval Date], [PO Owner], [PM], [PAC Date], [PAC Approval Date], [Element Group Code], [Element Code], [Element Description], [Effective Contract Date], [End Implementation], [End Contract Date], [WO Number], [As Built Cost], [PO Name], [PO Number], [WO Status], [Design MOP Status], [Design MOP Status Date], [Finance Number], [PO Year], [ECTC CUL Discount], [ECTC Lump Sum Discount], [ECTC], [ECTC FOC], [SOW Cost], [SOW Lump Sum Discount], [SOW CUL Discount], [SOW FOC], [SOW CUL Gross Amount], [SOW Status], [SOW Work Type], [Model Description], [Model Name], [PAT Reference Number], [Scheduled PAT Date], [Job Description], [Activity PAT Status], [PAT Start], [PAT End], [Vendor PAT Ref Number], [PAT Document Received Date], [PAT Document To Contractor Date], [Design Contractor Reference Number], [Design Contractor Reference Date], [Design Document Received Date], [PAT Reviewer Name (Prime Only)], [PAT Doc Status], [Planned PAT End Date], [Planned PAT Start Date], [LatestStatus]
							
							from
							[WNI_Audit].[dbo].[MW_Handover]
							
							
							)
							
							N ON N.[Telecom Job Number] = S.JobNumber collate database_default
							left join 
							(Select [JobNumber],Stage from [dbo].[WNI_ePAT_List_Static]
							union
							Select jobnumber,stage from [dbo].[WNI_MW_ePAT_List_Static]
							) ePAT on ePAT.jobnumber = S.JobNumber
                           where S.Department='WNI'

                           UNION
    
                           SELECT 
                                           'OSP' AS Department,
                                           case 
                                                           when M.JobWorkOrder is null then S.JobNumber collate database_default
                                                           else M.JobWorkOrder
                                           end as JobNumber,
                                           S.JobNumber JobNFTS,
                                           S.Origin_Number collate database_default as SiteID,
                                           --CASE 
                                           --             WHEN m.Priority IN ('P5 - Not designed yet','P5.1 Returned to design','P6- Under Cancellation') THEN 'M1-Under Design' 
                                           --             When m.Priority = 'P4.5 - No Permit ' THEN 'M2-Under Permit'
                                           --             When m.Priority IN ('P4 - Civil not started','P3 - Civil in progress in the field') THEN 'M3-Under Civil'
                                           --             When m.Priority = 'P2 - Fiber in progress in the field' THEN 'M4-Under Fiber'
                                           --             When m.Priority = 'P1 - Fiber and Civil completed in field' THEN 'M7-Under PAT'
                                           --             When m.Priority = 'P0.5 -Asbuilt' THEN 'M8-Under As-Built'
                                           --END AS Milestone,
                                           case
                                                           --when M.[As-Built Director OUT] is not null then 'As-Built Done'
                                                           when M.[PAT and Handover Actual End Date] is not null and M.[As-Built PCC Out] is null then 'Under As-Built'
                                                           when  M.[Fibre Work Actual End Date] is not null and M.[PAT and Handover Actual End Date] is null then 'Under PAT'
                                                           when (M.[Civil Work Actual End Date] is not null or M.[DocumentType] = 'Permit not required and civil not required') and M.[Fibre Work Actual End Date] is null then 'Under Civil/Fiber'
                                                           when  (M.[Permit Actual End Date] is not null or M.[DocumentType] = 'Permit not required and civil required') and  M.[Civil Work Actual End Date] is null then 'Under Civil/Fiber'
                                                           when M.[Network Design QC Actual End Date]  is not null and M.[Permit Actual End Date] is null then 'Under Permit'
                                                           when M.ScopeIntimationDate is not null and M.[Network Design QC Actual End Date] is null then 'Under Design'
                                           end as Milestone
                                           ,case
                                                           --when M.[As-Built Director OUT] is not null then 'As-Built Done'
                                                           when M.[PAT and Handover Actual End Date] is not null and M.[As-Built Director OUT] is null then 10
                                                           when  M.[Fibre Work Actual End Date] is not null and M.[PAT and Handover Actual End Date] is null then 9
                                                           when (M.[Civil Work Actual End Date] is not null or M.[DocumentType] = 'Permit not required and civil not required') and M.[Fibre Work Actual End Date] is null then 5
                                                           when (M.[Permit Actual End Date] is not null or M.[DocumentType] = 'Permit not required and civil required') and  M.[Civil Work Actual End Date] is null then 5
                                                           when M.[Network Design QC Actual End Date]  is not null and M.[Permit Actual End Date] is null then 3
                                                           when M.ScopeIntimationDate is not null and M.[Network Design QC Actual End Date] is null then 2
                                           end as MilestoneOrder
                                           
                                           
                                           ,
                                           case 
                                                           when dep.Dependency='Baladiya Permit' then dep.Dependency collate database_default
                                                           when dep.Dependency in ('Access issue','ISOW/WO cancelled/Revision','Not enough Resources','Not in Scope','On Hold by STC','Wrong Location','Others','Re-Design','Site not Ready','Depend on Other Contractor','Delay in PAT') and M.JobType='Civil' then dep.Dependency collate database_default
                                           end        as CivilDependency,
                                           case 
                                                           when dep.Dependency in ('Delay in NE','Material') then dep.Dependency collate database_default
                                                           when dep.Dependency in ('Access issue','ISOW/WO cancelled/Revision','Not enough Resources','Not in Scope','On Hold by STC','Wrong Location','Others','Re-Design','Site not Ready','Depend on Other Contractor','Delay in PAT') and M.JobType='Fiber' then dep.Dependency collate database_default
                                           end        as TelecomDependency,
                                           M.ScopeIntimationDate as M1_In,
                                           M.[Network Design QC Actual End Date] as M1_Out,
                                           M.[Network Design QC Actual End Date] as M2_In,
                                           M.[Permit Actual End Date] as M2_Out,
                                           M.[Permit Actual End Date] as M3_In,
                                           M.[Civil Work Actual End Date] as M3_Out,
                                           M.[Civil Work Actual End Date] as M4_In,
                                           M.[Fibre Work Actual End Date] as M4_Out,
                                           null as [M4.5_In],
                                           null as [M4.5_Out],
                                           null as M5_In,
                                           null as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                           M.[Fibre Work Actual End Date] as M7_In,
                                           M.[PAT and Handover Actual End Date] as M7_Out,
                                           M.[PAT and Handover Actual End Date] as M8_In,
                                           M.[As-Built Director OUT] as M8_Out,
                                           M.[FJS Planned End Date] as PlannedSites,
                                           M.[FJS Planned End Date] PlannedCost, -- To be crosschecked 
                                           M.[FJS Forecast End Date] as ForecastSites,
                                           M.[FJS Forecast End Date] ForecastCost, -- To be crosschecked 
                                           M.[DP Date],
                                           case 
                                                           when M.[OSP PD Cost] is not null then M.[OSP PD Cost]
                                                           else M.ReconciledCost
                                           end as [OSP PD Cost]


                           FROM Infra_Quick_WIn M -- link from CRDB 
                           LEFT JOIN [FNI_TF_OSP].dbo.T_OSPJobWORecWithStatusRep S ON M.JobWorkOrder = S.JobWorkOrder COLLATE DATABASE_DEFAULT
                           left join Infra_FirstExpiredMilestoneflag dep on dep.RefNumber=M.Origin_Number collate database_default

                           UNION
                         SELECT
                                           'CNI' AS Department,
                                           T.JobNumber,
                                           T.JobNumber JobNFTS,
                                          case 
                                                          when T.SiteNumber is not null then T.SiteNumber
                                                          else ECTC.MoPNumber collate database_default
                                           end as SiteID,
										    case
										                   
														   
														   when [SoftPATActual] is not null      and [SoftPATActual]<> '1899-12-31 00:00:00.000' then 'Under As-Built'

														   when CommissionActual  is not null    and CommissionActual<> '1899-12-31 00:00:00.000' then 'Under PAT'

														   when [InstallationActual] is not null and [InstallationActual]<> '1899-12-31 00:00:00.000' then 'Under Integration' 
														   when  ECTC.[MOP Status - Design]='Approved' then 'Under Installation'
														   	when ECTC.[MOP Status - Design]<>'Approved' or ECTC.[MOP Status - Design] is null then  'Under MOP' 
										          
										   end as Milestone,
                                          case
										                   
										                  when [SoftPATActual] is not null        and [SoftPATActual]<> '1899-12-31 00:00:00.000'  then  10
																								 
														   when CommissionActual  is not null     and CommissionActual<> '1899-12-31 00:00:00.000'  then 9
																								 
														   when [InstallationActual] is not null  and [InstallationActual]<> '1899-12-31 00:00:00.000' then 7
														   when  ECTC.[MOP Status - Design]='Approved' then 6
														   	when ECTC.[MOP Status - Design]<>'Approved' or ECTC.[MOP Status - Design] is null then  1.02
										          
										   end as MilestoneOrder,
										  
                                           null as CivilDependency,
                                           T.Dependencies as TelecomDependency,
                                           null as M1_In,
                                           null as M1_Out,
                                           null as M2_In,
                                           null as M2_Out,
                                           null as M3_In,
                                           null as M3_Out,
                                           null as M4_In,
                                           null as M4_Out,
                                           null as [M4.5_In],null as [M4.5_Out],
                                           ECTC.[SOW Completion Date] as M5_In,
                                           ECTC.[PAT End] as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                           ECTC.[PAT End] as M7_In,
                                           ECTC.[PAC Date] as M7_Out,
                                           ECTC.[PAC Date] as M8_In,
                                           DATEADD(d,5,ECTC.[PAC Date]) as M8_Out,
                                           null as PlannedSites,
                                           null as PlannedCost, -- To change date 
                                           null as ForecastSites,
                                           null as ForecastCost, -- To change
                                           null as [DP Date],
                                           null as [OSP PD Cost]
						FROM [FNI_TF_OSP].[dbo].Infra_TransmissionJobViewAll T						
						   Left join [dbo].T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp ECTC on ECTC.JobNumber=T.JobNumber collate database_default
						   left join [dbo].T_vECTCJobLevel_Active_POs ECT_ALL on ECTC.JobNumber=ECT_ALL.JobNumber collate database_default
                           where ECTC.Department='CNI'



						   UNION 
						    SELECT
                                           'CNI' AS Department,
                                           T.JobNumber  collate database_default ,
                                           T.JobNumber  collate database_default JobNFTS,
                                          case 
                                                          when T.sitenumber is not null then T.sitenumber  collate database_default
                                                          else ECTC.MoPNumber collate database_default
                                           end as SiteID,
										    case
										                    
										                    when T.[PATApprovedFromDCCDate] is not null then 'Under As-Built'
															when T.[ImplementationActualDate] is not null then 'Under PAT'
															when T.[DesignMOPTechnicaStatus]='Approved' and  T.[DesignMOPTechnicalStatusDate] is not null then 'Under Integration'
															when T.[DesignMOPSubmission] is not null then 'Under MOP' ---'Under MOP Approval'
															else  'Under MOP' --'Under MOP Submission'
										   end  collate database_default as Milestone,
                                          case
										                   
										            

														     when T.[PATApprovedFromDCCDate] is not null then 10
															when T.[ImplementationActualDate] is not null then 9
															when T.[DesignMOPTechnicaStatus]='Approved' and  T.[DesignMOPTechnicalStatusDate] is not null then 7
															when T.[DesignMOPSubmission] is not null then 1.02 --1.49
															else 1.02 --1.04


										   end as MilestoneOrder,
										  
                                           null as CivilDependency,
                                           T.[DependencyRemarks] as TelecomDependency,
                                           null as M1_In,
                                           null as M1_Out,
                                           null as M2_In,
                                           null as M2_Out,
                                           null as M3_In,
                                           null as M3_Out,
                                           null as M4_In,
                                           null as M4_Out,
                                           null as [M4.5_In],null as [M4.5_Out],
                                           ECTC.[SOW Completion Date] as M5_In,
                                           ECTC.[PAT End] as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                           ECTC.[PAT End] as M7_In,
                                           ECTC.[PAC Date] as M7_Out,
                                           ECTC.[PAC Date] as M8_In,
                                           DATEADD(d,5,ECTC.[PAC Date]) as M8_Out,
                                           null as PlannedSites,
                                           null as PlannedCost, -- To change date 
                                           null as ForecastSites,
                                           null as ForecastCost, -- To change
                                           null as [DP Date],
                                           null as [OSP PD Cost]
                           FROM Infra_IPMPLSMasterSheetView  T 
						
						   Left join [dbo].T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp ECTC on ECTC.JobNumber=T.JobNumber  collate database_default
						   left join [dbo].T_vECTCJobLevel_Active_POs ECT_ALL on ECTC.JobNumber=ECT_ALL.JobNumber collate database_default
                           where ECTC.Department='CNI'

						   union
						    select 
									  'CNI' AS Department,
                                           T.[Job Number]  collate database_default,
                                           T.[Job Number]  collate database_default JobNFTS,
                                          [Site Number]  collate database_default as SiteID,
										    
										               case 


													    when T.[PAT Actual Date] is not null then 'Under As-Built'
															when T.[Implementation Actual Date] is not null then 'Under PAT'
															when T.[HW Actual Date] is not null then  'Others'   ---'Under Implementation'
															when ECTC.[MOP Status - Design]='Approved' then 'Under Installation'
															when T.[HW Planned Date] is  null and ECTC.[MOP Status - Design]='Approved' then   'Others' --'Under Implementation'
															when ECTC.[MOP Status - Design]<>'Approved' or ECTC.[MOP Status - Design] is null then  'Under MOP' -- 'Under MOP Approval'
														
														end  collate database_default
										    as Milestone,
                                          
										   case 
														
														    when T.[PAT Actual Date] is not null then 10
															when T.[Implementation Actual Date] is not null then 9
															---when T.[HW Actual Date] is not null then 1
															when ECTC.[MOP Status - Design]='Approved' then 6
														--	when T.[HW Planned Date] is  null and ECTC.[MOP Status - Design]='Approved' then 1
															when ECTC.[MOP Status - Design]<>'Approved' or ECTC.[MOP Status - Design] is null then 1.02--1.49
														
														end

										    as MilestoneOrder,
										  
                                           null as CivilDependency,
                                           T.[Scope Dependency 1]  collate database_default as TelecomDependency,
                                           null as M1_In,
                                           null as M1_Out,
                                           null as M2_In,
                                           null as M2_Out,
                                           null as M3_In,
                                           null as M3_Out,
                                           null as M4_In,
                                           null as M4_Out,
                                           null as [M4.5_In],null as [M4.5_Out],
                                           ECTC.[SOW Completion Date] as M5_In,
                                           ECTC.[PAT End] as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                           ECTC.[PAT End] as M7_In,
                                           ECTC.[PAC Date] as M7_Out,
                                           ECTC.[PAC Date] as M8_In,
                                           DATEADD(d,5,ECTC.[PAC Date]) as M8_Out,
                                           null as PlannedSites,
                                           null as PlannedCost, -- To change date 
                                           null as ForecastSites,
                                           null as ForecastCost, -- To change
                                           null as [DP Date],
                                           null as [OSP PD Cost]

										   --select top 10 t.*
                           FROM [dbo].[Infra CNI Data Core 9/1/2021]  T 
						
						   Left join [dbo].T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp ECTC on ECTC.JobNumber=T.[Job Number] collate database_default
						--   left join [dbo].T_vECTCJobLevel_Active_POs ECT_ALL on ECTC.JobNumber=ECT_ALL.JobNumber collate database_default
                           where ECTC.Department='CNI'

						 

						   union
						   SELECT
                                           'CNI' AS Department,
                                           T.[Job#],
                                           T.[Job#] JobNFTS,
                                          null as SiteID,
										    
										               case 


													    when T.[PAT Actual] is not null then 'Under As-Built'
															when T.[Integration Actual date] is not null then 'Under PAT'
															when T.[MOP Approval Actual date] is not null then 'Under Integration'

															---material installation needs to be discussed with the team

														--	when T.[Material Installation Actual date] is not null then  'Under MOP' ---'Under MOP Approval'
													--		when [Material Installation_(Y/N/NA)] <>'NA' and [Site survey Actual date] is not null then 'Under Installation'
															when [Site survey Actual date] is not null then   'Under MOP' --'Under MOP Approval'
															else 'Under Survey'
														end
										    as Milestone,
                                          
										                case   
										            when T.[PAT Actual] is not null then 10.00
															when T.[Integration Actual date] is not null then 9.00
															when T.[MOP Approval Actual date] is not null then 7.00
														--	when T.[Material Installation Actual date] is not null then  1.02-- 1.49
													--	   when [Material Installation_(Y/N/NA)] <>'NA' and [Site survey Actual date] is not null then 1.51
															when [Site survey Actual date] is not null then  1.02---1.49
															else 1.01
														end


										    as MilestoneOrder,
										  
                                           null as CivilDependency,
                                           T.[Dependencies] as TelecomDependency,
                                           null as M1_In,
                                           null as M1_Out,
                                           null as M2_In,
                                           null as M2_Out,
                                           null as M3_In,
                                           null as M3_Out,
                                           null as M4_In,
                                           null as M4_Out,
                                           null as [M4.5_In],null as [M4.5_Out],
                                           ECTC.[SOW Completion Date] as M5_In,
                                           ECTC.[PAT End] as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                           ECTC.[PAT End] as M7_In,
                                           ECTC.[PAC Date] as M7_Out,
                                           ECTC.[PAC Date] as M8_In,
                                           DATEADD(d,5,ECTC.[PAC Date]) as M8_Out,
                                           null as PlannedSites,
                                           null as PlannedCost, -- To change date 
                                           null as ForecastSites,
                                           null as ForecastCost, -- To change
                                           null as [DP Date],
                                           null as [OSP PD Cost]
                           FROM [dbo].[Infra voice CNI Data]  T 
						
						   Left join [dbo].T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp ECTC on ECTC.JobNumber=T.[Job#] collate database_default
						   left join [dbo].T_vECTCJobLevel_Active_POs ECT_ALL on ECTC.JobNumber=ECT_ALL.JobNumber collate database_default
                           where ECTC.Department='CNI'

						   union
						     select 
									  'CNI' AS Department,
                                           T.[JobNumber],
                                           T.[JobNumber] JobNFTS,
                                          [SiteNumber] as SiteID,
										    
										               case 


															 when [SoftPATActualDate] is not null then 'Under As-Built' --10
														   when [FieldPATActualDate] is not null  or  [ServiceTestingActualDate] is not null then 'Under PAT' ---9.5
									
														   when [IntegrationActualDate]  is not null then 'Under PAT' -- 7.5
														   when [HWInstallationActualDate]  is not null then 'Under Integration' ---7.00
														   when [HLDLLDClearanceActualDate] is not null then 'Under Installation' 	 ---   6.95

												   else 'Under Design' end
										    as Milestone,
                                          
										case 	  
										
												   when [SoftPATActualDate] is not null then 10
												   when [FieldPATActualDate] is not null or [ServiceTestingActualDate] is not null then 9
								
												   when [IntegrationActualDate]  is not null then 7
												   when [HWInstallationActualDate]  is not null then 7.00
												   when [HLDLLDClearanceActualDate] is not null then 6

												   else 2.0 end 


										    as MilestoneOrder,
										  
                                           null as CivilDependency,
                                           null as TelecomDependency,
                                           null as M1_In,
                                           null as M1_Out,
                                           null as M2_In,
                                           null as M2_Out,
                                           null as M3_In,
                                           null as M3_Out,
                                           null as M4_In,
                                           null as M4_Out,
                                           null as [M4.5_In],null as [M4.5_Out],
                                           ECTC.[SOW Completion Date] as M5_In,
                                           ECTC.[PAT End] as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                           ECTC.[PAT End] as M7_In,
                                           ECTC.[PAC Date] as M7_Out,
                                           ECTC.[PAC Date] as M8_In,
                                           DATEADD(d,5,ECTC.[PAC Date]) as M8_Out,
                                           null as PlannedSites,
                                           null as PlannedCost, -- To change date 
                                           null as ForecastSites,
                                           null as ForecastCost, -- To change
                                           null as [DP Date],
                                           null as [OSP PD Cost]

										   --select top 10 ECTC.[PAC Date] , t.*
                           FROM [10.21.35.167,1467].[PMCSv2].[CORE].[CoreSingleTrackerView]  T 
						
						   Left join [dbo].T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp ECTC on ECTC.JobNumber=T.[JobNumber] collate database_default
						--   left join [dbo].T_vECTCJobLevel_Active_POs ECT_ALL on ECTC.JobNumber=ECT_ALL.JobNumber collate database_default
                           where ECTC.Department='CNI'




						   UNION 
						   SELECT
                                           'UNG' AS Department,
                                           T.[Job Number],
                                           T.[Job Number] JobNFTS,
                                            null  SiteID,
										     case [Dependency] 
											 when  'Under MOP Approval' then 'Under MOP'
											 when  'Under FAD Approval' then 'Under MOP'
											
											 when  null then 'TBD'



										             else  [Dependency] end
										    as Milestone,
											case [Dependency]  
											when 'Under Permit' then	3.00
											when 'Under Survey'	then 1.01
											when 'Under MOP Approval'	 then 1.02--1.49
											when 'Under FAD Approval' then 1.02
											when 'Under PAT'then	9.00
											when 'Under Integration' then	7.00
											when 'Under As-Built (Vendor)' then	10.00
											when 'Under Migration'	then 3.01
											when 'Dismantling' then 1.03
											when  null then 0.1


end
										    as MilestoneOrder,
										  
                                           null as CivilDependency,
                                           null as TelecomDependency,
                                           null as M1_In,
                                           null as M1_Out,
                                           null as M2_In,
                                           null as M2_Out,
                                           null as M3_In,
                                           null as M3_Out,
                                           null as M4_In,
                                           null as M4_Out,
                                           null as [M4.5_In],null as [M4.5_Out],
                                          nullif(ECTC.[SOW Completion Date] ,'2400-01-01 00:00:00.000') as M5_In,
                                          nullif(ECTC.[PAT End],'2400-01-01 00:00:00.000') as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                          nullif(ECTC.[PAT End] ,'2400-01-01 00:00:00.000')as M7_In,
                                          nullif(ECTC.[PAC Date],'2400-01-01 00:00:00.000') as M7_Out,
                                          nullif(ECTC.[PAC Date],'2400-01-01 00:00:00.000') as M8_In,
                                           DATEADD(d,5,ECTC.[PAC Date]) as M8_Out,
                                           null as PlannedSites,
                                           null as PlannedCost, -- To change date 
                                           null as ForecastSites,
                                           null as ForecastCost, -- To change
                                           null as [DP Date],
                                           null as [OSP PD Cost]

										   --select * 
                           FROM InfraGlobalLegacy T 

   Left join [dbo].T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp ECTC on ECTC.JobNumber=T.[Job Number] collate database_default
						   left join [dbo].T_vECTCJobLevel_Active_POs ECT_ALL on ECTC.JobNumber=ECT_ALL.JobNumber collate database_default
                           where ECTC.Department='UNG'
						     and [Dependency] is not null and [Dependency]<>''

                           UNION
                           SELECT
                                           'FNI_Material' AS Department,
                                           JobNumber,
                                           JobNumber JobNFTS,
                                           JobNumber SiteID,
                                           case
                                                         
														  
														  when  instsowstatus is null or instsowstatus ='PID Approved' then 'Under SOW Creation' 
														  when  instsowstatus in ('Finance Approved', 'PM Approved') and JobNumber is null then 'Under Job Creation'
														  when instwostatus <> 'Approved' and JobNumber is not null then 'Under 25%WO Creation'
                                                         when instasbstage is null then 'Under As-Built - INT' 
                          								when  instasbstage is not null   then 'Under As-Built'
														else 'TBD'
                                           end as Milestone,
                                           
                                           case
															when  instsowstatus is null or instsowstatus = 'PID Approved'   then 5.4
															when  instsowstatus in ('Finance Approved', 'PM Approved') and JobNumber is null  then  5.5
															when instwostatus <> 'Approved' and JobNumber is not null  then 5.6
                                                            when  instasbstage is null then 9.5
															when  instasbstage is not null  then 10
															else 0.1
                                           end as MilestoneOrder,
                                           null as CivilDependency,
                                           null as TelecomDependency,
                                           null as M1_In,
                                           null as M1_Out,
                                           null as M2_In,
                                           null as M2_Out,
                                           null as M3_In,
                                           null as M3_Out,
                                           null as M4_In,
                                           null as M4_Out,
                                           null as [M4.5_In]
                                           ,null as [M4.5_Out],
                                           null as M5_In,
                                           null as M5_Out,
                                           null as M6_In,
                                           null as M6_Out,
                                           null as M7_In,
                                           null as M7_Out,
                                           null as M8_In,
                                           null as M8_Out,
                                           null as PlannedSites,
                                           null as PlannedCost, 
                                           null as ForecastSites,
                                           null as ForecastCost, 
                                           null as [DP Date],
                                           null as [OSP PD Cost] 

                           FROM [FNI_TF_OSP].[dbo].[v.OSPMaterialJobDetailRpt]
                           where  [ContractorName] <>'STC Warehouse - Materials'

						  UNION

							 select   
							   'FNI_Telecom' AS Department ,
							   [Job number] collate database_default,
							   [Job number] collate database_default JobNFTS,
							   [Site Number] collate database_default Site_ID
							   ,CASE WHEN ([Handover Actual Date] is not null and year([Handover Actual Date] ) <> 2400) and ([As-Built Actual Date] is null or year([As-Built Actual Date]) = 2400) THEN 'Under As-Built'
							   when ([Integration Actual Date] is null and year( [Integration Actual Date]) <> 2400) and ([Handover Actual Date] IS NOT NULL or year([Handover Actual Date]) = 2400) THEN 'Under PAT' 
							   When ([Installation Actual Date]  is not null and year([Installation Actual Date]) <> 2400) AND ([Integration Actual Date] is null or year([Integration Actual Date]) = 2400) THEN 'Under Integration' 
							   When ([Design - MOP Actual Date] is not null and year([Design - MOP Actual Date] ) <> 2400) AND ([Installation Actual Date] is null or year([Installation Actual Date]) = 2400) THEN 'Under Installation' 
							   WHEN ([Scope Actual Date] IS NOT NULL and year([Scope Actual Date] ) <> 2400) AND [Design - MOP Actual Date] is null THEN 'Under Design' 
							   END AS Milestone

							   ,CASE WHEN ([Handover Actual Date] is not null and year([Handover Actual Date] ) <> 2400) and ([As-Built Actual Date] is null or year([As-Built Actual Date]) = 2400) THEN 10
							   when ([Integration Actual Date] is null and year( [Integration Actual Date]) <> 2400) and ([Handover Actual Date] IS NOT NULL or year([Handover Actual Date]) = 2400) THEN 9 
							   When ([Installation Actual Date]  is not null and year([Installation Actual Date]) <> 2400) AND ([Integration Actual Date] is null or year([Integration Actual Date]) = 2400) THEN 7 
							   When ([Design - MOP Actual Date] is not null and year([Design - MOP Actual Date] ) <> 2400) AND ([Installation Actual Date] is null or year([Installation Actual Date]) = 2400) THEN 6
							   WHEN ([Scope Actual Date] IS NOT NULL and year([Scope Actual Date] ) <> 2400) AND [Design - MOP Actual Date] is null THEN 2 
								END AS Milestoneorder

							   ,null as civildep,
							    null as telcomdep,
							    [Scope Actual Date] as M1_In,
							    [Design - MOP Actual Date] as M1_Out,
							    null as M2_In,
							    null as M2_Out,
							    null as M3_In,
							    null as M3_Out,
							    null as M4_In,
							    null as M4_Out,
							   [Design - MOP Actual Date] as [M4.5_In],
							   [Installation Actual Date] as [M4.5_Out],
							   [Installation Actual Date] as M5_In,
							   [Integration Actual Date]  as M5_Out,
							    null as M6_In,
							    null as M6_Out,
							    [Integration Actual Date] as M7_In,
							    [Handover Actual Date] as M7_Out,
							    [Handover Actual Date] as M8_In,
							    [As-Built Actual Date] as M8_Out,
							    [Handover Plan Date] as PlannedSites, --Same Date for Planned Sites/Cost in WNI
							    [Handover Plan Date] as PlannedCost,           --Same Date for Planned Sites/Cost in WNI
							    [Handover Forecast Date] as ForecastSites, --Same Date for Forecast Sites/Cost in WNI
							    [Handover Forecast Date] as ForecastCost, --Same Date for Forecast Sites/Cost in WNI
							    null as [DP Date],
							    null as [OSP PD Cost]
								 from Infra_All_FNI_View

							UNION

							 select   
							   'Design' AS Department ,
							   jobnumber collate database_default jobnumber,
							   jobnumber collate database_default JobNFTS,
							   SiteID collate database_default Site_ID,
							    Milestone,
							   case
							   when milestone = 'Integrated Not On-Air'  then 8 
							   when milestone = 'Asbuilt Under Approval' then 11
							   when Milestone = 'Under Asbuilt'			 then 10
							   when milestone = 'Under PAT'				 then 9 
							   when milestone = 'TBD'					 then 0.1 
							   when milestone = 'Under MOP'				 then 1.02 
							   when milestone = 'Under Integration'		 then 7 
							   when milestone = 'Under Civil'			 then 4 
							   when milestone = 'As-Built Done'			 then 12 
							   end as Milestoneorder,
							   null as civildep,
							    null as telcomdep,
							    null as M1_In,
							    null as M1_Out,
							    null as M2_In,
							    null as M2_Out,
							    null as M3_In,
							    null as M3_Out,
							    [CivilStartedActual] as M4_In,
							    [PISMAcceptedActual] as M4_Out,
							   null as [M4.5_In],
							   null as [M4.5_Out],
							   null as M5_In,
							   null  as M5_Out,
							    null as M6_In,
							    null as M6_Out,
							    [SiteInstalledActual] as M7_In,
							    [SiteIntegratedActual] as M7_Out,
								[SiteIntegratedActual] as M8_In,
							    [SiteOnAirActual]  as M8_Out,
							    null as PlannedSites, --Same Date for Planned Sites/Cost in WNI
							    null as PlannedCost,           --Same Date for Planned Sites/Cost in WNI
							    null as ForecastSites, --Same Date for Forecast Sites/Cost in WNI
							    null as ForecastCost, --Same Date for Forecast Sites/Cost in WNI
							    null as [DP Date],
							    null as [OSP PD Cost]
								from [Infra_Design_Tracker_NPTS] A
								left join
								(select sitesiteid ,[NFTSTelecomPONumber]
								,max([CivilStartedActual]) [CivilStartedActual]
								,max([PISMAcceptedActual]) [PISMAcceptedActual]
								,max([SiteInstalledActual]) [SiteInstalledActual]
								,max([SiteIntegratedActual]) [SiteIntegratedActual]
								,max([SiteOnAirActual]) [SiteOnAirActual]
								from [Design_Tracker_NPTS] 
									group by [NFTSTelecomPONumber], [SiteSiteID]) B
									on a.PONumber = b.[NFTSTelecomPONumber] collate database_default and A.SiteID = b.sitesiteid collate database_default

                           ) X on X.JobNumber = m.JobNumber 
                                                                                                   
                                                                                                   
                                                                                                    left join
                                                (              Select [Approval Stage],[StageCreateDate],[JobNumber],[To Be Approved BY] from
                                                --select top 10 * from
                                                Infra_AsbuiltApprovalReport) PPCAppRep
                                                on PPCAppRep.JobNumber=isnull(JobNFTS,M.JobNumber)
                                                left join [InfraReport2020OldAch642020] oldach
                                                                on oldach.JOB_NO=isnull(JobNFTS,M.JobNumber)
                                                                                                   
                                                                left join (select   S.JobNumber,M.[As-Built Current Stage],M.[As-Built Current Received Date] 
							--select top 1 * 
							from   Infra_Quick_WIn M -- link from CRDB 
							LEFT JOIN [FNI_TF_OSP].dbo.T_OSPJobWORecWithStatusRep S 
							ON M.JobWorkOrder = S.JobWorkOrder COLLATE DATABASE_DEFAULT )  QWM  on QWM.JobNumber=JobNFTS  
							
					

							
                                                                                                   
) V

						  
		END


		IF EXISTS (SELECT TOP 1 1 FROM [#PCC_Dashboard_Data_BI])
		BEGIN
		
		SELECT * INTO [#PCC_Dashboard_Data_BI_01] FROM 
		(
			SELECT * FROM [#PCC_Dashboard_Data_BI] 
			
			UNION

		
			SELECT 
			 'FNI_Material' AS Department,cast ([PO Number] as nvarchar) PONumber,yEAR ProjectYear,[Project Name] ProjectName,'Material','Material','Material',NULL AS JobNumber ,NUll /*this was inserted by Abbas on 12  Dec 20*/ [NPTWNIActivityId],NULL AS JobNumber,NULL AS StageDate,NULL AS AsBuiltCost_SR,NULL AS ECTC
			,NULL AS [Invoice Approved Net],cast([Allocated Capex] as float),NULL AS VendorName,NULL AS VendorName,NULL AS AsB_Status,null as MoPIssueDate,NULL AS [SOW Completion Date],NULL AS SiteID,NULL AS APPR_ASB,NULL AS PREVIOUS_ASB_UR
			,NULL AS AsB_Year,NULL AS AsB_Month,NULL AS AsB_Week,NULL AS AsB_Order,NULL AS SoW_Month,NULL AS SoW_Order,NULL AS ECTC_F,NULL AS GAP_Status
			,NULL AS GAP2_Age,NULL AS GAP2_AGE_Cat,NULL AS Milestone,NULL AS Milestoneorder,null as CivilDependency,null as CivilDependencyCat,null as TelecomDependency,null as TelecomDependencyCat
			,null as M1_In,null as M1_Out,null as M2_In,null as M2_Out,null as M3_In,null as M3_Out,null as M4_In,null as M4_Out,null as [M4.5_In],null as [M4.5_Out],null as M5_In,null as M5_Out,null as M6_In
			,null as M6_Out,null as M7_In,null as M7_Out,null as M8_In,null as M8_Out,null as PlannedSites,null as PlannedCost,null as ForecastSites,null as ForecastCost,null as DPDate,null as DPCost, null [oldAchFlag]

			FROM 		[FNI_Material EBNET Static_New]
			 

			UNion
			SELECT 
			 'OSP ' + [Region]  AS Department,PONumber,ProjectYear,ProjectName,[FinalClass],[FinalClass],[FinalClass],NULL AS JobNumber,NUll /*this was inserted by Abbas on 12  Dec 20*/ [NPTWNIActivityId],NULL AS JobNumber,NULL AS StageDate,NULL AS AsBuiltCost_SR,NULL AS ECTC
			,NULL AS [Invoice Approved Net],Total,NULL AS VendorName,NULL AS VendorName,NULL AS AsB_Status,null as MoPIssueDate,NULL AS [SOW Completion Date],NULL AS SiteID,NULL AS APPR_ASB,NULL AS PREVIOUS_ASB_UR
			,NULL AS AsB_Year,NULL AS AsB_Month,NULL AS AsB_Week,NULL AS AsB_Order,NULL AS SoW_Month,NULL AS SoW_Order,NULL AS ECTC_F,NULL AS GAP_Status
			,NULL AS GAP2_Age,NULL AS GAP2_AGE_Cat,NULL AS Milestone,NULL AS Milestoneorder,null as CivilDependency,null as CivilDependencyCat,null as TelecomDependency,null as TelecomDependencyCat
			,null as M1_In,null as M1_Out,null as M2_In,null as M2_Out,null as M3_In,null as M3_Out,null as M4_In,null as M4_Out,null as [M4.5_In],null as [M4.5_Out],null as M5_In,null as M5_Out,null as M6_In
			,null as M6_Out,null as M7_In,null as M7_Out,null as M8_In,null as M8_Out,null as PlannedSites,null as PlannedCost,null as ForecastSites,null as ForecastCost,null as DPDate,null as DPCost , null [oldAchFlag]
			FROM [dbo].[OSP EBNET Static_New] 
			UNION
			SELECT 
			 'OSP ' + [Region]  AS Department,NULL AS PONumber,null as projectyear,[Project],[FinalClass],[FinalClass],[FinalClass],NULL AS JobNumber,NUll /*this was inserted by Abbas on 12  Dec 20*/ [NPTWNIActivityId],NULL AS JobNumber,NULL AS StageDate,NULL AS AsBuiltCost_SR,NULL AS ECTC
			,NULL AS [Invoice Approved Net],NULL as [Cost],NULL AS VendorName,NULL AS VendorName,NULL AS AsB_Status,null as MoPIssueDate,NULL AS [SOW Completion Date]
			,[ISOW Number] AS SiteID,NULL AS APPR_ASB,NULL AS PREVIOUS_ASB_UR,NULL AS AsB_Year,NULL AS AsB_Month,NULL AS AsB_Week,NULL AS AsB_Order,NULL AS SoW_Month,NULL AS SoW_Order,NULL AS ECTC_F,NULL AS GAP_Status
			,NULL AS GAP2_Age,NULL AS GAP2_AGE_Cat,NULL AS Milestone,NULL AS MilestoneOrder,null as CivilDependency,null as CivilDependencyCat,null as TelecomDependency,null as TelecomDependencyCat
			,null as M1_In,null as M1_Out,null as M2_In,null as M2_Out,null as M3_In,null as M3_Out,null as M4_In,null as M4_Out,null as [M4.5_In],null as [M4.5_Out],null as M5_In,null as M5_Out,null as M6_In
			,null as M6_Out,null as M7_In,null as M7_Out,null as M8_In,null as M8_Out,null as PlannedSites,null as PlannedCost,null as ForecastSites,null as ForecastCost,[DP Date] as DPDate,[OSP DP Cost] as DPCost , null [oldAchFlag]
			FROM (select
					[ISOW Number] collate database_default as [ISOW Number],
					case 
						when MP.[FNI Class] is not null then MP.[FNI Class]
						else [Project Class]
					end collate database_default as [FinalClass],
					Project collate database_default as Project,
					case
						when Region='Center' then 'Central'
						when Region='Eastern' then 'Eastern'
						when Region='Western' then 'Western'
						when Region='Southern' then 'Southern'
					end collate database_default as Region,
					[DP Date] ,
					[OSP DP Cost]  

					from T_Table_Generate_ISOW_TrackingSheet_dump isw
					left join (select distinct Origin_Number from Infra_Quick_WIn) k on k.Origin_Number=isw.[ISOW Number] collate database_default
					left join  Infra_FNI_Class_Mapping  MP on MP.[Project Code]=isw.[Project]  collate database_Default
					where k.Origin_Number is null and [OSP DP Cost]>0 and [OSP Status] in ('Completed','In-Progress') and [Project Class] not in ('ISP','MAAN','HO') and [Project Class] is not null and Project <>'DUBA FIBER CONNECTIVITY 2019' and [DP Status]='Forwarded to Design'
					and [Project Year]>2018
				) Z
			) X

		DROP TABLE [#PCC_Dashboard_Data_BI]
						  
		END

		IF EXISTS (SELECT TOP 1 1 FROM [#PCC_Dashboard_Data_BI_01])
		BEGIN
		---- Added flag for Exp POs

			Select   [Department]
			,BI.[PONumber]
			,[POYear]
			,[ProjectName]
			,[Element]
			,[Element_Drill]
			,NFTS_Element
			,BI.[JobNumber]
			,[NPTWNIActivityId]
			,JobNFTS
			,[StageDate]
			,[AsBuiltCost_SR]
			,[ECTC]
			,[Invoice Approved Net]
			,[EBNetAmount_SR]
			,[VendorName]
			,[VendorName_Drill]
			,[AsB_Status]
			,[MoPIssueDate]
			,[SOW Completion Date]
			,[SiteID]
			,[APPR_ASB]
			,[PREVIOUS_ASB_UR]
			,[AsB_Year]
			,[AsB_Month]
			,[AsB_Week]
			,[AsB_Order]
			,[SoW_Month]
			,[SoW_Order]
			,[ECTC_F]
			,[GAP_Status]
			,[GAP2_Age]
			,[GAP2_AGE_Cat]
			, [Milestone]
			,[MilestoneOrder]
			,[CivilDependency]
			,[CivilDependencyCat]
			,[TelecomDependency]
			,[TelecomDependencyCat]
			,[M1_In]
			,[M1_Out]
			,[M2_In]
			,[M2_Out]
			,[M3_In]
			,[M3_Out]
			,[M4_In]
			,[M4_Out]
			,[M4.5_In]
			,[M4.5_Out]
			,[M5_In]
			,[M5_Out]
			,[M6_In]
			,[M6_Out]
			,[M7_In]
			,[M7_Out]
			,[M8_In]
			,[M8_Out]
			,[PlannedSites]
			,[PlannedCost]
			,[ForecastSites]
			,[ForecastCost]
			,[DP Date]
			,[OSP PD Cost]
			,oldAchFlag
			,iif(ExpiredPO.PONumber is null, 'Active','Expired') ExpFlag

			----------------------------------------------[Approval Stage],[StageCreateDate] and Bin added on PPC Requirement -------------------------------------------
		,isnull([Approval Stage],QWM.[As-Built Current Stage]) [Approval Stage] , isnull([StageCreateDate],[As-Built Current Received Date]) [StageCreateDate],[to be approved by]
		,case when isnull([Approval Stage],QWM.[As-Built Current Stage]) = 'PM' then 1
		when isnull([Approval Stage],QWM.[As-Built Current Stage]) = 'District Manager' then 2
				when isnull([Approval Stage],QWM.[As-Built Current Stage]) = 'Section Manager' then 3
				when isnull([Approval Stage],QWM.[As-Built Current Stage]) = 'Control Manager' then 4
				when isnull([Approval Stage],QWM.[As-Built Current Stage]) = 'Director' then 5
				when isnull([Approval Stage],QWM.[As-Built Current Stage]) = 'PCC' then 6
			End as [Approval Stage Order]

		 ,case when isnull([StageCreateDate],[As-Built Current Received Date]) is not null  AND Stagedate IS NULL then 
						CASE WHEN   (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 0   and 30  THEN '< 1 Month'
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 30  and 60  THEN '1 - 2 Months' 
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 60  and 90  THEN '2 - 3 Months' 
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 90  and 180 THEN '3 - 6 Months' 
							   WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 180 and 365 THEN '6 - 12 Months' 
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 365 and 730 THEN '1 - 2 Years'  
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) )> 730 THEN '> 2 Years' 
                             End
                       END [StageCreateDateBin]


					    ,case when isnull([StageCreateDate],[As-Built Current Received Date]) is not null  AND Stagedate IS NULL then 
						CASE WHEN   (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 0   and 30  THEN 1
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 30  and 60  THEN 2
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 60  and 90  THEN 3
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 90  and 180 THEN 4
							   WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 180 and 365 THEN 5 
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) ) between 365 and 730 THEN 6
                               WHEN (GETDATE() - isnull([StageCreateDate],[As-Built Current Received Date]) )> 730 THEN 7
                             End
                       END [StageCreateDateBinOrder]
					  
			into #PCC_Dashboard_Data_BI_02
					from [#PCC_Dashboard_Data_BI_01] BI
					LEFT JOIN  
					(
					SELECT pONUMBER FROM
					[FNI_TF_OSP].[dbo].[tblPurchaseOrder] where cast (POEndDate as DATE)<cast (getdate() as DATE)  
				)ExpiredPO
				on BI.PONumber=ExpiredPO.PONumber
				

						    left join
			(	Select [Approval Stage],[StageCreateDate],[JobNumber],[to be approved by] from

			Infra_AsbuiltApprovalReport) PPCAppRep
			on PPCAppRep.JobNumber=JobNFTS
				left join (select   S.JobNumber,M.[As-Built Current Stage],M.[As-Built Current Received Date] 
--select top 1 * 
from   Infra_Quick_WIn M -- link from CRDB 
LEFT JOIN [FNI_TF_OSP].dbo.T_OSPJobWORecWithStatusRep S 
ON M.JobWorkOrder = S.JobWorkOrder COLLATE DATABASE_DEFAULT )  QWM  on QWM.JobNumber=Bi.JobNFTS


		DROP TABLE [#PCC_Dashboard_Data_BI_01]
		
		END
		IF EXISTS (SELECT TOP 1 1 FROM [#PCC_Dashboard_Data_BI_02])
		BEGIN

		select * into [#PCC_Dashboard_Data_BI_03]
		from ( Select z.*,CR.[CR JOB TYPE],CR.[CR TYPE],CR.[CR STATUS] from (
		select Main.*
		,case when Main.JobNumber like '%TK%' then Main.JobNumber else TKWO.TKWONo end as TK_WO
		,case when TKWO.jobworkorder is not null then TKWO.District else OTK.District end as District 
		
		from [#PCC_Dashboard_Data_BI_02] Main
		left join (select distinct jobworkorder,TKWONo, District from Infra_OSPJobWORecWithStatusRep) TKWO on main.JobNumber = TKWO.jobworkorder collate Database_Default 
		left join (select distinct [TK WorkOrder No], District from  [dbo].[T_OSPTKWorkOrder]) OTK on TKWO.TKWONo = OTK.[TK WorkOrder No]
		) Z
		left join (select * from (select *, row_number() over(Partition by [TK WORK ORDER] order by [CR DATE] desc) as RNO
					FROM [dbo].[T_external_vW_iSOWwOCR_fOR_PMCS]
							  where [Project Name]   in (
							  '(0468031) National Broadband (NBB) Phase 1 -2017-FTTH',
							'Mobile Aspiration Project 2019-2020',
							'National Broadband ( NBB - NW )',
							'National Broadband (NBB) NW - NBB OSP Phase 2',
							'OSP FTTx Works & Improvement 2016',
							'OSP FTTx Works & Improvement 2018',
							'OSP FTTx Works and Improvement 2019',
							'OSP FTTx Works and Improvement 2020',
							'Works to Connect FTTH 2015',
							'Works to Connect FTTH 2017',
							N'(0466868)  أعمال الشبكة الخارجية لإيصال شبكة الألياف البصرية2017 م')
							and [CR JOB TYPE] not in ( 'Design', 'Survey', 'Survey & Design')
							and [CR STATUS] not like '%reject%'
							and [CR TYPE] = 'Cancel') A where RNO =1 
						) CR on Z.TK_WO = CR.[TK WORK ORDER] 
						--where JobNumber not in (select distinct JobNumber from Temp_Dummy_SOW_WNI) -- Dummy SOW removed as per Amando's email
			
				) x
		drop table [#PCC_Dashboard_Data_BI_02]
		End
	------------------- code for 2021 Accrual --------------------------	
		
		
	IF EXISTS (SELECT TOP 1 1 FROM [#PCC_Dashboard_Data_BI_03])
		BEGIN	
		Select * into #Temp from (
		Select A.* from [#PCC_Dashboard_Data_BI_03] A
		inner join  (select distinct po_no from [10.21.35.167,1467].[CRDB].[dbo].[PCC_BudgetData_RevisedTarget_new] where year = 2021) B 
		on A.PONumber = b.PO_NO
		where (stagedate is null or year(stagedate) = 2021) and PONumber <> 'OSP 2019-CENTRAL' 
		
		Union 

		Select * from [#PCC_Dashboard_Data_BI_03]
		where year(stagedate) < 2021
		) x

		--select A.*,case when b.JobNumber is not null then 'Accrual' else 'Non Accrual' end as Accrual_Flag from [#PCC_Dashboard_Data_BI_03] A
		--left join #Temp B on a.JobNumber = b.JobNumber
		--where  year(A.stagedate) = 2021
	


	----- Added for Audit trail

	--		insert	into  [PCC_Dashboard_Data_BI_bkup]
	--	Select * ,getdate() DataTime
	--from 
	--	#temp 

	--	Delete from [PCC_Dashboard_Data_BI_bkup]
	--	where [DataTime] < getdate()-2

	--		--- Added for Audit trail






insert into #temp (  [Department],	[PONumber],[POYear],[ExpFlag],oldAchFlag)
			  select 'FNI_Material','2020 Not Awarded', '2020','Active','No'
		union select 'Cloud',		'2020 Not Awarded', '2020','Active','No'
		union select 'Planning',	'2020 Not Awarded', '2020','Active','No'
		union select 'Design',		'2020 Not Awarded', '2020','Active','No'
		union select 'FNI_Telecom',	'2020 Not Awarded', '2020','Active','No'
		union select 'FNI_Telecom',	'2019 Not Awarded', '2020','Active','No'
		union select 'PCC',			'2019 Not Awarded', '2020','Active','No'
		union select 'FNI_Material','2019 Not Awarded', '2020','Active','No'
		union select 'Cloud',		'2019 Not Awarded', '2020','Active','No'
		union select 'Planning',	'2019 Not Awarded', '2020','Active','No'
		union select 'Design',		'2019 Not Awarded', '2020','Active','No'
		Union Select 'OSP Central',	'Not distributed',	'2020','Active','No'
		Union Select 'OSP Eastern',	'Not distributed',	'2020','Active','No'
		Union Select 'OSP Southern','Not distributed',	'2020','Active','No'
		Union Select 'OSP Western',	'Not distributed',	'2020','Active','No'
		Union Select 'OSP Eastern',	'2019 Not Awarded',	'2020','Active','No'
		Union Select 'OSP Western',	'2019 Not Awarded',	'2020','Active','No'
		Union Select 'OSP Southern','2019 Not Awarded',	'2020','Active','No'
		Union Select 'OSP Central',	'2019 Not Awarded',	'2020','Active','No'
		Union Select 'OSP Central' ,'2021 Not Awarded',	'2021','Active','No'
		Union Select 'OSP Eastern' ,'2021 Not Awarded',	'2021','Active','No'
		Union Select 'OSP Southern' ,'2021 Not Awarded','2021','Active','No'
		Union Select 'OSP Western' ,'2021 Not Awarded',	'2021','Active','No'




		insert into #temp (  [Department],	[PONumber],[POYear],[ExpFlag],oldAchFlag)
		Select distinct   DEP ,PO_NO,year,'Active','No' from [10.21.35.167,1467].CRDB.[dbo].[PCC_BudgetData_RevisedTarget_new] t
left join 
#temp bi on   bi.Department= t.DEP and t.po_no=bi.PONumber
where  bi.PONumber is  null or bi.oldAchFlag = 'Yes' -- added Oldachflag condition to reflect PO Target where whole PO = 'Yes'


		insert into #temp (  [Department],	[PONumber],[POYear],[ExpFlag],oldAchFlag)
Select distinct   DEP ,PO_NO,t.year,'Active','No' from Infra_PCC_Budget_Data t
left join 
#temp bi on   bi.Department= t.DEP and t.po_no=bi.PONumber and (year( StageDate)=year or StageDate is null)
where bi.PONumber is  null or bi.oldAchFlag = 'Yes'  -- added Oldachflag condition to reflect PO Target where whole PO = 'Yes'



Delete from #temp where (PONumber='93462' and Department = 'DC' and VendorName='AWAL IT Services') OR (PONumber in ('93799','93798','93854','94277','93797','94278') and Department = 'Cloud') --- 93451 REMOVED FROM EXCLUTION TO MAT MATCH PCC TARGET FOR 2021





	drop table [PCC_Dashboard_Data_BI]

	Select * into  [PCC_Dashboard_Data_BI]
	from(
	Select A.* ,b.[project group]
	,iif(ExpiredPO.PONumber is null, 'Active','Expired')  ExpFlag_F
	,getdate() DataTime
	from 
		#temp A
		left join (select [project group],ProjectName as PN,department as Dep from [dbo].[Infra_Project_Mapping]) B on a.ProjectName = b.PN and A.Department = b.Dep
		LEFT JOIN  
					(
					SELECT pONUMBER FROM
					[FNI_TF_OSP].[dbo].[tblPurchaseOrder] where cast (POEndDate as DATE)<cast (getdate() as DATE)  
				)ExpiredPO
				on A.PONumber=ExpiredPO.PONumber
	) x
		
		drop table [#temp]
	------------------------ Code for 2021 Accrual ------------------------	
		
		End 
		
		IF EXISTS (SELECT TOP 1 1 FROM [PCC_Dashboard_Data_BI])
		BEGIN

		drop table PCC_Dashboard_Milestones

		select * into PCC_Dashboard_Milestones from (select distinct Milestone from PCC_Dashboard_Data_BI  where Milestone is not null
		union Select 'GAP 1' ----Requirement to add GAP1 to Balance Card
		union Select 'GAP 2' ----Requirement to add GAP1 to Balance Card
		)
		 t

		END

		BEGIN
		select * into [#PCC_Dashboard_Data_BI_Dependency] from
				(
				SELECT 
				Department,
				ProjectName,
				Element,
				VendorName,
				Milestone,
				case
					when DependencyFlag='CivilDependencyCat' then 'Civil'
					when DependencyFlag='TelecomDependencyCat' then 'Telecom'
				end as DependencyFlag,
				DependencyCategory,
				count(JobNumber) as CountofJobs,
				sum(ECTC) as Cost

				FROM [FNI_TF_OSP].[dbo].[PCC_Dashboard_Data_BI]
				unpivot (
					DependencyCategory 
					for DependencyFlag in (CivilDependencyCat,TelecomDependencyCat)
				) unpvt
				group by Department,ProjectName,Element,VendorName,Milestone,DependencyFlag,DependencyCategory
				) C
		END	

		IF EXISTS (SELECT TOP 1 1 FROM [#PCC_Dashboard_Data_BI_Dependency])
		BEGIN

		DROP TABLE [PCC_Dashboard_Data_BI_Dependency]

		select * into [PCC_Dashboard_Data_BI_Dependency] from [#PCC_Dashboard_Data_BI_Dependency]

		DROP TABLE [#PCC_Dashboard_Data_BI_Dependency]
		END
		
		
END

