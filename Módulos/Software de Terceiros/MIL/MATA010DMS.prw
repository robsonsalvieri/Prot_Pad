#include 'protheus.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

#include 'MATA010DMS.ch'

#define _CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} MATA010DMS
Eventos padrão para o Produto quando MV_VEICULO igual a "S" - Modulos DMS
Se uma regra for especifica para um ou mais paises ela deve ser feita no evento do pais correspondente. 

Todas as validações de modelo, linha, pré e pos, também todas as interações com a gravação
são definidas nessa classe.

Importante: Use somente a função Help para exibir mensagens ao usuario, pois apenas o help
é tratado pelo MVC. 

Documentação sobre eventos do MVC: http://tdn.totvs.com/pages/viewpage.action?pageId=269552294

@type classe
 
@author Andre Luis Almeida
@since 28/03/2018
@version P12.1.17
 
/*/
CLASS MATA010DMS FROM FWModelEvent
	
	DATA cCodProduto
	DATA cCodGrupo
	DATA cCodIte
	DATA cCodGrpAnt
	DATA nOpc

	METHOD New() CONSTRUCTOR
	METHOD Activate()
	METHOD InTTS()
	METHOD ModelPosVld()
	Method VL0CanActivate()
	Method VldActivate()
	Method ModelDefVL0()
ENDCLASS

//-----------------------------------------------------------------
METHOD New() CLASS MATA010DMS

Return

/*/{Protheus.doc} Activate
Metodo executado no Activate das Telas

@type metodo
 
@author Andre Luis Almeida
@since 29/03/2018
@version P12.1.17
/*/
METHOD Activate(oModel) CLASS MATA010DMS
	::nOpc := oModel:GetOperation()

	If ::nOpc == MODEL_OPERATION_UPDATE // ALTERACAO
		::cCodGrpAnt := oModel:GetValue("SB1MASTER", "B1_GRUPO") // Quando ALTERAR - salvar Grupo Anterior
	EndIf
Return

/*/{Protheus.doc} ModelDefVL0

	@type method
	@author Vinicius Gati
	@since 18/07/2024
/*/
Method ModelDefVL0(oModel) Class MATA010DMS
	Local oStruct := Nil
	if FWAliasInDic("VL0", .F.)
		oStruct := FWFormStruct(1, 'VL0')
		oModel:AddFields("VL0FIELDS", "SB1MASTER", oStruct )
		oModel:SetRelation("VL0FIELDS", {{ 'VL0_FILIAL', 'xFilial("VL0")' }, { 'VL0_CODPEC', 'B1_COD' }}, VL0->(IndexKey(1)))
		oModel:GetModel("VL0FIELDS"):SetDescription(STR0001)
		oModel:GetModel("VL0FIELDS"):SetOptional(.F.)
	endif
Return .t.

/*/{Protheus.doc} VldActivate
Método que é chamado pelo MVC quando ocorrer as ações de pre 
validação do Model. Esse evento ocorre uma vez no contexto 
do modelo principal.

@param oModel, object, Objeto do model
@param cModelId, caracter, nome do model
@author  Marcia Junko
@since   25/08/2022/*/
//---------------------------------------------------------
Method VldActivate( oModel, cModelId ) Class MATA010DMS
	if FWAliasInDic("VL0", .F.)
    	self:ModelDefVL0( oModel )
	endif
Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo executado na pós validação do modelo, antes de realizar a gravação

@type metodo
 
@author Andre Luis Almeida
@since 28/03/2018
@version P12.1.17
/*/
METHOD ModelPosVld(oModel, cID) CLASS MATA010DMS
	Local lRet := .T.
	Local cMsg := ""
	
	::cCodProduto := oModel:GetValue("SB1MASTER", "B1_COD")
	::cCodGrupo   := oModel:GetValue("SB1MASTER", "B1_GRUPO")
	::cCodIte     := oModel:GetValue("SB1MASTER", "B1_CODITE")

	If ::nOpc == MODEL_OPERATION_INSERT .or. ::nOpc == MODEL_OPERATION_UPDATE

		If ::nOpc == MODEL_OPERATION_INSERT .and. !Empty(::cCodIte) // CODITE digitado
			lRet := ExistChav( "SB1" , ::cCodGrupo + ::cCodIte , 7 , .F. ) // NÃO permitir mesmo Grupo + CodIte ( SB1 indice 7 )
			If !lRet
				cMsg := _CRLF + RetTitle("B1_GRUPO")  + ::cCodGrupo
				cMsg += _CRLF + RetTitle("B1_CODITE") + ::cCodIte
				Help(" ",1,"JAGRAVEI",,cMsg,3,1) //Já existe Cod Item cadastrado! Verifique o campo B1_CODITE através do módulo SIGAVEI.
			EndIf
		Else // B1_CODITE não foi digitado
			If Empty(::cCodIte) 
				If strzero(nModulo,2) $ "11/14/41/" // Validar somente para os Modulos: 11-Veiculos, 14-Oficina e 41-Auto-Peças
					Help(" ",1,"OBRIGAT2",,RetTitle("B1_CODITE"),4,1)
					lRet := .f.
				Else
					oModel:SetValue( "SB1MASTER" , "B1_CODITE" , ::cCodProduto ) // Carregar com o mesmo conteudo do B1_COD
				EndIf
			EndIf
		EndIf

	EndIf

