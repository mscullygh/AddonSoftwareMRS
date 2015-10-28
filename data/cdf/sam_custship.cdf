[[SAM_CUSTSHIP.BPRK]]
rem --- Use current selections for initiating previous record
	year$=callpoint!.getColumnData("SAM_CUSTSHIP.YEAR")
	customer_id$=callpoint!.getColumnData("SAM_CUSTSHIP.CUSTOMER_ID")
	shipto_no$=callpoint!.getColumnData("SAM_CUSTSHIP.SHIPTO_NO")
	item_id$=callpoint!.getColumnData("SAM_CUSTSHIP.ITEM_ID")
	sam_dev=fnget_dev("SAM_CUSTSHIP")
	read(sam_dev,key=firm_id$+year$+customer_id$+shipto_no$+item_id$,dir=0,dom=*next)
[[SAM_CUSTSHIP.BNEK]]
rem --- Use current selections for initiating next record
	year$=callpoint!.getColumnData("SAM_CUSTSHIP.YEAR")
	customer_id$=callpoint!.getColumnData("SAM_CUSTSHIP.CUSTOMER_ID")
	shipto_no$=callpoint!.getColumnData("SAM_CUSTSHIP.SHIPTO_NO")
	item_id$=callpoint!.getColumnData("SAM_CUSTSHIP.ITEM_ID")
	sam_dev=fnget_dev("SAM_CUSTSHIP")
	read(sam_dev,key=firm_id$+year$+customer_id$+shipto_no$+item_id$,dom=*next)
[[SAM_CUSTSHIP.ITEM_ID.AINV]]
rem --- Item synonym processing

	call stbl("+DIR_PGM")+"ivc_itemsyn.aon::option_entry"
[[SAM_CUSTSHIP.ITEM_ID.AVAL]]
rem --- Enable/Disable Summary button
	cust_no$=callpoint!.getColumnData("SAM_CUSTSHIP.CUSTOMER_ID")
	shipto_no$=callpoint!.getColumnData("SAM_CUSTSHIP.SHIPTO_NO")
	item_no$=callpoint!.getUserInput()
	gosub summ_button
[[SAM_CUSTSHIP.SHIPTO_NO.AVAL]]
rem --- Enable/Disable Summary button
	cust_no$=callpoint!.getColumnData("SAM_CUSTSHIP.CUSTOMER_ID")
	shipto_no$=callpoint!.getUserInput()
	item_no$=callpoint!.getColumnData("SAM_CUSTSHIP.ITEM_ID")
	gosub summ_button
[[SAM_CUSTSHIP.CUSTOMER_ID.AVAL]]
rem --- Enable/Disable Summary button
	cust_no$=callpoint!.getUserInput()
	shipto_no$=callpoint!.getColumnData("SAM_CUSTSHIP.SHIPTO_NO")
	item_no$=callpoint!.getColumnData("SAM_CUSTSHIP.ITEM_ID")
	gosub summ_button
[[SAM_CUSTSHIP.AOPT-SUMM]]
rem --- Calculate and display summary info
	tcst=0
	tqty=0
	tsls=0
	year$=callpoint!.getColumnData("SAM_CUSTSHIP.YEAR")
	lyear$=str(num(year$)-1:"0000")
	trip_key$=firm_id$+year$+callpoint!.getColumnData("SAM_CUSTSHIP.CUSTOMER_ID")
	ltrip_key$=firm_id$+lyear$+callpoint!.getColumnData("SAM_CUSTSHIP.CUSTOMER_ID")
	shipto_no$=callpoint!.getColumnData("SAM_CUSTSHIP.SHIPTO_NO")
	item_id$=callpoint!.getColumnData("SAM_CUSTSHIP.ITEM_ID")
	if cvs(shipto_no$,2)<>"" 
		trip_key$=trip_key$+shipto_no$
		ltrip_key$=ltrip_key$+shipto_no$
	else
		callpoint!.setColumnData("SAM_CUSTSHIP.SHIPTO_NO","")
	endif
	callpoint!.setColumnData("SAM_CUSTSHIP.ITEM_ID","")

