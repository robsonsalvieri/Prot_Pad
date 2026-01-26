#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFAPR2055.CH"

#DEFINE TCABC  		1,1
#DEFINE TAQUIS 		2,1
#DEFINE TPROC  		3,1
#DEFINE TNFS   		4,1
#DEFINE DELTCABC 	1,2
#DEFINE DELTAQUIS 	2,2
#DEFINE DELTPROC 	3,2
#DEFINE DELTNFS 	4,2
#DEFINE TRIBCODE	1
#DEFINE TRIBNAME	2

#DEFINE ICMS_ST "000004"
#DEFINE IPI	"000005"

/*/{Protheus.doc} TAFAPR2055
Rotina para carregar as grids do evento R-2055 de acordo com o novo layout 1.5.1 do Reinf
@type  Function
@author 
@since 27/01/2021
@version 1.0
@param cPerApur, character, Período de Apuração
@return Nil
/*/

Function TAFAPR2055(cReg, cPerApur, dtIni, dtFin, cIdApReinf, aFil, oProcess, lValid, lSucesso, cFilApur )
	
	Default cReg	:= 'R-2055'
	Default cPerApur := ''
	Default lValid	:= .F.	
	Default cIdApReinf := ''
	Default aFil := {}
	
	TAFR2055( cPerApur, cIdApReinf, aFil, oProcess, lValid, @lSucesso, cFilApur )

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFR2055
Rotina de apuração da Aquisição da Produção por Produtor Rural PJ/Agroindústria
Registro R-2055 da Reinf
Contem a inteligencia de verificação de cada status do modelo, e toma a ação necessário de acordo com o status retornado

@author Karen Honda , Rafael Leme
@since 27/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TAFR2055( cPerApur, cIdApReinf, aFil, oProcess, lValid, lSucesso,cFilApur )
	Local aLog 		As Array
	Local aRegApur	As Array
	Local aMovs		As Array
	Local lDsarm	As Logical
	Local lProc		As Logical
	Local nContLog	As Numeric
	Local nTotReg	As Numeric
	Local nContApur	As Numeric	
	Local cIdAnt	As Character
	Local oModel	As Object
	Local oModelV5S	As Object
	Local oModelV5T	As Object	
	Local oModelV5U	As Object	
	Local oModelV5V	As Object	

	
 	Default cPerApur	:= ""

	aLog  		:= {}
	aRegApur	:= {}
	aMovs		:= {}
	lDsarm		:= .F.
	lProc 		:= oProcess <> nil
	nContLog	:= 0
	nTotReg		:= 0
	nContApur	:= 0
	cIdAnt		:= ""	
 	
 	cPerApuGrv 	:= cPerApur
	cPerApur 	:= SubSTR(cPerApur,3,4) + SubSTR(cPerApur,1,2) 	
 	
 	If !Empty(cPerApur)
		If lProc 
			oProcess:IncRegua2(STR0001) // "Selecionando dados a serem apurados"
		EndIf
		aApurac	:= Apur2055(cPerApur, aFil, cFilApur)
		lExecApr 	:= aApurac[5]
	EndIf
	
	If lExecApr
		V5S->(DbSetOrder(2)) //V5S_FILIAL+V5S_PERAPU+V5S_TPINSC+V5S_NRINSC+V5S_TPINSP+V5S_NRINSP+V5S_ATIVO
		(aApurac[TCABC])->( DbGoTop() )
		(aApurac[TAQUIS])->( DbGoTop() )
		(aApurac[TPROC])->( DbGoTop() )
		(aApurac[TNFS])->( DbGoTop() )

		If (aApurac[TCABC])->( !Eof() )
			
			oModel 		:= FWLoadModel("TAFA576")
			oModelV5S 	:= oModel:GetModel("MODEL_V5S")
			oModelV5T 	:= oModel:GetModel("MODEL_V5T")
			oModelV5U 	:= oModel:GetModel("MODEL_V5U")
			oModelV5V 	:= oModel:GetModel("MODEL_V5V")

			If lProc
				(aApurac[TCABC])->(DbSetOrder(1))
				(aApurac[TCABC])->(DbEval({|| ++nTotReg }))
				(aApurac[TCABC])->(DbGoTop())

				oProcess:IncRegua2(STR0002) // "Gravando registros"
				oProcess:SetRegua2(nTotReg) 
			EndIf
			
			While (aApurac[TCABC])->( !Eof() )	
				Begin Transaction
					cTpInsc := (aApurac[TCABC])->CTPINSC
					cNrInsc := (aApurac[TCABC])->CNRINSC
					cStatus := StatsReg(cPerApuGrv, cTpInsc, cNrInsc, (aApurac[TCABC])->CTPINSPRD, (aApurac[TCABC])->CNRINSCPRD)
					lDsarm		:= .F.
					If lProc
						oProcess:IncRegua2(STR0003 + cValTochar(nContApur++) + "/" + cValTochar(nTotReg)) // "Gravando "
					EndIf

					If Empty((aApurac[TCABC])->PROCID)
						Do Case					
						//Alteração direta na base, e retono do V5S_STATUS  para branco
						Case cStatus $ ' |0|1|3|7' // 0-validado, 1-invalidado, 3-inconsistente, 7-exclusão validada 

							If ExcluiReg(@aLog)

								If !Grava2055(MODEL_OPERATION_INSERT, cPerApuGrv, aApurac, aFil, V5S->V5S_VERANT,V5S->V5S_PROTPN , cIdApReinf, @aLog, V5S->V5S_ID, lValid, cStatus, @aMovs, @oModel, @oModelV5S, @oModelV5T, @oModelV5U, @oModelV5V)
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
							cErro	:= STR0004 + CRLF // "Inconsistência na gravação do registro contendo a chave: "

							cErro 	+= "tpInscAdq: "	+ (aApurac[TCABC])->CTPINSC  + CRLF
							cErro 	+= "nrInscAdq: " 	+ (aApurac[TCABC])->CNRINSC + CRLF
							cErro 	+= "tpInscProd: "	+ (aApurac[TCABC])->CTPINSPRD  + CRLF
							cErro 	+= "nrInscProd: " 	+ (aApurac[TCABC])->CNRINSCPRD + CRLF

							cErro 	+= STR0005 + CRLF // "A apuração foi cancelada pois este registro já foi transmitido e está aguardando retorno do RET, portanto não pode ser modificado."
							Aadd(aLog, {'R-2055', STR0009, cErro}) // "ERRO"
							lDsarm := .T.
							lSucesso := .F.
						Case cStatus == '4'

								cVerAnt := V5S->V5S_VERSAO
								cProTpn := V5S->V5S_PROTUL
								cIdAnt  := V5S->V5S_ID

								FAltRegAnt( 'V5S', '2', .F. )
								if !Grava2055( MODEL_OPERATION_INSERT, cPerApuGrv, aApurac, aFil, cVerAnt, cProTpn, cIdApReinf, @aLog, cIdAnt, lValid, cStatus, @aMovs, @oModel, @oModelV5S, @oModelV5T, @oModelV5U, @oModelV5V)
									lDsarm := .T.
									lSucesso := .F.
								Else
									lSucesso := .T.
								EndIf			 

						Case cStatus == "Z" // Commit do modelo em modo de inclusão							
							if !Grava2055( MODEL_OPERATION_INSERT, cPerApuGrv, aApurac, aFil , , , cIdApReinf, @aLog, cIdAnt, lValid, cStatus, @aMovs,@oModel, @oModelV5S, @oModelV5T, @oModelV5U, @oModelV5V)
								lDsarm := .T.
								lSucesso := .F.
							Else
								lSucesso := .T.

							EndIf
						EndCase
					EndIf

					(aApurac[TCABC])->(DbSkip())

					If lDsarm
						DisarmTransaction()
					Else 
						GravaId(@aMovs,cIdApReinf)
						TafXLog(cIdApReinf, "R-2055", STR0013, STR0014 ,cPerApuGrv ) // "MSG" | "Processamento realizado com sucesso"
					EndIf 
				End Transaction						
			EndDo
						
			For nContLog := 1 to Len (aLog) 
				TafXLog(cIdApReinf, aLog[nContLog][1], aLog[nContLog][2], aLog[nContLog][3], cPerApuGrv )
			Next nContLog
			
		EndIf
		//Destruo as tabelas temporárias
		aApurac[DELTCABC]:Delete()
		aApurac[DELTAQUIS]:Delete()
		aApurac[DELTPROC]:Delete()	
		aApurac[DELTNFS]:Delete()		
	Else
		//Alimenta aLog com Informação de que a Data Inicial está vazia
		TafXLog(cIdApReinf, 'R-2055', STR0006, STR0007) // "ALERTA" | "Não foram localizados registros que atendam os parâmetros selecionados para processamento da apuração."
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Apur2055
Rotinas de apuração da Aquisição da Produção por Produtor Rural PJ/Agroindústria
Registro R-2055 da Reinf
Executa a quary principal, esta que é montada por Qury2055()
@param cPerApur, caracter, periodo de apuracao AAAAMM
@aFil, array com os dados das filiais
@cFilApur, caracter, Código da Filial a ser processada
@author Karen Honda, Rafael Leme
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function Apur2055(cPerApur, aFil, cFilApur )
	Local cAliasApr	as Character	
	Local cQRy 		as	Character		
	
	cAliasApr			:=	GetNextAlias()
	
	cQRy := Qury2055(cPerApur, .T., .F. , aFil, .F., cFilApur )
	
	cQRy	:= "%" + cQRy + "%"
	
	BeginSql Alias cAliasApr
		column DTDOC 		as Date
		column DTES 		as Date
		column VLRRECBRUTA 	as Numeric(14,2)
		column CONTPR 		as Numeric(14,2)
		column GILRAT 		as Numeric(14,2)
		column SENAR 		as Numeric(14,2)

		SELECT
			%EXP:cQRy%	
	EndSql

	aRegApur := RegPrinc( cAliasApr, cPerApur)
	(cAliasApr)->(dbCloseArea())
Return aRegApur



