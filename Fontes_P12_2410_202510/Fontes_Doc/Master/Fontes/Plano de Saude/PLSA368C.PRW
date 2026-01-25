#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#Include 'PLSA368C.ch'

function PLSA368C(lAutoma)
local   cFiltro  := ""
default lAutoma := .f.
private oBrwBE3  := nil

If !FWAliasInDic("BE3")
	If !lAutoma
		aviso( "Atenção","Para a execução da rotina, é necessário a criação da tabela BE3." ,{ "Ok" }, 2 )
		return
	Else
		return .F.
	EndIf
EndIf

cFiltro := "@(BE3_FILIAL = '" + xFilial("BE3") +  "' "
cFiltro += "AND BE3_CODRDA   = '" + B8O->B8O_CODRDA + "' "
cFiltro += "AND BE3_IDCOPR   = '" + B8O->B8O_IDCOPR + "')"

oBrwBE3:= FWMBrowse():New()
oBrwBE3:SetAlias('BE3')
oBrwBE3:SetDescription(STR0001) //Cadastro de Faixas
oBrwBE3:SetFilterDefault(cFiltro)
oBrwBE3:SetMenuDef("PLSA368C")

if !lAutoma
    oBrwBE3:Activate()
endif

return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author    Thiago Rodrigues
@version   V12
@since     05/10/2022
/*/
Static function ModelDef()
local oModel    := nil
local oStrBE3   := FWFormStruct(1,'BE3')// cria as estruturas a serem usadas no modelo de dados

oModel := MPFormModel():New( 'PLSA368C' , ,  /*{ || PlPosVld(oModel) }*/ ) // cria o objeto do modelo de dados

oModel:addFields('MasterBE3',/*cOwner*/, oStrBE3)  // adiciona ao modelo um componente de formulário

oModel:GetModel('MasterBE3'):SetDescription(STR0001) // adiciona a descrição do modelo de dados : (Cadastro de Faixas)

//Inicializador padrão
oStrBE3:SetProperty( 'BE3_CODRDA' , MODEL_FIELD_INIT, { || B8O->B8O_CODRDA} )
oStrBE3:SetProperty( 'BE3_IDCOPR' , MODEL_FIELD_INIT, { || B8O->B8O_IDCOPR} )
oStrBE3:SetProperty( 'BE3_CODOPE' , MODEL_FIELD_INIT, { || B8O->B8O_CODINT} )

//Obrigatórios
oStrBE3:SetProperty( "BE3_CODRDA" , MODEL_FIELD_OBRIGAT,.T.)
oStrBE3:SetProperty( "BE3_IDCOPR" , MODEL_FIELD_OBRIGAT,.T.)
oStrBE3:SetProperty( "BE3_CODOPE" , MODEL_FIELD_OBRIGAT,.T.)
oStrBE3:SetProperty( "BE3_SEQUEN" , MODEL_FIELD_OBRIGAT,.T.)
oStrBE3:SetProperty( "BE3_FAIXIN" , MODEL_FIELD_OBRIGAT,.T.)
oStrBE3:SetProperty( "BE3_FAIFIM" , MODEL_FIELD_OBRIGAT,.T.)
oStrBE3:SetProperty( "BE3_VLRCON" , MODEL_FIELD_OBRIGAT,.T.)

oModel:SetPrimaryKey( {"BE3_FILIAL", "BE3_CODRDA", "BE3_IDCOPR","BE3_CODOPE","BE3_SEQUEN"} )// define chave primária do model

Return oModel // Retorna o modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author    Thiago Rodrigues
@version   V12
@since     05/10/2022
/*/
Static function ViewDef()
local oView  // interface de visualização 
local oModel := FWLoadModel( 'PLSA368C' ) // cria as estruturas a serem usadas na View
local oStrBE3:= FWFormStruct(2, 'BE3')

oView := FWFormView():New() // cria o objeto de View

oView:SetModel(oModel)		// define qual Modelo de dados será utilizado

oView:AddField('ViewBE3' , oStrBE3,'MasterBE3' ) // adiciona no nosso View um controle do tipo formulário

oView:EnableTitleView( 'ViewBE3', 'Cadastro de faixas')

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} menuDef
função para criar o menu da tela

@author    Thiago Rodrigues
@version   V12
@since     08/2022
/*/
static function menuDef()
private aRotina := {}

