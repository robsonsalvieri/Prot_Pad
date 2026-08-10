#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"

#DEFINE EMPRESA 1
#DEFINE UNIDADE 2
#DEFINE FIL 3

Static _cBd := ""
Static _nTamIDNat := 0
Static __lV3UPerApu := nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFQRY40XX()

@author Denis Souza
@since 20/08/2019
@version 1.0
@Return

/*/
//-------------------------------------------------------------------
Function TAFQRY40XX( cPerApu, cReg, aFil, aInfEUF, cCPF, cCNPJC1H, l4010, cCodPar, cNIF, lReinf212, lApuSTri)

Local aAlsRet   as character
Default cPerApu     :=  ''
Default cReg        :=  ''
Default aFil        :=  {}
Default aInfEUF     :=  {}
Default cCPF        :=  ''
Default cCNPJC1H    :=  ''
Default l4010       :=  .t.
Default cCodPar     :=  ''
Default cNIF     	:=  ''
Default lReinf212	:= .F.
Default lApuSTri    := .F.

aAlsRet :=  ''
if !empty(cPerApu) .and. !empty(cReg) 
	aAlsRet := QRY40XX( cPerApu, cReg, aFil, aInfEUF, cCPF, cCNPJC1H, l4010, cCodPar, cNIF, lReinf212, lApuSTri )
endif

Return aAlsRet

//-------------------------------------------------------------------
/*/{Protheus.doc} QRY40XX()