//-------------------------------------------------------------------
/*/{Protheus.doc} Qury2055
Rotinas de apuração da Aquisição da Produção por Produtor Rural PJ/Agroindústria
Registro R-2055 da Reinf
cPerApur, character, periodo de apuração formato AAAAMM
cFilApur, character, para filtrar o CPF ou CNPJ do participante 
nView, numerico, parametro utilizado nas visoes do po ui:
0 default utilizado no carregamento do card ou na própria apuração
1 versao sintetica ( agrupado por fornecedor para apurar )
2 versao detalhada ( expandido do registro da apuração )

@author 
@since 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function Qury2055(cPerApur as Character, lApur as Logical, lIdProc as Logical, aFil as Array, lGetStatus as Logical, cFilApur as Character, nView as Numeric) as Character

Local nIndex       as Numeric
Local cCompC1H     as Character
Local cFiliais     as Character
Local cQuery       as Character
Local cWhereC20    as Character
Local cWhereLEM    as Character
Local cConcat      as Character
Local cConcat1     as Character
Local cConcat2     as Character
Local cBd          as Character
Local cTmpTabName  as Character
Local cPerApuIn    as Character
Local cPerApuFi	   as Character
Local aInfoEUF     as Array
Local aTributeConf as Array

Default lApur		:=	.f.
Default lGetStatus 	:= .f. 
Default cFilApur    := ""

Default nView := 0 //nao utilizar

aInfoEUF    := TAFTamEUF(Upper(AllTrim(SM0->M0_LEIAUTE)))
cCompC1H    := Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3)))
cFiliais    := TafRetFilC("C20", aFil)
cBd         := Upper(AllTrim(TcGetDb()))

cWhereC20    	:= ""
cWhereLEM    	:= ""
cTmpTabName  	:= ""
cQuery       	:= IIf(nView == 0, " DISTINCT ", "") 
cPerApuIn		:= cPerApur + "01"		
cPerApuFi		:= DtoS(LastDay(StoD(cPerApuIn)))	
aTributeConf	:= {{"13", "CONTPR"}, {"24", "GILRAT"}, {"25", "SENAR"}}

If cBd $ "POSTGRES"
	cConcat := " CONCAT(CNPJPR,CPF) "
	cConcat1 := " CONCAT(C1H.C1H_CNPJ,C1H.C1H_CPF) "
	cConcat2 := " CONCAT(C1H2.C1H_CNPJ,C1H2.C1H_CPF) "
ElseIf cBd $ "ORACLE|DB2|INFORMIX|OPENEDGE"
	cConcat := " CNPJPR || CPF "
	cConcat1 := " C1H.C1H_CNPJ || C1H.C1H_CPF "
	cConcat2 := " C1H2.C1H_CNPJ || C1H2.C1H_CPF "
Else
	cConcat := " CNPJPR+CPF "
	cConcat1 := " C1H.C1H_CNPJ+C1H.C1H_CPF "	
	cConcat2 := " C1H2.C1H_CNPJ+C1H2.C1H_CPF "
EndIf

//Inicio WHERE da C20
cWhereC20 := " WHERE "
If !Empty(cFilApur)
	cWhereC20 += " C20.C20_FILIAL = '" + xFilial("C20", cFilApur) + "' "
ELSE
	cWhereC20 += " C20.C20_FILIAL IN " + cFiliais + " "
Endif

If !lApur  .or. lGetStatus// Consulta Status
	If lIdProc
		cWhereC20	+= "AND C20.C20_PROCID <> '" + Padr(" ", TamSx3("C20_PROCID")[1]) + "' "
	Else
		cWhereC20	+= "AND C20.C20_PROCID = '" + Padr(" ", TamSx3("C20_PROCID")[1]) + "' "
	EndIf	
EndIf

cWhereC20 += " AND C20.C20_INDOPE = '0' " //Entrada
cWhereC20 += " AND C20.C20_DTDOC BETWEEN '" + cPerApuIn + "' AND '" + cPerApuFi + "' "

If nView == 0
	cWhereC20 += " AND C20.R_E_C_N_O_ NOT IN ( SELECT C202.R_E_C_N_O_ FROM " + RetSQLName("C20") + " C202 WHERE "
	
	If !Empty(cFilApur)
		cWhereC20 += " C202.C20_FILIAL = '" + xFilial("C20", cFilApur) + "' "
	Else
		cWhereC20 += " C202.C20_FILIAL IN " + cFiliais + " "
	EndIf

	cWhereC20 += " AND C202.C20_DTDOC BETWEEN '" + cPerApuIn + "' AND '" + cPerApuFi + "' "
	cWhereC20 += " AND C202.C20_INDOPE = '0' AND (C202.C20_CODSIT IN ( '000003', '000004', '000005', '000006' ) "
	cWhereC20 += " OR  C202.C20_TPDOC = '000002') AND C202.D_E_L_E_T_ = ' ' ) AND C20.D_E_L_E_T_ = ' ' "
	cWhereC20 += " AND ( C30.C30_IDTSER = ' ' OR C30.C30_SRVMUN = ' ' OR C30.C30_CODSER = ' ' OR C30.C30_TPREPA = ' ' ) "
Else
	cWhereC20 +=  " AND C20.C20_CODSIT IN ('000001', '000002', '000007','000008','000009') " //Canceladas/Denegadas/Inutilizadas
	cWhereC20 +=  " AND C20.C20_TPDOC <> '000002' "
	cWhereC20 +=  " AND C20.D_E_L_E_T_ = ' ' "

	// Tratamento feito para retornar registros da tabela C30 em que os campos C30_IDTSER, C30_SRVMUN, 
	// C30_CODSER e C30_TPREPA sejam diferentes de branco.
	// Caso seja retornado algum registro, esse documento fiscal não deverá estar disponível para apuração no evento R-2055 e sim R-2010.
	cWhereC20 += " AND NOT EXISTS (SELECT C30.C30_CHVNF FROM " + RetSQLName("C30") + " C30 "
	cWhereC20 += " WHERE C30.C30_FILIAL = C20.C20_FILIAL "
	cWhereC20 += " AND C30.C30_CHVNF = C20.C20_CHVNF "
	cWhereC20 += " AND (C30.C30_IDTSER != '" + Padr(" ", TamSx3("C30_IDTSER")[1]) + "' OR C30.C30_SRVMUN != '" + Padr(" ", TamSx3("C30_SRVMUN")[1]) + "' "
	cWhereC20 += " OR C30.C30_CODSER != '" + Padr(" ", TamSx3("C30_CODSER")[1]) + "' OR C30.C30_TPREPA != '" + Padr(" ", TamSx3("C30_TPREPA")[1]) + "') "
	cWhereC20 += " AND C30.D_E_L_E_T_ = ' ') "

EndIf

//Inicio WHERE da LEM
cWhereLEM :=	" WHERE "

If !Empty(cFilApur)
	cWhereLEM += " LEM.LEM_FILIAL = '" + xFilial("LEM", cFilApur) + "' "
ELSE
	cWhereLEM += " LEM.LEM_FILIAL IN " + cFiliais + " "
Endif

If !lApur  .or. lGetStatus// Consulta Status
	If lIdProc
		cWhereLEM	+= "AND LEM.LEM_PROCID <> '" + Padr(" ", TamSx3("LEM_PROCID")[1]) + "' "
	Else
		cWhereLEM	+= "AND LEM.LEM_PROCID = '" + Padr(" ", TamSx3("LEM_PROCID")[1]) + "' "
	EndIf	
EndIf

cWhereLEM += " AND LEM.LEM_NATTIT = '0' "
cWhereLEM += " AND LEM.LEM_DOCORI = '" + Padr(" ", TamSx3("LEM_DOCORI")[1]) + "' "
cWhereLEM += " AND LEM.LEM_DTEMIS BETWEEN '" + cPerApuIn + "' AND '" + cPerApuFi + "' "
cWhereLEM += " AND (LEM.LEM_VLRGIL > 0 OR LEM.LEM_VLRSEN > 0 OR LEM.LEM_VLRCP > 0) "
cWhereLEM += " AND LEM.D_E_L_E_T_ = ' ' "

// Tratamento feito para retornar registros da tabela T5M em que os campos T5M_IDTSER e T5M_TPREPA sejam diferentes de branco.
// Caso seja retornado algum registro, essa fatura não deverá estar disponível para apuração no evento R-2055 e sim no evento R-2010.
cWhereLEM +=	" AND NOT EXISTS (SELECT T5M.T5M_NUMFAT FROM " + RetSqlName("T5M") + " T5M WHERE T5M.T5M_FILIAL = LEM.LEM_FILIAL "
cWhereLEM +=	" AND T5M.T5M_ID = LEM.LEM_ID "
cWhereLEM +=	" AND T5M.T5M_IDPART = LEM.LEM_IDPART "
cWhereLEM +=	" AND T5M.T5M_NUMFAT = LEM.LEM_NUMERO "
cWhereLEM +=	" AND (T5M.T5M_IDTSER != '" + Padr(" ", TamSx3("T5M_IDTSER")[1]) + "' "
cWhereLEM +=	" OR T5M.T5M_TPREPA != '" + Padr(" ", TamSx3("T5M_TPREPA")[1]) + "' ) "
cWhereLEM +=	" AND T5M.D_E_L_E_T_ = ' ') "

If lApur

	if nView == 1
		// TOTALIZA PARTICIPANTES
		cQuery += " FIL, " 
		cQuery += " sum(TOTALDOCS)	TOTALDOCS, "
		cQuery += " SUM(VLRRECBRUTA) VLRRECBRUTA, "
		cQuery += " SUM(CONTPR) CONTPR, "
		cQuery += " SUM(GILRAT) GILRAT, "
		cQuery += " SUM(SENAR) SENAR, "
		cQuery += " SUM(PROCID) PROCID, "
		cQuery += " COUNT(" + cConcat+ " ) PARTIC "	
		cQuery += " FROM "
		cQuery += " ( "
		cQuery += " SELECT FIL, "
		cQuery += " sum(TOTALDOCS)	TOTALDOCS,"
		cQuery += " SUM(VLRRECBRUTA) VLRRECBRUTA, "
		cQuery += " SUM(CONTPR) CONTPR, "
		cQuery += " SUM(GILRAT) GILRAT, "
		cQuery += " SUM(SENAR) SENAR, "
		cQuery += " MIN(PROCID) PROCID, "
		cQuery += " CNPJPR,CPF "
		cQuery += "FROM "
		cQuery += "( "
		cQuery += "SELECT FIL, COUNT(DOC) TOTALDOCS, MIN(PROCID) PROCID, SUM(VLRRECBRUTA) VLRRECBRUTA,"
		cQuery += "SUM(CONTPR) CONTPR, SUM(GILRAT) GILRAT, SUM(SENAR) SENAR, CNPJPR, CPF "
		cQuery += " FROM ( SELECT "
	endif

	if nView == 0
		cQuery += " C20.C20_FILIAL FIL "
		cQuery += " , ' ' IDFAT ,'NFS' TIPO "
		cQuery += " , C20.C20_CHVNF CHVNF "
		cQuery += " , C20.C20_NUMDOC NUMDOC "
		cQuery += " , C20.C20_SERIE SERIE "
		cQuery += " , C20.C20_DTDOC DTDOC "
		cQuery += " , C30.C30_INDISE INDISE "
		cQuery += " , C30.C30_NUMITE NUMITE "
		cQuery += " , C20.C20_DTES DTES "
		cQuery += " , C20.R_E_C_N_O_ RECNO "
		cQuery += " , C30.C30_VLOPER VLRRECBRUTA "
	Elseif nView == 1
		cQuery += " FIL, "
        cQuery += " DOC DOC, "
        cQuery += " MIN(PROCID) PROCID,"
    	cQuery += " SUM(VLRRECBRUTA) VLRRECBRUTA,"
        cQuery += " SUM(CONTPR) CONTPR,"
        cQuery += " SUM(GILRAT) GILRAT,"
        cQuery += " SUM(SENAR) SENAR,"
    	cQuery += " CNPJPR,CPF From ( SELECT "
		cQuery += " C20.C20_FILIAL FIL "
		cQuery += " , C20_CHVNF DOC "
		cQuery += " ,CASE WHEN C20.C20_PROCID = ' ' THEN 0 ELSE 1 END PROCID "
		cQuery += " , C30.C30_NUMITE NUMITE "
		cQuery += " , C30.C30_VLOPER VLRRECBRUTA "
		cQuery += " ,C1H.C1H_CNPJ CNPJPR " 
		cQuery += " ,C1H.C1H_CPF CPF "
	endif

	If nView == 0

		For nIndex := 1 To 3
			cTmpTabName	:= "V" + CValToChar(nIndex) + "C35." + aTributeConf[nIndex][TRIBNAME]
			If cBd $ "INFORMIX" 
				cQuery 		+= " ,NVL(" + cTmpTabName + ", 0) " + aTributeConf[nIndex][TRIBNAME] + " "	
			else
				cQuery 		+= " ,COALESCE(" + cTmpTabName + ", 0) " + aTributeConf[nIndex][TRIBNAME] + " "	
			endif
		Next nIndex

	Else
		cQuery += ", SUM(CASE WHEN C35.C35_CODTRI = '000013' THEN C35.C35_VALOR ELSE 0 END) AS CONTPR, "
		cQuery += "SUM(CASE WHEN C35.C35_CODTRI = '000024' THEN C35.C35_VALOR ELSE 0 END) AS GILRAT, "
		cQuery += "SUM(CASE WHEN C35.C35_CODTRI = '000025' THEN C35.C35_VALOR ELSE 0 END) AS SENAR "
	EndIf	

	if nView == 0
		cQuery += " , C1H.C1H_CNPJ CNPJPR "
		cQuery += " , C1H.C1H_CPF CPFPR "
		cQuery += " , C1H.C1H_NOME NOME "
		cQuery += " , C1H.C1H_CODPAR CODPAR "
		cQuery += " , C1H.C1H_ID IDPART "
		cQuery += " , C1H.C1H_INDCP INDCP "
		cQuery += " , C0Y.C0Y_CODIGO CFOP "
        If TAFColumnPos("C1H_PAA")
			cQuery +=  ", C1H.C1H_PAA PAA "
        EndIf
		cQuery +=  ", C20.C20_PROCID PROCID "
	endif
Else
	cQuery	:= " COUNT(*) TOTAL "
EndIf

cQuery +=  " FROM " + RetSqlName( 'C20' ) + " C20"
cQuery += " INNER JOIN " + RetSqlName( 'C1H' ) + " C1H ON "
	
If cCompC1H == "EEE"
	cQuery += " C1H.C1H_FILIAL = C20.C20_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQuery += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQuery += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] = C20.C20_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] "
		Else
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		EndIf
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQuery += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQuery += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] = C20.C20_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] "
		Else
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(C20.C20_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		EndIf
	Else
		cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf

cQuery += " AND C1H.C1H_ID     = C20.C20_CODPAR "
cQuery += " AND C1H.C1H_RAMO   = '4' "
cQuery += " AND C1H.D_E_L_E_T_ = ' ' "

cQuery += 	" INNER JOIN " + RetSqlName( 'C30' ) + " C30 "
cQuery += 	" ON C30.C30_FILIAL = C20.C20_FILIAL "
cQuery += 	" AND C30.C30_CHVNF = C20.C20_CHVNF "
cQuery += 	" AND C30.D_E_L_E_T_ = ' ' "

If nView == 0 .or. nView == 1
	cQuery += " INNER JOIN " + RetSqlName( 'C35' ) + " C35 "
	cQuery += " ON C35.C35_FILIAL = C30.C30_FILIAL "
	cQuery += " AND C35.C35_CHVNF = C30.C30_CHVNF "
	cQuery += " AND C35.C35_NUMITE = C30.C30_NUMITE "
	cQuery += " AND C35.C35_CODTRI IN ('000013', '000024', '000025') "
	cQuery += " AND C35.D_E_L_E_T_= ' ' "
EndIf

cQuery	+= " INNER JOIN " + RetSqlName("C0Y") + " C0Y ON C0Y.C0Y_FILIAL = '" + xFilial("C0Y") + "' "
cQuery 	+= " AND C0Y.C0Y_ID = C30.C30_CFOP AND C0Y.D_E_L_E_T_ = ' ' "

If nView == 0

	For nIndex := 1 To 3
		cTmpTabName	:= "V" + CValToChar(nIndex) + "C35"
		cQuery 		+= " LEFT JOIN ( SELECT C35.C35_FILIAL, C35.C35_CHVNF, C35.C35_NUMITE, C35.C35_CODITE, SUM(C35.C35_VALOR) " + aTributeConf[nIndex][TRIBNAME] + " FROM " + RetSqlName("C35") + " C35 "
        cQuery 		+= " INNER JOIN " + RetSqlName("C3S") + " C3S ON C3S.C3S_FILIAL = '" + xFilial("C3S") + "' "                
        cQuery 		+= " AND C3S.C3S_CODIGO = '" + aTributeConf[nIndex][TRIBCODE] + "' AND C3S.C3S_ID = C35.C35_CODTRI AND C3S.D_E_L_E_T_ = ' ' "                
		cQuery 		+= " WHERE C35.C35_CODTRI = '" + PadL(aTributeConf[nIndex][TRIBCODE], 6, "0") + "' AND C35.D_E_L_E_T_ = ' ' "
		cQuery 		+= " GROUP BY C35.C35_FILIAL, C35.C35_CHVNF, C35.C35_NUMITE, C35.C35_CODITE ) " + cTmpTabName + " ON " + cTmpTabName + ".C35_FILIAL = C20.C20_FILIAL "
		cQuery		+= " AND " + cTmpTabName + ".C35_CHVNF = C20.C20_CHVNF AND " + cTmpTabName + ".C35_NUMITE = C30.C30_NUMITE AND " + cTmpTabName + ".C35_CODITE = C30.C30_CODITE "
	Next nIndex

EndIf

cQuery += cWhereC20

if nView == 1 //+Agrupado a Nivel Notas
	cQuery += " GROUP BY C20.C20_FILIAL, C20.C20_CHVNF, C20.C20_PROCID, C30.C30_NUMITE,C30.C30_VLOPER, C1H.C1H_CNPJ,C1H.C1H_CPF ) A "
	cQuery += " GROUP BY A.FIL, A.DOC, A.CNPJPR, A.CPF) B GROUP BY B.FIL, B.CNPJPR, B.CPF "
endif

cQuery +=	" UNION ALL " // Query para buscar os títulos na tabela LEM conforme os parâmetros abaixo.

if nView == 1
	cQuery += " SELECT FIL, COUNT(*) DOC, MIN(PROCID) PROCID, SUM(VLRRECBRUTA) VLRRECBRUTA, SUM(CONTPR) CONTPR, "
	cQuery += " SUM(GILRAT) GILRAT, SUM(SENAR) SENAR, CNPJPR, CPF FROM ("
endIf
cQuery +=	" SELECT LEM.LEM_FILIAL FIL, "

if nView == 0
	cQuery += " LEM.LEM_ID IDFAT, "
	cQuery += 	" 'FAT' TIPO, "
	cQuery +=	" ' ' CHVNF, "
	cQuery +=	" LEM.LEM_NUMERO NUMDOC, "
	cQuery += 	" LEM.LEM_PREFIX SERIE, "
	cQuery += 	" LEM.LEM_DTEMIS DTDOC, "
	cQuery += 	" LEM.LEM_INDISE INDISE, "
	cQuery += 	" '0001'         NUMITE, "
	cQuery += 	" ' '            DTES, "
	cQuery += 	" LEM.R_E_C_N_O_ RECNO, "
	cQuery += 	" LEM.LEM_VLBRUT VLRRECBRUTA, "
	cQuery += 	" LEM.LEM_VLRCP CONTPR, "
	cQuery += 	" LEM.LEM_VLRGIL GILRAT, "
	cQuery += 	" LEM.LEM_VLRSEN SENAR, "
	cQuery += 	" C1H.C1H_CNPJ CNPJPR, "
	cQuery +=   " C1H.C1H_CPF CPFPR, "
	cQuery +=   " C1H.C1H_NOME NOME, "		
	cQuery +=   " C1H.C1H_CODPAR CODPAR, "
	cQuery +=   " C1H.C1H_ID IDPART, "
	cQuery +=   " C1H.C1H_INDCP INDCP, "
	cQuery += 	" ' ' CFOP, "
	cQuery += 	" ' ' PAA, "
	cQuery += 	" LEM.LEM_PROCID PROCID "
elseIf nView ==1
	cQuery += 	" LEM.LEM_ID DOC, "
	cQuery += 	" CASE WHEN LEM.LEM_PROCID = ' ' THEN 0 ELSE 1 END PROCID, "
	cQuery += 	" SUM(LEM.LEM_VLBRUT) VLRRECBRUTA, "
	cQuery += 	" SUM(LEM.LEM_VLRCP) CONTPR, "
	cQuery += 	" SUM(LEM.LEM_VLRGIL) GILRAT, "
	cQuery += 	" SUM(LEM.LEM_VLRSEN) SENAR, "
	cQuery += 	" C1H.C1H_CNPJ CNPJPR, "
	cQuery += 	" C1H.C1H_CPF CPF "
Endif
	
cQuery +=	" FROM " + RetSqlName("LEM") + " LEM "
cQuery +=	" INNER JOIN " + RetSqlName("C1H") + " C1H ON "

If cCompC1H == "EEE"
	cQuery += " C1H.C1H_FILIAL = LEM.LEM_FILIAL "			
Else
	If cCompC1H == "EEC" .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQuery += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTR(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQuery += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] = LEM.LEM_FILIAL[1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + "] "
		Else
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1] + aInfoEUF[2]) + ") "
		EndIf
	ElseIf cCompC1H == 'ECC' .And. aInfoEUF[1] + aInfoEUF[2] > 0
		If cBd $ "ORACLE|POSTGRES|DB2"
			cQuery += " SUBSTR(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTR(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		ElseIf cBd $ "INFORMIX"
			cQuery += " C1H.C1H_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] = LEM.LEM_FILIAL[1," + cValToChar(aInfoEUF[1]) + "] "
		Else
			cQuery += " SUBSTRING(C1H.C1H_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") = SUBSTRING(LEM.LEM_FILIAL,1," + cValToChar(aInfoEUF[1]) + ") "
		EndIf
	Else
		cQuery += " C1H.C1H_FILIAL = '" + xFilial("C1H") + "' "
	EndIf
EndIf

cQuery +=	" AND C1H.C1H_ID = LEM.LEM_IDPART "
cQuery +=	" AND C1H.C1H_RAMO = '4' "
cQuery +=	" AND C1H.D_E_L_E_T_ = ' ' "

cQuery += cWhereLEM

if nView == 1 //+ Agrupado a Nivel de Fornecedor
	cQuery +=	" Group BY LEM.LEM_FILIAL,LEM.LEM_ID,LEM.LEM_PROCID,C1H.C1H_CNPJ, C1H.C1H_CPF)  C "
	cQuery +=	" GROUP BY C.FIL, C.CNPJPR, C.CPF ) TB1 "
	cQuery +=	" GROUP BY TB1.FIL, TB1.CNPJPR, TB1.CPF) TB2 "
	cQuery +=	" GROUP BY TB2.FIL "
	cQuery +=	" ORDER BY TB2.FIL "
endif

if nView == 0 .and. lApur
	cQuery += " ORDER BY FIL, CNPJPR, CPFPR, PROCID, DTDOC "
Endif

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} StatsReg
Verifica a existência ou não do registro que será apurado

@author Karen Honda, Rafael Leme
@since 28/01/2021
@version 1.0
@return Retorna o status do registro encontrado, caso contrário retorna status "Z", indicando que ainda não existe o registro no cadastro espelho

/*/ 
//-------------------------------------------------------------------

