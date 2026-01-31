#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR4020.CH"

#DEFINE IDEBENEF  	1,1
#DEFINE IDEPGTO   	1,2
#DEFINE INFOPGTO  	1,3
#DEFINE INFOPROCRET 1,4
#DEFINE IDEADV  	1,5
#DEFINE CHVREC 	    1,6

Static oModel546 As Object
Static lTafRVld	 As Logical //MV_TAFRVLD
Static _nTamFil := TamSX3( "C1E_FILTAF" )[1]
Static _nTamNIF := TamSX3( "V5D_NIF"    )[1]
Static _cVsReinf := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} TafApr4020
Rotina de apuração R-4020 - Retenções na Fonte - Pessoa Jurídica MVC Espelho TAFA546
@param  cPeriod, caracter, periodo MMAAAA Ex. "092022"
@param aFil, array, array com a filial
@param lValid, logico, se realizar a validação
@param lSucesso, logico, retorno sobre a gravacao
@param cCNPJ, caracter, cnpj a ser processado

@author Denis Souza / Jose Mauro
@since 08/11/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Function TafApr4020( cPeriod, aFil, lValid, lSucesso, cCNPJ, aIDLog, cCodPar, cNif, lReinf212, lCentApr, cAliasAp, lImp )

Local nOpc		 	As Numeric
Local oTR4020    	As Object
Local oTIdePgto  	As Object
Local oTInfoPgto 	As Object
Local oTInfoProcRet	As Object
Local oTChvRec		As Object
Local cEvento		As Character
Local cVerAnt		As Character
Local cProTpn		As Character
Local cRetStat		As Character
Local cId			As Character
Local cAlias		As Character
Local cErro 		As Character
Local cAmbReinf	 	As Character
Local cChv			As Character
Local cIDApReinf 	As Character 
Local aTTName 	 	As Array
Local aPreMap		As Array
Local lR4010        As Logical
Local lOk     	    As Logical
Local lLoteErr  	As Logical
Local lDisarm  	 	As Logical
Local lApuSTri      As Logical
Local nContLog 		As Numeric
Local aInfoEUF		As Array

Default cPeriod    := ""
Default aFil 	   := { "", "", "", "", "", "", .F. }
Default lValid	   := .F.	
Default lSucesso   := .F.
Default cCNPJ      := ""
Default aIDLog     := {}
Default cCodPar    := ''
Default cNif       := ''
Default lReinf212  := .F.
Default lCentApr   := .F.
Default lImp	   := .F.

nOpc	  := MODEL_OPERATION_INSERT
aPreMap	  := {}
aTTName   := {}
cEvento   := ""
cVerAnt	  := ""
cProTpn	  := ""
cRetStat  := ""
cId		  := ""
cErro	  := ""
cIDApReinf:= ""
cAmbReinf := Left(GetNewPar( "MV_TAFAMBR", "2" ),1)
cChv	  := ""
lTafRVld  := lValid
lR4010    := .F.
lOk    	  := .F.
lLoteErr  := .T.
nContLog  := 0	
aInfoEUF  := {}
_cVsReinf := StrTran( SuperGetMv('MV_TAFVLRE',.F.,"1_03_02") , "_","" )
lApuSTri  := GetMv('MV_TAFSTRI',.F.,.F.)


aInfoEUF  := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
//Efetua Consulta Princial Fatura + Nota
If !lImp
	cAlias := TAFQRY40XX( cPeriod, 'R-4020', aFil, aInfoEUF, /*5*/, cCNPJ, lR4010, cCodPar, cNif, lReinf212, lApuSTri )
Else
	cAlias := cAliasAp
Endif

//Efetua Montagem da Estrutura de Tabelas Temporarias
TTR4020( @aTTName, @oTR4020, @oTIdePgto, @oTInfoPgto, @oTInfoProcRet, @oTChvRec )

//grava legado na temporaria
If GRVTMP( cAlias, aTTName, oTR4020, oTIdePgto, oTInfoPgto, oTInfoProcRet, oTChvRec, cPeriod, @aPreMap, lTafRVld, lReinf212, lApuSTri, lCentApr, lImp )
	//Grava espelho
	DbSelectArea("V5C")
	V5C->( DbSetOrder(2) ) //V5C_FILIAL, V5C_PERAPU, V5C_TPINSC, V5C_NRINSC, V5C_CNPJBN, V5C_IDEXTE, V5C_EVADIC, V5C_ATIVO, R_E_C_N_O_, D_E_L_E_T_

	DbSelectArea( aTTName[IDEBENEF] )
	( aTTName[IDEBENEF] )->(DbSetOrder(1))
	( aTTName[IDEBENEF] )->(DbGoTop())

	oModel546  := FWLoadModel("TAFA546")
	While (aTTName[IDEBENEF])->(!EOF())
		cEvento  := ""
		cVerAnt  := ""
		cProTpn  := ""
		cRetStat := ""
		cId 	 := ""
		lOk    	  := .T.
		lDisarm	  := .F.

		cChv     := cPeriod + ( aTTName[IDEBENEF] )->( CTPINSC + CNRINSC + CCNPJBN + CIDEXT)
		If lReinf212
			cChv += ( aTTName[IDEBENEF] )->CEVADIC
		EndIf
		//Verifica Situacao do Registro
		Stats40XX( "R-4020", cChv, @cVerAnt, @cProTpn, @cRetStat, @cId )

		cIDApReinf := TAFXLogIni( cIDApReinf, "R-4020", cPeriod )
		Begin Transaction

			If cRetStat $ 'Z'
				nOpc := MODEL_OPERATION_INSERT
				cEvento	:= 'I'
				If !GRV4020(nOpc,@oModel546,aTTName,aFil,cPeriod,nil,nil,cEvento,nil,@aPreMap,cAmbReinf,@aIDLog, cIDApReinf, lReinf212, lImp)
					lOk    	  := .F.
					lDisarm	  := .T.
				EndIf

			ElseIf cRetStat $ ' |0|1|3|7'
				If ExcluiReg( @aPreMap, @oModel546, @aIDLog, cPeriod, cIDApReinf )
					nOpc := MODEL_OPERATION_INSERT
					If cRetStat <> '7' .And. V5C->V5C_EVENTO == 'A'
						cEvento	:= 'A'
						If !GRV4020(nOpc,@oModel546,aTTName,aFil,cPeriod,V5C->V5C_VERANT,V5C->V5C_PROTPN,cEvento,cId,@aPreMap,cAmbReinf,@aIDLog, cIDApReinf, lReinf212, lImp)
							lOk    	  := .F.
							lDisarm	  := .T.
						EndIf
					Else
						cEvento	:= 'I'
						If !GRV4020(nOpc,@oModel546,aTTName,aFil,cPeriod,nil,nil,cEvento,nil,@aPreMap,cAmbReinf,@aIDLog, cIDApReinf, lReinf212, lImp)
							lOk    	  := .F.
							lDisarm	  := .T.
						EndIf
					EndIf
				EndIf
			ElseIf cRetStat $ '2|6'
				cErro := STR0030 + CRLF //"Registro transmitido ao governo e sem retorno, não deve ser alterado."
				cErro += STR0007 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
				cErro += STR0008 + (aTTName[IDEBENEF])->CTPINSC + CRLF 			//"tpInscEstab: "
				cErro += STR0008 + (aTTName[IDEBENEF])->CTPINSC + CRLF 			//"tpInscEstab: "
				cErro += STR0009 + (aTTName[IDEBENEF])->CNRINSC + CRLF + CRLF 	//"nrInscEstab: "
				cErro += STR0010 + (aTTName[IDEBENEF])->CCNPJBN + CRLF 			//"cnpjBenef: "			
				cChv := (aTTName[IDEBENEF])->FIL + '|' + cPeriod + '|' + (aTTName[IDEBENEF])->CTPINSC + '|' + (aTTName[IDEBENEF])->CNRINSC +'|'+ (aTTName[IDEBENEF])->CCNPJBN + '|' +(aTTName[IDEBENEF])->CIDEXT + '|' + (aTTName[IDEBENEF])->CEVADIC
				Aadd( aPreMap, { "R-4020", "ERRO", cErro, cChv } )
				If !lImp
					aAdd( aIDLog, { cIDApReinf, (aTTName[IDEBENEF])->FIL, Iif(!Empty((aTTName[IDEBENEF])->CCNPJBN),Alltrim( (aTTName[IDEBENEF])->CCNPJBN  ),Alltrim((aTTName[IDEBENEF])->CIDEXT)) } )
				else
					aAdd( aIDLog, { cIDApReinf, (aTTName[IDEBENEF])->FIL, Iif(!Empty((aTTName[IDEBENEF])->CCNPJBN),Alltrim( (aTTName[IDEBENEF])->CCNPJBN  ),Alltrim((aTTName[IDEBENEF])->CIDEXT)), cErro } )
				EndIf
				lOk := .F.
				lDisarm := .F.
			ElseIf cRetStat == '4'
				cVerAnt := V5C->V5C_VERSAO
				cProTpn := V5C->V5C_PROTUL
				cId		:= V5C->V5C_ID
				FAltRegAnt( 'V5C', '2', .F. ) //V5C_FILIAL, V5C_PERAPU, V5C_TPINSC, V5C_NRINSC, V5C_CNPJBN, V5C_ATIVO
				nOpc	:= MODEL_OPERATION_INSERT
				cEvento	:= 'A'
				If !GRV4020(nOpc,@oModel546,aTTName,aFil,cPeriod,cVerAnt,cProTpn,cEvento,cId,@aPreMap,cAmbReinf,@aIDLog, cIDApReinf, lReinf212, lImp)
					lOk    	  := .F.
					lDisarm	  := .T.
				EndIf
			EndIf
			If lLoteErr //Se lLoteErr for o false nao devera ser mais sobreposto com true, pois indica se o lote possui algum problema
				lLoteErr := lOk
			EndIf
			If lDisarm
				DisarmTransaction()
			EndIf

		End Transaction

		For nContLog := 1 to Len (aPreMap)

			cChv := cPeriod + '|' +(aTTName[IDEBENEF])->CTPINSC + '|' + (aTTName[IDEBENEF])->CNRINSC +'|'+ (aTTName[IDEBENEF])->CCNPJBN
			cChv += '|' + (aTTName[IDEBENEF])->CIDEXT
			cChv += '|' + (aTTName[IDEBENEF])->CEVADIC

			nPos := aScan(aPreMap,{|x| cChv $ x[04] })
			If nPos > 0
				TafXLog(cIdApReinf, aPreMap[nContLog][1], aPreMap[nContLog][2], aPreMap[nContLog][3], cPeriod )
			EndIf	
		Next nContLog

		TAFXLogFim( cIDApReinf, "R-4020" , cPeriod )
		(aTTName[IDEBENEF])->(DbSkip())

	EndDo
	oModel546:Destroy()
	oModel546 := Nil
