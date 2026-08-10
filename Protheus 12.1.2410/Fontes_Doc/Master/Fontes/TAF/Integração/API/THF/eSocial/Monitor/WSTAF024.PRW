#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWAdapterEAI.ch"
#INCLUDE "WSTAF024.CH"
#INCLUDE "FWLIBVERSION.CH"

#DEFINE PAGESIZE_DEF	100
#DEFINE CODE_DEF	    200
#DEFINE ENTER  			CHR ( 13 ) + CHR ( 10 )
#DEFINE API_CODE		"WSTAF024"

Static __cBanco     := Nil
Static __cLibVer    := Nil
Static __oQryT3A    := Nil
Static __oQryT1U    := Nil
Static __oQryV73    := Nil

WSRESTFUL TAFEsocialDetailTransmission DESCRIPTION oEmToAnsi( "Serviço do Monitor de Transmissão do eSocial" ) FORMAT APPLICATION_JSON

	WSDATA companyCode 	AS STRING
	WSDATA branchCode  	AS STRING
	WSDATA id 		   	AS STRING
	WSDATA eventCode	AS STRING
	WSDATA period		AS STRING
    WSDATA periodFrom   AS STRING
    WSDATA periodTo     AS STRING
	WSDATA status		AS STRING
	WSDATA userId		AS STRING
	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL

	WSMETHOD POST DESCRIPTION oEmToAnsi( "Método para consultar o detalhamento das transmissões dos eventos do Esocial para o governo" ) WSSYNTAX "api/rh/esocial/v1/TAFEsocialDetailTransmission/" PATH "api/rh/esocial/v1/TAFEsocialDetailTransmission/" TTALK "v1" PRODUCES APPLICATION_JSON
	END WSRESTFUL

WSMETHOD POST WSREST TAFEsocialDetailTransmission

    Local oInput            as Object
    Local cRet			    as Character
    Local cUserId           as Character
    Local lRet			    as Logical
    Local aData			    as Array
    Local aHeader		    as Array
    Local aAmb			    as Array
    Local nPageSize		    as Numeric
    Local nPage			    as Numeric
    Local lHasNext		    as Logical
    Local lGlbVarFunctions  as Logical
    Local aBranches         as Array
    Local aFilTss           as Array
    Local aEvtsESoc         as Array
    Local lEnd              as Logical

    cRet                := ""
    lRet	            := .T.
    aData	            := {}
    aHeader	            := {}
    aAmb		        := {}
    nPageSize	        := PAGESIZE_DEF
    nPage		        := 1
    lHasNext	        := .F.
    aBranches           := {}
    aFilTss             := {}
    aEvtsESoc           := {}
    lEnd                := .F.
    lGlbVarFunctions    := FindFunction("hasUKeyByUID")

    oInput 		:= JsonObject():New()
    cBody     	:= ::GetContent()
    cUserId     := IIf(lGlbVarFunctions,;
                       getIdUserFromRequest(::GetHeader("Authorization")),;
                       "000000")
    oInput:FromJson( cBody )
  
    // Realiza pré-validações
    If lRet := fPreValid( oInput )

        // Controle de Paginação
        If !Empty( oInput["pageSize"] ) .AND. oInput["pageSize"] > 1 .AND. oInput["pageSize"] < PAGESIZE_DEF
            nPageSize := VAL( oInput["pageSize"] )
        EndIf
        
        If !Empty( oInput["page"] ) .AND. oInput["page"] > 1
            nPage := oInput["page"]
        EndIf

        aAmb := StrTokArr( oInput["companyId"], "|")
        
        If PrepEnv(aAmb[1], aAmb[2])
            aBranches := IIf(lGlbVarFunctions,;
                                getFilFromRequestOrCached(oInput["branches"], cUserId, aAmb[1], aAmb[2], API_CODE),;
                                oInput["branches"])

            //Realizo a chamada do TAFProc5 afim de atualizar o status dos registros no TAF
            aFilTss     := RETINFEMP(aAmb[1], aBranches)
            aAdd( aEvtsESoc, TAFRotinas( oInput["eventCode"], 4, .F., 2 ) )
            
            TAFProc5TSS(.T.,aEvtsESoc,,,,@lEnd,,aFilTss)

            aHeader := fTafGetHeader( oInput )
            aHeader := fSortCol( aHeader )
            aData 	:= fGetData( oInput, aHeader, nPage, nPageSize, @lHasNext, aBranches )

        EndIf 
    EndIf

    // Montagem de retorno da API de Processamento
    cRet := fReturn( aHeader, aData, lHasNext, oInput["eventCode"] )
    ::SetResponse( cRet )
    


Return( lRet )


/*/{Protheus.doc} function fPreValid
Função que realiza as pré-validações
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fPreValid( oInput )

    Local lRet 	   	:= .T.
    Local cMessage	:= ""

    If Empty( oInput["companyId"] )
        cMessage := "O parâmetro 'companyId' é obrigatório e não foi informado."
        lRet 	 := .F.

    ElseIf oInput["branches"] == Nil
        cMessage := "Parâmetro 'branches' é obrigatório e não pode estar ausente do corpo da requisição."
        lRet 	 := .F.

    ElseIf Empty( oInput["eventCode"] )
        cMessage := "O parâmetro 'eventCode' é obrigatório e não foi informado."
        lRet 	 := .F.
    EndIf

    If !lRet
        SetRestFault(CODE_DEF, EncodeUTF8( cMessage ), , , , , )
    EndIf

Return lRet

/*/{Protheus.doc} function fReturn
Função que monta a estrutura de retorno da API
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fReturn(aHeader as array, aData as array, lHasNext as logical, cEvento as character)

    Local cKeyValue     as character
    Local cRet	    	as character        
    Local aAux		    as array
    Local aItems	    as array
    Local aColums	    as array
    Local aHeadProp	    as array	    
    Local aLabel	    as array
    Local aKeysField    as array
    Local nX		    as numeric
    Local nY		    as numeric
    Local nT	        as numeric
    Local oRet          as json
    Local oHeader       as json
    Local oItem         as json
    Local oItems        as json
    Local oColums       as json

    cKeyValue   := ""
    cRet        := ""     
    aAux		:= {}
    aItems	    := {}
    aColums	    := {}
    aHeadProp   := {}	    
    aLabel	    := {}
    aKeysField  := {}
    nX		    := 0
    nY		    := 0
    nT	        := 0
    oRet        := Nil
    oHeader     := Nil
    oItem       := Nil
    oItems      := Nil
    oColums     := Nil

    oRet				:= JsonObject():new()
    oRet["hasNext"]		:= lHasNext

    aLabel	:= fGetLabel( aHeader )

    // Montagem do Header
    If !Empty( aHeader )
        For nX := 1 To Len( aHeader )
            
            If !("|" $ aHeader[nX]) .And. (aHeader[nX] != 'alert')

                oHeader := JsonObject():new()
                
                If "_STATUS" $ aHeader[nX]
                    oHeader["property"] := "status"
                Else
                    oHeader["property"] := aHeader[nX]
                EndIf
                
                oHeader["label"] 	:= EncodeUTF8( aLabel[nX] )
                oHeader["type"] 	:= "string"
                oHeader["visible"]  := !HiddenField(aHeader[nX], cEvento)

                AAdd( aHeadProp, oHeader )
                FreeObj( oHeader )

            EndIf

        Next nX
    EndIf

    oRet["header"] 	:= aHeadProp

    // Montagem dos dados
    If !Empty( aData )
        aAux := {}
        
        For nX := 1 To Len( aData )
            oItem   := JsonObject():new()
            aColums := {}
            
            For nY := 1 To Len( aHeader )

                If "|" $ aHeader[nY]
                    aKeysField   := StrToKArr( aData[nX][nY], "|" )
                    For nT := 1 To Len(aKeysField)
                        If nT == 2
                            cKeyValue += StrTran(cEvento,"-","") + "|" + aKeysField[nT] + "|"
                        Else
                            cKeyValue += aKeysField[nT] + "|"
                        EndIf
                    Next  nT

                    oItem["key"] := cKeyValue
                    cKeyValue := ""

                ElseIf aHeader[nY] == "alert" 
                
                    oItem["hasAlert"] 	:= aData[nX][nY] 
                Else

                    oColums := JsonObject():new()

                    Do Case
                        Case "_STATUS" $ aHeader[nY]

                            oColums["property"] := "status"
                            oColums["value"] 	:= ALLTRIM( aData[nX][nY] )
                            oItem["hasError"] 	:= IIf( ALLTRIM( aData[nX][nY] ) == "3", .T., .F.)	

                        Case "_EVENTO" $ aHeader[nY]

                            oColums["property"] := aHeader[nY]

                            If ALLTRIM( aData[nX][nY] ) == "A" .Or. ALLTRIM( aData[nX][nY] ) == "R"
                                oColums["value"] := EncodeUTF8( "Sim" )
                            Else
                                oColums["value"] := EncodeUTF8( "Não" )
                            EndIf

                        Case aHeader[nY] == "error" 

                            oColums["property"] := aHeader[nY] 
                            oColums["value"] 	:= EncodeUTF8("error") 

                        OTHERWISE

                            oColums["property"] := aHeader[nY]
                            oColums["value"]    := IIf( Empty(aData[nX][nY]), IIF(GetSx3Cache(aHeader[nY],"X3_TIPO") == "D","","N/A"), aData[nX][nY] )

                    EndCase

                    AAdd( aColums, oColums )
                    FreeObj( oColums )

                EndIf
                    
            Next nY
            
            oItem["columns"] := aColums
            
            AAdd( aAux, oItem )
            FreeObj( oItem )
        Next nX
    EndIf

    oItems 		 	:= JsonObject():new()
    oItems["item"] 	:= aAux

    AAdd( aItems, oItems )
    FreeObj( oItems )

    oRet["items"] := aItems

    // Compactação do objeto JSON
    cRet := fCompress( oRet )
    FreeObj( oRet )
	
Return cRet

