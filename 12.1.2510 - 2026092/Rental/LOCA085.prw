#INCLUDE "LOCA085.CH" 
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"                                                                                                   
#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSMGADD.CH"                                                                                                         

/*/{PROTHEUS.DOC} LOCA085.PRW
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - CADASTRO DE SUB-STATUS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 20/03/2024
@HISTORY 20/03/2024, FRANK ZWARG FUGA, CRIACAO DO FONTE
/*/

FUNCTION LOCA085()
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local oBrowse 
Local lImplemento := .F.

Private aRotina   := MenuDef()
Private cCadastro := STR0004 // "Registro dos Sub-Status"
Private lCorret := .T. // DSERLOCA-1982 - implemento - Frank em 10/05/2024

    If !lMvLocBac
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
		{STR0003}) //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
        Return .F.
    EndIf

    If FindFunction( "LOCA224B1" )
        If LOCA224B1("FQG_FILIAL", "FQG") .and. LOCA224B1("FQF_FILIAL", "FQF") 
            If LOCA224B1("FQH_FILIAL", "FQH") .and. LOCA224B1("FQE_FILIAL", "FQE") 
                lImplemento := .T.
            EndIf
        EndIf
    EndIf

    If !lImplemento
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
		{STR0014}) //"Não foram localizadas as tabelas relacionadas ao sub-status."
        Return .F.
    EndIf

	If !AmIIn(94)
		Return .F.
	Endif

    oBrowse := FwmBrowse():NEW() 
    oBrowse:SetAlias("FQE")
    oBrowse:SetDescription(STR0004) //"Registro dos Sub-Status"
    oBrowse:Activate() 

Return( NIL )

/*/{PROTHEUS.DOC} MenuDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - CADASTRO DE SUB-STATUS - OPCOES DO MENU
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 20/03/2024
/*/

Static Function MenuDef()
Local aRotina := {}
	aAdd(aRotina,{ STR0005, "PESQBRW"            , 0, 2, 0, NIL } ) //"Pesquisar"
    aAdd(aRotina,{ STR0006, "VIEWDEF.LOCA085"    , 0, 2, 0, NIL } ) //"Visualizar"
	aAdd(aRotina,{ STR0007, "VIEWDEF.LOCA085"    , 0, 3, 0, NIL } ) //"Incluir"
	aAdd(aRotina,{ STR0008, "VIEWDEF.LOCA085"    , 0, 4, 0, NIL } ) //"Alterar"
	aAdd(aRotina,{ STR0009, "VIEWDEF.LOCA085"    , 0, 5, 0, NIL } ) //"Excluir"
Return aRotina

/*/{PROTHEUS.DOC} ModelDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - CADASTRO DE SUB-STATUS - DEFINICAO DO MODELO DE DADOS
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 20/03/2024
/*/

Static Function ModelDef()
Local oModel    := Nil
Local oStPai    := FWFormStruct(1, "FQE") 
Local oStFilho  := FWFormStruct(1, "FQH") 
Local bVldPos   := {|| LOCA85A() .and. LOCA085B()}
     
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New("LOCA085",,bVldPos)
    oModel:AddFields("FQEMASTER",,oStPai)
    oModel:AddGrid("FQHDETAIL","FQEMASTER",oStFilho,,,,,)
     
    oModel:SetRelation('FQHDETAIL', { { 'FQH_FILIAL', "xFilial('FQH')" }, { 'FQH_STATUS', 'FQE_CODSTA'  }, { 'FQH_SUBSTA', 'FQE_CODIGO'  } }, FQH->(IndexKey(1)) )
    oModel:SetPrimaryKey({})
     
    //Setando as descrições
    oModel:SetDescription(STR0004) // "Registro dos Sub-Status"
    oModel:GetModel("FQEMASTER"):SetDescription(STR0004) // "Registro dos Sub-Status"
    oModel:GetModel("FQHDETAIL"):SetDescription(STR0011) // "Serviços"

    // Permite deletar todas as linhas do crid.
    oModel:GetModel( 'FQHDETAIL' ):SetOptional( .T. )
   