Static Function StatsReg( cPerApur as Character, cTpInsc as Character, cNrInsc as Character, cTpInscPrd as Character, cNrInscPrd as Character) as Character

	Local cRetStat as Character //retorno do status do registro
	
	Default cPerApur := ""

    V5S->(DbSetOrder(2))  // V5S_FILIAL+V5S_PERAPU+V5S_TPINSC+V5S_NRINSC+V5S_TPINSP+V5S_NRINSP+V5S_ATIVO
    If V5S->(MsSeek(xFilial("V5S") + cPerApur + cTpInsc + cNrInsc +  cTpInscPrd + cNrInscPrd + '1'))
        cRetStat := V5S->V5S_STATUS
    Else 
        cRetStat := "Z"
    EndIf
		
Return cRetStat 


//-------------------------------------------------------------------
/*/{Protheus.doc} RegPrinc
Rotinas de apuração da Aquisição da Produção por Produtor Rural PJ/Agroindústria
Registro R-2055 da Reinf
Recebe o alias da query principal, cria e alimenta as temporary tables

@author Karen Honda, Rafael Leme
@since 27/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RegPrinc( cAlias , cPeriod )
Local 	cAlsTTCabc		as Character
Local	cAlsTTPAqui		as Character
Local	cAlsTTProc		as Character
Local	cAlsTTNFs		as Character
Local	cCompart		as Character
Local	cChvReg			as Character
Local	cTpInsc			as Character
Local	cNrInsc			as Character
Local	cCodPar			as Character
Local	cDParti			as Character
Local	cIDPart			as Character

Local 	aCampCabc		as Array
Local 	aCampTpAqui		as Array
Local 	aCampProc		as Array
Local 	aCampNFs		as Array
Local 	oTTCabc			as Object  
Local 	oTTPAqui		as Object
Local 	oTTProc			as Object
Local 	oTTNFs			as Object
Local	nContLaco		as Numeric
Local 	nValIPI			as Numeric
Local	nValICMSST		as Numeric
Local   nVlIcmsFrt      as Numeric			  
Local	nAbat			as Numeric
Local	lAvanc			as Logical
Local 	lIPI			as Logical
Local	lICMSST			as Logical
Local   lICMSFRETE      as Logical						  

Local 	aFieldsC1E 		as Array
Local 	cTpInscPrd 		as Character
Local	cNrInscPrd  	as Character
Local 	cID				as Character
Local	cPAA			as Character 
Local 	cIndAquis		as Character


cAlsTTCabc	:= ""
cAlsTTPAqui	:= ""
cAlsTTProc	:= ""
cAlsTTNFs	:= ""
cCompart	:= ""
cChvReg		:= ""
cTpInsc		:= ""
cNumIte		:= ""
cFil		:= ""
cCodPar		:= ""	
cDParti		:= ""
cIDPart		:= ""
nVlIcmsFrt  := 0
lICMSFRETE  := .F.	

aFieldsC1E	:= {}			

//Parâmetro criado para que o usuário informe se quer ou não que o tributo seja abatido do valor contábil
lIPI		:= Iif( "1" $ SuperGetMV("MV_2055TRB",," "), .T., .F. ) // 1 - IPI
lICMSST		:= Iif( "2" $ SuperGetMV("MV_2055TRB",," "), .T., .F. ) // 2 - ICMS ST

If TAFColumnPos("C30_ICMSFT")
	lICMSFRETE := Iif( "3" $ SuperGetMV("MV_2055TRB",," "), .T., .F. ) // 3 - ICMS ST do frete
EndIf					 

nContLaco	:= 1

aCampCabc	:= {}
aCampTpAqui	:= {}
aCampProc	:= {}
aCampNFs	:= {}

oTTCabc	    := Nil
oTTPAqui	:= Nil
oTTProc	    := Nil
oTTNFs	    := Nil

lAvanc		:= .T.

	DbSelectArea("T9Q")
	T9Q->(DbSetOrder(1))

	DbSelectArea("T9E")
	T9E->(DbSetOrder(1))

	DbSelectArea(cAlias)
	(cAlias)->(DbGoTop())
	
	If (cAlias)->(!EOF())

        cCompart := Upper(AllTrim(FWModeAccess("C1G",1)+FWModeAccess("C1G",2)+FWModeAccess("C1G",3)))		

		cAlsTTCabc	:= getNextAlias()
		cAlsTTPAqui	:= getNextAlias()
		cAlsTTProc	:= getNextAlias()
        cAlsTTNFs	:= getNextAlias()
		
		// Cria a estrutura (array) das temporary table
		PopArray(@aCampCabc, @aCampTpAqui, @aCampProc, @aCampNFs)
		
		// Instancia o objeto Temporary Table 
		oTTCabc	    := FWTemporaryTable():New(cAlsTTCabc, aCampCabc)
		oTTPAqui	:= FWTemporaryTable():New(cAlsTTPAqui, aCampTpAqui)
		oTTProc	    := FWTemporaryTable():New(cAlsTTProc, aCampProc)
        oTTNFs	    := FWTemporaryTable():New(cAlsTTNFs, aCampNFs)
		
		// Seta os devidos indices 
		PopIdxObj(@oTTCabc, @oTTPAqui, @oTTProc, @oTTNFs)

		DbSelectArea(cAlsTTCabc)
		(cAlsTTCabc)->(DbSetOrder(2)) //"CPERIOD","CTPINSC", "CNRINSC"
		
		DbSelectArea(cAlsTTPAqui)
		(cAlsTTPAqui)->(DbSetOrder(1)) //"ID","INDAQUI"

		DbSelectArea(cAlsTTNFs)
		(cAlsTTNFs)->(DbSetOrder(2)) //"ID","INDAQUI, CCHAVENF,IDFAT"

		(cAlias)->(DbGoTop())

		aFieldsC1E := XGetTPInsc((cAlias)->FIL)
		cTpInsc	:= aFieldsC1E[1]
		cNrInsc := aFieldsC1E[2]
		cPAA := RetPAA(cNrInsc,cTpInsc) 
		
		While (cAlias)->(!EOF())
			
			cFil	:= (cAlias)->FIL
			cCodPar	:= (cAlias)->CODPAR
			cDParti	:= (cAlias)->NOME
			cIDPart := (cAlias)->IDPART

			//Funções para pegar o valor dos tributos
			nValIPI		:=	Iif(lIPI, GetValTRB((cAlias)->CHVNF, (cAlias)->NUMITE, cFil, IPI), 0 )
			nValICMSST	:=	Iif(lICMSST, GetValTRB((cAlias)->CHVNF, (cAlias)->NUMITE, cFil, ICMS_ST), 0 )
			
			If TAFColumnPos("C30_ICMSFT") .and. lICMSFRETE
				nVlIcmsFrt := GetICMSFRT( (cAlias)->CHVNF, (cAlias)->NUMITE, cFil )
			EndIF
			
			nAbat	:= (cAlias)->VLRRECBRUTA - nValIPI - nValICMSST - nVlIcmsFrt

			cIndAquis := ""
			If Empty((cAlias)->CPFPR) .AND. !Empty((cAlias)->CNPJPR)
				
				cNrInscPrd  := (cAlias)->CNPJPR
				cTpInscPrd := "1"

				//-- Pessoa jurídica
				If TAFColumnPos("C1E_PAA")
					If cPAA == "1" .AND. (cAlias)->INDISE <> "1"
						cIndAquis := "3"
					Else
						If cPAA == "1" .AND. (cAlias)->INDISE == "1"  
							cIndAquis := "6"
						EndIf
					EndIf	
				Else
					If cPAA == "1" .AND. (cAlias)->INDISE == "1" 
						cIndAquis := "6"	
					EndIf
				EndIf
				If cPAA <> "1"
					cIndAquis := "3"
				EndIf	
			Else
				//-- Produtor pessoa física
				cNrInscPrd  := (cAlias)->CPFPR
				cTpInscPrd := "2"
				
				If cPAA == "1" .AND. (cAlias)->INDISE <> "1"
					cIndAquis := "2"
				ElseIf cPAA != "1" .AND. (cAlias)->INDISE <> "1"
					cIndAquis := "1"
				ElseIf cPAA <> "1" .AND. (cAlias)->INDISE == "1" 
					cIndAquis := "4"
				ElseIf cPAA == "1" .AND. (cAlias)->INDISE == "1"
					cIndAquis := "5"		 				
				EndIf	

				If (cAlias)->CFOP == "1501" .or. (cAlias)->CFOP == "2501" 
					cIndAquis := "7"
				EndIf
			EndIf 

			cID	:= Padr(cPeriod + cTpInsc + cNrInsc + cTpInscPrd + cNrInscPrd,60)
			If !(cAlsTTCabc)->(DbSeek(cID))
				
				RecLock(cAlsTTCabc,.T.)
				
				(cAlsTTCabc)->FIL			:= cFil
				(cAlsTTCabc)->ID			:= cID
				(cAlsTTCabc)->CCODPAR		:= cCodPar
				(cAlsTTCabc)->CDPARTI		:= cDParti
				(cAlsTTCabc)->CIDPART		:= cIDPart
				(cAlsTTCabc)->CTPINSC 		:= cTpInsc 	 				//tpInscAdq
				(cAlsTTCabc)->CNRINSC		:= cNrInsc 					//nrInscAdq	
				(cAlsTTCabc)->CPERIOD		:= cPeriod 	
               	(cAlsTTCabc)->CTPINSPRD     := cTpInscPrd				//tpInscProd
                (cAlsTTCabc)->CNRINSCPRD    := cNrInscPrd				//nrInscProd
                (cAlsTTCabc)->CINDOPCCP     := (cAlias)->INDCP			//indOpcCP
				(cAlsTTCabc)->PROCID        := (cAlias)->PROCID			//ProcId

				(cAlsTTCabc)->(MsUnlock())

			EndIf
			
			If (cAlsTTPAqui)->( !DbSeek( cID + cIndAquis ) )	
				
				RecLock(cAlsTTPAqui,.T.)
				
				(cAlsTTPAqui)->FIL			:= cFil
				(cAlsTTPAqui)->ID			:= cID
				(cAlsTTPAqui)->INDAQUI		:= cIndAquis	 				//indAquis
				(cAlsTTPAqui)->VLRRECBRUT	:= nAbat						//vlrBruto
				(cAlsTTPAqui)->VLRCPAPUR	:= (cAlias)->CONTPR 			//vlrCPDescPR
				(cAlsTTPAqui)->VLRRATAPUR	:= (cAlias)->GILRAT	 			//vlrRatDescPR
				(cAlsTTPAqui)->VLRSENAPUR	:= (cAlias)->SENAR				//vlrSenarDesc
				
								
				(cAlsTTPAqui)->(MsUnlock())
			Else
				RecLock(cAlsTTPAqui,.F.)			
				If cChvReg <> (cAlias)->CHVNF .Or. cNumIte <> (cAlias)->NUMITE .Or. (cAlias)->IDFAT <> ' '
					(cAlsTTPAqui)->VLRRECBRUT	+= nAbat						//vlrBruto
					(cAlsTTPAqui)->VLRCPAPUR	+= (cAlias)->CONTPR				//vlrCPDescPR
					(cAlsTTPAqui)->VLRRATAPUR	+= (cAlias)->GILRAT	 			//vlrRatDescPR
					(cAlsTTPAqui)->VLRSENAPUR	+= (cAlias)->SENAR				//vlrSenarDesc

				EndIf
				(cAlsTTPAqui)->(MsUnlock())		
			EndIf
			
			If !(cAlsTTNFs)->(DbSeek( cID + (cAlsTTPAqui)->INDAQUI + (cAlias)->CHVNF + (cAlias)->IDFAT))
				Reclock(cAlsTTNFs, .T.)
				(cAlsTTNFs)->FIL		:= cFil
				(cAlsTTNFs)->ID			:= cID
				(cAlsTTNFs)->INDAQUI	:= (cAlsTTPAqui)->INDAQUI 
				(cAlsTTNFs)->CCHVNF		:= (cAlias)->CHVNF
				(cAlsTTNFs)->CSERIE		:= (cAlias)->SERIE
                (cAlsTTNFs)->DDTEMIS	:= (cAlias)->DTDOC				
				If (cAlias)->TIPO == 'FAT'
					(cAlsTTNFs)->CNUMFAT := (cAlias)->NUMDOC
				Else // TIPO == 'NFS'
					(cAlsTTNFs)->CNUMDOC := (cAlias)->NUMDOC
				EndIF
				(cAlsTTNFs)->CIDFAT	    := (cAlias)->IDFAT
				(cAlsTTNFs)->NVBRTPR	:= nAbat
                (cAlsTTNFs)->NVCPPR		:= (cAlias)->CONTPR
                (cAlsTTNFs)->NVRATPR	:= (cAlias)->GILRAT	
                (cAlsTTNFs)->NVSENPR	:= (cAlias)->SENAR
				(cAlsTTNFs)->RECNO		:= (cAlias)->RECNO
			Else
				Reclock(cAlsTTNFs, .F.)		
				(cAlsTTNFs)->NVBRTPR	+= nAbat
                (cAlsTTNFs)->NVCPPR		+= (cAlias)->CONTPR
                (cAlsTTNFs)->NVRATPR	+= (cAlias)->GILRAT	
                (cAlsTTNFs)->NVSENPR	+= (cAlias)->SENAR
			EndIf


			(cAlsTTNFs)->(MsUnlock())

			If nContLaco == 1 .Or. (cChvReg <> (cAlias)->CHVNF .Or. cNumIte <> (cAlias)->NUMITE) .Or. (cAlias)->IDFAT <> ' '
				
				cChvReg := (cAlias)->CHVNF
				cNumIte := (cAlias)->NUMITE
				
				If IIf((cAlias)->TIPO == 'NFS',T9Q->(MsSeek(xFilial("T9Q", (cAlias)->FIL) + (cAlias)->CHVNF + (cAlias)->NUMITE  ) ),;
				   T9E->(MsSeek( xFilial("T9E", (cAlias)->FIL) + (cAlias)->IDFAT + cIDPart) ) )
					RetProc(cAlsTTProc, cAlias, aCampProc, cID, cCompart, cAlsTTNFs,cIndAquis)
				EndIf	
			EndIf
			
			(cAlias)->(DbSkip())
			nContLaco++
		
		EndDo
	Else
		lAvanc := .F.
	EndIf
Return {{cAlsTTCabc,oTTCabc}, {cAlsTTPAqui,oTTPAqui}, {cAlsTTProc,oTTProc}, {cAlsTTNFs,oTTNFs}, lAvanc }


//-------------------------------------------------------------------
/*/{Protheus.doc} PopArray
Rotinas de apuração da Aquisição da Produção por Produtor Rural PJ/Agroindústria
Registro R-2055 da Reinf
Popula os 4 array com a estrutura das temporary tables

