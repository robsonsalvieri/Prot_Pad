#include "protheus.ch"
#include "TECXSV.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc) TECXSV
Validações genéricas para relatórios em smartview
/*/
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc) TecConvData
Exemplo de função para converter a data para o formato 'YYYYMMDD'

@param cData character - Data a ser convertida
@author julia.marcela
@since 29/01/2025
@version 1.0
*/
//-------------------------------------------------------------------
Function TecConvData( cData as character)
    Local cDataConvertida := ""

    // Remove a parte de hora e fuso horário da data
    cData := SubStr(cData, 1, 10)

    // Substituir os separadores "-" por vazio
    cDataConvertida := StrTran(cData, "-", "")

Return stod(cDataConvertida) 

//-------------------------------------------------------------------
/*/{Protheus.doc) TecVldSmart
Valida se existe a configuração do smartview

@type function
@version 1,0
autor julia.marcela
@since 16/05/2025
/*/
//-------------------------------------------------------------------
Function TecVldSmart()

    Local nOpc  	as numeric
    Local lSuccess  As Logical
	Local lRet	    as logical

	lSuccess := .F.
    lSuccess := totvs.framework.smartview.util.isConfig()
    If lSuccess
        lRet := .T.
    Else
        nOpc := Aviso( STR0001, STR0002  + CRLF + CRLF +; //"Smart View!" #"Não existe configuração do Smart View." 
                        STR0003 + CRLF + CRLF +; //"Para atualização dessa funcionalidade, será necessário instalar e configurar o Smart View."
                        STR0004, { STR0005, STR0006 }, 3 )//"Siga as instruções da documentação." #"Sair" #"Abrir"

        If nOpc == 2 //Doc
            ShellExecute( "open", "https://tdn.totvs.com/pages/releaseview.action?pageId=626636542", "", "", 1 )//"Abrir"
        EndIf
	EndIf
    
Return lRet