Return oModel

/*/{PROTHEUS.DOC} ViewDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - CADASTRO DE SUB-STATUS - DEFINICAO DA INTERFACE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 20/03/2024
/*/

Static Function ViewDef()
Local oView     := Nil
Local oModel
Local oStPai    := FWFormStruct(2, "FQE")
Local oStFilho  := FWFormStruct(2, "FQH")
    
    oModel    := FWLoadModel("LOCA085")

     //Criando a View
     oView := FWFormView():New()
     oView:SetModel(oModel)
     
     //Adicionando os campos do cabeçalho e o grid dos filhos
     oView:AddField("VIEW_FQE",oStPai,"FQEMASTER")
     oView:AddGrid("VIEW_FQH",oStFilho,"FQHDETAIL")
     
     //Setando o dimensionamento de tamanho
     oView:CreateHorizontalBox("CABEC",40)
     oView:CreateHorizontalBox("GRID1",60)
     
     //Amarrando a view com as box
     oView:SetOwnerView("VIEW_FQE","CABEC")
     oView:SetOwnerView('VIEW_FQH','GRID1')
     
     //Habilitando título
     oView:EnableTitleView("VIEW_FQE",STR0004) // "Registro dos Sub-Status"
Return oView

/*/{PROTHEUS.DOC} LOCA85A
ITUP BUSINESS - TOTVS RENTAL
CADASTRO DE SUB-STATUS - VALIDACAO DA INTERFACE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 03/04/2024
/*/
Function LOCA85A
Local lRet := .T.
Local oModel
Local cSubst
Local cCaract
Local cTipo

    oModel := FWModelActive()
	oFQE   := oModel:GetModel("FQEMASTER")

    cSubst := oFQE:GetValue("FQE_SUBST") 
    cCaract := oFQE:GetValue("FQE_CARACT") 
    cTipo := oFQE:GetValue("FQE_TIPO") 

    If cSubst = "S" .and. (empty(cCaract) .or. empty(cTipo))
        lRet := .F.
        Help( ,, "LOCA085-LOCA085A",, STR0002, 1, 0,,,,,,{STR0010}) //"Inconsistência nos dados."###"Os campos Característica e Tipo são obrigatórios, quando usado a substituição."
    EndIf

Return lRet