Return lRet

/*/{Protheus.doc} InTTS
Metodo executado logo após a gravação completa do modelo, mas dentro da transação

@type metodo
 
@author Andre Luis Almeida
@since 28/03/2018
@version P12.1.17 
/*/
METHOD InTTS(oModel,cModelId) CLASS MATA010DMS
	Local oVmi
	Local oVmiPars
	Local nCntFor    := 0
	Local aFilis     := {}
	Local cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial logada trabalha
	Local cBkpFilAnt := cFilAnt
	Local lGerDeman  := .f.
	Private oSqlHlp      := DMS_SqlHelper():New()

	If ::nOpc == MODEL_OPERATION_UPDATE // ALTERACAO

		If ::cCodGrpAnt != ::cCodGrupo // Se grupo foi modificado roda rotina de alteracao de grupo
			FGX_ALTGRU( ::cCodProduto , ::cCodIte , ::cCodGrpAnt , ::cCodGrupo )
		EndIf
		If ExistFunc('OFAGVmi') .and. ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
			oVmi     := OFAGVmi():New()
			If oVmi:EmUso()
				oVmiPars := OFAGVmiParametros():New()
				aFilis   := oVmiPars:filiais()
				For nCntFor := 1 to len(aFilis) // Fazer para todas as Filiais do VMI
					cFilAnt := aFilis[nCntFor]
					cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial posicionada trabalha
					If ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
						If oVmiPars:FilialValida(cFilAnt)
							oVMi:Trigger({;
								{'EVENTO', oVmi:oVmiMovimentos:DadosPeca},;
								{'ORIGEM', "MATA010DMS_InTTS_ALT"       },;
								{'PECAS' , {::cCodProduto              }} ;
							})
						EndIf
					EndIf
				Next
				cFilAnt := cBkpFilAnt
			Endif
		EndIf

		lGerDeman := .t.

	ElseIf ::nOpc == MODEL_OPERATION_INSERT // INCLUSAO

		If ExistFunc('OFAGVmi') .and. ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
			oVmi     := OFAGVmi():New()
			If oVmi:EmUso()
				oVmiPars := OFAGVmiParametros():New()
				aFilis   := oVmiPars:filiais()
				For nCntFor := 1 to len(aFilis) // Fazer para todas as Filiais do VMI
					cFilAnt := aFilis[nCntFor]
					cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial posicionada trabalha
					If ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
						If oVmiPars:FilialValida(cFilAnt)
							oVMi:Trigger({;
								{'EVENTO', oVmi:oVmiMovimentos:DadosPeca},;
								{'ORIGEM', "MATA010DMS_InTTS_INC"       },;
								{'PECAS' , {::cCodProduto              }} ;
							})
						EndIf
					EndIf
				Next
				cFilAnt := cBkpFilAnt
			Endif
		EndIf

		lGerDeman := .t.

	EndIf

	If lGerDeman .and. cMVMIL0006 == "JD"

		SBM->( DbSetOrder(1) )
		SBM->(DbSeek( xFilial("SBM") + ::cCodGrupo ))

		If SBM->(FieldPos("BM_VAIDPM")) > 0 .and. SBM->BM_VAIDPM == '1'

			//Gera demanda para a filial de origem
			oDados := DMS_DataContainer():New({;
				{'VB8_FILIAL' , xFilial("VB8")  },;
				{'VB8_PRODUT' , ::cCodProduto   },;
				{'VB8_CRICOD' , oModel:GetValue("SB1MASTER","B1_CRICOD")  },;
				{'VB8_ANO'    , cValToChar(YEAR(dDataBase))   },;
				{'VB8_MES'    , cValToChar(StrZero(MONTH(dDataBase),2))  },;
				{'VB8_DIA'    , cValToChar(StrZero(DAY(dDataBase),2))    },;
				{'VB8_LOCAL'  , IIF(SBM->BM_PROORI == "1","D1","N1") },;
				{'VB8_TIPLOC' , IIF(SBM->BM_PROORI == "1","M","N") },;
				{'VB8_STOCK'  , "S"},;
				{'VB8_TIPREG' , "D"},;
				{'VB8_PROCES' , "N"};
			})

			oDem := DMS_DataContainer():New({;
				{'VB8_HITSI' , 0},;
				{'VB8_VDAI'  , 0},;
				{'VB8_IMEDI' , 0},;
				{'VB8_HIPERI', 0};
			})

			ONJD3101_GravaDem(oDados, oDem, .t.)
		
		EndIf
	
	EndIf

Return

function MT010DMS014_ViewDMS(oView)
	if FWAliasInDic("VL0", .F.)
		oStruct := FWFormStruct( 2, 'VL0' )
		oStruct:RemoveField("VL0_CODPEC")
		oView:AddField("VL0FIELDS", oStruct, "VL0FIELDS")
		oView:EnableTitleView('VL0FIELDS', STR0001)

		oView:CreateHorizontalBox('FOLDER_DMS', 10)
		oView:SetOwnerView('VL0FIELDS', 'FOLDER_DMS')
		oView:EnableTitleView('VL0FIELDS', STR0001)
	endif
return
