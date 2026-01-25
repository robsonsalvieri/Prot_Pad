#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR4010.CH"                                                                                                                                                                                                                                                "

#DEFINE IDEBENEF  1,1
#DEFINE IDEPGTO   1,2
#DEFINE INFOPGTO  1,3
#DEFINE DETDED    1,4
#DEFINE BENEFPEN  1,5
#DEFINE RENDISEN  1,6
#DEFINE INFOPROC  1,7
#DEFINE DEDSUSP   1,8
#DEFINE DEDBENEF  1,9
#DEFINE CHVREC 	  1,10

Static oModel545 as object
Static lTafRVld	 As Logical
Static nTamFil	:= TamSX3( "C1E_FILTAF" )[1]

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR4010()
Executa a apuração do evento R-4010
@param  cReg,caracter, Nome evento R-4010
@param  cPeriod, caracter, periodo MMAAAA Ex. "092022"
@param aFil, array, array com a filial
@param lValid, logico, se realizar a validação

@author Denis Souza / Jose Mauro / Henrique Pereira / Katielly Feitosa
@since 11/09/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Function TAFAPR4010(cPeriod, aFil, lValid, lSucesso, cCPF, aIDLog, cCodPar, cNIF, lReinf212, lCentApr, cAliasTp, lImp)

Local nOpc		 As Numeric
Local oTR4010    As Object 
Local oTIdePgto  As Object
Local oTInfoPgto As Object
Local oTDetDed   As Object
Local oTBenefPen As Object
Local oTRendIsen As Object
Local oTInfoProc As Object
Local oTChvRec	 As Object
Local oTDedSusp  As Object 
Local oTBenDedSu As Object
Local oModel545	 As Object
Local aTTName 	 As Array
Local aPreMap	 As Array
Local cVerAnt	 As Character
Local cProTpn	 As Character
Local cRetStat	 As Character
Local cId		 As Character 
Local cEvento	 As Character 
Local cErro		 As Character
Local cAmbReinf	 As Character
Local cIDApReinf As Character
Local lOk     	 As Logical
Local lDisarm  	 As Logical
Local lLoteErr   As Logical
Local lApuSTri   As Logical
Local nContLog	 As Numeric
Local aInfEUF 	 As Array
Local cChvV4Q	 As Character

Default cPeriod		:=	" "
Default aFil 		:= {}
Default lValid		:= .F.	
Default lSucesso    := .F.
Default cCPF        := ''
Default aIDLog      := {}
Default cCodPar     := ''
Default cNIF     	:= ''
Default lReinf212  	:= .F.
Default lCentApr  	:= .F.
Default lImp		:= .F.

nOpc	  := MODEL_OPERATION_INSERT
aPreMap   := {}
aTTName   := {}
cVerAnt	  := ''
cProTpn	  := ''
cRetStat  := ''
cId		  := ''
cErro	  := ''
cIDApReinf:= ''
cChvV4Q   := ''
cAmbReinf := Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
lTafRVld  := lValid
lLoteErr  := .T.
nContLog  := 0
aInfEUF   := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
lApuSTri  := GetMv('MV_TAFSTRI',.F.,.F.)

If !lImp
	cAlias := TAFQRY40XX( cPeriod, "R-4010", aFil, aInfEUF, cCPF, /*6*/, .T., cCodPar, cNIF, lReinf212,lApuSTri)
else
	cAlias := cAliasTp
EndIf

//Cria as tabelas temporárias
TTR4010( @aTTName, @oTR4010, @oTIdePgto, @oTInfoPgto, @oTDetDed, @oTBenefPen, @oTRendIsen, @oTInfoProc, @oTDedSusp, @oTBenDedSu, @oTChvRec )

//Grava legado na temporaria
If GRVTMP(cAlias, aTTName, oTR4010, oTIdePgto, oTInfoPgto, oTDetDed, oTBenefPen, oTRendIsen, oTInfoProc, oTDedSusp, oTBenDedSu, oTChvRec, cPeriod, @aPreMap, lReinf212, lCentApr, lImp, lApuSTri)

	//Grava espelho
	DbSelectArea("V4Q")
	V4Q->(DbSetOrder(2))

	( aTTName[IDEBENEF] )->(DbSetOrder(1))
	( aTTName[IDEBENEF] )->(DbGoTop())

	oModel545  := FWLoadModel("TAFA545")
	While (aTTName[IDEBENEF])->(!EOF())
		cEvento  := ""
		cVerAnt  := "" 
		cProTpn  := ""
		cRetStat := ""  
		cId 	 := ""
		lOk    	  := .T.
		lDisarm	  := .F.

		//Verifica Situacao do Registro
		Stats40XX( "R-4010", cPeriod + (aTTName[IDEBENEF])->( CTPINSC + CNRINSC + CCPFBENEF + CIDEXT + Iif(lReinf212, CEVADIC, Space(8)) ), @cVerAnt, @cProTpn, @cRetStat, @cId )		
		cIDApReinf := TAFXLogIni( cIDApReinf, "R-4010", cPeriod )
		Begin Transaction

			If cRetStat $ 'Z' 
				nOpc	:= MODEL_OPERATION_INSERT
				cEvento	:= 'I'
				If !GRV4010(nOpc, @oModel545, aTTName, aFil, cPeriod,nil, nil, cEvento, nil,  @aPreMap, cAmbReinf, @aIDLog, cIDApReinf, lReinf212, lCentApr, lImp)
					lOk    	  := .F.
					lDisarm	  := .T.
				EndIf
			Elseif cRetStat $ ' |0|1|3|7'				
				If ExcluiReg(@aIDLog, "R-4010", @aPreMap, @oModel545, cPeriod, cIDApReinf)
					nOpc := MODEL_OPERATION_INSERT
					If cRetStat<>'7' .And. V4Q->V4Q_EVENTO=='A'
						cEvento	:= 'A'
						If !GRV4010(nOpc, @oModel545, aTTName, aFil, cPeriod, V4Q->V4Q_VERANT, V4Q->V4Q_PROTPN, cEvento, cID,  @aPreMap, cAmbReinf, @aIDLog, cIDApReinf, lReinf212, lCentApr, lImp)
							lOk    	  := .F.
							lDisarm	  := .T.
						EndIf
					else
						cEvento := 'I'
						If !GRV4010(nOpc, @oModel545, aTTName, aFil, cPeriod, nil, nil, cEvento, nil,  @aPreMap, cAmbReinf, @aIDLog, cIDApReinf, lReinf212, lCentApr, lImp)
							lOk    	  := .F.
							lDisarm	  := .T.
						EndIf
					EndIf
				EndIf
			Elseif cRetStat $ '2|6'
				cErro := STR0017 + CRLF //"Registro transmitido ao governo e sem retorno, não deve ser alterado." + CRLF
				cErro += STR0007 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
				cErro += "tpInscEstab: " + (aTTName[IDEBENEF])->CTPINSC + CRLF
				cErro += "nrInscEstab: " + (aTTName[IDEBENEF])->CNRINSC + CRLF + CRLF
				cErro += "cnpjPrestador: " +  (aTTName[IDEBENEF])->CCPFBENEF  + CRLF
				Aadd( aPreMap, {"R-4010", "ERRO", cErro, (aTTName[IDEBENEF])->FIL + '|' + cPeriod + '|' +(aTTName[IDEBENEF])->CTPINSC + '|' + (aTTName[IDEBENEF])->CNRINSC +'|'+ (aTTName[IDEBENEF])->CCPFBENEF + '|' +(aTTName[IDEBENEF])->CIDEXT + '|' + (aTTName[IDEBENEF])->CEVADIC} )
				If !lImp
					aAdd( aIDLog, { cIDApReinf, (aTTName[IDEBENEF])->FIL, Iif( !Empty((aTTName[IDEBENEF])->CCPFBENEF), Alltrim((aTTName[IDEBENEF])->CCPFBENEF), Alltrim((aTTName[IDEBENEF])->CIDEXT)) } )
				else
					aAdd( aIDLog, { cIDApReinf, (aTTName[IDEBENEF])->FIL, Iif( !Empty((aTTName[IDEBENEF])->CCPFBENEF), Alltrim((aTTName[IDEBENEF])->CCPFBENEF), Alltrim((aTTName[IDEBENEF])->CIDEXT)), cErro } )
				EndIf
				lOk := .F.
				lDisarm	  := .F.
			Elseif cRetStat == '4'
				cVerAnt := V4Q->V4Q_VERSAO
				cProTpn := V4Q->V4Q_PROTUL
				cId		:= V4Q->V4Q_ID 
				FAltRegAnt( 'V4Q', '2', .F. )
				nOpc	:= MODEL_OPERATION_INSERT
				cEvento	:= 'A'
				If !GRV4010(nOpc, @oModel545, aTTName, aFil, cPeriod, cVerAnt, cProTpn, cEvento, cId,  @aPreMap, cAmbReinf, @aIDLog, cIDApReinf, lReinf212, lCentApr, lImp)
					lOk    	  := .F.
					lDisarm	  := .T.
				EndIf	
			EndIf
			if lLoteErr //Se lLoteErr for o false nao devera ser mais sobreposto com true, pois indica se o lote possui algum problema
				lLoteErr := lOk
			EndIf
			If lDisarm
				DisarmTransaction()
			EndIf
		End Transaction
		

		For nContLog := 1 to Len (aPreMap) 
			cChvV4Q := cPeriod + '|' +(aTTName[IDEBENEF])->CTPINSC + '|' + (aTTName[IDEBENEF])->CNRINSC +'|'+ (aTTName[IDEBENEF])->CCPFBENEF
			cChvV4Q += '|' + (aTTName[IDEBENEF])->CIDEXT
			cChvV4Q += '|' + (aTTName[IDEBENEF])->CEVADIC

			nPos := aScan(aPreMap,{|x| cChvV4Q $ x[04] })
			If nPos > 0
				TafXLog(cIdApReinf, aPreMap[nContLog][1], aPreMap[nContLog][2], aPreMap[nContLog][3], cPeriod )
			EndIf	
		Next nContLog

		TAFXLogFim( cIDApReinf, "R-4010" , cPeriod )
		(aTTName[IDEBENEF])->(DbSkip())
	EndDo
	
	oModel545:Destroy()
	oModel545 := Nil

EndIf

TTempDel( @oTR4010, @oTIdePgto, @oTInfoPgto, @oTDetDed, @oTBenefPen, @oTRendIsen, @oTInfoProc, @oTChvRec, @oTDedSusp, @oTBenDedSu )

lSucesso := lLoteErr

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TTR4010()
Criação das tabelas temporárias referente ao evento R-4010

