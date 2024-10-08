[[GLR_TRANSHISTORY.ARAR]]
rem --- Set default values
	gls01_dev=fnget_dev("GLS_PARAMS")
	dim gls01a$:fnget_tpl$("GLS_PARAMS")
	readrecord(gls01_dev,key=firm_id$+"GL00")gls01a$
	callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_GL_PER",gls01a.current_per$)
	callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_YEAR",gls01a.current_year$)
	callpoint!.setColumnData("GLR_TRANSHISTORY.END_GL_PER",gls01a.current_per$)
	callpoint!.setColumnData("GLR_TRANSHISTORY.END_YEAR",gls01a.current_year$)
	callpoint!.setStatus("REFRESH")

rem --- Set maximum number of periods allowed for beginning fiscal year
	gls_calendar_dev=fnget_dev("GLS_CALENDAR")
	dim gls_calendar$:fnget_tpl$("GLS_CALENDAR")
	current_year$=callpoint!.getColumnData("GLR_TRANSHISTORY.BEG_YEAR")
	readrecord(gls_calendar_dev,key=firm_id$+current_year$,dom=*next)gls_calendar$
	callpoint!.setDevObject("beginning_total_pers",gls_calendar.total_pers$)

rem --- Set maximum number of periods allowed for ending fiscal year
	gls_calendar_dev=fnget_dev("GLS_CALENDAR")
	dim gls_calendar$:fnget_tpl$("GLS_CALENDAR")
	current_year$=callpoint!.getColumnData("GLR_TRANSHISTORY.END_YEAR")
	readrecord(gls_calendar_dev,key=firm_id$+current_year$,dom=*next)gls_calendar$
	callpoint!.setDevObject("ending_total_pers",gls_calendar.total_pers$)

[[GLR_TRANSHISTORY.ASVA]]
rem --- Check for Ending Period before Beginning Period
	begper$=str(num(callpoint!.getColumnData("GLR_TRANSHISTORY.BEG_YEAR")):"0000")+
:			str(num(callpoint!.getColumnData("GLR_TRANSHISTORY.BEG_GL_PER")):"00")
	endper$=str(num(callpoint!.getColumnData("GLR_TRANSHISTORY.END_YEAR")):"0000")+
:			str(num(callpoint!.getColumnData("GLR_TRANSHISTORY.END_GL_PER")):"00")
	if num(endper$)<>0
		if begper$>endper$
			begper$="Beginning Period/Year "+begper$(5,2)+"/"+begper$(1,4)
			endper$="Ending Period/Year "+endper$(5,2)+"/"+endper$(1,4)
			callpoint!.setMessage("ENTRY_FROM_TO:"+begper$+";"+endper$)
			callpoint!.setStatus("ABORT")
		endif
	endif

rem --- If Query option was selected, launch query (otherwise report will run)

	if callpoint!.getColumnData("GLR_TRANSHISTORY.PICK_LISTBUTTON")="Q"
		gosub launch_query
		callpoint!.setStatus("ABORT")
	endif
	

[[GLR_TRANSHISTORY.BEG_GL_PER.AVAL]]
rem --- Verify haven't exceeded calendar total periods for beginning fiscal year
	period$=callpoint!.getUserInput()
	if cvs(period$,2)<>"" and period$<>callpoint!.getColumnData("GLR_TRANSHISTORY.BEG_GL_PER") then
		period=num(period$)
		total_pers=num(callpoint!.getDevObject("beginning_total_pers"))
		if period<1 or period>total_pers then
			msg_id$="AD_BAD_FISCAL_PERIOD"
			dim msg_tokens$[2]
			msg_tokens$[1]=str(total_pers)
			msg_tokens$[2]=callpoint!.getColumnData("GLR_TRANSHISTORY.BEG_YEAR")
			gosub disp_message
			callpoint!.setStatus("ABORT")
			break
		endif
	endif

