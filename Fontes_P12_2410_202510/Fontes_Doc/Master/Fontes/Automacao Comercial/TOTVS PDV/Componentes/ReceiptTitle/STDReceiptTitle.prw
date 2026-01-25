#INCLUDE "PROTHEUS.CH"
#INCLUDE "STPOS.CH"
#INCLUDE "AUTODEF.CH"
#INCLUDE "MSOBJECT.CH"

//------------------------------------------------------------------------------   
/*/{Protheus.doc} STDRecSE5
Função responsável por criar os registros na tabeal SE5 para serem exibidos na conferencia de 
caixa ao encerrar o caixa.

@param		aTit		- Lista com todos os titulos selecionados e baixados.
			aForm		- Lista com todas as formas de pgto utilizada na baixa.
			lEstorno	- é esotrno? (.T. = estorno/ .F. = baixa) 
@author		Varejo
@version	P11.8
@since		10/08/2015
@return		Nil
@obs     
@sample
/*/
//------------------------------------------------------------------------------
Function STDRecSE5(aTit, aForm, lEstorno,lOffLine)
Local nI		:= 1
Local cCashier	:= xNumCaixa()
Local cNumMov	:= STDNumMov()
Local lE5FORMAPG:= SE5->(FieldPos("E5_FORMAPG")) > 0
Local lE5ORIGEM	:= SE5->(FieldPos("E5_ORIGEM")) > 0
Local lE5NUMMOV	:= SE5->(FieldPos("E5_NUMMOV")) > 0
Local cNatRece	:= IIf( ExistFunc("LjMExePara"), LjMExeParam("MV_NATRECE"), &(SuperGetMV("MV_NATRECE")))
Local nOpcConf	:= SuperGetmv("MV_LJOPCON",,2)	//1-Conferencia em uma so forma (Recebimentos); 2-Conferencia por forma de pagamento
 
Default aTit		:= {}
Default aForm		:= {}
Default lEstorno	:= .F.
Default lOffLine 	:= .F. //Processo offline

LjGrvLog( "Recebimento_Titulo", "Executando STDRecSE5. MV_NATRECE:",cNatRece)
LjGrvLog( "Recebimento_Titulo", "Executando STDRecSE5. MV_LJOPCON:",nOpcConf)

SA6->(dbSetOrder(2))
SA6->(dbSeek(xFilial("SA6") + Upper(cCashier)))

//Foi serpado a geração dos registro na tabela SE5 para que seja possivel na conferencia de caixa
//exibir os recebimento ou por formas de pagamentos ou por apenas uma forma de pagamento (esta ultima
//ficando igual a red.z)
//Este SE5 não devera subir para a retaguarda.
If nOpcConf == 2 .And. lE5FORMAPG
	
	For nI := 1 To Len(aForm)
	
		If Reclock("SE5",.T.)
			REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
			REPLACE SE5->E5_DATA	WITH dDataBase
			REPLACE SE5->E5_TIPO	WITH "FI"
			REPLACE SE5->E5_BANCO	WITH cCashier
			REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
			REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
			REPLACE SE5->E5_RECPAG	WITH Iif(lEstorno , "P", "R")
			REPLACE SE5->E5_HISTOR	WITH Iif(lEstorno,"Cancel de baixa","Receb Titulo")+IIF(lOffLine, "OffLine - ", " - ") +aForm[nI][3]+"/"+aForm[nI][4]+"/"+aForm[nI][5]
			REPLACE SE5->E5_TIPODOC	WITH Iif(lEstorno ,"ES","VL")
			If lE5FORMAPG
				REPLACE SE5->E5_FORMAPG	WITH AllTrim(aForm[nI][1])
			EndIf
			If lE5ORIGEM
				REPLACE SE5->E5_ORIGEM	WITH "LOJXREC"
			EndIf
			REPLACE SE5->E5_VALOR	WITH aForm[nI][2]
			REPLACE SE5->E5_DTDIGIT	WITH dDataBase
			REPLACE SE5->E5_DTDISPO	WITH SE5->E5_DATA
			REPLACE SE5->E5_NATUREZ	WITH cNatRece
			If lE5NUMMOV
				Replace SE5->E5_NUMMOV	WITH cNumMov
			EndIf   
			REPLACE SE5->E5_PREFIXO	WITH aForm[nI][3]
			REPLACE SE5->E5_NUMERO	WITH aForm[nI][4]
			SE5->(dbCommit())
			SE5->(MsUnLock())
		EndIf
	Next

Else

	For nI := 1 To Len(aTit)
	
		If Reclock("SE5",.T.)
			REPLACE SE5->E5_FILIAL	WITH xFilial("SE5")
			REPLACE SE5->E5_DATA	WITH dDataBase
			REPLACE SE5->E5_TIPO	WITH "FI"
			REPLACE SE5->E5_BANCO	WITH cCashier
			REPLACE SE5->E5_AGENCIA	WITH SA6->A6_AGENCIA
			REPLACE SE5->E5_CONTA	WITH SA6->A6_NUMCON
			REPLACE SE5->E5_RECPAG	WITH Iif(lEstorno , "P", "R")
			REPLACE SE5->E5_HISTOR	WITH Iif(lEstorno,"Cancel de baixa","Receb Titulo")+IIF(lOffLine, "OffLine - ", " - ")+aTit[nI][2]+"/"+aTit[nI][3]+"/"+aTit[nI][4]
			REPLACE SE5->E5_TIPODOC	WITH Iif(lEstorno ,"ES","VL")
			If lE5FORMAPG .And. Len(aForm) > 0 // Colocamos esse tratamento, pois na retaguarda mesmo com o parâmetro igual a 1 estava realizando a gravação deste campo. 
				REPLACE SE5->E5_FORMAPG	WITH AllTrim(aForm[nI][1])
			EndIf
			If lE5ORIGEM
				REPLACE SE5->E5_ORIGEM	WITH "LOJXREC"
			EndIf
			REPLACE SE5->E5_VALOR	WITH aTit[nI][10]
			REPLACE SE5->E5_DTDIGIT	WITH dDataBase
			REPLACE SE5->E5_DTDISPO	WITH SE5->E5_DATA
			REPLACE SE5->E5_NATUREZ	WITH cNatRece
			If lE5NUMMOV
				Replace SE5->E5_NUMMOV	WITH cNumMov
			EndIf   
			REPLACE SE5->E5_PREFIXO	WITH aTit[nI][2]
			REPLACE SE5->E5_NUMERO	WITH aTit[nI][3]
			SE5->(dbCommit())
			SE5->(MsUnLock())
		EndIf
	Next 
EndIf

Return Nil
