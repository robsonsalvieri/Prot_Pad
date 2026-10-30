#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TAFAPR2050.CH"

#DEFINE TCABC 1,1
#DEFINE TPCOM 2,1
#DEFINE TPROC 3,1
#DEFINE DELTCABC 1,2
#DEFINE DELTPCOM 2,2
#DEFINE DELTPROC 3,2
#DEFINE EMPRESA 1
#DEFINE UNIDADE 2
#DEFINE FILIAL  3
#DEFINE ICMS_ST "000004"
#DEFINE IPI	"000005"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2050
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Function TAFAPR2050(cReg, cPerApu, dtIni, dtFin, cIdApReinf, aFil, oProcess, lValid, lSucesso)

	Local lProc	As logical
	
	lProc 	:= oProcess <> nil
	
	Default cReg	:= 'R-2050'
	Default aFil 	:= {}
	
	If lProc 
		oProcess:IncRegua2(STR0001 + cReg ) //"Processando apuração "
	EndIf
	
	TAFR2050( cPerApu, cIdApReinf, aFil, oProcess, lValid, @lSucesso )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFR2050
Rotina de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf
Contem a inteligencia de verificação de cada status do modelo, e toma a ação necessário de acordo com o status retornado

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAFR2050( cPerApu, cIdApReinf, aFil, oProcess, lValid, lSucesso )
	Local aLog 		 As Array
	Local aMovs		 As Array
	Local lDsarm	 As Logical
	Local lProc		 As Logical
	Local lExecApr   As Logical
	Local nContLog	 As Numeric
	Local nTotReg	 As Numeric
	Local nContApur	 As Numeric	
	Local cIdAnt	 As Character
	Local cPerApuGrv As Character
	Local cNrInsc    As Character
	Local cStatus    As Character
	Local cErro      As Character
	Local cVerAnt    As Character
	lOCAL cProTpn    As Character

	aLog  		:= {}
	aMovs		:= {}
	lDsarm		:= .F.
	lProc 		:= oProcess <> nil
	lExecApr    := .F.
	nContLog	:= 0
	nTotReg		:= 0
	nContApur	:= 0
	cIdAnt		:= ""
	cPerApuGrv  := ""	
	cNrInsc     := ""
	cStatus     := ""
	cErro       := ""
	cVerAnt     := ""
	cProTpn     := ""
 	cPerApuGrv 	:= cPerApu
 	cPerApu 	:= SubSTR(cPerApu,3,4) + SubSTR(cPerApu,1,2)
 	
 	Default cPerApu	:= ""
 	
 	If !Empty(cPerApu)
		If lProc 
			oProcess:IncRegua2(STR0002) // "Selecionando dados a serem apurados"
		EndIf
		aApurac	 := Apur2050(cPerApu, aFil, @aMovs)
		lExecApr := aApurac[4]
	EndIf
	
	If lExecApr
		V1D->(DbSetOrder(2))
		If !(aApurac[TCABC])->(Eof())
			(aApurac[TCABC])->(DbSetOrder(1))
			(aApurac[TCABC])->(DbEval({|| ++nTotReg }))
			(aApurac[TCABC])->(DbGoTop())
			
			If lProc
				oProcess:IncRegua2(STR0003) //"Gravando registros"
				oProcess:SetRegua2(nTotReg) 
			EndIf

			Begin Transaction			
			
				While !(aApurac[TCABC])->(Eof())										
				
					cNrInsc := (aApurac[TCABC])->CNRINSC
					cStatus := StatsReg(cPerApuGrv, "1", cNrInsc)

					If lProc
						oProcess:IncRegua2(STR0004 + cValTochar(nContApur++) + "/" + cValTochar(nTotReg)) // "Gravando "
					EndIf

					Do Case					
					//Alteração direta na base, e retono do V1D_STATUS  para branco
					Case cStatus $ ' |0|1|3|7'
		
						If ExcluiReg(cIdApReinf, @aLog)

							If !Grava2050(MODEL_OPERATION_INSERT, cPerApuGrv, aApurac, aFil, V1D->V1D_VERANT,V1D->V1D_PROTPN , cIdApReinf, @aLog, V1D->V1D_ID, lValid, cStatus )
								lDsarm := .T.
								lSucesso := .F.
							Else
								lSucesso := .T.
							EndIf 
						Else 
							lDsarm := .T.
							lSucesso := .F.
						EndIf								
						
					//Registro transmitido ao governão e sem retorno, não deve ser alaterado
					Case cStatus $ '2|6'
						cErro	:= STR0006 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
						cErro 	+= "tpInscEstab: " + (aApurac[TCABC])->CTPINSC + CRLF
						cErro 	+= "nrInscEstab: " + cNrInsc + CRLF 
						cErro 	+= STR0007 + CRLF //"A apuração foi cancelada pois este registro já foi transmitido e está aguardando retorno do RET, portanto não pode ser modificado."
						Aadd(aLog, {'R-2050', "ERRO", cErro})
						lDsarm := .T.
						lSucesso := .F.
					
					Case cStatus == '4'
						cVerAnt := V1D->V1D_VERSAO
						cProTpn := V1D->V1D_PROTUL
						cIdAnt  := V1D->V1D_ID

						FAltRegAnt( 'V1D', '2', .F. )
						if !Grava2050( MODEL_OPERATION_INSERT, cPerApuGrv, aApurac, aFil, cVerAnt, cProTpn, cIdApReinf, @aLog, cIdAnt, lValid, cStatus)
							lDsarm := .T.
							lSucesso := .F.
						Else
							lSucesso := .T.
						EndIf			 
		
					Case cStatus == "Z" // Commit do modelo em modo de inclusão							
						if !Grava2050( MODEL_OPERATION_INSERT, cPerApuGrv, aApurac, aFil , , , cIdApReinf, @aLog, cIdAnt, lValid, cStatus )
							lDsarm := .T.
							lSucesso := .F.
						Else
							lSucesso := .T.
							
						EndIf
					EndCase

					(aApurac[TCABC])->(DbSkip())
				
				EndDo

				If lDsarm
					DisarmTransaction()
				EndIf
				
			End Transaction

			If !lDsarm
				GravaId(aMovs, cIdApReinf)
			EndIf 			
			
			For nContLog := 1 to Len (aLog) 
				TafXLog(cIdApReinf, aLog[nContLog][1], aLog[nContLog][2], aLog[nContLog][3] )
			Next nContLog
			
		EndIf
		//Destruo as tabelas temporárias
		aApurac[DELTCABC]:Delete()
		aApurac[DELTPCOM]:Delete()
		aApurac[DELTPROC]:Delete()			
	Else
		//Alimenta aLog com Informação de que a Data Inicial está vazia
		TafXLog(cIdApReinf, 'R-2050', "ALERTA", STR0005) //"Não foram localizados registros que atendam os parâmetros selecionados para processamento da apuração."
	EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Apur2050
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf
Executa a quary principal, esta que é montada por Qury2050()

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function Apur2050(cPerApu, aFil, aMovs )
	Local cAliasApr	as Character	
	Local cQRy 		as	Character		
	
	cAliasApr			:=	GetNextAlias()
	
	cQRy := Qury2050(cPerApu, .T., .F. , aFil)
	
	cQRy	:= "%" + cQRy + "%"
	
	BeginSql Alias cAliasApr
		SELECT
			%EXP:cQRy%	
	EndSql
	
	aRegApur := RegPrinc( cAliasApr, cPerApu, @aMovs)

	(cAliasApr)->(DbCloseArea())
		
