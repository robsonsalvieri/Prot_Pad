#INCLUDE "LOJA210.CH"
#Include 'Protheus.ch'
#INCLUDE "FWEVENTVIEWCONSTS.CH"                            
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "FWMVCDEF.CH"  
#INCLUDE "FWMBROWSE.CH"

#DEFINE CRLF		CHR(10)+CHR(13)
		
Static lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.) //Identifica se o ambiente esta operando em offline

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA210   ºAutor  ³Edney S. Souza      º Data ³  05/29/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Utilizado para associar varios codigos de barra a um mesmo º±±
±±º          ³ produto                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA, FRONTLOJA                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA210(aAuto, nOpcAuto) 
          
Local cDel 		 := Nil                     // Funcao a ser executada ao deletar o registro
Local lLj7210Exc := ExistBlock("LJ7210EXC") // Verifica se existe o ponto de entrada LJ7210EXC
Local lAuto		 := !Empty(aAuto)

Private aRotina := MenuDef()

//Ponto de entrada que permite realizar customizacoes na exclusao de um cod. barras
If lLj7210Exc 
	cDel := "U_LJ7210EXC()"
EndIf

 
If lAuto
	FWMVCRotAuto(ModelDef(),"SLK",nOpcAuto,{{"LOJA210_SLK",aAuto}})
Else	
	aRotina := MenuDef()
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('SLK')
	oBrowse:SetDescription(OemToAnsi(STR0001))
	If hasSmartX()
		oBrowse:SetSmartX()
	EndIf
	oBrowse:Activate()	
EndIf


Return NIL

//-------------------------------------------------------------------
/* {Protheus.doc} MenuDef
Menu Funcional

@author Vendas & CRM
@since 02/08/2012
@version 11
@return  aRotina - Array com as opcoes de menu

*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina := {}

If !hasSmartX()
	ADD OPTION aRotina TITLE STR0003 ACTION "PesqBrw"           OPERATION 0                           ACCESS 0 //"Pesquisar"
Endif 
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.LOJA210"   OPERATION MODEL_OPERATION_VIEW         ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.LOJA210"     OPERATION MODEL_OPERATION_INSERT      ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.LOJA210"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.LOJA210"     OPERATION MODEL_OPERATION_DELETE     ACCESS 0 //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/* {Protheus.doc} ModelDef
Definicao do Modelo de dados

@author Vendas & CRM
@since 02/08/2012
@version 11
@return  oModel - Retorna o model com todo o conteudo dos campos preenchido

*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructSLK 	:= FWFormStruct(1,"SLK") 	//Estrutura da tabela SLK
Local oModel 		:= Nil						// Objeto do modelo de dados
Local oEventMain 	:= Nil						//Objeto do tipo LOJA210EVDEF, responsável por tratar os eventos do formulário	

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA210", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
oModel:AddFields("LOJA210_SLK", Nil/*cOwner*/, oStructSLK ,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
oModel:GetModel("LOJA210_SLK"):SetDescription(STR0001)

oEventMain := LOJA210EVDEF():New()
oModel:InstallEvent('LOJA210EVDEF', /*cOwner*/, oEventMain)

Return oModel