@author Henrique Pereira
@since 21/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTR4010(aTTName, oTR4010, oTIdePgto, oTInfoPgto, oTDetDed, oTBenefPen, oTRendIsen, oTInfoProc, oTDedSusp, oTBenDedSu, oTChvRec)
                 
	Local cTR4010     as character
	Local cTIdePgto   as character 
	Local cTInfoPgto  as character
	Local cTDetDed    as character
	Local cTBenefPen  as character 
	Local cTRendIsen  as character
	Local cTInfoProc  as character
	Local cTDedSusp	  as character
	Local cTBenDedSu  as character	
	
	Local cChvRec	  as character
	
	Local aTR4010     as  array
	Local aTIdePgto   as  array
	Local aTInfoPgto  as  array
	Local aTDetDed    as  array
	Local aTBenefPen  as  array
	Local aTRendIsen  as  array
	Local aTInfoProc  as  array
	Local aTDedSusp   as  array
	Local aTBenDedSu  as  array
	Local aChvRec     as  array

	// Incialização variaveis tipo caractere para armazenagem dos alias das temp tables
	cTR4010      := getNextAlias()
	cTIdePgto    := getNextAlias()
	cTInfoPgto   := getNextAlias()
	cTDetDed     := getNextAlias()
	cTBenefPen   := getNextAlias()
	cTRendIsen   := getNextAlias()
	cTInfoProc   := getNextAlias()
	cTDedSusp	 := getNextAlias()
	cTBenDedSu	 := getNextAlias()
	cChvRec      := getNextAlias()

	//Array com nome de todas as tabelas temporarias
	aAdd(aTTName,{ cTR4010, cTIdePgto, cTInfoPgto, cTDetDed, cTBenefPen, cTRendIsen, cTInfoProc,  cTDedSusp, cTBenDedSu, cChvRec })

	// Incialização variaveis tipo array para armazenagem dos canpos das temp tables
	aTR4010      := {}
	aTIdePgto    := {}
	aTInfoPgto   := {}
	aTDetDed     := {}
	aTBenefPen   := {}
	aTRendIsen   := {}
	aTInfoProc   := {}
	aTDedSusp	 := {}
	aTBenDedSu   := {}
	aChvRec		 := {}
	
	//Popula os campos das tabelas temporárias
	TTempCmp(@aTR4010, @aTIdePgto, @aTInfoPgto, @aTDetDed, @aTBenefPen, @aTRendIsen, @aTInfoProc, @aTDedSusp, @aTBenDedSu, @aChvRec )
	
	oTR4010     :=  FWTemporaryTable():New(cTR4010   , aTR4010   ) //ideEstab e ideBenef
	oTIdePgto   :=  FWTemporaryTable():New(cTIdePgto , aTIdePgto ) //idePgto
	oTInfoPgto  :=  FWTemporaryTable():New(cTInfoPgto, aTInfoPgto) //infoPgto
	oTDetDed    :=  FWTemporaryTable():New(cTDetDed  , aTDetDed  ) //detDed
	oTBenefPen  :=  FWTemporaryTable():New(cTBenefPen, aTBenefPen) //detDed - benefPen
	oTRendIsen  :=  FWTemporaryTable():New(cTRendIsen, aTRendIsen) //rendIsento
	oTInfoProc  :=  FWTemporaryTable():New(cTInfoProc, aTInfoProc) //infoProcRet
	oTDedSusp   :=  FWTemporaryTable():New(cTDedSusp , aTDedSusp ) //dedSusp
	oTBenDedSu  :=  FWTemporaryTable():New(cTBenDedSu, aTBenDedSu) //dedSusp - benefPen
	oTChvRec    :=  FWTemporaryTable():New( cChvRec  , aChvRec   )
	
	TTempIdx(@oTR4010, @oTIdePgto, @oTInfoPgto, @oTDetDed, @oTBenefPen, @oTRendIsen, @oTInfoProc, @oTDedSusp, @oTBenDedSu, @oTChvRec)
	
Return 
	
//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj()
Criação dos campos para as tabelas temporárias referente ao evento R-4010

@author Henrique Pereira
@since 21/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTempCmp(aTR4010, aTIdePgto, aTInfoPgto, aTDetDed, aTBenefPen, aTRendIsen, aTInfoProc, aTDedSusp, aTBenDedSu, aChvRec)
				
Local nTamFil := TamSX3( "C20_FILIAL" )[1]  

		aTR4010	    :=  {{'ID'		        ,'C', 250     	,0},;
						{'FIL'		   		,'C', nTamFil 	,0},; //Dinamizar Filial  -->#Importante
						{'CTPINSC'	        ,'C', 01	  	,0},; //tpInscEstab
						{'CNRINSC'	        ,'C', 14	  	,0},; //nrInscEstab 
						{'CIDPART'	        ,'C', 36	  	,0},; //ID Participante 
						{'CCPFBENEF'	    ,'C', 11	  	,0},; //cpfBenef
						{'CNMBENEF'	        ,'C', 70	  	,0},; //nmBenef
						{'CIDEXT'	    	,'C', 60	  	,0},; //Id Exterior: NIF ou CODPAR
						{'CPAISEXT'         ,'C', 003		,0},; //pais Exterior
						{'CEVADIC'	        ,'C', 08	  	,0},;  //ideEvtAdic
						{'ORIGEM'	        ,'C', 01	  	,0}} 
	
		aTIdePgto   :=  {{'ID'              ,'C', 250		,0},;
						{'FIL'		   		,'C', nTamFil	,0},; //Dinamizar Filial  -->#Importante
						{'CNATREND'         ,'C', 006		,0},; //natRend ID TAF
						{'COBSERV'          ,'C', 200		,0}}  //observ
	
		aTInfoPgto  :=  {{'ID'              ,'C', 250		,0},;
						{'FIL'		   		,'C', nTamFil	,0},; //Dinamizar Filial  -->#Importante
						{'DDTFG'            ,'D', 008		,0},; //dtFG
						{'CCOMPFP'          ,'C', 006		,0},; //compFP
						{'CINDDECTER'       ,'C', 001		,0},; //indDecTerc
						{'NVLRRENDBR'       ,'N', 014		,2},; //vlrRendBruto
						{'NVLRRENDTR'       ,'N', 014		,2},; //vlrRendTrib    
						{'NVLRIR'           ,'N', 014		,2},; //vlrIR
						{'CJUDRRA'          ,'C', 036		,0},; //infoRRA-Id
						{'CINDFCISCP'       ,'C', 001		,0},; //indFciScp
						{'CNRINSFCSC'       ,'C', 014		,0},; //nrInscFciScp
						{'CIDFCISCP'        ,'C', 036		,0},; //nrInscFciScp
						{'NPERCSCP'         ,'N', 004		,1},; //percSCP
						{'CPAISRESID'       ,'C', 003		,0},; //paisResidExt
						{'BAIEXT'			,'C', 060       ,0},;
                		{'LOGEXT'			,'C', 080       ,0},;
                		{'NUMEXT'			,'C', 010       ,0},;
                		{'NMCEXT'			,'C', 040       ,0},;
						{'INDNIF'			,'C', 001       ,0},;
                		{'NIF'				,'C', 030       ,0},;
                		{'IDTRIB'			,'C', 036       ,0},;
                		{'DESCID'			,'C', 220       ,0},;
						{'IDTRIB2'			,'C', 002       ,0},;
						{'DDTESCRCT'        ,'D', 008		,0},; //dtEscrCont
						{'COBSERV'          ,'C', 200		,0}}  //observ

		aTDetDed    :=  {{'ID'              ,'C', 250		,0},;
						{'FIL'		   		,'C', nTamFil	,0},; //Dinamizar Filial  -->#Importante
						{'CINDTPDEDU'       ,'C', 002		,0},; //indTpDeducao
						{'NVLRDEDUCA'       ,'N', 014		,2},; //vlrDeducao
						{'CINFOENTID'       ,'C', 001		,0},;  //infoEntid
						{'CNRINSCPRE'       ,'C', 014		,0},;  //nrInscPrevComp
						{'NVLRFUNP'       	,'N', 014		,2}}  //vlrPatrocFunp
	
		aTBenefPen  :=  {{'ID'              ,'C', 250		,0},;
						{'FIL'		   		,'C', nTamFil	,0},; //Dinamizar Filial  -->#Importante
						{'CCPF'             ,'C', 011		,0},;   //cpf
						{'CNOME'            ,'C', 060		,0},;   //nome
						{'NVLRDEPEN'        ,'N', 014		,2}}    //vlrDepen
	
		aTRendIsen  :=  {{'ID'              ,'C', 250		,0},;
						{'FIL'		   		,'C', nTamFil	,0},; //Dinamizar Filial  -->#Importante  
						{'CTPISENCAO'       ,'C', 002		,0},;   //tpisencao'    
						{'CIDISENCAO'       ,'C', 006		,0},;   //ID tipo isenção'   
						{'CDSISENCAO'       ,'C', 100		,0},;   //tpisencao'   
						{'NVLRISENTO'       ,'N', 014		,2},;   //vlrisento'     
						{'CDESCRENDI'       ,'C', 100		,0},;   //descrendimento'
						{'DDTLAUDO'         ,'D', 008		,0}}    //dtlaudo'       
	
		aTInfoProc  :=  {{'ID'              ,'C' ,250		,0},;
						{'FIL'		   		,'C' ,nTamFil	,0},; //Dinamizar Filial  -->#Importante
						{'CTPPROCRET'       ,'C' ,001		,0},; //tpProcRet
						{'CNRPROCRET'       ,'C' ,021		,0},; //nrProcRet
						{'CODSUSP'          ,'C' ,014		,0},; //codSusp
						{'NVLRNRETID'       ,'N' ,014		,2},; //vlrNRetido
						{'NVLRDEP'          ,'N' ,014		,2},; //vlrDepJud
						{'NVLRANO'          ,'N' ,014		,2},; //vlrCmpAnoCal
						{'NVLRANA'          ,'N' ,014		,2},; //vlrCmpAnoAnt
						{'NVLRBSSUSP'       ,'N' ,014		,2}}  //vlrRendSusp
	
		aTDedSusp   :=  {{'ID'              ,'C' ,252		,0},;
						{'FIL'		   		,'C' ,nTamFil	,0},; //Dinamizar Filial  -->#Importante
						{'CINDTPDEDU'       ,'C' ,001		,0},; //indTpDeducao
						{'NVLRDEDSUS'       ,'N' ,014		,2}} //vlrDedSusp

		aTBenDedSu   :=  {{'ID'              ,'C' ,265		,0},;
						{'FIL'		   		,'C' ,nTamFil	,0},; //Dinamizar Filial  -->#Importante
						{'CCPFDEP'       	,'C' ,011		,0},; //cpfDep
						{'NVLRDEPSUS'       ,'N' ,014		,2}}  //vlrDepenSusp

	    aChvRec 	:=  {{'CHAVE'   ,'C', 250, 0},;
					    {'NREGISTR' ,'N', 020, 0},;
				        {'CROTINA'  ,'C', 003, 0},;
						{'CCNATRE'  ,'C', 005, 0}}

Return 
	
//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj()
Criação dos indice das tabelas temporárias referente ao evento R-4010

@author Henrique Pereira
@since 21/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTempIdx(oTR4010, oTIdePgto, oTInfoPgto, oTDetDed, oTBenefPen, oTRendIsen, oTInfoProc, oTDedSusp, oTBenDedSu, oTChvRec )
				
oTR4010:AddIndex("1", {"ID"})   
oTIdePgto:AddIndex("1", {"ID"})
oTInfoPgto:AddIndex("1", {"ID"})
oTDetDed:AddIndex("1", {"ID"})
oTBenefPen:AddIndex("1", {"ID"})
oTRendIsen:AddIndex("1", {"ID"})
oTInfoProc:AddIndex("1", {"ID"})
oTDedSusp:AddIndex("1", {"ID"})
oTBenDedSu:AddIndex("1", {"ID"})
oTChvRec:AddIndex("1", {"CHAVE"})

//Cria a tabela fisicamente 
oTR4010:Create()    
oTIdePgto:Create()  
oTInfoPgto:Create()
oTDetDed:Create()   
oTBenefPen:Create() 
oTRendIsen:Create() 
oTInfoProc:Create() 
oTDedSusp:Create()
oTBenDedSu:Create()
oTChvRec:Create() 

Return
	
//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj()
Mecanismo de destruição das tabelas temporárias referente ao evento R-4010

@author Henrique Pereira
@since 21/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTempDel(oTR4010, oTIdePgto, oTInfoPgto, oTDetDed, oTBenefPen, oTRendIsen, oTInfoProc,  oTChvRec, oTDedSusp, oTBenDedSu )
	
oTR4010:Delete()    
oTIdePgto:Delete()  
oTInfoPgto:Delete() 
oTDetDed:Delete()   
oTBenefPen:Delete() 
oTRendIsen:Delete() 
oTInfoProc:Delete() 

oTChvRec:Delete()
oTDedSusp:Delete()
oTBenDedSu:Delete()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} GRVTMP()

Varre o retorno da query (cAlias) e grava as tabelas temporárias, de acordo
as regras do layout.  

@author Henrique Pereira e Katielly Rezende;
@since 20/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function GRVTMP(cAlias, aTTName, oTR4010, oTIdePgto, oTInfoPgto, oTDetDed, oTBenefPen, oTRendIsen, oTInfoProc, oTDedSusp, oTBenDedSu, oTChvRec, cPeriod, aPreMap, lReinf212, lCentApr, lImp, lApuSTri)

Local lAvanc   		As Logical
Local cTpInscE 		As Character
Local cNrInscE 		As Character
Local cChvReg  		As Character
Local cCodNat       As Character
Local cCompC1G		As Character
Local aSM0EUF		As Character
Local cCompFP		As Character
Local cChaveV4R		As Character
Local cChaveV4X		As Character
Local dFatoGer		As DATE
Local cPaisRend		As Character
Local nValDed		As Numeric
Local cIdEvAdic		As Character

Default cAlias		:= Nil
Default aTTName		:= {}
Default oTR4010		:= Nil
Default oTIdePgto	:= Nil
Default oTInfoPgto	:= Nil
Default oTDetDed	:= Nil
Default oTBenefPen	:= Nil
Default oTRendIsen	:= Nil
Default oTInfoProc	:= Nil
Default oTDedSusp   := Nil
Default oTBenDedSu  := Nil
Default oTChvRec    := Nil
Default cPeriod		:= ""
Default aPreMap		:= {}
Default lReinf212  	:= .F.
Default lCentApr  	:= .F.
Default lApuSTri    := .F.