/*/{Protheus.doc} function fGetLabel
Função responsável por montar as labels que serão exibidas na tela
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fGetLabel(aHeader as array)
    
    Local aLabel    as array    
    Local nX 	    as numeric

    Default aHeader := {}

    aLabel  := {}
    nX      := 1

    For nX := 1 To Len( aHeader )
        If  "_STATUS" $ aHeader[nX]
            aadd( aLabel, "Status") // "status"
        
        ElseIf "_FILIAL" $ aHeader[nX] .And. "_ID" $ aHeader[nX] .And. "_VERSAO" $ aHeader[nX]
            aadd( aLabel, "Chave de Identificaçao" ) // "key"
            
        // S1000
        ElseIf "_TPINSC" $ aHeader[nX]
            aadd( aLabel, "Tipo de Inscrição" )
        
        ElseIf "_NRINSC" $ aHeader[nX] .Or. "_CGC" $ aHeader[nX]
            aadd( aLabel, "Número de Inscrição" )
        
        ElseIf "C1E_NOME" $ aHeader[nX] 
            aadd( aLabel, "Nome Razão Social" )
        
        // S1010
        ElseIf "_EVENTO" $ aHeader[nX]
            aadd( aLabel, "Retificação" )
            
        ElseIf "_CODRUB" $ aHeader[nX]
            aadd( aLabel, "Código da Rubrica"  )
        
        ElseIf "_IDTBRU" $ aHeader[nX]
            aadd( aLabel, "Ident. Tabela de Rubrica" )
        
        ElseIf "_DESRUB" $ aHeader[nX]
            aadd( aLabel, "Descrição da Rubrica" )
            
        // S-1020
        ElseIf "C99_CODIGO" $ aHeader[nX]
            aadd( aLabel, "Código Lotação" ) // "Código Lotação"
            
        ElseIf "C99_TPLOT" $ aHeader[nX]
            aadd( aLabel, "Tipo da Lotação" ) // "Tipo da Lotação"
        
        // S-1030
        ElseIf "C8V_CODIGO" $ aHeader[nX]
            aadd( aLabel, "Código do Cargo" ) // "Código do Cargo"
        
        ElseIf "C8V_DESCRI" $ aHeader[nX]
            aadd( aLabel, "Número do Cargo" ) // "Número do Cargo"
        
        // S-1035
        ElseIf "T5K_CODIGO" $ aHeader[nX]
            aadd( aLabel, "Código da Carreira" ) // "Código da Carreira"
        
        ElseIf "T5K_DESCRI" $ aHeader[nX]
            aadd( aLabel, "Descrição da Carreira" ) // "Descrição da Carreira"
        
        // S-1040
        ElseIf "C8X_CODIGO" $ aHeader[nX]
            aadd( aLabel, "Código da Função" ) // "Código da Função"
        
        ElseIf "C8X_DESCRI" $ aHeader[nX]
            aadd( aLabel, "Descrição da Função" ) // "Descrição da Função"
        
        // S-1050
        ElseIf "C90_CODIGO" $ aHeader[nX]
            aadd( aLabel, "Código Horário de Trabalho" ) // "Código Horário de Trabalho"

        ElseIf "C90_DESCRI" $ aHeader[nX]
            aadd( aLabel, "Descrição do Horário de Trabalho" ) // "Descrição do Horário de Trabalho"

        // S-1060
        ElseIf "T04_CODIGO" $ aHeader[nX]
            aadd( aLabel, "Código do Ambiente" ) // "Código do Ambiente"
        
        ElseIf "T04_DESCRI" $ aHeader[nX]
            aadd( aLabel, "Nome do Ambiente" ) // "Nome do Ambiente"
        
        // S-1070
        ElseIf "_TPPROC"  $ aHeader[nX]
            aadd( aLabel, "Tipo do Processo" ) // "Tipo do Processo"
        
        ElseIf "_NUMPRO" $ aHeader[nX]
            aadd( aLabel, "Nome do Processo" ) // "Nome do Processo"

        ElseIf "_DTNASC" $ aHeader[nX]
            AAdd(aLabel, STR0003) // "Data de Nascimento"

        ElseIf "_DTADMI" $ aHeader[nX]
            aadd( aLabel, "Data de Admissão" ) // "Data de Admissão"

        ElseIf "_CPFRES" $ aHeader[nX]
            aadd( aLabel, "CPF Médico Responsável/Coordenador PCMSO" ) // "CPF Médico Responsável/Coordenador PCMSO"

        ElseIf "_MATRIC" $ aHeader[nX] .Or. "_MATTSV" $ aHeader[nX]
            aadd( aLabel, "Matrícula do Trabalhador" ) // "Matrícula do Trabalhador"

        // S-2231
        ElseIf "V72_DTINIC" $ aHeader[nX]
            aadd( aLabel, "Data de Iní­ci­o de Cessão") // "Data de Início de Cessão"
        ElseIf "V72_CNPJCE" $ aHeader[nX]
            aadd( aLabel, "CNPJ do Empregador") // "CNPJ do Empregador"
        ElseIf "V72_DTTERM" $ aHeader[nX]
            aadd( aLabel, "Data de Término da Cessão") // "Data de Término da Cessão"
        ElseIf "V72_RESPRE" $ aHeader[nX]
            aadd( aLabel, "Informação de Remuneração") // "Informação de Remuneração"

        // Info Beneficiário (Família S-2400 - Órgãos Públicos) 
        ElseIf "_CPFBEN" $ aHeader[nX]
            aadd( aLabel, "CPF do Beneficiário") // "CPF do Beneficiário"
        ElseIf "_NRBENF" $ aHeader[nX]
            aadd( aLabel, "Número do Benefício") // "Número do Benefício"
        ElseIf "_TPPENS" $ aHeader[nX]
            aadd( aLabel, "Tipo Pensão por Morte") // "Tipo Pensão por Morte"
        ElseIf "_TPBENE" $ aHeader[nX]
            aadd( aLabel, "Tipo Benefício") // "Tipo Benefício"
        ElseIf "_DTTERM" $ aHeader[nX]
            aadd( aLabel, "Data Cessação do Benefício") // "Data Cessação do Benefício"
        ElseIf "_MTVTER" $ aHeader[nX]
            aadd( aLabel, "Motivo Cessação do Benefício") // "Motivo Cessação do Benefício"

        // S-2400|S-2405
        ElseIf "V73_NOMEB" $ aHeader[nX]
            aadd( aLabel, "Nome do Beneficiário") // "Nome do Beneficiário"
        ElseIf "V73_DTINIC" $ aHeader[nX]
            aadd( aLabel, "Data Iní­ci­o Beneficiário") // "Data Iní­ci­o Beneficiário"
        ElseIf "V73_DTALTE" $ aHeader[nX]
            aadd( aLabel, "Data Alteração") // "Data Alteração"
        ElseIf "V73_INCFIS" $ aHeader[nX]
            aadd( aLabel, "Doença Incapacitante") // "Doença Incapacitante"
        ElseIf "V73_DTINCF" $ aHeader[nX]
            aadd( aLabel, "Data Reconhecimento Incapacidade") // "Data Reconhecimento Incapacidade"

        // S-2410
        ElseIf "V75_MATRIC" $ aHeader[nX]
            aadd( aLabel, "Matrícula do Beneficiário") // "Matrícula do Beneficiário"
        ElseIf "V75_SITBEN" $ aHeader[nX]
            aadd( aLabel, "Situação do Benefício") // "Situação do Benefício"
        ElseIf "V75_DTINBE" $ aHeader[nX]
            aadd( aLabel, "Data Início do Benefício") // "Data Início do Benefício"
        ElseIf "V75_CADINI" $ aHeader[nX]
            aadd( aLabel, "Cadastro Inicial") // "Cadastro Inicial"
        ElseIf "V75_CNPJDS" $ aHeader[nX]
            aadd( aLabel, "CNPJ Origem") // "CNPJ Origem"
        ElseIf "V75_DTPUBL" $ aHeader[nX]
            aadd( aLabel, "Data Publicação") // "Data Publicação"

        // S-2416
        ElseIf "V76_DALTBE" $ aHeader[nX]
            aadd( aLabel, "Data Alteração Benefício") // "Data Alteração Benefício"
        ElseIf "V76_INDSUS" $ aHeader[nX]
            aadd( aLabel, "Indicativo de Suspensão") // "Indicativo de Suspensão"
        ElseIf "V76_MTSUSP" $ aHeader[nX]
            aadd( aLabel, "Motivo Suspensão") // "Motivo Suspensão"

        // S-2418
        ElseIf "V77_DTREAT" $ aHeader[nX]
            aadd( aLabel, "Data Reativação Benefício") // "Data Reativação Benefício"
        ElseIf "V77_DTEF" $ aHeader[nX]
            aadd( aLabel, "Data Efeitos Financeiros da Reativação") // "Data Efeitos Financeiros da Reativação"

        // S-2420
        ElseIf "V78_CNPJO" $ aHeader[nX]
            aadd( aLabel, "CNPJ Orgão Sucessor") // "CNPJ Orgão Sucessor"
        ElseIf "V78_NEWCPF" $ aHeader[nX]
            aadd( aLabel, "Novo CPF") // "Novo CPF"

        ElseIf "_CPF" $ aHeader[nX]
            aadd( aLabel, "CPF do Trabalhador" ) // "CPF do Trabalhador"
        
        ElseIf aHeader[nX] $ "C9V_NOME|T1U_NOME|"
            AAdd(aLabel, STR0002) // "Nome do Trabalhador"
        
        ElseIf "_DTALT" $ aHeader[nX]
            aadd( aLabel, "Data de Alteração"   ) // "Data de Alteração"
        
        ElseIf "C9V_FILIAL" $ aHeader[nX]
            aadd( aLabel,  "Filial do Trabalhador" ) // "Filial do Trabalhador"
        
        ElseIf "_MOTVAF" $ aHeader[nX]
            aadd( aLabel, "Cód. Mot. Afast." ) // "Cód. Mot. Afast."
        
        ElseIf "_DTAFAS" $ aHeader[nX]
            aadd( aLabel, "Data Início Afast." ) // "Data Início Afast."

        ElseIf "_DTFAFA" $ aHeader[nX]
            aadd( aLabel, "Data Fim Afast." ) // "Data Fim Afast."

        ElseIf aHeader[nX] $ "V7C_PERAPU|V7J_PERAPU"
            AAdd(aLabel, STR0011) // "Mês de Pagamento da Parcela"

        ElseIf "_PERAPU" $ aHeader[nX]
            AAdd(aLabel, STR0005) // "Competência"
        
        ElseIf "_DTDESL" $ aHeader[nX]
            aadd( aLabel, "Data de Desligamento" ) // "Data de Desligamento"

        ElseIf "_DTERAV" $ aHeader[nX]
            aadd( aLabel, "Data Término" ) // "Data Término do Contrato"

        ElseIf "_DTRET" $ aHeader[nX]
            aadd( aLabel, "Data Efetivação Retorno" ) // "Data Efetivação Retorno"

        ElseIf "_DTEFEI" $ aHeader[nX]
            aadd( aLabel, "Data Efeito" ) // "Data Efeito"

        ElseIf "_INDAPU" $ aHeader[nX]
            aadd( aLabel, "Indic. de Apuração" ) // "Indic. de Apuração"

        ElseIf "_PROTUL" $ aHeader[nX]
            aadd( aLabel, "Recibo de Transmissão" ) // "Recibo de Transmissão"

        ElseIf "_NIS" $ aHeader[nX]
            aadd( aLabel, "NIS") // "NIS"

        ElseIf "_NRRECI" $ aHeader[nX]
            AAdd(aLabel, STR0007) // "Recibo do Evento"

        ElseIf "_TPEVEN" $ aHeader[nX]
            AAdd(aLabel, STR0006) // "Evento"

        ElseIf "_FILIAL" $ aHeader[nX] .And. !("C9V_FILIAL" $ aHeader[nX])
            aadd( aLabel, "Filial" ) // "Filial"

        ElseIf "_DTACID" $ aHeader[nX]
            aadd( aLabel, "Data do Acidente") // "Data do Acidente"

        ElseIf "_HRACID" $ aHeader[nX]
            aadd( aLabel, "Hora do Acidente") // "Hora do Acidente"

        ElseIf "_TIPACI" $ aHeader[nX]
            aadd( aLabel, "Tipo do Acidente") // "Tipo do Acidente"

        ElseIf "_CODCAT" $ aHeader[nX]
            aadd( aLabel, "Categoria do Trabalhador") // "Categoria do Trabalhador"

        // S-2260
        ElseIf "_CONVOC" $ aHeader[nX]
            aadd( aLabel, "Código Convocação") // "Código Convocação"
        ElseIf "_DTINIP" $ aHeader[nX]
            aadd( aLabel, "Data Início Prestação") // "Data Início Prestação"
        ElseIf "_DTFIMP" $ aHeader[nX]
            aadd( aLabel, "Término Prest. Trabalho") // "Término Prest. Trabalho"
        ElseIf "_DTPREV" $ aHeader[nX]
            aadd( aLabel, "Data Prevista Pagamento") // "Data Prevista Pagamento"

        // S-2240
        ElseIf "_DTINI" $ aHeader[nX]
            aadd( aLabel, "Data Inicio") // "Data Inicio"
        ElseIf "_LAMB" $ aHeader[nX]
            aadd( aLabel, "Tipo Estabelecimento") // "Tipo Estabelecimento"
        ElseIf "T0Q_DSETOR" $ aHeader[nX]
            aadd( aLabel, "Descrição Lugar Administrativo") // "Descrição Lugar Administrativo"
        ElseIf "T0Q_TPINSC" $ aHeader[nX]
            aadd( aLabel, "Tp Inscrição do ambiente") // "Tp Inscrição do ambiente"
        ElseIf "T0Q_NRINSC" $ aHeader[nX]
            aadd( aLabel, "Número Inscrição do ambiente") // "Número Inscrição do ambiente"

        // S-2245
        ElseIf "_CODTCA" $ aHeader[nX]
            aadd( aLabel, "Cod Trein. Capacitação") // "Cod Trein. Capacitação"
        ElseIf "_OBSTCA" $ aHeader[nX]
            aadd( aLabel, "Obs. Trein. Capacitação") // "Obs. Trein. Capacitação"

        // S-2250
        ElseIf "_DTAVIS" $ aHeader[nX]
            aadd( aLabel, "Data do Aviso Prévio") // "Data do Aviso Prévio"
        ElseIf "_TPAVIS" $ aHeader[nX]
            aadd( aLabel, "Tipo de Aviso Prévio") // "Tipo de Aviso Prévio"

        // S-2220
        ElseIf "_TPEXAM" $ aHeader[nX]
            aadd( aLabel, "Tipo Exame Ocupacional") // "Tipo Exame Ocupacional"
        ElseIf "_DTASO" $ aHeader[nX]
            aadd( aLabel, "Data ASO") // "Data ASO"
        ElseIf "_RESULT" $ aHeader[nX]
            aadd( aLabel, "Resultado da ASO") // "Resultado da ASO"
        ElseIf "_NRCRM" $ aHeader[nX]
            aadd( aLabel, "CRM do médico Responsável/Coordenador PCMSO") // "CRM do médico Responsável/Coordenador PCMSO"
        ElseIf "_NOMRES" $ aHeader[nX]
            aadd( aLabel, "Nome Médico Responsável/Coordenador PCMSO") // "Nome Médico Responsável/Coordenador PCMSO"
        ElseIf "CM7_CODIGO" $ aHeader[nX]
            aadd( aLabel, "CRM do Médico") // "CRM do Médico"
        ElseIf aHeader[nX] $ "CM7_NOME|V3B_NMMED|"
            aadd( aLabel, "Nome do Médico") // "Nome do Médico"       

        // S-2021
        ElseIf "_DTEXAM" $ aHeader[nX]
            aadd( aLabel, "Data do Exame") // "Data do Exame"

        // S-1260
        ElseIf "T1M_IDESTA" $ aHeader[nX]
            aadd( aLabel, "Nr. CAEPF") // "Nr. CAEPF"
        
        ElseIf "V9U_ORIGEM" $ aHeader[nX]
            AAdd(aLabel, STR0001) // "Origem do Processo"

        ElseIf "_NMTRAB" $ aHeader[nX]
            AAdd(aLabel, STR0002) // "Nome do Trabalhador"

        ElseIf "_NRPROC" $ aHeader[nX]
            AAdd(aLabel, STR0004) // "Número do Processo"
        
        ElseIf "_PROCTR" $ aHeader[nX] 
            AAdd(aLabel, STR0012) // "Número do Processo Trabalhista"

        Else
            aadd( aLabel, "" )

        EndIf
    Next nX
	
Return aLabel

/*/{Protheus.doc} function fTafGetHeader
Função que monta os campos que serão retornados de acordo com o evento filtrado
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Function fTafGetHeader(oInput as json)

    Local aHeader 	as array
    Local aTafInfo  as array
    Local cTabela	as character

    Default oInput  := JsonObject():New()

    aHeader 	:= {}
    aTafInfo    := TAFRotinas(oInput["eventCode"], 4, .F., 2)
    cTabela	    := aTafInfo[3]

    // Adiciona campos que controle da API
    aadd( aHeader, cTabela + "_STATUS" )
    aadd( aHeader, cTabela + "_EVENTO" )
    aadd( aHeader, cTabela + "_FILIAL" + "|" + cTabela + "_ID" + "|" + cTabela + "_VERSAO" )

    // Adiciona campos necessários para todos os eventos
    aadd( aHeader, "error" )

    // Adiciona somente os campos necessários de acordo com cada evento
    If oInput["eventCode"] == "S-1000"
        aadd( aHeader, "M0_TPINSC" )
        aadd( aHeader, "M0_CGC" )
        aadd( aHeader, cTabela + "_NOME" )
        
    ElseIf oInput["eventCode"] == "S-1005"
        aadd( aHeader, cTabela + "_TPINSC" )
        aadd( aHeader, cTabela + "_NRINSC" )
        
    ElseIf oInput["eventCode"] == "S-1010"
        aadd( aHeader, cTabela + "_CODRUB" )
        aadd( aHeader, cTabela + "_IDTBRU" )
        aadd( aHeader, cTabela + "_DESRUB" )      
        
    ElseIf oInput["eventCode"] == "S-1020"
        aadd( aHeader, cTabela + "_CODIGO" )
        aadd( aHeader, cTabela + "_TPLOT" )
        
    ElseIf oInput["eventCode"] == "S-1030"
        aadd( aHeader, cTabela + "_CODIGO" )
        aadd( aHeader, cTabela + "_DESCRI" )
        
    ElseIf oInput["eventCode"] == "S-1035"
        aadd( aHeader, cTabela + "_CODIGO" )
        aadd( aHeader, cTabela + "_DESCRI" )
        
    ElseIf oInput["eventCode"] == "S-1040"
        aadd( aHeader, cTabela + "_CODIGO" )
        aadd( aHeader, cTabela + "_DESCRI" )
        
    ElseIf oInput["eventCode"] == "S-1050"
        aadd( aHeader, cTabela + "_CODIGO" )
        aadd( aHeader, cTabela + "_DESCRI" )

    ElseIf oInput["eventCode"] == "S-1060"
        aadd( aHeader, cTabela + "_CODIGO" )
        
    ElseIf oInput["eventCode"] == "S-1070"
        aadd( aHeader, cTabela + "_TPPROC" )
        aadd( aHeader, cTabela + "_NUMPRO" )

    EndIf

    If oInput["eventCode"] == "S-2190"
        AAdd(aHeader, cTabela + "_DTADMI")    
    EndIf

    If oInput["eventCode"] $ "S-1200|S-1202|S-1210|S-2200|S-2206|S-2210|S-2220|S-2221|S-2231|S-2245|S-2250|S-2260|" +;
                                "S-2240|S-2230|S-2298|S-2299|S-2300|S-2306|S-2399"
        AAdd(aHeader, "C9V_CPF")
    EndIf

    If oInput["eventCode"] $ "S-1200|S-1202|S-1210|S-2200|S-2206|S-2210|S-2220|S-2221|S-2231|S-2245|S-2250|S-2260|" +;
                                "S-2240|S-2230|S-2298|S-2299|S-2300|S-2306|S-2399|S-3500"
        AAdd(aHeader, "C9V_NOME")
    EndIf
    
    If oInput["eventCode"] $ "S-2205"
        aadd( aHeader, "T1U_CPF" )
        aadd( aHeader, "T1U_NOME" )
    EndIf

    If oInput["eventCode"] $ "S-2221|S-2231|S-2245|S-2250|S-2260"
        AAdd(aHeader, "C9V_MATRIC")
    EndIf

    If oInput["eventCode"] $ "S-1280|S-1250|S-1260|S-1295|S-1298|S-1299|S-1300"
        aadd( aHeader, cTabela + "_INDAPU" )
        aadd( aHeader, cTabela + "_PROTUL" )
        aadd( aHeader, cTabela + "_FILIAL" )
    EndIf

    If oInput["eventCode"] $ "S-1200|S-1202|S-1207|S-1210|S-1250|S-1260|S-1280|S-1295|S-1298|S-1299|S-1300|S-2501|S-3000|S-3500"
        AAdd(aHeader, cTabela + "_PERAPU")
    EndIf

    If oInput["eventCode"] $ "S-2555" .And. TAFAlsInDic( "T8I" )
        AAdd(aHeader, cTabela + "_PERAPU")
    EndIf

    If oInput["eventCode"] $ "S-1207"
        AAdd(aHeader, cTabela + "_INDAPU")
        AAdd(aHeader, "V73_NOMEB")
    EndIf

    If oInput["eventCode"] $ "S-1260"
        aadd( aHeader, "T1M_IDESTA" )
    EndIf

    If oInput["eventCode"] $ "S-2200,S-2205,S-2206,S-2210,S-2220,S-2240,S-2230,S-2298,S-2299"
        aadd( aHeader, "C9V_MATRIC" )
    EndIf

    If oInput["eventCode"] $ "S-2300|S-2399"
        aadd( aHeader, "C9V_MATTSV" )
    EndIf

    If oInput["eventCode"] $ "S-2210,S-2220,S-2221,S-2240,S-2245"
        aadd( aHeader, "CUP_CODCAT" )
    EndIf

    If oInput["eventCode"] $ "S-2205,S-2206,S-2306"
        aadd( aHeader, cTabela + "_DTALT" )
    EndIf

    If oInput["eventCode"] $ "S-2210"
        aadd( aHeader, cTabela + "_DTACID" )
        aadd( aHeader, cTabela + "_HRACID" )
        aadd( aHeader, cTabela + "_TIPACI" )
    EndIf

    If oInput["eventCode"] $ "S-2220"
        aadd( aHeader, cTabela + "_TPEXAM" )
        aadd( aHeader, cTabela + "_DTASO"  )
        aadd( aHeader, cTabela + "_RESULT" )    
        aadd( aHeader, cTabela + "_CPFRES" )
        aadd( aHeader, cTabela + "_NRCRM"  )
        aadd( aHeader, cTabela + "_NOMRES" )
    EndIf

    If oInput["eventCode"] $ "S-2221"
        aadd( aHeader, cTabela + "_DTEXAM" )
        aadd( aHeader, cTabela + "_NMMED" )
        aadd( aHeader, cTabela + "_NRCRM" )
    EndIf

    If oInput["eventCode"] $ "S-2220|"
        aadd( aHeader, "CM7_CODIGO" )
        aadd( aHeader, "CM7_NOME" )
    EndIf

    If oInput["eventCode"] $ "S-2230"
        aadd( aHeader, cTabela + "_MOTVAF" )
        aadd( aHeader, cTabela + "_DTFAFA" )
    EndIf

    If oInput["eventCode"] $ "S-2240"
        aadd( aHeader, cTabela + "_DTINI" )    
        aadd( aHeader, "T0Q_LAMB" )  
        aadd( aHeader, "T0Q_DSETOR" )
        aadd( aHeader, "T0Q_TPINSC" )
        aadd( aHeader, "T0Q_NRINSC" )    
    EndIf

    If oInput["eventCode"] $ "S-2245"
        aadd( aHeader, cTabela + "_CODTCA" )
        aadd( aHeader, cTabela + "_OBSTCA" )
    EndIf

    If oInput["eventCode"] $ "S-2250"
        aadd( aHeader, cTabela + "_DTAVIS" )
        aadd( aHeader, cTabela + "_TPAVIS" )
    EndIf

    If oInput["eventCode"] $ "S-2230|S-2250"
        aadd( aHeader, cTabela + "_DTAFAS" )
    EndIf

    If oInput["eventCode"] $ "S-2260"
        aadd( aHeader, cTabela + "_CONVOC" )    
        aadd( aHeader, cTabela + "_DTINIP" )
        aadd( aHeader, cTabela + "_DTFIMP" )
        aadd( aHeader, cTabela + "_DTPREV" )
    EndIf

    If oInput["eventCode"] $ "S-2299"
        aadd( aHeader, cTabela + "_DTDESL" )
    EndIf

    If oInput["eventCode"] $ "S-2399"
        aadd( aHeader, cTabela + "_DTERAV" )
    EndIf

    If oInput["eventCode"] $ "S-2298"
        aadd( aHeader, cTabela + "_DTRET" )
        aadd( aHeader, cTabela + "_DTEFEI" )
    EndIf

    If oInput["eventCode"] $ "S-3000"
        AAdd(aHeader, cTabela + "_NIS")
        AAdd(aHeader, cTabela + "_INDAPU")
    EndIf

    If oInput["eventCode"] $ "S-2231"
        aadd( aHeader, "V72_DTINIC" )
        aadd( aHeader, "V72_CNPJCE" )
        aadd( aHeader, "V72_DTTERM" )
        aadd( aHeader, "V72_RESPRE" )
    EndIf

    If oInput["eventCode"] $ "S-2400|S-2405|S-2410|S-2416|S-2418|S-2420"
        aadd( aHeader, cTabela + "_CPFBEN" )
    EndIf

    If oInput["eventCode"] $ "S-2410|S-2416|S-2418|S-2420"
        aadd( aHeader, cTabela + "_NRBENF" )
    EndIf

    If oInput["eventCode"] $ "S-2410|S-2416"
        aadd( aHeader, cTabela + "_TPBENE" )
        aadd( aHeader, cTabela + "_TPPENS" )
    EndIf

    If oInput["eventCode"] $ "S-2410|S-2420"
        aadd( aHeader, cTabela + "_MTVTER" )
    EndIf

    If oInput["eventCode"] $ "S-2400|S-2405"
        aadd( aHeader, "V73_NOMEB" )
        aadd( aHeader, "V73_INCFIS" )
        aadd( aHeader, "V73_DTINCF" )
    EndIf

    If oInput["eventCode"] $ "S-2400"
        AAdd(aHeader, "V73_DTINIC")
    EndIf

    If oInput["eventCode"] $ "S-2405"
        aadd( aHeader, "V73_DTALTE" )
    EndIf

    If oInput["eventCode"] $ "S-2410"
        aadd( aHeader, "V75_MATRIC" )
        aadd( aHeader, "V75_SITBEN" )
        aadd( aHeader, "V75_DTINBE" )
        aadd( aHeader, "V75_CADINI" )
        aadd( aHeader, "V75_CNPJDS" )
        aadd( aHeader, "V75_DTPUBL" )
        aadd( aHeader, "V75_DTTERM" )
    EndIf

    If oInput["eventCode"] $ "S-2416"
        aadd( aHeader, "V76_DALTBE" )
        aadd( aHeader, "V76_INDSUS" )
        aadd( aHeader, "V76_MTSUSP" )
    EndIf

    If oInput["eventCode"] $ "S-2418"
        aadd( aHeader, "V77_DTREAT" )
        aadd( aHeader, "V77_DTEF"   )
    EndIf

    If oInput["eventCode"] $ "S-2420"
        aadd( aHeader, "V78_DTTERM" )
        aadd( aHeader, "V78_CNPJO" )
        aadd( aHeader, "V78_NEWCPF" )
    EndIf

    If oInput["eventCode"] $ "S-2190|S-2400|S-2500"
        AAdd(aHeader, cTabela + "_DTNASC")
    EndIf

    If oInput["eventCode"] $ "S-1202"
        AAdd(aHeader, "C9V_DTNASC")
    EndIf

    If oInput["eventCode"] $ "S-1207|S-2190|S-3000|S-3500"
        AAdd(aHeader, cTabela + "_CPF")
    EndIf
    
    If oInput["eventCode"] $ "S-2500"
        AAdd(aHeader, cTabela + "_ORIGEM")
        AAdd(aHeader, cTabela + "_CPFTRA")
        AAdd(aHeader, cTabela + "_NMTRAB")
    EndIf

    If oInput["eventCode"] $ "S-2500|S-2501"
        AAdd(aHeader, cTabela + "_NRPROC")
    EndIf

    If oInput["eventCode"] $ "S-2555" .And. TAFAlsInDic( "T8I" )
        AAdd(aHeader, cTabela + "_NRPROC")
    EndIf

    If oInput["eventCode"] $ "S-3000|S-3500"
        AAdd(aHeader, EncodeUTF8(STR0009)) // "Descrição"
        AAdd(aHeader, cTabela + "_TPEVEN")
        AAdd(aHeader, cTabela + "_NRRECI")
    EndIf

    If oInput["eventCode"] $ "S-3500"
        AAdd(aHeader, cTabela + "_PROCTR")
    EndIf

    AAdd(aHeader,  "alert") //Indica que existem alertas do RET para o registro