[[GLR_TRANSHISTORY.BEG_YEAR.AVAL]]
rem --- Verify calendar exists for entered beginning fiscal year
	year$=callpoint!.getUserInput()
	if cvs(year$,2)<>"" and year$<>callpoint!.getColumnData("GLR_TRANSHISTORY.BEG_YEAR") then
		gls_calendar_dev=fnget_dev("GLS_CALENDAR")
		dim gls_calendar$:fnget_tpl$("GLS_CALENDAR")
		readrecord(gls_calendar_dev,key=firm_id$+year$,dom=*next)gls_calendar$
		if cvs(gls_calendar.year$,2)="" then
			msg_id$="AD_NO_FISCAL_CAL"
			dim msg_tokens$[1]
			msg_tokens$[1]=year$
			gosub disp_message
			callpoint!.setStatus("ABORT")
			break
		endif
		callpoint!.setDevObject("beginning_total_pers",gls_calendar.total_pers$)

		rem --- Verify haven't exceeded calendar total periods for beginning fiscal year
		period$=callpoint!.getColumnData("GLR_TRANSHISTORY.BEG_GL_PER")
		if cvs(period$,2)<>"" then
			period=num(period$)
			total_pers=num(callpoint!.getDevObject("beginning_total_pers"))
			if period<1 or period>total_pers then
				msg_id$="AD_BAD_FISCAL_PERIOD"
				dim msg_tokens$[2]
				msg_tokens$[1]=str(total_pers)
				msg_tokens$[2]=year$
				gosub disp_message
				callpoint!.setStatus("ABORT")
				break
			endif
		endif
	endif

[[GLR_TRANSHISTORY.BSHO]]
rem --- Open and get Current Period/Year parameters
	num_files=2
	dim open_tables$[1:num_files],open_opts$[1:num_files],open_chans$[1:num_files],open_tpls$[1:num_files]
	open_tables$[1]="GLS_PARAMS",open_opts$[1]="OTA"
	open_tables$[2]="GLS_CALENDAR",open_opts$[2]="OTA"

	gosub open_tables

rem --- Disable SORT_BY unless detail report and both audit number and journal ID entered 
	callpoint!.setColumnEnabled("GLR_TRANSHISTORY.SORT_BY",0)

[[GLR_TRANSHISTORY.END_GL_PER.AVAL]]
rem --- Verify haven't exceeded calendar total periods for ending fiscal year
	period$=callpoint!.getUserInput()
	if cvs(period$,2)<>"" and period$<>callpoint!.getColumnData("GLR_TRANSHISTORY.END_GL_PER") then
		period=num(period$)
		total_pers=num(callpoint!.getDevObject("ending_total_pers"))
		if period<1 or period>total_pers then
			msg_id$="AD_BAD_FISCAL_PERIOD"
			dim msg_tokens$[2]
			msg_tokens$[1]=str(total_pers)
			msg_tokens$[2]=callpoint!.getColumnData("GLR_TRANSHISTORY.END_YEAR")
			gosub disp_message
			callpoint!.setStatus("ABORT")
			break
		endif
	endif

[[GLR_TRANSHISTORY.END_YEAR.AVAL]]
rem --- Verify calendar exists for entered ending fiscal year
	year$=callpoint!.getUserInput()
	if cvs(year$,2)<>"" and year$<>callpoint!.getColumnData("GLR_TRANSHISTORY.END_YEAR") then
		gls_calendar_dev=fnget_dev("GLS_CALENDAR")
		dim gls_calendar$:fnget_tpl$("GLS_CALENDAR")
		readrecord(gls_calendar_dev,key=firm_id$+year$,dom=*next)gls_calendar$
		if cvs(gls_calendar.year$,2)="" then
			msg_id$="AD_NO_FISCAL_CAL"
			dim msg_tokens$[1]
			msg_tokens$[1]=year$
			gosub disp_message
			callpoint!.setStatus("ABORT")
			break
		endif
		callpoint!.setDevObject("ending_total_pers",gls_calendar.total_pers$)

		rem --- Verify haven't exceeded calendar total periods for ending fiscal year
		period$=callpoint!.getColumnData("GLR_TRANSHISTORY.END_GL_PER")
		if cvs(period$,2)<>"" then
			period=num(period$)
			total_pers=num(callpoint!.getDevObject("ending_total_pers"))
			if period<1 or period>total_pers then
				msg_id$="AD_BAD_FISCAL_PERIOD"
				dim msg_tokens$[2]
				msg_tokens$[1]=str(total_pers)
				msg_tokens$[2]=year$
				gosub disp_message
				callpoint!.setStatus("ABORT")
				break
			endif
		endif
	endif