lAvanc   	:= .T. 
cTpInscE 	:= ""
cNrInscE 	:= ""
cChvReg  	:= ""
cCodNat	    := ""
cCompC1G	:= ""
aSM0EUF		:= {}
cCompFP 	:= ""
cChaveV4R	:= ""	
cChaveV4X	:= ""	
cPaisRend	:= ""	
cIdEvAdic	:= ""

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

DbSelectArea("C08")
C08->(DbSetOrder(3))

DbSelectArea("V3Q")
V3Q->(DbSetOrder(1))

DbSelectArea("V3R")
V3R->(DbSetOrder(1))

DbSelectArea("V4E")
V4E->(DbSetOrder(1))


If (cAlias)->(!EOF())

	aSM0EUF	 :=	TafTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	cCompC1G := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3))) // 1=Empresa, 2=Unidade de Negócio e 3=Filial
	
	cNrInscE := Posicione("SM0", 1, cEmpAnt + (cAlias)->FILIAL, "M0_CGC")
	If Len(Alltrim(cNrInsce))>11 .And. Len(Alltrim(cNrInsce))<=14
		cTpInscE:="1"
	Elseif Len(Alltrim(cNrInsce))<=11
		cTpInscE:="2"
	EndIf
	dbSelectArea("C1E")
	C1E->(dbSetOrder(3))
	If C1E->(MSSeek(XFilial("C1E")+PadR((cAlias)->FILIAL, nTamFil)+"1"))
		If !Empty(C1E->C1E_CAEPFR) .And. (Len(Alltrim(cNrInscE))<=11)
			cTpInscE := "3"
			cNrInscE := C1E->C1E_CAEPFR
		EndIf
		If lReinf212
			cIdEvAdic := C1E->C1E_EVADIC
		EndIf	
	EndIf	
	
	DbSelectArea( aTTName[CHVREC] )
	( aTTName[CHVREC] )->(DbSetOrder(1))

	DbSelectArea( aTTName[IDEBENEF] )
	( aTTName[IDEBENEF] )->(DbSetOrder(1)) 

	DbSelectArea( aTTName[IDEPGTO] )
	( aTTName[IDEPGTO] )->(DbSetOrder(1)) 

	DbSelectArea( aTTName[INFOPGTO] ) 
	( aTTName[INFOPGTO] )->(DbSetOrder(1)) 

	DbSelectArea( aTTName[INFOPROC] ) 
	( aTTName[INFOPROC] )->(DbSetOrder(1))

	DbSelectArea( aTTName[DEDSUSP] ) 
	( aTTName[DEDSUSP] )->(DbSetOrder(1))

	DbSelectArea( aTTName[DEDBENEF] ) 
	( aTTName[DEDBENEF] )->(DbSetOrder(1))

	DbSelectArea( aTTName[DETDED] ) 
	( aTTName[DETDED] )->(DbSetOrder(1))

	DbSelectArea( aTTName[BENEFPEN] ) 
	( aTTName[BENEFPEN] )->(DbSetOrder(1))

	DbSelectArea( aTTName[RENDISEN] ) 
	( aTTName[RENDISEN] )->(DbSetOrder(1))
	
	While (cAlias)->(!EOF())
		cPaisRend := ""
		If C08->( MsSeek(xFilial("C08")+(cAlias)->CODPAI) ) 
			cPaisRend := C08->C08_CREINF
		EndIf	
		//O agrupamento ocorre por CPF para as filiais de mesmo CNPJ
		cChvReg := /*(cAlias)->FILIAL + '|' + */ cPeriod + '|' +cTpInscE +'|' + cNrInscE + '|' + (cAlias)->CPF 
		If !Empty(cPaisRend)
			If !Empty((cAlias)->NIF)
				cChvReg += '|' + PADR((cAlias)->NIF,60) 
			ElseIf !Empty((cAlias)->CODPAR)
				cChvReg += '|' + PADR((cAlias)->CODPAR,60)
			Else
				cChvReg += '|' + PADR((cAlias)->NOME,60)
			EndIf
		Else
			cChvReg += '|' + Space(60)	
		EndIf	
		If lReinf212
			cChvReg += IIF(lImp,'|' + PADR((cAlias)->CEVADIC,8),'|' + PADR(cIdEvAdic,8))
		EndIf	
		
		//--------------------------------------------------------------------
		// Controle de RECNO dos legados utilizados em cada chave de apuração
		// controle necessário devido Commit\RollBack
		//--------------------------------------------------------------------
		RecLock(aTTName[CHVREC],.T.)
		(aTTName[CHVREC])->CHAVE    := cChvReg
		(aTTName[CHVREC])->NREGISTR := (cAlias)->RECNO
		(aTTName[CHVREC])->CROTINA  := (cAlias)->ROTINA
		(aTTName[CHVREC])->CCNATRE  := (cAlias)->CCNATRE		
		(aTTName[CHVREC])->(MsUnlock())
		
		//-------------------------------------------- 
		// 					ideBenef 
		//--------------------------------------------
		If !(aTTName[IDEBENEF])->(DbSeek(cChvReg))
			RecLock(aTTName[IDEBENEF],.T.)								
			(aTTName[IDEBENEF])->ID		   := cChvReg 
			(aTTName[IDEBENEF])->FIL	   := (cAlias)->FILIAL
			(aTTName[IDEBENEF])->CTPINSC   := cTpInscE
			(aTTName[IDEBENEF])->CNRINSC   := cNrInscE
			(aTTName[IDEBENEF])->CIDPART   := (cAlias)->C1H_ID
			(aTTName[IDEBENEF])->CCPFBENEF := (cAlias)->CPF
			(aTTName[IDEBENEF])->CNMBENEF  := (cAlias)->NOME
			(aTTName[IDEBENEF])->CEVADIC   := IIF(lImp,(cAlias)->CEVADIC,cIdEvAdic)
			(aTTName[IDEBENEF])->ORIGEM	   := IIF(lImp,'I','')

			If !Empty(cPaisRend)
				If !Empty((cAlias)->NIF)
					(aTTName[IDEBENEF])->CIDEXT := (cAlias)->NIF 
				ElseIf !Empty((cAlias)->CODPAR)
					(aTTName[IDEBENEF])->CIDEXT := (cAlias)->CODPAR
				Else
					(aTTName[IDEBENEF])->CIDEXT := (cAlias)->NOME
				EndIf
				(aTTName[IDEBENEF])->CPAISEXT  := cPaisRend

				If Empty((cAlias)->INDNIF) 
					Aadd( aPreMap, {"R-4010", Iif(lTafRVld, "ERRO", "ALERTA"), STR0018, cChvReg } ) 	//"Indicador NIF não preenchido."			
				EndIf
				If Empty((cAlias)->IDTRIB) 	
					Aadd( aPreMap, {"R-4010", Iif(lTafRVld, "ERRO", "ALERTA"), STR0019, cChvReg } ) //"Forma de tributação não preenchida."				
				EndIf	
			EndIf

			(aTTName[IDEBENEF])->(MsUnlock())
		EndIf

		cCodNat := (cAlias)->IDNATR 
		cCompFP := padr(StrTran((cAlias)->COMPFP,"-",""),06) // AAAA ou AAAAMM

		cChaveV4R := cChvReg + '|' + cCodNat

		//-------------------------------------------- 
		// 					idePgto 
		//--------------------------------------------
		PopIdePgto( cAlias, cCodNat, @aTTName[IDEPGTO], cChaveV4R )

		dFatoGer := Ctod("  /  /    ")
		If (cAlias)->ROTINA == "PGT"
			dFatoGer := (cAlias)->DTPV3U
		ElseIf (cAlias)->ROTINA == "INT"
            dFatoGer := StoD((cAlias)->DTEMISSA)
		Else 
			dFatoGer := (cAlias)->DTEMISSA
		EndIf	

		cChaveV4X := cChaveV4R + '|' + (cAlias)->CODPAI + '|' + Dtos( dFatoGer ) + '|' + cCompFP + '|' + (cAlias)->DECTER + "|" + (cAlias)->IDRRAPJD + "|" + (cAlias)->INDFCISCP + "|" + (cAlias)->IDSCP
		
		//-------------------------------------------- 
		// 					infoProcRet 
		//--------------------------------------------
		If !(cAlias)->ROTINA == 'PLS'
			If !lImp
				PopProcRet( cAlias, @aTTName, cChaveV4X, cCompC1G, aSM0EUF, cChvReg, @aPreMap, lCentApr, lApuSTri)
			EndIf
			
			//-------------------------------------------- 
			// 					detDed
			//--------------------------------------------
			nValDed := 0
			If !lImp
				PopDetDed(cAlias, @aTTName, cChaveV4X, cChvReg, @aPreMap, @nValDed)
			EndIf

			//-------------------------------------------- 
			// 					infoPgto 
			//--------------------------------------------
			PopInfoPgt(  cAlias, cCodNat, cPaisRend, dFatoGer, @aTTName[INFOPGTO], cChvReg, cChaveV4X, @aPreMap, nValDed, lReinf212, lImp )
			
			//--------------------------------------------  
			// 					rendIsento		
			//--------------------------------------------
			If !lImp
				PopRendIsen(cAlias, @aTTName, cChaveV4X)
			EndIf
		Endif

		(cAlias)->(DbSkip())
	EndDo
	
Else
	lAvanc := .F.
EndIf

(cAlias)->(DbCloseArea())  

return lAvanc

