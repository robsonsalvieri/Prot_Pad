#include "TOTVS.ch"    
#include "TOPCONN.CH"
#include "LOCA248.CH"
#include "FWMVCDEF.CH"
#include "PROTHEUS.CH"
#include "RWMAKE.CH"    

/*/{Protheus.doc} LOCA248.PRW
ITUP Business - TOTVS RENTAL
@author Frank Zwarg Fuga
@since 25/07/2024
Medições
/*/  

Function LOCA248()
Local lMvLocBac := SuperGetMv("MV_LOCBAC",.F.,.F.) //Integração com Módulo de Locações SIGALOC
Local lErro 
Private aRotina   := MenuDef()
Private cCadastro := STR0004 // Medição
Private nTotHrre  := 0 // Total execedente
Private lInclui   := .F.
Private lAltera   := .F.
Private lVisual   := .F.
Private lExclui   := .F.  
Private aCalcGrp  := {}
Private xConteud  := "" // usado na função LOCA248C6X() 
Private dControl  := ctod("") // usado no valid da data inicial da FQK
Private aBlqFQL   := {}
Private aBlqFQK   := {}
Private cMarca    := ""   

    If !lMvLocBac
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
		{STR0003}) //"Uso obrigatório do parâmetro habilitado MV_LOCBAC."
        Return .F.
    EndIf

    If !AmIIn(94, 05, 19)  
		Return .F.
	Endif

    IF FPF->(FIELDPOS("FPF_FILTRO")) == 0 .or. FPF->(FIELDPOS("FPF_MEDSEQ")) == 0     
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
        {STR0136}) //"Falta a atualização da base de dados com o campo FPF_FILTRO"
        Return .F.
    EndIf

    lErro := .F.
    If FindFunction( "LOCA224B1" ) .and. !file("\SYSTEM\248E1.TXT")
        If !LOCA224B1("FQK_FILIAL", "FQK") .or. file("\SYSTEM\248E2.TXT")
			lErro := .T.
		EndIf
        If !LOCA224B1("FP0_TPFRAN", "FP0") .or. file("\SYSTEM\248E3.TXT")
			lErro := .T.
		EndIf
    Else
        lErro := .T.
	EndIf
    If lErro
        Help( ,, "LOCA248",, STR0002, 1, 0,,,,,,{STR0096}) //"Inconsistência nos dados."###"Falta a atualização do sistema."
        Return .F.
    EndIf

	SETKEY(VK_F12 , {|| LOCA248BB() })  

    // Identifica todos os gatilhos da FQK e FQL para controle dos bloqueios nos campos
    Identifica()

    oBrowse := FwmBrowse():NEW() 
    oBrowse:SetAlias("FQK")
    oBrowse:SetDescription(STR0004) //"Medição"
    oBrowse:AddLegend("FQK_SITUAC=='1'", 'BR_AZUL', STR0005) //"Digitado"
    oBrowse:AddLegend("FQK_SITUAC=='2' .AND. FQK->FQK_VALTOT>0", 'BR_VERDE', STR0006) //"Confirmado"
    oBrowse:AddLegend("FQK_SITUAC=='3' .OR. FQK_SITUAC=='6'", 'BR_PRETO', STR0008) //"Cancelado"
    oBrowse:AddLegend("FQK_SITUAC=='4'", 'BR_VERMELHO', STR0007) //"PV Liberado, ou Faturado"
    oBrowse:AddLegend("FQK_SITUAC=='5'", 'BR_BRANCO',STR0010 ) //Em aberto
    oBrowse:AddLegend("FQK_SITUAC=='2' .AND. FQK->FQK_VALTOT==0", 'BR_VIOLETA',STR0009 ) //"Confirmado com vlr.total zerado"
    oBrowse:Activate() 

	SETKEY(VK_F12 , NIL)

Return .T.


/*/{PROTHEUS.DOC} MenuDef
ITUP BUSINESS - TOTVS RENTAL
GERENCIAMENTO DE BENS - OPCOES DO MENU
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 18/03/2024
@HISTORY 18/03/2024, FRANK ZWARG FUGA, TRANSFORMAÇÃO EM MVC
/*/

