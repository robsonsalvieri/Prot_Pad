#include 'totvs.ch'
#include 'STDRecSelCust.ch'

Static aCustSele   := {} 

//-------------------------------------------------------------------
/*/{Protheus.doc} STDRSelCus()
Retorna relacao de cadastro de cliente pela busca por CGC

@param	  cCGC - recebe CPF ou CNPJ do cliente para busca de cadastro
@author  Joao Marcos Martins
@version 12.1.17
@since   08/03/2018
@return  aRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDRSelCus(cCGC)

Local aAreaSA1      := SA1->(GetArea())
Local aRet          := {}
Local nMVLJPEATU    := SuperGetMV("MV_LJPEATU",,1)    // Pesquisa retaguarda 0=Desabilitado, faz pesquisa Local. 1=Pesquisa retaguarda se falhar local. 2=Pesquisa somente retaguarda
Local aRetCli       := {} // Retorno da busca pelo cliente na retaguarda    
Local nX            := 1  // Contador do For

DbSelectArea("SA1")
SA1->(DbSetOrder(3))	//FILIAL + CGC	

// verifica primeiro na Retaguarda
If nMVLJPEATU <> 0

    STFMessage(ProcName(),"RUN",STR0001) //"Pesquisando cliente no Servidor. Aguarde..."
    STFShowMessage(ProcName())
    LjGrvLog( "Recebimento de Titulo", "Pesquisando cliente na Retaguarda", cCGC )
    CursorWait()

    aRetCli := STBGetCust(xFilial("SA1"),cCGC)
    
    If ValType(aRetCli) != "A" 
        LjGrvLog( "Recebimento de Titulo", "Não conseguiu Pesquisar na retaguarda ", cCGC ) 
    ElseIf Len(aRetCli) > 0

        For nX :=1 To Len(aRetCli)
            AADD(aRet, aRetCli[nX][1] + " / " + aRetCli[nX][2] + " / " + aRetCli[nX][3] + " / " +;
            		 Iif(Len(aRetCli[nX])>4,aRetCli[nX][5],"") )
        Next nX

    EndIf                
    
    CursorArrow()
    
ElseIf SA1->(DbSeek(xFilial("SA1")+AllTrim(cCGC))) .AND. nMVLJPEATU <> 2 // Se nao achar na Retaguarda busca no PDV
    
    LjGrvLog( "Recebimento de Titulo", "Pesquisando cliente no PDV ", cCGC )
    While SA1->(!EOF()) .AND. SA1->A1_FILIAL+AllTrim(SA1->A1_CGC) ==  xFilial("SA1")+AllTrim(cCGC)
            AADD(aRet, SA1->A1_COD + " / " + SA1->A1_LOJA + " / " + SA1->A1_NOME + " / " + SA1->A1_CGC )
            SA1->( dbSkip() )       
    EndDo


EndIf

STDSCustSele( aRet )

RestArea(aAreaSA1)
		
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDSCustSele()
Responsável por Atualizar os valores de aCustSele

@param	  aCadCli - Array com Codigo e Loja do Cliente que atualizará o array estático aCustSele
@author  Joao Marcos Martins
@version 12.1.17
@since   08/03/2018
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDSCustSele( aCadCli )

Default aCadCli := {}

aCustSele := aCadCli

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGCustTt()
Retorna array com codigo e loja do cliente 

@param	  aCadLoj  array com Codigo e Loja do Cliente
@author  Joao Marcos Martins
@version 12.1.17
@since   08/03/2018
@return  aRet
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDGCustTt(aCodLoj)

Local aRet       := {}
Local aAuxCodLoj := {} 

Default aCodLoj := {}

aAuxCodLoj := STDStr2Arr( aCodLoj, " / " )
AADD(aRet, PadR(aAuxCodLoj[01],TamSX3( "A1_COD" )[1]," "))
AADD(aRet, PadR(aAuxCodLoj[02],TamSX3( "A1_LOJA" )[1]," "))
		
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} STDGCustSele()
Responsável por retornar um array com o valor de aCustSele

@author  Joao Marcos Martins
@version 12.1.17
@since   08/03/2018
@return  aCustSele
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDGCustSele()
Return aCustSele

//-------------------------------------------------------------------
/*/{Protheus.doc} STDCallCustTit()
Responsável por Chamar a tela se seleção de título conforme a loja do cliente que foi selecionada 

@param	  nPos    - Posicao do Cliente selecionado no array aCadCli
@author  Joao Marcos Martins
@version 12.1.17
@since   08/03/2018
@return  
@obs
@sample
/*/
//-------------------------------------------------------------------
Function STDCallCustTit(nPos)

local aAux := {}
Local aCadCli := STDGCustSele() // Recupera conteudo a aCadCli

If Len(aCadCli) > 0
	aAux := STDGCustTt(aCadCli[nPos])
EndIf

STIFindTit( aAux )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} STDStr2Arr
Retorna array com código e loja do cliente com espaçõs em branco no código

@author  	Lucas Novais
@version 	P12.1.25
@since   	04/03/2020
@param   	cText, Caracter, String matriz com as informações que serão separadas
@param   	cToken, Caracter, Separador de conteúdo
@return		Array, Retorna informações sobre os clientes buscado		  
/*/
//-------------------------------------------------------------------

Function STDStr2Arr(cText,cToken)

Local aRet      := {}   //Variavel de Retorno
Local nEnd      := 1    //Variavel de controle para fim da String
Local nStart    := 1    //Variavel de controle para inicio da String

Default cText   := ""
Default cToken  := ";"

While nEnd < Len(cText) .And. nEnd > 0
    nEnd := At(cToken,cText,nStart)
    If nEnd == 0 
        nEnd := Len(cText)
    EndIf
    aAdd(aRet,substr(cText,nStart,nEnd - nStart ))
    nStart := nEnd + Len(cToken)
End

Return aRet