Return aHeader

//--------------------------------------------------------------------
/*/{Protheus.doc} function fGetData
Função que consulta e retorna os valores dos campos no banco de dados
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function fGetData(oInput as json, aHeader as array, nPage as numeric, nPageSize as numeric, lHasNext as logical, aFil as Array)

    Local aAux          as array
    Local aChave        as array
    Local aData         as array
    Local aDescriEvt    as array
    Local aDtRefEve     as array
    Local aGetArea      as array
    Local aIndApu       as array
    Local aMotives      as array
    Local aTafInfo      as array
    Local aTipAcid      as array
    Local aTpAvis       as array
    Local aTpExam       as array
    Local cAliasTAF     as character
    Local cAux          as character
    Local cBanco        as character
    Local cBranQry      as character
    Local cBranQryC1E   as character
    Local cC1EFilTaf    as character
    Local cCampoTable   as character
    Local cCmpCPF       as character
    Local cCmpNome      as character
    Local cCmpProc      as character
    Local cCpf          as character
    Local cDtAux        as character
    Local cEvent        as character
    Local cEventsTab    as character
    Local cFieldTAF     as character
    Local cFil          as character
    Local cFilter       as character
    Local cFunc         as character
    Local cHrAcid       as character
    Local cIDCateg      as character
    Local cKeyTafLength as character
    Local cMotAfas      as character
    Local cMotives      as character
    Local cOrderFields  as character
    Local cPerApu       as character
    Local cPeriod       as character
    Local cPeriodFilter as character
    Local cPeriodFrom   as character
    Local cPeriodTo     as character
    Local cQuery        as character
    Local cTabela       as character
    Local cTypeEvent    as character
    Local cXFilBkp      as character
    Local cFieldsChv    as character
    Local cTableDB      as character
    Local cTpInsc       as character
    Local lExibFil      as logical
    Local lFilter       as logical
    Local lHasFilPeriod as logical
    Local lJoin         as logical
    Local lPeriodFilter as logical
    Local lSeek         as logical
    Local lTabela       as logical
    Local nPos          as numeric
    Local nW            as numeric
    Local nX            as numeric
    Local nY            as numeric
    Local xTpInsc       as variant

    Default aFil      := {}
    Default aHeader   := {}
    Default lHasNext  := .F.
    Default nPage     := 0
    Default nPageSize := 0
    Default oInput    := JsonObject():New()

    aAux          := {}
    aChave        := {}
    aData         := {}
    aDescriEvt    := {}
    aDtRefEve     := {}
    aGetArea      := GetArea()
    aIndApu       := {}
    aMotives      := {}
    aTafInfo      := AdjustEventDate(TAFRotinas(oInput["eventCode"], 4, .F., 2))
    aTipAcid      := {}
    aTpAvis       := {}
    aTpExam       := {}
    cAliasTAF     := GetNextAlias()
    cAux          := ""
    cBanco        := Upper(AllTrim(TCGetDB()))
    cBranQry      := ""
    cBranQryC1E   := ""
    cC1EFilTaf    := ""
    cCampoTable   := aTafInfo[6]
    cChave        := ""
    cCmpCPF       := ""
    cCmpNome      := ""
    cCmpProc      := ""
    cCpf          := ""
    cDtAux        := ""
    cEvent        := oInput["eventCode"]
    cEventsTab    := "S-1005|S-1010|S-1020|S-1030|S-1035|S-1040|S-1050|S-1060|S-1070|S-1080|"
    cFieldTAF     := ""
    cFil          := ""
    cFilter       := Iif( oInput["genericFilter"] <> NIL, oInput["genericFilter"], oInput["nameOrCPF"] )
    cFunc         := ""
    cHrAcid       := ""
    cIDCateg      := ""
    cMotAfas      := ""
    cMotives      := ""
    cOrderFields  := ""
    cPerApu       := ""
    cFieldsChv    := ""
    cTableDB      := ""
    cTpInsc       := ""
    cPeriod       := oInput["period"]
    cPeriodFilter := oInput["periodFilter"]
    cPeriodFrom   := oInput["periodFrom"]
    cPeriodTo     := oInput["periodTo"]
    cQuery        := ""
    cTabela       := aTafInfo[3]
    cTabInd1      := "S-2205|S-2206|S-2210|S-2220|S-2240|S-2230|S-2260|S-2250|S-2245|S-2221|S-2298|S-2299|S-2306|S-2399|S-2231|S-3500|"
    cTypeEvent    := aTafInfo[12]
    cXFilBkp      := cFilAnt
    lFilter       := Iif(!Empty(cFilter), .T., .F.)
    lHasFilPeriod := !(Empty(cPeriodFrom) .And. Empty(cPeriodTo) .And. Empty(cPeriod))
    lJoin         := cEvent $ "S-1200|S-1202|S-1207|S-1210|S-2210|S-2220|S-2230|S-2231|S-2240|S-2241|S-2245|S-2250|S-2260|S-2298|S-2299|S-2399|S-2221"
    lPeriodFilter := Iif(!Empty(cPeriodFilter), .T., .F.)
    lSeek         := .F.
    lTabela       := cEvent $ "S-2190|S-2200|S-2205|S-2206|S-2300|S-2306|S-2400|S-2405|S-2410|S-2416|S-2418|S-2420|S-2500|S-2501|S-2555|S-3000|S-3500"
    lExibFil      := cEvent $ "S-1280|S-1250|S-1260|S-1295|S-1298|S-1299|S-1300"
    nPos          := 0
    nW            := 0
    nX            := 0
    nY            := 0
    xTpInsc       := Nil

    cKeyTafLength := IIf(cBanco == "POSTGRES", StrZero(GetSx3Cache( cTabela + "_FILIAL","X3_TAMANHO") + GetSx3Cache( cTabela + "_ID","X3_TAMANHO") + GetSx3Cache( cTabela + "_VERSAO","X3_TAMANHO") + 2, 2), Nil)

    If oInput["motiveCode"] <> NIL
        aMotives := aClone(oInput["motiveCode"])
    EndIf
 
    cBranQry    := fGetFil( cEvent, aFil ) // Retorno da Filial origem da Tabela do TAF
    cBranQryC1E := fGetFil( cEvent, aFil, "C1E" )

    For nX := 1 To Len( aHeader )

        If aHeader[nX] == 'alert'
            Loop
        EndIf 

        If Left(AllTrim(aHeader[nX]), 3) <> "M0_" .And. AT("error",  aHeader[nX] ) == 0 .And. AT( cTabela, aHeader[nX] ) > 0 .And. AT( EncodeUTF8(STR0009), aHeader[nX] ) == 0 // "Descrição"
           
           If AT("|",  aHeader[nX] ) > 0

                aAux := StrTokArr( aHeader[nX], "|" )

                If cBanco $ "ORACLE|DB2|INFORMIX|OPENEDGE"
                    
                    For nY := 1 To Len(aAux)
                        
                        If nY <> Len(aAux)
                            cFieldsChv += aAux[nY] + " || '|' || "
                        Else
                            cFieldsChv += aAux[nY] + " AS KEYTAF, "
                        EndIf

                        cFieldTAF += aAux[nY] + ", "
                        cOrderFields += aAux[nY] + ", "

                    Next nY

                Else

                    cFieldsChv += " ("
                    
                    For nY := 1 To Len(aAux)

                        If nY <> Len(aAux)

                            cFieldsChv   += aAux[nY] + " || '|' || "
                            
                        Else

                            If cKeyTafLength == Nil
                                cFieldsChv += aAux[nY] + " ) AS KEYTAF, "
                            Else
                                cFieldsChv += aAux[nY] + " )::VARCHAR(" + cKeyTafLength + ") AS KEYTAF, "
                            EndIf

                        EndIf
                        
                        cFieldTAF += aAux[nY] + ", "
                        cOrderFields += aAux[nY] + ", "

                    Next nY

                EndIf

            Else

                If !(lExibFil .and. ctabela + '_FILIAL' == aHeader[nX])
                    cFieldTAF    += aHeader[nX]    
                    cOrderFields += aHeader[nX]
                EndIf 
                
                If !(lExibFil .and. ctabela + '_FILIAL' == aHeader[nX]) .and. nX != Len( aHeader )
                    cFieldTAF    += ","
                    cOrderFields += ","
                EndIf

            EndIf

        EndIf

    Next nX

    If SubStr( cFieldTAF, -1) == ","
        cFieldTAF := SubStr( cFieldTAF, 0, Len( cFieldTAF ) -1 )    
    EndIf

    If SubStr( cOrderFields, -1) == ","
        cOrderFields := SubStr( cOrderFields, 0, Len( cOrderFields ) -1 )
    EndIf

    cOrderFields :=  ' ALERT_COUNT DESC,' + cOrderFields // Ordenação por quantidade de alertas (Warnings RET)

    // Montagem da consulta
    cQuery := "SELECT * FROM ( "
    
    If cBanco != "OPENEDGE"
        cQuery += "SELECT ROW_NUMBER() OVER(ORDER BY " +cOrderFields+ ") ITEMNUMBER, COUNT (1) OVER() TOTALNUMBER,"	
    Else
        cQuery += "SELECT COUNT (1) TOTALNUMBER,"	
    EndIf

    cTableDB := RetSqlName(cTabela) 

    cQuery += cFieldTAF + " ,KEYTAF, ALERT_COUNT "
    cQuery += " FROM " 
    cQuery += "(SELECT " 
    cQuery += cFieldTAF + ',' + cFieldsChv
    cQuery += "(SELECT COUNT(V2H_IDCHVE) FROM " + RetSqlName("V2H") 
    cQuery += " WHERE ('" + StrTran(cEvent,"-","")  + "' || " + cTableDB + "." + cTabela + "_ID || " + cTableDB + "." + cTabela + "_VERSAO) = V2H_IDCHVE  AND V2H_CODREC = '202') AS ALERT_COUNT " 
    cQuery += " FROM " + cTableDB    
                  

    If lFilter .AND. lJoin

        cQuery += " INNER JOIN " + RetSqlName("C9V") + " C9V "
        cQuery += " ON C9V.C9V_FILIAL = " + cTabela + "_FILIAL "

        If cEvent $ "S-1200|S-1202"
            cQuery += " AND (C9V.C9V_ID = C91_TRABAL OR C9V.C9V_CPF = C91_CPF) "
        ElseIf cEvent $ "S-1210"
            cQuery += " AND (C9V.C9V_ID = T3P_BENEFI OR C9V.C9V_CPF = T3P_CPF) "
        Else
            cQuery += " AND C9V.C9V_ID = " + cTabela + RetCmp(oInput["eventCode"])
        EndIf

        cQuery += " AND ( UPPER(C9V.C9V_CPF) LIKE '%" + Upper(StrTran(StrTran(cFilter, '-'), '.')) + "%' OR UPPER(C9V.C9V_NOME) LIKE '%" + Upper(cFilter) + "%' ) "
        cQuery += " AND C9V.C9V_ATIVO = '1' AND C9V.D_E_L_E_T_ = '' "

    EndIf

    If cCampoTable $ "CUP_DTADMI|CUP_DTINVI"

        cQuery += " INNER JOIN " + RetSqlName("CUP") + " CUP ON C9V_FILIAL = CUP_FILIAL "
        cQuery += " AND C9V_ID = CUP_ID  "
        cQuery += " AND C9V_VERSAO = CUP_VERSAO "
        cQuery += " AND CUP.D_E_L_E_T_ = ' ' "

    EndIf

    cQuery += " WHERE "

    If lFilter .AND. lTabela        
             
        Do Case

            Case cEvent $ "S-2500"

                If TafColumnPos('V9U_NRPROC')
                    cQuery += " ( UPPER(V9U_CPFTRA) LIKE '%" + Upper(StrTran(StrTran(cFilter, '-'), '.')) + "%' OR UPPER(V9U_NRPROC) LIKE '%" + Upper(StrTran(StrTran(cFilter, '-'), '.')) + "%' ) AND "
                EndIf

            Case cEvent $ "S-2501"

                If TafColumnPos('V7C_NRPROC')
                    cQuery += " ( UPPER(V7C_NRPROC) LIKE '%" + Upper(StrTran(StrTran(cFilter, '-'), '.')) + "%' ) AND "    
                EndIf    

            Case cEvent $ "S-3500"

                 If TafColumnPos('V7J_CPF')
                    cQuery += " ( UPPER(V7J_CPF) LIKE '%" + Upper(StrTran(StrTran(cFilter, '-'), '.')) + "%' OR UPPER(V7J_PROCTR) LIKE '%" + Upper(StrTran(StrTran(cFilter, '-'), '.')) + "%' ) AND "
                EndIf        

            Otherwise

                //Tratamento para distinguir campo CPF/NOME de Trabalhador (C9V) do de Beneficiário (V73)
                If TafColumnPos(cTabela + "_CPF")   

                    cCmpCPF     := cTabela + "_CPF"
                    cCmpNome    := cTabela + "_NOME"

                ElseIf TafColumnPos(cTabela + "_CPFBEN")

                    cCmpCPF     := cTabela + "_CPFBEN"
                    cCmpNome    := cTabela + "_NOMEB"               

                EndIf

                cQuery += " ( UPPER(" + cCmpCPF + ") LIKE '%" + Upper(StrTran(StrTran(cFilter, '-'), '.')) + "%' " 

                If !TAFisBDLegacy()             
                    cQuery += Iif(TafColumnPos(cCmpNome), "OR UPPER(TRANSLATE(" + cCmpNome + "," + RetTranslate() + ")) LIKE '%" + Upper(StrTran(StrTran(NoAcento(DecodeUtf8(cFilter)), '-'), '.')) + "%' ) AND ",") AND " )
                Else
                    cQuery += Iif(TafColumnPos(cCmpNome), "OR UPPER(" + cCmpNome + ") LIKE '%" + Upper(StrTran(StrTran(DecodeUtf8(cFilter), '-'), '.')) + "%' ) AND ",") AND " )
                EndIf 
        
        EndCase
        
    EndIf

    //Proteção, pois a alteração realizada no Front ainda não foi liberada para os clientes
    If ValType(oInput["status"]) != "A"

       oInput["status"] := { oInput["status"] }

    EndIf

    If !Empty( oInput["status"] ) .AND. ALLTRIM( oInput["status"] ) != "-1"

        For nY := 1 to Len(oInput["status"])

            If nY == 1
                cAux := ""
            Else
                cAux += ", "
            EndIf
        
            //De/Para do Status do Front para o status do BackEnd 
            If  ALLTRIM( oInput["status"][nY] ) == "1" 

                cAux += " '', '0' , '1' "

            ElseIf ALLTRIM( oInput["status"][nY]) == "5" 

                If oInput['eventCode'] $ cEventsTab
                    cAux += " '4' "
                Else
                    // retirado status 6 para que os eventos excluídos pendente de tranmissão sejam visualizados apenas no S-3000
                    cAux += " '7' "
                EndIf

            Else

                cAux += " '" + ALLTRIM( oInput["status"][nY] ) + "' "

            EndIf

        Next

        cQuery += cTabela + "_STATUS IN  ( " + cAux + " ) AND "

    EndIf

    If cEvent <> "S-3000" .AND. cTypeEvent <> "C"

        If aTafInfo[12] == "E"

            If !Empty(aTafInfo[6])  .And. lHasFilPeriod   

                aDtRefEve   := StrTokArr(aTafInfo[6], "|")
                cQuery      += " ("

                For nY := 1 To Len(aDtRefEve)

                    If !Empty(cPeriodFrom) .OR. !Empty(cPeriodTo)
                        cQuery += aDtRefEve[nY] + " BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
                    ElseIf !Empty(cPeriod)
                        cQuery += aDtRefEve[nY] + " BETWEEN '" + cPeriod + "01" + "' AND '" + cPeriod + "31" + "' "
                    EndIf

                    cQuery  += Iif(nY != Len(aDtRefEve), " OR ", ") AND ")    

                Next nY 

            Else  

                If cEvent == "S-2230" .AND. !Empty(cPeriodFrom) .AND. !Empty(cPeriodTo)
                    cQuery += " ( CM6_DTAFAS BETWEEN '" + cPeriodFrom + "' AND '"  + cPeriodTo + "' OR "
                    cQuery +=   " CM6_DTFAFA BETWEEN '" + cPeriodFrom + "' AND '"  + cPeriodTo + "' ) AND "
                EndIf

            EndIf

        Else 

            If !Empty(cPeriod)

                If !Empty(aTafInfo[6])

                    cQuery += " (" + aTafInfo[6] + " = '" + cPeriod + "' OR " + aTafInfo[6] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "') AND "
                
                Else

                    If cTypeEvent == "M" .AND. !Empty(cPeriod) .AND. !Empty(cTabela)
                        cQuery += cTabela + "_PERAPU = '" + cPeriod + "' AND "
                    EndIf

                EndIf

            EndIf

        EndIf

    ElseIf cEvent == "S-3000" .AND. cTypeEvent <> "C" .AND. lHasFilPeriod

        If !Empty(aTafInfo[6])    

            aDtRefEve   := StrTokArr(aTafInfo[6], "|")
            cQuery      += " ("

            For nY := 1 To Len(aDtRefEve)

                If !Empty(cPeriod) .AND. ( Empty(cPeriodFrom) .OR. Empty(cPeriodTo) )

                    cQuery += " (" + aTafInfo[6] + " = '" + cPeriod + "' OR " + aTafInfo[6] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "') "
                
                ElseIf ( !Empty(cPeriodFrom) .OR. !Empty(cPeriodTo) ) .AND. Empty(cPeriod )
                
                    cQuery += " CMJ_PERAPU = '' AND CMJ_DINSIS BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "' "
                
                Else 

                    cQuery += " (" + aTafInfo[6] + " = '" + cPeriod + "' OR " + aTafInfo[6] + " = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "') OR "
                    cQuery += " ( CMJ_PERAPU = '' AND CMJ_DINSIS BETWEEN '" + cPeriodFrom + "' AND '" + cPeriodTo + "') "
                
                EndIf

                cQuery  += Iif(nY != Len(aDtRefEve), " OR ", ") AND ") 

            Next nY 

        EndIf    

    EndIf

    If cEvent $ cEventsTab .And. !Empty(cPeriod)

        If len(cPeriod)>5          
            cQuery += cTabela + "_DTINI = '" + Right(cPeriod, 2) + Left(cPeriod, 4) + "' AND " 
        Else
            cQuery += "SUBSTRING(" + cTabela + "_DTINI,3, 4) = '" + cPeriod + "' AND "    
        EndIf

    EndIf

    If cEvent == "S-1000"
        cQuery += cTabela + "_MATRIZ = 'T' AND " + cTabela + "_FILTAF IN ( SELECT FILIAIS.FILIAL FROM " + cBranQryC1E + " FILIAIS ) AND "
    EndIf

    If cEvent == "S-2200" .OR. cEvent == "S-2300" .OR. cEvent $ "S-2400|S-2405"
        cQuery += cTabela + "_NOMEVE = '"+ StrTran(cEvent,"-","") + "' AND "
    EndIf

    cQuery += RetSqlName(cTabela) + ".D_E_L_E_T_ <> '*' "

    If cEvent == "S-2230"

        If Len(aMotives) > 0

            For nW := 1 To Len(aMotives)

                If nW == Len(aMotives)
                    cMotives += Posicione("C8N", 2, xFilial("C8N") + aMotives[nW], "C8N_ID")
                Else
                    cMotives += Posicione("C8N", 2, xFilial("C8N") + aMotives[nW], "C8N_ID") + ","
                EndIf

            Next nW

            cMotives := FormatIn(cMotives, ",")
            cQuery += " AND CM6_MOTVAF IN " + cMotives + " "

        EndIf

    EndIf

    If TafColumnPos( cTabela + "_STASEC" ) .AND. cEvent $ "S-2205|S-2206"
        cQuery += " AND (" + cTabela + "_ATIVO = '1' OR ( " + cTabela + "_ATIVO = '2' AND " + cTabela + "_STATUS = '7' ) ) "
    ElseIf TafColumnPos( cTabela + "_STASEC" )
        cQuery += " AND (" + cTabela + "_ATIVO = '1' OR " + cTabela + "_STASEC = 'E' OR ( " + cTabela + "_ATIVO = '2' AND " + cTabela + "_STATUS = '7' ) ) "
    ElseIf cEvent $ cEventsTab
        cQuery += " AND (" + cTabela + "_ATIVO = '1' OR ( " + cTabela + "_EVENTO = 'E' AND " + cTabela + "_ATIVO = '2' AND " + cTabela + "_STATUS = '4' )) "        
    Else
        cQuery += " AND (" + cTabela + "_ATIVO = '1' OR ( " + cTabela + "_ATIVO = '2' AND " + cTabela + "_STATUS = '7' ) ) "
    EndIf

    If lPeriodFilter

        If !Empty(aTafInfo[6])

            If Len(cPeriodFilter) > 5
                cQuery += "AND (" + aTafInfo[6] + " = '" + cPeriodFilter + "' ) "
            Else
                cQuery += "AND (" + aTafInfo[6] + " BETWEEN '" + cPeriodFilter + "01' AND '" + cPeriodFilter + "12') "
            EndIf  

        EndIf

    EndIf

    cQuery += "AND " + cTabela + "_FILIAL IN ( SELECT FILIAIS.FILIAL FROM " + cBranQry + " FILIAIS ) " 

    If cEvent == "S-1070"
        cQuery += " AND " + cTabela + "_ESOCIA = '1' "
    EndIf 

    If cEvent $ "S-1200|S-1202"

        cQuery += " AND " + cTabela + "_NOMEVE = '" + StrTran(cEvent, "-") + "' "
        cQuery += " GROUP BY C91_FILIAL, C91_ID, C91_VERSAO, C91_PERAPU, C91_EVENTO, C91_STATUS " 

    ElseIf cEvent $ "S-1210"

        cQuery += " GROUP BY T3P_FILIAL, T3P_ID, T3P_VERSAO, T3P_PERAPU, T3P_EVENTO, T3P_STATUS " 

    EndIf

    cQuery += ") CMDSUB"

    If cBanco != "OPENEDGE"

        cQuery += ") QRY WHERE (QRY.ITEMNUMBER BETWEEN " + Alltrim(Str((nPage - 1) * nPageSize + 1)) + " AND " + Alltrim(Str((nPage * nPageSize))) + ") "
        
        If cEvent <> "S-3000"
            cQuery += "AND " + cTabela + "_STATUS <> '6' "
        EndIf

    Else

        If !oInput["eventCode"] $ "S-1200|S-1202|S-1210"
            cQuery += " GROUP BY " + cOrderFields
        EndIf

        cQuery += ") QRY "

        If oInput['eventCode'] <> "S-3000"
            cQuery += "WHERE " + cTabela + "_STATUS <> '6' "
        EndIf

        cQuery += "OFFSET " + Alltrim(Str((nPage - 1) * nPageSize )) + " ROWS FETCH NEXT " + Alltrim(Str((nPage * nPageSize))) + " ROWS ONLY"
        
    EndIf

    // Execute Query
    cQuery := ChangeQuery(cQuery)
    DBUseArea( .T., "TOPCONN", TcGenQry( , ,cQuery), cAliasTAF, .T., .T. )

    // Pega todas as ocorrências encontradas na consulta
    aAux   := {}
    
    If (cAliasTAF)->( !Eof() )

        ChkFile("C9V") //Garanto que a tabela esteja aberta para realizar o Posicione corretamente
        ChkFile("C92") //Garanto que a tabela esteja aberta para realizar o Posicione corretamente

        If (cAliasTAF)->TOTALNUMBER > nPage * nPageSize
            lHasNext := .T.
        EndIf

        While ( cAliasTAF )->( !Eof() )

            cChave := RTrim(StrTran((cAliasTAF)->KEYTAF, "|", ""))

            For nX := 1 To Len( aHeader )

                If AT("|",  aHeader[nX] ) == 0 .AND. GetSx3Cache(aHeader[nX],"X3_TIPO") == "D" .AND. AT(cTabela, aHeader[nX]) > 0
                    
                    aAdd( aAux, IIF( Empty((cAliasTAF )->&( aHeader[nX] )) , "" , SUBSTR( ( cAliasTAF )->&( aHeader[nX] ), 0, 4 ) + "-"+ SUBSTR( ( cAliasTAF )->&( aHeader[nX] ), 5, 2 ) + "-"+ SUBSTR( ( cAliasTAF )->&( aHeader[nX] ), 7, 2 ) ) )
                
                Else
                    
                    If AT("|",  aHeader[nX] ) > 0
                        
                        aAdd( aAux, RTrim(( cAliasTAF )->KEYTAF) )

                    ElseIf aHeader[nX] == "alert"

                        aAdd( aAux, IIf (( cAliasTAF )->ALERT_COUNT  > 0, .T., .F. ))

                    ElseIf aHeader[nX] == "error"
                        
                        aAdd( aAux, "" )

                    ElseIf AT("C9V_", aHeader[nX]) > 0 .And. !(cEvent $ "S-2200|S-2300")

                        aChave := StrTokArr((cAliasTAF)->KEYTAF, "|")

                        If cEvent $ cTabInd1

                            (cTabela)->(DbSetOrder(1))
                            If (cTabela)->(MsSeek(cChave) )

                                If !Empty(xFilial("C9V")) .AND. xFilial("C9V") != (cTabela)->&(cTabela + "_FILIAL")
                                    cFilAnt := (cTabela)->&(cTabela + "_FILIAL")
                                EndIf

                                lSeek := .T.

                            EndIf

                        EndIf

                        Do Case

                            Case cEvent $ "S-1200|S-1202"

                                C91->(DbSetOrder(1))
                                If C91->(MsSeek(PadR( aChave[1], TamSx3( "C91_FILIAL" )[1]) + PadR( aChave[2], TamSx3( "C91_ID" )[1]) + PadR( aChave[3], TamSx3( "C91_VERSAO" )[1]) + StrTran(cEvent, "-", "") + IIf((cAliasTAF)->C91_EVENTO != "E", "1", "2")))
                                   
                                    If !Empty(xFilial("C9V")) .And. xFilial("C9V") != C91->C91_FILIAL
                                        cFilAnt := C91->C91_FILIAL
                                    EndIf

                                    If Empty(C91->C91_TRABAL)

                                        If !Empty(C91->C91_CPF)

                                            If "_DTNASC" $ aHeader[nX]
                                                cCampo := "C91_NASCTO"
                                            ElseIf "_NOME" $ aHeader[nX] 
                                                cCampo := "C91_NOME"
                                            ElseIf "_CPF" $ aHeader[nX] 
                                                cCampo := "C91_CPF"
                                            EndIf

                                            If GetSx3Cache(cCampo, "X3_TIPO") == "D"
                                                
                                                cDtAux := DTOS(Posicione("C91", 12, xFilial("C91") + C91->C91_CPF + "1", cCampo))
                                                aAdd( aAux, Iif(Empty(cDtAux), "", SUBSTR( cDtAux, 0, 4 ) + "-"+ SUBSTR( cDtAux, 5, 2 ) + "-"+ SUBSTR( cDtAux, 7, 2 )))                                       
                                            
                                            Else
                                               
                                                cAux := AllTrim(Posicione("C91", 12, xFilial("C91") + C91->C91_CPF + "1", cCampo))

                                                If Empty(cAux) .And. cCampo == "C91_NOME"
                                                    cAux := AllTrim(GetMVName(C91->C91_FILIAL, C91->C91_CPF))
                                                EndIf

                                                aAdd(aAux, EncodeUTF8(Upper(cAux)))

                                            EndIf 

                                        Else
                                            aAdd( aAux, "") 
                                        EndIf  

                                    Else

                                        If TafColumnPos("C91_ORIEVE") .And. C91->C91_ORIEVE == 'S2190'

                                            DbSelectArea("T3A")

                                            If "_CPF" $ aHeader[nX]
                                                aAdd( aAux, EncodeUTF8(Posicione("T3A", 3, xFilial("T3A") + C91->C91_TRABAL + "1", "T3A_CPF")) )
                                            ElseIf "_NOME" $ aHeader[nX]  
                                                aAdd( aAux, "TRABALHADOR PRELIMINAR")                
                                            Else
                                                aAdd( aAux, "")
                                            EndIf

                                        Else

                                            If GetSx3Cache(aHeader[nX],"X3_TIPO") == "D" 

                                                cDtAux := DTOS(Posicione("C9V", 2, xFilial("C9V") + C91->C91_TRABAL + "1", aHeader[nX]))
                                                aAdd( aAux, Iif(Empty(cDtAux), "", SUBSTR( cDtAux, 0, 4 ) + "-"+ SUBSTR( cDtAux, 5, 2 ) + "-"+ SUBSTR( cDtAux, 7, 2 )))
                                            
                                            Else 

                                                If "_NOME" $ aHeader[nX] 

                                                    aAdd( aAux, GetNomeTra(C91->C91_FILIAL, C91->C91_CPF, C91->C91_TRABAL) )
                                                
                                                Else

                                                    cCpf := Posicione("C9V", 2, xFilial("C9V") + C91->C91_TRABAL + "1", aHeader[nX])
                                                    
                                                    If Empty(cCpf)
                                                        cCpf := Posicione("C9V", 2, xFilial("C9V") + C91->C91_TRABAL + "2", aHeader[nX])
                                                    EndIf

                                                    aAdd( aAux, EncodeUTF8(cCpf) )

                                                EndIf

                                            EndIf

                                        EndIf

                                    EndIf

                                Else

                                    aAdd( aAux, "") 
                                    
                                EndIf
                                
                            Case "S-1210" == cEvent

                                T3P->(DbSetOrder(4))
                                If T3P->(MsSeek(PadR( aChave[1], TamSx3( "T3P_FILIAL" )[1]) + PadR( aChave[2], TamSx3( "T3P_ID" )[1]) + IIf((cAliasTAF)->T3P_EVENTO != "E", "1", "2")))
                                    
                                    If !Empty(xFilial("C9V")) .And. xFilial("C9V") != T3P->T3P_FILIAL
                                        cFilAnt := T3P->T3P_FILIAL
                                    EndIf

                                    If Empty(T3P->T3P_BENEFI)

                                        If !Empty(T3P->T3P_CPF)
                                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 3, xFilial("C9V") + T3P->T3P_CPF + "1", aHeader[nX])) )
                                        Else
                                            aAdd( aAux, "")
                                        EndIf

                                    ElseIf TafColumnPos("T3P_ORIEVE") .And. T3P->T3P_ORIEVE == "S2400"

                                        If "_CPF" $ aHeader[nX]
                                            cCampo := "V73_CPFBEN"
                                        ElseIf "_NOME" $ aHeader[nX] 
                                            cCampo := "V73_NOMEB"
                                        EndIf

                                        aAdd( aAux, EncodeUTF8(Posicione("V73", 4, xFilial("V73")  + T3P->T3P_BENEFI + "1", cCampo)) )

                                    Else

                                        If "_NOME" $ aHeader[nX]
                                            aAdd( aAux, EncodeUTF8(GetNomeTra(T3P->T3P_FILIAL, T3P->T3P_CPF, T3P->T3P_BENEFI)))
                                        Else
                                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + T3P->T3P_BENEFI + "1", aHeader[nX])) )
                                        EndIf

                                    EndIf

                                Else

                                    aAdd( aAux, "")

                                EndIf       

                            Case cEvent $ "S-2205|S-2206"

                                If (ctabela)->(MsSeek(cChave + IIf((cAliasTAF)->&(ctabela + "_EVENTO") != "E", "1", "2")))

                                    If !Empty(xFilial("C9V")) .And. xFilial("C9V") != (ctabela)->&(ctabela + "_FILIAL")
                                        cFilAnt := (ctabela)->&(ctabela + "_FILIAL")
                                    EndIf

                                    If aHeader[nX] != "C9V_MATRIC"

                                        aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + (ctabela)->&(ctabela + "_ID") + "1", aHeader[nX])) )
                                   
                                    Else

                                        cMatric := EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + (ctabela)->&(ctabela + "_ID") + "1", aHeader[nX]))

                                        If Empty(cMatric)
                                            cMatric := EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + (ctabela)->&(ctabela + "_ID") + "1", "C9V_MATTSV")) 
                                        EndIf

                                        aAdd( aAux, cMatric )

                                    EndIf

                                Else

                                    aAdd( aAux, "")

                                EndIf     
                            
                            Case cEvent $ "S-2210|S-2220|S-2240" //SST
                                
                                If lSeek

                                    cFunc := Iif(cEvent $ "S-2210","_TRABAL","_FUNC")

                                    If (cTabela)->&(cTabela + "_NOMEVE") == 'S2190' 

                                        If "_CPF" $ aHeader[nX]
                                            aAdd( aAux, EncodeUTF8(Posicione("T3A", 3, xFilial("T3A") + (cTabela)->&(cTabela + cFunc) + "1", "T3A_CPF")) )
                                        ElseIf "_MATRIC" $ aHeader[nX]
                                            aAdd( aAux, EncodeUTF8(Posicione("T3A", 3, xFilial("T3A") + (cTabela)->&(cTabela + cFunc) + "1", "T3A_MATRIC")) )
                                        ElseIf "_NOME" $ aHeader[nX]  
                                            aAdd( aAux, "TRABALHADOR PRELIMINAR")
                                        Else
                                            aAdd( aAux, "")
                                        EndIf

                                    ElseIf (cTabela)->&(cTabela + "_NOMEVE") == 'S2300'

                                        If "_MATRIC" $ aHeader[nX]
                                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + (cTabela)->&(cTabela + cFunc) + "1", "C9V_MATTSV")) )
                                        ElseIf "_NOME" $ aHeader[nX] 
                                            aAdd( aAux, GetNomeTra(xFilial("C9V"), C9V->C9V_CPF, (cTabela)->&(cTabela + cFunc) ) )
                                        Else
                                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + (cTabela)->&(cTabela + cFunc) + "1", aHeader[nX])) )
                                        EndIf

                                    Else

                                        If "_NOME" $ aHeader[nX] .and. (cTabela)->&(cTabela + "_NOMEVE") <> 'S2190' 
                                            aAdd( aAux, GetNomeTra(xFilial("C9V"), C9V->C9V_CPF, (cTabela)->&(cTabela + cFunc) ) )
                                        Else
                                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + (cTabela)->&(cTabela + cFunc) + "1", aHeader[nX])) )
                                        EndIf 
                                    
                                    EndIf     
                         
                                Else

                                    aAdd( aAux, "") 

                                EndIf  

                            Case "S-2230" == cEvent

                                If lSeek                     

                                    If "_MATRIC" $ aHeader[nX]

                                        If Posicione("C9V", 2, xFilial("C9V") + CM6->CM6_FUNC + "1", "C9V_NOMEVE") == "S2300"
                                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + CM6->CM6_FUNC + "1", "C9V_MATTSV")) )
                                        Else
                                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + CM6->CM6_FUNC + "1", "C9V_MATRIC")) )
                                        EndIf

                                    Else

                                        aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + CM6->CM6_FUNC + "1", aHeader[nX])) )
                                    
                                    EndIf

                                Else

                                    aAdd( aAux, "")

                                EndIf

                            Case cEvent $ "S-2260|S-2250"    

                                If lSeek

                                    If "_CPF" $ aHeader[nX]
                                        aAdd(aAux, EncodeUTF8(Posicione("C9V", 2, aChave[1] + (cTabela)->&(cTabela + "_TRABAL") + "1", "C9V_CPF")))
                                    ElseIf "_MATRIC" $ aHeader[nX]
                                        aAdd(aAux, EncodeUTF8(Posicione("C9V", 2, aChave[1] + (cTabela)->&(cTabela + "_TRABAL")+ "1", "C9V_MATRIC")))
                                    Else
                                        aAdd(aAux, "")
                                    EndIf

                                Else

                                    aAdd(aAux, "")
                                    
                                EndIf

                            Case cEvent $ "S-2221|S-2231|S-2245|S-2298|S-2299|"   

                                If lSeek

                                    aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, aChave[1] + (cTabela)->&(cTabela + "_FUNC") + "1", aHeader[nX])) )

                                Else

                                    aAdd(aAux, "") 

                                EndIf                           

                            Case "S-2306" == cEvent

                                If T0F->(MsSeek(cChave + IIf((cAliasTAF)->T0F_EVENTO != "E", "1", "2")))

                                    If !Empty(xFilial("C9V")) .And. xFilial("C9V") != T0F->T0F_FILIAL
                                        cFilAnt := T0F->T0F_FILIAL
                                    EndIf                            

                                    aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + T0F->T0F_ID + "1", aHeader[nX])) )

                                Else

                                    aAdd( aAux, "")

                                EndIf    

                            Case "S-2399" == cEvent

                                If lSeek                         

                                    aAdd( aAux, EncodeUTF8(Posicione("C9V", 2, xFilial("C9V") + T92->T92_TRABAL + "1", aHeader[nX])) )

                                Else

                                    aAdd( aAux, "")

                                EndIf
                            
                            Case cEvent $ "S-3500"

                                If lSeek

                                    If "_NOME" $ aHeader[nX]
                                        AAdd(aAux, GetNomeTra(V7J->V7J_FILIAL, V7J->V7J_CPF))
                                    EndIf

                                Else

                                    AAdd(aAux, "")

                                EndIf
        
                        EndCase

                    ElseIf AT("M0_CGC", aHeader[nX]) > 0

                        cC1EFilTaf := Posicione( "C1E", 2, cChave , "C1E_FILTAF" )
                        aAdd( aAux, EncodeUTF8(Posicione( "SM0", 1, cEmpAnt + cC1EFilTaf, "M0_CGC" )))

                    ElseIf AT("M0_TPINSC", aHeader[nX]) > 0

                        cC1EFilTaf := Posicione( "C1E", 2, cChave , "C1E_FILTAF" )
                        xTpInsc    := Posicione( "SM0", 1, cEmpAnt + cC1EFilTaf, "M0_TPINSC" )

                        If xTpInsc == 1
                            aAdd( aAux, "CEI")
                        ElseIf xTpInsc == 2
                            aAdd( aAux, "CNPJ")
                        ElseIf xTpInsc == 3
                            aAdd( aAux, "CPF")
                        Else
                            aAdd( aAux, "")
                        EndIf

                    ElseIf AT("_TPINSC", aHeader[nX]) > 0 .And. !(AT("M0_TPINSC", aHeader[nX]) > 0) .And. !(AT("T0Q_TPINSC", aHeader[nX]) > 0)

                        xTpInsc    := (cAliasTAF)->&( aHeader[nX] )

                        If xTpInsc == "1"
                            aAdd( aAux, "CNPJ")
                        ElseIf xTpInsc == "2"
                            aAdd( aAux, "CPF")
                        ElseIf xTpInsc == "3"
                            aAdd( aAux, "CAEPF")
                        ElseIf xTpInsc == "4"
                            aAdd( aAux, "CNO")
                        Else
                            aAdd( aAux, "")
                        EndIf

                    ElseIf At("_STATUS", aHeader[nX]) > 0 

                        If (cAliasTAF)->&( aHeader[nX] ) $ " |0|1"
                            aAdd( aAux, "1")
                        ElseIf (cAliasTAF)->&( aHeader[nX] ) == "2"
                            aAdd( aAux, "2")
                        ElseIf (cAliasTAF)->&( aHeader[nX] ) == "3"
                            aAdd( aAux, "3")
                        ElseIf (cAliasTAF)->&( aHeader[nX] ) == "4"

                            If (cAliasTAF)->ALERT_COUNT > 0
                                aAdd( aAux, "A")
                            Else
                                aAdd( aAux, "4")    
                            EndIf
                        ElseIf (cAliasTAF)->&( aHeader[nX] ) $ "6|7"
                            aAdd( aAux, "5")
                        EndIf              

                    ElseIf "_TPEVEN" $ aHeader[nX]

                        If !Empty((cAliasTAF)->&(aHeader[nX]))

                            C8E->(DbSetOrder(1))
                            If C8E->(MsSeek(xFilial("C8E") + (cAliasTAF)->&(aHeader[nX])))
                                AAdd(aAux, C8E->C8E_CODIGO)
                            EndIf

                        Else

                            aAdd( aAux, 'N/A' )

                        EndIf

                    ElseIf EncodeUTF8(STR0009) $ aHeader[nX] // "Descrição"

                        If cEvent $ "S-3000"
                            cCampo := "CMJ_TPEVEN"
                        ElseIf cEvent $ "S-3500"
                            cCampo := "V7J_TPEVEN"
                        EndIf

                        If !Empty((cAliasTAF)->&(cCampo))

                            C8E->(DbSetOrder(1))
                            If C8E->(MsSeek(xFilial("C8E") + (cAliasTAF)->&(cCampo)))

                                aDescriEvt := StrToKArr(EncodeUTF8(C8E->C8E_DESCRI), "-")
                                
                                AAdd(aAux, aDescriEvt[2])

                            EndIf

                        Else

                            aAdd( aAux, 'N/A' )

                        EndIf

                    ElseIf At("_TPEXAM", aHeader[nX]) > 0

                        aTpExam  := StrTokArr2(CbTpExam(), ";")
                        nPos     := AScan(aTpExam, {|x| StrTran(AllTrim(Substr(x, 1, 2)), "=") $ (cAliasTAF)->&(aHeader[nX])})     

                        If nPos > 0
                            aAdd(aAux, EncodeUTF8(Upper(Substr(aTpExam[nPos], At("=", aTpExam[nPos]) + 1, Len(aTpExam[nPos])))))
                        EndIf

                    ElseIf At("_RESULT", aHeader[nX]) > 0

                        If (cAliasTAF)->&( aHeader[nX] ) == "1"
                            aAdd( aAux, "Apto")
                        ElseIf (cAliasTAF)->&( aHeader[nX] ) == "2"
                            aAdd( aAux, "Inapto")
                        Else    
                            aAdd( aAux, 'N/A' )
                        EndIf
                    
                    ElseIf At("CM7_CODIGO", aHeader[nX]) > 0 .OR. At("CM7_NOME", aHeader[nX]) > 0

                        aAdd( aAux, EncodeUTF8(Posicione( "CM7", 1, xFilial("CM7") + (cTabela)->&(cTabela + "_CODMED"), aHeader[nX] )) )  
                                        
                    ElseIf At("_LAMB", aHeader[nX]) > 0

                        If T0Q->(DbSeek(xFilial("T0Q") + (cTabela)->&(cTabela + "_ID" ) + (cTabela)->&(cTabela + "_VERSAO" )))
                            If T0Q->&( aHeader[nX] ) == "1"
                                aAdd( aAux, EncodeUTF8(Upper("Estabelecimento do próprio empregador")))
                            ElseIf T0Q->&( aHeader[nX] ) == "2"
                                aAdd( aAux, Upper("Estabelecimento de terceiro"))
                            EndIf 
                        Else    
                            aAdd( aAux, "N/A" )
                        EndIf

                    ElseIf At("T0Q_DSETOR", aHeader[nX]) > 0  .OR. At("T0Q_NRINSC", aHeader[nX]) > 0       

                        aAdd(aAux, EncodeUTF8(Posicione( "T0Q", 1, xFilial("T0Q") + (cTabela)->&(cTabela + "_ID" ) + (cTabela)->&(cTabela + "_VERSAO" ), aHeader[nX]))) 

                    ElseIf AT("T0Q_TPINSC", aHeader[nX]) > 0

                        cTpInsc := Posicione( "T0Q", 1, xFilial("T0Q") + (cTabela)->&(cTabela + "_ID" ) + (cTabela)->&(cTabela + "_VERSAO" ), aHeader[nX])

                        If cTpInsc == "1"
                            aAdd( aAux, "CNPJ")
                        ElseIf cTpInsc == "3"
                            aAdd( aAux, "CAEPF")
                        ElseIf cTpInsc == "4"
                            aAdd( aAux, "CNO")
                        Else    
                            aAdd( aAux, 'N/A' )
                        EndIf        

                    ElseIf At("T1M_IDESTA", aHeader[nX]) > 0 
                    
                        aAdd( aAux, Posicione( "C92", 5, xFilial("C92",(cAliasTAF)->T1M_FILIAL) + (cAliasTAF)->T1M_IDESTA , 'C92_NRINSC' ) )  
                    
                    ElseIf "_INDAPU" $ aHeader[nX]

                        aIndApu  := StrTokArr2(AllTrim(GetSx3Cache(aHeader[nX], "X3_CBOX")), ";")
                        nPos     := AScan(aIndApu, {|x| AllTrim(SubStr(x, 1, At("=", x) - 1)) == AllTrim((cAliasTAF)->&(aHeader[nX]))})     

                        If nPos > 0
                            aAdd(aAux, EncodeUTF8(Upper(Substr(aIndApu[nPos], At("=", aIndApu[nPos]) + 1, Len(aIndApu[nPos])))))
                        Else
                            aAdd(aAux, "")
                        EndIf

                    ElseIf "_PERAPU" $ aHeader[nX]

                        cPerApu := IIf(Len((cAliasTAF)->&(aHeader[nX])) == 4, (cAliasTAF)->&(aHeader[nX]), Left((cAliasTAF)->&(aHeader[nX]), 4) + "-" + Right((cAliasTAF)->&(aHeader[nX]), 2))

                        AAdd(aAux, IIf(Empty((cAliasTAF)->&(aHeader[nX])), "", cPerApu))

                    ElseIf "_TIPACI" $ aHeader[nX]
                        
                        aTipAcid := StrTokArr2(AllTrim(GetSx3Cache(aHeader[nX], "X3_CBOX")), ";")
                        nPos     := AScan(aTipAcid, {|x| AllTrim(SubStr(x, 1, At("=", x) - 1)) == AllTrim((cAliasTAF)->&(aHeader[nX]))})     

                        If nPos > 0
                            aAdd(aAux, EncodeUTF8(Upper(Substr(aTipAcid[nPos], At("=", aTipAcid[nPos]) + 1, Len(aTipAcid[nPos])))))
                        Else
                            aAdd(aAux, "")
                        EndIf                          

                    ElseIf "_HRACID" $ aHeader[nX] 
                        
                        cHrAcid := AllTrim( Transform( ( cAliasTAF )->&( aHeader[nX] ), "@R 99:99") )

                        aAdd( aAux, Iif(cHrAcid == ":", "", cHrAcid))  

                    ElseIf "_CODCAT" $ aHeader[nX]

                        cFil := (cTabela)->&(cTabela + "_FILIAL")

                        If cEvent $ "S-2210|S-2220|S-2240" 

                            cFunc := Iif(cEvent $ "S-2210","_TRABAL","_FUNC")
                            
                            If (cTabela)->&(cTabela + "_NOMEVE") == 'S2190' 
                                cIDCateg := Posicione("T3A", 3, xFilial("T3A", cFil ) + (cTabela)->&(cTabela + cFunc) + "1", "T3A_CODCAT")
                            ElseIf (cTabela)->&(cTabela + "_NOMEVE") == 'S2300'
                                cIDCateg := TafLolCateg((cTabela)->&(cTabela + cFunc), "T0F", cFil)
                            Else
                                cIDCateg    := TafLolCateg((cTabela)->&(cTabela + cFunc), "T1V", cFil)
                            EndIf    

                            If !Empty(cIDCateg)
                                aAdd( aAux, EncodeUTF8(Posicione("C87", 1, xFilial("C87") + cIDCateg, "C87_CODIGO + ' - ' + C87_DESCRI")) )
                            Else
                                aAdd( aAux, "")
                            EndIf

                        ElseIf cEvent $ "S-2245|S-2221" 

                            If lSeek

                                cFunc := "_FUNC"

                                If Posicione("C9V", 2, xFilial("C9V", cFil ) + (cTabela)->&(cTabela + cFunc) + "1", "C9V_NOMEVE") == "S2200"
                                    cIDCateg    := TafLolCateg((cTabela)->&(cTabela + cFunc), "T1V", cFil)
                                Else
                                    cIDCateg    := TafLolCateg((cTabela)->&(cTabela + cFunc), "T0F", cFil)
                                EndIf

                                If !Empty(cIDCateg)
                                    aAdd(aAux, EncodeUTF8(Posicione("C87", 1, xFilial("C87") + cIDCateg, "C87_CODIGO + ' - ' + C87_DESCRI")))
                                Else
                                    aAdd(aAux, "")
                                EndIf

                            Else

                                aAdd( aAux, "") 

                            EndIf

                        Else

                            aAdd( aAux, "") 

                        EndIf 

                    ElseIf ("_MATRIC" $ aHeader[nX] .Or. "_MATTSV" $ aHeader[nX]) .And. cEvent $ "S-2200|S-2300"

                        If cEvent $ "S-2300"
                            
                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 1, cChave, "C9V_MATTSV")) )

                        ElseIf cEvent $ "S-2200"

                            aAdd( aAux, EncodeUTF8(Posicione("C9V", 1, cChave, "C9V_MATRIC")) )

                        EndIf

                    ElseIf "_CONVOC" $ aHeader[nX]

                        aAdd(aAux, EncodeUTF8(AllTrim(Posicione(cTabela, 1, cChave, aHeader[nX]))))      

                    ElseIf "_CODTCA" $ aHeader[nX]

                        cCodTCa := AllTrim(Posicione(cTabela, 1, cChave, aHeader[nX]))

                        aAdd(aAux, EncodeUTF8(Posicione("V2M", 1, xFilial("V2M") + cCodTCa, "V2M_CODIGO + ' - ' + V2M_DESCRI")))      

                    ElseIf "_OBSTCA" $ aHeader[nX]

                        aAdd(aAux, EncodeUTF8(AllTrim(Posicione(cTabela, 1, cChave, aHeader[nX]))))      

                    ElseIf "_TPAVIS" $ aHeader[nX]

                        aTpAvis  := StrTokArr2(AllTrim(GetSx3Cache(aHeader[nX], "X3_CBOX")), ";")
                        nPos     := AScan(aTpAvis, {|x| AllTrim(SubStr(x, 1, At("=", x) - 1)) == AllTrim((cAliasTAF)->&(aHeader[nX]))})     

                        If nPos > 0
                            aAdd(aAux, EncodeUTF8(Upper(Substr(aTpAvis[nPos], At("=", aTpAvis[nPos]) + 1, Len(aTpAvis[nPos])))))
                        Else
                            aAdd(aAux, "")
                        EndIf

                    ElseIf "_MOTVAF" $ aHeader[nX]

                        cMotAfas := AllTrim((cAliasTAF)->&(aHeader[nX])) 
                        
                        If !Empty(cMotAfas)     

                            aAdd(aAux, EncodeUTF8(Posicione("C8N", 1, xFilial("C8N") + cMotAfas, "C8N_CODIGO + ' - ' + C8N_DESCRI")))

                        Else
 
                            aAdd(aAux, "")

                        EndIf    
                    
                    ElseIf "_MTVTER" $ aHeader[nX]

                        aAdd(aAux, EncodeUTF8(Posicione("T5H", 1, xFilial("T5H") + AllTrim((cAliasTAF)->&(aHeader[nX])), "Alltrim(T5H_CODIGO) + ' - ' + Alltrim(T5H_DESCRI)")))    

                    ElseIf "_TPBENE" $ aHeader[nX]

                        aAdd(aAux, EncodeUTF8(Posicione("V5Z", 1, xFilial("V5Z") + AllTrim((cAliasTAF)->&(aHeader[nX])), "Alltrim(V5Z_CODIGO) + ' - ' + Alltrim(V5Z_DESCRI)")))    

                    // Campos COMBOBOX (retorno Minúsculo e com acento)
                    ElseIf "_INCFIS" $ aHeader[nX]  .Or. "V72_RESPRE" $ aHeader[nX] .Or. "V75_CADINI" $ aHeader[nX] .Or. ;
                        "_TPPENS" $ aHeader[nX] .Or. "_MTSUSP" $ aHeader[nX] .Or. "_INDSUS" $ aHeader[nX]

                        aAdd(aAux, getCBoxOpt(aHeader[nX], AllTrim((cAliasTAF)->&(aHeader[nX])), .F.))

                    ElseIf "_SITBEN" $ aHeader[nX] // Campos COMBOBOX (retorno Minúsculo e com acento)

                        aAdd(aAux, getCBoxOpt(aHeader[nX], AllTrim((cAliasTAF)->&(aHeader[nX])), .F.))

                    ElseIf AT("V73_", aHeader[nX]) > 0 .And. (cEvent $ "S-1207")

                        T62->(DbSetOrder(1))

                        If T62->(MsSeek(StrTran((cAliasTAF)->KEYTAF, "|", "") + IIf((cAliasTAF)->T62_EVENTO != "E", "1", "2")))

                            If !Empty(xFilial("T62")) .And. xFilial("T62") != (ctabela)->&(ctabela + "_FILIAL")
                                cFilAnt := (ctabela)->&(ctabela + "_FILIAL")
                            EndIf

                            aAdd( aAux, EncodeUTF8(Posicione("V73", 4, xFilial("V73") + T62->T62_IDBEN + "1", aHeader[nX])) )
                        EndIf
                        
                    ElseIf "_NRPROC" $ aHeader[nX]

                        AAdd(aAux, AllTrim((cAliasTAF)->&(aHeader[nX])))

                    ElseIf "_ORIGEM" $ aHeader[nX]

                        AAdd(aAux, getCBoxOpt(aHeader[nX], AllTrim((cAliasTAF)->&(aHeader[nX]))))

                    ElseIf "_CPF" $ aHeader[nX]

                        AAdd(aAux, AllTrim((cAliasTAF)->&(aHeader[nX])))

                    ElseIf "_NMTRAB" $ aHeader[nX]

                        AAdd(aAux, EncodeUTF8(AllTrim((cAliasTAF)->&(aHeader[nX]))))
                        
                    Else

                        aAdd(aAux, EncodeUTF8((cAliasTAF)->&(aHeader[nX]))) 

                    EndIf

                EndIf
      
                cFilAnt := cXFilBkp
            Next nX

            AADD( aData, aAux )
            aAux := {}
            (cAliasTAF)->( DBSkip() )
            
        EndDo

    EndIf

    (cAliasTAF)->( DbCloseArea() )
    RestArea(aGetArea)

Return aData

//--------------------------------------------------------------------
/*/{Protheus.doc} function fGetFil
Função que retorna as filiais de acordo com o compartilhamento da tabela que originou o evento gravado na RJE
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function fGetFil(cEvent, aBranch, cAlias)

    Local aRet     := {}
    Local cRet     := ""
    Local nX       := 1
    Local aTafInfo := TAFRotinas( cEvent, 4, .F., 2 )
    Local cTabela  := aTafInfo[3]

    Default cAlias := ""

    If !Empty(cAlias) .And. cAlias == "C1E"

        cRet := TAFCacheFil("C1E", aBranch, .T.)

    Else

        For nX := 1 To Len(aBranch)

            aAdd(aRet, xFilial(cTabela, aBranch[nX]))

        Next nX

        cRet := TAFCacheFil(cTabela, aRet, .T.)

    EndIf