rem --- Start progress meter
	task_id$=info(3,0)
	Window_Name$=Translate!.getTranslation("AON_SUMMARIZING")
	Progress! = bbjapi().getGroupNamespace()
	Progress!.setValue("+process_task",task_id$+"^C^"+Window_Name$+"^CNC-IND^"+str(n)+"^")

	sam_dev=	fnget_dev("SAM_CUSTSHIP")
	dim sam_tpl$:fnget_tpl$("SAM_CUSTSHIP")
	dim qty[13],cost[13],sales[13]

rem --- Calculate Last Year

	read(sam_dev,key=ltrip_key$,dom=*next)
	while 1
		read record(sam_dev,end=*break)sam_tpl$

		Progress!.getValue("+process_task_"+task_id$,err=*next);break
	
		if pos(ltrip_key$=sam_tpl$)<>1 break
		for x=1 to 13
			qty[x]=qty[x]+nfield(sam_tpl$,"qty_shipped_"+str(x:"00"))
			cost[x]=cost[x]+nfield(sam_tpl$,"total_cost_"+str(x:"00"))
			sales[x]=sales[x]+nfield(sam_tpl$,"total_sales_"+str(x:"00"))
		next x
	wend
	For x=1 to 13
		tcst=tcst+cost[x]
		tqty=tqty+qty[x]
		tsls=tsls+sales[x]
	next x

	for x=1 to 13
		callpoint!.setColumnData("<<DISPLAY>>.LY_SHIP_"+str(x:"00"),str(qty[x]))
		callpoint!.setColumnData("<<DISPLAY>>.LY_SALES_"+str(x:"00"),str(sales[x]))
		callpoint!.setColumnData("<<DISPLAY>>.LY_COST_"+str(x:"00"),str(cost[x]))
	next x

	callpoint!.setColumnData("<<DISPLAY>>.LY_COST_TOT",str(tcst))
	callpoint!.setColumnData("<<DISPLAY>>.LY_SALES_TOT",str(tsls))
	callpoint!.setColumnData("<<DISPLAY>>.LY_SHIP_TOT",str(tqty))

	tcst=0
	tsls=0
	tqty=0
	dim cost[13],qty[13],sales[13]

rem --- Calculate This Year

	read(sam_dev,key=trip_key$,dom=*next)
	while 1
		read record(sam_dev,end=*break)sam_tpl$

		Progress!.getValue("+process_task_"+task_id$,err=*next);break

		if pos(trip_key$=sam_tpl$)<>1 break
		for x=1 to 13
			qty[x]=qty[x]+nfield(sam_tpl$,"qty_shipped_"+str(x:"00"))
			cost[x]=cost[x]+nfield(sam_tpl$,"total_cost_"+str(x:"00"))
			sales[x]=sales[x]+nfield(sam_tpl$,"total_sales_"+str(x:"00"))
		next x
	wend
	For x=1 to 13
		tcst=tcst+cost[x]
		tqty=tqty+qty[x]
		tsls=tsls+sales[x]
	next x

Progress!.setValue("+process_task",task_id$+"^D^")

rem --- Now display all of these things and disable key fields
	for x=1 to 13
		callpoint!.setColumnData("SAM_CUSTSHIP.TOTAL_SALES_"+str(x:"00"),str(sales[x]))
		callpoint!.setColumnData("SAM_CUSTSHIP.TOTAL_COST_"+str(x:"00"),str(cost[x]))
		callpoint!.setColumnData("SAM_CUSTSHIP.QTY_SHIPPED_"+str(x:"00"),str(qty[x]))
	next x
	callpoint!.setColumnData("<<DISPLAY>>.TCST",str(tcst))
	callpoint!.setColumnData("<<DISPLAY>>.TQTY",str(tqty))
	callpoint!.setColumnData("<<DISPLAY>>.TSLS",str(tsls))

	callpoint!.setColumnEnabled("SAM_CUSTSHIP.YEAR",0)
	callpoint!.setColumnEnabled("SAM_CUSTSHIP.CUSTOMER_ID",0)
	callpoint!.setColumnEnabled("SAM_CUSTSHIP.SHIPTO_NO",0)
	callpoint!.setColumnEnabled("SAM_CUSTSHIP.ITEM_ID",0)
	callpoint!.setOptionEnabled("SUMM",0)
	callpoint!.setStatus("REFRESH-CLEAR")
