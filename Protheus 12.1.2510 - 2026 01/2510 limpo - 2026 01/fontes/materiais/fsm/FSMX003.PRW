#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetUTCDateTime

FunÁ„o para obter a data e hora atual em UTC

@author     Alexandre Takaki
@since      03/02/2025
/*/
//------------------------------------------------------------------------------
Function GetUTCDateTime(cTM)

    Local cData         := ""
    Local cHora         := ""
    Local dDataS        := Date()  // ObtÈm a data atual do Servidor
    Local cHoraS        := Time()  // ObtÈm a hora atual do Servidor
    Local nUtc          := 0
    Local nMinutos      := 0
    Local nHora         := 0
    Local cUtcServ      := ""
    Local nUtcServ      := 0
    Local nUtcRes       := 0
    
    // Extrai o valor do UTC (sem o operador)
    nUtc  := Val(SubStr(cTM, 1, Len(cTM)))

    // Converte o UTC para minutos (1 hora = 60 minutos)
    nUtc := nUtc * 60

    // Pegar o UTC do Servidor
    cUtcServ := Right(FWTimeStamp(5, dDataS, cHoraS),6)

    // Converte o UTC para minutos (1 hora = 60 minutos)
    nUtcServ := Val(cUtcServ) * 60

    nUtcRes := nUtcServ - nUtc

    // Converte a hora atual do servidor para minutos
    nMinutos := Hrs2Min(cHoraS)

    nMinutos := nMinutos - nUtcRes

    // Ajusta a data, se necess·rio
    If nMinutos < 0
        // Se o resultado for negativo, subtrai um dia
        dDataS := DaySub(dDataS, 1)
        nMinutos := nMinutos + 1440 // Adiciona 24 horas (1440 minutos)
    ElseIf nMinutos >= 1440
        // Se o resultado for maior que 24 horas, adiciona um dia
        dDataS := DaySum(dDataS, 1)
        nMinutos := nMinutos - 1440 // Subtrai 24 horas (1440 minutos)
    EndIf

    // Converte os minutos de volta para o formato HH:MM:SS
    nHora := Min2Hrs(nMinutos) // Converte minutos para horas e minutos
    cHora := StrZero(Int(nHora), 2) + ":" + StrZero(Val(Right(cValToChar(nHora - Int(nHora)),2)), 2) + ":" + Right(cHoraS, 2)

    // Formata a data no formato YYYYMMDD
    cData := DTOS(dDataS)

Return ({cData, cHora})

//------------------------------------------------------------------------------
/*/{Protheus.doc} validTime

FunÁ„o para validar hora (99:99:99)