Return cRet

/*/{Protheus.doc} function fCompress
Função que compacta e converte objeto JSON para String
@author  Hugo de Oliveira
@since   05/12/2019
@version 1.0
/*/
Static Function fCompress(oObj)

    Local cJson    := ""
    Local cComp    := ""
    Local lCompact := .F.

    // Set gzip format to Json Object
    cJson := oObj:toJSON()

    If Type("::GetHeader('Accept-Encoding')") != "U"  .and. 'GZIP' $ Upper(::GetHeader('Accept-Encoding') )
        lCompact := .T.
    EndIf

    If(lCompact)
        ::SetHeader('Content-Encoding','gzip')
        GzStrComp(cJson, @cComp, @nLenComp )
    Else
        cComp := cJson
    EndIf

Return cComp

/*/{Protheus.doc} function fSortCol
Realiza a ordenação das colunas a serem exibidas
@author  Hugo de Oliveira
@since   10/01/2020
@version 1.0
/*/
Static Function fSortCol(aData as array)

    Local aInd		as array
    Local aBox		as array
    Local cEvtTaf 	as character
    Local nX 		as numeric
    Local nInd		as numeric
 
    Default aData := {}

    aInd	:= {}
    aBox	:= {}
    cEvtTaf := ""
    nX 		:= 0
    nInd	:= 0

    For nX := 1 To Len(aData)
        cEvtTaf := aData[nX]
        
        If "_STATUS" $ cEvtTaf 
            nInd := 1
        ElseIf "_CPF" $ cEvtTaf
            nInd := 2
        ElseIf "_FILIAL" $ cEvtTaf
            nInd := 3
        ElseIf "_MATRIC" $ cEvtTaf .Or. "_MATTSV" $ cEvtTaf
            nInd := 4
        ElseIf "_CODCAT" $ cEvtTaf
            nInd := 5
        ElseIf "_FILIAL" $ cEvtTaf .And. "_ID" $ cEvtTaf .And. "_VERSAO" $ cEvtTaf
            nInd := 6
        ElseIf ("_NOME" $ cEvtTaf .Or. "_NMTRAB" $ cEvtTaf) .And. !cEvtTaf $ "C1E_NOME|CM7_NOME" 
            nInd := 7
        ElseIf "V73_DTINIC" $ cEvtTaf
            nInd := 8
        ElseIf "_DTNASC" $ cEvtTaf
            nInd := 9
        ElseIf "_TPINSC" $ cEvtTaf
            nInd := 10
        ElseIf "_INSCR" $ cEvtTaf
            nInd := 11
        ElseIf "C1E_NOME" $ cEvtTaf
            nInd := 12
        ElseIf "_CODRUB" $ cEvtTaf
            nInd := 13
        ElseIf "_IDTBRU" $ cEvtTaf
            nInd := 14
        ElseIf "_DESRUB" $ cEvtTaf
            nInd := 15
        ElseIf "C99_CODIGO" $ cEvtTaf
            nInd := 16
        ElseIf "C99_TPLOT" $ cEvtTaf
            nInd := 17
        ElseIf "C8V_CODIGO" $ cEvtTaf
            nInd := 18
        ElseIf "C8V_DESCRI" $ cEvtTaf
            nInd := 19
        ElseIf "T5K_CODIGO" $ cEvtTaf
            nInd := 20
        ElseIf "T5K_DESCRI" $ cEvtTaf
            nInd := 21
        ElseIf "C8X_CODIGO" $ cEvtTaf
            nInd := 22
        ElseIf "C8X_DESCRI" $ cEvtTaf
            nInd := 23
        ElseIf "C90_CODIGO" $ cEvtTaf
            nInd := 24
        ElseIf "C90_DESCRI" $ cEvtTaf
            nInd := 25
        ElseIf "T04_CODIGO" $ cEvtTaf
            nInd := 26
        ElseIf "T04_DESCRI" $ cEvtTaf
            nInd := 27
        ElseIf "_TPPROC" $ cEvtTaf
            nInd := 28
        ElseIf "_NUMPRO" $ cEvtTaf
            nInd := 29
        ElseIf "_DTALT" $ cEvtTaf
            nInd := 30    
        ElseIf "_MOTVAF" $ cEvtTaf
            nInd := 31
        ElseIf "_DTAVIS" $ cEvtTaf
            nInd := 32
        ElseIf "_DTAFAS" $ cEvtTaf
            nInd := 33
        ElseIf "_DTFAFA" $ cEvtTaf
            nInd := 34
        ElseIf "_INDAPU" $ cEvtTaf
            nInd := 35
        ElseIf "_PERAPU" $ cEvtTaf
            nInd := 36
        ElseIf "_DTDESL" $ cEvtTaf
            nInd := 37
        ElseIf "_DTEFEI" $ cEvtTaf
            nInd := 38
        ElseIf "_DTRET" $ cEvtTaf
            nInd := 39
        ElseIf "_DTACID" $ cEvtTaf 
            nInd := 40
        ElseIf "_HRACID" $ cEvtTaf
            nInd := 41
        ElseIf "_TIPACI" $ cEvtTaf
            nInd := 42
        ElseIf "_TPEXAM" $ cEvtTaf
            nInd := 43
        ElseIf "_DTASO" $ cEvtTaf
            nInd := 44
        ElseIf "_RESULT" $ cEvtTaf
            nInd := 45  
        ElseIf "_NRCRM" $ cEvtTaf
            nInd := 46
        ElseIf "_NOMRES" $ cEvtTaf
            nInd := 47
        ElseIf "_CONVOC" $ cEvtTaf
            nInd := 48
        ElseIf "_DTINIP" $ cEvtTaf
            nInd := 49
        ElseIf "_DTFIMP" $ cEvtTaf
            nInd := 50
        ElseIf "_DTPREV" $ cEvtTaf
            nInd := 51
        ElseIf "_DTINIC" $ cEvtTaf
            nInd := 52
        ElseIf "_DTINI" $ cEvtTaf
            nInd := 53
        ElseIf "_LAMB" $ cEvtTaf
            nInd := 54
        ElseIf "_DTEXAM" $ cEvtTaf
            nInd := 55
        ElseIf "_OBSTCA" $ cEvtTaf
            nInd := 56
        ElseIf "T0Q_DSETOR" $ cEvtTaf
            nInd := 57
        ElseIf "T0Q_TPINSC" $ cEvtTaf
            nInd := 58
        ElseIf "T0Q_NRINSC" $ cEvtTaf
            nInd := 59 
        ElseIf "T1M_IDESTA" $ cEvtTaf
            nInd := 60
        ElseIf "CM7_CODIGO" $ cEvtTaf
            nInd := 61
        ElseIf "CM7_NOME" $ cEvtTaf
            nInd := 62
        ElseIf "_CPFRES" $ cEvtTaf
            nInd := 63
        ElseIf "_TPAVIS" $ cEvtTaf
            nInd := 64
        ElseIf "_CNPJCE" $ cEvtTaf
            nInd := 65    
        ElseIf "_SITBEN" $ cEvtTaf
            nInd := 66
        ElseIf "_NRBENF" $ cEvtTaf
            nInd := 67
        ElseIf "_DTINBE" $ cEvtTaf
            nInd := 68
        ElseIf "_CADINI" $ cEvtTaf
            nInd := 69
        ElseIf "_CNPJDS" $ cEvtTaf
            nInd := 70
        ElseIf "_DTPUBL" $ cEvtTaf
            nInd := 71
        ElseIf "_DALTBE" $ cEvtTaf
            nInd := 72
        ElseIf "_TPBENE" $ cEvtTaf
            nInd := 73
        ElseIf "_INDSUS" $ cEvtTaf
            nInd := 74
        ElseIf "_TPPENS" $ cEvtTaf
            nInd := 75
        ElseIf "_DTTERM" $ cEvtTaf
            nInd := 76
        ElseIf "_MTSUSP" $ cEvtTaf
            nInd := 77
        ElseIf "_DSCSUS" $ cEvtTaf
            nInd := 78
        ElseIf "_MTVTER" $ cEvtTaf
            nInd := 79
        ElseIf "V73_INCFIS" $ cEvtTaf
            nInd := 80
        ElseIf "V73_DTINCF" $ cEvtTaf
            nInd := 81
        ElseIf "_DTREAT" $ cEvtTaf
            nInd := 82
        ElseIf "_DTEF" $ cEvtTaf
            nInd := 83
        ElseIf "_CNPJO" $ cEvtTaf
            nInd := 84
        ElseIf "_NEWCPF" $ cEvtTaf
            nInd := 85
        ElseIf "_NRPROC" $ cEvtTaf
            nInd := 86  
        ElseIf "_PROCTR" $ cEvtTaf
            nInd := 87  
        ElseIf "_ORIGEM" $ cEvtTaf
            nInd := 88          
        ElseIf "_PROTUL" $ cEvtTaf .Or. "_NRRECI" $ cEvtTaf
            nInd := 89
        ElseIf "_TPEVEN" $ cEvtTaf
            nInd := 90
        ElseIf EncodeUTF8(STR0009) $ cEvtTaf // "Descrição"
            nInd := 91
        ElseIf "_EVENTO" $ cEvtTaf
            nInd := 92
        ElseIf cEvtTaf == "alert"
            nInd := 93
        ElseIf cEvtTaf == "error" //Manter sempre por último
            nInd := 94
        EndIf

        aadd( aInd, nInd )
    Next nX

    For nX := 1 To Len( aData )
        aadd( aBox, {} )
        aadd( aBox[nX], aData[nX] )
        aadd( aBox[nX], aInd[nX] )
    Next nX

    ASORT(aBox, , , { | x,y | x[2] < y[2] } )

    aData := {}
    For nX := 1 To Len( aBox )
        aadd( aData, aBox[nX][1] )
    Next nX