//-------------------------------------------------------------------
/*/{Protheus.doc} GRV4010
Efetua gravação das tabelas espelhos, do evento 
R-4010- Retenções na Fonte Pessoa Física;

@author Katielly Feitosa; Henrique Pereira
@since   29/08/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function GRV4010(nOpc, oModel545, aTTName, aFil, cPerApu, cVerAnt, cProTpn, cEvento, cId,  aPreMap, cAmbReinf, aIDLog, cIDApReinf, lReinf212, lCentApr, lImp)

Local aAreaSM0 	As Array
Local aInfoC1E	As Array
Local aMovs     As Array
Local oModelV4Q As Object
Local oModelV86 As Object
Local oModelV4R As Object
Local oModelV5E As Object
Local oModelV5Eg As Object
Local oModelV5Eh As Object
Local oModelV4T As Object
Local oModelV4V As Object
Local oModelV4X As Object
Local oModelV92 As Object
Local oModelV93 As Object
Local oModelV4U As Object
Local oModelV4Y As Object
Local oModelV4Z As Object
Local oModelV5A As Object
Local oModelV5B As Object

Local cAlias4Q	As Character
Local cAlias4R	As Character
Local cAlias5E	As Character
Local cAlias4T  As Character
Local cAlias4U  As Character
Local cAlias4V  As Character
Local cAlias92  As Character
Local cAlias93  As Character
Local cAliasChv As Character
Local cAliasV4B  As Character

Local cChvV4R   As Character
Local cChvV5E   As Character
Local cChvV4U   As Character
Local cChvV92   As Character
Local nContv4t	As Numeric
Local nContv4u	As Numeric
Local nContv4X	As Numeric
Local nContv4V	As Numeric
Local nContv4y	As Numeric
Local nContv5A	As Numeric
Local nContv4z	As Numeric

Local nTamFil	 As Numeric
Local nC1EArray	 As Numeric
Local nInscrPLS  As Character
Local nInscrMed  As Character
Local cCNatRen	 As Character
Local cDNatRen	 As Character
Local cIdNat	 As Character
Local cDtFGer    As Character
Local cDecTer    As Character
Local cTipoProc  As Character
Local cCpfDep 	 As Character
Local cIdtrib    As Character
Local cFormatrib As Character
Local cDescTrib  As Character
Local cFilBenef  As Character
Local cCPFBen	 As Character

Local cPaisExt   As Character
Local cIdExt   	 As Character
Local cLogExt    As Character
Local cNumExt    As Character
Local cComExt    As Character
Local cBaiExt    As Character
Local cCidExt    As Character
Local cEstExt    As Character
Local cCxaExt    As Character
Local cTelExt    As Character

Local nVlrPgD	 As Numeric
Local nVlrPag	 As Numeric
Local nVlrReemb	 As Numeric
Local nVlrAnt	 As Numeric

Local lOk		 As Logical
Local aDivid     As Array // Array com os recnos dos dividendos

Default nOpc  	   := 0
Default aTTName    := {}
Default aFil 	   := {}
Default cPerApu    := ""
Default cVerAnt	   := ""
Default cProTpn	   := ""
Default cEvento    := "I"
Default cId		   := ""
Default aPreMap	   := {}
Default cAmbReinf  := ""
Default aIDLog     := {}
Default cIDApReinf := ""
Default lReinf212 := .F.
Default lCentApr  := .F.

aAreaSM0  := SM0->(GetArea())
aInfoC1E  := {}
lOk 	  := .T.
cCNatRen  := ""

cAlias4Q  := aTTName[IDEBENEF]
cAlias4R  := aTTName[IDEPGTO]
cAlias5E  := aTTName[INFOPGTO]
cAlias4T  := aTTName[DETDED]
cAlias4U  := aTTName[BENEFPEN]	
cAlias4V  := aTTName[RENDISEN]
cAlias4X  := aTTName[INFOPROC]
cAlias92  := aTTName[DEDSUSP]	
cAlias93  := aTTName[DEDBENEF]	
cAliasChv := aTTName[CHVREC]
cAliasV4B := ""
cChvV4R	  := ""
cChvV5E   := ""
cChvV4U	  := ""
cChvV92   := ""
nInscrPLS := ""
nInscrMed := ""

nContv4t  := 0
nContv4u  := 0
nContv4X  := 0
nContv4V  := 0

cIdNat	   := ""
cDtFGer    := ""
cDecTer    := "" 
cTipoProc  := ""
cPaisExt   := ""
cIdExt	   := ""	
cFilBenef  := ""
cCPFBen	   := ""
cFormaTrib := ""
cDescTrib  := ""
cIdTrib	   := "" 
cLogExt    := " " 
cNumExt    := " " 
cComExt    := " " 
cBaiExt    := " " 
cCidExt    := " "
cEstExt    := " " 
cCxaExt    := " " 
cTelExt    := " " 

nTamFil   := len( aFil )
nC1EArray := ASCAN(aFil,{|x|x[7]})

If nC1EArray > 0
	AADD(aInfoC1E,aFil[nC1EArray][1])
	AADD(aInfoC1E,aFil[nC1EArray][4])
Elseif nTamFil > 0
	AADD(aInfoC1E,aFil[nTamFil][1])
	AADD(aInfoC1E,aFil[nTamFil][4])
EndIf

oModelV4Q := oModel545:GetModel( "MODEL_V4Q" )
oModelV86 := oModel545:GetModel( "MODEL_V86" )
oModelV4R := oModel545:GetModel( "MODEL_V4R" )
oModelV5E := oModel545:GetModel( "MODEL_V5Ea" )
oModelV5Eg := oModel545:GetModel( "MODEL_V5Eg" )
oModelV5Eh := oModel545:GetModel( "MODEL_V5Eh" )
oModelV4T := oModel545:GetModel( "MODEL_V4T" )
oModelV4V := oModel545:GetModel( "MODEL_V4V" )
oModelV4X := oModel545:GetModel( "MODEL_V4X" )
oModelV92 := oModel545:GetModel( "MODEL_V92" )
oModelV93 := oModel545:GetModel( "MODEL_V93" )

oModelV4U := oModel545:GetModel( "MODEL_V4U" ) 
oModelV4Y := oModel545:GetModel( "MODEL_V4Y" )
oModelV4Z := oModel545:GetModel( "MODEL_V4Z" )
oModelV5A := oModel545:GetModel( "MODEL_V5A" )
oModelV5B := oModel545:GetModel( "MODEL_V5B" )

oModel545:SetOperation(nOpc)
oModel545:Activate() 

V4Q->(DbSetOrder(2)) //V4Q_FILIAL+V4Q_PERAPU+V4Q_TPINSC+V4Q_NRINSC+V4Q_CPF+V4Q_IDEXTE+V4Q_ATIVO
( cAlias4R )->(DbSetOrder(1))
( cAlias5E )->(DbSetOrder(1))
( cAlias4T )->(DbSetOrder(1))
( cAlias4U )->(DbSetOrder(1)) 
( cAlias4V )->(DbSetOrder(1)) 
( cAlias4X )->(DbSetOrder(1))
( cAlias92 )->(DbSetOrder(1))
( cAlias93 )->(DbSetOrder(1))
( cAliasChv )->(DbSetOrder(1))

DbSelectArea( "V3O" ) 
V3O->(DbSetOrder(2)) 

DbSelectArea( "T9A" ) 
T9A->(DbSetOrder(1))

DbSelectArea( "C1H" ) 
C1H->(DbSetOrder(5)) //C1H_FILIAL, C1H_ID, R_E_C_N_O_, D_E_L_E_T_

DbSelectArea( "C08" ) 
C08->(DbSetOrder(3)) //C08_FILIAL, C08_ID, R_E_C_N_O_, D_E_L_E_T_

//Chaves
cTpNInsc:= (cAlias4Q)->CTPINSC + '|' + (cAlias4Q)->CNRINSC +'|'+ (cAlias4Q)->CCPFBENEF 

//O agrupamento ocorre por CPF para as filiais de mesmo CNPJ
cChvV4Q := /*(cAlias4Q)->FIL + '|' + */cPerApu + '|' +(cAlias4Q)->CTPINSC + '|' + (cAlias4Q)->CNRINSC +'|'+ (cAlias4Q)->CCPFBENEF
If !Empty((cAlias4Q)->CIDEXT)
	cChvV4Q += '|' + (cAlias4Q)->CIDEXT
Else
	cChvV4Q += '|' + Space(60)
EndIf
If lReinf212
	cChvV4Q += '|' + (cAlias4Q)->CEVADIC
EndIf

cChvV4R := cChvV4Q 


nPos := aScan(aPreMap,{|x| cChvV4Q $ x[04] })

//Limpa Array com Recno das Movimentacoes
aMovs := {}
aDivid:= {}

//-------------------------------------------------------------
//Condicionamento p/ iniciar a gravacao
//-------------------------------------------------------------