Return aRegApur
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Qury2050
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function Qury2050(cPerApu, lApur, lIdProc , aFil, lGetStatus)

Local aInfoEUF	as array
Local cCompC1H	as Character
Local cFiliais	as Character
Local cQuery 	as Character
Local cBd		as Character

Default lApur	:=	.f.
Default lGetStatus := .f. 
aInfoEUF	:= TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
cCompC1H	:= Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cFiliais	:= TafRetFilC("C20", aFil) 

cBd			:= TcGetDb()
cQuery		:= ""

	If lApur 
		cQuery	:= " C20.C20_FILIAL AS FIL, C20.C20_CHVNF AS CHVNF, C35_VALOR AS VALOR, C35_CODTRI AS CODTRI, C30.C30_VLOPER AS VLRRECBRUTA, C30.C30_NUMITE AS NUMITE," 

		cQuery 	+= " CASE "

		If GetNewPAr('MV_TAFVLRE','1_04_00') >= '1_04_00' 
			cQuery		+= " WHEN C30.C30_INDISE = '1'"
			cQuery		+= " THEN '7'"
		EndIf

		cQuery 	+= " WHEN C1H.C1H_PAA = '1'" 
		cQuery 	+= " THEN '8'"
		cQuery 	+= " WHEN C1H.C1H_PAA <> '1' AND ( "

		If cBd $ "ORACLE|POSTGRES|DB2"
			cQuery 	+= " SUBSTR(C0Y.C0Y_CODIGO,1,1) = '7' "
		
		ElseIf cBd $ "INFORMIX"
			cQuery 	+= " C0Y.C0Y_CODIGO[1,1] = '7'" 			
		
		Else //MSSQL,MYSQL,PROGRESS
			cQuery 	+= " SUBSTRING(C0Y.C0Y_CODIGO,1,1) = '7' " 
		EndIf 
		
		cQuery 	+= " OR C0Y.C0Y_CODIGO IN ('5501','5502','6501','6502') ) "
		
		cQuery 	+= " THEN '9'"
		cQuery 	+= " WHEN C1H.C1H_PAA <> '1' AND "
		
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQuery 	+= " SUBSTR(C0Y.C0Y_CODIGO,1,1) <> '7'"
		
		ElseIf cBd $ "INFORMIX"
			cQuery 	+= " C0Y.C0Y_CODIGO[1,1] <> '7'"
		
		Else //MSSQL,MYSQL,PROGRESS
			cQuery 	+= " SUBSTRING(C0Y.C0Y_CODIGO,1,1) <> '7'"
		EndIf

		cQuery	+= " THEN '1'"
		cQuery  += " END AS INDCOM, "
		cQuery  += " C20.R_E_C_N_O_ AS RECNO"
	Else
		cQuery	:= "  COUNT(*) TOTAL "
	EndIf	
	   
	cQuery	+= " FROM " + RetSqlName("C20") + " C20"
	
	cQuery	+= " INNER JOIN " + RetSqlName("C30") + " C30 On C20.C20_FILIAL 	= C30_FILIAL AND C30.D_E_L_E_T_ <> '*' AND C20.C20_CHVNF = C30.C30_CHVNF AND "
	cQuery	+= " C30.C30_IDTSER = '" + Padr(" ", TamSx3("C30_IDTSER")[1]) + "' AND C30.C30_SRVMUN = '" + Padr(" ", TamSx3("C30_SRVMUN")[1]) + "' AND C30.C30_CODSER = '" + Padr(" ", TamSx3("C30_CODSER")[1]) + "' AND C30.C30_TPREPA = '" + Padr(" ", TamSx3("C30_TPREPA")[1]) + " ' "	
	cQuery	+= " INNER JOIN " + RetSqlName("C35") + " C35 On C30.C30_FILIAL 	= C35_FILIAL AND C30.C30_CHVNF = C35.C35_CHVNF AND "
	cQuery	+= " C30.C30_NUMITE = C35.C35_NUMITE AND C35.C35_CODTRI IN ('000013','000024','000025') AND C35.D_E_L_E_T_ <> '*' "
	cQuery	+= " INNER JOIN " + RetSqlName("C1H") + " C1H ON C1H.C1H_ID = C20.C20_CODPAR " // " AND C1H.C1H_PPES IN ('2','3') "
	cQuery	+= " AND C1H.C1H_INDDES <> '1' AND C1H.D_E_L_E_T_ <> '*' "

	If cCompC1H == "EEE"
		cQuery += "AND C1H.C1H_FILIAL = C20.C20_FILIAL "			
	Else
		If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0 
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") " 
		ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0 
			cQuery += "AND SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") " 
		Else
			cQuery += "AND C1H.C1H_FILIAL = '" + xFilial("C1H") + "'"								
		EndIf
	EndIf

	cQuery	+= " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_ID = C30.C30_CFOP"
	
	// Where
	cQuery	+= " WHERE C20.C20_FILIAL IN " + cFiliais + " AND C20.C20_CODSIT NOT IN ('000003','000004','000005','000006') AND C20.D_E_L_E_T_ <> '*' AND "
	
	If !lApur  .or. lGetStatus// Consulta Status
		If lIdProc
			cQuery	+= " C20.C20_PROCID <> '" + Padr(" ", TamSx3("C20_PROCID")[1]) + "' AND "
		Else
			cQuery	+= " C20.C20_PROCID = '" + Padr(" ", TamSx3("C20_PROCID")[1]) + "' AND "
		EndIf	
	EndIf
	
	cQuery	+=  " C20.C20_INDOPE = '1' AND "
	
	If cBd $ "ORACLE|POSTGRES|DB2"
		cQuery	+=  " SUBSTR(C20.C20_DTDOC,1,6) = '"+ cPerApu +"'"
			
	ElseIf cBd $ "INFORMIX"
		cQuery	+=  " C20.C20_DTDOC[1,6] = '"+ cPerApu +"'"
	
	Else
		cQuery	+=  " SUBSTRING(C20.C20_DTDOC,1,6) = '"+ cPerApu +"'"
	EndIf
	
	If lApur 
		cQuery += " ORDER BY 1,2,6"
	EndIf 

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} DeParaLog
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf
Rotina para identificação dos campos do legado a partir do campo da espelho
Usada para melhor geração do LOG da apuração 

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DeParaLog( )