Return aData

/*/{Protheus.doc} function RetCmp
Retorna o nome do campo de CPF ou nome correspondente de cada evento
@author  Matheus Prada
@since   05/11/2020
@version 1.0
/*/
Static Function RetCmp(cEvent as character)

    Local cCampo    as character

    Default cEvent  := ""
 
    cCampo := ""

    If !Empty(cEvent)
        If cEvent $ "S-2220|S-2221|S-2230|S-2240|S-2245|S-2298|S-2299|S-2231"
            cCampo := "_FUNC"
        ElseIf  cEvent $ "S-1202|S-2210|S-2250|S-2260|S-2399"
            cCampo := "_TRABAL"
        ElseIf cEvent $ "S-2241"
            cCampo := "_IDTRAB"
        EndIf
    EndIf

return cCampo

/*/{Protheus.doc} getCBoxOpt
    Obtém a descrição da opção gravada no Campo Combo passado por parâmetro

    @author Fabio Mendonça
    @since 27/09/2021
    @version 1.0

    @param cCBoxField, string, Campo ComboBox desejado
    @param cSearchedOpt, string, Opção (flag) escolhida no Campo Combo
    @param lUpper, boolean, Se retorno será maiúsculo
    @param lAccent, boolean, Se retorno conterá acentos
    
    @return cRet, string, Descrição da opção gravada no Campo Combo
/*/
Static Function getCBoxOpt(cCBoxField, cSearchedOpt, lUpper, lAccent)

    Local aCBoxOpt  :=  {}
    Local nPos      :=  0
    Local cRet      :=  ""
    
    Default lUpper          :=  .T.
    Default lAccent         :=  .F.
    Default cCBoxField      :=  ""
    Default cSearchedOpt    :=  ""

    aCBoxOpt    := StrTokArr2(AllTrim(GetSx3Cache(cCBoxField, "X3_CBOX")), ";")
    nPos        := AScan(aCBoxOpt, {|x| AllTrim(SubStr(x, 1, At("=", x) - 1)) == cSearchedOpt})     

    If nPos > 0
        cRet    :=  Substr(aCBoxOpt[nPos], At("=", aCBoxOpt[nPos]) + 1, Len(aCBoxOpt[nPos]))

        If lUpper
            cRet    :=  upper(cRet)
        EndIf

         If lAccent
            cRet    :=  FwNoAccent(cRet)
        EndIf

    EndIf
    