@author Denis Souza / Jose Mauro
@since 20/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function QRY40XX( cPerApu, cReg, aFil, aInfEUF, cCPF, cCNPJC1H, l4010, cCodPar, cNIF, lReinf212, lApuSTri )

	Local cAliasApr As	Character

	Local cSelect	As	Character
	Local cSelect2	As	Character
	Local cSelect3	As	Character
	Local cSelect4	As  Character

	Local cWhere	As	Character	
	Local cWhere2	As	Character
	Local cWhere3	As	Character
	Local cWhere4	As 	Character

	Local cCmpQry	As 	Character
	Local cFiliais	As  Character
	Local cCompC1H  As  Character	
	Local cCompV3X  As  Character	
	Local cQryFat	As	Character
	Local cQryNot	As	character
	Local aRegApur	As  Array
	Local cDataIni	As Character 
	Local cDataFim	As Character
	Local cDtConta	As Character
	Local cOrderBy  As Character 
	Local cTrib		As Character
	Local cSel4020  As Character
	Local cTabTemp  As character
	Local oTabTemp  As object
	Local cQryV3O	As Character
	Local lApuC20   As Logical

	//-----FATURA
	Local cFromLEM	As Character //Fatura
	Local cIJoiC1H	As Character //Participantes
	Local cLJoi1V3R	As Character //Dependente
	Local cIJoiV3S	As Character //Nat.Rend
	Local cIJoiV47  As Character //Trib
	Local cLJoiV3X  As Character //FCI
	Local cLJoinV4L	As Character //Detal. Deducoes
	Local cLJoinV4M	As Character //Detal. Isencoes
	Local cLJoinT9E	As Character //Ind.Suspensao Processo
    Local cLJoinT51	As Character //Parcelas Fatura
	Local cLJoinV3U	As Character //Pgto Parcela
	Local cLJoinV3V	As Character //Trib. Sobre Pgto x Nat Rend.
	Local cLJoinV4I	As Character //Deducao Pgto
	Local cLJoinV4J As Character //Isencao Pgto
	Local cLJoinV4H	As Character //Suspensao Pgto
	Local cLJoinV3X	As Character //Cad SCP
	Local cLJoinV3Y	As Character //Particp.SCP
	Local cLJoinV4F	As Character //Despesas Processuais RRA
	Local cLJoinV4G	As Character //Detal. Das Despesas
	Local cLJoinC1G	As Character //Processos Ref
	Local cLJoinT5L As Character //Informacoes de Suspensao
	Local cLJoinV3Z	As Character //Advogado
	Local cIJoi1V3O As Character //Natureza
	Local cLJoi1C08 As Character //Pais
	Local cLJoi1CUB As Character //Relacao Fonte Pagadora
	Local cLJoi1T9A As Character //Tribut. rend. benef. no Ext.
	//------NOTA
	Local cFromC20	As Character //Cab Nota
	Local cIJoi2C1H	As Character //Participantes
	Local cLJoi2V3R	As Character //Dependente
	Local cLJoinC30	As Character //Item Nota
	Local cIJoiC35	As Character //Tributo x Item Nota
	Local cLJoinV4C	As Character //Deducao
	Local cLJoinV4D	As Character //Isencao
	Local cLJoinT9Q	As Character //Susp. Processo Adm/Judicial
	Local cLJoi2C1G	As Character //Processos Ref
	Local cLJoi2T5L As Character //Informacoes de Suspensao
	Local cIJoi2V3O As Character //Natureza
	Local cLJoi2C08 As Character //Pais
	Local cLJoi2CUB As Character //Relacao Fonte Pagadora
	Local cLJoi2T9A As Character //Tribut. rend. benef. no Ext.
	//------PGTO FINANCEIRO
	Local cFromV3U	As Character //Pgto
	Local cFromV4B  As Character //PLS
	Local cIJoiV3V	As Character //Tributo
	Local cLJoiV46  As Character //Natureza
	Local cLJoi3V3X As Character //FCI
	Local cIJoi3C1H	As Character //Particip
	Local cIJoi4C1H As Character //Particip
	Local cIJoi3V3O As Character //Natureza
	Local cLJoi3C08 As Character //Pais
	Local cLJoi3CUB As Character //Relacao Fonte Pagadora
	Local cLJoi3T9A As Character //Tribut. rend. benef. no Ext.
	Local cQryPgto	As Character
	Local cDtDivIni As Character // data inicial para filtro dos dividedendos
	Local cGroupPls As Character
	Local nTamPrId40 As Numeric

	Default lApuSTri    := .F.
	Default cPerApu  	:= ""
	Default cReg 	 	:= ""
	Default aFil 	 	:= {}
	Default aInfEUF		:= {}
	Default cCNPJC1H 	:= ''
	Default cCPF     	:= ''
	Default l4010		:= .T.
	Default cCodPar    	:= ''
	Default cNIF    	:= ''
	Default lReinf212	:= .F.

	IniVarStat()

	aRegApur  := {}			
	cAliasApr := GetNextAlias()
	cSelect	  := ""
	cSelect2  := ""
	cSelect3  := ""
	cSelect4  := ""
	cWhere	  := ""	
	cWhere2	  := ""
	cWhere3   := ""
	cWhere4	  := ""
	cCmpQry	  := ""	
	cTrib     := ""	
	cTabTemp  := ''
	cCompC1H  := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))	
	cCompV3X  := Upper(AllTrim(FWModeAccess("V3X",1)+FWModeAccess("V3X",2)+FWModeAccess("V3X",3)))	
	cFiliais  := RetFil(aFil)
	cDtDivIni := DtoS( DtIniLucDiv(cPerApu) )
	cPerApu   := SubSTR(cPerApu,3,4) + SubSTR(cPerApu,1,2)
	cDataIni  := cPerApu + "01" //ex: 20220201
	cDataFim  := DtoS( LastDay( StoD( cDataIni ) ) )
	cDtConta  := SuperGetMv('MV_TAFDT40',.F.,'2')
	lApuC20	  := SuperGetMv('MV_TAFAC20',.F.,.F.)
	oTabTemp  := Nil
	nTamPrId40 := TamSX3("V3U_PRID40")[1]

	If lApuSTri .or. l4010
		cQryV3O := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.V3O_TRIB <> '8' AND V3O.D_E_L_E_T_ = ' ')
	Else
		cQryV3O   := " (SELECT V3O.V3O_ID FROM " + RetSqlName("V3O") + " V3O WHERE V3O.D_E_L_E_T_ = ' ' AND V3O.V3O_CODIGO LIKE '20%') "
	EndIf

	//---------FATURA
	cFromLEM  := ""	
	cIJoiC1H  := ""
	cLJoi1V3R := ""	
	cIJoiV3S  := ""
	cIJoiV47  := ""
	cLJoiV3X  := ""
	cLJoinV4L := ""
	cLJoinV4M := ""
	cLJoinT9E := ""
	cLJoinT51 := ""
	cLJoinV3U := ""
	cLJoinV3V := ""
	cLJoinV4I := ""
	cLJoinV4J := ""
	cLJoinV4H := ""
	cLJoinV3X := ""
	cLJoinV3Y := ""
	cLJoinV4F := ""
	cLJoinV4G := ""
	cLJoinC1G := ""	
	cLJoinT5L := ""			
	cLJoinV3Z := ""	
	cIJoi1V3O := ""
	cLJoi1C08 := ""
	cLJoi1CUB := ""
	cLJoi1T9A := ""
	cQryFat	  := ""

	//---------NOTA
	cFromC20  := ""	
	cIJoi2C1H := ""
	cLJoi2V3R := ""
	cLJoinC30 := ""	
	cIJoiC35  := ""	
	cLJoinV4C := ""	
	cLJoinV4D := ""	
	cLJoinT9Q := ""
	cLJoi2C1G := ""
	cLJoi2T5L := ""
	cIJoi2V3O := ""
	cLJoi2C08 := ""
	cLJoi2CUB := ""
	cLJoi2T9A := ""
	cQryNot	  := ""

	//------PGTO FIN
	cFromV3U  := ""
	cIJoiV3V  := ""
	cLJoiV46  := ""
	cLJoi3V3X := ""
	cIJoi3C1H := ""
	cIJoi3V3O := ""
	cLJoi3C08 := ""
	cLJoi3CUB := ""
	cLJoi3T9A := ""
	cWhere3	  := ""
	cQryPgto  := ""
	cOrderBy  := ""

	//------PLS FIN
	cFromV4B  := ""
	cIJoi4C1H := ""
	cGroupPls := ""

	if !l4010 //Coluna SUMBRT, se existir pagamento no mesmo dia que houve fatura NAO soma bruto.

		TafJoinFat(@cFromLEM,@cIJoiC1H,l4010,cCompC1H,aInfEUF,cCNPJC1H,cCPF,@cIJoiV3S,@cIJoiV47,@cLJoiV3X,cCompV3X,@cIJoi1V3O,@cLJoi1C08,@cLJoi1CUB,@cLJoi1T9A,@cWhere,cFiliais,cDataIni,cDataFim,cCodPar,cNIF, cQryV3O,,lApuSTri)

		cTabTemp := QryPagto(cFromLEM,cIJoiC1H,cIJoiV3S,cIJoiV47,cLJoiV3X,cIJoi1V3O,cLJoi1C08,cLJoi1CUB,cLJoi1T9A,cWhere,@oTabTemp)
		
		cSel4020 := " CASE "
		cSel4020 += " 	WHEN TAB1.ROTINA = 'PGT'"
		cSel4020 += " 		AND EXISTS ( "
		cSel4020 += " 					SELECT NRNTLEM "
		cSel4020 += " 					FROM " + cTabTemp + " TMP "
		cSel4020 += " 					WHERE TMP.FILIAL = TAB1.FILIAL "
		cSel4020 += " 						AND TMP.SERIE = TAB1.SERV3U "
		cSel4020 += " 						AND TMP.NUMDOCTO = TAB1.NRV3U "
		cSel4020 += " 						AND TMP.C1H_ID = TAB1.C1H_ID "
		cSel4020 += " 						AND TMP.DTEMISSA = TAB1.DTPV3U "
		cSel4020 += " 					) "
		cSel4020 += " 	THEN 'N' "
		cSel4020 += " 	ELSE 'S' "
		cSel4020 += " END SUMBRT, "
		cSel4020 += " TAB1.* "

		cSel4020 := "%" + cSel4020 + "%"
	endif

	//-------------------------------------------- 
	// 					FATURA
	//--------------------------------------------
	cSelect := " 'FAT' 			ROTINA,   " //01
	cSelect += " LEM.R_E_C_N_O_ RECNO, 	  " //02
	cSelect += " LEM.LEM_ID 	LEMID, 	  " //03
	cSelect += " LEM.LEM_FILIAL FILIAL,   " //04
	cSelect += " LEM.LEM_DOCORI NRNTLEM,  " //05
	cSelect += " LEM.LEM_NUMERO NUMDOCTO, " //06
	cSelect += " LEM.LEM_PREFIX SERIE, 	  " //07
	cSelect += " '' 			CHVNF,    " //08
	cSelect += " ''        	    V3UID,    " //09
	cSelect += " LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+" DTEMISSA," //10
	cSelect += " '' 			DTPV3U,	  " //11
	cSelect += " '' 			NRV3U,    " //12
	cSelect += " '' 			SERV3U,   " //13
	cSelect += " '' 			LEMDOCORI," //14
	cSelect += " C1H.C1H_FILIAL FILC1H,   " //15 
	cSelect += " C1H.C1H_ID 	C1H_ID,   " //16
	cSelect += " C1H.C1H_BAIEXT BAIEXT,	  " //17
	cSelect += " C1H.C1H_CDPOSE CDPOSE,	  " //18
	cSelect += " C1H.C1H_PAISEX CODPAI,	  " //19	
	cSelect += " C1H.C1H_COMEXT COMEXT,	  " //20
	cSelect += " C1H.C1H_CPF 	CPF, 	  " //21
	cSelect += " C1H.C1H_CNPJ 	CNPJ,     " //22
	cSelect += " C1H.C1H_ISEIMU ISENT, 	  " //23
	cSelect += " C1H.C1H_RELFON RELFONT,  " //24
	cSelect += " C1H.C1H_DTMOLE DTMOLE,   " //25
	cSelect += " C1H.C1H_NOME 	NOME,	  " //26
	cSelect += " LEM.LEM_FCISCP INDFCISCP," //27
	cSelect += " V3S.V3S_VALOR  VLBRUT,   " //29
	cSelect += " V3S.V3S_IFCISC	IDSCP, 	  " //30
	cSelect += " V3S.V3S_IDPROC IDRRAPJD, " //31
	cSelect += " cast(" + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(V47.V47_IDTRIB, ' ') as char(" + cValToChar( GetSX3Cache('V47_IDTRIB', 'X3_TAMANHO') ) + ") ) IDTRIB2," //32
	cSelect += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(V47.V47_BASECA, 0) BASECA," //33
	cSelect += " V3S.V3S_DECTER DECTER,   " //34
	cSelect += " V3S.V3S_IDNATR IDNATR,   " //35
	cSelect += " V3S.V3S_COMPFP COMPFP,   " //36
	cSelect += " C1H.C1H_INDNIF INDNIF,   " //37
	cSelect += " C1H.C1H_NIF NIF,         " //38
	cSelect += " C1H.C1H_IDTRIB IDTRIB,   " //39
	If l4010
		cSelect += " ' '        TRIBNAT,   " //40
		cSelect += " ' '        CCNATRE,   " //41
	EndIf
	if !l4010
		cSelect += " V3O.V3O_TRIB TRIBNAT,     " //36
		cSelect += " V3O.V3O_CODIGO CCNATRE,   " //37
		cSelect += " V3O.V3O_DESCR CDNATRE,    " //38
		cSelect += " C1H.C1H_LOGEXT LOGEXT,    " //42
		cSelect += " C1H.C1H_NUMEXT NUMEXT,    " //43
		cSelect += " C1H.C1H_NMCEXT NMCEXT,    " //44
		cSelect += " C1H.C1H_ESTEXT ESTEXT,    " //45
		cSelect += " C1H.C1H_TELEXT TELEXT,    " //46
		cSelect += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(C08.C08_CREINF, ' ') PAISEXT, "//47
		cSelect += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(CUB.CUB_CODIGO, ' ') CRELPGT, "//48
		cSelect += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(CUB.CUB_DESCRI, ' ') CDRELPG, "//49
		cSelect += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(T9A.T9A_CREINF, ' ') CCTRIB, " //50
		cSelect += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(T9A.T9A_DESCRI, ' ') CDTRIB, " //51
	endif
	cSelect += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(V47.V47_VLTRIB, 0) VLTRIB, " //52
	cSelect += " '' 			CHVNFC30, " //53
	cSelect += " '' 			NUMITC30, " //54
	cSelect += " '' 			CODITC30, " //55
	cSelect += " '' 			NUMITE,   " //56
	cSelect += " '' 			CODITE,   " //57
	cSelect += " C1H.C1H_CODPAR CODPAR 	  " //58 
	If lReinf212
		cSelect += ", LEM.LEM_DTESCO DTESCO	  " //59 
	EndIf
	cSelect += ", LEM.LEM_OBSERV OBSERV   " //60
	//-------------------------------------------- 
	// 					JOIN FATURAS
	//--------------------------------------------
	cFromLEM  := ''
	cIJoiC1H  := ''
	cIJoiV3S  := ''
	cIJoiV47  := ''
	cLJoiV3X  := ''
	cIJoi1V3O := ''
	cLJoi1C08 := ''
	cLJoi1CUB := ''
	cLJoi1T9A := ''
	cWhere    := ''

	TafJoinFat(@cFromLEM,@cIJoiC1H,l4010,cCompC1H,aInfEUF,cCNPJC1H,cCPF,@cIJoiV3S,@cIJoiV47,@cLJoiV3X,cCompV3X,@cIJoi1V3O,@cLJoi1C08,@cLJoi1CUB,@cLJoi1T9A,@cWhere,cFiliais,cDataIni,cDataFim,cCodPar,cNIF,cQryV3O,cDtConta,lApuSTri)

    cSelect	  := "%" + cSelect   + "%"
    cFromLEM  := "%" + cFromLEM  + "%"
	cIJoiC1H  := "%" + cIJoiC1H  + "%" //Participantes
	cIJoiV3S  := "%" + cIJoiV3S  + "%" //Nat.Rend
	cIJoiV47  := "%" + cIJoiV47  + "%" //Tributo
	cLJoiV3X  := "%" + cLJoiV3X  + "%" //FCI
	cIJoi1V3O := "%" + cIJoi1V3O + "%" //Natureza
	cLJoi1C08 := "%" + cLJoi1C08 + "%" //Pais
	cLJoi1CUB := "%" + cLJoi1CUB + "%" //Relacao Fonte Pagadora
	cLJoi1T9A := "%" + cLJoi1T9A + "%" //Tribut. rend. benef. no Ext.
	cWhere 	  := "%" + cWhere    + "%"

	If !lApuC20 .or. l4010

		//-------------------------------------------- 
		// 					NOTA
		//--------------------------------------------
		cSelect2 := " 'NFS' 		 ROTINA,    " //01
		cSelect2 += " C20.R_E_C_N_O_ RECNO, 	" //02
		cSelect2 += " '' 			 LEMID,   	" //03
		cSelect2 += " C20.C20_FILIAL FILIAL,    " //04
		cSelect2 += " '' 			 NRNTLEM,   " //05
		cSelect2 += " C20.C20_NUMDOC NUMDOCTO,  " //06
		cSelect2 += " C20.C20_SERIE  SERIE, 	" //07
		cSelect2 += " C20.C20_CHVNF  CHVNF, 	" //08
		cSelect2 += " ''        	 V3UID,     " //09
		cSelect2 += " C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+" DTEMISSA," //10
		cSelect2 += " '' 			 DTPV3U,    " //11
		cSelect2 += " '' 			 NRV3U,	    " //12
		cSelect2 += " '' 			 SERV3U,    " //13
		cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(LEM.LEM_DOCORI, ' ') LEMDOCORI, " //14
		cSelect2 += " C1H.C1H_FILIAL FILC1H,    " //15
		cSelect2 += " C1H.C1H_ID 	 C1H_ID,    " //16
		cSelect2 += " C1H.C1H_BAIEXT BAIEXT,    " //17
		cSelect2 += " C1H.C1H_CDPOSE CDPOSE,    " //18
		cSelect2 += " C1H.C1H_PAISEX CODPAI,    " //19
		cSelect2 += " C1H.C1H_COMEXT COMEXT,    " //20
		cSelect2 += " C1H.C1H_CPF 	 CPF, 	    " //21
		cSelect2 += " C1H.C1H_CNPJ 	 CNPJ, 	    " //22
		cSelect2 += " C1H.C1H_ISEIMU ISENT, 	" //23
		cSelect2 += " C1H.C1H_RELFON RELFONT,   " //24
		cSelect2 += " C1H.C1H_DTMOLE DTMOLE,    " //25
		cSelect2 += " C1H.C1H_NOME 	 NOME, 	    " //26
		cSelect2 += " C20.C20_FCISCP INDFCISCP, " //27
		cSelect2 += " C30.C30_TOTAL  VLBRUT,    " //29
		cSelect2 += " C30.C30_IFCISC IDSCP, 	" //30
		cSelect2 += " '' 			 IDRRAPJD,  " //31
		cSelect2 += "cast(" + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(C35.C35_CODTRI, ' ') as char(" + cValToChar( GetSX3Cache('C35_CODTRI', 'X3_TAMANHO') ) + ") ) IDTRIB2, " //32
		cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(C35.C35_BASE, 0) BASECA, " //33
		cSelect2 += " C30.C30_DECTER DECTER,    " //34
		cSelect2 += " C30.C30_CNATRE IDNATR,    " //35
		cSelect2 += " C30.C30_COMPFP COMPFP,    " //36
		cSelect2 += " C1H.C1H_INDNIF INDNIF,    " //37
		cSelect2 += " C1H.C1H_NIF NIF,          " //38
		cSelect2 += " C1H.C1H_IDTRIB IDTRIB,    " //39
		if l4010
			cSelect2 += " ' '       TRIBNAT,    " //40
			cSelect2 += " ' '       CCNATRE,    " //41
		endif
		if !l4010			
			cSelect2 += " V3O.V3O_TRIB TRIBNAT,     " //36
			cSelect2 += " V3O.V3O_CODIGO CCNATRE,   " //37
			cSelect2 += " V3O.V3O_DESCR CDNATRE,    " //38
			cSelect2 += " C1H.C1H_LOGEXT LOGEXT,    " //42
			cSelect2 += " C1H.C1H_NUMEXT NUMEXT,    " //43
			cSelect2 += " C1H.C1H_NMCEXT NMCEXT,    " //44
			cSelect2 += " C1H.C1H_ESTEXT ESTEXT,    " //45
			cSelect2 += " C1H.C1H_TELEXT TELEXT,    " //46
			cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(C08.C08_CREINF, ' ') PAISEXT, " //47
			cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(CUB.CUB_CODIGO, ' ') CRELPGT, " //48
			cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(CUB.CUB_DESCRI, ' ') CDRELPG, " //49
			cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(T9A.T9A_CREINF, ' ') CCTRIB, "  //50
			cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(T9A.T9A_DESCRI, ' ') CDTRIB, "  //51
		endif
		cSelect2 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(C35.C35_VALOR, 0)  VLTRIB, " //52
		cSelect2 += " C30.C30_CHVNF  CHVNFC30,  " //53
		cSelect2 += " C30.C30_NUMITE NUMITC30,  " //54
		cSelect2 += " C30.C30_CODITE CODITC30,  " //55
		cSelect2 += " C35.C35_NUMITE NUMITE,    " //56
		cSelect2 += " C35.C35_CODITE CODITE,    " //57
		cSelect2 += " C1H.C1H_CODPAR CODPAR     " //58
		If lReinf212
			cSelect2 += ", C20.C20_DTESCO DTESCO    " //59
		EndIf	
		cSelect2 += ", ' '			  OBSERV    " //60 - CAMPO MEMO DEIXAR POR ULTIMO

		//-------------------------------------------- 
		// 					JOIN NOTAS
		//--------------------------------------------	
		cFromC20 := RetSqlName("C20") + " C20 "

		//Participantes
    	cIJoi2C1H := RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR AND C1H.D_E_L_E_T_ = ' ' "
		if l4010
			cIJoi2C1H += " AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1')  OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) "
		else
			cIJoi2C1H += " AND ((C1H.C1H_CNPJ <> ' ' AND C1H.C1H_PPES = '2')  OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ') ) "		
		endif
		If cCompC1H == "EEE"
			cIJoi2C1H += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
		Else
			If cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
				cIJoi2C1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " 
			ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
				cIJoi2C1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL, 1," + cValToChar(aInfEUF[1]) + ") "
			EndIf
		EndIf
		if !empty(cCNPJC1H)
			cIJoi2C1H += " AND C1H.C1H_CNPJ IN (" + cCNPJC1H + ") "
		elseif !empty(cCPF)
			cIJoi2C1H += " AND C1H.C1H_CPF IN (" + cCPF + ") "	
		elseIf !empty(cNif)	
			cIJoi2C1H += " AND C1H.C1H_NIF IN (" + cNif + ") "
		elseIf !empty(cCodPar)	
			cIJoi2C1H += " AND C1H.C1H_CODPAR IN (" + cCodPar + ") "
		endif

		//Item Nota
    	cIJoiC30 := RetSqlName("C30") + " C30 ON C30.C30_FILIAL = C20.C20_FILIAL AND C30.C30_CHVNF = C20.C20_CHVNF AND C30.D_E_L_E_T_ = ' ' "
		cIJoiC30 += "AND C30.C30_CNATRE <> '" + Space(_nTamIDNat) + "' " 

		//Tributo do Item
		cIJoiC35 := RetSqlName("C35") + " C35 ON C35.C35_FILIAL = C30.C30_FILIAL AND C35.C35_CHVNF = C30.C30_CHVNF "
		cIJoiC35 += " AND C35.C35_NUMITE = C30.C30_NUMITE AND C35.C35_CODITE = C30.C30_CODITE "
		cIJoiC35 += " AND C35.C35_CODTRI = '000012' " //IR Emissao
		cIJoiC35 += " AND C35.D_E_L_E_T_ = ' ' "

		//Fatura
		cLJoiLEM := RetSqlName("LEM") + " LEM ON LEM.LEM_FILIAL = C20.C20_FILIAL AND LEM.LEM_DOCORI = C20.C20_CHVNF AND LEM.D_E_L_E_T_ = ' ' "

		//Natureza
		cIJoi2V3O := RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' AND V3O.V3O_ID = C30.C30_CNATRE AND V3O.D_E_L_E_T_ = ' ' "

		//Pais
		cLJoi2C08 := RetSqlName("C08") + " C08 ON C08.C08_FILIAL = '" + xFilial("C08") + "' AND C08.C08_ID = C1H.C1H_PAISEX AND C08.D_E_L_E_T_ = ' ' "

		//Relacao Fonte Pagadora
		cLJoi2CUB := RetSqlName("CUB") + " CUB ON CUB.CUB_FILIAL = '" + xFilial("CUB") + "' AND CUB.CUB_ID = C1H.C1H_RELFON AND CUB.D_E_L_E_T_ = ' ' "

		//Tribut. rend. benef. no Ext.
		cLJoi2T9A := RetSqlName("T9A") + " T9A ON T9A.T9A_FILIAL = '" + xFilial("T9A") + "' AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ' ' "

		cWhere2 := " C20.C20_FILIAL IN (" + cFiliais + ") AND C20.D_E_L_E_T_ = ' ' AND C20.C20_INDOPE = '0' AND "
		cWhere2 += " C20."+ iif(cDtConta == '2','C20_DTDOC','C20_DTCONT')+" BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND ""
		cWhere2 += " LEM.LEM_DOCORI IS NULL "

		If lApuSTri
			cWhere2 += " AND C30.C30_CNATRE IN " + cQryV3O
		Else
			If l4010
				cWhere2 += " AND C35.C35_CODTRI IS NOT NULL "
			Else
				cWhere2 += " AND (C35.C35_BASE > 0 OR (C35.C35_CODTRI IS NULL AND C30.C30_CNATRE IN " + cQryV3O + " ))"
			Endif
		EndIf	

		cSelect2  := "%" + cSelect2  + "%"
    	cFromC20  := "%" + cFromC20  + "%"
		cIJoi2C1H := "%" + cIJoi2C1H + "%" //Participante
		cIJoiC30  := "%" + cIJoiC30  + "%" //Item Nota
		cIJoiC35  := "%" + cIJoiC35  + "%" //Tributo x Item Nota
		cLJoiLEM  := "%" + cLJoiLEM  + "%" //Fatura
		cIJoi2V3O := "%" + cIJoi2V3O + "%" //Natureza
		cLJoi2C08 := "%" + cLJoi2C08 + "%" //Pais
		cLJoi2CUB := "%" + cLJoi2CUB + "%" //Relacao Fonte Pagadora
		cLJoi2T9A := "%" + cLJoi2T9A + "%" //Tribut. rend. benef. no Ext.
		cWhere2   := "%" + cWhere2   + "%"

	EndIf

	//-------------------------------------------- 
	//       PGT - PAGAMENTO FINANCEIRO
	//--------------------------------------------
	cSelect3 := " 'PGT' 			ROTINA,    " //01
	cSelect3 += " V3U.R_E_C_N_O_ 	RECNO,     " //02
	cSelect3 += " SUBSTRING(V3U.V3U_IDFTPC,1,36) LEMID, "
	cSelect3 += " V3U.V3U_FILIAL  	FILIAL,    " //04
	cSelect3 += " ''  				NRNTLEM,   " //05
	cSelect3 += " V3U.V3U_NUMERO  	NUMDOCTO,  " //06
	cSelect3 += " ''  				SERIE,     " //07
	cSelect3 += " '' 				CHVNF,     " //08
	cSelect3 += " V3U.V3U_ID        V3UID,     " //09
	cSelect3 += " V3U.V3U_DTEMIS 	DTEMISSA,  " //10
	cSelect3 += " V3U.V3U_DTPAGT 	DTPV3U,    " //11
	cSelect3 += " V3U.V3U_NUMERO 	NRV3U,     " //12
	cSelect3 += " V3U.V3U_SERIE  	SERV3U,    " //13
	cSelect3 += " '' 				LEMDOCORI, " //14
	cSelect3 += " C1H.C1H_FILIAL 	FILC1H,    " //15
	cSelect3 += " C1H.C1H_ID 	    C1H_ID,    " //16
	cSelect3 += " C1H.C1H_BAIEXT 	BAIEXT,    " //17
	cSelect3 += " C1H.C1H_CDPOSE 	CDPOSE,    " //18
	cSelect3 += " C1H.C1H_PAISEX 	CODPAI,    " //19
	cSelect3 += " C1H.C1H_COMEXT 	COMEXT,    " //20
	cSelect3 += " C1H.C1H_CPF 		CPF,  	   " //21
	cSelect3 += " C1H.C1H_CNPJ 		CNPJ,  	   " //22
	cSelect3 += " C1H.C1H_ISEIMU 	ISENT,     " //23
	cSelect3 += " C1H.C1H_RELFON 	RELFONT,   " //24
	cSelect3 += " C1H.C1H_DTMOLE 	DTMOLE,    " //25
	cSelect3 += " C1H.C1H_NOME 		NOME,  	   " //26
	cSelect3 += " V3U.V3U_FCISCP   	INDFCISCP, " //27
	cSelect3 += " V3V.V3V_VALOR 	VLBRUT,    " //29
	cSelect3 += " V3V.V3V_IFCISC    IDSCP,     " //30
	cSelect3 += " V3V.V3V_IDPROC	IDRRAPJD,  " //31
	cSelect3 += " cast(" + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(V46.V46_IDTRIB, ' ') as char(" + cValToChar( GetSX3Cache('V46_IDTRIB', 'X3_TAMANHO') ) + ") ) IDTRIB2, " //32
	cSelect3 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(V46.V46_BASE, 0) BASECA, " //33
	cSelect3 += " V3V.V3V_DECTER	DECTER,    " //34
	cSelect3 += " V3V.V3V_CNATRE 	IDNATR,    " //35
	cSelect3 += " V3V.V3V_COMPFP 	COMPFP,    " //36
	cSelect3 += " C1H.C1H_INDNIF INDNIF,    " //37
	cSelect3 += " C1H.C1H_NIF NIF,          " //38
	cSelect3 += " C1H.C1H_IDTRIB IDTRIB,    " //39
	cSelect3 += " V3O.V3O_TRIB TRIBNAT,     " //36
	cSelect3 += " V3O.V3O_CODIGO CCNATRE,   " //37

	if !l4010
		
		cSelect3 += " V3O.V3O_DESCR CDNATRE,    " //38
		cSelect3 += " C1H.C1H_LOGEXT LOGEXT,    " //42
		cSelect3 += " C1H.C1H_NUMEXT NUMEXT,    " //43
		cSelect3 += " C1H.C1H_NMCEXT NMCEXT,    " //44
		cSelect3 += " C1H.C1H_ESTEXT ESTEXT,    " //45
		cSelect3 += " C1H.C1H_TELEXT TELEXT,    " //46
		cSelect3 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(C08.C08_CREINF, ' ') PAISEXT, " //47
		cSelect3 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(CUB.CUB_CODIGO, ' ') CRELPGT, " //48
		cSelect3 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(CUB.CUB_DESCRI, ' ') CDRELPG, " //49
		cSelect3 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(T9A.T9A_CREINF, ' ') CCTRIB, "  //50
		cSelect3 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(T9A.T9A_DESCRI, ' ') CDTRIB, "  //51
	endif
	cSelect3 += " " + iif(!("INFORMIX" $ _cBd),"COALESCE","NVL") + "(V46.V46_VALOR, 0) VLTRIB," //52
	cSelect3 += " ''				CHVNFC30,  " //53
	cSelect3 += " ''				NUMITC30,  " //54
	cSelect3 += " ''				CODITC30,  " //55
	cSelect3 += " ''				NUMITE,    " //56
	cSelect3 += " ''				CODITE,    " //57
	cSelect3 += " C1H.C1H_CODPAR 	CODPAR     " //58
	If lReinf212
		cSelect3 += ", V3U.V3U_DTESCO 	DTESCO    " //59
	Endif
	cSelect3 += ", ' ' 				OBSERV    " 


	//Pagamento
	cFromV3U := RetSqlName("V3U") + " V3U "

	//Tributo do Pagamento
	cIJoiV3V := RetSqlName("V3V") + " V3V ON V3V.V3V_FILIAL = V3U.V3U_FILIAL AND V3V.V3V_ID = V3U.V3U_ID AND V3V.D_E_L_E_T_ = ' ' "
	cIJoiV3V += "AND V3V.V3V_CNATRE <> '" + Space(_nTamIDNat) + "' "

	cLJoiV46 := RetSqlName("V46") + " V46 ON V46.V46_FILIAL = V3V.V3V_FILIAL AND V46.V46_ID = V3V.V3V_ID AND V46.V46_IDNAT = V3V.V3V_CNATRE AND V46.D_E_L_E_T_ = ' ' "

	cLJoi3V3X := RetSqlName("V3X") + " V3X ON V3X.V3X_FILIAL = V3V.V3V_FILIAL AND V3X.V3X_ID = V3V.V3V_IFCISC AND V3X.D_E_L_E_T_ = ' ' "

	if l4010
		cLJoiV46 += " AND V46.V46_IDTRIB = '000028' " //IR BAIXA
	else
		cLJoiV46 += " AND V46.V46_IDTRIB IN ( "
		cLJoiV46 += " '000010', '000011', '000018', '000028','000029','000030' " //PIS/COFINS/CSLL/IR BAIXA
		cLJoiV46 += " ) "
	Endif

	//Participantes
    cIJoi3C1H := RetSqlName("C1H") + " C1H ON C1H.C1H_ID = V3U.V3U_IDPART AND C1H.D_E_L_E_T_ = ' ' "
	if l4010
		cIJoi3C1H += " AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1')  OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) "
	else
		cIJoi3C1H += " AND ((C1H.C1H_CNPJ <> ' ' AND C1H.C1H_PPES = '2')  OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ') ) "
	endif
	If cCompC1H == "EEE"
		cIJoi3C1H += "AND C1H.C1H_FILIAL = V3U.V3U_FILIAL "			
	ElseIf cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
		cIJoi3C1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") = SUBSTRING(V3U.V3U_FILIAL, 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " 
	ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
		cIJoi3C1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + ") = SUBSTRING(V3U.V3U_FILIAL, 1," + cValToChar(aInfEUF[1]) + ") "
	Else
		cIJoi3C1H += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "	
	EndIf
	if !empty(cCNPJC1H)
		cIJoi3C1H += " AND C1H.C1H_CNPJ IN (" + cCNPJC1H + ") "
	elseif !empty(cCPF)
		cIJoi3C1H += " AND C1H.C1H_CPF IN (" + cCPF + ") "
	elseIf !empty(cNif)	
		cIJoi3C1H += " AND C1H.C1H_NIF IN (" + cNif + ") "
	elseIf !empty(cCodPar)	
		cIJoi3C1H += " AND C1H.C1H_CODPAR IN (" + cCodPar + ") "
	endif

	//Natureza
	cIJoi3V3O := RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' AND V3O.V3O_ID = V3V.V3V_CNATRE AND V3O.D_E_L_E_T_ = ' ' "
	
	//Pais
	cLJoi3C08 := RetSqlName("C08") + " C08 ON C08.C08_FILIAL = '" + xFilial("C08") + "' AND C08.C08_ID = C1H.C1H_PAISEX AND C08.D_E_L_E_T_ = ' ' "

	//Relacao Fonte Pagadora
	cLJoi3CUB := RetSqlName("CUB") + " CUB ON CUB.CUB_FILIAL = '" + xFilial("CUB") + "' AND CUB.CUB_ID = C1H.C1H_RELFON AND CUB.D_E_L_E_T_ = ' ' "

	//Tribut. rend. benef. no Ext.
	cLJoi3T9A := RetSqlName("T9A") + " T9A ON T9A.T9A_FILIAL = '" + xFilial("T9A") + "' AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ' ' "

	cWhere3 := " V3U.V3U_FILIAL IN (" + cFiliais + ") AND V3U.D_E_L_E_T_ = ' ' AND "
	cWhere3 += " V3U.V3U_NATTIT = '0' AND "
	// para pagamentos no mês
	cWhere3 += " (( V3U.V3U_DTPAGT BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "
	
	If lApuSTri
		cWhere3 += " AND V3V.V3V_CNATRE IS NOT NULL "
		If __lV3UPerApu
			cWhere3 += " AND V3O.V3O_CODIGO <> '12001' " 
		EndIf
	Else
		If !l4010
			cWhere3 += " AND (V46.V46_BASE > 0 OR (V46.V46_IDTRIB IS NULL AND (V3O.V3O_CODIGO LIKE '20%' OR (V3O.V3O_TRIB = '8' "
			If __lV3UPerApu
				cWhere3 += " AND V3O.V3O_CODIGO <> '12001' " 
			EndIf
			cWhere3 += ")))) "
		Else
			cWhere3 += " AND (V46.V46_IDTRIB IS NOT NULL OR (V3O.V3O_TRIB = '8' "
			If __lV3UPerApu
				cWhere3 += " AND V3O.V3O_CODIGO <> '12001' "
			EndIf
			cWhere3 += ") ) "
		EndIf
	EndIf
	cWhere3 += " ) "
	If __lV3UPerApu
		// para pagamentos de dividendos nos meses anteriores
		cWhere3 += " OR ( V3U.V3U_DTPAGT BETWEEN '" + cDtDivIni + "' AND '" + cDataFim + "' "
		cWhere3 += " AND (( V3U.V3U_PRID40 = '" + Space(nTamPrId40) + "' "
	
		cWhere3 += " AND ( V3U.V3U_PERAPU = '" + Space(6) + "' OR V3U.V3U_PERAPU = '" + SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4)  + "')) " 
		cWhere3 += " OR ( V3U.V3U_PRID40 != '" + Space(nTamPrId40) + "' AND V3U.V3U_PERAPU = '" + SubSTR(cDataIni,5,2) + SubSTR(cDataIni,1,4)  + "' ) " 
	
		cWhere3 += " )) "		
		cWhere3 += " AND V3O.V3O_CODIGO = '12001' "		
	EndIf
	cWhere3 += " ) "	

	cSelect3  := "%" + cSelect3  + "%"
    cFromV3U  := "%" + cFromV3U  + "%"
	cIJoiV3V  := "%" + cIJoiV3V  + "%" //Tributo
	cLJoiV46  := "%" + cLJoiV46  + "%" //Natureza
	cLJoi3V3X := "%" + cLJoi3V3X + "%" //FCI
	cIJoi3C1H := "%" + cIJoi3C1H + "%" //Participante
	cIJoi3V3O := "%" + cIJoi3V3O + "%" //Natureza
	cLJoi3C08 := "%" + cLJoi3C08 + "%" //Pais
	cLJoi3CUB := "%" + cLJoi3CUB + "%" //Relacao Fonte Pagadora
	cLJoi3T9A := "%" + cLJoi3T9A + "%" //Tribut. rend. benef. no Ext.
	cWhere3   := "%" + cWhere3   + "%" // filtro pagamentos no periodo

	If l4010
		
		cSelect4 += " 'PLS'             ROTINA,	    "
		cSelect4 += " 0                 RECNO,   	"
		cSelect4 += " ' '               V4BID,   	"
		cSelect4 += " V4B.V4B_FILIAL    FILIAL,  	"
		cSelect4 += " '' 				NRNTLEM,  	"
		cSelect4 += " '' 				NUMDOCTO,	"
		cSelect4 += " '' 				SERIE,		"	
		cSelect4 += " '' 				CHVNF,		"
		cSelect4 += " '' 				V3UID,		"
		cSelect4 += " ''            	DTEMISSA,	"
		cSelect4 += " '' 				DTPV3U,		"
		cSelect4 += " ''			 	NRV3U,		"
		cSelect4 += " ''			 	SERV3U,		"
		cSelect4 += " '' 				LEMDOCORI, 	"
		cSelect4 += " C1H.C1H_FILIAL    FILC1H,  	"
		cSelect4 += " C1H.C1H_ID        C1H_ID,  	"
		cSelect4 += " C1H.C1H_BAIEXT    BAIEXT,  	"
		cSelect4 += " C1H.C1H_CDPOSE    CDPOSE,  	"
		cSelect4 += " C1H.C1H_PAISEX    CODPAI,  	"
		cSelect4 += " C1H.C1H_COMEXT    COMEXT,  	"
		cSelect4 += " C1H.C1H_CPF       CPF,     	"
		cSelect4 += " C1H.C1H_CNPJ      CNPJ,    	"
		cSelect4 += " C1H.C1H_ISEIMU    ISENT,   	"
		cSelect4 += " C1H.C1H_RELFON    RELFONT, 	"
		cSelect4 += " C1H.C1H_DTMOLE    DTMOLE,  	"
		cSelect4 += " C1H.C1H_NOME      NOME,		"
		cSelect4 += " ''				INDFCISCP,  "
		cSelect4 += " 0					VLBRUT,		"
		cSelect4 += " ''			 	IDSCP,		"
		cSelect4 += " ''			 	IDRRAPJD,	"
		cSelect4 += " ''			 	IDTRIB2,	"
		cSelect4 += " 0				    BASECA,		"
		cSelect4 += " ''			 	DECTER,		"
		cSelect4 += " ''			 	IDNATR,		"
		cSelect4 += " ''			 	COMPFP,		"
		cSelect4 += " C1H.C1H_INDNIF 	INDNIF,		"
		cSelect4 += " C1H.C1H_NIF 		NIF,		"
		cSelect4 += " C1H.C1H_IDTRIB 	IDTRIB,		"
		cSelect4 += " ''		 		TRIBNAT,	"
		cSelect4 += " ''			 	CCNATRE,	"
		cSelect4 += " 0					VLTRIB,	    "
		cSelect4 += " '' 				CHVNFC30,	"
		cSelect4 += " '' 				NUMITC30,	"
		cSelect4 += " '' 				CODITC30,	"
		cSelect4 += " '' 				NUMITE,		"
		cSelect4 += " '' 				CODITE,		"
		cSelect4 += " C1H.C1H_CODPAR 	CODPAR,		"
		If lReinf212
			cSelect4 += " ''			DTESCO,	    "
		Endif
		cSelect4 += " '' 				OBSERV		"
		cFromV4B := "  " + RetSqlName("V4B") + " V4B "
		cIJoi4C1H += " " + RetSqlName("C1H") + " C1H ON "
		cIJoi4C1H += TafJoinC1H( cCompC1H , aInfEUF, "V4B.V4B_FILIAL" )
		
		If !empty(cCPF)
			cIJoi4C1H += " AND C1H.C1H_CPF IN (" + cCPF + ") "	
		elseIf !empty(cNif)	
			cIJoi4C1H += " AND C1H.C1H_NIF IN (" + cNif + ") "
		elseIf !empty(cCodPar)	
			cIJoi4C1H += " AND C1H.C1H_CODPAR IN (" + cCodPar + ") "
		endif
		
		cIJoi4C1H += " AND C1H.C1H_ID = V4B.V4B_IDPART AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1') OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) AND C1H.D_E_L_E_T_ = ' ' "	
		cWhere4   += " V4B.V4B_FILIAL  IN (" + cFiliais + ") AND "
		cWhere4   += " V4B.V4B_DTPGTO BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND V4B.D_E_L_E_T_ = ' ' "
		
		cGroupPls += " V4B.V4B_FILIAL, C1H.C1H_FILIAL, C1H.C1H_ID, C1H.C1H_CPF,	C1H.C1H_NOME, C1H.C1H_INDNIF, C1H.C1H_NIF, C1H.C1H_IDTRIB, "
		cGroupPls += " C1H.C1H_CODPAR, C1H.C1H_BAIEXT, C1H.C1H_CDPOSE, C1H.C1H_PAISEX, C1H.C1H_COMEXT, C1H.C1H_CNPJ, C1H.C1H_ISEIMU, C1H.C1H_RELFON, C1H.C1H_DTMOLE  "

		cSelect4  := "%" + cSelect4  + "%"
		cFromV4B  := "%" + cFromV4B  + "%"
		cIJoi4C1H := "%" + cIJoi4C1H + "%"
		cWhere4   := "%" + cWhere4   + "%"
		cGroupPls := "%" + cGroupPls + "%"
	Endif
    
	if l4010
		cTrib := "('1','2','4','5')" //1=IR; 2=IR, CSLL, COFINS, PP e Agreg; 4=IR e CSLL; 5=IR,CSLL e Agreg;
		cWhereAll := " ( TAB1.IDNATR IN ( select distinct(V3O.V3O_ID) from " + RetSqlName("V3O") + " V3O where V3O.V3O_TRIB = '8' OR V3O.V3O_TRIB IN " + cTrib + " ) OR TAB1.ROTINA = 'PLS') "
	else //4020
		cTrib := "('1','2','3','4','5','6','7','8','9')" //1=IR; 2=IR, CSLL, COFINS, PP e Agreg; 3=COFINS e PP; 4=IR e CSLL; 5=IR,CSLL e Agreg; 6=CSLL; 7=CSSL,COFINS,PP e Agreg;
		cWhereAll := " TAB1.TRIBNAT IN " + cTrib + " "
	endif
	cWhereAll += " AND (TAB1.IDTRIB2 <> '" + Space(6) + "' OR TAB1.IDTRIB2 IS NOT NULL) "
	cWhereAll := "%" + cWhereAll + "%"

	if !empty(cCNPJC1H)
		cOrderBy += "%CNPJ,CODPAR,IDNATR,FILIAL,DTEMISSA,DTPV3U,ROTINA,NRNTLEM,CHVNF,NRV3U%"
	elseif !empty(cCPF)
		cOrderBy += "%ROTINA, FILIAL, CPF, LEMID, NUMDOCTO, SERIE, V3UID, RECNO, DTEMISSA%"
	elseIf !empty(cNif)
		if l4010	
			cOrderBy += "%ROTINA, FILIAL, NIF, LEMID, NUMDOCTO, SERIE, V3UID, RECNO, DTEMISSA%"
		else
			cOrderBy += "%NIF,CODPAR,IDNATR,FILIAL,DTEMISSA,DTPV3U,ROTINA,NRNTLEM,CHVNF,NRV3U%"	
		endIf
	elseIf !empty(cCodPar)
		if l4010	
			cOrderBy += "%ROTINA, FILIAL, CODPAR, LEMID, NUMDOCTO, SERIE, V3UID, RECNO, DTEMISSA%"
		else
			cOrderBy += "%CODPAR,IDNATR,FILIAL,DTEMISSA,DTPV3U,ROTINA,NRNTLEM,CHVNF,NRV3U%"
		endIf
	endif

	//------------------------------------------- 
	// 			QUERY FATURA + NOTA + PAGAMENTO + PLS
	//--------------------------------------------
	if l4010
		BeginSql Alias cAliasApr
			COLUMN DTMOLE   AS DATE
			COLUMN DTEMISSA AS DATE
			COLUMN DTPV3U   AS DATE
			
			SELECT * FROM (
				SELECT DISTINCT %Exp:cSelect%
				FROM 		%Exp:cFromLEM% //Fatura
				INNER JOIN 	%Exp:cIJoiC1H% //Participantes
				INNER JOIN	%Exp:cIJoiV3S% //Nat.Rend
				LEFT JOIN   %Exp:cIJoiV47% //Trib
				LEFT JOIN   %Exp:cLJoiV3X% //FCI
				WHERE		%Exp:cWhere%

				union

				SELECT	DISTINCT %Exp:cSelect2%
				FROM		%Exp:cFromC20%	//Cab Nota
				INNER JOIN	%Exp:cIJoi2C1H%	//Participantes
				INNER JOIN	%Exp:cIJoiC30%	//Item Nota 
				LEFT JOIN	%Exp:cIJoiC35%	//Tributo x Item Nota
				LEFT JOIN   %Exp:cLJoiLEM% 	//Fatura
				WHERE		%Exp:cWhere2%

				union

				SELECT	DISTINCT %Exp:cSelect3%
				FROM		%Exp:cFromV3U%	//Pgto
				INNER JOIN	%Exp:cIJoiV3V% 	//Natureza
				INNER JOIN  %Exp:cIJoi3V3O% //Tabela de Natureza
				INNER JOIN	%Exp:cIJoi3C1H%	//Participantes
				LEFT JOIN   %Exp:cLJoiV46%	//Tributos
				LEFT JOIN   %Exp:cLJoi3V3X% //FCI
				WHERE		%Exp:cWhere3%

				union 

				SELECT	    %Exp:cSelect4%
				FROM		%Exp:cFromV4B%	//PLS
				INNER JOIN	%Exp:cIJoi4C1H%	//Participantes
				WHERE		%Exp:cWhere4%
				GROUP BY    %Exp:cGroupPls%

			) TAB1
			WHERE %Exp:cWhereAll%
			ORDER BY %Exp:cOrderBy%
		EndSql
	elseIf !lApuC20
		BeginSql Alias cAliasApr
			COLUMN DTMOLE   AS DATE
			COLUMN DTEMISSA AS DATE
			COLUMN DTPV3U   AS DATE
			
			SELECT
				%Exp:cSel4020%
			FROM (
				SELECT DISTINCT %Exp:cSelect%
				FROM 		%Exp:cFromLEM%  //Fatura
				INNER JOIN 	%Exp:cIJoiC1H%  //Participantes
				INNER JOIN	%Exp:cIJoiV3S%  //Nat.Rend
				LEFT JOIN   %Exp:cIJoiV47%  //Trib
				LEFT JOIN   %Exp:cLJoiV3X%  //FCI
				INNER JOIN  %Exp:cIJoi1V3O% //Natureza
				LEFT JOIN   %Exp:cLJoi1C08% //Pais
				LEFT JOIN   %Exp:cLJoi1CUB% //Relacao Fonte Pagadora
				LEFT JOIN   %Exp:cLJoi1T9A% //Tribut. rend. benef. no Ext.
				WHERE		%Exp:cWhere%

				union

				SELECT	DISTINCT %Exp:cSelect2%
				FROM	   %Exp:cFromC20%  //Cab Nota
				INNER JOIN %Exp:cIJoi2C1H% //Participantes
				INNER JOIN %Exp:cIJoiC30%  //Item Nota
				LEFT JOIN  %Exp:cIJoiC35%  //Tributo x Item Nota
				LEFT JOIN  %Exp:cLJoiLEM%  //Fatura
				INNER JOIN %Exp:cIJoi2V3O% //Natureza
				LEFT JOIN  %Exp:cLJoi2C08% //Pais
				LEFT JOIN  %Exp:cLJoi2CUB% //Relacao Fonte Pagadora
				LEFT JOIN  %Exp:cLJoi2T9A% //Tribut. rend. benef. no Ext.
				WHERE	   %Exp:cWhere2%

				union

				SELECT	DISTINCT %Exp:cSelect3%
				FROM		%Exp:cFromV3U%  //Pgto
				INNER JOIN	%Exp:cIJoiV3V%  //Natureza
				LEFT JOIN   %Exp:cLJoiV46%  //Tributos
				LEFT JOIN   %Exp:cLJoi3V3X% //FCI
				INNER JOIN	%Exp:cIJoi3C1H% //Participantes
				INNER JOIN  %Exp:cIJoi3V3O% //Natureza
				LEFT JOIN   %Exp:cLJoi3C08% //Pais
				LEFT JOIN   %Exp:cLJoi3CUB% //Relacao Fonte Pagadora
				LEFT JOIN   %Exp:cLJoi3T9A% //Tribut. rend. benef. no Ext.
				WHERE		%Exp:cWhere3%
			) TAB1
			WHERE %Exp:cWhereAll%
			ORDER BY %Exp:cOrderBy% //O agrupamento ocorre por CNPJ para as filiais de mesmo CNPJ
		EndSql
		oTabTemp:Delete()
		FreeObj(oTabTemp)
	else //R4020
		BeginSql Alias cAliasApr
			COLUMN DTMOLE   AS DATE
			COLUMN DTEMISSA AS DATE
			COLUMN DTPV3U   AS DATE
			
			SELECT
				%Exp:cSel4020%
			FROM (
				SELECT DISTINCT %Exp:cSelect%
				FROM 		%Exp:cFromLEM%  //Fatura
				INNER JOIN 	%Exp:cIJoiC1H%  //Participantes
				INNER JOIN	%Exp:cIJoiV3S%  //Nat.Rend
				LEFT JOIN   %Exp:cIJoiV47%  //Trib
				LEFT JOIN   %Exp:cLJoiV3X%  //FCI
				INNER JOIN  %Exp:cIJoi1V3O% //Natureza
				LEFT JOIN   %Exp:cLJoi1C08% //Pais
				LEFT JOIN   %Exp:cLJoi1CUB% //Relacao Fonte Pagadora
				LEFT JOIN   %Exp:cLJoi1T9A% //Tribut. rend. benef. no Ext.
				WHERE		%Exp:cWhere%

				union

				SELECT	DISTINCT %Exp:cSelect3%
				FROM		%Exp:cFromV3U%  //Pgto
				INNER JOIN	%Exp:cIJoiV3V%  //Natureza
				LEFT JOIN   %Exp:cLJoiV46%  //Tributos
				LEFT JOIN   %Exp:cLJoi3V3X% //FCI
				INNER JOIN	%Exp:cIJoi3C1H% //Participantes
				INNER JOIN  %Exp:cIJoi3V3O% //Natureza
				LEFT JOIN   %Exp:cLJoi3C08% //Pais
				LEFT JOIN   %Exp:cLJoi3CUB% //Relacao Fonte Pagadora
				LEFT JOIN   %Exp:cLJoi3T9A% //Tribut. rend. benef. no Ext.
				WHERE		%Exp:cWhere3%
			) TAB1
			WHERE %Exp:cWhereAll%
			ORDER BY %Exp:cOrderBy% //O agrupamento ocorre por CNPJ para as filiais de mesmo CNPJ
		EndSql
		oTabTemp:Delete()
		FreeObj(oTabTemp)
	Endif
	If lReinf212
		TCSetField(cAliasApr, "DTESCO"  ,"D" )
	EndIf	
