// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 6      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH" 
#include "OFIXA019.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIXA019 ³ Autor ³ Luis Delorme                      ³ Data ³ 28/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Liberacao de Credito do Oficina                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIXA019()
//
Local cFilTop     := ""
Local cConcat     := ""
Local cFunc       := ""
Private cCadastro := STR0001
Private cMotivo   := "000012"  // Filtro da consulta do motivo
Private aRotina   := MenuDef()
Private aCores    := {	{'LEFT(VSW->VSW_NUMORC,2)<>"OS"','BR_PRETO'},; // Solicitacao de Orcamento
						{'LEFT(VSW->VSW_NUMORC,2)=="OS".and.VSW->VSW_LIBVOO=="OS_TOTAL"','BR_AZUL'},; // Solicitacao de OS Total
						{'LEFT(VSW->VSW_NUMORC,2)=="OS".and.VSW->VSW_LIBVOO<>"OS_TOTAL"','BR_VERDE'}} // Solicitacao de OS + Tipo de Tempo
Private oSqlHelp:= DMS_SqlHelper():New()
cFunc   := oSqlHelp:CompatFunc("SUBSTR")
cConcat := oSqlHelp:Concat({cFunc+'(VSW_DATHOR,7,2)', cFunc+'(VSW_DATHOR,4,2)', cFunc+'(VSW_DATHOR,1,2)'})
cFilTop := cFunc+"(VSW_NUMORC,1,2) = 'OS' AND "+cConcat+" > '"+Right(dtos(ddatabase - GetNewPar("MV_MIL0017",15)),6)+"' AND VSW_DTHLIB = '" + Space(TamSX3("VSW_DTHLIB")[1]) + "' "

if ExistBlock("OXA019BR")
	ExecBlock("OXA019BR",.F.,.F.)
EndIf

mBrowse( 6, 1,22,75,"VSW",,,,,,aCores,,,,,,,,cFilTop)

return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA019V  ³ Autor ³ Luis Delorme                      ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Orcamento de Oficina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA019V(cAlias,nReg,nOpc)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA019M  ³ Autor ³ Luis Delorme                      ³ Data ³ 05/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Mostra Posicao do Cliente e motivo do Pedido de Liberacao              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA019M()
//

PutMv("MV_CKCLIXX","")
DBSelectArea("VS1")
FG_CKCLINI(VSW->VSW_CODCLI+VSW->VSW_LOJA,.t.,.t.)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA019V  ³ Autor ³ Luis Delorme                      ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem da Janela de Orcamento de Oficina                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA019L(cAlias,nReg,nOpc)
//
if ExistBlock("OXA019LB")
	if !ExecBlock("OXA019LB",.f.,.f.)
		Return(.f.)
	Endif
Endif
DBSelectArea("VSW")
if !MsgYesNo(STR0008,STR0006)
	return .f.
endif
if !MsgYesNo(STR0009,STR0006)
	return .f.
endif
// dbClearFilter()           // CLAUDIA

if VAI->(FieldPos("VAI_ALLBCR")) > 0  
	DbSelectArea("VAI")
	Dbsetorder(4)
	DbSeek(xFilial("VAI")+__cUserID)
	if VAI->VAI_ALLBCR > 0 
		nValConv := VAI->VAI_ALLBCR
		VO1->(DbSeek(xFilial("VO1")+ VSW->VSW_NUMOSV))
		If  VAI->(FieldPos("VAI_ALLBCM")) > 0  .AND. (VO1->VO1_MOEDA == 2 .OR. VAI->VAI_ALLBCM == 2 ) .AND. VO1->VO1_MOEDA <> VAI->VAI_ALLBCM
			nValConv := FG_MOEDA( VAI->VAI_ALLBCR  , VAI->VAI_ALLBCM , VO1->VO1_MOEDA )
		Endif
		if nValConv < VSW->VSW_VALCRE
			MsgStop(STR0022,STR0006)		
			Return(.f.)
		Endif
	Endif
Endif

                              
cMotivo := space(TamSX3("VSW_MOTIVO")[1])
nOpca := 1
DEFINE MSDIALOG oDlgMot TITLE OemtoAnsi(STR0015) FROM  01,11 TO 08,76 OF oMainWnd

oTPanelLib := TPanel():New(0,0,"",oDlgMot,NIL,.T.,.F.,NIL,NIL,0,08,.T.,.F.)
oTPanelLib:Align := CONTROL_ALIGN_ALLCLIENT

@ 005,003 SAY STR0014 SIZE 170,40  Of oTPanelLib PIXEL 
@ 005,030 MSGET oMotivo VAR cMotivo PICTURE "@!" SIZE 200,4 OF oTPanelLib PIXEL COLOR CLR_BLUE 


ACTIVATE MSDIALOG oDlgMot ON INIT EnchoiceBar(oDlgMot,{||nOpca := 1,oDlgMot:End()},{||nOpca := 0,oDlgMot:End()}) CENTER

//liberao 
// DBSelectArea("VAI")
// DBSetOrder(6)
// DBSeek(xFilial("VAI")+VS1->VS1_CODVEN)

// DBSelectArea("SA1")
// DBSetOrder(1)
// DBSeek(xFIlial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)

