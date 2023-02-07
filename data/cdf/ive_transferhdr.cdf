[[IVE_TRANSFERHDR.ARNF]]
rem --- New Batch?
	if num(stbl("+BATCH_NO"),err=*next)<>0
		rem --- Check if this record exists in a different batch
		tableAlias$=callpoint!.getAlias()
		primaryKey$=callpoint!.getColumnData("IVE_TRANSFERHDR.FIRM_ID")+
:			callpoint!.getColumnData("IVE_TRANSFERHDR.WAREHOUSE_ID")+
:			callpoint!.getColumnData("IVE_TRANSFERHDR.WAREHOUSE_ID_TO")+
:			callpoint!.getColumnData("IVE_TRANSFERHDR.TRANS_DATE")
		call stbl("+DIR_PGM")+"adc_findbatch.aon",tableAlias$,primaryKey$,Translate!,table_chans$[all],existingBatchNo$,status
		if status or existingBatchNo$<>"" then callpoint!.setStatus("NEWREC")
	endif

[[IVE_TRANSFERHDR.BEND]]
rem --- Remove software lock on batch, if batching
	batch$=stbl("+BATCH_NO",err=*next)
	if num(batch$)<>0
		lock_table$="ADM_PROCBATCHES"
		lock_record$=firm_id$+stbl("+PROCESS_ID")+batch$
		lock_type$="X"
		lock_status$=""
		lock_disp$=""
		call stbl("+DIR_SYP")+"bac_lock_record.bbj",lock_table$,lock_record$,lock_type$,lock_disp$,rd_table_chan,table_chans$[all],lock_status$
	endif

[[IVE_TRANSFERHDR.BSHO]]
rem --- Open files
	num_files=4
	dim open_tables$[1:num_files],open_opts$[1:num_files],open_chans$[1:num_files],open_tpls$[1:num_files]
	open_tables$[1]="IVS_PARAMS",   open_opts$[1]="OTA"
	open_tables$[2]="IVM_ITEMMAST", open_opts$[2]="OTA"
	open_tables$[3]="IVM_ITEMWHSE", open_opts$[3]="OTA"
	open_tables$[4]="IVM_LSMASTER", open_opts$[4]="OTA"	

	gosub open_tables

	ivs01_dev=num(open_chans$[1])
	dim ivs01a$:open_tpls$[1]

rem --- Get IV parameter record
	find record(ivs01_dev,key=firm_id$+"IV00",dom=std_missing_params) ivs01a$
	callpoint!.setDevObject("lotser_flag",ivs01a.lotser_flag$)

	precision num(ivs01a.precision$)

rem --- Exit if not multi-warehouse
	if ivs01a.multi_whse$ <> "Y" then
		callpoint!.setMessage("IV_NOT_MULTI_WHSE")
		callpoint!.setStatus("EXIT")
		break
	endif

rem --- Is the GL module installed?
	gl$="N"
	glint$="N"
	call stbl("+DIR_PGM")+"adc_application.aon","GL",info$[all]
	if info$[20]="Y" then 
		call stbl("+DIR_PGM")+"adc_application.aon","IV",info$[all]

		rem --- Does IV post to GL?
		gl$=info$[9]

			rem --- Create GL Posting Control
		if gl$="Y" then 	call stbl("+DIR_PGM")+"glc_ctlcreate.aon",err=*next,pgm(-2),"OP",glw11$,glint$,status
		endif
	endif
	callpoint!.setDevObject("gl",gl$)
			callpoint!.setDevObject("glint",glint$)

[[IVE_TRANSFERHDR.BTBL]]
rem --- Get Batch information
	call stbl("+DIR_PGM")+"adc_getbatch.aon",callpoint!.getAlias(),"",table_chans$[all]
	callpoint!.setTableColumnAttribute("IVE_TRANSFERHDR.BATCH_NO","PVAL",$22$+stbl("+BATCH_NO")+$22$)

[[IVE_TRANSFERHDR.BWRI]]
rem --- Both warehouses can't be the same
	from_whse$ = callpoint!.getColumnData("IVE_TRANSFERHDR.WAREHOUSE_ID")
	to_whse$   = callpoint!.getColumnData("IVE_TRANSFERHDR.WAREHOUSE_ID_TO")
	if from_whse$ = to_whse$ then
		msg_id$ = "IV_FROM_TO_WHSE_MTCH"
		gosub disp_message
		callpoint!.setStatus("ABORT")
		break
	endif

[[IVE_TRANSFERHDR.TRANS_DATE.AVAL]]
rem --- Is date within range of GL period?
	if callpoint!.getDevObject("glint")="Y" then 
		call stbl("+DIR_PGM")+"glc_datecheck.aon",callpoint!.getUserInput(),"Y",period$,year$,status
		if status>99 then callpoint!.setStatus("ABORT")
	endif

[[IVE_TRANSFERHDR.WAREHOUSE_ID.AVAL]]
rem --- Both warehouses can't be the same
	from_whse$ = callpoint!.getUserInput()
	to_whse$   = callpoint!.getColumnData("IVE_TRANSFERHDR.WAREHOUSE_ID_TO")
	if from_whse$ = to_whse$ then
		msg_id$ = "IV_FROM_TO_WHSE_MTCH"
		gosub disp_message
		callpoint!.setStatus("ABORT")
		break
	endif

[[IVE_TRANSFERHDR.WAREHOUSE_ID_TO.AVAL]]
rem --- Both warehouses can't be the same
	to_whse$ = callpoint!.getUserInput()
	from_whse$   = callpoint!.getColumnData("IVE_TRANSFERHDR.WAREHOUSE_ID")
	if from_whse$ = to_whse$ then
		msg_id$ = "IV_FROM_TO_WHSE_MTCH"
		gosub disp_message
		callpoint!.setStatus("ABORT")
		break
	endif

[[IVE_TRANSFERHDR.<CUSTOM>]]
rem ===========================================================================
#include [+ADDON_LIB]std_missing_params.aon
rem ===========================================================================