cFilBenef := (cAlias4Q)->FIL
cCPFBen   := (cAlias4Q)->CCPFBENEF
cIdExt    := (cAlias4Q)->CIDEXT
if !lTafRVld .Or. (lTafRVld .And. nPos == 0 )
	//-------------------------------------------------------------------
	//Carrega a lista de recno dos legados que compoe a chave de apuracao
	//necessario caso efetue o Commit, para atualizar o campo _PRID40
	//-------------------------------------------------------------------
	If (cAliasChv)->(DbSeek(cChvV4Q))
		While !(cAliasChv)->(Eof()) .And. AllTrim(cChvV4Q) $ AllTrim((cAliasChv)->CHAVE)
			Aadd(aMovs, { (cAliasChv)->CROTINA, (cAliasChv)->NREGISTR } )
			If (cAliasChv)->CCNATRE == "12001" .and. (cAliasChv)->CROTINA == "PGT" // Se for dividendo
				Aadd(aDivid, { (cAliasChv)->NREGISTR  } )				
			EndIF
			(cAliasChv)->(DbSkip())
		EndDo
	EndIf

	If !Empty(cVerAnt)
		oModelV4Q:LoadValue( 'V4Q_VERANT', cVerAnt )
		oModelV4Q:LoadValue( 'V4Q_PROTPN', cProTpn )
		oModelV4Q:LoadValue( 'V4Q_ID'    , cId     )
	EndIf

	//-------------------------------------------- 
	// 					ideBenef
	//--------------------------------------------
	oModelV4Q:LoadValue( 'V4Q_FILIAL', cFilBenef)
	oModelV4Q:LoadValue( 'V4Q_VERSAO', xFunGetVer())
	oModelV4Q:LoadValue( 'V4Q_STATUS', ' ')
	oModelV4Q:LoadValue( 'V4Q_EVENTO', cEvento)
	oModelV4Q:LoadValue( 'V4Q_ATIVO' , '1')
	oModelV4Q:LoadValue( 'V4Q_PERAPU', cPerApu)
	
	oModelV4Q:LoadValue( 'V4Q_IDESTA', aInfoC1E[1])
	oModelV4Q:LoadValue( 'V4Q_DESTAB', aInfoC1E[2])
	oModelV4Q:LoadValue( 'V4Q_TPINSC', (cAlias4Q)->CTPINSC)
	oModelV4Q:LoadValue( 'V4Q_NRINSC', (cAlias4Q)->CNRINSC)
	oModelV4Q:LoadValue( 'V4Q_IDPART', (cAlias4Q)->CIDPART)
	oModelV4Q:LoadValue( 'V4Q_CPF'	 , cCPFBen)
	oModelV4Q:LoadValue( 'V4Q_NOME'	 , (cAlias4Q)->CNMBENEF)
	oModelV4Q:LoadValue( 'V4Q_IDEXTE', (cAlias4Q)->CIDEXT)
	oModelV4Q:LoadValue( 'V4Q_TPAMB' , cAmbReinf)
	If lReinf212
		oModelV4Q:LoadValue( 'V4Q_EVADIC', (cAlias4Q)->CEVADIC)
	EndIf	
	If TAFColumnPos("V4Q_ORIGEM")
		oModelV4Q:LoadValue( 'V4Q_ORIGEM' , (cAlias4Q)->ORIGEM)
	EndIf
	If C1H->(DBSeek( xFilial("C1H",cFilBenef) + (cAlias4Q)->CIDPART ) )
		If !Empty((cAlias4Q)->CPAISEXT)
			cIndNif := C1H->C1H_INDNIF
			cIdTrib    := C1H->C1H_IDTRIB
			cPaisExt := (cAlias4Q)->CPAISEXT
			cNif := C1H->C1H_NIF
			If T9A->(DBSeek(xFilial("T9A") + cIdTrib))
				cFormaTrib := StrZero(Val(T9A->T9A_CODIGO),2)
				cDescTrib := T9A->T9A_DESCRI
			EndIf
			cLogExt := C1H->C1H_LOGEXT 
			cNumExt := IIF(ALLTRIM(C1H->C1H_NUMEXT) $ "SN|S/N",'',ALLTRIM(C1H->C1H_NUMEXT))
			cComExt := C1H->C1H_COMEXT
			cBaiExt := C1H->C1H_BAIEXT
			cCidExt := C1H->C1H_NMCEXT
			cCxaExt := C1H->C1H_CDPOSE
			cEstExt := C1H->C1H_ESTEXT
			cTelExt := C1H->C1H_TELEXT
		EndIf
		//-------------------------------------------- 
		// 					ideDep
		//--------------------------------------------
		PopIdeDep(@oModelV86, C1H->C1H_FILIAL, C1H->C1H_ID)
	Else
		If lImp
			cIndNif  := (cAlias5E)->INDNIF
			cIdTrib  := (cAlias5E)->IDTRIB
			cPaisExt := (cAlias5E)->CPAISRESID
			cNif     := (cAlias5E)->NIF
		EndIf
	EndIf

	//-------------------------------------------- 
	// 					idePgto
	//--------------------------------------------
	if ( cAlias4R )->(DbSeek( cChvV4R ))
		cIdNat := ""
		nContv4r :=	0
		While !(cAlias4R)->(Eof()) .And. AllTrim(cChvV4R) $ AllTrim( (cAlias4R)->ID)
			If ( !Empty((cAlias4R)->CNATREND )) .and. cIdNat <> (cAlias4R )->CNATREND  
				nContv4r++
				cIdNat  := (cAlias4R)->CNATREND

				oModelV4R:lValid := .T.
				If nContv4r > 1 
					oModelV4R:AddLine()
				EndIf
				cCNatRen := ""
				cDNatRen := ""
				If V3O->( DbSeek(xFilial("V3O") + cIdNat) )
					cCNatRen := V3O->V3O_CODIGO
					cDNatRen := Alltrim(V3O->V3O_DESCR)
				EndIf
				oModelV4R:LoadValue( 'V4R_IDNTRE', cIdNat )
				oModelV4R:LoadValue( 'V4R_NATREN', cCNatRen )
				oModelV4R:LoadValue( 'V4R_DNATRE', cDNatRen ) 
				oModelV4R:LoadValue( 'V4R_OBSERV', (cAlias4R)->COBSERV)
				//-------------------------------------------- 
				// 					infoPgto
				//--------------------------------------------
				cChvV5E :=  cChvV4R + '|'+cIdNat + '|'
				//V5E_FILIAL, V5E_ID, V5E_VERSAO, V5E_NATREN, V5E_PAISRE, V5E_DATAFG, V5E_INDDEC, R_E_C_N_O_, D_E_L_E_T_
				if ( cAlias5E )->(DbSeek( cChvV5E )) 
					nContv5e := 0 
					cDtFGer := "" 
					cDecTer := ""
					
					While !(cAlias5E)->(Eof()) .And. AllTrim(cChvV5E) $ (cAlias5E)->ID
						If ( (cDtFGer + cDecTer) <> ( DTOS((cAlias5E)->DDTFG) + (cAlias5E)->CINDDECTER )  )
								nContv5e++
								cDtFGer := DTOS((cAlias5E)->DDTFG)
								If !Empty((cAlias5E)->CINDDECTER)
									cDecTer := (cAlias5E)->CINDDECTER 
								Else
									cDecTer := "2" 
								EndIf
								oModelV5E:lValid := .T. 
								If nContv5e > 1
									oModelV5E:AddLine()
								EndIf
						EndIf

						//V5E_FILIAL, V5E_ID, V5E_VERSAO, V5E_NATREN, V5E_PAISRE, V5E_DATAFG, V5E_INDDEC, R_E_C_N_O_, D_E_L_E_T_
						oModelV5E:LoadValue('V5E_DATAFG', (cAlias5E)->DDTFG )
						oModelV5E:LoadValue('V5E_COMPFP', (cAlias5E)->CCOMPFP )
						oModelV5E:LoadValue('V5E_INDDEC', cDecTer )
						oModelV5E:LoadValue('V5E_VLRBRU', (cAlias5E)->NVLRRENDBR + FWFldGet( "V5E_VLRBRU" ) )
						oModelV5E:LoadValue('V5E_VLRTRI', (cAlias5E)->NVLRRENDTR + FWFldGet( "V5E_VLRTRI" ) )
						oModelV5E:LoadValue('V5E_VLRIR' , (cAlias5E)->NVLRIR + FWFldGet( "V5E_VLRIR" ) )
						oModelV5E:LoadValue('V5E_FCISCP', (cAlias5E)->CINDFCISCP )
						oModelV5E:LoadValue('V5E_NFCISC', (cAlias5E)->CNRINSFCSC )
						oModelV5E:LoadValue('V5E_PERSCP', (cAlias5E)->NPERCSCP ) 
						
						If !Empty(cPaisExt) .and. cPaisExt != "105"
							oModelV5E:LoadValue('V5E_PAISRE', cPaisExt )
						EndIf	
						If lReinf212
							oModelV5E:LoadValue('V5E_DTESCO', (cAlias5E)->DDTESCRCT ) 
							oModelV5E:LoadValue('V5E_OBSERV', (cAlias5E)->COBSERV ) 
						EndIf

						//--------------------- 
						//  infoRRA
						//---------------------
						cTipoProc := ""
						ProcRRA( @oModel545, cAlias5E, @cTipoProc, cChvV4Q, @aPreMap)
						If cTipoProc == "1" // RRA
							oModelV5E:LoadValue('V5E_INDRRA', "1" )
							oModelV5E:LoadValue('V5E_INDJUD', "2" )
						ElseIf cTipoProc == '2'
							oModelV5E:LoadValue('V5E_INDRRA', "2" )
							oModelV5E:LoadValue('V5E_INDJUD', "1" )
						Else
							oModelV5E:LoadValue('V5E_INDRRA', "2" )
							oModelV5E:LoadValue('V5E_INDJUD', "2" )
						EndIf

						//---------------------			
						//infoPgtoExt
						//---------------------
						If !Empty(cPaisExt) .and. cPaisExt != "105" .and. !lImp
							oModelV5Eg:LoadValue("V5E_INDNIF", cIndNif)
							oModelV5Eg:LoadValue("V5E_NIF"   , cNif)
							oModelV5Eg:LoadValue("V5E_IDTRIB", cIdTrib)
							oModelV5Eg:LoadValue("V5E_CTRIB" , cFormaTrib)
							oModelV5Eg:LoadValue("V5E_DTRIB" , cDescTrib)

							oModelV5Eh:LoadValue("V5E_LOGRAD",cLogExt)
							oModelV5Eh:LoadValue("V5E_NRLOGR",cNumExt)
							oModelV5Eh:LoadValue("V5E_COMPLE",cComExt)
							oModelV5Eh:LoadValue("V5E_BAIRRO",cBaiExt)
							oModelV5Eh:LoadValue("V5E_CIDADE",cCidExt)
							oModelV5Eh:LoadValue("V5E_ESTADO",cEstExt)
							oModelV5Eh:LoadValue("V5E_CEP",cCxaExt)
							oModelV5Eh:LoadValue("V5E_TELEF",cTelExt)

						elseif !Empty(cPaisExt) .and. cPaisExt != "105" .and. lImp
							oModelV5Eg:LoadValue("V5E_INDNIF", (cAlias5E)->INDNIF)
							oModelV5Eg:LoadValue("V5E_NIF"   , (cAlias5E)->NIF)
							oModelV5Eg:LoadValue("V5E_IDTRIB", (cAlias5E)->IDTRIB)
							oModelV5Eg:LoadValue("V5E_CTRIB" , (cAlias5E)->IDTRIB2)
							oModelV5Eg:LoadValue("V5E_DTRIB" , (cAlias5E)->DESCID)

							oModelV5Eh:LoadValue("V5E_LOGRAD",(cAlias5E)->LOGEXT)
							oModelV5Eh:LoadValue("V5E_NRLOGR",(cAlias5E)->NUMEXT)
							oModelV5Eh:LoadValue("V5E_COMPLE",cComExt)
							oModelV5Eh:LoadValue("V5E_BAIRRO",(cAlias5E)->BAIEXT)
							oModelV5Eh:LoadValue("V5E_CIDADE",(cAlias5E)->NMCEXT)
							oModelV5Eh:LoadValue("V5E_ESTADO",cEstExt)
							oModelV5Eh:LoadValue("V5E_CEP",cCxaExt)
							oModelV5Eh:LoadValue("V5E_TELEF",cTelExt)

						EndIf	
						If !lImp
							//---------------------
							//  detDed
							//---------------------
							cChvV4T :=  cChvV5E + C1H->C1H_PAISEX + '|' + cDtFGer + '|'  + (cAlias5E)->CCOMPFP  + '|' + (cAlias5E)->CINDDECTER + "|" + (cAlias5E)->CJUDRRA + "|" + (cAlias5E)->CINDFCISCP + "|" + (cAlias5E)->CIDFCISCP 

							If (( cAlias4T )->(DbSeek( cChvV4T )))
								nContv4t := 0
								While !(cAlias4T)->(Eof()) .And. cChvV4T $ (cAlias4T)->ID  
									nContv4t++ 
									oModelV4T:lValid := .T.
									if nContv4t>1
										oModelV4T:AddLine()
									EndIf
									oModelV4T:LoadValue("V4T_TPDEDU",(cAlias4T)->CINDTPDEDU) 
									oModelV4T:LoadValue("V4T_VLRDED",(cAlias4T)->NVLRDEDUCA)
									oModelV4T:LoadValue("V4T_IENTID",(cAlias4T)->CINFOENTID)
									oModelV4T:LoadValue("V4T_NRPVCM",(cAlias4T)->CNRINSCPRE)
									oModelV4T:LoadValue("V4T_VLFPRE",(cAlias4T)->NVLRFUNP)

									//-------------------------------------------- 
									// 					benefPen		
									//-------------------------------------------- 
									cChvV4U	:= cChvV4T+'|'+(cAlias4T)->CINDTPDEDU
									If (( cAlias4U )->(DbSeek( alltrim(cChvV4U) )))
										nContv4u := 0
										While !(cAlias4U)->(Eof()) .And. alltrim(cChvV4U) $ (cAlias4U)->ID  
											nContv4u++
											if nContv4u>1
												oModelV4U:AddLine()
											EndIf
											oModelV4U:LoadValue("V4U_CPFDEP",(cAlias4U)->CCPF	)
											oModelV4U:LoadValue("V4U_NOMEDB",(cAlias4U)->CNOME 	)
											oModelV4U:LoadValue("V4U_VALDED",(cAlias4U)->NVLRDEPEN)
											(cAlias4U)->(DbSkip())
										EndDo
									EndIf
									(cAlias4T)->(DbSkip())
								EndDo            	    
							EndIf

							//---------------------
							//  rendIsen
							//---------------------
							cChvV4V :=  cChvV5E + C1H->C1H_PAISEX + '|' + cDtFGer + '|'  + (cAlias5E)->CCOMPFP  + '|' + (cAlias5E)->CINDDECTER + "|" + (cAlias5E)->CJUDRRA + "|" + (cAlias5E)->CINDFCISCP + "|" + (cAlias5E)->CIDFCISCP 
							nContv4V	:=	0
							If( cAlias4V )->(DbSeek( cChvV4V ))                    
								While !(cAlias4V)->(Eof()) .And. cChvV4V $ (cAlias4V)->ID  

									nContv4V++
									if nContv4V>1
										oModelV4V:AddLine()
									EndIf
									oModelV4V:LoadValue("V4V_TPISEN",(cAlias4V)->CTPISENCAO)
									oModelV4V:LoadValue("V4V_VLRISE",(cAlias4V)->NVLRISENTO) 
									oModelV4V:LoadValue("V4V_DESREN",(cAlias4V)->CDESCRENDI)
									oModelV4V:LoadValue("V4V_DTLAUD",(cAlias4V)->DDTLAUDO)
									oModelV4V:LoadValue("V4V_IDTPIS",(cAlias4V)->CIDISENCAO)
									oModelV4V:LoadValue("V4V_DRENDI",(cAlias4V)->CDSISENCAO)
									(cAlias4V)->(DbSkip())
								EndDo 
							EndIf
							//--------------------- 
							//  infoProcRet
							//---------------------

							cChvV4X :=  cChvV5E + C1H->C1H_PAISEX + '|' + cDtFGer + '|'  + (cAlias5E)->CCOMPFP  + '|' + (cAlias5E)->CINDDECTER + "|" + (cAlias5E)->CJUDRRA + "|" + (cAlias5E)->CINDFCISCP + "|" + (cAlias5E)->CIDFCISCP 
							nContv4X	:= 0
							If ( cAlias4X )->(DbSeek( cChvV4X ))                    
								While !(cAlias4X)->(Eof()) .And.  cChvV4X $ (cAlias4X)->ID  

									nContv4X++
									If nContv4X>1
										oModelV4X:AddLine()
									EndIf 
									oModelV4X:LoadValue("V4X_TPPROC",( cAlias4X )->CTPPROCRET)
									oModelV4X:LoadValue("V4X_NRPROC",( cAlias4X )->CNRPROCRET)
									oModelV4X:LoadValue("V4X_CODSUS",( cAlias4X )->CODSUSP)
									oModelV4X:LoadValue("V4X_VLRETI",( cAlias4X )->NVLRNRETID)
									oModelV4X:LoadValue("V4X_VLRDEP",( cAlias4X )->NVLRDEP)
									oModelV4X:LoadValue("V4X_VLRANO",( cAlias4X )->NVLRANO)
									oModelV4X:LoadValue("V4X_VLRANA",( cAlias4X )->NVLRANA)
									oModelV4X:LoadValue("V4X_VLRSUS",( cAlias4X )->NVLRBSSUSP)
									cChvV92 := cChvV4X + '|' +( cAlias4X )->(CTPPROCRET + '|' + CNRPROCRET)
									If ( cAlias92 )->(DbSeek( cChvV92 ))
										nContv92	:= 0
										While !(cAlias92)->(Eof()) .And.  cChvV92 $ (cAlias92)->ID 
											nContv92++
											If nContv92>1
												oModelV92:AddLine()
											EndIf
											oModelV92:LoadValue("V92_TPDEDU",( cAlias92 )->CINDTPDEDU)
											oModelV92:LoadValue("V92_VDEDSU",( cAlias92 )->NVLRDEDSUS)

											If ( cAlias93 )->(DbSeek( cChvV92 + '|' + ( cAlias92 )->CINDTPDEDU ))
												nContv93	:= 0
												While !(cAlias93)->(Eof()) .And.  cChvV92+'|'+( cAlias92 )->CINDTPDEDU $ (cAlias93)->ID 
													nContv93++
													If nContv93>1
														oModelV93:AddLine()
													EndIf
													oModelV93:LoadValue("V93_CPFDEP",( cAlias93 )->CCPFDEP)
													oModelV93:LoadValue("V93_VDEPSU",( cAlias93 )->NVLRDEPSUS)
													(cAlias93)->(DbSkip())
												EndDo
											EndIf

											(cAlias92)->(DbSkip())
										EndDo
									EndIf
									(cAlias4X)->(DbSkip())
								EndDo
							EndIf
						EndIf	
						(cAlias5E)->(DbSkip())
					EndDo    
				EndIf
			EndIf
			(cAlias4R)->(dbskip())
		EndDo
	EndIf

	//---------------------
	//  ideOpSaude
	//---------------------
	If !lImp
		If TafOpePLS(cPerApu, aFil, (cAlias4Q)->CCPFBENEF, @cAliasV4B, (cAlias4Q)->CIDPART)
			nContv4y	:=	0
			nInscrPLS	:= ""
			nInscrMed	:= ""
			nVlrPag		:= 0
			nContv4z    := 0

			While !(cAliasV4B)->(Eof())
				Aadd(aMovs, { 'PLS',  (cAliasV4B)->RECNO } )

				If nInscrPLS != (cAliasV4B)->CNPJPLS
					nContv4y++
					nVlrPag   := 0
					nVlrReemb := 0
					nVlrAnt   := 0
					nContv5A  := 0
					nContv4z  := 0
					cCpfDep   := ""
					nInscrMed := ""
					nVlrPgD   := 0
					If nContv4y>1
						oModelV4Y:AddLine()
					EndIf
					nInscrPLS	:=   (cAliasV4B)->CNPJPLS
					oModelV4Y:LoadValue("V4Y_NRINSC",(cAliasV4B)->CNPJPLS) 
					oModelV4Y:LoadValue("V4Y_REGANS",(cAliasV4B)->REGANS) 
				EndIf

				If (cAliasV4B)->INDBEN4B == '1' // 1-titular
					If (cAliasV4B)->TPPGTV4B == '1'  // 1-Pagamento
						nVlrPag += (cAliasV4B)->VRPGTV4B
						//Se Beneficiario = 1-Titular e Tipo Pagamento = 1-Pagamento
						oModelV4Y:LoadValue("V4Y_VLRPAG",nVlrPag)
					ElseIf (cAliasV4B)->TPPGTV4B == '2' // 2 - Reembolso
						If nInscrMed != (cAliasV4B)->NRINSV4B
							nContv4z++ 
							If nContv4z>1
								nVlrReemb := 0
								nVlrAnt   := 0
								oModelV4Z:AddLine()
							EndIf 
						EndIf	
						nInscrMed	:= (cAliasV4B)->NRINSV4B
						nVlrReemb += (cAliasV4B)->VRPGTV4B
						nVlrAnt += (cAliasV4B)->VRBANT4B
						oModelV4Z:LoadValue("V4Z_TPINSC",(cAliasV4B)->TPINSV4B  ) 
						oModelV4Z:LoadValue("V4Z_NRINSC",(cAliasV4B)->NRINSV4B  )
						oModelV4Z:LoadValue("V4Z_VLRREE",nVlrReemb)
						oModelV4Z:LoadValue("V4Z_VLRANT",nVlrAnt)

					EndIf	

				ElseIf (cAliasV4B)->INDBEN4B == '2' // 1-Dependente
					If V3R->( DbSeek( (cAliasV4B)->FILC1H + (cAliasV4B)->C1H_ID +  (cAliasV4B)->CODDEV4B ) ) //V3R_FILIAL, V3R_ID, V3R_CODIGO, R_E_C_N_O_, D_E_L_E_T_

						//---------------------
						//  infoDependPl
						//---------------------
						If cCpfDep != V3R->V3R_CPF				                    
							nContv5A++ 
							nContv5b := 0
							nVlrReDep := 0
							nVlrAnt := 0
							nVlrPgD := 0
							If nContv5A>1
								oModelV5A:AddLine()
							EndIf
						EndIf	   
						cCpfDep := V3R->V3R_CPF

						oModelV5A:LoadValue("V5A_CPF"	,V3R->V3R_CPF)
						oModelV5A:LoadValue("V5A_NOMEDE",V3R->V3R_NOME)
						If  (cAliasV4B)->TPPGTV4B == '1' // se for pagamento
							nVlrPgD += (cAliasV4B)->VRPGTV4B
							oModelV5A:LoadValue("V5A_VALOR"	,nVlrPgD)
						ElseIf (cAliasV4B)->TPPGTV4B == '2' // se for reembolso
							//  infoReembDep
							If nInscrMed != (cAliasV4B)->NRINSV4B
								nContv5b++ 
								If nContv5b>1
									nVlrReDep := 0
									nVlrAnt   := 0
									oModelV5B:AddLine()
								EndIf 
							EndIf

							nInscrMed := (cAliasV4B)->NRINSV4B
							nVlrReDep += (cAliasV4B)->VRPGTV4B
							nVlrAnt   += (cAliasV4B)->VRBANT4B
							oModelV5B:LoadValue("V5B_SEQ", StrZero(nContv5b,2))
							oModelV5B:LoadValue("V5B_TPINSC",(cAliasV4B)->TPINSV4B)
							oModelV5B:LoadValue("V5B_NRINSC",(cAliasV4B)->NRINSV4B) 
							oModelV5B:LoadValue("V5B_VLRREE",nVlrReDep)
							oModelV5B:LoadValue("V5B_VLRANT",nVlrAnt)

						EndIf						
					EndIf
				EndIf
				(cAliasV4B)->(DbSkip()) 
			EndDo 
		EndIf
		(cAliasV4B)->(DbCloseArea())
	EndIf
	If oModel545:VldData()
		FwFormCommit(oModel545)
		TafEndGRV( "V4Q","V4Q_PROCID", cIdApReinf, V4Q->(Recno()))
		GravaId(aMovs,cIdApReinf)
		If TAFColumnPos("V3U_PERAPU")
			GravaDiv(aDivid, cPerApu)
		EndIf

		//Exito Gravacao
		cMsg := STR0020 + CRLF //"Processamento realizado com sucesso."
		cMsg += "Tp Nr Insc: " + AllTrim(cTpNInsc) + CRLF
		cMsg += "Apuracao_Id:" + cValToChar( cIdApReinf ) + " Recno:" + cValToChar( V4R->(Recno()))
		TafXLog(cIdApReinf, "R-4010", "MSG", cMsg, cPerApu )
	Else
		lOk := .F.
		cMsg 		:= STR0021 + CRLF + CRLF //"Detalhes técnicos do erro: "
		cMsg		+= TafRetEMsg(oModel545)
		Aadd( aPreMap, {"R-4010", "ERRO", cMsg, cChvV4Q} )
	EndIf
