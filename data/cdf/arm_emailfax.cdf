[[ARM_EMAILFAX.EMAIL_CC.AVAL]]
	mail$=callpoint!.getColumnData("ARM_EMAILFAX.EMAIL_CC")
	gosub multi_email
	if not_valid
		callpoint!.setMessage("INVALID_EMAIL")
		callpoint!.setStatus("ABORT")
	endif
[[ARM_EMAILFAX.EMAIL_TO.AVAL]]
	mail$=callpoint!.getColumnData("ARM_EMAILFAX.EMAIL_TO")
	gosub multi_email
	if not_valid
		callpoint!.setMessage("INVALID_EMAIL")
		callpoint!.setStatus("ABORT")
	endif
[[ARM_EMAILFAX.<CUSTOM>]]
multi_email: rem --- Validate format of email address(es)
	simple_email$="[-_.A-Za-z0-9]+@[-_A-Za-z0-9\.]+"
rem	dummy=mask("","^(""[^""]+"" *<"+simple_email$+">|"+simple_email+")$")
	dummy=mask("",simple_email$)
	not_valid=0
	if cvs(mail$,2)<>"" 
		save_mail$=mail$
		temp_mail$=mail$
		while temp_mail$<>""
			pp=pos(","=temp_mail$)
			if pp=0
				mail$=temp_mail$
				temp_mail$=""
			else
				mail$=temp_mail$(1,pp-1)
				temp_mail$=temp_mail$(pp+1)
			endif
			gosub valid_email
			if not_valid break
		wend
		mail$=save_mail$
	endif
return

valid_email: rem --- Validate format of one email address only
	not_valid=0
	if mask(cvs(mail$,1+2))<>1
		not_valid=1
	endif
return