AAdd(aRet,{'XXX_VALBRU','C20_VALBRU'})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RegPrinc
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf
Recebe o alias da query principal, cria e alimenta as temporary tables

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RegPrinc( cAlias , cPeriod, aMovs )
Local 	cAlsTTCabc		as Character
Local	cAlsTTPCom		as Character
Local	cAlsTTProc		as Character
Local	cCompart		as Character
Local	cChvReg			as Character
Local	cTpInsc			as Character
Local	cNrInsc			as Character
Local 	aCampCabc		as Array
Local 	aCampTpCom		as Array
Local 	aCampProc		as Array
Local 	oTTCabc			as Object  
Local 	oTTPCom			as Object
Local 	oTTProc			as Object
Local	nContLaco		as Numeric
Local 	nValIPI			as Numeric
Local	nValICMSST		as Numeric
Local   nVlIcmsFrt      as Numeric			  
Local	nAbat			as Numeric
Local	lAvanc			as Logical
Local 	lIPI			as Logical
Local	lICMSST			as Logical
Local   lICMSFRETE      as Logical

cAlsTTCabc	:= ""
cAlsTTPCom	:= ""
cAlsTTProc	:= ""
cCompart	:= ""
cChvReg		:= ""
cTpInsc		:= ""
cNumIte		:= ""
cFil		:= ""
nVlIcmsFrt  := 0
lICMSFRETE  := .F.				

//Parâmetro criado para que o usuário informe se quer ou não que o tributo seja abatido do valor contábil
lIPI		:= Iif( "1" $ SuperGetMV("MV_2050TRB",," "), .T., .F. ) // 1 - IPI
lICMSST		:= Iif( "2" $ SuperGetMV("MV_2050TRB",," "), .T., .F. ) // 2 - ICMS ST

If TAFColumnPos("C30_ICMSFT")
	lICMSFRETE := Iif( "3" $ SuperGetMV("MV_2050TRB",," "), .T., .F. ) // 3 - ICMS ST do frete
EndIf					 

nContLaco	:= 1

aCampCabc	:= {}
aCampTpCom	:= {}
aCampProc	:= {}

oTTCabc	:= Nil
oTTPCom	:= Nil
oTTProc	:= Nil