Return cAliasApr

//-------------------------------------------------------------------
/*/{Protheus.doc} SCPR40XX()
// Retorna o percentual do participante da SCP com base o cAlias Passado
@author Henrique Pereira, Denis NAves, Jose Mauro
@since 03/09/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Function SCPR40XX(cAlias, cCnpjSCP, cPercSCP, cTipoLig)

	Local cAliasBgn	as character
	Local cSelect 	as character
	Local cFrom		as character
	Local cInerJoin as character
	Local lRet 		as logical

	Default cAlias := ''
	cAliasBgn	:=	GetNextAlias()
	cSelect 	:=	''
	cFrom		:=	''
	cInerJoin	:=	''
	lRet		:=	.f.

	cSelect   := "V3Y.V3Y_PERC PERC, V3X.V3X_CNPJ CNPJSCP, V3X.V3X_TPENTL TPENTL "
    cFrom	  := RetSqlName("V3X") + " V3X "
	cInerJoin := RetSqlName("V3Y") + " V3Y ON V3X.V3X_FILIAL = '" + (cAlias)->FILIAL + "' "
	cInerJoin += " AND V3X.V3X_FILIAL = V3Y.V3Y_FILIAL "
	cInerJoin += " AND V3X.V3X_ID = V3Y.V3Y_ID AND V3X.V3X_ID = '" + (cAlias)->IDSCP +  "' "
	cInerJoin += " AND V3Y.V3Y_IDPART = '" + (cAlias)->C1H_ID +  "' "
	cInerJoin += " AND V3X.D_E_L_E_T_ = ' ' AND V3Y.D_E_L_E_T_ = ' ' "

	cSelect   := "%" + cSelect   + "%"
	cFrom	  := "%" + cFrom	 + "%"
	cInerJoin := "%" + cInerJoin + "%"

	 BeginSql Alias cAliasBgn
	 	SELECT DISTINCT		%Exp:cSelect% 
	 	FROM				%Exp:cFrom%
	 	INNER JOIN 			%Exp:cInerJoin% 	
	 EndSql	

	 if (cAliasBgn)->(!Eof())
		lRet	 :=	.t.
		cPercSCP :=	(cAliasBgn)->PERC
		cCnpjSCP :=	(cAliasBgn)->CNPJSCP
		cTipoLig :=	(cAliasBgn)->TPENTL
	 endif

	(cAliasBgn)->( DbCloseArea() )

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} HasPgtoFat
@author Denis Souza
@since 03/09/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------

Function HasPgtoFat( cEvent, cAlias, cGrupo )

Local cAliasBgn	As Character
Local cSelect 	As Character
Local cFrom		As Character
Local cIJoin	As Character
Local cGroupBy  As Character
Local cWhere	As Character

Default cEvent  := ''
Default cAlias  := ''
Default cGrupo  := ''

IniVarStat()
cAliasBgn := GetNextAlias() 
cSelect   := ''
cFrom	  := ''
cIJoin    := ''
cGroupBy  := ''
cWhere	  := ''

if cEvent == 'R4010'
	if cGrupo $ 'detDed|rendIsento' 
		cSelect := cFrom := cWhere := ''
		If (cAlias)->ROTINA == 'FAT'
			if cGrupo == 'detDed'
				cSelect := 	" V4L.V4L_TPDEDU CINDTPDEDU, V4L.V4L_VLRDED NVLRDEDUCA, V4L.V4L_NUMPRE CNRINSCPRE, V4L.V4L_IENTID IENTID, V4L.V4L_VLFPRE VLFPRE "
				cFrom  	:= 	RetSqlName("V4L") + " V4L "
				cWhere	:=	" V4L.V4L_FILIAL 	 = '" + (cAlias)->FILIAL + "' "
				cWhere	+=	" AND V4L.V4L_ID 	 = '" + (cAlias)->LEMID + "' "
				cWhere	+=	" AND V4L.V4L_IDPART = '" + (cAlias)->C1H_ID + "' "
				cWhere	+=	" AND V4L.V4L_NUMFAT = '" + (cAlias)->NUMDOCTO + "' "
				cWhere	+=	" AND V4L.V4L_IDNATR = '" + (cAlias)->IDNATR + "' "
				cWhere	+=	" AND V4L.V4L_DECTER = '" + (cAlias)->DECTER + "' "
				cWhere	+=	" AND V4L.V4L_IDTRIB = '000012' "
				cWhere	+=	" AND V4L.D_E_L_E_T_ = ' ' "
			elseif cGrupo == 'rendIsento'
				cSelect := " V4M.V4M_IDTPIS CTPISENCAO, V4M.V4M_VLRISE NVLRISENTO, V4M.V4M_DRENDI CDESCRENDI "
				cFrom  	:= 	RetSqlName("V4M") + " V4M "
				cWhere	:=	" V4M.V4M_FILIAL 	 = '" + (cAlias)->FILIAL + "' "
				cWhere	+=	" AND V4M.V4M_ID 	 = '" + (cAlias)->LEMID + "' "
				cWhere	+=	" AND V4M.V4M_IDPART = '" + (cAlias)->C1H_ID + "' "
				cWhere	+=	" AND V4M.V4M_NUMFAT = '" + (cAlias)->NUMDOCTO + "' "
				cWhere	+=	" AND V4M.V4M_IDNATR = '" + (cAlias)->IDNATR + "' "
				cWhere	+=	" AND V4M.V4M_DECTER = '" + (cAlias)->DECTER + "' "
				cWhere	+=	" AND V4M.V4M_IDTRIB = '000012' "
				cWhere	+=	" AND V4M.D_E_L_E_T_ = ' ' "
			endif

		ElseIf (cAlias)->ROTINA == 'NFS'
			If cGrupo == 'detDed'
				cSelect := 	" V4C.V4C_TPDEDU CINDTPDEDU, V4C.V4C_VLRDED NVLRDEDUCA, V4C.V4C_VLDEDS NVLRDEDSUS, V4C.V4C_NUMPRE CNRINSCPRE, V4C.V4C_IENTID IENTID, V4C.V4C_VLFPRE VLFPRE  "
				cFrom  	:= 	RetSqlName("V4C") + " V4C "
				cWhere 	:=  " V4C.V4C_FILIAL 		= '" + (cAlias)->FILIAL 	+ "' " 
				cWhere	+=	" AND V4C.V4C_CHVNF 	= '" + (cAlias)->CHVNF 		+ "' "
				cWhere	+=	" AND V4C.V4C_NUMITE	= '" + (cAlias)->NUMITE		+ "' "
				cWhere	+=	" AND V4C.V4C_CODITE	= '" + (cAlias)->CODITE		+ "' "	
				cWhere	+=	" AND V4C.V4C_CODTRI	= '" + (cAlias)->IDTRIB2	+ "' "	
				cWhere	+=	" AND V4C.D_E_L_E_T_ 	= ' ' "
			elseif cGrupo == 'rendIsento'
				cSelect := 	" V4D.V4D_IDTPIS CTPISENCAO, V4D.V4D_VLRISE NVLRISENTO, V4D.V4D_DRENDI CDESCRENDI "
				cFrom  	:= 	RetSqlName("V4D") + " V4D "
				cWhere 	:=  " V4D.V4D_FILIAL 		= '" + (cAlias)->FILIAL 	+ "' " 
				cWhere	+=	" AND V4D.V4D_CHVNF 	= '" + (cAlias)->CHVNF 		+ "' "
				cWhere	+=	" AND V4D.V4D_NUMITE	= '" + (cAlias)->NUMITE		+ "' "
				cWhere	+=	" AND V4D.V4D_CODITE	= '" + (cAlias)->CODITE		+ "' "	
				cWhere	+=	" AND V4D.V4D_CODTRI	= '" + (cAlias)->IDTRIB2	+ "' "	
				cWhere	+=	" AND V4D.D_E_L_E_T_ 	= ' ' "
			Endif
		ElseIf (cAlias)->ROTINA == 'PGT'
			If cGrupo == 'detDed'
				cSelect := " V4I.V4I_TPDEDU CINDTPDEDU, V4I.V4I_VLRDED NVLRDEDUCA, V4I.V4I_VLDEDS NVLRDEDSUS, V4I.V4I_NUMPRE CNRINSCPRE,V4I.V4I_IENTID IENTID, V4I.V4I_VLFPRE VLFPRE "
				cFrom  	:= 	RetSqlName("V4I") + " V4I "
				cWhere  := " V4I.V4I_FILIAL 	= '" + (cAlias)->FILIAL	+ "' " 
				cWhere  += " AND V4I.V4I_ID 	= '" + (cAlias)->V3UID  + "' "
				cWhere  += " AND V4I.V4I_IDNAT 	= '" + (cAlias)->IDNATR + "' "
				cWhere  += " AND V4I.V4I_IDTRIB = '000028' "
				cWhere  += " AND V4I.D_E_L_E_T_ = ' ' "
			Elseif cGrupo == 'rendIsento'	
				cSelect := 	" V4J.V4J_IDTPIS CTPISENCAO, V4J.V4J_VLRISE NVLRISENTO, V4J.V4J_DRENDI CDESCRENDI "
				cFrom  	:= 	RetSqlName("V4J") + " V4J "
				cWhere 	:=  " V4J.V4J_FILIAL 		= '" + (cAlias)->FILIAL 	+ "' " 
				cWhere	+=	" AND V4J.V4J_ID 		= '" + (cAlias)->V3UID 		+ "' "
				cWhere	+=	" AND V4J.V4J_IDNAT		= '" + (cAlias)->IDNATR		+ "' "
				cWhere	+=	" AND V4J.V4J_IDTRIB	= '000028' "
				cWhere	+=	" AND V4J.D_E_L_E_T_ 	= ' ' "
			EndIf
		Endif

		if !empty(cSelect)

			cSelect	:= "%" + cSelect + "%"
			cFrom	:= "%" + cFrom	 + "%"
			cWhere	:= "%" + cWhere  + "%"

			BeginSql Alias cAliasBgn 
				SELECT %Exp:cSelect%
				FROM %Exp:cFrom%
				WHERE %Exp:cWhere%
			EndSql
		Endif
	Endif
Endif

Return cAliasBgn

//-------------------------------------------------------------------
/*/{Protheus.doc} HasRraPJud
@param cEvent- R4010 ou R4020
@param cGrupo - tag do grupo "IdeAdv" - Advogados, "InfoRRA" para processos
@param cFil - Filial da apuração
@param cNrProc - Id do processo RRA ou JUD
@param dFatoGer - data do fato gerador do pagamento ou fatura