[[GLR_TRANSHISTORY.GL_ACCOUNT.AVAL]]
rem "GL INACTIVE FEATURE"
   glm01_dev=fnget_dev("GLM_ACCT")
   glm01_tpl$=fnget_tpl$("GLM_ACCT")
   dim glm01a$:glm01_tpl$
   glacctinput$=callpoint!.getUserInput()
   glm01a_key$=firm_id$+glacctinput$
   find record (glm01_dev,key=glm01a_key$,err=*break) glm01a$
   if glm01a.acct_inactive$="Y" then
      call stbl("+DIR_PGM")+"adc_getmask.aon","GL_ACCOUNT","","","",m0$,0,gl_size
      msg_id$="GL_ACCT_INACTIVE"
      dim msg_tokens$[2]
      msg_tokens$[1]=fnmask$(glm01a.gl_account$(1,gl_size),m0$)
      msg_tokens$[2]=cvs(glm01a.gl_acct_desc$,2)
      gosub disp_message
      callpoint!.setStatus("ACTIVATE")
   endif

[[GLR_TRANSHISTORY.GL_ADT_NO.AVAL]]
rem --- Validate audit number
	gl_adt_no$=cvs(callpoint!.getUserInput(),2)
	audit_num=-1
	audit_num=num(gl_adt_no$,err=*next)
	if gl_adt_no$<>"" and (audit_num<=0 or audit_num>9999999) then
		msg_id$="ENTRY_INVALID"
		dim msg_tokens$[1]
		msg_tokens$[1]=Translate!.getTranslation("AON_AUDIT_NUMBER")+" 0000001 - 9999999"
		gosub disp_message
		callpoint!.setStatus("ABORT")
		break
	endif