[[SAM_CUSTSHIP.ARAR]]
rem --- Create totals

	gosub calc_totals
[[SAM_CUSTSHIP.AREC]]
rem --- Enable key fields
	ctl_name$="SAM_CUSTSHIP.YEAR"
	ctl_stat$=""
	gosub disable_fields
	ctl_name$="SAM_CUSTSHIP.CUSTOMER_ID"
	ctl_stat$=""
	gosub disable_fields
	ctl_name$="SAM_CUSTSHIP.SHIPTO_NO"
	ctl_stat$=""
	gosub disable_fields
	ctl_name$="SAM_CUSTSHIP.ITEM_ID"
	ctl_stat$=""
	gosub disable_fields
	callpoint!.setColumnData("<<DISPLAY>>.TCST","0")
	callpoint!.setColumnData("<<DISPLAY>>.TQTY","0")
	callpoint!.setColumnData("<<DISPLAY>>.TSLS","0")

	for x=1 to 13
		callpoint!.setColumnData("<<DISPLAY>>.LY_SHIP_"+str(x:"00"),"0")
		callpoint!.setColumnData("<<DISPLAY>>.LY_SALES_"+str(x:"00"),"0")
		callpoint!.setColumnData("<<DISPLAY>>.LY_COST_"+str(x:"00"),"0")
	next x

	callpoint!.setColumnData("<<DISPLAY>>.LY_COST_TOT","0")
	callpoint!.setColumnData("<<DISPLAY>>.LY_SALES_TOT","0")
	callpoint!.setColumnData("<<DISPLAY>>.LY_SHIP_TOT","0")

	callpoint!.setStatus("REFRESH")
[[SAM_CUSTSHIP.BSHO]]
rem --- Check for parameter record
	num_files=2
	dim open_tables$[1:num_files],open_opts$[1:num_files],open_chans$[1:num_files],open_tpls$[1:num_files]
	open_tables$[1]="SAS_PARAMS",open_opts$[1]="OTA"
	open_tables$[2]="SAM_CUSTSHIP",open_opts$[2]="OTA@"
	gosub open_tables
	sas01_dev=num(open_chans$[1]),sas01a$=open_tpls$[1]

	dim sas01a$:sas01a$
	read record (sas01_dev,key=firm_id$+"SA00")sas01a$
	if sas01a.by_shipto$<>"Y"
		msg_id$="INVALID_SA"
		dim msg_tokens$[1]
		msg_tokens$[1]=Translate!.getTranslation("AON_SHIP-TO")
		gosub disp_message
		bbjAPI!=bbjAPI()
		rdFuncSpace!=bbjAPI!.getGroupNamespace()
		rdFuncSpace!.setValue("+build_task","OFF")
		release
	endif

rem --- disable total elements
	ctl_name$="<<DISPLAY>>.TQTY"
	ctl_stat$="I"
	gosub disable_fields
	ctl_name$="<<DISPLAY>>.TCST"
	ctl_stat$="I"
	gosub disable_fields
	ctl_name$="<<DISPLAY>>.TSLS"
	ctl_stat$="I"
	gosub disable_fields
	callpoint!.setStatus("ABLEMAP-ACTIVATE-REFRESH")

rem --- Disable Summary Button
	callpoint!.setOptionEnabled("SUMM",0)
[[SAM_CUSTSHIP.<CUSTOM>]]
disable_fields:
rem --- used to disable/enable controls depending on parameter settings
rem --- send in control to toggle (format "ALIAS.CONTROL_NAME"), and D or space to disable/enable

	wctl$=str(num(callpoint!.getTableColumnAttribute(ctl_name$,"CTLI")):"00000")
	wmap$=callpoint!.getAbleMap()
	wpos=pos(wctl$=wmap$,8)
	wmap$(wpos+6,1)=ctl_stat$
	callpoint!.setAbleMap(wmap$)

	return