lAvanc		:= .T.

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!EOF())
		cCompart := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3)))
		
		cAlsTTCabc	:= getNextAlias()
		cAlsTTPCom	:= getNextAlias()
		cAlsTTProc	:= getNextAlias()
		
		// Cria a estrutura (array) das temporary table
		PopArray(@aCampCabc, @aCampTpCom,@aCampProc, cPeriod)
		
		// Instancia o objeto Temporary Table 
		oTTCabc	:= FWTemporaryTable():New(cAlsTTCabc, aCampCabc)
		oTTPCom	:= FWTemporaryTable():New(cAlsTTPCom, aCampTpCom)
		oTTProc	:= FWTemporaryTable():New(cAlsTTProc, aCampProc)
		
		// Seta os devidos indices 
		PopIdxObj(@oTTCabc, @oTTPCom, @oTTProc, cPeriod)
	

		DbSelectArea(cAlsTTCabc)
		(cAlsTTCabc)->(DbSetOrder(2)) //"CPERIODO", "CTPINSC", "CNRINSC", "CCNPJTMPR", "CTPINSCTOM"
		
		DbSelectArea(cAlsTTPCom)
		(cAlsTTPCom)->(DbSetOrder(2)) //"CPERIODO", "CTPINSC", "CNRINSC"	
	
		(cAlias)->(DbGoTop())
		cTpInsc := '1'
		While (cAlias)->(!EOF())
			
			cFil := (cAlias)->FIL

			cNrInsc := FWSM0Util( ):GetSM0Data( , (cAlias)->FIL , { "M0_CGC" } )[1][2] 

			//Funções para pegar o valor dos tributos
			nValIPI		:=	Iif(lIPI, GetValTRB((cAlias)->CHVNF, (cAlias)->NUMITE, cFil, IPI), 0 )
			nValICMSST	:=	Iif(lICMSST, GetValTRB((cAlias)->CHVNF, (cAlias)->NUMITE, cFil, ICMS_ST), 0 )
			
			If TAFColumnPos("C30_ICMSFT") .and. lICMSFRETE
				nVlIcmsFrt := GetICMSFRT( (cAlias)->CHVNF, (cAlias)->NUMITE, cFil )
			EndIF
			
			nAbat	:= (cAlias)->VLRRECBRUTA - nValIPI - nValICMSST - nVlIcmsFrt
			If !(cAlsTTCabc)->(DbSeek(cPeriod + cTpInsc + cNrInsc))
				
				RecLock(cAlsTTCabc,.T.)
				
				(cAlsTTCabc)->FIL			:= cFil
				(cAlsTTCabc)->ID			:= (cPeriod + cTpInsc + cNrInsc)
				(cAlsTTCabc)->CTPINSC 		:= cTpInsc 	 						//tpInscEstab
				(cAlsTTCabc)->CNRINSC		:= cNrInsc 							//nrInscEstab	
				(cAlsTTCabc)->CPERIOD		:= cPeriod 	
				(cAlsTTCabc)->VLRRECBRUT	:= nAbat							//vlrRecBrutaTotal

				If (cAlias)->CODTRI == '000013'
					(cAlsTTCabc)->VLRCPAPUR		:= (cAlias)->VALOR 				//vlrCPApur
				
				ElseIf (cAlias)->CODTRI == '000024'
					(cAlsTTCabc)->VLRRATAPUR	:= (cAlias)->VALOR	 			//vlrRatApur
					
				ElseIf (cAlias)->CODTRI == '000025'
					(cAlsTTCabc)->VLRSENARPR	:= (cAlias)->VALOR				//vlrSenarApur
				EndIf
				
				(cAlsTTCabc)->(MsUnlock())
			Else
				RecLock(cAlsTTCabc,.F.)	
				
				If cChvReg <> (cAlias)->CHVNF .Or. cNumIte <> (cAlias)->NUMITE
					(cAlsTTCabc)->VLRRECBRUT	+= nAbat						//vlrRecBrutaTotal
				Endif 
				
				If (cAlias)->CODTRI == '000013'
					(cAlsTTCabc)->VLRCPAPUR	+= (cAlias)->VALOR 					//vlrCPApur
				
				ElseIf (cAlias)->CODTRI == '000024'
					(cAlsTTCabc)->VLRRATAPUR	+= (cAlias)->VALOR	 			//vlrRatApur
					
				ElseIf (cAlias)->CODTRI == '000025'
					(cAlsTTCabc)->VLRSENARPR	+= (cAlias)->VALOR				//vlrSenarApur
				EndIf
				
				(cAlsTTCabc)->(MsUnlock())
			EndIf
			
			If !(cAlsTTPCom)->(DbSeek(cPeriod + cTpInsc + cNrInsc + (cAlias)->INDCOM  ))	
				
				RecLock(cAlsTTPCom,.T.)
				
				(cAlsTTPCom)->FIL		:= cFil
				(cAlsTTPCom)->ID		:= (cPeriod + cTpInsc + cNrInsc)
				(cAlsTTPCom)->INDCOM	:= (cAlias)->INDCOM	 				//indCom
				(cAlsTTPCom)->CTPINSC	:= cTpInsc							//tpInscEstab
				(cAlsTTPCom)->CNRINSC	:= cNrInsc 							//nrInscEstab	
				(cAlsTTPCom)->CPERIOD	:= cPeriod							//periodo
				(cAlsTTPCom)->VLRRECBRT	:= nAbat							//vlrRecBruta
								
				(cAlsTTPCom)->(MsUnlock())
			Else
				RecLock(cAlsTTPCom,.F.)			
				If cChvReg <> (cAlias)->CHVNF .Or. cNumIte <> (cAlias)->NUMITE
					(cAlsTTPCom)->VLRRECBRT	+= nAbat						//vlrRecBruta
				EndIf
					
				(cAlsTTPCom)->(MsUnlock())		
			EndIf
			
			If nContLaco == 1 .Or. (cChvReg <> (cAlias)->CHVNF .Or. cNumIte <> (cAlias)->NUMITE)
				AADD(aMovs,(cAlias)->RECNO)
				cChvReg := (cAlias)->CHVNF
				cNumIte := (cAlias)->NUMITE
				RetProc(cAlsTTProc, cAlias, aCampProc, cPeriod + cTpInsc + cNrInsc, cCompart, cAlsTTCabc)
			EndIf
			
			(cAlias)->(DbSkip())
		nContLaco++
		
		EndDo
	Else
		lAvanc := .F.
	EndIf
	
Return {{cAlsTTCabc,oTTCabc}, {cAlsTTPCom,oTTPCom}, {cAlsTTProc,oTTProc}, lAvanc }

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2050
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf
Popula os 3 array com a estrutura das temporary tables

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PopArray(aCampCabc, aCampTpCom, aCampProc, cPeriod)