@author Denis Souza
@since 05/09/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Function HasRraPJud( cEvent, cGrupo, cFil, cNrProc )

Local cAliasBgn	As Character
Local cSelect 	As Character
Local cFrom		As Character
Local cWhere    As Character
Local cLJoiV4G	As Character
Local cLJoiV3Z	As Character
Local cGroupBy  As Character
Local cOrderBy  As Character

Default cEvent  := ''
Default cGrupo  := ''
Default cFil    := ''
Default cNrProc := ''

IniVarStat()
cAliasBgn := GetNextAlias()
cSelect   := ''
cFrom	  := ''
cWhere 	  := ''
cLJoiV4G  := ''
cLJoiV3Z  := ''
cGroupBy  := ''
cOrderBy  := ''

//------------------------------------------- 
// 					CAMPOS
//--------------------------------------------
if cGrupo != "IdeAdv"
	cSelect := " V4F.V4F_INDRRA INDRRA, V4F.V4F_TPPROC TPPROC, V4F.V4F_NRPROC NRPROC, V4F.V4F_INDORI INDORI, V4F.V4F_DESCRI DESCRI, V4F.V4F_CNPJOR CNPJOR, V4F.V4F_QTDMES QTDMESRRA "
elseif cGrupo == "IdeAdv"
	If !("INFORMIX" $ _cBd)  
		cSelect := " COALESCE(V3Z.V3Z_TPINSC, ' ') TPINSC, COALESCE(V3Z.V3Z_NRINSC, ' ') NRINSC, V4F.V4F_NRPROC NRPROC, V4G.V4G_TPDESP TPDESP, V4G.V4G_IDADVG IDADVG , SUM( V4G.V4G_VLDESP) VLDESP "
	else
		cSelect := " NVL(V3Z.V3Z_TPINSC, ' ') TPINSC, NVL(V3Z.V3Z_NRINSC, ' ') NRINSC, V4F.V4F_NRPROC NRPROC, V4G.V4G_TPDESP TPDESP, V4G.V4G_IDADVG IDADVG , SUM( V4G.V4G_VLDESP) VLDESP "
	endif