@author Karen Honda, Rafael Leme
@since 27/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PopArray(aCampCabc, aCampAqui, aCampProc, aCampNFs)

Local nTamFil	:= TamSX3("C20_FILIAL")[1]
Local nTamChvNf	:= GetSx3Cache('C20_CHVNF','X3_TAMANHO')

aCampCabc	:=  {{'FIL'			,'C', nTamFil  ,0},;
				{'ID'			,'C', 60 ,0},;
				{'CCODPAR'		,'C', 60 ,0},;
				{'CDPARTI'		,'C', 220 ,0},;
				{'CIDPART'		,'C', 36 ,0},;
				{'CPERIOD'		,'C', 06 ,0},;	//periodo	
				{'CTPINSC'		,'C', 01 ,0},; 	//tpInscAdq
				{'CNRINSC'		,'C', 14 ,0},; 	//nrInscAdq	
				{'CTPINSPRD'	,'C', 01 ,0},; 	//tpInscProd
				{'CNRINSCPRD'	,'C', 14 ,0},; 	//nrInscProd
				{'CINDOPCCP'	,'C', 01 ,0},;
				{'PROCID'	    ,'C', 06 ,0}}	//PROCID	
				
					
aCampAqui	:=	{{'FIL'			,'C', nTamFil  ,0},;
				{'ID'			,'C', 60 ,0},;
				{'INDAQUI'		,'C', 01 ,0},;	//indAquis
				{'VLRRECBRUT'	,'N', 14 ,2},; 	//vlrBruto
				{'VLRCPAPUR'	,'N', 14 ,2},; 	//vlrCPDescPR
				{'VLRRATAPUR'	,'N', 14 ,2},; 	//vlrRatDescPR
				{'VLRSENAPUR'	,'N', 14 ,2}} 	//vlrSenarApur