Else
	//Se ha alguma inconsistencia mapeada e o validador estiver habilitado nao grava a apuracao mas grava o Log
	lOk := .F.
	Aadd( aPreMap, {"R-4010", Iif(lTafRVld, "ERRO", "ALERTA"), "Tp.Nr.Insc: " + AllTrim(cTpNInsc) + " " + aPreMap[nPos][3], cChvV4Q} )
EndIf

//Se Ocorreu Algum Problema na Gravacao e Disarmou a Transação Grava Apenas o Log
If !lOk
	Aadd( aPreMap, {"R-4010", "ERRO", "Tp.Nr.Insc: " + AllTrim(cTpNInsc) + " " + TafRetEMsg(oModel545), cChvV4Q} )
EndIf

If !lImp
	aAdd( aIDLog, { cIDApReinf, cFilBenef, Iif(!Empty(cCPFBen),Alltrim(cCPFBen),Alltrim(cIdExt)) } )
else
	aAdd( aIDLog, { cIDApReinf, cFilBenef, Iif(!Empty(cCPFBen),Alltrim(cCPFBen),Alltrim(cIdExt)), IIF(!lOk,TafRetEMsg(oModel545),'') } )
EndIf

oModel545:DeActivate()

RestArea(aAreaSM0)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} Stats40XX
Verifica a existência ou não do registro que será apurado

@author 
@since
@version 1.0

@parameters Retorna o status do registro encontrado, caso contrário retorna status "Z", 
indicando que ainda não existe o registro no cadastro espelho
@return
/*/ 
//-------------------------------------------------------------------

Static Function Stats40XX(cReg, cChave, cVerAnt, cProTpn, cRetStat, cId )
				
Default cReg   	 := ""
Default cChave   := ""
Default cVerAnt  := ""
Default cProTpn  := ""
Default cRetStat := "Z"
Default cId		 := ""

If V4Q->( DbSeek( xFilial("V4Q",cFilAnt) + cChave + '1') ) //cPerApu + cTpInsc + cNrInsc + cCpf 
	cVerAnt	 := V4Q->V4Q_VERSAO
	cProTpn  := V4Q->V4Q_PROTUL
	cRetStat := V4Q->V4Q_STATUS
	cId		 := V4Q->V4Q_ID
Else
	cVerAnt  := ""
	cProTpn  := ""
	cRetStat := "Z"
	cId		 := ""
EndIf

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()

Efetua a exclusão do modelo conforme parâmetro

@author Henrique Pereira
@since 29/08/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function ExcluiReg(aIDLog, cReg, aErro, oModel545,cPerApu, cIDApReinf, lAutomato)

Local cErro		 As Character
Local cNrInscEst As Character
Local cTpInscEst As Character
Local cCpf		 As Character
Local cIdExt	 As Character
Local lExcluiu	 As Logical 


Default aIDLog  := {}
Default cReg 	:= "R-4010"
Default aErro	:= {}
Default oModel545 := nil
Default cPerApu := ''
Default cIDApReinf := ''
Default lAutomato := .F.


cErro := "" 
lExcluiu := .F.
cNrInscEst	:= V4Q->V4Q_NRINSC
cTpInscEst	:= V4Q->V4Q_TPINSC
cCpf		:= V4Q->V4Q_CPF 
cIdExt		:= V4Q->V4Q_IDEXTE

oModel545:SetOperation(5)
oModel545:Activate()

If FwFormCommit(oModel545) .and. !lAutomato
	lExcluiu := .T.
Else
	cErro	:= STR0007 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
	cErro 	+= "tpInscEstab: " + cTpInscEst + CRLF	
	cErro 	+= "nrInscEstab: " + cNrInscEst + CRLF
	cErro  	+= "cpf: " + cCpf + CRLF
	
	cErro 	+= TafRetEMsg(oModel545)
	Aadd(aErro, {"R-4010", "ERRO", cErro})
	aAdd( aIDLog, { cIDApReinf, V4Q->V4Q_FILIAL, Iif(!Empty(cCpf),Alltrim( cCpf  ),Alltrim(cIdExt)) } )
	lExcluiu := .F.
EndIf

oModel545:DeActivate()

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()


@author Henrique Pereira
@since 29/08/2019
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Static Function GravaId(aMovs, cIdApur)

Local	nX	as numeric 

Default aMovs 	:= {}
Default cIdApur	:= ''

For nX := 1 to Len(aMovs)
	Do case
	case Alltrim(aMovs[nX][1]) == 'NFS'
		TafEndGRV( "C20","C20_PRID40", cIdApur, aMovs[nX][2]  )
	case Alltrim(aMovs[nX][1]) == 'FAT'
		TafEndGRV( "LEM","LEM_PRID40", cIdApur, aMovs[nX][2]  )
	case Alltrim(aMovs[nX][1]) == 'PLS' 
		TafEndGRV( "V4B","V4B_PRID40", cIdApur, aMovs[nX][2]  )
	case Alltrim(aMovs[nX][1]) == 'PGT'
		TafEndGRV( "V3U","V3U_PRID40", cIdApur, aMovs[nX][2]  )

	EndCase
Next nX

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdePgto()
Função que popula a tabela temporária de Natureza de rendimento (IdePgto).

@author Katielly Rezende
@since 05/09/2019
@version 1.0
@return
/*/ 
Static Function PopIdePgto( cAlias, cCodNat, cNmIdePgto, cChaveV4R )

if !( cNmIdePgto )->(DbSeek( cChaveV4R ) )
	RecLock(cNmIdePgto,.T.)
	(cNmIdePgto)->ID			:=  cChaveV4R 
	(cNmIdePgto)->FIL			:= (cAlias)->FILIAL
	(cNmIdePgto)->CNATREND 		:= cCodNat
	(cNmIdePgto)->COBSERV		:= ''
	(cNmIdePgto)->(MsUnlock())
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} PopInfoPgt()
Função que popula a tabela temporária de pagamentos (infoPgto). 