//-------------------------------------------------------------------
/* {Protheus.doc} ViewDef
Definicao da Interface do programa.

@author		Vendas & CRM
@version	11
@since 		02/08/2012
@return		oView - Retorna o objeto que representa a interface do programa

*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView  		:= Nil						//Objeto da interface
Local oModel  		:= FWLoadModel("LOJA210")	//Objeto do modelo de dados
Local oStructSLK 	:= FWFormStruct(2,"SLK")	//Estrutura da tabela SLK

//Não permite alteração do campo
If oStructSLK:HasField("LK_DTHRALT")
    oStructSLK:SetProperty("LK_DTHRALT", MVC_VIEW_CANCHANGE, .F.)
EndIf

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)   
oView:EnableControlBar(.T.)  
oView:AddField( "LOJA210_SLK" , oStructSLK )
oView:CreateHorizontalBox( "HEADER" , 100 )
oView:SetOwnerView( "LOJA210_SLK" , "HEADER" )
                
Return oView

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Lj210TudOkºAutor  ³Danilo Calil        º Data ³  27/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a validacao do codigo de barras. Se esta amarrado  º±±
±±º          ³ a outro produto.                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj210TudOk(oModel)

    Local lRet      := .T.  //Retorno da funcao
    Local nOpc      := 0	//Numero da operacao (1: Visualizacao, 3: Inclusao, 4: Alteracao, 5: Exclusao)
    Local cCodigo   := ""
    Local cCodBar   := ""
    Local nQuant    := ""
    Local cDataHora := ""

    Default oModel := Nil

    //Verifica se é MVC
    If oModel <> Nil

        nOpc    := oModel:GetOperation()
        cCodigo := oModel:GetValue("LOJA210_SLK", "LK_CODIGO")
        cCodBar := oModel:GetValue("LOJA210_SLK", "LK_CODBAR")
        nQuant  := oModel:GetValue("LOJA210_SLK", "LK_QUANT")
    Else

        If INCLUI
            nOpc := 3
        ElseIf ALTERA
            nOpc := 4
        Else
            nOpc := 5
        EndIf
        
        cCodigo := M->LK_CODIGO
        cCodBar := M->LK_CODBAR
        nQuant  := M->LK_QUANT
    EndIf

    //Efetua as validações do formulario
    lRet := Valida(nOpc, cCodigo, cCodBar, nQuant)

    //A cada alteração grava data e hora
    If lRet .And. (nOpc == 3 .Or. nOpc == 4) .And. SLK->( FieldPos("LK_DTHRALT") > 0 )

        cDataHora := DtoS( Date() ) + " " + Left(Time(), 5)

        If oModel <> Nil
            oModel:GetModel("LOJA210_SLK"):LoadValue("LK_DTHRALT", cDataHora)
        Else
            M->LK_DTHRALT := cDataHora
        EndIf
    EndIf
	
Return lRet

//-------------------------------------------------------------------
/* {Protheus.doc} Valida
Efetua as validações do formulario.

@param	nOpc    - Operação sendo realizada
@param	cCodigo - Código do produto
@param	cCodBar - Código de barras
@param	nQuant  - Quantidade
@return lRet    - Define se as informações são validas
*/
//-------------------------------------------------------------------
Static Function Valida(nOpc, cCodigo, cCodBar, nQuant)

    Local lRet 	    := .T.
    Local aArea     := GetArea()
    Local aAreaSLK  := SLK->( GetArea() )
    Local cErro     := ""

    //Valida se o codigo de barra esta cadastrado para outro produto
    lRet := LjxValCBar(cCodigo, cCodBar)

    If !lRet
        cErro := STR0013 + " (LjxValCBar)"      //"Erro ao validar digitação do código de barras."
    Else

        If nQuant  <= 0  
            lRet  := .F.
            cErro := STR0012    //"Quantidade deve ser maior que 0"
            Help("", 1, "LJ210BQTD", , cErro, 1, 0)
        EndIf

        If lRet .And. (nOpc == 3 .Or. nOpc == 4) .And. Alltrim(cCodigo) = Alltrim(cCodBar) .And. nQuant <= 0
            lRet  := .F.
            cErro := STR0010 + CRLF + CRLF + STR0011    //###"O código de barras (LK_CODBAR) não deverá ser igual ao código do produto (LK_CODIGO) para quantidades (LK_QUANT) maiores que 1."###"Cadastre o código de barras diferente do código do produto."
            Help("", 1, "LJ210CBAR", , cErro, 1, 0)
        EndIf
    EndIf 

    //Responsavel em enviar os dados do codigo de barra para integracao
    If lRet .And. (nOpc == 3 .Or. nOpc == 4) .And. lAmbOffLn 
        LJ210AltOk()
    EndIf

    If lRet .And. nOpc == 5 .And. ExistBlock("LJ7210EXC") 
        lRet := ExecBlock("LJ7210EXC")
        If ValType(lRet) <> "L"
            lRet := .T.
            LjGrvLog(cCodBar, STR0014 + " (LJ7210EXC)")     //"Retorno incorreto do Ponto de Entrada."
        EndIf
    EndIf

    If !lRet
        LjGrvLog(cCodBar, cErro)
    EndIf

    RestArea(aAreaSLK)    
    RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LJ210AltOk³ Autor ³ Vendas cliente		³ Data ³ 31/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Responsavel em enviar os dados do codigo de barra para     ³±±
