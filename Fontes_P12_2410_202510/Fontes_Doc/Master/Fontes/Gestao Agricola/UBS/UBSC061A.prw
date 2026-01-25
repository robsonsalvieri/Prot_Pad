#INCLUDE "UBSC061A.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWPrintSetup.ch"
#include 'parmtype.ch'

/*/{Protheus.doc} UBSC061A
Função principal responsavel pela impressão do termo aditivo conforme lotes selecionados
@type function
@version P12
@author Daniel Silveira / claudineia.reinert
@since 12/12/2023
@param aDados, array, array de dados do s lotes
@param cCodTerm, character, codigo do termo aditivo
@param cTerResp, character, codigo do responsavel tecnico
@param cTerSafra, character, codigo da safra
@param cTerCultr, character, codigo da cultura
@param cTerCtvar, character, codigo da cultivar
@param cTerCateg, character, codigo da categoria
@param cTipoAdt, character, tipo do aditivo (T=Tratado;R=Reembalado;C=Reembalado/Tratado)
@param dData, date, data de criação do termo aditivo
@param aObsTrat, array, array com as observações de tratamento
/*/
Function UBSC061A(aDados,cCodTerm, cTerResp, cTerSafra, cTerCultr , cTerCtvar, cTerCateg,cTipoAdt, dData, aObsTrat)
    Local cLocal          := ALLTRIM(GETTEMPPATH())

	Local cNome         := alltrim(FWSM0Util():GetSM0Data(, , { "M0_NOMECOM" } )[1][2])
	Local cCNPJ         := alltrim(FWSM0Util():GetSM0Data(, , {"M0_CGC"})[1][2])
	Local cRenasem      := alltrim(SuperGetMV("MV_AGRRENA",.F.,""))
	Local cEnder        := alltrim(FWSM0Util():GetSM0Data(, , {"M0_ENDENT"})[1][2])
	Local cMunic        := UPPER(Alltrim(FWSM0Util():GetSM0Data(, , {"M0_CIDENT"})[1][2]) + " / " + alltrim(FWSM0Util():GetSM0Data(, , {"M0_ESTENT"})[1][2]))
	Local cCEP          := alltrim(FWSM0Util():GetSM0Data(, , {"M0_CEPENT"})[1][2])
    Local cTelefone     := alltrim(FWSM0Util():GetSM0Data(, , {"M0_TEL"})[1][2]) 
    Local cEmail        := fMailPrdtor(cCNPJ) 

	Local cNomeTec	    := ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_NOME"))
	Local cCPFTec 	    := ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_CPF"))
	Local cRenasTec     := ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_RENASE"))
	Local cEndTec 	    := ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_ENDER"))
	Local cMunTec 	    := UPPER(ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_DESMUN")) + " / " + ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_EST")))
	Local cTelTec 	    := ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_NUMTEL"))
	Local cMailTec 	    := LOWER(ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_EMAIL")))
	Local cCepTec 	    := ALLTRIM(Posicione("NP8", 1, xFilial("NP8") + cTerResp, "NP8_CEP"))

	Local cMsg          := ""
	Local aRetTmp       := {}
    Local aRetTmp2      := {}
    Local aRetTrato     := {}
	local cEspecie      := alltrim(Posicione("NP3", 1, xFilial("NP3") + cTerCultr, "NP3_DESCRI"))//"SOJA"
	local cCultivar     := ALLTRIM(Posicione("NP4", 1, xFilial("NP4") + cTerCtvar,"NP4_DESCRI"))
	Local cCategoria    := cTerCateg
	Local cSafra        := cTerSafra
	Local cData         := ""           
    Local nL            := 0
    Local nX            := 0
    Local nH            := 0
    Local nJ            := 0
    Local nG            := 0
    Local cMsgTrato     := ''
    Local cPmsObs       := ''
    Local aMsgTrato     := {}
    Local cInfo         := STR0033 //##"Informações sobre o tratamento (deverão constar, no mínimo, o tipo de revestimento ou o corante utilizado, quando for o caso, e o nome comercial, o ingrediente ativo e a dose utilizada do agrotóxico ou de qualquer outra substancia nociva à saúde humana ou animal ou ao meio ambiente): "
    Local cPathLogo 	:= LOWER(Alltrim(SuperGetMV("MV_AGRS007",,"" ))) 

	Private _oFntAr13N  := TFont():New( "Arial", /*uPar2*/, 13, /*uPar4*/, .T. ,/*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/ )   
	Private _oFntAr14   := TFont():New( "Arial", /*uPar2*/, 11, /*uPar4*/, .F. ,/*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, /*lUnderline*/, /*lItalic*/ )   
    Private _oPrint     := FwMSPrinter():New(STR0041 + AllTrim(cCodTerm) + ".pdf" ,6,.T., cLocal,.T.,,,,.T., .F.) //##"TermoAditivo"
    Private _nLin       := 80
	Private _nCol       := 160
	Private _nLinFim    := 2800    

    Default dData 	    := dDataBase

    cData := cvaltochar(Day(dData)) + STR0042 + AGRMesAno(SUBSTR( DTOC(dData), 4, 10) , 4) + STR0042 + cvaltochar(Year(dData)) //##" de "

    cPathLogo  := cPathLogo+"lgrl"+cEmpAnt+cFilAnt+".bmp"
	If !File(cPathLogo)
		cPathLogo := cPathLogo+"lgrl"+cEmpAnt+".bmp"
		If !File(cPathLogo)
			cPathLogo := ""
		Endif   
	Endif  

    _oPrint:SetResolution(72)
	_oPrint:SetPortrait()
	_oPrint:SetPaperSize(DMPAPER_A4)
    _oPrint:SetMargin(001,001,001,001)

    If Len(aDados) > 0
        //Validando a mensagem
        If AllTrim(cTipoAdt) == "T"
            cMsg := STR0034 + STR0035 + STR0036 //##"O(s) lotes de semente abaixo discriminados(s) ou parte destes, após analisados e aprovados, foram submetidos a " ##"( X ) TRATAMENTO e/ou (  ) ALTERAÇÂO DE TAMANHO DE EMBALAGEM, "##"passando a apresentar as seguintes caracteristicas: "
        ElseIF AllTrim(cTipoAdt) == "R"
            cMsg := STR0034 + STR0037 + STR0036 //##"O(s) lotes de semente abaixo discriminados(s) ou parte destes, após analisados e aprovados, foram submetidos a " ##(  ) TRATAMENTO e/ou ( X ) ALTERAÇÂO DE TAMANHO DE EMBALAGEM, "##"passando a apresentar as seguintes caracteristicas: "
        ElseIF AllTrim(cTipoAdt) == "C"
            cMsg := STR0034 + STR0038 + STR0036 //##"O(s) lotes de semente abaixo discriminados(s) ou parte destes, após analisados e aprovados, foram submetidos a " ##( X ) TRATAMENTO e/ou ( X ) ALTERAÇÂO DE TAMANHO DE EMBALAGEM, "##"passando a apresentar as seguintes caracteristicas: "
        EndIf  
        _oPrint:StartPage()     
        
        _oPrint:SayBitmap(010, 120, cPathLogo, 200, 200) //logo
        _oPrint:SayAlign(_nLin,220 ,STR0001, _oFntAr13N , 2180, 12, , 2, 0 )//TEXTO //##"TERMO ADITIVO PARA TRATAMENTO DE SEMENTES "
	    _oPrint:SayAlign(_nLin+28,220 ,STR0002 + AllTrim(cCodTerm)	, _oFntAr13N , 2180, 12, , 2, 0 ) //##"E/OU ALTERAÇÃO DE TAMANHO DE EMBALAGEM NR: "

        _nLin+=150
        _oPrint:Box(_nLin,_nCol,_nLin+90,2300)        
        //Valida se é boletim para imprimir
        If cTerCateg $ "C1/C2"
            _oPrint:Say(_nLin+60,_nCol+60, STR0004+AllTrim(aDados[1][_nPosCert])+STR0005+AllTrim(aDados[1][_nPosDtCt])+".", _oFntAr13N) //##"AO CERTIFICADO DE SEMENTES Nº " #" DE "
        Else 
            _oPrint:Say(_nLin+60,_nCol+60, STR0003+AllTrim(aDados[1][_nTCmfeOri])+STR0005+aDados[1][_DTCmfeOri] +".", _oFntAr13N) //##"AO TERMO DE CONFORMIDADE Nº " #" DE "
        EndIF

        _nLin+=180

        //Box Id Produtor/Reembalador---------------------------------------------------------------------------------------
        _oPrint:Say(_nLin, _nCol, STR0006, _oFntAr13N) //##"IDENTIFICAÇÃO DO ( ) PRODUTOR OU ( ) REEMBALADOR"
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,2300)
    
        _oPrint:Say(_nLin+62,_nCol+10,STR0007+cNome, _oFntAr14) //##"Nome/Razão Social: "
        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,1150)
        _oPrint:Say(_nLin+70,_nCol+10,STR0008+AGRXCPOCGC(cCNPJ), _oFntAr14) //##"CPF/CNPJ: "
        _oPrint:Box(_nLin+20, 1150,_nLin+90,2305)
        _oPrint:Say(_nLin+70,_nCol+1010,STR0009+cRenasem, _oFntAr14) //##"Renasem nº: "
        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,2300)
        _oPrint:Say(_nLin+62,_nCol+10,STR0010+cEnder, _oFntAr14) //##"Endereço: "
        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,1150) //BOX MUNICIPIO  
        _oPrint:Say(_nLin+70,_nCol+10,STR0011+cMunic, _oFntAr14) //##"Município:  "
        _oPrint:Box(_nLin+20, 1150,_nLin+90,2305)
        _oPrint:Say(_nLin+70,_nCol+1010,STR0012+TRANSFORM(cCEP,  PesqPict("SA2","A2_CEP")), _oFntAr14) //##"CEP:  "
        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,1150)
        _oPrint:Say(_nLin+70,_nCol+10,STR0013+cTelefone, _oFntAr14) //##"Telefone:  "
        _oPrint:Box(_nLin+20, 1150,_nLin+90,2305)
        _oPrint:Say(_nLin+70,_nCol+1010,STR0014+cEmail, _oFntAr14) //##"E-mail:  "
        //------------------------------------------------------------------------------------------------------------------
        _nLin+=150
        //Box Responsável tecnico-------------------------------------------------------------------------------------------
        _oPrint:Say(_nLin, _nCol, STR0015, _oFntAr13N) //##"IDENTIFICAÇÃO DO RESPONSAVEL TECNICO"
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,2300)
    
        _oPrint:Say(_nLin+62,_nCol+10,STR0016+cNomeTec, _oFntAr14) //##"Nome: "
        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,1150)
        _oPrint:Say(_nLin+70,_nCol+10,STR0017+AGRXCPOCGC(cCPFTec), _oFntAr14) //##"CPF:  "
        _oPrint:Box(_nLin+20, 1150,_nLin+90,2305)
        _oPrint:Say(_nLin+70,_nCol+1010,STR0009+cRenasTec, _oFntAr14) //##"Renasem nº: "

        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,2300)
        _oPrint:Say(_nLin+62,_nCol+10,STR0010+cEndTec, _oFntAr14) //##"Endereço: "
        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,1150)
        _oPrint:Say(_nLin+70,_nCol+10,STR0011+cMunTec, _oFntAr14) //##"Municipio: "
        _oPrint:Box(_nLin+20, 1150,_nLin+90,2305)
        _oPrint:Say(_nLin+70,_nCol+1010,STR0012+TRANSFORM(cCEPTec,  PesqPict("SA2","A2_CEP")), _oFntAr14) //##"CEP: "

        _nLin+=67
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,1150)
        _oPrint:Say(_nLin+70,_nCol+10,STR0013+cTelTec, _oFntAr14) //##"Telefone: "
        _oPrint:Box(_nLin+20, 1150,_nLin+90,2305)
        _oPrint:Say(_nLin+70,_nCol+1010,STR0014+cMailTec, _oFntAr14) //##"E-mail: "
        //------------------------------------------------------------------------------------------------------------------
        _nLin+=150
        //Informações dos lotes de Semente----------------------------------------------------------------------------------
        _oPrint:Box(_nLin+20, _nCol,_nLin+90,500)
        _oPrint:Say(_nLin+70,_nCol+20,STR0018+cEspecie, _oFntAr14) //##"Especie: "
        _oPrint:Box(_nLin+20, 500,_nLin+90,1400)
        _oPrint:Say(_nLin+70,_nCol+360,STR0019+cCultivar, _oFntAr14) //##"Cultivar: "
        _oPrint:Box(_nLin+20, 1400,_nLin+90,1900)
        _oPrint:Say(_nLin+70,_nCol+1300,STR0020+cCategoria, _oFntAr14) //##"Categoria: "
        _oPrint:Box(_nLin+20, 1900,_nLin+90,2305)
        _oPrint:Say(_nLin+70,_nCol+1800,STR0021+cSafra, _oFntAr14) //##"Safra: "
        //--------------------------------------------------------------------------------------------------------------------
        _nLin+=150
        //AVISO---------------------------------------------------------------------------------------------------------------
        aRetTmp := FWTxt2Array(cMsg , 150 , .T. )
        For nL := 1 To Len(aRetTmp)
            _oPrint:Say(_nLin, _nCol, aRetTmp[nL], _oFntAr14)
            _nLin+=50
        Next nL
        //--------------------------------------------------------------------------------------------------------------------
        //_nLin+=80
        //Box dos dados-------------------------------------------------------------------------------------------------------
        _oPrint:Box(_nLin+20, _nCol,_nLin+115,1150)
        _oPrint:Say(_nLin+80,_nCol+20,STR0022, _oFntAr13N) //##"DADOS DO CERTIFICADO/TERMO DE CONFIRMIDADE"
        _oPrint:Box(_nLin+20, 1150,_nLin+115,2305)
        _oPrint:Say(_nLin+60,_nCol+1010,STR0023, _oFntAr13N) //"DADOS DO LOTE OU PARTE DO LOTE APÓS TRATAMENTO/"
        _oPrint:Say(_nLin+100,_nCol+1010,STR0024, _oFntAr13N) //##"ALTERAÇÃO DE TAMANHO DE EMBALAGEM"

        //Certificado/Termo
        _nLin+=92
        _oPrint:Box(_nLin+20, _nCol,_nLin+182,400)
        _oPrint:Say(_nLin+110,_nCol+40,STR0025, _oFntAr14) //##"Nº do Lote"

        _oPrint:Box(_nLin+20, 400,_nLin+103,1150)
        _oPrint:Say(_nLin+70,_nCol+360,STR0026, _oFntAr14) //##"Representividade original do Lote"
        _nLin+=80
        _oPrint:Box(_nLin+20, 400,_nLin+100,720)
        _oPrint:Say(_nLin+70,_nCol+260,STR0027, _oFntAr14) //##"Nº de embalagens"
        _oPrint:Box(_nLin+20, 720,_nLin+100,1150)
        _oPrint:Say(_nLin+70,_nCol+600,STR0028, _oFntAr14) //##"Peso p/ embalagem"
        
        //Dados tratamento/reembalagem
        _oPrint:Box(_nLin-60, 1150,_nLin+22,1900)
        _oPrint:Say(_nLin,_nCol+1050,STR0029, _oFntAr14) //##"Nova Representividade ou parte do lote"
        _nLin+=80
        _oPrint:Box(_nLin-60, 1150,_nLin+20,1530)
        _oPrint:Say(_nLin,_nCol+1050,STR0027, _oFntAr14) //##"Nº de embalagens"
        _oPrint:Box(_nLin-60, 1530,_nLin+20,2000)
        _oPrint:Say(_nLin,_nCol+1400,STR0028, _oFntAr14) //##"Peso p/ embalagem"
        _oPrint:Box(_nLin-140, 1900,_nLin+22,2305)
        _oPrint:Say(_nLin-40,_nCol+1800,STR0030, _oFntAr14) //##"Data do Tratamento" 
        //--------------------------------------------------------------------------------------------------------------------
        For nX := 1 To Len(aDados)
            //Busca dados lote original
            //aDados := fBusOrig(aDados[nX][_nPosLote])

            //original
            _oPrint:Box(_nLin+20, _nCol,_nLin+100,400)
            _oPrint:Say(_nLin+70,_nCol+40,aDados[nX][_nPosLote], _oFntAr14) //Lote
            _oPrint:Box(_nLin+20, 400,_nLin+100,720)
            _oPrint:Say(_nLin+70,_nCol+260,aDados[nx][_nPosQtOri], _oFntAr14) //Nº embalagens
            _oPrint:Box(_nLin+20, 720,_nLin+100,1150)
            _oPrint:Say(_nLin+70,_nCol+600,aDados[nx][_nPosPMEOri], _oFntAr14) //Peso embalagens
            //tratada/reembalada
            _nLin+=80
            _oPrint:Box(_nLin-60, 1150,_nLin+20,1530)
            _oPrint:Say(_nLin,_nCol+1050,aDados[nX][_nPosQtTR], _oFntAr14) //Nº embalagens
            _oPrint:Box(_nLin-60, 1530,_nLin+20,2000)
            _oPrint:Say(_nLin,_nCol+1400,aDados[nX][_nPosPMETR], _oFntAr14) //Peso embalagens
            _oPrint:Box(_nLin-60, 1900,_nLin+20,2305)
            if cTipoAdt $ "T/C" //se houve tratamento
                _oPrint:Say(_nLin,_nCol+1800,cValToChar(aDados[nX][_nPosDataLT]), _oFntAr14) //Data tratamento
            endif
            cPmsObs += alltrim(aDados[nX][_nPosLote])+ ": "+ aDados[nX][_nPosPMSTR] + "  "
            NovaPagina()
        Next
        //Texto sobre Tratamento----------------------------------------------------------------------------
        _oPrint:Box(_nLin+10, _nCol,_nLin+150,2300)
        aRetTmp2 := FWTxt2Array(cInfo , 150 , .T. )
        For nH := 1 To Len(aRetTmp2)
            _oPrint:Say(_nLin+62,_nCol+10,aRetTmp2[nH], _oFntAr14)
            _nLin+=50
            NovaPagina()
        Next nH
        _nLin+=100
        NovaPagina()
        if cTipoAdt $ "T/C"//Busca as informações/receita do tratamento na SG1 para colocar na Observação
            aRetTrato := aObsTrat
            For nJ := 1 To Len(aRetTrato)
                cMsgTrato := aRetTrato[nJ]
            Next nJ 
            //Imprimi tratamento
            aMsgTrato := FWTxt2Array(cMsgTrato , 110 , .T. )
            
            _oPrint:Say(_nLin+62,_nCol+10,STR0031 + cPmsObs, _oFntAr14) //##"Observações: PMS - "
            _nLin+=40
            _oPrint:Say(_nLin+62,_nCol+10,STR0032, _oFntAr14) //##"Tratamento:   "
            
            For nG := 1 To Len(aMsgTrato)
                _oPrint:Say(_nLin+62,_nCol+280,aMsgTrato[nG], _oFntAr14)
                _nLin+=50
                NovaPagina()                         
            Next nG
        endif
        _nLin+=150
        
        NovaPagina()
        //-----------------------------------------------------------------------------------------------------
        _oPrint:Say(_nLin+150,_nCol+750,cMunic+", " + cData, _oFntAr14)

        _oPrint:Say(_nLin+300,_nCol+500,"_________________________________________________________________", _oFntAr14)
        _oPrint:Say(_nLin+340,_nCol+900,Iif(!Empty(cNomeTec), cNomeTec, STR0039), _oFntAr14) //##"Responsável Tecnico"

        _oPrint:Endpage()
        _oPrint:Preview()
    Else 
        MsgInfo(STR0040) //##"Não foram encontrados Dados para impressão do Aditivo. Entre em contato com a área de TI."
    EndIf
