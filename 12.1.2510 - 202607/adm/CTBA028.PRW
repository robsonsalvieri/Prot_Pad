#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CTBA028.CH'

//--------------------------------------------------
/*/{Protheus.doc} CTBA028
Cadastramento de Códigos de Tributos para a DeRE

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510
/*/
//--------------------------------------------------
Function CTBA028()

	Local oBrw As Object

    If !FWSX3Util():SeekX3File("QLS_CODTRB")//Proteção para não quebrar enquando a tabela não existir
        Help(" ",1,"NODICQLS",, STR0007, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0008})//"O dicionário da tabela QLS não foi aplicado."###"Utilize o UPDDISTR para criar os componentes necessários."
	    Return
    EndIf
    
    oBrw := FWMBrowse():New()

    MsgRun( STR0001 ,, { || CheckQLS() } )//"Aguarde, estamos preparando a tabela QLS"

	oBrw:setDescription(STR0002)//"Códigos de Tributos DERE"
	oBrw:setAlias("QLS")

	oBrw:Activate()

Return

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Opções do Menu Funcional da rotina CTBA028

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510

@return array, opcoes de menu da rotina
/*/
//--------------------------------------------------
static function MenuDef() As Object

    Local aRotina As Array 
    aRotina := {}

    ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.CTBA028'	OPERATION 2 ACCESS 0 //"Visualizar"
    ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.CTBA028'	OPERATION 3 ACCESS 0 //"Incluir"
    ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.CTBA028'	OPERATION 4 ACCESS 0 //"Alterar"
    ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.CTBA028'   OPERATION 5 ACCESS 0 //"Excluir" 

Return (aRotina)

//--------------------------------------------------
/*/{Protheus.doc} ModelDef
Definições do modelo de dados da rotina

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510

@return objeto, modelo de dados
/*/
//--------------------------------------------------
static function ModelDef() As Object

	Local oModel    As Object
	Local oStr      As Object
    
    oStr := FwFormStruct(1,"QLS")

    oStr:SetProperty( 'QLS_CODTRB' , MODEL_FIELD_WHEN ,{||IIF( !IsBlind(),IIF(INCLUI,.T.,.F.),.T.)}) //Permite editar o código apenas na inclusão.

    oModel := MpFormModel():New("CTBA028")

	oModel:AddFields("QLSMASTER",,oStr)//nomeio o Modelo e coloco a Struct nele
	oModel:SetDescription(STR0002) //"Códigos de Tributos DERE"
	oModel:getModel("QLSMASTER"):SetDescription(STR0002) //"Códigos de Tributos DERE"

return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição da Interface da Rotina.

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510
/*/
//-------------------------------------------------------------------
static function ViewDef() As Object

    Local oModel    As Object
	Local oStr      As Object
    Local oView     As Object

    oModel := FwLoadModel("CTBA028")
    oStr := FwFormStruct(2,"QLS")
    oView:= FwFormView():new()

    oView:setModel(oModel)
    oView:addField("VIEW_QLS",oStr, "QLSMASTER")
    oView:CreateHorizontalBox("TELA",100)
	oView:EnableTitleView("VIEW_QLS", STR0002)//"Códigos de Tributos DERE"

return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Efetua a primeira carga da tabela QLS se não estiver populada

