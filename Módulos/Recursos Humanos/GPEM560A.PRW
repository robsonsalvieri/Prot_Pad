#INCLUDE "RWMAKE.CH"      
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GPEM560.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} VLMVCRSP
ValidaÃ§Ã£o de Modelo da rotina de Cadastro de Fatores de AvaliaÃ§Ã£o (RSPA110)

@author raquel.andrade
@since 05/05/2021
@version P12
/*/
//-------------------------------------------------------------------
Function GPEM560A()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SRL")
oBrowse:SetDescription(OemToAnsi(STR0001+" -"+STR0002)) 
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.GPEM560A' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Manutencao' ACTION 'VIEWDEF.GPEM560A' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.GPEM560A' OPERATION 5 ACCESS 0

Return aRotina



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ModelDef   ºAutor  ³Deivys Joenck       º Data ³  30/08/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Definicao do modelo de dados das informações complementares º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ModelDef()
Local oModel
Local oStructSRL
Local oStructRCS

    Pergunte("GPM560", .F.)
    oStructSRL := FWFormStruct(1,"SRL",{|cCampo| AllTrim(cCampo)+"|" $ "RL_FILIAL|RL_MAT|RL_CODRET|RL_TIPOFJ|RL_CPFCGC|RL_BENEFIC|RL_CGCFONT|RL_NOMFONT|"})
    oStructRCS := FWFormStruct(1,"RCS")
    oStructRCS:RemoveField( "RCS_MAT" )
    oStructRCS:RemoveField( "RCS_TIPOFJ" )
    oStructRCS:RemoveField( "RCS_CPFBEN" )
    oStructRCS:RemoveField( "RCS_CODRET" )
    oStructRCS:RemoveField( "RCS_ANO" )

    oStructRCS:SetProperty( "RCS_ORIGEM", MODEL_FIELD_INIT, { |oModel| '1' } )
    oStructRCS:SetProperty( "RCS_ORIGEM", MODEL_FIELD_WHEN, { |oModel| .F. } )

    oModel:= MpFormModel():New("GPEM560")
    oModel:AddFields("MASTERSRL", /*cOwner*/, oStructSRL , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
    oModel:SetPrimaryKey( {"RL_FILIAL", "RL_MAT"} )

    oModel:GetModel("MASTERSRL"):SetOnlyView( .T. )
    oModel:GetModel("MASTERSRL"):SetOnlyQuery( .T. )
    
    oModel:AddGrid("DETAILRCS", "MASTERSRL"/*cOwner*/, oStructRCS, /*bLinePre*/ ,  { |oGrid| gp560aLinOk(oGrid) } /* bLinePost*/, /*bPre*/,/*bPost*/,/*bLoad*/)
    oModel:GetModel("DETAILRCS"):SetOptional(.T.)
    oModel:GetModel('DETAILRCS'):SetUniqueLine({'RCS_NOME','RCS_CPFCGC','RCS_VERBA','RCS_TIPORE','RCS_DESCRI','RCS_OUTROS'})

    oModel:SetRelation("DETAILRCS",{;
                                        {"RCS_FILIAL",'xFilial("SRL",SRL->RL_FILIAL)'},;
                                        {"RCS_MAT","RL_MAT"},;
                                        {"RCS_TIPOFJ","RL_TIPOFJ"},;
                                        {"RCS_CPFBEN","RL_CPFCGC"},;
                                        {"RCS_CODRET","RL_CODRET"},;
                                        {'RCS_ANO','Strzero(MV_PAR01, 4)'};
                                    },;
                                    RCS->(IndexKey(1)))

Return(oModel)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ViewDef   ºAutor  ³Deivys Joenck       º Data ³  30/08/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Definicao da tela para informações complementares           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SIGAGPE                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ViewDef()
Local oModel	 := ModelDef()
Local oStructSRL := Nil
Local oStructRCS := Nil
Local oView	

oView := FWFormView():New()
oView:SetModel(oModel)

oStructSRL := FWFormStruct(2,"SRL",{|cCampo| AllTrim(cCampo)+"|" $ "RL_FILIAL|RL_MAT|RL_CODRET|RL_TIPOFJ|RL_CPFCGC|RL_BENEFIC|RL_CGCFONT|RL_NOMFONT|"})
oStructRCS := FWFormStruct(2,"RCS")
oStructRCS:RemoveField( "RCS_MAT" )
oStructRCS:RemoveField( "RCS_TIPOFJ" )
oStructRCS:RemoveField( "RCS_CPFBEN" )
oStructRCS:RemoveField( "RCS_CODRET" )
oStructRCS:RemoveField( "RCS_ANO" )
oStructSRL:SetNoFolder()
oStructRCS:SetNoFolder()

oView:createHorizontalBox("FORMFIELD",25)
oView:createHorizontalBox("GRID"     ,75)

oView:AddField("MASTERSRL", oStructSRL)
oView:SetOwnerView( "MASTERSRL","FORMFIELD")
oView:SetViewProperty("MASTERSRL","OnlyView")


oView:AddGrid( "DETAILRCS", oStructRCS )
oView:SetOwnerView( "DETAILRCS","GRID")

oView:SetCloseOnOk({ || .T. }) //retira bota salvar e criar novo

Return(oView)

/*/{Protheus.doc} gp560aLinOk
Executa validações na linha.
@type  		Function
@author		raquel.andrade
@since		09.02.2024
@version	001
@return 	lRet - Indica que a linha foi validada.
/*/
 Function gp560aLinOk(oGrid)
Local aAreaRCS	:= RCS->( GetArea() )
Local lRet      := .T.
Local cMsg      := ""

	If !oGrid:IsDeleted()
		If "I" $ oGrid:GetValue("RCS_TIPORE")  
            If Empty(oGrid:GetValue("RCS_OUTROS"))
                cMsg := " Tipo : " + oGrid:GetValue("RCS_TIPORE") + " / Linha : " + AllTrim(Str(oGrid:nLine)) + " - " + OemtoAnsi(STR0124)
                Help( ,, OemtoAnsi(STR0079),, OemToAnsi(cMsg), 1,,,,,,, {OemToAnsi(STR0125)} )
                // "O campo Espec.Outros (RCS_OUTROS) está vazio."
                // "Para que o Informe de Rendimentos gere a Descrição do item 09.Outros é necessário preencher o campo Espec.Outros (RCS_OUTROS)."
                lRet:= .F.
            EndIf

             If lRet .And. !Empty(oGrid:GetValue("RCS_VALOR"))
                cMsg := " Tipo : " + oGrid:GetValue("RCS_TIPORE") + " / Linha : " + AllTrim(Str(oGrid:nLine)) + " - " + OemtoAnsi(STR0126)
                Help( ,, OemtoAnsi(STR0079),, OemToAnsi(cMsg), 1,,,,,,, {OemToAnsi(STR0127)} )
                // "O campo Valor (RCS_VALOR) está preenchido."
                // "Para lançamentos do Tipo de Rendimento igual I, o valor está gravado pela Geração da DIRF."
                lRet:= .F.
             EndIf
        EndIf
    EndIf

    RestArea(aAreaRCS)

Return lRet
