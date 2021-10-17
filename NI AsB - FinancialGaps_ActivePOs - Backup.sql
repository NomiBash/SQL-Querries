USE [NI_AsBuilt]
GO

/****** Object:  View [dbo].[V.NI_FinaicalGAPs_ActivePOs]    Script Date: 10/5/2021 9:24:30 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





ALTER  view  [dbo].[V.NI_FinaicalGAPs_ActivePOs] as 
Select 


		[UpdatedDep]
      ,[ElementGroupDepartment]
      ,[PONumber]
      ,[ElementGroupCode]
      ,[JobNumber]
      ,[StageDate]
      ,[AsBuiltCost_SR]
      ,[ECTC]
      ,[Invoice Approved Net]
      ,[EBNetAmount]
      ,[EBNetAmount_SR]
      ,[ContractorName]
      ,[ProjectName]
      ,[As-Built Approval]
      ,[MoPIssueDate]
      ,[NPTWNIActivityId]
      ,[MoPNumber]
      ,[PAC Date]
      ,[PAT End]
	  ,PM
	  ,SiteNumber
	  from (
SELECT        
f2.UpdatedDep, 
f2.ElementGroupDepartment, 
f2.PONumber, 
f2.ElementGroupCode, 
f2.JobNumber, 
f2.StageDate, 
f2.AsBuiltCost_SR, 
f2.ECTC, 
f2.[Invoice Approved Net], 
f2.EBNetAmount, 
f2.EBNetAmount_SR, 
f2.ContractorName,
f2.ProjectName,  
t2.[As-Built Approval],
f2.MoPIssueDate, -- added MOPIssueDate by Said on 2020-01-19
f2.NPTWNIActivityId, -- added NPTWNIActivityId by Said on 2020-02-16
f2.MoPNumber, -- added MoPNumber by Said on 2020-02-16
f2.[PAC Date], -- added [PAC Date] by Said on 2020-02-16
f2.[PAT End], -- added [PAT End] by Said on 2020-02-16
f2.PM, -- added for FNI Telecon elemen split
f2.SiteNumber -- for site ID
FROM  (
	SELECT        
	f.UpdatedDep, 
	f.ElementGroupDepartment, 
	f.PONumber, 
	f.ElementGroupCode, 
	f.JobNumber, 
	k.StageDate, 
	f.AsBuiltCost_SR, 
	f.ECTC_SR AS ECTC, 
	f.[Invoice Approved Net_SR] AS [Invoice Approved Net],
	NULL AS EBNetAmount, 
	NULL AS EBNetAmount_SR, 
	f.ContractorName,
	f.ProjectName,
	f.MoPIssueDate, -- added MOPIssueDate by Said on 2020-01-19
	f.NPTWNIActivityId, -- added NPTWNIActivityId by Said on 2020-02-16
	f.MoPNumber, -- added MoPNumber by Said on 2020-02-16
	f.[PAC Date], -- added [PAC Date] by Said on 2020-02-16
	f.[PAT End], -- added [PAT End] by Said on 2020-02-16
	f.PM, -- added for FNI Telecon elemen split
	f.SiteNumber -- for site ID
	FROM (
	SELECT        
	x.ElementGroupDepartment
	,CASE 
	when x.PONumber in ('96591','96590')  and x.ElementGroupCode in ('HLR','SBS-Core-SW','SW - CNI') then 'CNI' --as per PCC maping file 26-Aug-2021
	    	when x.PONumber = '96338'  then 'PCC' --By default CNI change to PCC as per target 7/26/2021 
		when x.PONumber = '95812'  then 'Cloud' --email from abu Aysha 5/27/2021 
		when  x.JobNumber in ('J-DRACOW003-0000002','J-DRAEOW001-0000006','J-DRAWOW001-0000015','J-DRCCOW001-0000002')then 'CNI' 
		When  x.PONumber  in  ('91860') then 'DC' -- Reuested by PCC add to DC
		when x.PONumber = '91699' and ElementGroupCode = 'OSS' then 'CNI' --As per PCC email to shift PO from CI to CNI (Noruddin)
	------------------------------------Block added to add Cloud planning and Design by Arsalan on 3/22/2020
		WHEN x.PONumber in (
								'96305','96336','93881','93875','94094','94089','91459','91951','96548','95407','95800') then 'Planning'
		When   UPDatedDep  is not null 
			then UPDatedDep 
		
	------------------------------------- Block added to add Cloud planning and Design by Arsalan on 3/22/2020
		WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share') THEN 'FNI_Material' 
		When  x.PONumber  in  ('93412','93416','93417','93419','94004') and x.ElementGroupCode in ('TX&DWDM' ,'Data Transport','SVCS - CNI','SAV-CNI', 'IP-CNI') then 'CNI' -- Reuested by PCC to Shift PO from UNG to CNI
		When  x.PONumber  in  ('89823'	,'94178'	) and x.ElementGroupCode in ('Consultancy','Consultancy - DC') then 'DC' -- Reuested by PCC add to DC
		when x.PONumber in ('93462' )AND x.ElementGroupCode IN ( 'DC - DC') THEN 'Cloud' -- Reuested by PCC TO be added for Cloud
		when x.PONumber in ('93309','93451','93462','93878','94092','94096','94330'  ,'93069','93073','93080','93202','93204','93301','93302','93798','93799','94230','94879','95202','95703' ) 
		AND x.ElementGroupCode IN ( 'CPC','OSS','VAS','NMS','TCLD-NFVI','TCLD-SDN','TCLD-SI','ENH-SVC','SVC - NETCOOL','SVC - NSS','OSS-Exp') THEN 'Cloud' -- Reuested by PCC TO be added for Cloud
		when x.PONumber in ('94879','95202' ) AND x.ElementGroupCode IN ('CPE','SD-WAN','SVCS' ) THEN 'Cloud' -- Confirmation sent to Abu el Magd (26Nov2020)
		when x.ProjectName in ('Disaster Recovery 2015 - Container','(70666) Broadband ISP network improvement and Expansion 2019','(70481) UNG Migration Modernization (LMM) 2019') then 'UNG'
		when x.PONumber in ('95931','95932','95933') then 'UNG' --updated as per Israr's email confirmation
		WHEN x.[POType] = 'Telecom' AND x.ElementGroupDepartment = 'FNI' THEN 'FNI_Telecom' 
		WHEN x.ElementGroupDepartment = 'CNI' AND x.ElementGroupCode = 'TRX' AND x.POType = 'Civil' THEN 'FNI_Telecom' 
		WHEN x.[POType] NOT IN ('Material', 'Telecom') AND x.ElementGroupDepartment = 'FNI' THEN 'FNI_OSP' 
		WHEN x.[POType] = 'Consultancy' THEN 'PCC' 
		WHEN x.ElementGroupDepartment = 'CNI' AND x.ElementGroupCode in ('SW - CNI','SBS-Core-SW') AND x.ContractorName in ('Ericsson','Huawei','Nokia Solution and Network Branch Operation OY','Nokia Solutions and Networks Al Saudia Company Limited','Nokia Arabia Limited') AND x.PONumber NOT IN ('93131') THEN 'WNI' 
		WHEN x.ElementGroupDepartment = 'CI' AND x.ElementGroupCode IN ('OSS','OSS-CI','VAS','NMS','NMS-CI','TCLD-NFVI','TCLD-NFVO','TCLD-VIM','TCLD-SDN','TCLD-SI','SBS-OSS-SW')  THEN 'Cloud' --Check with Cloud team for SBS
		WHEN x.PONumber in ('94411','94408','95207','95389','95294','95312','96363')  then 'Cloud' --Email confirmation by Abu Ayesha on 10Aug2021
		
		ELSE x.ElementGroupDepartment 
		END AS UpdatedDep,
		x.ElementGroupCode, 
		x.[PO Value], 
		x.JobNumber, 
		x.PONumber, 
		x.[AsBuilt Cost], 
        CASE WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share')  AND z.Currency = 'USD' THEN isnull(x.[AsBuilt Cost], 0)  * 3.756  -- SHARE added to reflect Material 75%
			 WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share') AND z.Currency <> 'USD' THEN isnull(x.[AsBuilt Cost], 0) 
			 WHEN x.[POType] <> 'Material' AND x.ElementGroupDepartment not in ('FNI','Share') AND z.Currency = 'USD' THEN isnull(x.[AsBuilt Cost], 0) * 3.756 
			 ELSE isnull(x.[AsBuilt Cost], 0) 
		END AS AsBuiltCost_SR, 
		CASE 
			WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share') AND z.Currency = 'USD' THEN isnull(x.[ECTC], 0)  * 3.756 
			WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share') AND z.Currency <> 'USD' THEN isnull(x.[ECTC], 0)  
			WHEN x.[POType] <> 'Material' AND x.ElementGroupDepartment not in ('FNI','Share') AND z.Currency = 'USD' THEN isnull(x.[ECTC], 0) * 3.756 
			ELSE isnull(x.[ECTC], 0) END AS ECTC_SR, 
			x.ECTC,
		CASE WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share') AND z.Currency = 'USD' THEN isnull(x.[Invoice Approved Net], 0)  * 3.756
			WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share') AND z.Currency <> 'USD' THEN isnull(x.[Invoice Approved Net], 0) 
			WHEN x.[POType] <> 'Material' AND x.ElementGroupDepartment not in ('FNI','Share') AND z.Currency = 'USD' THEN isnull(x.[Invoice Approved Net], 0) * 3.756 
			ELSE isnull(x.[Invoice Approved Net], 0) 
		END AS 'Invoice Approved Net_SR', 
			x.[Invoice Approved Net], 
			x.ContractorName,
			x.ProjectName,
			x.MoPIssueDate, -- added MOPIssueDate by Said on 2020-01-19
			x.NPTWNIActivityId, -- added NPTWNIActivityId by Said on 2020-02-16
			x.MoPNumber, -- added MoPNumber by Said on 2020-02-16
			x.[PAC Date], -- added [PAC Date] by Said on 2020-02-16
			x.[PAT End], -- added [PAT End] by Said on 2020-02-16
			x.PM, -- added for FNI Telecon elemen split
			x.SiteNumber -- for site ID
            FROM FNI_TF_OSP.dbo.T_vECTCJobLevel_Active_POs AS x 
			INNER JOIN T_ISP_POs AS z ON x.PONumber = z.PO_no
			left join FNI_TF_OSP.dbo.Planning_Cloud_Design_PCC  pcc on x.ElementGroupCode=Element and X.PONumber=pcc.PO_NO
            WHERE (x.ElementGroupDepartment NOT IN ('FA', 'CID', 'NO', 'Cyber Security Risks & Compliance', 'HRD') and x.PONumber+x.ElementGroupCode <> '93417ELE' )) AS f --CI, ND, NSS  removed from exclusion to include cloud,planning and Design POs // NI removed from exclusion to add DC PO 89823 // SHARE added to reflect Material 75% // '93417ELE' removed based on Email Confirmation by Imaad 28Sep2021
			LEFT OUTER JOIN FNI_TF_OSP.dbo.[T.vImplementJobAsBuiltApprStage1] AS k ON f.JobNumber = k.jobNumber) AS f2 
			LEFT OUTER JOIN [FNI_TF_OSP].[dbo].[T.AsBuiltApprovalReport] t2 ON f2.JobNumber = t2.JobNumber


Union -- to adde the Element budget of all POs with element

SELECT
CASE
when x.PONumber  in ('96591','96590') and x.ElementGroupCode in ('HLR','SBS-Core-SW','SW - CNI') then 'CNI' --as per PCC maping file 26-Aug-2021
	    	when x.PONumber = '96338'  then 'PCC' --By default CNI change to PCC as per target 7/26/2021 
	when x.PONumber = '95812'  then 'Cloud' --email from abu Aysha 5/27/2021 
When  x.PONumber  in  ('91860'		) then 'DC' -- Reuested by PCC add to DC
when x.PONumber = '91699' and ElementGroupCode = 'OSS' then 'CNI' --As per PCC email to shift PO from CI to CNI (Noruddin)

------------------------------------Block added to add Cloud planning and Design by Arsalan on 3/22/2020
		WHEN x.PONumber in (
								'96305','96336','93881','93875','94094','94089','91459','91951','96548','95407','95800') then 'Planning'
		When  max(UPDatedDep) is not null
			then max(UPDatedDep )
		
			-------------------------------- Block added to add Cloud planning and Design
	WHEN x.[POType]= 'Material' and x.ElementGroupDepartment in ('FNI','Share') THEN 'FNI_Material' 
			When  x.PONumber  in  ('93412','93416','93417','93419','94004','95051') and x.ElementGroupCode in ('TX&DWDM' ,'Data Transport','SVCS - CNI','SAV-CNI', 'IP-CNI') then 'CNI' -- Reuested by PCC to Shift PO from UNG to CNI
		When  x.PONumber  in  ('89823'	,'94178'	) and x.ElementGroupCode in ('Consultancy','Consultancy - DC') then 'DC' -- Reuested by PCC add to DC
		
				
		 when x.PONumber in ('93462' )AND x.ElementGroupCode IN ( 'DC - DC') THEN 'Cloud' -- Reuested by PCC TO be added for Cloud

		 when x.PONumber in ('93309','93451','93462','93878','94092','94096','94330'  ,'93069','93073','93080','93202','93204','93301','93302','93798','93799','94230','95703' ) 
		 AND x.ElementGroupCode IN ( 'CPC','OSS','VAS','NMS','TCLD-NFVI','TCLD-SDN','TCLD-SI','ENH-SVC','SVC - NETCOOL','SVC - NSS','OSS-Exp') THEN 'Cloud' -- Reuested by PCC TO be added for Cloud
		when x.PONumber in ('94879','95202' ) AND x.ElementGroupCode IN ('CPE','SD-WAN','SVCS' ) THEN 'Cloud' -- Confirmation sent to Abu el Magd (26Nov2020)
		when max(x.ProjectName) in ('Disaster Recovery 2015 - Container','(70666) Broadband ISP network improvement and Expansion 2019','(70481) UNG Migration Modernization (LMM) 2019') then 'UNG'
		when x.PONumber in ('95931','95932','95933') then 'UNG' --updated as per Israr's email confirmation
	WHEN x.[POType]= 'Telecom' and x.ElementGroupDepartment='FNI' THEN 'FNI_Telecom'
	WHEN x.ElementGroupDepartment='CNI' and 	x.ElementGroupCode='TRX' and	x.POType='Civil'  THEN 'FNI_Telecom'
	WHEN x.[POType] not in ('Material','Telecom') and x.ElementGroupDepartment='FNI' THEN 'FNI_OSP'
	WHEN x.[POType] = 'Consultancy' THEN 'PCC' 
	WHEN x.ElementGroupDepartment = 'CNI' AND x.ElementGroupCode in ('SW - CNI','SBS-Core-SW') AND x.ContractorName in ('Ericsson','Huawei','Nokia Solution and Network Branch Operation OY','Nokia Solutions and Networks Al Saudia Company Limited','Nokia Arabia Limited') AND x.PONumber NOT IN ('93131') THEN 'WNI' 
	WHEN x.ElementGroupDepartment = 'CI' AND x.ElementGroupCode IN ('OSS','OSS-CI','VAS','NMS','NMS-CI','TCLD-NFVI','TCLD-NFVO','TCLD-VIM','TCLD-SDN','TCLD-SI','SBS-OSS-SW')  THEN 'Cloud' --Check with Cloud team for SBS
	WHEN x.PONumber in ('94411','94408','95207','95389','95294','95312','96363')  then 'Cloud' --Email confirmation by Abu Ayesha on 10Aug2021
	
	
	ELSE x.ElementGroupDepartment 
END AS UpdatedDep
,x.[ElementGroupDepartment]
,x.[PONumber]
,x.[ElementGroupCode]
, null as JobNumber
, null as StageDate
, null as Asbuilt
, null as ECTC
, null as Invoice 
,sum([EBNetAmount]) as [EBNetAmount]
 ,case when max(y.Currency)='USD' then sum(isnull([EBNetAmount],0)) * 3.756 else sum(isnull([EBNetAmount],0)) end  as [EBNetAmount_SR]
  ,x.ContractorName
  ,max(x.ProjectName) ProjectName
  , null as [As-Built Approval]
  , null as MoPIssueDate -- added MOPIssueDate by Said on 2020-01-19
,null as NPTWNIActivityId -- added NPTWNIActivityId by Said on 2020-02-16
,null as MoPNumber -- added MoPNumber by Said on 2020-02-16
,null as [PAC Date] -- added [PAC Date] by Said on 2020-02-16
,null as [PAT End] -- added [PAT End] by Said on 2020-02-16
,null as PM -- added for FNI Telecon elemen split
,null as site_number -- for site ID
  FROM [NI_AsBuilt].[dbo].[T.vElementBudgetReportNew] x inner join [dbo].[T_ISP_POs] y on x.PONumber=y.PO_no
  left join FNI_TF_OSP.dbo.Planning_Cloud_Design_PCC  pcc on x.ElementGroupCode=Element and X.PONumber=pcc.PO_NO
  where [ElementGroupDepartment] not in ('FA','CID','NO','Cyber Security Risks & Compliance','HRD')  and x.PONumber+x.ElementGroupCode <> '93417ELE' --- ND , NSS removed for CLoud Desing and planning Pos // NI removed from exclusion to add DC PO 89823
group by [PONumber],[ElementGroupDepartment],[ElementGroupCode],ContractorName,[POType]


Union -- To add the element budget for all POs without element and not in element budget report



SELECT        
f.UpdatedDep,
f.ElementGroupDepartment, 
f.PONumber, 
f.ElementGroupCode,
null as JobNumber,
null as StageDate, 
null AsBuiltCost_SR,
null as ECTC, 
null [Invoice Approved Net], 
max(f.EBNetAmount) as EBNetAmount ,
max(f.EBNetAmount_SR) as EBNetAmount_SR,
f.ContractorName,
max(f.ProjectName) ProjectName, 
null [As-Built Approval],
null as MoPIssueDate -- added MOPIssueDate by Said on 2020-01-19
,null as NPTWNIActivityId -- added NPTWNIActivityId by Said on 2020-02-16
,null as MoPNumber -- added MoPNumber by Said on 2020-02-16
,null as [PAC Date] -- added [PAC Date] by Said on 2020-02-16
,null as [PAT End] -- added [PAT End] by Said on 2020-02-16
,null as PM -- added for FNI Telecon elemen split	
,null as site_number -- for site ID
FROM (
SELECT        
x.ElementGroupDepartment
, CASE  
when x.PONumber  in ('96591','96590') and x.ElementGroupCode in ('HLR','SBS-Core-SW','SW - CNI') then 'CNI' --as per PCC maping file 26-Aug-2021
	    	when x.PONumber = '96338'  then 'PCC' --By default CNI change to PCC as per target 7/26/2021 
	when x.PONumber = '95812'  then 'Cloud' --email from abu Aysha 5/27/2021 

When  x.PONumber  in  ('91860'		) then 'DC' -- Reuested by PCC add to DC
when x.PONumber = '91699' and ElementGroupCode = 'OSS' then 'CNI' --As per PCC email to shift PO from CI to CNI (Noruddin)

------------------------------------Block added to add Cloud planning and Design by Arsalan on 3/22/2020
		WHEN x.PONumber in (
								'96305','96336','93881','93875','94094','94089','91459','91951','96548','95407','95800') then 'Planning'
		When   UPDatedDep is not null
			then   UPDatedDep 
		
			-------------------------------- Block added to add Cloud planning and Design
	WHEN x.[POType] = 'Material' AND x.ElementGroupDepartment in ('FNI','Share') THEN 'FNI_Material' 
				When  x.PONumber  in  ('93412','93416','93417','93419','94004','95051') and x.ElementGroupCode in ('TX&DWDM' ,'Data Transport','SVCS - CNI','SAV-CNI', 'IP-CNI') then 'CNI' -- Reuested by PCC to Shift PO from UNG to CNI
		When  x.PONumber  in  ('89823'	,'94178'	) and x.ElementGroupCode in ('Consultancy','Consultancy - DC') then 'DC' -- Reuested by PCC add to DC
		
			
		 when x.PONumber in ('93462' )AND x.ElementGroupCode IN ( 'DC - DC') THEN 'Cloud' -- Reuested by PCC TO be added for Cloud
	
		 when x.PONumber in ('93309','93451','93462','93878','94092','94096','94330'  ,'93069','93073','93080','93202','93204','93301','93302','93798','93799','94230','95703' ) 
		 AND x.ElementGroupCode IN ( 'CPC','OSS','VAS','NMS','TCLD-NFVI','TCLD-SDN','TCLD-SI','ENH-SVC','SVC - NETCOOL','SVC - NSS','OSS-Exp') THEN 'Cloud' -- Reuested by PCC TO be added for Cloud 
		when x.PONumber in ('94879','95202' ) AND x.ElementGroupCode IN ('CPE','SD-WAN','SVCS' ) THEN 'Cloud' -- Confirmation sent to Abu el Magd (26Nov2020)
		when x.ProjectName in ('Disaster Recovery 2015 - Container','(70666) Broadband ISP network improvement and Expansion 2019','(70481) UNG Migration Modernization (LMM) 2019') then 'UNG'
		when x.PONumber in ('95931','95932','95933') then 'UNG' --updated as per Israr's email confirmation
	WHEN x.[POType] = 'Telecom' AND x.ElementGroupDepartment = 'FNI' THEN 'FNI_Telecom' 
	WHEN x.ElementGroupDepartment = 'CNI' AND x.ElementGroupCode = 'TRX' AND x.POType = 'Civil' THEN 'FNI_Telecom' 
	WHEN x.[POType] NOT IN ('Material', 'Telecom') AND x.ElementGroupDepartment = 'FNI' THEN 'FNI_OSP'
	WHEN x.[POType] = 'Consultancy' THEN 'PCC' 
	WHEN x.ElementGroupDepartment = 'CNI' AND x.ElementGroupCode in ('SW - CNI','SBS-Core-SW') AND x.ContractorName in ('Ericsson','Huawei','Nokia Solution and Network Branch Operation OY','Nokia Solutions and Networks Al Saudia Company Limited','Nokia Arabia Limited') AND x.PONumber NOT IN ('93131') THEN 'WNI' 
	WHEN x.ElementGroupDepartment = 'CI' AND x.ElementGroupCode IN ('OSS','OSS-CI','VAS','NMS','NMS-CI','TCLD-NFVI','TCLD-NFVO','TCLD-VIM','TCLD-SDN','TCLD-SI','SBS-OSS-SW')  THEN 'Cloud' --Check with Cloud team for SBS
	WHEN x.PONumber in ('94411','94408','95207','95389','95294','95312','96363')  then 'Cloud' --Email confirmation by Abu Ayesha on 10Aug2021
	

	ELSE x.ElementGroupDepartment 
END AS UpdatedDep
, x.ElementGroupCode, 
x.[PO Value], 
x.JobNumber, 
x.PONumber, 
x.[AsBuilt Cost], 
CASE WHEN z.Currency = 'USD' THEN isnull(x.[AsBuilt Cost], 0) * 3.756 ELSE x.[AsBuilt Cost] END AS AsBuiltCost_SR,
CASE WHEN z.Currency = 'USD' THEN isnull(x.[ECTC], 0) * 3.756 ELSE x.[ECTC] END AS ECTC_SR, x.ECTC, 
CASE WHEN z.Currency = 'USD' THEN isnull(x.[Invoice Approved Net], 0) * 3.756 ELSE x.[Invoice Approved Net] END AS 'Invoice Approved Net_SR', 
x.[Invoice Approved Net], 
NULLIF(z.PO_Value ,'NULL') AS EBNetAmount, 
CASE WHEN z.Currency = 'USD' THEN isnull(x.[PO Value], 0) * 3.756 ELSE isnull(x.[PO Value], 0) END AS 'EBNetAmount_SR'
, x.ContractorName
,x.ProjectName					 
FROM            FNI_TF_OSP.dbo.T_vECTCJobLevel_Active_POs AS x 
INNER JOIN T_ISP_POs AS z ON x.PONumber = z.PO_no
left join FNI_TF_OSP.dbo.Planning_Cloud_Design_PCC  pcc on x.ElementGroupCode=Element and X.PONumber=pcc.PO_NO
where (x.[ElementGroupDepartment] not in ('FA','CID','NO','Cyber Security Risks & Compliance','HRD')  and x.PONumber+x.ElementGroupCode <> '93417ELE' and (z.BudgetControlLevel='1' or x.POOwner='FNI' and x.ElementGroupCode='OSP' and x.[Element Code]='OSPW'))) f 
--ND and NSS removed for  cloud desing and planning POs // NI removed from exclusion to add DC PO 89823
group by f.ContractorName,f.UpdatedDep,f.ElementGroupDepartment, f.PONumber, f.ElementGroupCode
			)asd										
			where UpdatedDep not in 
('E2E Orchestration and Assurance Management'
,'IBBS'
,'ND'
,'NSS'
,'NSS-Core'
,'NSS-Naps'
)

GO