// if nOpca == 1
// 	DBSelectArea("VSW")
// 	RecLock("VSW",.f.)
// 	VSW_USULIB := Subs(cUsuario,7,15)
// 	VSW_DTHLIB := Left(Dtoc(dDataBase),6)+Right(STR(Year(dDataBase)),2)+"-"+Left(Time(),5)
// 	VSW_MOTIVO := cMotivo
// 	msunlock()
// endif

OF019002J_GravaLibCredito()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA019P  ³ Autor ³ Thiago		                    ³ Data ³ 04/09/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Posicao do cliente.						                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA019P(cAlias,nReg,nOpc)

DBSelectArea("SA1")
DBSetOrder(1)
DBSeek(xFilial("SA1")+VSW->VSW_CODCLI + VSW->VSW_LOJA)  
FC010CON() // Tela de Consulta -> Posicao do Cliente

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OXA019LG ³ Autor ³ Andre Luis Almeida                ³ Data ³ 23/02/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda - Solicitacoes de Liberacao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OXA019LG()
Local aLegenda := {	{'BR_PRETO', STR0019 },; // Solicitacao de Orcamento
					{'BR_AZUL' , STR0020 },; // Solicitacao de OS Total
					{'BR_VERDE', STR0021 }}  // Solicitacao de OS + Tipo de Tempo
BrwLegenda(cCadastro,STR0018,aLegenda) // Legenda
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Luis Delorme                      ³ Data ³ 26/01/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Menu (AROTINA) - Orcamento de Oficina                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Veiculos                                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {	{ STR0002, "axPesqui" , 0, 1 },; // "Pesquisar"
					{ STR0014, "OXA019M"  , 0, 2 },; // "Verificar Motivo"
					{ STR0004, "OXA019L"  , 0, 4 },; // "Liberar"
					{ STR0016, "OFIXC007(.t.)" , 0, 2 },; // Consulta
					{ STR0017, "OXA019P"  , 0, 4 },; // Posicao do cliente
					{ STR0018, "OXA019LG" , 0, 4, 2, .f.}} // Legenda
Return aRotina



/*/{Protheus.doc} OXA01901D_Remove_Lib_Credito_Pendente

Remover a solicitação de liberação de crédito pendente (caso exista)
no caso de cancelamento do tipo de tempo

@author Francisco Carvalho
@since 14/07/2023
@version 1.0
@return NIL
/*/

Function OXA01901D_Remove_Lib_Credito_Pendente (cOsVSW, cCliVSW, cLojaVSW, cTTVSW, cLibVSW)

Local cQry    := ""
Local nRegVSW := 0

Default cOsVSW   := ""
Default cCliVSW  := ""
Default cLojaVSW := ""
Default cTTVSW   := ""
Default cLibVSW  := ""

cQry := " SELECT VSW.R_E_C_N_O_ " 
cQry += " FROM " + RetSQLName("VSW") + " VSW "
cQry += " WHERE VSW_FILIAL = '"+xFilial("VSW")+"' "
cQry += " AND VSW_NUMORC = 'OS"+cOsVSW+"' "
cQry += " AND VSW_CODCLI = '"+cCliVSW+"' "
cQry += " AND VSW_LOJA = '"+cLojaVSW+"' "
cQry += " AND VSW_TIPTEM = '"+cTTVSW+"' "
cQry += " AND VSW_LIBVOO = '"+cLibVSW+"' "
cQry += " AND VSW_ORIGEM = 'OFIXX100' "
cQry += " AND VSW_DTHLIB = ' ' "
cQry += " AND VSW.D_E_L_E_T_ = ' '"

nRegVSW := FM_SQL(cQry)
If nRegVSW > 0 
	DBSelectArea("VSW")
	DBGoTo(nRegVSW)
    Reclock("VSW",.f.,.t.)
	DbDelete()
	MsUnlock()
EndIf
Return



/*/{Protheus.doc} OF019002J_GravaLibCredito()
	Isola a liberacao de credito para ser utilizada tanto protheus tanto quanto via webservice
	@type  Function
	@author Renan Migliari
	@since 03/07/2025
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function OF019002J_GravaLibCredito(oWsData)
	local cDatAjust := Left(Dtoc(dDataBase),6)+Right(STR(Year(dDataBase)),2)+"-"+Left(Time(),5)
	default oWsData	 := nil
	
	if oWsData == nil
		DBSelectArea("VAI")
		DBSetOrder(6)
		DBSeek(xFilial("VAI")+VS1->VS1_CODVEN)

		DBSelectArea("SA1")
		DBSetOrder(1)
		DBSeek(xFIlial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)

		if nOpca == 1
			dbSelectArea("VSW")
			RecLock("VSW",.f.)
			VSW_USULIB := Subs(cUsuario,7,15)
			VSW_DTHLIB := cDatAjust
			VSW_MOTIVO := cMotivo
			msunlock()
		endif
	endif

	if oWsData <> nil
		dbSelectArea("VSW")
		dbGoTo(oWsData["recno"])
		if !Empty(VSW->VSW_NUMORC)
			reclock("VSW", .f.)
			VSW->VSW_USULIB := oWsData["nomeUsuario"]
			VSW->VSW_DTHLIB := cDatAjust
			VSW->VSW_MOTIVO := oWsData["motivo"]
			
			VSW->(msUnlock())
			VSW->(dbCloseArea())
		endif
	endif
Return