±±³			 ³ integracao  												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de produto	                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ210AltOk()

    Local aArea         := GetArea()
    Local aAreaSLK      := SLK->( GetArea() )
    Local cTipo 		:= ""                       //Como os dados serao integrados no processo offline    
    Local oProcessOff 	:= Nil                      //Objeto do tipo LJCProcessoOffLine

    //Verifica se o ambiente esta em off-line
    If lAmbOffLn

        //Instancia o objeto LJCProcessoOffLine
        oProcessOff := LJCProcessoOffLine():New("011")
        
        //Determina o tipo de operacao 
        If INCLUI
            cTipo := "INSERT"
        ElseIf ALTERA
            cTipo := "UPDATE"
        Else
            cTipo := "DELETE"
            
            //Considera os registros deletados
            SET DELETED OFF
        EndIf
                
        If !Empty(cTipo)
            //Insere os dados do processo (registro da tabela)
            oProcessOff:Inserir("SLK", xFilial("SLK") + SLK->LK_CODIGO + SLK->LK_CODBAR, 2, cTipo)	
                
            //Processa os dados 
            oProcessOff:Processar()	
        EndIf
        
        //Desconsidera os registros deletados
        SET DELETED ON
    EndIf

    RestArea(aAreaSLK)
    RestArea(aArea)
	
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj210Integ³ Autor ³ Vendas Cliente        ³ Data ³ 14/10/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusao do Codigo de Barras na integracao de Produtos via ³±±
±±³          ³ Mensagem Unica - MATI010.                	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Cadastro de Produtos					                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj210Integ(nEvento, cCode, aBarCode, cMarca)

Local cValInt		:= "" //Codigo interno utilizado no De/Para de codigos - Tabela XXF
Local cValExt		:= "" //Codigo externo utilizado no De/Para de codigos - Tabela XXF
Local cAliasTmp 	:= "SLK" //Alias temporario
Local cFieldTmp  	:= "LK_CODBAR" //Campo temporario
Local cWhere 	  	:= "" //Condicao da query
Local cAliasSLK 	:= GetNextAlias() //Alias temporario
Local nI 			:= 0  //Contador
Local nOpcX			:= 3 //Opcao do ExecAuto
Local aCab			:= {} //Array contendo Codigos de Barra do Produto
Local aIntBarCode	:= {} //Array contendo InternalIds de Codigo de Barras
Local aAux			:= {} //Array auxiliar
							
Private lMsErroAuto := .F.

//Condicional para a query		
cWhere := "%"
cWhere += " LK_FILIAL = '" + xFilial("SLK") + "'"
cWhere += " AND LK_CODIGO = '" + PadR(cCode, TamSX3("B1_COD")[1]) + "'"
cWhere += " AND SLK.D_E_L_E_T_ = ''"   		   			
cWhere += "%" 

//Executa a query
BeginSql alias cAliasSLK
	SELECT 
		LK_CODBAR 
	FROM %table:SLK% SLK							
	WHERE %exp:cWhere% 			
EndSql

(cAliasSLK)->(dbGoTop()) //Posiciona no inicio do arquivo temporario