endif

//------------------------------------------- 
// 			TABELAS + JOINS + GROUPBY
//--------------------------------------------
cFrom 	 := RetSqlName("V4F") + " V4F "
cLJoiV4G := RetSqlName("V4G") + " V4G ON V4G.V4G_FILIAL = V4F.V4F_FILIAL AND V4G.V4G_ID = V4F.V4F_ID AND V4G.D_E_L_E_T_ = ' ' "
cLJoiV3Z := RetSqlName("V3Z") + " V3Z ON V3Z.V3Z_FILIAL = V4G.V4G_FILIAL AND V3Z.V3Z_ID = V4G.V4G_IDADVG AND V3Z.D_E_L_E_T_ = ' ' "

cWhere := " V4F.V4F_FILIAL = '" + xFilial("V4F", cFil) + "' AND V4F.V4F_ID = '" + cNrProc + "' "

if cGrupo == "InfoRRA"
	cWhere += " AND V4F.V4F_INDRRA IN (' ','1','2') " //4010 POR TER AMBOS 
	cWhere += " AND V4F.V4F_TPPROC IN ('1','2','3') " //4010 POR TER AMBOS 
EndIf
cWhere += " AND V4F.D_E_L_E_T_ = ' ' "

if cGrupo == "IdeAdv"
	cGroupBy := " V3Z.V3Z_TPINSC, V3Z.V3Z_NRINSC, V4F.V4F_NRPROC, V4G.V4G_TPDESP, V4G.V4G_IDADVG "
endif
cOrderBy := "% NRPROC, INDRRA, TPPROC %"
cSelect	 := "%" + cSelect  + "%"
cFrom	 := "%" + cFrom	   + "%"
cLJoiV4G := "%" + cLJoiV4G + "%"
cLJoiV3Z := "%" + cLJoiV3Z + "%"
cWhere	 := "%" + cWhere   + "%"	
if cGrupo == "IdeAdv"
	cGroupBy := "%" + cGroupBy + "%"	
endif

//------------------------------------------- 
// 			EXECUCAO QUERY
//--------------------------------------------
if cGrupo == "InfoRRA"
	BeginSql Alias cAliasBgn
		SELECT DISTINCT %Exp:cSelect%
		FROM %Exp:cFrom%
		WHERE  %Exp:cWhere% 
		ORDER BY %Exp:cOrderBy% 
	EndSql

elseif cGrupo == "IdeAdv"
	BeginSql Alias cAliasBgn
		SELECT %Exp:cSelect%
		FROM %Exp:cFrom%
		LEFT JOIN %Exp:cLJoiV4G%
		LEFT JOIN %Exp:cLJoiV3Z%
		WHERE  %Exp:cWhere%
		GROUP BY %Exp:cGroupBy%
		ORDER BY 3,1,2
	EndSql
endif

Return cAliasBgn 

//-------------------------------------------------------------------