aCampProc	:= {{'FIL'			,'C', nTamFil  ,0},;
				{'ID'			,'C', 60 ,0},;	
				{'INDAQUI'		,'C', 01 ,0},;	//indCom
				{'C1GID'		,'C', 06 ,0},;
				{'C1GVERSAO'	,'C', 14 ,0},;
				{'CNUMPRO'	    ,'C', TamSx3("C1G_NUMPRO")[1] ,0},;	//nrProcJud
				{'CCODSUS'		,'C', 14 ,0},; 	//codSusp	
				{'VALCPSUS'		,'N', 14 ,2},;	//vlrCPSusp
				{'VLRRATSUSP'	,'N', 14 ,2},; 	//vlrRatSusp
				{'VLRSNRSUSP'	,'N', 14 ,2}}	//vlrSenarSusp

aCampNFs	:= {{'FIL'			,'C', nTamFil  ,0},;
				{'ID'			,'C', 60 ,0},;	
				{'INDAQUI'		,'C', 01 ,0},;	//indCom
				{'CCHVNF'		,'C', nTamChvNf,0},;//V5V_CHVNF
				{'CSERIE'	    ,'C', 20 ,0},; 	//V5V_SERIE
				{'CNUMDOC'	    ,'C', 15 ,0},;	//V5V_NUMDOC
				{'DDTEMIS'      ,'D', 08 ,0},;	//V5V_DTEMIS
				{'NVBRTPR'      ,'N', 14 ,2},;	//V5V_VBRTPR
				{'NVCPPR'       ,'N', 14 ,2},;	//V5V_VCPPR
				{'NVRATPR'      ,'N', 14 ,2},;	//V5V_VRATPR
				{'NVSENPR'      ,'N', 14 ,2},;	//V5V_VSENPR
				{'NVCPSUS'      ,'N', 14 ,2},;	//V5V_VCPSUS
				{'NVRASUS'      ,'N', 14 ,2},;	//V5V_VRASUS
				{'NVSESUS'      ,'N', 14 ,2},;	//V5V_VSESUS
				{'CNUMFAT'      ,'C', 15 ,0},;  //V5V_NUMFAT
				{'CIDFAT'       ,'C', 36 ,0},;  //V5V_IDFAT
				{'RECNO'        ,'N', 10 ,0}}	//RECNO
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PopIdxObj
Rotinas de apuração da Aquisição da Produção por Produtor Rural PJ/Agroindústria
Registro R-2055 da Reinf
Cria os 4 indices para suas respectivas temporary tables