Return EncodeUTF8(cRet)


/*/{Protheus.doc} HiddenField
    Verifica se campo passado por parâmetro deve ser enviado pela API como não-visível

    @author Fabio Mendonça
    @since 28/09/2021
    @version 1.0

    @param cFieldName, string, Campo a verificar se deve ser enviado como não-visível

    @return lRet, boolean, Se true, campo será enviado pela API como não-visível
/*/
Static Function HiddenField(cFieldName as character, cEvento as character)

    Local cHiddenFld    as character
    Local lRet          as logical

    Default cFieldName  :=  ""
    Default cEvento     :=  ""

    cHiddenFld      := ""
    lRet            := .F.
    
    Do Case
        Case cEvento == "S-2231"
            cHiddenFld := "V72_RESPRE"
        
        Case cEvento == "S-2410"
            cHiddenFld := "V75_CADINI|V75_CNPJDS|V75_DTPUBL|V75_TPBENE|V75_TPPENS|V75_DTTERM|V75_MTVTER|"

        Case cEvento == "S-2416"
            cHiddenFld := "V76_TPPENS|V76_MTSUSP|V76_DSCSUS|"

        Case cEvento == "S-2420"
            cHiddenFld := "V78_CNPJO|V78_NEWCPF|"

        Case cEvento == "S-2500"
            cHiddenFld := "V9U_DTNASC|"
    
    EndCase

    If cFieldName $ cHiddenFld
        lRet := .T.
    EndIf   