rem --- Clear and disable date, period and year fields when audit number entered
	if gl_adt_no$<>"" then
		rem --- Only EXPORT_FORMAT and PICK_LISTBUTTON remain enabled
		callpoint!.setColumnData("GLR_TRANSHISTORY.TRNS_DATE","",1)
		callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_GL_PER","",1)
		callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_YEAR","",1)
		callpoint!.setColumnData("GLR_TRANSHISTORY.END_GL_PER","",1)
		callpoint!.setColumnData("GLR_TRANSHISTORY.END_YEAR","",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.TRNS_DATE",0)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.BEG_GL_PER",0)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.BEG_YEAR",0)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.END_GL_PER",0)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.END_YEAR",0)
	else
		gls01_dev=fnget_dev("GLS_PARAMS")
		dim gls01a$:fnget_tpl$("GLS_PARAMS")
		readrecord(gls01_dev,key=firm_id$+"GL00")gls01a$
		callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_GL_PER",gls01a.current_per$,1)
		callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_YEAR",gls01a.current_year$,1)
		callpoint!.setColumnData("GLR_TRANSHISTORY.END_GL_PER",gls01a.current_per$,1)
		callpoint!.setColumnData("GLR_TRANSHISTORY.END_YEAR",gls01a.current_year$,1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.TRNS_DATE",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.BEG_GL_PER",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.BEG_YEAR",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.END_GL_PER",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.END_YEAR",1)
	endif

rem --- Initialize SORT_BY=R and enable when detail report and both audit number and journal ID entered
	report$=callpoint!.getColumnData("GLR_TRANSHISTORY.PICK_LISTBUTTON")
	journal_id$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.PICK_JOURNAL_ID"),2)
	if report$="D" and gl_adt_no$<>"" and journal_id$<>"" then
		callpoint!.setColumnData("GLR_TRANSHISTORY.SORT_BY","R",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.SORT_BY",1)
	else
		callpoint!.setColumnData("GLR_TRANSHISTORY.SORT_BY","A",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.SORT_BY",0)
	endif

[[GLR_TRANSHISTORY.GL_WILDCARD.AVAL]]
rem --- Check length of wildcard against defined mask for GL Account
	if callpoint!.getUserInput()<>""
		call "adc_getmask.aon","GL_ACCOUNT","","","",m0$,0,m0
		if len(callpoint!.getUserInput())>len(m0$)
			msg_id$="GL_WILDCARD_LONG"
			gosub disp_message
			callpoint!.setStatus("ABORT")
		endif
	endif

[[GLR_TRANSHISTORY.PICK_JOURNAL_ID.AVAL]]
rem --- Initialize SORT_BY=R and enable when detail report and both audit number and journal ID entered
	journal_id$=cvs(callpoint!.getUserInput(),2)
	gl_adt_no$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.GL_ADT_NO"),2)
	report$=callpoint!.getColumnData("GLR_TRANSHISTORY.PICK_LISTBUTTON")
	if report$="D" and gl_adt_no$<>"" and journal_id$<>"" then
		callpoint!.setColumnData("GLR_TRANSHISTORY.SORT_BY","R",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.SORT_BY",1)
	else
		callpoint!.setColumnData("GLR_TRANSHISTORY.SORT_BY","A",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.SORT_BY",0)
	endif

[[GLR_TRANSHISTORY.PICK_LISTBUTTON.AVAL]]
rem --- Initialize SORT_BY=R and enable when detail report and both audit number and journal ID entered
	report$=callpoint!.getUserInput()
	gl_adt_no$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.GL_ADT_NO"),2)
	journal_id$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.PICK_JOURNAL_ID"),2)
	if report$="D" and gl_adt_no$<>"" and journal_id$<>"" then
		callpoint!.setColumnData("GLR_TRANSHISTORY.SORT_BY","R",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.SORT_BY",1)
	else
		callpoint!.setColumnData("GLR_TRANSHISTORY.SORT_BY","A",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.SORT_BY",0)
	endif

[[GLR_TRANSHISTORY.TRNS_DATE.AVAL]]
rem --- Clear and disable fields when transaction date entered
	if cvs(callpoint!.getUserInput(),2)<>"" then
		rem --- Clear and disable Audit Number, Period and Year fields
		callpoint!.setColumnData("GLR_TRANSHISTORY.GL_ADT_NO","",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.GL_ADT_NO",0)
		callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_GL_PER","",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.BEG_GL_PER",0)
		callpoint!.setColumnData("GLR_TRANSHISTORY.BEG_YEAR","",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.BEG_YEAR",0)
		callpoint!.setColumnData("GLR_TRANSHISTORY.END_GL_PER","",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.END_GL_PER",0)
		callpoint!.setColumnData("GLR_TRANSHISTORY.END_YEAR","",1)
		callpoint!.setColumnEnabled("GLR_TRANSHISTORY.END_YEAR",0)
	endif

[[GLR_TRANSHISTORY.<CUSTOM>]]
rem ==============================================
launch_query: 
rem in: begper$ (YYYYMM), endper$ (YYYYMM)
rem ==============================================

rem --- launch query instead of report

gl_adt_no$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.GL_ADT_NO"),2)
trns_date$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.TRNS_DATE"),2)
beg_acct$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.GL_ACCOUNT_1"),2)
end_acct$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.GL_ACCOUNT_2"),2)
jrnl_id$=cvs(callpoint!.getColumnData("GLR_TRANSHISTORY.PICK_JOURNAL_ID"),2)

dim filter_defs$[10,2]
filter_defs$[1,0]="GLT_TRANSDETAIL.FIRM_ID"
filter_defs$[1,1]="='"+firm_id$+"'"
filter_defs$[1,2]="LOCK"
if gl_adt_no$<>""
	filter_defs$[2,0]="GLT_TRANSDETAIL.GL_ADT_NO"
	filter_defs$[2,1]="='"+gl_adt_no$+"'"
endif
if trns_date$<>""
	filter_defs$[3,0]="GLT_TRANSDETAIL.TRNS_DATE"
	filter_defs$[3,1]="='"+trns_date$+"'"
endif
if num(begper$)<>0
	filter_defs$[4,0]="GLT_TRANSDETAIL.POSTING_PER"
	filter_defs$[4,1]=">='"+begper$(5,2)+"'"
	filter_defs$[5,0]="GLT_TRANSDETAIL.POSTING_YEAR"
	filter_defs$[5,1]=">='"+begper$(1,4)+"'"
endif
if num(endper$)<>0
	filter_defs$[6,0]="GLT_TRANSDETAIL.POSTING_PER"
	filter_defs$[6,1]="<='"+endper$(5,2)+"'"
	filter_defs$[7,0]="GLT_TRANSDETAIL.POSTING_YEAR"
	filter_defs$[7,1]="<='"+endper$(1,4)+"'"
endif
if beg_acct$<>""
	filter_defs$[8,0]="GLT_TRANSDETAIL.GL_ACCOUNT"
	filter_defs$[8,1]=">='"+beg_acct$+"'"
endif
if end_acct$<>""
	filter_defs$[9,0]="GLT_TRANSDETAIL.GL_ACCOUNT"
	filter_defs$[9,1]="<='"+end_acct$+"'"
endif
if jrnl_id$<>""
	filter_defs$[10,0]="GLT_TRANSDETAIL.JOURNAL_ID"
	filter_defs$[10,1]="='"+jrnl_id$+"'"
endif

call stbl("+DIR_SYP")+"bax_query.bbj",gui_dev,Form!,"GL_TRANS_INQ","",table_chans$[all],
:	"",filter_defs$[all],search_defs$[all]

return



#include [+ADDON_LIB]std_functions.aon