Local	nTamFil	:= TamSX3("C20_FILIAL")[1]

	aCampCabc	:=  {{'FIL'			,'C', nTamFil  ,0},;
					{'ID'			,'C', 21 ,0},;
				    {'CTPINSC'		,'C', 01 ,0},; 	//tpInscEstab
				    {'CNRINSC'		,'C', 14 ,0},; 	//nrInscEstab	
				    {'CPERIOD'		,'C', 06 ,0},;	//periodo	
				    {'VLRRECBRUT'	,'N', 14 ,2},; 	//vlrRecBrutaTotal
				    {'VLRCPAPUR'	,'N', 14 ,2},; 	//vlrCPApur
				    {'VLRRATAPUR'	,'N', 14 ,2},; 	//vlrRatApur
				    {'VLRSENARPR'	,'N', 14 ,2},; 	//vlrSenarApur
				    {'VLRCPSUST'	,'N', 14 ,2},; 	//vlrCPSuspTotal
				    {'VLRRATSUST'	,'N', 14 ,2},; 	//vlrRatSuspTotal
				    {'VLRSNRSUST'	,'N', 14 ,2}} 	//vlrSenarSuspTotal
					  
	aCampTpCom	:=	{{'FIL'			,'C', nTamFil  ,0},;
					{'ID'			,'C', 21 ,0},;
					{'INDCOM'		,'C', 01 ,0},;	//indCom
					{'CTPINSC'		,'C', 01 ,0},; 	//tpInscEstab
					{'CNRINSC'		,'C', 14 ,0},; 	//nrInscEstab	
					{'CPERIOD'		,'C', 06 ,0},;	//periodo
					{'VLRRECBRT'	,'N', 14 ,2}}	//vlrRecBruta

	aCampProc	:= {{'FIL'			,'C', nTamFil  ,0},;
					{'ID'			,'C', 21 ,0},;	
					{'INDCOM'		,'C', 01 ,0},;	//indCom
					{'CTPPROC'		,'C', 01 ,0},; 	//tpProc
					{'NUMPRO'		,'C', 06 ,2},;
					{'C1GNUMPRO'	,'C', TamSx3("C1G_NUMPRO")[1] ,0},;	//nrProc
					{'CODSUS'		,'C', 14 ,0},; 	//codSusp	
					{'VALCPSUS'		,'N', 14 ,2},;	//vlrCPSusp
					{'VLRRATSUSP'	,'N', 14 ,2},; 	//vlrRatSusp
					{'VLRSNRSUSP'	,'N', 14 ,2},;	//vlrSenarSusp
					{'RECNO'		,'N', 10 ,0},;	//RECNO DA NOTA
					{'C1GID'		,'C', 06 ,0},;
					{'C1GVERSAO'	,'C', 14 ,0},;
					{'C1GFILIAL'	,'C', TamSx3("C1G_FILIAL")[1] ,0}}
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2050
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf
Cria os 3 indices para suas respectivas temporary tables

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PopIdxObj(oTTCabc, oTTPCom, oTTProc )

	oTTCabc:AddIndex("1", {"ID"})
	oTTCabc:AddIndex("2", { "CPERIOD","CTPINSC", "CNRINSC"})

	oTTPCom:AddIndex("1", {"ID"})
	oTTPCom:AddIndex("2", {"CPERIOD","CTPINSC", "CNRINSC", "INDCOM"})

	oTTProc:AddIndex("1", {"ID", "INDCOM"})
	oTTProc:AddIndex("2", {"ID", "INDCOM", "CTPPROC", "C1GNUMPRO", "CODSUS"})

	oTTCabc:Create()
	oTTPCom:Create()
	oTTProc:Create()

Return	
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAPR2050
Rotinas de apuração da Comercialização da Produção por Produtor Rural PJ/Agroindústria
Registro R-2050 da Reinf
Consulta os processos que devem ser apurados para o R-2050
Popula as temporary tables com o retorno da consulta

