#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//--------------------------------------------------------
/*/{Protheus.doc} RetailReduction
Realiza gravação da Redução Z
@type function
@author  	rafael.pessoa
@since   	26/08/2019
@version 	P12
@param 		aAutoCab  	, Array, Cabeçalho da Redução - SFI
@return	lRet - Retorna se executou corretamente
/*/
//--------------------------------------------------------
Function RetailReduction(aAutoCab,nOpcAuto)

    Local   lRotAuto 	:= aAutoCab <> Nil	   	//Cadastro por rotina automatica
    Local 	lRet		:= .F.

    Private aRotina 	:= MenuDef()       		// Array com os menus disponiveis

    Default aAutoCab 	:= {}
    Default nOpcAuto	:= 3

    If lRotAuto
        lRet := FWMVCRotAuto(ModelDef(), "SFI", nOpcAuto, {{"SFIMASTER", aAutoCab}})	
    EndIf	

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} MenuDef
MenuDef MVC
@type function
@author  	rafael.pessoa
@since   	26/08/2019
@version 	P12
@return	    aRotina - Rotinas disponiveis
/*/
//--------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina, { "Visualizar"	, 'VIEWDEF.RetailReduction', 0, 2, 0, NIL } )//"Visualizar"
aAdd( aRotina, { "Incluir" 	    , 'VIEWDEF.RetailReduction', 0, 3, 0, NIL } )//"Incluir" 
aAdd( aRotina, { "Alterar"  	, 'VIEWDEF.RetailReduction', 0, 4, 0, NIL } )//"Alterar" 
aAdd( aRotina, { "Imprimir"  	, 'VIEWDEF.RetailReduction', 0, 8, 0, NIL } )//"Imprimir" 

Return aRotina


//--------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef MVC
@type function
@author  	rafael.pessoa
@since   	26/08/2019
@version 	P12
@return	    oModel - modelo de dados
/*/
//--------------------------------------------------------
Static Function ModelDef()

    Local oMStruSFI 	:= FWFormStruct( 1, 'SFI' ) // Cria as estruturas a serem usadas no Modelo de Dados    
    Local oModelDef 	:= Nil						// Modelo de dados construído

    LjxAddFil('SFI', oMStruSFI, 1)

    oModelDef := MPFormModel():New( 'RetailReduction') // Cria o objeto do Modelo de Dados
    oModelDef:AddFields( 'SFIMASTER', /*cOwner*/, oMStruSFI )// Adiciona ao modelo um componente de formulário
    oModelDef:SetDescription( "Redução Z" )// "Redução Z"
    oModelDef:GetModel( 'SFIMASTER' ):SetDescription( "Redução Z" )	//"CRedução Z" 

Return oModelDef

//--------------------------------------------------------
/*/{Protheus.doc} LjxConSfi
Consulta a SFI para saber se já existe na base
@type 		function
@author  	Varejo
@since   	09/09/2019
@version 	P12
@return	    
/*/
//--------------------------------------------------------
Function LjxConSfi(aAutoCab)

Local lRet 	    := .F. //Variavel de retorno
Local aArea	    := GetArea() //Guarda a area
Local nFilial   := 0 //Posicao do campo filial da SFI
Local nDtMovTo  := 0 //Posicao do campo data do movimento da SFI
Local nPdv      := 0 //Posicao do campo pdv da SFI
Local nNumRedz  := 0 //Posicao do campo numero da reducao z da SFI
Local cChave    := "" //Chave de pesquisa

Default aAutoCab := {}

If Len(aAutoCab) > 0

    nFilial     := aScan(aAutoCab,{|x| AllTrim(x[1]) == "FI_FILIAL" })
    nDtMovTo    := aScan(aAutoCab,{|x| AllTrim(x[1]) == "FI_DTMOVTO" })
    nPdv        := aScan(aAutoCab,{|x| AllTrim(x[1]) == "FI_PDV" })
    nNumRedz    := aScan(aAutoCab,{|x| AllTrim(x[1]) == "FI_NUMREDZ" })

    If nFilial > 0 .AND. nDtMovTo > 0 .AND. nPdv > 0 .AND. nNumRedz > 0

        cChave := PadR(aAutoCab[nFilial][2], TamSx3("FI_FILIAL")[1]) +; //Filial
                  DToS(aAutoCab[nDtMovTo][2]) +; //Data do movimento
                  PadR(aAutoCab[nPdv][2], TamSx3("FI_PDV")[1]) +; //Numero do PDV
                  PadR(aAutoCab[nNumRedz][2], TamSx3("FI_NUMREDZ")[1]) //Numero da reducao z

        DbSelectArea('SFI') 
        SFI->(dbSetOrder(1)) //FI_FILIAL+DTOS(FI_DTMOVTO)+FI_PDV+FI_NUMREDZ

        If SFI->(dbSeek(cChave))
            lRet := .T.
        Else
            lRet := .F.
        EndIf

    EndIf

EndIf

RestArea(aArea)

Return lRet