#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'GPEA946.CH'

Static aPerAtual

/*/{Protheus.doc} GPEA946
Cadastro de Períodos de Substituição
@author Leandro Drumond
@since 06/05/2024
@version P12.1.2410
@Type     Function
/*/
Function GPEA946()

Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias("SRA")
oMBrowse:SetDescription(OemToAnsi(STR0001)) //"Períodos de Substituição"

If !ChkFile("RUE")
	Help( " ", 1, OemToAnsi(STR0002),, OemToAnsi(STR0003), 1, 0 )//"Atenção"#"Tabela RUE não encontrada. Execute o UPDDISTR - Atualizador de dicionário e base de dados."
	Return
EndIf

oMBrowse:SetLocate()
GpLegMVC(@oMBrowse)

oMBrowse:ExecuteFilter(.T.)

oMBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Definição do MenuDef
@type function
@author Leandro Drumond
@since 06/05/2024
@version 1.0
/*/
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'PesqBrw'           OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA946'   OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA946'   OPERATION 4 ACCESS 0 //"Atualizar"
ADD OPTION aRotina Title OemToAnsi(STR0007)  Action 'VIEWDEF.GPEA946'   OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*/{Protheus.doc} ModelDef
Definição e detalhamento do Model
@type function
@author Leandro Drumond
@since 06/05/2024
@version 1.0
/*/
Static Function ModelDef()

Local oModel
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|RA_CODUNIC|"}
Local oStruSRA      := FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRUE      := FWFormStruct(1, 'RUE', /*bAvalCampo*/,/*lViewUsado*/)
Local bPosValid 	:= {|oModel| Gp946CPosVal(oModel)}
Local bLinePos 	    := {|oModel| GP946LOk(oModel)}

oModel := MPFormModel():New('GPEA946', /*bPreValid */, bPosValid, /*bCommit*/, /*bCancel*/)

oStruRUE:SetProperty( 'RUE_DATDE', MODEL_FIELD_WHEN, {|| Gpa946When("RUE_DATDE") } )
oStruRUE:SetProperty( 'RUE_FILSUB', MODEL_FIELD_WHEN, {|| .F. } )
oStruRUE:SetProperty( "RUE_EVEFAL", MODEL_FIELD_VALID, {|oGrid| Gpa946GetEve(oGrid)})

oModel:AddFields('GPEA946_SRA', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

oModel:AddGrid( 'GPEA946_RUE', 'GPEA946_SRA', oStruRUE, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

oModel:SetRelation('GPEA946_RUE', {{'RUE_FILIAL', 'RA_FILIAL'}, {'RUE_MAT', 'RA_MAT'}}, RUE->(IndexKey(3)))

oModel:GetModel('GPEA946_RUE'):SetUniqueLine({'RUE_FILIAL', 'RUE_MAT', 'RUE_FILSUB', 'RUE_MATSUB', 'RUE_DATDE'})

//Permite grid sem dados
oModel:GetModel('GPEA946_RUE'):SetOptional(.T.)
oModel:GetModel('GPEA946_SRA'):SetOnlyView(.T.)
oModel:GetModel('GPEA946_SRA'):SetOnlyQuery(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel('GPEA946_SRA'):SetDescription(OemToAnsi(STR0008)) // "Funcionário Substituto"

oModel:SetActivate( { |oModel| Gpa946ActModel(oModel) } )

Return oModel

/*/{Protheus.doc} ViewDef
Definição da viewdef
@type method
@author Leandro Drumond
@since 06/05/2024
@version 1.0
/*/
Static Function ViewDef()

Local oView
Local oModel        := FWLoadModel('GPEA946')
Local bAvalCampo    := {|cCampo| AllTrim(cCampo)+"|" $ "|RA_FILIAL|RA_MAT|RA_NOME|RA_CIC|"}
Local oStruSRA      := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRUE      := FWFormStruct(2, 'RUE')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW_SRA', oStruSRA, 'GPEA946_SRA')
oStruSRA:SetNoFolder()

oView:AddGrid('VIEW_RUE', oStruRUE, 'GPEA946_RUE')

oStruSRA:RemoveField("RA_CIC")
oStruRUE:RemoveField("RUE_MAT")
oStruRUE:RemoveField("RUE_FILIAL")

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 15)
oView:CreateHorizontalBox('INFERIOR', 85)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RUE', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0008)) // "Funcionário Substituto"
oView:EnableTitleView('VIEW_RUE', OemToAnsi(STR0001)) // "Períodos de Substituição"

oView:SetCloseOnOk({ || .T. })	//Desabilita botão "Salvar e Criar Novo"
oView:SetViewCanActivate({|oView| VldView(oView)})

Return oView

/*/{Protheus.doc} Gp946CPosVal
Pos-validacao do Cadastro
@type      	Static Function
@author Leandro Drumond
@since 06/05/2024
@version	1.0
@return		lRet
/*/

Static Function Gp946CPosVal( oModel )

Local lRet          := .T.
Local aDataAux      := {}
Local nOperation    := oModel:GetOperation()
Local oGrid         := oModel:GetModel("GPEA946_RUE")
Local nTam          := oGrid:Length()
Local nX            := 0

DEFAULT aPerAtual := Gp946PerAtual()

For nX := 1 to nTam 
    oGrid:GoLine(nX)
    If nOperation == 5 .or. oGrid:IsDeleted()//--Exclusão
        If Empty(aPerAtual) .or. oGrid:GetValue("RUE_DATDE") < aPerAtual[1, 6]
            lRet := .F.
            Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0009) , 1, 0,,,,,, { OemToAnsi(STR0010)})
            //"Atencao" ## "Registro foi incluído em período anterior ao atual, portanto não poderá ser excluído." ### "Registro não pode ser excluído"
            Exit
        EndIf
    Else
        aAdd(aDataAux, {oGrid:GetValue("RUE_DATDE"), oGrid:GetValue("RUE_DATATE")})
    EndIf