/*/{Protheus.doc} TafProcRet
@param Alias - Alias da query principal, FAT, NFS, PGT
@param cChavProc - Chave da tabela Pai
@param cCompC1G - Compartilhamento  da tabela C1G
@param aSM0EUF - Layout da SM0
@param l4010 - .T. se evento = R-4010

@author Denis Souza
@since
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function TafProcRet( Alias, cChavProc, cCompC1G, aSM0EUF, l4010, lApuSTri )

	Local cSelect		AS Character
	Local cFrom			AS Character
	Local cLJoiT5L		AS Character
	Local cJoinC1G		AS Character
	Local cWhere		AS Character
	Local cAliasPro		AS Character
	Local nTam			As Numeric
	Local nTamIDSUSP	AS Numeric
	Local lFormat		As Logical

	Default l4010		:= .F.
	
	Default Alias		:= ""
	Default cChavProc	:= ""
	Default cCompC1G	:= ""
	Default aSM0EUF		:= {}
	Default lApuStri    := .F.

	cSelect	  := ''
	cFrom	  := ''
	cLJoiT5L  := ''
	cJoinC1G  := ''
	cWhere	  := ''
	cAliasPro := GetNextAlias()
	nTam	  := 0
	nTamIDSUSP:= 0
	lFormat	  := .F.
	IniVarStat()
	//-------------------------------------------- 
	// 				NOTA FISCAL
	//--------------------------------------------
	If 'NFS' $ ALLTRIM((Alias)->ROTINA)

		cSelect := " '" + cChavProc + "' ID,  '" + (Alias)->CHVNFC30 + "' CCHAVE, 'NFS' ROTINA, "
		cSelect += " T9Q.T9Q_FILIAL CODFIL, T9Q.T9Q_TPPROC CTPPROC, T9Q.T9Q_NUMPRO NUMPRO, T9Q.T9Q_VALSUS VALSUS, T9Q.T9Q_BSSUSP BSSUSP, T9Q.T9Q_CODTRI CODTRI, T9Q.T9Q_IDSUSP IDSUSP, "
		cSelect += " T9Q.T9Q_VLRANO VLRANO, T9Q.T9Q_VLRANA VLRANA,"
		cSelect += " C1G.C1G_TPPROC C1GTPPROC, C1G.C1G_NUMPRO C1GNUMPRO, C1G.C1G_ID C1GID, C1G.C1G_VERSAO C1GVERSAO, C1G.C1G_FILIAL C1GFILIAL, "
		cSelect += " T5L.T5L_CODSUS CODSUS, T5L.T5L_INDDEP INDDEP, T5L.T5L_VLRDEP VLRDEP "

		cFrom	 := RetSqlName("T9Q") + " T9Q "
		cJoinC1G := RetSqlName("C1G") + " C1G ON "

		If cCompC1G == 'EEE'
			cJoinC1G += " C1G.C1G_FILIAL = T9Q.T9Q_FILIAL AND "
		ElseIf cCompC1G == 'CCC'
			cJoinC1G += " C1G.C1G_FILIAL = '" + xFilial("C1G") + "' AND "
		Else
			If cCompC1G == 'EEC'
				nTam := aSM0EUF[EMPRESA] + aSM0EUF[UNIDADE]
				nTam += iif(nTam == 0, aSM0EUF[FIL], 0)
				lFormat := .T.
			ElseIf cCompC1G == 'ECC'
				nTam := aSM0EUF[EMPRESA]
				nTam += iif(nTam == 0, aSM0EUF[FIL], 0)
				lFormat := .T.		
			EndIf
			if lFormat
				cJoinC1G += " SUBSTRING(C1G.C1G_FILIAL,1," + cValToChar(nTam) + " ) = SUBSTRING(T9Q.T9Q_FILIAL,1," + cValToChar(nTam) + " ) AND "
			EndIf		
		EndIf
		cJoinC1G += " C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "

		nTamIDSUSP	:= TamSX3("T9Q_IDSUSP")[1]
		cLJoiT5L := RetSqlName("T5L") + " T5L ON SUBSTRING(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") = T9Q.T9Q_IDSUSP "

		cLJoiT5L += " AND T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere := " T9Q.D_E_L_E_T_ = ' ' AND T9Q.T9Q_CHVNF = '" + (Alias)->CHVNFC30 +  "' "
		cWhere += " AND T9Q.T9Q_FILIAL = '" + (Alias)->FILIAL + "' AND T9Q.T9Q_NUMITE = '" + (Alias)->NUMITC30 + "' AND T9Q.T9Q_ID = '" + (Alias)->CODITC30 + "' "
		cWhere += " AND T9Q.T9Q_CODTRI = '000012' " //IR

	//-------------------------------------------- 
	// 				   FATURA
	//--------------------------------------------
	Elseif 'FAT' $ ALLTRIM((Alias)->ROTINA)

		cSelect := " '" + cChavProc + "' ID, '" + (Alias)->LEMID + "' CCHAVE, 'FAT' ROTINA, "
		cSelect += " T9E.T9E_FILIAL CODFIL, T9E.T9E_TPPROC CTPPROC, T9E.T9E_NUMPRO NUMPRO, T9E.T9E_VALSUS VALSUS, T9E.T9E_BSSUSP BSSUSP, T9E.T9E_CODTRI CODTRI, "
		cSelect += " T9E.T9E_VLRANO VLRANO, T9E.T9E_VLRANA VLRANA, T9E.T9E_IDSUSP IDSUSP, "
		cSelect += " C1G.C1G_TPPROC C1GTPPROC, C1G.C1G_NUMPRO C1GNUMPRO, C1G.C1G_ID C1GID, C1G.C1G_VERSAO C1GVERSAO, C1G.C1G_FILIAL C1GFILIAL, "
		cSelect += " T5L.T5L_CODSUS CODSUS, T5L.T5L_INDDEP INDDEP, T5L.T5L_VLRDEP VLRDEP "

		cFrom	 := RetSqlName("T9E") + " T9E"
		cJoinC1G := RetSqlName("C1G") + " C1G ON "

		If cCompC1G == 'EEE'
			cJoinC1G += " C1G.C1G_FILIAL = T9E.T9E_FILIAL AND "			
		ElseIf cCompC1G == 'CCC'
			cJoinC1G += " C1G.C1G_FILIAL = '" + xFilial("C1G") + "' AND "
		Else
			If cCompC1G == 'EEC'
				nTam := aSM0EUF[EMPRESA] + aSM0EUF[UNIDADE]
				nTam += iif(nTam == 0, aSM0EUF[FIL], 0) 
				lFormat := .T.
			ElseIf cCompC1G == 'ECC'
				nTam := aSM0EUF[EMPRESA] 
				nTam += iif(nTam == 0, aSM0EUF[FIL], 0)
				lFormat := .T.		
			EndIf
			if lFormat
				cJoinC1G += " SUBSTRING(C1G.C1G_FILIAL,1," + cValToChar(nTam) + " ) = SUBSTRING(T9E.T9E_FILIAL,1," + cValToChar(nTam) + " ) AND "
			EndIf
		EndIf
		cJoinC1G += " C1G.C1G_ID = T9E.T9E_NUMPRO AND C1G.D_E_L_E_T_ = ' ' "
    
		nTamIDSUSP	:= TamSX3("T9E_IDSUSP")[1]
		cLJoiT5L := RetSqlName("T5L") + " T5L ON SUBSTRING(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") = T9E.T9E_IDSUSP "

		cLJoiT5L += " AND T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere := " T9E.D_E_L_E_T_ = ' ' AND T9E.T9E_ID = '" + (Alias)->LEMID + "' "
		cWhere += " AND T9E.T9E_FILIAL = '" + (Alias)->FILIAL + "' "
		cWhere += " AND T9E.T9E_CNATRE = '" + (Alias)->IDNATR + "' "
		cWhere += " AND T9E.T9E_CODTRI = '000012' " //IR

	//-------------------------------------------- 
	// 				  PAGAMENTO
	//--------------------------------------------
	Elseif 'PGT' $ AllTrim((Alias)->ROTINA) .And. ( ( l4010 .And. AllTrim((Alias)->IDTRIB2) $ "000028" ) .Or. ( !l4010 .And. AllTrim((Alias)->IDTRIB2) $ "000010|000011|000018|000028|000029|000030" ) .Or. (Alias)->TRIBNAT == '8' .Or. lApuStri )
		cSelect := " '" + cChavProc + "' ID,  '" + (Alias)->V3UID + "' CCHAVE, 'PGT' ROTINA, "
		cSelect += " V4H.V4H_FILIAL CODFIL, '' CTPPROC, V4H.V4H_IDPROC NUMPRO, V4H.V4H_VALSUS VALSUS, V4H.V4H_VBASSU BSSUSP, V4H.V4H_IDTRIB CODTRI, "
		cSelect += " V4H.V4H_VLRANO VLRANO, V4H.V4H_VLRANA VLRANA, V4H.V4H_IDSUSP IDSUSP, ""
		cSelect += " C1G.C1G_TPPROC C1GTPPROC, C1G.C1G_NUMPRO C1GNUMPRO, C1G.C1G_ID C1GID, C1G.C1G_VERSAO C1GVERSAO, C1G.C1G_FILIAL C1GFILIAL, "
		cSelect += " T5L.T5L_CODSUS CODSUS, T5L.T5L_INDDEP INDDEP, T5L.T5L_VLRDEP VLRDEP "

		cFrom	 := RetSqlName("V4H") + " V4H"
		cJoinC1G := RetSqlName("C1G") + " C1G ON "

		If cCompC1G == 'EEE'
			cJoinC1G += " C1G.C1G_FILIAL = V4H.V4H_FILIAL AND "
		ElseIf cCompC1G == 'CCC'
			cJoinC1G += " C1G.C1G_FILIAL = '" + xFilial("C1G") + "' AND "
		Else
			If cCompC1G == 'EEC'
				nTam := aSM0EUF[EMPRESA] + aSM0EUF[UNIDADE]
				nTam += iif(nTam == 0, aSM0EUF[FIL], 0)
				lFormat := .T.
			ElseIf cCompC1G == 'ECC'
				nTam := aSM0EUF[EMPRESA]
				nTam += iif(nTam == 0, aSM0EUF[FIL], 0)
				lFormat := .T.		
			EndIf
			if lFormat
				cJoinC1G += " SUBSTRING(C1G.C1G_FILIAL,1," + cValToChar(nTam) + " ) = SUBSTRING(V4H.V4H_FILIAL,1," + cValToChar(nTam) + " ) AND "
			EndIf
		EndIf
		cJoinC1G += " C1G.C1G_ID = V4H.V4H_IDPROC AND C1G.D_E_L_E_T_ = ' ' "

		nTamIDSUSP	:= TamSX3("V4H_IDSUSP")[1]
		cLJoiT5L := RetSqlName("T5L") + " T5L ON SUBSTRING(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") = V4H.V4H_IDSUSP "

		cLJoiT5L += " AND T5L.D_E_L_E_T_ = ' ' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere := " V4H.D_E_L_E_T_ = ' ' AND V4H.V4H_ID = '" + (Alias)->V3UID + "' "
		cWhere += " AND V4H.V4H_FILIAL = '" + (Alias)->FILIAL + "' "
		cWhere += " AND V4H.V4H_CNATRE = '" + (Alias)->IDNATR + "' "

		if l4010
			cWhere += " AND V4H.V4H_IDTRIB = '000028' " //IR BAIXA
		else
			cWhere += " AND V4H.V4H_IDTRIB IN ('000010', '000011', '000018', '000028','000029','000030' ) " //PISPASEP/COFINS/CSLL//IR
		EndIf
	EndIf

	cSelect  := "%" + cSelect  + "%"
	cFrom	 := "%" + cFrom	   + "%"
	cJoinC1G := "%" + cJoinC1G + "%"
	cLJoiT5L := "%" + cLJoiT5L + "%"
	cWhere	 := "%" + cWhere   + "%"

	BeginSql Alias cAliasPro 
		SELECT
		%Exp:cSelect%
		FROM
		%Exp:cFrom%
		INNER JOIN
		%Exp:cJoinC1G%
		LEFT JOIN
		%Exp:cLJoiT5L%
		Where
		%Exp:cWhere%
	EndSql
	(cAliasPro)->(DbGoTop())
Return cAliasPro

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFil()

Trata o array de filiais passado pela tela da apuracao
para que fique no formato de execucao do IN no SQL


@since 11/09/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function RetFil(aFil)
	Local cRetFils	as Character
	Local nX		as Numeric

	cRetFils	:= ""
	nX			:= 0

	For nX := 1 to Len(aFil)
		If nX > 1
			cRetFils += " , '" + aFil[nX][2] + "'"
		Else
			cRetFils += "'" + aFil[nX][2] + "'"
		EndIf
	Next nX

Return cRetFils

//-------------------------------------------------------------------
/*/{Protheus.doc} IniVarStat        

Inicializa as variaveis statics

@Return nil 

@author Denis Souza
@since  10/10/2019
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Static Function IniVarStat()

If Empty(_cBd)
	_cBd := TcGetDb()
EndIf	

If Empty(_nTamIDNat)
	_nTamIDNat := TamSX3("V3S_IDNATR")[1]
EndIf

If __lV3UPerApu == nil
	__lV3UPerApu := TafColumnPos("V3U_PERAPU")
EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TafBenefPen        

Retorna os beneficiarios da dedução de Pensão Alimenticia e Dependentes
tag {benefPen} da detDed e dedSusp

@Return nil 

@author Karen Honda
@since  03/10/2022
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Function TafBenefPen(cAlias, cAliasDep, cTpDedu, cTag, cNumPro, cCodSus, cTpProc)
Local lRet as logical
Local cQuery as Character

