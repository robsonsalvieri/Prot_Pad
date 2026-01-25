#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"
#INCLUDE "PLSA260.ch"

/*/{Protheus.doc} PL260FD2EVDEF
Classe Responsavel pelo Evento de validações e  
atualizações do cadastro de Dados Comerciais da Família
@author    Guilherme Carreiro
@since     12/04/2024
/*/
Class PL260FD2EVDEF From FwModelEvent
Data oModel			As Object
Data cCodVenAnt		As Character
Data cCodVe2Ant		As Character
Data cCodEqpAnt		As Character

Method New() Constructor
Method AfterTTS( oModel, cIdModel  )
//Method After(oSubModel, cModelId, cAlias, lNewRecord)
//Method ModelPreVld( oModel, cModelId )
//Method ModelPosVld( oModel, cModelId )
//Method Before(oModel, cModelId)
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue)
Method BeforeTTS(oModel, cModelId, cCodVenAnt, cCodVe2Ant, cCodEqpAnt)
//Method InTTS(oModel, cModelId)

EndClass

/*/{Protheus.doc} new
Metodo construtor da classe
@author    Guilherme Carreiro
@since     12/04/2024
/*/
Method new() Class PL260FD2EVDEF
	Self:oModel := nil
	Self:cCodVenAnt := ""
	Self:cCodVe2Ant := ""
	Self:cCodEqpAnt := ""
Return Self

/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)
@author    Guilherme Carreiro
@since     12/04/2024
/*/
//Method After(oSubModel, cModelId, cAlias, lNewRecord) Class PL260FD2EVDEF
    //FWFormCommit( oSubModel )
//Return .T.

/*/{Protheus.doc} BeforeTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit antes da transação.
Esse evento ocorre uma vez no contexto do modelo principal.
@author    Guilherme Carreiro
@since     12/04/2024
/*/
Method BeforeTTS(oModel, cModelId) Class PL260FD2EVDEF
	
	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))

	Self:cCodVenAnt := BA3->BA3_CODVEN
	Self:cCodVe2Ant := BA3->BA3_CODVE2
	Self:cCodEqpAnt := BA3->BA3_EQUIPE

Return .T.

/*/{Protheus.doc} InTTS
Método que é chamado pelo MVC quando ocorrer as ações do commit Após as gravações porém 
antes do final da transação.
Esse evento ocorre uma vez no contexto do modelo principal.

@author    Guilherme Carreiro
@since     12/04/2024
/*/
// Method InTTS(oModel, cModelId) Class PL260FD2EVDEF
// Return .T.

/*/{Protheus.doc} ModelPosVld
Metodo responsavel por realizar a pos validação do modelo
@author    Guilherme Carreiro
@since     12/04/2024

/*/
// Method ModelPosVld( oModel, cModelId ) Class PL260FD2EVDEF
// Return .T.


/*/{Protheus.doc} ModelPreVld
Método que é chamado pelo MVC quando ocorrer as ações do commit
antes da gravação de cada submodelo (field ou cada linha de uma grid)
@author    Guilherme Carreiro
@since     12/04/2024
/*/
// Method Before(oSubModel, cModelId, cAlias, lNewRecord) Class PL260FD2EVDEF
// Return .T.

/*/{Protheus.doc} AfterTTS
Metodo Utilizado apos Concluido o Commit do Modelo
Realizo as integrações
@author    Guilherme Carreiro
@since     12/04/2024
/*/
Method AfterTTS( oModel, cIdModel ) Class PL260FD2EVDEF  
	Local lRet := .T.
	Local cCodVen := oModel:GetValue("MasterBA3","BA3_CODVEN")
	Local cCodVen2 := oModel:GetValue("MasterBA3","BA3_CODVE2")
	Local cCodEqp := oModel:GetValue("MasterBA3","BA3_EQUIPE")
	Local aArea	:= GetArea()

	If GetNewPar("MV_PLSRVEN",.F.)

		If (cCodEqp <> Self:cCodEqpAnt .Or. cCodVen <> Self:cCodVenAnt .Or. cCodVen2 <> Self:cCodVe2Ant)
			If MsgYesNo(STR0243,STR0242)
				//""Atenção"|"Foram identificadas alterações nos dados comerciais da família. Deseja replicar essas alterações para o nível do usuário?"
				//³ Se sim, o vendedor e a equipe dos usuarios serao os mesmos da familia...
				BA1->(DbSelectArea("BA1"))
				BA1->(DbSetOrder(1))
				BA1->(DbGoTop())
				If BA1->((MsSeek(xFilial("BA1")+BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))

					While !BA1->(eof())

						BA1->(RecLock("BA1",.F.))
						BA1->BA1_CODVEN := cCodVen
						BA1->BA1_CODVE2 := cCodVen2
						BA1->BA1_EQUIPE := cCodEqp
						BA1->(Msunlock())

					BA1->(dbSkip())
					EndDo
				EndIf
			Endif
		Endif
	EndIf

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} FieldPreVld
Método que é chamado pelo MVC quando ocorrer a ação de pré validação do Field
@param oSubModel , Modelo principal
@param cModelId  , Id do submodelo
@param nLine     , Linha do grid
@param cAction   , Ação executada no grid, podendo ser: ADDLINE, UNDELETE, DELETE, SETVALUE, CANSETVALUE, ISENABLE
@param cId     , nome do campo
@param xValue    , Novo valor do campo

@author    Guilherme Carreiro
@since     12/04/2024
/*/
//Method FieldPreVld(oModel, cModelID, cAction, cId, xValue) Class PL260FD2EVDEF
//Return .T.