Static Function MenuDef() 
Local aRotina := {}
Local lPe1 := ExistBlock("LC035ROT")  

    aAdd(aRotina,{ STR0013, "ExeC248(3)"                                ,0,3,0, NIL } ) //"Incluir"
    aAdd(aRotina,{ STR0014, "ExeC248(4)"                                ,0,4,0, NIL } ) //"Manutenção"
    aAdd(aRotina,{ STR0012, "ExeC248(2)"                                ,0,2,0, NIL } ) //"Visualizar"
    aAdd(aRotina,{ STR0059, "PESQBRW"                                   ,0,2,0, NIL } ) //"Pesquisar"
	aAdd(aRotina,{ STR0015, "LOCA24817"                                 ,0,4,0, NIL } ) //"Estornar Pedido de Venda"
    aAdd(aRotina,{ STR0016, "LOCA24816"                                 ,0,4,0, NIL } ) //"Mudar Situação"
    aAdd(aRotina,{ STR0011, "LOCA248L"                                  ,0,6,0, NIL } ) //"Legenda"
    If superGetMV("MV_LOCX224",,.T.)
	    aAdd(aRotina,{ STR0017, "LOCR013"                               ,0,6,0, NIL } ) //"Relatório de Medição"
    EndIf
    aAdd(aRotina,{ STR0018, "LOCA007"                                   ,0,4,0, NIL } ) //"Custos Extras"
    aAdd(aRotina,{ STR0019, "LOCA24804"                                 ,0,6,0, NIL } ) //"Gerar Pedido de Vendas"
    aAdd(aRotina,{ STR0137, "MSDOCUMENT"                                ,0,4,0, Nil } ) //"Conhecimento"

    If lPe1
		aRotina := EXECBLOCK("LC035ROT" ,.T.,.T.,{aRotina}) 
	EndIf

Return aRotina

/*/{PROTHEUS.DOC} LOCA248L
ITUP BUSINESS - TOTVS RENTAL
MEDICAO - LEGENDA
@AUTHOR FRANK ZWARG FUGA
@SINCE 25/07/2024
/*/

Function LOCA248L()
Local aLegenda := {}

    aadd(aLegenda,{"BR_AZUL"    , STR0005}) //"Digitado"
    aadd(aLegenda,{"BR_VERDE"   , STR0006}) //"Em aprovação/fechado"
    aadd(aLegenda,{"BR_PRETO"   , STR0008}) //"Cancelado"
    aadd(aLegenda,{"BR_VERMELHO", STR0007}) //"Medido"
    aadd(aLegenda,{"BR_BRANCO"  , STR0010}) //"Não aprovado"
    aadd(aLegenda,{"BR_VIOLETA" , STR0009}) //"Sem excedente"

    BRWLEGENDA(STR0004,STR0011,aLegenda) // Medição###Legenda

return aLegenda

/*/{PROTHEUS.DOC} ViewDef
ITUP BUSINESS - TOTVS RENTAL
MEDICAO - DEFINICAO DA INTERFACE
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA
@SINCE 26/07/2024
/*/

