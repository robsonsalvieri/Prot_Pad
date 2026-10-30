#Include 'TOTVS.ch'
#Include 'FWMVCDef.ch'
#Include "FWEVENTVIEWCONSTS.CH"
#Include "OFIA640.CH"

Class OFIA640EVDEF From FWModelEvent

	Method New() Constructor
    METHOD Activate()
    METHOD VldActivate()
    METHOD GridLinePreVld()
    METHOD ModelPosVld()
    
EndClass

Method New() Class OFIA640EVDEF
Return .T.

/*/{Protheus.doc} Activate
	@type method
	@author Leandro Rodrigues
	@since 18/07/2026
/*/
METHOD Activate(oModel, lCopy) CLASS OFIA640EVDEF
	Local nOpcMod := oModel:GetOperation()
	Local oVWD    := oModel:GetModel("VWDMASTER")
		
    If nOpcMod == MODEL_OPERATION_INSERT // Inclusão 
        oVWD:SetValue("VWD_FILOSV", VO1->VO1_FILIAL)   
        oVWD:SetValue("VWD_STATUS", "1")               
        oVWD:SetValue("VWD_NUMOSV", VO1->VO1_NUMOSV)   
        oVWD:SetValue("VWD_CLIFAT", VO1->VO1_FATPAR)   
        oVWD:SetValue("VWD_LOJFAT", VO1->VO1_LOJA)   
        oVWD:SetValue("VWD_DATINC", DDATABASE)         
        oVWD:SetValue("VWD_HORINC", SUBSTR(TIME(),1,5)) 

	ElseIf nOpcMod == MODEL_OPERATION_UPDATE // Alteração	
        oVWD:LoadValue("VWD_CLIFAT", VWD->VWD_CLIFAT) // Necessario para possibilitar dar OK sem precisar alterar os dados na Alteração
	EndIf

RETURN .T.

/*/{Protheus.doc} VldActivate
	@type method
	@author Leandro Rodrigues
	@since 18/07/2026
/*/
METHOD VldActivate(oModel, cModelId) CLASS OFIA640EVDEF
	Local nOperation := oModel:GetOperation()
	Local lRet := .t.

    If nOperation == MODEL_OPERATION_UPDATE .AND. FWIsInCallStack("OA6400117_gerar_documento")		
		IF VWD->VWD_STATUS <> "1" // 1 = Remessa em aberto
            FMX_HELP("OFIA640VLD1",STR0030) // "Remessa não está em aberto para gerar o documento."
            lRet := .F.
        Else    
            oModel:GetModel("VWDMASTER"):SetOnlyView()
            oModel:GetModel("VWEDETAIL"):SetOnlyView()
            oModel:GetModel("VWEDETAIL"):SetNoInsertLine(.t.)
            oModel:GetModel("VWEDETAIL"):SetNoDeleteLine(.t.)
        EndIf
	ElseIf nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_UPDATE
        IF VWD->VWD_STATUS <> "1" // 1 = Remessa em aberto
             FMX_HELP("OFIA640VLD3",STR0032) // "Remessa não está em aberto para realizar a alteração ou exclusão."
            lRet := .F.
        EndIf
    EndIf

Return lRet

/*/{Protheus.doc} GridLinePreVld
	@type method
	@author Leandro Rodrigues
	@since 18/07/2026
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS OFIA640EVDEF
	Local lRet       := .T.
    Local cQuery     := ""
    Local cMV_GRUVEI := IIF(ExistFunc('FGX_GrupoVeic'),FGX_GrupoVeic(VO1->VO1_CHAINT), Left(GetMV("MV_GRUVEI")+Space(TamSX3("B1_GRUPO")[1]),TamSX3("B1_GRUPO")[1]))
       	
    If cModelId == "VWEDETAIL"
    
        If cAction == "SETVALUE"

            If cId == "VWE_CODSB1"

                IF ! FWIsInCallStack("OA6400087_add_veiculo_grid")
                    DBSelectArea("SB1")
                    SB1->(DbSetOrder(1))
                    If SB1->(DbSeek(FWxFilial("SB1") + AvKey(xValue, "B1_COD"))) 
                        IF AllTrim(cMV_GRUVEI) == AllTrim(SB1->B1_GRUPO) // Valida se está sendo digitado uma maquina (veiculo).
                            FMX_HELP("OFIA640EVDEF01",STR0037) // "Para informar maquina na remessa acesse 'Outras Ações' opção 'Add Maquina Remessa'."                         
                            lRet := .f.
                        Else                           
                            If !Empty(MV_PAR01)  // MV do parametro da pergunte "OA640" da tecla F12 da rotina.
                                cQuery := "SELECT COUNT(*) FROM "+RetSqlName("SB1")+" WHERE B1_FILIAL = '"+FWxFilial("SB1")+"' AND B1_COD = '"+xValue+"' AND B1_GRUPO = '"+MV_PAR01+"' AND D_E_L_E_T_ = ' '"
                                If FM_SQL(cQuery) == 0
                                    lRet := .f.
                                    FMX_HELP("OFIA640EVDEF02",STR0038, STR0039 + AllTrim(MV_PAR01)+".") // "Peça não pertence ao grupo informado no parametro inicial (F12) da rotina." | "Informe somente peças do grupo "
                                EndIf
                            EndIf
                        EndIf
                    EndIf
                EndIf

            EndIf
        EndIf
    EndIf
    
Return lRet

/*/{Protheus.doc} ModelPosVld
	@type method
	@author Leandro Rodrigues
	@since 18/07/2026
/*/
METHOD ModelPosVld(oModel, cModelId) CLASS OFIA640EVDEF
    Local lRet := .T.
    
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .AND. FWIsInCallStack("OA6400117_gerar_documento")
        
        If FWAlertYesNo(STR0040, STR0027) // "Deseja gerar o documento?" | "Atenção"
            FWMsgRun(, {|| lRet := OA6400127_gerando_documento() }, STR0035, STR0041) // "Aguarde" / "Processando" 
        EndIf 
    
	EndIf

RETURN lRet