@author Karen Honda
@since 29/09/2021
@version 1.0
@return
/*/
//-------------------------------------------------------------------
Static Function PopInfoPgt( cAlias, cCodNat, cPaisRend, dFatoGer, cNmInfoPgto, cChvReg, cChaveV4X, aPreMap, nValDed, lReinf212, lImp)

Local cCnpjSCP   As Character
Local cErro	     As Character
Local cPercSCP   As Character
Local cTipoLig	 As Character

Default cAlias 		:= ""
Default cCodNat		:= ""
Default cPaisRend	:= ""
Default dFatoGer	:= dDataBase
Default cNmInfoPgto	:= ""
Default cChvReg		:= ""
Default cChaveV4X	:= ""
Default aPreMap		:= {}
Default nValDed		:= 0
Default lReinf212   := .F.

cCnpjSCP 	:= ''
cErro 	 	:= ''
cPercSCP 	:= ''
cTipoLig 	:= ''

If !( cNmInfoPgto )->( DbSeek( cChaveV4X ) ) 
	RecLock( cNmInfoPgto ,.T. )
	(cNmInfoPgto)->ID			:=  cChaveV4X
	(cNmInfoPgto)->FIL			:= (cAlias)->FILIAL

	(cNmInfoPgto)->DDTFG   		:= dFatoGer
	(cNmInfoPgto)->CCOMPFP   	:= StrTran((cAlias)->COMPFP,"-","")
	
	(cNmInfoPgto)->CINDDECTER	:= (cAlias)->DECTER

	(cNmInfoPgto)->NVLRRENDBR	:= (cAlias)->VLBRUT
	(cNmInfoPgto)->NVLRRENDTR	:= (cAlias)->BASECA
	(cNmInfoPgto)->NVLRIR   	:= (cAlias)->VLTRIB
	(cNmInfoPgto)->CPAISRESID  	:= cPaisRend

	(cNmInfoPgto)->CJUDRRA		:= (cAlias)->IDRRAPJD
	(cNmInfoPgto)->CINDFCISCP	:= (cAlias)->INDFCISCP

	If lImp
		(cNmInfoPgto)->INDNIF	:= (cAlias)->INDNIF
		(cNmInfoPgto)->NIF		:= (cAlias)->NIF
		(cNmInfoPgto)->IDTRIB	:= (cAlias)->IDTRIB
		(cNmInfoPgto)->IDTRIB2	:= (cAlias)->IDTRIB2
		(cNmInfoPgto)->DESCID	:= (cAlias)->DESCID
		(cNmInfoPgto)->BAIEXT	:= (cAlias)->BAIEXT
		(cNmInfoPgto)->LOGEXT	:= (cAlias)->LOGEXT
		(cNmInfoPgto)->NUMEXT	:= (cAlias)->NUMEXT
		(cNmInfoPgto)->NMCEXT	:= (cAlias)->NMCEXT
	EndIf
	
	// Função que retorna o percentual de participação em uma SCP
	If !Empty((cAlias)->INDFCISCP) 
		If SCPR40XX(cAlias, @cCnpjSCP, @cPercSCP, @cTipoLig)
			(cNmInfoPgto)->CIDFCISCP	:= (cAlias)->IDSCP
			(cNmInfoPgto)->CNRINSFCSC	:= cCnpjSCP
			If cTipoLig == "4" // SCP
				(cNmInfoPgto)->NPERCSCP 	:= cPercSCP
			EndIf	
		Else
			cErro := STR0022 //"Indicativo da origem do rendimento preenchido porém sem informações do FCI/SCP."
		EndIf
	EndIf	
	(cNmInfoPgto)->(MsUnlock())
Else
	RecLock( cNmInfoPgto ,.F. )
	(cNmInfoPgto)->NVLRRENDBR	+= (cAlias)->VLBRUT
	(cNmInfoPgto)->NVLRRENDTR	+= (cAlias)->BASECA
	(cNmInfoPgto)->NVLRIR   	+= (cAlias)->VLTRIB
	(cNmInfoPgto)->(MsUnlock())
EndIf

If lReinf212
	If !Empty( (cAlias)->DTESCO )
		(cNmInfoPgto)->DDTESCRCT  	:= (cAlias)->DTESCO
	EndIf	
	If (cAlias)->ROTINA == 'FAT' 
		If !Empty( (cAlias)->OBSERV )
			(cNmInfoPgto)->COBSERV  	:= Substr( (cAlias)->OBSERV, 1, 200 )
		EndIf
	ElseIf (cAlias)->ROTINA == 'NFS' .or. (cAlias)->ROTINA == 'PGT'
		//Busca a descrição do campo memo
		If (cAlias)->ROTINA == 'NFS'
			C21->(DbSetOrder(1))
			If C21->( MsSeek( (cAlias)->FILIAL + (cAlias)->CHVNF ) )
				If !Empty( C21->C21_DESCRI )
					(cNmInfoPgto)->COBSERV  	:= Substr( C21->C21_DESCRI, 1, 200 )
				EndIf
			EndIf
		else
			V3U->(DbSetOrder(1))
			If V3U->( MsSeeK( (cAlias)->FILIAL + (cAlias)->V3UID ))
				If !Empty( V3U->V3U_OBSERV )
					(cNmInfoPgto)->COBSERV	:= Substr( V3U->V3U_OBSERV, 1, 200 )
				Endif
			Endif
		Endif
	EndIf
EndIf



(cNmInfoPgto)->NVLRRENDTR += nValDed // Soma as deducoes

If !Empty(cErro)
	nPos := aScan(aPreMap,{|x| x[04] == AllTrim(cChvReg)})
	If nPos > 0
		aPreMap[nPos][3] += cErro
	Else
		Aadd( aPreMap, {"R-4010", Iif(lTafRVld, "ERRO", "ALERTA"), cErro, cChvReg } )
	EndIf 
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopProcRet()

Função que popula a tabela temporária de infoProcRet

@author Denis Souza
@since 09/09/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function PopProcRet( cAlias, aTTName, cChaveV4X,  cCompC1G, aSM0EUF, cChvReg, aPreMap, lCentApr, lApuSTri)

Local cTipPro 	As Character
Local cAliasPro As Character
Local cAliasDed As Character
Local cAliasDep As Character
Local cTpDedu   As Character
Local cChvProc  As Character
Local cChvDed   As Character

Default cAlias		:= ""
Default aTTName		:= {}
Default cChaveV4X	:= ""
Default cCompC1G	:= ""
Default aSM0EUF		:= {}
Default lCentApr	:= .F.
Default lApuSTri    := .F.

cAliasPro   := ""
cAliasDed   := ""
cAliasDep   := ""
cChvProc	:= ""
cChvDed		:= ""

cAliasPro := TafProcRet( cAlias, cChaveV4X, cCompC1G, aSM0EUF, .T., lApuSTri  )

If !Empty(cAliasPro) .And. Select( cAliasPro ) > 0 .And. (cAliasPro)->( !Eof() )
	While (cAliasPro)->( !Eof() )
		cTipPro   	:= ""
		cAliasDed   := ""
		cAliasDep   := ""
		cTpDedu		:= ""
		cChvDed		:= ""
		//infoProcRet
		cTipPro := iif( !Empty((cAliasPro)->CTPPROC), (cAliasPro)->CTPPROC, Iif((cAliasPro)->C1GTPPROC == "1", "2", "1") )
		If lCentApr == .F.
			cChvProc := cChaveV4X + '|' + cTipPro + '|' + (cAliasPro)->C1GNUMPRO
		Else 
			cChvProc := cChaveV4X + '|' + cTipPro 
		EndIf
		If !(aTTName[INFOPROC])->( DBSeek( cChvProc ) )

			RecLock(aTTName[INFOPROC], .T.)
			(aTTName[INFOPROC])->ID	   		:= cChvProc
			(aTTName[INFOPROC])->FIL	   	:= (cAlias)->FILIAL
			(aTTName[INFOPROC])->CTPPROCRET	:= cTipPro
			(aTTName[INFOPROC])->CNRPROCRET := (cAliasPro)->C1GNUMPRO
			(aTTName[INFOPROC])->CODSUSP 	:= (cAliasPro)->CODSUS
			(aTTName[INFOPROC])->NVLRNRETID := (cAliasPro)->VALSUS
			(aTTName[INFOPROC])->NVLRANO 	:= (cAliasPro)->VLRANO
			(aTTName[INFOPROC])->NVLRANA 	:= (cAliasPro)->VLRANA
			(aTTName[INFOPROC])->NVLRBSSUSP	:= (cAliasPro)->BSSUSP
			If (cAliasPro)->INDDEP == '1'
				(aTTName[INFOPROC])->NVLRDEP	:= (cAliasPro)->VLRDEP
			EndIf	
			(aTTName[INFOPROC])->(MsUnlock())
		Else
			RecLock(aTTName[INFOPROC], .F.)
			(aTTName[INFOPROC])->NVLRNRETID += (cAliasPro)->VALSUS
			(aTTName[INFOPROC])->NVLRANO 	+= (cAliasPro)->VLRANO
			(aTTName[INFOPROC])->NVLRANA 	+= (cAliasPro)->VLRANA
			(aTTName[INFOPROC])->NVLRBSSUSP	+= (cAliasPro)->BSSUSP
			If (cAliasPro)->INDDEP == '1'
				(aTTName[INFOPROC])->NVLRDEP 		:= (cAliasPro)->VLRDEP
			EndIf
			(aTTName[INFOPROC])->(MsUnlock())
		EndIf

		//dedSusp
		If TafDedSus(cAlias, cAliasPro, @cAliasDed)
			While (cAliasDed)->( !Eof() )
				cTpDedu :=  (cAliasDed)->TPDEDU
				cChvDed := cChvProc + '|' + (cAliasDed)->TPDEDU 
				If !(aTTName[DEDSUSP])->( DBSeek( cChvDed ) )
					RecLock(aTTName[DEDSUSP], .T.)
					(aTTName[DEDSUSP])->ID			:= cChvDed
					(aTTName[DEDSUSP])->FIL 		:= (cAlias)->FILIAL
					(aTTName[DEDSUSP])->CINDTPDEDU  := (cAliasDed)->TPDEDU
					(aTTName[DEDSUSP])->NVLRDEDSUS  := (cAliasDed)->VALDED
					(aTTName[DEDSUSP])->(MsUnlock())
				Else	
					RecLock(aTTName[DEDSUSP], .F.)
					(aTTName[DEDSUSP])->NVLRDEDSUS  += (cAliasDed)->VALDED
					(aTTName[DEDSUSP])->(MsUnlock())
				EndIf	
				//benefPen
				
				If cTpDedu $ '5|7' // Se dedução 5 - Pensão ou 7 - Dependentes 
					If TafBenefPen(cAlias, @cAliasDep, cTpDedu, 'dedSusp',(cAliasPro)->NUMPRO, (cAliasPro)->(NUMPRO+C1GVERSAO+CODSUS), (cAliasPro)->CTPPROC) 
						While (cAliasDep)->( !Eof() )
							If !(aTTName[DEDBENEF])->( DBSeek( cChvDed + '|' + (cAliasDep)->CPFDEP ) )
								RecLock(aTTName[DEDBENEF], .T.)
								(aTTName[DEDBENEF])->ID			:= cChvDed + '|' + (cAliasDep)->CPFDEP
								(aTTName[DEDBENEF])->CCPFDEP	:= (cAliasDep)->CPFDEP
								(aTTName[DEDBENEF])->NVLRDEPSUS	:= (cAliasDep)->VDEDSU
								(aTTName[DEDBENEF])->(MsUnlock())
							Else
								RecLock(aTTName[DEDBENEF], .F.)
								(aTTName[DEDBENEF])->NVLRDEPSUS	+= (cAliasDep)->VDEDSU
								(aTTName[DEDBENEF])->(MsUnlock())
							EndIf
							(cAliasDep)->( DbSkip() )
						EndDo
					Else
						Aadd( aPreMap, {"R-4010", Iif(lTafRVld, "ERRO", "ALERTA"), STR0023, cChvReg } )		//"Dependentes não informados na suspensão da dedução do tipo 5 ou 7."
					EndIf
					(cAliasDep)->( DbCloseArea() )				
				EndIf	
				(cAliasDed)->( DbSkip() )
			EndDo	
		EndIf
		(cAliasDed)->( DbCloseArea() )
		(cAliasPro)->( DbSkip() )
	Enddo
EndIf
(cAliasPro)->( DbCloseArea() )	

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRRA ()
Função que popula o model referente a processos judiciais (infoProcJud) ou RRA (infoRRA),
e verifica a existência de advogados. 

@author Karen honda
@since 04/10/2022
@version 1.0
@return
/*/ 
Static Function ProcRRA( oModel545, cAlias5E, cTipoProc, cChvV4Q, aPreMap) 
Local cProdJud  As Character
Local nQtdProRRA As Numeric       
Local nCustasJud As Numeric       
Local nCustasAdv As Numeric
Local nContV4W  As Numeric
Local oModelV5Ed As Object
Local oModelV5Ee As Object
Local oModelV4W As Object