@author Henrique Pereira; Anieli Rodrigues
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RetProc(cAlsTTProc, Alias, aCampProc, cChavProc, cCompC1G, cAlsTTCabc)
	
	Local cSelect		AS Character
	Local cFrom			AS Character
	Local cJoin			AS Character
	Local cJoinC1G		AS Character
	Local cWhere		AS Character
	Local cAliasT9Q		AS Character
	Local cChavSeek		AS Character
	Local cBd			As Character
	Local nTam			As Numeric
	Local nTamIDSUSP	As Numeric
	Local lFormat		As Logical
	Local lProcessa		As Logical
	
	cSelect		:= ''
	cFrom		:= ''
	cJoin		:= ''
	cJoinC1G	:= ''
	cWhere		:= ''
	cChavSeek	:= ''

	cAliasT9Q	:= GetNextAlias()
	cBd			:= TcGetDb()
	nTam		:= 0
	nTamIDSUSP	:= 0
	lFormat		:= .F.
	lProcessa	:= .F.
		
		cSelect 	:= "'" + cChavProc + "' AS ID,  '"+ (Alias)->CHVNF + "' AS CCHAVE, T9Q.T9Q_CODTRI AS CODTRI, "
		cSelect 	+= " T9Q.T9Q_NUMPRO AS NUMPRO, T5L.T5L_INDDEC AS INDSUSP,  T5L.T5L_CODSUS AS CODSUS, T9Q.T9Q_VALSUS AS VALSUS, "
		cSelect 	+= " CASE WHEN C1G.C1G_TPPROC = '1' "
		cSelect		+= " THEN '2' " 
		cSelect 	+= " ELSE '1' "
		cSelect 	+= " END AS CTPPROC, "
		cSelect 	+= " C1G.C1G_NUMPRO AS C1GNUMPRO, C1G.C1G_ID AS C1GID, C1G.C1G_VERSAO AS C1GVERSAO, C1G.C1G_FILIAL AS C1GFILIAL "
		cFrom		:= RetSqlName("T9Q") + " T9Q"

		cJoinC1G	:=  RetSqlName("C1G") + " C1G ON "
	
		cJoinC1G += " C1G.C1G_FILIAL = '" + xFilial("C1G",(Alias)->FIL) + "' AND "

		cJoinC1G += " C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ <> '*' "

		If cBd $ "ORACLE|POSTGRES|DB2|INFORMIX"
			if cBd $ "POSTGRES"
				nTamIDSUSP	:= TamSX3("T9Q_IDSUSP")[1]
				cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = SUBSTR(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") AND  T9Q.T9Q_FILIAL = '" +  (Alias)->FIL + "' AND "
			Else
				cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS AND  T9Q.T9Q_FILIAL = '" +  (Alias)->FIL + "' AND "
			Endif
		Else
			cJoin :=  RetSqlName("T5L") + " T5L ON T9Q.T9Q_IDSUSP = T5L.T5L_ID+T5L.T5L_VERSAO+T5L.T5L_CODSUS AND  T9Q.T9Q_FILIAL = '" +  (Alias)->FIL + "' AND "
		EndIf
		cJoin += " T5L.D_E_L_E_T_ <> '*' AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "

		cWhere := "  T9Q.D_E_L_E_T_ <> '*' AND T9Q.T9Q_CHVNF = '" + (Alias)->CHVNF +  "' AND T9Q.T9Q_CODTRI IN ('000013','000024','000025') AND T9Q.T9Q_NUMITE = '" + (Alias)->NUMITE + "' "
		
		cSelect 	:= "%" +	cSelect 	+ 	"%"
		cFrom		:= "%" +	cFrom	 	+ 	"%"
		cJoinC1G	:= "%" +	cJoinC1G	+ 	"%"
		cJoin 		:= "%" +	cJoin 		+ 	"%"
		cWhere 	:= "%" +	cWhere 	+ 	"%"
		
		BeginSql Alias cAliasT9Q
			SELECT
			%Exp:cSelect%
			FROM
			%Exp:cFrom%
			INNER JOIN
			%Exp:cJoinC1G%
			INNER JOIN
			%Exp:cJoin%
			Where
			%Exp:cWhere%
		EndSql
		
		If!(cAliasT9Q)->(EOF())
			cChavSeek := (cAliasT9Q)->ID + (Alias)->INDCOM + (cAliasT9Q)->CTPPROC + (cAliasT9Q)->C1GNUMPRO + (cAliasT9Q)->CODSUS 
			lProcessa	:= .T.
		EndIf
		
		DbSelectArea(cAlsTTProc)
		(cAlsTTProc)->(DbSetOrder(2)) //"CTPINSC", "CNRINDC", "CTPPROC", "C1GNUMPRO", "CODSUS"
		(cAliasT9Q)->(DbGoTop())
		If lProcessa
			If !(cAliasT9Q)->(EOF())
				(cAlsTTCabc)->(DbSetOrder(1))
				(cAlsTTCabc)->(DbSeek((cAliasT9Q)->ID))
				RecLock(cAlsTTCabc, .F.)
				
				While !(cAliasT9Q)->(EOF())
				
					If !(cAlsTTProc)->(MsSeek(cChavSeek))
						 RecLock(cAlsTTProc, .T.)
						(cAlsTTProc)->ID			:= (cAliasT9Q)->ID
						(cAlsTTProc)->C1GFILIAL		:= (cAliasT9Q)->C1GFILIAL
						(cAlsTTProc)->C1GVERSAO 	:= (cAliasT9Q)->C1GVERSAO
						(cAlsTTProc)->C1GID  		:= (cAliasT9Q)->C1GID  				
						(cAlsTTProc)->INDCOM		:= (Alias)->INDCOM
						(cAlsTTProc)->CTPPROC		:= (cAliasT9Q)->CTPPROC		//tpProc
						(cAlsTTProc)->C1GNUMPRO		:= (cAliasT9Q)->C1GNUMPRO	//nrProc
						(cAlsTTProc)->CODSUS		:= (cAliasT9Q)->CODSUS		//codSusp
						
						If (cAliasT9Q)->CODTRI == '000013'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
							
							(cAlsTTProc)->VALCPSUS	:= (cAliasT9Q)->VALSUS //vlrCPSusp
							(cAlsTTCabc)->VLRCPSUST += (cAliasT9Q)->VALSUS //vlrCPSusp
							
						ElseIf (cAliasT9Q)->CODTRI == '000024'	.AND. (cAliasT9Q)->INDSUSP <> '000015'					
							
							(cAlsTTProc)->VLRRATSUSP	:= (cAliasT9Q)->VALSUS 	//vlrRatSusp
							(cAlsTTCabc)->VLRRATSUST += (cAliasT9Q)->VALSUS //vlrCPSusp
							
						ElseIf (cAliasT9Q)->CODTRI == '000025'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
							
							(cAlsTTProc)->VLRSNRSUSP	:= (cAliasT9Q)->VALSUS	//vlrSenarSusp
							(cAlsTTCabc)->VLRSNRSUST	+= (cAliasT9Q)->VALSUS	//vlrSenarSusp
							
						EndIf
					Else
					  RecLock(cAlsTTProc, .F.)
					  
					  If (cAliasT9Q)->CODTRI == '000013'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
						
						(cAlsTTProc)->VALCPSUS	+= (cAliasT9Q)->VALSUS //vlrCPSusp
					  	(cAlsTTCabc)->VLRCPSUST += (cAliasT9Q)->VALSUS //vlrCPSusp
					  	
					  ElseIf (cAliasT9Q)->CODTRI == '000024'	.AND. (cAliasT9Q)->INDSUSP <> '000015'	 					
						
						(cAlsTTProc)->VLRRATSUSP	+= (cAliasT9Q)->VALSUS 	//vlrRatSusp
					  	(cAlsTTCabc)->VLRRATSUST += (cAliasT9Q)->VALSUS //vlrCPSusp
					  	
					  ElseIf (cAliasT9Q)->CODTRI == '000025'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
						
						(cAlsTTProc)->VLRSNRSUSP	+= (cAliasT9Q)->VALSUS	//vlrSenarSusp
						(cAlsTTCabc)->VLRSNRSUST	+= (cAliasT9Q)->VALSUS	//vlrSenarSusp
						
					  EndIf

					EndIf
					(cAliasT9Q)->(DbSkip())
					cChavSeek := (cAliasT9Q)->ID + (Alias)->INDCOM + (cAliasT9Q)->CTPPROC + (cAliasT9Q)->C1GNUMPRO + (cAliasT9Q)->CODSUS
					(cAlsTTProc)->(MsUnlock())
				EndDo
				(cAlsTTCabc)->(MsUnlock())
			Endif
		EndIf
		
		(cAliasT9Q)->(DbCloseArea())
		
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} StatsReg
Verifica a existência ou não do registro que será apurado

@author Henrique Pereira; Anieli Rodrigues
@since 28/03/2018
@version 1.0
@return Retorna o status do registro encontrado, caso contrário retorna status "Z", indicando que ainda não existe o registro no cadastro espelho