lRet := .F.
If cTag == 'detDed'
	If (cAlias)->ROTINA == 'FAT' 
		cQuery := "SELECT V83.V83_CODDEP CODDEP, V83.V83_CPFDEP CPFDEP, V83.V83_VALDED VALDED, V3R.V3R_NOME NOME "
		cQuery += "FROM " + RetSqlName("V83") + " V83 "
		cQuery += "INNER JOIN " + RetSqlName("V3R") + " V3R "
		cQuery += "ON V3R.V3R_FILIAL = '" + (cAlias)->FILC1H +"' "
		cQuery += "AND V3R.V3R_ID = V83.V83_IDPART "
		cQuery += "AND V3R.V3R_CODIGO = V83.V83_CODDEP "
		cQuery += "AND V3R.V3R_CPF = V83.V83_CPFDEP "
		cQuery += "AND V3R.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "V83.V83_FILIAL = '" + (cAlias)->FILIAL + "' "
		cQuery += "AND V83.V83_ID = '" + (cAlias)->LEMID + "' "
		cQuery += "AND V83.V83_IDPART = '" + (cAlias)->C1H_ID + "' "
		cQuery += "AND V83.V83_NUMFAT = '" + (cAlias)->NUMDOCTO + "' " 
		cQuery += "AND V83.V83_IDNATR = '" + (cAlias)->IDNATR + "' " 
		cQuery += "AND V83.V83_DECTER = '" + (cAlias)->DECTER + "' " 
		cQuery += "AND V83.V83_IDTRIB = '" + (cAlias)->IDTRIB2 + "' " 
		cQuery += "AND V83.V83_TPDEDU = '" + cTpDedu + "' " 
		cQuery += "AND V83.D_E_L_E_T_ = ' ' "
	ElseIf (cAlias)->ROTINA == 'NFS'
		cQuery := "SELECT V84.V84_CODDEP CODDEP, V84.V84_CPFDEP CPFDEP, V84.V84_VALDED VALDED, V3R.V3R_NOME NOME "
		cQuery += "FROM " + RetSqlName("V84") + " V84 "
		cQuery += "INNER JOIN " + RetSqlName("V3R") + " V3R "
		cQuery += "ON V3R.V3R_FILIAL = '" + (cAlias)->FILC1H +"' "
		cQuery += "AND V3R.V3R_ID = V84.V84_IDPART "
		cQuery += "AND V3R.V3R_CODIGO = V84.V84_CODDEP "
		cQuery += "AND V3R.V3R_CPF = V84.V84_CPFDEP "
		cQuery += "AND V3R.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "V84.V84_FILIAL = '" + (cAlias)->FILIAL + "' "
		cQuery += "AND V84.V84_IDPART = '" + (cAlias)->C1H_ID + "' "
		cQuery += "AND V84.V84_CHVNF  = '" + (cAlias)->CHVNF + "' "
		cQuery += "AND V84.V84_NUMITE = '" + (cAlias)->NUMITC30 + "' " 
		cQuery += "AND V84.V84_CODITE = '" + (cAlias)->CODITC30 + "' " 
		cQuery += "AND V84.V84_CODTRI = '" + (cAlias)->IDTRIB2 + "' " 
		cQuery += "AND V84.V84_TPDEDU = '" + cTpDedu + "' " 
		cQuery += "AND V84.D_E_L_E_T_ = ' ' "
	ElseIf (cAlias)->ROTINA == 'PGT'
		cQuery := "SELECT V85.V85_CODDEP CODDEP, V85.V85_CPFDEP CPFDEP, V85.V85_VALDED VALDED, V3R.V3R_NOME NOME "
		cQuery += "FROM " + RetSqlName("V85") + " V85 "
		cQuery += "INNER JOIN " + RetSqlName("V3R") + " V3R "
		cQuery += "ON V3R.V3R_FILIAL = '" + (cAlias)->FILC1H +"' "
		cQuery += "AND V3R.V3R_ID = V85.V85_IDPART "
		cQuery += "AND V3R.V3R_CODIGO = V85.V85_CODDEP "
		cQuery += "AND V3R.V3R_CPF = V85.V85_CPFDEP "
		cQuery += "AND V3R.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "V85.V85_FILIAL = '" + (cAlias)->FILIAL + "' "
		cQuery += "AND V85.V85_ID = '" + (cAlias)->V3UID + "' "
		cQuery += "AND V85.V85_IDPART = '" + (cAlias)->C1H_ID + "' "
		cQuery += "AND V85.V85_IDNAT  = '" + (cAlias)->IDNATR + "' "
		cQuery += "AND V85.V85_IDTRIB = '" + (cAlias)->IDTRIB2 + "' " 
		cQuery += "AND V85.V85_TPDEDU = '" + cTpDedu + "' " 
		cQuery += "AND V85.D_E_L_E_T_ = ' ' "
	EndIf
ElseIf cTag == 'dedSusp'
	If (cAlias)->ROTINA == 'FAT' 
		cQuery := "SELECT V96.V96_CODDEP CODDEP, V96.V96_CPF CPFDEP, V96.V96_VDEDSU VDEDSU, V3R.V3R_NOME NOME "
		cQuery += "FROM " + RetSqlName("V96") + " V96 "
		cQuery += "INNER JOIN " + RetSqlName("V3R") + " V3R "
		cQuery += "ON V3R.V3R_FILIAL = '" + (cAlias)->FILC1H +"' "
		cQuery += "AND V3R.V3R_ID = V96.V96_IDPART "
		cQuery += "AND V3R.V3R_CPF = V96.V96_CPF "
		cQuery += "AND V3R.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "V96.V96_FILIAL = '" + (cAlias)->FILIAL + "' "
		cQuery += "AND V96.V96_ID = '" + (cAlias)->LEMID + "' "
		cQuery += "AND V96.V96_IDPART = '" + (cAlias)->C1H_ID + "' "
		cQuery += "AND V96.V96_NUMFAT = '" + (cAlias)->NUMDOCTO + "' " 
		cQuery += "AND V96.V96_NUMPRO = '" + cNumPro + "' " 
		cQuery += "AND V96.V96_IDSUSP = '" + cCodSus + "' " 
		cQuery += "AND V96.V96_TPPROC = '" + cTpProc + "' " 
		cQuery += "AND V96.V96_CODTRI = '" + (cAlias)->IDTRIB2 + "' " 
		cQuery += "AND V96.V96_TPDEDU = '" + cTpDedu + "' " 
		cQuery += "AND V96.D_E_L_E_T_ = ' ' "
	ElseIf (cAlias)->ROTINA == 'NFS'
		cQuery := "SELECT V94.V94_CODDEP CODDEP, V94.V94_CPF CPFDEP, V94.V94_VDEDSU VDEDSU, V3R.V3R_NOME NOME "
		cQuery += "FROM " + RetSqlName("V94") + " V94 "
		cQuery += "INNER JOIN " + RetSqlName("V3R") + " V3R "
		cQuery += "ON V3R.V3R_FILIAL = '" + (cAlias)->FILC1H +"' "
		cQuery += "AND V3R.V3R_ID = V94.V94_IDPART "
		cQuery += "AND V3R.V3R_CODIGO = V94.V94_CODDEP "
		cQuery += "AND V3R.V3R_CPF = V94.V94_CPF "
		cQuery += "AND V3R.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "V94.V94_FILIAL = '" + (cAlias)->FILIAL + "' "
		cQuery += "AND V94.V94_IDPART = '" + (cAlias)->C1H_ID + "' "
		cQuery += "AND V94.V94_CHVNF  = '" + (cAlias)->CHVNF + "' "
		cQuery += "AND V94.V94_NUMITE = '" + (cAlias)->NUMITC30 + "' " 
		cQuery += "AND V94.V94_IDPROC = '" + (cAlias)->CODITC30 + "' " 
		cQuery += "AND V94.V94_CODTRI = '" + (cAlias)->IDTRIB2 + "' " 
		cQuery += "AND V94.V94_NUMPRO = '" + cNumPro + "' " 
		cQuery += "AND V94.V94_IDSUSP = '" + cCodSus + "' " 
		cQuery += "AND V94.V94_TPPROC = '" + cTpProc + "' " 
		cQuery += "AND V94.V94_TPDEDU = '" + cTpDedu + "' " 
		cQuery += "AND V94.D_E_L_E_T_ = ' ' "
	ElseIf (cAlias)->ROTINA == 'PGT'
		cQuery := "SELECT V95.V95_CODDEP CODDEP, V95.V95_CPF CPFDEP, V95.V95_VDEDSU VDEDSU, V3R.V3R_NOME NOME "
		cQuery += "FROM " + RetSqlName("V95") + " V95 "
		cQuery += "INNER JOIN " + RetSqlName("V3R") + " V3R "
		cQuery += "ON V3R.V3R_FILIAL = '" + (cAlias)->FILC1H +"' "
		cQuery += "AND V3R.V3R_ID = V95.V95_IDPART "
		cQuery += "AND V3R.V3R_CODIGO = V95.V95_CODDEP "
		cQuery += "AND V3R.V3R_CPF = V95.V95_CPF "
		cQuery += "AND V3R.D_E_L_E_T_ = ' ' "
		cQuery += "WHERE "
		cQuery += "V95.V95_FILIAL = '" + (cAlias)->FILIAL + "' "
		cQuery += "AND V95.V95_ID = '" + (cAlias)->V3UID + "' "
		cQuery += "AND V95.V95_IDPART = '" + (cAlias)->C1H_ID + "' "
		cQuery += "AND V95.V95_CNATRE  = '" + (cAlias)->IDNATR + "' "
		cQuery += "AND V95.V95_IDPROC = '" + cNumPro + "' " 
		cQuery += "AND V95.V95_IDSUSP = '" + cCodSus + "' " 
		cQuery += "AND V95.V95_IDTRIB = '" + (cAlias)->IDTRIB2 + "' " 
		cQuery += "AND V95.V95_TPDEDU = '" + cTpDedu + "' " 
		cQuery += "AND V95.D_E_L_E_T_ = ' ' "
	EndIf
EndIf		
If !Empty(cQuery)	
	cQuery := changeQuery(cQuery)
	cAliasDep := GetNextAlias()
	dbUseArea( .t.,'TOPCONN',TcGenQry(,,cQuery ),cAliasDep,.f.,.t.)
	If (cAliasDep)->( !Eof())
		lRet := .T.
	EndIf
EndIf	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TafDedSus        

Retorna as deduções suspensas pelo processo judicial
tag {dedSusp} da R-4010

@Return nil 

@author Karen Honda
@since  03/10/2022
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Function TafDedSus(cAlias, cAliasPro, cAliasDed )
Local lRet as logical
Local cQuery as Character

lRet := .F.
If (cAlias)->ROTINA == "FAT" 
	cQuery := "SELECT V89.V89_TPDEDU TPDEDU, V89.V89_VALDED VALDED "
	cQuery += "FROM " + RetSqlName("V89") + " V89 "
	cQuery += "WHERE "
	cQuery += "V89.V89_FILIAL = '" + (cAliasPro)->CODFIL + "' " 
	cQuery += "AND V89.V89_ID     = '" + (cAlias)->LEMID + "' "  
	cQuery += "AND V89.V89_IDPT9E = '" + (cAlias)->C1H_ID + "' "  
	cQuery += "AND V89.V89_NFAT9E = '" + (cAlias)->NUMDOCTO + "' "  
	cQuery += "AND V89.V89_NUMPRO = '" + (cAliasPro)->NUMPRO + "' "  
	cQuery += "AND V89.V89_IDSUSP = '" + (cAliasPro)->IDSUSP + "' "  
	cQuery += "AND V89.V89_CODTRI = '" + (cAlias)->IDTRIB2 + "' "  
	cQuery += "AND V89.V89_TPPROC = '" + (cAliasPro)->CTPPROC + "' "  
	cQuery += "AND V89.D_E_L_E_T_ = ' ' "

ElseIf (cAlias)->ROTINA == "NFS"
	cQuery := "SELECT V88.V88_TPDEDU TPDEDU, V88.V88_VALDED VALDED "
	cQuery += "FROM " + RetSqlName("V88") + " V88 "
	cQuery += "WHERE "
	cQuery += "V88.V88_FILIAL = '" + (cAliasPro)->CODFIL + "' "  
	cQuery += "AND V88.V88_CHVNF  = '" + (cAlias)->CHVNF + "' "   
	cQuery += "AND V88.V88_NUMITE = '" + (cAlias)->NUMITE + "' "    
	cQuery += "AND V88.V88_IDPROC = '" + (cAlias)->CODITE + "' "    
	cQuery += "AND V88.V88_NUMPRO = '" + (cAliasPro)->NUMPRO + "' "    
	cQuery += "AND V88.V88_IDSUSP = '" + (cAliasPro)->IDSUSP + "' "    
	cQuery += "AND V88.V88_CODTRI = '" + (cAlias)->IDTRIB2 + "' "    
	cQuery += "AND V88.V88_TPPROC = '" + (cAliasPro)->CTPPROC + "' "    
	cQuery += "AND V88.D_E_L_E_T_ = ' ' "
ElseIf (cAlias)->ROTINA == "PGT"
	cQuery := "SELECT V90.V90_TPDEDU TPDEDU, V90.V90_VALDED VALDED "
	cQuery += "FROM " + RetSqlName("V90") + " V90 "	
	cQuery += "WHERE "
	cQuery += "V90.V90_FILIAL     = '" + (cAliasPro)->CODFIL + "' "
	cQuery += "AND V90.V90_ID  	  = '" + (cAlias)->V3UID + "' " 
	cQuery += "AND V90.V90_CNATRE = '" + (cAlias)->IDNATR + "' " 
	cQuery += "AND V90.V90_IDPROC = '" + (cAliasPro)->NUMPRO + "' " 
	cQuery += "AND V90.V90_IDSUSP = '" + (cAliasPro)->IDSUSP + "' " 
	cQuery += "AND V90.V90_IDTRIB = '" + (cAlias)->IDTRIB2 + "' "
	cQuery += "AND V90.D_E_L_E_T_ = ' ' "
EndIf

If !Empty(cQuery)	
	cQuery := changeQuery(cQuery)
	cAliasDed := GetNextAlias()
	dbUseArea( .t.,'TOPCONN',TcGenQry(,,cQuery ),cAliasDed,.f.,.t.)
	If (cAliasDed)->( !Eof())
		lRet := .T.
	EndIf
EndIf	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafOpePLS        

Retorna os dados dos pagamentos/reembolso do plano de saude por periodo e participante
tag {ideOpSaude} da R-4010

@Return nil 

@author Karen Honda
@since  03/10/2022
@version 1.0

/*/                                 
//-------------------------------------------------------------------

Function TafOpePLS(cPerApu, aFil, cCPFC1H, cAliasV4B, cIdPart)
Local cQuery   As Character
Local cDataIni	As Character 
Local cDataFim	As Character
Local cFilV4B As Character
Local cFilC1H As Character
Local lRet As Logical 

Default cPerApu := ""
Default aFil := {}
Default cCPFC1H := ""
Default cAliasV4B := ""
Default cIdPart := ""

cFilV4B  := TafRetFilC( "V4B", aFil )
cFilC1H   := TafRetFilC( "C1H", aFil )

lRet := .F.
cPerApu   := SubSTR(cPerApu,3,4) + SubSTR(cPerApu,1,2)
cDataIni := cPerApu + "01" //ex: 20220201
cDataFim := DtoS( LastDay( StoD( cDataIni ) ) )

cQuery := ""

//-------------------------------------------- 
// 				 PGTO REEMB PLS
//--------------------------------------------
cQuery := "SELECT "
cQuery += " C1H.C1H_FILIAL FILC1H, "
cQuery += " C1H.C1H_ID 	 C1H_ID,   "
cQuery += " V4A.V4A_REGANS REGANS, " 
cQuery += " V4A.V4A_CNPJ   CNPJPLS," 
cQuery += " V4B.V4B_TPINSC TPINSV4B,"
cQuery += " V4B.V4B_NRINSC NRINSV4B,"
cQuery += " V4B.V4B_INDBEN INDBEN4B,"
cQuery += " V4B.V4B_TPPGTO TPPGTV4B,"
cQuery += " V4B.V4B_CODDEP CODDEV4B, "
cQuery += " V4B.R_E_C_N_O_ RECNO, "
cQuery += " V4B.V4B_VLRPGT VRPGTV4B, "
cQuery += " V4B.V4B_VRBANT VRBANT4B "
//cQuery += " SUM(V4B.V4B_VLRPGT) VRPGTV4B,"
//cQuery += " SUM(V4B.V4B_VRBANT) VRBANT4B"

cQuery  += "FROM " + RetSqlName("V4B") + " V4B "

//Plano de Saude
cQuery += "INNER JOIN " + RetSqlName("V4A") + " V4A ON V4A_FILIAL = V4B.V4B_FILIAL AND V4A.V4A_ID = V4B.V4B_IDPLS AND V4A.D_E_L_E_T_ = ' ' "

//Participante
cQuery += "INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = V4B.V4B_IDPART AND C1H.D_E_L_E_T_ = ' ' "
cQuery += "AND C1H.C1H_FILIAL IN " + cFilC1H
If !Empty(cCPFC1H)
	cQuery += "AND C1H.C1H_CPF = '" + cCPFC1H + "' "
Else
	cQuery += "AND C1H.C1H_ID = '" + cIdPart + "' "
EndIf

cQuery += "WHERE V4B.V4B_FILIAL IN " + cFilV4B + " AND V4B.D_E_L_E_T_ = ' ' AND "
cQuery += "V4B.V4B_DTPGTO BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' "

cQuery += "ORDER BY V4A.V4A_CNPJ, C1H.C1H_ID, V4A.V4A_REGANS, V4B.V4B_CODDEP, V4B.V4B_TPPGTO, V4B.V4B_INDBEN, V4B.V4B_TPINSC,V4B.V4B_NRINSC "
If !Empty(cQuery)
	cQuery := changeQuery(cQuery)
	cAliasV4B := GetNextAlias()
	dbUseArea( .t.,'TOPCONN',TcGenQry(,,cQuery ),cAliasV4B,.f.,.t.)
	If (cAliasV4B)->( !Eof()) 
		lRet := .T.
	EndIf
EndIf		

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TafJoinFat        
Funcao para montar os relacionamentos da fatura,
se fez necessario devido o R4020, para reaproveitar a verificacao
do pagamento na fatura e nao duplicar query no fonte.

@Return nil 

@author Denis Souza
@since  22/11/2022
@version 1.0
/*/                                 
//-------------------------------------------------------------------
Static Function TafJoinFat(cFromLEM,cIJoiC1H,l4010,cCompC1H,aInfEUF,cCNPJC1H,cCPF,cIJoiV3S,cIJoiV47,cLJoiV3X,cCompV3X,cIJoi1V3O,cLJoi1C08,cLJoi1CUB,cLJoi1T9A,cWhere,cFiliais,cDataIni,cDataFim,cCodPar,cNif,cQryV3O,cDtConta,lApuSTri)