//Eventos de Inclusao/Alteracao
If nEvento <> 5		          	       	
	For nI := 1 To Len(aBarCode)			 			
		lMsErroAuto := .F.
		aCab := {} //Inicializa array
		
		//Verifica se cupom já foi integrado
		aAux := IntCodeBInt(aBarCode[nI][2], cMarca)
		
		//Se encontrou o cupom no de-para
      	If ValType(aAux) == "A" .And. Len(aAux) > 0 .And. aAux[1]
      		nOpcX := 4 //Alteracao de Codigo de Barras
      	Else
      		nOpcX := 3 //Inclusao de Codigo de Barras
      	EndIf
					
		//Armazena informacoes no array
		aAdd(aCab, {"LK_CODBAR"	, PadR(aBarCode[nI][1], TamSx3("LK_CODBAR")[1])	, Nil}) //Codigo de Barras
		aAdd(aCab, {"LK_CODIGO"	, PadR(cCode, TamSx3("LK_CODIGO")[1])				, Nil}) //Codigo do Produto					       	
		aAdd(aCab, {"LK_QUANT"	, aBarCode[nI][4]										, Nil}) //Quantidade do Produto					       	
	
		//Monta o InternalId de produto que será gravado na table XXF (de/para)
		cValInt := IntCodeBExt(/*Empresa*/, /*Filial*/, aBarCode[nI][1])[2]
		
		//Efetua o cadastro (Inclusao/Alteracao)         				         					
		MSExecAuto({|x,y| LOJA210(x,y)}, aCab, nOpcX)
			
		If !lMsErroAuto																			
			If CFGA070Mnt(cMarca, cAliasTmp, cFieldTmp, aBarCode[nI][2], cValInt)
				aAdd(aIntBarCode, {aBarCode[nI][2], cValInt}) //Armazena InternalId para retorno
			EndIf						
		EndIf					
	Next nI
	
	//Tratamento para exclusao de Codigos de Barras que nao foram enviados na integracao de alteracao
	//Deverao ser excluidos
	While (cAliasSLK)->(!EOF())
		//Compara Codigos de Barras da Base com os enviados na alteracao
		If aScan(aBarCode, {|x| AllTrim(x[1]) == AllTrim((cAliasSLK)->LK_CODBAR)}) == 0
			//Codigo de Barras nao enviado, sera excluido
			nOpcX := 5
			lMsErroAuto := .F.
			aCab := {} //Inicializa array
			
			//Armazena informacoes no array
			aAdd(aCab, {"LK_CODBAR", (cAliasSLK)->LK_CODBAR, Nil}) //Codigo de Barras
		
			//Efetua o cadastro (Exclusao)         				         					
			MSExecAuto({|x,y| LOJA210(x,y)}, aCab, nOpcX)
			
			If !lMsErroAuto
				//------------------------------------------------------------
				//Tratamento utilizando a tabela XXF com um De/Para de codigos
				//------------------------------------------------------------ 			
				cValInt := IntCodeBExt(/*Empresa*/, /*Filial*/, aCab[1][2])[2]
			
				//Busca ExternalId do Produto
				cValExt := CFGA070Ext(cMarca, cAliasTmp, cFieldTmp, cValInt)
			
				//Exclui registro da Tabela XXF (de/para)
				If CFGA070Mnt(cMarca, cAliasTmp, cFieldTmp, cValExt, cValInt, .T.)								
					//aAdd(aIntBarCode, {cValExt, cValInt}) //Armazena InternalId para retorno 				
				EndIf			
			EndIf
		EndIf	
	
		(cAliasSLK)->(dbSkip())
	EndDo	
ElseIf nEvento == 5 //Evento de Exclusao do Produto
	//Verifica Codigos de Barras existentes
	While (cAliasSLK)->(!EOF()) 	
		nOpcX := 5
		lMsErroAuto := .F.
		aCab := {} //Inicializa array
		
		//Armazena informacoes no array
		aAdd(aCab, {"LK_CODBAR", (cAliasSLK)->LK_CODBAR, Nil}) //Codigo de Barras
		
		//Efetua o cadastro (Exclusao)         				         					
		MSExecAuto({|x,y| LOJA210(x,y)}, aCab, nOpcX)
				 		
		If !lMsErroAuto					
			//------------------------------------------------------------
			//Tratamento utilizando a tabela XXF com um De/Para de codigos
			//------------------------------------------------------------ 			
			cValInt := IntCodeBExt(/*Empresa*/, /*Filial*/, aCab[1][2])[2]
		
			//Busca ExternalId do Produto
			cValExt := CFGA070Ext(cMarca, cAliasTmp, cFieldTmp, cValInt)
		
			//Exclui registro da Tabela XXF (de/para)
			If CFGA070Mnt(cMarca, cAliasTmp, cFieldTmp, cValExt, cValInt, .T.)								
				//aAdd(aIntBarCode, {cValExt, cValInt}) //Armazena InternalId para retorno				
			EndIf			
		EndIf
							
		(cAliasSLK)->(dbSkip())
	EndDo