Static Function ViewDef()
Local oModel   := FWLoadModel("LOCA248")
Local oStPai   := FWFormStruct(2,"FQK")
Local oStFilho := FWFormStruct(2,"FQL")
Local oStFilh2  
Local oView    := Nil  
Local bPreenche 

    //cMarca := GetMark()
    bPreenche := {|| LOCA248A7(cMarca)}

    oStFilh2  := FWFormStruct(2, "FPF")

    //Criando a View
    oView := FWFormView():New() 
    oView:SetModel(oModel)

    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField("VIEW_FQK",oStPai,"FQKMASTER")
    oView:AddGrid("VIEW_FQL",oStFilho,"FQLDETAIL")
    oView:AddGrid("VIEW_FPF",oStFilh2,"FPFDETAIL")
     
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox("CABEC",40)
    oView:CreateHorizontalBox("BOX3" ,60)
    oView:CreateFolder( 'FOLDER1', 'BOX3')		
    oView:AddSheet('FOLDER1','SHEET1', STR0020) // Itens da Medição

    //If lVisual
    //    oView:AddSheet('FOLDER1','SHEET2', STR0021, ) // Minutas
    //Else
        oView:AddSheet('FOLDER1','SHEET2', STR0021, bPreenche) // Minutas
    //EndIf

    oView:CreateHorizontalBox( 'PASTA1A', 100, , , 'FOLDER1', 'SHEET1') 
    oView:CreateHorizontalBox( 'PASTA1B', 100, , , 'FOLDER1', 'SHEET2') 
    oView:SetOwnerView('VIEW_FQK','CABEC') 
    oView:SetOwnerView('VIEW_FQL','PASTA1A')
    oView:SetOwnerView('VIEW_FPF','PASTA1B')
    oView:EnableTitleView("VIEW_FQK",STR0022) // "Detalhamento da Medição"
    oView:EnableTitleView("VIEW_FQL",STR0020) // "Itens da Medição"
    oView:EnableTitleView("VIEW_FPF",STR0021) // "Minutas"
    //oView:SetViewProperty("VIEW_FQK", "ONLYVIEW") 
	//oView:SetViewProperty("VIEW_FPF", "ONLYVIEW")
	oView:AddIncrementField('FQLDETAIL','FQL_ITEM')
    
    oView:AddUserButton( STR0023, STR0023 , {|oView| LOCA248A() } ) // "Visualizar o projeto"
	oView:AddUserButton( STR0082, STR0082 , {|oView| LOCA248C5() } ) // "Atualizar"
    oView:AddUserButton( STR0119, STR0119 , {|oView| LOCA248HIS() } ) // Histórico do contador
    oView:AddUserButton( STR0149, STR0149 , {|oView| LOCA248PV() } ) // Complemento de locação - PV

    // Recálculo da medição - issue 7762 - Frank em 23/07/25
    oView:SetAfterViewActivate({|oView| LOCA24818(oView) })

Return oView

/*/{PROTHEUS.DOC} ModelDef
ITUP BUSINESS - TOTVS RENTAL
MEDICAO - DEFINICAO DO MODELO
@TYPE FUNCTION
@AUTHOR FRANK ZWARG FUGA  
@SINCE 26/07/2024
/*/

Static Function ModelDef()    
Local oModel    := Nil
Local oStPai    := FWFormStruct(1, "FQK") 
Local oStFilho  := FWFormStruct(1, "FQL") 
Local oStFilh2  := FWFormStruct(1, "FPF") 
Local bCommit   := {|| LOCA248B(oModel)}
Local bCanc     := {|| LOCA248C()}  
Local bValida   := {|| LOCA248B2(oModel)}
Local bPreGrid  := {|oStFilho, nLine, cAction, cIDField, xValue, xCurrentValue| fPreLin(oStFilho, nLine, cAction, cIDField, xValue, xCurrentValue)}

    If type("lVisual") <> "L"
        lVisual := .T.
        lInclui := .F.
        lAltera := .F.
        lExclui := .F.
    EndIF

    oStFilh2 := FWFormStruct(1, "FPF")   
    
    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New("LOCA248",,bValida,bCommit,bCanc) 

    oModel:AddFields("FQKMASTER",,oStPai)

    oModel:AddGrid("FQLDETAIL","FQKMASTER",oStFilho,,,bPreGrid,,)
        
    If lVisual
        oModel:AddGrid("FPFDETAIL","FQLDETAIL",oStFilh2,,,,,{|oGrid| LOCA248VP(oGrid)})
    Else
        oModel:AddGrid("FPFDETAIL","FQLDETAIL",oStFilh2,,,,,)
    EndIf
     
    oModel:SetRelation('FQLDETAIL', { { 'FQL_FILIAL', "xFilial('FQL')" }, { 'FQL_COD', 'FQK_COD'  } }, FQL->(IndexKey(1)) )
    oModel:SetRelation('FPFDETAIL', { { 'FPF_FILIAL', "xFilial('FPF')" }, { 'FPF_AS', 'FQL_AS' }, { 'FPF_TURNO', 'FQL_TURNO' }, { 'FPF_FILTRO', 'LOCA248XX()' } }, FPF->(IndexKey(1)) )

    oModel:SetPrimaryKey({})

    //Setando as descrições
    oModel:SetDescription(STR0026) // "Gerenciamento"
    oModel:GetModel("FQKMASTER"):SetDescription(STR0015) // "Medição"
    oModel:GetModel("FQLDETAIL"):SetDescription(STR0014) // "Itens"
    oModel:GetModel("FPFDETAIL"):SetDescription(STR0016) // "Minuta"
    
    oModel:GetModel('FPFDETAIL'):SetOptional(.T.)
    oModel:GetModel('FQLDETAIL'):SetOptional(.T.)
	
    oModelFQL := oModel:GetModel("FQLDETAIL")
    oModel:GetModel( "FPFDETAIL" ):SetOnlyQuery ( .T. ) // não grava a aba das minutas

    oModel:InstallEvent("LOCA248", /*cOwner*/, LOCA248EVDEF():New() )
 
