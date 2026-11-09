#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"    
 
//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980EventBRAFIS
Classe responsável pelo evento das regras de negócio da 
localização Brasil fiscal.

@type 		Classe
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Class CRM980EventBRAFIS From FwModelEvent 
	
	Data lHistFiscal	As Logical
	Data aCmps			As Array
	Data lFacFis        As Logical
	Data cCodigo        As Character
	Data cLoja          As Character
		
	Method New() CONSTRUCTOR
	
	//---------------------
	// PosValid do Model.
	//---------------------
	Method ModelPosVld()
		
	//-------------------------------------------------------------------
	// Bloco com regras de negócio dentro da transação do modelo de dados.
	//-------------------------------------------------------------------
	Method InTTS()
	
	//-------------------------------------------------------------------
	// Bloco com regras de negócio após a transação do modelo de dados.
	//-------------------------------------------------------------------
	Method AfterTTS()
	
	Method Destroy()
			
EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo responsável pela construção da classe.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method New() Class CRM980EventBRAFIS
	Self:lHistFiscal	:= HistFiscal()
	Self:aCmps			:= {}
	Self:lFacFis        := IIf(FindFunction("FSA172VLD"), FSA172VLD(), .F.)
	Self:cCodigo        := ""
	Self:cLoja          := ""
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelPosVld
Método responsável por executar as validações das regras de negócio
do Fiscal antes da gravação do formulario.
Se retornar falso, não permite gravar.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel,cID) Class CRM980EventBRAFIS
	Local lValid 		:= .T.
	Local nOperation	:= oModel:GetOperation()
	Local oMdlSA1		:= oModel:GetModel("SA1MASTER")
	Local bCampoSA1  	:= { |x| SA1->(Field(x)) }

	Self:cCodigo := oModel:GetValue("SA1MASTER","A1_COD")
	Self:cLoja := oModel:GetValue("SA1MASTER","A1_LOJA")
	
	If ( nOperation == MODEL_OPERATION_UPDATE )
		
		If Self:lHistFiscal
			//---------------------------------------------
			// Salva dados antes da alteracao.
			//---------------------------------------------
			Self:aCmps := RetCmps("SA1",bCampoSA1)
			oMdlSA1:LoadValue("A1_IDHIST", IdHistFis())
		EndIf
		
	EndIf
Return lValid
 
//-------------------------------------------------------------------
/*/{Protheus.doc} InTTS
Método responsável por executar regras de negócio do Fiscal dentro da
transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		24/05/2017 
/*/
//-------------------------------------------------------------------
Method InTTS(oModel,cID) Class CRM980EventBRAFIS
	Local nOperation	:= oModel:GetOperation()
	
	If ( nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE )
		//---------------------------------------
		// Gravacao do Historico das alterações
		//---------------------------------------
		If Self:lHistFiscal
			GrvHistFis("SA1", "SS2", Self:aCmps ) 
		EndIf
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AfterTTS
Método responsável por executar regras de negócio do Fiscal depois da
transação do modelo de dados.

@type 		Método

@param 		oModel	,objeto	,Modelo de dados de Clientes.
@param 		cID		,caracter	,Identificador do sub-modelo.

@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/09/2018
/*/
//-------------------------------------------------------------------
Method AfterTTS(oModel, cID) Class CRM980EventBRAFIS

Local nOperation := oModel:GetOperation()
Local lCpoNomEnd := oModel:HasField("SA1MASTER", "A1_NOMEEND")
Local lEndComp   := .F.
Local aAreaSA1   := {}
Local cFilSA1    := xFilial("SA1")
Local cCGC       := ""

if findFunction("f164ProfOp")
	f164ProfOp('CUSTOMER',nOperation) // Otimizador do Perfil de Participantes
endIf

// Identifica se estamos inserindo um endereço irmão via Sincronismo da Grid
// ou se é uma rotina automática replicando dados para um CPF já existente
If lCpoNomEnd
	lEndComp := FwIsInCallStack("GrvSincSA1") .Or. FwIsInCallStack("RepInfoEnd")
	If !lEndComp .And. (Type("l030Auto") == "L" .And. l030Auto)
		aAreaSA1 := SA1->(FWGetArea())
		SA1->(dbSetOrder(3)) // A1_FILIAL + A1_CGC
		cCGC := oModel:GetValue("SA1MASTER", "A1_CGC")
		If SA1->(dbSeek(cFilSA1 + cCGC))
			While !SA1->(Eof()) .And. SA1->A1_FILIAL == cFilSA1 .And. SA1->A1_CGC == cCGC
				If SA1->A1_COD != Self:cCodigo
					lEndComp := .T.
					Exit
				EndIf
				SA1->(dbSkip())
			EndDo
		EndIf
		FwRestArea(aAreaSA1)
	EndIf
EndIf

// Não acionar o facilitador de dentro do FISA170 pois se o cliente estiver sendo cadastrado pela
// consulta padrão ele já será vinculado ao perfil.
If Self:lFacFis .And. nOperation == MODEL_OPERATION_INSERT .And. FunName() <> "FISA170"
	If lEndComp
		// É a inserção de um irmão (Endereço Complementar).
		// Copia o perfil fiscal do irmão mais velho (.F.)
		CRM980PfEnd(oModel, .F.)
	Else
		// É a inserção de um cliente novo (O primeiro do CPF ou um CNPJ normal).
		// Cria o perfil fiscal principal para ele
		FSA172FAC({"CLIENTE", Self:cCodigo, Self:cLoja})
		
		If lCpoNomEnd
			// Se ele preencheu endereços na grid, replica esse novo perfil para as linhas do grid (.T.)
			CRM980PfEnd(oModel, .T.)
		EndIf
	EndIf
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} Destroy
Metodo responsável por destruir os atributos da classe como 
arrays e objetos.

@type 		Método
@author 	Squad CRM / FAT
@version	12.1.17 / Superior
@since		19/05/2017 
/*/
//-------------------------------------------------------------------
Method Destroy() Class CRM980EventBRAFIS
	aSize(Self:aCmps,0)
	Self:aCmps := Nil
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CRM980PfEnd
Vincula o perfil do cliente principal (pai) aos endereços complementares (filhos).

