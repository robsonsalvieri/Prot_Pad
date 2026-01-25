#INCLUDE "TOTVS.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "OFIC280.CH"

Function OFIC280()
Local oOFIC280
Local aSize   := FWGetDialogSize( oMainWnd )
Private cCadastro := STR0001 // Saldos das Promoções
Private dFDatRef := dDataBase
Private cFGruIte := space(GetSx3Cache("B1_GRUPO","X3_TAMANHO"))
Private cFCodIte := space(GetSx3Cache("B1_CODITE","X3_TAMANHO"))
Private cFSldAtu := STR0002 // Todos

SetKey(VK_F12,{ || OC2800011_FiltroBrowse() })

oOFIC280 := MSDIALOG() :New(aSize[1],aSize[2],aSize[3],aSize[4],cCadastro,,,,128,,,,,.t.)

oTPOC280 := TPanel():New(0,0,"",oOFIC280,NIL,.T.,.F.,NIL,NIL,120,oOFIC280:nClientHeight,.F.,.F.)
oTPOC280:Align := CONTROL_ALIGN_ALLCLIENT

oBrwOC280 := FWMBrowse():New()
oBrwOC280:SetOwner(oTPOC280)
oBrwOC280:SetAlias('VBM')
oBrwOC280:SetMenuDef( '' )
oBrwOC280:ForceQuitButton()
oBrwOC280:SetDescription(cCadastro)
oBrwOC280:AddFilter(STR0011+" F12 - "+STR0003+": "+Transform(dFDatRef,"@D") , "@ VBM_DATINI <= '"+dtos(dFDatRef)+"' and VBM_DATFIN >= '"+dtos(dFDatRef)+"' ",.t.,.f.,,,,"datareferencia") // Filtro / Data de Referencia
oBrwOC280:SetDoubleClick( { || OC2800021_Visualizar() } )
oBrwOC280:AddButton(STR0004,{ || oOFIC280:End() }) // Fechar
oBrwOC280:AddButton(STR0005,{ || OC2800021_Visualizar() }) // Visualiza Movimentações
oBrwOC280:AddButton(STR0011+" F12",{ || OC2800011_FiltroBrowse() }) // Filtro
oBrwOC280:DisableDetails()
oBrwOC280:Activate()

oOFIC280:Activate()

SetKey(VK_F12, NIL)

Return

/*/
{Protheus.doc} OC2800011_FiltroBrowse
Filtro do Browse do VBM - Saldos das Promoções

@author Andre Luis Almeida
@since 27/05/2022
/*/
Function OC2800011_FiltroBrowse()
Local aRet       := {}
Local aParamBox  := {}
Local aSldAtu    := {STR0002,STR0006,STR0007} // Todos / Com Saldo / Sem Saldo
Local cQuery     := ""

SetKey(VK_F12, NIL)

aAdd(aParamBox,{1,STR0003,dFDatRef,"@D",'',"",".t.",065,.t.}) // Data de Referencia
aAdd(aParamBox,{1,STR0008,cFGruIte,"@!",'vazio().or.FG_SEEK("SBM","MV_PAR02",1,.f.)',"SBM",".t.",045,.f.}) // Grupo do Item
aAdd(aParamBox,{1,STR0009,cFCodIte,"@!",'vazio().or.FG_POSSB1("MV_PAR03","SB1->B1_CODITE","MV_PAR02")',"B11",".t.",100,.f.}) // Código do Item
aAdd(aParamBox,{2,STR0010,cFSldAtu,aSldAtu,65,"",.f.,".t."}) // Saldo Atual

If ParamBox(aParamBox,STR0011+" F12",@aRet,,,,,,,,.F.,.F.) // Filtro
	//
	dFDatRef := aRet[1]
	cFGruIte := aRet[2]
	cFCodIte := aRet[3]
	cFSldAtu := aRet[4]
	//
	oBrwOC280:DeleteFilter("datareferencia")
	oBrwOC280:DeleteFilter("grupoitem")
	oBrwOC280:DeleteFilter("codigoitem")
	oBrwOC280:DeleteFilter("saldoatual")
	oBrwOC280:Refresh()
	//
	oBrwOC280:AddFilter(STR0011+" F12 - "+STR0003+": "+Transform(dFDatRef,"@D") , "@ VBM_DATINI <= '"+dtos(dFDatRef)+"' and VBM_DATFIN >= '"+dtos(dFDatRef)+"' ",.t.,.f.,,,,"datareferencia") // Filtro / Data de Referencia
	If !Empty(cFGruIte)
		oBrwOC280:AddFilter(STR0011+" F12 - "+STR0008+": "+cFGruIte , "@ VBM_GRUITE = '"+cFGruIte+"' ",.t.,.t.,,,,"grupoitem") // Filtro / Grupo do Item
	EndIf
	If !Empty(cFCodIte)
		oBrwOC280:AddFilter(STR0011+" F12 - "+STR0009+": "+cFCodIte , "@ VBM_CODITE = '"+cFCodIte+"' ",.t.,.t.,,,,"codigoitem") // Filtro / Código do Item
	EndIf
	If cFSldAtu <> STR0002 // diferente de Todos
		cQuery := "@ ( "
		cQuery += "SELECT SUM( VBN.VBN_QTDMOV * CASE VBN.VBN_TIPMOV WHEN '1' THEN -1 ELSE 1 END ) QTDATU"
		cQuery += "  FROM "+RetSqlName("VBN")+" VBN "
		cQuery += " WHERE VBN.VBN_FILIAL = VBM_FILIAL "
		cQuery += "   AND VBN.VBN_CODVBM = VBM_CODIGO "
		cQuery += "   AND VBN.D_E_L_E_T_ = ' ' )"
		If cFSldAtu == STR0006 // Com Saldo
			oBrwOC280:AddFilter(STR0011+" F12 - "+STR0010+": "+cFSldAtu , cQuery+" > 0 ",.t.,.t.,,,,"saldoatual") // Filtro / Saldo Atual
		Else // Sem Saldo
			oBrwOC280:AddFilter(STR0011+" F12 - "+STR0010+": "+cFSldAtu , cQuery+" <= 0 ",.t.,.t.,,,,"saldoatual") // Filtro / Saldo Atual
		EndIf
	EndIf
	oBrwOC280:ExecuteFilter( .t. )
	oBrwOC280:Refresh()
	//
EndIf

SetKey(VK_F12,{ || OC2800011_FiltroBrowse() })

Return

/*/
{Protheus.doc} OC2800021_Visualizar
Visualizar os VBN (Movimentações) do VBM posicionado

@author Andre Luis Almeida
@since 27/05/2022
/*/
Static Function OC2800021_Visualizar()
SetKey(VK_F12, NIL)
OFIA440( VBM->VBM_CODIGO )
SetKey(VK_F12,{ || OC2800011_FiltroBrowse() })
Return