EndIf

TTempDel( @oTR4020, @oTIdePgto, @oTInfoPgto, @oTInfoProcRet, @oTChvRec )

lSucesso := lLoteErr

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TTR4020()
Criação das tabelas temporárias referente ao evento R-4020

@author Jose Mauro
@since 22/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTR4020( aTTName, oTR4020, oTIdePgto, oTInfoPgto, oTInfoProcRet, oTChvRec )

Local cTR4020       As Character
Local cTIdePgto     As Character
Local cTInfoPgto    As Character
Local cTInfoProcRet	As Character
Local cTIdeAdv      As Character
Local cChvRec		As Character

Local aTR4020       As Array
Local aTIdePgto     As Array
Local aTInfoPgto    As Array
Local aTInfoProcRet As Array
Local aChvRec       As Array

//Incializa  o variaveis tipo caractere para armazenagem dos alias das temp tables
cTR4020       := GetNextAlias()
cTIdePgto     := GetNextAlias()
cTInfoPgto    := GetNextAlias()
cTInfoProcRet := GetNextAlias()
cTIdeAdv      := GetNextAlias()
cChvRec       := GetNextAlias()

aAdd( aTTName, { cTR4020, cTIdePgto, cTInfoPgto, cTInfoProcRet, cTIdeAdv, cChvRec } )

// Inicializa  o variaveis tipo array para armazenagem dos campos das temp tables
aTR4020       := {}
aTIdePgto     := {}
aTInfoPgto    := {}
aTInfoProcRet := {}
aChvRec		  := {}

//Popula os campos das tabelas temporarias
TTempCmp( @aTR4020, @aTIdePgto, @aTInfoPgto, @aTInfoProcRet, @aChvRec )

oTR4020       := FWTemporaryTable():New( cTR4020      , aTR4020       )
oTIdePgto     := FWTemporaryTable():New( cTIdePgto    , aTIdePgto     )
oTInfoPgto    := FWTemporaryTable():New( cTInfoPgto   , aTInfoPgto    )
oTInfoProcRet := FWTemporaryTable():New( cTInfoProcRet, aTInfoProcRet )
oTChvRec      := FWTemporaryTable():New( cChvRec   	  , aChvRec       )

TTempIdx( @oTR4020, @oTIdePgto, @oTInfoPgto, @oTInfoProcRet, @oTChvRec )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TTempCmp()
Criação dos indices nas tabelas temporárias referente ao evento R-4020

@author Jose Mauro / Denis Souza
@since 22/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTempCmp( aTR4020, aTIdePgto, aTInfoPgto, aTInfoProcRet, aChvRec, TTempCmp )

Local nTamFil := TamSX3( "C20_FILIAL" )[1] 

//V5C
aTR4020	:= { {'ID'	   , 'C', 250	 , 0 },;
			 {'FIL'	   , 'C', nTamFil, 0 },;
			 {'CTPINSC', 'C', 001	 , 0 },; //tpInscEstab		  (ok) 17
			 {'CNRINSC', 'C', 014	 , 0 },; //nrInscEstab		  (ok) 18
			 {'CIDPART', 'C', 036	 , 0 },; //ID do Participante ref 20
			 {'CCNPJBN', 'C', 014	 , 0 },; //cnpjBenef		  (ok) 20
			 {'CNMBENE', 'C', 070	 , 0 },; //nmBenef			  (ok) 21
			 {'CISEIMU', 'C', 001	 , 0 },;  //isenImun		  (ok) 22
			 {'CIDEXT' , 'C', 060	 , 0 },; //Id Exterior: NIF ou CODPAR
			 {'CPAISEXT','C', 003	 , 0 },;  //pais Exterior
			 {'CEVADIC', 'C', 008	 , 0 },;  //ideEvtAdic
			 {'ORIGEM',  'C', 001	 , 0 }}  //Origem Importação

//V5D
aTIdePgto := { {'ID'      , 'C', 250 	, 0 },;
			   {'FIL'	  , 'C', nTamFil, 0 },;
			   {'CIDNATRE', 'C', 006    , 0 },; //Id Nat Rendi				ref 24
			   {'CCNATRE' , 'C', 005    , 0 },; //Cod Nat Rendi				ref 24
			   {'CDNATRE' , 'C', 254    , 0 },; //Desc Nat Rendi			ref 24
			   {'COBSERV' , 'C', 200    , 0 },; //observ					(ok) 25
			   {'CPAISRE' , 'C', 003	, 0 },; //paisResid
			   {'CBAIRRO' , 'C', 060	, 0 },; //bairro  					(ok)
			   {'CCEP'	  , 'C', 012	, 0 },; //codPostal					(ok) 85
			   {'CCIDADE' , 'C', 030	, 0 },; //cidade  					(ok) 83
			   {'CCOMPLE' , 'C', 030	, 0 },; //complem  					(ok) 81
			   {'CESTADO' , 'C', 030	, 0 },; //estado  					(ok) 84
			   {'CINDNIF' , 'C', 001	, 0 },; //indNif					(ok) 74
			   {'CLOGRAD' , 'C', 080	, 0 },; //dscLograd 				(ok) 79
			   {'CNIF'	  , 'C', _nTamNIF, 0 },; //nifBenef					(ok) 75
			   {'CNRLOGR' , 'C', 010	, 0 },; //nrLograd 					(ok) 80
			   {'CTELEF'  , 'C', 015	, 0 },; //telef						(ok) 86
			   {'CIDTRIB' , 'C', 036	, 0 },; //ID Forma Tributacao T9A 	ref 77
			   {'CCTRIB'  , 'C', 002	, 0 },; //frmTribut					(ok) 77
			   {'CDTRIB'  , 'C', 254	, 0 },; //Desc. Tribut 				ref 77
			   {'CRELPGT' , 'C', 003	, 0 },; //relFontPg					(ok) 76
			   {'CIDRELP' , 'C', 006	, 0 },; //Id Rel PG - Rel Pgto CUB 	ref 76
			   {'CDRELPG' , 'C', 250	, 0 } } //Desc. Rel 				ref 76

//V4S
aTInfoPgto := { {'ID'        ,'C', 250	  , 0 },;
				{'FIL'		 ,'C', nTamFil, 0 },;
				{'CIDMOV'	 ,'C', 3+nTamFil+36, 0 },; //Prefixo+Filial+Id
				{'CTRIB'	 ,'C', 006	  , 0 },; //chave P/ Controle PGTO | FAT | NOTA Total/Total Cred
				{'DDTFG'     ,'D', 008	  , 0 },; //dtFG			(ok) 27
				{'NVBRUTO'	 ,'N', 014	  , 2 },; //vlrBruto	    (ok) 28
				{'CINDFCISCP','C', 001	  , 0 },; //indFciScp		(ok) 29
				{'CIDFCISCP' ,'C', 036	  , 0 },; //nrInscFciScpId 	ref 29
				{'CNRINSFCSC','C', 014	  , 0 },; //nrInscFciScp	(ok) 30
				{'NPERCSCP'  ,'N', 004	  , 1 },; //percSCP		 	(ok) 31				  
				{'CINDJUD'	 ,'C', 001	  , 0 },; //indJud		 	(ok) 32
				{'CJUDRRA'   ,'C', 036	  , 0 },; //infoRRA-Id	    ref 32	  
				{'CPAISRE'	 ,'C', 003	  , 0 },; //paisResidExt	(ok) 33
				{'NBSIR'	 ,'N', 014	  , 2 },; //vlrBaseIR		(ok) 35
				{'NVLIR'	 ,'N', 014	  , 2 },; //vlrIR			(ok) 36
				{'NBSAGRE'	 ,'N', 014	  , 2 },; //vlrBaseAgreg	(ok) 37
				{'NVLAGRE'	 ,'N', 014	  , 2 },; //vlrAgreg		(ok) 38
				{'NBSCSLL'	 ,'N', 014	  , 2 },; //vlrBaseCSLL	    (ok) 39
				{'NVLCSLL'	 ,'N', 014	  , 2 },; //vlrCSLL		    (ok) 40
				{'NBSCOF'	 ,'N', 014	  , 2 },; //vlrBaseCofins	(ok) 41	
				{'NVLCOF'	 ,'N', 014	  , 2 },; //vlrCofins		(ok) 42
				{'NBSPP'	 ,'N', 014	  , 2 },; //vlrBasePP		(ok) 43
				{'NVLPP'	 ,'N', 014	  , 2 },; //vlrPP		    (ok) 44
				{'DDTESCRCT' ,'D', 008	  , 0 },; //dtEscrCont
				{'COBSERV'   ,'C', 200	  , 0 }}  //observ


