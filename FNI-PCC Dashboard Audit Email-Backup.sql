USE [FNI_TF_OSP]
GO
/****** Object:  StoredProcedure [dbo].[PCC Dasboard Audit Email]    Script Date: 10/7/2021 3:41:42 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[PCC Dasboard Audit Email]
as BEGIN

---------- All Variables ------------

DECLARE 


 @PO_NO				VARCHAR(Max)
,@I_Dep				VARCHAR(Max)
,@I_Elem			VARCHAR(Max)
,@T_Dep				VARCHAR(Max)
,@ECTC				VARCHAR(Max)
,@Complete			VARCHAR(max) 
,@Header			VARCHAR(max) 
,@mesG				VARCHAR(max) 
,@subject			VARCHAR(max) 
,@date 	  			varchar(50)
,@day				varchar(50)
,@Table_Name		VARCHAR(Max)
,@Refresh_Date		VARCHAR(Max)
,@JobNumber			VARCHAR(50) 
,@YesterdayECTC_F	VARCHAR(50) 
,@Department 	  	varchar(50)
,@Element			varchar(50) 
,@todayECTC_F		varchar(50)
,@Difference		VARCHAR(max) 
,@PONum				VARCHAR(Max)
,@FIN_NO			VARCHAR(Max)
,@Dep				VARCHAR(Max)
,@Elem				VARCHAR(Max)
,@#Jobs				VARCHAR(Max)
,@Cost				VARCHAR(Max)
,@PO1				VARCHAR(Max) 
,@Dep1				VARCHAR(Max)
,@Elem1				VARCHAR(Max)
,@Job1				VARCHAR(Max)
,@Count				VARCHAR(Max)
,@ECTC1				VARCHAR(Max)
,@Dep2				varchar(max) 
,@OldACH			varchar(max)	
,@NewACH			varchar(max)	
,@Diff				varchar(max) 
,@minDate			varchar(max)
,@maxDate			varchar(max)

set @mindate = (select Min(DataTime) from PCC_Dashboard_Data_BI_bkup)
set @maxDate = (select Max(DataTime) from PCC_Dashboard_Data_BI_bkup)
set @date = (convert (date,Getdate()))
set @day = DATENAME(WEEKDAY, GETDATE())
set @HEader= 
	'<p style=''color: Black;font-family: Calibri''> Dear Gents,</p>' +
	 '<p style=''color: Black;font-family: Calibri''> Find below audit for "Infra Global Report".
 </p>'+
	'<h3 style=''color: Brown;font-family: Calibri''> PO with Mismatch Dep </h3>'+
	'<table style=''width:800; font-size: 15; border:1px solid black; font-family: Calibri; text-align:center''><tr style="border: 1px solid black;background: #C0C0C0">' +
	'<td> PO Number </td>' +
	'<td> Infra Dep </td>' +
	'<td> Infra Element </td>' +
	'<td> Target Dep </td>' +
	'<td> ECTC </td>' +
	
	'</tr>'
Set @Complete = @Header

DECLARE db_cursor CURSOR FOR 
---------- Table Query ----------
select 
A.PONumber,A.Department Infra_Dep,Element Infra_Element,b.dep Target_Dep,format(A.ECTC,'#,#') cost 
from (
select  PONumber+Department [key],PONumber,department,Element,sum(ectc_f) ECTC 
from PCC_Dashboard_Data_BI
left join [10.21.35.167,1467].[CRDB].[dbo].[PCC_BudgetData_RevisedTarget_new] n
on PONumber+Department =PO_no+dep
where PONumber not like '%not%' and (StageDate is null or year(StageDate) = 2021
) and oldAchFlag = 'No' and JobNumber is not null and ECTC_F > 0
and PO_no is null 
group by PONumber+Department,PONumber,department,Element 
) A
left join [10.21.35.167,1467].[CRDB].[dbo].[PCC_BudgetData_RevisedTarget_new] b on a.PONumber = b.po_no
where  PO_no+dep<>PONumber+Department and b.year=2021

---------- Filling Table ---------
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @PO_NO, @I_Dep,@I_Elem,@T_Dep,@ECTC
WHILE @@FETCH_STATUS = 0  
BEGIN  
	SET @mesG =
	'<tr>'+
	'<td>' +isnull(cast(@PO_NO as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@I_Dep as varchar),'')+'</td>' +
	'<td>' +isnull(cast(@I_Elem as varchar),'')+'</td>' +
	'<td>' +isnull(cast(@T_Dep as varchar),'')+'</td>' +
	'<td>' +isnull(cast(@ECTC as varchar),'')+'</td>' +
	'</tr>'
	set @Complete =@Complete+isnull(@mesG,'')
    FETCH NEXT FROM db_cursor INTO @PO_NO, @I_Dep,@I_Elem,@T_Dep,@ECTC
END 
CLOSE db_cursor 
DEALLOCATE db_cursor

Set @Complete=@Complete+'</table>'

---------------------------------------------------------------------------------------------------------------------------------------------------
set @HEader= 
'<style> table.mytable tr:first-child, table.mytable tr:last-child { background-color: #C0C0C0; color: black }</style>'+
	'<h3 style=''color: Brown;font-family: Calibri''> Data Refresh Time </h3>'+
	'<table class="mytable"><tr>'+
	'<table style=''width:800; font-size: 15; border:1px solid black; font-family: Calibri; text-align:center''><tr style="border: 1px solid black;background: #C0C0C0">' +
	'<td> Table Name </td>' +
	'<td> Refresh Date </td>' +
	'</tr>'
Set @Complete = concat(@Complete, @Header)

DECLARE db_cursor2 CURSOR FOR 
---------- Table Query ----------
	  Select top 1 Refresh_Date,'T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp' as Table_Name from T_NI_FinaicalGAPs_ActivePOs_WithOSP_Temp
Union Select  top 1 Refresh_Date,'tblPurchaseOrder'as Table_Namefrom from tblPurchaseOrder
Union Select  top 1 Refresh_Date,'Infra_Quick_WIn'as Table_Namefrom from Infra_Quick_WIn
Union Select  top 1 Refresh_Date,'Infra_FirstExpiredMilestoneflag'as Table_Namefrom from Infra_FirstExpiredMilestoneflag
Union Select  top 1 Refresh_Date,'Infra_TransmissionJobViewAll'as Table_Namefrom from Infra_TransmissionJobViewAll
Union Select  top 1 Refresh_Date,'Infra_All_FNI_View'as Table_Namefrom from Infra_All_FNI_View
Union Select  top 1 Refresh_Date,'Infra_AsbuiltApprovalReport'as Table_Namefrom from Infra_AsbuiltApprovalReport
Union Select  top 1 Refresh_Date,'Infra_FNI_Class_Mapping'as Table_Namefrom from Infra_FNI_Class_Mapping
Union Select  top 1 Refresh_Date,'Infra_PCC_Revised_Target_Updated'as Table_Namefrom from Infra_PCC_Revised_Target_Updated
Union Select  top 1 Refresh_Date,'Infra_OSPJobWORecWithStatusRep'as Table_Namefrom from Infra_OSPJobWORecWithStatusRep

---------- Filling Table ---------
OPEN db_cursor2  
FETCH NEXT FROM db_cursor2 INTO @Table_Name, @Refresh_Date
WHILE @@FETCH_STATUS = 0  
BEGIN  
	SET @mesG =
	'<tr>'+
	'<td>' +isnull(cast(@Refresh_Date as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Table_Name as varchar),'')+'</td>' +
	'</tr>'
	set @Complete =@Complete+isnull(@mesG,'')
    FETCH NEXT FROM db_cursor2 INTO @Table_Name, @Refresh_Date
END 


CLOSE db_cursor2
DEALLOCATE db_cursor2
 
 -----------------------------------------------------------------------------------------------------------------------------------------------------

Set @Complete=@Complete+'</table>'	
set @HEader= 
'<style> table.mytable tr:first-child, table.mytable tr:last-child { background-color: #C0C0C0; color: black }</style>'+
	'<h3 style=''color: Brown;font-family: Calibri''> Not Awarded - PO Issued </h3>'+
	'<table class="mytable"><tr>'+
	'<table style=''width:800; font-size: 15; border:1px solid black; font-family: Calibri; text-align:center''><tr style="border: 1px solid black;background: #C0C0C0">' +
	'<td>JobNumber</td>' +'<td>Finance Number</td>' +'<td>Department</td>' +'<td> Element </td>' +'<td> Jobs</td>' + '<td> ECTC</td>' +   
	'</tr>'
Set @Complete = concat(@Complete, @Header)
--EXEC [dbo].[Infra_Global_Audit_Email]
DECLARE db_cursor3 CURSOR FOR 
---------- Table Query ----------

Select PONumber,POFinanceNumber,ElementGroupDepartment,ElementGroupCode,Jobs_Count,ECTC from ( select a.PONumber,POFinanceNumber,a.ElementGroupDepartment,a.ElementGroupCode,count(a.JobNumber) Jobs_Count,Format(sum(a.ECTC),'#,#') ECTC 
,case when ElementGroupDepartment = 'CI' and a.PONumber in ('93797','93798','93799','93867') and ElementGroupCode in ('OSS','TCLD-NFVI')
then 'Ignore as per Imaad email on 26Sep2021' end as Remarks
from [NFTS].[NFTS].[nfts_views].[vECTCJobLevel] A
left join nfts.nfts.nfts_views.[vImplementJobAsBuiltApprStage] B on A.JobNumber = B.jobNumber
inner join (select PONumber,POFinanceNumber from tblPurchaseOrder where POFinanceNumber in ('115022',	'117006',	'117010',	'117001',	'117012',	'118004',	'118006',	'118010',	'118017',	'118018',	'118016',
'118019',	'118008',	'118009',	'119001',	'119004',	'119006',	'119011',	'119002',	'119003',	'119008',	'119012',	'119007',	'120008',	'120009',	'120010',	'120013',	'120006',
'120012',	'120001',	'120002',	'120011',	'121001',	'121002') ) C on A.PONumber = C.PONumber
left join [10.21.35.167,1467].[CRDB].[dbo].[PCC_BudgetData_RevisedTarget_new] d on a.PONumber = d.PO_NO
where (year(StageDate) = 2021 or StageDate is null) and d.po_no is null and ElementGroupCode <> 'OSP' and ElementGroupDepartment not in ('FA', 'CID', 'NO', 'Cyber Security Risks & Compliance', 'HRD')
Group by a.PONumber,POFinanceNumber,a.ElementGroupDepartment,a.ElementGroupCode
 ) X where Remarks is null
		
OPEN db_cursor3  
FETCH NEXT FROM db_cursor3 INTO  @PONum,@FIN_NO,@Dep,@Elem,@#Jobs,@Cost
WHILE @@FETCH_STATUS = 0  
BEGIN  
	
	SET @mesG =
	'<tr>'+
	'<td>' +isnull(cast(@PONum			as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@FIN_NO		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Dep		as varchar),'') +'</td>'+
	'<td>' +isnull(cast(@Elem		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@#Jobs		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Cost	as varchar),'') +'</td>' +	'</tr>'
	set @Complete =@Complete+isnull(@mesG,'')
	
    FETCH NEXT FROM db_cursor3 INTO 
@PONum,@FIN_NO,@Dep,@Elem,@#Jobs,@Cost
END 
CLOSE db_cursor3
DEALLOCATE db_cursor3

--------------------------------------------------------------------------------------------------------------------------------------------------------
Set @Complete=@Complete+'</table>'	
set @HEader= 
'<style> table.mytable tr:first-child, table.mytable tr:last-child { background-color: #C0C0C0; color: black }</style>'+
	'<h3 style=''color: Brown;font-family: Calibri''> Negative As-Built </h3>'+
	'<table class="mytable"><tr>'+
	'<table style=''width:800; font-size: 15; border:1px solid black; font-family: Calibri; text-align:center''><tr style="border: 1px solid black;background: #C0C0C0">' +
	'<td>JobNumber</td>' +'<td>Department</td>' +'<td>Element</td>' +'<td> Yesterday''s ECTC_F. </td>' +'<td> Today''s ECTC_F</td>' + '<td> Difference</td>' +   
	'</tr>'
Set @Complete = concat(@Complete, @Header)

EXEC [dbo].[Infra_Global_Audit_Email]

DECLARE db_cursor4 CURSOR FOR 
---------- Table Query ----------
Select 	JobNumber,department,element,yesterdayECTC_F,todayECTC_F,diffrence	from InfraNegativeAsbuilt
		
OPEN db_cursor4  
FETCH NEXT FROM db_cursor4 INTO  @JobNumber,@Department,@Element,@YesterdayECTC_F,@todayECTC_F,@Difference
WHILE @@FETCH_STATUS = 0  
BEGIN  
	
	SET @mesG =
	'<tr>'+
	'<td>' +isnull(cast(@JobNumber			as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Department		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Element		as varchar),'') +'</td>'+
	'<td>' +isnull(cast(@YesterdayECTC_F		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@todayECTC_F		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Difference	as varchar),'') +'</td>' +	'</tr>'
	set @Complete =@Complete+isnull(@mesG,'')
	
    FETCH NEXT FROM db_cursor4 INTO 
@JobNumber,@Department 	,@Element,@YesterdayECTC_F	    ,@todayECTC_F		    ,@Difference
END 
CLOSE db_cursor4
DEALLOCATE db_cursor4

-------------------------------------------------------------------------------------------------------------------------------------------
Set @Complete=@Complete+'</table>'	
set @HEader= 
'<style> table.mytable tr:first-child, table.mytable tr:last-child { background-color: #C0C0C0; color: black }</style>'+
	'<h3 style=''color: Brown;font-family: Calibri''> Duplicate Jobs </h3>'+
	'<table class="mytable"><tr>'+
	'<table style=''width:800; font-size: 15; border:1px solid black; font-family: Calibri; text-align:center''><tr style="border: 1px solid black;background: #C0C0C0">' +
	'<td>PO</td>' 
	+'<td>Department</td>' 
	+'<td>Element</td>' 
	+'<td>Job Number' 
	+'<td>Count' 
	+ '<td>ECTC</td>' +   
	'</tr>'
Set @Complete = concat(@Complete, @Header)

EXEC [dbo].[Infra_Global_Audit_Email]

DECLARE db_cursor5 CURSOR FOR 
---------- Table Query ----------

select PONumber,Department,Element,JobNumber,max(R) R,Format(sum(ECTC),'#,#') ECTC from (
Select PONumber,Department,Element,JobNumber,row_number() over(partition by jobnumber order by jobnumber) R,ECTC from PCC_Dashboard_Data_BI
where jobnumber is not null and (year(StageDate)=2021 or StageDate is null) and oldAchFlag = 'No'
) X Group By PONumber,Department,Element,JobNumber having max(R)>1 order by Sum(ECTC) DESC

OPEN db_cursor5  
FETCH NEXT FROM db_cursor5 INTO  @PO1,@Dep1,@Elem1,@Job1,@Count,@ECTC1
WHILE @@FETCH_STATUS = 0  
BEGIN  
	
	SET @mesG =
	'<tr>'+
	'<td>' +isnull(cast(@PO1			as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Dep1		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Elem1		as varchar),'') +'</td>'+
	'<td>' +isnull(cast(@Job1		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@Count		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@ECTC1	as varchar),'') +'</td>' +	'</tr>'
	set @Complete =@Complete+isnull(@mesG,'')
	
    FETCH NEXT FROM db_cursor5 INTO 
@PO1,@Dep1,@Elem1,@Job1,@Count,@ECTC1
END 
CLOSE db_cursor5
DEALLOCATE db_cursor5

------------------------------------------------------------------------------------------------------------------------------------------------
Set @Complete=@Complete+'</table>'	
set @HEader= 
'<style> table.mytable tr:first-child, table.mytable tr:last-child { background-color: #C0C0C0; color: black }</style>'+
	'<h3 style=''color: Brown;font-family: Calibri''> AsB Check </h3>'+
	'<table class="mytable"><tr>'+
	'<table style=''width:800; font-size: 15; border:1px solid black; font-family: Calibri; text-align:center''><tr style="border: 1px solid black;background: #C0C0C0">' +
	'<td>Department</td>' 
	+'<td>Old_Ach</td>' 
	+'<td>New_Achv</td>' 
	+ '<td>Diff</td>' +   
	'</tr>'
Set @Complete = concat(@Complete, @Header)

EXEC [dbo].[Infra_Global_Audit_Email]

DECLARE db_cursor6 CURSOR FOR 
---------- Table Query ----------

select A.Department, Old_ACHV, New_Achv, (New_Achv-Old_ACHV) as Diff
from (Select Department,SUM(ECTC_F) New_Achv
from PCC_Dashboard_Data_BI_bkup
where year(StageDate)=2021 and datatime = @maxDate
group by Department)A
left join
(Select Department,SUM(ECTC_F) Old_ACHV
from PCC_Dashboard_Data_BI_bkup
where year(StageDate)=2021 and datatime = @minDate
group by Department)B
on a.Department = b.Department

OPEN db_cursor6  
FETCH NEXT FROM db_cursor6 INTO  @Dep2,@OldACH,@NewACH,@Diff
WHILE @@FETCH_STATUS = 0  
BEGIN  
	
	SET @mesG =
	'<tr>'+
	'<td>' +isnull(cast(@Dep2			as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@OldACH		as varchar),'') +'</td>' +
	'<td>' +isnull(cast(@NewACH		as varchar),'') +'</td>'+
	'<td>' +isnull(cast(@Diff	as varchar),'') +'</td>' +	'</tr>'
	set @Complete =@Complete+isnull(@mesG,'')
	
    FETCH NEXT FROM db_cursor6 INTO 
@Dep2,@OldACH,@NewACH,@Diff
END 

CLOSE db_cursor6
DEALLOCATE db_cursor6

Set @Complete=@Complete+'</table>' + '<br/><p>Note: This is system generated email scheduled to be sent out everyday at 9:00 AM, for any querries please reply back to same email.</p><br/><p>Regards: </p><h5>OSP PMO Control</h5><br/>'
print @Complete
------------*******  Subject ******------------
Set @subject = 'Infra Global Audit Email'

-----------****** Sending Email ******------------
EXEC msdb.dbo.sp_send_dbmail  
    @profile_name = 'OP Control',  
    @recipients = 
					'nbasharat.c@stc.com.sa;amehmood.c@stc.com.sa;mkaramat.c@stc.com.sa',  
	@copy_recipients = 
					'amahammat.c@stc.com.sa;hbajwa.c@stc.com.sa',
    @body = @Complete,
	@body_format = 'HTML',
    @subject = @subject


End