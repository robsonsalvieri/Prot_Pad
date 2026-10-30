#Include "RUS34S10D.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*MAINTENANCE FOR PROJECTS Appointments (simple model to be used in web forms for VISUALIZATION)*/

PUBLISH MODEL REST NAME RU34S10D RESOURCE OBJECT oRU34S10D

Class oRU34S10D From FwRestModel
//Method Seek()
//Method Total()
//Method DeActivate()
//Method SetAlias()
//Method Skip()
//Method Seek()

EndClass
/*
Method Seek(cPK) Class oRU34S10D
Local lRet := .T. //SEEKMethod(@self,cPK)
Return lRet
*/
Function RUS34S10D()
        /*Declarando as variáveis que serão utilizadas*/
	Local aArea := CV3->(GetArea())
	Private oBrowse
   Private aRotina:= MenuDef()
   //Iniciamos a construção básica de um Browse.
	oBrowse := FWMBrowse():New()

        //Definimos a tabela que será exibida na Browse utilizando o método SetAlias
	oBrowse:SetAlias("CV3")

        //Definimos o título que será exibido como método SetDescription
	oBrowse:SetDescription("CV3")
	
	//Adiciona um filtro ao browse
	//oBrowse:SetFilterDefault( "X5_TABELA == '21'" )
	
	//Desliga a exibição dos detalhes
	//oBrowse:DisableDetails()
	
   //Ativamos a classe
	oBrowse:Activate()
   RestArea(aArea)
Return
Static Function MenuDef() 
Local aRotina := {}
aAdd( aRotina, { STR0001   , 'VIEWDEF.RUS34S10D', 0, 2, 0, NIL } )
Return aRotina

Static Function ModelDef() 
// Cria a estrutura a ser usada no Modelo de Dados
Local oStru
Local oModel // Modelo de dados que ser? constru?do
dbSelectArea('CV3')
If CT5->(FieldPos('CT5_MODEL')) > 0 .AND. CT5->(dbSeek(xFilial("CT5")+CV3->CV3_LP,.F.)) .and. !Empty(CT5->CT5_MODEL)
   oModel := FWLoadModel( Alltrim(CT5->CT5_MODEL))
ElseIf CTL->(FieldPos('CTL_MODEL')) > 0 .AND. CTL->(dbSeek(xFilial("CTL")+CV3->CV3_LP)) .AND. !Empty(CTL->CTL_MODEL)
   oModel := FWLoadModel( Alltrim(CTL->CTL_MODEL))
Endif

If oModel == Nil
   //CV3->(DBGOTO(9969))
   SX2->(DBSETORDER(1))
   SX2->(MSSeek(CV3->CV3_TABORI))
   aKey := StrTokArr(ALLTRIM(SX2->X2_UNICO),"+")

   oStru    := FWFormStruct(  1, CV3->CV3_TABORI)
   oModel   := MPFormModel():New('RUS34S10D')

   //FWFORMMODELSTRUCT():AddField(<cTitulo >, <cTooltip >, <cIdField >, <cTipo >, <nTamanho >, [ nDecimal ], [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], <lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL
   oModel:AddFields( 'MASTER', /*cOwner*/, oStru)
   oModel:getModel('MASTER'):SetDescription(STR0002) //"Documentos de Origem"
   oModel:SetPrimaryKey(aKey)
Endif

Return oModel


Static Function ViewDef()
Local oModel 
Local oStru 

// Interface de visualiza??o constru?da
Local oView
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
dbSelectArea('CV3')
CT5->(dbsetOrder(1))
CTL->(dbsetOrder(1))
If CT5->(FieldPos('CT5_MODEL')) > 0 .AND. CT5->(dbSeek(xFilial("CT5")+CV3->CV3_LP,.F.)) .and. !Empty(CT5->CT5_MODEL)
//   oModel := FWLoadModel( Alltrim(CTL->CTL_MODEL))
   oView := FWLoadView( Alltrim(CT5->CT5_MODEL))
ElseIf CTL->(FieldPos('CTL_MODEL') )> 0 .AND. CTL->(dbSeek(xFilial("CTL")+CV3->CV3_LP)) .AND. !Empty(CTL->CTL_MODEL)
   //oModel := FWLoadModel( Alltrim(CTL->CTL_MODEL))
   oView := FWLoadView( Alltrim(CTL->CTL_MODEL))
Endif
If oView == Nil
   oModel := FWLoadModel( 'RUS34S10D' )
   //Local oRestModel:= oModelCT2():New()
   (CV3->CV3_TABORI)->(DbGoTo(VAL(CV3->CV3_RECORI)))

   oStru := FWFormStruct( 2, CV3->CV3_TABORI )
   // Cria a estrutura a ser usada na View
   //oStruCT2:SetNoFolder()
   // Cria o objeto de View
   oView := FWFormView():New()
   // Define qual o Modelo de dados ser? utilizado na View
   oView:SetModel( oModel )
   // Adiciona no nosso View um controle do tipo formul?rio
   // (antiga Enchoice)
   oView:AddField( 'VIEW', oStru, 'MASTER' )
   oView:CreateHorizontalBox( 'HEADER', 100)
   oView:SetOwnerView( 'VIEW', 'HEADER' )
Endif

// Retorna o objeto de View criado
Return oView

/*
Static Function SEEKMethod (oFMModel,cPK) 
Local lRet := .F.
Local cQry
Local cPkFilter
    If oFMModel:HasAlias()
        If !Empty(cPK)
            cPkFilter := FWAToS(oFMModel:oModel:GetPrimaryKey(),"||") + " = '" + cPk + "'"
            If (oFMModel:cAlias)->(FieldPos(PrefixoCpo(oFMModel:cAlias)+"_FILIAL")) > 0
                cPkFilter := PrefixoCpo(oFMModel:cAlias)+"_FILIAL||" + cPkFilter
            EndIf
            oFMModel:SetFilter(cPkFilter)
        Endif
        cQry := createQueryAlias(@oFMModel:cQryAlias, oFMModel:cAlias, oFMModel:cFilter,oFMModel:cOrder,oFMModel)
        If oFMModel:lDebug .And. oFMModel:GetQSValue("showQuery") == "true"
            i18nConOut("[FWRESTMODELOBJECT] Query: #1#2", {CRLF, cQry})
        EndIf
        If !(oFMModel:cQryAlias)->(Eof())
            (oFMModel:cAlias)->(dbGoTo((oFMModel:cQryAlias)->R_E_C_N_O_))
            lRet := !(oFMModel:cAlias)->(Eof())
        EndIf
    Endif
Return lRet
*/
                   
//Merge Russia R14 

                   