@author Karen Honda, Rafael Leme
@since 27/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function PopIdxObj(oTTCabc, oTTPAqui, oTTProc, oTTNFs )

	oTTCabc:AddIndex("1", {"ID"})
	oTTCabc:AddIndex("2", { "CPERIOD","CTPINSC", "CNRINSC","CTPINSPRD", "CNRINSCPRD"})

	oTTPAqui:AddIndex("1", {"ID","INDAQUI"})

	oTTProc:AddIndex("1", {"ID", "INDAQUI"})
	oTTProc:AddIndex("2", {"ID", "INDAQUI", "CNUMPRO", "CCODSUS"})

	oTTNFs:AddIndex("1", {"ID", "INDAQUI"})
	oTTNFs:AddIndex("2", {"ID", "INDAQUI","CCHVNF","CIDFAT"})

	oTTCabc:Create()
	oTTPAqui:Create()
	oTTProc:Create()
    oTTNFs:Create()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} XGetTPInsc

Função responsável por retornar o TIPO da inscrição para a filial logada no sistema CNPJ/CAEPF.

@author Robson Santos
@since 14/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function XGetTPInsc(cFil as Character) as Array

Local cRetTPInsc	as Character
Local aArea			as Array
Local nTamFil		as Numeric
Local cRetInsc		as Character
Local cCGCFil		as Character



cRetTPInsc	:= "" 
aArea		:= GetArea()  
nTamFil		:= TamSX3( "C1E_FILTAF" )[1]		
cRetInsc	:= ""
cCGCFil:= Posicione("SM0", 1, cEmpAnt + cFil, "M0_CGC")

//-- Posiciona na C1E de acordo com a filial do registro
dbSelectArea("C1E")
C1E->(dbSetOrder(3))
If C1E->(MSSeek(XFilial("C1E")+PadR(cFil, nTamFil)+"1"))
	If TAFColumnPos("C1E_CAEPFR") .AND. !Empty(C1E->C1E_CAEPFR) .And. (Len(Alltrim(cCgcFil))<=11)
		cRetTPInsc := "3"
		cRetInsc := C1E->C1E_CAEPFR
	Else
		cRetTPInsc := "1"
		cRetInsc := cCGCFil
	EndIf
EndIf

RestArea(aArea)
Return {cRetTPInsc,cRetInsc}

//-------------------------------------------------------------------
/*/{Protheus.doc} RetPAA

Função responsável por retornar o conteudo do campo PAA 
da tabela C1E de acordo com a raiz do CNPJ.

cInsc: CNPJ do estabelcimento

@author Robson Santos
@since 30/05/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetPAA(cInsc, cTpInsc)

Local cPAA 		:= ""
Local aAreaSM0	:= SM0->(GetArea())
Local aAreaC1E	:= C1E->(GetArea())
Local nTamFil	:= TamSX3( "C1E_FILTAF" )[1]
Local lAchou	:= .F.

//-- Posiciona na SM0 com a raiz do CNPJ do estabelecimento
dbSelectArea("SM0")
SM0->(dbGoTop())

//-- CNPJ
If cTpInsc == '1'

	While !SM0->(Eof()) .And. !lAchou
		If !Empty(cInsc)
			If AllTrim(SM0->M0_CGC) == AllTrim(cInsc)

				lAchou	:= .T.
				cPAA 	:= Posicione("C1E", 3, XFilial("C1E")+PadR(SM0->M0_CODFIL, nTamFil)+"1", "C1E_PAA" )

			EndIf
		EndIf
		SM0->(DbSkip())
	EndDo

//-- CAEPF	
ElseIf cTpInsc == '3'

	dbSelectArea("C1E")
	C1E->(dbGoTop())

	While !C1E->(Eof()) .And. !lAchou
		If !Empty(cInsc)
			If SubStr(AllTrim(C1E->C1E_NRCPF), 1, 9) == SubStr(AllTrim(cInsc),1,9)
				lAchou	:= .T.
				cPAA := C1E->C1E_PAA
			EndIf
		EndIf
		C1E->(DbSkip())
	EndDo

EndIf

RestArea(aAreaC1E)
RestArea(aAreaSM0)

Return cPAA

//-------------------------------------------------------------------
/*/{Protheus.doc} RetProc
Rotinas de apuração da Aquisição da Produção por Produtor Rural /Agroindústria
Registro R-2055 da Reinf
Consulta os processos que devem ser apurados para o R-2055
Popula as temporary tables com o retorno da consulta

