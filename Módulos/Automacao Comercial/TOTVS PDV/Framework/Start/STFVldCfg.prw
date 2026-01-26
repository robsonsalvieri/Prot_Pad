#INCLUDE "PROTHEUS.CH"
#INCLUDE "POSCSS.CH"
#INCLUDE "STFVLDCFG.CH"

//--------------------------------------------------------
/*/{Protheus.doc} STFVldCfg
Faz validações importantes para o correto funcionamento do PDV.
Podendo ser versõess de fonte, Lib, Binário, Dicionário etc.
@type function
@author  	rafael.pessoa
@since   	18/11/2016
@version 	P12
@param 		
@return	Nil
/*/
//--------------------------------------------------------
Function STFVldCfg()

Local cMsg := ""	//Mensagem
Local lRet := .T.	//Retorno

LjGrvLog( "Valida_Config" , "ID_INICIO" )

//validacao compartilhamento tabelas
STFVldComp()

lRet := STFVldIdx()

LjGrvLog( "Valida_Config" , "ID_FIM" )

Return lRet


//--------------------------------------------------------
/*/{Protheus.doc} STFVldComp
Valida compartilhamento da tabelas
@type function
@author  	rafael.pessoa
@since   	18/11/2016
@version 	P12
@param 		
@return	Nil
/*/
//--------------------------------------------------------
Static Function STFVldComp()

Local cMsg := ""	//Mensagem
Local cSL1 := ""	//Controle compartilhamento
Local cSL2 := ""	//Controle compartilhamento
Local cSL4 := ""	//Controle compartilhamento

//validacao compartilhamento 1=Empresa
cSL1 := FWModeAccess("SL1",1)
cSL2 := FWModeAccess("SL2",1)
cSL4 := FWModeAccess("SL4",1)

If (cSL1 <> cSL2) .OR. (cSL1 <> cSL4) .OR. (cSL2 <> cSL4)
	cMsg +=  STR0001 + STR0002 + ": SL1(" + cSL1 + ") SL2(" +  cSL2 + ") SL4(" +  cSL4 + ")." + CHR(10) //"Nível " "Empresa" 
EndIf

//validacao compartilhamento 2=Unidade de Negócio
cSL1 := FWModeAccess("SL1",2)
cSL2 := FWModeAccess("SL2",2)
cSL4 := FWModeAccess("SL4",2)


If (cSL1 <> cSL2) .OR. (cSL1 <> cSL4) .OR. (cSL2 <> cSL4)
	cMsg += STR0001 + STR0003 + ": SL1(" + cSL1 + ") SL2(" +  cSL2 + ") SL4(" +  cSL4 + ")." + CHR(10) //"Nível " "Unidade de Negócio"
EndIf

//validacao compartilhamento 3=Filial
cSL1 := FWModeAccess("SL1",3)
cSL2 := FWModeAccess("SL2",3)
cSL4 := FWModeAccess("SL4",3)

If (cSL1 <> cSL2) .OR. (cSL1 <> cSL4) .OR. (cSL2 <> cSL4)
	cMsg += STR0001 + STR0004 + ": SL1(" + cSL1 + ") SL2(" +  cSL2 + ") SL4(" +  cSL4 + ")." + CHR(10) //"Nível " "Filial"
EndIf

If !Empty(cMsg)
	STFMessage(ProcName(),"POPUP",STR0005 + CHR(10)+ cMsg) //"Atenção, O compartilhamento das tabelas devem ser iguais."
	STFShowMessage(ProcName())
	LjGrvLog( "Valida_Config" , STR0005 + CHR(10)+ cMsg)
EndIf

Return Nil


//-----------------------------------------------------------------
/*/{Protheus.doc} STFVldIdx
Valida campo LI_SEQ e índice 1 se houver preenchido o campo LI_SEQ
@type function
@author  	marisa.cruz
@since   	16/01/2018
@version 	P12
@param 		
@return	Nil
/*/
//-----------------------------------------------------------------
Function STFVldIdx()

Local cMsg := ""								//Mensagem
Local lRet := .T.								//Retorno
Local aArea     := {}							//Guarda a área atual

#IFDEF TOP
	aArea     := GetArea()
	If SLI->(ColumnPos("LI_SEQ")) = 0	//Se o campo LI_SEQ não for criado
		cMsg += STR0007 + CHR(10)		//"Favor criar o campo LI_SEQ, caracter de 9 posições."
		cMsg += STR0008 + CHR(10)		//"Em seguida, "
		cMsg += STR0009 + CHR(10)		//"Favor alterar, na tabela SIX, o conteúdo da ordem 1 do índice em SLI: LI_FILIAL+LI_ESTACAO+LI_TIPO+LI_SEQ"	
		cMsg += STR0010 + CHR(10)		//"Favor alterar, na tabela SX2, campo X2_UNICO da chave SLI para: LI_FILIAL+LI_ESTACAO+LI_TIPO+LI_SEQ"	
	Else	//Pesquisar se tem LI_SEQ no conteúdo de SIX.
		SIX->(DbSetOrder(1))	//INDICE+ORDEM
		If SIX->(DbSeek("SLI1"))
			If At( "LI_SEQ",SIX->CHAVE )  = 0		//Verifico se o LI_SEQ está presente na ordem 1 do índice em SLI 
				cMsg += STR0009 + CHR(10)		//"Favor alterar, na tabela SIX, o conteúdo da ordem 1 do índice em SLI: LI_FILIAL+LI_ESTACAO+LI_TIPO+LI_SEQ"	
				cMsg += STR0010 + CHR(10)		//"Favor alterar, na tabela SX2, campo X2_UNICO da chave SLI para: LI_FILIAL+LI_ESTACAO+LI_TIPO+LI_SEQ"	
			EndIf
		EndIf
	EndIf
	If !Empty(cMsg)
		STFMessage(ProcName(),"POPUP",STR0006 + CHR(10)+ cMsg) //"Atenção!"
		STFShowMessage(ProcName())
		LjGrvLog( "Valida_Config" , STR0006 + CHR(10)+ cMsg)
		lRet := .F.
	EndIf
	RestArea(aArea)
#ENDIF

Return lRet