Next nX

//Garante que não exista mais de uma substituição no mesmo período
If lRet .and. Len(aDataAux) > 1 
    aSort( aDataAux ,,, { |x,y| x[1] < y[1] } )
    nTam := Len(aDataAux)
    For nX := 1 to Len(aDataAux)
        If Empty(aDataAux[nX,2]) .and. nX < nTam
            lRet := .F. 
            Exit
        ElseIf nX > 1
            If aDataAux[nX,1] >= aDataAux[nX-1,1] .and. aDataAux[nX,1] <= aDataAux[nX-1,2] 
                lRet := .F.
                Exit
            EndIf            
        EndIf 
    Next nX
    If !lRet
        Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0011) , 1, 0,,,,,, { OemToAnsi(STR0012)})
        //"Atencao" ## "Não pode existir mais de uma substituição para o mesmo período." ### "Ajuste os períodos de substituição"
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} GP941LOk
Linhao Ok
@type      	Static Function
@author Leandro Drumond
@since 06/05/2024
@version	1.0
@return		lRet,		logic
/*/

Static Function GP946LOk(oGrid)

Local lRet 	    := .T.
Local dDataIni  := oGrid:GetValue("RUE_DATDE")
Local dDataFim  := CtoD("")
Local nDiasAf   := 0

DEFAULT aPerAtual := Gp946PerAtual()

Begin Sequence

    If oGrid:IsFieldUpdated("RUE_DATDE") .and. ( Empty(aPerAtual) .or. oGrid:GetValue("RUE_DATDE") < aPerAtual[1, 6] )
        lRet := .F.
        Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0024) , 1, 0,,,,,, { OemToAnsi(STR0014)})
        //"Atencao" ## "Data inicial não deve ser menor que o período atual de cálculo" ### "Efetue a correção do período"
        Break
    EndIf

    If !Empty(oGrid:GetValue("RUE_DATATE")) .and. oGrid:GetValue("RUE_DATATE") < oGrid:GetValue("RUE_DATDE")
        lRet := .F.
        Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0013) , 1, 0,,,,,, { OemToAnsi(STR0014)})
        //"Atencao" ## "Data final não pode ser menor que a data inicial" ### "Efetue a correção do período"
        Break
    EndIf

    If Empty(aPerAtual) .or. ( !Empty(oGrid:GetValue("RUE_DATATE")) .and. oGrid:GetValue("RUE_DATATE") < aPerAtual[1, 6] )
        lRet := .F.
        Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0015) , 1, 0,,,,,, { OemToAnsi(STR0014)})
        //"Atencao" ## "Data final não deve ser menor que o período atual de cálculo" ### "Efetue a correção do período"
        Break
    EndIf

    If ( Empty(oGrid:GetValue("RUE_FILSUB")) .or. Empty(oGrid:GetValue("RUE_MATSUB")) ) .and. Empty(oGrid:GetValue("RUE_SALARI"))
        lRet := .F.
        Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0016) , 1, 0,,,,,, { OemToAnsi(STR0017)})
        //"Atencao" ## "Informe o salário de substituição ou a filial e matrícula do funcionário substituído." ### "Corrija os dados informados"
        Break
    EndIf

    If oGrid:IsFieldUpdated("RUE_DATDE")
        dDataFim  := If(Empty(oGrid:GetValue("RUE_DATATE")),aPerAtual[1,7],oGrid:GetValue("RUE_DATATE"))

        fRetAfas(dDataIni,dDataFim,,,@nDiasAf,,,,,,,,,,.F.)

        If nDiasAf > 0
            lRet := .F.
            Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0028) , 1, 0,,,,,, { OemToAnsi(STR0017)})
            //"Atencao" ## "Funcionário possui afastamento no período informado e não poderá substituir outros" ### "Corrija os dados informados"
            Break
        EndIf
    EndIf

End Sequence

Return lRet

/*{Protheus.doc} Gpa946When
When do campo RUE_SALARI 
Permite preechimento apenas se não informar a filial e matrícula do substituido
@type      	Static Function
@author Leandro Drumond
@since 06/05/2024
@version	1.0
@return		lRet
*/
Function Gpa946When(cCampo)
Local oModel	:= FwModelActivate()
Local oGrid 	:= oModel:GetModel("GPEA946_RUE") 
Local lRet      := .F.

