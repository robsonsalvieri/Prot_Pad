#include "PROTHEUS.CH"
#include "OFIIA410.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OFIIA410  ³ Autor ³ Luis Delorme         ³ Data ³ 21/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cadastro de Negocios do Cliente                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OFIIA410                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MP8                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function OFIIA410()
	OFIA532()
Return

Static Function MenuDef()
Local aRotina := {  { oemtoansi(STR0007),"AxPesqui", 0 , 1,,.F.},;  // "Pesquisar"
                    { oemtoansi(STR0008),"AxCadVis", 0 , 2},;       // "Visualizar"
                    { oemtoansi(STR0009),"AxCadInc", 0 , 3},;       // "Incluir"
                    { oemtoansi(STR0010),"AxCadAlt", 0 , 4},;       // "Alterar"
                    { oemtoansi(STR0011),"AxCadDel", 0 , 5}}        // "Excluir"
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ OFIIA410OK ³ Autor ³ Thiago              ³ Data ³ 19/08/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do cadastro.			                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ OFIIA410                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA410OK()
      
dbSelectArea("VZO")
dbSetOrder(1)           
if dbSeek(xFilial("VZO")+M->VZO_CLIENT+M->VZO_LOJA+M->VZO_TIPO)
   MsgStop(STR0002)
   Return(.f.)
Endif
Return(.t.)

/*/{Protheus.doc} OIA410011_Tipos_de_Negocios_do_Cliente
	Visualiza todos os Tipos de Negocios de um determinado Cliente
	
	@author Andre Luis Almeida
	@since 08/03/2022
/*/
Function OIA410011_Tipos_de_Negocios_do_Cliente( cCodCli , cLojCli )
Local oTpNegCli
Local aSize      := FWGetDialogSize( oMainWnd )
Local cFiltroVZN := ""
Local cTitulo    := STR0003+": "+cCodCli+"-"+cLojCli+" " // Tipos de Negócios do Cliente
Private aRotina  := {}
//
If !Empty(cCodCli+cLojCli)
	//
	cTitulo += FM_SQL("SELECT A1_NOME FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+cCodCli+"' AND A1_LOJA='"+cLojCli+"' AND D_E_L_E_T_=' '")
	//
	cFiltroVZN := "@ EXISTS ( "
	cFiltroVZN += " SELECT VZO.VZO_CLIENT "
	cFiltroVZN += "   FROM "+RetSQLName("VZO")+" VZO"
	cFiltroVZN += "  WHERE VZO.VZO_FILIAL=VZN_FILIAL"
	cFiltroVZN += "    AND VZO.VZO_CLIENT='"+cCodCli+"'"
	cFiltroVZN += "    AND VZO.VZO_LOJA='"+cLojCli+"'"
	cFiltroVZN += "    AND VZO.VZO_TIPO=VZN_TIPO"
	cFiltroVZN += "    AND VZO.D_E_L_E_T_=' '"
	cFiltroVZN += " )"
	//
	oTpNegCli := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],cTitulo,,,,128,,,,,.t.)
	//
	oBrwVZN:= FWMBrowse():New()
	oBrwVZN:SetOwner(oTpNegCli)
	oBrwVZN:SetAlias("VZN")
	oBrwVZN:SetMenuDef("")
	oBrwVZN:DisableLocate()
	oBrwVZN:DisableDetails()
	oBrwVZN:SetAmbiente(.F.)
	oBrwVZN:SetWalkthru(.F.)
	oBrwVZN:SetDescription(cTitulo)
	oBrwVZN:AddButton(STR0004,{ || oTpNegCli:End() }) // Fechar
	oBrwVZN:SetFilterDefault(cFiltroVZN)
	oBrwVZN:SetInsert(.f.)
	oBrwVZN:ForceQuitButton(.T.)
	oBrwVZN:SetUseFilter()
	oBrwVZN:Activate()
	//
	oTpNegCli:Activate()
	//
Else
	MsgStop(STR0005,STR0006) // Necessário informar um cliente. / Atenção
EndIf
//
Return
