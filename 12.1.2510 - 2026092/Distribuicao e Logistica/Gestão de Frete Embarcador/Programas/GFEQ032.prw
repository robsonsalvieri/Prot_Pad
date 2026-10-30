#Include "protheus.ch"
#Include 'quicksearch.ch'

QSSTRUCT GFEQ032 DESCRIPTION 'Ocorrências' MODULE 78 

QSMETHOD INIT QSSTRUCT GFEQ032
	QSTABLE "GWD" JOIN "GU5" ON "GU5_CDTIPO = GWD_CDTIPO"
	QSTABLE "GWD" JOIN "GU3" ON "GWD_CDTRP = GU3_CDEMIT"
	
	//-- campos do SX3 e indices do SIX 
	QSPARENTFIELD 'GWD_NROCO' INDEX ORDER 1
	QSPARENTFIELD 'GU3_NMEMIT' INDEX ORDER 2 LABEL 'Transportador'
	
	//-- campos do SX3
	QSFIELD 'GWD_NROCO'
	QSFIELD 'GWD_DTOCOR'
	QSFIELD 'GWD_DSOCOR'
	QSFIELD 'GU3_NMEMIT' LABEL 'Transportador'
	
	//-- acoes do menudef, MVC ou qualquer rotina
	QSACTION MENUDEF "GFEC032" OPERATION 2 LABEL "Visualizar"
	dbSelectArea("GU5")
	GU5->(dbSetOrder(1))
	GU5->(dbGoTop())
	
	dbSelectArea("GWD")
	GWD->(dbSetOrder(2))
	
	While !GU5->(Eof())
		If GU5->GU5_SIT == "1"
			If GWD->(dbSeek(xFilial("GWD") + GU5->GU5_CDTIPO))
				QSFILTER AllTrim(GU5->GU5_DESC)	WHERE "GWD_CDTIPO = '" + GU5->GU5_CDTIPO + "' AND GWD_SIT = '1'"
			EndIf
		EndIf
		GU5->(dbSkip())
	EndDo
Return