Add Option aRotina Title  STR0002	Action 'VIEWDEF.PLSA368C' 	Operation 2 Access 0  //Visualizar
Add Option aRotina Title  STR0003 	Action "VIEWDEF.PLSA368C" 	Operation 3 Access 0  //Incluir
Add Option aRotina Title  STR0004 	Action "VIEWDEF.PLSA368C" 	Operation 4 Access 0  //Alterar
Add Option aRotina Title  STR0005	Action 'VIEWDEF.PLSA368C'	Operation 5 Access 0 // Excluir

return aRotina


/*/{Protheus.doc} VldVlrNeg
    (Valida Valor Negativo)
    @type  Function
    @author Thiago Rodrigues
    @since 06/10/2022
    @version version
    @param Campo
    @return logico
/*/
Function PLVldVlNeg(cCampo)
local lRet   := .t. 
local oModel := FWModelActive() 

if oModel:getModel("MasterBE3"):getValue(cCampo) < 0
    Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {STR0008} )//"Atenção Valor negativo não é válido, Informe um valor positivo
    lRet := .f.
endif

Return lRet



/*/{Protheus.doc} PLVldFaixa
    (Valida Faixa)
    @type Function
    @author Thiago Rodrigues
    @since 06/10/2022
    @version version
    @param  nOpc (1 = faixa inicial , 2 = faixa final)
    @return logico
/*/
Function PLVldFaixa(nOpc)
local lRet       := .t. 
Local oModel     := FWModelActive() 
local aMsg       := {STR0009,STR0010} //"Valor inicial da faixa não pode ser maior que o valor final"
local nFaixaIni  := oModel:getModel("MasterBE3"):getValue("BE3_FAIXIN")
local nFaixaFim  := oModel:getModel("MasterBE3"):getValue("BE3_FAIFIM")
local cSql       := ""
local nOperation := oModel:getOperation() 

if nFaixaIni > nFaixaFim .and. nFaixaFim > 0
    lRet := .f. 
    if nOpc == 2 
        aMsg := {STR0011,STR0012} //Atenção Valor final da faixa não pode ser menor que o valor inicial
    endif
elseif nFaixaIni == nFaixaFim .and. nFaixaIni <> 0
     lRet := .f. 
     aMsg := {STR0015,STR0016} //Atenção Os valores de faixa não podem ser iguais
endif

 //Valida as vigências
if lRet .and. nOpc == 1
    cSql := " SELECT 1 FROM "        + RetSqlName("BE3") 
    cSql += " WHERE BE3_FILIAL = '"  + xFilial("BE3") + "' "
    cSql += " AND BE3_CODRDA = '"    + oModel:getModel("MasterBE3"):GetValue("BE3_CODRDA") + "' "
    cSql += " AND BE3_IDCOPR = '"    + oModel:getModel("MasterBE3"):GetValue("BE3_IDCOPR") + "' "
    cSql += " AND BE3_CODOPE = '"    + oModel:getModel("MasterBE3"):GetValue("BE3_CODOPE") + "' "
    cSql += " AND    " + cValToChar(nFaixaIni) + " >= BE3_FAIXIN "
    cSql += " AND    " + cValToChar(nFaixaIni) + " <= BE3_FAIFIM "
    cSql += " AND D_E_L_E_T_ = ' ' " 

    if nOperation == 4  // Proteção contra alterar o proprio registro
        cSql += " AND R_E_C_N_O_  <> "   + cValToChar(BE3->(RECNO())) 
    endif

    dbUseArea(.t.,"TOPCONN",tcGenQry(,,cSql),"VerFaixaDup",.f.,.t.)

    if !VerFaixaDup->(eof())
        aMsg := {STR0013,STR0014}//Já existe uma faixa cadastrada que compreende ao intervalo informado
        lRet := .F.
    endif
    VerFaixaDup->(DbCloseArea())
endif

if !lRet
    Help(nil, nil , STR0006, nil, aMsg[1], 1, 0, nil, nil, nil, nil, nil, {aMsg[2]} ) 
endif
Return lRet