Return oModel


/*/{PROTHEUS.DOC} fPreLin
ITUP BUSINESS - TOTVS RENTAL
Controle das deleções na FQL
@AUTHOR FRANK ZWARG FUGA
/*/

Static Function fPreLin(oModel, nLine, cAction, cIDField, xValue, xCurrentValue)
Local lRet := .T.

    IF cAction == 'UNDELETE'
        Help( ,, "LOCA248-FPRELIN",, STR0002, 1, 0,,,,,,{STR0111}) //"Inconsistência nos dados."###
        lRet := .F.
    EndIf
  
Return lRet


/*/{PROTHEUS.DOC} LOCA248HIS
ITUP BUSINESS - TOTVS RENTAL
Apresenta o histórico do bem
Frank Z Fuga
29/10/2024  
/*/

Function LOCA248HIS
Local aArea := GetArea()
Local oModel := FWModelActive()
Local oModelFQL := oModel:GetModel("FQLDETAIL")

    MNTA080HCO(oModelFQL:GetValue("FQL_FROTA"),1)

    RestArea(aArea)
Return .T.

/*/{PROTHEUS.DOC} Identifica
ITUP BUSINESS - TOTVS RENTAL
Identifica os campos que estão com x3_when bloqueados
Frank Z Fuga
29/10/2024  
/*/

Static Function Identifica
Local aFQL := FWSX3Util():GetListFieldsStruct( "FQL", .F.)
Local aFQK := FWSX3Util():GetListFieldsStruct( "FQK", .F.)
Local nX
Local cCampo
Local cWhen

    aBlqFQL   := {} // Declarado como private no LOCA248.PRW
    aBlqFQK   := {} // Declarado como private no LOCA248.PRW

    For nX := 1 to len(aFQL)
		cCampo := alltrim(GetSx3Cache(alltrim(aFQL[nX][01]),"X3_CAMPO"))
		cWhen  := GetSx3Cache(alltrim(cCampo),"X3_WHEN")
        If !empty(cWhen)
            aadd(aBlqFQL,{cCampo,cWhen})
        EndIF
    Next

    For nX := 1 to len(aFQK)
		cCampo := alltrim(GetSx3Cache(alltrim(aFQK[nX][01]),"X3_CAMPO"))
		cWhen  := GetSx3Cache(alltrim(cCampo),"X3_WHEN")
        If !empty(cWhen)
            aadd(aBlqFQK,{cCampo,cWhen})
        EndIF
    Next
    
Return .T.

/*/{PROTHEUS.DOC} LOCA248XX
ITUP BUSINESS - TOTVS RENTAL
Uso no filtro da FPF com base nas datas
Frank Z Fuga
03/06/2025  
/*/

Function LOCA248XX
cMarca := GetMark()
Return cMarca

/*/{PROTHEUS.DOC} LOCA248VP
ITUP BUSINESS - TOTVS RENTAL
Cria os registros na grid da minuta na visualização
Frank Z Fuga
03/06/2025  
/*/