DEFAULT cCampo    := ""
DEFAULT aPerAtual := Gp946PerAtual()

If Empty(cCampo) .and. ( Empty(oGrid:GetValue("RUE_FILSUB")) .or. Empty(oGrid:GetValue("RUE_MATSUB")) )
    //Se não preencheu filial e matrícula, habilita campo RUE_SALARI
    lRet := .T. 
EndIf

If cCampo == "RUE_DATDE" .and. ( oGrid:IsInserted() .or. ( !Empty(aPerAtual) .and. aPerAtual[1,6] <= oGrid:GetValue("RUE_DATDE")) )
    lRet := .T.
EndIf 

Return lRet

/*{Protheus.doc} Gp946PerAtual
Carrega período atual
@type      	Static Function
@author Leandro Drumond
@since 06/05/2024
@version	1.0
@return		lRet
*/
Static Function Gp946PerAtual()
Local aPerAux := {}

fGetPerAtual( @aPerAux, xFilial("RCH"), SRA->RA_PROCES, fGetCalcRot('1') )

Return aPerAux

/*{Protheus.doc} Gpa946Vld
Valid do campo verba
@type      	Static Function
@author Leandro Drumond
@since 07/05/2024
@version	1.0
@return		lRet
*/
Function Gpa946Vld()
Local lRet      := .T.
Local cCampo    := ReadVar()
Local cPd       := &(ReadVar())

If ("RUE_VERBA" $ cCampo) 
    If Empty(cPd) .or. RetValSrv( cPd , SRA->RA_FILIAL , "RV_TIPOCOD" ) <> "1"
        lRet := .F. 
    EndIf
Else
    If !Empty(cPd) .and. RetValSrv( cPd , SRA->RA_FILIAL , "RV_TIPOCOD" ) <> "1"
        lRet := .F. 
    EndIf
EndIf

If !lRet
    Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0018) , 1, 0,,,,,, { OemToAnsi(STR0019)})
    //"Atencao" ## "Apenas verbas de provento podem ser cadastradas." ### "Informe uma verba de provento"
EndIf

Return lRet

/*{Protheus.doc} Gpa946VMat
Valid do campo matrícula
@type      	Static Function
@author Leandro Drumond
@since 08/05/2024
@version	1.0
@return		lRet
*/
Function Gpa946VMat()
Local oModel	:= FwModelActivate()
Local oGrid 	:= oModel:GetModel("GPEA946_RUE")
Local aAux      := {}
Local cMatAux   := &(ReadVar())
Local cFilAux   := SRA->RA_FILIAL
Local cFilMat   := oGrid:GetValue("RUE_FILIAL") + oGrid:GetValue("RUE_MAT")
Local nLine     := 0
Local lAtuDta   := .F.
Local lRet      := .T.

DEFAULT aPerAtual := Gp946PerAtual()

If Empty(cMatAux)
    oGrid:LoadValue("RUE_FILSUB","")
    oGrid:LoadValue("RUE_NOME","")
ElseIf cFilMat == cFilAux + cMatAux
    lRet := .F.
    Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0020) , 1, 0,,,,,, { OemToAnsi(STR0021)})
    //"Atencao" ## "Não deve ser informado o mesmo funcionário como substituto." ### "Informe um funcionário diferente."