Return lRet

/*/{Protheus.doc} GetMVName
Retorna o nome do trabalhador múltiplo vínculo dando preferência para a filial 
em que a folha gerada, e caso não encontre, trás o nome de qualquer outra filial 
em que possuir cadastro

@author Melkz Siqueira
@since 17/08/2022
@version 1.0
@param cFilC91  - Filial em que a folha foi gerada
@param cCPF     - CPF do trabalhador múltiplo vínculo
@return cNome   - Nome do trabalhador múltiplo vínculo 
/*/
Static Function GetMVName(cFilC91 as character, cCPF as character)

    Local cC91Filial    as character
    Local cFilQuery     as character
    Local cNome         as character
    Local cQryAlias     as character
    Local lT1U          as logical

    Default cFilC91 := ""
    Default cCPF    := ""

    cC91Filial  := ""
    cFilQuery   := "" 
    cNome       := ""
    cQryAlias   := ""
    lT1U        := .T.

    If !Empty(cCPF)
        cQryAlias := GetNextAlias()

        BeginSQL Alias cQryAlias

            SELECT T1U.T1U_FILIAL FILIAL, T1U.T1U_NOME NOME
                FROM %Table:T1U% T1U
                WHERE T1U.%NotDel%
                    AND T1U.T1U_ATIVO = '1'
                    AND T1U.T1U_CPF = %Exp:cCPF%
                GROUP BY T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT
                ORDER BY T1U.T1U_FILIAL, T1U.T1U_DTALT DESC

        EndSQL

        If (cQryAlias)->(EOF())
            (cQryAlias)->(DBCloseArea())
            
            lT1U := .F.

            BeginSQL Alias cQryAlias

                SELECT C9V.C9V_FILIAL FILIAL, C9V.C9V_NOME NOME
                    FROM %Table:C9V% C9V
                    WHERE C9V.%NotDel% 
                        AND C9V.C9V_ATIVO = '1'
                        AND C9V.C9V_CPF = %Exp:cCPF%
                    GROUP BY C9V.C9V_FILIAL, C9V.C9V_NOME, C9V.C9V_VERSAO
                    ORDER BY C9V.C9V_FILIAL, C9V.C9V_VERSAO DESC

            EndSQL
        EndIf

        (cQryAlias)->(DBGoTop())

        While !(cQryAlias)->(EOF())
            cC91Filial  := xFilial("C91", (cQryAlias)->FILIAL)
            cFilQuery   := IIf(lT1U, xFilial("T1U", cFilC91), xFilial("C9V", cFilC91))

            If cC91Filial == cFilQuery
                cNome := (cQryAlias)->NOME

                Exit
            Else
                cNome := (cQryAlias)->NOME
            EndIf

            (cQryAlias)->(DBSkip())
        EndDo

        (cQryAlias)->(DBCloseArea())
    EndIf