//V5F
aTInfoProcRet := { {'ID'      	, 'C', 250    ,0 },;
				   {'FIL'	    , 'C', nTamFil,0 },;				 
				   {'CTPPROCRET', 'C', 001	  ,0 },; //tpProcRet		 (ok) 46
				   {'CNRPROCRET', 'C', 021	  ,0 },; //nrProcRet 		 (ok) 47 //todo TamSx3("C1G_NUMPRO")[1] ,0},; //NRPROCRETPRINC OU NRPROCRETADIC
				   {'CODSUSP'   , 'C', 014	  ,0 },; //codSusp			 (ok) 48
				   {'BSSUSPIR'  , 'N', 014	  ,2 },; //vlrBaseCSLL		 (ok) 49
				   {'VALSUSIR'  , 'N', 014	  ,2 },; //vlrNIR			 (ok) 50
				   {'VLRDEPIR'  , 'N', 014	  ,2 },; //vlrDepIR			 (ok) 51
				   {'BSSUSPCSL' , 'N', 014	  ,2 },; //vlrBaseSuspCSLL	 (ok) 52
				   {'VALSUSCSL' , 'N', 014	  ,2 },; //vlrNCSLL			 (ok) 53
				   {'VLRDEPCSL' , 'N', 014	  ,2 },; //vlrDepCSLL		 (ok) 54
				   {'BSSUSPCOF' , 'N', 014	  ,2 },; //vlrBaseSuspCofins (ok) 55
				   {'VALSUSCOF' , 'N', 014	  ,2 },; //vlrNCofins		 (ok) 56
				   {'VLRDEPCOF' , 'N', 014	  ,2 },; //vlrDepCofins		 (ok) 57
				   {'BSSUSPPP'  , 'N', 014	  ,2 },; //vlrBaseSuspPP	 (ok) 58
				   {'VALSUSPP'  , 'N', 014	  ,2 },; //vlrNPP			 (ok) 59
				   {'VLRDEPPP'  , 'N', 014	  ,2 } } //vlrDepPP			 (ok) 60

//Chave X Recno
aChvRec := { {'CHAVE'	 ,'C', 250, 0 },;
			 {'NREGISTR' ,'N', 020, 0 },;
			 {'CROTINA'  ,'C', 003, 0 },;
			 {'CCNATRE'  ,'C', 005, 0 }}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TTempIdx()
Criação dos indices nas tabelas temporárias referente ao evento R-4020

@author Jose Mauro
@since 22/08/2019
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTempIdx( oTR4020, oTIdePgto, oTInfoPgto, oTInfoProcRet, oTChvRec )

oTR4020:AddIndex("1", {"ID"})
oTIdePgto:AddIndex("1", {"ID"})
oTInfoPgto:AddIndex("1", {"ID"})
oTInfoProcRet:AddIndex("1", {"ID"})
oTChvRec:AddIndex("1", {"CHAVE"})

//Cria a tabela fisicamente 
oTR4020:Create()
oTIdePgto:Create()
oTInfoPgto:Create()
oTInfoProcRet:Create()
oTChvRec:Create()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TTempDel()
Mecanismo de destruição das tabelas temporárias referente ao evento R-4020

@author Denis Souza
@since 09/11/2022
@version 1.0
@Return

/*/ 
//-------------------------------------------------------------------
Static Function TTempDel( oTR4020, oTIdePgto, oTInfoPgto, oTInfoProcRet, oTChvRec )

oTR4020:Delete()    
oTIdePgto:Delete()  
oTInfoPgto:Delete() 
oTInfoProcRet:Delete()
oTChvRec:Delete() 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GRVTMP()

@author Denis Souza
@since 02/09/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function GRVTMP( cAlias, aTTName, oTR4020, oTIdePgto, oTInfoPgto, oTInfoProcRet, oTChvRec, cPeriod, aPreMap, lTafRVld, lReinf212, lApuSTri, lCentApr, lImp )

Local lAvanc     As Logical
Local cCompC1G   As Character
Local cChaveV5C  As Character
Local cChaveV5D  As Character
Local cChaveV4S  As Character
Local cMovID 	 As Character
Local cLastMovID As Character
Local aQtdFCI    As Array
Local aQtdSCP    As Array
Local aInfoEUF   As Array
Local aProcRet   As Array
Local aSM0EUF	 As Array
Local cIdEvAdic	 As Character

Default cAlias		  := Nil
Default oTR4020		  := Nil
Default oTIdePgto	  := Nil
Default oTInfoPgto	  := Nil
Default oTInfoProcRet := Nil
Default oTChvRec      := Nil
Default aTTName		  := {}
Default aPreMap		  := {}
Default cPeriod       := ""
Default lTafRVld	  := .F.
Default lReinf212	  := .F.
Default lApuSTri      := .F.
Default lCentApr   	  := .F.

lAvanc  	:= .T.
cCompC1G  	:= ""
cChaveV5C 	:= ""
cChaveV5D 	:= ""
cChaveV4S 	:= ""
cMovID 		:= ""
cLastMovID 	:= ""
aSM0EUF 	:= {}
aInfoEUF    := {}
aProcRet    := {}
aQtdFCI     := {}
aQtdSCP     := {}
cIdEvAdic	:= ""

DbSelectArea(cAlias)
(cAlias)->(DbGoTop())

If (cAlias)->(!EOF())
	aInfoEUF  := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	cNrInscE  := Posicione("SM0", 1, cEmpAnt + (cAlias)->FILIAL, "M0_CGC")
	cCompC1G  := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3))) // 1=Empresa, 2=Unidade de Negócio e 3=Filial
	aSM0EUF   := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
	If Len(Alltrim(cNrInscE))>11 .And. Len(Alltrim(cNrInscE))<=14
		cTpInscE:="1"
	ElseIf Len(Alltrim(cNrInscE))<=11
		cTpInscE:="2"
	EndIf
	dbSelectArea("C1E")
	C1E->(dbSetOrder(3))
	If C1E->(MSSeek(XFilial("C1E")+PadR((cAlias)->FILIAL, _nTamFil)+"1"))
		If !Empty(C1E->C1E_CAEPFR) .And. (Len(Alltrim(cNrInscE))<=11)
			cTpInscE := "3"
			cNrInscE := C1E->C1E_CAEPFR
		EndIf

		If lReinf212
			cIdEvAdic := C1E->C1E_EVADIC
		EndIf	
	EndIf	
	//-------------------------------------------- 
	// Selecao Tabelas Temporarias
	//--------------------------------------------
	DbSelectArea( aTTName[IDEBENEF] )
	( aTTName[IDEBENEF] )->(DbSetOrder(1))

	DbSelectArea( aTTName[IDEPGTO] )
	( aTTName[IDEPGTO] )->(DbSetOrder(1))

	DbSelectArea( aTTName[INFOPGTO] )
	( aTTName[INFOPGTO] )->(DbSetOrder(1))

	DbSelectArea( aTTName[INFOPROCRET] )
	( aTTName[INFOPROCRET] )->(DbSetOrder(1))

	DbSelectArea( aTTName[CHVREC] )
	( aTTName[CHVREC] )->(DbSetOrder(1))

	While (cAlias)->(!EOF())
		If (cAlias)->ROTINA == "FAT"
			cMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->LEMID
		ElseIf (cAlias)->ROTINA == "NFS"
			cMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->CHVNF
		ElseIf (cAlias)->ROTINA == "PGT"
			cMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->V3UID
		EndIf
		//O agrupamento ocorre por CNPJ para as filiais de mesmo CNPJ
		cChaveV5C := /* (cAlias)->FILIAL + '|' +  */ cPeriod + '|' +  cTpInscE + '|' +  cNrInscE + '|' +  (cAlias)->(CNPJ)
		If !Empty((cAlias)->CODPAI)
			If !Empty((cAlias)->NIF)
				cChaveV5C += '|' + PADR((cAlias)->NIF,60) 
			ElseIf !Empty((cAlias)->CODPAR)
				cChaveV5C += '|' + PADR((cAlias)->CODPAR,60)
			Else
				cChaveV5C += '|' + PADR((cAlias)->NOME,60)
			EndIf
		Else
			cChaveV5C += '|' + Space(60)	
		EndIf	
		If lReinf212
			cChaveV5C +=  IIF(lImp,'|' + PADR((cAlias)->CEVADIC,8),'|' + PADR(cIdEvAdic,8))
		EndIf	

		//--------------------------------------------------------------------------------------------------------------
		// Controle de RECNO dos legados utilizados em cada chave de apuração controle necessário devido Commit\RollBack
		//--------------------------------------------------------------------------------------------------------------
		PopChvRec( cAlias, aTTName[CHVREC], cChaveV5C )
		//--------------------------------------------
		//         ideBenef - V5C
		//--------------------------------------------
		PopIdeBenef( cAlias, cTpInscE, cNrInscE, aTTName[IDEBENEF], cChaveV5C, @aPreMap, lTafRVld, cIdEvAdic, lImp )
		cIdNat   := (cAlias)->IDNATR
		cChaveV5D := cChaveV5C + '|' + cIdNat
		//--------------------------------------------
		//         idePgto - V5D
		//--------------------------------------------
		PopIdePgto( cAlias, cIdNat, aTTName[IDEPGTO], cChaveV5D )

		cTribNat := (cAlias)->TRIBNAT
		cTribID  := (cAlias)->IDTRIB2

		dFatoGer := Ctod("  /  /    ")
		If (cAlias)->ROTINA == "PGT"
			dFatoGer := (cAlias)->DTPV3U
		ElseIf (cAlias)->ROTINA == "INT"
			dFatoGer := StoD((cAlias)->DTEMISSA)
		Else
			dFatoGer := (cAlias)->DTEMISSA
		EndIf

		cChaveV4S := cChaveV5D + '|' + Dtos( dFatoGer ) //+ "|" + (cAlias)->IDRRAPJD + "|" + (cAlias)->INDFCISCP + "|" + (cAlias)->IDSCP

		//-------------------------------------------- 
		// 					infoPgto V4S
		//--------------------------------------------
		PopInfoPgt(cAlias,cIdNat,dFatoGer,cTribNat,cTribID,aTTName[INFOPGTO],cChaveV4S,aProcRet,@aQtdFCI,@aQtdSCP,@aPreMap, lReinf212)

		//-------------------------------------------- 
		// 				 infoProcRet V5F
		//--------------------------------------------
		If !lImp
			If cMovID <> cLastMovID .and. Iif(lApuSTri,.T.,!Empty((cAlias)->IDTRIB2))
				PopProcRet( cAlias, aTTName[INFOPROCRET], @aTTName, cChaveV4S, cCompC1G, aSM0EUF, @aPreMap, @cLastMovID, lApuSTri, lCentApr)
			EndIf
		Endif

		(cAlias)->(DbSkip())
	EndDo