Return 

/*/{Protheus.doc} NovaPagina
Verifica se quebra a pagina gerando uma nova pagina
@author Daniel Silveira / claudineia.reinert
@since 12/12/2023
@version Git
@type Function
/*/
Static Function NovaPagina()
	If _nLin > _nLinFim
		//filanizo a pagina
		_oPrint:endPage()

		//Inicia uma nova pagina
		_oPrint:StartPage() 

        //Reestarto _nLin
        _nLin := 80
	EndIf
Return

/*/{Protheus.doc} fMailPrdtor
Função busca e-mail do produtor na tabela de cliente/fornecedor
@type function
@version P12
@author claudineia.reinert
@since 12/12/2023
@return character, e-mail do produtor
/*/
Static Function fMailPrdtor(cCGC)
    Local cRet := ""
    Local cAliasPRT  := GetNextAlias()

    BeginSql Alias cAliasPRT
        SELECT COALESCE(A1_EMAIL,'') A1_EMAIL,COALESCE(A2_EMAIL,'') A2_EMAIL
        FROM %Table:SA1% SA1
        LEFT OUTER JOIN %Table:SA2% SA2 ON SA2.%notDel% AND A2_FILIAL = %xFilial:SA2% 
            AND A2_CGC = %exp:cCGC% AND A2_EMAIL <> ''
        WHERE SA1.%notDel%
            AND A1_FILIAL = %xFilial:SA1%
            AND A1_CGC = %exp:cCGC% 
            GROUP BY A1_EMAIL,A2_EMAIL
			HAVING  (A1_EMAIL <> '' OR A2_EMAIL <> '')
    EndSQL

    If (cAliasPRT)->(!Eof())
		If !Empty(Alltrim((cAliasPRT)->A1_EMAIL ))
		    cRet :=  (cAliasPRT)->A1_EMAIL 
        ElseIf !Empty(Alltrim((cAliasPRT)->A2_EMAIL ))
		    cRet :=  (cAliasPRT)->A2_EMAIL 
	    EndIf
	EndIf
	(cAliasPRT)->(DbCloseArea())

Return cRet