Return cNome

/*/{Protheus.doc} GetLibDb
Carrega a versão da Lib e Banco de Dados para executar as queries com FwExecStatement()

@author Melkz Siqueira
@since 24/10/2022
@version 1.0
/*/
Static Function GetLibDb()

    Local cLegacyLib as character

    cLegacyLib := "20020101"

    If __cLibVer == Nil
        If FindFunction("TAFisBDLegacy")
            If TAFisBDLegacy()
                __cLibVer := cLegacyLib
            Else
                __cLibVer := FwLibVersion()
            EndIf
        Else
            __cLibVer := cLegacyLib
        EndIf 
    EndIf

    If __cBanco == Nil
        __cBanco := TCGetDB()
    EndIf

Return

/*/{Protheus.doc} GetNomeTra
Retorna o nome do trabalhador dos eventos S-2205, S-2200, S-2300, S-2190, S-2405 e S-2400

@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@param  cFil    - Filial a ser procurado o trabalhador
@param  cCPF    - CPF do trabalhador
@return cNome   - Nome do trabalhador
/*/
Static Function GetNomeTra(cFil as character, cCPF as character, cIdTrabal as character)

    Local cNome     as character

    Default cFil        := ""
    Default cCPF        := ""
    Default cIdTrabal   := ""

    cNome       := ""
    
    If !Empty(cCPF) .OR. !Empty(cIdTrabal)
        cNome := GetNomeT1U(cFil, cCPF, cIdTrabal)

        If Empty(cNome)

            IIf(!Empty(cCPF), C9V->(DbSetOrder(3)), C9V->(DbSetOrder(2)))

            If !Empty(cCPF)
                If C9V->(MsSeek(xFilial("C9V", cFil) + cCPF + "1"))
                    cNome := AllTrim(C9V->C9V_NOME)
                EndIf
            Else
                If C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrabal + "1"))
                    cNome := AllTrim(C9V->C9V_NOME)
                ElseIf C9V->(MsSeek(xFilial("C9V", cFil) + cIdTrabal + "2"))
                    cNome := AllTrim(C9V->C9V_NOME)
                EndIf
            EndIf

            If Empty(cNome)

                If Empty(cNome)

                    cNome := GetNomeT3A(cFil, cCPF)

                    If Empty(cNome)

                        cNome := GetNomeV73(cFil, cCPF)

                        If Empty(cNome)
                            
                            V73->(DbSetOrder(3))

                            If V73->(MsSeek(xFilial("V73", cFil) + cCPF + "S2400" + "1"))
                                cNome := EncodeUTF8(AllTrim(V73->V73_NOMEB))
                            EndIf

                            If Empty(cNome)

                                V9U->(DbSetOrder(5))

                                If V9U->(MsSeek(xFilial("V73", cFil) + cCPF + "1"))
                                    cNome := EncodeUTF8(AllTrim(V9U->V9U_NMTRAB))
                                EndIf
                                
                            EndIf
                            
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

Return cNome

/*/{Protheus.doc} GetNomeT1U

Retorna o nome do trabalhador do evento S-2205

@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@param  cFil    - Filial a ser procurado o trabalhador
@param  cCPF    - CPF do trabalhador
@return cNome   - Nome do trabalhador
/*/
Static Function GetNomeT1U(cFil as character, cCPF as character, cIdTrabal as character)
    
    Local cLibVer   as character
    Local cQuery    as character
    Local cQryT1U   as character
    Local cQryAlias as character
    Local cNome     as character

    Default cFil        := ""
    Default cCPF        := ""
    Default cIdTrabal   := ""

    cLibVer     := ""
    cQuery      := ""
    cQryT1U     := ""
    cQryAlias   := ""
    cNome       := ""

    If !Empty(cCPF) .OR. !Empty(cIdTrabal)
        cLibVer := "20211116"
        
        GetLibDb()

        If __oQryT1U == Nil .Or. __cLibVer < cLibVer
            cQuery := ""

            If __cLibVer >= cLibVer
                cQuery := " SELECT "
            EndIf

            If __cBanco $ "ORACLE|MYSQL|POSTGRES"
                cQuery += " T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT "
            Else
                cQuery += IIf(__cBanco $ "MSSQL|OPENEDGE", " TOP 1 T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT ",; 
                            " FIRST 1 T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT ")
            EndIf

            cQuery += " FROM " + RetSQLName("T1U") + " T1U "
            cQuery += " WHERE T1U.D_E_L_E_T_ = ' ' "
            cQuery += " AND T1U.T1U_ATIVO = '1' "
            
            If __cLibVer >= cLibVer
                cQuery += " AND T1U.T1U_FILIAL = ? "
                cQuery += " AND ( T1U.T1U_CPF = ? "
                cQuery += " OR  T1U.T1U_ID = ? ) "
            Else
                cQuery += " AND T1U.T1U_FILIAL = '" + xFilial("T1U", cFil) + "' "
                cQuery += " AND ( T1U.T1U_CPF = '" + cCPF + "' "
                cQuery += " OR T1U.T1U_ID = '" + cIdTrabal + "' ) "
            EndIf

            cQuery += " GROUP BY T1U.T1U_FILIAL, T1U.T1U_NOME, T1U.T1U_DTALT "
            cQuery += " ORDER BY T1U.T1U_FILIAL, T1U.T1U_DTALT DESC "
            
            If __cBanco $ "POSTGRES|MYSQL"
                cQuery += " LIMIT 1 "
            EndIf

            If __cBanco == "ORACLE"
                If __cLibVer >= cLibVer
                    cQryT1U := " SELECT "
                EndIf

                cQryT1U += " TEMP.T1U_NOME FROM ( "

                If __cLibVer < cLibVer
                    cQryT1U += " SELECT "
                EndIf

                cQryT1U += cQuery
                cQryT1U += " ) TEMP "
                cQryT1U += " WHERE ROWNUM <= 1 "
            Else
                cQryT1U := cQuery
            EndIf

            If __cLibVer >= cLibVer
                cQryT1U		:= ChangeQuery(cQryT1U)
                __oQryT1U 	:= FwExecStatement():New(cQryT1U)
            EndIf
        EndIf
        
        If __cLibVer >= cLibVer
            __oQryT1U:SetString(1, xFilial("T1U", cFil))
            __oQryT1U:SetString(2, cCPF)
            __oQryT1U:SetString(3, cIdTrabal)

            cQryAlias := __oQryT1U:OpenAlias()
        Else
            cQryAlias	:= GetNextAlias()
            cQryT1U		:= "%" + cQryT1U + "%"

            BeginSQL Alias cQryAlias
                SELECT %Exp:cQryT1U%
            EndSQL
        EndIf

        If !(cQryAlias)->(EOF())
            cNome := EncodeUTF8(AllTrim((cQryAlias)->T1U_NOME))
        EndIf

        (cQryAlias)->(DbCloseArea())
    EndIf

Return cNome

/*/{Protheus.doc} GetNomeV73
Retorna o nome do trabalhador do evento S-2405

@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@param  cFil    - Filial a ser procurado o trabalhador
@param  cCPF    - CPF do trabalhador
@return cNome   - Nome do trabalhador
/*/
Static Function GetNomeV73(cFil as character, cCPF as character)

    Local cLibVer   as character
    Local cQuery    as character
    Local cQryV73   as character
    Local cQryAlias as character
    Local cNome     as character

    Default cFil    := ""
    Default cCPF    := ""

    cLibVer     := ""
    cQuery      := ""
    cQryV73     := ""
    cQryAlias   := ""
    cNome       := ""

    If !Empty(cCPF)
        cLibVer := "20211116"

        GetLibDb()

        If __oQryV73 == Nil .Or. __cLibVer < cLibVer
            cQuery := ""

            If __cLibVer >= cLibVer
                cQuery := " SELECT "
            EndIf

            If __cBanco $ "ORACLE|MYSQL|POSTGRES"
                cQuery += " V73.V73_FILIAL, V73.V73_NOMEB, V73.V73_DTALTE "
            Else
                cQuery += IIf(__cBanco $ "MSSQL|OPENEDGE", " TOP 1 V73.V73_FILIAL, V73.V73_NOMEB, V73.V73_DTALTE ",; 
                            " FIRST 1 V73.V73_FILIAL, V73.V73_NOMEB, V73.V73_DTALTE ")
            EndIf

            cQuery += " FROM " + RetSQLName("V73") + " V73 "
            cQuery += " WHERE V73.D_E_L_E_T_ = ' ' "
            cQuery += " AND V73.V73_ATIVO = '1' "
            cQuery += " AND V73.V73_NOMEVE = 'S2405' "
            
            If __cLibVer >= cLibVer
                cQuery += " AND V73.V73_FILIAL = ? "
                cQuery += " AND V73.V73_CPFBEN = ? "
            Else
                cQuery += " AND V73.V73_FILIAL = '" + xFilial("V73", cFil) + "' "
                cQuery += " AND V73.V73_CPFBEN = '" + cCPF + "' "
            EndIf

            cQuery += " GROUP BY V73.V73_FILIAL, V73.V73_NOMEB, V73.V73_DTALTE "
            cQuery += " ORDER BY V73.V73_FILIAL, V73.V73_DTALTE DESC "
            
            If __cBanco $ "POSTGRES|MYSQL"
                cQuery += " LIMIT 1 "
            EndIf

            If __cBanco == "ORACLE"
                If __cLibVer >= cLibVer
                    cQryV73 := " SELECT "
                EndIf

                cQryV73 += " TEMP.V73_NOMEB FROM ( "

                If __cLibVer < cLibVer
                    cQryV73 += " SELECT "
                EndIf

                cQryV73 += cQuery
                cQryV73 += " ) TEMP "
                cQryV73 += " WHERE ROWNUM <= 1 "
            Else
                cQryV73 := cQuery
            EndIf

            If __cLibVer >= cLibVer
                cQryV73		:= ChangeQuery(cQryV73)
                __oQryV73 	:= FwExecStatement():New(cQryV73)
            EndIf
        EndIf
        
        If __cLibVer >= cLibVer
            __oQryV73:SetString(1, xFilial("T1U", cFil))
            __oQryV73:SetString(2, cCPF)

            cQryAlias := __oQryV73:OpenAlias()
        Else
            cQryAlias	:= GetNextAlias()
            cQryV73		:= "%" + cQryV73 + "%"

            BeginSQL Alias cQryAlias
                SELECT %Exp:cQryV73%
            EndSQL
        EndIf

        If !(cQryAlias)->(EOF())
            cNome := EncodeUTF8(AllTrim((cQryAlias)->V73_NOMEB))
        EndIf

        (cQryAlias)->(DbCloseArea())
    EndIf

Return cNome

/*/{Protheus.doc} GetNomeT3A
Retorna o nome do trabalhador do evento S-2190

@author Melkz Siqueira
@since 24/10/2022
@version 1.0
@param  cFil    - Filial a ser procurado o trabalhador
@param  cCPF    - CPF do trabalhador
@return cNome   - Nome do trabalhador
/*/
Static Function GetNomeT3A(cFil as character, cCPF as character)
    
    Local cLibVer   as character
    Local cQuery    as character
    Local cQryT3A   as character
    Local cQryAlias as character
    Local cNome     as character

    Default cFil    := ""
    Default cCPF    := ""

    cLibVer     := ""
    cQuery      := ""
    cQryT3A     := ""
    cQryAlias   := ""
    cNome       := ""

    If !Empty(cCPF)
        cLibVer := "20211116"
        
        GetLibDb()

        If __oQryT3A == Nil .Or. __cLibVer < cLibVer
            cQuery := ""

            If __cLibVer >= cLibVer
                cQuery := " SELECT "
            EndIf

            cQuery += " T3A.T3A_FILIAL, T3A.T3A_ID "
            cQuery += " FROM " + RetSQLName("T3A") + " T3A "
            cQuery += " WHERE T3A.D_E_L_E_T_ = ' ' "
            cQuery += " AND T3A.T3A_ATIVO = '1' "
            
            If __cLibVer >= cLibVer
                cQuery += " AND T3A.T3A_FILIAL = ? "
                cQuery += " AND T3A.T3A_CPF = ? "
            Else
                cQuery += " AND T3A.T3A_FILIAL = '" + xFilial("T3A", cFil) + "' "
                cQuery += " AND T3A.T3A_CPF = '" + cCPF + "' "
            EndIf

            cQuery += " GROUP BY T3A.T3A_FILIAL, T3A.T3A_ID "
            
            cQryT3A := cQuery

            If __cLibVer >= cLibVer
                cQryT3A		:= ChangeQuery(cQryT3A)
                __oQryT3A 	:= FwExecStatement():New(cQryT3A)
            EndIf
        EndIf
        
        If __cLibVer >= cLibVer
            __oQryT3A:SetString(1, xFilial("T3A", cFil))
            __oQryT3A:SetString(2, cCPF)

            cQryAlias := __oQryT3A:OpenAlias()
        Else
            cQryAlias	:= GetNextAlias()
            cQryT3A		:= "%" + cQryT3A + "%"

            BeginSQL Alias cQryAlias
                SELECT %Exp:cQryT3A%
            EndSQL
        EndIf

        If !(cQryAlias)->(EOF())
            cNome := Upper(STR0010) // "Trabalhador Preliminar"
        EndIf

        (cQryAlias)->(DbCloseArea())
    EndIf

Return cNome

/*/{Protheus.doc} RetTranslate
    (long_description)
    @type  Static Function
    @author Silas/Karyna
    @since 10/05/2023
    @version version
    @return cRet, string
/*/
Static Function RetTranslate()
    
    Local cRet      as character
    Local cAcento   as character
    Local cNoAcento as character
    
    cAcento   := 'áéíóúÁÉÍÓÚâêîôûÂÊÎÔÛäëïöüÄËÏÖÜàèìòùÀÈÌÒÙãõÃÕçÇ'
    cNoAcento := 'aeiouAEIOUaeiouAEIOUaeiouAEIOUaeiouAEIOUaoAOcC'

    cRet      := " '" + cAcento + "' , '" + cNoAcento + "' "
    
Return cRet

/*/{Protheus.doc} TafLolCateg
    (long_description)
    @type Function
    @author Alexandre Lima Santos
    @since 14/06/2024
    @version version
    @param  cId    - Id do trabalhador
    @param  cAlias - Alias da tabela T1V ou T0F
    @return cFil   - filial do registro a ser pesquisado
    @return cRet, string
/*/
Function TafLolCateg( cId as character, cAlias as character, cFil as character)
    
    Local cRet   as character

    Default cId := ""
    Default cAlias := ""

    cRet   := ""

	dbSelectArea(cAlias)
	(cAlias)->(dbSetorder(2)) // FILIAL + ID + ATIVO + DTALT
	(cAlias)->(dbGoTop())

	If (cAlias)->(msSeek(xFilial(cAlias, cFil ) + cId + "1"))

		While (cAlias)->(!Eof()) .And. (cAlias)->&(cAlias + "_FILIAL" ) + (cAlias)->&(cAlias + "_ID" ) + (cAlias)->&(cAlias + "_ATIVO" ) == cFil + cId + "1"

			If (cAlias)->&(cAlias + "_EVENTO") $ 'I|A'

                If cAlias == "T1V"
                    cRet := (cAlias)->&(cAlias + "_CODCAT")
                Else
                    cRet := (cAlias)->&(cAlias + "_CATAV")
                EndIf

            EndIf
            
            (cAlias)->(dbSkip())

		Enddo
	EndIf

    If Empty(cRet)
        If cAlias == "T1V"
            cRet := Posicione("CUP", 1, xFilial("CUP", cFil ) + cId, "CUP_CODCAT")
        Else
            cRet := Posicione("C9V", 2, xFilial("C9V", cFil ) + cId + "1", "C9V_CATCI")
        EndIf
    EndIf 

Return cRet