EndIf	

//Fecha arquivo temporario
If (Select(cAliasSLK) > 0)
	(cAliasSLK)->(dbCloseArea())	
EndIf

Return aIntBarCode

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntCodeBInt

Recebe um InternalID e retorna o código de Barras Protheus

@param   cInternalID	InternalID recebido na mensagem
@param   cRefer    	Produto que enviou a mensagem 
@param   cVersao  		Versão da mensagem única (Default 1.000)

@author  Vendas Cliente      
@version P12
@since   02/10/2015
@return  Array contendo no primeiro parâmetro uma variável logica
		  indicando se o registro foi encontrado no de/para
		  No segundo parâmetro uma variável array com empresa, filial
		  e o codigo de barras.
/*/
//-------------------------------------------------------------------------------------------------
Function IntCodeBInt(cInternalID, cRefer)
   
Local aResult  := {}
Local aTemp    := {}
Local cTemp    := ""
Local cAlias   := "SLK"
Local cField   := "LK_CODBAR"

cTemp := CFGA070Int(cRefer, cAlias, cField, cInternalID)
   
If Empty(cTemp)
	aAdd(aResult, .F.)
	aAdd(aResult, "Codigo de Barras" + " " + AllTrim(cInternalID) + " " + "nao encontrado no de/para!") 
Else	
	aAdd(aResult, .T.)
   	aTemp := Separa(cTemp, "|")
   	aAdd(aResult, aTemp)	     	
EndIf
  
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntCodeBExt

Monta o InternalID do Codigo de Barras de acordo com codigo passado

@param   cEmpresa	Código da empresa (Default cEmpAnt)
@param   cFil    	Código da Filial (Default cFilAnt) 
@param   cBarCode Código de Barras
@param   cVersao  Versao da Mensagem

@author  Vendas Cliente      
@version P12
@since   02/10/2015
@return  Array contendo no primeiro parâmetro uma variável logica
		  indicando se o registro foi encontrado
		  No segundo parâmetro uma variável string com o InternalID
		  montado              

/*/
//-------------------------------------------------------------------------------------------------
Function IntCodeBExt(cEmpresa, cFil, cBarCode)
   
Local aResult := {}

Default cEmpresa 	:= cEmpAnt
Default cFil     	:= xFilial("SLK")
Default cBarCode	:= ""

aAdd(aResult, .T.)
aAdd(aResult, cEmpresa + "|" + cFil + "|" + PadR(cBarCode, TamSx3("LK_CODBAR")[1])) 					
   
Return aResult

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao de tratamento para o recebimento/envio de mensagem unica de cadastro 
de clientes. 

@sample		IntegDef( cXml, nTypeTrans, cTypeMessage )
@param		ExpC1 = Conteúdo XML 
			ExpN1 = Tipo dtransação
			ExpC2 = Tipo de Menssagem 
