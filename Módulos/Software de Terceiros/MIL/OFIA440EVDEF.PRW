#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"
#INCLUDE "OFIA440.CH"

CLASS OFIA440EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
	METHOD VldActivate()

ENDCLASS


METHOD New() CLASS OFIA440EVDEF

RETURN .T.


METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS OFIA440EVDEF
Local lRet    := .t.
Local nOperation := oSubModel:GetOperation()
Local nRECVBM := 0
Local oMod440
Local oDet440
Local oVie440
Local lRefresh := .f. // Refresh na VIEW de Cadastro
If cModelId == "VBMMASTER"
	If cAction == "SETVALUE" // Valid do campo
		If cId == "VBM_SEQVEN" .and. !Empty(xValue)
			nRECVBM := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSqlName('VBM')+" WHERE VBM_FILIAL='"+xFilial("VBM")+"' AND VBM_SEQVEN='"+xValue+"' AND D_E_L_E_T_=' '")
			If nRECVBM > 0
				If nOperation == 3 .or. ( nOperation == 4 .and. VBM->(RecNo()) <> nRECVBM )
					lRet := .f.
					Help("",1,"FIELDPREVLD",,STR0013,1,0) // Já existe cadastro de Saldo dessa Promoção. Impossivel continuar.
				EndIf
			EndIf
			If lRet
				DbSelectArea("VEN")
				DbSetOrder(8)
				If DbSeek(xFilial("VEN")+xValue) .and. !Empty(VEN->VEN_CODITE) .and. VEN->VEN_DATFIN>=dDataBase .and. VEN->VEN_SLDPRO=="1"
					oSubModel:LoadValue("VBM_NOMCRI",OA4400031_NomeCriterio(VEN->VEN_SEQUEN))
					oSubModel:LoadValue("VBM_DATINI",VEN->VEN_DATINI)
					oSubModel:LoadValue("VBM_DATFIN",VEN->VEN_DATFIN)
					oSubModel:LoadValue("VBM_GRUITE",VEN->VEN_GRUITE)
					oSubModel:LoadValue("VBM_CODITE",VEN->VEN_CODITE)
					oSubModel:LoadValue("VBM_DESITE",left(Posicione("SB1",7,xFilial("SB1")+VEN->VEN_GRUITE+VEN->VEN_CODITE,"B1_DESC"),30))
					oSubModel:SetValue("VBM_SLDINI",oSubModel:GetValue("VBM_SLDINI")) // dispara o valid do campo para carregar saldo inicial do filho
				Else
					lRet := .f. 
				EndIf
			EndIf
		ElseIf cId == "VBM_SLDINI"
			oVie440 := FWViewActive()
			If oVie440 <> NIL .and. oVie440:AVIEWS[1,1] == "VIEW_VBM"
				lRefresh := .t. // Refresh na VIEW de Cadastro
			EndIf
			oMod440 := FWModelActive()
			oDet440 := oMod440:GetModel("VBNDETAIL")
			If len(oDet440:aDataModel) == 1
				oDet440:GoLine(1)
				If Empty(oDet440:GetValue("VBN_CODIGO"))
					oDet440:LoadValue("VBN_CODIGO",GetSXENum("VBN","VBN_CODIGO"))
				EndIf
				oDet440:LoadValue("VBN_TIPMOV","0")
				oDet440:LoadValue("VBN_DATMOV",dDataBase)
				oDet440:LoadValue("VBN_HORMOV",SUBSTR(time(),1,2)+SUBSTR(time(),4,2))
				oDet440:LoadValue("VBN_QTDMOV",xValue)
				oDet440:LoadValue("VBN_POSNEG","+")
				oDet440:LoadValue("VBN_USRMOV",__cUserID)
				oDet440:LoadValue("VBN_USRNOM",left(Posicione("VAI",4,xFilial("VAI")+__cUserID,"VAI_NOMTEC"),20))
				If lRefresh
					oVie440:Refresh() // Refresh na VIEW de Cadastro
				EndIf
				oSubModel:LoadValue("VBM_SLDATU",xValue)
			EndIf
		EndIf
	EndIf
EndIf
RETURN lRet


METHOD VldActivate(oModel, cModelId) CLASS OFIA440EVDEF
Local lRet := .t.
Local nOperation := oModel:GetOperation()
Local nQtdREC := 0
If nOperation == 4 .or. nOperation == 5
	nQtdREC := FM_SQL("SELECT COUNT(VBN_CODIGO) FROM "+RetSqlName('VBN')+" WHERE VBN_FILIAL='"+xFilial("VBN")+"' AND VBN_CODVBM='"+VBM->VBM_CODIGO+"' AND D_E_L_E_T_=' '")
	If nQtdREC > 1 // Já possui alguma movimentação, não deixar ALTERAR nem EXCLUIR os registros dessa promoção.
		lRet := .f.
		Help("",1,"VLDACTIVATE",,STR0014,1,0) // Já existem movimentações para essa Promoção. Impossivel ALTERAR ou EXCLUIR.
	EndIf
EndIf
RETURN lRet