@author Karen Honda, Rafael Leme
@since 27/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function RetProc(cAlsTTProc, Alias, aCampProc, cChavProc, cCompC1G, cAlsTTNFs,cIndAquis)
	
	Local cSelect		AS Character
	Local cFrom			AS Character
	Local cJoin			AS Character
	Local cJoinC1G		AS Character
	Local cWhere		AS Character
	Local cAliasT9Q		AS Character
	Local cChavSeek		AS Character
	
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
	cBd			:= Upper( AllTrim( TCGetDB() ) )
	
	nTam		:= 0
	nTamIDSUSP	:= 0
	lFormat		:= .F.
	lProcessa	:= .F.

	
	cSelect 	:= "'" + cChavProc + "' ID, T9Q.T9Q_CODTRI CODTRI, "
	cSelect 	+= " T9Q.T9Q_NUMPRO NUMPRO, T5L.T5L_INDDEC INDSUSP,  T5L.T5L_CODSUS CODSUS, T9Q.T9Q_VALSUS VALSUS, "
	cSelect 	+= " CASE WHEN C1G.C1G_TPPROC = '1' "
	cSelect		+= " THEN '2' " 
	cSelect 	+= " ELSE '1' "
	cSelect 	+= " END CTPPROC, "
	cSelect 	+= " C1G.C1G_NUMPRO C1GNUMPRO, C1G.C1G_ID C1GID, C1G.C1G_VERSAO C1GVERSAO, C1G.C1G_FILIAL C1GFILIAL "
	cSelect		+= " FROM " + RetSqlName("T9Q") + " T9Q"
	cSelect		+= " INNER JOIN " + RetSqlName("C1G") + " C1G ON "
	cSelect 	+= " C1G.C1G_FILIAL = '" + xFilial("C1G",(Alias)->FIL) + "' AND "
	cSelect 	+= " C1G.C1G_ID = T9Q.T9Q_NUMPRO AND C1G.D_E_L_E_T_ = ' '  "
	cSelect		+= " INNER JOIN " +  RetSqlName("T5L") + " T5L ON "

	If cBd $ "ORACLE|POSTGRES"
		if  cBd $ "POSTGRES"
			nTamIDSUSP	:= TamSX3("T9Q_IDSUSP")[1]
			cSelect	+= " T9Q.T9Q_IDSUSP = SUBSTR(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") AND " 
		Else
			cSelect	+= " T9Q.T9Q_IDSUSP = T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS AND " 
		Endif
	Else
		cSelect	+= " T9Q.T9Q_IDSUSP = T5L.T5L_ID + T5L.T5L_VERSAO + T5L.T5L_CODSUS AND "
	EndIf 
	
	cSelect		+= " T5L.D_E_L_E_T_ = ' '  AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "
	cSelect		+= " WHERE "
	cSelect		+= " T9Q.T9Q_FILIAL = '" +  (Alias)->FIL + "' AND "
	cSelect		+= " T9Q.D_E_L_E_T_ = ' '  AND T9Q.T9Q_CHVNF = '" + (Alias)->CHVNF +  "' AND T9Q.T9Q_CODTRI IN ('000013','000024','000025') AND T9Q.T9Q_NUMITE = '" + (Alias)->NUMITE + "' "
	cSelect		+= " UNION ALL "
	cSelect		+= " SELECT "
	cSelect 	+= "'" + cChavProc + "' ID, " 		
	cSelect 	+= " T9E.T9E_CODTRI CODTRI, " 
	cSelect 	+= " T9E.T9E_NUMPRO NUMPRO, "
	cSelect 	+= " T5L.T5L_INDDEC INDSUSP, "
	cSelect 	+= " T5L.T5L_CODSUS CODSUS, "
	cSelect 	+= " T9E.T9E_VALSUS VALSUS, "
	cSelect 	+= " CASE WHEN C1G.C1G_TPPROC = '1' THEN '2' ELSE '1' END CTPPROC, "
	cSelect 	+= " C1G.C1G_NUMPRO C1GNUMPRO, "
	cSelect 	+= " C1G.C1G_ID C1GID, "
	cSelect 	+= " C1G.C1G_VERSAO C1GVERSAO, "
	cSelect 	+= " C1G.C1G_FILIAL C1GFILIAL "
	cSelect 	+= " FROM " + RetSqlName("T9E") + " T9E "
	cSelect 	+= " INNER JOIN " + RetSqlName("C1G") + " C1G ON "
	cSelect 	+= " C1G.C1G_FILIAL = '" + xFilial("C1G",(Alias)->FIL) + "' "
	cSelect 	+= " AND C1G.C1G_ID = T9E.T9E_NUMPRO "
	cSelect 	+= " AND C1G.D_E_L_E_T_ = ' ' "
	cSelect 	+= " INNER JOIN " + RetSqlName("T5L") + " T5L ON "
	
	If cBd $ "ORACLE|POSTGRES"
		if  cBd $ "POSTGRES"
			nTamIDSUSP	:= TamSX3("C5O_IDSUSP")[1]
			cSelect	+= " T9E.T9E_IDSUSP = SUBSTR(T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS,1,"+cValToChar(nTamIDSUSP)+") " 
		Else
			cSelect	+= " T9E.T9E_IDSUSP = T5L.T5L_ID || T5L.T5L_VERSAO || T5L.T5L_CODSUS " 
		Endif
	Else
		cSelect	+= " T9E.T9E_IDSUSP = T5L.T5L_ID + T5L.T5L_VERSAO + T5L.T5L_CODSUS "
	EndIf 

	cSelect 	+= " AND T5L.D_E_L_E_T_ = ' ' "
	cSelect 	+= " AND T5L.T5L_FILIAL = C1G.C1G_FILIAL "
	cSelect 	+= " WHERE T9E.T9E_FILIAL = '" + xFilial("T9E",(Alias)->FIL) + "' "
	cSelect 	+= " AND T9E.T9E_NUMFAT = '" + (Alias)->NUMDOC + "' "
	cSelect 	+= " AND T9E.T9E_CODTRI IN ('000013','000024','000025')	"	
	cSelect 	+= " AND T9E.D_E_L_E_T_ = ' ' "

	cSelect 	:= "%" + cSelect + "%"
	BeginSql Alias cAliasT9Q
		SELECT
		%Exp:cSelect%
	EndSql
	
	If (cAliasT9Q)->(!EOF())
		cChavSeek := (cAliasT9Q)->ID + cIndAquis + (cAliasT9Q)->C1GNUMPRO + (cAliasT9Q)->CODSUS 
		lProcessa	:= .T.
	EndIf
	
	DbSelectArea(cAlsTTProc)
	(cAlsTTProc)->(DbSetOrder(2)) //"ID", "INDAQUI", "CNUMPRO", "CCODSUS"
	(cAliasT9Q)->(DbGoTop())
	If lProcessa
		RecLock(cAlsTTNFs, .F.)
		While !(cAliasT9Q)->(EOF())
		
			If !(cAlsTTProc)->(MsSeek(cChavSeek))
				
				RecLock(cAlsTTProc, .T.)

				(cAlsTTProc)->FIL		:= (cAliasT9Q)->C1GFILIAL
				(cAlsTTProc)->ID		:= (cAliasT9Q)->ID
				(cAlsTTProc)->INDAQUI 	:= cIndAquis
				(cAlsTTProc)->C1GVERSAO := (cAliasT9Q)->C1GVERSAO
				(cAlsTTProc)->C1GID 	:= (cAliasT9Q)->C1GID
				(cAlsTTProc)->CNUMPRO	:= (cAliasT9Q)->C1GNUMPRO	//nrProc
				(cAlsTTProc)->CCODSUS	:= (cAliasT9Q)->CODSUS		//codSusp

				If (cAliasT9Q)->CODTRI == '000013'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
					
					(cAlsTTProc)->VALCPSUS	:= (cAliasT9Q)->VALSUS //vlrCPSusp
					(cAlsTTNFs)->NVCPSUS += (cAliasT9Q)->VALSUS //vlrCPSusp
					
				ElseIf (cAliasT9Q)->CODTRI == '000024'	.AND. (cAliasT9Q)->INDSUSP <> '000015'					
					
					(cAlsTTProc)->VLRRATSUSP	:= (cAliasT9Q)->VALSUS 	//vlrRatSusp
					(cAlsTTNFs)->NVRASUS += (cAliasT9Q)->VALSUS //vlrCPSusp
					
				ElseIf (cAliasT9Q)->CODTRI == '000025'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
					
					(cAlsTTProc)->VLRSNRSUSP	:= (cAliasT9Q)->VALSUS	//vlrSenarSusp
					(cAlsTTNFs)->NVSESUS	+= (cAliasT9Q)->VALSUS	//vlrSenarSusp
					
				EndIf
			Else
				RecLock(cAlsTTProc, .F.)
				If (cAliasT9Q)->CODTRI == '000013'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
					
					(cAlsTTProc)->VALCPSUS	+= (cAliasT9Q)->VALSUS //vlrCPSusp
					(cAlsTTNFs)->NVCPSUS += (cAliasT9Q)->VALSUS //vlrCPSusp
					
				ElseIf (cAliasT9Q)->CODTRI == '000024'	.AND. (cAliasT9Q)->INDSUSP <> '000015'					
					
					(cAlsTTProc)->VLRRATSUSP	+= (cAliasT9Q)->VALSUS 	//vlrRatSusp
					(cAlsTTNFs)->NVRASUS += (cAliasT9Q)->VALSUS //vlrCPSusp
					
				ElseIf (cAliasT9Q)->CODTRI == '000025'	.AND. (cAliasT9Q)->INDSUSP <> '000015'
					
					(cAlsTTProc)->VLRSNRSUSP	+= (cAliasT9Q)->VALSUS	//vlrSenarSusp
					(cAlsTTNFs)->NVSESUS	+= (cAliasT9Q)->VALSUS	//vlrSenarSusp
					
				EndIf

			EndIf

			(cAlsTTProc)->(MsUnlock())

			(cAliasT9Q)->(DbSkip())
			cChavSeek := (cAliasT9Q)->ID + cIndAquis + (cAliasT9Q)->C1GNUMPRO + (cAliasT9Q)->CODSUS

		EndDo
		(cAlsTTNFs)->(MsUnlock())
	EndIf
	(cAliasT9Q)->(DbCloseArea())
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiReg()

Efetua a exclusão do modelo conforme parâmetro

@author Karen Honda, Rafael Leme
@since 28/01/2018
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function ExcluiReg(aErro as Array) as Logical

	Local cErro			As Character
	Local cNrInsc		As Character
	Local cTpInsc		As Character
	Local cNrInscPrd	As Character
	Local cTpInscPrd	As Character

	Local lExcluiu		As Logical 
	Local oModel 		As Object
	
	cErro := "" 
	lExcluiu := .F.
	
	oModel 	:= FWLoadModel("TAFA576")
	cNrInsc	:= V5S->V5S_NRINSC
	cTpInsc	:= V5S->V5S_TPINSC
	cTpInscPrd  := V5S->V5S_TPINSP
	cNrInscPrd  := V5S->V5S_NRINSP

	oModel:SetOperation(5)
	oModel:Activate()
	
	If FwFormCommit(oModel)
	    lExcluiu := .T.
	Else
		cErro	:= STR0007 + CRLF // "Não foram localizados registros que atendam os parâmetros selecionados para processamento da apuração."
	
		cErro 	+= "tpInscAdq: " + cTpInsc + CRLF	
		cErro 	+= "nrInscAdq: " + cNrInsc + CRLF
		cErro 	+= "tpInscProd: " + cTpInscPrd + CRLF
		cErro 	+= "nrInscProd: " + cNrInscPrd + CRLF

		cErro  	+= STR0004 + CRLF // "Inconsistência na gravação do registro contendo a chave: "
		cErro 	+= TafRetEMsg(oModel)
		Aadd(aErro, {"R-2055", STR0009, cErro}) // "ERRO"
		lExcluiu := .F.
	EndIf

Return lExcluiu

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava2055
Efetua gravação no modelo da tabela espelho do evento R-2055 (Aquisição de Produção Rural )

@author Karen Honda, Rafael Leme
@since 28/01/2021
@version 1.0
@return Retorna se a transação é válida

