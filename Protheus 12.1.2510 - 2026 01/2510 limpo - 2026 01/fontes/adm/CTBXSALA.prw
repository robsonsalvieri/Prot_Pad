#Include 'Protheus.ch'
#include "tbiconn.ch"
#INCLUDE "CTBXSALA.CH"

// Manejo de entidad 05
Static lEntidad05 := (cPaisLoc $ "COL|PER" .And. CtbMovSaldo("CT0",,"05") .And. FWAliasInDic("QL6") .And. FWAliasInDic("QL7"))
Static cKeyMaxCQ  := ""
Static oQueryQry
Static oQrySldCQ  
Static lSelConta  := .F.
Static lSelCCusto := .F.
Static lSelItem   := .F.
Static lSelCLVL   := .F.
Static lSelEnt05  := .F.
Static lSelIdent  := .F.
Static lSelCodigo := .F.
Static lIsSmartView := CTBChkSV() //Verifica se o relatorio esta sendo executado via SmartView

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCQFil
Saldo da entidade por filial 

@author Alvaro Camillo Neto

@param cArqBase 	Arquivo Base para o saldo ( CT1 - Conta , CTT - Centro de Custo, CTD - Item Contábil , CTH - Classe de Valor, CTU - Saldo por entidade )
@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cIdent 	Identificador da Tabela
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo                       
@param cRotina 	Rotina de processamento			           
@param lImpAntLP 	Flag para indicar se imprime antes do Lucro/Perdas
@param dDataLP 	Data de Lucro/Perdas                      
@param aSelFil 	Array de Filial		
@param lTodasFil 	Flag para saber se será retornado o saldo de todas as filiais.	
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function SaldoCQFil(cArqBase as character,cConta as character,cCCusto as character,cItem as character,cClasse as character,cIdent as character,dData as date,cMoeda as character,cTpSald as character,cRotina as character,lImpAntLP as logical,dDataLP as date,aSelFil as array,lTodasFil as logical) as array
Local aSaveAnt		as array
Local aSaldo		as array
Local nSaldoAtu		as numeric
Local nDebito 		as numeric
Local nCredito 		as numeric
Local nAtuDeb 		as numeric
Local nAtuCrd 		as numeric
Local nSaldoAnt		as numeric
Local nAntDeb 		as numeric
Local nAntCrd 		as numeric
Local cQuery		as character
Local cArquivo		as character
Local cCampoFil		as character
Local cCodigo		as character

Local cFilAux		as character
Local cCQTmpFil		as character

aSaveAnt		:= GetArea()
aSaldo			:= {}
nSaldoAtu		:= 0
nDebito 		:= 0
nCredito 		:= 0
nAtuDeb 		:= 0
nAtuCrd 		:= 0
nSaldoAnt		:= 0
nAntDeb 		:= 0
nAntCrd 		:= 0
cQuery			:= ""
cArquivo		:= ""
cCampoFil		:= ""
cCodigo			:= ""

cFilAux			:= ""
cCQTmpFil		:= ""

DEFAULT cArqBase	:= ""
DEFAULT cConta		:= ""
DEFAULT cCCusto		:= ""
DEFAULT cItem		:= ""
DEFAULT cClasse		:= ""
DEFAULT cIdent		:= ""
DEFAULT dData		:= STOD("")
DEFAULT cMoeda		:= ""
DEFAULT cTpSald		:= "1"
DEFAULT cRotina		:= ""
DEFAULT lImpAntLP	:= .F.
DEFAULT dDataLP		:= STOD("")
DEFAULT aSelFil		:= {} 
DEFAULT lTodasFil	:= .F.

If cArqBase == "CT1"
	dbSelectArea("CQ0")
	dbSelectArea("CQ1")
	cArquivo := "CQ0"
ElseIf cArqBase == "CTT"
	dbSelectArea("CQ2")
	dbSelectArea("CQ3")
	cArquivo := "CQ2"
	
ElseIf cArqBase == "CTD"
	dbSelectArea("CQ4")
	dbSelectArea("CQ5")
	cArquivo := "CQ4"
	
ElseIf cArqBase == "CTH"
	dbSelectArea("CQ6")
	dbSelectArea("CQ7")
	cArquivo := "CQ6"
	
ElseIf cArqBase == "CTU"
	dbSelectArea("CQ7")
	dbSelectArea("CQ8")
	cArquivo := "CQ8"
EndIf

If cIdent == "CTT"
	cCodigo := cCCusto	
ElseIf cIdent == "CTD"
	cCodigo := cItem	
ElseIf cIdent == "CTH"
	cCodigo := cClasse
EndIf

If Empty(xFilial(cArquivo)) .Or. Len(aSelFil) <= 1  
	cFilAux	:= IIF( Len(aSelFil) == 1, aSelFil[1] , Nil)
	cFilEsp	:= xFilial(cArquivo,cFilAux)	
	RETURN SaldoCQ(@cArqBase,@cConta,@cCCusto,@cItem,@cClasse,@cIdent,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,@cFilEsp)
EndIf

// Tratativa para o filtro de filiais 

cCampoFil := cArquivo+"_FILIAL"
          
cQuery := "SELECT "+cArquivo+"."+cCampoFil
cQuery += " FROM " + RetSqlName( cArquivo ) + " " + cArquivo
cQuery += " WHERE "

cQuery += " D_E_L_E_T_  = ' ' "

If cArqBase != "CTU"

	cQuery += " AND "+cArquivo+"_CONTA = '" + cConta  + "'"

	If cArqBase $ "CTT/CTD/CTH"
		cQuery += " AND "+cArquivo+"_CCUSTO = '" + cCCusto  + "'"
	EndIf

	If cArqBase $ "CTD/CTH"
		cQuery += " AND "+cArquivo+"_ITEM = '" + cItem  + "'"
	EndIf
	
	If cArqBase $ "CTH"
		cQuery += " AND "+cArquivo+"_CLVL = '" + cClasse  + "'"
	EndIf
	
Else
	cQuery += " AND "+cArquivo+"_IDENT = '" + cIdent  + "'"
	cQuery += " AND "+cArquivo+"_CODIGO = '" + cCodigo  + "'"
EndIf

cQuery += " AND "+cArquivo+"_MOEDA   = '" + cMoeda  + "'"
If !FwIsInCallStack("CTBS301") .and. !FwIsInCallStack("LALUREXMOV")
	cQuery += " AND "+cArquivo+"_TPSALD  = '" + cTpSald + "'"
Else
	cQuery += " AND "+cArquivo+"_TPSALD IN (" + cTpSald + ")"
Endif

If !lTodasFil
	cQryFil := " " + cCampoFil + " " + GetRngFil( aSelFil ,cArquivo, .T., @cCQTmpFil)
	cQuery += " AND " + cQryFil
Endif
 
cQuery += " GROUP BY " + cCampoFil

//	konstantin.cherchik 03/15/2018	added cPaisLoc for optimization research 
if cPaisLoc != "RUS"
	cQuery := ChangeQuery(cQuery)
endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"FILCQ",.T.,.F.)

// efetuo a recuperação do saldo por filial
While FILCQ->( !Eof() )

	aSaldo := SaldoCQ(@cArqBase,@cConta,@cCCusto,@cItem,@cClasse,@cIdent,@dData,@cMoeda,@cTpSald,@cRotina,@lImpAntLP,@dDataLP,FILCQ->&(cCampoFil))

	nSaldoAtu	+= aSaldo[1]
	nDebito 	+= aSaldo[2]
	nCredito 	+= aSaldo[3]
	nAtuDeb 	+= aSaldo[4]
	nAtuCrd 	+= aSaldo[5]
	nSaldoAnt	+= aSaldo[6]
	nAntDeb 	+= aSaldo[7]
	nAntCrd	+= aSaldo[8]
	
	FILCQ->( DbSkip() )
End

dbSelectArea("FILCQ")
FILCQ->( dbCloseArea() )

CtbTmpErase(cCQTmpFil)

RestArea(aSaveAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                             ³
//³ [1] Saldo Atual (com sinal)                          ³
//³ [2] Debito na Data                                   ³
//³ [3] Credito na Data                                  ³
//³ [4] Saldo Atual Devedor                              ³
//³ [5] Saldo Atual Credor                               ³
//³ [6] Saldo Anterior (com sinal)                       ³
//³ [7] Saldo Anterior Devedor                           ³
//³ [8] Saldo Anterior Credor                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]
Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCQ
Retorna o saldo da entidade

@author Alvaro Camillo Neto

@param cArqBase 	Arquivo Base para o saldo ( CT1 - Conta , CTT - Centro de Custo, CTD - Item Contábil , CTH - Classe de Valor, CTU - Saldo por entidade )
@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cIdent 	Identificador da Tabela
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo                       
@param cRotina 	Reservado		           
@param lImpAntLP 	Flag para indicar se imprime antes do Lucro/Perdas
@param dDataLP 	Data de Lucro/Perdas                      
@param cFilEsp   Filial de busca
@param lUltDtVl Busca a ultima data de saldo válida


   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function SaldoCQ(cArqBase as character,cConta as character,cCCusto as character,cItem as character,cClasse as character,cIdent as character,dData as date,cMoeda as character,cTpSald as character,cRotina as character,lImpAntLP as logical,dDataLP as date,cFilEsp as character,lUltDtVl as logical,cEnt05 as character) as array

Local nSaldoAtu		as numeric
Local nDebito		as numeric
Local nCredito		as numeric
Local nAtuDeb		as numeric
Local nAtuCrd		as numeric
Local nSaldoAnt		as numeric
Local nAntDeb		as numeric
Local nAntCrd		as numeric
Local cQuery		as character
Local cTabMes		as character
Local cTabDia		as character
Local cFilMes		as character
Local cFilDia		as character
Local cCodigo		as character
Local cCpoTot		as character
Local cCpoDia		as character
Local cCpoMes		as character
Local cGrpDia		as character
Local cGrpMes		as character
Local aTamVlr		as array
Local aArea			as array
Local nDebLP		as numeric
Local nCrdLP		as numeric
Local cTRB			as character
Local dDataNew     	as date
Local cBanco		as character
Local cNulo			as character
Local cCpoTotVal    as character
Local nParam		as Numeric
Local cPrimeiro     as character
Local cDataAnt      as character

Private lTpSldIn 	as Logical
Private cTpSldIn	as Character
Private lKeyDif		as Logical

cCpoTotVal := ""
nParam     := 1    
cTRB	   := ""

nSaldoAtu	:= 0
nDebito		:= 0
nCredito	:= 0
nAtuDeb		:= 0
nAtuCrd		:= 0
nSaldoAnt	:= 0
nAntDeb		:= 0
nAntCrd		:= 0
cQuery		:= ""
cTabMes		:= ""
cTabDia		:= ""
cFilMes		:= ""
cFilDia		:= ""
cCodigo		:= ""
cCpoTot		:= ""
cCpoDia		:= ""
cCpoMes		:= ""
cGrpDia		:= ""
cGrpMes		:= ""
aTamVlr		:= TamSX3("CT2_VALOR")
aArea		:= GetArea()
nDebLP		:= 0
nCrdLP		:= 0
dDataNew    := CTOD("")
cBanco		:= TcGetDb()
cNulo		:= ""
lKeyDif 	:= .F.

DEFAULT cConta 		:= Nil
DEFAULT cCCusto		:= Nil
DEFAULT cItem		:= Nil
DEFAULT cClasse		:= Nil
DEFAULT cIdent		:= ""
DEFAULT dData		:= STOD("")
DEFAULT cMoeda		:= ""
DEFAULT cTpSald		:= "1"
DEFAULT cRotina		:= ""
DEFAULT lImpAntLP   := .F.
DEFAULT dDataLP		:= STOD("")
DEFAULT cFilEsp		:= xFilial("CT2")
DEFAULT lUltDtVl	:= .T.
DEFAULT cEnt05		:= Nil

If !FwIsInCallStack("CTBS301") .and. !FwIsInCallStack("LALUREXMOV")
	lTpSldIn := .F.
	cTpSldIn := "0"
Else
	lTpSldIn := .T.
	cTpSldIn := "1"
EndiF

If cArqBase $ "CT1/CT7/CQ0/CQ1"
	cArqBase := "CT1"
	dbSelectArea("CQ0")
	dbSelectArea("CQ1")
	cTabMes := "CQ0"
	cTabDia := "CQ1"
ElseIf cArqBase $ "CTT/CT3/CQ2/CQ3"
	cArqBase := "CTT"
	dbSelectArea("CQ2")
	dbSelectArea("CQ3")
	cTabMes := "CQ2"
	cTabDia := "CQ3"
ElseIf cArqBase $ "CTD/CT4/CQ4/CQ5"
	cArqBase := "CTD"
	dbSelectArea("CQ4")
	dbSelectArea("CQ5")
	cTabMes := "CQ4"
	cTabDia := "CQ5"
ElseIf cArqBase $ "CTH/CTI/CQ6/CQ7"
	cArqBase := "CTH"
	dbSelectArea("CQ6")
	dbSelectArea("CQ7")
	cTabMes := "CQ6"
	cTabDia := "CQ7"
	
ElseIf cArqBase  $ "CTU/CQ8/CQ9"
	dbSelectArea("CQ7")
	dbSelectArea("CQ8")
	cTabMes := "CQ8"
	cTabDia := "CQ9"
	cArqBase := "CTU"
	If cIdent $ "CTT/CT3"
		cIdent := "CTT"
		cCodigo := cCCusto
	ElseIf cIdent $ "CTD/CT4"
		cIdent := "CTD"
		cCodigo := cItem
	ElseIf cIdent $ "CTH/CTI"
		cIdent := "CTH"
		cCodigo := cClasse
	ElseIf lEntidad05 .And. cIdent $ "CV0/QL6/QL7"
		cIdent := "CV0"
		cCodigo := Left( cEnt05 , Len(CQ8->CQ8_CODIGO) )
	EndIf
ElseIf lEntidad05 .And. cArqBase $ "CV0/QL6/QL7"
	cArqBase := "CV0"
	If cEnt05 != Nil
		cEnt05 := Left( cEnt05 , Len(QL6->QL6_ENT05) )
	EndIf
	dbSelectArea("QL6")
	dbSelectArea("QL7")
	cTabMes := "QL6"
	cTabDia := "QL7"
EndIf

//Tratativa para o filtro de filiais
If cFilEsp == nil .Or. Empty( cFilEsp ) .Or. ValType(cFilEsp) <> "C"
	cFilEsp	:= xFilial( cTabMes )
Else
	cFilEsp := Alltrim( cFilEsp )
Endif

cFilMes := " "+cTabMes+"_FILIAL = '" + cFilEsp + "' "
cFilDia := " "+cTabDia+"_FILIAL = '" + cFilEsp + "' "

cRetKey := RetKeyAtu(cFilEsp,cArqBase,cTabMes,cTabDia,cIdent,cTpSldIn,cMoeda,cCodigo,lImpAntLP) //Monta Chave para identificar se será preciso refazer cabeçalho da Query

If ValType(cKeyMaxCQ) != "C" .Or. Empty(cKeyMaxCQ) .Or. cKeyMaxCQ <> cRetKey
	cKeyMaxCQ := cRetKey
	lKeyDif   := .T.
	oQrySldCQ := Nil
EndIf

If lUltDtVl
	If lEntidad05
		dDataNew := GetDtMaxCQ(cArqBase,cConta,cCCusto,cItem,cClasse,cIdent,dData,cMoeda,cTpSald,cFilEsp,,cEnt05)
	Else
		dDataNew := GetDtMaxCQ(cArqBase,cConta,cCCusto,cItem,cClasse,cIdent,dData,cMoeda,cTpSald,cFilEsp)
	EndIf
Else 
	dDataNew := dData
EndIf

cPrimeiro   := DTOS(FirstDay(dDataNew))
cDataAnt    := DTOS(FirstDay(dDataNew) - 1)
cDataRef    := DTOS(dDataNew)   

If !Empty(dDataNew)
	If lKeyDif .or. oQrySldCQ == Nil
		If cArqBase != "CTU"

			If cConta != Nil
				cCpoTot    += ",CONTA"
				cCpoTotVal += ", ? CONTA" + CRLF
				lSelConta   := .T.
			EndIf

			If lEntidad05
				If cArqBase $ 'CTT/CTD/CTH/CV0' .And. cCCusto != Nil
					cCpoTot    += ",CCUSTO"
					cCpoTotVal += ", ? CCUSTO" + CRLF
					lSelCCusto  := .T.
				EndIf
				If cArqBase $ 'CTD/CTH/CV0' .And. cItem != Nil
					cCpoTot    += ",ITEM"
					cCpoTotVal += ", ? ITEM" + CRLF
					lSelItem    := .T.
				EndIf
				If cArqBase $ 'CTH/CV0' .And. cClasse != Nil
					cCpoTot    += ",CLVL"
					cCpoTotVal += ", ? CLVL" + CRLF
					lSelCLVL    := .T.
				EndIf
				If cArqBase $ 'CV0' .And. cEnt05 != Nil
					cCpoTot    += ",ENT05"
					cCpoTotVal += ", ? ENT05" + CRLF
					lSelEnt05   := .T.
				EndIf
			Else
				If cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
					cCpoTot    += ",CCUSTO"
					cCpoTotVal += ", ? CCUSTO" + CRLF
					lSelCCusto  := .T.
				EndIf
				If cArqBase $ 'CTD/CTH' .And. cItem != Nil
					cCpoTot    += ",ITEM"
					cCpoTotVal += ", ? ITEM" + CRLF
					lSelItem    := .T.
				EndIf
				If cArqBase $ 'CTH' .And. cClasse != Nil
					cCpoTot    += ",CLVL"
					cCpoTotVal += ", ? CLVL" + CRLF
					lSelCLVL    := .T.
				EndIf
			EndIf

		Else
			cCpoTot    += ",IDENT, CODIGO"
			cCpoTotVal += ", ? IDENT"  + CRLF
			cCpoTotVal += ", ? CODIGO" + CRLF
			lSelIdent   := .T.
			lSelCodigo  := .T.
		EndIf

		/* --------- WHERE base com bind (serve para Q3 e Q2) --------- */
		cWhereDia := cTabDia + "_FILIAL = ?" + CRLF
		cWhereMes := cTabMes + "_FILIAL = ?" + CRLF

		If cArqBase != "CTU"
			If cConta != Nil
				cWhereDia += "AND " + cTabDia + "_CONTA  = ?" + CRLF
				cWhereMes += "AND " + cTabMes + "_CONTA  = ?" + CRLF
			EndIf

			If lEntidad05
				If cArqBase $ 'CTT/CTD/CTH/CV0' .And. cCCusto != Nil
					cWhereDia += "AND " + cTabDia + "_CCUSTO = ?" + CRLF
					cWhereMes += "AND " + cTabMes + "_CCUSTO = ?" + CRLF
				EndIf
				If cArqBase $ 'CTD/CTH/CV0' .And. cItem != Nil
					cWhereDia += "AND " + cTabDia + "_ITEM   = ?" + CRLF
					cWhereMes += "AND " + cTabMes + "_ITEM   = ?" + CRLF
				EndIf
				If cArqBase $ 'CTH/CV0' .And. cClasse != Nil
					cWhereDia += "AND " + cTabDia + "_CLVL   = ?" + CRLF
					cWhereMes += "AND " + cTabMes + "_CLVL   = ?" + CRLF
				EndIf
				If cArqBase $ 'CV0' .And. cEnt05 != Nil
					cWhereDia += "AND " + cTabDia + "_ENT05  = ?" + CRLF
					cWhereMes += "AND " + cTabMes + "_ENT05  = ?" + CRLF
				EndIf
			Else
				If cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
					cWhereDia += "AND " + cTabDia + "_CCUSTO = ?" + CRLF
					cWhereMes += "AND " + cTabMes + "_CCUSTO = ?" + CRLF
				EndIf
				If cArqBase $ 'CTD/CTH' .And. cItem != Nil
					cWhereDia += "AND " + cTabDia + "_ITEM   = ?" + CRLF
					cWhereMes += "AND " + cTabMes + "_ITEM   = ?" + CRLF
				EndIf
				If cArqBase $ 'CTH' .And. cClasse != Nil
					cWhereDia += "AND " + cTabDia + "_CLVL   = ?" + CRLF
					cWhereMes += "AND " + cTabMes + "_CLVL   = ?" + CRLF
				EndIf
			EndIf
		Else
			cWhereDia += "AND " + cTabDia + "_IDENT  = ?" + CRLF
			cWhereDia += "AND " + cTabDia + "_CODIGO = ?" + CRLF
			cWhereMes += "AND " + cTabMes + "_IDENT  = ?" + CRLF
			cWhereMes += "AND " + cTabMes + "_CODIGO = ?" + CRLF
		EndIf

		cWhereDia += "AND " + cTabDia + "_MOEDA = ?" + CRLF
		cWhereMes += "AND " + cTabMes + "_MOEDA = ?" + CRLF

		If !lTpSldIn
			cWhereDia += "AND " + cTabDia + "_TPSALD = ?" + CRLF
			cWhereMes += "AND " + cTabMes + "_TPSALD = ?" + CRLF
		Else
			cWhereDia += "AND " + cTabDia + "_TPSALD IN (?)" + CRLF
			cWhereMes += "AND " + cTabMes + "_TPSALD IN (?)" + CRLF
		EndIf

		cWhereDia += "AND D_E_L_E_T_ = ?" + CRLF
		cWhereMes += "AND D_E_L_E_T_ = ?" + CRLF

		cWherDtDia := cWhereDia + ;
			"AND " + cTabDia + "_DATA >= ?" + CRLF + ;
			"AND " + cTabDia + "_DATA <= ?" + CRLF

		cWherDtMes := cWhereMes + ;
			"AND " + cTabMes + "_DATA <= ?" + CRLF

		cQuery := "WITH" + CRLF

		// --------- TABDIA  --------- 
		cQuery += "TABDIA AS (" + CRLF
		cQuery += "  SELECT" + CRLF
		cQuery += "    SUM(CASE WHEN " + cTabDia + "_DATA =  ? THEN " + cTabDia + "_DEBITO ELSE 0 END) AS DEB_REF," + CRLF
		cQuery += "    SUM(CASE WHEN " + cTabDia + "_DATA =  ? THEN " + cTabDia + "_CREDIT ELSE 0 END) AS CRD_REF," + CRLF

		// anterior no mês: >= primeiro_dia AND < data_ref 
		cQuery += "    SUM(CASE WHEN " + cTabDia + "_DATA >= ? AND " + cTabDia + "_DATA <  ? THEN " + cTabDia + "_DEBITO ELSE 0 END) AS DEB_ANT_DIA," + CRLF
		cQuery += "    SUM(CASE WHEN " + cTabDia + "_DATA >= ? AND " + cTabDia + "_DATA <  ? THEN " + cTabDia + "_CREDIT ELSE 0 END) AS CRD_ANT_DIA," + CRLF

		// atual do mês: >= primeiro_dia AND <= data_ref 
		cQuery += "    SUM(CASE WHEN " + cTabDia + "_DATA >= ? AND " + cTabDia + "_DATA <= ? THEN " + cTabDia + "_DEBITO ELSE 0 END) AS DEB_ATU_DIA," + CRLF
		cQuery += "    SUM(CASE WHEN " + cTabDia + "_DATA >= ? AND " + cTabDia + "_DATA <= ? THEN " + cTabDia + "_CREDIT ELSE 0 END) AS CRD_ATU_DIA" + CRLF

		If lImpAntLP
			cQuery += "   ,SUM(CASE WHEN " + cTabDia + "_DATA >= ? AND " + cTabDia + "_DATA <= ? AND " + cTabDia + "_LP = ? AND " + cTabDia + "_DTLP = ? THEN " + cTabDia + "_DEBITO ELSE 0 END) AS DEB_LP_DIA" + CRLF
			cQuery += "   ,SUM(CASE WHEN " + cTabDia + "_DATA >= ? AND " + cTabDia + "_DATA <= ? AND " + cTabDia + "_LP = ? AND " + cTabDia + "_DTLP = ? THEN " + cTabDia + "_CREDIT ELSE 0 END) AS CRD_LP_DIA" + CRLF
		EndIf

		cQuery += "  FROM " + RetSqlName(cTabDia) + CRLF
		cQuery += "  WHERE " + cWherDtDia
		cQuery += ")," + CRLF

		// --------- TABMES  --------- 
		cQuery += "TABMES AS (" + CRLF
		cQuery += "  SELECT" + CRLF
		cQuery += "    SUM(" + cTabMes + "_DEBITO) AS DEB_MES," + CRLF
		cQuery += "    SUM(" + cTabMes + "_CREDIT) AS CRD_MES" + CRLF

		If lImpAntLP
			cQuery += "   ,SUM(CASE WHEN " + cTabMes + "_DATA <= ? AND " + cTabMes + "_LP = ? AND " + cTabMes + "_DTLP = ? THEN " + cTabMes + "_DEBITO ELSE 0 END) AS DEB_LP_MES" + CRLF
			cQuery += "   ,SUM(CASE WHEN " + cTabMes + "_DATA <= ? AND " + cTabMes + "_LP = ? AND " + cTabMes + "_DTLP = ? THEN " + cTabMes + "_CREDIT ELSE 0 END) AS CRD_LP_MES" + CRLF
		EndIf

		cQuery += "  FROM " + RetSqlName(cTabMes) + CRLF
		cQuery += "  WHERE " + cWherDtMes
		cQuery += ")" + CRLF

		cQuery += "SELECT" + CRLF
		cQuery += "  COALESCE(TABMES.DEB_MES,0) + COALESCE(TABDIA.DEB_ANT_DIA,0) AS SLDANTDEB," + CRLF
		cQuery += "  COALESCE(TABMES.CRD_MES,0) + COALESCE(TABDIA.CRD_ANT_DIA,0) AS SLDANTCRD," + CRLF
		cQuery += "  COALESCE(TABDIA.DEB_REF,0) AS SALDODEB," + CRLF
		cQuery += "  COALESCE(TABDIA.CRD_REF,0) AS SALDOCRD," + CRLF

		If lImpAntLP
			cQuery += "  COALESCE(TABMES.DEB_LP_MES,0) + COALESCE(TABDIA.DEB_LP_DIA,0) AS SALDODEBLP," + CRLF
			cQuery += "  COALESCE(TABMES.CRD_LP_MES,0) + COALESCE(TABDIA.CRD_LP_DIA,0) AS SALDOCRDLP," + CRLF
		Else
			cQuery += "  0 AS SALDODEBLP," + CRLF
			cQuery += "  0 AS SALDOCRDLP," + CRLF
		EndIf

		cQuery += "  COALESCE(TABMES.DEB_MES,0) + COALESCE(TABDIA.DEB_ATU_DIA,0) AS SALDODEBATU," + CRLF
		cQuery += "  COALESCE(TABMES.CRD_MES,0) + COALESCE(TABDIA.CRD_ATU_DIA,0) AS SALDOCRDATU" + CRLF

		cQuery += cCpoTotVal

		cQuery += "FROM TABDIA" + CRLF
		cQuery += "CROSS JOIN TABMES" + CRLF

		If !Empty(cCpoTot)
			cQuery += "ORDER BY " + CRLF
			cQuery += Right(cCpoTot, Len(cCpoTot)-1) + CRLF
		EndIf

		oQrySldCQ := FWExecStatement():New(cQuery)
	EndIf

	// 1) TABDIA: (DEB_REF)
	oQrySldCQ:SetString(nParam++, cDataRef)
	//(CRD_REF)
	oQrySldCQ:SetString(nParam++, cDataRef)

	//(DEB_ANT_DIA)
	oQrySldCQ:SetString(nParam++, cPrimeiro)
	oQrySldCQ:SetString(nParam++, cDataRef)

	//(CRD_ANT_DIA)
	oQrySldCQ:SetString(nParam++, cPrimeiro)
	oQrySldCQ:SetString(nParam++, cDataRef)

	// (DEB_ATU_DIA)
	oQrySldCQ:SetString(nParam++, cPrimeiro)
	oQrySldCQ:SetString(nParam++, cDataRef)

	//(CRD_ATU_DIA)
	oQrySldCQ:SetString(nParam++, cPrimeiro)
	oQrySldCQ:SetString(nParam++, cDataRef)

	If lImpAntLP
		// DEB_LP_DIA 
		oQrySldCQ:SetString(nParam++, cPrimeiro)   // >=
		oQrySldCQ:SetString(nParam++, cDataRef)    // <=
		oQrySldCQ:SetString(nParam++, "Z")         // LP
		oQrySldCQ:SetString(nParam++, DTOS(dDataLP))// DTLP

		// CRD_LP_DIA 
		oQrySldCQ:SetString(nParam++, cPrimeiro)   // >=
		oQrySldCQ:SetString(nParam++, cDataRef)    // <=
		oQrySldCQ:SetString(nParam++, "Z")         // LP
		oQrySldCQ:SetString(nParam++, DTOS(dDataLP))// DTLP
	EndIf

	// 2) TABDIA: WHERE comum + datas do WHERE
	nParam := BindWhere( nParam, cFilEsp, cMoeda, cTpSald,cArqBase, cConta, cCCusto, cItem, cClasse, lEntidad05, cEnt05, cIdent, cCodigo )
	
	oQrySldCQ:SetString(nParam++, cPrimeiro)   // WHERE TABDIA: >= cPrimeiro
	oQrySldCQ:SetString(nParam++, cDataRef)    // WHERE TABDIA: <= cDataRef

	// 3) TABMES — ORDEM DOS BINDS
	If lImpAntLP
		//DEB_LP_MES
		oQrySldCQ:SetString(nParam++, cDataAnt)      // CQ2_DATA <= ?
		oQrySldCQ:SetString(nParam++, "Z")           // CQ2_LP = ?
		oQrySldCQ:SetString(nParam++, DTOS(dDataLP)) // CQ2_DTLP = ?
		// CRD_LP_MES
		oQrySldCQ:SetString(nParam++, cDataAnt)      // CQ2_DATA <= ?
		oQrySldCQ:SetString(nParam++, "Z")           // CQ2_LP = ?
		oQrySldCQ:SetString(nParam++, DTOS(dDataLP)) // CQ2_DTLP = ?
	EndIf

	// DEPOIS: WHERE comum do TABMES + data <= cDataAnt 
	nParam := BindWhere( nParam, cFilEsp, cMoeda, cTpSald, ;
							cArqBase, cConta, cCCusto, cItem, cClasse, lEntidad05, ;
							cEnt05, cIdent, cCodigo )
	oQrySldCQ:SetString(nParam++, cDataAnt)          // WHERE TABMES: CQ2_DATA <= cDataAnt


	// 4) Literais do SELECT (cCpoTotVal) — na MESMA ordem

	nParam := BindKeys( nParam, .T., cArqBase, cConta, cCCusto, cItem, cClasse, ;
						lEntidad05, cEnt05, cIdent, cCodigo )

	cTRB := oQrySldCQ:OpenAlias(GetNextAlias())
	
	TcSetField(cTRB,"SLDANTDEB"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SLDANTCRD"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDODEB"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDOCRD"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDODEBLP"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDOCRDLP"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDODEBATU"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDOCRDATU"  ,"N",aTamVlr[1],aTamVlr[2])
	
	If (cTRB)->(!EOF())
		
		lAchouNoDia := dDataNew == dData
		
		nAtuDeb		:= (cTRB)->SALDODEBATU
		nAtuCrd		:= (cTRB)->SALDOCRDATU
		nDebLP			:= (cTRB)->SALDODEBLP
		nCrdLP			:= (cTRB)->SALDOCRDLP
		
		IF lAchouNoDia						//Se achou saldo na data solicitada
			nAntDeb		:= (cTRB)->SLDANTDEB
			nAntCrd		:= (cTRB)->SLDANTCRD
			nDebito		:= (cTRB)->SALDODEB
			nCredito		:= (cTRB)->SALDOCRD
		Else
			nAntDeb		:= nAtuDeb 	
			nAntCrd		:= nAtuCrd  
		EndIf
				
		If lImpAntLP
			nAntDeb -= nDebLP
			nAntCrd -= nCrdLP
			nAtuDeb -= nDebLP
			nAtuCrd -= nCrdLP
		EndIf

		nSaldoAnt		:= nAntCrd - nAntDeb 
		nSaldoAtu		:= nAtuCrd - nAtuDeb
	EndIf
	If Select(cTRB) > 0
		dbSelectArea(cTRB)
		(cTRB)->(dbCloseArea())
	Endif

EndIf


RestArea(aArea)
aSize(aArea,0)
aArea := nil 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                             ³
//³ [1] Saldo Atual (com sinal)                          ³
//³ [2] Debito na Data                                   ³
//³ [3] Credito na Data                                  ³
//³ [4] Saldo Atual Devedor                              ³
//³ [5] Saldo Atual Credor                               ³
//³ [6] Saldo Anterior (com sinal)                       ³
//³ [7] Saldo Anterior Devedor                           ³
//³ [8] Saldo Anterior Credor                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]
Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} GetDtMaxCQ
Retorna a ultima data com dados para a tabela.

@author Alvaro Camillo Neto

@param cArqBase 	Arquivo Base para o saldo ( CT1 - Conta , CTT - Centro de Custo, CTD - Item Contábil , CTH - Classe de Valor, CTU - Saldo por entidade )
@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cIdent 	Identificador da Tabela
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo 
@param cTipo   	Tipo de data 1- Data do saldo - 2 - Data de Apuração                       

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function GetDtMaxCQ(cArqBase as character,cConta as character,cCCusto as character,cItem as character,cClasse as character,cIdent as character,dData as date,cMoeda as character,cTpSald as character,cFilEsp as character,cTipo as character,cEnt05 as character) as date

Local dDataMax 	as date
Local cCodigo	as character
Local cQuery	as character
Local cTabDia	as character
Local aArea		as array
Local nSeq		:= 1

dDataMax 	:= STOD("")
cCodigo		:= ""
cQuery		:= ""
cTabDia		:= ""
aArea		:= GetArea()

DEFAULT cArqBase	:= ""
DEFAULT cConta  	:= Nil
DEFAULT cCCusto  	:= Nil
DEFAULT cItem  		:= Nil
DEFAULT cClasse  	:= Nil
DEFAULT cIdent		:= ""
DEFAULT dData		:= STOD("")
DEFAULT cMoeda		:= ""
DEFAULT cTpSald		:= "1"
DEFAULT cFilEsp 	:= xFilial("CT2")
DEFAULT cTipo	  	:= '1'
DEFAULT cEnt05  	:= Nil


If lKeyDif .or. cArqBase  $ "CTU/CQ8/CQ9"
	If cArqBase $ "CT1/CT7/CQ0/CQ1"
		dbSelectArea("CQ1")
		cTabDia := "CQ1"
	ElseIf cArqBase $ "CTT/CT3/CQ2/CQ3"
		dbSelectArea("CQ3")
		cTabDia := "CQ3"
	ElseIf cArqBase $ "CTD/CT4/CQ4/CQ5"
		dbSelectArea("CQ5")
		cTabDia := "CQ5"
	ElseIf cArqBase $ "CTH/CTI/CQ6/CQ7"
		dbSelectArea("CQ7")
		cTabDia := "CQ7"
	ElseIf cArqBase  $ "CTU/CQ8/CQ9"
		dbSelectArea("CQ8")
		cTabDia := "CQ9"
		If cIdent == "CTT"
			cCodigo := cCCusto
		ElseIf cIdent == "CTD"
			cCodigo := cItem
		ElseIf cIdent == "CTH"
			cCodigo := cClasse
		ElseIf lEntidad05 .And. cIdent $ "CV0/QL6/QL7"
			cIdent := "CV0"
			cCodigo := Left( cEnt05 , Len(CQ8->CQ8_CODIGO) )
		EndIf
	ElseIf lEntidad05 .And. cArqBase $ "CV0/QL6/QL7"
		cArqBase := "CV0"
		If cEnt05 != Nil
			cEnt05 := Left( cEnt05 , Len(QL6->QL6_ENT05) )
		EndIf
		dbSelectArea("QL7")
		cTabDia := "QL7"
	EndIf
	RetQryMax(cFilEsp,cTipo,cTabDia,cArqBase,cConta,cCCusto,cItem,cClasse,cEnt05,lEntidad05)
EndIf

oQueryQry:SetString(nSeq++,	cFilEsp)
If cArqBase != "CTU"
	If cConta!= Nil
		oQueryQry:SetString(nSeq++,	cConta)
	EndIf
	If lEntidad05
		If  cArqBase $ 'CTT/CTD/CTH/CV0' .And. cCCusto!= Nil
			oQueryQry:SetString(nSeq++,	cCCusto)
		EndIf
		If  cArqBase $ 'CTD/CTH/CV0' .And. cItem!= Nil
			oQueryQry:SetString(nSeq++,	cItem)
		EndIf
		If  cArqBase $ 'CTH/CV0' .And. cClasse!= Nil
			oQueryQry:SetString(nSeq++,	cClasse)
		EndIf
		If  cArqBase $ 'CV0' .And. cEnt05 != Nil
			oQueryQry:SetString(nSeq++,	cEnt05)
		EndIf
	Else
		If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto!= Nil
			oQueryQry:SetString(nSeq++,	cCCusto)
		EndIf
		If  cArqBase $ 'CTD/CTH' .And. cItem!= Nil
			oQueryQry:SetString(nSeq++,	cItem)
		EndIf
		If  cArqBase $ 'CTH' .And. cClasse!= Nil
			oQueryQry:SetString(nSeq++,	cClasse)
		EndIf
	EndIf
Else
	oQueryQry:SetString(nSeq++,	cIdent)
	oQueryQry:SetString(nSeq++,	cCodigo)
EndIf

oQueryQry:SetString(nSeq++,	cMoeda)

If !lTpSldIn
	oQueryQry:SetString(nSeq++,	cTpSald)
Else
	oQueryQry:SetUnsafe(nSeq++,	cTpSald)
EndIf
oQueryQry:SetString(nSeq++,	DTOS(dData))

oQueryQry:SetString(nSeq++,	Space(1))

dDataMax := oQueryQry:ExecScalar('DATAMAX')  
dDataMax := Stod(dDataMax)
	
RestArea(aArea)
aSize(aArea,0)
aArea := nil 

Return dDataMax

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoTotCQ
Retorna os saldos do intervalo da entidade ate a Entidade 	

@author Alvaro Camillo Neto

@param cArqBase 	Arquivo Base para o saldo ( CT1 - Conta , CTT - Centro de Custo, CTD - Item Contábil , CTH - Classe de Valor, CTU - Saldo por entidade )
@param cContaIni 	Conta Contábil Inicial
@param cContaFim 	Conta Contábil Final
@param cCCustoIni 	Centro de Custo Inicial
@param cCCustoFim 	Centro de Custo Final
@param cItemIni 		Item contábil Inicial
@param cItemFim 		Item contábil Final
@param cClasseIni 	Classe Contábil Inicial
@param cClasseFim 	Classe Contábil Final
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo                       
@param cRotina 	Reservado		           
@param lImpAntLP 	Flag para indicar se imprime antes do Lucro/Perdas
@param dDataLP 	Data de Lucro/Perdas                      
@param cFilArq 	Filial do Arquivo	


   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function SaldoTotCQ(cArqBase as Character,cContaIni as Character,cContaFim as Character,cCCustoIni as Character,cCCustoFim as Character,cItemIni as Character,cItemFim as Character,cClasseIni as Character,cClasseFim as Character,dData as Date,;
cMoeda as Character,cTpSald as Character,lImpAntLP as Logical,dDataLP as Date,aSelFil as Array,lRecDesp0 as Logical,cRecDesp as Character,dDtZeraRD as Date,lTodasFil as Logical,cModEsc as Character) as Array

Local aArea			as Array
Local nSaldoAtu		as Numeric
Local nDebito 		as Numeric
Local nCredito		as Numeric
Local nAtuDeb		as Numeric
Local nAtuCrd		as Numeric
Local nSaldoAnt		as Numeric
Local nAntDeb		as Numeric
Local nAntCrd		as Numeric
Local cQuery		as Character
Local nCont			as Numeric
Local nTamRecDes	as Numeric
Local cQryFilDia	as Character
Local cQryFilMes	as Character
Local cTipoSaldo	as Character
Local aTamVlr		as Array
Local cMesTmpFil	as Character
Local cDiaTmpFil	as Character
Local cTabMes		as Character
Local cTabDia		as Character
Local cTrb			as Character
Local cIsNull		as Character
Local cTipoDB		as Character

Default cArqBase	:= ""
Default cContaIni	:= ""
Default cContaFim	:= ""
Default cCCustoIni	:= ""
Default cCCustoFim	:= ""
Default cItemIni	:= ""
Default cItemFim	:= ""
Default cClasseIni	:= ""
Default cClasseFim	:= ""
Default dData		:= CTOD("  /  /  ")			
Default cMoeda		:= ""
Default cTpSald     := Iif(Empty(cTpSald),"1",cTpSald)
Default lImpAntLp   := .F.
Default dDataLp     := CTOD("  /  /  ")
Default aSelFil     := {}
Default lRecDesp0   := .F.
Default cRecDesp    := ""
Default dDtZeraRD   := CTOD("  /  /  ")
Default lTodasFil   := .F.
Default cModEsc     := ""

aArea				:= GetArea()
nSaldoAtu			:= 0
nDebito 			:= 0
nCredito			:= 0
nAtuDeb				:= 0
nAtuCrd				:= 0
nSaldoAnt			:= 0
nAntDeb				:= 0
nAntCrd				:= 0
cQuery				:= ""
nCont				:= 0 
nTamRecDes			:= Len(Alltrim(cRecDesp))
cQryFilDia			:= ''
cQryFilMes			:= ''
cTipoSaldo			:= ""
aTamVlr				:= TamSX3("CT2_VALOR")
cMesTmpFil			:= ""
cDiaTmpFil			:= ""
cTabMes				:= ""
cTabDia				:= ""
cTrb				:= GetNextAlias()
cIsNull				:= ""
cTipoDB				:= Alltrim(Upper(TCGetDB()))

//-------------------------------------------------------
// Tratamento realizado devido ausência se ChangeQuery() 
//-------------------------------------------------------
If ("INFORMIX" $ cTipoDB) .Or. ("ORACLE" $ cTipoDB)
	cIsNull  := " NVL"
ElseIf ("DB2" $ cTipoDB)  .Or. ("POSTGRES" $ cTipoDB)
	cIsNull := " COALESCE"
Else
	cIsNull := " ISNULL"
EndIf
 

cTipoSaldo := IIF(cModEsc == 'ECF', cTpSald,FormatIn(cTpSald,";"))

If lRecDesp0 .And. ( Empty(cRecDesp) .Or. Empty(dDtZeraRD) )
	lRecDesp0 := .F.
EndIf

If cArqBase $ "CT1/CT7"
	cArqBase := "CT1"
	dbSelectArea("CQ0")
	dbSelectArea("CQ1")
	cTabMes := "CQ0"
	cTabDia := "CQ1"
ElseIf cArqBase $ "CTT/CT3"
	cArqBase := "CTT"
	dbSelectArea("CQ2")
	dbSelectArea("CQ3")
	cTabMes := "CQ2"
	cTabDia := "CQ3"
ElseIf cArqBase$ "CTD/CT4"
	cArqBase := "CTD"
	dbSelectArea("CQ4")
	dbSelectArea("CQ5")
	cTabMes := "CQ4"
	cTabDia := "CQ5"
ElseIf cArqBase $ "CTH/CTI"
	cArqBase := "CTH"
	dbSelectArea("CQ6")
	dbSelectArea("CQ7")
	cTabMes := "CQ6"
	cTabDia := "CQ7"
EndIf

//³ Tratativa para o filtro de filiais           ³

cQryFilDia := GetRngFil( aSelFil,cTabMes, .T., @cMesTmpFil)
cQryFilMes := GetRngFil( aSelFil,cTabDia, .T., @cDiaTmpFil)

cQuery +=     " SELECT " +CRLF

cQuery +=     " " + cIsNull + "(SUM(SLDANTDEB),0) SLDANTDEB, " +CRLF
cQuery +=     " " + cIsNull + "(SUM(SLDANTCRD),0) SLDANTCRD, " +CRLF
cQuery +=     " " + cIsNull + "(SUM(SALDODEB),0) SALDODEB, " +CRLF
cQuery +=     " " + cIsNull + "(SUM(SALDOCRD),0) SALDOCRD " +CRLF
cQuery +=     " FROM    " +CRLF
cQuery +=     " ( " +CRLF
//		---------- Saldo atual ------

cQuery +=       " SELECT " +CRLF
cQuery +=          " " + cIsNull + "(SUM("+cTabDia+"_DEBITO),0) SALDODEB, " +CRLF
cQuery +=          " " + cIsNull + "(SUM("+cTabDia+"_CREDIT),0) SALDOCRD, " +CRLF
cQuery +=          " 0 SLDANTDEB, " +CRLF
cQuery +=          " 0 SLDANTCRD  " +CRLF
cQuery +=      " FROM "+RetSqlName(cTabDia) +CRLF
cQuery +=      " WHERE " +CRLF
cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF

If !lTodasFil
	cQuery +=          " AND "+cTabDia+"_FILIAL " + cQryFilDia
EndIf

If cContaIni != Nil .And. cContaFim != Nil 
	cQuery +=   " AND "+cTabDia+"_CONTA >= '"+cContaIni+"' " +CRLF
	cQuery +=   " AND "+cTabDia+"_CONTA <= '"+cContaFim+"' " +CRLF
EndIf

If cCCustoIni != Nil .And. cCCustoFim != Nil 
	If  cArqBase $ 'CTT/CTD/CTH'
		cQuery +=   " AND "+cTabDia+"_CCUSTO >= '"+cCCustoIni+"' " +CRLF
		cQuery +=   " AND "+cTabDia+"_CCUSTO <= '"+cCCustoFim+"' " +CRLF
	EndIf
EndIf

If cItemIni != Nil .And. cItemFim != Nil
	If  cArqBase $ 'CTD/CTH'
		cQuery +=   " AND "+cTabDia+"_ITEM >= '"+cItemIni+"' " +CRLF
		cQuery +=   " AND "+cTabDia+"_ITEM <= '"+cItemFim+"' " +CRLF
	EndIf
EndIf

If cClasseIni != Nil .And. cClasseFim != Nil
	If  cArqBase $ 'CTH'
		cQuery +=   " AND "+cTabDia+"_CLVL >= '"+cClasseIni+"'" +CRLF
		cQuery +=   " AND "+cTabDia+"_CLVL <= '"+cClasseFim+"'" +CRLF
	EndIf
EndIf

cQuery +=          " AND "+cTabDia+"_MOEDA = '"+cMoeda+"' " +CRLF
If cModEsc == 'ECF'
	cQuery +=          " AND "+cTabDia+"_TPSALD IN ("+cTipoSaldo+") " +CRLF
Else
	cQuery +=          " AND "+cTabDia+"_TPSALD IN "+cTipoSaldo +CRLF
Endif
cQuery +=          " AND "+cTabDia+"_DATA = '"+DTOS(dData)+"' " +CRLF
If lImpAntLP
	cQuery +=      "  AND ("+cTabDia+"_LP <> 'Z' OR ("+cTabDia+"_LP = 'Z' AND "+cTabDia+"_DTLP <> ' ' AND "+cTabDia+"_DTLP <> '' AND "+cTabDia+"_DTLP < '"+DTOS(dDataLP)+"')) "  +CRLF
Endif
//------------------------------------------ Saldo anterior ------------------------------------
//------------------------------Mensal----------------------------------
cQuery +=       " UNION ALL	 " +CRLF

cQuery +=       " SELECT  " +CRLF
cQuery +=          " 0 SALDODEB, " +CRLF
cQuery +=          " 0 SALDOCRD, " +CRLF
cQuery +=          " " + cIsNull + "(SUM("+cTabMes+"_DEBITO),0) SLDANTDEB, " +CRLF
cQuery +=          " " + cIsNull + "(SUM("+cTabMes+"_CREDIT),0) SLDANTCRD " +CRLF
cQuery +=       " FROM " + RetSqlName(cTabMes) +CRLF
cQuery +=       " WHERE " +CRLF

cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF

If !lTodasFil
	cQuery +=          " AND "+cTabMes+"_FILIAL " + cQryFilMes
EndIf

If cContaIni != Nil .And. cContaFim != Nil 
	cQuery +=   " AND "+cTabMes+"_CONTA >= '"+cContaIni+"' " +CRLF
	cQuery +=   " AND "+cTabMes+"_CONTA <= '"+cContaFim+"' " +CRLF
EndIf

If cCCustoIni != Nil .And. cCCustoFim != Nil 
	If  cArqBase $ 'CTT/CTD/CTH'
		cQuery +=   " AND "+cTabMes+"_CCUSTO >= '"+cCCustoIni+"' " +CRLF
		cQuery +=   " AND "+cTabMes+"_CCUSTO <= '"+cCCustoFim+"' " +CRLF
	EndIf
EndIf

If cItemIni != Nil .And. cItemFim != Nil
	If  cArqBase $ 'CTD/CTH'
		cQuery +=   " AND "+cTabMes+"_ITEM >= '"+cItemIni+"' " +CRLF
		cQuery +=   " AND "+cTabMes+"_ITEM <= '"+cItemFim+"' " +CRLF
	EndIf
EndIf

If cClasseIni != Nil .And. cClasseFim != Nil
	If  cArqBase $ 'CTH'
		cQuery +=   " AND "+cTabMes+"_CLVL >= '"+cClasseIni+"'" +CRLF
		cQuery +=   " AND "+cTabMes+"_CLVL <= '"+cClasseFim+"'" +CRLF
	EndIf
EndIf

cQuery +=          " AND "+cTabMes+"_MOEDA = '"+cMoeda+"' " +CRLF
If cModEsc == 'ECF'
	cQuery +=          " AND "+cTabMes+"_TPSALD IN ("+ cTipoSaldo+") " +CRLF
Else
	cQuery +=          " AND "+cTabMes+"_TPSALD IN " + cTipoSaldo +CRLF
Endif
cQuery +=          " AND "+cTabMes+"_DATA <= '"+DTOS(FirstDay(dData)-1)+"' " +CRLF

If !lImpAntLP .And. lRecDesp0 
	For nCont	:= 1 to nTamRecDes
		If nCont == 1
			cQuery += "	 			AND ( ("+cTabMes+"_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"
		Else
			cQuery += "	 			AND  ("+cTabMes+"_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"
		EndIf
	Next
	cQuery += " OR "
	cQuery += " ( "
	For nCont	:= 1 to nTamRecDes
		If nTamRecDes == 1
			cQuery += " ( "+cTabMes+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%')  AND "
		Else
			If nCont == 1
				cQuery += " ( "+cTabMes+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%' OR "
			ElseIf nCont < nTamRecDes
				cQuery += "  "+cTabMes+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%' OR "
			ElseIf nCont == nTamRecDes
				cQuery += " "+cTabMes+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%') AND "
			EndIf
		EndIf
	Next
	cQuery += " "+cTabMes+"_DATA > '" +DTOS(dDtZeraRD)+"') "
	cQuery += " ) "
EndIf

If lImpAntLP
	cQuery += "  AND ("+cTabMes+"_LP <> 'Z' OR ("+cTabMes+"_LP = 'Z' AND "+cTabMes+"_DTLP <> ' ' AND "+cTabMes+"_DTLP <> '' AND "+cTabMes+"_DTLP < '"+DTOS(dDataLP)+"')) "
Endif


//-------------------------Diario Posterior--------------------------------------
cQuery +=   " UNION ALL " +CRLF

cQuery +=       " SELECT " +CRLF

cQuery +=          " 0 SALDODEB, " +CRLF
cQuery +=          " 0 SALDOCRD, " +CRLF
cQuery +=          " " + cIsNull + "(SUM("+cTabDia+"_DEBITO),0) SLDANTDEB, " +CRLF
cQuery +=          " " + cIsNull + "(SUM("+cTabDia+"_CREDIT),0) SLDANTCRD  " +CRLF
cQuery +=      " FROM "+RetSqlName(cTabDia) +CRLF
cQuery +=      " WHERE " +CRLF

cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF

If !lTodasFil
	cQuery +=          " AND "+cTabDia+"_FILIAL " + cQryFilDia
EndIf

If cContaIni != Nil .And. cContaFim != Nil 
	cQuery +=   " AND "+cTabDia+"_CONTA >= '"+cContaIni+"' " +CRLF
	cQuery +=   " AND "+cTabDia+"_CONTA <= '"+cContaFim+"' " +CRLF
EndIf

If cCCustoIni != Nil .And. cCCustoFim != Nil 
	If  cArqBase $ 'CTT/CTD/CTH'
		cQuery +=   " AND "+cTabDia+"_CCUSTO >= '"+cCCustoIni+"' " +CRLF
		cQuery +=   " AND "+cTabDia+"_CCUSTO <= '"+cCCustoFim+"' " +CRLF
	EndIf
EndIf

If cItemIni != Nil .And. cItemFim != Nil
	If  cArqBase $ 'CTD/CTH'
		cQuery +=   " AND "+cTabDia+"_ITEM >= '"+cItemIni+"' " +CRLF
		cQuery +=   " AND "+cTabDia+"_ITEM <= '"+cItemFim+"' " +CRLF
	EndIf
EndIf

If cClasseIni != Nil .And. cClasseFim != Nil
	If  cArqBase $ 'CTH'
		cQuery +=   " AND "+cTabDia+"_CLVL >= '"+cClasseIni+"'" +CRLF
		cQuery +=   " AND "+cTabDia+"_CLVL <= '"+cClasseFim+"'" +CRLF
	EndIf
EndIf

cQuery +=          " AND "+cTabDia+"_MOEDA = '"+cMoeda+"' " +CRLF
If cModEsc == 'ECF'
	cQuery +=          " AND "+cTabDia+"_TPSALD IN ("+cTipoSaldo+")" +CRLF
Else
	cQuery +=          " AND "+cTabDia+"_TPSALD IN "+cTipoSaldo +CRLF
Endif

cQuery +=          " AND "+cTabDia+"_DATA >= '"+DTOS(FirstDay(dData))+"' " +CRLF
cQuery +=          " AND "+cTabDia+"_DATA < '"+DTOS(dData)+"' " +CRLF

If !lImpAntLP .And. lRecDesp0 
	For nCont	:= 1 to nTamRecDes
		If nCont == 1
			cQuery += "	 			AND ( ("+cTabDia+"_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"
		Else
			cQuery += "	 			AND  ("+cTabDia+"_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"
		EndIf
	Next
	cQuery += " OR "
	cQuery += " ( "
	For nCont	:= 1 to nTamRecDes
		If nTamRecDes == 1
			cQuery += " ( "+cTabDia+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%')  AND "
		Else
			If nCont == 1
				cQuery += " ( "+cTabDia+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%' OR "
			ElseIf nCont < nTamRecDes
				cQuery += "  "+cTabDia+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%' OR "
			ElseIf nCont == nTamRecDes
				cQuery += " "+cTabDia+"_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%') AND "
			EndIf
		EndIf
	Next
	cQuery += " "+cTabDia+"_DATA > '" +DTOS(dDtZeraRD)+"') "
	cQuery += " ) "
EndIf

If lImpAntLP
	cQuery += "  AND ("+cTabDia+"_LP <> 'Z' OR ("+cTabDia+"_LP = 'Z' AND "+cTabDia+"_DTLP <> ' ' AND "+cTabDia+"_DTLP <> '' AND "+cTabDia+"_DTLP < '"+DTOS(dDataLP)+"')) "
Endif

cQuery +="		) SALDO " +CRLF


cQuery := ChangeQuery(cQuery)		


If Select(cTRB) > 0
	dbSelectArea(cTRB)
	(cTRB)->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRB,.T.,.F.)

TcSetField(cTRB,"SLDANTDEB"  ,"N",aTamVlr[1],aTamVlr[2])
TcSetField(cTRB,"SLDANTCRD"  ,"N",aTamVlr[1],aTamVlr[2])
TcSetField(cTRB,"SALDODEB"  ,"N",aTamVlr[1],aTamVlr[2])
TcSetField(cTRB,"SALDOCRD"  ,"N",aTamVlr[1],aTamVlr[2])
// Movimentacao da data
nDebito	:= (cTRB)->SALDODEB
nCredito	:= (cTRB)->SALDOCRD

nAntDeb	:= (cTRB)->SLDANTDEB  
nAntCrd	:= (cTRB)->SLDANTCRD  

nAtuDeb := nAntDeb + nDebito
nAtuCrd := nAntCrd + nCredito

nSaldoAtu := nAtuCrd - nAtuDeb
nSaldoAnt := nAntCrd - nAntDeb

If Select(cTrb) > 0
	dbSelectArea(cTrb)
	(cTrb)->(dbCloseArea())
	CtbTmpErase(cMesTmpFil)
	CtbTmpErase(cDiaTmpFil)
Endif


RestArea(aArea)
aSize(aArea,0)
aArea := nil 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                             ³
//³ [1] Saldo Atual (com sinal)                          ³
//³ [2] Debito na Data                                   ³
//³ [3] Credito na Data                                  ³
//³ [4] Saldo Atual Devedor                              ³
//³ [5] Saldo Atual Credor                               ³
//³ [6] Saldo Anterior (com sinal)                       ³
//³ [7] Saldo Anterior Devedor                           ³
//³ [8] Saldo Anterior Credor                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]
Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCQPer
Retorna o saldo da entidade em um período

@author Alvaro Camillo Neto

@param cArqBase 	Arquivo Base para o saldo ( CT1 - Conta , CTT - Centro de Custo, CTD - Item Contábil , CTH - Classe de Valor, CTU - Saldo por entidade )
@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cIdent 	Identificador da Tabela
@param dDataIni	Data Inicial do Saldo
@param dDataFim	Data Final do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo                                 
@param lImpAntLP 	Flag para indicar se imprime antes do Lucro/Perdas
@param dDataLP 	Data de Lucro/Perdas                      
@param cFilEsp   Filial de busca
@param lUltDtVl Busca a ultima data de saldo válida


   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function SaldoCQPer(cArqBase,cConta,cCCusto,cItem,cClasse,cIdent,dDataIni,dDataFim,cMoeda,cTpSald,lImpAntLP,dDataLP,aSelFil,cArqCqM,cArqCqD)

Local nSaldoAtu	:= 0
Local nDebito		:= 0
Local nCredito	:= 0
Local nAtuDeb		:= 0
Local nAtuCrd		:= 0
Local nSaldoAnt	:= 0
Local nAntDeb		:= 0
Local nAntCrd		:= 0
Local cQuery		:= ""
Local cTabMes		:= ""
Local cTabDia		:= ""
Local cCodigo		:= ""
Local cCpoTot		:= ""
Local cCpoDia		:= ""
Local cCpoMes		:= ""
Local cGrpDia		:= ""
Local cGrpMes		:= ""
Local aTamVlr		:= TamSX3("CT2_VALOR")
Local aArea		:= GetArea()
Local nDebLP		:= 0
Local nCrdLP		:= 0
Local cTRB			:= GetNextAlias()
Local cQryFilDia	:= "" 
Local cQryFilMes	:= "" 
Local cMesTmpFil	:= ""
Local cDiaTmpFil	:= ""
Local cTabelaMes := ""
Local cTabelaDia := ""

DEFAULT aSelFil		:= {cFilAnt}
DEFAULT cConta 		:= Nil
DEFAULT cCCusto		:= Nil
DEFAULT cItem			:= Nil
DEFAULT cClasse		:= Nil
DEFAULT cIdent		:= ""
DEFAULT dDataIni		:= STOD("")
DEFAULT dDataFim		:= STOD("")
DEFAULT lImpAntLP    := .F.
DEFAULT dDataLP		:= STOD("")
DEFAULT cTpSald		:= "1"
DEFAULT cArqCqM      := Nil
DEFAULT cArqCqD      := Nil

If cArqBase $ "CT1/CT7"
	cArqBase := "CT1"
	dbSelectArea("CQ0")
	dbSelectArea("CQ1")
	cTabMes := "CQ0"
	cTabDia := "CQ1"
ElseIf cArqBase $ "CTT/CT3"
	cArqBase := "CTT"
	dbSelectArea("CQ2")
	dbSelectArea("CQ3")
	cTabMes := "CQ2"
	cTabDia := "CQ3"
ElseIf cArqBase $ "CTD/CT4"
	cArqBase := "CTD"
	dbSelectArea("CQ4")
	dbSelectArea("CQ5")
	cTabMes := "CQ4"
	cTabDia := "CQ5"
ElseIf cArqBase $ "CTH/CTI"
	cArqBase := "CTH"
	dbSelectArea("CQ6")
	dbSelectArea("CQ7")
	cTabMes := "CQ6"
	cTabDia := "CQ7"
	
ElseIf cArqBase == "CTU"
	dbSelectArea("CQ7")
	dbSelectArea("CQ8")
	cTabMes := "CQ8"
	cTabDia := "CQ9"
	If cIdent $ "CTT/CT3"
		cIdent := "CTT"
		cCodigo := cCCusto
	ElseIf cIdent $ "CTD/CT4"
		cIdent := "CTD"
		cCodigo := cItem
	ElseIf cIdent $ "CTH/CTI"
		cIdent := "CTH"
		cCodigo := cClasse
	EndIf
EndIf

/* --------------------------------------------------------------------------------
	cArqMes e cArqDia são diferentes de NIL quando chamado pela consolidação
   --------------------------------------------------------------------------------  */
cTabelaMes := If(cArqCqM == Nil, RetSqlName(cTabMes), cArqCqM )
cTabelaDia := If(cArqCqD == Nil, RetSqlName(cTabDia), cArqCqD )

//Tratativa para o filtro de filiais
cQryFilDia := GetRngFil( aSelFil,cTabMes, .T., @cMesTmpFil)
cQryFilMes := GetRngFil( aSelFil,cTabDia, .T., @cDiaTmpFil)

lMesmoMes := Month(dDataIni) == Month(dDataFim) .And. Year(dDataIni) == Year(dDataFim)

If !Empty(dDataIni) .Or. !Empty(dDataFim)
	If cArqBase != "CTU"
		If cConta != Nil
			cCpoTot  +=   ",CONTA " +CRLF
			cCpoDia  +=   ","+cTabDia+"_CONTA CONTA" +CRLF
			cCpoMes  +=   ","+cTabMes+"_CONTA CONTA" +CRLF
			cGrpDia  +=   ","+cTabDia+"_CONTA " +CRLF
			cGrpMes  +=   ","+cTabMes+"_CONTA " +CRLF
		EndIf
		If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
			cCpoTot +=   ",CCUSTO " +CRLF
			cCpoDia +=   ","+cTabDia+"_CCUSTO CCUSTO " +CRLF
			cCpoMes +=   ","+cTabMes+"_CCUSTO CCUSTO " +CRLF
			cGrpDia +=   ","+cTabDia+"_CCUSTO  " +CRLF
			cGrpMes +=   ","+cTabMes+"_CCUSTO  " +CRLF
		EndIf
		If  cArqBase $ 'CTD/CTH' .And. cItem != Nil
			cCpoTot +=   ",ITEM " +CRLF
			cCpoDia +=   ","+cTabDia+"_ITEM ITEM " +CRLF
			cCpoMes +=   ","+cTabMes+"_ITEM ITEM " +CRLF
			cGrpDia +=   ","+cTabDia+"_ITEM  " +CRLF
			cGrpMes +=   ","+cTabMes+"_ITEM  " +CRLF
		EndIf
		If  cArqBase $ 'CTH' .And. cItem != Nil
			cCpoTot +=   ",CLVL " +CRLF
			cCpoDia +=   ","+cTabDia+"_CLVL CLVL" +CRLF
			cCpoMes +=   ","+cTabMes+"_CLVL CLVL" +CRLF
			cGrpDia +=   ","+cTabDia+"_CLVL " +CRLF
			cGrpMes +=   ","+cTabMes+"_CLVL " +CRLF
		EndIf
	Else
		cCpoTot +=   ",IDENT " +CRLF
		cCpoTot +=   ",CODIGO " +CRLF
		cCpoDia +=   ","+cTabDia+"_IDENT IDENT " +CRLF
		cCpoDia +=   ", "+cTabDia+"_CODIGO CODIGO " +CRLF
		cCpoMes +=   ","+cTabMes+"_IDENT IDENT " +CRLF
		cCpoMes +=   ", "+cTabMes+"_CODIGO CODIGO " +CRLF
		cGrpDia +=   ","+cTabDia+"_IDENT  " +CRLF
		cGrpDia +=   ", "+cTabDia+"_CODIGO  " +CRLF
		cGrpMes +=   ","+cTabMes+"_IDENT  " +CRLF
		cGrpMes +=   ", "+cTabMes+"_CODIGO  " +CRLF
	EndIf
	
	
	cQuery +=     " SELECT " +CRLF
	
	cQuery +=     " ISNULL(SUM(SLDANTDEB),0) SLDANTDEB " +CRLF
	cQuery +=     " ,ISNULL(SUM(SLDANTCRD),0) SLDANTCRD " +CRLF
	cQuery +=     " ,ISNULL(SUM(SALDODEB),0) SALDODEB " +CRLF
	cQuery +=     " ,ISNULL(SUM(SALDOCRD),0) SALDOCRD " +CRLF
	cQuery +=     " ,ISNULL(SUM(SALDODEBLP),0) SALDODEBLP " +CRLF
	cQuery +=     " ,ISNULL(SUM(SALDOCRDLP),0) SALDOCRDLP " +CRLF
	cQuery +=     " "+cCpoTot+"  " +CRLF
	
	cQuery +=     " FROM    " +CRLF
	cQuery +=     " ( " +CRLF
	//		---------------------------- Saldo atual -----------------------------------------------
	
	//		----------------------------Diário Antes -----------------------------------------------
	cQuery +=       " SELECT " +CRLF
	cQuery +=          " ISNULL(SUM("+cTabDia+"_DEBITO),0) SALDODEB " +CRLF
	cQuery +=          " ,ISNULL(SUM("+cTabDia+"_CREDIT),0) SALDOCRD " +CRLF
	cQuery +=          " ,0 SLDANTDEB " +CRLF
	cQuery +=          " ,0 SLDANTCRD  " +CRLF
	cQuery +=          " ,0 SALDODEBLP " +CRLF
	cQuery +=          " ,0 SALDOCRDLP " +CRLF
	cQuery +=          " "+cCpoDia+"  " +CRLF
	
	cQuery +=      " FROM "+cTabelaDia +CRLF
	cQuery +=      " WHERE " +CRLF
	cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF
	cQuery +=          " AND "+cTabDia+"_FILIAL " + cQryFilDia
	If cArqBase != "CTU"
		If cConta != Nil
			cQuery +=   " AND "+cTabDia+"_CONTA = '"+cConta+"' " +CRLF
		EndIf
		If  cArqBase $ 'CTT/CTD/CTH' .And.  cCCusto != Nil
			cQuery +=   " AND "+cTabDia+"_CCUSTO = '"+cCCusto+"' " +CRLF
		EndIf
		If  cArqBase $ 'CTD/CTH'  .And.  cItem != Nil
			cQuery +=   " AND "+cTabDia+"_ITEM = '"+cItem+"' " +CRLF
		EndIf
		If  cArqBase $ 'CTH'  .And.  cClasse != Nil
			cQuery +=   " AND "+cTabDia+"_CLVL = '"+cClasse+"'" +CRLF
		EndIf
	Else
		cQuery +=   " AND "+cTabDia+"_IDENT = '"+cIdent+"' " +CRLF
		cQuery +=   " AND "+cTabDia+"_CODIGO = '"+cCodigo+"' " +CRLF
	EndIf
	
	cQuery +=          " AND "+cTabDia+"_MOEDA = '"+cMoeda+"' " +CRLF
	cQuery +=          " AND "+cTabDia+"_TPSALD = '"+cTpSald+"' " +CRLF
	cQuery +=          " AND "+cTabDia+"_DATA >= '"+DTOS(dDataIni)+"' " +CRLF
	
	If lMesmoMes
		cQuery +=          " AND "+cTabDia+"_DATA <= '"+DTOS(dDataFim)+"' " +CRLF
	Else
		cQuery +=          " AND "+cTabDia+"_DATA <= '"+DTOS(LastDay(dDataIni))+"' " +CRLF
	EndIf
	
	cQuery +=          " GROUP BY " +CRLF
	cQuery +=" "+Right(cGrpDia,Len(cGrpDia)-1)+"  " +CRLF
	
	If !lMesmoMes
		//------------------------------Mensal----------------------------------
		cQuery +=       " UNION ALL	 " +CRLF
		
		cQuery +=       " SELECT  " +CRLF
		
		cQuery +=          " ISNULL(SUM("+cTabMes+"_DEBITO),0) SALDODEB " +CRLF
		cQuery +=          " ,ISNULL(SUM("+cTabMes+"_CREDIT),0) SALDOCRD " +CRLF
		cQuery +=          " ,0 SLDANTDEB " +CRLF
		cQuery +=          " ,0 SLDANTCRD " +CRLF
		cQuery +=          " ,0 SALDODEBLP " +CRLF
		cQuery +=          " ,0 SALDOCRDLP " +CRLF
		cQuery +=          " "+cCpoMes+"  " +CRLF
		
		cQuery +=       " FROM " + cTabelaMes +CRLF
		cQuery +=       " WHERE " +CRLF
		cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF
		cQuery +=          " AND "+cTabMes+"_FILIAL " + cQryFilMes
		
		If cArqBase != "CTU"
			If cConta != Nil
				cQuery +=   " AND "+cTabMes+"_CONTA = '"+cConta+"' " +CRLF
			EndIf
			
			If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
				cQuery +=   " AND "+cTabMes+"_CCUSTO = '"+cCCusto+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTD/CTH' .And. cItem != Nil
				cQuery +=   " AND "+cTabMes+"_ITEM = '"+cItem+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTH' .And. cClasse != Nil
				cQuery +=   " AND "+cTabMes+"_CLVL = '"+cClasse+"'" +CRLF
			EndIf
		Else
			cQuery +=   " AND "+cTabMes+"_IDENT = '"+cIdent+"' " +CRLF
			cQuery +=   " AND "+cTabMes+"_CODIGO = '"+cCodigo+"' " +CRLF
		EndIf
		cQuery +=          " AND "+cTabMes+"_MOEDA = '"+cMoeda+"' " +CRLF
		cQuery +=          " AND "+cTabMes+"_TPSALD = '"+cTpSald+"' " +CRLF
		cQuery +=          " AND "+cTabMes+"_DATA >= '"+DTOS(LastDay(dDataIni)+1)+"' " +CRLF
		cQuery +=          " AND "+cTabMes+"_DATA <= '"+DTOS(FirstDay(dDataFim)-1)+"' " +CRLF
		
		cQuery +=          " GROUP BY " +CRLF
		
		cQuery +=" "+Right(cGrpMes,Len(cGrpMes)-1)+"  " +CRLF
		
		//-------------------------------------------Diário Posterior------------------------------------
		cQuery +=       " UNION ALL	 " +CRLF
		
		cQuery +=       " SELECT " +CRLF
		cQuery +=          " ISNULL(SUM("+cTabDia+"_DEBITO),0) SALDODEB " +CRLF
		cQuery +=          " ,ISNULL(SUM("+cTabDia+"_CREDIT),0) SALDOCRD " +CRLF
		cQuery +=          " ,0 SLDANTDEB " +CRLF
		cQuery +=          " ,0 SLDANTCRD  " +CRLF
		cQuery +=          " ,0 SALDODEBLP " +CRLF
		cQuery +=          " ,0 SALDOCRDLP " +CRLF
		cQuery +=          " "+cCpoDia+"  " +CRLF
		
		cQuery +=      " FROM "+cTabelaDia +CRLF
		cQuery +=      " WHERE " +CRLF
		cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF
		cQuery +=          " AND "+cTabDia+"_FILIAL " + cQryFilDia
		If cArqBase != "CTU"
			If cConta != Nil
				cQuery +=   " AND "+cTabDia+"_CONTA = '"+cConta+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTT/CTD/CTH' .And.  cCCusto != Nil
				cQuery +=   " AND "+cTabDia+"_CCUSTO = '"+cCCusto+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTD/CTH'  .And.  cItem != Nil
				cQuery +=   " AND "+cTabDia+"_ITEM = '"+cItem+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTH'  .And.  cClasse != Nil
				cQuery +=   " AND "+cTabDia+"_CLVL = '"+cClasse+"'" +CRLF
			EndIf
		Else
			cQuery +=   " AND "+cTabDia+"_IDENT = '"+cIdent+"' " +CRLF
			cQuery +=   " AND "+cTabDia+"_CODIGO = '"+cCodigo+"' " +CRLF
		EndIf
		
		cQuery +=          " AND "+cTabDia+"_MOEDA = '"+cMoeda+"' " +CRLF
		cQuery +=          " AND "+cTabDia+"_TPSALD = '"+cTpSald+"' " +CRLF
		cQuery +=          " AND "+cTabDia+"_DATA >= '"+DTOS(FirstDay(dDataFim))+"' " +CRLF
		cQuery +=          " AND "+cTabDia+"_DATA <= '"+DTOS(dDataFim)+"' " +CRLF
		
		cQuery +=          " GROUP BY " +CRLF
		cQuery +=" "+Right(cGrpDia,Len(cGrpDia)-1)+"  " +CRLF
		
		
	EndIf
	
	//------------------------------------------ Saldo anterior ------------------------------------
	//------------------------------Mensal----------------------------------
	cQuery +=       " UNION ALL	 " +CRLF
	
	cQuery +=       " SELECT  " +CRLF
	
	cQuery +=          " 0 SALDODEB " +CRLF
	cQuery +=          " ,0 SALDOCRD " +CRLF
	cQuery +=          " ,ISNULL(SUM("+cTabMes+"_DEBITO),0) SLDANTDEB " +CRLF
	cQuery +=          " ,ISNULL(SUM("+cTabMes+"_CREDIT),0) SLDANTCRD " +CRLF
	cQuery +=          " ,0 SALDODEBLP " +CRLF
	cQuery +=          " ,0 SALDOCRDLP " +CRLF
	cQuery +=          " "+cCpoMes+"  " +CRLF
	
	cQuery +=       " FROM " + cTabelaMes +CRLF
	cQuery +=       " WHERE " +CRLF
	cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF
	cQuery +=          " AND "+cTabMes+"_FILIAL " + cQryFilMes
	
	If cArqBase != "CTU"
		If cConta != Nil
			cQuery +=   " AND "+cTabMes+"_CONTA = '"+cConta+"' " +CRLF
		EndIf
		
		If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
			cQuery +=   " AND "+cTabMes+"_CCUSTO = '"+cCCusto+"' " +CRLF
		EndIf
		If  cArqBase $ 'CTD/CTH' .And. cItem != Nil
			cQuery +=   " AND "+cTabMes+"_ITEM = '"+cItem+"' " +CRLF
		EndIf
		If  cArqBase $ 'CTH' .And. cClasse != Nil
			cQuery +=   " AND "+cTabMes+"_CLVL = '"+cClasse+"'" +CRLF
		EndIf
	Else
		cQuery +=   " AND "+cTabMes+"_IDENT = '"+cIdent+"' " +CRLF
		cQuery +=   " AND "+cTabMes+"_CODIGO = '"+cCodigo+"' " +CRLF
	EndIf
	cQuery +=          " AND "+cTabMes+"_MOEDA = '"+cMoeda+"' " +CRLF
	cQuery +=          " AND "+cTabMes+"_TPSALD = '"+cTpSald+"' " +CRLF
	cQuery +=          " AND "+cTabMes+"_DATA <= '"+DTOS(FirstDay(dDataIni)-1)+"' " +CRLF
	
	cQuery +=          " GROUP BY " +CRLF
	
	cQuery +=" "+Right(cGrpMes,Len(cGrpMes)-1)+"  " +CRLF
	
	//-------------------------Diario --------------------------------------
	cQuery +=   " UNION ALL " +CRLF
	
	cQuery +=       " SELECT " +CRLF
	
	cQuery +=          " 0 SALDODEB " +CRLF
	cQuery +=          " ,0 SALDOCRD " +CRLF
	cQuery +=          " ,ISNULL(SUM("+cTabDia+"_DEBITO),0) SLDANTDEB " +CRLF
	cQuery +=          " ,ISNULL(SUM("+cTabDia+"_CREDIT),0) SLDANTCRD  " +CRLF
	cQuery +=          " ,0 SALDODEBLP " +CRLF
	cQuery +=          " ,0 SALDOCRDLP " +CRLF
	cQuery +=          " "+cCpoDia+"  " +CRLF
	
	cQuery +=      " FROM "+cTabelaDia +CRLF
	cQuery +=      " WHERE " +CRLF
	
	cQuery +=          " D_E_L_E_T_ = ' ' " +CRLF
	cQuery +=          " AND "+cTabDia+"_FILIAL " + cQryFilDia
	
	If cArqBase != "CTU"
		If cConta != Nil
			cQuery +=   " AND "+cTabDia+"_CONTA = '"+cConta+"' " +CRLF
		EndIf
		If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
			cQuery +=   " AND "+cTabDia+"_CCUSTO = '"+cCCusto+"' " +CRLF
			
		EndIf
		If  cArqBase $ 'CTD/CTH' .And. cItem != Nil
			cQuery +=   " AND "+cTabDia+"_ITEM = '"+cItem+"' " +CRLF
		EndIf
		If  cArqBase $ 'CTH' .And. cClasse != Nil
			cQuery +=   " AND "+cTabDia+"_CLVL = '"+cClasse+"'" +CRLF
		EndIf
	Else
		cQuery +=   " AND "+cTabDia+"_IDENT = '"+cIdent+"' " +CRLF
		cQuery +=   " AND "+cTabDia+"_CODIGO = '"+cCodigo+"' " +CRLF
	EndIf
	
	cQuery +=          " AND "+cTabDia+"_MOEDA = '"+cMoeda+"' " +CRLF
	cQuery +=          " AND "+cTabDia+"_TPSALD = '"+cTpSald+"' " +CRLF
	
	cQuery +=          " AND "+cTabDia+"_DATA >= '"+DTOS(FirstDay(dDataIni))+"' " +CRLF
	cQuery +=          " AND "+cTabDia+"_DATA < '"+DTOS(dDataIni)+"' " +CRLF
	
	cQuery +=          " GROUP BY " +CRLF
	
	cQuery +=" "+Right(cGrpDia,Len(cGrpDia)-1)+"  " +CRLF
	//---------------------Saldo Antes Lucros e Perdas ---------------------------------------
	If lImpAntLP
		
		cQuery +=          " UNION ALL  " +CRLF
		
		cQuery +=          " SELECT  " +CRLF
		cQuery +=          "  0 SALDODEB " +CRLF
		cQuery +=          " ,0 SALDOCRD " +CRLF
		cQuery +=          " ,0 SLDANTDEB " +CRLF
		cQuery +=          " ,0 SLDANTCRD " +CRLF
		cQuery +=          " ,ISNULL(SUM("+cTabMes+"_DEBITO),0) SALDODEBLP " +CRLF
		cQuery +=          " ,ISNULL(SUM("+cTabMes+"_CREDIT),0) SALDOCRDLP " +CRLF
		cQuery +=          " "+cCpoMes+"  " +CRLF
		
		cQuery +=          " FROM  " +cTabelaMes +CRLF
		cQuery +=          " WHERE  " +CRLF
		cQuery +=          " D_E_L_E_T_ = ' '  " +CRLF
		cQuery +=          " AND "+cTabMes+"_FILIAL " + cQryFilMes
		
		If cArqBase != "CTU"
			If cConta != Nil
				cQuery +=   " AND "+cTabMes+"_CONTA = '"+cConta+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
				cQuery +=   " AND "+cTabMes+"_CCUSTO = '"+cCCusto+"' " +CRLF
				
			EndIf
			If  cArqBase $ 'CTD/CTH' .And. cItem != Nil
				cQuery +=   " AND "+cTabMes+"_ITEM = '"+cItem+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTH' .And. cClasse != Nil
				cQuery +=   " AND "+cTabMes+"_CLVL = '"+cClasse+"'" +CRLF
			EndIf
		Else
			cQuery +=   " AND "+cTabMes+"_IDENT = '"+cIdent+"' " +CRLF
			cQuery +=   " AND "+cTabMes+"_CODIGO = '"+cCodigo+"' " +CRLF
		EndIf
		
		cQuery +=          " AND "+cTabMes+"_MOEDA = '"+cMoeda+"' " +CRLF
		cQuery +=          " AND "+cTabMes+"_TPSALD = '"+cTpSald+"' " +CRLF
		
		cQuery +=          " AND "+cTabMes+"_DATA <= '"+DTOS(FirstDay(dDataFim)-1)+"'  " +CRLF
		cQuery +=          " AND "+cTabMes+"_LP    = 'Z'   " +CRLF
		cQuery +=          " AND "+cTabMes+"_DTLP  = '"+DTOS(dDataLP)+"' " +CRLF
		
		cQuery +=          " GROUP BY  " +CRLF
		
		cQuery +=" "+Right(cGrpMes,Len(cGrpMes)-1)+"  " +CRLF
		
		cQuery +=          " UNION ALL  " +CRLF
		cQuery +=          " SELECT  " +CRLF
		
		cQuery +=          " 0 SALDODEB  " +CRLF
		cQuery +=          " ,0 SALDOCRD  " +CRLF
		cQuery +=          " ,0 SLDANTDEB  " +CRLF
		cQuery +=          " ,0 SLDANTCRD  " +CRLF
		cQuery +=          " ,ISNULL(SUM("+cTabDia+"_DEBITO),0) SALDODEBLP  " +CRLF
		cQuery +=          " ,ISNULL(SUM("+cTabDia+"_CREDIT),0) SALDOCRDLP  " +CRLF
		cQuery +=          " "+cCpoDia+"  " +CRLF
		
		cQuery +=          " FROM "+cTabelaDia +CRLF
		cQuery +=          " WHERE  " +CRLF
		cQuery +=          " D_E_L_E_T_ = ' '  " +CRLF
		cQuery +=          " AND "+cTabDia+"_FILIAL " + cQryFilDia
		
		If cArqBase != "CTU"
			If cConta != Nil
				cQuery +=   " AND "+cTabDia+"_CONTA = '"+cConta+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
				cQuery +=   " AND "+cTabDia+"_CCUSTO = '"+cCCusto+"' " +CRLF
				
			EndIf
			If  cArqBase $ 'CTD/CTH' .And. cItem != Nil
				cQuery +=   " AND "+cTabDia+"_ITEM = '"+cItem+"' " +CRLF
			EndIf
			If  cArqBase $ 'CTH' .And. cClasse != Nil
				cQuery +=   " AND "+cTabDia+"_CLVL = '"+cClasse+"'" +CRLF
			EndIf
		Else
			cQuery +=   " AND "+cTabDia+"_IDENT = '"+cIdent+"' " +CRLF
			cQuery +=   " AND "+cTabDia+"_CODIGO = '"+cCodigo+"' " +CRLF
		EndIf
		cQuery +=          " AND "+cTabDia+"_MOEDA = '"+cMoeda+"' " +CRLF
		cQuery +=          " AND "+cTabDia+"_TPSALD = '"+cTpSald+"' " +CRLF
		
		cQuery +=          " AND "+cTabDia+"_DATA >= '"+DTOS(FirstDay(dDataFim))+"'  " +CRLF
		cQuery +=          " AND "+cTabDia+"_DATA <= '"+DTOS(dDataFim)+"' " +CRLF
		cQuery +=          " AND "+cTabDia+"_LP    = 'Z'   " +CRLF
		cQuery +=          " AND "+cTabDia+"_DTLP  = '"+DTOS(dDataLP)+"'  " +CRLF
		
		cQuery +=          " GROUP BY  " +CRLF
		cQuery +=" "+Right(cGrpDia,Len(cGrpDia)-1)+"  " +CRLF
	EndIf

	cQuery +="		) SALDO " +CRLF
	cQuery +="	  GROUP BY " +CRLF
	
	cQuery +=" "+Right(cCpoTot,Len(cCpoTot)-1)+"  " +CRLF
	
	cQuery +=" ORDER BY " +CRLF
	
	cQuery +=" "+Right(cCpoTot,Len(cCpoTot)-1)+"  " +CRLF
	
	cQuery := ChangeQuery(cQuery)
	
	If Select(cTRB) > 0
		dbSelectArea(cTRB)
		(cTRB)->(dbCloseArea())
	Endif
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRB,.T.,.F.)
	
	TcSetField(cTRB,"SLDANTDEB"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SLDANTCRD"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDODEB"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDOCRD"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDODEBLP"  ,"N",aTamVlr[1],aTamVlr[2])
	TcSetField(cTRB,"SALDOCRDLP"  ,"N",aTamVlr[1],aTamVlr[2])
	
	If (cTRB)->(!EOF())
		
		nDebLP			:= (cTRB)->SALDODEBLP
		nCrdLP			:= (cTRB)->SALDOCRDLP
		
		nDebito		:= (cTRB)->SALDODEB
		nCredito		:= (cTRB)->SALDOCRD
		
		nAntDeb		:= (cTRB)->SLDANTDEB
		nAntCrd		:= (cTRB)->SLDANTCRD
		
		If lImpAntLP
			If dDataIni > dDataLP
				nAntDeb -= nDebLP
				nAntCrd -= nCrdLP
			Else
				nDebito -= nDebLP
				nCredito -= nCrdLP
			EndIf
		EndIf
		
		nSaldoAnt		:= nAntCrd - nAntDeb
		nAtuDeb		:= nAntDeb + nDebito
		nAtuCrd		:= nAntCrd + nCredito
		nSaldoAtu		:= nAtuCrd - nAtuDeb
	EndIf
	
EndIf

If Select(cTrb) > 0
	dbSelectArea(cTrb)
	(cTrb)->(dbCloseArea())
	CtbTmpErase(cMesTmpFil)
	CtbTmpErase(cDiaTmpFil)
Endif

RestArea(aArea)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                             ³
//³ [1] Saldo Atual (com sinal)                          ³
//³ [2] Debito na Data                                   ³
//³ [3] Credito na Data                                  ³
//³ [4] Saldo Atual Devedor                              ³
//³ [5] Saldo Atual Credor                               ³
//³ [6] Saldo Anterior (com sinal)                       ³
//³ [7] Saldo Anterior Devedor                           ³
//³ [8] Saldo Anterior Credor                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]

Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}



//-------------------------------------------------------------------
/*{Protheus.doc} CQ0BlnQry
Retorna alias TRBTMP com a composição dos saldos Conta 

@author Alvaro Camillo Neto
@param cConta, Character, Conta Contábil
@param cCCusto, Character, Centro de Custo
@param cItem, Character, Item contábil
@param cClasse, Character, Classe Contábil
@param cIdent, Character, Identificador da Tabela
@param dData, Character, Data do Saldo
@param cMoeda, Character, Moeda                                            
@param cTpSald, Character, Tipo de Saldo 
@param cTipo, Character, Tipo de data 1- Data do saldo - 2 - Data de Apuração 
@param cModEsc, Character                      
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ0BlnQry(dDataIni as Date,dDataFim as Date,cContaIni as Character,cContaFim as Character,cMoeda as Character,cTpSald as Character,aSetOfBook as Array,lImpMov as Logical,;
	lVlrZerado as Logical,lImpAntLP as Logical,dDataLP as Date,cFilUsu as Character,cMoedaDsc as Character,aSelFil as Array,dDtCorte as Date,lTodasFil as Logical,aTmpFil as Array,;
	cModEsc as Character, lLstSldZero as Logical,lPageControl as logical,nRecnoI as numeric,nRecnoF as numeric,nTotalRows as numeric,nLastRowPage as numeric)

Local cQuery      as Character
Local aAreaQry    as Array
Local aTamVlr     as Array
Local aCtbMoeda	  as Array
Local cCampUSU    as Character
Local aStrSTRU    as Array
Local nStruLen    as Numeric
Local nStr        as Numeric
Local cDecimais   as Character
Local lCT1EXDTFIM as Logical
Local cQryFilDia  as Character
Local cQryFilMes  as Character
Local cTmpFilDia  as Character
Local cTmpFilMes  as Character
Local cTypeDB	  as Character

DEFAULT dDataIni   := CTOD("  /  /  ")
DEFAULT dDataFim   := CTOD("  /  /  ")
DEFAULT cContaIni  := ""
DEFAULT cContaFim  := ""
DEFAULT cMoeda     := ""
DEFAULT cTpSald    := ""
DEFAULT aSetOfBook := {"","",0,"","","","","",1,"","",""}
DEFAULT lImpMov    := .T.
DEFAULT lVlrZerado := .F.
DEFAULT lImpAntLP  := .F.
DEFAULT dDataLP	   := CTOD("  /  /  ")
DEFAULT cMoedaDsc  := "01"
DEFAULT aSelFil	   := {}
DEFAULT dDtCorte   := CTOD("  /  /  ")
DEFAULT lTodasFil  := .F.
DEFAULT aTmpFil	   := {}
DEFAULT cModEsc    := ""
DEFAULT lLstSldZero	:= .F.

cQuery      := ""
aAreaQry    := GetArea()		/// array com a posição no arquivo original
aTamVlr     := TAMSX3("CT2_VALOR")
cCampUSU    := ""
aStrSTRU    := {}
nStruLen    := 0
nStr        := 1
lCT1EXDTFIM := CtbExDtFim("CT1")
cQryFilDia  := ""
cQryFilMes  := ""
cTmpFilDia  := ""
cTmpFilMes  := ""
cContaIni   := Padr(cContaIni, TamSX3("CT1_CONTA")[1])
cContaFim   := Padr(cContaFim, TamSX3("CT1_CONTA")[1])
cMoeda      := Padr(cMoeda, TamSX3("CQ1_MOEDA")[1])
cTpSald     := If(cModEsc == "ECF" , AllTrim(cTpSald), Padr(cTpSald, TamSX3("CQ1_TPSALD")[1]))
cTypeDB		:= Upper(TcGetDb())

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
cDecimais := iif(empty(aCtbMoeda[5]), "2", cValToChar(aCtbMoeda[5]))

//Tratativa para o filtro de filiais
If !lTodasFil
	cQryFilMes := " CQ0_FILIAL "+GetRngFil(aSelFil, "CQ0", .T., @cTmpFilMes)
	aAdd(aTmpFil, cTmpFilMes)
	cQryFilDia := " CQ1_FILIAL "+GetRngFil(aSelFil, "CQ1", .T., @cTmpFilDia)
	aAdd(aTmpFil, cTmpFilDia)
EndIf

cQuery := "WITH SALDOARQ AS ( "+CRLF
cQuery += " SELECT CQ1_CONTA,"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
If !Empty(dDtCorte) .And. ValType(dDtCorte) == "D" //data de corte para calculo do saldo anterior - Usado em Portugal	
	cQuery += " SUM(CASE WHEN CQ1_DATA >= '"+DTOS(dDtCorte)+"' AND CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS SALDOANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDtCorte)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS SLDANTCTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ1_DATA >='"+DTOS(dDtCorte)+"' AND CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_CREDIT,2) ELSE 0 END) AS SALDOANTCR,"+CRLF
	cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDtCorte)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_CREDIT,"+cDecimais+") ELSE 0 END) AS SLDANTCTCR,"+CRLF
	If lImpAntLP
		cQuery += " SUM(CASE WHEN CQ1_DATA >= '"+DTOS(dDtCorte)+"' AND CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z' AND"
		cQuery += " ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS SLDLPANTDB,"+CRLF
		cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDtCorte)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z' AND" 
		cQuery += " ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = ' ' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS SLLPATCTDB,"+CRLF
		cQuery += " SUM(CASE WHEN CQ1_DATA >= '"+DTOS(dDtCorte)+"' AND CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z'"
		cQuery += " AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_CREDIT,"+cDecimais+") ELSE 0 END) AS SLDLPANTCR,"+CRLF
		cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDtCorte)+"' AND CQ1_TPSALD = '"+cTpSald+"' AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z' AND"
		cQuery += " ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_CREDIT,"+cDecimais+") ELSE 0 END) AS SLLPATCTCR,"+CRLF
	EndIf	
Else
	cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD"+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS SALDOANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD"+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_CREDIT,"+cDecimais+") ELSE 0 END) AS SALDOANTCR,"+CRLF
	If lImpAntLP
		cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD"+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z' AND"
		cQuery += " ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS SLDLPANTDB,"+CRLF
		cQuery += " SUM(CASE WHEN CQ1_DATA < '"+DTOS(dDataIni)+"' AND CQ1_TPSALD"+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z' AND"
		cQuery += " ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_CREDIT,"+cDecimais+") ELSE 0 END) AS SLDLPANTCR,"+CRLF
	EndIf	
EndIf

lMesmoMes := Month(dDataIni) == Month(dDataFim) .And. Year(dDataIni) == Year(dDataFim)

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ1_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ1_TPSALD"+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ1_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ1_TPSALD "+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' THEN ROUND(CQ1_CREDIT,"+cDecimais+") ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ1_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ1_TPSALD"+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z' AND"
	cQuery += " ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_DEBITO,"+cDecimais+") ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ1_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ1_TPSALD "+If(cModEsc == "ECF", " IN ("+cTpSald+")", " = '"+cTpSald+"'")+" AND CQ1_MOEDA = '"+cMoeda+"' AND CQ1_LP = 'Z' AND"
	cQuery += " ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) THEN ROUND(CQ1_CREDIT,"+cDecimais+") ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ1")+" CQ1"+CRLF
If lTodasFil
	cQuery += " WHERE CQ1_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ1_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFilDia+CRLF
EndIf
cQuery += " AND CQ1.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ1_CONTA"+CRLF

//Se for smartview, faz controle por paginação
if lIsSmartView .and. lPageControl
	
	cQuery += "), BASE AS ( SELECT "
	cQuery += " ROW_NUMBER() OVER (ORDER BY CT1_CTASUP, CT1_CONTA) AS RN, "
else //Senão continua como já estava
	cQuery += ") SELECT "
endif

cQuery += " CT1_CONTA AS CONTA,  CT1_NORMAL AS NORMAL, CT1_RES AS CTARES, CT1_CTASUP AS SUPERIOR, CT1_CLASSE AS TIPOCONTA, CT1_GRUPO AS GRUPO,"+CRLF
If CT1->(FieldPos("CT1_NATCTA")) > 0
	cQuery += " CT1_NATCTA NATCTA,"+CRLF	
EndIf
If lCT1EXDTFIM
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF	
EndIf

//TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
cCampUSU := ""							  //// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)						  //// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT1->(dbStruct())		  //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	
	For nStr := 1 To nStruLen             //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+"," //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
EndIf
cQuery += cCampUSU						  //// ADICIONA OS CAMPOS NA QUERY

If CtbUso("CT1_DESC"+cMoedaDsc) .And. !Empty(cMoedaDsc)
	If cMoedaDsc = "01"
		cQuery += "	CT1_DESC01 DESCCTA,"+CRLF		
	Else
		cQuery += "	CT1_DESC"+cMoedaDsc+" DESCCTA, CT1_DESC01 DESCCTA01,"+CRLF		
	EndIf
Else
	If cMoeda == "01"
		cQuery += "	CT1_DESC01 DESCCTA,"+CRLF		
	Else
		cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CT1_DESC01 DESCCTA01,"+CRLF		
	EndIf
EndIf

If !Empty(dDtCorte) .And. ValType(dDtCorte) == "D" //data de corte para calculo do saldo anterior - Usado em Portugal
	cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
	cQuery += " COALESCE(SALDOS.SLDANTCTDB, 0) AS SLDANTCTDB,"+CRLF
	cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
	cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLLPATCTDB, 0) AS SLLPATCTDB,"+CRLF, "")
	cQuery += "	COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
	cQuery += "	COALESCE(SALDOS.SLDANTCTCR, 0) AS SLDANTCTCR,"+CRLF
	cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
	cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLLPATCTCR, 0) AS SLLPATCTCR,"+CRLF, "")		
Else
	cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
	cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
	cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
	cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")	
EndIf

cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += "	FROM "+RetSqlName("CT1")+" ARQ "+CRLF
cQuery += "	LEFT JOIN SALDOARQ SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ1_CONTA"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF
cQuery += " AND ARQ.CT1_CLASSE = '2' "+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
If !lVlrZerado .And. !lImpAntLP	.And. !lLstSldZero	// Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB-SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

//Se for smartview, faz controle por paginação.
//Controlando para que todas as contas de uma sintética fiquem na mesma página.
if lIsSmartView .and. lPageControl
	if cTypeDB <> "POSTGRES"
		cQuery += " ), TOTAL AS ( SELECT COUNT(*) AS TOTAL_ROWS FROM BASE ), "+CRLF
		cQuery += " BASE_G AS (SELECT B.*, MAX(RN) OVER (PARTITION BY SUPERIOR) AS GROUPENDRN FROM BASE B), "+CRLF
		cQuery += " LIMITES AS (SELECT "+cValToChar(nRecnoI)+" AS INIPAGE, "+cValToChar(nRecnoI)+" + "+cValToChar(nRecnoF-nRecnoI)+" AS FIMPAGE "
		if cTypeDB == "ORACLE"
			cQuery += " FROM DUAL "
		endif
		cQuery += "), "+CRLF
		cQuery += " ENDPAGE AS ( "+CRLF
		cQuery += 		" SELECT COALESCE(( "+CRLF
		cQuery += 			" SELECT "
		if cTypeDB == "MSSQL"
			cQuery  += " TOP 1 "
		endif
		cQuery += 			" G.GROUPENDRN "+CRLF
		cQuery += 			" FROM BASE_G G "+CRLF
		cQuery += 			" CROSS JOIN LIMITES L "+CRLF
		cQuery += 			" WHERE G.RN >= L.FIMPAGE "+CRLF
		cQuery += 			" ORDER BY G.RN "+CRLF
		if cTypeDB == "ORACLE"
			cQuery += " FETCH FIRST 1 ROWS ONLY "+CRLF
		endif
		cQuery += 			" ), (SELECT MAX(GROUPENDRN) FROM BASE_G) "+CRLF
		cQuery += 		" ) AS FIM_REAL "
		if cTypeDB == "ORACLE"
			cQuery += " FROM DUAL "
		endif
		cQuery += " ) "+CRLF
		cQuery += " SELECT  "+CRLF
		cQuery += 		" (SELECT TOTAL_ROWS FROM TOTAL) AS TOTAL_ROWS,  "+CRLF
		cQuery += 		" MAX(B.RN) OVER () AS LAST_ROW_PAGE, "+CRLF
		cQuery += 		" B.* "+CRLF
		cQuery += " FROM BASE_G B "+CRLF
		cQuery += " CROSS JOIN LIMITES L "+CRLF
		cQuery += " CROSS JOIN ENDPAGE E "+CRLF
		cQuery += " WHERE B.RN BETWEEN L.INIPAGE AND E.FIM_REAL "+CRLF
		cQuery += " ORDER BY B.RN"+CRLF
	else
		cQuery += " ), TOTAL AS (SELECT COUNT(*) AS TOTAL_ROWS FROM BASE) " + CRLF
		cQuery += " ,BASE_G AS (SELECT B.*, " + CRLF
		cQuery += 		"(SELECT MAX(B2.RN) " + CRLF
		cQuery += 		" FROM BASE B2 " + CRLF
		cQuery += 		" WHERE B2.SUPERIOR = B.SUPERIOR) AS GROUPENDRN " + CRLF
		cQuery += 	" FROM BASE B), " + CRLF
		cQuery += " LIMITES AS (SELECT "+cValToChar(nRecnoI)+" AS INIPAGE, "+cValToChar(nRecnoI)+" + "+cValToChar(nRecnoF-nRecnoI)+" AS FIMPAGE FROM BASE LIMIT 1), " + CRLF
		cQuery += " ENDPAGE AS (SELECT COALESCE( " + CRLF
		cQuery += 		"(SELECT G.GROUPENDRN " + CRLF
		cQuery += 		" FROM BASE_G G, LIMITES L " + CRLF
		cQuery += 		" WHERE G.RN >= L.FIMPAGE " + CRLF
		cQuery += 		" ORDER BY G.RN " + CRLF
		cQuery += 		" LIMIT 1), " + CRLF
		cQuery += 		"(SELECT MAX(G2.GROUPENDRN) " + CRLF
		cQuery += 		" FROM BASE_G G2)) AS FIM_REAL" + CRLF
		cQuery += 	" FROM BASE_G BG, LIMITES L2 " + CRLF
		cQuery += 	" LIMIT 1) " + CRLF
		cQuery += 	" SELECT " + CRLF
		cQuery += 		" (SELECT TOTAL_ROWS FROM TOTAL) AS TOTAL_ROWS, " + CRLF
		cQuery += 		" (SELECT MAX(B2.RN) " + CRLF
		cQuery += 		" FROM BASE_G B2, LIMITES L2, ENDPAGE E2 " + CRLF
		cQuery += 		" WHERE B2.RN BETWEEN L2.INIPAGE AND E2.FIM_REAL) AS LAST_ROW_PAGE, " + CRLF
		cQuery += 		" B.* " + CRLF
		cQuery += " FROM BASE_G B, LIMITES L, ENDPAGE E " + CRLF
		cQuery += " WHERE B.RN BETWEEN L.INIPAGE AND E.FIM_REAL " + CRLF
		cQuery += " ORDER BY B.RN " + CRLF
	endif
endif

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

if lIsSmartView .and. lPageControl
	if nTotalRows == 0 //Se ainda não informou na variável a quantidade total de registros
		nTotalRows := TRBTMP->TOTAL_ROWS
	endif
	nLastRowPage := TRBTMP->LAST_ROW_PAGE
endif

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

If lCT1EXDTFIM
	TCSetField("TRBTMP","CT1DTEXSF","D",8,0)
	TCSetField("TRBTMP","CT1_DTEXSF","D",8,0)
	TCSetField("TRBTMP","CT1_DTEXIS","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLIN","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLFI","D",8,0)
EndIf

If lImpAntLP
	TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPDEB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPCRD","N",aTamVlr[1],aTamVlr[2])
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³data de corte para calculo do saldo anterior - Usado em Portugal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( dDtCorte )
	TcSetField("TRBTMP","SLDANTCTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDANTCTCR","N",aTamVlr[1],aTamVlr[2])
	
	If lImpAntLP
		TcSetField("TRBTMP","SLLPATCTDB","N",aTamVlr[1],aTamVlr[2])
		TcSetField("TRBTMP","SLLPATCTCR","N",aTamVlr[1],aTamVlr[2])
	EndIf
EndIf
RestArea(aAreaQry)

FWFreeArray(aAreaQry)
FWFreeArray(aTamVlr)
FWFreeArray(aCtbMoeda)
FWFreeArray(aStrSTRU)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ2BlnQry
Retorna alias TRBTMP com a composição dos saldos Conta X Centro de Custo 

@author Alvaro Camillo Neto


@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cIdent 	Identificador da Tabela
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo 
@param cTipo   	Tipo de data 1- Data do saldo - 2 - Data de Apuração                       

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CQ2BlnQry(dDataIni As Date,dDataFim As Date,cContaIni As Character,cContaFim As Character,cCCIni As Character,cCCFim As Character,;
				   cMoeda As Character,cTpSald As Character,aSetOfBook As Array,lImpMov As Logical,lVlrZerado As Logical,lImpAntLP As Logical,;
				   dDataLP As Date,cFilUSU As Character,aSelFil As Array,lTodasFil As Logical,aTmpFil As Array, lPageControl As Logical,;
				   nRecnoI As Numeric, nRecnoF As Numeric, nTotalRows as Numeric)

Local cQuery		As Character
Local aAreaQry	    As Array
Local aTamVlr		As Array
Local cCampUSU	    As Character
Local aStrSTRU	    As Array
Local nStruLen	    As Numeric
Local nStr			As Numeric
Local cQryFilDia	As Character
Local cQryFilMes	As Character
Local cTmpFilDia    As Character
Local cTmpFilMes    As Character
Local cFilAte       As Character

DEFAULT lImpAntLP	:= .F.
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT aSelFil	    := {}
DEFAULT dDataIni	:= CTOD("  /  /  ")
DEFAULT dDataFim	:= CTOD("  /  /  ")
DEFAULT cFilUSU	    := ""
DEFAULT cContaIni	:= ""
DEFAULT cContaFim	:= ""
DEFAULT cCCIni	    := ""
DEFAULT cCCFim	    := ""
DEFAULT cMoeda	    := "01"
DEFAULT cTpSald	    := "1"
DEFAULT lImpAntLP   := .F.
DEFAULT lVlrZerado  := .F.
DEFAULT lImpMov     := .F.
DEFAULT lTodasFil   := .F.
DEFAULT aSetOfBook	:= {}
DEFAULT aTmpFil	    := {}

cQuery		:= ""
aAreaQry	:= GetArea()		/// array com a posição no arquivo original
aTamVlr		:= TAMSX3("CT2_VALOR")
cCampUSU	:= ""
aStrSTRU	:= {}
nStruLen	:= 0
nStr		:= 1
cQryFilDia	:= ""
cQryFilMes	:= ""
cTmpFilDia  := ""
cTmpFilMes  := ""
cFilAte     := Replicate("Z", Len(cFilAnt))
cContaIni   := Padr(cContaIni, TamSX3("CT1_CONTA")[1])
cContaFim   := Padr(cContaFim, TamSX3("CT1_CONTA")[1])
cCCIni	    := Padr(cCCIni, TamSX3("CTT_CUSTO")[1])
cCCFim	    := Padr(cCCFim, TamSX3("CTT_CUSTO")[1])
cMoeda      := Padr(cMoeda, TamSX3("CQ3_MOEDA")[1])
cTpSald     := Padr(cTpSald, TamSX3("CQ3_TPSALD")[1])

// Tratativa para o filtro de filiais
cQryFilMes := " CQ2_FILIAL " + GetRngFil( aSelFil, "CQ2", .T., @cTmpFilMes )
aAdd(aTmpFil, cTmpFilMes)
cQryFilDia := " CQ3_FILIAL " + GetRngFil( aSelFil, "CQ3", .T., @cTmpFilDia )
aAdd(aTmpFil, cTmpFilDia)

cQuery := "WITH SALDOARQ AS ( "+CRLF
cQuery += " SELECT CQ3_CONTA,CQ3_CCUSTO,"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF

If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ3")+" CQ3"+CRLF

If lTodasFil
	cQuery += " WHERE CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFilDia+CRLF
EndIf
cQuery += " AND CQ3.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ3_CONTA, CQ3_CCUSTO)"+CRLF
//Se for smartview, faz controle por paginação
if lIsSmartView .and. lPageControl
	
	cQuery += ", RESULT AS ( SELECT "
	cQuery += " ROW_NUMBER() OVER (ORDER BY ARQ.CT1_CONTA, ARQ2.CTT_CUSTO) AS RN, "
else //Senão continua como já estava
	cQuery += " SELECT "
endif
cQuery += " CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL,CT1_RES CTARES, CT1_DESC01 DESCCTA,"+CRLF
cQuery += " CT1_CTASUP SUPERIOR, CTT_RES CCRES, CT1_GRUPO GRUPO, CTT_DESC01 DESCCC, CT1_CLASSE TIPOCONTA,CTT_CLASSE TIPOCC,"+CRLF
If CtbExDtFim("CT1")
	cQuery += "CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTT")
	cQuery += "CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf
cQuery += "CTT_CCSUP CCSUP,"+CRLF

// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
cCampUSU := ""								//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)							//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT1->(dbStruct())			//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen               //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","	//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
EndIf
cQuery += cCampUSU						    //// ADICIONA OS CAMPOS NA QUERY

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += " JOIN "+RetSqlName("CTT")+" ARQ2 ON ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"' AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += " LEFT JOIN SALDOARQ SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ3_CONTA AND ARQ2.CTT_CUSTO = SALDOS.CQ3_CCUSTO"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF	
cQuery += " AND ARQ.CT1_CLASSE = '2' "+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ2.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1])  .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])  // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE CENTRO DE CUSTO DO MESMO SETOFBOOKS
EndIf

If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB <> 0 OR SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

//Se for smartview, faz controle por paginação
if lIsSmartView .and. lPageControl
	cQuery += " ), TOTAL AS ( SELECT COUNT(*) AS TOTAL_ROWS FROM RESULT ) "

	cQuery += "SELECT (SELECT TOTAL_ROWS FROM TOTAL) AS TOTAL_ROWS, r.* FROM RESULT r WHERE RN BETWEEN "+cValToChar(nRecnoI)+" AND "+cValToChar(nRecnoF)
endif

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

if lIsSmartView .and. lPageControl
	if nTotalRows == 0 //Se ainda não informou na variável a quantidade total de registros
		nTotalRows := TRBTMP->TOTAL_ROWS
	endif
endif

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

If CtbExDtFim("CT1")
	TCSetField("TRBTMP","CT1DTEXSF","D",8,0)
EndIf

If CtbExDtFim("CTT")
	TCSetField("TRBTMP","CTTDTEXSF","D",8,0)
EndIf

If lImpAntLP
	TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPDEB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPCRD","N",aTamVlr[1],aTamVlr[2])
EndIf

RestArea(aAreaQry)


Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ2BlnQryC
Retorna alias TRBTMP com a composição dos saldos Conta x Centro de Custo com o saldo de conta sem centro de custo


@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ2BlnQryC(dDataIni as Date,dDataFim as Date,cContaIni as Character,cContaFim as Character,cCustoIni as Character,cCustoFim as Character,cMoeda as Character,cTpSald as Character,aSetOfBook as Array,lImpMov as Logical,lVlrZerado as Logical,lImpAntLP as Logical,dDataLP as Date,cFilUSU as Character,aSelFil as Array,lTodasFil as Logical,aTmpFil as Array,cModEsc as Character)
Local cQuery		as Character
Local aAreaQry		as Array	
Local aTamVlr		as Array
Local cCampUSU		as Character
Local aStrSTRU		as Array
Local nStruLen		as Numeric
Local nStr			as Numeric
Local cQryCQ1		as Character
Local cQryCQ3		as Character
Local cTmpCQ1		as Character
Local cTmpCQ3		as Character
Local cTipoDB		as Character

DEFAULT dDataIni 	:= CTOD("  /  /  ")
DEFAULT dDataFim 	:= CTOD("  /  /  ")
DEFAULT cContaIni 	:= ""
DEFAULT cContaFim 	:= ""
DEFAULT cCustoIni 	:= ""
DEFAULT cCustoFim 	:= ""
DEFAULT cMoeda		:= ""
DEFAULT cTpSald		:= ""
DEFAULT aSetOfBook 	:= {}
DEFAULT lImpMov 	:= .F.
DEFAULT lVlrZerado 	:= .F.
DEFAULT cFilUSU		:= ""
DEFAULT lImpAntLP	:= .F.
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT aSelFil		:= {}
DEFAULT lTodasFil   := .F.
DEFAULT aTmpFil		:= {}
DEFAULT cModEsc 	:= ""

cQuery		:= ""
aAreaQry	:= GetArea()		/// array com a posição no arquivo original
aTamVlr		:= TAMSX3("CT2_VALOR")
cCampUSU	:= ""
aStrSTRU	:= {}
nStruLen	:= 0
nStr		:= 1
cQryCQ1		:= ""
cQryCQ3		:= ""
cTmpCQ1		:= ""
cTmpCQ3		:= ""
cTipoDB		:= Alltrim(Upper(TCGetDB()))
cContaIni   := Padr(cContaIni, TamSX3("CQ3_CONTA")[1])
cContaFim   := Padr(cContaFim, TamSX3("CQ3_CONTA")[1])
cCustoIni 	:= Padr(cCustoIni, TamSX3("CQ3_CCUSTO")[1])
cCustoFim 	:= Padr(cCustoFim, TamSX3("CQ3_CCUSTO")[1])
cMoeda      := Padr(cMoeda, TamSX3("CQ3_MOEDA")[1])
cTpSald     := If(cModEsc == "ECF" , AllTrim(cTpSald), Padr(cTpSald, TamSX3("CQ3_TPSALD")[1]))

// Tratativa para o filtro de filiais
If !lTodasFil
	cQryCQ1 := " CQ1_FILIAL " + GetRngFil( aSelFil, "CQ1", .T., @cTmpCQ1 )
	aAdd(aTmpFil, cTmpCQ1)
	cQryCQ3 := " CQ3_FILIAL " + GetRngFil( aSelFil, "CQ3", .T., @cTmpCQ3 )
	aAdd(aTmpFil, cTmpCQ3)
EndIf

cQuery			+= "SELECT " + CRLF
cQuery			+= " QRY1.CONTA     CONTA " + CRLF
cQuery			+= ", QRY1.CUSTO     CUSTO " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.SALDOANTDB),0) SALDOANTDB " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.SLDLPANTDB),0) SLDLPANTDB " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.SALDOANTCR),0) SALDOANTCR " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.SLDLPANTCR),0) SLDLPANTCR " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.SALDODEB  ),0) SALDODEB " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.MOVLPDEB  ),0) MOVLPDEB " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.SALDOCRD  ),0) SALDOCRD " + CRLF
cQuery			+= ", COALESCE(SUM(QRY1.MOVLPCRD  ),0) MOVLPCRD " + CRLF
cQuery			+= ", CT1.CT1_NORMAL NORMAL " + CRLF
cQuery			+= ", CT1_RES        CTARES " + CRLF
cQuery			+= ", CT1_DESC01     DESCCTA " + CRLF
cQuery			+= ", CT1_CTASUP     SUPERIOR " + CRLF
cQuery			+= ", CTT_RES        CCRES " + CRLF
cQuery			+= ", CT1_GRUPO      GRUPO " + CRLF
cQuery			+= ", CTT_DESC01     DESCCC " + CRLF
cQuery			+= ", CT1_CLASSE     TIPOCONTA " + CRLF
cQuery			+= ", CTT_CLASSE     TIPOCC " + CRLF
cQuery			+= ", CTT_CCSUP      CCSUP " + CRLF
// tratamento de campos especificos
If CtbExDtFim("CT1")
	cQuery += ", CT1_DTEXSF AS CT1DTEXSF" + CRLF
EndIf
If CtbExDtFim("CTT")
	cQuery += ", CTT_DTEXSF AS CTTDTEXSF"+ CRLF
EndIf

//+-----------------------------------------------------------------------+
//| TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO                      |
//+-----------------------------------------------------------------------+
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO

If !Empty( cFilUsu )								//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT1->(dbStruct())				    //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len( aStrSTRU )
	
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += ", " + aStrSTRU[nStr][1]			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif

cQuery += cCampUSU	+ CRLF

cQuery			+= " FROM  ( " + CRLF
cQuery			+= " SELECT CQ3.CQ3_CONTA  CONTA " + CRLF
cQuery			+= ", CQ3.CQ3_CCUSTO  CUSTO " + CRLF
cQuery			+= ", 0 SALDOANTDB " + CRLF
cQuery			+= ", 0 SLDLPANTDB " + CRLF
cQuery			+= ", 0 SALDOANTCR " + CRLF
cQuery			+= ", 0 SLDLPANTCR " + CRLF
cQuery			+= ", COALESCE(SUM( CQ3.CQ3_DEBITO ),0) SALDODEB " + CRLF
cQuery			+= ", 0 MOVLPDEB " + CRLF
cQuery			+= ", COALESCE(SUM( CQ3.CQ3_CREDIT ),0) SALDOCRD " + CRLF
cQuery			+= ", 0 MOVLPCRD " + CRLF
cQuery			+= " FROM "+RetSqlName("CQ3")+" CQ3 " + CRLF
cQuery			+= " WHERE " + CRLF
If lTodasFil
	cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else //Utiliza a seleção de filiais feita pelo usuário 
	cQuery += cQryCQ3+CRLF
EndIf
cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
If cModEsc == 'ECF'
	cQuery			+= " AND CQ3.CQ3_TPSALD IN  ("+cTpSald+") " + CRLF
Else
	cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
Endif
cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF
cQuery			+= " AND CQ3_DATA >= '"+DtoS(dDataIni)+"' " + CRLF
cQuery			+= " AND CQ3_DATA <= '"+DtoS(dDataFim)+"' " + CRLF
cQuery			+= " GROUP BY CQ3.CQ3_CCUSTO, CQ3.CQ3_CONTA " + CRLF

cQuery			+= " UNION ALL  " + CRLF

cQuery			+= " SELECT CQ1_CONTA  CONTA " + CRLF
cQuery			+= ", ' ' CUSTO " + CRLF
cQuery			+= ", 0 SALDOANTDB " + CRLF
cQuery			+= ", 0 SLDLPANTDB " + CRLF
cQuery			+= ", 0 SALDOANTCR " + CRLF
cQuery			+= ", 0 SLDLPANTCR " + CRLF
cQuery			+= ", CQ1_DEBITO - COALESCE(CQ3_DEBITO, 0) SALDODEB " + CRLF
cQuery			+= ", 0 MOVLPDEB " + CRLF
cQuery			+= ", CQ1_CREDIT - COALESCE(CQ3_CREDIT, 0) SALDOCRD " + CRLF
cQuery			+= ", 0 MOVLPCRD " + CRLF
cQuery			+= " FROM  " + CRLF
cQuery			+= " (   " + CRLF
cQuery			+= " SELECT  " + CRLF
cQuery			+= " 	CQ1.CQ1_CONTA , " + CRLF
cQuery			+= " 		COALESCE(SUM( CQ1.CQ1_DEBITO ),0) CQ1_DEBITO, " + CRLF
cQuery			+= "		COALESCE(SUM( CQ1.CQ1_CREDIT ),0) CQ1_CREDIT  " + CRLF
cQuery			+= " 	FROM "+RetSqlName("CQ1")+" CQ1  " + CRLF
cQuery			+= " WHERE  " + CRLF
If lTodasFil
	cQuery += " CQ1_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ1_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else //Utiliza a seleção de filiais feita pelo usuário 
	cQuery += cQryCQ1+CRLF
EndIf
cQuery			+= " AND CQ1.CQ1_CONTA >=  '"+cContaIni+"' " + CRLF
cQuery			+= " AND CQ1.CQ1_CONTA <=  '"+cContaFim+"' " + CRLF
cQuery			+= " AND CQ1.CQ1_MOEDA =   '"+cMoeda+"' " + CRLF
If cModEsc == 'ECF'
	cQuery			+= " AND CQ1.CQ1_TPSALD IN  ("+cTpSald+") " + CRLF	
Else
	cQuery			+= " AND CQ1.CQ1_TPSALD =  '"+cTpSald+"' " + CRLF
Endif
cQuery			+= " AND CQ1.D_E_L_E_T_ = ' '  " + CRLF
cQuery			+= " AND CQ1_DATA >= '"+DtoS(dDataIni)+"' " + CRLF
cQuery			+= " AND CQ1_DATA <= '"+DtoS(dDataFim)+"' " + CRLF
cQuery			+= " 	GROUP BY  " + CRLF
cQuery			+= " 		CQ1.CQ1_CONTA   " + CRLF
cQuery			+= " 	)CQ1_ORIGINAL  LEFT OUTER JOIN " + CRLF
cQuery			+= " 	( " + CRLF
cQuery			+= " 		SELECT  " + CRLF
cQuery			+= " 			CQ3.CQ3_CONTA  , " + CRLF
cQuery			+= " 			COALESCE(SUM( CQ3.CQ3_DEBITO ),0) CQ3_DEBITO, " + CRLF
cQuery			+= "			COALESCE(SUM( CQ3.CQ3_CREDIT ),0) CQ3_CREDIT  " + CRLF
cQuery			+= " 		FROM "+RetSqlName("CQ3")+" CQ3  " + CRLF
cQuery			+= " WHERE " + CRLF
If lTodasFil
	cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else //Utiliza a seleção de filiais feita pelo usuário 
	cQuery += cQryCQ3+CRLF
EndIf
cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
If cModEsc == 'ECF'
	cQuery			+= " AND CQ3.CQ3_TPSALD IN  ("+cTpSald+") " + CRLF
Else 
	cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
Endif
cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF
cQuery			+= " AND CQ3_DATA >= '"+DtoS(dDataIni)+"' " + CRLF
cQuery			+= " AND CQ3_DATA <= '"+DtoS(dDataFim)+"' " + CRLF
cQuery			+= " 		GROUP BY  " + CRLF
cQuery			+= " 				 CQ3.CQ3_CONTA " + CRLF
cQuery			+= "	)CQ3_ORIGINAL ON " + CRLF
cQuery			+= " 		CQ1_ORIGINAL.CQ1_CONTA = CQ3_ORIGINAL.CQ3_CONTA " + CRLF

cQuery			+= "UNION ALL  " + CRLF

cQuery			+= "SELECT CQ3.CQ3_CONTA  CONTA " + CRLF
cQuery			+= ", CQ3.CQ3_CCUSTO  CUSTO " + CRLF
cQuery			+= ", COALESCE(SUM( CQ3.CQ3_DEBITO ),0) SALDOANTDB " + CRLF
cQuery			+= ", 0 SLDLPANTDB " + CRLF
cQuery			+= ", COALESCE(SUM( CQ3.CQ3_CREDIT ),0) SALDOANTCR " + CRLF
cQuery			+= ", 0 SLDLPANTCR " + CRLF
cQuery			+= ", 0 SALDODEB " + CRLF
cQuery			+= ", 0 MOVLPDEB " + CRLF
cQuery			+= ", 0 SALDOCRD " + CRLF
cQuery			+= ", 0 MOVLPCRD " + CRLF
cQuery			+= " FROM "+RetSqlName("CQ3")+" CQ3 " + CRLF
cQuery			+= " WHERE " + CRLF
If lTodasFil
	cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else //Utiliza a seleção de filiais feita pelo usuário 
	cQuery += cQryCQ3+CRLF
EndIf
cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
If cModEsc == 'ECF'
	cQuery			+= " AND CQ3.CQ3_TPSALD IN ("+cTpSald+") " + CRLF
Else
	cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
Endif
cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF
cQuery			+= " AND CQ3_DATA < '"+DtoS(dDataIni)+"' " + CRLF
cQuery			+= " GROUP BY CQ3.CQ3_CCUSTO  , CQ3.CQ3_CONTA " + CRLF
cQuery			+= " UNION ALL  " + CRLF
cQuery			+= " SELECT CQ1_CONTA  CONTA  " + CRLF
cQuery			+= " , ' ' CUSTO  " + CRLF
cQuery			+= ", CQ1_DEBITO - COALESCE(CQ3_DEBITO, 0) SALDOANTDB " + CRLF
cQuery			+= ", 0 SLDLPANTDB " + CRLF
cQuery			+= ", CQ1_CREDIT - COALESCE(CQ3_CREDIT, 0) SALDOANTCR " + CRLF
cQuery			+= ", 0 SLDLPANTCR " + CRLF
cQuery			+= ", 0 SALDODEB " + CRLF
cQuery			+= ", 0 MOVLPDEB " + CRLF
cQuery			+= ", 0 SALDOCRD " + CRLF
cQuery			+= ", 0 MOVLPCRD " + CRLF
cQuery			+= "FROM  " + CRLF
cQuery			+= " (   " + CRLF
cQuery			+= " SELECT  " + CRLF
cQuery			+= " 	CQ1.CQ1_CONTA , " + CRLF
cQuery			+= " 		COALESCE(SUM( CQ1.CQ1_DEBITO ),0) CQ1_DEBITO, " + CRLF
cQuery			+= " 		COALESCE(SUM( CQ1.CQ1_CREDIT ),0) CQ1_CREDIT  " + CRLF
cQuery			+= " 	FROM "+RetSqlName("CQ1")+" CQ1  " + CRLF
cQuery			+= " WHERE " + CRLF
If lTodasFil
	cQuery += " CQ1_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ1_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else //Utiliza a seleção de filiais feita pelo usuário 
	cQuery += cQryCQ1+CRLF
EndIf
cQuery			+= " AND CQ1.CQ1_CONTA >=  '"+cContaIni+"' " + CRLF
cQuery			+= " AND CQ1.CQ1_CONTA <=  '"+cContaFim+"' " + CRLF
cQuery			+= " AND CQ1.CQ1_MOEDA =   '"+cMoeda+"' " + CRLF
If cModEsc == 'ECF'
	cQuery			+= " AND CQ1.CQ1_TPSALD IN ("+cTpSald+") " + CRLF
Else
	cQuery			+= " AND CQ1.CQ1_TPSALD =  '"+cTpSald+"' " + CRLF
Endif
cQuery			+= " AND CQ1.D_E_L_E_T_ = ' '  " + CRLF
cQuery			+= " AND CQ1_DATA < '"+DtoS(dDataIni)+"' " + CRLF
cQuery			+= " 	GROUP BY  " + CRLF
cQuery			+= " 		CQ1.CQ1_CONTA   " + CRLF
cQuery			+= " 	)CQ1_ANTERIOR  LEFT OUTER JOIN " + CRLF
cQuery			+= " 	( " + CRLF
cQuery			+= " 		SELECT  " + CRLF
cQuery			+= " 			CQ3.CQ3_CONTA  , " + CRLF
cQuery			+= " 			COALESCE(SUM( CQ3.CQ3_DEBITO ),0) CQ3_DEBITO, " + CRLF
cQuery			+= " 			COALESCE(SUM( CQ3.CQ3_CREDIT ),0) CQ3_CREDIT  " + CRLF
cQuery			+= " 		FROM "+RetSqlName("CQ3")+" CQ3  " + CRLF
cQuery			+= " WHERE  " + CRLF
If lTodasFil
	cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else //Utiliza a seleção de filiais feita pelo usuário 
	cQuery += cQryCQ3+CRLF
EndIf
cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
If cModEsc == 'ECF'
	cQuery			+= " AND CQ3.CQ3_TPSALD IN ("+cTpSald+") " + CRLF
Else
	cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
Endif
cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF
cQuery			+= " AND CQ3_DATA < '"+DtoS(dDataIni)+"' " + CRLF
cQuery			+= " 		GROUP BY  " + CRLF
cQuery			+= " 				 CQ3.CQ3_CONTA " + CRLF
cQuery			+= " 	)CQ3_ANTERIOR ON " + CRLF
cQuery			+= " 		CQ1_ANTERIOR.CQ1_CONTA = CQ3_ANTERIOR.CQ3_CONTA " + CRLF


IF lImpAntLp
	
	cQuery			+= " UNION ALL  " + CRLF
	
	cQuery			+= " SELECT CQ3.CQ3_CONTA  CONTA " + CRLF
	cQuery			+= ", CQ3.CQ3_CCUSTO  CUSTO " + CRLF
	cQuery			+= ", 0 SALDOANTDB " + CRLF
	cQuery			+= ", 0 SLDLPANTDB " + CRLF
	cQuery			+= ", 0 SALDOANTCR " + CRLF
	cQuery			+= ", 0 SLDLPANTCR " + CRLF
	cQuery			+= ", 0 SALDODEB " + CRLF
	cQuery			+= ", COALESCE(SUM( CQ3.CQ3_DEBITO ),0) MOVLPDEB " + CRLF
	cQuery			+= ", 0 SALDOCRD " + CRLF
	cQuery			+= ", COALESCE(SUM( CQ3.CQ3_CREDIT ),0) MOVLPCRD " + CRLF
	cQuery			+= " FROM "+RetSqlName("CQ3")+" CQ3 " + CRLF
	cQuery			+= " WHERE  " + CRLF
	If lTodasFil
		cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else //Utiliza a seleção de filiais feita pelo usuário 
		cQuery += cQryCQ3+CRLF
	EndIf
	cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
	If cModEsc == 'ECF'
		cQuery			+= " AND CQ3.CQ3_TPSALD IN  ("+cTpSald+") " + CRLF
	Else
		cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
	Endif
	cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF
	cQuery			+= " AND CQ3_DATA >= '"+DtoS(dDataIni)+"' " + CRLF
	cQuery			+= " AND CQ3_DATA <= '"+DtoS(dDataFim)+"' " + CRLF
	cQuery			+= " AND CQ3_LP =  'Z' " + CRLF
	cQuery			+= " AND ( ( CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) OR ( CQ3_DTLP = '' AND CQ3_DATA >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) ) " + CRLF
	cQuery			+= " GROUP BY CQ3.CQ3_CCUSTO, CQ3.CQ3_CONTA " + CRLF
	cQuery			+= " UNION ALL  " + CRLF
	
	cQuery			+= "SELECT CQ1_CONTA  CONTA " + CRLF
	cQuery			+= ", ' ' CUSTO " + CRLF
	cQuery			+= ", 0 SALDOANTDB " + CRLF
	cQuery			+= ", 0 SLDLPANTDB " + CRLF
	cQuery			+= ", 0 SALDOANTCR " + CRLF
	cQuery			+= ", 0 SLDLPANTCR " + CRLF
	cQuery			+= ", 0 SALDODEB " + CRLF
	cQuery			+= ", CQ1_DEBITO - COALESCE(CQ3_DEBITO, 0) MOVLPDEB " + CRLF
	cQuery			+= ", 0 SALDOCRD " + CRLF
	cQuery			+= ", CQ1_CREDIT - COALESCE(CQ3_CREDIT, 0) MOVLPCRD " + CRLF
	cQuery			+= " FROM  " + CRLF
	cQuery			+= " (   " + CRLF
	cQuery			+= " SELECT  " + CRLF
	cQuery			+= " 	CQ1.CQ1_CONTA ,  " + CRLF
	cQuery			+= " 		COALESCE(SUM( CQ1.CQ1_DEBITO ),0) CQ1_DEBITO, " + CRLF
	cQuery			+= " 		COALESCE(SUM( CQ1.CQ1_CREDIT ),0) CQ1_CREDIT  " + CRLF
	cQuery			+= " 	FROM "+RetSqlName("CQ1")+" CQ1  " + CRLF
	cQuery			+= " WHERE  " + CRLF
	If lTodasFil
		cQuery += " CQ1_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ1_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else //Utiliza a seleção de filiais feita pelo usuário 
		cQuery += cQryCQ1+CRLF
	EndIf
	cQuery			+= " AND CQ1.CQ1_CONTA >=  '"+cContaIni+"' " + CRLF
	cQuery			+= " AND CQ1.CQ1_CONTA <=  '"+cContaFim+"' " + CRLF
	cQuery			+= " AND CQ1.CQ1_MOEDA =   '"+cMoeda+"' " + CRLF
	If cModEsc == 'ECF'
		cQuery			+= " AND CQ1.CQ1_TPSALD IN ("+cTpSald+") " + CRLF
	Else 
		cQuery			+= " AND CQ1.CQ1_TPSALD =  '"+cTpSald+"' " + CRLF
	Endif
	cQuery			+= " AND CQ1.D_E_L_E_T_ = ' '  " + CRLF	
	cQuery			+= " AND CQ1_DATA >= '"+DtoS(dDataIni)+"' " + CRLF
	cQuery			+= " AND CQ1_DATA <= '"+DtoS(dDataFim)+"' " + CRLF
	cQuery			+= " AND CQ1_LP =  'Z' " + CRLF
	cQuery			+= " AND ( ( CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) OR ( CQ1_DTLP = '' AND CQ1_DATA >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " AND CQ1_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) ) " + CRLF
	cQuery			+= " 	GROUP BY  " + CRLF
	cQuery			+= " 		CQ1.CQ1_CONTA   " + CRLF
	cQuery			+= " 	)CQ1_LPORIGINAL  LEFT OUTER JOIN " + CRLF
	cQuery			+= " 	( " + CRLF
	cQuery			+= " 		SELECT  " + CRLF
	cQuery			+= " 			CQ3.CQ3_CONTA  , " + CRLF
	cQuery			+= " 			COALESCE(SUM( CQ3.CQ3_DEBITO ),0) CQ3_DEBITO, " + CRLF
	cQuery			+= " 			COALESCE(SUM( CQ3.CQ3_CREDIT ),0) CQ3_CREDIT  " + CRLF
	cQuery			+= " 		FROM "+RetSqlName("CQ3")+" CQ3  " + CRLF
	cQuery			+= " WHERE  " + CRLF
	If lTodasFil
		cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else //Utiliza a seleção de filiais feita pelo usuário 
		cQuery += cQryCQ3+CRLF
	EndIf
	cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
	If cModEsc == 'ECF'
		cQuery			+= " AND CQ3.CQ3_TPSALD IN ("+cTpSald+") " + CRLF
	Else 
		cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
	Endif
	cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF	
	cQuery			+= " AND CQ3_DATA >= '"+DtoS(dDataIni)+"' " + CRLF
	cQuery			+= " AND CQ3_DATA <= '"+DtoS(dDataFim)+"' " + CRLF
	cQuery			+= " AND CQ3_LP =  'Z' " + CRLF
	cQuery			+= " AND ( ( CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) OR ( CQ3_DTLP = '' AND CQ3_DATA >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) ) " + CRLF
	cQuery			+= " 		GROUP BY " + CRLF
	cQuery			+= " 				 CQ3.CQ3_CONTA " + CRLF
	cQuery			+= " 	)CQ3_LPORIGINAL ON " + CRLF
	cQuery			+= " 		CQ1_LPORIGINAL.CQ1_CONTA = CQ3_LPORIGINAL.CQ3_CONTA " + CRLF
	cQuery			+= " UNION ALL  " + CRLF
	cQuery			+= "SELECT CQ3.CQ3_CONTA  CONTA " + CRLF
	cQuery			+= ", CQ3.CQ3_CCUSTO  CUSTO " + CRLF
	cQuery			+= ", 0 SALDOANTDB " + CRLF
	cQuery			+= ", COALESCE(SUM( CQ3.CQ3_DEBITO ),0) SLDLPANTDB " + CRLF
	cQuery			+= ", 0 SALDOANTCR " + CRLF
	cQuery			+= ", COALESCE(SUM( CQ3.CQ3_CREDIT ),0) SLDLPANTCR " + CRLF
	cQuery			+= ", 0 SALDODEB " + CRLF
	cQuery			+= ", 0 MOVLPDEB " + CRLF
	cQuery			+= ", 0 SALDOCRD " + CRLF
	cQuery			+= ", 0 MOVLPCRD " + CRLF
	cQuery			+= " FROM "+RetSqlName("CQ3")+" CQ3 " + CRLF
	cQuery			+= " WHERE  " + CRLF
	If lTodasFil
		cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else //Utiliza a seleção de filiais feita pelo usuário 
		cQuery += cQryCQ3+CRLF
	EndIf
	cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
	If cModEsc == 'ECF'
		cQuery			+= " AND CQ3.CQ3_TPSALD IN ("+cTpSald+") " + CRLF
	Else
		cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
	Endif
	cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF	
	cQuery			+= " AND CQ3_DATA < '"+DtoS(dDataIni)+"' " + CRLF
	cQuery			+= " AND CQ3_LP =  'Z' " + CRLF
	cQuery			+= " AND ( ( CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) OR ( CQ3_DTLP = '' AND CQ3_DATA >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) ) " + CRLF
	cQuery			+= " GROUP BY CQ3.CQ3_CCUSTO  , CQ3.CQ3_CONTA " + CRLF
	cQuery			+= " UNION ALL  " + CRLF
	cQuery			+= "SELECT CQ1_CONTA  CONTA " + CRLF
	cQuery			+= ", ' ' CUSTO  " + CRLF
	cQuery			+= ", 0 SALDOANTDB " + CRLF
	cQuery			+= ", CQ1_DEBITO - COALESCE(CQ3_DEBITO, 0) SLDLPANTDB " + CRLF
	cQuery			+= ", 0 SALDOANTCR " + CRLF
	cQuery			+= ", CQ1_CREDIT - COALESCE(CQ3_CREDIT, 0) SLDLPANTCR " + CRLF
	cQuery			+= ", 0 SALDODEB " + CRLF
	cQuery			+= ", 0 MOVLPDEB " + CRLF
	cQuery			+= ", 0 SALDOCRD " + CRLF
	cQuery			+= ", 0 MOVLPCRD " + CRLF
	cQuery			+= " FROM  " + CRLF
	cQuery			+= " (   " + CRLF
	cQuery			+= " SELECT  " + CRLF
	cQuery			+= " 	CQ1.CQ1_CONTA ,  " + CRLF
	cQuery			+= " 		COALESCE(SUM( CQ1.CQ1_DEBITO ),0) CQ1_DEBITO, " + CRLF
	cQuery			+= " 		COALESCE(SUM( CQ1.CQ1_CREDIT ),0) CQ1_CREDIT  " + CRLF
	cQuery			+= " 	FROM "+RetSqlName("CQ1")+" CQ1  " + CRLF
	cQuery			+= " WHERE  " + CRLF
	If lTodasFil
		cQuery += " CQ1_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ1_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else //Utiliza a seleção de filiais feita pelo usuário 
		cQuery += cQryCQ1+CRLF
	EndIf
	cQuery			+= " AND CQ1.CQ1_CONTA >=  '"+cContaIni+"' " + CRLF
	cQuery			+= " AND CQ1.CQ1_CONTA <=  '"+cContaFim+"' " + CRLF
	cQuery			+= " AND CQ1.CQ1_MOEDA =   '"+cMoeda+"' " + CRLF
	If cModEsc == 'ECF'
		cQuery			+= " AND CQ1.CQ1_TPSALD IN ("+cTpSald+") " + CRLF
	Else
		cQuery			+= " AND CQ1.CQ1_TPSALD =  '"+cTpSald+"' " + CRLF
	Endif
	cQuery			+= " AND CQ1.D_E_L_E_T_ = ' '  " + CRLF	
	cQuery			+= " AND CQ1_DATA < '"+DtoS(dDataIni)+"' " + CRLF
	cQuery			+= " AND CQ1_LP =  'Z' " + CRLF
	cQuery			+= " AND ( ( CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) OR ( CQ1_DTLP = '' AND CQ1_DATA >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " AND CQ1_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) ) " + CRLF
	cQuery			+= " 	GROUP BY  " + CRLF
	cQuery			+= " 		CQ1.CQ1_CONTA  " + CRLF
	cQuery			+= " 	)CQ1_LPANTERIOR  LEFT OUTER JOIN " + CRLF
	cQuery			+= " 	( " + CRLF
	cQuery			+= " 		SELECT  " + CRLF
	cQuery			+= " 			CQ3.CQ3_CONTA  , " + CRLF
	cQuery			+= " 			COALESCE(SUM( CQ3.CQ3_DEBITO ),0) CQ3_DEBITO, " + CRLF
	cQuery			+= " 			COALESCE(SUM( CQ3.CQ3_CREDIT ),0) CQ3_CREDIT  " + CRLF
	cQuery			+= " 		FROM "+RetSqlName("CQ3")+" CQ3  " + CRLF
	cQuery			+= " WHERE " + CRLF
	If lTodasFil
		cQuery += " CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else //Utiliza a seleção de filiais feita pelo usuário 
		cQuery += cQryCQ3+CRLF
	EndIf
	cQuery			+= " AND CQ3.CQ3_CONTA >=  '"+cContaIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CONTA <=  '"+cContaFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO >=  '"+cCustoIni+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_CCUSTO <=  '"+cCustoFim+"' " + CRLF
	cQuery			+= " AND CQ3.CQ3_MOEDA =   '"+cMoeda+"' " + CRLF
	If cModEsc == 'ECF'
		cQuery			+= " AND CQ3.CQ3_TPSALD IN ("+cTpSald+") " + CRLF
	Else
		cQuery			+= " AND CQ3.CQ3_TPSALD =  '"+cTpSald+"' " + CRLF
	Endif
	cQuery			+= " AND CQ3.D_E_L_E_T_ = ' '  " + CRLF	
	cQuery			+= " AND CQ3_DATA < '"+DtoS(dDataIni)+"' " + CRLF
	cQuery			+= " AND CQ3_LP =  'Z' " + CRLF
	cQuery			+= " AND ( ( CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) OR ( CQ3_DTLP = '' AND CQ3_DATA >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " AND CQ3_DTLP >= '"+DtoS(dDataLP)+"' " + CRLF
	cQuery			+= " ) ) " + CRLF
	cQuery			+= " 		GROUP BY  " + CRLF
	cQuery			+= " 				 CQ3.CQ3_CONTA " + CRLF
	cQuery			+= " 	)CQ3_LPANTERIOR ON " + CRLF
	cQuery			+= " 		CQ1_LPANTERIOR.CQ1_CONTA = CQ3_LPANTERIOR.CQ3_CONTA " + CRLF
EndIf

cQuery			+= " ) QRY1  " + CRLF

cQuery			+= "  LEFT OUTER JOIN "+RetSQLName("CT1")+" CT1 ON   " + CRLF
cQuery			+= "  CT1.CT1_CONTA = QRY1.CONTA AND 	 " + CRLF
cQuery			+= " CT1_FILIAL ='"+xFilial("CT1")+"' AND  	 " + CRLF
cQuery			+= "  CT1.D_E_L_E_T_ = ' '   LEFT OUTER JOIN "+RetSQLName("CTT")+" CTT ON " + CRLF
cQuery			+= "  CTT.CTT_CUSTO = QRY1.CUSTO AND  	CTT_FILIAL = '"+xFilial("CTT")+"' AND  	CTT.D_E_L_E_T_ = ' ' " + CRLF

If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " 	AND CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "  // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif

If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " 	AND CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' "  // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
Endif

cQuery			+= " GROUP BY CONTA, CUSTO, CT1.CT1_DESC01,  " + CRLF
cQuery			+= " CT1.CT1_NORMAL, CT1_RES, CT1_DESC01, CT1_CTASUP, " + CRLF
cQuery			+= "  CTT_RES, CT1_GRUPO, CTT_DESC01, CT1_CLASSE,  " + CRLF
cQuery			+= "  CTT_CLASSE, CTT_CCSUP  " + CRLF

// tratamento de campos especificos
If CtbExDtFim("CT1")
	cQuery += ", CT1_DTEXSF"  + CRLF
EndIf
If CtbExDtFim("CTT")
	cQuery += ", CTT_DTEXSF" + CRLF
EndIf

cQuery += cCampUSU + CRLF

cQuery			+= " ORDER BY CONTA, CUSTO " + CRLF

cQuery := ChangeQuery(cQuery )

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif
	
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , "TRBTMP" , .T. , .F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDODEB"  ,"N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOCRD"  ,"N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","MOVLPDEB"  ,"N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","MOVLPCRD"  ,"N",aTamVlr[1],aTamVlr[2])	    

If CtbExDtFim("CT1") 
	TCSetField("TRBTMP","CT1DTEXSF","D",8,0)	
EndIf

If CtbExDtFim("CTT") 
	TCSetField("TRBTMP","CTTDTEXSF","D",8,0)	
EndIf

RestArea(aAreaQry)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CQ4BlnQry
Retorna alias TRBTMP com a composição dos saldos Conta X Item Contábil

@author Alvaro Camillo Neto

@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cIdent 	Identificador da Tabela
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo 
@param cTipo   	Tipo de data 1- Data do saldo - 2 - Data de Apuração                       

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CQ4BlnQry(dDataIni,dDataFim,cContaIni,cContaFim,cItemIni,cItemFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil,lCTBR100SV,lCTBR140SV)
Local cQuery		:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local cCampUSU		:= ""
Local aStrSTRU		:= {}
Local nStruLen		:= 0
Local nStr			:= 1
Local cQryFilDia	:= ""
Local cQryFilMes	:= ""
Local cTmpFilDia	:= ""
Local cTmpFilMes	:= ""
Local cTmpFil		:= ""
Local cRngFilCTD 	:= ""
Local cTmpCta 		:= ""
Local cRngFilCT1    := "" //Filiais tabela CT1 - Plano de Contas

//Verificação se a chamada é do CTBR140 ou teste automatizado do CTBR140
Local lCtbr140		:= .F.

//Verificação se a chamada é do CTBR140 ou teste automatizado do CTBR140
Local lCtbr100		:= .F.


DEFAULT lImpAntLP	:= .F.
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT aSelFil		:= {}
DEFAULT lTodasFil	:= .F.
DEFAULT aTmpFil		:= {}
DEFAULT lCTBR100SV  := .F.
DEFAULT lCTBR140SV  := .F.

lCtbr100 := IIf(FwIsInCallStack('CTBR100') .or. (FunName() == 'CTBR100') .or. lCTBR100SV, .T., .F.)
lCtbr140 := IIf(FwIsInCallStack('CTBR140') .or. (FunName() == 'CTBR140') .or. lCTBR140SV, .T., .F.)

cContaIni := Padr(cContaIni, TamSX3("CT1_CONTA")[1])
cContaFim := Padr(cContaFim, TamSX3("CT1_CONTA")[1])
cItemIni  := Padr(cItemIni, TamSX3("CTD_ITEM")[1])
cItemFim  := Padr(cItemFim, TamSX3("CTD_ITEM")[1])
cMoeda    := Padr(cMoeda, TamSX3("CQ5_MOEDA")[1])
cTpSald   := Padr(cTpSald, TamSX3("CQ5_TPSALD")[1])

// Tratativa para o filtro de filiais
If !lTodasFil
	cQryFilMes := " CQ4_FILIAL " + GetRngFil( aSelFil, "CQ4", .T., @cTmpFilMes )
	aAdd(aTmpFil, cTmpFilMes)
	cQryFilDia := " CQ5_FILIAL " + GetRngFil( aSelFil, "CQ5", .T., @cTmpFilDia )
	aAdd(aTmpFil, cTmpFilDia)	
EndIf
cRngFilCTD := GetRngFil(aSelFil,"CTD",.T.,@cTmpFil)
cRngFilCT1 := GetRngFil(aSelFil,"CT1",.T.,@cTmpCta) //Considerando as filiais selecionadas, tabelas compartilhadas ou não

cQuery := "WITH SALDOARQ AS ( "+CRLF
cQuery += " SELECT CQ5_CONTA,CQ5_ITEM,"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF

If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ5")+" CQ5"+CRLF

If lTodasFil
	cQuery += " WHERE CQ5_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ5_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFilDia+CRLF
EndIf
cQuery += " AND CQ5.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ5_CONTA,CQ5_ITEM)"+CRLF
cQuery += " SELECT"
If lCtbr140 .Or. lCtbr100	
	cQuery += " DISTINCT CTD_ITEM ITEM,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
Else
	cQuery += " CTD_ITEM ITEM,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, CT1_GRUPO GRUPO,"+CRLF
EndIf
cQuery += " CT1_CTASUP SUPERIOR, CTD_RES ITRES, CTD_ITSUP ITSUP, CT1_CLASSE TIPOCONTA, CTD_CLASSE TIPOITEM,"+CRLF
If CtbExDtFim("CT1") 
	cQuery += "CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTD") 
	cQuery += "CTD_DTEXSF CTDDTEXSF,"+CRLF
EndIf

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU := ""									 //// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)								 //// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT1->(dbStruct())				 //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                    //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","+CRLF //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif                
cQuery += cCampUSU								//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////		

If !lCtbr140
	If cMoeda == "01"
		cQuery += " CT1_DESC01 DESCCTA, CTD_DESC01 DESCITEM,"+CRLF
	Else
		cQuery += " CT1_DESC"+cMoeda+" DESCCTA, CTD_DESC"+cMoeda+" DESCITEM, CT1_DESC01 DESCCTA01, CTD_DESC01 DESCIT01,"+CRLF
	EndIf
EndIf

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "") 

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += "	JOIN "+RetSqlName("CTD")+" ARQ2 ON ARQ2.CTD_FILIAL "+cRngFilCTD+"  AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += "	LEFT JOIN SALDOARQ SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ5_CONTA AND ARQ2.CTD_ITEM = SALDOS.CQ5_ITEM"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL "+cRngFilCT1+CRLF		
cQuery += " AND ARQ.CT1_CLASSE = '2' "+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF	
cQuery += " AND ARQ2.CTD_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf
If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB <> 0 OR SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

//---------------------------------------------------------------------------------------

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

If CtbExDtFim("CT1")
	TCSetField("TRBTMP","CT1DTEXSF","D",8,0)
EndIf

If CtbExDtFim("CTD")
	TCSetField("TRBTMP","CTDDTEXSF","D",8,0)
EndIf

If lImpAntLP
	TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPDEB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPCRD","N",aTamVlr[1],aTamVlr[2])
EndIf

RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ6BlnQry
Retorna alias TRBTMP com a composição dos saldos Conta X Item Contábil

@author Alvaro Camillo Neto

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ6BlnQry(dDataIni,dDataFim,cContaIni,cContaFim,cClVlIni,cClVlFim,cMoeda,cTpSald,aSetOfBook,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
Local cQuery		:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local cCampUSU		:= ""
Local aStrSTRU		:= {}
Local nStruLen		:= 0
Local nStr			:= 1
Local cQryFilDia	:= ""
Local cQryFilMes	:= ""
Local cTmpFilDia  	:= ""
Local cTmpFilMes  	:= ""
Local lCT1EXDTFIM	:= CtbExDtFim("CT1")
Local lCTHEXDTFIM	:= CtbExDtFim("CTH")

DEFAULT lImpAntLp	:= .F.
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT aSelFil		:= {}
DEFAULT lTodasFil	:= .F.
DEFAULT aTmpFil		:= {}

cContaIni := Padr(cContaIni, TamSX3("CT1_CONTA")[1])
cContaFim := Padr(cContaFim, TamSX3("CT1_CONTA")[1])
cClVlIni  := Padr(cClVlIni, TamSX3("CTH_CLVL")[1])
cClVlFim  := Padr(cClVlFim, TamSX3("CTH_CLVL")[1])
cMoeda    := Padr(cMoeda, TamSX3("CQ7_MOEDA")[1])
cTpSald   := Padr(cTpSald, TamSX3("CQ7_TPSALD")[1])

// Tratativa para o filtro de filiais
If !lTodasFil
	cQryFilMes := " CQ6_FILIAL " + GetRngFil( aSelFil, "CQ6", .T., @cTmpFilMes )
	aAdd(aTmpFil, cTmpFilMes)
	cQryFilDia := " CQ7_FILIAL " + GetRngFil( aSelFil, "CQ7", .T., @cTmpFilDia )
	aAdd(aTmpFil, cTmpFilDia)
EndIf

cQuery := "WITH SALDOARQ AS ( "+CRLF
cQuery += " SELECT CQ7_CONTA,CQ7_CLVL,"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF

If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ7")+" CQ7"+CRLF

If lTodasFil
	cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFilDia+CRLF
EndIf
cQuery += " AND CQ7.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ7_CONTA,CQ7_CLVL)"+CRLF
cQuery += " SELECT CTH_CLVL CLVL,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, CT1_GRUPO GRUPO,"+CRLF
cQuery += " CT1_CTASUP SUPERIOR, CTH_RES CLVLRES, CTH_CLSUP CLSUP, CT1_CLASSE TIPOCONTA, CTH_CLASSE TIPOCLVL,"+CRLF
If lCT1EXDTFIM
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf	
If lCTHEXDTFIM
	cQuery += " CTH_DTEXSF CTHDTEXSF,"+CRLF
EndIf

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU := ""								   //// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)							   //// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT1->(dbStruct())			   //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                  //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","+CRLF //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif                
cQuery += cCampUSU	//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////		

If cMoeda == "01"
	cQuery += "	CT1_DESC01 DESCCTA, CTH_DESC01 DESCCLVL,"                                                   	
Else
	cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CTH_DESC"+cMoeda+" DESCCLVL, CT1_DESC01 DESCCTA01, CTH_DESC01 DESCCV01,"                                                   	
EndIf

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += " JOIN "+RetSqlName("CTH")+" ARQ2 ON ARQ2.CTH_FILIAL = '"+xFilial("CTH")+"' AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += " LEFT JOIN SALDOARQ SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ7_CONTA AND ARQ2.CTH_CLVL = SALDOS.CQ7_CLVL"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF	
cQuery += " AND ARQ.CT1_CLASSE = '2' "+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ2.CTH_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE CLVL DO MESMO SETOFBOOKS
EndIf
If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB <> 0 OR SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

If CtbExDtFim("CT1")
	TCSetField("TRBTMP","CT1DTEXSF","D",8,0)
EndIf

If CtbExDtFim("CTH")
	TCSetField("TRBTMP","CTHDTEXSF","D",8,0)
EndIf

If lImpAntLP
	TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPDEB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPCRD","N",aTamVlr[1],aTamVlr[2])
EndIf

RestArea(aAreaQry)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} CQ0CompQry
Query para comparativo de conta x 6/12 meses  


@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ0CompQry(dDataIni,dDataFim,cTpSaldo,cMoeda,cContaIni,cContaFim,aSetOfBook,lVlrZerado,lMeses,aMeses,cString,cFILUSU,lImpAntLP,dDataLP,lAcum)
Local aSaveArea	:= GetArea()
Local cQuery	:= ""
Local nColunas	:= 0
Local aTamVlr	:= TAMSX3("CT2_VALOR")
Local nStr		:= 1
Local lCT1EXDTFIM := CtbExDtFim("CT1") 
Local lCTBSldLP := ExistBlock("CTBSldLP")

DEFAULT lVlrZerado	:= .F.
DEFAULT lAcum		:= .F.

cQuery += " SELECT * FROM ( " + CRLF
cQuery += " SELECT CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA,  	"+ CRLF
If lCT1EXDTFIM 
	cQuery += " CT1_DTEXSF CT1DTEXSF, "+ CRLF
EndIf
cQuery += " 	CT1_CLASSE TIPOCONTA, CT1_GRUPO GRUPO, CT1_CTASUP CTASUP, "+ CRLF

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+"," + CRLF			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

If lMeses
	If lCTBSldLP
		cQuery += ExecBlock("CTBSldLP", .F.,.F., { lImpAntLP , dDataLP, aMeses , lAcum , cMoeda , cTpSaldo , 1 } )
	Else
		For nColunas := 1 to Len(aMeses)
			cQuery += " 	(SELECT ISNULL(SUM(CQ1_CREDIT) - SUM(CQ1_DEBITO),0) "+ CRLF
			cQuery += "			 	FROM "+RetSqlName("CQ1")+" CQ1 "+ CRLF
			cQuery += " 			WHERE CQ1.CQ1_FILIAL = '"+xFilial("CQ1")+"' "+ CRLF
			cQuery += " 			AND ARQ.CT1_CONTA	= CQ1_CONTA "+ CRLF
			cQuery += " 			AND CQ1_MOEDA = '"+cMoeda+"' "+ CRLF
			cQuery += " 			AND CQ1_TPSALD = '"+cTpSaldo+"' "+ CRLF
			If lAcum //.and. nColunas == 1/// SE FOR ACUMULADO, A PRIMEIRA COLUNA TERA O SALDO ATE O FINAL DO PERIODO
				cQuery += " 			AND CQ1_DATA <= '"+DTOS(aMeses[nColunas][3])+"' "+ CRLF
			Else						/// AS DEMAIS COLUNAS SEMPRE SOMAM O MOVIMENTO NO PERIODO. (CALCULO NO RELATORIO)
				cQuery += " 			AND CQ1_DATA BETWEEN '"+DTOS(aMeses[nColunas][2])+"' AND '"+DTOS(aMeses[nColunas][3])+"' "+ CRLF
			Endif

			If lImpAntLP
				If IsInCallStack("CTBR265") .or. IsInCallStack("CTBR260")				
					cQuery +=" AND ( CQ1_LP = 'Z' AND (CQ1_DTLP <> ' ' AND CQ1_DTLP < '"+DTOS(dDataLP)+"') OR (CQ1_LP <> 'Z')) " + CRLF //protegido para ctbr265 avaliar se faz sentido para outros relatorios
				Else
					cQuery += " AND CQ1_LP <> 'Z' "+ CRLF
				EndIf
			Endif

			cQuery += " 			AND CQ1.D_E_L_E_T_ = ' ') COLUNA"+Str(nColunas,Iif(nColunas>9,2,1))+" "+ CRLF
			
			If nColunas <> Len(aMeses)
				cQuery += ", "
			EndIf		
		Next
	EndIf	
EndIf

cQuery += " 	FROM "+RetSqlName("CT1")+" ARQ "+ CRLF
cQuery += " 	WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"' "+ CRLF
cQuery += " 	AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' "+ CRLF
cQuery += " 	AND ARQ.CT1_CLASSE = '2' "+ CRLF
	
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS									//// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " 	AND CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' " + CRLF // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif	
cQuery += " 	AND ARQ.D_E_L_E_T_ = ' ' "+ CRLF

cQuery += " ) ARQCOMP "+ CRLF
 
If !lVlrZerado
	If lMeses
		If lCTBSldLP
			cQuery += ExecBlock("CTBSldLP", .F.,.F., { lImpAntLP , dDataLP, aMeses , lAcum , cMoeda , cTpSaldo , 2 } )
		Else
			cQuery += " WHERE ("+ CRLF
			For nColunas := 1 to Len(aMeses)
				cQuery += "	COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)) + " <> 0 "+ CRLF
				If nColunas <> Len(aMeses)
					cQuery += " 	OR "+ CRLF
				EndIf
			Next
			cQuery += " ) "+ CRLF
		Endif
	EndIf
Endif
cQuery := ChangeQuery(cQuery)		   

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
If lMeses
	For nColunas := 1 to Len(aMeses)
		TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
	Next                                                                                           
	If lCT1EXDTFIM 
		TcSetField("TRBTMP","CT1DTEXSF","D",8,0)	
		TCSetField("TRBTMP","CT1_DTEXSF","D",8,0)	
 		TCSetField("TRBTMP","CT1_DTEXIS","D",8,0)
		TCSetField("TRBTMP","CT1_DTBLIN","D",8,0)
		TCSetField("TRBTMP","CT1_DTBLFI","D",8,0)
	EndIf
EndIf


RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ2CompQry
Obtem o saldo dos C.Custo x Conta retornando um alias TRBTMP executado com a query 


@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ2CompQry(dDataIni,dDataFim,cCCIni,cCCFim,cContaIni,cContaFim,cMoeda,cSaldos,aSetOfBook,lImpAntLP,dDataLP,lMeses,aMeses,lVlrZerado,lEntid,aEntid,cHeader,cString,cFILUSU,lAcum)

Local cQuery		:= ""
Local aAreaQry		:= {}		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local nStr			:= 0
Local nMes			:= 0
Local nColunas		:= 0

DEFAULT lMeses		:= .F.
DEFAULT lVlrZerado:= .F.
DEFAULT lEntid		:= .F.
DEFAULT lAcum		:= .F.

aAreaQry := GetArea()

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
////////////////////////////////////////////////////////////



If lMeses
	If cHeader == "CTT"
		cQuery += " SELECT * FROM (  "+ CRLF
		cQuery += " SELECT CTT_CUSTO CUSTO, CT1_CONTA CONTA, CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CTT_CLASSE TIPOCC, CTT_CCSUP CCSUP, "+ CRLF
		cQuery += " 	CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA, CT1_CLASSE TIPOCONTA, CT1_CTASUP CTASUP, CT1_GRUPO GRUPO, "+ CRLF
		cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
		
		If lMeses .and. Len(aMeses) > 0
			For nMes := 1 to Len(aMeses)
				cQuery += "  	(SELECT ISNULL(SUM(CQ3_CREDIT) - SUM(CQ3_DEBITO),0) "+ CRLF
				cQuery += " 		 	FROM "+RetSqlName("CQ3")+" CQ3 "+ CRLF
				cQuery += "   			WHERE CQ3_FILIAL = '"+xFilial("CQ3")+"' "+ CRLF
				cQuery += "   			AND CQ3_MOEDA = '"+cMoeda+"' "+ CRLF
				cQuery += "   			AND CQ3_TPSALD = '"+cSaldos+"' "+ CRLF
				cQuery += "   			AND CQ3_CCUSTO = ARQ.CTT_CUSTO "+ CRLF
				cQuery += "  			AND CQ3_CONTA = ARQ2.CT1_CONTA "+ CRLF
				If lAcum
					cQuery += " 		AND CQ3_DATA <= '"+DTOS(aMeses[nMes,3])+"' "+ CRLF
				Else
					cQuery += "    	AND CQ3_DATA BETWEEN '"+DTOS(aMeses[nMes,2])+"' AND '"+DTOS(aMeses[nMes,3])+"' "+ CRLF
				EndIf
				If lImpAntLP .and. dDataLP >= aMeses[nMes,2]
					cQuery += "	AND CQ3_LP <> 'Z' "+ CRLF
				Endif
				cQuery += "   			AND CQ3.D_E_L_E_T_ = ' ') COLUNA"+ALLTRIM(STR(nMes))+ CRLF
				If nMes < Len(aMeses)
					cQuery += ","
				Endif
			Next
		Else
			cQuery += "  	(SELECT ISNULL(SUM(CQ3_CREDIT) - SUM(CQ3_DEBITO),0) "+ CRLF
			cQuery += " 		 	FROM "+RetSqlName("CQ3")+" CQ3 "+ CRLF
			cQuery += "   			WHERE CQ3_FILIAL = '"+xFilial("CQ3")+"' "+ CRLF
			cQuery += "   			AND CQ3_MOEDA = '"+cMoeda+"' "+ CRLF
			cQuery += "   			AND CQ3_TPSALD = '"+cSaldos+"' "+ CRLF
			cQuery += "   			AND CQ3_CCUSTO = ARQ.CTT_CUSTO	 "+ CRLF
			cQuery += "  			AND CQ3_CONTA = ARQ2.CT1_CONTA "+ CRLF
			If lAcum
				cQuery += " 		AND CQ3_DATA <= '"+DTOS(dDataFim)+"' "+ CRLF
			Else
				cQuery += "			AND CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "+ CRLF
			EndIf
			If lImpAntLP .and. dDataLP >= dDataINI
				cQuery += "	AND CQ3_LP <> 'Z' "+ CRLF
			Endif
			cQuery += "   			AND CQ3.D_E_L_E_T_ = ' ') COLUNA1 "+ CRLF
		Endif
		
		cQuery += " FROM "+RetSqlName("CTT")+" ARQ, "+RetSqlName("CT1")+" ARQ2 "+ CRLF
		cQuery += " WHERE ARQ.CTT_FILIAL = '"+xFilial("CTT")+"'  	"+ CRLF
		cQuery += " AND ARQ.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "+ CRLF
		cQuery += " AND ARQ.CTT_CLASSE = '2'  	"+ CRLF
		
		If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS									//// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
			cQuery += " AND ARQ.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' 	"+ CRLF
		Endif
		
		cQuery += " AND ARQ2.CT1_FILIAL = '"+xFilial("CT1")+"'  	"+ CRLF
		cQuery += " AND ARQ2.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'  	"+ CRLF
		cQuery += " AND ARQ2.CT1_CLASSE = '2'  	"+ CRLF
		
		If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS									//// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
			cQuery += " AND ARQ2.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "+ CRLF
		Endif
		
		cQuery += " AND ARQ.D_E_L_E_T_ = ' '  	"+ CRLF
		cQuery += " AND ARQ2.D_E_L_E_T_ = ' '  	"+ CRLF

		cQuery += " ) ARQCOMP "+ CRLF
		 
		If !lVlrZerado
			If lMeses
				cQuery += " WHERE ("+ CRLF
				If lMeses .and. Len(aMeses) > 0
					For nColunas := 1 to Len(aMeses)
						cQuery += "	COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)) + " <> 0 "+ CRLF
						If nColunas <> Len(aMeses)
							cQuery += " 	OR "+ CRLF
						EndIf
					Next
				Else
					cQuery += " COLUNA1 <> 0 "+ CRLF
				EndIf
	
				cQuery += " ) "
			EndIf
		Endif
	EndIf
	
EndIf

cQuery := ChangeQuery(cQuery)

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
If lMeses
	For nColunas := 1 to Len(aMeses)
		TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
	Next
ElseIf lEntid
	For nColunas := 1 to Len(aEntid)
		TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
	Next
Else
	TcSetField("TRBTMP","COLUNA1","N",aTamVlr[1],aTamVlr[2])
EndIf

RestArea(aAreaQry)


Return
//-------------------------------------------------------------------
/*{Protheus.doc} CQ0CmpQry
Retorna o Alias TRBTMP através de query com a composição de saldos por conta 

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ0CmpQry(dDataIni,dDataFim,cContaIni,cContaFim,cMoeda,cTpSld1,cTpSld2,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,cSegAte,lVariacao0,nDivide,nGrupo,bVariacao,cIdent,lCt1Sint,cString,cFILUSU)

Local cQuery		:= ""
Local aAreaQry		:= {}		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local nStr			:= 1

DEFAULT lVariacao0	:= .F.

aAreaQry := GetArea()

cQuery += " SELECT * FROM ( " + CRLF
cQuery += " 	 SELECT CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA, " + CRLF
cQuery += "   	 	CT1_CLASSE TIPOCONTA, CT1_GRUPO GRUPO,                                                 " + CRLF

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

cQuery += " 		(SELECT ISNULL(SUM(CQ1_CREDIT) - SUM(CQ1_DEBITO),0) " + CRLF
cQuery += "  			 	FROM "+RetSqlName("CQ1")+" CQ1                                                 " + CRLF
cQuery += "   			WHERE CQ1_FILIAL = '"+xFilial("CQ1")+"'											   " + CRLF
If cTpSld1 == cTpSld2					/// Compatibilização com CTBR380 CodeBase (Se saldo1 = saldo 2 então é comparativo de moedas)
	cQuery += "    			AND CQ1_DATA <= '"+DTOS(dDataFim)+"' " + CRLF
Else
	cQuery += "    			AND CQ1_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' " + CRLF
Endif

cQuery += "   			AND CQ1_CONTA	= ARQ.CT1_CONTA                                                        " + CRLF
If cTpSld1 == cTpSld2					/// Compatibilização com CTBR380 CodeBase (Se saldo1 = saldo 2 então é comparativo de moedas)
	cQuery += "   			AND CQ1_MOEDA = '01' " + CRLF
Else
	cQuery += "   			AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
Endif
cQuery += "  			AND CQ1_TPSALD = '"+cTpSld1+"'                                                               " + CRLF
cQuery += "   			AND CQ1.D_E_L_E_T_ = ' ') MOVIMENTO1,                                    	       " + CRLF

cQuery += " 		(SELECT ISNULL(SUM(CQ1_CREDIT) - SUM(CQ1_DEBITO),0) " + CRLF
cQuery += "   			FROM "+RetSqlName("CQ1")+" CQ1                                                     " + CRLF
cQuery += "   			WHERE CQ1_FILIAL	= '"+xFilial("CQ1")+"'                                         " + CRLF
If cTpSld1 == cTpSld2					/// Compatibilização com CTBR380 CodeBase (Se saldo1 = saldo 2 então é comparativo de moedas)
	cQuery += "    			AND CQ1_DATA <= '"+DTOS(dDataFim)+"' " + CRLF
Else
	cQuery += "    			AND CQ1_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' " + CRLF
Endif
cQuery += "   			AND CQ1_CONTA	= ARQ.CT1_CONTA                                                        " + CRLF
cQuery += "   			AND CQ1_MOEDA = '"+cMoeda+"'                                                       " + CRLF
cQuery += "   			AND CQ1_TPSALD = '"+cTpSld2+"'                                                     " + CRLF
cQuery += "   			AND CQ1.D_E_L_E_T_ = ' ') MOVIMENTO2                                 	           " + CRLF
cQuery += "   	FROM "+RetSqlName("CT1")+" ARQ                                                             " + CRLF
cQuery += "   	WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'                                                " + CRLF
cQuery += "   	AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'				               " + CRLF
cQuery += "   	AND ARQ.CT1_CLASSE = '2'                                                                   " + CRLF

If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS									//// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += "   	AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "
Endif

cQuery += "   	AND ARQ.D_E_L_E_T_ = ' '                                                                    " + CRLF
cQuery += " ) ARQCOMP " + CRLF

If !lVariacao0
	cQuery += " WHERE " + CRLF
	cQuery += " MOVIMENTO1 <> 0 OR " + CRLF
	cQuery += " MOVIMENTO2 <> 0 " + CRLF
Endif

cQuery := ChangeQuery(cQuery)

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
TcSetField("TRBTMP","MOVIMENTO1","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","MOVIMENTO2","N",aTamVlr[1],aTamVlr[2])


RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ2CmpQry
Retorna alias TRBTMP com a composição dos saldos C.Custo x Conta Contabil

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ2CmpQry(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,cTpSld1,cTpSld2,aSetOfBook,lVariacao0,cString,cFILUSU)
Local cQuery		:= ""
Local aAreaQry	:= {}		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local nStr			:= 1

DEFAULT lVariacao0	:= .F.

aAreaQry := GetArea()
cQuery += " SELECT * FROM (
cQuery += " SELECT CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, CT1_DESC"+cMoeda+" DESCCTA,  	"
cQuery += " 	CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC, CT1_CLASSE TIPOCONTA,CTT_CLASSE TIPOCC,  	"
cQuery += " 	CTT_CCSUP CCSUP, CT1_GRUPO GRUPO, CT1_CTASUP SUPERIOR,"
////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

cQuery += " 	(SELECT ISNULL(SUM(CQ3_CREDIT) - SUM(CQ3_DEBITO),0) "
cQuery += "			 	FROM "+RetSqlName("CQ3")+" CQ3 "
cQuery += " 			WHERE CQ3_FILIAL = '"+xFilial("CQ3")+"'  "
cQuery += " 			AND CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
cQuery += " 			AND ARQ.CTT_CUSTO	= CQ3_CCUSTO "
cQuery += " 			AND CQ3_MOEDA = '"+cMoeda+"' "
cQuery += " 			AND CQ3_TPSALD = '"+cTpSld1+"' "
cQuery += "    			AND ARQ2.CT1_CONTA	= CQ3_CONTA "
cQuery += " 			AND CQ3.D_E_L_E_T_ = ' ') MOVIMENTO1, "
cQuery += " 		(SELECT ISNULL(SUM(CQ3_CREDIT) - SUM(CQ3_DEBITO),0) "
cQuery += " 			FROM "+RetSqlName("CQ3")+" CQ3 "
cQuery += " 			WHERE CQ3_FILIAL	= '"+xFilial("CQ3")+"' "
cQuery += " 			AND CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
cQuery += " 			AND ARQ.CTT_CUSTO	= CQ3_CCUSTO "
cQuery += " 			AND CQ3_MOEDA = '"+cMoeda+"' "
cQuery += " 			AND CQ3_TPSALD = '"+cTpSld2+"' "
cQuery += " 			AND ARQ2.CT1_CONTA	= CQ3_CONTA "
cQuery += " 			AND CQ3.D_E_L_E_T_ = ' ') MOVIMENTO2 "
cQuery += " 	FROM "+RetSqlName("CTT")+" ARQ, "+RetSqlName("CT1")+" ARQ2 "
cQuery += " 	WHERE ARQ.CTT_FILIAL = '"+xFilial("CTT")+"' "
cQuery += " 	AND ARQ.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
cQuery += " 	AND ARQ.CTT_CLASSE = '2' "

If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " 	AND ARQ.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%' "    //// FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif

cQuery += " 	AND ARQ2.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery += " 	AND ARQ2.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' "
cQuery += " 	AND ARQ2.CT1_CLASSE = '2' "

If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " 	AND ARQ2.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' "    //// FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif

cQuery += " 	AND ARQ.D_E_L_E_T_ = ' ' "
cQuery += " 	AND ARQ2.D_E_L_E_T_ = ' ' "
cQuery += " 	) ARQTMP"

If !lVariacao0
	cQuery += " WHERE " + CRLF
	cQuery += " MOVIMENTO1 <> 0 OR " + CRLF
	cQuery += " MOVIMENTO2 <> 0 " + CRLF
Endif

cQuery := ChangeQuery(cQuery)

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
TcSetField("TRBTMP","MOVIMENTO1","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","MOVIMENTO2","N",aTamVlr[1],aTamVlr[2])

RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ8CmpQry
Retorna alias TRBTMP com a composição dos saldos por Entid. C.Custo, Item ou CL.Valor 

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ8CmpQry(dDataIni,dDataFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,cTpSld1,cTpSld2,aSetOfBook,lVariacao0,cIdent,cString,cFILUSU)

Local cQuery		:= ""
Local aAreaQry		:= {}		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local nStr			:= 1

DEFAULT lVariacao0	:= .F.

DO CASE
CASE cIdent == "CTD" 
	cFieldQry	:= " CTD_ITEM ITEM	,CTD_RES ITEMRES, CTD_DESC"+cMoeda+" DESCITEM	, CTD_CLASSE TIPOITEM	, CTD_ITSUP ITSUP, "
	cOrdQry		:= "CTD_ITEM"
	cEntIni		:= cITEMIni
	cEntFim		:= cITEMFim
CASE cIdent == "CTT"
	cFieldQry	:= " CTT_CUSTO CUSTO	,CTT_RES CCRES	, CTT_DESC"+cMoeda+" DESCCC		, CTT_CLASSE TIPOCC		, CTT_CCSUP CCSUP, "
	cOrdQry		:= "CTT_CUSTO"
	cEntIni		:= cCCIni
	cEntFim		:= cCCFim
CASE cIdent == "CTH"
	cFieldQry	:= " CTH_CLVL CLVL	,CTH_RES CLVLRES, CTH_DESC"+cMoeda+" DESCCLVL	, CTH_CLASSE TIPOCLVL	, CTH_CLSUP CLSUP, "
	If Alltrim(Upper(FunName())) == "CTBR210"  
		cFieldQry	:= cFieldQry + " CTH_FILIAL FILIAL , " 
	EndIf

	If Alltrim(Upper(FunName())) == "CTBR210"   
		cOrdQry		:= "FILIAL+CTH_CLVL"
	else
		cOrdQry		:= "CTH_CLVL"
	Endif
	
	cEntIni		:= cCLVLIni
	cEntFim		:= cCLVLFim
ENDCASE

aAreaQry := GetArea()

cQuery += " SELECT * FROM ( " + CRLF

cQuery += " SELECT " +cFieldQry + CRLF
	
	////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","	+ CRLF		//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////
	
	cQuery += " 	(SELECT ISNULL(SUM(CQ9_CREDIT) - SUM(CQ9_DEBITO),0) "+ CRLF
	cQuery += "			 	FROM "+RetSqlName("CQ9")+" CQ9 "+ CRLF
	cQuery += " 			WHERE CQ9_FILIAL = '"+xFilial("CQ9")+"'  "+ CRLF
	cQuery += "				AND '"+cIdent+"' = CQ9_IDENT "+ CRLF
	cQuery += " 			AND CQ9_MOEDA = '"+cMoeda+"' "+ CRLF
	cQuery += " 			AND CQ9_TPSALD = '"+cTpSld1+"' "+ CRLF
	cQuery += " 			AND ARQ."+cOrdQry+"	= CQ9_CODIGO "+ CRLF
	cQuery += " 			AND CQ9_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "+ CRLF
	cQuery += " 			AND CQ9.D_E_L_E_T_ = ' ') MOVIMENTO1, "+ CRLF
	cQuery += " 		(SELECT ISNULL(SUM(CQ9_CREDIT) - SUM(CQ9_DEBITO),0) "+ CRLF
	cQuery += "			 	FROM "+RetSqlName("CQ9")+" CQ9 "+ CRLF
	cQuery += " 			WHERE CQ9_FILIAL = '"+xFilial("CQ9")+"'  "+ CRLF
	cQuery += "				AND '"+cIdent+"' = CQ9_IDENT "+ CRLF
	cQuery += " 			AND CQ9_MOEDA = '"+cMoeda+"' "+ CRLF
	cQuery += " 			AND CQ9_TPSALD = '"+cTpSld2+"' "+ CRLF
	cQuery += " 			AND ARQ."+cOrdQry+"	= CQ9_CODIGO "+ CRLF
	cQuery += " 			AND CQ9_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "+ CRLF
	cQuery += " 			AND CQ9.D_E_L_E_T_ = ' ') MOVIMENTO2 "+ CRLF
	cQuery += " 	FROM "+RetSqlName(cIdent)+" ARQ	" + CRLF
	cQuery += " 	WHERE ARQ."+cIdent+"_FILIAL = '"+xFilial(cIdent)+"' "+ CRLF
	cQuery += " 	AND ARQ."+cOrdQry+" BETWEEN '"+cEntIni+"' AND '"+cEntFim+"' "+ CRLF
	cQuery += " 	AND ARQ."+cIdent+"_CLASSE = '2' "+ CRLF
	
	If !Empty(aSetOfBook[1])										//// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
		cQuery += " 	AND ARQ."+cIdent+"_BOOK LIKE '%"+aSetOfBook[1]+"%' " + CRLF   //// FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
	Endif
	cQuery += " 	AND ARQ.D_E_L_E_T_ = ' ' "+ CRLF
	cQuery += " 	) SLARQ "+ CRLF
    
	If !lVariacao0
		cQuery += " WHERE " + CRLF
		cQuery += " MOVIMENTO1 <> 0 OR " + CRLF
		cQuery += " MOVIMENTO2 <> 0 " + CRLF
	Endif 
	           
	cQuery := ChangeQuery(cQuery)		   

	If Select("TRBTMP") > 0
		dbSelectArea("TRBTMP")
		dbCloseArea()
	Endif
	
  	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)
  	TcSetField("TRBTMP","MOVIMENTO1","N",aTamVlr[1],aTamVlr[2])
  	TcSetField("TRBTMP","MOVIMENTO2","N",aTamVlr[1],aTamVlr[2])

	If TRBTMP->( FieldPos(cIdent+"DTEXSF") ) > 0
		Do Case
		Case cIdent == "CTT"     
			If CtbExDtFim("CTT") 
			  	TcSetField("TRBTMP","CTTDTEXSF","D",8,0)	
			EndIf
		Case cIdent == "CTD"
			If CtbExDtFim("CTD") 
			  	TcSetField("TRBTMP","CTDDTEXSF","D",8,0)	
			EndIf
		Case cIdent == "CTH"
			If CtbExDtFim("CTH") 
			  	TcSetField("TRBTMP","CTHDTEXSF","D",8,0)	
			EndIf
		EndCase
   EndIf
	
RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ2Bln1Ent
Retorna alias TRBTMP com a composição dos saldos de  uma Entidade filtrada pela conta.  

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CQ2Bln1Ent(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,cSaldos,aSetOfBook,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)

Local cQuery		:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local cCampUSU		:= ""
Local aStrSTRU		:= {}
Local nStruLen		:= 0
Local nStr			:= 1
Local nTamRecDes	:= Len(Alltrim(cRecDesp))
Local nCont		  	:= 0
Local cQryFil	  	:= ""
Local cTmpCQ3Fil  	:= ""
Local lCTTEXDTFIM 	:= CtbExDtFim("CTT")
Local cFilRecDes  	:= ""

DEFAULT lImpAntLP	:= .F.
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT cFilUsu		:= ".T."
DEFAULT lRecDesp0	:= .F.
DEFAULT cRecDesp 	:= ""                
DEFAULT dDtZeraRD	:= CTOD("  /  /  ")

DEFAULT aSelFil		:= {}
DEFAULT lTodasFil   := .F.
DEFAULT aTmpFil		:= {}

cContaIni := Padr(cContaIni,TamSX3("CQ3_CONTA")[1])
cContaFim := Padr(cContaFim,TamSX3("CQ3_CONTA")[1])
cCCIni    := Padr(cCCIni, 	TamSX3("CTT_CUSTO")[1])
cCCFim    := Padr(cCCFim, 	TamSX3("CTT_CUSTO")[1])
cMoeda    := Padr(cMoeda, 	TamSX3("CQ3_MOEDA")[1])
cSaldos   := Padr(cSaldos, 	TamSX3("CQ3_TPSALD")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa para o filtro de filiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQryFil := " CQ3_FILIAL " + GetRngFil(aSelFil, "CQ3", .T., @cTmpCQ3Fil)
aAdd(aTmpFil, cTmpCQ3Fil)

cQuery := "WITH SALDOARQ AS ( "+CRLF
cQuery += " SELECT CQ3_CCUSTO,"+CRLF

//Tratamento para filtros nas contas
If !lImpAntLP .And. lRecDesp0                                       
	For nCont := 1 To nTamRecDes
		If nCont == 1
			cFilRecDes += " AND ((CQ3_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"				
		Else
			cFilRecDes += " AND (CQ3_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"						
		EndIf
	Next	                                                                                
	cFilRecDes += " OR "
	cFilRecDes += "("
	For nCont := 1 To nTamRecDes
		cFilRecDes += " (CQ3_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%') AND"						
	Next
	cFilRecDes += " CQ3_DATA > '" +DTOS(dDtZeraRD)+"')"        	
	cFilRecDes += ")"
EndIf

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"'"+cFilRecDes+" THEN CQ3_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"'"+cFilRecDes+" THEN CQ3_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP
	cQuery += " ,SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cSaldos+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ3")+" CQ3"+CRLF

If lTodasFil
	cQuery += " WHERE CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFil+CRLF
EndIf
cQuery += " AND CQ3_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"
cQuery += " AND CQ3.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ3_CCUSTO)"+CRLF
cQuery += " SELECT CTT_CUSTO CUSTO, CTT_RES CCRES,  CTT_DESC"+cMoeda+" DESCCC,  CTT_DESC01 DESCCC01, CTT_CLASSE TIPOCC,"+CRLF
If lCTTEXDTFIM 
	cQuery += " CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf
cQuery += " CTT_CCSUP CCSUP,"+CRLF

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU := ""								   //// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)							   //// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CTT->(dbStruct())			   //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                  //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","+CRLF //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif                
cQuery += cCampUSU							   //// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")	

cQuery += " FROM "+RetSqlName("CTT")+" ARQ"+CRLF
cQuery += "	LEFT JOIN SALDOARQ SALDOS ON ARQ.CTT_CUSTO = SALDOS.CQ3_CCUSTO"+CRLF
cQuery += " WHERE ARQ.CTT_FILIAL = '"+xFilial("CTT")+"'"+CRLF
cQuery += " AND ARQ.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CENTRO DE CUSTO DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"
If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB <> 0 OR SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])	

If lCTTEXDTFIM
	TCSetField("TRBTMP","CTTDTEXSF","D",8,0)
EndIf

RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ4Bln1Ent
Retorna alias TRBTMP com a composição dos saldos de  uma Entidade filtrada pela conta.

@author Alvaro Camillo Neto


@version P12
@since   20/02/2014
@return  Nil
@obs
*/
//-------------------------------------------------------------------

Function CQ4Bln1Ent(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
		cMoeda,cSaldos,aSetOfBook,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
		lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)
	
Local cQuery		:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local cCampUSU		:= ""
Local aStrSTRU		:= {}
Local nStruLen		:= 0
Local nStr			:= 1
Local nTamRecDes	:= Len(Alltrim(cRecDesp))
Local nCont			:= 0
Local cQryFil		:= ""
Local cTmpCQ5Fil  	:= ""
Local lCTDEXDTFIM 	:= CtbExDtFim("CTD")
Local cFilRecDes 	:= ""

DEFAULT aSelFil		:= {}
DEFAULT lTodasFil   := .F.
DEFAULT aTmpFil		:= {}
DEFAULT lImpAntLP	:= .F.
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT cFilUsu		:= ".T."
DEFAULT lRecDesp0	:= .F.
DEFAULT cRecDesp 	:= ""
DEFAULT dDtZeraRD	:= CTOD("  /  /  ")

cContaIni := Padr(cContaIni,TamSX3("CQ5_CONTA")[1])
cContaFim := Padr(cContaFim,TamSX3("CQ5_CONTA")[1])
cCCIni    := Padr(cCCIni, 	TamSX3("CQ5_CCUSTO")[1])
cCCFim    := Padr(cCCFim, 	TamSX3("CQ5_CCUSTO")[1])
cItemIni  := Padr(cItemIni, TamSX3("CQ5_ITEM")[1])
cItemFim  := Padr(cItemFim, TamSX3("CQ5_ITEM")[1])
cMoeda    := Padr(cMoeda, 	TamSX3("CQ5_MOEDA")[1])
cSaldos   := Padr(cSaldos, 	TamSX3("CQ5_TPSALD")[1])


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa para o filtro de filiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTodasFil
	cQryFil := " CQ5_FILIAL " + GetRngFil( aSelFil, "CQ5", .T., @cTmpCQ5Fil )
	aAdd(aTmpFil, cTmpCQ5Fil)
EndIf

cQuery := "WITH SALDOARQ AS ( "+CRLF
cQuery += " SELECT CQ5_ITEM,"+CRLF

//Tratamento para filtros nas contas
If !lImpAntLP .And. lRecDesp0                                       
	For nCont := 1 To nTamRecDes
		If nCont == 1
			cFilRecDes += " AND ((CQ5_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"				
		Else
			cFilRecDes += " AND (CQ5_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"						
		EndIf
	Next	                                                                                
	cFilRecDes += " OR "
	cFilRecDes += "("
	For nCont := 1 To nTamRecDes
		cFilRecDes += " (CQ5_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%') AND"						
	Next
	cFilRecDes += " CQ5_DATA > '" +DTOS(dDtZeraRD)+"')"        	
	cFilRecDes += ")"
EndIf

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"'"+cFilRecDes+" THEN CQ5_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"'"+cFilRecDes+" THEN CQ5_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP
	cQuery += " ,SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cSaldos+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ5")+" CQ5"+CRLF

If lTodasFil
	cQuery += " WHERE CQ5_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ5_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFil+CRLF
EndIf
cQuery += " AND CQ5_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
cQuery += " AND CQ5_CCUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
cQuery += " AND CQ5.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ5_ITEM)"+CRLF
cQuery += " SELECT CTD_ITEM ITEM, CTD_RES ITRES, CTD_DESC"+cMoeda+" DESCITEM,  CTD_DESC01 DESCIT01, CTD_CLASSE TIPOITEM,"+CRLF
If lCTDEXDTFIM
	cQuery += " CTD_DTEXSF CTDDTEXSF,"+CRLF
EndIf
cQuery += " CTD_ITSUP ITSUP,"+CRLF

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU := ""								   //// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)							   //// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CTD->(dbStruct())			   //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                  //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","+CRLF //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU							   //// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")	

cQuery += " FROM "+RetSqlName("CTD")+" ARQ"+CRLF
cQuery += "	LEFT JOIN SALDOARQ SALDOS ON ARQ.CTD_ITEM = SALDOS.CQ5_ITEM"+CRLF
cQuery += " WHERE ARQ.CTD_FILIAL = '"+xFilial("CTD")+"'"+CRLF
cQuery += " AND ARQ.CTD_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CENTRO DE CUSTO DO MESMO SETOFBOOKS
EndIf
cQuery += "	AND ARQ.D_E_L_E_T_ = ' '"+CRLF
If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB <> 0 OR SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

If lCTDEXDTFIM
	TCSetField("TRBTMP","CTDDTEXSF","D",8,0)
EndIf

RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ6Bln1Ent
Retorna alias TRBTMP com a composição dos saldos de  uma Entidade filtrada pela conta. 

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CQ6Bln1Ent(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,;
			cItemFim,cClVlIni,cClVlFim,	cMoeda,cSaldos,aSetOfBook,lVlrZerado,;
			lImpAntLP,dDataLP,cFilUsu,lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)

Local cQuery		:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local cCampUSU		:= ""
Local aStrSTRU		:= {}
Local nStruLen		:= 0
Local nStr			:= 1
Local nTamRecDes	:= Len(Alltrim(cRecDesp))
Local nCont			:= 0
Local cQryFil		:= ""
Local cTmpCQ7Fil	:= ""
Local lCTHEXDTFIM 	:= CtbExDtFim("CTH")
Local cFilRecDes 	:= ""

DEFAULT aSelFil		:= {}
DEFAULT lTodasFil   := .F.
DEFAULT aTmpFil		:= {}
DEFAULT lImpAntLP	:= .F.
DEFAULT dDataLP		:= CTOD("  /  /  ")
DEFAULT cFilUsu		:= ".T."
DEFAULT lRecDesp0	:= .F.
DEFAULT cRecDesp 	:= ""
DEFAULT dDtZeraRD	:= CTOD("  /  /  ")

cContaIni := Padr(cContaIni,TamSX3("CQ7_CONTA")[1])
cContaFim := Padr(cContaFim,TamSX3("CQ7_CONTA")[1])
cCCIni    := Padr(cCCIni, 	TamSX3("CQ7_CCUSTO")[1])
cCCFim    := Padr(cCCFim, 	TamSX3("CQ7_CCUSTO")[1])
cItemIni  := Padr(cItemIni, TamSX3("CQ7_ITEM")[1])
cItemFim  := Padr(cItemFim, TamSX3("CQ7_ITEM")[1])
cClVlIni  := Padr(cClVlIni, TamSX3("CTH_CLVL")[1])
cClVlFim  := Padr(cClVlFim, TamSX3("CTH_CLVL")[1])
cMoeda    := Padr(cMoeda, 	TamSX3("CQ7_MOEDA")[1])
cSaldos   := Padr(cSaldos, 	TamSX3("CQ7_TPSALD")[1])
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa para o filtro de filiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTodasFil
	cQryFil := " CQ7_FILIAL " + GetRngFil( aSelFil, "CQ7", .T., @cTmpCQ7Fil )
	aAdd(aTmpFil, cTmpCQ7Fil)
EndIf

cQuery := "WITH SALDOARQ AS ( "+CRLF
cQuery += " SELECT CQ7_CLVL,"+CRLF

//Tratamento para filtros nas contas
If !lImpAntLP .And. lRecDesp0                                       
	For nCont := 1 To nTamRecDes
		If nCont == 1
			cFilRecDes += " AND ((CQ7_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"				
		Else
			cFilRecDes += " AND (CQ7_CONTA NOT LIKE '"+Substr(cRecDesp,nCont,1)+"%')"						
		EndIf
	Next	                                                                                
	cFilRecDes += " OR "
	cFilRecDes += "("
	For nCont := 1 To nTamRecDes
		cFilRecDes += " (CQ7_CONTA LIKE '"+Substr(cRecDesp,nCont,1)+"%') AND"						
	Next
	cFilRecDes += " CQ7_DATA > '" +DTOS(dDtZeraRD)+"')"        	
	cFilRecDes += ")"
EndIf

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"'"+cFilRecDes+" THEN CQ7_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"'"+cFilRecDes+" THEN CQ7_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP
	cQuery += " ,SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cSaldos+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ7")+" CQ7"+CRLF

If lTodasFil
	cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFil+CRLF
EndIf
cQuery += " AND CQ7_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
cQuery += " AND CQ7_CCUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
cQuery += " AND CQ7_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'"+CRLF
cQuery += " AND CQ7.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ7_CLVL)"+CRLF

cQuery += " SELECT CTH_CLVL CLVL,CTH_RES CLVLRES,CTH_DESC"+cMoeda+" DESCCLVL,CTH_DESC01 DESCCV01,CTH_CLASSE TIPOCLVL,"+CRLF
If lCTHEXDTFIM
	cQuery += " CTH_DTEXSF CTHDTEXSF,"+CRLF
EndIf
cQuery += " CTH_CLSUP CLSUP,"+CRLF

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU := ""								   //// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)							   //// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CTH->(dbStruct())			   //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	For nStr := 1 to nStruLen                  //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","+CRLF //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU							   //// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CTH")+" ARQ"+CRLF
cQuery += "	LEFT JOIN SALDOARQ SALDOS ON ARQ.CTH_CLVL = SALDOS.CQ7_CLVL"+CRLF
cQuery += " WHERE ARQ.CTH_FILIAL = '"+xFilial("CTH")+"'"+CRLF
cQuery += " AND ARQ.CTH_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CLASSE DE VALOR DO MESMO SETOFBOOKS
Endif
cQuery += "	AND ARQ.D_E_L_E_T_ = ' '"+CRLF
If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB <> 0 OR SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

If lCTHEXDTFIM
	TCSetField("TRBTMP","CTHDTEXSF","D",8,0)
EndIf

RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ8BlnQry
Retorna alias TRBTMP com a composição dos saldos de uma entidade gerencial

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CQ8BlnQry(dDataIni,dDataFim,cIdent,cEntidIni,cEntidFim,cMoeda,cTpSald,;
  aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,aSelFil,lTodasFil,aTmpFil)

Local cQuery		:= ""
Local cCampUSU		:= ""
Local cFieldQry		:= ""
Local cOrdQry		:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local aStrSTRU		:= {}
Local nStruLen		:= 0   
Local nStr			:= 1
Local cQryFil		:= ""
Local cTmpCQ9Fil 	:= ""
Local cTmpIdeFil 	:= ""
Local cCpoFilQry 	:= ""

DEFAULT aSelFil		:= {}
DEFAULT lTodasFil 	:= .F.
DEFAULT aTmpFil		:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa para o filtro de filiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQryFil := " CQ9_FILIAL " + GetRngFil(aSelFil, "CQ9", .T., @cTmpCQ9Fil)
aAdd(aTmpFil, cTmpCQ9Fil)

DO CASE
CASE cIdent == "CTD"
	cFieldQry := " CTD_ITEM ITEM,CTD_RES ITEMRES,CTD_DESC"+cMoeda+" DESCITEM,CTD_DESC01 DESCIT01,CTD_CLASSE TIPOITEM,CTD_ITSUP ITSUP,CTD_NORMAL ITNORMAL,"
	If CtbExDtFim("CTD") 
		cFieldQry += " CTD_DTEXSF CTDDTEXSF,"	
	EndIf
	cOrdQry	:= "CTD_ITEM"
	If !Empty( FwFilial("CTD")) .And. !Empty( xFilial("CQ9")) 
		cCpoFilQry := "CTD_FILIAL"
	EndIf	
CASE cIdent == "CTT"
	cFieldQry	:= " CTT_CUSTO CUSTO,CTT_RES CCRES, CTT_DESC"+cMoeda+" DESCCC,CTT_DESC01 DESCCC01,CTT_CLASSE TIPOCC,CTT_CCSUP CCSUP,CTT_NORMAL CCNORMAL,"
	If CtbExDtFim("CTT") 
		cFieldQry += " CTT_DTEXSF CTTDTEXSF,"	
	EndIf	
	cOrdQry	:= "CTT_CUSTO"
	If !Empty( FwFilial("CTT")) .And. !Empty(xFilial("CQ9"))
		cCpoFilQry := "CTT_FILIAL"
	EndIf			
CASE cIdent == "CTH"   
	cFieldQry := " CTH_CLVL CLVL,CTH_RES CLVLRES,CTH_DESC"+cMoeda+" DESCCLVL, CTH_DESC01 DESCCV01, CTH_CLASSE TIPOCLVL, CTH_CLSUP CLSUP, CTH_NORMAL CLNORMAL,"	
	If AllTrim(Upper(FunName())) == "CTBR210"  
		cFieldQry := cFieldQry + " CTH_FILIAL FILIAL,"
	EndIf	
	If CtbExDtFim("CTH") 
		cFieldQry += " CTH_DTEXSF CTHDTEXSF,"	
	EndIf		
	cOrdQry	:= "CTH_CLVL"	
	If !Empty(FwFilial("CTH")) .And. !Empty(xFilial("CQ9"))
		cCpoFilQry := "CTH_FILIAL"
	EndIf	
ENDCASE

cEntidIni := Padr(cEntidIni, TamSX3(cOrdQry)[1])
cEntidFim := Padr(cEntidFim, TamSX3(cOrdQry)[1])
cMoeda    := Padr(cMoeda, TamSX3("CQ9_MOEDA")[1])
cTpSald   := Padr(cTpSald, TamSX3("CQ9_TPSALD")[1])
                  
aAreaQry := GetArea()

cQuery := "WITH SALDOARQ AS ( "+CRLF
If !Empty(cCpoFilQry)
	cQuery += " SELECT CQ9_FILIAL,CQ9_CODIGO,"+CRLF
Else
	cQuery += " SELECT CQ9_CODIGO,"+CRLF
EndIf

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ9_DATA < '"+DTOS(dDataIni)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' THEN CQ9_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ9_DATA < '"+DTOS(dDataIni)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' THEN CQ9_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ9_DATA < '"+DTOS(dDataIni)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' AND CQ9_LP = 'Z' AND"
	cQuery += " ((CQ9_DTLP <> ' ' AND CQ9_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ9_DTLP = '' AND CQ9_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ9_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ9_DATA < '"+DTOS(dDataIni)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' AND CQ9_LP = 'Z' AND"
	cQuery += " ((CQ9_DTLP <> ' ' AND CQ9_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ9_DTLP = '' AND CQ9_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ9_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ9_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' THEN CQ9_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ9_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' THEN CQ9_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP
	cQuery += " ,SUM(CASE WHEN CQ9_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' AND CQ9_LP = 'Z' AND"
	cQuery += " ((CQ9_DTLP <> ' ' AND CQ9_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ9_DTLP = '' AND CQ9_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ9_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ9_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ9_TPSALD = '"+cTpSald+"' AND CQ9_MOEDA = '"+cMoeda+"' AND CQ9_LP = 'Z' AND"
	cQuery += " ((CQ9_DTLP <> ' ' AND CQ9_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ9_DTLP = '' AND CQ9_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ9_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf

cQuery += " FROM "+RetSqlName("CQ9")+" CQ9"+CRLF
cQuery += " WHERE "+cQryFil+CRLF
cQuery += "	AND CQ9_IDENT = '"+cIdent+"'"+CRLF
cQuery += " AND CQ9.D_E_L_E_T_ = ' '"+CRLF
If !Empty(cCpoFilQry)
	cQuery += " GROUP BY CQ9_FILIAL,CQ9_CODIGO)"+CRLF
Else
	cQuery += " GROUP BY CQ9_CODIGO)"+CRLF
EndIf
cQuery += " SELECT "+cFieldQry+CRLF

///////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU := ""								   //// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)							   //// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cIdent)->(dbStruct())		   //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 To nStruLen                  //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","+CRLF //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU							   //// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName(cIdent)+" ARQ"+CRLF
cQuery += "	LEFT JOIN SALDOARQ SALDOS ON ARQ."+cOrdQry+" = SALDOS.CQ9_CODIGO"+CRLF
If !Empty(cCpoFilQry)
	cQuery += " 	AND  ARQ."+cCpoFilQry+" = SALDOS.CQ9_FILIAL "
Endif
If Len(aSelFil) > 0
	cQuery += " WHERE ARQ."+cIdent+"_FILIAL "+GetRngFil(aSelFil, cIdent, .T., @cTmpIdeFil)+CRLF
	aAdd(aTmpFil, cTmpIdeFil)
Else
	cQuery += " WHERE ARQ."+cIdent+"_FILIAL "+GetRngFil(aSelFil, cIdent, .T., @cTmpIdeFil)+CRLF
EndIf
cQuery += " AND ARQ."+cIdent+"_CLASSE = '2'"+CRLF
cQuery += " AND ARQ."+cOrdQry+" BETWEEN '"+cEntidIni+"' AND '"+cEntidFim+"'"+CRLF
If !Empty(aSetOfBook[1]) //// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ."+cIdent+"_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF //// FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " AND (SALDOANTDB <> 0 OR SALDOANTCR <> 0 OR SALDODEB <> 0 OR SALDOCRD <> 0)"
EndIf

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])	    

If cIdent == "CTT" .And. CtbExDtFim("CTT") 
	TcSetField("TRBTMP","CTTDTEXSF","D",8,0)	    
ElseIf cIdent == "CTD" .And. CtbExDtFim("CTD") 
	TcSetField("TRBTMP","CTDDTEXSF","D",8,0)	    
ElseIf cIdent == "CTH".And. CtbExDtFim("CTH") 
	TcSetField("TRBTMP","CTHDTEXSF","D",8,0)	    
EndIf

If lImpAntLP
	TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])	
	TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])	
	TcSetField("TRBTMP","MOVLPDEB","N",aTamVlr[1],aTamVlr[2])	
	TcSetField("TRBTMP","MOVLPCRD","N",aTamVlr[1],aTamVlr[2])	    
EndIf

RestArea(aAreaQry)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CQ2Bln3Ent
Retorna alias TRBTMP com a composição dos saldos CC x Conta x Item. 

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ2Bln3Ent(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cMoeda,;
					cTpSald,aSetOfBook,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil,lCTBR185SV)	

Local cQuery		:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr		:= TAMSX3("CT2_VALOR")
Local cCampUSU		:= ""
Local aStrSTRU   	:= {}
Local nStruLen    	:= 0
Local nStr        	:= 0
Local lCT1EXDTFIM 	:= CtbExDtFim("CT1") 
Local cQryFil		:= ""
Local cTmpCQ5Fil	:= ""
                             
DEFAULT cFilUsu		:= ""
DEFAULT aSelFil		:= {}
DEFAULT lTodasFil 	:= .F.
DEFAULT aTmpFil		:= {}
DEFAULT lCTBR185SV 	:= .F.

cContaIni := Padr(cContaIni,TamSX3("CT1_CONTA")[1])
cContaFim := Padr(cContaFim,TamSX3("CT1_CONTA")[1])
cCCIni    := Padr(cCCIni, 	TamSX3("CTT_CUSTO")[1])
cCCFim    := Padr(cCCFim, 	TamSX3("CTT_CUSTO")[1])
cItemIni  := Padr(cItemIni, TamSX3("CTD_ITEM")[1])
cItemFim  := Padr(cItemFim, TamSX3("CTD_ITEM")[1])
cMoeda    := Padr(cMoeda, 	TamSX3("CQ5_MOEDA")[1])
cTpSald   := Padr(cTpSald, 	TamSX3("CQ5_TPSALD")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa para o filtro de filiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTodasFil
	cQryFil := " CQ5_FILIAL "+GetRngFil(aSelFil, "CQ5", .T., @cTmpCQ5Fil)
	aAdd(aTmpFil, cTmpCQ5Fil)
EndIf                            

cQuery += "WITH CTDITENS AS ("+CRLF
cQuery += "	SELECT CTD_ITEM"+CRLF
cQuery += "	FROM "+RetSqlName("CTD")+CRLF
cQuery += "	WHERE CTD_FILIAL = '"+xFilial("CTD")+"'"+CRLF
cQuery += "	AND CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'"+CRLF
cQuery += "	AND CTD_CLASSE = '2'"+CRLF
cQuery += "	AND D_E_L_E_T_ = ' '),"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += "	SALDOARQ AS ("+CRLF
cQuery += "	SELECT CQ5_CONTA,CQ5_CCUSTO,CQ5_ITEM,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_DEBITO IS NOT NULL AND CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_CREDIT IS NOT NULL AND CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ5_DEBITO IS NOT NULL AND CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_CREDIT IS NOT NULL AND CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ5_DEBITO IS NOT NULL AND CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_CREDIT IS NOT NULL AND CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ5_DEBITO IS NOT NULL AND CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_CREDIT IS NOT NULL AND CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf
cQuery += " FROM "+RetSqlName("CQ5")+" CQ5"+CRLF
If lTodasFil
	cQuery += " WHERE CQ5_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ5_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
Else
	cQuery += " WHERE "+cQryFil+CRLF
EndIf 
cQuery += " AND CQ5_ITEM IN (SELECT CTD_ITEM FROM CTDITENS)"+CRLF
cQuery += " AND CQ5.D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ5_CONTA, CQ5_CCUSTO, CQ5_ITEM)"+CRLF
If TCGetDb() == "POSTGRES"		
	cQuery += " SELECT CHAR(3) 'CQ3' ALIAS,' ' ITEM, CTT_CUSTO CUSTO, CT1_CONTA CONTA,"+CRLF
Else
	cQuery += " SELECT 'CQ3' ALIAS,' ' ITEM, CTT_CUSTO CUSTO, CT1_CONTA CONTA,"+CRLF
EndIf
cQuery += " CT1_NORMAL NORMAL, CT1_RES CTARES, CT1_CTASUP SUPERIOR, CT1_CLASSE TIPOCONTA,"+CRLF
cQuery += " CTT_RES CCRES, CTT_CCSUP CCSUP,  CTT_CLASSE TIPOCC,"+CRLF
cQuery += " ' ' ITEMRES, ' ' TIPOITEM,"+CRLF
If lCT1EXDTFIM
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTT") 
	cQuery += " CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf                           
If ctbExDtFim("CTD")
	cQuery += " ' ' CTDDTEXSF,"+CRLF
EndIf
If cMoeda == "01"
	cQuery += "	CT1_DESC01 DESCCTA, CTT_DESC01 DESCCC, ' ' DESCITEM,"+CRLF                                                   	
Else
	cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CTT_DESC"+cMoeda+" DESCCC, CT1_DESC01 DESCCTA01, CTT_DESC01 DESCCC01, ' ' DESCITEM, ' ' DESCIT01,"+CRLF
EndIf

//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU := ""									//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)								//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT1->(dbStruct())			    //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                  //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","+CRLF //// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
EndIf 
cQuery += cCampUSU //// ADICIONA OS CAMPOS DO FILTRO DE USUARIO NA QUERY

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CTT")+" ARQ"+CRLF
cQuery += " LEFT JOIN SALDOARQ SALDOS ON ARQ.CTT_CUSTO = SALDOS.CQ5_CCUSTO"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CT1")+" ARQ2 ON SALDOS.CQ5_CONTA = ARQ2.CT1_CONTA"+CRLF
cQuery += " WHERE ARQ.CTT_FILIAL = '"+xFilial("CTT")+"'"+CRLF
cQuery += " AND ARQ.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ2.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF
cQuery += " AND ARQ2.CT1_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If Alltrim(Upper(FunName())) == "CTBR185" .Or.(lIsSmartView .And. lCTBR185SV)
	cQuery += " AND ARQ2.CT1_CONTA IN (SELECT CQ5_CONTA FROM "+RetSqlName("CQ5")+" WHERE CQ5_FILIAL = '"+ xFilial("CQ5") +"' AND D_E_L_E_T_ = ' ' GROUP BY CQ5_CONTA)"+CRLF
EndIf
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ2.D_E_L_E_T_ = ' '"+CRLF

cQuery += " AND (COALESCE(SALDOS.SALDOANTDB, 0) <> 0 OR COALESCE(SALDOS.SALDOANTCR, 0) <> 0 OR COALESCE(SALDOS.SALDODEB, 0) <> 0 OR COALESCE(SALDOS.SALDOCRD, 0) <> 0)"+CRLF

/////////////////////////////////////////////////////////////////////////
///////////////// FILTRA OS CENTROS DE CUSTO + ITEM//////////////////////
/////////////////////////////////////////////////////////////////////////

cQuery += " UNION"+CRLF
                
If TCGetDb() == "POSTGRES"		
	cQuery += " SELECT CHAR(3) 'CQ5' ALIAS, CTD_ITEM ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,"+CRLF
Else	
	cQuery += " SELECT 'CQ5' ALIAS, CTD_ITEM ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,"+CRLF
EndIf
cQuery += " CT1_NORMAL NORMAL, CT1_RES CTARES, CT1_CTASUP SUPERIOR, CT1_CLASSE TIPOCONTA,"+CRLF
cQuery += " CTT_RES CCRES, CTT_CCSUP CCSUP,  CTT_CLASSE TIPOCC,"+CRLF
cQuery += " CTD_RES ITEMRES, CTD_CLASSE TIPOITEM,"+CRLF

If lCT1EXDTFIM
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTT") 
	cQuery += " CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTD") 
	cQuery += " CTD_DTEXSF CTDDTEXSF,"+CRLF
EndIf                           

If cMoeda == "01"
	cQuery += "	CT1_DESC01 DESCCTA, CTT_DESC01 DESCCC, CTD_DESC01 DESCITEM,"+CRLF
Else
	cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CTT_DESC"+cMoeda+" DESCCC, CT1_DESC01 DESCCTA01, CTT_DESC01 DESCCC01, CTD_DESC01 DESCIT01, CTD_DESC"+cMoeda+" DESCITEM,"+CRLF
EndIf

cQuery += cCampUSU //// ADICIONA OS CAMPOS DO FILTRO DE USUARIO NA QUERY

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += " LEFT JOIN SALDOARQ SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ5_CONTA"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTT")+" ARQ2 ON SALDOS.CQ5_CCUSTO = ARQ2.CTT_CUSTO"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTD")+" ARQ3 ON SALDOS.CQ5_ITEM = ARQ3.CTD_ITEM"
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF
cQuery += " AND ARQ.CT1_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If Alltrim(Upper(FunName())) == "CTBR185" .Or. (lIsSmartView .And. lCTBR185SV)
	cQuery += " AND ARQ.CT1_CONTA IN (SELECT CQ5_CONTA FROM "+RetSqlName("CQ5")+" WHERE CQ5_FILIAL = '"+ xFilial("CQ5")+"' AND D_E_L_E_T_ = ' ' GROUP BY CQ5_CONTA)"+CRLF
EndIf
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'"+CRLF
cQuery += " AND ARQ2.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'"+CRLF
cQuery += " AND ARQ3.CTD_CLASSE = '2'"+CRLF
cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF  // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf
cQuery += " AND ARQ3.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND (COALESCE(SALDOS.SALDOANTDB, 0) <> 0 OR COALESCE(SALDOS.SALDOANTCR, 0) <> 0 OR COALESCE(SALDOS.SALDODEB, 0) <> 0 OR COALESCE(SALDOS.SALDOCRD, 0) <> 0)"

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])	

If lCT1EXDTFIM 
	TcSetField("TRBTMP","CT1DTEXSF","D",8,0)	
	TCSetField("TRBTMP","CT1_DTEXSF","D",8,0)	
	TCSetField("TRBTMP","CT1_DTEXIS","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLIN","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLFI","D",8,0)
EndIf

If CtbExDtFim("CTD") 
	TcSetField("TRBTMP","CTDDTEXSF","D",8,0)	
EndIf

If CtbExDtFim("CTT") 
	TcSetField("TRBTMP","CTTDTEXSF","D",8,0)	
EndIf


RestArea(aAreaQry)

Return	

//-------------------------------------------------------------------
/*{Protheus.doc} CQ6Bln4Ent
Retorna alias TRBTMP com a composição dos saldos CC x Conta x Item X Cl.Valor  

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ6Bln4Ent(dDataIni,dDataFim,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cClVlIni,cClVlFim,cMoeda,cTpSald,aSetOfBook,lImpAntLp,dDataLP,aSelFil,lTodasFil,aTmpFil,cTmpArq,nLimTmp)

Local cQuery	  := ""
Local cQueryAux   := ""
Local aAreaQry	  := GetArea() /// array com a posição no arquivo original
Local aTamVlr	  := TAMSX3("CT2_VALOR")
Local lCT1EXDTFIM := CtbExDtFim("CT1") 
Local cQryFilCQ3  := ""
Local cQryFilCQ5  := ""
Local cQryFilCQ7  := ""
Local cTmpCQ3Fil  := ""
Local cTmpCQ5Fil  := ""
Local cTmpCQ7Fil  := ""
Local lCtbr195    := IIf(FwIsInCallStack("CTBR195") .OR. (FunName() == "CTBR195"), .T., .F.)

DEFAULT aSelFil	  := {}
DEFAULT lTodasFil := .F.
DEFAULT aTmpFil	  := {}
DEFAULT cTmpArq   := ""
DEFAULT nLimTmp	  := 10

cContaIni := Padr(cContaIni, TamSX3("CT1_CONTA")[1])
cContaFim := Padr(cContaFim, TamSX3("CT1_CONTA")[1])
cCCIni    := Padr(cCCIni, TamSX3("CTT_CUSTO")[1])
cCCFim    := Padr(cCCFim, TamSX3("CTT_CUSTO")[1])
cItemIni  := Padr(cItemIni, TamSX3("CTD_ITEM")[1])
cItemFim  := Padr(cItemFim, TamSX3("CTD_ITEM")[1])
cClVlIni  := Padr(cClVlIni, TamSX3("CTH_CLVL")[1])
cClVlFim  := Padr(cClVlFim, TamSX3("CTH_CLVL")[1])
cMoeda    := Padr(cMoeda, TamSX3("CQ3_MOEDA")[1])
cTpSald   := Padr(cTpSald, TamSX3("CQ3_TPSALD")[1])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa para o filtro de filiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTodasFil
	cQryFilCQ3 := " CQ3_FILIAL " + GetRngFil( aSelFil, "CQ3", .T., @cTmpCQ3Fil, nLimTmp )
	aAdd(aTmpFil, cTmpCQ3Fil)
	cQryFilCQ5 := " CQ5_FILIAL " + GetRngFil( aSelFil, "CQ5", .T., @cTmpCQ5Fil, nLimTmp )
	aAdd(aTmpFil, cTmpCQ5Fil)
	cQryFilCQ7 := " CQ7_FILIAL " + GetRngFil( aSelFil, "CQ7", .T., @cTmpCQ7Fil, nLimTmp )
	aAdd(aTmpFil, cTmpCQ7Fil)
EndIf

cQuery += " WITH CQ3_SALDOS AS ("
cQuery += " SELECT CQ3_CCUSTO, CQ3_CONTA,"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ3_DATA < '"+DTOS(dDataIni)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' THEN CQ3_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ3_TPSALD = '"+cTpSald+"' AND CQ3_MOEDA = '"+cMoeda+"' AND CQ3_LP = 'Z' AND"
	cQuery += " ((CQ3_DTLP <> ' ' AND CQ3_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ3_DTLP = '' AND CQ3_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ3_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf
cQuery += " FROM "+RetSqlName("CQ3")+CRLF
If lTodasFil
	cQuery += " WHERE CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF		
Else
	cQuery += " WHERE "+cQryFilCQ3+CRLF
EndIf
cQuery += " AND D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ3_CCUSTO, CQ3_CONTA),"+CRLF

cQuery += " CQ5_SALDOS AS ("+CRLF
cQuery += " SELECT CQ5_CCUSTO, CQ5_CONTA, CQ5_ITEM,"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_DATA < '"+DTOS(dDataIni)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' THEN CQ5_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ5_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ5_TPSALD = '"+cTpSald+"' AND CQ5_MOEDA = '"+cMoeda+"' AND CQ5_LP = 'Z' AND"
	cQuery += " ((CQ5_DTLP <> ' ' AND CQ5_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ5_DTLP = '' AND CQ5_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ5_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf
cQuery += " FROM "+RetSqlName("CQ5")+CRLF
If lTodasFil
	cQuery += " WHERE CQ5_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ5_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF		
Else
	cQuery += " WHERE "+cQryFilCQ5+CRLF
EndIf
cQuery += " AND D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ5_CCUSTO, CQ5_CONTA, CQ5_ITEM),"+CRLF
cQuery += " CQ7_SALDOS AS ("+CRLF
cQuery += " SELECT CQ7_CCUSTO, CQ7_CONTA, CQ7_ITEM, CQ7_CLVL,"+CRLF

// ---------------------------  Saldo Anterior ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_DEBITO ELSE 0 END) AS SALDOANTDB,"+CRLF
cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_CREDIT ELSE 0 END) AS SALDOANTCR,"+CRLF
If lImpAntLP
	cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_DEBITO ELSE 0 END) AS SLDLPANTDB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ7_DATA < '"+DTOS(dDataIni)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_CREDIT ELSE 0 END) AS SLDLPANTCR,"+CRLF
EndIf

// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_DEBITO ELSE 0 END) AS SALDODEB,"+CRLF
cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' THEN CQ7_CREDIT ELSE 0 END) AS SALDOCRD"+CRLF
If lImpAntLP	
	cQuery += " ,SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_DEBITO ELSE 0 END) AS MOVLPDEB,"+CRLF
	cQuery += " SUM(CASE WHEN CQ7_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' AND CQ7_TPSALD = '"+cTpSald+"' AND CQ7_MOEDA = '"+cMoeda+"' AND CQ7_LP = 'Z' AND"
	cQuery += " ((CQ7_DTLP <> ' ' AND CQ7_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ7_DTLP = '' AND CQ7_DATA >= '"+DTOS(dDataLP)+"')) THEN CQ7_CREDIT ELSE 0 END) AS MOVLPCRD"+CRLF
EndIf
cQuery += " FROM "+RetSqlName("CQ7")+CRLF
If lTodasFil
	cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
	cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF		
Else
	cQuery += " WHERE "+cQryFilCQ7+CRLF
EndIf
cQuery += " AND D_E_L_E_T_ = ' '"+CRLF
cQuery += " GROUP BY CQ7_CCUSTO, CQ7_CONTA, CQ7_ITEM, CQ7_CLVL)"+CRLF

cQueryAux := cQuery

If TCGetDb() == "POSTGRES"		
	cQuery += " SELECT CHAR(3) 'CQ3' ALIAS, ' ' CLVL, ' ' ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
Else
	cQuery += " SELECT 'CQ3' ALIAS, '' CLVL, ' ' ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
EndIf
cQuery += " CT1_CTASUP SUPERIOR, CTT_RES CCRES, CTT_CCSUP CCSUP, CT1_CLASSE TIPOCONTA, CTT_CLASSE TIPOCC,"+CRLF
cQuery += " ' ' ITEMRES, ' ' TIPOITEM, ' ' CLVLRES, ' ' CLSUP,' ' TIPOCLVL,"+CRLF
If lCT1EXDTFIM
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTT") 
	cQuery += " CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf                           
If ctbExDtFim("CTD")
	cQuery += " ' ' CTDDTEXSF,"+CRLF
EndIf
If ctbExDtFim("CTH")
	cQuery += " ' ' CTHDTEXSF,"+CRLF
EndIf
If cMoeda == "01"
	cQuery += " CT1_DESC01 DESCCTA, CTT_DESC01 DESCCC, ' ' DESCITEM, ' ' DESCCLVL,"+CRLF
Else
	cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CTT_DESC"+cMoeda+" DESCCC, CT1_DESC01 DESCCTA01, CTT_DESC01 DESCCC01, ' ' DESCITEM, ' ' DESCIT01,  ' ' DESCCLVL, ' ' DESCCV01,"+CRLF
EndIf

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += " LEFT JOIN CQ3_SALDOS SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ3_CONTA"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTT")+" ARQ2 ON SALDOS.CQ3_CCUSTO = ARQ2.CTT_CUSTO"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF
cQuery += " AND ARQ.CT1_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
If lCtbr195
	cQuery += " AND ARQ.CT1_CONTA IN (SELECT CQ3_CONTA"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ3")+" CQ3AUX"+CRLF
	If lTodasFil
		cQuery += " WHERE CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ3+CRLF
	EndIf	
	cQuery += " AND CQ3AUX.CQ3_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ3AUX.CQ3_MOEDA  = '"+cMoeda+"'"+CRLF	
	cQuery += " AND CQ3AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ3AUX.CQ3_CONTA)"+CRLF
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND  ARQ2.CTT_FILIAL ='"+xFilial("CTT")+"'"+CRLF
cQuery += " AND ARQ2.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf
If lCtbr195
	cQuery += " AND ARQ2.CTT_CUSTO IN (SELECT  CQ3_CCUSTO"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ3")+" CQ3AUX "+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ3_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ3_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ3+CRLF
	EndIf		
	cQuery += " AND CQ3AUX.CQ3_MOEDA  = '"+cMoeda+"'"+CRLF
	cQuery += " AND CQ3AUX.CQ3_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " GROUP BY CQ3AUX.CQ3_CCUSTO)"+CRLF
EndIf
cQuery += " AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND (COALESCE(SALDOS.SALDOANTDB, 0) <> 0 OR COALESCE(SALDOS.SALDOANTCR, 0) <> 0 OR COALESCE(SALDOS.SALDODEB, 0) <> 0 OR COALESCE(SALDOS.SALDOCRD, 0) <> 0)"+CRLF

cQuery += " UNION "+CRLF

If TCGetDb() == "POSTGRES"		
	cQuery += " SELECT CHAR(3) 'CQ5' ALIAS,' ' CLVL, CTD_ITEM ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
Else	
	cQuery += " SELECT 'CQ5' ALIAS, ' ' CLVL, CTD_ITEM ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
EndIf
cQuery += " CT1_CTASUP SUPERIOR, CTT_RES CCRES, CTT_CCSUP CCSUP, CT1_CLASSE TIPOCONTA, CTT_CLASSE TIPOCC,"+CRLF
cQuery += " CTD_RES ITEMRES, CTD_CLASSE TIPOITEM, ' ' CLVLRES, ' ' CLSUP, ' ' TIPOCLVL, "+CRLF
If CtbExDtFim("CT1") 
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTT") 
	cQuery += " CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf                           
If ctbExDtFim("CTD")
	cQuery += " CTD_DTEXSF CTDDTEXSF,"+CRLF
EndIf
If ctbExDtFim("CTH")
	cQuery += " ' ' CTHDTEXSF,"+CRLF
EndIf
If cMoeda == "01"
	cQuery += "	CT1_DESC01 DESCCTA, CTT_DESC01 DESCCC,  CTD_DESC01 DESCITEM, ' ' DESCCLVL,"+CRLF
Else
	cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CTT_DESC"+cMoeda+" DESCCC, CT1_DESC01 DESCCTA01,"+CRLF
	cQuery += " CTT_DESC01 DESCCC01, CTD_DESC01 DESCIT01, CTD_DESC"+cMoeda+" DESCITEM,"+CRLF                                             	
	cQuery += " ' ' DESCV01, ' ' DESCCLVL, "+CRLF
EndIf

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += " LEFT JOIN CQ5_SALDOS SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ5_CONTA"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTT")+" ARQ2 ON SALDOS.CQ5_CCUSTO = ARQ2.CTT_CUSTO"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTD")+" ARQ3 ON SALDOS.CQ5_ITEM = ARQ3.CTD_ITEM"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF
cQuery += " AND ARQ.CT1_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
If lCtbr195
	cQuery += " AND ARQ.CT1_CONTA IN (SELECT  CQ5_CONTA"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ5")+" CQ5AUX "+CRLF
	If lTodasFil
		cQuery += " WHERE CQ5_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ5_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ5+CRLF
	EndIf
	cQuery += " AND CQ5AUX.CQ5_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ5AUX.CQ5_MOEDA  = '"+cMoeda+"'"+CRLF	
	cQuery += " AND CQ5AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ5AUX.CQ5_CONTA)"+CRLF
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'"+CRLF
cQuery += " AND ARQ2.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf                                      
If lCtbr195
	cQuery += " AND ARQ2.CTT_CUSTO IN (SELECT  CQ5_CCUSTO"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ5")+" CQ5AUX "+CRLF
	If lTodasFil
		cQuery += " WHERE CQ5_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ5_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ5+CRLF
	EndIf		
	cQuery += " AND CQ5AUX.CQ5_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ5AUX.CQ5_MOEDA = '"+cMoeda+"'"+CRLF	
	cQuery += " AND CQ5AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ5AUX.CQ5_CCUSTO) "+CRLF
endIf
cQuery += " AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'"+CRLF
cquery += " AND ARQ3.CTD_CLASSE = '2'"+CRLF
cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf                                      
If lCtbr195
	cQuery += " AND ARQ3.CTD_ITEM IN (SELECT  CQ5_ITEM"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ5")+" CQ5AUX"+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ5_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ5_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ5+CRLF
	EndIf
	cQuery += " AND CQ5AUX.CQ5_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ5AUX.CQ5_MOEDA = '"+cMoeda+"'"+CRLF	
	cQuery += " AND CQ5AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ5AUX.CQ5_ITEM) "+CRLF
EndIf
cQuery += "	AND ARQ3.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND (COALESCE(SALDOS.SALDOANTDB, 0) <> 0 OR COALESCE(SALDOS.SALDOANTCR, 0) <> 0 OR COALESCE(SALDOS.SALDODEB, 0) <> 0 OR COALESCE(SALDOS.SALDOCRD, 0) <> 0)"+CRLF

cQuery += " UNION "+CRLF

If TCGetDb() == "POSTGRES"		
	cQuery += " SELECT CHAR(3) 'CQ7' ALIAS, CTH_CLVL CLVL, CTD_ITEM ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
Else	
	cQuery += " SELECT 'CQ7' ALIAS, CTH_CLVL CLVL, CTD_ITEM ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
EndIf
cQuery += "	CT1_CTASUP SUPERIOR, CTT_RES CCRES, CTT_CCSUP CCSUP, CT1_CLASSE TIPOCONTA, CTT_CLASSE TIPOCC,"+CRLF
cQuery += "	CTD_RES ITEMRES, CTD_CLASSE TIPOITEM, CTH_RES CLVLRES, CTH_CLSUP CLSUP, CTH_CLASSE TIPOCLVL,"+CRLF
If CtbExDtFim("CT1") 
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTT") 
	cQuery += " CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf                           
If ctbExDtFim("CTD")
	cQuery += " CTD_DTEXSF CTDDTEXSF,"+CRLF
EndIf
If ctbExDtFim("CTH")
	cQuery += " CTH_DTEXSF CTHDTEXSF,"+CRLF
EndIf
If cMoeda == "01"
	cQuery += "	CT1_DESC01 DESCCTA, CTT_DESC01 DESCCC,  CTD_DESC01 DESCITEM, CTH_DESC01 DESCCLVL,"+CRLF                                              	
Else
	cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CTT_DESC"+cMoeda+" DESCCC, CT1_DESC01 DESCCTA01,"+CRLF
	cQuery += "	CTT_DESC01 DESCCC01, CTD_DESC01 DESCIT01, CTD_DESC"+cMoeda+" DESCITEM,"+CRLF
	cQuery += " CTH_DESC01 DESCCV01, CTH_DESC"+cMoeda+" DESCCLVL,"+CRLF                       	
EndIf

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += " LEFT JOIN CQ7_SALDOS SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ7_CONTA"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTT")+" ARQ2 ON SALDOS.CQ7_CCUSTO = ARQ2.CTT_CUSTO"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTD")+" ARQ3 ON SALDOS.CQ7_ITEM = ARQ3.CTD_ITEM"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTH")+" ARQ4 ON SALDOS.CQ7_CLVL = ARQ4.CTH_CLVL"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF
cQuery += " AND ARQ.CT1_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF// FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
If lCtbr195
	cQuery += " AND ARQ.CT1_CONTA IN (SELECT  CQ7_CONTA"+CRLF 
	cQuery += " FROM " + RetSQLName("CQ7")+" CQ7AUX"+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ7+CRLF
	EndIf
	cQuery += " AND CQ7AUX.CQ7_TPSALD = '"+cTpSald+"'"+CRLF 	
	cQuery += " AND CQ7AUX.CQ7_MOEDA  = '"+cMoeda+"'"+CRLF
	cQuery += " AND CQ7AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ7AUX.CQ7_CONTA)"+CRLF 
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'"+CRLF
cQuery += " AND ARQ2.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF// FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf
If lCtbr195
	cQuery += " AND ARQ2.CTT_CUSTO IN (SELECT  CQ7_CCUSTO"+CRLF 
	cQuery += " FROM " + RetSQLName("CQ7")+" CQ7AUX"+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ7+CRLF
	EndIf
	cQuery += " AND CQ7AUX.CQ7_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ7AUX.CQ7_MOEDA  = '"+cMoeda+"'"+CRLF
	cQuery += " AND CQ7AUX.D_E_L_E_T_ = ' '"+CRLF	
	cQuery += " GROUP BY CQ7AUX.CQ7_CCUSTO) "+CRLF 
EndIf
cQuery += " AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ3.CTD_FILIAL = '"+xFilial("CTD")+"'"+CRLF
cquery += " AND ARQ3.CTD_CLASSE = '2'"+CRLF
cQuery += " AND ARQ3.CTD_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ3.CTD_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF// FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf                                      
If lCtbr195
	cQuery += " AND ARQ3.CTD_ITEM IN (SELECT CQ7_ITEM"+CRLF 
	cQuery += " FROM " + RetSQLName("CQ7")+" CQ7AUX"+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ7+CRLF
	EndIf
	cQuery += " AND CQ7AUX.CQ7_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ7AUX.CQ7_MOEDA = '"+cMoeda+"'"+CRLF
	cQuery += " AND CQ7AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ7AUX.CQ7_ITEM)"+CRLF 
EndIf
cQuery += "	AND ARQ3.D_E_L_E_T_ = ' ' "+CRLF
cQuery += " AND ARQ4.CTH_FILIAL = '"+xFilial("CTH")+"'"+CRLF
cQuery += " AND ARQ4.CTH_CLASSE = '2'"+CRLF
cQuery += " AND ARQ4.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'"+CRLF
If lCtbr195
	cQuery += " AND ARQ4.CTH_CLVL IN (SELECT CQ7_CLVL"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ7")+" CQ7AUX"+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ7+CRLF
	EndIf
	cQuery += " AND CQ7AUX.CQ7_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ7AUX.CQ7_MOEDA  = '"+cMoeda+"'"+CRLF
	cQuery += " AND CQ7AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ7AUX.CQ7_CLVL)"+CRLF
EndIf
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ4.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf                                      
cQuery += "	AND ARQ4.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND (COALESCE(SALDOS.SALDOANTDB, 0) <> 0 OR COALESCE(SALDOS.SALDOANTCR, 0) <> 0 OR COALESCE(SALDOS.SALDODEB, 0) <> 0 OR COALESCE(SALDOS.SALDOCRD, 0) <> 0)"+CRLF

cQuery += " UNION "+CRLF

If TCGetDb() == "POSTGRES"		
	cQuery += " SELECT CHAR(3) 'CQ7' ALIAS, CTH_CLVL CLVL, ' '  ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
Else	
	cQuery += " SELECT 'CQ7' ALIAS, CTH_CLVL CLVL, ' ' ITEM, CTT_CUSTO CUSTO,CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES,"+CRLF
EndIf
cQuery += " CT1_CTASUP SUPERIOR, CTT_RES CCRES, CTT_CCSUP CCSUP, CT1_CLASSE TIPOCONTA, CTT_CLASSE TIPOCC,"+CRLF
cQuery += " ' ' ITEMRES, ' ' TIPOITEM, CTH_RES CLVLRES, CTH_CLSUP CLSUP, CTH_CLASSE TIPOCLVL,"+CRLF
If CtbExDtFim("CT1") 
	cQuery += " CT1_DTEXSF CT1DTEXSF,"+CRLF
EndIf
If CtbExDtFim("CTT") 
	cQuery += " CTT_DTEXSF CTTDTEXSF,"+CRLF
EndIf                           
If ctbExDtFim("CTD")
	cQuery += " ' '  CTDDTEXSF,"+CRLF
EndIf
If ctbExDtFim("CTH")
	cQuery += " CTH_DTEXSF CTHDTEXSF,"+CRLF
EndIf
If cMoeda == "01"
	cQuery += "	CT1_DESC01 DESCCTA, CTT_DESC01 DESCCC, ' ' DESCITEM, CTH_DESC01 DESCCLVL,"+CRLF                                                   	
Else
	cQuery += "	CT1_DESC"+cMoeda+" DESCCTA, CTT_DESC"+cMoeda+" DESCCC, CT1_DESC01 DESCCTA01,"+CRLF
	cQuery += " CTT_DESC01 DESCCC01, ' ' DESCIT01, ' '  DESCITEM,"+CRLF
	cQuery += " CTH_DESC01 DESCCV01, CTH_DESC"+cMoeda+" DESCCLVL,"+CRLF                                        	
EndIf

cQuery += "	COALESCE(SALDOS.SALDOANTDB, 0) AS SALDOANTDB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTDB, 0) AS SLDLPANTDB,"+CRLF, "")
cQuery += " COALESCE(SALDOS.SALDOANTCR, 0) AS SALDOANTCR,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.SLDLPANTCR, 0) AS SLDLPANTCR,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDODEB, 0) AS SALDODEB,"+CRLF
cQuery += If(lImpAntLP, " COALESCE(SALDOS.MOVLPDEB, 0) AS MOVLPDEB,"+CRLF, "")
cQuery += "	COALESCE(SALDOS.SALDOCRD, 0) AS SALDOCRD"+CRLF
cQuery += If(lImpAntLP, " ,COALESCE(SALDOS.MOVLPCRD, 0) AS MOVLPCRD"+CRLF, "")

cQuery += " FROM "+RetSqlName("CT1")+" ARQ"+CRLF
cQuery += " LEFT JOIN CQ7_SALDOS SALDOS ON ARQ.CT1_CONTA = SALDOS.CQ7_CONTA"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTT")+" ARQ2 ON SALDOS.CQ7_CCUSTO = ARQ2.CTT_CUSTO"+CRLF
cQuery += " RIGHT JOIN "+RetSqlName("CTH")+" ARQ3 ON SALDOS.CQ7_CLVL = ARQ3.CTH_CLVL"+CRLF
cQuery += " WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"'"+CRLF
cQuery += " AND ARQ.CT1_CLASSE = '2'"+CRLF
cQuery += " AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
EndIf
if lCtbr195
	cQuery += " AND ARQ.CT1_CONTA IN (SELECT CQ7_CONTA"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ7")+" CQ7AUX"+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ7+CRLF
	EndIf
	cQuery += " AND CQ7AUX.CQ7_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ7AUX.CQ7_MOEDA  = '"+cMoeda+"'"+CRLF	
	cQuery += " AND CQ7AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ7AUX.CQ7_CONTA)"+CRLF
EndIf
cQuery += " AND ARQ.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ2.CTT_FILIAL = '"+xFilial("CTT")+"'"+CRLF
cQuery += " AND ARQ2.CTT_CLASSE = '2'"+CRLF
cQuery += " AND ARQ2.CTT_CUSTO BETWEEN '"+cCCIni+"' AND'"+cCCFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ2.CTT_BOOK LIKE '%"+aSetOfBook[1]+"%'"+CRLF // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf
If lCtbr195
	cQuery += " AND ARQ2.CTT_CUSTO IN (SELECT CQ7_CCUSTO"+CRLF 
	cQuery += " FROM " + RetSQLName("CQ7") + " CQ7AUX"+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ7+CRLF
	EndIf
	cQuery += " AND CQ7AUX.CQ7_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ7AUX.CQ7_MOEDA  = '"+cMoeda+"'"+CRLF	
	cQuery += " AND CQ7AUX.D_E_L_E_T_ = ' '"+CRLF
	cQuery += " GROUP BY CQ7AUX.CQ7_CCUSTO)"+CRLF
EndIf
cQuery += " AND ARQ2.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND ARQ3.CTH_FILIAL = '"+xFilial("CTH")+"'"+CRLF
cQuery += " AND ARQ3.CTH_CLASSE = '2'"+CRLF
cQuery += " AND ARQ3.CTH_CLVL BETWEEN '"+cClVlIni+"' AND '"+cClVlFim+"'"+CRLF
If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12]) // SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " AND ARQ3.CTH_BOOK LIKE '%"+aSetOfBook[1]+"%'" + CRLF  // FILTRA SOMENTE ITEM DO MESMO SETOFBOOKS
EndIf                                      
If lCtbr195
	cQuery += " AND ARQ3.CTH_CLVL IN (SELECT CQ7_CLVL"+CRLF 
	cQuery += " FROM "+RetSQLName("CQ7")+" CQ7AUX "+CRLF 
	If lTodasFil
		cQuery += " WHERE CQ7_FILIAL >= '"+Space(FWSizeFilial())+"'"+CRLF
		cQuery += " AND CQ7_FILIAL <= '"+Replicate("Z", FWSizeFilial())+"'"+CRLF
	Else
		cQuery += " WHERE "+cQryFilCQ7+CRLF
	EndIf
	cQuery += " AND CQ7AUX.CQ7_TPSALD = '"+cTpSald+"'"+CRLF
	cQuery += " AND CQ7AUX.CQ7_MOEDA  = '"+cMoeda+"'"+CRLF
	cQuery += " AND CQ7AUX.D_E_L_E_T_ = ' '"+CRLF	
	cQuery += " GROUP BY CQ7AUX.CQ7_CLVL)"+CRLF
EndIf
cQuery += "	AND ARQ3.D_E_L_E_T_ = ' '"+CRLF
cQuery += " AND SALDOS.CQ7_ITEM = '"+Space(TamSx3("CQ7_ITEM")[1])+"'"+CRLF
cQuery += " AND (COALESCE(SALDOS.SALDOANTDB, 0) <> 0 OR COALESCE(SALDOS.SALDOANTCR, 0) <> 0 OR COALESCE(SALDOS.SALDODEB, 0) <> 0 OR COALESCE(SALDOS.SALDOCRD, 0) <> 0)"+CRLF
cQuery += If(lCtbr195," ORDER BY 5,4,3,2 "," ") //SOMENTE PARA CTBR195

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
EndIf
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])	
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])	

RestArea(aAreaQry)

Return				         

//-------------------------------------------------------------------
/*{Protheus.doc} CQ6Cmp4Ent
Obtem o saldo/movimento das 4 entidades 

@author Alvaro Camillo Neto

                            
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQ6Cmp4Ent(dDataIni,dDataFim,cContaIni,cContafim,cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,;
					cMoeda,cTpSald,lImpAntLP,dDataLP,cTpVlr,aMeses,cString,cFilUSU)

Local aSaveArea	:= GetArea()
Local aTamVlr	:= TAMSX3("CT2_VALOR")
Local aStrSTRU	:= {}

Local cQuery	:= ""
Local cCampUSU	:= ""

Local nColunas	:= 0
Local nStr		:= 1 
Local nStruLen	:= 0

cQuery += " SELECT * FROM ( "
cQuery += " SELECT DISTINCT CQ7_CONTA CONTA, CQ7_CCUSTO CUSTO, CQ7_ITEM ITEM, CQ7_CLVL CLVL,   	"

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := (cString)->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY
////////////////////////////////////////////////////////////

For nColunas := 1 to Len(aMeses)
	cQuery += " 	(SELECT ISNULL(SUM(CQ7_CREDIT) - SUM(CQ7_DEBITO),0) "
	cQuery += "			 	FROM "+RetSqlName("CQ7")+" CQ7 "
	cQuery += " 			WHERE CQ7.CQ7_FILIAL = '"+xFilial("CQ7")+"' "
	cQuery += " 			AND ARQ.CQ7_CONTA	= CQ7.CQ7_CONTA "
	cQuery += " 			AND ARQ.CQ7_CCUSTO	= CQ7.CQ7_CCUSTO "
	cQuery += " 			AND ARQ.CQ7_ITEM 	= CQ7.CQ7_ITEM "	
	cQuery += " 			AND ARQ.CQ7_CLVL 	= CQ7.CQ7_CLVL "
	cQuery += " 			AND CQ7_MOEDA = '"+cMoeda+"' "
	cQuery += " 			AND CQ7_TPSALD = '"+cTpSald+"' "
	If cTpVlr == "S"			// SE FOR ACUMULADO, A PRIMEIRA COLUNA TERA O SALDO ATE O FINAL DO PERIODO
		cQuery += " 			AND CQ7_DATA <= '"+DTOS(aMeses[nColunas][3])+"' "
	Else						/// AS DEMAIS COLUNAS SEMPRE SOMAM O MOVIMENTO NO PERIODO. (CALCULO NO RELATORIO)
		cQuery += " 			AND CQ7_DATA BETWEEN '"+DTOS(aMeses[nColunas][2])+"' AND '"+DTOS(aMeses[nColunas][3])+"' "
	Endif
	If lImpAntLP .and. dDataLP >= aMeses[nColunas][2]
		cQuery += " AND CQ7_LP <> 'Z' "
	Endif
	cQuery += " 			AND CQ7.D_E_L_E_T_ = ' ') COLUNA"+Str(nColunas,Iif(nColunas>9,2,1))+" "
	
	If nColunas <> Len(aMeses)
		cQuery += ", "
	EndIf		
Next	
	
cQuery += " 	FROM "+RetSqlName("CQ7")+" ARQ "
cQuery += " 	WHERE ARQ.CQ7_FILIAL = '"+xFilial("CQ7")+"' "
cQuery += " 	AND ARQ.CQ7_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' "
cQuery += " 	AND ARQ.CQ7_CCUSTO BETWEEN '"+cCCIni+"' AND '"+cCCFim+"' "
cQuery += " 	AND ARQ.CQ7_ITEM BETWEEN '"+cItemIni+"' AND '"+cItemFim+"' "
cQuery += " 	AND ARQ.CQ7_CLVL BETWEEN '"+cClvlIni+"' AND '"+cClvlFim+"' "
cQuery += " 	AND ARQ.CQ7_MOEDA = '"+cMoeda+"' "
cQuery += " 	AND ARQ.CQ7_TPSALD = '"+cTpSald+"' "
cQuery += " 	AND ARQ.D_E_L_E_T_ = ' ' "  
cQuery += " 	) SLAARQ"

cQuery += " WHERE ("+ CRLF
For nColunas := 1 to Len(aMeses)
	cQuery += "	COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)) + " <> 0 "+ CRLF
	If nColunas <> Len(aMeses)
		cQuery += " 	OR "+ CRLF
	EndIf
Next
cQuery += " ) "+ CRLF

cQuery := ChangeQuery(cQuery)		   

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif	

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

For nColunas := 1 to Len(aMeses)
	TcSetField("TRBTMP","COLUNA"+Str(nColunas,Iif(nColunas>9,2,1)),"N",aTamVlr[1],aTamVlr[2])
Next                                                                                           


RestArea(aSaveArea)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} CtbSaldoLote

Saldo de Total do Lote

@author Alvaro Camillo Neto

@param cLote 		Lote Contábil
@param cSubLote 	Sub Lote
@param dData 		Data de Lote
@param cMoeda 	Moeda
@param cTpSald 	Tipo de Saldo
@param cFilX 		Filial de busca 
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------

Function CtbSaldoLote(cLote,cSubLote,dData,cMoeda,cTpSald,cFilX)

Local aSaveAnt	:= GetArea()
Local cQuery		:= ""
Local nDebito		:= 0					// Valor Debito na Data
Local nCredito 	:= 0					// Valor Credito na Data
Local nInf			:= 0					// Valor Debito na Data
Local nDig		 	:= 0					// Valor Credito na Data
Local cTab			:= GetNextAlias()

Default cFilX		:= cFilAnt
Default cMoeda	:= '01'
Default cTpSald	:= '1'

cQuery		+= " SELECT " +CRLF 
cQuery		+= " 	CTC_FILIAL, " +CRLF 
cQuery		+= " 	CTC_LOTE, " +CRLF 
cQuery		+= " 	CTC_SBLOTE, " +CRLF 
cQuery		+= " 	CTC_DATA, " +CRLF 
cQuery		+= " 	ISNULL(SUM(CTC_DEBITO),0) CTC_DEBITO , " +CRLF 
cQuery		+= " 	ISNULL(SUM(CTC_CREDIT),0) CTC_CREDIT, " +CRLF
cQuery		+= " 	ISNULL(SUM(CTC_DIG),0) CTC_DIG , " +CRLF 
cQuery		+= " 	ISNULL(SUM(CTC_INF),0) CTC_INF " +CRLF  
cQuery		+= " FROM " + RetSqlName("CTC") +CRLF 

cQuery		+= " WHERE " +CRLF 
cQuery		+= " 	D_E_L_E_T_ 		= ' ' " +CRLF 
cQuery		+= " 	AND CTC_FILIAL	= '"+xFilial("CTC",cFilX)+"' " +CRLF 
cQuery		+= " 	AND CTC_DATA		= '"+DTOS(dData)+"' " +CRLF 
cQuery		+= " 	AND CTC_LOTE		= '"+cLote+"' " +CRLF 
cQuery		+= " 	AND CTC_SBLOTE	= '"+cSubLote+"' " +CRLF 

cQuery		+= " 	AND CTC_MOEDA		= '"+cMoeda+"' " +CRLF
If cTpSald <> '*'
	cQuery		+= " 	AND CTC_TPSALD	= '"+cTpSald+"' " +CRLF
EndIf
 

cQuery		+= " GROUP BY " +CRLF 
cQuery		+= " 	CTC_FILIAL, " +CRLF 
cQuery		+= " 	CTC_LOTE, " +CRLF 
cQuery		+= " 	CTC_SBLOTE, " +CRLF 
cQuery		+= " 	CTC_DATA " +CRLF 

cQuery := ChangeQuery(cQuery)

If Select(cTab) > 0
	dbSelectArea(cTab)
	(cTab)->( dbCloseArea() )
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTab,.T.,.F.)

If (cTab)->(!EOF())
	nDebito	:= (cTab)->CTC_DEBITO
	nCredito	:= (cTab)->CTC_CREDIT
	nInf		:=	(cTab)->CTC_INF
	nDig		:=	(cTab)->CTC_DIG
EndIf

dbSelectArea(cTab)
(cTab)->( dbCloseArea() )


RestArea(aSaveAnt)
    
Return {nDebito,nCredito,nInf,nDig}

//-------------------------------------------------------------------
/*{Protheus.doc} CQARecs
Retorna o nro de registros pendentes de atualizacao na tabela CVO.

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CQARecs(cFil)
Local cAliasTmp	:=	GetNextAlias()
Local cQuery	:=	""
Local aRet		:=	{0,"",""}
Local aArea   := GetArea()

cQuery := " SELECT Count(*) CONTA, MAX(CQA_DATA) DATAMAX, MIN(CQA_DATA) DATAMIN "
cQuery += " FROM "+RetSqlName("CQA")+" CQA "
cQuery += " WHERE CQA.CQA_FILIAL ='"+cFil+"' AND "
cQuery += " CQA.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)		   

If Select(cAliasTmp) > 0
	(cAliasTmp)->(dbCloseArea())	
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.F.)

TCSetField(cAliasTmp,"DATAMIN","D",8,0)	
TCSetField(cAliasTmp,"DATAMAX","D",8,0)	

aRet	:={(cAliasTmp)->CONTA,Dtoc((cAliasTmp)->DATAMIN),Dtoc((cAliasTmp)->DATAMAX)}

(cAliasTmp)->(dbCloseArea())

RestArea(aArea)
  
Return aRet


//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCVNFil
Saldo da entidade referencial por filial 

@author Alvaro Camillo Neto

@param cCodPlan 	Código do plano de contas referencial
@param cVersao 	Versão do plano de contas referencial
@param cContaRef 	Conta referencial do plano de contas referencial
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo                       		           
@param lImpAntLP 	Flag para indicar se imprime antes do Lucro/Perdas
@param dDataLP 	Data de Lucro/Perdas                      
@param aSelFil 	Array de Filial		
   
@version P12.1.5
@since   22/04/2015	 
*/
//-------------------------------------------------------------------

Function SaldoCVNFil(cCodPlan,cVersao,cContaRef,dData,cMoeda,cTpSald,lImpAntLP,dDataLP,aSelFil)
Local aSaveAnt		:= GetArea()
Local aSaldo		:= {}
Local nSaldoAtu		:= 0
Local nDebito 		:= 0
Local nCredito 		:= 0
Local nAtuDeb 		:= 0
Local nAtuCrd 		:= 0
Local nSaldoAnt		:= 0
Local nAntDeb 		:= 0
Local nAntCrd 		:= 0
Local cFilEsp		:= ""
Local cFilAux		:= ""
Local nX			:= 0 

DEFAULT aSelFil		:= {}
DEFAULT cCodPlan	:= ""
DEFAULT cVersao		:= ""
DEFAULT cContaRef	:= ""

If Empty(xFilial("CQ1")) .Or. Len(aSelFil) <= 1
	cFilAux	:= IIF( Len(aSelFil) == 1, aSelFil[1] , Nil)
	cFilEsp	:= xFilial("CQ1",cFilAux)
	aSaldo 	:= SaldoCVN(@cCodPlan,@cVersao,@cContaRef,@dData,@cMoeda,@cTpSald,@lImpAntLP,@dDataLP,@cFilEsp)
	nSaldoAtu	+= aSaldo[1]
	nDebito 	+= aSaldo[2]
	nCredito 	+= aSaldo[3]
	nAtuDeb 	+= aSaldo[4]
	nAtuCrd 	+= aSaldo[5]
	nSaldoAnt	+= aSaldo[6]
	nAntDeb 	+= aSaldo[7]
	nAntCrd	+= aSaldo[8]
Else
	For nX := 1 to Len(aSelFil)
		cFilAux	:= aSelFil[nX]
		cFilEsp	:= xFilial("CQ1",cFilAux)		
		aSaldo 	:= SaldoCVN(@cCodPlan,@cVersao,@cContaRef,@dData,@cMoeda,@cTpSald,@lImpAntLP,@dDataLP,@cFilEsp)
		
		nSaldoAtu	+= aSaldo[1]
		nDebito 	+= aSaldo[2]
		nCredito 	+= aSaldo[3]
		nAtuDeb 	+= aSaldo[4]
		nAtuCrd 	+= aSaldo[5]
		nSaldoAnt	+= aSaldo[6]
		nAntDeb 	+= aSaldo[7]
		nAntCrd		+= aSaldo[8]	
	Next nX
EndIf

RestArea(aSaveAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                             ³
//³ [1] Saldo Atual (com sinal)                          ³
//³ [2] Debito na Data                                   ³
//³ [3] Credito na Data                                  ³
//³ [4] Saldo Atual Devedor                              ³
//³ [5] Saldo Atual Credor                               ³
//³ [6] Saldo Anterior (com sinal)                       ³
//³ [7] Saldo Anterior Devedor                           ³
//³ [8] Saldo Anterior Credor                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]
Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}

//-------------------------------------------------------------------
/*{Protheus.doc} SaldoCVN
Saldo da entidade referencial

@author Alvaro Camillo Neto

@param cCodPlan 	Código do plano de contas referencial
@param cVersao 	Versão do plano de contas referencial
@param cContaRef 	Conta referencial do plano de contas referencial
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo                       		           
@param lImpAntLP 	Flag para indicar se imprime antes do Lucro/Perdas
@param dDataLP 	Data de Lucro/Perdas                      
@param cFilCQ 	Filial da tabela de saldo	

   
@version P12.1.5
@since   22/04/2015
@obs	 
*/
//-------------------------------------------------------------------

Function SaldoCVN(cCodPlan,cVersao,cContaRef,dData,cMoeda,cTpSald,lImpAntLP,dDataLP,cFilCQ)
Local aSaveAnt		:= GetArea()
Local aAreaCVD		:= CVD->(GetArea())
Local aSaldo			:= {}
Local nSaldoAtu		:= 0
Local nDebito 		:= 0
Local nCredito 		:= 0
Local nAtuDeb 		:= 0
Local nAtuCrd 		:= 0
Local nSaldoAnt		:= 0
Local nAntDeb 		:= 0
Local nAntCrd 		:= 0
Local cFilCVD			:= xFilial("CVD")
Local cConta			:= ""
Local cCCusto			:= ""
Local cArqBase		:= ""

Default cCodPlan		:= ""
Default cVersao		:= ""
Default cContaRef		:= ""
Default dData			:= CTOD("")
Default cMoeda		:= "01"
Default cTpSald		:= "1"
Default lImpAntLP		:= .F.
Default dDataLP		:= CTOD("")
Default cFilCQ		:= xFilial("CQ1")

cCodPlan 	:= Padr(cCodPlan	,TamSx3("CVD_CODPLA")[1])
cVersao 	:= Padr(cVersao	,TamSx3("CVD_VERSAO")[1])
cContaRef	:= Padr(cContaRef	,TamSx3("CVD_CTAREF")[1])


CVD->(dbSetOrder(5))//CVD_FILIAL+CVD_CODPLA+CVD_VERSAO+CVD_CTAREF+CVD_CONTA+CVD_CUSTO :TODO: Novo indice

If CVD->(MsSeek( cFilCVD + cCodPlan + cVersao + cContaRef ))
	While CVD->(CVD_FILIAL+CVD_CODPLA+CVD_VERSAO+CVD_CTAREF) == cFilCVD + cCodPlan + cVersao + cContaRef  .And. CVD->(!EOF())
		
		cConta		:= CVD->CVD_CONTA
		cCCusto	:= CVD->CVD_CUSTO
		cArqBase	:= IIF(Empty(cCCusto),"CT1","CTT")
		
		aSaldo 	:= SaldoCQ(cArqBase,cConta,cCCusto,/*cItem*/,/*cClasse*/,/*cIdent*/,dData,cMoeda,cTpSald,/*cRotina*/,lImpAntLP,dDataLP,cFilCQ,/*lUltDtVl*/)
		
		nSaldoAtu	+= aSaldo[1]
		nDebito 	+= aSaldo[2]
		nCredito 	+= aSaldo[3]
		nAtuDeb 	+= aSaldo[4]
		nAtuCrd 	+= aSaldo[5]
		nSaldoAnt	+= aSaldo[6]
		nAntDeb 	+= aSaldo[7]
		nAntCrd	+= aSaldo[8]
		
		CVD->(dbSkip())
	EndDo
EndIf


RestArea(aAreaCVD)
RestArea(aSaveAnt)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno:                                             ³
//³ [1] Saldo Atual (com sinal)                          ³
//³ [2] Debito na Data                                   ³
//³ [3] Credito na Data                                  ³
//³ [4] Saldo Atual Devedor                              ³
//³ [5] Saldo Atual Credor                               ³
//³ [6] Saldo Anterior (com sinal)                       ³
//³ [7] Saldo Anterior Devedor                           ³
//³ [8] Saldo Anterior Credor                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//      [1]       [2]     [3]      [4]     [5]     [6]       [7]     [8]
Return {nSaldoAtu,nDebito,nCredito,nAtuDeb,nAtuCrd,nSaldoAnt,nAntDeb,nAntCrd}


//-------------------------------------------------------------------
/*{Protheus.doc} CtGerPlRef
Função para atualizar o arquivo temporário com os dados do plano referencial. 

@author Simone Mie Sato Kakinoana

@param cTableNam1	Nome do arquivo no banco de dados
@param cArqATmp		Nome do arquivo temporário        
@param cChave		Chave do índice
@param aChave		Array com os campos da chave de inidce
@param aCampos		Array com a estrutura da tabela a ser criada
@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial
@param lImpSint     Se atualiza sinteticas
@param lNImpMov     Se Imprime Entidade sem movimento
@param lImp3Ent     Se e Balancete C.Custo / Conta / Item              
@param lImp4Ent     Se e Balancete por CC x Cta x Item x Cl.Valor
@param cArqAux      Arquivo auxiliar permitindo a recursividade
@param cAlias       Alias do Arquivo
@param cHeader      Identifica qual a Entidade Principal
@param cMoeda       Moeda
@param nComp        Indica a quantidade de colunas
@param cEntid_De	Codigo da entidade inicial
@param cEntid_Ate	Codigo da entidade final
@param lEntSint		Indica se imprime a entidade sintetica
@param lImpConta    Se Imprime Conta
@param nPos		    Posicao do codigo para filtro do segemnto 
@param nPosG	    Posicao do codigo da entidade para filtro do segmento 
@param nDigitos		Numero de digitos a ser considerado para filtro do segmento  
@param nDigitosG	Numero de digitos do segmento a ser considerado para filtro do segmento
@param cSegmento	Segmento a ser considerado no filtro de segmento
@param cSegmentoG	Segmento da entidade a ser considerada no filtro do segmento
@param cSegIni		Segmento inicial a ser considerado no filtro do segmento
@param cSegIniG		Segmento inicial da entidade a ser considerada no filtro do segmento
@param cSegFim		Segmento final a ser considerado no filtro do segmento
@param cSegFimG		Segmento final da entidade a ser considerado no filtro do segmento
@param cFiltSegm	Codigo do segmento a ser considerado no filtro do segmento	
@param cFiltSegmG  	Codigo do segmento da entidade a ser cosinderado no filtro do segmento

@version P12.1.5
@since   28/04/2015
@obs	 
*/
//-------------------------------------------------------------------
Function CtGerPlRef(cTableNam1,cArqTmp,cChave,aChave,aCampos,cPlanoRef,cVersao,lImpSint,lNimpMOv,lImp3Ent,lImp4Ent,cArqAux,cAlias,cHeader,cMoeda,nComp, cEntid_De, cEntid_Ate,lEntSint,;
					lImpConta,nPos,nPosG,nDigitos,nDigitosG,cSegmento, cSegmentoG, cSegIni, cSegIniG, cSegFim, cSegFimG,  cFiltSegm, cFiltSegmG, ObjTable)

Local aSaveArea	:= GetArea()
Local aAreaAnt	:= {}
Local aStruSQL	:= {}
   
Local cArqTmpAnt:= ""
Local cQuery	:= ""

Local nCont		:= 0
Local nTrb	:= 0
Local nDifCta	:= 0 

Local oTempTable
Local cTableNam2	:= ""
Local cAliasTmp		:= ""
Local cOrderBy		:= ""
Local cChvTmp		:= ""

Local cCodigo		:= ""
Local cCodger		:= ""
Local cContaRef		:= ""
Local cCodCtaRef	:= ""

If Select(cArqAux) > 0
	(cArqAux)->(dbCloseArea())	
EndIf

aStruSQL	:= Aclone(aCampos)

AADD(aStruSQL, {"CTAAUX"		, "C", 70, 0 })

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New(cArqAux)
oTemptable:SetFields( aStruSql )

oTempTable:AddIndex("1", aChave)

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//Passagem por referencia.
ObjTable := oTempTable

cTableNam2 := oTempTable:GetRealName()

cOrderBy := STRTRAN(cChave,"+",",")

cQuery	:= " SELECT ( " + CRLF
cQuery	+= "			SELECT ISNULL(CVD_CTAREF,'') "+CRLF
cQuery	+= " 			FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  			AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 			AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 			AND CVD_CONTA = CONTA "+CRLF
If !Empty(mv_par01)
	cQuery	+= " 			AND " 
	cQuery	+= mv_par01 +  CRLF	
EndIf
cQuery  += " 		) CONTA, "+CRLF
cQuery	+= "		(	SELECT ISNULL(CVD_CTAREF,'') "+CRLF
cQuery	+= " 			FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  			AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 			AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '' "+CRLF
cQuery  += " 		) CTARES, "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_CLASSE,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) TIPOCONTA,  "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_CTASUP,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) SUPERIOR,  "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_DSCCTA,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) DESCCTA,  "+CRLF
cQuery	+= " 		'' GRUPO,"+CRLF

For nCont	:= 1 to Len(aStruSQL)
	If !(Alltrim(aStruSQL[nCont][1])$ "CONTA/SUPERIOR/DESCCTA/CTARES/TIPOCONTA/GRUPO/CTAAUX")
		cQuery	+= Alltrim(aStruSQL[nCont][1])
		If nCont < Len(aStruSQL)-1 //Desconsiderando o campo CTAAUX que foi incluido a mais na estrutura.			  
			cQuery	+= ", "+ CRLF
		Endif	
	EndIf 
Next
cQuery	+= " FROM " + cTableNam1 +  CRLF
cQuery	+= " WHERE TIPOCONTA = '2' " +  CRLF
If cHeader == "CT1"
	If cAlias == "CT3"
		cQuery	+= " AND TIPOCC = '2' "+  CRLF	  
	ElseIf cAlias == "CT4" 
		cQuery	+= " AND TIPOITEM = '2' "+  CRLF
	ElseIf cAlias == "CTI"
		cQuery	+= " AND TIPOCLVL = '2' "+  CRLF
	EndIF
Else
	If cAlias == "CT3"
		cQuery	+= " AND TIPOCC = '2' "+  CRLF
	ElseIf cAlias == "CT4"
		If !lImp3Ent 
			cQuery	+= " AND TIPOITEM = '2' "+  CRLF
		Endif
	ElseIf cAlias == "CTI"
		If !lImp4Ent 
			cQuery	+= " AND TIPOCLVL = '2' "+  CRLF
		End
	EndIF	
Endif
cQuery	+= " AND "+  CRLF
cQuery	+= " (	SELECT CVD_CTAREF "+CRLF
cQuery	+= " 				FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 				WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  				AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 				AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 				AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 				AND CVD_CONTA = CONTA "+CRLF
If !Empty(mv_par01)
	cQuery	+= " 			AND " 
	cQuery	+= mv_par01 +  CRLF	
EndIf
cQuery  += " 		) <> '' "+CRLF
cQuery	+= " ORDER BY " + cOrderBy
cQuery	:= ChangeQuery(cQuery)

cArqTmpAnt	:= MPSysOpenQuery( cQuery ,"cArqTmpAnt" ,  )

cContaRef	:= (cArqTmpAnt)->CONTA
cContaRef	:= StrTran(cContaRef,".","")
cContaRef	:= StrTran(cContaRef,"/","")
cContaRef	:= StrTran(cContaRef,"-","")

nDifCta		:= 70- LEN(cContaRef)

cChvTmp	:= STRTRAN(CCHAVE,"CONTA","cContaRef")
cChvTmp	:= STRTRAN(CCHVTMP,"CUSTO","(cArqTmpAnt)->CUSTO")
cChvTmp	:= STRTRAN(CCHVTMP,"ITEM","(cArqTmpAnt)->ITEM")
cChvTmp	:= STRTRAN(CCHVTMP,"CLVL","(cArqTmpAnt)->CLVL")
cChvTmp	:= STRTRAN(CCHVTMP,"cContaRef","cContaref+SPACE("+Alltrim(Str(nDifCta)) +")")

dbSelectArea("cArqTmpAnt")
dbGotop()
While !Eof()
	
	cContaRef	:= StrTran((cArqTmpAnt)->CONTA,".","")
	cCodCtaRef	:= (cArqTmpAnt)->CONTA	
	If Empty(cContaRef)
		DbSkip()
		Loop
	EndIf
	
	If lImpConta .Or. cAlias == "CT7"
		If cHeader == "CT1"
			If cAlias == "CT4"  
				cCodigo	:= (cArqTmpAnt)->ITEM
			ElseIf cAlias == "CT3"
				cCodigo	:= (cArqTmpAnt)->CUSTO
			Endif
		Else	
			cCodigo	:= cContaRef
		Endif
	Else
		If cAlias == "CT3"
			cCodigo	:= (cArqTmpAnt)->CUSTO
		ElseIf cAlias == "CT4"
			cCodigo	:= (cArqTmpAnt)->ITEM
		ElseIf cAlias == "CTI"
			cCodigo	:= (cArqTmpAnt)->CLVL
		EndIf
	EndIf
	
	If cAlias == "CT3" .And. cHeader == "CTT"
		cCodGer	:= (cArqTmpAnt)->CUSTO
	ElseIf 	cAlias == "CT4" .And. cHeader == "CTD"
		cCodGer	:= (cArqTmpAnt)->ITEM 
	ElseIf 	cAlias == "CTI" .And. cHeader == "CTH"
		cCodGer	:= (cArqTmpAnt)->CLVL
	EndIf	
		
	If !Empty(cSegmento)
		If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
			If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
				dbSkip()
				Loop
			EndIf
		Else
			If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
				Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
				dbSkip()
				Loop
			EndIf
		Endif
	EndIf
			
			
	//Caso faca filtragem por segmento gerencial,verifico se esta dentro
	//da solicitacao feita pelo usuario.
	If ( cAlias == "CT3" .And. cHeader == "CTT") .Or. ;
		( cAlias == "CT4" .And. cHeader == "CTD") .Or. ;
		( cAlias == "CTI" .And. cHeader == "CTH")
		 
		If !Empty(cSegmentoG)
			If Empty(cSegIniG) .And. Empty(cSegFimG) .And. !Empty(cFiltSegmG)
				If  !(Substr(cCodGer,nPosG,nDigitosG) $ (cFiltSegmG) )
					dbSkip()
					Loop
				EndIf
			Else
				If Substr(cCodGer,nPosG,nDigitosG) < Alltrim(cSegIniG) .Or. ;
					Substr(cCodGer,nPosG,nDigitosG) > Alltrim(cSegFimG)
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf
	EndIf

	DbSelectArea(cArqAux)
	DbSetOrder(1)
	If !DbSeek(Alltrim(&cChvTmp))
		Reclock(cArqAux,.T.)
		
		For nTRB := 1 to Len(aStruSQL)
			If !(Alltrim(aStruSQL[nTRB,1]) $ "NIVEL1/CTAAUX")				
				Field->&(aStruSQL[nTRB,1]) :=(cArqTmpAnt)->&(aStruSQL[nTRB,1])			
			EndIf
		Next
		(cArqAux)->FILIAL	:= cFilAnt
		(cArqAux)->GRUPO	:= ""
		(cArqAux)->CONTA	:= cContaRef
		(cArqAux)->CTARES	:= cContaRef
		(cArqAux)->CTAAUX	:= cCodCtaRef
		cContaSup			:= (cArqTmpAnt)->SUPERIOR
		cContaSup			:=  StrTran(cContaSup,".","")		
		cContaSup			:=  StrTran(cContaSup,"/","")
		cContaSup			:=  StrTran(cContaSup,"-","")
		
		If !lImp3Ent .And. !lImp4Ent
			If cAlias == "CT4" .And. cHeader == "CTD"
				If (cArqAux)->TIPOITEM == "1" .And. (cArqAux)->TIPOCONTA == "2"   
					(cArqAux)->SUPERIOR	:= cContaSup								
				EndIf	
			ElseIf cHeader == "CT1"
				(cArqAux)->SUPERIOR	:= cContaSup
			Endif
		Else
			If ( lImp3Ent .And. !Empty((cArqTmpant)->ITEM) ) .Or. ;
				( lImp4Ent .and. (!Empty((cArqAux)->ITEM) .Or. !Empty((cArqAux)->CLVL)))
					
				(cArqAux)->SUPERIOR	:= cContaSup
					
			Endif
		EndIf	
		
		MsUnlock()
	Else
		Reclock(cArqAux,.F.)
		For nTRB := 1 to Len(aStruSQL)
			If Alltrim(aStruSQL[nTRB][1]) $ "SALDODEB/SALDOCRD/SALDOANTDB/SALDOANTCR/SLDLPANTCR/SLDLPANTDB/MOVLPDEB/MOVLPCRD/MOVIMENTO/SALDOATUDB/SALDOATUCR" 
				Field->&(aStruSQL[nTRB,1])	+=((cArqTmpAnt)->&(aStruSQL[nTRB,1]))
			EndIf		
		Next
		MsUnlock()
	Endif
	cContaRef	:= ""	
	dbSelectArea("cArqTmpAnt")
	DbSkip()
End


If lImpSint
	If cAlias == "CT7"	//CONTA
		CtCtaPrSup(cPlanoRef,cVersao,@cArqAux,lNimpMOv)
	ElseIf cAlias $ "CT3/CT4/CTI"				
		If cHeader == "CT1"	//CONTA+ENTIDADE
			CtEntCtPrS(cPlanoRef,cVersao,@cArqAux,cAlias,lNIMpMov,cMoeda)
		Else
			If !lImp3Ent .And. !lImp4Ent //Se não for Balancete CC / Conta / Item
				CtEntPrSup(cPlanoRef,cVersao,@cArqAux,cAlias,lNImpMov,cMoeda,nComp, cEntid_De, cEntid_Ate,lEntSint)
			Else
				If lImp3Ent
					Ct3CtPrSup(cPlanoRef,cVersao,@cArqAux,cAlias,lNImpMov,cMoeda,cHeader)
				ElseIf  cAlias == "CTI" .And. lImp4Ent .And. cHeader == "CTT"
					Ct4CtPrSup(cPlanoRef,cVersao,@cArqAux,cAlias,lNImpMov,cMoeda,cHeader)
				EndIf
			Endif	
		EndIf
	EndIf
EndIf 

RestArea(aSaveArea)

Return(cArqAux)

//-------------------------------------------------------------------
/*{Protheus.doc} CtCtaPrSup 
Função para atualizar as sintéticas de conta

@author Simone Mie Sato Kakinoana

@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial
@param cArqTmpAtu	Nome do arquivo temporario a ser atualizado
@param lNImpMov     Se Imprime Entidade sem movimento		 


@version P12.1.5
@since   30/04/2015
@obs	 
*/
//-------------------------------------------------------------------
Function CtCtaPrSup(cPlanoRef,cVersao,cArqTmpAtu,lNimpMOv)				
		
Local aSaveArea	:= GetArea()				
Local cContaSup	:= ""
Local cCtaSupAux	:= ""
Local cDesc		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nRegTmp	:= 0
Local lSemestre 	:= FieldPos("SALDOSEM") > 0		// Saldo por semestre
Local lPeriodo0		:= FieldPos("SALDOPER") > 0		// Saldo dois periodos anteriores

nSaldoAnt	:= SALDOANT
nSaldoAtu	:= SALDOATU
nSaldoDeb	:= SALDODEB
nSaldoCrd	:= SALDOCRD
nMovimento	:= MOVIMENTO			
		
nSaldoAtuD	:= SALDOATUDB
nSaldoAtuC	:= SALDOATUCR


// Grava sinteticas
dbSelectArea(cArqTmpAtu)	
dbGoTop()  

While !Eof()

	If (cArqTmpAtu)->TIPOCONTA == "1"
		dbSkip()
		Loop
	EndIf
	
	nRegTmp	:= Recno()
	nSaldoAnt	:= SALDOANT
	nSaldoAtu	:= SALDOATU
	nSaldoDeb	:= SALDODEB
	nSaldoCrd	:= SALDOCRD
	nMovimento	:= MOVIMENTO					
	nSaldoAtuD	:= SALDOATUDB
	nSaldoAtuC	:= SALDOATUCR

	cContaSup 	:= (cArqTmpAtu)->SUPERIOR
	cCtaSupAux	:= cContaSup
	cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
	cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
	cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
	//Tira os caracteres da conta superior
	Reclock(cArqTmpAtu,.F.)
	(cArqTmpAtu)->SUPERIOR	:= cCtaSupAux	
	MsUnlock()
	
	dbSelectArea("CVN")
	dbSetOrder(4)//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF	
	If Empty(cContaSup)
		dbSelectArea(cArqTmpAtu)
		Replace NIVEL1 With .T.
		dbSelectArea("CVN")
	EndIf		
	MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cContaSup)
		
	While !Eof() .And. CVN->CVN_FILIAL == xFilial("CVN") ;
		.And. CVN->CVN_CODPLA == cPlanoRef; 
		.And. CVN->CVN_VERSAO == cVersao  

		cDesc := CVN->CVN_DSCCTA
		
   		dbSelectArea(cArqTmpAtu)
		dbSetOrder(1)

		cCtaSupAux	:= cContaSup
		cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
		
		//If !MsSeek(cContaSup)
		If !MsSeek(cCtaSupAux)
			dbAppend()
			Replace CONTA		With cCtaSupAux
			Replace CTARES		With cCtaSupAux
			Replace SUPERIOR	With CVN->CVN_CTASUP
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA	With CVN->CVN_CLASSE
		EndIf    

		Replace	SALDOANT 	With SALDOANT 	+ nSaldoAnt
		Replace SALDOANTDB  With SALDOANTDB + nSaldoAntD
		Replace SALDOANTCR	With SALDOANTCR + nSaldoAntC
		Replace SALDOATU 	With SALDOATU 	+ nSaldoAtu
		Replace SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
		Replace SALDOATUCR	With SALDOATUCR + nsaldoAtuC
		Replace SALDODEB 	With SALDODEB 	+ nSaldoDeb
		Replace SALDOCRD 	With SALDOCRD 	+ nSaldoCrd

		If !lNImpMov
			Replace MOVIMENTO With MOVIMENTO + nMovimento
		Endif

		If lSemestre		// Saldo por semestre
			Replace SALDOSEM With SALDOSEM 	+ nSaldoSEM
		Endif

   		If lPeriodo0		// Saldo dois periodos anteriores
			Replace SALDOPER With SALDOPER 	+ nSaldoSEM
		Endif
		
		dbSelectArea("CVN")
		cContaSup := CVN->CVN_CTASUP
		If Empty(CVN->CVN_CTASUP)
			dbSelectArea(cArqTmpAtu)
			Replace NIVEL1 With .T.
			dbSelectArea("CVN")
			Exit
		EndIf		
		//MsSeek(xFilial()+cContaSup)
		MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cContaSup)
	EndDo
	dbSelectArea(cArqTmpAtu)
	dbGoto(nRegTmp)
	dbSkip()

EndDo
	
    	
RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtCompPlRf
Função para atualizar o arquivo temporário com os dados do plano referencial. 

@author Simone Mie Sato Kakinoana
@param cTableNam1	Nome do arquivo no banco de dados
@param cPlanoRef 	Código do plano referencial       
@param cVersao   	Versão do plano referencial           
@param cArqAux		Nome do arquivo temporário        
@param cChave		Chave do índice
@param aChave		Array com os campos da chave de inidce
@param dDataIni		Data inicial 
@param dDataFim		Data final
@param cEntidIni1	Codigo da entidade inicial 1
@param cEntidFim1	Codigo da entidade final 1
@param cEntidIni2	Codigo da entidade inicial 2
@param cEntidFim2	Codigo da entidade final 2
@param cHeader      Identifica qual a Entidade Principal
@param cMoeda       Moeda
@param cSaldos      Tipo de Saldo
@param aSetOfBook   Array da configuração de livros
@param cSegmento	Segmento a ser considerado no filtro de segmento
@param cSegIni		Segmento inicial a ser considerado no filtro do segmento
@param cSegFim		Segmento final a ser considerado no filtro do segmento
@param cFiltSegm	Codigo do segmento a ser considerado no filtro do segmento
@param nPos		    Posicao do codigo para filtro do segemnto
@param nDigitos		Numero de digitos a ser considerado para filtro do segmento
@param lNImpMov     Se Imprime Entidade sem movimento
@param cAlias       Alias do Arquivo
@param lCusto      Indica se usa c.custo
@param lItem       Indica se usa item    
@param lClvl       Indica se usa classe de valor
@param lAtSldBase  Indica se atualiza os saldos
@param lAtSldCmp   Indica se atualiza os saldos compostos
@param nInicio	   Indica a moeda inicial
@param nFinal	   Indica a moeda final
@param cFilDe	   Filial inicial
@param cFilAte     Filial final
@param lImpAntLP   Flag para indicar se imprime antes do Lucro/Perdas
@param dDataLP 	   Data de Lucro/Perdas                      
@param nDivide	  Indica se divide o valor
@param cTpVlr	  Indica se é comparativo de saldo acumulado
@param lFiliais   Indica se é comparativo por filiais
@param aFiliais   Array contendo as filiais selecionadas  
@param lMeses	  Indica se é comparativo por mês	
@param aMeses	  Array contendo os periodos selecionados	
@param lVlrZerado Indica se imprime valor zerado
@param lEntid     Indicia se é comparativo por entidades
@param aEntid     Array contendo as entidades selecionadas
@param lImpSint   Indica se imprime sintetica
@param ObjTable	Tabela temporaria

 
@param aCampos		Array com a estrutura da tabela a ser criada
@param lImpSint     Se atualiza sinteticas

@version P12.1.5
@since   28/04/2015
@obs	 
*/
//-------------------------------------------------------------------
Function CtCompPlRf(cTableNam1,cPlanoRef,cVersao,cArqAux,cChave,aChave,aCampos,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid,lImpSint,ObjTable)

Local aSaveArea	:= GetArea()
Local aAreaAnt	:= {}
Local aStruSQL	:= {}
   
Local oTempTable

Local cTableNam2	:= ""
Local cAliasTmp	:= GetNextAlias()
Local cArqInd	:= ""
Local cQuery	:= ""
Local cGroupby	:= ""
Local cOrderBy		:= ""
Local cChvTmp		:= ""
Local cContaRef		:= ""
Local cCodCtaRef	:= ""

Local nDifCta	:= 0

Local nCont		:= 0
Local nCont1	:= 0
Local nCont2	:= 0 
Local nLastCpoC	:= 0
Local nX		:= 0
Local nTRB		:= 0    		

If Select(cArqAux) > 0
	(cArqAux)->(dbCloseArea())	
EndIf

aStruSQL	:= Aclone(aCampos)
AADD(aStruSQL, {"CTAAUX"		, "C", 70, 0 })

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New(cArqAux)
oTemptable:SetFields( aStruSql )

oTempTable:AddIndex("1", aChave)

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//Passagem por referencia.
ObjTable := oTempTable

cTableNam2 := oTempTable:GetRealName()

cOrderBy := STRTRAN(cChave,"+",",")

cQuery	:= " SELECT ( " + CRLF
cQuery	+= "			SELECT ISNULL(CVD_CTAREF,'') "+CRLF
cQuery	+= " 			FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  			AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 			AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 			AND CVD_CONTA = CONTA "+CRLF
If !Empty(mv_par01)
	cQuery	+= " 			AND " 
	cQuery	+= mv_par01 +  CRLF	
EndIf
cQuery  += " 		) CONTA, "+CRLF
cQuery	+= "		(	SELECT ISNULL(CVD_CTAREF,'') "+CRLF
cQuery	+= " 			FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  			AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 			AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '' "+CRLF
cQuery  += " 		) CTARES, "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_CLASSE,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) TIPOCONTA,  "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_CTASUP,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) CTASUP,  "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_DSCCTA,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) DESCCTA,  "+CRLF
cQuery	+= " 		'' GRUPO,"+CRLF

For nCont	:= 1 to Len(aStruSQL)
	If !(Alltrim(aStruSQL[nCont][1])$ "CONTA/CTASUP/DESCCTA/CTARES/TIPOCONTA/GRUPO/CTAAUX")
		cQuery	+= Alltrim(aStruSQL[nCont][1])
		If nCont < Len(aStruSQL)-1 //Desconsiderando o campo CTAAUX que foi incluido a mais na estrutura. 
			cQuery	+= ", "+ CRLF
		Endif	
	EndIf 
Next
cQuery	+= " FROM " + cTableNam1 +  CRLF
cQuery	+= " WHERE TIPOCONTA = '2' " +  CRLF
If cAlias == "CT3"
	cQuery	+= " AND TIPOCC = '2' "+  CRLF	  
ElseIf cAlias == "CT4" 
	cQuery	+= " AND TIPOITEM = '2' "+  CRLF
ElseIf cAlias == "CTI"
	cQuery	+= " AND TIPOCLVL = '2' "+  CRLF
EndIF
cQuery	+= " AND "+  CRLF
cQuery	+= " (	SELECT CVD_CTAREF "+CRLF
cQuery	+= " 				FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 				WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  				AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 				AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 				AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 				AND CVD_CONTA = CONTA "+CRLF
If !Empty(mv_par01)
	cQuery	+= " 			AND " 
	cQuery	+= mv_par01 +  CRLF	
EndIf
cQuery  += " 		) <> '' "+CRLF
cQuery	+= " ORDER BY " + cOrderBy
cQuery	:= ChangeQuery(cQuery)

cArqTmpAnt	:= MPSysOpenQuery( cQuery ,"cArqTmpAnt" ,  )


cContaRef	:= (cArqTmpAnt)->CONTA
cContaRef	:= StrTran(cContaRef,".","")
cContaRef	:= StrTran(cContaRef,"/","")
cContaRef	:= StrTran(cContaRef,"-","")

nDifCta		:= 70- LEN(cContaRef)

cChvTmp	:= STRTRAN(CCHAVE,"CONTA","cContaRef")
cChvTmp	:= STRTRAN(CCHVTMP,"CUSTO","(cArqTmpAnt)->CUSTO")
cChvTmp	:= STRTRAN(CCHVTMP,"ITEM","(cArqTmpAnt)->ITEM")
cChvTmp	:= STRTRAN(CCHVTMP,"CLVL","(cArqTmpAnt)->CLVL")
cChvTmp	:= STRTRAN(CCHVTMP,"cContaRef","cContaref+SPACE("+Alltrim(Str(nDifCta)) +")")

dbSelectArea("cArqTmpAnt")
dbGotop()
While !Eof()
	
	cContaRef	:= StrTran((cArqTmpAnt)->CONTA,".","")
	cCodCtaRef	:= (cArqTmpAnt)->CONTA	
	If Empty(cContaRef)
		DbSkip()
		Loop
	EndIf
	
	If cAlias == "CT7"
		cCodigo	:= cContaRef
	Else
		If cAlias == "CT3"
			cCodigo	:= (cArqTmpAnt)->CUSTO
		ElseIf cAlias == "CT4"
			cCodigo	:= (cArqTmpAnt)->ITEM
		ElseIf cAlias == "CTI"
			cCodigo	:= (cArqTmpAnt)->CLVL
		EndIf
	EndIf
	If cAlias == "CT3" .And. cHeader == "CTT"
		cCodGer	:= (cArqTmpAnt)->CUSTO
	EndIf	
		
	If !Empty(cSegmento)
		If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
			If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
				dbSkip()
				Loop
			EndIf
		Else
			If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
				Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
				dbSkip()
				Loop
			EndIf
		Endif
	EndIf
			
			
	//Caso faca filtragem por segmento gerencial,verifico se esta dentro
	//da solicitacao feita pelo usuario.
	/*If cAlias == "CT3" .And. cHeader == "CTT"
		If !Empty(cSegmentoG)
			If Empty(cSegIniG) .And. Empty(cSegFimG) .And. !Empty(cFiltSegmG)
				If  !(Substr(cCodGer,nPosG,nDigitosG) $ (cFiltSegmG) )
					dbSkip()
					Loop
				EndIf
			Else
				If Substr(cCodGer,nPosG,nDigitosG) < Alltrim(cSegIniG) .Or. ;
					Substr(cCodGer,nPosG,nDigitosG) > Alltrim(cSegFimG)
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf
	EndIf*/

	DbSelectArea(cArqAux)
	DbSetOrder(1)
	If !DbSeek(Alltrim(&cChvTmp))
		Reclock(cArqAux,.T.)
		
		For nTRB := 1 to Len(aStruSQL)
			If !(Alltrim(aStruSQL[nTRB,1]) $ "NIVEL1/CTAAUX")
				Field->&(aStruSQL[nTRB,1]) :=(cArqTmpAnt)->&(aStruSQL[nTRB,1])
			EndIf
		Next
		(cArqAux)->FILIAL	:= cFilAnt
		(cArqAux)->GRUPO	:= ""
		(cArqAux)->CONTA	:= cContaRef
		(cArqAux)->CTARES	:= cContaRef
		(cArqAux)->CTAAUX	:= cCodCtaRef
		cContaSup			:= (cArqTmpAnt)->CTASUP
		cContaSup			:=  StrTran(cContaSup,".","")		
		cContaSup			:=  StrTran(cContaSup,"/","")
		cContaSup			:=  StrTran(cContaSup,"-","")		
		MsUnlock()
	Else
		Reclock(cArqAux,.F.)
		For nTRB := 1 to Len(aStruSQL)
			If Subs(aStruSQL[nTRB][1],1,6) $ "COLUNA" 
				Field->&(aStruSQL[nTRB,1])	+=((cArqTmpAnt)->&(aStruSQL[nTRB,1]))
			EndIf		
		Next
		MsUnlock()
	Endif
	cContaRef	:= ""	
	dbSelectArea("cArqTmpAnt")
	DbSkip()
End


If lImpSint
	If cAlias == "CT7"
		SupPRefCT7(cPlanoRef,cVersao,@cArqAux,lNimpMOv,lMeses,aMeses,cMoeda,cTpVlr,lFiliais,aFiliais)	
	ElseIf cAlias == "CT3"
		SupCmpPlRf(cPlanoRef,cVersao,@cArqAux,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid)
	EndIf
EndIf 


RestArea(aSaveArea)

Return(cArqAux)


//-------------------------------------------------------------------
/*{Protheus.doc} SupPRefCT7 
Função para atualização das sintéticas do plano referencial 

@author Simone Mie Sato Kakinoana
admin

@version P12.1.5
@since   04/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function SupPRefCT7(cPlanoRef,cVersao,cArqTmpAtu,lNimpMOv,lMeses,aMeses,cMoeda,cTpVlr,lFiliais,aFiliais)		

Local aSaveArea	:= GetArea()
Local nTotVezes		:= 0                     
Local nVezes		:= 0
Local nReg			:= 0
Local cContaSup		:= ""         
Local cCtaSupAux	:= ""      
Local cDesc			:= ""
Local aMovimento	:= {}

If lMeses	//Se for Comparativo por Mes
	nTotVezes := Len(aMeses)
EndIf

If lFiliais
	nTotVezes := Len(aFiliais)
EndIf

// Grava contas sinteticas
dbSelectArea(cArqTmpAtu)	

dbGoTop()  

While!Eof()          

	nReg	:= Recno()   
	cContaSup := (cArqTmpAtu)->CTASUP
	// Grava contas sinteticas		
	If Empty((cArqTmpAtu)->CTASUP)
		dbSelectArea(cArqTmpAtu)
		Replace NIVEL1 With .T.
	EndIf		       

	For nVezes := 1 to nTotVezes	
		AADD(aMovimento,&("COLUNA"+Alltrim(Str(nVezes,2))))
	Next
	
	cContaSup 	:= (cArqTmpAtu)->CTASUP
	cCtaSupAux	:= cContaSup
	cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
	cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
	cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
	//Tira os caracteres da conta superior
	Reclock(cArqTmpAtu,.F.)
	(cArqTmpAtu)->CTASUP	:= cCtaSupAux	
	MsUnlock()

	dbSelectArea("CVN")
	dbSetOrder(4)//CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF                                                                                                                     
		
	//cContaSup := (cArqTmpAtu)->CTASUP
	If Empty(cContaSup)
		dbSelectArea(cArqTmpAtu)
		Replace NIVEL1 With .T.
		dbSelectArea("CVN")
	EndIf		
	MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cContaSup)
		
	While !Eof() .And. CVN->CVN_FILIAL == xFilial("CVN") ;
	.And. CVN->CVN_CODPLA == cPlanoRef; 
	.And. CVN->CVN_VERSAO == cVersao  
	

		cDesc := CVN->CVN_DSCCTA
		
		dbSelectArea(cArqTmpAtu)
		dbSetOrder(1)
		cCtaSupAux	:= cContaSup
		cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
		
		//If !MsSeek(cContaSup)
		If !MsSeek(cCtaSupAux)
			dbAppend()
			Replace CONTA		With cCtaSupAux
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA	With CVN->CVN_CLASSE
			Replace CTASUP		With CVN->CVN_CTASUP
		EndIf      
		                         
		For nVezes := 1 to nTotVezes
//			If cTpVlr == 'M'         				 									
				Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])								
//			EndIf
	   	Next
			
		dbSelectArea("CVN")
		cContaSup := CVN->CVN_CTASUP
		If Empty(CVN->CVN_CTASUP)
			dbSelectArea(cArqTmpAtu)
			Replace NIVEL1 With .T.
			dbSelectArea("CVN")
			Exit                            
		EndIf		
		MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cContaSup)
	EndDo  		
	aMovimento	:= {}    	
	dbSelectArea(cArqTmpAtu)
	dbGoTo(nReg)
	dbSkip()
EndDo	
                   
RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtCmpPlRef
Função para atualizar o arquivo temporário com os dados do plano referencial. 

@author Simone Mie Sato Kakinoana

@param cTableNam1	Nome do arquivo no banco de dados
@param cAlias       Alias do Arquivo
@param cArqTmp		Arquivo temporário
@param cArqAux		Alias do arquivo temporario
@param cChave		Chave do índice
@param aChave		Array com a chave de indice
@param aCampos		Array com a estrutura da abela a ser criada
@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial
@param lCt1Sint		Indica se imprime as contas sinteticas
@param lVariacao0	Indica se imprime com variação zero
@param bVariacao 	Bloco de codigo da variação         
@param cMoeda    	Indica ocodigo da moeda              
@param lEntSint   	Indica se imprime entidade sintetica
@param ObtTable		Objeto da tabela temporaria

@version P12.1.5
@since   04/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function CtCmpPlRef(cTableNam1,cAlias,cArqTmp,cArqAux,cChave,aChave,aCampos,cPlanoRef,cVersao,lCt1Sint,lVariacao0,bVariacao,cMoeda,lEntSint,ObjTable,;
					cSegmento,cSegIni,cSegFim,cFiltSegM,nPos,nDigitos )
		
Local aSaveArea	:= GetArea()
Local aAreaAnt	:= {}
Local aStruSQL	:= {}

Local oTempTable
   
Local cArqTmpAnt:= "cArqTmp"
Local cQuery	:= ""
Local cGroupby	:= ""
Local cOrderBy		:= ""
Local cChvTmp		:= ""
Local cContaRef		:= ""
Local cCodCtaRef	:= ""


Local nDifCta	:= 0
Local nCont		:= 0
Local nCont1	:= 0
Local nCont2	:= 0 
Local nLastCpoC	:= 0
Local nLastRec	:= 0
Local nX		:= 0    		
Local nTRB		:= 0

If Select(cArqAux) > 0
	(cArqAux)->(dbCloseArea())	
EndIf

aStruSQL	:= Aclone(aCampos)
AADD(aStruSQL, {"CTAAUX"		, "C", 70, 0 })

//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New(cArqAux)
oTemptable:SetFields( aStruSql )

oTempTable:AddIndex("1", aChave)

//------------------
//Criação da tabela
//------------------
oTempTable:Create()

//Passagem por referencia.
ObjTable := oTempTable


cTableNam2 := oTempTable:GetRealName()

cOrderBy := STRTRAN(cChave,"+",",")

cQuery	:= " SELECT ( " + CRLF
cQuery	+= "			SELECT ISNULL(CVD_CTAREF,'') "+CRLF
cQuery	+= " 			FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  			AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 			AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 			AND CVD_CONTA = CONTA "+CRLF
If !Empty(mv_par01)
	cQuery	+= " 			AND " 
	cQuery	+= mv_par01 +  CRLF	
EndIf
cQuery  += " 		) CONTA, "+CRLF
cQuery	+= "		(	SELECT ISNULL(CVD_CTAREF,'') "+CRLF
cQuery	+= " 			FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  			AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 			AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '' "+CRLF
cQuery  += " 		) CTARES, "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_CLASSE,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) TIPOCONTA,  "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_CTASUP,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) SUPERIOR,  "+CRLF
cQuery	+= "		( SELECT ISNULL(CVN_DSCCTA,'')" + CRLF 
cQuery	+= "		 			FROM "+RetSqlName("CVN")+" CVN" + CRLF  
cQuery	+= "		 			WHERE CVN_FILIAL ='"+xFilial("CVN")+"' "+CRLF 
cQuery	+= "		  			AND CVN.D_E_L_E_T_ = ' '"+CRLF 
cQuery	+= "			 		AND CVN_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "					AND CVN_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "		AND CVN_CTAREF = ( 
cQuery	+= "		SELECT ISNULL(CVD_CTAREF,'') 
cQuery	+= "			FROM "+RetSqlName("CVD") + " CVD "+CRLF 
cQuery	+= "			WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF 
cQuery	+= "			AND CVD.D_E_L_E_T_ = ' ' 
cQuery	+= "			AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF 
cQuery	+= "			AND CVD_VERSAO ='"+cVersao+"'"+CRLF
cQuery	+= "			AND CVD_CONTA = CONTA "+CRLF
cQuery	+= "			AND CVD_CTAREF <> '')"+CRLF 
cQuery	+= "			) DESCCTA,  "+CRLF
cQuery	+= " 		'' GRUPO,"+CRLF

For nCont	:= 1 to Len(aStruSQL)
	If !(Alltrim(aStruSQL[nCont][1])$ "CONTA/SUPERIOR/DESCCTA/CTARES/TIPOCONTA/GRUPO/CTAAUX")
		cQuery	+= Alltrim(aStruSQL[nCont][1])
		If nCont < Len(aStruSQL) -1 //Desconsiderando o campo CTAAUX que foi incluido a mais na estrutura.
			cQuery	+= ", "+ CRLF
		Endif	
	EndIf 
Next
cQuery	+= " FROM " + cTableNam1 +  CRLF
cQuery	+= " WHERE TIPOCONTA = '2' " +  CRLF
If cAlias == "CT3"
	cQuery	+= " AND TIPOCC = '2' "
Endif 
cQuery	+= " AND "+  CRLF
cQuery	+= " (	SELECT CVD_CTAREF "+CRLF
cQuery	+= " 				FROM "+RetSqlName("CVD") + " CVD "+CRLF
cQuery	+= " 				WHERE CVD_FILIAL ='"+xFilial("CVD")+"' "+CRLF
cQuery	+= "  				AND CVD.D_E_L_E_T_ = ' ' "+CRLF
cQuery	+= " 				AND CVD_CODPLA ='"+cPlanoRef+"' "+CRLF
cQuery	+= " 				AND CVD_VERSAO ='"+cVersao+"'"+CRLF 
cQuery	+= " 				AND CVD_CONTA = CONTA "+CRLF
If !Empty(mv_par01)
	cQuery	+= " 			AND " 
	cQuery	+= mv_par01 +  CRLF	
EndIf
cQuery  += " 		) <> '' "+CRLF
cQuery	+= " ORDER BY " + cOrderBy
cQuery	:= ChangeQuery(cQuery)

cArqTmpAnt	:= MPSysOpenQuery( cQuery ,"cArqTmpAnt" ,  )

cContaRef	:= (cArqTmpAnt)->CONTA
cContaRef	:= StrTran(cContaRef,".","")
cContaRef	:= StrTran(cContaRef,"/","")
cContaRef	:= StrTran(cContaRef,"-","")

nDifCta		:= 70- LEN(cContaRef)

cChvTmp	:= STRTRAN(CCHAVE,"CONTA","cContaRef")
cChvTmp	:= STRTRAN(CCHVTMP,"CUSTO","(cArqTmpAnt)->CUSTO")
cChvTmp	:= STRTRAN(CCHVTMP,"ITEM","(cArqTmpAnt)->ITEM")
cChvTmp	:= STRTRAN(CCHVTMP,"CLVL","(cArqTmpAnt)->CLVL")
cChvTmp	:= STRTRAN(CCHVTMP,"cContaRef","cContaref+SPACE("+Alltrim(Str(nDifCta)) +")")

dbSelectArea("cArqTmpAnt")
dbGotop()
While !Eof()

	cContaRef	:= StrTran((cArqTmpAnt)->CONTA,".","")
	cCodCtaRef	:= (cArqTmpAnt)->CONTA	
	
	If Empty(cContaRef)
		DbSkip()
		Loop
	EndIf
	
	If cAlias == "CT7"
		cCodigo	:= cContaRef
	ElseIf cAlias == "CT3"
		cCodigo	:= cContaRef
/*		If cAlias == "CT3"
			cCodigo	:= (cArqTmpAnt)->CUSTO
		ElseIf cAlias == "CT4"
			cCodigo	:= (cArqTmpAnt)->ITEM
		ElseIf cAlias == "CTI"
			cCodigo	:= (cArqTmpAnt)->CLVL
		EndIf*/
	EndIf
	If cAlias == "CT3" 
		cCodGer	:= (cArqTmpAnt)->CUSTO
	EndIf	
		
	If !Empty(cSegmento)
		If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
			If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
				dbSkip()
				Loop
			EndIf
		Else
			If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
				Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
				dbSkip()
				Loop
			EndIf
		Endif
	EndIf
			
			
	//Caso faca filtragem por segmento gerencial,verifico se esta dentro
	//da solicitacao feita pelo usuario.
	/*If cAlias == "CT3" .And. cHeader == "CTT"
		If !Empty(cSegmentoG)
			If Empty(cSegIniG) .And. Empty(cSegFimG) .And. !Empty(cFiltSegmG)
				If  !(Substr(cCodGer,nPosG,nDigitosG) $ (cFiltSegmG) )
					dbSkip()
					Loop
				EndIf
			Else
				If Substr(cCodGer,nPosG,nDigitosG) < Alltrim(cSegIniG) .Or. ;
					Substr(cCodGer,nPosG,nDigitosG) > Alltrim(cSegFimG)
					dbSkip()
					Loop
				EndIf
			Endif
		EndIf
	EndIf*/

	DbSelectArea(cArqAux)
	DbSetOrder(1)
	If !DbSeek(Alltrim(&cChvTmp))
		Reclock(cArqAux,.T.)
		
		For nTRB := 1 to Len(aStruSQL)
			If !(Alltrim(aStruSQL[nTRB,1]) $ "NIVEL1/CTAAUX")
				Field->&(aStruSQL[nTRB,1]) :=(cArqTmpAnt)->&(aStruSQL[nTRB,1])
			EndIf
		Next
		(cArqAux)->FILIAL	:= cFilAnt
		(cArqAux)->GRUPO	:= ""
		(cArqAux)->CONTA	:= cContaRef
		(cArqAux)->CTARES	:= cContaRef
		(cArqAux)->CTAAUX	:= cCodCtaRef
		cContaSup			:= (cArqTmpAnt)->SUPERIOR
		cContaSup			:=  StrTran(cContaSup,".","")		
		cContaSup			:=  StrTran(cContaSup,"/","")
		cContaSup			:=  StrTran(cContaSup,"-","")	
		MsUnlock()
	Else
		Reclock(cArqAux,.F.)
		For nTRB := 1 to Len(aStruSQL)
			//If Subs(aStruSQL[nTRB][1],1,6) $ "COLUNA" 
			If aStruSQL[nTRB][2] == "N"
				Field->&(aStruSQL[nTRB,1])	+=((cArqTmpAnt)->&(aStruSQL[nTRB,1]))
			EndIf		
		Next
		MsUnlock()
	Endif
	
	dbSelectArea("cArqTmpAnt")
	DbSkip()
End


If lCt1Sint
	If cAlias == "CT7"
		CtSupPRCT7(cPlanoRef,cVersao,@cArqAux,lCt1Sint,bVariacao)
	Else
		CtEntPrSup(cPlanoRef,cVersao,@cArqAux,cAlias,lVariacao0,cMoeda,2, ,,lEntSint)		
	EndIf
EndIf

RestArea(aSaveArea)

Return(cArqAux)

//-------------------------------------------------------------------
/*{Protheus.doc} CtSupPRCT7
Função para atualizar o arquivo temporário com os dados do plano referencial. 

@author Simone Mie Sato Kakinoana

@param cArqTmp		Arquivo temporário
@param cChave		Chave do índice
@param aCampos		Array com a estrutura da abela a ser criada
@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial

@version P12.1.5
@since   04/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function CtSupPRCT7(cPlanoRef,cVersao,cArqTmpAtu,lCt1Sint,bVariacao)

Local aSaveArea 	:= GetArea()

Local cCtaSupAux	:= ""
Local nRegTmp   	:= 0
Local nColuna1		:= 0
Local nColuna2		:= 0

DEFAULT lCt1Sint := .T.
	
If !lCt1Sint
	RestArea(aSaveArea)	/// SE NÃO DEVE CALCULAR AS SINTETICAS ABORTA
	Return
Endif
		
// Grava contas sinteticas

dbSelectArea(cArqTmpAtu)	
dbGoTop()  

While!Eof()                                 
                                            
	nMovim01	:= MOVIMENTO1
	nMovim02	:= MOVIMENTO2
	If FieldPos("COLUNA_1") > 0
		nColuna1 := COLUNA_1
		nColuna2 := COLUNA_2
	Else
		nColuna1 := nColuna2 := 0.00
	Endif
	nRegTmp 	:= Recno()   
	
	cContaSup 	:= (cArqTmpAtu)->SUPERIOR
	cCtaSupAux	:= cContaSup
	cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
	cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
	cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
	//Tira os caracteres da conta superior
	Reclock(cArqTmpAtu,.F.)
	(cArqTmpAtu)->SUPERIOR	:= cCtaSupAux	
	MsUnlock()
	
	dbSelectArea("CVN")
	dbSetOrder(4)
	MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cArqTmp->CONTA)	

	If Empty(CVN->CVN_CTASUP)
		dbSelectArea(cArqTmpAtu)
		Replace NIVEL1 With .T.
		dbSelectArea("CVN")
	EndIf
		
	MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cContaSup)
		
	While !Eof() .And. CVN->CVN_FILIAL == xFilial("CVN") ;
		.And. CVN->CVN_CODPLA == cPlanoRef; 
		.And. CVN->CVN_VERSAO == cVersao  		
		
		cDesc := CVN->CVN_DSCCTA
		dbSelectArea(cArqTmpAtu)
		dbSetOrder(1)
		
		cCtaSupAux	:= cContaSup
		cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
			
		If !MsSeek(cCtaSupAux)
			
			RecLock(cArqTmpAtu,.T.)
			Replace CONTA		With cCtaSupAux
			Replace DESCCTA		With cDesc
			Replace TIPOCONTA	With CVN->CVN_CLASSE
			Replace SUPERIOR	With CVN->CVN_CTASUP
			Replace CTARES   	With cCtaSupAux
		Else
			RecLock(cArqTmpAtu,.F.)
		EndIf    
		Replace	 MOVIMENTO1 With MOVIMENTO1 + nMovim01
		Replace  MOVIMENTO2 With MOVIMENTO2 + nMovim02
		
		If nColuna1 # 0
			Replace COLUNA_1 With COLUNA_1 + nColuna1
		Endif
		   		
		If nColuna2 # 0
			Replace COLUNA_2 With COLUNA_2 + nColuna2
		Endif
	   		
		If bVariacao <> Nil
			Eval(bVariacao)
		Endif		
	
		dbSelectArea("CVN")
		cContaSup := CVN->CVN_CTASUP
		If Empty(CVN->CVN_CTASUP)
			dbSelectArea(cArqTmpAtu)
			Replace NIVEL1 With .T.
			dbSelectArea("CVN")
			Exit
		EndIf		
		(cArqTmpAtu)->(MsUnlock())
		MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cContaSup)      		
	EndDo

	dbSelectArea(cArqTmpAtu)
	dbSetOrder(1)
	dbGoTo(nRegTmp)
	dbSkip()
EndDo	
		
RestArea(aSaveArea)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} CtEntPrSup
Função para atualizar as sinteticas dos balancetes entidade/conta

@author Simone Mie Sato Kakinoana

@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial
@param cArqAux		Arquivo temporário
@param cAlias		Alias do arquivo
@param lNImpMov		Indica se imprime a coluna de movimento          
@param cMoeda 		Codigo da moeda
@param nComp 		Se for comparativo por mes, indica a quantidade de colunas
@param cEntid_de	Codigo da entidade inicial
@param cEntid_Ate	Codigo da entidade final
@param lEntSint  	Indica se imprime a entidade sintetica

@version P12.1.5
@since   06/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function CtEntPrSup(cPlanoRef,cVersao,cArqAux,cAlias,lNImpMov,cMoeda,nComp, cEntid_De, cEntid_Ate,lEntSint)
		
Local aSaveArea	:= GetArea()				

Local cCadastro	:= ""
Local cSuperior	:= ""
Local cCtaSupAux := ""
Local cSupAux	:= ""	
Local cCpoSup	:= ""
Local cIndice	:= ""
Local cEntid 	:= ""
Local cEntidG	:= ""
Local cCodRes	:= ""
Local cTipoEnt  := ""
Local cContaSup	:= ""
Local cDesc		:= ""
Local cDescEnt  := "" 
Local cEntSup   := ""

Local nIndex	:= 0
Local nSaldoAnt := 0
Local nSaldoAtu := 0
Local nSaldoDeb := 0
Local nSaldoCrd := 0
Local nMovimento:= 0
Local nRegTmp 	:= 0
Local nReg		:= 0
Local nCol		:= 1
Local lFaixa  := .F.
Local aRecAux 	:= {}

DEFAULT nComp		:= 0			///SE FOR COMPARATIVO MES A MES INDICAR A QUANTIDADE DE COLUNAS
DEFAULT cEntid_De	:= ""
DEFAULT cEntid_Ate	:= ""
Default lEntSint	:= .F.

If ! Empty(cEntid_Ate)
	lFaixa := .T.
EndIf

Do Case
Case cAlias == 'CT3'
	cCadastro 	:= "CTT"
	cSuperior	:= 'CTT_FILIAL + CTT_CCSUP'
	cCpoSup		:= 'CTT_CCSUP'
Case cAlias == 'CT4'
	cCadastro 	:= "CTD"
	cSuperior	:= 'CTD_FILIAL + CTD_ITSUP'
	cCpoSup		:= 'CTD_ITSUP'
Case cAlias == 'CTI'
	cCadastro 	:= "CTH"
	cSuperior	:= 'CTH_FILIAL + CTH_CLSUP'
	cCpoSup		:= 'CTH_CLSUP'
EndCase

dbSelectArea("CVN")
DbSelectArea(cCadastro)

If !Empty(cSuperior) .And. Empty(IndexKey(5))
	IndRegua(cCadastro, cIndice := (CriaTrab(, .F. )), cSuperior,,, STR0001)//"Selecionando Registros"
	nIndex:=RetIndex(cCadastro)+1
	dbSelectArea(cCadastro)
Else
	nIndex := 5
Endif

dbSelectArea(cArqAux)
dbGoTop()

While (cArqAux)->(!Eof())

	If cAlias == "CT3"
		If Empty((cArqAux)->CUSTO)
			DbSkip()
			Loop
		Endif
	Endif
	
	If aScan( aRecAux, StrZero(Recno(),10) ) > 0
		dbSkip()
		Loop
	EndIf
	nRegTmp := Recno()
	If cAlias == 'CT3'
		cEntid 	 := (cArqAux)->CUSTO
		cCodRes	 := (cArqAux)->CCRES
		cTipoEnt := (cArqAux)->TIPOCC
		cDescEnt := (cArqAux)->DESCCC
	ElseIf cAlias == 'CT4'
		cEntid 	 := (cArqAux)->ITEM
		cCodRes	 := (cArqAux)->ITEMRES
		cTipoEnt := (cArqAux)->TIPOITEM
		cDescEnt := (cArqAux)->DESCITEM
	ElseIf cAlias == 'CTI'
		cEntid 	 := (cArqAux)->CLVL
		cCodRes	 := (cArqAux)->CLVLRES
		cTipoEnt := (cArqAux)->TIPOCLVL
		cDescEnt := (cArqAux)->DESCCLVL
	EndIf
	
	If cTipoEnt == "1"
		dbSkip()
		Loop
	EndIf
	
	If nComp < 2
		nSaldoAnt:= SALDOANT
		nSaldoAtu:= SALDOATU
		nSaldoDeb:= SALDODEB
		nSaldoCrd:= SALDOCRD
		nMovimento:= MOVIMENTO
	Else
		For nCol := 1 to nComp
			&("nMov"+ALLTRIM(STR(INT(nCol)))) := &("(cArqAux)->MOVIMENTO"+ALLTRIM(STR(INT(nCol))))
		Next
	EndIf
	
	DbSelectArea(cCadastro)
	cEntidG := cEntid
	
	dbSetOrder(1)
	
	MsSeek(xFilial(cCadastro)+cEntidG)
	
	While !Eof() .And. &(cCadastro + "->" + cCadastro + "_FILIAL") == xFilial(cCadastro)
		
		nReg := (cArqAux)->(Recno())
		dbSelectArea("CVN")
		dbSetOrder(4)
		MsSeek(xFilial("CVN")+cPlanoRef+cVersao+(cArqAux)->CONTA)	
		//cContaSup := (cArqAux)->CONTA
		cContaSup := (cArqAux)->CTAAUX
		MsSeek(xFilial("CVN")+cPlanoRef+cVersao+ cContaSup)
		
		If cEntid = cEntidG
			cContaSup := CVN->CVN_CTASUP
			//MsSeek(xFilial("CVN")+ cContaSup)
			MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+cContaSup)
		Endif
		
		cCtaSupAux	:= (cArqAux)->SUPERIOR
		cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
		//Tira os caracteres da conta superior
		Reclock(cArqAux,.F.)
		(cArqAux)->SUPERIOR	:= cCtaSupAux	
		MsUnlock()
		
		While !Eof() .And. CVN->CVN_FILIAL == xFilial("CVN")  ;
			.And. CVN->CVN_CODPLA == cPlanoRef; 
			.And. CVN->CVN_VERSAO == cVersao  		
		
			
			cDesc := CVN->CVN_DSCCTA
			
			cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC"+cMoeda)
			If Empty(cDescEnt)		// Caso nao preencher descricao da moeda selecionada
				cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC01")
			Endif
			cCodRes  := &(cCadastro + "->" + cCadastro + "_RES")
			cTipoEnt := &(cCadastro + "->" + cCadastro + "_CLASSE")
			
			If cAlias == 'CT3'
				cEntSup  := &(cCadastro + "->" + cCadastro + "_CCSUP")
			ElseIf cAlias == 'CT4'
				cEntSup  := &(cCadastro + "->" + cCadastro + "_ITSUP")
				
			ElseIf cAlias == 'CTI'
				cEntSup  := &(cCadastro + "->" + cCadastro + "_CLSUP")
			EndIf
			
			cCtaSupAux	:= cContaSup
			cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
			cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
			cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
			
			dbSelectArea(cArqAux)
			dbSetOrder(1)
			
			If  lEntSint .OR. cTipoEnt == '2'
				
				//If !MsSeek(cEntidG+cContaSup)
				If ! MsSeek(cEntidG+cCtaSupAux)
					dbAppend()
					aAdd(aRecAux, StrZero(Recno(),10) )
					Replace CONTA		With cCtaSupAux
					Replace CTARES		With cCtaSupAux
					Replace DESCCTA 	With cDesc
					Replace TIPOCONTA	With CVN->CVN_CLASSE
					
					cSupAux	:= CVN->CVN_CTASUP
					cSupAux	:= STRTRAN(cSupAux,".","")
					cSupAux	:= STRTRAN(cSupAux,"/","")
					cSupAux	:= STRTRAN(cSupAux,"-","")
					
					Replace SUPERIOR	With cSupAux 					
					If cAlias == 'CT3'
						Replace CUSTO With cEntidG
						Replace CCRES With cCodRes
						Replace TIPOCC With cTipoEnt
						Replace DESCCC With cDescEnt
						Replace CCSUP With cEntSup
					ElseIf cAlias == 'CT4'
						Replace ITEM With cEntidG
						Replace ITEMRES With cCodRes
						Replace TIPOITEM With cTipoEnt
						Replace DESCITEM With cDescEnt
						Replace ITSUP With cEntSup
					ElseIf cAlias == 'CTI'
						Replace CLVL With cEntidG
						Replace CLVLRES With cCodRes
						Replace TIPOCLVL With cTipoEnt
						Replace DESCCLVL WITH cDescEnt
						Replace CLSUP With cEntSup
					EndIf
				EndIf
				
				If nComp < 2
					Replace	 SALDOANT With SALDOANT + nSaldoAnt
					Replace  SALDOATU With SALDOATU + nSaldoAtu
					Replace  SALDODEB With SALDODEB + nSaldoDeb
					Replace  SALDOCRD With SALDOCRD + nSaldoCrd
					If !lNImpMov
						Replace MOVIMENTO With MOVIMENTO + nMovimento
					Endif
				Else
					For nCol := 1 to nComp
				&((cArqAux)+"->MOVIMENTO"+ALLTRIM(STR(INT(nCol)))) += &("nMov"+ALLTRIM(STR(INT(nCol))))
				//&("cArqTmp->MOVIMENTO"+ALLTRIM(STR(INT(nCol)))) += &("nMov"+ALLTRIM(STR(INT(nCol))))
					Next
				EndIf
			Endif
			
			dbSelectArea("CVN")
			cContaSup := CVN->CVN_CTASUP
			If Empty(CVN->CVN_CTASUP) //.And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea(cArqAux)
				Replace NIVEL1 With .T.
				dbSelectArea("CVN")
				Exit
			EndIf
			
			dbSelectArea(cArqAux)
			dbGoto(nRegTmp)
			dbSelectArea("CVN")
			cContaSup := CVN->CVN_CTASUP
			If Empty(cContaSup) .And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea(cArqAux)
				Replace NIVEL1 With .T.
				dbSelectArea("CVN")
			EndIf
			//MsSeek(xFilial("CVN")+ cContaSup)
			MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+cContaSup)
		EndDo
		dbSelectArea(cArqAux)
		dbGoto(nReg)
		DbSelectArea(cCadastro)
		cEntidG := &cCpoSup
		If Empty(cEntidG)		// Ultimo Nivel gerencial
			Exit
		EndIf
		If lFaixa .And. ( cEntidG<cEntid_De .Or. cEntidG>cEntid_Ate )   // se esta fora da faixa da entidade sai do loop tambem
			Exit
		EndIf
		MsSeek(xFilial(cCadastro)+cEntidG)
	EndDo
	dbSelectArea(cArqAux)
	dbGoto(nRegTmp)
	dbSkip()
EndDo

If ! Empty(cIndice)
	dbSelectArea(cCadastro)
	dbClearFil()
	RetIndex(cCadastro)
	dbSetOrder(1)
	Ferase(cIndice + OrdBagExt())
Endif

Restarea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CtEntCtPrS
Função para atualizar o arquivo temporário das entidades superiores com plano referencial 

@author Simone Mie Sato Kakinoana

@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial
@param cArqAux		Arquivo temporário
@param cAlias		Alias do arquivo 
@param lNImpMov		Indica se imprime coluna de movimento
@param cMoeda  		Código da moeda                         

@version P12.1.5
@since   14/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function CtEntCtPrS(cPlanoRef,cVersao,cArqAux,cAlias,lNIMpMov,cMoeda)
		
Local aSaveArea	:= GetArea()				
Local cCadAlias	:= ""
Local cCodSup	:= ""
Local cCtaAux	:= ""
LOCAL cSupAux	:= ""     
Local cCodEnt	:= ""
Local cConta	:= ""
Local cDescCta	:= ""
Local cEntSup	:= ""
Local cDescEnt	:= ""
Local cSeek		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nRegTmp	:= 0
Local aRegInc   := {}

Do Case
Case cAlias == "CT3" 
	cCadAlias 	:= 'CTT'
	cCodSup		:= "CCSUP" 	
	cCodEnt		:= "CUSTO"
Case cAlias == "CT4"
	cCadAlias 	:= 'CTD'
	cCodSup		:=	"ITSUP"
	cCodEnt		:= "ITEM"
Case cAlias == "CTI"
	cCadAlias 	:= 'CTH'
	cCodSup		:=	"CLSUP"
	cCodEnt		:= "CLVL"
EndCase
				         
// Grava sinteticas
dbSelectArea(cArqAux)
dbGoTop()  
While!Eof()                                 
                                            
	nSaldoAnt	:= SALDOANT
	nSaldoAtu	:= SALDOATU
	nSaldoDeb	:= SALDODEB
	nSaldoCrd	:= SALDOCRD   
	nMovimento	:= MOVIMENTO
	nSaldoAntD	:= SALDOANTDB
	nSaldoAntC	:= SALDOANTCR	
	nSaldoAtuD	:= SALDOATUDB
	nsaldoAtuC	:= SALDOATUCR

	nRegTmp := Recno()  
	
	If aScan(aRegInc, nRegTmp) > 0  //se encontrar recno que foi incluido por esta funcao despreza-o
		dbSkip()                    //pois ja subiu ate o topo na atualizacao das superiores
		Loop
	EndIf		
	
	dbSelectArea(cCadAlias)
	dbSetOrder(1)        
	MsSeek(xFilial(cCadAlias)+&(cArqAux+"->"+cCodEnt))
	
	If Empty(&(cCadAlias+"->"+cCadAlias+"_"+cCodSup))
		dbSelectArea(cArqAux)
		Replace NIVEL1 With .T.
		dbSelectArea(cCadAlias)
	EndIf		
	MsSeek(xFilial(cCadAlias)+ &(cArqAux+"->"+cCodSup))
		
	While !Eof() .And. &(cCadAlias+"->"+cCadAlias+"_FILIAL") == xFilial(cCadAlias)

		cConta 	 := (cArqAux)->CONTA	
		cCtaAux	 := (cArqAux)->CTAAUX			
		cDescCta := (cArqAux)->DESCCTA
		
		cEntSup 	:= &(cCadAlias+"->"+cCadAlias+"_"+cCodEnt)
		cDescEnt	:= &(cCadAlias+"->"+cCadAlias+"_DESC"+cMoeda)

		If Empty(cDescEnt)	// Caso nao preencher descricao da moeda selecionada
			cDescEnt	:=&(cCadAlias+"->"+cCadAlias+"_DESC01")
		Endif		

		cSeek 		:= cConta+cEntSup
		
		dbSelectArea("CVN")
		dbSetOrder(4)
		MsSeek(xFilial("CVN")+cPlanoRef+cVersao+cCtaAux,.F.)
		
		dbSelectArea(cArqAux)
		dbSetOrder(1)      
		If !MsSeek(cSeek)
			dbAppend()
			aAdd(aRegInc, Recno())
			Do Case
			Case cAlias == 'CT3'      
				Replace CUSTO   	With cEntSup
				Replace DESCCC		With cDescEnt
				Replace TIPOCC 		With CTT->CTT_CLASSE			
				Replace CCSUP 		With CTT->CTT_CCSUP	
				Replace CCRES		With CTT->CTT_RES	
			Case cAlias == 'CT4'
				Replace ITEM		With cEntSup
				Replace DESCITEM	With cDescEnt
				Replace TIPOITEM 	With CTD->CTD_CLASSE
				Replace ITSUP  		With CTD->CTD_ITSUP		
				Replace ITEMRES		With CTD->CTD_RES									
			Case cAlias == 'CTI'                   
				Replace CLVL    	With cEntSup
				Replace DESCCLVL	With cDescEnt
				Replace TIPOCLVL 	With CTH->CTH_CLASSE
				Replace CLSUP    	With CTH->CTH_CLSUP
				Replace CLVLRES		With CTH->CTH_RES			
			EndCase			
			Replace CONTA		With cConta
			Replace DESCCTA 	With cDescCta
			Replace TIPOCONTA	With CVN->CVN_CLASSE
			
			cSupAux		:= CVN->CVN_CTASUP		
			cSupAux		:= StrTran(cSupAux,".","")
			cSupAux		:= StrTran(cSupAux,"/","")
			cSupAux		:= StrTran(cSupAux,"-","")
			
			Replace SUPERIOR	With cSupAux 	
			Replace CTARES 		With cConta						
		EndIf    
		
		Replace	 SALDOANT 	With SALDOANT + nSaldoAnt
		Replace  SALDOANTDB With SALDOANTDB + nSaldoAntD
		Replace  SALDOANTCR	With SALDOANTCR + nSaldoAntC		
		Replace  SALDOATU 	With SALDOATU + nSaldoAtu
		Replace  SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
		Replace  SALDOATUCR	With SALDOATUCR + nsaldoAtuC		
		Replace  SALDODEB 	With SALDODEB + nSaldoDeb
		Replace  SALDOCRD 	With SALDOCRD + nSaldoCrd
		If !lNImpMov
			Replace MOVIMENTO With MOVIMENTO + nMovimento
		Endif
   		
		dbSelectArea(cCadAlias)
		If Empty(&(cCadAlias+"->"+cCadAlias+"_"+cCodSup))
			dbSelectArea(cArqAux)
			Replace NIVEL1 With .T.
			dbSelectArea(cCadAlias)
			Exit                     						
		EndIf		

		dbSelectArea(cCadAlias)
		MsSeek(xFilial(cCadAlias)+ &((cArqAux)+cCodSup))
	EndDo
	dbSelectArea(cArqAux)
	dbGoto(nRegTmp)
	dbSkip()
EndDo

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} Ct3CtPrSup
Função para atualizar o arquivo temporário das entidades superiores com plano referencial 
Balancete CC X Conta x Item
@author Simone Mie Sato Kakinoana

@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial
@param cArqAux		Arquivo temporário
@param cAlias		Alias do arquivo 
@param lNImpMov		Indica se imprime a coluna de movimento
@param cMoeda  		Indica o codigo da Moeda
@param cHeader 		Indica qual a tabela da entidade (CTT/CTH/CTD)

@version P12.1.5
@since   14/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function Ct3CtPrSup(cPlanoRef,cVersao,cArqAux,cAlias,lNImpMov,cMoeda,cHeader)
		
Local aSaveArea	:= GetArea()				
Local cCadAlias	:= ""
Local cCodSup	:= ""     
Local cCtaSupAux := ""
Local cCodEnt	:= ""
Local cConta	:= ""
Local cDescCta	:= ""
Local cOutEnt	:= ""
Local cEntSup	:= ""
Local cDescEnt	:= ""
Local cSeek		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nRegTmp	:= 0
local cCpoSup	:= ""

dbSelectArea(cArqAux)	
dbGoTop()  

While!Eof()                                 
	If cAlias == "CT4"     
		If cHeader == "CTT"			
			//Somar somente o que for do CT3 => para nao duplicar os valores do CT4 com CT3.			
			If !Empty((cArqAux)->ITEM)
				dbSkip()
				Loop
			EndIf						
		EndIf
	EndIf                                            

	nSaldoAnt:= SALDOANT
	nSaldoAtu:= SALDOATU
	nSaldoDeb:= SALDODEB
	nSaldoCrd:= SALDOCRD   
	nMovimento:= MOVIMENTO

	nRegTmp := Recno()      
	
	If cAlias == 'CT4'      	   
		If cHeader == "CTT"		   
			cCadastro := "CTT"
			cEntid 	 := (cArqAux)->CUSTO
			cCodRes	 := (cArqAux)->CCRES
			cTipoEnt := (cArqAux)->TIPOCC
			cDescEnt := (cArqAux)->DESCCC			
			cCpoSup	 := "CTT_CCSUP"	   
		EndIf		
	EndIf

	DbSelectArea(cCadastro)
	cEntidG := cEntid
	dbSetOrder(1)
	MsSeek(xFilial(cCadastro)+cEntidG)
		
	While !Eof() .And. &(cCadastro + "->" + cCadastro + "_FILIAL") == xFilial()
		
        nReg := (cArqAux)->(Recno())
        
		dbSelectArea("CVN")	
		dbSetOrder(4)      
		//cContaSup := (cArqAux)->CONTA
		cContaSup := (cArqAux)->CTAAUX
		MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+cContaSup)
		
		If cEntid = cEntidG
			cContaSup := CVN->CVN_CTASUP
			MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+ cContaSup)
		Endif
		
		cCtaSupAux	:= (cArqAux)->SUPERIOR
		cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
		//Tira os caracteres da conta superior
		Reclock(cArqAux,.F.)
		(cArqAux)->SUPERIOR	:= cCtaSupAux	
		MsUnlock()
				
		While !Eof() .And. CVN->CVN_FILIAL == xFilial() .And. CVN->CVN_CODPLA == cPlanoRef .And.;
				 CVN->CVN_VERSAO == cVersao
	
			cDesc := CVN->CVN_DSCCTA
	
			cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC"+cMoeda)
			If Empty(cDescEnt)		// Caso nao preencher descricao da moeda selecionada
				cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC01")
			Endif
			cCodRes  := &(cCadastro + "->" + cCadastro + "_RES")
			cTipoEnt := &(cCadastro + "->" + cCadastro + "_CLASSE")

			cCtaSupAux	:= cContaSup
			cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
			cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
			cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
			dbSelectArea(cArqAux)
			dbSetOrder(1)      
	//		If ! MsSeek(cEntidG+cContaSup)
			If ! MsSeek(cEntidG+cCtaSupAux)
				dbAppend()
				Replace CONTA		With cCtaSupAux	
				Replace DESCCTA 	With cDesc
				Replace TIPOCONTA	With CVN->CVN_CLASSE
				Replace CTARES		With cCtaSupAux
				Replace SUPERIOR	With CVN->CVN_CTASUP
				If cAlias == 'CT4'
					If cHeader == "CTT"					
						Replace CUSTO With cEntidG		 
						Replace CCRES With cCodRes
						Replace TIPOCC With cTipoEnt
						Replace DESCCC With cDescEnt
				        If !Empty((cArqAux)->ITEM)
							dbSelectArea("CTD")        
							dbSetOrder(1)
							If MsSeek(xFilial()+(cArqAux)->ITEM)
								Replace ITEM With (cArqAux)->ITEM
							    Replace ITEMRES With CTD->CTD_RES
							    If cMoeda == '01'
					    			Replace DESCITEM With CTD->CTD_DESC01
					    		Else 
					    			If !Empty(&("CTD->CTD_DESC"+cMoeda))
						    			Replace DESCITEM With &("CTD->CTD_DESC"+cMoeda)
						    		Else
						    			Replace DESCITEM With CTD->CTD_DESC01					    			
					    		    EndIf
					    		EndIf
    	    				EndIf
  						EndIf				    
					 EndIf
				EndIf
			EndIf    
			dbSelectArea(cArqAux)
			Replace	 SALDOANT With SALDOANT + nSaldoAnt
			Replace  SALDOATU With SALDOATU + nSaldoAtu
			Replace  SALDODEB With SALDODEB + nSaldoDeb
			Replace  SALDOCRD With SALDOCRD + nSaldoCrd
			If !lNImpMov
				Replace MOVIMENTO With MOVIMENTO + nMovimento
			Endif
	   		
			dbSelectArea("CVN")
			cContaSup := CVN->CVN_CTASUP
			If Empty(CVN->CVN_CTASUP)  
				dbSelectArea(cArqAux)
				Replace NIVEL1 With .T.
				dbSelectArea("CVN")
				Exit
			EndIf
	
			dbSelectArea(cArqAux)
			dbGoto(nRegTmp)
			dbSelectArea("CVN")
			cContaSup := CVN->CVN_CTASUP
			If Empty(cContaSup) .And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea(cArqAux)
				Replace NIVEL1 With .T.
				dbSelectArea("CVN")
			EndIf		
			MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+cContaSup)
		EndDo
		dbSelectArea(cArqAux)
		dbGoto(nReg)
		DbSelectArea(cCadastro)
		cEntidG := &cCpoSup
		If Empty(cEntidG)		// Ultimo Nivel gerencial
			Exit
		EndIf
		MsSeek(xFilial(cCadastro)+cEntidG)
	EndDo
	dbSelectArea(cArqAux)
	dbGoto(nRegTmp)
	dbSkip()
EndDo

RestArea(aSaveArea)

Return
//-------------------------------------------------------------------
/*{Protheus.doc} Ct4CtPrSup
Função para atualizar o arquivo temporário das entidades superiores com plano referencial 
Balancete CC X Conta x Item x Clvl
@author Simone Mie Sato Kakinoana

@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial
@param cArqAux		Arquivo temporário
@param cAlias 		Alias do arquivo
@param lNImpMov		Indica se imprime a coluna de movimento
@param cMoeda  		Indica o codigo da Moeda
@param cHeader 		Indica qual a tabela da entidade (CTT/CTH/CTD)

@version P12.1.5
@since   15/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function Ct4CtPrSup(cPlanoRef,cVersao,cArqAux,cAlias,lNImpMov,cMoeda,cHeader)
		
Local aSaveArea	:= GetArea()				
Local cCadAlias	:= ""
Local cCodSup	:= ""     
Local cCodEnt	:= ""
Local cConta	:= ""
Local cCtaSupAux := ""
Local cDescCta	:= ""
Local cOutEnt	:= ""
Local cEntSup	:= ""
Local cDescEnt	:= ""
Local cSeek		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nRegTmp	:= 0
local cCpoSup	:= ""

dbSelectArea(cArqAux)
dbGoTop()  

While!Eof()                                 
	If cAlias == "CTI"     
		If cHeader == "CTT"			
			//Somar somente o que for do CT3 => para nao duplicar os valores do CT4/CTI com CT3.			
			If !Empty((cArqAux)->ITEM) .Or. !Empty((cArqAux)->CLVL)
				dbSkip()
				Loop
			EndIf						
		EndIf
	EndIf                                            

	nSaldoAnt:= SALDOANT
	nSaldoAtu:= SALDOATU
	nSaldoDeb:= SALDODEB
	nSaldoCrd:= SALDOCRD   
	nMovimento:= MOVIMENTO

	nRegTmp := Recno()      
	
	If cAlias == 'CTI'      	   
		If cHeader == "CTT"		   
			cCadastro := "CTT"
			cEntid 	 := (cArqAux)->CUSTO
			cCodRes	 := (cArqAux)->CCRES
			cTipoEnt := (cArqAux)->TIPOCC
			cDescEnt := (cArqAux)->DESCCC			
			cCpoSup	 := "CTT_CCSUP"	   
		EndIf		
	EndIf

	DbSelectArea(cCadastro)
	cEntidG := cEntid
	dbSetOrder(1)
	MsSeek(xFilial(cCadastro)+cEntidG)
		
	While !Eof() .And. &(cCadastro + "->" + cCadastro + "_FILIAL") == xFilial()
		
        nReg := (cArqAux)->(Recno())
        
		dbSelectArea("CVN")	
		dbSetOrder(4)      
		cContaSup := (cArqAux)->CTAAUX
		MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+cContaSup)		
		
		If cEntid = cEntidG
			cContaSup := CVN->CVN_CTASUP
			MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+cContaSup)
		Endif
		
		cCtaSupAux	:= (cArqAux)->SUPERIOR
		cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
		//Tira os caracteres da conta superior
		Reclock(cArqAux,.F.)
		(cArqAux)->SUPERIOR	:= cCtaSupAux	
		MsUnlock()
		
		While !Eof() .And. CVN->CVN_FILIAL == xFilial() .And. CVN->CVN_CODPLA == cPlanoRef .And.;
				 CVN->CVN_VERSAO == cVersao
	
			cDesc := CVN->CVN_DSCCTA
				
			cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC"+cMoeda)
			If Empty(cDescEnt)		// Caso nao preencher descricao da moeda selecionada
				cDescEnt := &(cCadastro + "->" + cCadastro + "_DESC01")
			Endif
			cCodRes  := &(cCadastro + "->" + cCadastro + "_RES")
			cTipoEnt := &(cCadastro + "->" + cCadastro + "_CLASSE")

			cCtaSupAux	:= cContaSup
			cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
			cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
			cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
			dbSelectArea(cArqAux)
			dbSetOrder(1)      
			//If ! MsSeek(cEntidG+cContaSup)
			If ! MsSeek(cEntidG+cCtaSupAux)
				dbAppend()
				Replace CONTA		With cCtaSupAux	
				Replace DESCCTA 	With cDesc
				Replace TIPOCONTA	With CVN->CVN_CLASSE
				Replace CTARES		With cCtaSupAux
				Replace SUPERIOR	With CVN->CVN_CTASUP

				If cAlias == 'CTI'
					If cHeader == "CTT"					
						Replace CUSTO With cEntidG		 
						Replace CCRES With cCodRes
						Replace TIPOCC With cTipoEnt
						Replace DESCCC With cDescEnt
				        If !Empty((cArqAux)->ITEM)
							dbSelectArea("CTD")        
							dbSetOrder(1)
							If MsSeek(xFilial()+(cArqAux)->ITEM)
								Replace ITEM With (cArqAux)->ITEM
							    Replace ITEMRES With CTD->CTD_RES
							    If cMoeda == '01'
					    			Replace DESCITEM With CTD->CTD_DESC01
					    		Else 
					    			If !Empty(&("CTD->CTD_DESC"+cMoeda))
						    			Replace DESCITEM With &("CTD->CTD_DESC"+cMoeda)
						    		Else
						    			Replace DESCITEM With CTD->CTD_DESC01					    			
					    		    EndIf
					    		EndIf
    	    				EndIf
  						EndIf				    
				        If !Empty((cArqAux)->CLVL)
							dbSelectArea("CTH")        
							dbSetOrder(1)
							If MsSeek(xFilial()+(cArqAux)->CLVL)
								Replace CLVL With (cArqAux)->CLVL
							    Replace CLVLRES With CTH->CTH_RES
							    If cMoeda == '01'
					    			Replace DESCCLVL With CTH->CTH_DESC01
					    		Else 
					    			If !Empty(&("CTH->CTH_DESC"+cMoeda))
						    			Replace DESCCLVL With &("CTH->CTH_DESC"+cMoeda)
						    		Else
						    			Replace DESCCLVL With CTH->CTH_DESC01					    			
					    		    EndIf
					    		EndIf
    	    				EndIf
  						EndIf				    
					 EndIf
				EndIf
			EndIf    
			dbSelectArea(cArqAux)
			Replace	 SALDOANT With SALDOANT + nSaldoAnt
			Replace  SALDOATU With SALDOATU + nSaldoAtu
			Replace  SALDODEB With SALDODEB + nSaldoDeb
			Replace  SALDOCRD With SALDOCRD + nSaldoCrd
			If !lNImpMov
				Replace MOVIMENTO With MOVIMENTO + nMovimento
			Endif
	   		
			dbSelectArea("CVN")
			cContaSup := CVN->CVN_CTASUP
			If Empty(CVN->CVN_CTASUP)  
				dbSelectArea(cArqAux)
				Replace NIVEL1 With .T.
				dbSelectArea("CVN")
				Exit
			EndIf
	
			dbSelectArea(cArqAux)
			dbGoto(nRegTmp)
			
			dbSelectArea("CVN")
			cContaSup := CVN->CVN_CTASUP
			If Empty(cContaSup) .And. Empty(&(cCadastro + "->" + cCpoSup))
				dbSelectArea(cArqAux)
				Replace NIVEL1 With .T.
				dbSelectArea("CVN")
			EndIf		
			MsSeek(xFilial("CVN")+ cPlanoRef+cVersao+cContaSup)
			
		EndDo
		dbSelectArea(cArqAux)
		dbGoto(nReg)
		DbSelectArea(cCadastro)
		cEntidG := &cCpoSup
		If Empty(cEntidG)		// Ultimo Nivel gerencial
			Exit
		EndIf
		MsSeek(xFilial(cCadastro)+cEntidG)
	EndDo
	dbSelectArea(cArqAux)
	dbGoto(nRegTmp)
	dbSkip()
EndDo

RestArea(aSaveArea)

Return

//-------------------------------------------------------------------
/*{Protheus.doc} SupCmpPlRf
Função para atualizar o arquivo temporário das entidades superiores com plano referencial 
Comparativo C.c x Conta
@author Simone Mie Sato Kakinoana

@param cArqTmp		Arquivo temporário
@param cChave		Chave do índice
@param aCampos		Array com a estrutura da abela a ser criada
@param cPlanoRef	Código do plano de contas referencial
@param cVersao 		Versão do plano de contas referencial

@version P12.1.5
@since   18/05/2015
@obs	 
*/
//-------------------------------------------------------------------
Function SupCmpPlRf(cPlanoRef,cVersao,cArqAux,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
				cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
				lNImpMov,cAlias,lCusto,lItem,lClvl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,;
				cFilAte,lImpAntLP,dDataLP,nDivide,cTpVlr,lFiliais,aFiliais,lMeses,aMeses,lVlrZerado,lEntid,aEntid)
				         
Local aSaveArea 	:= GetArea()
Local cMascara1 	:= ""
Local cMascara2		:= ""
Local cCtaSupAux 	:= ""
Local cSupAux		:= ""
Local cEntid1		:= ""	//Codigo da Entidade Principal
Local nRegTmp   	:= 0
Local cChave		:= ""
Local bCond1		:= {||.F.}
Local bCond2		:= {||.F.}
Local cCadAlias1	:= ""	//Alias do Cadastro da Entidade Principal
Local cCadAlias2	:= ""	//Alias do Cadastro da Entidade que sera impressa no corpo.
Local cCodEnt1		:= ""	//Codigo da Entidade Principal
Local cCodEnt2		:= ""	//Codigo da Entidade que sera impressa no corpo do relat.
Local cDesc1		:= ""
Local cDesc2		:= ""
Local cDescEnt		:= ""
Local cDescEnt1		:= ""	//Descricao da Entidade Principal                           
Local cDescEnt2		:= ""	//Descricao da Entidade que sera impressa no corpo.                          
Local cCodSup1		:= ""	//Cod.Superior da Entidade Principal
Local cCodSup2		:= ""	//Cod.Superior da Entidade que sera impressa no corpo.
Local cEntidSup		:= ""
Local nTamDesc1		:= ""
Local nTamDesc2		:= ""
Local cIndice		:= ""
//Local cMensagem		:= OemToAnsi(STR0002)+ OemToAnsi(STR0003)	//"Os saldos compostos estao desatualizados.... ""Favor atualiza-los atraves da rotina de At.Saldos Compostos..."
Local nTotVezes		:= 0
Local aMovimento	:= {0,0,0,0,0,0}
Local nVezes		:= 1

Local lPlanoRef		:= .F. 

DEFAULT lEntid 		:= .F.
DEFAULT aEntid		:= {}

lFiliais			:= Iif(lFiliais == Nil,.F.,lFiliais)
aFiliais			:= Iif(aFiliais==Nil,{},aFiliais)	
lMeses				:= Iif(lMeses == NIl, .F.,lMeses)
aMeses				:= Iif(aMeses==Nil,{},aMeses)
nDivide 			:= Iif(nDivide == Nil,1,nDivide)
lVlrZerado			:= Iif(lVlrZerado == Nil,.T.,lVlrZerado)

If cAlias == "CT3" .And. cHeader == "CTT"
	lPlanoRef	:= .T.
EndIf

If lFiliais	//Se for Comparativo por Filiais
	nTotVezes := Len(aFiliais)		
Else
	If lMeses	//Se for Comparativo por Mes
		nTotVezes := Len(aMeses)
	Else 
		If lEntid	//// se for comparativo x 6 entidades (em parâmetro)
			nTotVezes := Len(aEntid)
		Endif
	EndIf
Endif

Do Case                  
Case cAlias == 'CT3'
	If cHeader == 'CTT'
		cCadAlias1	:= 'CTT'
		cCadAlias2	:= 'CVN'
		cCodEnt1	:= 'CUSTO' 
		cCodEnt2	:= 'CONTA'
		cCodSup1	:= 'CCSUP'
		cCodSup2	:= 'CTASUP'		
		cMascara1	:= aSetOfBook[6]	//Mascara do Centro de Custo
		cMascara2	:= aSetOfBook[2]	//Mascara da Conta
		nTamDesc1	:=	Len(CriaVar("CTT_DESC"+cMoeda))
		nTamDesc2	:=	Len(CriaVar("CVN_DSCCTA"))		
		cDescEnt1	:= "DESCCC"		
		cSuperior	:= 'CTT_FILIAL+CTT_CCSUP'
	EndIf
EndCase

cChave 		:= xFilial(cAlias)+cMoeda+cSaldos+cEntidIni1+cEntidIni2+dtos(dDataIni)
bCond1		:= {||&(cCadAlias1+"->"+cCadAlias1+"_FILIAL") == xFilial(cCadAlias1) .And. &(cCadAlias1+"->"+cCadAlias1+"_"+cCodEnt1) >= cEntidIni1 .And. &(cCadAlias1+"->"+cCadAlias1+"_"+cCodEnt1) <= cEntidFim1 }
bCond2		:= {||&(cCadAlias2+"->"+cCadAlias2+"_FILIAL") == xFilial(cCadAlias2) .And. &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2) >= cEntidIni2 .And. &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2) <= cEntidFim2 }


DbSelectArea(cCadAlias1)

If !Empty(cSuperior) .And. Empty(IndexKey(5))
	IndRegua(cCadAlias1, cIndice := (CriaTrab(, .F. )), cSuperior,,, STR0001)//Selecionando Registros
	nIndex:=RetIndex(cCadAlias1)+1
	dbSelectArea(cCadAlias1)
Else
	nIndex := 5
Endif

// Grava sinteticas
dbSelectArea(cArqAux)	
dbGoTop()  

While!Eof()                                                                         

	nRegTmp := Recno()      
	aMovimento	:= {}
	For nVezes	:= 1 to nTotVezes
		Aadd(aMovimento, 0)               				
	Next
	
	For nVezes := 1 to nTotVezes
		aMovimento[nVezes] := &("COLUNA"+Alltrim(Str(nVezes,2)))	     
	Next
	
	If cAlias == 'CT3' 
		cEntid 	 := &((cArqAux)+"->"+cCodEnt1)
		cDescEnt := &((cArqAux)+"->"+cDescEnt1)
	EndIf                           
	
	dbSelectArea(cCadAlias1)
	cEntidG	:= cEntid	
	dbSetOrder(1)
	MsSeek(xFilial(cCadAlias1)+cEntidG)
	
	While !Eof() .And. &(cCadAlias1 + "->" + cCadAlias1 + "_FILIAL") == xFilial()
	
        nReg := (cArqAux)->(Recno())
	
		dbSelectArea(cCadAlias2)
		If lPlanoRef
			dbSetOrder(4)
		Else
			dbSetOrder(1)
		Endif      
		
		If cCadAlias2	== 'CVN'
			cEntidSup := (cArqAux)->CTAAUX		
		Else 
			cEntidSup := &((cArqAux)+"->"+cCodEnt2)
		EndIf

		If lPlanoRef
			MsSeek(xFilial(cCadAlias2)+cPlanoRef+cVersao+cEntidSup)
			If cEntid = cEntidG
				cEntidSup := &((cArqAux)+"->"+cCodSup2)
				MsSeek(xFilial(cCadAlias2)+cPlanoRef+cVersao+cEntidSup)
			Endif
		Else			
			MsSeek(xFilial(cCadAlias2)+cEntidSup)
			If cEntid = cEntidG
				cEntidSup := &((cArqAux)+"->"+cCodSup2)
				MsSeek(xFilial(cCadAlias2)+ cEntidSup)
			Endif			
		Endif 		
		
		cDesc1	 := &((cCadAlias1)+ "->"+cCadAlias1+"_DESC"+cMoeda)		
		
		If Empty(cDesc1) 
			cDesc1	 := &((cCadAlias1)+ "->"+cCadAlias1+"_DESC01")				
		EndIf
		
		cCtaSupAux	:= (cArqAux)->CTASUP
		cCtaSupAux	:= STRTRAN(cCtaSupAux,".","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"/","")
		cCtaSupAux	:= STRTRAN(cCtaSupAux,"-","")
	
		//Tira os caracteres da conta superior
		Reclock(cArqAux,.F.)
		(cArqAux)->CTASUP	:= cCtaSupAux	
		MsUnlock()		
		
		While !Eof() .And. &(cCadAlias2+"->"+cCadAlias2+"_FILIAL") == xFilial()

			cEntid1	 := &((cArqAux)+"->"+cCodEnt1)
			
			If lPlanoRef
				cDesc2		:= CVN->CVN_DSCCTA			        
				cEntSup2 	:= CVN->CVN_CTAREF
			Else						
				cDescEnt2	:= (cCadAlias2+"->"+cCadAlias2+"_DESC")			
				cDesc2		:= &(cDescEnt2+"->"+cMoeda)			        
				If Empty(cDesc2)	// Caso nao preencher descricao da moeda selecionada		
					cDesc2	:= &(cDescEnt2+"01")
				Endif
				cEntSup2 := &(cCadAlias2+"->"+cCadAlias2+"_"+cCodEnt2)
			EndIf
			
			If lEntid									/// SE FOR ENTIDADE X 6 CODIGOS DE ENTIDADE				
				cSeek 		:= cEntSup2//cEntid1		/// PROCURA SOMENTE A ENTIDADE SUPERIOR POIS PODE NÃO ESTAR AMARRADO A 1ª ENTIDADE
			Else
				cSupAux	:= cEntidSup 
				cSupAux	:= STRTRAN(cSupAux,".","")
				cSupAux	:= STRTRAN(cSupAux,"/","")
				cSupAux	:= STRTRAN(cSupAux,"-","")											
			
				//cSeek 		:= cEntidG+cEntidSup
				cSeek 		:= cEntidG+cSupAux
			Endif
			dbSelectArea((cArqAux))
			dbSetOrder(1)      
			If !MsSeek(cSeek)
				RecLock(cArqAux,.T.)			
				Do Case               
				Case cAlias == 'CT3'
					If cHeader == 'CTT'
						Replace CUSTO		With cEntidG
						Replace DESCCC		With cDesc1
						Replace TIPOCC 		With CTT->CTT_CLASSE			
						Replace CCSUP 		With CTT->CTT_CCSUP	
						Replace CCRES		With CTT->CTT_RES	
						Replace CONTA		With cSupAux
						Replace DESCCTA 	With cDesc2
						Replace TIPOCONTA	With CVN->CVN_CLASSE
						Replace CTASUP 		With CVN->CVN_CTASUP	
						Replace CTARES 		With cEntidSup				
						Replace GRUPO 		With ""
					EndIf
				EndCase
			Else
				RecLock((cArqAux),.F.)
			EndIf    
		
			For nVezes := 1 to nTotVezes
				If cTpVlr == 'M'
					Replace &("COLUNA"+	Alltrim(Str(nVezes,2))) With (&("COLUNA"+Alltrim(Str(nVezes,2)))+aMovimento[nVezes])
				EndIf
    		Next
		
			dbSelectArea(cCadAlias2)
			cEntidSup	:= &(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2)
			If Empty(&(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2)) //.And. Empty(&(cCadAlias1+"->"+cCadAlias1+"_"+cCodSup1))
				dbSelectArea((cArqAux))
				Replace NIVEL1 With .T.
				dbSelectArea(cCadAlias2)
				Exit                     						
			EndIf
			dbSelectArea((cArqAux))
			dbGoto(nRegTmp)
			dbSelectArea(cCadAlias2)
			cEntidSup	:= &(cCadAlias2+"->"+cCadAlias2+"_"+cCodSup2)			
			If Empty(cEntidSup) .And. Empty(&(cCadAlias1+ "->"+cCadAlias1+"_" + cCodSup1))
				dbSelectArea((cArqAux))
				Replace NIVEL1 With .T.
				dbSelectArea(cCadAlias2)
			EndIf
			If lPlanoRef
				MsSeek(xFilial(cCadAlias2)+ cPlanoRef+cVersao+cEntidSup)				
			Else			
				MsSeek(xFilial(cCadAlias2)+ cEntidSup)				
			Endif		
		EndDo
		dbSelectArea(cArqAux)
		dbGoto(nReg)
		dbSelectArea(cCadAlias1)
		cEntidG	:= &(cCadAlias1+ "->"+cCadAlias1+"_"  + cCodSup1)
		If Empty(cEntidG)		// Ultimo Nivel gerencial
			Exit                                         	
		EndIf
		MsSeek(xFilial(cCadAlias1)+cEntidG)
	EndDo
	dbSelectArea(cArqAux)
	dbGoto(nRegTmp)
	dbSkip()
EndDo              

If ! Empty(cIndice)
	dbSelectArea(cCadAlias1)
	dbClearFil()
	RetIndex(cCadalias1)
	dbSetOrder(1)
   	Ferase(cIndice + OrdBagExt()) 
Endif

RestArea(aSaveArea)

Return 

/*/{Protheus.doc} Function CTBASALD
    Esta função tem como objetivo retornar se existe desbalanceamento em entre CT2 e CQs
    @type  Function
    @author Douglas Rodrigues da Silva
    @since 26/07/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function CTBASALD(dDataIni, dDataFim, cFilDe, cFilAte, cTpSald)
Local lReprocess := .F.
Local cSGBD      := TCGetDB()
Local lCusEmp    := AllTrim(SuperGetMv('MV_CUSFIL' ,.F.,"A")) == "E"
Local lCusto 	 := CtbMovSaldo("CTT")
Local cMV_MOEDACM:= SuperGetMv('MV_MOEDACM',.F.,"2345")

DEFAULT dDataIni := StoD("")
DEFAULT dDataFim := StoD("")
DEFAULT cFilDe   := ""
DEFAULT cFilAte  := ""
DEFAULT cTpSald  := ""

//Verifica divergência na CQ1
lReprocess := CTBSLDCQ1(dDataIni, dDataFim, cFilDe, cFilAte, cTpSald, cSGBD, lCusEmp, cMV_MOEDACM)

//Verifica divergência na CQ3
If lCusto .And. !lReprocess	
	lReprocess := CTBSLDCQ3(dDataIni, dDataFim, cFilDe, cFilAte, cTpSald, cSGBD, lCusEmp, cMV_MOEDACM)
EndIf

//Verifica divergência na CQ5 - Implementação próxima sprint
//If lItem .And. !lReprocess	
//	lReprocess := CTBSLDCQ5(dDataIni, dDataFim, cFilDe, cFilAte, cTpSald, cSGBD, lCusEmp, cMV_MOEDACM)
//EndIf

//Verifica divergência na CQ7 - Implementação próxima sprint
//If lClasse .And. !lReprocess	
//	lReprocess := CTBSLDCQ6(dDataIni, dDataFim, cFilDe, cFilAte, cTpSald, cSGBD, lCusEmp, cMV_MOEDACM)
//EndIf

Return lReprocess

/*/{Protheus.doc} Function CTBSLDCQ1
    Esta função tem como objetivo retornar se existe desbalanceamento em entre CT2 e CQ1
    @type  Function
    @author TOTVS
    @since 27/04/2023    
/*/
Static Function CTBSLDCQ1(dDataIni, dDataFim, cFilDe, cFilAte, cTpSald, cSGBD, lCusEmp, cMV_MOEDACM)
Local lReprocess := .F.
Local nCont      := 0
Local cQuery     := ""
Local cFuncSubs  := ""
Local cAliasSld  := GetNextAlias()

DEFAULT dDataIni := StoD("")
DEFAULT dDataFim := StoD("")
DEFAULT cFilDe   := ""
DEFAULT cFilAte  := ""
DEFAULT cTpSald  := ""
DEFAULT cSGBD    := ""
DEFAULT lCusEmp  := .F.
DEFAULT cMV_MOEDACM := ""

cFuncSubs := iIf( cSGBD $ "ORACLE/POSTGRES/DB2/INFORMIX", "SUBSTR" ,"SUBSTRING")

For nCont := 1 To 5

	// Verifica se moeda devera ser considerada
	If nCont # 1 .And. !(Str(nCont,1,0) $ cMV_MOEDACM)
		Loop
	EndIf

	//-- Soma o saldo atual DEBITO - CREDITO      
	cQuery := "SELECT TEMP2.DIF_DEBITO, TEMP2.DIF_CREDITO FROM ( "
	cQuery += "SELECT TEMP.CONTA, " 
	cQuery += " ROUND(SUM(TEMP.CQ1_DEBITO),2) AS CQ1_DEBITO, "
	cQuery += " ROUND(SUM(TEMP.CQ1_CREDITO),2) AS CQ1_CREDITO,  " 
	cQuery += " ROUND(SUM(TEMP.CT2_DEBITO),2) AS CT2_DEBITO, " 
	cQuery += " ROUND(SUM(TEMP.CT2_CREDITO),2) AS CT2_CREDITO, "
	cQuery += " ROUND(SUM(TEMP.CQ1_DEBITO) - SUM(TEMP.CT2_DEBITO),2) AS DIF_DEBITO, "
	cQuery += " ROUND(SUM(TEMP.CQ1_CREDITO) - SUM(TEMP.CT2_CREDITO),2) AS DIF_CREDITO "
	
	cQuery += " FROM (  "

	//Saldo CQ1
	cQuery += "        SELECT " 
	cQuery += "             CQ1.CQ1_CONTA CONTA, "
	cQuery += "             SUM(CQ1.CQ1_DEBITO) CQ1_DEBITO, " 
	cQuery += "             SUM(CQ1.CQ1_CREDIT) CQ1_CREDITO, "
	cQuery += "             0 AS CT2_DEBITO, "
	cQuery += "             0 AS CT2_CREDITO "  
	cQuery += "              FROM "+RetSqlName("CQ1")+" CQ1 WHERE "  	

	If !lCusEmp
		cQuery += "	CQ1.CQ1_FILIAL ='"+xFilial("CQ1")+"' AND "
	Else
		If FWSM0Layout() <> "FF"
			cQuery += cFuncSubs+"(CQ1.CQ1_FILIAL,1,"+cvaltochar(len(fwcodemp()))+") = '"+FwCodEmp()+"' And "
		EndIf
	EndIf
	
	cQuery += " CQ1.CQ1_CONTA <> ' ' AND " 
	cQuery += " CQ1.CQ1_MOEDA ='"+StrZero(nCont,2)+"'
	cQuery += " AND CQ1.CQ1_TPSALD ='1' " 
	cQuery += " AND CQ1.D_E_L_E_T_ = ' ' " 
	cQuery += " AND CQ1.CQ1_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += " GROUP BY CQ1.CQ1_CONTA "

	
	cQuery += " UNION "
	
	//Crédito CT2
	cQuery += " SELECT CT2.CT2_CREDIT, "
	cQuery += "     0 CQ1_DEBITO, " 
	cQuery += "     0 CQ1_CREDITO, "
	cQuery += "     0 DEBITO, " 
	cQuery += "     SUM(CT2.CT2_VALOR) CREDITO "  
	cQuery += " FROM "+RetSqlName("CT2")+" CT2 "  
	
	cQuery += " WHERE " 

	If !lCusEmp
		cQuery += "	CT2.CT2_FILIAL ='"+xFilial("CT2")+"' AND "
	Else
		If FWSM0Layout() <> "FF"
			cQuery += cFuncSubs+"(CT2.CT2_FILIAL,1,"+cvaltochar(len(fwcodemp()))+") = '"+FwCodEmp()+"' And "
		EndIf
	EndIf
	
	cQuery += "     CT2.CT2_DC IN('2','3') AND " 
	cQuery += "     CT2.CT2_MOEDLC ='"+StrZero(nCont,2)+"'
	cQuery += "     AND CT2.CT2_TPSALD ='1' " 
	cQuery += "     AND CT2.D_E_L_E_T_ = ' ' " 
	cQuery += "     AND CT2.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += " GROUP BY CT2.CT2_CREDIT "
	
	cQuery += " UNION "
	
	//Débito CT2
	cQuery += " SELECT CT2.CT2_DEBITO, "
	cQuery += "     0 CQ1_DEBITO, " 
	cQuery += "     0 CQ1_CREDITO, "
	cQuery += "     SUM(CT2_VALOR) DEBITO, " 
	cQuery += "     0 CREDITO "  
	cQuery += " FROM "+RetSqlName("CT2")+" CT2 "  
	
	cQuery += " WHERE "
	
	If !lCusEmp
		cQuery += "	CT2.CT2_FILIAL ='"+xFilial("CT2")+"' AND "
	Else
		If FWSM0Layout() <> "FF"
			cQuery += cFuncSubs+"(CT2.CT2_FILIAL,1,"+cvaltochar(len(fwcodemp()))+") = '"+FwCodEmp()+"' And "
		EndIf
	EndIf 
	
	cQuery += "     CT2.CT2_DC IN('1','3') AND " 	
	cQuery += "     CT2.CT2_MOEDLC ='"+StrZero(nCont,2)+"'
	cQuery += "     AND CT2.CT2_TPSALD ='1' " 
	cQuery += "     AND CT2.D_E_L_E_T_ = ' ' " 
	cQuery += "     AND CT2.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += " GROUP BY CT2.CT2_DEBITO ) TEMP "
	cQuery += " GROUP BY TEMP.CONTA "
	cQuery += " ) TEMP2 WHERE TEMP2.DIF_DEBITO <> 0 OR TEMP2.DIF_CREDITO <> 0 "
	
	cQuery := ChangeQuery(cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSld,.T.,.F.)
	
	//Se achou divergência, reprocessa
	lReprocess := !(cAliasSld)->(Eof())
		
	(cAliasSld)->(DbCloseArea())

	If lReprocess
		Exit
	EndIf

Next nCont

Return lReprocess

/*/{Protheus.doc} Function CTBSLDCQ3
    Esta função tem como objetivo retornar se existe desbalanceamento em entre CT2 e CQ3
    @type  Function
    @author TOTVS
    @since 27/04/2023 
/*/
Static Function CTBSLDCQ3(dDataIni, dDataFim, cFilDe, cFilAte, cTpSald, cSGBD, lCusEmp, cMV_MOEDACM)
Local lReprocess := .F.
Local nCont      := 0
Local cQuery     := ""
Local cFuncSubs  := ""
Local cAliasSld  := GetNextAlias()

DEFAULT dDataIni := StoD("")
DEFAULT dDataFim := StoD("")
DEFAULT cFilDe   := ""
DEFAULT cFilAte  := ""
DEFAULT cTpSald  := ""
DEFAULT cSGBD    := ""
DEFAULT lCusEmp  := .F.
DEFAULT cMV_MOEDACM := ""

cFuncSubs := iIf( cSGBD $ "ORACLE/POSTGRES/DB2/INFORMIX", "SUBSTR" ,"SUBSTRING")

For nCont := 1 To 5

	// Verifica se moeda devera ser considerada
	If nCont # 1 .And. !(Str(nCont,1,0) $ cMV_MOEDACM)
		Loop
	EndIf

	//-- Soma o saldo atual DEBITO - CREDITO      
	cQuery := "SELECT TEMP2.DIF_DEBITO, TEMP2.DIF_CREDITO FROM ( "
	cQuery += "SELECT TEMP.CUSTO, " 
	cQuery += " ROUND(SUM(TEMP.CQ3_DEBITO),2) AS CQ3_DEBITO, "
	cQuery += " ROUND(SUM(TEMP.CQ3_CREDITO),2) AS CQ3_CREDITO,  " 
	cQuery += " ROUND(SUM(TEMP.CT2_DEBITO),2) AS CT2_DEBITO, " 
	cQuery += " ROUND(SUM(TEMP.CT2_CREDITO),2) AS CT2_CREDITO, "
	cQuery += " ROUND(SUM(TEMP.CQ3_DEBITO) - SUM(TEMP.CT2_DEBITO),2) AS DIF_DEBITO, "
	cQuery += " ROUND(SUM(TEMP.CQ3_CREDITO) - SUM(TEMP.CT2_CREDITO),2) AS DIF_CREDITO "
	
	//Saldo CQ3
	cQuery += " FROM (  SELECT " 
	cQuery += "             CQ3.CQ3_CCUSTO CUSTO, "
	cQuery += "             SUM(CQ3.CQ3_DEBITO) CQ3_DEBITO, " 
	cQuery += "             SUM(CQ3.CQ3_CREDIT) CQ3_CREDITO, "
	cQuery += "             0 AS CT2_DEBITO, "
	cQuery += "             0 AS CT2_CREDITO "  
	cQuery += "         FROM "+RetSqlName("CQ3")+" CQ3 "  
	cQuery += "         WHERE "  

	If !lCusEmp
		cQuery += "	CQ3.CQ3_FILIAL ='"+xFilial("CQ3")+"' AND "
	Else
		If FWSM0Layout() <> "FF"
			cQuery += cFuncSubs+"(CQ3.CQ3_FILIAL,1,"+cvaltochar(len(fwcodemp()))+") = '"+FwCodEmp()+"' And "
		EndIf
	EndIf
	
	cQuery += " CQ3.CQ3_CCUSTO <> ' ' AND " 	
	cQuery += " CQ3.CQ3_MOEDA ='"+StrZero(nCont,2)+"'
	cQuery += " AND CQ3.CQ3_TPSALD ='1' " 
	cQuery += " AND CQ3.D_E_L_E_T_ = ' ' " 
	cQuery += " AND CQ3.CQ3_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += " GROUP BY CQ3.CQ3_CCUSTO "
	
	cQuery += " UNION "
	
	//CC Crédito CT2
	cQuery += " SELECT CT2.CT2_CCC, "
	cQuery += "     0 CQ3_DEBITO, " 
	cQuery += "     0 CQ3_CREDITO, "
	cQuery += "     0 DEBITO, " 
	cQuery += "     SUM(CT2.CT2_VALOR) CREDITO "  
	cQuery += " FROM "+RetSqlName("CT2")+" CT2 "  
	
	cQuery += " WHERE " 

	If !lCusEmp
		cQuery += "	CT2.CT2_FILIAL ='"+xFilial("CT2")+"' AND "
	Else
		If FWSM0Layout() <> "FF"
			cQuery += cFuncSubs+"(CT2.CT2_FILIAL,1,"+cvaltochar(len(fwcodemp()))+") = '"+FwCodEmp()+"' And "
		EndIf
	EndIf	
	cQuery += "     CT2.CT2_CCC <> ' ' AND 
	cQuery += "     CT2.CT2_DC IN('2','3') AND "
	cQuery += "     CT2.CT2_MOEDLC ='"+StrZero(nCont,2)+"'
	cQuery += "     AND CT2.CT2_TPSALD ='1' " 
	cQuery += "     AND CT2.D_E_L_E_T_ = ' ' " 
	cQuery += "     AND CT2.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += " GROUP BY CT2.CT2_CCC "
	
	//CC Débito CT2
	cQuery += " UNION "
	
	cQuery += " SELECT CT2.CT2_CCD, "
	cQuery += "     0 CQ3_DEBITO, " 
	cQuery += "     0 CQ3_CREDITO, "
	cQuery += "     SUM(CT2_VALOR) DEBITO, " 
	cQuery += "     0 CREDITO "  
	cQuery += " FROM "+RetSqlName("CT2")+" CT2 "  
	
	cQuery += " WHERE "
	
	If !lCusEmp
		cQuery += "	CT2.CT2_FILIAL ='"+xFilial("CT2")+"' AND "
	Else
		If FWSM0Layout() <> "FF"
			cQuery += cFuncSubs+"(CT2.CT2_FILIAL,1,"+cvaltochar(len(fwcodemp()))+") = '"+FwCodEmp()+"' And "
		EndIf
	EndIf 
	
	cQuery += "     CT2.CT2_CCD <> ' ' AND "
	cQuery += "     CT2.CT2_DC IN('1','3') AND " 
	cQuery += "     CT2.CT2_MOEDLC ='"+StrZero(nCont,2)+"'
	cQuery += "     AND CT2.CT2_TPSALD ='1' " 
	cQuery += "     AND CT2.D_E_L_E_T_ = ' ' " 
	cQuery += "     AND CT2.CT2_DATA BETWEEN '"+DTOS(dDataIni)+"' AND '"+DTOS(dDataFim)+"' "
	cQuery += " GROUP BY CT2.CT2_CCD ) TEMP "
	cQuery += " GROUP BY TEMP.CUSTO "
	cQuery += " ) TEMP2 WHERE TEMP2.DIF_DEBITO <> 0 OR TEMP2.DIF_CREDITO <> 0 "
	
	cQuery := ChangeQuery(cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSld,.T.,.F.)
	
	//Se achou divergência, reprocessa
	lReprocess := !(cAliasSld)->(Eof())
		
	(cAliasSld)->(DbCloseArea())

	If lReprocess
		Exit
	EndIf
	
Next nCont

Return lReprocess


//-------------------------------------------------------------------
/*{Protheus.doc} RetQryMax
Monta Query com Bind - Só é chamado se houve alteração na estrutura da query, caso contrário só executa conforme o Bind

@author Ewerton Franklin
@param cFilEsp  Filial
@param cTipo   	Tipo de data 1- Data do saldo - 2 - Data de Apuração 
@param cTabDia  Tabela de Saldo Dia
@param cArqBase 	Arquivo Base para o saldo ( CT1 - Conta , CTT - Centro de Custo, CTD - Item Contábil , CTH - Classe de Valor, CTU - Saldo por entidade )
@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cEnt05 	Entidade Adicional
@param lEntidad05 	Se existe entidade adiciona
                         
@version P12
@since   26/09/2025
@return  Nil
@obs	 
*/

Static Function RetQryMax(cFilEsp as Character,cTipo as Character,cTabDia as Character,cArqBase as Character,cConta as Character,;
							cCCusto as Character,cItem as Character,cClasse as Character,cEnt05 as Character,lEntidad05 as Logical)

Local cQuery := "" as Character

DEFAULT cTipo 		:= '1'
DEFAULT cTabDia 	:= ""
DEFAULT cArqBase 	:= ""
DEFAULT cConta 		:= Nil
DEFAULT cCCusto 	:= Nil
DEFAULT cItem 		:= Nil 
DEFAULT cClasse 	:= Nil
DEFAULT cEnt05 		:= Nil
DEFAULT lEntidad05 	:= .F.

cQuery += " SELECT " + CRLF 
cQuery += " MAX("+cTabDia+"_DATA) DATAMAX  " + CRLF

cQuery += " FROM " +RetSqlName(cTabDia) + CRLF 
cQuery += " WHERE "
cQuery += cTabDia+"_FILIAL = ? " + CRLF 


If cArqBase != "CTU"
	If cConta!= Nil
		cQuery +=   " AND "+cTabDia+"_CONTA = ? " +CRLF
	EndIf
	If lEntidad05
		If  cArqBase $ 'CTT/CTD/CTH/CV0' .And. cCCusto!= Nil
			cQuery +=   " AND "+cTabDia+"_CCUSTO = ? " +CRLF
		EndIf
		If  cArqBase $ 'CTD/CTH/CV0' .And. cItem!= Nil
			cQuery +=   " AND "+cTabDia+"_ITEM = ? " +CRLF
		EndIf
		If  cArqBase $ 'CTH/CV0' .And. cClasse!= Nil
			cQuery +=   " AND "+cTabDia+"_CLVL = ? " +CRLF
		EndIf
		If  cArqBase $ 'CV0' .And. cEnt05 != Nil
			cQuery +=   " AND "+cTabDia+"_ENT05 = ? " +CRLF
		EndIf
	Else
		If  cArqBase $ 'CTT/CTD/CTH' .And. cCCusto!= Nil
			cQuery +=   " AND "+cTabDia+"_CCUSTO = ? " +CRLF
		EndIf
		If  cArqBase $ 'CTD/CTH' .And. cItem!= Nil
			cQuery +=   " AND "+cTabDia+"_ITEM = ? " +CRLF
		EndIf
		If  cArqBase $ 'CTH' .And. cClasse!= Nil
			cQuery +=   " AND "+cTabDia+"_CLVL = ? " +CRLF
		EndIf
	EndIf
Else
	cQuery +=   " AND "+cTabDia+"_IDENT = ? " +CRLF
	cQuery +=   " AND "+cTabDia+"_CODIGO = ? " +CRLF
EndIf
 
cQuery += " 	AND "+cTabDia+"_MOEDA = ? " + CRLF 
If !lTpSldIn
	cQuery += " 	AND "+cTabDia+"_TPSALD = ? " + CRLF
Else 
	cQuery += " 	AND "+cTabDia+"_TPSALD IN (?)"  + CRLF 
Endif
cQuery += " 	AND "+cTabDia+"_DATA <= ? " + CRLF 

cQuery += " 	AND  D_E_L_E_T_ = ? " + CRLF 

oQueryQry := FwExecStatement():New(cQuery)

Return 


//-------------------------------------------------------------------
/*{Protheus.doc} RetKeyAtu

Cria chave para verificar se será necessário recriar estrutura da Query

@author Ewerton Franklin
                         
@version P12
@since   26/09/2025
@return  Nil
@obs	 
*/

Static Function RetKeyAtu(cFilEsp as Character ,cArqBase as Character ,cTabMes as Character,cTabDia as Character,cIdent as Character,cTpSldIn as Character,cMoeda as Character,cCodigo as Character,lImpAntLP as Logical) as Character

Local cKey as Character

DEFAULT cFilEsp  := " "
DEFAULT cArqBase := " "
DEFAULT cTabMes  := " "
DEFAULT cTabDia  := " " 
DEFAULT cIdent   := " " 
DEFAULT cTpSldIn := " "  
DEFAULT cMoeda   := " " 
DEFAULT cCodigo  := " " 
DEFAULT lImpAntLP:= .F.

cKey := AllTrim(cFilEsp)+AllTrim(cArqBase)+AllTrim(cTabMes)+AllTrim(cTabDia)+AllTrim(cIdent)+AllTrim(cTpSldIn)+AllTrim(cMoeda)+AllTrim(cCodigo)+Iif(lImpAntLP,"1","0")

Return cKey


//-------------------------------------------------------------------
/*{Protheus.doc} BindKeys

Binda as CHAVES (CONTA/CCUSTO/ITEM/CLVL/ENT05 ou IDENT/CODIGO)
Se lForSelect=.T., respeita os flags lSel* (ordem do cCpoTotVal). 
@author Ewerton Franklin
                         
@version P12
@since   26/09/2025
@return  Nil
@obs	 
*/

Static Function BindKeys(nParam as Numeric ,lForSelect as Logical ,cArqBase as Character,cConta as Character,cCCusto as Character,;
				cItem as Character,cClasse as Character, lEntidad05 as Logical ,cEnt05 as Character ,cIdent as Character,cCodigo as Character) as Numeric

If cArqBase != "CTU"
	If lForSelect
		If lSelConta
			oQrySldCQ:SetString(nParam++, cConta)
		EndIf
	Else
		If cConta != Nil
			oQrySldCQ:SetString(nParam++, cConta)
		EndIf
	EndIf

	If lEntidad05
		If cArqBase $ 'CTT/CTD/CTH/CV0' .And. cCCusto != Nil
			If !lForSelect .Or. lSelCCusto
				oQrySldCQ:SetString(nParam++, cCCusto)
			EndIf
		EndIf
		If cArqBase $ 'CTD/CTH/CV0' .And. cItem != Nil
			If !lForSelect .Or. lSelItem
				oQrySldCQ:SetString(nParam++, cItem)
			EndIf
		EndIf
		If cArqBase $ 'CTH/CV0' .And. cClasse != Nil
			If !lForSelect .Or. lSelCLVL
				oQrySldCQ:SetString(nParam++, cClasse)
			EndIf
		EndIf
		If cArqBase $ 'CV0' .And. cEnt05 != Nil
			If !lForSelect .Or. lSelEnt05
				oQrySldCQ:SetString(nParam++, cEnt05)
			EndIf
		EndIf
	Else
		If cArqBase $ 'CTT/CTD/CTH' .And. cCCusto != Nil
			If !lForSelect .Or. lSelCCusto
				oQrySldCQ:SetString(nParam++, cCCusto)
			EndIf
		EndIf
		If cArqBase $ 'CTD/CTH' .And. cItem != Nil
			If !lForSelect .Or. lSelItem
				oQrySldCQ:SetString(nParam++, cItem)
			EndIf
		EndIf
		If cArqBase $ 'CTH' .And. cClasse != Nil
			If !lForSelect .Or. lSelCLVL
				oQrySldCQ:SetString(nParam++, cClasse)
			EndIf
		EndIf
	EndIf
Else
	If lForSelect
		If lSelIdent
			oQrySldCQ:SetString(nParam++, cIdent)
		EndIf
		If lSelCodigo
			oQrySldCQ:SetString(nParam++, cCodigo)
		EndIf
	Else
		oQrySldCQ:SetString(nParam++, cIdent)
		oQrySldCQ:SetString(nParam++, cCodigo)
	EndIf
EndIf

Return nParam



//-------------------------------------------------------------------
/*{Protheus.doc} BindWhere

Binda a sequência comum do WHERE (serve para DIA e MÊS):

@author Ewerton Franklin
FILIAL ? CHAVES ? MOEDA ? (TPSALD =) ? D_E_L_E_T_  

@version P12
@since   26/09/2025
@return  Nil
@obs	 
*/

Static Function BindWhere( nParam as Numeric,cFilEsp as Character,cMoeda as Character,cTpSald as Character,cArqBase as Character,;
				cConta as Character,cCCusto as Character,cItem as Character,cClasse as Character,lEntidad05 as Logical,;
				cEnt05 as Character,cIdent as Character,cCodigo as Character) as Numeric

oQrySldCQ:SetString(nParam++, cFilEsp)      
nParam := BindKeys( nParam, .F.,cArqBase,cConta,cCCusto,cItem,cClasse,lEntidad05,cEnt05,cIdent,cCodigo)   
oQrySldCQ:SetString(nParam++, cMoeda)      
If !lTpSldIn
	oQrySldCQ:SetString(nParam++, cTpSald)   
Else
	oQrySldCQ:SetUnsafe(nParam++, cTpSald)
EndIf
oQrySldCQ:SetString(nParam++, Space(1))  

Return nParam