Else
	lAvanc := .F.
EndIf

(cAlias)->( DbCloseArea() )

return lAvanc

//-------------------------------------------------------------------
/*/{Protheus.doc} PopChvRec()

@author Denis Souza
@since 08/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function PopChvRec( cAlias, cNmChvRec, cChaveV5C) 

RecLock(cNmChvRec,.T.)
	(cNmChvRec)->CHAVE    := cChaveV5C
	(cNmChvRec)->NREGISTR := (cAlias)->RECNO
	(cNmChvRec)->CROTINA  := (cAlias)->ROTINA
	(cNmChvRec)->CCNATRE  := (cAlias)->CCNATRE
(cNmChvRec)->(MsUnlock())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdeBenef()

@author Denis Souza
@since 08/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function PopIdeBenef( cAlias, cTpInscE, cNrInscE, cNmIdeBenef, cChaveV5C, aPreMap, lTafRVld, cIdEvAdic, lImp )
Local lVSup211 as Logical

Default cIdEvAdic := ""

lVSup211 	:= Alltrim(_cVsReinf) > '20101'

If !(cNmIdeBenef)->( DbSeek(cChaveV5C) )
	RecLock(cNmIdeBenef, .T.)
		(cNmIdeBenef)->ID      := cChaveV5C
		(cNmIdeBenef)->FIL     := (cAlias)->FILIAL
		(cNmIdeBenef)->CTPINSC := cTpInscE
		(cNmIdeBenef)->CNRINSC := cNrInscE
		(cNmIdeBenef)->CIDPART := (cAlias)->C1H_ID
		(cNmIdeBenef)->CCNPJBN := (cAlias)->CNPJ
		(cNmIdeBenef)->CNMBENE := (cAlias)->NOME
		(cNmIdeBenef)->CISEIMU := iif((cAlias)->ISENT $ '2|3' ,(cAlias)->ISENT,  Iif(lVSup211,'','1')) //Valores validos 2 e 3
		(cNmIdeBenef)->CEVADIC := IIF(lImp,(cAlias)->CEVADIC,cIdEvAdic)
		(cNmIdeBenef)->ORIGEM  := IIF(lImp,'I',' ' )
		If !Empty((cAlias)->CODPAI)
			If !Empty((cAlias)->NIF)
				(cNmIdeBenef)->CIDEXT := (cAlias)->NIF 
			ElseIf !Empty((cAlias)->CODPAR)
				(cNmIdeBenef)->CIDEXT := (cAlias)->CODPAR
			Else
				(cNmIdeBenef)->CIDEXT := (cAlias)->NOME
			EndIf

			(cNmIdeBenef)->CPAISEXT  := (cAlias)->CODPAI

			If Empty((cAlias)->INDNIF) 
				Aadd( aPreMap, {"R-4020", Iif(lTafRVld, "ERRO", "ALERTA"), STR0031, cChaveV5C } ) 	//"Indicador NIF não preenchido."			
			EndIf
			If Empty((cAlias)->IDTRIB) 	
				Aadd( aPreMap, {"R-4020", Iif(lTafRVld, "ERRO", "ALERTA"), STR0032, cChaveV5C } ) //"Forma de tributação não preenchida."				
			EndIf	
		EndIf

	(cNmIdeBenef)->(MsUnlock())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdePgto()

@author Denis Souza
@since 08/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function PopIdePgto( cAlias, cIdNat, cNmIdePgto, cChaveV5D )

If !( cNmIdePgto )->(DbSeek( cChaveV5D ) )
	RecLock( cNmIdePgto ,.T.)
	(cNmIdePgto)->ID	   := cChaveV5D
	(cNmIdePgto)->FIL      := (cAlias)->FILIAL
	(cNmIdePgto)->CIDNATRE := cIdNat
	(cNmIdePgto)->CCNATRE  := (cAlias)->CCNATRE
	(cNmIdePgto)->CDNATRE  := AllTrim((cAlias)->CDNATRE)
	(cNmIdePgto)->COBSERV  := ''
	(cNmIdePgto)->CINDNIF  := (cAlias)->INDNIF
	(cNmIdePgto)->CNIF     := (cAlias)->NIF
	(cNmIdePgto)->CIDRELP  := (cAlias)->RELFONT
	(cNmIdePgto)->CIDTRIB  := (cAlias)->IDTRIB
	(cNmIdePgto)->CCTRIB   := StrZero(Val((cAlias)->CCTRIB),2)
	(cNmIdePgto)->CDTRIB   := (cAlias)->CDTRIB
	(cNmIdePgto)->CLOGRAD  := (cAlias)->LOGEXT
	(cNmIdePgto)->CNRLOGR  := IIF(ALLTRIM((cAlias)->NUMEXT) $ "SN|S/N",'',ALLTRIM((cAlias)->NUMEXT))
	(cNmIdePgto)->CCOMPLE  := (cAlias)->COMEXT
	(cNmIdePgto)->CPAISRE  := (cAlias)->PAISEXT
	(cNmIdePgto)->CBAIRRO  := (cAlias)->BAIEXT
	(cNmIdePgto)->CCIDADE  := (cAlias)->NMCEXT
	(cNmIdePgto)->CESTADO  := (cAlias)->ESTEXT
	(cNmIdePgto)->CCEP     := (cAlias)->CDPOSE
	(cNmIdePgto)->CTELEF   := (cAlias)->TELEXT
	(cNmIdePgto)->CRELPGT  := (cAlias)->CRELPGT
	(cNmIdePgto)->CDRELPG  := Alltrim((cAlias)->CDRELPG)
	(cNmIdePgto)->(MsUnlock())
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopProcRet()
Função que popula a tabela temporária de infoProcRet

@author Denis Souza
@since 11/11/2022
@version 1.0
@return

/*/
//-------------------------------------------------------------------
Static Function PopProcRet(cAlias,cNmInfoProc,aTTName,cChaveV4S,cCompC1G,aSM0EUF,aPreMap,cLastMovID, lApuSTri, lCentApr)

Local cTipPro 	As Character
Local cAliasPro As Character
Local cChvProc  As Character
Local l4010     As Logical

Default cAlias		:= ""
Default cNmInfoProc := ""
Default aTTName		:= {}
Default cChaveV4S	:= ""
Default cCompC1G	:= ""
Default aSM0EUF		:= {}
Default aPreMap     := {}
Default lApuSTri    := .F.
Default lCentApr   	  := .F.

cAliasPro := ""
cChvProc  := ""
cTipPro   := ""
l4010     := .F.
cAliasPro := TafProcRet( cAlias, cChaveV4S, cCompC1G, aSM0EUF, l4010, lApuSTri )