Else
    If !SRA->(DbSeek(cFilAux + cMatAux))
        lRet := .F.
        Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0022) , 1, 0,,,,,, { OemToAnsi(STR0023)})
        //"Atencao" ## "Funcionário não encontrado." ### "Selecione um funcionário pela consulta padrão."
    Else 
        oGrid:LoadValue("RUE_FILSUB",cFilAux)
        oGrid:LoadValue("RUE_NOME",SRA->RA_NOME)
        oGrid:LoadValue("RUE_SALARI", 0)
        If !Empty(aPerAtual)
            fRetAfas(aPerAtual[1,6],aPerAtual[1,7],,,,,@aAux,,,,,,,,.F.)
            If !Empty(aAux)
                nLine := oGrid:GetLine()
                If nLine > 1 
                    If !Empty(oGrid:GetValue("RUE_DATATE",nLine-1)) .and. aAux[1,3] > oGrid:GetValue("RUE_DATATE",nLine-1)
                        lAtuDta := .T.
                    EndIf
                Else 
                    lAtuDta := .T.
                EndIf
                If lAtuDta
                    oGrid:LoadValue("RUE_DATDE",aAux[1,3])
                    If !Empty(aAux[1,4])
                        oGrid:LoadValue("RUE_DATATE",aAux[1,4])
                    EndIf
                EndIf 
            EndIf 
        EndIf
    EndIf
EndIf


SRA->(DbSeek(cFilMat))

Return lRet

/*/{Protheus.doc} Gpa946ActModel
Executado na ativação do modelo
@author  Leandro Drumond
@since   08/05/2024
/*/
Static Function Gpa946ActModel(oModel)
	aPerAtual 	:= Nil
Return .T.

/*/{Protheus.doc} VldView
Valida ativação da view
@author  Leandro Drumond
@since   09/05/2024
/*/
Static Function VldView(oView)
Local aArea         := GetArea()
Local oModel        := oView:GetModel()
Local nOperation    := 0
Local lRet          := .T.

oModel:Activate()

nOperation := oModel:GetOperation()

If nOperation <> 4 
	If oModel:GetModel("GPEA946_RUE"):IsEmpty()
        Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0026) , 1, 0,,,,,, { OemToAnsi(STR0027)})
         //"Atencao" ## "Não existem dados para este funcionário" ### "Utilize a opção de atualização"
		lRet:= .F.
	EndIf
EndIf

If lRet .and. !Empty(SRA->RA_DEMISSA) .and. ( nOperation == 4 .or. nOperation == 5 )
    Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0029) , 1, 0,,,,,, { OemToAnsi(STR0030)})
    //"Atencao" ## "Não é permitido manutenção de funcionário demitido." ### "Utilize a opção de visualização."
    lRet:= .F.
EndIf

oModel:DeActivate()

RestArea(aArea)

Return lRet

/*/{Protheus.doc} Gpa946GetEve
Busca eventos do ponto eletrônico
@author Leandro Drumond
@since 09/05/2024
@version P12
@return Nil
/*/
Function Gpa946GetEve(oGrid)

Local aItens 	:= {}
Local aRet 		:= {}
Local cRet 		:= ""
Local MvParDef	:= ""
Local cFilSP9 	:= xFilial("SP9")

dbSelectArea("SP9")
dbSeek(cFilSP9)

While !Eof() .And. SP9->P9_FILIAL == cFilSP9

	If SP9->P9_TIPOCOD $ "1*2"
		aAdd(aItens, SP9->P9_CODIGO + "-" + SP9->P9_DESC)
		MvParDef += SP9->P9_CODIGO
	EndIf

	dbSkip()
EndDo

If f_Opcoes(@aRet, STR0025, aItens, MvParDef, , , .F., 3) //"Selecione os eventos de falta"
	aEval(aRet,{|x| cRet += x +"*"})
	oGrid:LoadValue("RUE_EVEFAL",cRet)
EndIf

Return .T.

/*{Protheus.doc} Gpa946VlDta
Valid do campo data inicio
@type      	Static Function
@author Leandro Drumond
@since 09/05/2024
@version	1.0
@return		lRet
*/
Function Gpa946VlDta()
Local dDataAux  := &(ReadVar())
Local lRet      := .T.

DEFAULT aPerAtual := Gp946PerAtual()

If ( Empty(aPerAtual) .or. dDataAux < aPerAtual[1, 6] )
    lRet := .F.
    Help(,, OemToAnsi(STR0002),, OemToAnsi(STR0024) , 1, 0,,,,,, { OemToAnsi(STR0014)})
    //"Atencao" ## "Data inicial não deve ser menor que o período atual de cálculo" ### "Efetue a correção do período"
EndIf

Return lRet

/*{Protheus.doc} Gpa946Posic
Inicializador Padrão RUE_NOME
@type      	Static Function
@author Leandro Drumond
@since 10/05/2024
@version	1.0
@return		lRet
*/
Function Gpa946Posic()
Local cRet      := ""
Local nRecSRA

If !Empty(RUE->RUE_MATSUB)
    nRecSRA   := SRA->(Recno())
    cRet := Posicione( 'SRA', 1, RUE->RUE_FILSUB + RUE->RUE_MATSUB, 'RA_NOME')
    SRA->(DbGoTo(nRecSRA))
EndIf 

Return cRet