Default cFromLEM  := ''
Default cIJoiC1H  := ''
Default l4010     := .F.
Default cCompC1H  := ''
Default aInfEUF   := {}
Default cCNPJC1H  := ''
Default cCPF 	  := ''
Default cIJoiV3S  := ''
Default cIJoiV47  := ''
Default cLJoiV3X  := ''
Default cCompV3X  := ''
Default cIJoi1V3O := ''
Default cLJoi1C08 := ''
Default cLJoi1CUB := ''
Default cLJoi1T9A := ''
Default cWhere    := ''
Default cFiliais  := ''
Default cDataIni  := ''
Default cDataFim  := ''
Default cCodPar   := ''
Default cNif  	  := ''
Default cQryV3O	  := ''
Default cDtConta  := '2'
Default lApuSTri  := .F.

cFromLEM	:= RetSqlName("LEM") + " LEM "
//Participantes
cIJoiC1H 	:= RetSqlName("C1H") + " C1H ON C1H.C1H_ID = LEM.LEM_IDPART AND C1H.D_E_L_E_T_ = ' ' "
if l4010
	cIJoiC1H += " AND ((C1H.C1H_CPF <> ' ' AND C1H.C1H_PPES = '1')  OR (C1H.C1H_PEEXTE = '1' AND C1H.C1H_PAISEX <> ' ') ) "
else
	cIJoiC1H += "AND ((C1H.C1H_CNPJ <> ' ' AND C1H.C1H_PPES = '2')  OR (C1H.C1H_PEEXTE = '2' AND C1H.C1H_PAISEX <> ' ') ) "
endif
If cCompC1H == "EEE"
	cIJoiC1H += "AND C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
ElseIf cCompC1H == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
	cIJoiC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL, 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " 
ElseIf cCompC1H == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
	cIJoiC1H += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL, 1," + cValToChar(aInfEUF[1]) + ") "
Else
	cIJoiC1H += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "			
EndIf
If !empty(cCNPJC1H)
	cIJoiC1H += " AND C1H.C1H_CNPJ IN (" + cCNPJC1H + ") "
ElseIf !empty(cCPF)
	cIJoiC1H += " AND C1H.C1H_CPF IN (" + cCPF + ") "	
ElseIf !empty(cNif)	
	cIJoiC1H += " AND C1H.C1H_NIF IN (" + cNif + ") "
ElseIf !empty(cCodPar)	
	cIJoiC1H += " AND C1H.C1H_CODPAR IN (" + cCodPar + ") "
EndIf

//Nat.Rend
cIJoiV3S := RetSqlName("V3S") + " V3S ON V3S.V3S_FILIAL = LEM.LEM_FILIAL AND V3S.V3S_ID = LEM.LEM_ID "
cIJoiV3S += " AND V3S.V3S_IDPART = LEM.LEM_IDPART AND V3S.V3S_NUMFAT = LEM.LEM_NUMERO AND V3S.D_E_L_E_T_ = ' ' "
cIJoiV3S += " AND V3S.V3S_IDNATR <> '" + Space(_nTamIDNat) + "' "

//Tributo
cIJoiV47 := RetSqlName("V47") + " V47 ON V47.V47_FILIAL = V3S.V3S_FILIAL AND V47.V47_ID = V3S.V3S_ID "
cIJoiV47 += " AND V47.V47_IDPART = V3S.V3S_IDPART AND V47.V47_NUMFAT = V3S.V3S_NUMFAT AND V47.V47_IDNATR = V3S.V3S_IDNATR AND V47.V47_DECTER = V3S.V3S_DECTER " 
cIJoiV47 += " AND V47.V47_IDTRIB = '000012' AND V47.D_E_L_E_T_ = ' ' " //IR Emissao

//FCI
cLJoiV3X :=  RetSqlName("V3X") + " V3X ON V3X.V3X_ID = V3S.V3S_IFCISC AND V3X.D_E_L_E_T_ = ' ' "
If cCompV3X == "EEE"
	cLJoiV3X += "AND V3X.V3X_FILIAL = LEM.LEM_FILIAL "			
ElseIf cCompV3X == "EEC" .And. aInfEUF[1] + aInfEUF[2] > 0
	cLJoiV3X += "AND SUBSTRING(V3X.V3X_FILIAL,1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL, 1," + cValToChar(aInfEUF[1] + aInfEUF[2]) + ") " 
ElseIf cCompV3X == 'ECC' .And. aInfEUF[1] + aInfEUF[2] > 0
	cLJoiV3X += "AND SUBSTRING(V3X.V3X_FILIAL,1," + cValToChar(aInfEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL, 1," + cValToChar(aInfEUF[1]) + ") "
Else
	cLJoiV3X += " AND V3X.V3X_FILIAL = '" + xFilial("V3X")+ "' "
EndIf

//Natureza
cIJoi1V3O := RetSqlName("V3O") + " V3O ON V3O.V3O_FILIAL = '" + xFilial("V3O") + "' AND V3O.V3O_ID = V3S.V3S_IDNATR AND V3O.D_E_L_E_T_ = ' ' "

//Pais	
cLJoi1C08 := RetSqlName("C08") + " C08 ON C08.C08_FILIAL = '" + xFilial("C08") + "' AND C08.C08_ID = C1H.C1H_PAISEX AND C08.D_E_L_E_T_ = ' ' "

//Relacao Fonte Pagadora
cLJoi1CUB := RetSqlName("CUB") + " CUB ON CUB.CUB_FILIAL = '" + xFilial("CUB") + "' AND CUB.CUB_ID = C1H.C1H_RELFON AND CUB.D_E_L_E_T_ = ' ' "

//Tribut. rend. benef. no Ext.
cLJoi1T9A := RetSqlName("T9A") + " T9A ON T9A.T9A_FILIAL = '" + xFilial("T9A") + "' AND T9A.T9A_ID = C1H.C1H_IDTRIB AND T9A.D_E_L_E_T_ = ' ' "

cWhere	:= " LEM.LEM_FILIAL IN (" + cFiliais + ") AND "
cWhere  += " LEM.LEM_NATTIT = '0' AND "
cWhere  += " LEM."+ iif(cDtConta == '2','LEM_DTEMIS','LEM_DTCONT')+" BETWEEN '" + cDataIni + "' AND '" + cDataFim + "' AND "

If lApuSTri
	cWhere += " V3S.V3S_IDNATR IN " + cQryV3O + " AND "
Else
	If l4010
		cWhere += " V47.V47_IDTRIB IS NOT NULL AND "
	Else
		cWhere += " (V47.V47_BASECA > 0 OR (V47.V47_IDTRIB IS NULL AND V3S.V3S_IDNATR IN " + cQryV3O + " )) AND "
	EndIf
EndIf

cWhere  += " LEM.D_E_L_E_T_ = ' ' "

Return Nil

/*-----------------------------------------------------------------------
{Protheus.doc} QryPagto        
Cria tabela temporaria que será usada na query principal considerndo 
a verificação do pagamento efetuado no mesmo dia que a emissão da fatura
com IR na emissão. Pois se trata de um registro que constará na query 
final da apuração
Obs.: Essa função foi criada para diminuir o tamanho da queru principal
      tornando mais facil a leitura da mesma e evitando error.log em
	  ambientes configurados com postgres.

@Return string(Nome da tabela no banco de dados)

@author Carlos Eduardo Boy
@since  16/12/2022
-----------------------------------------------------------------------*/
Static Function QryPagto(cFromLEM,cIJoiC1H,cIJoiV3S,cIJoiV47,cLJoiV3X,cIJoi1V3O,cLJoi1C08,cLJoi1CUB,cLJoi1T9A,cWhere,oTabTemp)
Local cInto  	:= ''
Local cTabName	:= ''
Local aStruct 	:= {{'FILIAL' , GetSx3Cache('LEM_FILIAL','X3_TIPO'), GetSx3Cache('LEM_FILIAL','X3_TAMANHO'), GetSx3Cache('LEM_FILIAL','X3_DECIMAL')},;			      
                   {'NRNTLEM' , GetSx3Cache('LEM_DOCORI','X3_TIPO'), GetSx3Cache('LEM_DOCORI','X3_TAMANHO'), GetSx3Cache('LEM_DOCORI','X3_DECIMAL')},;
                   {'NUMDOCTO', GetSx3Cache('LEM_NUMERO','X3_TIPO'), GetSx3Cache('LEM_NUMERO','X3_TAMANHO'), GetSx3Cache('LEM_NUMERO','X3_DECIMAL')},;
			       {'SERIE'   , GetSx3Cache('LEM_PREFIX','X3_TIPO'), GetSx3Cache('LEM_PREFIX','X3_TAMANHO'), GetSx3Cache('LEM_PREFIX','X3_DECIMAL')},;
                   {'DTEMISSA', GetSx3Cache('LEM_DTEMIS','X3_TIPO'), GetSx3Cache('LEM_DTEMIS','X3_TAMANHO'), GetSx3Cache('LEM_DTEMIS','X3_DECIMAL')},;
                   {'C1H_ID'  , GetSx3Cache('C1H_ID'	,'X3_TIPO'), GetSx3Cache('C1H_ID'	 ,'X3_TAMANHO'), GetSx3Cache('C1H_ID'	 ,'X3_DECIMAL')} }


//Cria tabela temporaria
oTabTemp	:= FWTemporaryTable():New(,aStruct)
oTabTemp:Create()
cTabName := oTabTemp:GetRealName()	

cInto := " INSERT INTO " + cTabName
cInto += "( FILIAL, NRNTLEM, NUMDOCTO, SERIE, DTEMISSA, C1H_ID ) "
If !("INFORMIX" $ _cBd)
	cInto += "("
EndIf 
cInto += " SELECT DISTINCT "
cInto += " 		LEM.LEM_FILIAL FILIAL, "
cInto += " 		LEM.LEM_DOCORI NRNTLEM, "
cInto += " 		LEM.LEM_NUMERO NUMDOCTO, "
cInto += " 		LEM.LEM_PREFIX SERIE, "
cInto += " 		LEM.LEM_DTEMIS DTEMISSA, "
cInto += " 		C1H.C1H_ID C1H_ID "
cInto += "	FROM " + cFromLEM 
cInto += "		INNER JOIN " + cIJoiC1H 
cInto += "		INNER JOIN " + cIJoiV3S 
cInto += "		INNER JOIN " + cIJoiV47  //Apenas faturas com IR na Emissao e base de cálculo
cInto += "		LEFT JOIN "  + cLJoiV3X  
cInto += "		INNER JOIN " + cIJoi1V3O  
cInto += "		LEFT JOIN "  + cLJoi1C08  
cInto += "		LEFT JOIN "  + cLJoi1CUB 
cInto += "		LEFT JOIN "  + cLJoi1T9A
cInto += "	WHERE " + cWhere 
If !("INFORMIX" $ _cBd)
	cInto += ")"
EndIf 

//Inclui registros na tabela temporária
tcSqlExec( cInto )

return cTabName

//-------------------------------------------------------------------
/*/{Protheus.doc} DtIniLucDiv        
Funcao para retornar o mes inicial para pesquisa dos movimentos com 
natureza 12001 - Lucros e Dividendos, pois conforme NT 11/2023, estes 
poderão ser enviados até 3 meses passados do fato gerador.

@param perApur Período da apuração Ex: "012023"
@Return dataini Data inicial do período para apuração   Ex: 01/10/2022

@author Karen Honda
@since  10/11/2023
/*/
//-------------------------------------------------------------------
Function DtIniLucDiv( perApur )
Local cMonthIni as Character
Local cMes 		as Character
Local cAno		as Character
Local dDataIni  as Date

Default perApur := ""

cMonthIni := ""
cMes	 := SUBSTR(perApur,1,2)
cAno 	 := SUBSTR(perApur,3,4)
dDataIni  := CtoD("//")

Do Case
	Case cMes == "01"
		// mes 10 do ano anterior
		cMonthIni := "10"
		cAno := Str(Val(cAno) - 1,4)
	Case cMes $ "02|03|04"
		// mes 01 do mesmo ano
		cMonthIni := "01"
	Case cMes $ "05|06|07"
		// mes 04 do mesmo ano
		cMonthIni := "04"
	Case cMes $ "08|09|10"
		// mes 07 do mesmo ano
		cMonthIni := "07"
	Case cMes $ "11|12"
		// mes 10 do mesmo ano
		cMonthIni := "10"
EndCase	

dDataIni  := ctod("01/"+cMonthIni+"/"+cAno)

Return dDataIni