Function LOCA248VP(oGrid)
Local aArea      := GetArea()
Local cAliasT    := GetNextAlias()
Local aDados     := {}
Local aStruQry   := {}
Local nLinha     := 0
Local cQuery 	 := ''
Local aParam     := {}
Local oModel     := FWModelActive()
Local oModelFQL  := oModel:GetModel("FQLDETAIL")
Local aAs        := {}
Local cAs        := ""
Local lMinuta    := .F.

    If !empty(oModelFQL:GetValue("FQL_AS")) 
		aadd(aAs,{oModelFQL:GetValue("FQL_AS"),oModelFQL:GetValue("FQL_TURNO")})
	EndIf

	If len(aAs) > 0
		cAs := aAs[1,1] // o primeiro registro já dá base para saber se é de minuta
		FPA->(dbSetOrder(3))
		If FPA->(dbSeek(xFilial("FPA")+cAs))
			If FPA->FPA_TIPOCA == "H" .and. FPA->FPA_TPBASE == "H" .and. (FPA->FPA_TIPOSE == "L" .or. FPA->FPA_TIPOSE == "M")
				lMinuta := .T.
			EndIf
		EndIF
	EndIf

	cQuery += "SELECT FPF.*, FPF.R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("FPF") + " FPF " 
	cQuery += " WHERE FPF.FPF_FILIAL = '" + xFilial("FPF") + "' "
    If !lMinuta
        cQuery += " AND FPF.FPF_MINUTA = '' "
    EndIf
    cQuery += " AND ( FPF.FPF_STATUS = '3' OR FPF.FPF_STATUS = '6' )  "
    cQuery += " AND FPF.FPF_AS = ? "
    cQuery += " AND FPF.FPF_DATA >= ? "
	cQuery += " AND FPF.FPF_DATA <= ? "
    cQuery += " AND FPF.D_E_L_E_T_ = '' "
    cQuery += " AND FPF.FPF_NROMED = ? "
    cQuery += " AND FPF.FPF_MEDSEQ = ? "
    cQuery += " AND FPF.FPF_TURNO = ? "

	aadd( aParam, cAs )
    aadd( aParam, dtos(M->FQK_DTINIC) )
	aadd( aParam, dtos(M->FQK_DTFIM) )
    aadd( aParam, M->FQK_COD)
    aadd( aParam, M->FQK_MEDSEQ)
    aadd( aParam, oModelFQL:GetValue("FQL_TURNO"))

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery,cAliasT,,,aParam)

	aStruQry := (cAliasT)->(DbStruct())

	For nLinha := 1 To Len(aStruQry)
		If GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "D" .Or. GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO") == "N"
			TCSetField( cAliasT , aStruQry[nLinha][1], GetSX3Cache(aStruQry[nLinha][1],"X3_TIPO"), GetSX3Cache(aStruQry[nLinha][1],"X3_TAMANHO") , GetSX3Cache(aStruQry[nLinha][1],"X3_DECIMAL"))
		Endif
	Next 
	
	aDados := FWLoadByAlias( oGrid , cAliasT , 'FPF' , 'RECNO' , Nil , .t. )

	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return( aDados )

/*/{Protheus.doc} LOCA248EVDEF
Classe para tratamento da movimentação da aba minutas
@type class
@version  
@author Frank Zwarg Fuga
@since 11/07/2025
/*/
CLASS LOCA248EVDEF FROM FWModelEvent
	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
ENDCLASS

/*/{Protheus.doc} New
Método de instanciação - construtor
@author Frank Zwarg Fuga
@since 11/07/2025
@type method
@return logical, sempre .T.
/*/
METHOD New() CLASS LOCA248EVDEF
RETURN .T.


/*/{Protheus.doc} GridLinePreVld
Método para validação das grids
@author Frank Zwarg Fuga
@since 11/07/2025
@return logical, se confirma ou não a ação no Grid
/*/
METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS LOCA248EVDEF
local lRet  := .T.

    If cModelID == "FPFDETAIL"
        if cAction == "CANSETVALUE" .or. cAction == "DELETE" .or. cAction == "UNDELETE"
            FMX_HELP("LOCA248", STR0002, STR0138) //"Inconsistência nos dados."###"Operação inválida para a aba minutas."
            lRet := .F.
        endif
    EndIf

