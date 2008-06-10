[[ARR_AGINGREPORT.UPDATE_AGING.AVAL]]
if callpoint!.getColumnData("ARR_AGINGREPORT.FIXED_PERIODS")="N"
	if callpoint!.getColumnData("ARR_AGINGREPORT.UPDATE_AGING")="Y"
		callpoint!.setMessage("FIXED_PERIODS")
		callpoint!.setColumnData("ARR_AGINGREPORT.UPDATE_AGING","N")
		callpoint!.setStatus("REFRESH")
	endif
endif
[[ARR_AGINGREPORT.FIXED_PERIODS.AVAL]]
rem --- Recalc dates if fixed periods
if callpoint!.getColumnData("ARR_AGINGREPORT.FIXED_PERIODS")="Y"
	cal_date=1
	gosub set_date_seq
	gosub calc_dates
	callpoint!.setStatus("REFRESH")
else
	if callpoint!.getColumnData("ARR_AGINGREPORT.UPDATE_AGING")="Y"
		callpoint!.setMessage("FIXED_PERIODS")
		callpoint!.setColumnData("ARR_AGINGREPORT.FIXED_PERIODS","Y")
		callpoint!.setStatus("REFRESH")
	endif
endif
[[ARR_AGINGREPORT.AREC]]
cal_date=1
gosub set_date_seq
gosub calc_dates
[[ARR_AGINGREPORT.DAYS_IN_PER.AVAL]]
cal_date=1
gosub set_date_seq
gosub calc_dates
callpoint!.setStatus("REFRESH")
[[ARR_AGINGREPORT.REPORT_DATE.AVAL]]
cal_date=1
gosub set_date_seq
gosub calc_dates
callpoint!.setStatus("REFRESH")
[[ARR_AGINGREPORT.<CUSTOM>]]
set_date_seq:rem --- Set Sequence of Date Columns

rem	date_seq$=
rem :		pad("ARR_AGINGREPORT.AGEDATE_FUT_FROM",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_CUR_FROM",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_CUR_THRU",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_30_FROM",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_30_THRU",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_60_FROM",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_60_THRU",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_90_FROM",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_90_THRU",40)+
rem :		pad("ARR_AGINGREPORT.AGEDATE_120_THRU",40)

	return

calc_dates:rem --- Calculate Aging Dates

	fixed_periods$=callpoint!.getColumnData("ARR_AGINGREPORT.FIXED_PERIODS")
	days_in_per=num(callpoint!.getColumnData("ARR_AGINGREPORT.DAYS_IN_PER"))
	if days_in_per=0 days_in_per=30
	start_date$=callpoint!.getColumnData("ARR_AGINGREPORT.REPORT_DATE")

	switch cal_date
		case 1
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_FUT_FROM",start_date$)
		case 2
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_FUT_FROM")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-1:"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_CUR_THRU",new_date$)
		case 3
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_CUR_THRU")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-(days_in_per-1):"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_CUR_FROM",new_date$)
		case 4
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_CUR_FROM")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-1:"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_30_THRU",new_date$)
		case 5
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_30_THRU")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-(days_in_per-1):"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_30_FROM",new_date$)
		case 6
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_30_FROM")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-1:"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_60_THRU",new_date$)
		case 7
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_60_THRU")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-(days_in_per-1):"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_60_FROM",new_date$)
		case 8
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_60_FROM")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-1:"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_90_THRU",new_date$)
		case 9
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_90_THRU")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-(days_in_per-1):"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_90_FROM",new_date$)
		case 10
			prev_date$=callpoint!.getColumnData("ARR_AGINGREPORT.AGEDATE_90_FROM")
			if fixed_periods$="Y"
				new_date$=date(jul(prev_date$,"%Yd%Mz%Dz")-1:"%Yd%Mz%Dz")
			endif
			callpoint!.setColumnData("ARR_AGINGREPORT.AGEDATE_120_THRU",new_date$)
		break
	swend

	return