/*/ 
//-------------------------------------------------------------------

Static Function Grava2055(nOpc, cPerApu, aApuracao, aFil, cVerAnt, cProTpn, cIdApReinf, aErro, cId, lValid, cStatus, aMovs, oModel, oModelV5S, oModelV5T, oModelV5U, oModelV5V )
				
	Local cEvento		As Character
	Local cChaveReg		As Character
	Local lVldData		As Logical
	Local lVldProc		As Logical
	Local nContLaco		As Numeric
	Local nContLac2		As Numeric
	Local nErro			As Numeric
	Local aDocsErro		As Array
	Local aRecnos		As Array
	
	cChaveReg	:= ""
	cEvento		:= "I"
	lVldData	:= .T.
	lVldProc	:= .T.
	nContLaco	:= 1   
	nContLac2 	:= 1
	nErro		:= 0
	aDocsErro	:= {}
	aRecnos		:= {}

	Default	cVerAnt	:= ''
	Default cProTpn	:= ''
	Default cId		:= ''
	Default aMovs	:= {}
	
	
	
	oModel:SetOperation(nOpc)
	oModel:Activate()

	If !Empty(cVerAnt)
		oModel:LoadValue('MODEL_V5S', 'V5S_VERANT'	, cVerAnt)
		oModel:LoadValue('MODEL_V5S', 'V5S_PROTPN'	, cProTpn)
		oModel:LoadValue('MODEL_V5S', 'V5S_ID'		, cId)
		// Excluido deve gerar uma inclusão
		If cStatus == "7"
			cEvento := 'I'		
		Else
			cEvento := 'A'
		EndIf
	EndIf

	oModel:LoadValue('MODEL_V5S', 'V5S_VERSAO'  , xFunGetVer())
	oModel:LoadValue('MODEL_V5S', 'V5S_STATUS'  , '')
	oModel:LoadValue('MODEL_V5S', 'V5S_EVENTO'  , cEvento)
	oModel:LoadValue('MODEL_V5S', 'V5S_ATIVO'   , '1')
	oModel:LoadValue('MODEL_V5S', 'V5S_PERAPU'	, cPerApu)
	oModel:LoadValue('MODEL_V5S', 'V5S_IDESTA'  , aFil[aScan(aFil, {|x|Alltrim(x[2])== Alltrim((aApuracao[TCABC])->FIL) })][1])
	oModel:LoadValue('MODEL_V5S', 'V5S_DESTAB'  , Alltrim(FWSM0Util():GETSM0Data(, (aApuracao[TCABC])->FIL, {"M0_FILIAL"})[1,2]))
	oModel:LoadValue('MODEL_V5S', 'V5S_TPINSC'	, (aApuracao[TCABC])->CTPINSC)		//tpInscAdq
	oModel:LoadValue('MODEL_V5S', 'V5S_NRINSC'	, (aApuracao[TCABC])->CNRINSC) 		//nrInscAdq													
	oModel:LoadValue('MODEL_V5S', 'V5S_TPINSP'	, (aApuracao[TCABC])->CTPINSPRD)		//tpInscProd
	oModel:LoadValue('MODEL_V5S', 'V5S_NRINSP'	, (aApuracao[TCABC])->CNRINSCPRD) 		//nrInscProd													
	oModel:LoadValue('MODEL_V5S', 'V5S_INDCP '	, (aApuracao[TCABC])->CINDOPCCP) 		//indOpcCP
	oModel:LoadValue('MODEL_V5S', 'V5S_CODPAR'	, (aApuracao[TCABC])->CCODPAR)
	oModel:LoadValue('MODEL_V5S', 'V5S_DPARTI'	, (aApuracao[TCABC])->CDPARTI)
	oModel:LoadValue('MODEL_V5S', 'V5S_IDPART'	, (aApuracao[TCABC])->CIDPART)

	(aApuracao[TAQUIS])->(DbSetOrder(1))
	(aApuracao[TAQUIS])->(DbSeek((aApuracao[TCABC])->ID))
	
	(aApuracao[TPROC])->(DbSetOrder(1))
	(aApuracao[TNFS])->(DbSetOrder(1))

	While !(aApuracao[TAQUIS])->(Eof()) .And. (aApuracao[TCABC])->ID == (aApuracao[TAQUIS])->ID
		nContLac2 	:= 1
		
		If nContLaco > 1 .And. !oModelV5S:VldData() 
			lVldData := .F.
		EndIf 
			
		If nContLaco > 1
			oModelV5T:AddLine() 
		EndIf 
		
		oModel:LoadValue('MODEL_V5T', 'V5T_IDAQUI'	, (aApuracao[TAQUIS])->INDAQUI)		//indAquis
		oModel:LoadValue('MODEL_V5T', 'V5T_VBRTPR'	, (aApuracao[TAQUIS])->VLRRECBRUT)	//vlrBruto
		oModel:LoadValue('MODEL_V5T', 'V5T_VCPPR '	, (aApuracao[TAQUIS])->VLRCPAPUR)	//vlrCPDescPR
		oModel:LoadValue('MODEL_V5T', 'V5T_VRATPR'	, (aApuracao[TAQUIS])->VLRRATAPUR)	//vlrRatDescPR
		oModel:LoadValue('MODEL_V5T', 'V5T_VSENPR'	, (aApuracao[TAQUIS])->VLRSENAPUR)	//vlrSenarApur

		(aApuracao[TPROC])->(DbSeek((aApuracao[TAQUIS])->ID + (aApuracao[TAQUIS])->INDAQUI))
		
		While !(aApuracao[TPROC])->(Eof()) .And. (aApuracao[TAQUIS])->ID == (aApuracao[TPROC])->ID .And. (aApuracao[TAQUIS])->INDAQUI == (aApuracao[TPROC])->INDAQUI
			If nContLac2 > 1 .And. !oModelV5T:VldData()
				lVldData := .F. 
			EndIf 
			
			If nContLac2 > 1 .And. nOpc == MODEL_OPERATION_INSERT
				oModelV5U:AddLine()
			EndIf
			
			oModel:LoadValue('MODEL_V5U', 'V5U_IDPROC', (aApuracao[TPROC])->C1GID)
			oModel:LoadValue('MODEL_V5U', 'V5U_NUMPRO', (aApuracao[TPROC])->CNUMPRO)	//nrProc
			oModel:LoadValue('MODEL_V5U', 'V5U_CODSUS', (aApuracao[TPROC])->CCODSUS)		//codSusp
			oModel:LoadValue('MODEL_V5U', 'V5U_IDSUSP', (aApuracao[TPROC])->C1GID + (aApuracao[TPROC])->C1GVERSAO + (aApuracao[TPROC])->CCODSUS)
			oModel:LoadValue('MODEL_V5U', 'V5U_VCPSUS', (aApuracao[TPROC])->VALCPSUS)	//vlrCPSusp
			oModel:LoadValue('MODEL_V5U', 'V5U_VRASUS', (aApuracao[TPROC])->VLRRATSUSP)	//vlrRatSusp
			oModel:LoadValue('MODEL_V5U', 'V5U_VSESUS', (aApuracao[TPROC])->VLRSNRSUSP)	//vlrSenarSusp
			
			If lValid
				T9V->(DbSetOrder(5))
				If !T9V->(DbSeek(xFilial('T9V') + (aApuracao[TPROC])->C1GID + "1"))    
					lVldProc := .F. 
					Exit 
				EndIf
			EndIf
			
			(aApuracao[TPROC])->(DbSkip()) 
			nContLac2++
		EndDo 
		
		If !lVldProc
			Exit
		EndIf

		nContLac2 := 1
		(aApuracao[TNFS])->(DbSeek((aApuracao[TAQUIS])->ID + (aApuracao[TAQUIS])->INDAQUI))
		While !(aApuracao[TNFS])->(Eof()) .And. (aApuracao[TAQUIS])->ID == (aApuracao[TNFS])->ID .And. (aApuracao[TAQUIS])->INDAQUI == (aApuracao[TNFS])->INDAQUI
			If nContLac2 > 1 .And. !oModelV5T:VldData()
				lVldData := .F. 
			EndIf 
			
			If nContLac2 > 1 .And. nOpc == MODEL_OPERATION_INSERT
				oModelV5V:AddLine()
			EndIf
			
			
			oModel:LoadValue('MODEL_V5V', 'V5V_CHVNF',  (aApuracao[TNFS])->CCHVNF)
			oModel:LoadValue('MODEL_V5V', 'V5V_SERIE',  (aApuracao[TNFS])->CSERIE)	
			oModel:LoadValue('MODEL_V5V', 'V5V_NUMDOC', (aApuracao[TNFS])->CNUMDOC)
			oModel:LoadValue('MODEL_V5V', 'V5V_DTEMIS', (aApuracao[TNFS])->DDTEMIS)
			oModel:LoadValue('MODEL_V5V', 'V5V_VBRTPR', (aApuracao[TNFS])->NVBRTPR)	
			oModel:LoadValue('MODEL_V5V', 'V5V_VCPPR',  (aApuracao[TNFS])->NVCPPR)	
			oModel:LoadValue('MODEL_V5V', 'V5V_VRATPR', (aApuracao[TNFS])->NVRATPR)	
			oModel:LoadValue('MODEL_V5V', 'V5V_VSENPR', (aApuracao[TNFS])->NVSENPR)	
			oModel:LoadValue('MODEL_V5V', 'V5V_VCPSUS', (aApuracao[TNFS])->NVCPSUS)	
			oModel:LoadValue('MODEL_V5V', 'V5V_VRASUS', (aApuracao[TNFS])->NVRASUS)	
			oModel:LoadValue('MODEL_V5V', 'V5V_VSESUS', (aApuracao[TNFS])->NVSESUS)	
			oModel:LoadValue('MODEL_V5V', 'V5V_NUMFAT', (aApuracao[TNFS])->CNUMFAT)	
			oModel:LoadValue('MODEL_V5V', 'V5V_IDFAT',  (aApuracao[TNFS])->CIDFAT)	

			If Empty((aApuracao[TNFS])->CIDFAT)
				AADD(aRecnos,{'C20','C20_PROCID',(aApuracao[TNFS])->RECNO})
			Else
				AADD(aRecnos,{'LEM','LEM_PROCID',(aApuracao[TNFS])->RECNO})
			EndIf

			(aApuracao[TNFS])->(DbSkip()) 
			nContLac2++
		EndDo 

		(aApuracao[TAQUIS])->(DbSkip())
		nContLaco++
	EndDo
			
	If lVldData .And. oModel:VldData() .And. lVldProc
		FwFormCommit(oModel)
		
		RecLock("V5S", .F.)
		V5S->V5S_PROCID := cIdApReinf
		MsUnlock()
	    lRollBack := .T.

		For nContLaco := 1 to Len(aRecnos)
			aAdd(aMovs, {aRecnos[nContLaco][1],aRecnos[nContLaco][2],aRecnos[nContLaco][3]})
		Next nContLaco
	Else
		
		cErro	:= STR0004 + CRLF // "Inconsistência na gravação do registro contendo a chave: "
		cErro 	+= "tpInscAdq: "	+ (aApuracao[TCABC])->CTPINSC  + CRLF
		cErro 	+= "nrInscAdq: " 	+ (aApuracao[TCABC])->CNRINSC + CRLF
		cErro 	+= "tpInscProd: "	+ (aApuracao[TCABC])->CTPINSPRD  + CRLF
		cErro 	+= "nrInscProd: " 	+ (aApuracao[TCABC])->CNRINSCPRD + CRLF

		If !lVldProc 
			oModel:VldData()
			cErro	+= STR0010 + Alltrim((aApuracao[TPROC])->CNUMPRO) + STR0011  + CRLF // "Processo número " | " não localizado na tabela de apurações do evento R-1070. Regra de predecessão não atendida."
		EndIf
		
		cErro  	+= STR0012 + CRLF + CRLF // "Detalhes do Erro: "
		cErro 	+= TafRetEMsg(oModel)
		
		Aadd(aErro, {"R-2055", STR0009, cErro}) // "ERRO"
		lRollBack := .F.

	EndIf

	oModel:DeActivate()

Return lRollBack


//-------------------------------------------------------------------
/*/{Protheus.doc} GravaId()
Efetua a gravação dos ids da tabela legado

@author Karen Honda, Rafael Leme
@since 28/01/2021
@version 1.0
@return

/*/ 
//-------------------------------------------------------------------

Static Function GravaId(aMovs, cIdApur)

	Local	nX	as numeric
 
	Default aMovs 	:= {}
	Default cIdApur	:= ''

	For nX := 1 to Len(aMovs)
		TafEndGRV( aMovs[nX][1],aMovs[nX][2], cIdApur, aMovs[nX][3])
	Next nX
	aSize(aMovs,0)
	aMovs := {}

Return