return lRet

/*/{Protheus.doc} LOCA24818
Recalculo da medição
@type function
@version  
@author Frank Zwarg Fuga
@since 23/07/2025
/*/
Function LOCA24818(oView)
    If lAltera .or. lVisual
        LOCA248A7(cMarca)
    EndIf
Return .T.

/*/{Protheus.doc} LOCA24819
Função para encontrar a quantidade de parcelas de um ciclo de faturamento
Precisa estar posicionado na FPA
@type function
@author Frank Zwarg Fuga
@since 28/07/2025
/*/
Function LOCA24819()
Local nParc248 := 0
Local nTot := 0
Local nX

    FPA->(dbSetOrder(1))
    FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))
    While !FPA->(eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == FP0->FP0_PROJET
        nTot ++
        FPA->(dbSkip())
    EndDo

    ProcRegua(nTot)
    FPA->(dbSetOrder(1))
    FPA->(dbSeek(xFilial("FPA")+FP0->FP0_PROJET))
    nX := 0
    While !FPA->(eof()) .and. FPA->FPA_FILIAL == xFilial("FPA") .and. FPA->FPA_PROJET == FP0->FP0_PROJET
        nX ++
        nParc248 := LOCA24819B()
        If FPA->FPA_QTDPRC <> nParc248
            FPA->(RecLock("FPA",.F.))
            FPA->FPA_QTDPRC := nParc248
            FPA->(MsUnlock())
        EndIf
        IncProc(STR0145+alltrim(str(nX))+STR0146+alltrim(str(nTot))) //"Processo: "###" de: "
        SysRefresh()
        FPA->(dbSkip())
    EndDo
Return

/*/{Protheus.doc} LOCA24819B
Função para encontrar a quantidade de parcelas de um ciclo de faturamento
Precisa estar posicionado na FPA
@type function
@author Frank Zwarg Fuga
@since 28/07/2025
/*/
Function LOCA24819B()
Local nParc := 0
Local aRet := {}
Local aPedVen := {}
Local nX
Local lExiste := .F.
Local aAreaFPA := FPA->(GetArea())
Local aProvisorio := {}

    // neste momento a FPA deve estar posicionada registro a registro para o processamento das parcelas
    // fonte utilizado na geração do contrato

    aRet := LOCA24819A()

    nParc := len(aRet)

    // Validar além do ciclo de faturamento se algo ja foi faturado
    FPZ->(dbSetOrder(2))
    FPZ->(dbSeek(xFilial("FPZ")+FPA->FPA_AS))
    While !FPZ->(Eof()) .and. FPZ->(FPZ_FILIAL+FPZ_AS) == xFilial("FPZ")+FPA->FPA_AS
        FPY->(dbSetOrder(1))
        If FPY->(dbSeek(xFilial("FPY")+FPZ->FPZ_PEDVEN))
            If FPY->FPY_TIPFAT <> "R" .and. alltrim(FPY->FPY_STATUS) <> "2"
                lExiste := .F.
                For nX := 1 to len(aPedVen)
                    If aPedVen[nX] == FPY->FPY_PEDVEN
                        lExiste := .T.
                        Exit
                    EndIF
                Next
                If !lExiste
                    aadd(aPedVen,FPY->FPY_PEDVEN)
                EndIf
            EndIf
        EndIf
        FPZ->(dbSkip())
    EndDo
    nParc += len(aPedVen)

    For nX := 1 to len(aRet)
        aadd(aProvisorio,{aRet[nX,1,2],aRet[nX,1,3],aRet[nX,1,4],aRet[nX,1,5],aRet[nX,1,1],aRet[nX,1,6],aRet[nX,1,7],aRet[nX,1,8],aRet[nX,1,9]})
    Next

    // Regra para os pedidos já gerados
    // Dos itens que já geraram pedido de vendas (aPedVen), não vamos gerar o provisório

    LOCA01315(aProvisorio)

    FPA->(RestArea(aAreaFPA))

Return nParc

/*/{Protheus.doc} LOCA24819A
Função para encontrar a quantidade de parcelas de um ciclo de faturamento
@type function
@author Frank Zwarg Fuga
@since 28/07/2025
/*/
Function LOCA24819A
Local aExecAuto := {}
Local cPrjd     := FPA->FPA_PROJET
Local cPrja     := FPA->FPA_PROJET
Local aAs       := {FPA->FPA_AS} 
Local dTemp     := ctod("")
Local aPedidos  := {}

Private lMsErroAuto    := .F.
Private lAutoErrNoFile := .T.
Private aRetExec       := {.T.} // Tratamento .T. para indicar que é apenas para ver as parcelas
Private lPreview       := .T. // indica para o LOCA021 que não é para gerar os PV, calcula apenas as parcelas
Private dUltFat248     := FPA->FPA_ULTFAT
Private dDtFim248      := FPA->FPA_DTFIM
Private dGeraEm248     := FPA->FPA_GERAEM

    dTemp := dUltFat248

    While FPA->FPA_DTENRE > dUltFat248 
        aRetExec := {}
        aExecAuto := {}
        aadd(aExecAuto,.T.)
        aadd(aExecAuto,aRetExec)
        aadd(aExecAuto,"")
        aadd(aExecAuto,"ZZZZZZ")
        aadd(aExecAuto,"")
        aadd(aExecAuto,"ZZ")
        aadd(aExecAuto,"                ")
        aadd(aExecAuto,"ZZZZZZZZZZZZZZZZ")
        aadd(aExecAuto,"                              ")
        aadd(aExecAuto,"ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ")
        aadd(aExecAuto,"   ")
        aadd(aExecAuto,"ZZZ")  
        aadd(aExecAuto,ctod("01/01/2000"))
        aadd(aExecAuto,ctod("01/01/2045"))
        aadd(aExecAuto,3)
        aadd(aExecAuto,ctod(""))
        aadd(aExecAuto,ctod("01/01/2045"))

        MSEXECAUTO({|A,B,C,D,E,F,G| LOCA021(A,B,C,D,E,F,G)} , Nil , cPrjd , cPrja, aAs , .T. , 1 , aExecAuto)

        If len(aRetExec) > 0
            If len(aRetExec[1]) > 0
                aadd(aPedidos,aRetExec)
            EndIf
        Else
            Exit
        EndIf

        If dTemp == dUltFat248
            Exit
        EndIf

    EndDo
    
Return aPedidos

/*/{Protheus.doc} LOCA248PV
Detalhamento do pedido de vendas
@type function
@author Frank Zwarg Fuga
@since 11/08/2025
/*/
Function LOCA248PV
Local lRet := .T.
Local cErro := ""
    If lInclui
        cErro := STR0150 //"Opção não disponível no momento da inclusão da medição."
        lRet := .F.
    EndIf
    If Empty(FQK->FQK_NUMPV) .and. lRet
        cErro := STR0151 //"Não há um pedido de vendas associado a esta medição"
        lRet := .F.
    EndIf
    If !lRet
        Help(Nil,	Nil,STR0001+alltrim(upper(Procname())),; //"RENTAL: "
		Nil,STR0002,1,0,Nil,Nil,Nil,Nil,Nil,; //"Inconsistência nos dados."
		{cErro}) 
    EndIf
    if lRet
        SC5->(dbSetOrder(1))
        SC5->(dbSeek(xFilial("SC5")+FQK->FQK_NUMPV))
        A410Visual("SC5",SC5->(Recno()),2)
    EndIf
Return lRet

/*/{Protheus.doc} LOCACLOSE
Fecha um alias se este estiver aberto
@type function
@author Frank Zwarg Fuga
@since 30/09/2025
/*/
Function LOCACLOSE(cAlias)
    If Select(cAlias) > 0
        (cAlias)->(DbCloseArea())
    EndIf
Return