@author     Alexandre Takaki
@since      03/02/2025
/*/
//------------------------------------------------------------------------------
Function validTime(cHora)

    Local lRet  := .F.
    Local cSeg  := ""

    If AtVldHora(cHora)
        // Validar os segundos
        cSeg := SubStr(cHora,7,Len(cHora))
        If Val(cSeg) < 60
            lRet := .T.
        EndIf
    EndIf
    
Return(lRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} OsAponta

FunÁ„o para retornar os apontamentos da Ordem de Servico

@author     Alexandre Takaki
@since      03/02/2025
/*/
//------------------------------------------------------------------------------
Function OsAponta(cNumOS,cAttendant,cCodAgenda)

    Local aRet          := {}
    Local oQuery
    Local cQuery        := ""
    Local cAlias		:= GetNextAlias() 

    cQuery := " SELECT	JN3.JN3_CODIGO, "
    cQuery += "         JN3.JN3_CODPRO, "
    cQuery += "         SB1.B1_DESC, "
    cQuery += "         JN3.JN3_NUMSER "
    cQuery += " FROM	" + RetSqlName('JN3') + "	JN3, "
    cQuery += "         " + RetSqlName('SB1') + "	SB1, "
    cQuery += "         " + RetSqlName('JN6') + "	JN6 "
    cQuery += " WHERE	JN3.JN3_FILIAL	= ? "
    cQuery += " AND		JN3.JN3_CODIGO	= ? "
    cQuery += " AND		JN3.D_E_L_E_T_	= ? "
    cQuery += " AND		SB1.B1_FILIAL	= ? "
    cQuery += " AND		SB1.B1_COD		= JN3.JN3_CODPRO "
    cQuery += " AND		SB1.D_E_L_E_T_	= ? "
    cQuery += " AND		JN6.JN6_FILIAL	= JN3.JN3_FILIAL "
    cQuery += " AND		JN6.JN6_CODJN3	= JN3.JN3_CODIGO "
    cQuery += " AND		JN6.JN6_CODIGO	= ? "
    cQuery += " AND		JN6.JN6_CODAA1	= ? "
    cQuery += " AND		JN6.D_E_L_E_T_	= ? "

    cQuery  := ChangeQuery(cQuery)
    oQuery  := FWPreparedStatement():New(cQuery)    

    oQuery:SetString(1, xFilial("JN3"))
    oQuery:SetString(2, cNumOS)
    oQuery:SetString(3, ' ')
    oQuery:SetString(4, xFilial("SB1"))
    oQuery:SetString(5, ' ')
    oQuery:SetString(6, cCodAgenda)
    oQuery:SetString(7, cAttendant)
    oQuery:SetString(8, ' ')

    cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

    If (cAlias)->(!Eof())

        Do While (cAlias)->(!Eof())

            aAdd(aRet,{;
                (cAlias)->JN3_CODPRO,;
                (cAlias)->B1_DESC,;
                (cAlias)->JN3_NUMSER,;
                0,;
                "",;
                "",;
                "",;
                "",;
                "";
            })

            (cAlias)->(DbSkip())
        EndDo

    EndIf
        
    (cAlias)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)

Return aRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FncCaracEsp

Verifica a existencia de alguns caracteres especiais na descriÁ„o

@param cExp: Express„o que ser· avaliada para a existencia de caracter especial
@param cDescExp: Express„o j· corrigida 