Obs: Os endereços complementares são registros na SA1 porém aparecem 
como um grid no cliente principal. As informações do registro principal 
são replicadas para os endereços (incluindo os perfis tributários), 
exceto as informações relacionadas a endereço, que são preenchidas no grid.

@type     Function

@param    oModel , objeto, Modelo de dados de Clientes.
@param    lRegPai, logico, .T. commit do cliente principal (pai)
                           .F. commit do cliente endereço (filho)

@author   Squad CRM / FAT
@version  12.1.2610 / Superior
@since    26/06/2026
/*/
//-------------------------------------------------------------------
Static Function CRM980PfEnd(oModel, lRegPai)
	Local cAliasQry  as Character
	Local cCGC       as Character
	Local cQuery     as Character
	Local nParam     as Numeric
	Local nCliente   as Numeric
	Local cCodPerfil as Character
	Local cOper      as Character
	Local cCliente   as Character
	Local cLoja      as Character
	Local oGridEnd   as Object
	Local aClientes  as Array
	Local oQry       as Object

	Default oModel  := Nil
	Default lRegPai := .F.

	If oModel <> Nil .And. Findfunction("A980PesFis") .and. A980PesFis(oModel:GetModel("SA1MASTER"))

		cCGC      := oModel:GetValue("SA1MASTER", "A1_CGC")
		cAliasQry := GetNextAlias()
		nParam    := 1
		cOper     := "INCLUI"
		aClientes := {}

		cQuery :=  "SELECT F22.F22_FILIAL, F22.F22_CODIGO, F22.F22_CLIFOR, F22.F22_LOJA"
		cQuery +=   " FROM " + RetSqlName("F22") + " F22"
		cQuery +=  " INNER JOIN " + RetSqlName("SA1") + " SA1"
		cQuery +=     " ON SA1.A1_FILIAL = ?"
		cQuery +=    " AND SA1.A1_COD = F22.F22_CLIFOR"
		cQuery +=    " AND SA1.A1_LOJA = F22.F22_LOJA"
		cQuery +=    " AND SA1.A1_CGC = ?"
		cQuery +=    " AND SA1.D_E_L_E_T_ = ?"
		cQuery +=  " WHERE F22.F22_FILIAL = ?"
		cQuery +=    " AND F22.F22_TPPART = ?"
		cQuery +=    " AND F22.D_E_L_E_T_ = ?"

		oQry := FwExecStatement():New(cQuery)

		oQry:SetString(nParam++, xFilial('SA1'))
		oQry:SetString(nParam++, cCGC)
		oQry:SetString(nParam++, Space(1))
		oQry:SetString(nParam++, xFilial('F22'))
		oQry:SetString(nParam++, "2")
		oQry:SetString(nParam++, Space(1))

		oQry:OpenAlias(cAliasQry)

		If lRegPai
			// Na inclusão do registro pai, o perfil do cliente principal é replicado para os endereços complementares.
			oGridEnd := oModel:GetModel("SA1ENDCOMP")
			
			For nCliente := 1 To oGridEnd:GetQtdLine()
				If !oGridEnd:IsDeleted(nCliente)
					AAdd(aClientes, {oGridEnd:GetValue("A1_COD", nCliente), oGridEnd:GetValue("A1_LOJA", nCliente)})
				EndIf
			Next
		Else
			// Na alteração do registro pai, o perfil do cliente principal é replicado para os endereços complementares.
			AAdd(aClientes, {oModel:GetValue("SA1MASTER", "A1_COD"), oModel:GetValue("SA1MASTER", "A1_LOJA")})
		EndIf

		While !(cAliasQry)->(EOF())
			cCodPerfil := (cAliasQry)->F22_CODIGO
			
			For nCliente := 1 To Len(aClientes)
				cCliente := aClientes[nCliente][1]
				cLoja    := aClientes[nCliente][2]
				FSA164GF22(cCodPerfil, cOper, "2", cCliente, cLoja) // Faz o vínculo dos clientes endereço no mesmo perfil do cliente principal (pai) no Cfg Trib (tabela F22)
			Next

			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DBCloseArea())
		oQry:Destroy()
	EndIf

Return
