#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "STBCONFCASH.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} STBValOpCash
Valida se o caixa ja esta aberto, caso não esteja, libera o usuario
para abertura do caixa, caso contrario bloqueia  

@param 	
@author  	Varejo
@version 	P11.8
@since   	04/04/2012
@return  	cChave - Retorna a chave da SLW
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STBValOpCash()

Local cChave		:= ""								//Recebe a chave da SLW que esta pendente
Local aId			:= STBInfoEst( 1, .F., .T. )	//Array com informacoes da SLG
Local cNumMov		:= AllTrim(STDNumMov()) 			//Retorno o numero do movimento atual
Local uRet			:= Nil								//Retorno da funcao LjUltMovAb

lContinue := STBRemoteExecute(	"LjUltMovAb"					,;
									{2,aId[1][1],"","","",.T.}	,;
									Nil								,;
									.F. 							,;
									@uRet			 				)

cChave := uRet

If lContinue

	If Empty(cChave) .Or. MsgNoYes(STR0001,STR0002) //"O fechamento deste caixa não foi atualizado na retaguarda, deseja continuar com a abertura do caixa ?" ## "Abertura de caixa"
	
		//Executa a função no PDV
		If Empty(cNumMov)

			cChave := STDUtMovAb(2,aId[1][1],"","","",.T.)	

		EndIf
	
	EndIf

EndIf

Return cChave