@return ExpL: Retorna .T. se achou algum caracter especial
/*/
//--------------------------------------------------------------------------------------------------------------------
Function FncCaracEsp(cExp,cDescExp)

    Local lRet      := .F.
    Local aCarac    := {"'",'"',"{","}","[","]","(",")",char(129),char(141),char(143),char(144),char(157)}
    Local nI        := 0

    If ValType(cExp) == "C"
        cDescExp := cExp
        For nI := 1 To Len(aCarac)
            If At(aCarac[nI],cExp) > 0
                lRet := .T.
                If aCarac[nI] == '"'
                    cDescExp := StrTran( cExp, aCarac[nI], CHR(96)+CHR(96) )
                    Exit
                ElseIf aCarac[nI] == char(157);
                        .OR. aCarac[nI] == char(129);
                        .OR. aCarac[nI] == char(141);
                        .OR. aCarac[nI] == char(143);
                        .OR. aCarac[nI] == char(144);
                        .OR. aCarac[nI] == char(157);
                        .OR. aCarac[nI] == "'"
                        
                    cDescExp := StrTran( cExp, aCarac[nI], CHR(32) )
                    cDescExp := ALLTRIM(cDescExp)
                    Exit                
                EndIf
            EndIf
        Next nI
        cDescExp := StrTran( cDescExp, '\', '\\' )
        cDescExp := StrTran( cDescExp, '\\n', '\n' )
    EndIf

Return lRet

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FncArqB64

Funcao para transformar um arquivo em base64
cArquivo := "caminho completo do arquivo"

@author     Alexandre Takaki
@since      07/03/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function FncArqB64(cArquivo)
    
    Local cConteudo := ""
    Local cString64 := ""
    Local oFile
    Local cExt      := ""
 
    If File(cArquivo)
 
        //Tenta abrir o arquivo e pegar o conteudo
        oFile := FwFileReader():New(cArquivo)
        If oFile:Open() 
            //Se deu certo abrir o arquivo, pega o conteudo e transforma em base 64
            cConteudo  := oFile:FullRead()
            cString64  := Encode64(cConteudo, , .F., .F.)
            If SubStr(cString64,1,4) <> "data"
                cExt := Right(Alltrim(cArquivo),3)
                cString64 := "data:image/"+cExt+";base64," + cString64
            EndIf
        EndIf

        oFile:Close()

    EndIf

Return cString64

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} getLaudo

Funcao para retornar o laudo da OS

@author     Alexandre Takaki
@since      21/03/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function getLaudo(cNumOS,cNumAgenda)

    Local aRet          := {}
    Local oQuery
    Local cQuery        := ""
    Local cAlias		:= GetNextAlias() 

    cQuery := " SELECT	JNY_CODIGO, "
    cQuery += "         JNY_DESCRI "
    cQuery += " FROM	" + RetSqlName('JNY') + " "
    cQuery += " WHERE	JNY_FILIAL	= ? "
    cQuery += " AND		JNY_CODJN3	= ? "
    cQuery += " AND		JNY_CODJN6	= ? "
    cQuery += " AND		D_E_L_E_T_	= ? "
       
    cQuery  := ChangeQuery(cQuery)
    oQuery  := FWPreparedStatement():New(cQuery)    

    oQuery:SetString(1, xFilial("JNY"))
    oQuery:SetString(2, cNumOS)
    oQuery:SetString(3, cNumAgenda)
    oQuery:SetString(4, ' ')

    cAlias := MPSysOpenQuery( oQuery:getFixQuery() )

    If (cAlias)->(!Eof())
        Do While (cAlias)->(!Eof())
            aAdd(aRet,{Alltrim((cAlias)->JNY_CODIGO),Alltrim((cAlias)->JNY_DESCRI)})
            (cAlias)->(DbSkip())
        EndDo    
    EndIf

    (cAlias)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)

Return(aRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} incLaudo

Funcao para inclusao do laudo da OS

@author     Alexandre Takaki
@since      26/03/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function incLaudo(cNumOS,cNumAgenda,cCodAtend,cNewLaudo,cCodUsr)

    Local oModel            := Nil
    Local lRet              := .F.    
    Local cDescExp          := ""
    Local cNewDesc          := ""

    JNY->(dbSetOrder(1))
       
    FncCaracEsp(cNewLaudo,@cDescExp)

    cNewDesc := ProcExcEsp(cDescExp)

    oModel := FwLoadModel('FSMA025')

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue('JNYMASTER', 'JNY_DESCRI', Alltrim(EncodeUTF8(cNewDesc)))
    oModel:SetValue('JNYMASTER', 'JNY_CODUSR', cCodUsr)
    oModel:SetValue('JNYMASTER', 'JNY_CODJN3', cNumOS)
    oModel:SetValue('JNYMASTER', 'JNY_CODJN6', cNumAgenda)
    oModel:SetValue('JNYMASTER', 'JNY_CODAA1', cCodAtend)
    oModel:SetValue('JNYMASTER', 'JNY_DTINCL', dDataBase)
    
    If oModel:VldData()
            oModel:CommitData()
            lRet := .T.            
    Endif

    oModel:DeActivate()

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} incFoto

Funcao para inclusao de foto ou arquivo na OS

@author     Alexandre Takaki
@since      26/03/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function incFoto(cTabela,cCodAgenda,cBase64,cTipoArq,cDescriFix)

    Local oModel            := Nil
    Local lRet              := .F.   
    Local cDescExp          := ""
    Local cNewDesc          := "" 

    if !Empty(cDescriFix) 
        FncCaracEsp(DecodeUtf8(cDescriFix),@cDescExp)
    Endif
    cNewDesc := ProcExcEsp(cDescExp)

    oModel := FwLoadModel('FSMA026')

    oModel:SetOperation(MODEL_OPERATION_INSERT)
    oModel:Activate()

    oModel:SetValue('JO0MASTER', 'JO0_ALIAS', cTabela)
    oModel:SetValue('JO0MASTER', 'JO0_CODORI', cCodAgenda)
    oModel:SetValue('JO0MASTER', 'JO0_MIDIA', cBase64)
    oModel:SetValue('JO0MASTER', 'JO0_EXTARQ', cTipoArq)
    oModel:SetValue('JO0MASTER', 'JO0_DESCRI', Alltrim(EncodeUTF8(cNewDesc)))
    
    If oModel:VldData()
            oModel:CommitData()
            lRet := .T.            
    Endif

    oModel:DeActivate()

Return(lRet)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} EncerraOS()

Encerrar Ordem de ServiÁo

@param ExpO: Objeto com os dados do put para encerramento da ordem de serviÁo

@author     Alexandre Takaki
@since      22/04/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function EncerraOS(oRequest,cMsgError) //

    Local oModel            := Nil
    Local lRet              := .F.
    Local cBaseAtend        := ""
    Local cData             := ""
    Local cHora             := ""
    Local aRet              := {}
    Local cStatus           := ""
    Local dData             := CTOD("  /  /  ")
    Local cOrigem           := "1"
    Local cDescExp          := ""
    Local nX, nY            := 0
    Local cBase64           := ""
    Local nPos              := 0
    Local aFotos            := {}
    Local aAssinatura       := {}


    Default cMsgError       := ""

    JN3->(dbSetOrder(1))
    
    If !Empty(oRequest['numOS'])
        If JN3->(dbSeek(xFilial('JN3')+oRequest['numOS']))
            cBaseAtend := Alltrim(JN3->JN3_CODPRO)
            lRet := .T.
        Else
            cMsgError := EncodeUtf8("N˙mero da OS n„o localizado")
            lRet := .F.
        EndIf

        JN6->(dbSetOrder(1))
        If JN6->(dbSeek(xFilial('JN6')+PadR(oRequest['codAgenda'],TamSx3("JN6_CODIGO")[1])))
            If JN6->JN6_SITUAC <> "01" 
                If JN6->JN6_SITUAC <> "10" 
                    cMsgError := EncodeUtf8("Para encerramento o Status da Agenda precisa estar 'Em atendimento ou Atendimento Pendente'")
                    lRet :=  .F.
                Endif  
            EndIf  
        Else
            cMsgError := EncodeUtf8("CÛdigo da Agenda n„o localizado")
            lRet :=  .F.
        Endif

    EndIf

    if lRet
        If Valtype(oRequest['statusOs']) == "N"
            cStatus := StrZero(oRequest['statusOs'],2)
        Else
            cStatus := StrZero(Val(oRequest['statusOs']),2)
        EndIf
            
        If !Empty(oRequest['utc'])
            aRet := GetUTCDateTime(oRequest['utc'])
            cData := aRet[1]
            cHora := aRet[2]
        Else                
            cData := DTOS(Date())
            cHora := Time()
        EndIf

        dData := StoD(cData)

        For nX := 1 To Len(oRequest['itensOs'])
            FncCaracEsp(oRequest['itensOs'][nX]['apontamento']['laudo'],@cDescExp)
            If oRequest['itensOs'][nX]['apontamento']['fotos'] != NIL .And. ;
                Len(oRequest['itensOs'][nX]['apontamento']['fotos']) > 0
                    For nY := 1 To Len(oRequest['itensOs'][nX]['apontamento']['fotos'])
                        aAdd(aFotos,{;
                            oRequest['itensOs'][nX]['apontamento']['fotos'][nY]['base64'],;
                            oRequest['itensOs'][nX]['apontamento']['fotos'][nY]['description'],;
                            oRequest['itensOs'][nX]['apontamento']['fotos'][nY]['cFileType'];
                        })
                    Next nY
            EndIf
        Next nX

        aAdd(aAssinatura,{;
            oRequest['assinatura'],;
            oRequest['responsavel'],;
            oRequest['cFileType'];
        })
        
        oModel := FwLoadModel('FSMA011')

        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        oModel:Activate()

        oModel:SetValue('JN6MASTER', 'JN6_CODIGO', oRequest['codAgenda'])
        oModel:SetValue('JN6MASTER', 'JN6_CODJN3', oRequest['numOS'])
        oModel:SetValue('JN6MASTER', 'JN6_CODAA1', oRequest['CodTec'])
        oModel:SetValue('JN6MASTER', 'JN6_SITUAC', cStatus)

        If !(oModel:GetModel('JNJDETAIL'):IsEmpty())
            oModel:GetModel('JNJDETAIL'):AddLine()
        EndIf
        
        oModel:SetValue('JNJDETAIL', 'JNJ_CODJN6', oRequest['codAgenda'])
        oModel:SetValue('JNJDETAIL', 'JNJ_CODATD', oRequest['CodTec'])
        oModel:SetValue('JNJDETAIL', 'JNJ_DTINI', dData)
        oModel:SetValue('JNJDETAIL', 'JNJ_HRINI', cHora)
        oModel:SetValue('JNJDETAIL', 'JNJ_CODJN3', oRequest['numOS'])
        oModel:SetValue('JNJDETAIL', 'JNJ_BASE', cBaseAtend)
        oModel:SetValue('JNJDETAIL', 'JNJ_ORIGEM', cOrigem)
        oModel:SetValue('JNJDETAIL', 'JNJ_CODUSU', oRequest['codProtheus'])
        oModel:SetValue('JNJDETAIL', 'JNJ_SITUAC', cStatus)

        If !Empty(cDescExp)
            incLaudo(oRequest['numOS'],oRequest['codAgenda'],oRequest['CodTec'],Alltrim(DecodeUTF8(cDescExp)),oRequest['codProtheus'])
        EndIf        

        If Len(aFotos) > 0
            For nX := 1 To Len(aFotos)
                If SubStr(aFotos[nX][1],1,4) == "data"
                    nPos := At(",",aFotos[nX][1])
                    If nPos > 0
                        cBase64 := SubStr(aFotos[nX][1],nPos+1,Len(aFotos[nX][1])) 
                    EndIf
                Else
                    cBase64 := aFotos[nX][1]
                EndIf
                incFoto("JN6",oRequest['codAgenda'],cBase64,aFotos[nX][3],aFotos[nX][2])
            Next nX                
        EndIf 

        If Len(aAssinatura) > 0            
            If SubStr(aAssinatura[1][1],1,4) == "data"
                nPos := At(",",aAssinatura[1][1])
                If nPos > 0
                    cBase64 := SubStr(aAssinatura[1][1],nPos+1,Len(aAssinatura[1][1])) 
                EndIf
            Else
                cBase64 := aAssinatura[1][1]
            EndIf
            incFoto("JN6",oRequest['codAgenda'],cBase64,aAssinatura[1][3],aAssinatura[1][2])
        EndIf 
        
        If oModel:VldData()
            oModel:CommitData()
            lRet := .T.
            cMsgError := EncodeUtf8('Atendimento encerrado com sucesso')
        Endif

        oModel:DeActivate()
    Endif    

Return(lRet)   

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcExcEsp()

Retirar caracteres especiais

@author     Alexandre Takaki
@since      23/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function ProcExcEsp(cString)

	Local cQryString	:= ""	
	Local cSpecChar		:= "¿Ã“Ÿ»¡Õ”⁄…√œ’‹Àƒ÷¬Œ‘€ ‡ÏÚ˘Ë·ÌÛ˙È„Ôı¸Î·ˆ‚ÓÙ˚Í«Á@#$%()+=ß¨¢£≥≤π^~¥`[]{}™∫∞<>/\|*!&,:?;''∞" //86
	Local cSpecTran		:= "AIOUEAIOUEAIOUEAOAIOUEaioueaioueaioueaoaioueCc" //46
	
	cQryString:= MsSqlTran(@cString,cSpecChar,cSpecTran)
	
Return(cString)

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MsSqlTran()

Retirar caracteres especiais

@author     Alexandre Takaki
@since      23/05/2025
/*/
//--------------------------------------------------------------------------------------------------------------------
Function MsSqlTran(cString,cSpecChar,cSpecTran)  

	Local nTam	:= 0
	Local nC	:= 0
	Local nPos	:= 0
	
	nTam := Len(cString)
	
	For nC := 1 To nTam
		
		nPos := At(Substr(cString,nC,1), cSpecChar)
		
		If 	nPos <> 0 
			cString := Left(cString, nC-1) + iif( empty(Substr(cSpecTran,nPos,1))," ",Substr(cSpecTran,nPos,1) ) + Substr(cString,nC+1, Len(cString)-nC)  
		Endif 
		
	Next nC
	
Return