calc_totals:

rem --- Calculate Last Year

	year$=callpoint!.getColumnData("SAM_CUSTSHIP.YEAR")
	lyear$=str(num(year$)-1:"0000")
	cust_no$=callpoint!.getColumnData("SAM_CUSTSHIP.CUSTOMER_ID")
	shipto$=callpoint!.getColumnData("SAM_CUSTSHIP.SHIPTO_NO")
	item$=callpoint!.getColumnData("SAM_CUSTSHIP.ITEM_ID")
	ltrip_key$=firm_id$+lyear$+cust_no$+shipto$+item$
	sam_dev=fnget_dev("@SAM_CUSTSHIP")
	dim sam_tpl$:fnget_tpl$("@SAM_CUSTSHIP")
	dim qty[13],cost[13],sales[13]

	while 1
		read record(sam_dev,key=ltrip_key$,dom=*break)sam_tpl$

		Progress!.getValue("+process_task_"+task_id$,err=*next);break
	
		if pos(ltrip_key$=sam_tpl$)<>1 break
		for x=1 to 13
			qty[x]=qty[x]+nfield(sam_tpl$,"qty_shipped_"+str(x:"00"))
			cost[x]=cost[x]+nfield(sam_tpl$,"total_cost_"+str(x:"00"))
			sales[x]=sales[x]+nfield(sam_tpl$,"total_sales_"+str(x:"00"))
		next x
		break
	wend
	For x=1 to 13
		tcst=tcst+cost[x]
		tqty=tqty+qty[x]
		tsls=tsls+sales[x]
	next x

	for x=1 to 13
		callpoint!.setColumnData("<<DISPLAY>>.LY_SHIP_"+str(x:"00"),str(qty[x]))
		callpoint!.setColumnData("<<DISPLAY>>.LY_SALES_"+str(x:"00"),str(sales[x]))
		callpoint!.setColumnData("<<DISPLAY>>.LY_COST_"+str(x:"00"),str(cost[x]))
	next x

	callpoint!.setColumnData("<<DISPLAY>>.LY_COST_TOT",str(tcst))
	callpoint!.setColumnData("<<DISPLAY>>.LY_SALES_TOT",str(tsls))
	callpoint!.setColumnData("<<DISPLAY>>.LY_SHIP_TOT",str(tqty))
	
	tcst=0
	tqty=0
	tsls=0
	For x=1 to 13
		tcst=tcst+num(callpoint!.getColumnData("SAM_CUSTSHIP.TOTAL_COST_"+str(x:"00")))
		tqty=tqty+num(callpoint!.getColumnData("SAM_CUSTSHIP.QTY_SHIPPED_"+str(x:"00")))
		tsls=tsls+num(callpoint!.getColumnData("SAM_CUSTSHIP.TOTAL_SALES_"+str(x:"00")))
	next x
	callpoint!.setColumnData("<<DISPLAY>>.TCST",str(tcst))
	callpoint!.setColumnData("<<DISPLAY>>.TQTY",str(tqty))
	callpoint!.setColumnData("<<DISPLAY>>.TSLS",str(tsls))
	callpoint!.setStatus("REFRESH-CLEAR")

	return

rem --- Enable/Disable Summary Button
summ_button:
	if callpoint!.isEditMode() then callpoint!.setOptionEnabled("SUMM",1)
	if cvs(cust_no$,2)=""
		callpoint!.setOptionEnabled("SUMM",0)
	else
		if cvs(shipto_no$,2)=""
			if cvs(item_no$,2)<>""
				callpoint!.setOptionEnabled("SUMM",0)
			endif
		else
			if cvs(item_no$,2)<>""
				callpoint!.setOptionEnabled("SUMM",0)
			endif
		endif
	endif
	return