@return		aRet
@author		Felipe Sales Martinez    
@since		30/01/2017
@version	12.1.14
/*/
//-------------------------------------------------------------------------------------------------
Static Function IntegDef( cXml, nTypeTrans, cTypeMessage )
Local aRet		:= {}
Local BkpALTERA	:= .F.
Local aSB1Area	:= {}

//Posicionamos o SB1 para correto funcionamento da mensagem unica MATI010 
If nTypeTrans == "1" //Envia
	aSB1Area := SB1->(GetArea())

	SB1->(DBSetOrder(1)) //"B1_FILIAL+B1_COD"
	If SB1->(DBSeek(xFilial("SB1")+SLK->LK_CODIGO)) 
		//Tratamento ncessário para que não seja enviado uma exclusão do produto
		If !INCLUI .And. !ALTERA
			BkpALTERA	:=	ALTERA
			Altera		:=	.T.
		Else
			BkpALTERA	:=	ALTERA
		EndIf
	EndIf

EndIf

//a funcao integdef original foi transferida para o fonte mati030, conforme novas regras de mensagem unica.
aRet:= MATI010( cXml, nTypeTrans, cTypeMessage )

If Len(aSB1Area) > 0
	//Restaura o valor original
	ALTERA := BkpALTERA 
	RestArea(aSB1Area)
EndIf

Return aRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Lj210VBar
A função tem como objetivo realizar a validação do codigo de barras 
Esta função foi adicionada pelo fato de quando executar via execauto e usar a funçã do framework essa 
não realizar a validação do ok.

@sample		Lj210VBar()

@return		lRet retorno Logico caso a validação seja correta retorna verdadeiro.
@author		Rene Julian     
@since		28/05/2018
@version	12.1.17
/*/
//-------------------------------------------------------------------------------------------------
Function Lj210VBar()
Local lRet := .T.
If M->LK_QUANT  <= 0
	Help("",1,"LJ210BQTD",,STR0012,1,0)  // "Quantidade deve ser maior que 0"
	lRet := .F. 
EndIf  

If lRet 
	lRet := LjxValCBar( M->LK_CODIGO , M->LK_CODBAR )
EndIf
	 
If lRet .And. (Alltrim(M->LK_CODIGO) = Alltrim(M->LK_CODBAR)) .And. (M->LK_QUANT <= 0)
	Help("",1,"LJ210CBAR",,STR0010 + CRLF + CRLF + STR0011,1,0) //###"O código de barras (LK_CODBAR) não deverá ser igual ao código do produto (LK_CODIGO) para quantidades (LK_QUANT) maiores que 1."###"Cadastre o código de barras diferente do código do produto."
	lRet := .F. 
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA210EVDEF
Eventos padrão do cadastro de Código de Barras (SLK).

As regras definidas aqui se aplicam a todos os paises.
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente.

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type    Class
@author  cruz.rafael
@since   12/05/2026
@version 12

/*/
//-------------------------------------------------------------------
CLASS LOJA210EVDEF From FWModelEvent
	DATA nOpc        as Numeric
	Data aModelD3Q   as Array // Model para operações em fator de conversão (D3Q)
	DATA cProblema   as Character
	DATA cSolucao    as Character

	METHOD new() CONSTRUCTOR

	METHOD ModelPosVld()
	METHOD InTTS()
	METHOD LJ210Manut( nOperation, aData )

ENDCLASS

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} new
Método construtor da classe LOJA210EVDEF

@type    Method
@author  cruz.rafael
@since   12/05/2026
@version 12
/*/
//-------------------------------------------------------------------------------------------------------------
Method new() Class LOJA210EVDEF
	self:aModelD3Q := {}
	self:cProblema := ""
	self:cSolucao  := ""
Return Self

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pós validação do Model.

@author  Jorge Martins | Protheus Retail
@since   27/05/2026
@version 1.0
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class LOJA210EVDEF
Local lRet     as Logical
Local cProduto as Character
Local cCodBar  as Character
Local nQuant   as Numeric

Default oModel   := NIL
Default cModelId := ""
	
	self:aModelD3Q := {}

	If oModel <> NIL
		lRet := Lj210TudOk(oModel)
	
		If lRet .And. cModelId == "LOJA210" .And. !FwIsInCallStack("SINCSLK")
			::nOpc := oModel:GetOperation()

			cProduto := oModel:GetValue("LOJA210_SLK", "LK_CODIGO")
			cCodBar  := oModel:GetValue("LOJA210_SLK", "LK_CODBAR")
			nQuant   := oModel:GetValue("LOJA210_SLK", "LK_QUANT")

			lRet := ::LJ210Manut(::nOpc, cProduto, cCodBar, nQuant)
			
			If !lRet .And. !Empty(self:cProblema) .And. !Empty(self:cSolucao)
				Help('', 1, '', ProcName(0), self:cProblema, 1,,,,,,, {self:cSolucao})
			EndIf
		EndIf
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém antes do final da transação.

@type    Method
@author  cruz.rafael
@since   12/05/2026
@version 12