/*/{PROTHEUS.DOC} LOCA085B
ITUP BUSINESS - TOTVS RENTAL
VALIDACAO NAO PERMITIR A GRACACAO DE UM SERVICO EM SUBSTATUS DIFERENTES
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 05/04/2024
/*/
Function LOCA085B
Local lRet := .T.
Local cQuery
Local nX
Local oModel := FWModelActive()
Local oFQH   := oModel:GetModel("FQHDETAIL")
Local oFQE   := oModel:GetModel("FQEMASTER")
Local cServ
Local lTem   := .F.
Local aTemp  := {}
Local nY 
Local lBlq   := .F. // bloqueia o carro reserva
Local cSubst := oFQE:GetValue("FQE_SUBST")

    // validar se outro status/substatus já possui este serviço cadastrado
    For nX := 1 to oFQH:Length()
        oFQH:GoLine(nX)
        IF !oFQH:IsDeleted() // Linha não deletada
            cServ := oFQH:GetValue("FQH_SERV")

            //If empty(cServ)
            //    Help( ,, "LOCA085-LOCA085B",, STR0002, 1, 0,,,,,,{STR0015}) //"Inconsistência nos dados."###"Serviço não informado. Se não há serviços delete a linha."
            //    Return .F.
            //EndIF

            If !empty(cServ)

                cStatus := oFQE:GetValue("FQE_CODSTA")
                cSubSta := oFQE:GetValue("FQE_CODIGO")
                If select("TRBFQH") > 0
                    TRBFQH->(dbCloseArea())
                EndIf
                lTem   := .F.
                If inclui
                    cQuery := " SELECT FQH.R_E_C_N_O_ AS REG "
                    cQuery += " FROM " + RETSQLNAME("FQH") + " FQH "
                    cQuery += " WHERE FQH.D_E_L_E_T_ = '' AND FQH.FQH_SERV = ? "
                    cQuery += " AND (FQH.FQH_STATUS <> ? OR FQH.FQH_SUBSTA <> ?) "
                    cQuery += " AND FQH.FQH_FILIAL = '"+xFilial("FQH")+"' "
                    cQuery := CHANGEQUERY(cQuery)
                    aBindParam := {cServ, cStatus, cSubSta}
                    MPSysOpenQuery(cQuery,"TRBFQH",,,aBindParam)
                    If !TRBFQH->(Eof())
                        FQH->(dbGoto(TRBFQH->REG))
                        lTem := .T.
                    EndIF
                Else 
                    cQuery := " SELECT FQH.R_E_C_N_O_ AS REG "
                    cQuery += " FROM " + RETSQLNAME("FQH") + " FQH "
                    cQuery += " WHERE FQH.D_E_L_E_T_ = '' AND FQH.FQH_SERV = ? "
                    cQuery += " AND (FQH.FQH_STATUS <> ? OR FQH.FQH_SUBSTA <> ?) "
                    cQuery += " AND FQH.FQH_FILIAL = '"+xFilial("FQH")+"' "
                    cQuery := CHANGEQUERY(cQuery)
                    aBindParam := {cServ, cStatus, cSubSta }
                    MPSysOpenQuery(cQuery,"TRBFQH",,,aBindParam)
                    While !TRBFQH->(Eof())
                        If alltrim(str(TRBFQH->REG)) <> alltrim(str(oFQH:GetDataId()))
                            lTem := .T.
                            //Exit
                        EndIF
                        TRBFQH->(dbSkip())
                    EndDo
                EndIF
                
                TRBFQH->(dbCloseArea())
            EndIf

        EndIf
        If lTem
            exit
        EndIf
    Next
    If lTem
        lRet := .F.
        Help( ,, "LOCA085-LOCA085B",, STR0002, 1, 0,,,,,,{STR0012+cStatus+"/"+cSubSta+"/"+cServ}) //"Inconsistência nos dados."###""Já existe um registro com este serviço. Status/SubStatus/Serviço: "
    EndIf
    If lRet 
        // Validar se existe algum serviço repetido para o mesmo status/substatus
        aTemp := {}
        For nX := 1 to oFQH:Length()
            oFQH:GoLine(nX)
            IF !oFQH:IsDeleted() 
                lTem := .F.
                cStatus := oFQE:GetValue("FQE_CODSTA")
                cSubSta := oFQE:GetValue("FQE_CODIGO")
                cServ := oFQH:GetValue("FQH_SERV")
                If !empty(cServ)
                    
                    lBlq := .T. // Existe pelo menos um registro na FQH, não deve permitir a substituição                    
                    
                    For nY := 1 to len(aTemp)
                        If aTemp[nY] == cServ
                            lTem := .T.
                            Exit
                        EndIf
                    Next
                EndIf
                If !lTem 
                    If !empty(cServ)
                        aadd(aTemp,cServ)
                    EndIF
                Else
                    lRet := .F.
                    Help( ,, "LOCA085-LOCA085B",, STR0002, 1, 0,,,,,,{STR0012+cStatus+"/"+cSubSta+"/"+cServ}) //"Inconsistência nos dados."###""Já existe um registro com este serviço. Status/SubStatus/Serviço: "
                    Exit
                EndIf
            EndIF
        NExt
    EndIf
    If lRet .and. lBlq .and. cSubst == "S"
        Help( ,, "LOCA085-LOCA085B",, STR0002, 1, 0,,,,,,{STR0013}) //"Inconsistência nos dados."###"Um substatus com serviços registrados não possibilita a substituição."
        lRet := .F.
    EndIf

Return lRet