If !Empty(cAliasPro) .And. Select( cAliasPro ) > 0 .And. (cAliasPro)->( !Eof() )
	While (cAliasPro)->( !Eof() )
		cTipPro := iif( !Empty((cAliasPro)->CTPPROC), (cAliasPro)->CTPPROC, Iif((cAliasPro)->C1GTPPROC == "1", "2", "1") )
		If lCentApr == .F.
			cChvProc := cChaveV4S + '|' + cTipPro + '|' + (cAliasPro)->NUMPRO
		else
			cChvProc := cChaveV4S + '|' + cTipPro 
		EndIf
		If !(cNmInfoProc)->( DBSeek( cChvProc ) )
			RecLock(cNmInfoProc, .T. )
				( cNmInfoProc )->ID	   		:= cChvProc
				( cNmInfoProc )->FIL	   	:= (cAlias)->FILIAL
				( cNmInfoProc )->CTPPROCRET	:= cTipPro
				( cNmInfoProc )->CNRPROCRET := (cAliasPro)->C1GNUMPRO
				( cNmInfoProc )->CODSUSP 	:= (cAliasPro)->CODSUS
				If (cAliasPro)->CODTRI $ ("000012|000028") //IR
					( cNmInfoProc )->BSSUSPIR := (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSIR := (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPIR	:= (cAliasPro)->VLRDEP
					EndIf
				ElseIf (cAliasPro)->CODTRI $ ("000018") //CSLL
					( cNmInfoProc )->BSSUSPCSL := (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSCSL := (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPCSL := (cAliasPro)->VLRDEP
					EndIf					
				ElseIf (cAliasPro)->CODTRI $ ("000011") //COFINS
					( cNmInfoProc )->BSSUSPCOF := (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSCOF := (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPCOF := (cAliasPro)->VLRDEP
					EndIf
				ElseIf (cAliasPro)->CODTRI $ ("000010") //PIS/PASEP
					( cNmInfoProc )->BSSUSPPP := (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSPP := (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPPP := (cAliasPro)->VLRDEP
					EndIf
				EndIf
			(cNmInfoProc)->( MsUnlock() )
		Else
			RecLock(cNmInfoProc, .F. )
				If (cAliasPro)->CODTRI $ ("000012|000028") //IR
					( cNmInfoProc )->BSSUSPIR += (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSIR += (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPIR	+= (cAliasPro)->VLRDEP
					EndIf
				ElseIf (cAliasPro)->CODTRI $ ("000018") //CSLL
					( cNmInfoProc )->BSSUSPCSL += (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSCSL += (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPCSL += (cAliasPro)->VLRDEP
					EndIf					
				ElseIf (cAliasPro)->CODTRI $ ("000011") //COFINS
					( cNmInfoProc )->BSSUSPCOF += (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSCOF += (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPCOF += (cAliasPro)->VLRDEP
					EndIf
				ElseIf (cAliasPro)->CODTRI $ ("000010") //PIS/PASEP
					( cNmInfoProc )->BSSUSPPP += (cAliasPro)->BSSUSP
					( cNmInfoProc )->VALSUSPP += (cAliasPro)->VALSUS
					If (cAliasPro)->INDDEP == '1'
						(cNmInfoProc)->VLRDEPPP += (cAliasPro)->VLRDEP
					EndIf
				EndIf
			(cNmInfoProc)->( MsUnlock() )
		EndIf
		(cAliasPro)->( DbSkip() )
	Enddo
EndIf
(cAliasPro)->( DbCloseArea() )

If (cAlias)->ROTINA == "FAT"
	cLastMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->LEMID
ElseIf (cAlias)->ROTINA == "NFS"
	cLastMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->CHVNF
ElseIf (cAlias)->ROTINA == "PGT"
	cLastMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->V3UID
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PopInfoPgt()

@author Denis Souza
@since 09/11/2022
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function PopInfoPgt(cAlias,cIdNat,dFatoGer,cTribNat,cTribID,cNmInfoPgto,cChaveV4S,aProcRet,aQtdFCI,aQtdSCP,aPreMap, lReinf212)

Local cMovID 	As Character
Local cCnpjSCP  As Character
Local cErro	    As Character
Local cPercSCP  As Character
Local cTipoLig  As Character
Local nPos      As Numeric

Default cAlias      := ""
Default cIdNat      := ""
Default dFatoGer    := ""
Default cTribNat    := ""
Default cTribID		:= ""
Default cNmInfoPgto	:= ""
Default cChaveV4S	:= ""
Default aProcRet    := {}
Default aQtdFCI		:= {}
Default aQtdSCP 	:= {}
Default aPreMap     := {}
Default lReinf212   := .F.

cMovID 	 := ''
cCnpjSCP := ''
cErro 	 := ''
cPercSCP := ''
nPos     := 0

If (cAlias)->ROTINA == "FAT"
	cMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->LEMID
ElseIf (cAlias)->ROTINA == "NFS"
	cMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->CHVNF + (cAlias)->NUMITE
ElseIf (cAlias)->ROTINA == "PGT"
	cMovID := (cAlias)->ROTINA + (cAlias)->FILIAL + (cAlias)->V3UID
EndIf

If !( cNmInfoPgto )->(DbSeek( cChaveV4S ) ) //
	RecLock( cNmInfoPgto , .T. )
		(cNmInfoPgto)->ID 		  := cChaveV4S
		(cNmInfoPgto)->FIL 		  := (cAlias)->FILIAL
		(cNmInfoPgto)->CIDMOV 	  := cMovID
		(cNmInfoPgto)->CTRIB 	  := cTribID
		(cNmInfoPgto)->DDTFG 	  := dFatoGer
		(cNmInfoPgto)->CINDFCISCP := (cAlias)->INDFCISCP

		If !Empty((cAlias)->INDFCISCP)
			If SCPR40XX( cAlias, @cCnpjSCP, @cPercSCP, @cTipoLig )
				(cNmInfoPgto)->CNRINSFCSC := cCnpjSCP
				If cTipoLig == "4" // SCP
					(cNmInfoPgto)->NPERCSCP := cPercSCP
				EndIf	
			Else
				(cNmInfoPgto)->CNRINSFCSC := ' '
				cErro := STR0028 //"Indicativo da origem do rendimento preenchido porém sem informações do FCI/SCP."
			EndIf
		EndIf

		(cNmInfoPgto)->CINDJUD := iif(!Empty((cAlias)->IDRRAPJD),'1','2') //1=Sim;2=Nao
		(cNmInfoPgto)->CJUDRRA := (cAlias)->IDRRAPJD
		(cNmInfoPgto)->CPAISRE := (cAlias)->PAISEXT
		(cNmInfoPgto)->NVBRUTO := (cAlias)->VLBRUT

		If cTribID $ ("000029|000030") //Se tiver o tributo CSRF agrega PCC e COSIRF agrega IR E PCC 
			(cNmInfoPgto)->NBSAGRE := (cAlias)->BASECA
			(cNmInfoPgto)->NVLAGRE := (cAlias)->VLTRIB
		ElseIf cTribID $ ("000012|000028") .or. Empty(cTribID) //IR
			(cNmInfoPgto)->NBSIR := (cAlias)->BASECA
			(cNmInfoPgto)->NVLIR := (cAlias)->VLTRIB
		ElseIf cTribID $ ("000018") //CSLL
			(cNmInfoPgto)->NBSCSLL := (cAlias)->BASECA
			(cNmInfoPgto)->NVLCSLL := (cAlias)->VLTRIB
		ElseIf cTribID $ ("000011") //COFINS
			(cNmInfoPgto)->NBSCOF := (cAlias)->BASECA
			(cNmInfoPgto)->NVLCOF := (cAlias)->VLTRIB
		ElseIf cTribID $ ("000010") //PIS/PASEP
			(cNmInfoPgto)->NBSPP := (cAlias)->BASECA
			(cNmInfoPgto)->NVLPP := (cAlias)->VLTRIB
		EndIf
	(cNmInfoPgto)->( MsUnlock() )
Else
	lastId := (cNmInfoPgto)->CIDMOV //Id encontrado no seek
	//Controle para a Fatura e o Pagamento, caso exista mais de um tributo, serao 2 registros porem nao deverao ser somados no Total bruto, 
	//diferente da nota, onde a mesma podera possuir mais de um item no T015 e deverá ser contabilizado.
	//Coluna SUMBRT, se existir pgto no mesmo dia que houve fatura nao soma bruto.
	RecLock( cNmInfoPgto, .F. )
		If  ( (cAlias)->ROTINA == "PGT" .And. (cAlias)->SUMBRT == 'S' .And. (lastId <> cMovID) ) .Or. ( (cAlias)->ROTINA $ "FAT|NFS" .And. (lastId <> cMovID) )
			(cNmInfoPgto)->NVBRUTO += (cAlias)->VLBRUT
			(cNmInfoPgto)->CIDMOV := cMovID //Atualiza o Id pois se trata de um novo lancamento
		EndIf
		If cTribID $ ("000029|000030") //2=IR, CSLL, COFINS, PP e Agreg | 5=IR,CSLL e Agreg | 7=CSSL,COFINS,PP e Agreg
			(cNmInfoPgto)->NBSAGRE += (cAlias)->BASECA
			(cNmInfoPgto)->NVLAGRE += (cAlias)->VLTRIB
		ElseIf cTribID $ ("000012|000028") .OR. Empty(cTribID)//IR
			(cNmInfoPgto)->NBSIR += (cAlias)->BASECA
			(cNmInfoPgto)->NVLIR += (cAlias)->VLTRIB
		ElseIf cTribID $ ("000018")  //CSLL
			(cNmInfoPgto)->NBSCSLL += (cAlias)->BASECA
			(cNmInfoPgto)->NVLCSLL += (cAlias)->VLTRIB
		ElseIf cTribID $ ("000011") //COFINS
			(cNmInfoPgto)->NBSCOF += (cAlias)->BASECA
			(cNmInfoPgto)->NVLCOF += (cAlias)->VLTRIB
		ElseIf cTribID $ ("000010") //PIS/PASEP
			(cNmInfoPgto)->NBSPP += (cAlias)->BASECA
			(cNmInfoPgto)->NVLPP += (cAlias)->VLTRIB
		EndIf
	(cNmInfoPgto)->( MsUnlock() )
EndIf

If lReinf212
	If !Empty( (cAlias)->DTESCO )
		(cNmInfoPgto)->DDTESCRCT := (cAlias)->DTESCO
	EndIf	
	If (cAlias)->ROTINA == 'FAT' 
		If !Empty( (cAlias)->OBSERV )
			(cNmInfoPgto)->COBSERV  	:= Substr( (cAlias)->OBSERV, 1, 200 )
		EndIf	
	ElseIf (cAlias)->ROTINA == 'NFS' .or. (cAlias)->ROTINA == 'PGT'
		If (cAlias)->ROTINA == 'NFS'
			//Busca a descrição do campo memo
			C21->(DbSetOrder(1))
			If C21->( MsSeek( (cAlias)->FILIAL + (cAlias)->CHVNF ) )
				If !Empty( C21->C21_DESCRI )
					(cNmInfoPgto)->COBSERV  	:= Substr( C21->C21_DESCRI, 1, 200 )
				EndIf	
			EndIf
		else
			V3U->(DbSetOrder(1))
			If V3U->( MsSeeK( (cAlias)->FILIAL +(cAlias)->V3UID ))
				If !Empty( V3U->V3U_OBSERV )
					(cNmInfoPgto)->COBSERV	:= Substr( V3U->V3U_OBSERV, 1, 200 )
				Endif
			Endif
		Endif
	EndIf
EndIf

If !Empty(cErro)
	nPos := aScan(aPreMap,{|x| x[04] == AllTrim( cChaveV4S ) } )
	If nPos > 0
		aPreMap[nPos][3] += cErro
	Else
		Aadd( aPreMap, {"R-4020", Iif(lTafRVld, "ERRO", "ALERTA"), cErro, cChaveV4S } )
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Stats40XX
Verifica a existência ou não do registro que será apurado

@author Denis Souza
@since
@version 1.0

@parameters Retorna o status do registro encontrado, caso contrário retorna status "Z", 
indicando que ainda não existe o registro no cadastro espelho
@return
/*/ 
//-------------------------------------------------------------------
Static Function Stats40XX( cReg, cChave, cVerAnt, cProTpn, cRetStat, cId )

Default cReg   	 := ""
Default cChave   := ""
Default cVerAnt  := ""
Default cProTpn  := ""
Default cRetStat := "Z"
Default cId		 := ""

If V5C->( DbSeek( xFilial("V5C",cFilAnt) + cChave + '1') ) //cPeriod + cTpInsc + cNrInsc + CNPJ + IdEXT
	cVerAnt	 := V5C->V5C_VERSAO
	cProTpn  := V5C->V5C_PROTUL
	cRetStat := V5C->V5C_STATUS
	cId		 := V5C->V5C_ID
Else
	cVerAnt  := ""
	cProTpn  := ""
	cRetStat := "Z"
	cId		 := ""
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GRV4020()
Efetua gravação no modelo da tabela espelho do evento 
R-4020 Retenções na Fonte Pessoa Jurídica

@author Denis Souza
@since 02/09/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function GRV4020(nOpc,oModel546,aTTName,aFil,cPerApu,cVerAnt,cProTpn,cEvento,cId,aPreMap,cAmbReinf,aIDLog, cIDApReinf, lReinf212, lImp)

Local aAreaSM0 	 As Array
Local aInfoC1E	 As Array
Local aMovs      As Array
Local aDivid     As Array
Local lOk		 As Logical
Local oModelV5C  As Object
Local oMdlV5DA 	 As Object
Local oMdlV4SA 	 As Object
Local oModelV5F  As Object
Local oModelV5G  As Object
Local cAliasV5C  As Character
Local cAliasV5D  As Character
Local cAliasV4S  As Character
Local cAliasV5F  As Character
Local cAliasChv  As Character
Local cChvV5C    As Character
Local cChvV5D    As Character
Local cChvV4S    As Character
Local cChvV5F    As Character
Local cChvV5G    As Character
Local cStatus    As Character
Local cIdNat	 As Character
Local cDtFg		 As Character
Local cTpNInsc	 As Character
Local cPaisExt   As Character
Local cIdExt	 As Character
Local nQtdNatP	 As Numeric
Local nQtdFtG    As Numeric
Local nQtdProR	 As Numeric
Local nQtdAdv	 As Numeric
Local cFilBenef  As Character
Local cCnpj 	 As Character
Local nTamFil	 As Numeric
Local nC1EArray	 As Numeric

Default nOpc  	   := 0
Default oModel546  := nil
Default aTTName    := {}
Default aFil 	   := {}
Default cPerApu    := ""
Default cVerAnt    := ""
Default cProTpn    := ""
Default cEvento    := ""
Default cId		   := ""
Default aPreMap	   := ""
Default cAmbReinf  := ""
Default aIDLog     := {}
Default cIDApReinf := ""
Default lReinf212  := .F.

aAreaSM0   := SM0->(GetArea())
aInfoC1E   := {}
lOk 	   := .T.
nTamFil    := len( aFil )
nC1EArray  := ASCAN(aFil,{|x|x[7]})
cStatus    := ' '
cAliasV5C  := aTTName[IDEBENEF]
cAliasV5D  := aTTName[IDEPGTO]
cAliasV4S  := aTTName[INFOPGTO]
cAliasV5F  := aTTName[INFOPROCRET]
cAliasChv  := aTTName[CHVREC]
cChvV5C    := ""
cChvV5D    := ""
cChvV4S    := ""
cChvV5F    := ""
cChvV5G    := ""
cIdNat	   := ""
cPaisExt   := ""
cIdExt	   := ""
nQtdFtG    := 0
nQtdNatP   := 0
nQtdProR   := 0
nQtdAdv    := 0
cDtFg      := ctod( "  /  /    ")
cFilBenef  := ""
cCnpj 	   := ""

If nC1EArray > 0
	AADD(aInfoC1E,aFil[nC1EArray][1])
	AADD(aInfoC1E,aFil[nC1EArray][4])
ElseIf nTamFil > 0
	AADD(aInfoC1E,aFil[nTamFil][1])
	AADD(aInfoC1E,aFil[nTamFil][4])
EndIf

oModelV5C := oModel546:GetModel( "MODEL_V5C"  )
oMdlV5DA  := oModel546:GetModel( "MODEL_V5DA" )
oMdlV4SA  := oModel546:GetModel( "MODEL_V4SA" )
oModelV5F := oModel546:GetModel( "MODEL_V5F"  )
oModelV5G := oModel546:GetModel( "MODEL_V5G"  )

oModel546:SetOperation(nOpc)
oModel546:Activate()

DbselectArea("V5C")
V5C->(DbSetOrder(2)) //V5C_FILIAL+V5C_PERAPU+V5C_TPINSC+V5C_NRINSC+V5C_CNPJBN+V5C_ATIVO

//-------------------------------------------- 
//Realiza Abertura das Temporarias "Filhas"
//--------------------------------------------
DbSelectArea( cAliasV5D ) //IdePgto
( cAliasV5D )->(DbSetOrder(1))

DbSelectArea( cAliasV4S ) //InfoPgto
( cAliasV4S )->(DbSetOrder(1))

DbSelectArea( cAliasV5F ) //InfoProcRet
( cAliasV5F )->(DbSetOrder(1))

DbSelectArea( cAliasChv ) //Chave X RECNO
( cAliasChv )->(DbSetOrder(1))

//-------------------------------------------- 
//Controle das chaves
//--------------------------------------------
cTpNInsc := (cAliasV5C)->CTPINSC + '|' +  (cAliasV5C)->CNRINSC + '|' + (cAliasV5C)->CCNPJBN 
If !Empty( (cAliasV5C)->CIDEXT )
	cTpNInsc += '|' + (cAliasV5C)->CIDEXT
Else
	cTpNInsc += '|' + Space(60)
EndIf
If lReinf212
	cTpNInsc += '|' + (cAliasV5C)->CEVADIC
EndIf

//O agrupamento ocorre por CNPJ para as filiais de mesmo CNPJ
cChvV5C  := /*(cAliasV5C)->FIL + '|'*/ + cPerApu + '|' + cTpNInsc
cChvV5D  := cChvV5C
cChvV4S  := cChvV5C
cChvV5F  := cChvV5C
cChvV5G  := cChvV5C
//-------------------------------------------------------------
//Verifica se há alguma inconsistência de FCI, SCP ou PJud 
//com mais de 1 ocorrência por beneficiario + natureza + Dt FG
//-------------------------------------------------------------
nPos := aScan(aPreMap,{|x| cChvV5C $ x[04] })
//Limpa Array com Recno das Movimentacoes
aMovs  := {}
aDivid := {}
cFilBenef := (cAliasV5C)->FIL
cCnpj 	  := (cAliasV5C)->CCNPJBN
cIdExt    := (cAliasV5C)->CIDEXT
//-------------------------------------------------------------
//Condicionamento p/ iniciar a gravacao
//-------------------------------------------------------------
If !lTafRVld .Or. (lTafRVld .And. nPos == 0 )

	//-------------------------------------------------------------------
	//Carrega a lista de recno dos legados que compoe a chave de apuracao
	//necessario caso efetue o Commit, para atualizar o campo _PRID40
	//-------------------------------------------------------------------
	If (cAliasChv)->( DbSeek(cChvV5C) )
		while !(cAliasChv)->(Eof()) .And. AllTrim(cChvV5C) $ AllTrim((cAliasChv)->CHAVE )
			aadd(aMovs, { (cAliasChv)->CROTINA, (cAliasChv)->NREGISTR } )
			If (cAliasChv)->CCNATRE == "12001" .and. (cAliasChv)->CROTINA == "PGT" // Se for dividendo
				Aadd(aDivid, { (cAliasChv)->NREGISTR  } )				
			EndIF
			(cAliasChv)->( DbSkip() )
		EndDo
	EndIf
	//ideBenef - V5C
	If !Empty(cVerAnt)
		oModel546:LoadValue( 'MODEL_V5C', 'V5C_VERANT', cVerAnt )
		oModel546:LoadValue( 'MODEL_V5C', 'V5C_PROTPN', cProTpn )
		oModel546:LoadValue( 'MODEL_V5C', 'V5C_ID'	  , cId )
	EndIf
	oModel546:LoadValue('MODEL_V5C', 'V5C_FILIAL', cFilBenef )
	oModel546:LoadValue('MODEL_V5C', 'V5C_VERSAO', xFunGetVer() )
	oModel546:LoadValue('MODEL_V5C', 'V5C_STATUS', cStatus )
	oModel546:LoadValue('MODEL_V5C', 'V5C_EVENTO', cEvento )
	oModel546:LoadValue('MODEL_V5C', 'V5C_ATIVO' , '1' )
	oModel546:LoadValue('MODEL_V5C', 'V5C_PERAPU', cPerApu )
	oModel546:LoadValue('MODEL_V5C', 'V5C_IDESTA', aInfoC1E[1] )
	oModel546:LoadValue('MODEL_V5C', 'V5C_DESTAB', aInfoC1E[2] )
	oModel546:LoadValue('MODEL_V5C', 'V5C_IDPART', (cAliasV5C)->CIDPART )
	oModel546:LoadValue('MODEL_V5C', 'V5C_TPINSC', (cAliasV5C)->CTPINSC )
	oModel546:LoadValue('MODEL_V5C', 'V5C_NRINSC', (cAliasV5C)->CNRINSC )
	oModel546:LoadValue('MODEL_V5C', 'V5C_CNPJBN', cCnpj )
	oModel546:LoadValue('MODEL_V5C', 'V5C_NMBENE', (cAliasV5C)->CNMBENE )
	oModel546:LoadValue('MODEL_V5C', 'V5C_ISEIMU', (cAliasV5C)->CISEIMU )
	oModel546:LoadValue('MODEL_V5C', 'V5C_TPAMB' , cAmbReinf )
	oModel546:LoadValue('MODEL_V5C', 'V5C_IDEXTE' , (cAliasV5C)->CIDEXT )
	If lReinf212
		oModel546:LoadValue('MODEL_V5C', 'V5C_EVADIC' , (cAliasV5C)->CEVADIC )
	EndIf 
	If TAFColumnPos("V5C_ORIGEM")
		oModel546:LoadValue('MODEL_V5C', 'V5C_ORIGEM' , (cAliasV5C)->ORIGEM )
	EndIf

	//oTIdePgto - V5D
	If ( cAliasV5D )->(DbSeek( cChvV5D ))
		cIdNat := ""
		cPaisExt := ""
		nQtdNatP := 0 
		While !(cAliasV5D)->(Eof()) .And. AllTrim(cChvV5D) $ AllTrim( (cAliasV5D)->ID)
			nQtdNatP++
			If cIdNat <> (cAliasV5D)->CIDNATRE
				cIdNat := (cAliasV5D)->CIDNATRE
				cPaisExt := (cAliasV5D)->CPAISRE
				oMdlV5DA:lValid := .T.
				If nQtdNatP > 1
					oMdlV5DA:AddLine()
				EndIf
				oModel546:LoadValue('MODEL_V5DA', "V5D_IDNTRE", (cAliasV5D)->CIDNATRE )
				oModel546:LoadValue('MODEL_V5DA', "V5D_CNATRE", (cAliasV5D)->CCNATRE )
				oModel546:LoadValue('MODEL_V5DA', "V5D_DNATRE", (cAliasV5D)->CDNATRE )
				oModel546:LoadValue('MODEL_V5DA', "V5D_OBSERV", Alltrim((cAliasV5D)->COBSERV) )
				If !Empty(cPaisExt) .and. cPaisExt != "105"
					oModel546:LoadValue('MODEL_V5DC', "V5D_INDNIF", (cAliasV5D)->CINDNIF )
					oModel546:LoadValue('MODEL_V5DC', "V5D_NIF"   , Alltrim( (cAliasV5D)->CNIF ) )
					oModel546:LoadValue('MODEL_V5DC', "V5D_IDTRIB", (cAliasV5D)->CIDTRIB ) //Forma de Tributacao
					oModel546:LoadValue('MODEL_V5DC', "V5D_CTRIB" , (cAliasV5D)->CCTRIB )
					oModel546:LoadValue('MODEL_V5DC', "V5D_DTRIB" , (cAliasV5D)->CDTRIB )
					oModel546:LoadValue('MODEL_V5DB', "V5D_LOGRAD", Alltrim((cAliasV5D)->CLOGRAD) )
					oModel546:LoadValue('MODEL_V5DB', "V5D_NRLOGR", (cAliasV5D)->CNRLOGR )
					oModel546:LoadValue('MODEL_V5DB', "V5D_BAIRRO", Alltrim((cAliasV5D)->CBAIRRO) )					
					oModel546:LoadValue('MODEL_V5DB', "V5D_CIDADE", Alltrim((cAliasV5D)->CCIDADE) )
					oModel546:LoadValue('MODEL_V5DB', "V5D_ESTADO", Alltrim((cAliasV5D)->CESTADO) )
					oModel546:LoadValue('MODEL_V5DB', "V5D_CEP"   , (cAliasV5D)->CCEP )
					oModel546:LoadValue('MODEL_V5DB', "V5D_TELEF" , (cAliasV5D)->CTELEF )
					oModel546:LoadValue('MODEL_V5DB', "V5D_COMPLE", Alltrim((cAliasV5D)->CCOMPLE) )
					oModel546:LoadValue('MODEL_V5DC', "V5D_IDRELP", (cAliasV5D)->CIDRELP ) //Relacao de Pagamento
					oModel546:LoadValue('MODEL_V5DC', "V5D_DRELPG", SUBSTR(Alltrim((cAliasV5D)->CDRELPG),1,100))
					oModel546:LoadValue('MODEL_V5DC', "V5D_RELPGT", (cAliasV5D)->CRELPGT )
				EndIf
			EndIf
			//oTInfoPgto - V4S
			cChvV4S := cChvV5C + '|' + cIdNat
			If ( cAliasV4S )->( DbSeek(cChvV4S) )
				cDtFg := ctod( "  /  /    ")
				nQtdFtG := 0
				While !(cAliasV4S)->(Eof()) .And. cChvV4S $ (cAliasV4S)->ID
					If (cDtFg) <> ( (cAliasV4S)->( DDTFG ) )
						nQtdFtG++
						cDtFg := (cAliasV4S)->(DDTFG)
						oMdlV4SA:lValid := .T.
						If nQtdFtG > 1
							oMdlV4SA:AddLine()
						EndIf
						//infoPgto
						oModel546:LoadValue( 'MODEL_V4SA', "V4S_DATAFG" , (cAliasV4S)->DDTFG      )
						oModel546:LoadValue( 'MODEL_V4SA', "V4S_VLRTOT" , (cAliasV4S)->NVBRUTO    )
						oModel546:LoadValue( 'MODEL_V4SA', "V4S_INDJUD" , (cAliasV4S)->CINDJUD    )
						oModel546:LoadValue( 'MODEL_V4SA', "V4S_FCISCP" , (cAliasV4S)->CINDFCISCP )
						oModel546:LoadValue( 'MODEL_V4SA', "V4S_NFCISC" , (cAliasV4S)->CNRINSFCSC )
						oModel546:LoadValue( 'MODEL_V4SA', "V4S_PERSCP" , (cAliasV4S)->NPERCSCP   )
						If !Empty((cAliasV4S)->CPAISRE ) .and. (cAliasV4S)->CPAISRE  != "105"
							oModel546:LoadValue( 'MODEL_V4SA', "V4S_PAISRE" , (cAliasV4S)->CPAISRE )
						EndIf
						If lReinf212
							oModel546:LoadValue( 'MODEL_V4SA', "V4S_DTESCO", (cAliasV4S)->DDTESCRCT )
							oModel546:LoadValue( 'MODEL_V4SA', "V4S_OBSERV", (cAliasV4S)->COBSERV )
						EndIf

						//retencoes
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_BASEIR" , (cAliasV4S)->NBSIR   )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_VLRIR " , (cAliasV4S)->NVLIR   )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_BAGREG" , (cAliasV4S)->NBSAGRE )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_VAGREG" , (cAliasV4S)->NVLAGRE )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_BCSLL"  , (cAliasV4S)->NBSCSLL )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_VLCSLL" , (cAliasV4S)->NVLCSLL )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_BCOFIN" , (cAliasV4S)->NBSCOF  )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_VCOFIN" , (cAliasV4S)->NVLCOF  )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_BASEPP" , (cAliasV4S)->NBSPP   )
						oModel546:LoadValue( 'MODEL_V4SB', "V4S_VLRPP"  , (cAliasV4S)->NVLPP   )

						//aTInfoProcRet
						cChvV5F := cChvV4S + '|' + Dtos(cDtFg)
						If ( cAliasV5F )->( DbSeek( cChvV5F ) )
							nQtdProR := 0
							While !(cAliasV5F)->(Eof()) .And. cChvV5F $ (cAliasV5F)->ID
								If (++nQtdProR) > 1
									oModelV5F:lValid := .T.
									If nOpc == MODEL_OPERATION_INSERT
										oModelV5F:AddLine()
									EndIf
								EndIf
								oModel546:LoadValue( 'MODEL_V5F', "V5F_TPPROC" , (cAliasV5F)->CTPPROCRET )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_NRPROC" , (cAliasV5F)->CNRPROCRET )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_CODSUS" , (cAliasV5F)->CODSUSP    )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VLRNIR" , (cAliasV5F)->VALSUSIR   )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VDEPIR" , (cAliasV5F)->VLRDEPIR   )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_BSUSIR" , (cAliasV5F)->BSSUSPIR   )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VLNCSL" , (cAliasV5F)->VALSUSCSL  )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VDCSLL" , (cAliasV5F)->VLRDEPCSL  )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_BSUSCS" , (cAliasV5F)->BSSUSPCSL  )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VNRCOF" , (cAliasV5F)->VALSUSCOF  )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VDPCOF" , (cAliasV5F)->VLRDEPCOF  )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_BSUSCF" , (cAliasV5F)->BSSUSPCOF  )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VLNRPP" , (cAliasV5F)->VALSUSPP   )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_VLDPPP" , (cAliasV5F)->VLRDEPPP   )
								oModel546:LoadValue( 'MODEL_V5F', "V5F_BSUSPP" , (cAliasV5F)->BSSUSPPP   )
								(cAliasV5F)->(DbSkip())
							EndDo
						EndIf
						//infoProcJud
						ProcJud( @oModel546, cAliasV4S, cChvV4S, @aPreMap) 
					EndIf
					(cAliasV4S)->(DbSkip())
				EndDo
			EndIf
			(cAliasV5D)->(DbSkip())
		EndDo
	EndIf

	If oModel546:VldData()
		FwFormCommit(oModel546)
		TafEndGRV("V5C", "V5C_PROCID", cIdApReinf, V5C->(Recno()) )
		GravaId( aMovs , cIdApReinf )
		If TAFColumnPos("V3U_PERAPU")
			GravaDiv(aDivid, cPerApu)
		EndIf

		//Exito Gravacao
		cMsg := STR0022 + CRLF //"Processamento realizado com sucesso."
		cMsg += STR0021 + AllTrim(cTpNInsc) + CRLF //"Tp Nr Insc: "
		cMsg += STR0023 + cValToChar( cIdApReinf ) + STR0024 + cValToChar( V5C->(Recno())) //"Apuracao Id: " # " Recno: "
		TafXLog( cIdApReinf, "R-4020", "MSG", cMsg, cPerApu ) //"MSG"
	Else
		lOk := .F.
		cMsg := STR0029 + CRLF + CRLF //"Detalhes técnicos do erro: "
		cMsg += TafRetEMsg(oModel546)
		Aadd( aPreMap, {"R-4020", "ERRO", cMsg, cChvV5C} )
	EndIf
Else
	//Se ha alguma inconsistencia mapeada e o validador estiver habilitado nao grava a apuracao mas grava o Log
	lOk := .F.
	Aadd( aPreMap, {"R-4020", Iif(lTafRVld, "ERRO", "ALERTA"), STR0021 + AllTrim(cTpNInsc) + " " + aPreMap[nPos][3], cChvV5C} )
EndIf

//Se Ocorreu Algum Problema na Gravacao e Disarmou a Transação Grava Apenas o Log
If !lOk
	Aadd( aPreMap, {"R-4020", "ERRO", STR0021 + AllTrim(cTpNInsc) + CRLF + TafRetEMsg(oModel546), cChvV5C} )
EndIf

If !lImp
	aAdd( aIDLog, { cIDApReinf, cFilBenef, Iif(!Empty(cCnpj),Alltrim(cCnpj),Alltrim(cIdExt)) } )
else
	aAdd( aIDLog, { cIDApReinf, cFilBenef, Iif(!Empty(cCnpj),Alltrim(cCnpj),Alltrim(cIdExt)), IIF(!lOk,TafRetEMsg(oModel546),'') } )
EndIf

oModel546:DeActivate()

RestArea(aAreaSM0)

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()
Efetua a exclusão do modelo conforme parâmetro

@author Denis Souza
@since 	 02/09/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function ExcluiReg( aPreMap, oModel546, aIDLog, cPerApu, cIDApReinf, lAutomato )

Local cErro		 As Character
Local cTpInscEst As Character	
Local cNrInscEst As Character
Local cCnpj		 As Character
Local cIdExt		 As Character
Local lExcluiu	 As Logical 

Default aPreMap	:= {}
Default oModel546 := nil
Default aIDLog  := {}
Default cPerApu := ''
Default cIDApReinf := ''
Default lAutomato := .F.

cErro 		:= ""
cIDApReinf  := ""
lExcluiu    := .F.
cTpInscEst	:= V5C->V5C_TPINSC
cNrInscEst	:= V5C->V5C_NRINSC	
cCnpj		:= V5C->V5C_CNPJBN
cIdExt		:= V5C->V5C_IDEXTE

oModel546:SetOperation(5)
oModel546:Activate()

If FwFormCommit(oModel546) .and. !lAutomato
	lExcluiu := .T.
Else
	cErro	:= STR0007 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
	cErro 	+= "tpInscEstab: " + cTpInscEst + CRLF	
	cErro 	+= "nrInscEstab: " + cNrInscEst + CRLF
	cErro  	+= "cnpj: " + cCnpj + CRLF	
	cErro 	+= TafRetEMsg(oModel546)
	Aadd( aPreMap, {"R-4020", "ERRO", cErro} )
	aAdd( aIDLog, { cIDApReinf, V5C->V5C_FILIAL, Iif(!Empty(cCnpj),Alltrim(cCnpj),Alltrim(cIdExt))  } )

	lExcluiu := .F.
EndIf
oModel546:DeActivate()

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()

@author Denis Souza
@since 02/09/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Static Function GravaId(aMovs, cIdApur)

Local nX As numeric

Default aMovs 	:= {}
Default cIdApur	:= ''

For nX := 1 to Len(aMovs)
	Do case
	case Alltrim(aMovs[nX][1]) == 'NFS'
		TafEndGRV( "C20","C20_PRID40", cIdApur, aMovs[nX][2] )
	case Alltrim(aMovs[nX][1]) == 'FAT'
		TafEndGRV( "LEM","LEM_PRID40", cIdApur, aMovs[nX][2] )
	case Alltrim(aMovs[nX][1]) == 'PGT'
		TafEndGRV( "V3U","V3U_PRID40", cIdApur, aMovs[nX][2] )
	EndCase
Next nX

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcJud ()
Função que popula o model referente a processos judiciais (infoProcJud),
e verifica a existência de advogados. 

@author Karen honda
@since 04/10/2022
@version 1.0
@return
/*/ 
Static Function ProcJud( oModel546, cAliasV4S, cChvV4S, aPreMap )

Local cProdJud   As Character
Local nQtdPro 	 As Numeric       
Local nCustasJud As Numeric       
Local nCustasAdv As Numeric
Local nContV4W   As Numeric
Local oModelV4SH As Object
Local oModelV4SI As Object
Local oModelV5G  As Object

Default oModel546 := nil
Default cAliasV4S := ""
Default cChvV4S   := ""
Default aPreMap   := {}

nCustasJud  := 0
nCustasAdv  := 0
nContV4W    := 0
cProdJud   	:= ''
nQtdPro 	:= 0

If !Empty( (cAliasV4S)->CJUDRRA )
	oModelV4SH  := oModel546:GetModel( "MODEL_V4SH" ) // infoProcJud
	oModelV4SI  := oModel546:GetModel( "MODEL_V4SI" ) // despProcJud
	oModelV5G   := oModel546:GetModel( "MODEL_V5G"  ) // ideAdv

	cProdJud := HasRraPJud( "R4020", "InfoRRA", (cAliasV4S)->FIL, (cAliasV4S)->CJUDRRA )

	DbSelectArea( cProdJud )
	If (cProdJud)->(!Eof())
		While (cProdJud)->(!Eof())
			nQtdPro++
			If nQtdPro == 1// Somente pode ter 1 processo por Infopgto
				oModelV4SH:LoadValue('V4S_NRPROC', (cProdJud)->NRPROC )
				oModelV4SH:LoadValue('V4S_ORIREC', (cProdJud)->INDORI )
				oModelV4SH:LoadValue('V4S_DESCRI', (cProdJud)->DESCRI )
				If (cProdJud)->INDORI == "2"
					oModelV4SH:LoadValue('V4S_CGCORI', (cProdJud)->CNPJOR )		
				EndIf
				//-------------------------------------------- 
				//   		 	IdeAdv - V4W
				//--------------------------------------------
				cIdeAdv := HasRraPJud( "R4020", "IdeAdv", (cAliasV4S)->FIL, (cAliasV4S)->CJUDRRA)
				If !Empty(cIdeAdv)  .And. (cIdeAdv)->( !Eof() )										
					nCustasAdv := 0
					nCustasJud := 0
					nContV5G   := 0
					While (cIdeAdv)->(!Eof())
						If (cIdeAdv)->TPDESP == '1'	  //Custo Com Advogado
							nCustasAdv += (cIdeAdv)->VLDESP
							nContV5G++
							If nContV5G > 1
								oModelV5G:AddLine()
							EndIf
							oModelV5G:LoadValue("V5G_TPINSC",(cIdeAdv)->TPINSC)
							oModelV5G:LoadValue("V5G_NRINSC",(cIdeAdv)->NRINSC)
							oModelV5G:LoadValue("V5G_VLRADV",(cIdeAdv)->VLDESP)
						ElseIf (cIdeAdv)->TPDESP == '2' //Custas Judiciais
							nCustasJud += (cIdeAdv)->VLDESP
						EndIf
						(cIdeAdv)->(DbSkip())
					EndDo
					oModelV4SI:LoadValue("V4S_VLRCUS",nCustasJud)
					oModelV4SI:LoadValue("V4S_VLRADV",nCustasAdv)
					(cIdeAdv)->(DbcloseArea())
				EndIf	
			Else
				Aadd(aPreMap,{"R-4020", Iif(lTafRVld, "ERRO", "ALERTA"), "Somente é permitido um processo judicial por pagamento.", cChvV4S } )								
			EndIf
			(cProdJud)->(DbSkip())
		EndDo
	EndIf
	(cProdJud)->( DbCloseArea() ) 
EndIf

Return Nil

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

Default aDivid 	 := {}
Default cPerApur := ''

DbSelectArea("V3U")
For nX := 1 to Len(aDivid)
	V3U->( DbGoto(aDivid[nX][1]) )
	Reclock("V3U", .F.)
	V3U->V3U_PERAPU := cPerApur
	V3U->( MsUnlock() )
Next nX

Return 