/*/ 
//-------------------------------------------------------------------

Static Function StatsReg( cPerApu, cTpInsc, cNrInsc)

	Local cRetStat as Character //retorno do status do registro
	cRetStat := "Z"
	Default cPerApu := ""
	
		If V1D->(MsSeek(cFilAnt + cPerApu + cTpInsc + cNrInsc + '1'))
			cRetStat := V1D->V1D_STATUS
		Else 
			cRetStat := "Z"
		EndIf
		
Return cRetStat 

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2050
Efetua gravação no modelo da tabela espelho do evento R-2050 (Comercialização da Produção por Produtor Rural PJ/Agroindústria)

@author anieli.rodrigues
@since 20/02/2018
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------

Static Function Grava2050(nOpc, cPerApu, aApuracao, aFil, cVerAnt, cProTpn, cIdApReinf, aErro, cId, lValid, cStatus )

	Local cEvento		As Character
	Local cChaveReg		As Character
	Local lVldData		As Logical
	Local lVldProc		As Logical
	Local nContLaco		As Numeric
	Local nContLac2		As Numeric
	Local nErro			As Numeric
	Local oModel		As Object
	Local oModelV1E		As Object
	Local oModelV1F		As Object	
	Local aDocsErro		As Array
	
	cChaveReg	:= ""
	cEvento		:= "I"
	lVldData	:= .T.
	lVldProc	:= .T.
	nContLaco	:= 1   
	nContLac2 	:= 1
	nErro		:= 0
	aDocsErro	:= {}

	Default	cVerAnt	:= ''
	Default cProTpn	:= ''
	Default cId		:= ''
	
	T9V->(DbSetOrder(1))
	
	oModel 		:= FWLoadModel("TAFA492")
	oModelV1D 	:= oModel:GetModel("MODEL_V1D")
	oModelV1E 	:= oModel:GetModel("MODEL_V1E")
	oModelV1F 	:= oModel:GetModel("MODEL_V1F")
		
	oModel:SetOperation(nOpc)
	oModel:Activate()

	If !Empty(cVerAnt)
		oModel:LoadValue('MODEL_V1D', 'V1D_VERANT'	, cVerAnt)
		oModel:LoadValue('MODEL_V1D', 'V1D_PROTPN'	, cProTpn)
		oModel:LoadValue('MODEL_V1D', 'V1D_ID'		, cId)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'		
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel:LoadValue('MODEL_V1D', 'V1D_VERSAO'  , xFunGetVer())
	oModel:LoadValue('MODEL_V1D', 'V1D_STATUS'  , '')
	oModel:LoadValue('MODEL_V1D', 'V1D_EVENTO'  , cEvento)
	oModel:LoadValue('MODEL_V1D', 'V1D_ATIVO'   , '1')
	oModel:LoadValue('MODEL_V1D', 'V1D_PERAPU'	, cPerApu)
	oModel:LoadValue('MODEL_V1D', 'V1D_IDESTA'  , aFil[aScan(aFil, {|x|x[2]== (aApuracao[TCABC])->FIL })][1])
	oModel:LoadValue('MODEL_V1D', 'V1D_DESTAB'  , Alltrim(FWSM0Util():GETSM0Data(, (aApuracao[TCABC])->FIL, {"M0_FILIAL"})[1,2]))
	oModel:LoadValue('MODEL_V1D', 'V1D_TPINSC'	, (aApuracao[TCABC])->CTPINSC)		//tpInscEstab - CNPJ
	oModel:LoadValue('MODEL_V1D', 'V1D_NRINSC'	, (aApuracao[TCABC])->CNRINSC) 		//nrInscEstab													
	oModel:LoadValue('MODEL_V1D', 'V1D_VRECBT'	, (aApuracao[TCABC])->VLRRECBRUT)	//vlrRecBrutaTotal
	oModel:LoadValue('MODEL_V1D', 'V1D_VCPAPU'	, (aApuracao[TCABC])->VLRCPAPUR)	//vlrCPApur
	oModel:LoadValue('MODEL_V1D', 'V1D_VRAAPU'	, (aApuracao[TCABC])->VLRRATAPUR)	//vlrRatApur
	oModel:LoadValue('MODEL_V1D', 'V1D_VSEAPU'	, (aApuracao[TCABC])->VLRSENARPR)	//vlrSenarApur
	oModel:LoadValue('MODEL_V1D', 'V1D_VCPSUS'	, (aApuracao[TCABC])->VLRCPSUST)	//vlrCPSuspTotal
	oModel:LoadValue('MODEL_V1D', 'V1D_VRASUS'	, (aApuracao[TCABC])->VLRRATSUST)	//vlrRatSuspTotal
	oModel:LoadValue('MODEL_V1D', 'V1D_VSESUS'	, (aApuracao[TCABC])->VLRSNRSUST)	//vlrSenarSuspTotal
	
	(aApuracao[TPCOM])->(DbSetOrder(1))
	(aApuracao[TPCOM])->(DbSeek((aApuracao[TCABC])->ID))
	
	(aApuracao[TPROC])->(DbSetOrder(1))

	While !(aApuracao[TPCOM])->(Eof()) .And. (aApuracao[TCABC])->ID == (aApuracao[TPCOM])->ID
	
		If nContLaco > 1 .And. !oModelV1D:VldData() 
			lVldData := .F.
			//If !oModelV1E:VldData()
				//Aadd(aDocsErro,{(aApuracao[ANALITICO])->ROTINA ,(aApuracao[ANALITICO])->NUMDOCTO, (aApuracao[ANALITICO])->SERIE, oModel:GetErrorMessage(), (aApuracao[ANALITICO])->CHVNF}  )
			//EndIf 
			//Exit
		EndIf 
			
		If nContLaco > 1
			oModelV1E:AddLine() 
		EndIf 
		
		oModel:LoadValue('MODEL_V1E', 'V1E_IDCOM'	, (aApuracao[TPCOM])->INDCOM)	//indCom
		oModel:LoadValue('MODEL_V1E', 'V1E_VRECBR'	, (aApuracao[TPCOM])->VLRRECBRT)//vlrRecBruta
		
		(aApuracao[TPROC])->(DbSeek((aApuracao[TPCOM])->ID + (aApuracao[TPCOM])->INDCOM))
		
		While !(aApuracao[TPROC])->(Eof()) .And. (aApuracao[TPCOM])->ID == (aApuracao[TPROC])->ID .And. (aApuracao[TPCOM])->INDCOM == (aApuracao[TPROC])->INDCOM
			If nContLac2 > 1 .And. !oModelV1E:VldData()
				lVldData := .F. 
				//Exit
			EndIf 
			
			If nContLac2 > 1 .And. nOpc == MODEL_OPERATION_INSERT
				oModelV1F:AddLine()
			EndIf
			
			oModel:LoadValue('MODEL_V1F', 'V1F_IDPROC', (aApuracao[TPROC])->C1GID)
			oModel:LoadValue('MODEL_V1F', 'V1F_TPPROC', (aApuracao[TPROC])->CTPPROC)	//tpProc 
			oModel:LoadValue('MODEL_V1F', 'V1F_NRPROC', (aApuracao[TPROC])->C1GNUMPRO)	//nrProc
			oModel:LoadValue('MODEL_V1F', 'V1F_CODSUS', (aApuracao[TPROC])->CODSUS)		//codSusp
			oModel:LoadValue('MODEL_V1F', 'V1F_IDSUSP', (aApuracao[TPROC])->C1GID + (aApuracao[TPROC])->C1GVERSAO + (aApuracao[TPROC])->CODSUS)
			oModel:LoadValue('MODEL_V1F', 'V1F_VCPSUS', (aApuracao[TPROC])->VALCPSUS)	//vlrCPSusp
			oModel:LoadValue('MODEL_V1F', 'V1F_VRASUS', (aApuracao[TPROC])->VLRRATSUSP)	//vlrRatSusp
			oModel:LoadValue('MODEL_V1F', 'V1F_VSESUS', (aApuracao[TPROC])->VLRSNRSUSP)	//vlrSenarSusp
			
			T9V->(DbSetOrder(5))
			If !T9V->(DbSeek(xFilial('T9V') + (aApuracao[TPROC])->C1GID + "1"))    
				lVldProc := .F. 
				Exit 
			EndIf
			
			(aApuracao[TPROC])->(DbSkip()) 
			nContLac2++
		EndDo 
		
		nContLac2 := 1

		(aApuracao[TPCOM])->(DbSkip())
		nContLaco++
	EndDo
			
	If lVldData .And. oModel:VldData() .And. lVldProc
		FwFormCommit(oModel)
		TafEndGRV( "V1D","V1D_PROCID", cIdApReinf, V1D->(Recno()))
	    lRollBack := .T.
	Else
		
		cErro	:= STR0008 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
		cErro 	+= "tpInscEstab: "	+ (aApuracao[TCABC])->CTPINSC  + CRLF
		cErro 	+= "nrInscEstab: " 	+ (aApuracao[TCABC])->CNRINSC + CRLF
		
		If !lVldProc 
			oModel:VldData()
			cErro	+= STR0009 + Alltrim((aApuracao[TPROC])->C1GNUMPRO) + STR0010  + CRLF // "Processo número " "não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."
		EndIf
		
		cErro  	+= STR0011 + CRLF + CRLF //"Detalhes do Erro: "
		cErro 	+= TafRetEMsg(oModel)
		
		Aadd(aErro, {"R-2050", "ERRO", cErro})
		lRollBack := .F.

	EndIf

Return lRollBack

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()
Efetua a gravação dos ids da tabela legado

@author anieli.rodrigues
@since 03/04/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function GravaId(aMovs, cIdApur)

	Local	nX	as numeric
 
	Default aMovs 	:= {}
	Default cIdApur	:= ''
	
	For nX := 1 to Len(aMovs)
		TafEndGRV( "C20","C20_PROCID", cIdApur, aMovs[nX])
	Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()

Efetua a exclusão do modelo conforme parâmetro

@author anieli.rodrigues
@since 05/03/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function ExcluiReg(cIdApReinf, cReg, aErro)

	Local cErro		As Character
	Local cNrInscEst	As Character
	Local cTpInscEst	As Character
	Local lExcluiu	As Logical 
	Local oModel 		As Object
	
	cErro := "" 
	cTpInscEst := ""
	lExcluiu := .F.
	
	
	oModel 	:= FWLoadModel("TAFA492")
	cNrInscEst	:= V1D->V1D_NRINSC
	cTpInscEst	:= V1D->V1D_TPINSC
 
	oModel:SetOperation(5)
	oModel:Activate()
	
	If FwFormCommit(oModel)
	    lExcluiu := .T.
	Else
		cErro	:= STR0005 + CRLF //"Inconsistência na gravação do registro contendo a chave: "
	
		cErro 	+= "tpInscEstab: " + cTpInscEst + CRLF	
		cErro 	+= "nrInscEstab: " + cNrInscEst + CRLF

		cErro  	+= STR0006 + CRLF
		cErro 	+= TafRetEMsg(oModel)
		Aadd(aErro, {"R-2050", "ERRO", cErro})
		lExcluiu := .F.
	EndIf

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValTRB()

Pega o valor do IP na tabela C35 quando houver, para posteriormente somar ao valor bruto.

@author bruno.cremaschi	
@since 31/01/2019
@version 1.0
@return


/*/ 
//-------------------------------------------------------------------
Function GetValTRB(cChvNF, cNumIte, cFil, cCodTrib)

	Local cAlC35	:= GetNextAlias()
	Local nRet 		:= 0

	BeginSql alias cAlC35
		SELECT C35_VALOR
		FROM %Table:C35% C35
		WHERE
			C35_FILIAL = %Exp:cFil%
			AND C35_CHVNF = %Exp:cChvNF%
			AND C35_NUMITE = %Exp:cNumIte%
			AND C35_CODTRI = %Exp:cCodTrib%
			AND C35.%NotDel%
	EndSql

	If (cAlC35)->(!EOF())
		nRet := (cAlC35)->C35_VALOR
	Endif

	(cAlC35)->(DbCloseArea())

Return nRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GetICMSFRT()

Pega o valor ICMS-ST do frete do item na tabela C30 quando houver, para posteriormente abater do valor bruto.

@author Wesley Pinheiro	
@since 22/08/2019
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------
Function GetICMSFRT( cChvNF, cNumIte, cFil )

	Local cAlC30	:= GetNextAlias( )
	Local nRet 		:= 0

	BeginSql alias cAlC30
		SELECT C30_ICMSFT
		FROM %Table:C30% C30
		WHERE
			C30_FILIAL = %Exp:cFil%
			AND C30_CHVNF = %Exp:cChvNF%
			AND C30_NUMITE = %Exp:cNumIte%
			AND C30.%NotDel%
	EndSql

	If ( cAlC30 )->( !EOF( ) )
		nRet := ( cAlC30 )->C30_ICMSFT
	Endif

	( cAlC30 )->( DbCloseArea( ) )

Return nRet																	 