Default oModel545 := nil
Default cAlias5E := ""
Default cTipoProc := ""

nCustasJud  := 0
nCustasAdv  := 0
nContV4W    := 0
oModelV5Ed:= oModel545:GetModel( "MODEL_V5Ed" )
oModelV5Ee:= oModel545:GetModel( "MODEL_V5Ee" )
oModelV4W := oModel545:GetModel( "MODEL_V4W" )

cProdJud   := HasRraPJud( "R4010", "InfoRRA", (cAlias5E)->FIL, (cAlias5E)->CJUDRRA)

nQtdProRRA := 0

DbSelectArea( cProdJud )
If (cProdJud)->(!Eof())
	While (cProdJud)->(!Eof())
		nQtdProRRA++
		If nQtdProRRA == 1    // Somente pode ter 1 processo por Infopgto
			cTipoProc  := (cProdJud)->INDRRA
			oModelV5Ed:LoadValue('V5E_TPPROC', (cProdJud)->TPPROC )
			oModelV5Ed:LoadValue('V5E_NRPROC', (cProdJud)->NRPROC )
			oModelV5Ed:LoadValue('V5E_DESCRI', (cProdJud)->DESCRI )
			If (cProdJud)->INDRRA == "1" // RRA
				oModelV5Ed:LoadValue('V5E_QTDMES', (cProdJud)->QTDMESRRA )
				oModelV5Ed:LoadValue('V5E_INDORI', (cProdJud)->INDORI )
				If (cProdJud)->INDORI == "2"
					oModelV5Ed:LoadValue('V5E_CNPJOR', (cProdJud)->CNPJOR )		
				EndIf	
			Else
				oModelV5Ed:LoadValue('V5E_INDORI', (cProdJud)->INDORI )
				If (cProdJud)->INDORI == "2"
					oModelV5Ed:LoadValue('V5E_CNPJOR', (cProdJud)->CNPJOR )		
				EndIf	
			EndIf	

			//-------------------------------------------- 
			//   		 	IdeAdv - V4W
			//--------------------------------------------
			cIdeAdv := HasRraPJud( "R4010", "IdeAdv", (cAlias5E)->FIL, (cAlias5E)->CJUDRRA)
			If !Empty(cIdeAdv)  .And. (cIdeAdv)->( !Eof() )										
				nCustasAdv := 0
				nCustasJud := 0
				nContV4W   := 0
				While (cIdeAdv)->(!Eof())
					
					If (cIdeAdv)->TPDESP == '1'	  //Custo Com Advogado
						nCustasAdv += (cIdeAdv)->VLDESP 
						nContV4W++
						If nContV4W > 1 
							oModelV4W:AddLine()
						EndIf
						oModelV4W:LoadValue("V4W_TPINSC",(cIdeAdv)->TPINSC)
						oModelV4W:LoadValue("V4W_NRINSC",(cIdeAdv)->NRINSC)
						oModelV4W:LoadValue("V4W_VLRADV",(cIdeAdv)->VLDESP)
					Elseif (cIdeAdv)->TPDESP == '2' //Custas Judiciais 
						nCustasJud += (cIdeAdv)->VLDESP
					EndIf 
					(cIdeAdv)->(DbSkip())
				EndDo
				oModelV5Ee:LoadValue("V5E_VLRDES",nCustasJud)
				oModelV5Ee:LoadValue("V5E_VLRADV",nCustasAdv) 
			EndIf
			(cIdeAdv)->(DbcloseArea()) //TravaDebug		
		Else
			Aadd( aPreMap, {"R-4010", Iif(lTafRVld, "ERRO", "ALERTA"), STR0024, cChvV4Q } ) //"Somente é permitido um processo RRA por pagamento."								
		EndIf
		(cProdJud)->(DbSkip())
	EndDo
EndIf
(cProdJud)->( DbCloseArea() ) 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdeDep()
Função que popula a tabela temporária de IdeDep

@author Karen Honda
@since 29/09/2019
@version 1.0
/*/ 

Static Function PopIdeDep(oModelV86, cFilPart, cIdPart)
Local nContv86 as Numeric

nContv86 := 0
If V3R->(DBSeek( cFilPart + cIdPart )) 
	While V3R->( !Eof() ) .and. V3R->(V3R_FILIAL + V3R_ID) == cFilPart + cIdPart
		
		nContv86++
		oModelV86:lValid := .T.
		If nContv86 > 1 
			oModelV86:AddLine()
		EndIf		
		oModelV86:LoadValue("V86_CPFDEP", V3R->V3R_CPF)
		oModelV86:LoadValue("V86_DSCOUT", V3R->V3R_DESCDP)
		If V3Q->(DBSeek(XFILIAL("V3Q")+V3R->V3R_CREDEP))
			oModelV86:LoadValue("V86_RELDEP", V3Q->V3Q_CODIGO)
			oModelV86:LoadValue("V86_DESDEP", Substr(V3Q->V3Q_DESCRI,1,30))
		EndIf
		V3R->( DbSkip() )
	EndDo	
EndIf	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PopDetDed()
Função que popula a tabela temporária de DetDed

@author Karen Honda
@since 29/09/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function PopDetDed(cAlias,aTTName, cChaveV4X, cChvReg, aPreMap, nValDed)
Local cAlsDeduc as Character
Local cAliasDep as Character

Default cAlias 		:= ""
Default aTTName		:= {}
Default cChaveV4X	:= ""
Default cChvReg		:= ""
Default aPreMap		:= {}
Default nValDed		:= 0

cAlsDeduc := ""
cAliasDep := ""
nValDed	  := 0
// 	detDed
cAlsDeduc := HasPgtoFat( "R4010", cAlias, "detDed" )

(cAlsDeduc)->(DbGoTop())
While (cAlsDeduc)->(!EOF()) 
	cTpDedu	:= (cAlsDeduc)->CINDTPDEDU
	if !(aTTName[DETDED])->(DbSeek( cChaveV4X  + '|' + (cAlsDeduc)->CINDTPDEDU))
		RecLock(aTTName[DETDED],.T.)
		(aTTName[DETDED])->ID		  := cChaveV4X  + '|' + (cAlsDeduc)->CINDTPDEDU
		(aTTName[DETDED])->FIL		  := (cAlias)->FILIAL
		(aTTName[DETDED])->CINDTPDEDU := (cAlsDeduc)->CINDTPDEDU
		(aTTName[DETDED])->NVLRDEDUCA := (cAlsDeduc)->NVLRDEDUCA
		(aTTName[DETDED])->CNRINSCPRE := (cAlsDeduc)->CNRINSCPRE
		(aTTName[DETDED])->NVLRFUNP   := (cAlsDeduc)->VLFPRE
		If cTpDedu $ '2|3|4'
			(aTTName[DETDED])->CINFOENTID := If(Empty((cAlsDeduc)->IENTID), "2",(cAlsDeduc)->IENTID) 
		EndIf	
		(aTTName[DETDED])->(MsUnlock())
	Else
		RecLock(aTTName[DETDED],.F.)
		(aTTName[DETDED])->NVLRDEDUCA += (cAlsDeduc)->NVLRDEDUCA
		(aTTName[DETDED])->NVLRFUNP   += (cAlsDeduc)->VLFPRE
		(aTTName[DETDED])->(MsUnlock())
	EndIf
	nValDed += (cAlsDeduc)->NVLRDEDUCA

	//-------------------------------------------- 
	// 					benefPen		
	//--------------------------------------------
	If cTpDedu $ '5|7' // Se dedução 5 - Pensão ou 7 - Dependentes 
		if TafBenefPen(cAlias, @cAliasDep, cTpDedu, 'detDed')
			While ( (cAliasDep)->(!Eof()))
				If !(aTTName[BENEFPEN])->(DbSeek(cChaveV4X + '|' + cTpDedu + "|" +(cAliasDep)->CPFDEP))
					RecLock(aTTName[BENEFPEN],.T.)
					(aTTName[BENEFPEN])->ID			:= cChaveV4X + '|' + cTpDedu + '|' + (cAliasDep)->CPFDEP
					(aTTName[BENEFPEN])->FIL		:= (cAlias)->FILIAL
					(aTTName[BENEFPEN])->CCPF		:= (cAliasDep)->CPFDEP
					(aTTName[BENEFPEN])->CNOME 		:= (cAliasDep)->NOME
					(aTTName[BENEFPEN])->NVLRDEPEN 	:= (cAliasDep)->VALDED
					(aTTName[BENEFPEN])->(MsUnlock())	
				Else
					RecLock(aTTName[BENEFPEN],.F.)
					(aTTName[BENEFPEN])->NVLRDEPEN 	+= (cAliasDep)->VALDED
					(aTTName[BENEFPEN])->(MsUnlock())	
				EndIf
				(cAliasDep)->(DbSkip()) 
			Enddo
		Else
			Aadd( aPreMap, {"R-4010", Iif(lTafRVld, "ERRO", "ALERTA"), STR0025, cChvReg } )		//"Dependentes não informados na dedução do tipo 5 ou 7."
		EndIf
		(cAliasDep)->(DbCloseArea())
	EndIf
	(cAlsDeduc)->(DbSkip()) 		
Enddo
(cAlsDeduc)->( DbCloseArea() ) 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PopRendIsen()
Função que popula a tabela temporária de rendIsento

@author Karen Honda
@since 29/09/2019
@version 1.0
/*/ 
//-------------------------------------------------------------------
Static Function PopRendIsen(cAlias,aTTName, cChaveV4X)
Local cAlsIsenc as Character

cAlsIsenc := HasPgtoFat( "R4010", cAlias, "rendIsento" )

(cAlsIsenc)->(DbGoTop())
While (cAlsIsenc)->(!EOF()) 
	If !(aTTName[RENDISEN])->(DbSeek( cChaveV4X  + '|' + (cAlsIsenc)->CTPISENCAO))
		RecLock(aTTName[RENDISEN],.T.)
		(aTTName[RENDISEN])->ID			:= cChaveV4X  + '|' + (cAlsIsenc)->CTPISENCAO
		(aTTName[RENDISEN])->FIL		:= (cAlias)->FILIAL
		(aTTName[RENDISEN])->CIDISENCAO	:= (cAlsIsenc)->CTPISENCAO
		(aTTName[RENDISEN])->NVLRISENTO	:= (cAlsIsenc)->NVLRISENTO
		(aTTName[RENDISEN])->CDESCRENDI	:= (cAlsIsenc)->CDESCRENDI
		If V4E->( DbSeek(xFilial("V4E")+(cAlsIsenc)->CTPISENCAO) )
			(aTTName[RENDISEN])->CTPISENCAO	:= V4E->V4E_CODIGO
			(aTTName[RENDISEN])->CDSISENCAO	:= V4E->V4E_DESCRI
			If Alltrim(V4E->V4E_CODIGO) == "6" 
				(aTTName[RENDISEN])->DDTLAUDO	:= (cAlias)->DTMOLE			
			EndIf	

		EndIf
		(aTTName[RENDISEN])->(MsUnlock())
	Else
		RecLock(aTTName[RENDISEN],.F.)
		(aTTName[RENDISEN])->NVLRISENTO	+= (cAlsIsenc)->NVLRISENTO
		(aTTName[RENDISEN])->(MsUnlock()) 
	EndIf 
	(cAlsIsenc)->(DbSkip())
Enddo
(cAlsIsenc)->( DbCloseArea() )
			
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaDiv()
Grava o periodo de apuração nos pagamentos de dividendos (Natureza Rendimento 12001)
@param aDivid array, contém os recnos dos PGTs de dividendos
@cPerApur caracter, contém período da apuração

@author Karen Honda
@since 17/11/2023
@version 1.0
@return
/*/ 
//-------------------------------------------------------------------
Static Function GravaDiv(aDivid, cPerApur)
Local nX as Numeric

Default aDivid 	:= {}
Default cPerApur	:= ''
DbSelectArea("V3U")
For nX := 1 to Len(aDivid)
	V3U->( DbGoto(aDivid[nX][1]) )
	Reclock("V3U", .F.)
	V3U->V3U_PERAPU := cPerApur
	V3U->( MsUnlock() )
Next nX
Return 