@param   oModel - Modelo de dados de Código de Barras (SLK)
@param   cModelId - Identificador do modelo
@return  lOk - .T. se os dados estão válidos e podem ser gravados

/*/
//-------------------------------------------------------------------
METHOD InTTS(oModel) CLASS LOJA210EVDEF

Default oModel := Nil

	If oModel <> Nil .And. !Empty(self:aModelD3Q) .And. Len(self:aModelD3Q) == 1
		self:aModelD3Q[1]:CommitData()
		self:aModelD3Q[1]:DeActivate()
		self:aModelD3Q[1]:Destroy()
	EndIf

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} LJ210Manut
	Método de manutenção do cadastro de Fator de Conversão (D3Q)

	@type       Método
	@param      nOpc , Numeric, Operação a ser realizada
	@param      cProduto , Character, Código do produto
	@param      cCodBar , Character, Código de barras
	@param      nQuant , Numeric, Quantidade
	@return     lRet , Logical, Indica se os valores foram setados com sucesso
	@author     Rafael Cruz / Squad Retail
	@since      06/02/2026
	@version    12.1.2610
/*/
//------------------------------------------------------------------------------
METHOD LJ210Manut(nOpc as Numeric, cProduto as Character, cCodBar as Character, nQuant as Numeric) CLASS LOJA210EVDEF
	Local oModelD3Q  As Object
	Local oGridLista As Object
	Local aMsgErro   As Array
	Local nX         As Numeric
	Local aAreaD3Q   As Array
	Local lRet       As Logical
	Local nQtdLinha  As Numeric

	Default nOpc     := 0
	Default cProduto := ""
	Default cCodBar  := ""
	Default nQuant   := 0

	lRet := .T.

	dbSelectArea("D3Q")

	If !Empty(cCodBar) .And. D3Q->(ColumnPos("D3Q_CODBAR")) > 0

		aAreaD3Q := D3Q->(GetArea())

		D3Q->(DbSetOrder(1))
		If D3Q->(MsSeeK(xFilial('D3Q') + cProduto))

			// Processa com FWLoadModel para manutenção do cadastro de Fator de Conversão
			oModelD3Q := FWLoadModel("ESTA0001")

			oModelD3Q:setOperation(MODEL_OPERATION_UPDATE)
			oModelD3Q:Activate()

			// Verifica se o Model foi ativado e se os valores foram setados corretamente
			If oModelD3Q:IsActive()

				oGridLista	:= oModelD3Q:GetModel("D3QDETAILS")

				nQtdLinha := oGridLista:GetQtdLine()
				If nQtdLinha > 0
					For nX := 1 To nQtdLinha
						If !oGridLista:IsDeleted(nX) .And. Alltrim(oGridLista:GetValue("D3Q_CODBAR", nX)) == Alltrim(cCodBar)
							oGridLista:GoLine(nX)
							If nOpc <> MODEL_OPERATION_DELETE
								oGridLista:SetValue("D3Q_FATOR", nQuant)
							Else
								oGridLista:SetValue("D3Q_CODBAR", "")
							EndIf
							Exit
						EndIf
					Next nX
				EndIf
			EndIf

			If oModelD3Q:VldData()
				Aadd(self:aModelD3Q, oModelD3Q)
			Else
				aMsgErro := oModelD3Q:GetErrorMessage()
				If Len(aMsgErro) >= 7 .And. ValType(aMsgErro[6]) == "C" .and. !Empty(aMsgErro[6])
					self:cProblema := aMsgErro[6]
					self:cSolucao  := aMsgErro[7] + CRLF + i18n(STR0015, {Alltrim(cProduto), AllTrim(cCodBar)}) // "Avalie o cadastro de Fator de Conversão (D3Q) do produto '#1' e código de barras '#2'."
				EndIf
				
				lRet := .F.
				self:aModelD3Q := {}

				oModelD3Q:DeActivate()
				FreeObj(oGridLista)
				FreeObj(oModelD3Q)

			EndIf

			RestArea(aAreaD3Q)
		EndIf
	EndIf

Return lRet