@author pierre.nascimento
@since 05/03/2026
@version P12.1.2510
/*/
//-------------------------------------------------------------------
Function CheckQLS()

    Local aCodTrb   As Array
    Local nX        As Numeric
    Local cFilQLS   As Character
    Local nTamTrib  As Numeric

    aCodTrb     := {}
    nX          := 0
    cFilQLS     := FwXFilial("QLS")
    nTamTrib    := TAMSX3("QLS_CODTRB")[1]

    /* O Array aCodTrb terá as seguintes informações em ordem 
    1- Codigo do Tributo
    2- Titulo do Tributo
    3- Dispositivo Legal
    4- Descrição Detalhada*/

    //TRIBUTOS GERAIS
    aAdd(aCodTrb,{'1',"ATIVO","",""})
    aAdd(aCodTrb,{'11',"SERVIÇOS FINANCEIROS","",""})
    aAdd(aCodTrb,{'110000001',"Valores recebidos em operações de crédito, câmbio e TVM","LC 214/2025 Arts. 194 e 195",;
    "Classificar nesse código as rubricas contábeis representativas dos valores em operações de crédito, câmbio e TVM, que serão usadas como base para cálculo do valor do IBS e da CBS que será cobrado dos adquirentes. Obs.: As receitas oriundas de operações com títulos de dívida com oferta pública devem ser classificadas em código específicos, por não darem direito a crédito."})
    aAdd(aCodTrb,{'110000002',"Valores recebidos relativos a operações de securitização e faturização","LC 214/2025 Art. 196",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos a título de antecipação de recebíveis, que serão usadas como base para cálculo do valor do IBS e da CBS que será cobrado dos adquirentes."})
    aAdd(aCodTrb,{'110000003',"Valores recebidos em operações de crédito, com recursos do FGTS","LC 214/2025 Art. 194",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos em operações de crédito com recursos do FGTS, que serão usadas como base para cálculo do valor do IBS e da CBS que será cobrado dos adquirentes."})
    aAdd(aCodTrb,{'110000004',"Títulos de dívida com oferta pública","LC 214/2025 Art. 195, §§ 1º e 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores dos títulos de dívida adquiridos pelo contribuinte diretamente em oferta pública ou por meio de fundos exclusivos, com pelo menos 95% dos direitos relativos a esses títulos."})
    aAdd(aCodTrb,{'110000005',"Base de Cálculo Negativa do IBS/CBS","LC 214/2025 Art. 301",;
    "Classificar nesse código as rubricas contábeis que registrarem a base de cálculo negativa do IBS/CBS a ser compensada em períodos posteriores."})
    aAdd(aCodTrb,{'111',"ARRENDAMENTO MERCANTIL","",""})
    aAdd(aCodTrb,{'1111',"ARRENDAMENTO MERCANTIL OPERACIONAL","",""})
    aAdd(aCodTrb,{'11111',"BENS IMÓVEIS","",""})
    aAdd(aCodTrb,{'111111',"Valor da Parcela","",""})
    aAdd(aCodTrb,{'1111111',"Operações realizadas com contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11111111',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111111111',"Valores da parcela recebida, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, a, 1",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das parcelas recebidas, oriunda de operações realizadas com contribuintes do IBS e da CBS do Regime Regular. Incluir nesse código tarifas ou outros encargos cobrados juntamente com a parcela."})
    aAdd(aCodTrb,{'11111112',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111111121',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111111122',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1111112',"Operações realizadas com não contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11111121',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111111211',"Valores da parcela recebida, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, a, 1",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das parcelas recebidas, oriunda de operações realizadas com NÂO contribuintes do IBS e da CBS do Regime Regular. Incluir nesse código tarifas ou outros encargos cobrados juntamente com a parcela."})
    aAdd(aCodTrb,{'11111122',"Valores pagos despesas dedutíveis","",""})
    aAdd(aCodTrb,{'111111221',"Despesas de arrendamento comprovadas com documentos fiscais","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas com pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante a emissão de documentos fiscais."})
    aAdd(aCodTrb,{'111111222',"Despesas de arrendamento comprovadas com registro contábil","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas com pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante registro contábil, como depreciação do bem."})
    aAdd(aCodTrb,{'11111123',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111111231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111111232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1111113',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111111301',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'1111114',"Bens adquiridos para fins de arrendamento","",""})
    aAdd(aCodTrb,{'111111401',"Valor dos bens imóveis aquiridos para fins de arrendamento","LC 214/2025 Art. 303.",;
    "Classificar nesse código as rubricas contábeis onde estão registrados os bens imóveis adquiridos para fins de arrendamento mercantil operacional, comprovados mediante emissão de documento fiscal ou não (no caso de aquisição de pessoa física)."})
    aAdd(aCodTrb,{'111112',"Valor da Alienação","",""})
    aAdd(aCodTrb,{'1111121',"Operações realizadas com contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11111211',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111112111',"Valor recebido pela alienação do bem, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, b, 1",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos pela alienação do bem, com contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11111212',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111112121',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111112122',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1111122',"Operações realizadas com não contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11111221',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111112211',"Valor recebido pela alienação do bem, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, b, 1",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos pela alienação do bem, com NÃO contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11111222',"Valores pagos despesas dedutíveis","",""})
    aAdd(aCodTrb,{'111112221',"Despesas de arrendamento comprovadas com documentos fiscais","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante a emissão de documentos fiscais."})
    aAdd(aCodTrb,{'111112222',"Despesas de arrendamento comprovadas com registro contábil","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante registro contábil, como depreciação do bem."})
    aAdd(aCodTrb,{'11111223',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111112231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111112232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1111123',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111112301',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'1111124',"Bens adquiridos para fins de arrendamento","",""})
    aAdd(aCodTrb,{'111112401',"Valor dos bens móveis aquiridos para fins de arrendamento","LC 214/2025 Art. 303.",;
    "Classificar nesse código as rubricas contábeis onde estão registrados os bens móveis adquiridos para fins de arrendamento mercantil operacional, comprovados mediante emissão de documento fiscal."})
    aAdd(aCodTrb,{'11112',"BENS MÓVEIS","",""})
    aAdd(aCodTrb,{'111121',"Valor da Parcela","",""})
    aAdd(aCodTrb,{'1111211',"Operações realizadas com contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11112111',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111121111',"Valores da parcela recebida, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, a, 2",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das parcelas recebidas, oriunda de operações realizadas com contribuintes do IBS e da CBS do Regime Regular. Incluir nesse código tarifas ou outros encargos cobrados juntamente com a parcela."})
    aAdd(aCodTrb,{'11112112',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111121121',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111121122',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1111212',"Operações realizadas com não contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11112121',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111121211',"Valores da parcela recebida, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, a, 2",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das parcelas recebidas, oriunda de operações realizadas com NÃO contribuintes do IBS e da CBS do Regime Regular. Incluir nesse código tarifas ou outros encargos cobrados juntamente com a parcela."})
    aAdd(aCodTrb,{'11112122',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'111121221',"Despesas de arrendamento comprovadas com documentos fiscais","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante a emissão de documentos fiscais."})
    aAdd(aCodTrb,{'111121222',"Despesas de arrendamento comprovadas com registro contábil","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante registro contábil, como depreciação do bem."})
    aAdd(aCodTrb,{'11112123',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111121231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111121232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1111213',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111121301',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'1111214',"Bens adquiridos para fins de arrendamento","",""})
    aAdd(aCodTrb,{'111121401',"Valor dos bens móveis aquiridos para fins de arrendamento","LC 214/2025 Art. 303.",;
    "Classificar nesse código as rubricas contábeis onde estão registrados os bens móveis adquiridos para fins de arrendamento mercantil operacional, comprovados mediante emissão de documento fiscal."})
    aAdd(aCodTrb,{'111122',"Valor da Alienação","",""})
    aAdd(aCodTrb,{'1111221',"Operações realizadas com contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11112211',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111122111',"Valor recebido pela alienação do bem, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, b, 2",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos pela alienação do bem, com contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11112212',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111122121',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111122122',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11112213',"Valores pagos não dedutíveis","",""})
    aAdd(aCodTrb,{'111122131',"Despesas de arrendamento em operações realizadas com contribuintes do IBS/CBS","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional relativo a bens móveis, oriunda de operações realizadas pessoas físicas ou jurídicas contribuintes do IBS e da CBS do Regime Regular."})
    aAdd(aCodTrb,{'1111222',"Operações realizadas com não contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11112221',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111122211',"Valor recebido pela alienação do bem, incluindo tarifas e outros encargos","LC 214/2025 Art. 201, I, b, 2",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos pela alienação do bem, com contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11112222',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'111122221',"Despesas de arrendamento comprovadas com documentos fiscais","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante a emissão de documentos fiscais."})
    aAdd(aCodTrb,{'111122222',"Despesas de arrendamento comprovadas com registro contábil","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil operacional, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante registro contábil, como depreciação do bem."})
    aAdd(aCodTrb,{'11112223',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111122231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111122232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1111223',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111122301',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'1111224',"Bens adquiridos para fins de arrendamento","",""})
    aAdd(aCodTrb,{'111122401',"Valor dos bens móveis aquiridos para fins de arrendamento","LC 214/2025 Art. 303.",;
    "Classificar nesse código as rubricas contábeis onde estão registrados os bens móveis adquiridos para fins de arrendamento mercantil operacional, comprovados mediante emissão de documento fiscal."})
    aAdd(aCodTrb,{'1112',"ARRENDAMENTO MERCANTIL FINANCEIRO","",""})
    aAdd(aCodTrb,{'11121',"VALOR DA PARCELA","",""})
    aAdd(aCodTrb,{'111211',"Bens móveis ou imóveis","",""})
    aAdd(aCodTrb,{'1112111',"Operações realizadas com contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11121111',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111211111',"Valor da parcela recebida, inclusive tarifas e outros encargos","LC 214/2025 Art. 201, I, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das parcelas recebidas de arrendamento mercantil financeiro oriundas de clientes que sejam contribuintes do Regime Regular do IBS e da CBS. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11121112',"Valores pagos dedutíveis","",""})
    aAdd(aCodTrb,{'111211121',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111211122',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11121113',"Valores pagos não dedutíveis","",""})
    aAdd(aCodTrb,{'111211131',"Despesa de captação de recursos","LC 214/2025 Art. 201, II",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos para captação de recursos. Esse código deve ser utilizado somente por empresas exclusivamente arrendadoras, em relação às receitas obtidas com não contribuintes do IBS e da CBS do Regime Regular. Observação: ao final de cada competência a empresa deve fazer o cálculo do rateio das despesas de captação, na proporção das receitas tributáveis obtidas com contribuintes e com não contribuintes do IBS e da CBS, nos termos da legislação aplicável. No caso de bancos múltiplos, com carteira de arrendamento, utilizar os códigos 411100001 ou 411100002."})
    aAdd(aCodTrb,{'11121114',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111211141',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'111211142',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'1112112',"Operações realizadas com não contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11121121',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111211211',"Valor da parcela recebida, inclusive tarifas e outros encargos","LC 214/2025 Art. 201, I, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das parcelas recebidas de arrendamento mercantil financeiro oriundas de clientes que não sejam contribuintes do Regime Regular do IBS e da CBS. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11121122',"Despesa de captação de recursos","",""})
    aAdd(aCodTrb,{'111211221',"Despesas de captação de recursos","LC 214/2025 Art. 201, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos para captação interna de recursos. Esse código deve ser utilizado somente por empresas exclusivamente arrendadoras, em relação às receitas obtidas com contribuintes do IBS e da CBS do Regime Regular. Observação: ao final de cada competência a empresa deve fazer o cálculo do rateio das despesas de captação, na proporção das receitas obtidas com contribuintes e com não contribuintes do IBS e da CBS, nos termos da legislação aplicável. No caso de bancos múltiplos, com carteira de arrendamento, utilizar os códigos 411100001 ou 411100002."})
    aAdd(aCodTrb,{'11121123',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111211231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111211232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11121124',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111211241',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'111211242',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'11122',"VALOR RESIDUAL","",""})
    aAdd(aCodTrb,{'111221',"Bens Imóveis","",""})
    aAdd(aCodTrb,{'1112211',"Operações realizadas com contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11122111',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111221111',"Valor residual recebido, inclusive tarifas e outros encargos","LC 214/2025 Art. 201, I, d, 1",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos do valor residual do bem, com contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11122112',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111221121',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111221122',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11122113',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111221131',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'111221132',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'1112212',"Operações realizadas com não contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11122121',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111221211',"Valor residual recebido, inclusive tarifas e outros encargos","LC 214/2025 Art. 201, I, d, 1",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos do valor residual do bem, com NÃO contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11122122',"Valores pagos despesas dedutíveis","",""})
    aAdd(aCodTrb,{'111221221',"Despesas de arrendamento em relação ao valor residual do bem","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil financeiro, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante a emissão de documentos fiscais."})
    aAdd(aCodTrb,{'11122123',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111221231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111221232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11122124',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111221241',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'111221242',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'111222',"Bens Móveis","",""})
    aAdd(aCodTrb,{'1112221',"Operações realizadas com contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11122211',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111222111',"Valor residual recebido, inclusive tarifas e outros encargos","LC 214/2025 Art. 201, I, d, 2",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos do valor residual do bem, com contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11122212',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111222121',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111222122',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11122213',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111222131',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'111222132',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'1112222',"Operações realizadas com não contribuintes do IBS/CBS","",""})
    aAdd(aCodTrb,{'11122221',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'111222211',"Valor residual recebido, inclusive tarifas e outros encargos","LC 214/2025 Art. 201, I, d, 2",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos do valor residual do bem, com NÃO contribuintes do IBS e da CBS pelo Regime Regular. Incluir nesse código o valor cobrado por tarifas e outros encargos considerados acessórios à operação de arrendamento cobrados juntamente com o valor da parcela."})
    aAdd(aCodTrb,{'11122222',"Valores pagos despesas dedutíveis","",""})
    aAdd(aCodTrb,{'111222221',"Despesas de arrendamento em relação ao valor residual do bem","LC 214/2025 Art. 201, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das despesas com arrendamento mercantil financeiro, oriunda de operações realizadas pessoas físicas ou jurídicas não contribuintes do IBS e da CBS do Regime Regular, comprovadas mediante a emissão de documentos fiscais."})
    aAdd(aCodTrb,{'11122223',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'111222231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'111222232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11122224',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'111222241',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'111222242',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'112',"ARRANJOS DE PAGAMENTO","",""})
    aAdd(aCodTrb,{'1121',"VALORES TRIBUTADOS POR PREÇO OU COMISSÃO","",""})
    aAdd(aCodTrb,{'11211',"Valores Recebidos Tributáveis","",""})
    aAdd(aCodTrb,{'112111',"Valores Recebidos do Credenciado","",""})
    aAdd(aCodTrb,{'112111001',"Taxa de desconto nas transações (MDR) recebida","LC 214/2025 Art. 214, §1º, I",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos à taxa cobrada dos credenciados (MDR - Merchant Discount Rate) para a realização das operações, via meios de pagamento. Deve ser registrado o valor total recebido pela credenciadora ou subcredenciadora, ainda que parte desse valor seja direcionado a outros participantes do arranjo."})
    aAdd(aCodTrb,{'112111002',"Demais bens e serviços fornecidos ao credenciado","LC 214/2025 Art. 214, §1º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos aos demais bens ou serviços fornecidos ao credenciado relacionados aos serviços de arranjos de pagamento."})
    aAdd(aCodTrb,{'112111003',"Recebimento por locação de terminais eletrônicos e software","LC 214/2025 Art. 214, §1º, II",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos à locação de terminais eletrônicos, bem como softwares ou outros instrumentos tecnológicos fornecidos ao credenciado pelas credenciadoras ou subcredenciadoras."})
    aAdd(aCodTrb,{'112111004',"Valor recebido do exterior (não considerado exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores residuais recebidos, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'112112',"Recebidos de outro participante do arranjo","",""})
    aAdd(aCodTrb,{'112112001',"Tarifa de intercâmbio recebida","LC 214/2025 Art. 214, §3º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos à tarifa de intercâmbio recebida pelos emissores de cartões."})
    aAdd(aCodTrb,{'112112002',"Taxa de royalties ou outros valores recebidos pelo instituidor","LC 214/2025 Art. 214, §3º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos à taxa de royalties recebida pelos instituidores dos arranjos de pagamento."})
    aAdd(aCodTrb,{'112112003',"Bens e serviços fornecidos pelos instituidores aos demais participantes do arranjo","LC 214/2025 Art. 214, §1º, III",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos pelos instituidores dos arranjos de pagamento relativos ao fornecimento de bens ou serviços aos demais participantes do arranjo."})
    aAdd(aCodTrb,{'112112004',"Bens e serviços importados das bandeiras de cartões pelos instituidores e participantes do arranjo","LC 214/2025 Art. 214, §1º, IV",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos a bens e serviços importados das bandeiras de cartões pelos instituidores e demais participantes dos arranjos de pagamento."})
    aAdd(aCodTrb,{'112112005',"Valor recebido do exterior (não considerado exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores residuais recebidos, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'11212',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'112120001',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'112120002',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'11213',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'112130001',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'112130002',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'1122',"VALORES TRIBUTADOS POR MARGEM","",""})
    aAdd(aCodTrb,{'11221',"Antecipação de recebíveis","",""})
    aAdd(aCodTrb,{'112211',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'112211001',"Valor de desconto aplicado na operação","LC 214/2025 Art. 219",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos à taxa de desconto cobrada em operações de antecipação de recebíveis."})
    aAdd(aCodTrb,{'112212',"Valores dedutíveis","",""})
    aAdd(aCodTrb,{'1122121',"Despesas gerais","",""})
    aAdd(aCodTrb,{'112212101',"Curva de juros futuros da taxa DI - mercado interno","LC 214/2025 Art. 219, §1º",;
    "Classificar nesse código o valor total das taxas DI aplicadas às operações de antecipação de recebíveis, de acordo com o prazo do desconto aplicado a cada operação realizada com clientes nacionais. Trata-se de uma rubrica extracontábil, apenas para informação do valor total mensal a ser deduzido da base de cálculo dessas operações. Para tanto, deve ser incluída no evento do Plano de Contas e no Balancete Contábil-Fiscal uma rubrica com algarismos 9 (nove), tantos quantos forem necessários para a máscara do plano de contas interno usado pela empresa."})
    aAdd(aCodTrb,{'112212102',"Perdas incorridas no recebimento de créditos, concessão de descontos - mercado interno","LC 214/2025 Art. 219, §2º",;
    "Classificar nesse código as rubricas contábeis onde estão registradas as perdas no recebimento de créditos, na cessão de créditos ou na concessão de descontos, em operações do mercado interno."})
    aAdd(aCodTrb,{'1122122',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'112212201',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'112213',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'112213001',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'112213002',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'11222',"Receita financeira em contas de pagamento","",""})
    aAdd(aCodTrb,{'112221',"Valores tributáveis recebidos","",""})
    aAdd(aCodTrb,{'112221001',"Receita auferida nas contas de pagamento","LC 214/2025 Art. 214, §5º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas financeiras auferidas em decorrência da aplicação de recursos em contas de pagamento."})
    aAdd(aCodTrb,{'112222',"Valores dedutíveis","",""})
    aAdd(aCodTrb,{'1122221',"Despesas gerais","",""})
    aAdd(aCodTrb,{'112222101',"Valores pagos como remuneração das contas de pagamento","LC 214/2025 Art. 214, §5º",;
    "Classificar nesse código as rubricas contábeis representativas dos valore pagos aos titulares das contas de pagamento como remuneração pelo valor aplicado."})
    aAdd(aCodTrb,{'1122222',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'112222201',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'112223',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'112223001',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'112223002',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'113',"SEGUROS, RESSEGUROS, PREVIDÊNCIA COMPLEMENTAR E CAPITALIZAÇÃO","",""})
    aAdd(aCodTrb,{'1131',"SEGUROS DE RAMOS ELEMENTARES E SEGUROS DE PESSOAS SEM COBERTURA POR SOBREVIVÊNCIA","",""})
    aAdd(aCodTrb,{'11311',"Operações com contribuintes do Regime Regular do","",;
    "IBS/CBS"})
    aAdd(aCodTrb,{'113111',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'113111001',"Prêmios de seguros, cosseguros, resseguros e retrocessão recebidos","LC 214/2025 Art. 223, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores dos prêmios de seguros, cosseguros, resseguros e retrocessão recebidos de contribuintes do regime regular do IBS e da CBS, que terão direito a crédito dos tributos."})
    aAdd(aCodTrb,{'113111002',"Reversão de provisões ou reserva técnica retida pela entidade como receita","LC 214/2025 Art. 223, § 3º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de reversão de provisões, que foram deduzidas da base de cálculo quando de sua constituição, ou a reserva técnica retida pela entidade como receita própria."})
    aAdd(aCodTrb,{'113111003',"Valor recebido do exterior (não considerado exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores residuais recebidos, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'113112',"Valores a deduzir","",""})
    aAdd(aCodTrb,{'1131121',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'113112101',"Valor pago referente a restituições de prêmios","LC 214/2025 Art. 223, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das restituições de prêmios pagas a segurados."})
    aAdd(aCodTrb,{'113112102',"Valor pago relativo a serviços de intermediação de seguros individualizável a cada prêmio emitido","LC 214/2025 Art. 223, II, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação de seguros, que seja individualizável a cada prêmio recebido e comprovados por meio de documento fiscal idôneo, emitido pelo intermediador (corretor de seguros)."})
    aAdd(aCodTrb,{'113112103',"Valor pago referente ao prêmio nas operações de cosseguro cedido","LC 214/2025 Art. 223, II, d",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos relativos aos prêmios nas operações de cosseguro cedido."})
    aAdd(aCodTrb,{'113112104',"Parcela dos prêmios usada para provisões ou reservas técnicas referentes a seguro resgatável","LC 214/2025 Art. 223, II, e",;
    "Classificar nesse código as rubricas contábeis representativas dos valores da parcela dos prêmios usada para provisões ou reservas técnicas, referente a seguro resgatável."})
    aAdd(aCodTrb,{'1131122',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'113112201',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'113113',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'113113001',"Valores recebidos de resseguro e retrocessão (sujeitos à alíquota zero)","LC 214/2025 Art. 223, §4º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos em relação a resseguro e retrocesso, que são sujeitos a alíquota zero."})
    aAdd(aCodTrb,{'113113002',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'113113003',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'113114',"Valores pagos não dedutíveis","",""})
    aAdd(aCodTrb,{'113114001',"Despesas com indenizações pagas a segurados contribuintes do regime regular do IBS/CBS","LC 214/2025 Art. 223, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de indenizações pagas a segurados contribuintes do regime regular do IBS e da CBS que não serão deduzidas da base de cálculo."})
    aAdd(aCodTrb,{'113114002',"Valor pago relativo a serviços de intermediação de seguros não individualizável a cada prêmio emitido","",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos a corretores de seguros, mas que não sejam vinculados ao valor do prêmio. Por exemplo: Valores pagos por atingimento de metas de vendas de seguros. Nessa hipótese o contribuinte poderá se creditar do valor constante no documento fiscal."})
    aAdd(aCodTrb,{'11312',"Operações com não contribuintes do Regime Regular do IBS/CBS","",""})
    aAdd(aCodTrb,{'113121',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'113121001',"Prêmios de seguros, cosseguros, resseguros e retrocessão recebidos","LC 214/2025 Art. 223, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores dos prêmios de prêmios de seguros, cosseguros, resseguros e retrocessão recebidos de contribuintes não optantes pelo regime regular do IBS e da CBS, que não terão direito a crédito dos tributos."})
    aAdd(aCodTrb,{'113121002',"Valores de salvados recebidos","LC 214/2025 Art. 223, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores dos salvados recebidos em relação a sinistros efetivamente pagos a clientes que não sejam contribuintes do Regime Regular do IBS e da CBS."})
    aAdd(aCodTrb,{'113121003',"Valores de ressarcimentos recebidos","LC 214/2025 Art. 223, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores dos ressarcimentos recebidos em relação a sinistros efetivamente pagos a clientes que não sejam contribuintes do Regime Regular do IBS e da CBS."})
    aAdd(aCodTrb,{'113121004',"Reversão de provisões ou reserva técnica retida pela entidade como receita","LC 214/2025 Art. 223, § 3º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de reversão de provisões, que foram deduzidas da base de cálculo quando de sua constituição, ou a reserva técnica retida pela entidade como receita própria."})
    aAdd(aCodTrb,{'113121005',"Valor recebido do exterior (não considerado exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores residuais recebidos, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'113122',"Valores dedutíveis","",""})
    aAdd(aCodTrb,{'1131221',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'113122101',"Indenizações pagas diretamente a segurados não contribuintes do regime regular do IBS/CBS","LC 214/2025 Art. 223, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de indenizações pagas a segurados não contribuintes do regime regular do IBS e da CBS que poderão ser deduzidas da base de cálculo."})
    aAdd(aCodTrb,{'113122102',"Outras indenizações por meio do pagamento de bens ou serviços a segurados não contribuintes do regime regular do IBS/CBS","LC 214/2025 Art. 223, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos por bens ou serviços pagos para fins de indenizações a segurados não contribuintes do regime regular do IBS e da CBS que poderão ser deduzidas da base de cálculo e que sejam comprovadas por meio de documento fiscal idôneo. Exemplo: Pagamento de oficina mecânica para conserto de veículo objeto de sinistro."})
    aAdd(aCodTrb,{'113122103',"Valor pago referente a restituições de prêmios","LC 214/2025 Art. 223, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das restituições de prêmios pagas a segurados."})
    aAdd(aCodTrb,{'113122104',"Valor pago relativo a serviços de intermediação de seguros individualizável a cada prêmio emitido","LC 214/2025 Art. 223, II, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação de seguros, mediante a comprovação por meio de documento fiscal idôneo."})
    aAdd(aCodTrb,{'113122105',"Valor pago referente ao prêmio nas operações de cosseguro cedido","LC 214/2025 Art. 223, II, d",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos relativos aos prêmios nas operações de cosseguro cedido."})
    aAdd(aCodTrb,{'113122106',"Parcela dos prêmios usada para provisões ou reservas técnicas referentes a seguro resgatável","LC 214/2025 Art. 223, II, e",;
    "Classificar nesse código as rubricas contábeis representativas dos valores da parcela dos prêmios usada para provisões ou reservas técnicas, referente a seguro resgatável."})
    aAdd(aCodTrb,{'1131222',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'113122201',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'113123',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'113123001',"Valores recebidos de resseguro e retrocessão (sujeitos à alíquota zero)","LC 214/2025 Art. 223, §4º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos em relação a resseguro e retrocesso, que são sujeitos a alíquota zero."})
    aAdd(aCodTrb,{'113123002',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'113123003',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'113124',"Ativos garantidores de provisões técnicas","",""})
    aAdd(aCodTrb,{'113124001',"Ativos garantidores vinculados a provisões técnicas","LC 214/2025 Art. 223, I, b",;
    "Classificar nesse código as rubricas contábeis representativas dos ativos garantidores de provisões técnicas. Os valores tributaveis serão apurados no Evento D-1106 e para apuração da base de cálculo que sofrerá incidência tributária, será feita a proporcionalização do valor das receitas dos prêmios de seguros relativos a não contribuintes do regime regular, em relação ao total das receitas com prêmios de seguros, em atenção à disposição legal."})
    aAdd(aCodTrb,{'1132',"SEGURO DE PESSOAS COM COBERTURA POR SOBREVIVÊNCIA","",""})
    aAdd(aCodTrb,{'11321',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'113210001',"Prêmios recebidos de seguros de pessoas com cobertura por sobrevivência","LC 214/2025 Art. 224, I, b",;
    "Classificar nesse código as rubricas contábeis representativas dos prêmios dos seguros de pessoas com cobertura por sobrevivência."})
    aAdd(aCodTrb,{'113210002',"Encargo do fundo decorrente de estruturação e manutenção","LC 214/2025 Art. 224, I, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos a encargo de fundo decorrentes de estruturação e manutenção."})
    aAdd(aCodTrb,{'113210003',"Reversão de provisões ou reserva técnica retida pela entidade como receita","LC 214/2025 Art. 224, §1º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de reversão de provisões, que foram deduzidas da base de cálculo quando de sua constituição, ou a reserva técnica retida pela entidade como receita própria."})
    aAdd(aCodTrb,{'113210004',"Receitas financeiras sobre o excedente de ativos garantidores de reservas técnicas","LC 214/2025 Art. 224, § 3º, I",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das receitas financeiras recebidas, que excederem o limite dos ativos garantidores de reservas técnicas."})
    aAdd(aCodTrb,{'113210005',"Valor recebido do exterior (não considerado exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores residuais recebidos, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'11322',"Valores a deduzir","",""})
    aAdd(aCodTrb,{'113221',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'113221001',"Parcela dos prêmios para constituição de provisões ou reservas técnicas","LC 214/2025 Art. 224, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores utilizados para constituição de provisões ou reservas técnicas."})
    aAdd(aCodTrb,{'113221002',"Valores pagos a restituições de prêmios","LC 214/2025 Art. 224, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela restituição de prêmios de seguros de pessoas com cobertura por sobrevivência."})
    aAdd(aCodTrb,{'113221003',"Valor pago relativo a serviços de intermediação de seguros individualizável a cada prêmio emitido","LC 214/2025 Art. 224, II, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação na venda de seguros, devidamente comprovados por meio de documento fiscal idôneo."})
    aAdd(aCodTrb,{'113222',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'113222004',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'11323',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'113230001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'113230002',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Arts. 271 e 272",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'113230003',"Rendimentos de aplicações de recursos destinados ao pagamento de resgastes.","LC 214/2025 Art. 224, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas financeiras recebidas auferidas sobre recursos destinados ao pagamento de resgastes de seguros com cobertura por sobrevivência."})
    aAdd(aCodTrb,{'113230004',"Receitas financeiras sobre ativos garantidores de reservas técnicas, limitadas ao montante das provisões","LC 214/2025 Art. 224, § 3º, I",;
    "Classificar nesse código as rubricas contábeis representativas das receitas financeiras recebidas, que não excederem o limite dos ativos garantidores de reservas técnicas."})
    aAdd(aCodTrb,{'113230005',"Rendimentos dos ativos garantidores de provisões técnicas","LC 214/2025 Art. 224, §3º, II",;
    "Classificar nesse código as rubricas contábeis representativas dos rendimentos de ativos garantidores de provisões técnicas destinados exclusivamente a seguros de pessoas com cobertura por sobrevivência."})
    aAdd(aCodTrb,{'113230006',"Demais rendimentos de aplicações financeiras","LC 214/2025 Art. 224, § 4º",;
    "Classificar nesse código as rubricas contábeis representativas das demais receitas financeiras recebidas."})
    aAdd(aCodTrb,{'1133',"PREVIDÊNCIA COMPLEMENTAR","",""})
    aAdd(aCodTrb,{'11331',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'113310001',"Contribuições para planos de previdência complementar","LC 214/2025 Art. 224, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das contribuições para planos de Previdência Complementar recebidas."})
    aAdd(aCodTrb,{'113310002',"Encargo do fundo decorrente de estruturação e manutenção","LC 214/2025 Art. 224, I, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos relativos a encargo de fundo decorrentes de estruturação e manutenção."})
    aAdd(aCodTrb,{'113310003',"Reversão de provisões ou reserva técnica retida pela entidade como receita","LC 214/2025 Art. 224, §1º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de reversão de provisões, que foram deduzidas da base de cálculo quando de sua constituição, ou a reserva técnica retida pela entidade como receita própria."})
    aAdd(aCodTrb,{'113310004',"Receitas financeiras sobre o excedente de ativos garantidores de reservas técnicas","LC 214/2025 Art. 224, § 3º, I",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das receitas financeiras recebidas, que excederem o limite dos ativos garantidores de reservas técnicas."})
    aAdd(aCodTrb,{'113310005',"Valor recebido do exterior (não considerado exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores residuais recebidos, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'11332',"Valores a deduzir","",""})
    aAdd(aCodTrb,{'113321',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'113321001',"Parcela das contribuições para constituição de provisões ou reservas técnicas","LC 214/2025 Art. 224, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores utilizados para constituição de provisões ou reservas técnicas."})
    aAdd(aCodTrb,{'113321002',"Valores pagos a restituições de contribuições","LC 214/2025 Art. 224, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela restituição de contribuições de previdência complementar."})
    aAdd(aCodTrb,{'113321003',"Valores pagos a serviços de intermediação de previdência","LC 214/2025 Art. 224, II, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação de previdência complementar na venda desses produtos, devidamente comprovados por meio de documento fiscal idôneo."})
    aAdd(aCodTrb,{'113321004',"Valores de indenizações pagas por coberturas de risco em previdência complementar","LC 214/2025 Art. 224, II, d",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das indenizações pagas por cobertura de risco, correspondentes aos benefícios pagos em operações de previdência complementar."})
    aAdd(aCodTrb,{'113322',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'113322001',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'11333',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'113330001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'113330002',"Rendimentos de aplicações de recursos destinados ao pagamento de benefícios de aposentadoria, pensão, pecúlio e resgastes.","LC 214/2025 Art. 224, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas financeiras recebidas auferidas sobre recursos destinados ao pagamento de benefícios de aposentadoria, pensão, pecúlio e resgastes."})
    aAdd(aCodTrb,{'113330003',"Receitas financeiras sobre ativos garantidores de reservas técnicas, limitadas ao montante das provisões","LC 214/2025 Art. 224, §3º, I",;
    "Classificar nesse código as rubricas contábeis representativas das receitas financeiras recebidas, que não excederem o limite dos ativos garantidores de reservas técnicas."})
    aAdd(aCodTrb,{'113330004',"Rendimentos dos ativos garantidores de provisões técnicas","LC 214/2025 Art. 224, §3º, II",;
    "Classificar nesse código as rubricas contábeis representativas dos rendimentos de ativos garantidores de provisões técnicas destinados exclusivamente a planos de benefícios de caráter previdenciário."})
    aAdd(aCodTrb,{'113330005',"Demais rendimentos de aplicações financeiras","LC 214/2025 Art. 224, § 4º",;
    "Classificar nesse código as rubricas contábeis representativas das demais receitas financeiras recebidas."})
    aAdd(aCodTrb,{'1134',"CAPITALIZAÇÃO","",""})
    aAdd(aCodTrb,{'11341',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'113410001',"Arrecadação com os títulos de capitalização comercializados de forma online","LC 214/2025 Art. 225, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores arrecadados com os títulos de capitalização, que tenham sido comercializados de forma direta, sendo o adquirente identificado no momento da venda."})
    aAdd(aCodTrb,{'113410002',"Arrecadação com os títulos de capitalização comercializados de forma presencial","LC 214/2025 Art. 225, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores arrecadados com os títulos de capitalização, que tenham sido comercializados de forma presencial, por meio de pontos de vendas, onde os adquirentes somente são identificados em momento posterior à venda."})
    aAdd(aCodTrb,{'113410003',"Receitas com prescrição e penalidades","LC 214/2025 Art. 225, I, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das receitas auferidas com prescrição de títulos de capitalização vencidos e não resgatados ou penalidades aplicadas."})
    aAdd(aCodTrb,{'113410004',"Reversão de provisões ou reserva técnica retida pela entidade como receita","LC 214/2025 Art. 225, § 1º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de reversão de provisões, que foram deduzidas da base de cálculo quando de sua constituição, ou a reserva técnica retida pela entidade como receita própria."})
    aAdd(aCodTrb,{'113410005',"Receitas financeiras sobre o excedente de ativos garantidores de reservas técnicas","LC 214/2025 Art. 225, § 3º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das receitas financeiras recebidas, que excederem o limite dos ativos garantidores de reservas técnicas."})
    aAdd(aCodTrb,{'113410006',"Valor recebido do exterior (não considerado exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores residuais recebidos, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'11342',"Valores a deduzir","",""})
    aAdd(aCodTrb,{'113421',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'113421001',"Parcela das contribuições para constituição de provisões ou reservas técnicas, inclusive sorteios a pagar","LC 214/2025 Art. 225, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores utilizados para constituição de provisões ou reservas técnicas, inclusive as provisões de sorteios a pagar."})
    aAdd(aCodTrb,{'113421002',"Valores pagos por cancelamento e restituições de títulos","LC 214/2025 Art. 225, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos por cancelamentos ou restituições de títulos de capitalização."})
    aAdd(aCodTrb,{'113421003',"Valores pagos relativos a serviços de intermediação na venda de títulos de capitalização, individualizável a cada título emitido","LC 214/2025 Art. 225, II, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação na venda de títulos de capitalização, devidamente comprovados por meio de documento fiscal idôneo."})
    aAdd(aCodTrb,{'113422',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'113422004',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'11343',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'113430001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'113430002',"Rendimentos de aplicações de recursos destinados ao pagamento de resgates de títulos e sorteios","LC 214/2025 Art. 225, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas financeiras recebidas auferidas sobre recursos destinados ao pagamento de resgastes de títulos e sorteios"})
    aAdd(aCodTrb,{'113430003',"Receitas financeiras sobre ativos garantidores de reservas técnicas, limitadas ao montante das provisões","LC 214/2025 Art. 225, § 3º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas financeiras recebidas, que não excederem o limite dos ativos garantidores de reservas técnicas."})
    aAdd(aCodTrb,{'113430004',"Demais rendimentos de aplicações financeiras","LC 214/2025 Art. 225, § 4º",;
    "Classificar nesse código as rubricas contábeis representativas das demais receitas financeiras recebidas."})
    aAdd(aCodTrb,{'114',"ADMINISTRAÇÃO DE CONSÓRCIOS","",""})
    aAdd(aCodTrb,{'1141',"Valores recebidos tributáveis","",""})
    aAdd(aCodTrb,{'114100001',"Receitas recebidas em função da administração de consórcios","LC 214/2025 Art. 204, caput",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos a título de taxa de administração, outros valores cobrados como tarifas ou comissões, bem como os encargos, multa e juros decorrentes dos contratos de grupos de consórcios."})
    aAdd(aCodTrb,{'1142',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'114200001',"Valores pagos pela intermediação de consórcio, individualizável a cada cota de consórcio","LC 214/2025 Art. 204, §1º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação na venda de cotas de consórcio, individualizável a cada cota de consórcio e devidamente comprovado por meio de documento fiscal idôneo, emitido pelo intermediador."})
    aAdd(aCodTrb,{'1143',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'114300001',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'114300002',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'1144',"Valores pagos não dedutíveis","",""})
    aAdd(aCodTrb,{'114400001',"Valor pago relativo a serviços de intermediação não individualizável a cada cota de consórcio","",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação na venda de cotas de consórcio, mas que não sejam vinculados ao valor da cota de consórcio. Por exemplo: Valores pagos por atingimento de metas de vendas. Nessa hipótese o contribuinte poderá se creditar do valor constante no documento fiscal."})
    aAdd(aCodTrb,{'1145',"Valores recebidos não tributáveis","",""})
    aAdd(aCodTrb,{'114500001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas valores recebidos, que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'119',"OUTROS ATIVOS","",""})
    aAdd(aCodTrb,{'119000001',"Outras contas de Ativo Circulante","",;
    "Classificar nesse código as demais rubricas contábeis do Ativo Circulante, não classificadas anteriormente."})
    aAdd(aCodTrb,{'119000002',"Contas de Ativo Não circulante","",;
    "Classificar nesse código as rubricas contábeis do Ativo Não Circulante."})
    aAdd(aCodTrb,{'2',"PASSIVO e PL","",""})
    aAdd(aCodTrb,{'21',"SERVIÇOS FINANCEIROS","",""})
    aAdd(aCodTrb,{'210000001',"Contas do Passivo Circulante","",;
    "Classificar nesse código as rubricas contábeis pertencentes ao grupo do Passivo Circulante."})
    aAdd(aCodTrb,{'210000002',"Contas do Passivo Não Circulante","",;
    "Classificar nesse código as rubricas contábeis pertencentes ao grupo do Passivo Não Circulante."})
    aAdd(aCodTrb,{'210000003',"Contas do Patrimônio Líquido","",;
    "Classificar nesse código as rubricas contábeis pertencentes ao grupo do Patrimônio Líquido."})
    aAdd(aCodTrb,{'3',"RECEITAS","",""})
    aAdd(aCodTrb,{'31',"SERVIÇOS FINANCEIROS","",""})
    aAdd(aCodTrb,{'311',"REGIMES ESPECÍFICOS","",""})
    aAdd(aCodTrb,{'3111',"RECEITAS TRIBUTÁVEIS","",""})
    aAdd(aCodTrb,{'311101',"Crédito, Câmbio e TVM","",""})
    aAdd(aCodTrb,{'3111011',"Apuração por margem","",""})
    aAdd(aCodTrb,{'311101101',"Operações de Crédito","LC 214/2025 Art. 182, I",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas em operações de crédito. Incluir nesse código as tarifas e comissões que forem contabilizadas pelo método da TJEO – Taxa de Juros Efetiva da Operação, nos termos de regulamentação do BCB."})
    aAdd(aCodTrb,{'311101102',"Operações de Câmbio","LC 214/2025 Art. 182, II",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas em operações de câmbio, incluindo tarifas cobradas nestas operações."})
    aAdd(aCodTrb,{'311101103',"Operações com aquisição, negociação e liquidação de TVM","LC 214/2025 Art. 182, III",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas à aquisição, negociação e liquidação, assim considerada a diferença entre o valor do ativo e o custo de aquisição nas alienações de títulos e valores mobiliários."})
    aAdd(aCodTrb,{'311101104',"Serviços de custódia, corretagem, distribuição e outras formas de intermediação de TVM","LC 214/2025 Art. 182, III",;
    "Classificar nesse código as rubricas contábeis representativas das receitas de comissões auferidas relativas aos serviços de custódia, corretagem, distribuição e outras formas de intermediação de títulos e valores mobiliários, quando prestados por bancos múltiplos ou bancos comerciais."})
    aAdd(aCodTrb,{'311101105',"Operações com títulos de dívidas - sem oferta pública","LC 214/2025 Art. 195, caput",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas em operações com títulos de dívida sem oferta pública."})
    aAdd(aCodTrb,{'311101106',"Recuperação de crédito baixado como prejuízo","LC 214/2025 Art. 186",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com recuperação de créditos que tenham sido baixados como prejuízo."})
    aAdd(aCodTrb,{'311101107',"Estorno de encargos financeiros registrados no patrimônio líquido","LC 214/2025 Art. 192, § 3º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas relativas a estorno de encargos financeiros registrados no patrimônio líquido da entidade."})
    aAdd(aCodTrb,{'311101108',"Excesso rendimento em função de avaliação a valor justo","LC 214/2025 Art. 192, § 6º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas a excesso de rendimentos auferidos em função de registro contábil de avaliação a valor justo."})
    aAdd(aCodTrb,{'311101109',"Desconto condicional concedido","LC 214/2025 Art. 12, §1º, III",;
    "Classificar nesse código as rubricas contábeis representativas dos descontos condicionais concedidos, assim entendidos aqueles que dependem de condição de relacionamento do cliente com a instituição para sua concessão."})
    aAdd(aCodTrb,{'311101110',"Receita oriunda do exterior, não considerada exportação","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas com operações de crédito, câmbio ou com TVM, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'311101111',"Ajuste para recomposição da receita (custos e despesas TJEO)","Res. CMN 4966/2023 Art. 15",;
    "Classificar nesse código as rubricas contábeis representativas dos custos e despesas vinculados a operações de crédito, que forem registrados contabilmente como dedução das receitas, em obediência às regras instituídas pelo Banco Central do Brasil, para registro com base na TJEO – Taxa de Juros Efetiva da Operação."})
    aAdd(aCodTrb,{'311101112',"Receitas (líquidas das despesas) com derivativos contratados","LC 214/2025 Art. 192, §7º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas com derivativos contratados, já subtraídas as despesas a eles vinculadas."})
    aAdd(aCodTrb,{'311101113',"Valores recebidos da administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas recebidas com operações de crédito, câmbio ou com TVM, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dá no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'311101114',"Tarifas e comissões acessórias","LC 214/2025 Art. 7º, II",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com tarifas e comissões consideradas acessórias à operação principal de crédito, câmbio ou TVM. Incluir nesse código as tarifas que tenham sido contabilizadas de forma segregada, nos termos de regulamentação específica do Banco Central do Brasil."})
    aAdd(aCodTrb,{'3111012',"Apuração com títulos de dívida","",""})
    aAdd(aCodTrb,{'311101201',"Operações com títulos de dívidas - com oferta pública","LC 214/2025 Art. 195, § 1º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com títulos de dívidas adquiridos em oferta pública."})
    aAdd(aCodTrb,{'311101202',"Operações com títulos de dívidas - fundo de investimento exclusivo","LC 214/2025 Art. 195, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com títulos de dívidas adquiridos por meio de fundo de investimento exclusivo, cuja carteira seja composta por, no mínimo, 95% (noventa e cinco por cento) desses títulos."})
    aAdd(aCodTrb,{'311102',"Securitização e Faturização","",""})
    aAdd(aCodTrb,{'311102001',"Operações com securitização - Desconto aplicado","LC 214/2025 Art. 192, IV",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com o desconto aplicado em operações de securitização."})
    aAdd(aCodTrb,{'311102002',"Operações de faturização - Desconto aplicado","LC 214/2025 Art. 192, V",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com o desconto aplicado em operações de faturização."})
    aAdd(aCodTrb,{'311102003',"Receita tributável (não considerada exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas com operações de securitização ou faturização, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'311102004',"Valores recebidos da administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas recebidas com securitização ou faturização, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dá no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'311103',"Gestão e Adm. de Recursos, inclusive Fundos de Investimento","",""})
    aAdd(aCodTrb,{'311103001',"Taxa de administração e gestão serviços prestados ao Fundo de investimento","LC 214/2025 Art. 207",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas relativas a taxas de administração ou de gestão para serviços prestados aos fundos de investimento."})
    aAdd(aCodTrb,{'311103002',"Taxa de administração e gestão serviços prestados ao investidor","LC 214/2025 Art. 211",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas relativas a taxas de administração ou de gestão para serviços prestados aos investidores."})
    aAdd(aCodTrb,{'311104',"FGTS - Serviços prestados pelos agentes financeiros","",""})
    aAdd(aCodTrb,{'3111041',"Serviços prestados ao FGTS","",""})
    aAdd(aCodTrb,{'311104101',"Remunerados por preço fixo ou comissão","LC 214/2025 Art. 212",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com tarifas ou comissões relativas aos serviços prestados ao FGTS."})
    aAdd(aCodTrb,{'311104102',"Serviços de administração ou gestão de fundos","LC 214/2025 Art. 207",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas relativas a taxas de administração ou gestão para serviços prestados ao FGTS."})
    aAdd(aCodTrb,{'3111042',"Operações de Crédito com recursos do FGTS","LC 214/2025 Art. 212, §2º",""})
    aAdd(aCodTrb,{'311104201',"Operações de Crédito","LC 214/2025 Art. 182, I",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas em operações de crédito, com recursos do FGTS. Incluir nesse código as tarifas e comissões que forem contabilizadas pelo método da TJEO – Taxa de Juros Efetiva da Operação, nos termos da regulamentação específica do Banco Central do Brasil."})
    aAdd(aCodTrb,{'311104202',"Recuperação de crédito baixado como prejuízo","LC 214/2025 Art. 186",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com recuperação de créditos que tenham sido baixados como prejuízo, em operações com recursos do FGTS."})
    aAdd(aCodTrb,{'311104203',"Estorno de encargos financeiros registrados no patrimônio líquido","LC 214/2025 Art. 192, § 3º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas relativas a estorno de encargos financeiros registrados no patrimônio líquido da entidade, em operações com recursos do FGTS."})
    aAdd(aCodTrb,{'311104204',"Excesso rendimento em função de avaliação a valor justo","LC 214/2025 Art. 192, § 6º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas a excesso de rendimentos auferidos em função de registro contábil de avaliação a valor justo, em operações com recursos do FGTS."})
    aAdd(aCodTrb,{'311104205',"Receitas (líquidas das despesas) com derivativos contratados","LC 214/2025 Art. 192, §7º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas com derivativos contratados, já subtraídas as despesas a eles vinculadas, em operações com recursos do FGTS."})
    aAdd(aCodTrb,{'311104206',"Desconto condicional concedido","LC 214/2025 Art. 12, §1º, III",;
    "Classificar nesse código as rubricas contábeis representativas dos descontos condicionais concedidos, assim entendidos aqueles que dependem de condição de relacionamento do cliente com a instituição para sua concessão."})
    aAdd(aCodTrb,{'311104207',"Ajuste para recomposição da receita (custos e despesas TJEO)","Res. CMN 4966/2023 Art. 15",;
    "Classificar nesse código as rubricas contábeis representativas dos custos e despesas vinculados a operações de crédito, que forem registrados contabilmente como dedução das receitas, em obediência às regras instituídas pelo Banco Central do Brasil, para registro com base na TJEO – Taxa de Juros Efetiva da Operação."})
    aAdd(aCodTrb,{'311104208',"Valores recebidos da administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas recebidas com operações de crédito com recursos do FGTS, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dá no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'311104209',"Tarifas e comissões acessórias","LC 214/2025 Art. 7º, II",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com tarifas e comissões consideradas acessórias à operação principal de crédito com recursos do FGTS, mas que tenham sido contabilizadas de forma segregada, nos termos de regulamentação específica do Banco Central do Brasil. Por exemplo, tarifa de avaliação de crédito, embora seja considerada acessória à operação de crédito, tenha sido contabilizada no grupo de 717 – Receita de Serviços do COSIF."})
    aAdd(aCodTrb,{'311105',"Serviços de Ativos Virtuais","",""})
    aAdd(aCodTrb,{'311105001',"Receita com serviços remunerados por preço fixo ou comissão","LC 214/2025 Art. 229 caput",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com tarifas ou comissões cobradas em operações de ativos virtuais."})
    aAdd(aCodTrb,{'311105002',"Receita oriunda do exterior (não considerada exportação)","LC 214/2025 Art. 232, § 2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas com operações de securitização ou faturização, que sejam provenientes de residentes no exterior, mas que não sejam consideradas exportação de serviços, sendo, portanto, tributáveis para o IBS/CBS."})
    aAdd(aCodTrb,{'311105003',"Valores recebidos da administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas recebidas com securitização ou faturização, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dá no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'311106',"Intermediação de Negócios","",""})
    aAdd(aCodTrb,{'311106001',"Serviços de intermediação de consórcios","LC 214/2025 Art. 206",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com serviços de intermediação na venda de cotas de consórcios, prestados por instituições financeiras, que são obrigadas à entrega da DeRE."})
    aAdd(aCodTrb,{'311106002',"Serviços de intermediação seguros de ramos elementares e sem cobertura de sobrevivência e resseguros","LC 214/2025 Art. 228",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com serviços de intermediação na venda de seguros ou resseguros, prestados por instituições financeiras, que são obrigadas à entrega da DeRE."})
    aAdd(aCodTrb,{'311106003',"Serviços de intermediação de títulos de capitalização","LC 214/2025 Art. 228",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com serviços de intermediação na venda de títulos de capitalização, prestados por instituições financeiras, que são obrigadas à entrega da DeRE."})
    aAdd(aCodTrb,{'311106004',"Serviços de intermediação de previdência complementar e seguros com cobertura de sobrevivência","LC 214/2025 Art. 228",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com serviços de intermediação na venda de previdência complementar, prestados por instituições financeiras, que são obrigadas à entrega da DeRE."})
    aAdd(aCodTrb,{'311107',"Adm. de Mercados Organizados, Infraestruturas de Mercado e Depositárias Centrais","",""})
    aAdd(aCodTrb,{'311107001',"Serviços prestados por administradoras de mercados organizados, infraestruturas de Mercado e Depositárias Centrais","LC 214/2025 Art. 220",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com serviços prestados por administradoras de mercados organizados, infraestruturas de Mercado e Depositárias Centrais"})
    aAdd(aCodTrb,{'311108',"Administração de Programas de Fidelização","",""})
    aAdd(aCodTrb,{'311108001',"Valor dos pontos emitidos","LC 214/2025 Art. 219-A, I",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com pontos emitidos nos programas de fidelidade."})
    aAdd(aCodTrb,{'311109',"Operações de proteção patrimonial mutualista","",""})
    aAdd(aCodTrb,{'311109001',"Receitas das operações de proteção patrimonial mutualista","LC 214/2025 Art. 182, XVII",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas nos serviços de proteção mutualista."})
    aAdd(aCodTrb,{'311110',"Tarifas não acessórias","",""})
    aAdd(aCodTrb,{'311110001',"Vinculadas a operações com recursos do FGTS","LC 214/2025 Art. 198",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com tarifas e comissões consideradas não acessórias à operação principal de crédito com recursos do FGTS. Por exemplo: tarifa de Intermediação do FGTS para aquisição de Moradia, que embora tenha relação com a operação principal, é cobrada de forma autônoma, ou serviços remunerados mediante comissão, casos em que serão tributados pelo valor efetivamente cobrado."})
    aAdd(aCodTrb,{'311110002',"Vinculadas a operações de crédito, câmbio ou TVM","LC 214/2025 Art. 198",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com tarifas e comissões consideradas não acessórias à operação principal, vinculadas a operações de crédito, câmbio e TVM. Por exemplo, tarifa de acompanhamento de contrato de crédito, de adiantamento a depositante etc."})
    aAdd(aCodTrb,{'3112',"RECEITA NÃO TRIBUTÁVEL","",""})
    aAdd(aCodTrb,{'311201',"Crédito, Câmbio e TVM","",""})
    aAdd(aCodTrb,{'311201001',"Receitas com operações sujeitas a alíquota zero do regime de Cooperativas","LC 214/2025 Art. 192, § 8º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'311201002',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311201003',"Reversão de provisão","LC 214/2025 Art. 186",;
    "Classificar nesse código as rubricas contábeis representativas das reversões de provisões que não tinham sido usadas como dedução da base cálculo, quando de sua constituição."})
    aAdd(aCodTrb,{'311201004',"Recuperação de crédito baixado como prejuízo","LC 214/2025 Art. 186",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com recuperação de créditos que tenham sido baixados como prejuízo."})
    aAdd(aCodTrb,{'311201005',"Receita tributada anteriormente","",;
    "Classificar nesse código as rubricas contábeis representativas das receitas que já tenham sido tributadas em período anterior."})
    aAdd(aCodTrb,{'311201006',"Desconto incondicional","LC 214/2025 Art. 12, §2º, III",;
    "Classificar nesse código as rubricas contábeis representativas dos descontos incondicionais concedidos, assim entendidos aqueles que não dependem de condição de relacionamento do cliente com a instituição para sua concessão."})
    aAdd(aCodTrb,{'311202',"Securitização e Faturização","",""})
    aAdd(aCodTrb,{'311202001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311203',"Gestão e Adm. de Recursos, inclusive Fundos de Investimento","",""})
    aAdd(aCodTrb,{'311203001',"Exportação de Serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311204',"FGTS - Serviços prestados pelos agentes financeiros","",""})
    aAdd(aCodTrb,{'311204001',"Serviços prestados pelo agente operador do FGTS - Alíquota zero","LC 214/2025 Art. 212, §3º, I",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas a serviços prestados ao FGTS, pelo agente operador do fundo."})
    aAdd(aCodTrb,{'311204002',"Serviços prestados a Fundos garantidores de políticas públicas (pertencente a único ente)","LC 214/2025 Art. 213",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas a serviços prestados aos fundos garantidores de políticas públicas, pertencente a único ente federativo."})
    aAdd(aCodTrb,{'311204003',"Serviços prestados a Fundos garantidores de políticas públicas (pertencente a mais de um ente)","LC 214/2025 Art. 213",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas a serviços prestados aos fundos garantidores de políticas públicas, pertencente a mais de um ente federativo."})
    aAdd(aCodTrb,{'311204004',"Serviços prestados a Fundos garantidores de políticas públicas (não dividido em cotas)","LC 214/2025 Art. 213",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas a serviços prestados aos fundos garantidores de políticas públicas, não dividido em cotas."})
    aAdd(aCodTrb,{'311204005',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311204006',"Receitas com operações sujeitas a alíquota zero do regime de Cooperativas","LC 214/2025 Art. 192, § 8º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'311205',"Serviços de Ativos Virtuais","",""})
    aAdd(aCodTrb,{'311205001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311206',"Intermediação de Negócios","",""})
    aAdd(aCodTrb,{'311206001',"Exportação de serviços - Intermediação de consõrcios","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311206002',"Exportação de serviços - Intermediação de seguros ramos element. e sem cobertura por sobrevivência","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311206003',"Exportação de serviços - Intermediação de capitalização","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311206004',"Exportação de serviços - Intermediação de seguros com cobertura por sobrevivência e previdência complementar","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311207',"Adm. de Mercados Organizados, Infraestruturas de","",;
    "Mercado e Depositárias Centrais"})
    aAdd(aCodTrb,{'311207001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311208',"Administração de Programas de Fidelização","",""})
    aAdd(aCodTrb,{'311208001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311208002',"Receitas com operações sujeitas a alíquota zero do regime de Cooperativas","LC 214/2025 Art. 192, § 8º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'311209',"Operações de proteção patrimonial mutualista","",""})
    aAdd(aCodTrb,{'311209001',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311209002',"Receitas com operações sujeitas a alíquota zero do regime de Cooperativas","LC 214/2025 Art. 192, § 8º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'311210',"Tarifas não acessórias","",""})
    aAdd(aCodTrb,{'3112101',"Tarifas ligadas a operações de Crédito, Câmbio e TVM","",""})
    aAdd(aCodTrb,{'311210101',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311210102',"Receitas com operações sujeitas a alíquota zero do regime de Cooperativas","LC 214/2025 Art. 192, § 8º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'3112102',"Tarifas ligadas a operações com recursos do FGTS","",""})
    aAdd(aCodTrb,{'311210201',"Exportação de serviços","LC 214/2025 Art. 232",;
    "Classificar nesse código as rubricas contábeis representativas receitas que sejam provenientes de residentes no exterior e atendam os requisitos legais para serem consideradas exportação de serviços. Incluir nesse código os valores relativos a tarifas e outros encargos vinculados aos referidos contratos."})
    aAdd(aCodTrb,{'311210202',"Receitas com operações sujeitas a alíquota zero do regime de Cooperativas","LC 214/2025 Art. 192, § 8º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'311211',"COMUNS A TODOS OS SUBRREGIMES","",""})
    aAdd(aCodTrb,{'311211001',"Outras receitas não tributáveis pelo IBS/CBS","LC 214/2025 Art. 6º",;
    "Classificar nesse código as rubricas contábeis representativas de outras receitas auferidas que não sejam tributáveis pelo IBS/CBS. Por exemplo, receitas financeiras quando não incluídas expressamente na base de cálculo; receita com doação recebida; etc, nos termos da legislação."})
    aAdd(aCodTrb,{'312',"OUTRAS RECEITAS","",""})
    aAdd(aCodTrb,{'3121',"RECEITAS TRIBUTADAS PELO REGIME DE CAIXA","",""})
    aAdd(aCodTrb,{'31211',"Administração de Consórcios","",""})
    aAdd(aCodTrb,{'312110001',"Receita com administração de consórcio apuradas para fins de tributação do SN","LC 123/2006",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com taxas de administração de consórcio e demais valores cobrados em relação aos contratos de consórcios, que servirão como base para cálculo dos demais tributos incluídos no Simples Nacional, pelas empresas optantes por esse regime."})
    aAdd(aCodTrb,{'31212',"Crédito, Câmbio e TVM","",""})
    aAdd(aCodTrb,{'312120001',"Serviços prestados à administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dará no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'31213',"Securitização e Faturização","",""})
    aAdd(aCodTrb,{'312130001',"Serviços prestados à administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dará no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'31214',"FGTS - Serviços prestados pelos agentes financeiros","",""})
    aAdd(aCodTrb,{'312140001',"Serviços prestados à administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dará no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'31215',"Serviços de Ativos Virtuais","",""})
    aAdd(aCodTrb,{'312150001',"Serviços prestados à administração pública tributadas pelo regime de caixa","LC 214/2025 Art. 10, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas, praticadas com a administração pública direta, autárquica ou fundacional, cuja tributação se dará no momento do efetivo recebimento."})
    aAdd(aCodTrb,{'3122',"RECEITAS COM EMISSÃO DE NOTAS FISCAIS","",""})
    aAdd(aCodTrb,{'312200001',"Receitas com alienação de bens imóveis que tenham sido objeto de garantia","LC 214/2025 Art. 200",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com alienação de bens imóveis, que tenham sido objeto de garantia, cuja propriedade tenha sido transmitida para pagamento de dívidas."})
    aAdd(aCodTrb,{'312200002',"Receitas com alienação de outros bens imóveis","",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com alienação de outros bens móveis ou imóveis."})
    aAdd(aCodTrb,{'313',"NORMAS GERAIS DE TRIBUTAÇÃO","",""})
    aAdd(aCodTrb,{'3131',"SERVIÇOS INFORMADOS E TRIBUTADOS PELA DERE","",""})
    aAdd(aCodTrb,{'313100001',"Tarifas cobradas em operações tipicamente bancárias","LC 214/2025 Art. 184",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas com tarifas e comissões prestados exclusivamente por instituições financeiras bancárias."})
    aAdd(aCodTrb,{'313100002',"Tarifas cobradas pelos emissores de cartões","LC 214/2025 Art. 214, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das receitas relativas a tarifas cobradas pelos bancos ou instituições de pagamento, emissores dos portadores dos cartões, que ficam sujeitas às regras gerais de tributação do IBS/CBS."})
    aAdd(aCodTrb,{'3132',"RECEITAS COM EMISSÃO DE NOTAS FISCAIS","",""})
    aAdd(aCodTrb,{'313200001',"Outras receitas acobertadas pela emissão de notas fiscais","",;
    "Classificar nesse código as rubricas contábeis representativas das receitas não operacionais, que ficam sujeitas às regras gerais de tributação do IBS/CBS, cuja comprovação se dê pela emissão de documento fiscal. Por exemplo, receita com venda de ativo imobilizado, estacionamento etc."})
    aAdd(aCodTrb,{'4',"DESPESAS","",""})
    aAdd(aCodTrb,{'41',"SERVIÇOS FINANCEIROS","",""})
    aAdd(aCodTrb,{'411',"DESPESAS DEDUTÍVEIS","",""})
    aAdd(aCodTrb,{'4111',"REGIMES ESPECÍFICOS","",""})
    aAdd(aCodTrb,{'411101',"CRÉDITO, CÂMBIO E TVM","",""})
    aAdd(aCodTrb,{'4111011',"Despesas de Captação","",""})
    aAdd(aCodTrb,{'411101101',"Despesa de captação de recursos","LC 214/2025 Art. 192, I",;
    "Classificar nesse código as despesas com captação de recursos. No caso de banco múltiplos, o sistema fará um rateio dessas despesas entre as atividades que tiverem previsão de dedução da referida despesa, nos termos do Art. 202 da LC 214/2025."})
    aAdd(aCodTrb,{'411101102',"Despesa de captação de cooperativas com recursos próprios, de cooperados ou recursos públicos","LC 214/2025 Art. 192, §8º",;
    "Classificar nesse código as despesas com captação de recursos junto a cooperados, optantes pelo regime regular do IBS/CBS, ou com recursos públicos ou, ainda, recursos próprios, no caso das cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico do Art. 271 da LC 214/2025, quando NÂO aplicados a cooperados contribuintes do regime regular do IBS/CBS."})
    aAdd(aCodTrb,{'4111012',"Demais despesas","",""})
    aAdd(aCodTrb,{'411101201',"Despesas de câmbio","LC 214/2025 Art. 192, II",;
    "Classificar nesse código as despesas com operações de câmbio."})
    aAdd(aCodTrb,{'411101202',"Despesas financeiras resultantes de perdas em operações com TVM","LC 214/2025 Art. 192, III",;
    "Classificar nesse código as despesas com perdas em operações com Títulos e Valores Mobiliários."})
    aAdd(aCodTrb,{'411101203',"Encargos financeiros ainda que registrados no patrimônio líquido","LC 214/2025 Art. 192, IV",;
    "Classificar nesse código as despesas com encargos financeiros ainda que tenham sido registrados em contas do patrimônio líquido."})
    aAdd(aCodTrb,{'411101204',"Perdas incorridas nas operações de crédito","LC 214/2025 Art. 192, V",;
    "Classificar nesse código as despesas com perdas no recebimento de operações de crédito e perdas na cessão de créditos ou na concessão de descontos, desde que realizadas a valor de mercado e obedecidas as regras de dedutibilidade da legislação do Imposto de Renda."})
    aAdd(aCodTrb,{'411101205',"Despesas com assessor de investimento, consultor TVM e correspondentes bancários, vinculados aos serviços de crédito, câmbio e TVM","LC 214/2025 Art. 192, VI",;
    "Classificar nesse código as despesas com assessor de investimento, consultor de Títulos e Valores Mobiliários ou com correspondentes bancários, esses últimos, desde que vinculados aos serviços de crédito, câmbio e TVM, devidamente comprovados por meio de documento fiscal idôneo, emitidos pelos prestadores do serviço."})
    aAdd(aCodTrb,{'4111013',"Despesas tributárias","",""})
    aAdd(aCodTrb,{'411101301',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411101302',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411102',"SECURITIZAÇÃO E FATURIZAÇÃO","LC 214/2025 Art. 182, IV a V",""})
    aAdd(aCodTrb,{'4111021',"Despesas de Captação","",""})
    aAdd(aCodTrb,{'411102101',"Despesas de captação de recursos","LC 214/2025 Art. 193, §1º, I",;
    "Classificar nesse código as rubricas contábeis representativas das despesas com captação de recursos. Esse código deve ser utilizado somente por empresas exclusivamente securitizados ou faturizadoras. No caso de bancos múltiplos, com carteira de securitização ou faturização, utilizar o código 411100001, para que seja usado como dedução o rateio dessa despesa."})
    aAdd(aCodTrb,{'4111022',"Despesas gerais","",""})
    aAdd(aCodTrb,{'411102201',"Despesas de securitização","LC 214/2025 Art. 193, §1º, II",;
    "Classificar nesse código as rubricas contábeis representativas das despesas com securitização, consistindo na emissão, distribuição, custódia, escrituração, registro, preparação e formalização de documentos, administração do patrimônio separado e atuação de agentes fiduciários, de cobrança e de classificação de risco, desde que esses serviços não tenham sido prestados por empregados ou administradores da empresa."})
    aAdd(aCodTrb,{'411102202',"Perdas incorridas nos recebimentos de créditos","LC 214/2025 Art. 193, §2º",;
    "Classificar nesse código as rubricas contábeis representativas das despesas com perdas incorridas no recebimento de créditos e as perdas na cessão destes créditos e na concessão de descontos, desde que sejam realizados a valor de mercado."})
    aAdd(aCodTrb,{'4111023',"Despesas tributárias","",""})
    aAdd(aCodTrb,{'411102301',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411103',"GESTÃO E ADM RECURSOS, INCLUSIVE FUNDOS INVESTIMENTO","",""})
    aAdd(aCodTrb,{'411103001',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411103002',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411104',"FGTS","",""})
    aAdd(aCodTrb,{'4111041',"Serviços prestados ao FGTS","",""})
    aAdd(aCodTrb,{'411104101',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411104102',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'4111042',"Operações de Crédito com recursos do FGTS","",""})
    aAdd(aCodTrb,{'41110421',"Despesas de Captação","",""})
    aAdd(aCodTrb,{'411104211',"Despesa de Captação","LC 214/2025 Art. 192, I",;
    "Classificar nesse código as rubricas contábeis representativas das despesas com captação de recursos do FGTS."})
    aAdd(aCodTrb,{'41110422',"Despesas Gerais","",""})
    aAdd(aCodTrb,{'411104221',"Encargos financeiros ainda que registrados no patrimônio líquido","LC 214/2025 Art. 192, IV",;
    "Classificar nesse código as despesas com encargos financeiros ainda que tenham sido registrados em contas do patrimônio líquido."})
    aAdd(aCodTrb,{'411104222',"Perdas incorridas nas operações de crédito","LC 214/2025 Art. 192, V",;
    "Classificar nesse código as despesas com perdas no recebimento de operações de crédito e perdas na cessão de créditos ou na concessão de descontos, desde que realizadas a valor de mercado e obedecidas as regras de dedutibilidade da legislação do Imposto de Renda."})
    aAdd(aCodTrb,{'41110423',"Despesas tributárias","",""})
    aAdd(aCodTrb,{'411104231',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411104232',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411105',"SERVIÇOS DE ATIVOS VIRTUAIS","",""})
    aAdd(aCodTrb,{'411105001',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411105002',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411106',"INTERMEDIAÇÃO DE NEGÓCIOS","",""})
    aAdd(aCodTrb,{'4111061',"CONSÓRCIOS","",""})
    aAdd(aCodTrb,{'411106101',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411106102',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'4111062',"SEGUROS RAMOS ELEM., SEM COBERT. POR SOBREVIVÊNCIA E RESSEGUROS","",""})
    aAdd(aCodTrb,{'411106201',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411106202',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'4111063',"CAPITALIZAÇÃO","",""})
    aAdd(aCodTrb,{'411106301',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411106302',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'4111064',"PREVIDENCIA COMPLEMENTAR E SEGUROS COM COBERTURA POR SOBREVIVÊNCIA","",""})
    aAdd(aCodTrb,{'411106401',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411106402',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411107',"ADM. DE MERCADOS ORGANIZ., INFRAESTR. DE MERCADO","",;
    "E DEPOSITÁRIAS CENTRAIS"})
    aAdd(aCodTrb,{'411107001',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411107002',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411108',"ADM. DE PROGRAMAS DE FIDELIZAÇÃO","",""})
    aAdd(aCodTrb,{'4111081',"Despesas gerais","",""})
    aAdd(aCodTrb,{'411108101',"Valor dos pontos pagos no resgate","LC 214/2025 Art. 219-A, I",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pelos pontos utilizados."})
    aAdd(aCodTrb,{'411108102',"Valor ressarcido por pontos não utilizados, computados como receita","LC 214/2025 Art. 219-A, I",;
    "Classificar nesse código as rubricas contábeis representativas dos pontos não utilizados pelos parceiros adquirentes, que foram oferecidos à tributação no momento da emissão, e que tenham sido devolvidos à administradora do programa de fidelidade."})
    aAdd(aCodTrb,{'4111082',"Despesas tributárias","",""})
    aAdd(aCodTrb,{'411108201',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411109',"OPER. DE PROTEÇÃO PATRIMONIAL MUTUALISTA","",""})
    aAdd(aCodTrb,{'4111091',"Despesas tributárias","",""})
    aAdd(aCodTrb,{'411109101',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'411110',"TARIFAS NÃO ACESSÓRIAS","",""})
    aAdd(aCodTrb,{'4111101',"VINCULADAS A OP. CRÉDITO, COM RECURSOS DO FGTS","",""})
    aAdd(aCodTrb,{'411110101',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411110102',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'4111102',"VINCULADAS A OP. CRÉDITO, CÂMBIO E TVM","",""})
    aAdd(aCodTrb,{'411110201',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'411110202',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})
    aAdd(aCodTrb,{'4112',"DESPESA NÃO DEDUTÍVEL","",""})
    aAdd(aCodTrb,{'41121',"TODOS OS SUBRREGIMES","",""})
    aAdd(aCodTrb,{'411210001',"Despesa de captação de cooperativas com recursos próprios, de cooperados ou recursos públicos","LC 214/2025 Art. 192, §8º",;
    "Classificar nesse código as despesas com captação de recursos junto a cooperados, optantes pelo regime regular do IBS/CBS, ou com recursos públicos ou, ainda, recursos próprios, no caso das cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico do Art. 271 da LC 214/2025, aplicados em operações com cooperados do regime regular do IBS/CBS."})
    aAdd(aCodTrb,{'411210002',"Provisão para perdas","LC 214/2025 Art. 186",;
    "Classificar nesse código as despesas com provisão para perdas."})
    aAdd(aCodTrb,{'411210003',"Crédito baixado como prejuízo","LC 214/2025 Art. 186",;
    "Classificar nesse código as despesas com créditos baixados como prejuízo."})
    aAdd(aCodTrb,{'411210004',"Despesas Administrativas","LC 214/2025 Art. 187",;
    "Classificar nesse código as despesas administrativas."})
    aAdd(aCodTrb,{'411210005',"Despesa já deduzida anteriormente","LC 214/2025 Art. 302",;
    "Classificar nesse código as despesas já deduzidas anteriormente."})
    aAdd(aCodTrb,{'411210006',"Despesa com correspondente bancário não vinculadas a serviços de crédito, câmbio e TVM","LC 214/2025 Art. 192, VI",;
    "Classificar nesse código as despesas com correspondentes bancários, não vinculados aos serviços de crédito, câmbio e TVM, devidamente comprovados por meio de documento fiscal idôneo, emitidos pelos prestadores do serviço. Nesse caso, o contribuinte pode aproveitar crédito do IBS e CBS sobre o serviço."})
    aAdd(aCodTrb,{'411210007',"Outras despesas não dedutíveis","",;
    "Classificar nesse código outras despesas não dedutíveis"})
    aAdd(aCodTrb,{'412',"NORMAS GERAIS DE TRIBUTAÇÃO","",""})
    aAdd(aCodTrb,{'4121',"Tarifas bancárias","",""})
    aAdd(aCodTrb,{'412100001',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'412100002',"PIS/Cofins incidente sobre operação SERVIÇOS DE PLANOS DE ASSISTÊNCIA À SAUDE","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre receitas."})

    //TRIBUTOS DO SEGMENTO DE PLANOS DE SAÚDE
    aAdd(aCodTrb,{'1',"ATIVO","",""})
    aAdd(aCodTrb,{'12',"SERVIÇOS DE PLANOS DE ASSISTÊNCIA À SAUDE","",""})
    aAdd(aCodTrb,{'121',"Valores tributáveis recebidos","",""})
    aAdd(aCodTrb,{'121000001',"Prêmios ou Contraprestações recebidas - seguros ou planos individuais","LC 214/2025 Art. 235, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos por prêmios ou contraprestações em planos individuais."})
    aAdd(aCodTrb,{'121000002',"Prêmios ou Contraprestações recebidas - seguros ou planos coletivos sem estipulantes","LC 214/2025 Art. 235, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos por prêmios ou contraprestações em planos coletivos sem a interveniência de estipulantes."})
    aAdd(aCodTrb,{'121000003',"Prêmios ou Contraprestações recebidas - seguros ou planos coletivos com estipulantes","LC 214/2025 Art. 235, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos por prêmios ou contraprestações em planos coletivos com a interveniência de estipulantes."})
    aAdd(aCodTrb,{'121000004',"Prêmios ou Contraprestações recebidas - corresponsabilidade assumida","LC 214/2025 Art. 235, I, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos por prêmios ou contraprestações em razão de corresponsabilidade assumida."})
    aAdd(aCodTrb,{'121000005',"Prêmios ou Contraprestações recebidas - contratos sem individualização do valor por titular","LC 214/2025 Art. 239, §1º",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos por prêmios ou contraprestações em contratos sem a individualização do valor prêmio ou contraprestação por beneficiário titular."})
    aAdd(aCodTrb,{'121000006',"Taxas de administração recebidas","LC 214/2025 Art. 235, I, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de taxas de administração recebidas."})
    aAdd(aCodTrb,{'121000007',"Valores Recebidos de outras entidades do setor","LC 214/2025 Art. 235, I, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de outras entidades do setor de planos de assistência à saúde."})
    aAdd(aCodTrb,{'121000008',"Valores recebidos por atos cooperativos com opção à alíquota zero","LC 214/2025 Art. 271",;
    "Classificar nesse código as rubricas contábeis representativas dos valores recebidos de cooperados, optantes pelo regime regular do IBS e da CBS, pelas cooperativas de crédito ou bancos cooperativos, optantes pelo regime específico previsto no Art. 271 da LC 214/2025."})
    aAdd(aCodTrb,{'122',"Valores pagos dedutíveis","",""})
    aAdd(aCodTrb,{'1221',"Valores pagos relativos a despesas dedutíveis","",""})
    aAdd(aCodTrb,{'122100001',"Indenizações pagas ao beneficiário do plano ou seguro saúde correspondentes a eventos ocorridos","LC 214/2025 Art. 235, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das indenizações pagas aos usuários dos planos ou seguro saúde, referentes a eventos ocorridos, referentes ao total dos custos assistenciais, decorrente da utilização da cobertura pelos beneficiários dos planos ou seguro saúde. Incluir nesse código tanto os pagamentos de despesas pagas à vista (escrituradas diretamente nas contas de resultado), quanto as que forem pagos após o encerramento da competência (registradas no passivo circulante)."})
    aAdd(aCodTrb,{'122100002',"Indenizações pagas a terceiros correspondentes a eventos ocorridos","LC 214/2025 Art. 235, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das indenizações pagas a terceiros, devidamente comprovadas por meio de documento fiscal idôneo, emitido pelo prestador do serviço ao plano ou seguro saúde, referentes a eventos ocorridos, referentes ao total dos custos assistenciais, decorrente da utilização da cobertura pelos beneficiários. Incluir nesse código tanto os pagamentos de despesas pagas à vista (escrituradas diretamente nas contas de resultado), quanto as que forem pagos após o encerramento da competência (registradas no passivo circulante)."})
    aAdd(aCodTrb,{'122100003',"Valores pagos por corresponsabilidade cedida","LC 214/2025 Art. 235, II, a",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos por corresponsabilidade cedida. Incluir nesse código tanto os pagamentos de despesas pagas à vista (escrituradas diretamente nas contas de resultado), quanto as que forem pagos após o encerramento da competência (registradas no passivo circulante)."})
    aAdd(aCodTrb,{'122100004',"Restituições de prêmios ou contraprestações","LC 214/2025 Art. 235, II, b",;
    "Classificar nesse código as rubricas contábeis representativas dos valores das restituições de prêmios ou contraprestações pagas aos titulares dos planos ou seguro saúde. Incluir nesse código tanto os pagamentos de despesas pagas à vista (escrituradas diretamente nas contas de resultado), quanto as que forem pagos após o encerramento da competência (registradas no passivo circulante)."})
    aAdd(aCodTrb,{'122100005',"Valores pagos pela intermediação de seguros ou planos de saúde","LC 214/2025 Art. 235, II, c",;
    "Classificar nesse código as rubricas contábeis representativas dos valores pagos pela intermediação na venda de planos ou seguro saúde, devidamente comprovado por documento fiscal idôneo, emitido pelo intermediador. Incluir nesse código tanto os pagamentos de despesas pagas à vista (escrituradas diretamente nas contas de resultado), quanto as que forem pagos após o encerramento da competência (registradas no passivo circulante)."})
    aAdd(aCodTrb,{'122100006',"Taxa de administração paga às administradoras de benefícios","LC 214/2025 Art. 235, II, d",;
    "Classificar nesse código as rubricas contábeis representativas dos valores de taxa de administração paga à administradora de benefícios. Incluir nesse código tanto os pagamentos de despesas pagas à vista (escrituradas diretamente nas contas de resultado), quanto as que forem pagos após o encerramento da competência (registradas no passivo circulante)."})
    aAdd(aCodTrb,{'122100007',"Outros Valores Pagos às demais entidades","LC 214/2025 Art. 235, II, d",;
    "Classificar nesse código as rubricas contábeis representativas dos outros valores pagos às demais entidades do setor de planos de assistência à saúde. Incluir nesse código tanto os pagamentos de despesas pagas à vista (escrituradas diretamente nas contas de resultado), quanto as que forem pagos após o encerramento da competência (registradas no passivo circulante)."})
    aAdd(aCodTrb,{'1222',"Valores de tributos pagos","",""})
    aAdd(aCodTrb,{'122200001',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN incidentes sobre as operações."})
    aAdd(aCodTrb,{'122200002',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as rubricas contábeis representativas dos valores do PIS e da Cofins incidentes sobre as operações"})
    aAdd(aCodTrb,{'123',"Aplicações Financeiras sobre reservas técnicas","",""})
    aAdd(aCodTrb,{'123000001',"Aplicações Financeiras sobre reservas técnicas","LC 214/2025 Art. 235, §4º, I",;
    "Classificar nesse código as rubricas contábeis representativas das aplicações financeiras vinculadas a reservas técnicas, nos termos de regulamento da ANS, sejam elas pertencentes ao Ativo Circulante ou Não Circulante."})
    aAdd(aCodTrb,{'129',"Demais contas de Ativo","",""})
    aAdd(aCodTrb,{'129000001',"Demais contas de Ativo Circulante","",;
    "Classificar nesse código as demais rubricas contábeis do Ativo Circulante, não classificadas anteriormente."})
    aAdd(aCodTrb,{'129000002',"Contas de Ativo Não circulante","",;
    "Classificar nesse código as demais rubricas contábeis do Ativo Não Circulante, não classificadas anteriormente."})
    aAdd(aCodTrb,{'2',"PASSIVO e PL","",""})
    aAdd(aCodTrb,{'22',"SERVIÇOS DE PLANOS DE ASSISTÊNCIA À SAUDE","",""})
    aAdd(aCodTrb,{'221',"Passivo Circulante e Não Circulante","",""})
    aAdd(aCodTrb,{'2211',"Provisões Técnicas","",""})
    aAdd(aCodTrb,{'221100001',"Provisões técnicas lastreadas em ativo garantidor","LC 214/2025 Art. 235, §4º, II",;
    "Classificar nesse código as rubricas contábeis que representam as provisões técnicas lastreadas em ativo garantidor, nos termos da legislação própria da ANS. Incluir nesse código tanto as rubricas do Passivo Circulante, quanto as do Passivo Não Circulante."})
    aAdd(aCodTrb,{'221100002',"Provisões técnicas não lastreadas em ativo garantidor","",;
    "Classificar nesse código as rubricas contábeis que representam as provisões técnicas não lastreadas em ativo garantidor, nos termos da legislação própria da ANS. Incluir nesse código tanto as rubricas do Passivo Circulante, quanto as do Passivo Não Circulante."})
    aAdd(aCodTrb,{'2212',"Demais contas do passivo","",""})
    aAdd(aCodTrb,{'221200001',"Demais contas do passivo","",;
    "Classificar nesse código as rubricas contábeis pertencentes ao grupo do Passivo Circulante ou Não Circulante."})
    aAdd(aCodTrb,{'2213',"Patrimônio Líquido","",""})
    aAdd(aCodTrb,{'221300001',"Contas do Patrimônio Líquido","",;
    "Classificar nesse código as rubricas contábeis pertencentes ao grupo do Patrimônio Líquido."})
    aAdd(aCodTrb,{'3',"RECEITAS","",""})
    aAdd(aCodTrb,{'32',"SERVIÇOS DE PLANOS DE ASSISTÊNCIA À SAÚDE","",""})
    aAdd(aCodTrb,{'321',"Receitas com planos de assistência à Saúde","",""})
    aAdd(aCodTrb,{'321000001',"Receitas com planos de assistência à saúde apuradas para fins de tributação do SN","LC 123/2006",;
    "Classificar nesse código as rubricas contábeis representativas das receitas auferidas pelas empresas que forem optantes pelo Simples Nacional, para fins de tributação dos demais tributos incluídos naquele regime."})
    aAdd(aCodTrb,{'322',"Outras receitas","",""})
    aAdd(aCodTrb,{'322000001',"Receitas com emissão de notas fiscais","",;
    "Classificar nesse código as rubricas contábeis representativas das demais receitas auferidas, não sujeitas ao regime específico de serviços de assistência à saúde, que ficam sujeitas às regras gerais de tributação do IBS/CBS, cuja comprovação se dê pela emissão de documento fiscal."})
    aAdd(aCodTrb,{'322000002',"Receitas não operacionais","",;
    "Classificar nesse código todas as demais receitas não especificadas anteriormente."})
    aAdd(aCodTrb,{'4',"DESPESAS","",""})
    aAdd(aCodTrb,{'42',"SERVIÇOS DE PLANOS DE ASSISTÊNCIA À SAÚDE","",""})
    aAdd(aCodTrb,{'420000001',"Despesas em geral não dedutíveis CONCURSOS DE PROGNÓSTICOS","",;
    "Classificar nesse código outras despesas não dedutíveis."})

    //TRIBUTOS DO SEGMENTO CONCURSOS DE PROGNÓSTICOS
    aAdd(aCodTrb,{'1',"ATIVO","",""})
    aAdd(aCodTrb,{'13',"CONCURSOS DE PROGNÓSTICOS","",""})
    aAdd(aCodTrb,{'131',"VALORES TRIBUTÁVEIS","",""})
    aAdd(aCodTrb,{'131000001',"Valores de apostas esportivas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas esportivas efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'131000002',"Valores de apostas de Turfe","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas de turfe efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'131000003',"Valores relativos a modalidades Lotéricas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas efetuadas relativos a modalidades lotéricas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'131000004',"Valores relativos a Jogos Online (iGaming)","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas efetuadas relativos a jogos online (iGaming) independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'131000005',"Valores relativos a Fantasy Sport","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a fantasy sport independentemente do encerramento do evento ao qual estão vinculados."})
    aAdd(aCodTrb,{'131000006',"Valores relativos a Sweepstakes","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas de sweepstakes efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'131000007',"Valores relativos a outras modalidades de apostas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a outras modalidades de apostas efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'131000008',"Valores relativos a apostas decorrentes de recompensas ou vantagens oferecidas pelo fornecedor","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a apostas efetuadas decorrentes de recompensas ou vantagens oferecidas pelo fornecedor sujeito ao regime específico de concursos de prognósticos independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'131000099',"Outros valores decorrentes da atividade de concursos de prognósticos","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código outros valores decorrentes da atividade de concursos de prognósticos independentemente do encerramento do evento ao qual esteja vinculada."})
    aAdd(aCodTrb,{'132',"OUTROS REGIMES DE TRIBUTAÇÃO","",""})
    aAdd(aCodTrb,{'132000001',"Valores de recompensas ou vantagens tributáveis conforme as normas gerais","LC 214/2025 Título I, Capítulo II",;
    "Classificar nesse código outros valores de recompensas ou vantagens tributáveis conforme as normas gerais do regime regular."})
    aAdd(aCodTrb,{'132000002',"Outros valores tributáveis","LC 214/2025",;
    "Classificar nesse código outros valores tributáveis."})
    aAdd(aCodTrb,{'133',"VALORES NÃO TRIBUTÁVEIS","",""})
    aAdd(aCodTrb,{'133000001',"Valores recebidos e outras receitas próprias da entidade decorrentes da atividade de concursos de prognósticos provenientes de operações de exportação","LC 214/2025 Art. 250, caput",;
    "Classificar nesse código valores recebidos e outras receitas próprias da entidade decorrentes da atividade de concursos de prognósticos provenientes de operações de exportação."})
    aAdd(aCodTrb,{'134',"VALORES DEDUTÍVEIS","",""})
    aAdd(aCodTrb,{'134000001',"Premiações pagas em apostas esportivas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações pagas decorrentes de apostas esportivas."})
    aAdd(aCodTrb,{'134000002',"Premiações pagas em apostas de Turfe","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações pagas decorrentes de apostas de turfe."})
    aAdd(aCodTrb,{'134000003',"Premiações pagas em modalidades Lotéricas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações pagas decorrentes de modalidades lotéricas."})
    aAdd(aCodTrb,{'134000004',"Premiações pagas em Jogos Online (iGaming)","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações pagas decorrentes de jogos online (iGaming)."})
    aAdd(aCodTrb,{'134000005',"Premiações pagas em Fantasy Sport","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações pagas decorrentes de fantasy sport."})
    aAdd(aCodTrb,{'134000006',"Premiações pagas em Sweepstakes","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações pagas decorrentes de sweepstakes."})
    aAdd(aCodTrb,{'134000007',"Premiações pagas em outras modalidades de apostas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações pagas decorrentes de outras modalidades de apostas."})
    aAdd(aCodTrb,{'134000008',"Premiações devidas aos proprietários, criadores e profissionais do turfe, relacionados com os animais classificados em cada páreo, de que trata o art. 12 da Lei nº 7.291, de 19 de dezembro de 1984","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações devidas aos proprietários, criadores e profissionais do turfe, relacionados com os animais classificados em cada páreo, de que trata o art. 12 da Lei nº 7.291, de 19 de dezembro de 1984."})
    aAdd(aCodTrb,{'134000009',"Outras premiações pagas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código outras premiações pagas."})
    aAdd(aCodTrb,{'135',"OUTROS VALORES NÃO TRIBUTÁVEIS/DEDUTÍVEIS","",""})
    aAdd(aCodTrb,{'135000001',"Outros valores não tributáveis","LC 214/2025",;
    "Classificar nesse código outros valores não tributáveis."})
    aAdd(aCodTrb,{'135000002',"Outros valores não dedutíveis","LC 214/2025",;
    "Classificar nesse código outros valores não dedutíveis."})
    aAdd(aCodTrb,{'2',"PASSIVO e PL","",""})
    aAdd(aCodTrb,{'23',"CONCURSOS DE PROGNÓSTICOS","",""})
    aAdd(aCodTrb,{'231',"VALORES TRIBUTÁVEIS","",""})
    aAdd(aCodTrb,{'231000001',"Valores de apostas esportivas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas esportivas efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'231000002',"Valores de apostas de Turfe","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas de turfe efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'231000003',"Valores relativos a modalidades Lotéricas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas efetuadas relativos a modalidades lotéricas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'231000004',"Valores relativos a Jogos Online (iGaming)","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas efetuadas relativos a jogos online (iGaming) independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'231000005',"Valores relativos a Fantasy Sport","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a fantasy sport independentemente do encerramento do evento ao qual estão vinculados."})
    aAdd(aCodTrb,{'231000006',"Valores relativos a Sweepstakes","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas de sweepstakes efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'231000007',"Valores relativos a outras modalidades de apostas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a outras modalidades de apostas efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'231000008',"Valores relativos a apostas decorrentes de recompensas ou vantagens oferecidas pelo fornecedor","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a apostas efetuadas decorrentes de recompensas ou vantagens oferecidas pelo fornecedor sujeito ao regime específico de concursos de prognósticos independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'231000099',"Outros valores decorrentes da atividade de concursos de prognósticos","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código outros valores decorrentes da atividade de concursos de prognósticos independentemente do encerramento do evento ao qual esteja vinculada."})
    aAdd(aCodTrb,{'232',"OUTROS REGIMES DE TRIBUTAÇÃO","",""})
    aAdd(aCodTrb,{'232000001',"Outros valores tributáveis","LC 214/2025",;
    "Classificar nesse código outros valores tributáveis."})
    aAdd(aCodTrb,{'233',"VALORES NÃO TRIBUTÁVEIS","",""})
    aAdd(aCodTrb,{'233000001',"Valores recebidos e outras receitas próprias da entidade decorrentes da atividade de concursos de prognósticos provenientes de operações de exportação","LC 214/2025 Art. 250, caput",;
    "Classificar nesse código valores recebidos e outras receitas próprias da entidade decorrentes da atividade de concursos de prognósticos provenientes de operações de exportação."})
    aAdd(aCodTrb,{'233000002',"Valores de recompensas ou vantagens não convertidos em produto da arrecadação","LC 214/2025 Art. 245",;
    "Classificar nesse código valores de recompensas ou vantagens não convertidos em produto da arrecadação e que não são tributados conforme demais dispositivos do regime regular."})
    aAdd(aCodTrb,{'233000003',"Valores recebidos e não convertidos em produto da arrecadação","LC 214/2025 Art. 245",;
    "Classificar nesse código valores recebidos de clientes e ainda não convertidos em produto da arrecadação. Por exemplo, valores transferidos para a conta transacional e ainda não apostados."})
    aAdd(aCodTrb,{'233000004',"Outros valores não tributáveis","LC 214/2025",;
    "Classificar nesse código outros valores não tributáveis."})
    aAdd(aCodTrb,{'3',"RECEITAS","",""})
    aAdd(aCodTrb,{'33',"CONCURSOS DE PROGNÓSTICOS","",""})
    aAdd(aCodTrb,{'331',"VALORES TRIBUTÁVEIS","",""})
    aAdd(aCodTrb,{'3311',"VALORES TRIBUTÁVEIS DO REGIME ESPECÍFICO","",""})
    aAdd(aCodTrb,{'331100001',"Valores de apostas esportivas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas esportivas efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'331100002',"Valores de apostas de Turfe","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas de turfe efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'331100003',"Valores relativos a modalidades Lotéricas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas efetuadas relativos a modalidades lotéricas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'331100004',"Valores relativos a Jogos Online (iGaming)","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas efetuadas relativos a jogos online (iGaming) independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'331100005',"Valores relativos a Fantasy Sport","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a fantasy sport independentemente do encerramento do evento ao qual estão vinculados."})
    aAdd(aCodTrb,{'331100006',"Valores relativos a Sweepstakes","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores das apostas de sweepstakes efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'331100007',"Valores relativos a outras modalidades de apostas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a outras modalidades de apostas efetuadas independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'331100008',"Valores decorrentes de recompensas ou vantagens oferecidas","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código os valores relativos a apostas efetuadas decorrentes de recompensas ou vantagens oferecidas pelo fornecedor sujeito ao regime específico de concursos de prognósticos independentemente do encerramento do evento ao qual estão vinculadas."})
    aAdd(aCodTrb,{'331100009',"Outros valores decorrentes da atividade de concursos de prognósticos","LC 214/2025 Arts. 244 e 245, caput",;
    "Classificar nesse código outros valores decorrentes da atividade de concursos de prognósticos independentemente do encerramento do evento ao qual esteja vinculada."})
    aAdd(aCodTrb,{'3312',"OUTROS REGIMES DE TRIBUTAÇÃO","",""})
    aAdd(aCodTrb,{'331200001',"Valores tributáveis pelo regime regular e não sujeitos a regimes específicos","LC 214/2025",;
    "Classificar nesse código valores tributáveis pelo regime regular e não sujeitos a regimes específicos."})
    aAdd(aCodTrb,{'331200002',"Outros valores tributáveis","LC 214/2025",;
    "Classificar nesse código outros valores tributáveis."})
    aAdd(aCodTrb,{'332',"VALORES NÃO TRIBUTÁVEIS","",""})
    aAdd(aCodTrb,{'332000001',"Valores recebidos e outras receitas próprias da entidade decorrentes da atividade de concursos de prognósticos provenientes de operações de exportação","LC 214/2025 Art. 250, caput",;
    "Classificar nesse código valores recebidos e outras receitas próprias da entidade decorrentes da atividade de concursos de prognósticos provenientes de operações de exportação."})
    aAdd(aCodTrb,{'332000002',"Receita já tributada anteriormente quando da escrituração dos respectivos valores no ativo","",;
    "Classificar nesse código receita já tributada anteriormente quando da escrituração dos respectivos valores no ativo."})
    aAdd(aCodTrb,{'332000003',"Receita já tributada anteriormente quando da escrituração dos respectivos valores no passivo","",;
    "Classificar nesse código receita já tributada anteriormente quando da escrituração dos respectivos valores no passivo."})
    aAdd(aCodTrb,{'333',"OUTROS REGIMES DE TRIBUTAÇÃO","",""})
    aAdd(aCodTrb,{'333000001',"Valores NÃO decorrentes da atividade de concursos de prognósticos e provenientes de operações de exportação","LC 214/2025",;
    "Classificar nesse código valores não decorrentes da atividade de concursos de prognósticos e provenientes de operações de exportação."})
    aAdd(aCodTrb,{'333000002',"Valores decorrentes da conta de reserva técnica","LC 214/2025 Art. 6º, V",;
    "Classificar nesse código valores decorrentes da conta de reserva técnica."})
    aAdd(aCodTrb,{'333000003',"Outros valores de operações imunes, isentas, com não incidência ou outras modalidades de não tributação","LC 214/2025",;
    "Classificar nesse código outros valores de operações imunes, isentas, com não incidência ou outras modalidades de não tributação."})
    aAdd(aCodTrb,{'4',"DESPESAS","",""})
    aAdd(aCodTrb,{'43',"CONCURSOS DE PROGNÓSTICOS","",""})
    aAdd(aCodTrb,{'431',"DESPESA DEDUTÍVEL","",""})
    aAdd(aCodTrb,{'4310001',"Despesas com premiações pagas","",""})
    aAdd(aCodTrb,{'431000101',"Despesas com premiações pagas em apostas esportivas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiações pagas em apostas esportivas. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000102',"Despesas com premiações pagas em apostas de Turfe","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiações pagas em apostas de turfe. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000103',"Despesas com premiações pagas em modalidades Lotéricas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiações pagas em modalidades lotéricas. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000104',"Despesas com premiações pagas em Jogos Online (iGaming)","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiações pagas em jogos online (iGaming). Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000105',"Despesas com premiações pagas em Fantasy Sport","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiações pagas em fantasy sport. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000106',"Despesas com premiações pagas em Sweepstakes","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiações pagas em sweepstakes. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000107',"Despesas com premiações pagas em outras modalidades de apostas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiações pagas em outras modalidades de apostas. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000108',"Despesas com premiações devidas aos proprietários, criadores e profissionais do turfe, relacionados com os animais classificados em cada páreo, de que trata o art. 12 da Lei nº 7.291, de 19 de dezembro de 1984","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as premiações devidas aos proprietários, criadores e profissionais do turfe, relacionados com os animais classificados em cada páreo, de que trata o art. 12 da Lei nº 7.291, de 19 de dezembro de 1984. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'431000109',"Outras premiações pagas","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com outras premiações pagas. Nota: A efetiva dedução na base de cálculo é processada pelo sistema exclusivamente a partir dos valores vinculados às contas de ativo. A correspondente escrituração nas contas de despesa é obrigatória para a consistência contábil."})
    aAdd(aCodTrb,{'4310002',"Despesas com destinações legais","",""})
    aAdd(aCodTrb,{'431000201',"Destinações obrigatórias por lei a órgão ou fundo público e aos demais beneficiários","LC 214/2025 Art. 245, II",;
    "Classificar nesse código as despesas com destinações obrigatórias por lei a órgão ou fundo público e aos demais beneficiários."})
    aAdd(aCodTrb,{'4310003',"Despesas tributárias","",""})
    aAdd(aCodTrb,{'431000301',"ISSQN incidente sobre a operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com ISSQN."})
    aAdd(aCodTrb,{'431000302',"PIS/Cofins incidente sobre operação","LC 214/2025 Art. 12, §2º, V",;
    "Classificar nesse código as despesas com PIS/Cofins."})
    aAdd(aCodTrb,{'432',"DESPESA NÃO DEDUTÍVEL","",""})
    aAdd(aCodTrb,{'432000001',"Premiação paga em decorrência de valores classificados como operações de exportação","LC 214/2025 Art. 250, caput",;
    "Classificar nesse código as despesas com premiação paga em decorrência de valores classificados como operações de exportação."})
    aAdd(aCodTrb,{'432000002',"Premiação incorrida e não paga","LC 214/2025 Art. 245, I",;
    "Classificar nesse código as despesas com premiação incorrida e não paga."})
    aAdd(aCodTrb,{'432000003',"Outras despesas não dedutíveis","LC 214/2025",;
    "Classificar nesse código outras despesas não dedutíveis."})

    dbSelectArea("QLS")
    QLS->(dbSetOrder(1))//QLS_FILIAL+QLS_CODTRB    
    
    For nx := 1 to Len(aCodTrb)
        If !QLS->(DbSeek(cFilQLS+PadR(aCodTrb[nx,1],nTamTrib))) //Inclui apenas se não achar o registro
            RecLock("QLS",.T.)
            QLS->QLS_FILIAL := cFilQLS
            QLS->QLS_CODTRB := aCodTrb[nx,1]
            QLS->QLS_TITULO := aCodTrb[nx,2]
            QLS->QLS_DISLEI := aCodTrb[nx,3]
            QLS->QLS_DSCTRB := aCodTrb[nx,4]

            If Empty(aCodTrb[nx,3]) .AND. Empty(aCodTrb[nx,4]) //Se ambos forem em branco é sintético
                QLS->QLS_CLASSE := "1"
            Else
                QLS->QLS_CLASSE := "2" 
            EndIf

            QLS->(MsUnlock())
        EndIf
    Next
    
Return
