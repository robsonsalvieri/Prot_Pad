#INCLUDE "TOTVS.CH"
#INCLUDE "FWLIBVERSION.CH"
#INCLUDE "ESTXFUN.CH"

#DEFINE DEF_SPS_FROM_RPO                "1"
#DEFINE DEF_SPS_NOT_INSTALLED           "2"

Static __aPrep := Nil As Array

/*/{Protheus.doc} OrigemLote
    Essa função tem como objetivo informar a Origem do Produto de um dado Lote e Sublote (caso se aplique).
    Será considerado a Nota de Entrada classificada com maior Data de Digitação, usando o maior Recnumber da SD1 como fator de desempate.
    Parte-se do pressuposto que os parâmetros da função já foram previamente validados antes de sua chamada.
    @type  Function
    @author SQUAD Entradas
    @since 14/05/2019
    @version 1.1
    @param cProduto, Caracter, Código do Produto a ser consultado.
    @param cLote, Caracter, Lote a ser consultado.
    @param cNumLote, Caracter, Sublote a ser consultado.
    @return cOrigem, Caracter, Origem do produto composto pelo primeiro caracter do campo D1_CLASFIS
/*/
Function OrigemLote(cProduto, cLote, cNumLote)

Local cOrigem := ""
Local cBkpAlias := Alias()
Local cAlias := GetNextAlias()

Default cProduto := Space(TamSX3("D1_COD")[1])
Default cLote := Space(TamSX3("D1_LOTECTL")[1])
Default cNumLote := Space(TamSX3("D1_NUMLOTE")[1])

BeginSql Alias cAlias

    SELECT D1_CLASFIS
    FROM %table:SD1%
    WHERE R_E_C_N_O_ = (
        SELECT MAX(SD1.R_E_C_N_O_)
        FROM %table:SD1% SD1
        INNER JOIN %table:SD5% SD5
        ON SD5.D5_FILIAL = %xFilial:SD5% AND
        SD1.D1_FILIAL = %xFilial:SD1% AND
        SD5.D5_NUMSEQ = SD1.D1_NUMSEQ
        WHERE   D5_PRODUTO = %Exp:cProduto% AND
                D5_LOTECTL = %Exp:cLote% AND
                D5_NUMLOTE = %Exp:cNumLote% AND
                SD5.%NotDel% AND
                D1_DTDIGIT = (
                    SELECT MAX(D1_DTDIGIT)
                    FROM %table:SD1% SD1
                    INNER JOIN %table:SD5% SD5
                    ON SD5.D5_FILIAL = %xFilial:SD5% AND
                    SD1.D1_FILIAL = %xFilial:SD1% AND
                    SD5.D5_NUMSEQ = SD1.D1_NUMSEQ
                    WHERE D5_PRODUTO = %Exp:cProduto% AND
                        D5_LOTECTL = %Exp:cLote% AND
                        D5_NUMLOTE =  %Exp:cNumLote% AND
                        SD5.%NotDel%
                )
    )

EndSql

If !(cAlias)->(EoF())
    cOrigem := If(Len((cAlias)->D1_CLASFIS) > 0, SubStr((cAlias)->D1_CLASFIS, 1, 1), "")
EndIf

(cAlias)->(dbCloseArea())

If !Empty(cBkpAlias)
    DbSelectArea(cBkpAlias)
EndIf

Return (cOrigem)


/*/{Protheus.doc} ESTMetrics
    Tem como objeto coletar metricas ao acessar o modulo de estoque para envio a license server.
    @type  Function
    @author reynaldo
    @since 31/05/2021
    @version 1.0
    @return cOrigem, Caracter, Origem do produto composto pelo primeiro caracter do campo D1_CLASFIS
/*/
Function ESTMetrics()
Local cRastro
Local cQuery
Local cCusFil
Local cMP_SUBROT

//????????????????????????????????????????????????????????????????
// Telemetria - Uso da classe FwCustomMetrics                   //
// Metrica - setAverageMetric                                   //
//????????????????????????????????????????????????????????????????
If FWLibVersion() >= "20210628"

	cRastro := SuperGetMv('MV_RASTRO', .F., 'N')

	If cRastro == "S"
		// produto com rastrealibilidade por lote
		cQuery := "SELECT COUNT(R_E_C_N_O_) NREC FROM " + RetSqlName("SB1")
		cQuery += " WHERE B1_RASTRO = 'L' AND D_E_L_E_T_ = ' '"
		nCount := MpSysExecScalar(cQuery,"NREC")
		If nCount >0
			FWCustomMetrics():setAverageMetric(	"LOTE"/*cSubRoutine*/,;
											"estoque-protheus_controle-rastreabilidade_total" /*cIdMetric*/,;
											1/*nValue*/,;
                                /*dDateSend*/,;
                                /*nLapTime*/,;
                                "MATA010"/*cRotina*/)
		EndIf

		// produto com rastreabilidade por lote
		cQuery := "SELECT COUNT(R_E_C_N_O_) NREC FROM " + RetSqlName("SB1")
		cQuery += " WHERE B1_RASTRO = 'S' AND D_E_L_E_T_ = ' '"
		nCount := MpSysExecScalar(cQuery,"NREC")
		If nCount >0
			FWCustomMetrics():setAverageMetric(	"SUBLOTE"/*cSubRoutine*/,;
												"estoque-protheus_controle-rastreabilidade_total" /*cIdMetric*/,;
												1/*nValue*/,;
                                    /*dDateSend*/,;
                                    /*nLapTime*/,;
                                    "MATA010"/*cRotina*/)
		EndIf

    EndIf

    // etiqueta com rastreabilidade forte (CB0)
    If !Empty(SuperGetMv("MV_ACDCB0",.F.," "))
        FWCustomMetrics():setAverageMetric(	"ACDXFUN"/*cSubRoutine*/,;
                                            "estoque-protheus_rastreabilidade-etiqueta_count" /*cIdMetric*/,;
                                            1/*nValue*/,;
                                            /*dDateSend*/,;
                                            /*nLapTime*/,;
                                            "ACDXFUN"/*cRotina*/)
    EndIf

    cCusFil := SuperGetMV('MV_CUSFIL',.F.,"A")

    IF cCusFil == "E"
        cMP_SUBROT := "EMPRESA"
    ELSEIF cCusFil == "F"
        cMP_SUBROT := "FILIAL"
    ELSE
        cMP_SUBROT := "ARMAZEM"
    EndIf

    FWCustomMetrics():setAverageMetric(	cMP_SUBROT/*cSubRoutine*/,;
                                        "estoque-protheus_aglutinacao-custo_total" /*cIdMetric*/,;
                                        1/*nValue*/,;
                                        /*dDateSend*/,;
                                        /*nLapTime*/,;
                                        "MATA330"/*cRotina*/)

	If SuperGetMv('MV_FFONLIN', .F., .F.)
        FWCustomMetrics():setAverageMetric(	"SIGACUSB"/*cSubRoutine*/,;
                                        "estoque-protheus_custo-fifo-on-line_count" /*cIdMetric*/,;
                                        1/*nValue*/,;
                                        /*dDateSend*/,;
                                        /*nLapTime*/,;
                                        "SIGACUSB"/*cRotina*/)
    EndIf

EndIf

Return

/*/{Protheus.doc} CV8LogView
Função genérica responsável pela aprasentação dos logs de execução(CV8) na tNewProcess

@author Leonardo Kichitaro
@since 27/05/2024
/*/
Function CV8LogView(cProc, oCenterPanel)

	Local aAreaAnt  := GetArea()
	Local cFilterIni:= ""
	Local cFilterFin:= ""   
	Local cChave	:= ""

	Local oBrowse	:= Nil

	Local aButton	:= {}

	Default cProc 		:= ""  
	Default oCenterPanel:= Nil

    If Type("cCadastro") != "C"
        cCadastro := ""
    EndIf

	aAdd(aButton,{OemToAnsi(STR0002) ,OemToAnsi(STR0002),{|| ProcLogDet("CV8", CV8->(Recno()), 2, oBrowse)}}) //"Detalhes"

	//Criado parametro para filtro
	dbSelectArea("CV8")

	dbSetOrder(1) //CV8_FILIAL+CV8_PROC+DTOS(CV8_DATA)+CV8_HORA
	cProc := Padr( cProc,TamSx3("CV8_PROC")[1])
	cFilterIni :='xFilial("CV8")+"'+cProc+'"'
	cFilterFin :='xFilial("CV8")+"'+cProc+'zzzzzzzzzzz"'                    
	cChave := xFilial("CV8")+cProc

	MaWndBrowse(0,;											//01
				0,;											//02
				500,;										//03
				700,;										//04
				OemToAnsi(STR0001)+" - "+cCadastro,;	    //05 - "Log de Execução"
				"CV8",;										//06
				Nil,;										//07
				Nil,;										//08
				"CV8->CV8_INFO=='4'",;						//09
				cFilterIni,;								//10
				cFilterFin,;								//11
				.T.,;										//12
				{{"OK",""},{"CANCEL",""}},;					//13
				4,;											//14
				{{"Data+Hora",1},{"Usuario+Data+Hora",2}},;	//15
				cChave,;									//16
				Nil,;										//17
				Nil,;										//18
				Nil,;										//19
				Nil,;										//20
				Nil,;										//21
				@oBrowse,;									//22
				Nil,;										//23
				Nil,;										//24
				Nil,;										//25
				oCenterPanel,;								//26
				aButton,;									//27
				Nil,;										//28
				Nil,;										//29
				.F.,;										//30
				Nil,;										//31
				".F." )										//32

	RestArea(aAreaAnt)

Return

/*/{Protheus.doc} SD3Estorno
Função genérica para gerar o estorno na SD3
@param nRecORI, Numerico, Recno a ser estornado.
@param aCposCHG, Array, array com os campos Pos 1 e conteudo pos 2 que serão gerados no registro destino.
@param lInTran, Logico, indicativo em transação.
@return nRecDES, Numerico, Recno do registro destino. 
/*/
Function SD3Estorno (nRecORI, aCposCHG, lUnlOri, lUnlDes)
Local nRecDES    := 0
Local i          := 0
Default nRecORI  := 0
Default aCposCHG := {}
Default lUnlOri  := .F.
Default lUnlDes  := .F.

If nRecORI > 0 
    dbSelectArea("SD3")
    dbgoto(nRecORI)
    RecLock("SD3",.F.)
    Replace D3_ESTORNO With "S"
    If lUnlOri
        MsUnLock()
    EndIf
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Salva a integridade dos campos de Bancos de Dados            ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    For i := 1 To FCount() 
        If aScan(aCposCHG,{|x| alltrim(x[1]) == alltrim(Field(i))}) == 0
            aadd (aCposCHG,{Field(i) ,FieldGet(i)})
        EndIf 
    Next i
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Cria o registro de estorno com mesmos dados do original      ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    RecLock("SD3",.T.)
    For i := 1 TO FCount()
        If !('D3_MSUID' $ Field(i))
            nCPO := aScan(aCposCHG,{|x| alltrim(x[1]) == alltrim(Field(i))}) 
            If nCPO > 0
                FieldPut(i,aCposCHG[nCPO,2])
            EndIf
        EndIf
    Next i
    Replace D3_USUARIO With CUSERNAME
    If lUnlDes
        MsUnLock()
    EndIf
    nRecDES := Recno()
EndIf
Return nRecDES


/*/{Protheus.doc} ESTNXTNUM
	Obtém o próximo maior código sequencial de uma tabela.
@type  Function
@author Everton Fregonezi Diniz
@since 21/10/2025
/*/
Function ESTNXTNUM(cAlias, cField, lSoma)

local aArea		:= {}
local cAlsQry	:= ""
local cFldFil	:= ""
local cQry  	:= ""
local cRet  	:= ""
local cValIni	:= ""
local cValEnd	:= ""
local oBind		:= Nil
local nX		:= 1
local nDocSize  := 0
local lDocMinu  := .F.

default cAlias  := ""
default cField  := ""
default lSoma 	:= .T.

lDocMinu := SuperGetMv('MV_ESTMINU', .F., .F.)

	if !empty(cAlias) .and. !empty(cField)

		aArea := (cAlias)->(GetArea())

        nDocSize := FWTamSX3(cField)[1]
		
        DbSelectArea(cAlias)
		
		if FieldPos(cField) > 0

			cFldFil := FWJoinFilial(cAlias,cAlias,,,.F.)
			cFldFil	:= alltrim(substr(cFldFil, 1, At('=',cFldFil)-2))
				
			cValIni := Replicate("0", nDocSize)
            if !lDocMinu
    			cValEnd := Replicate("Z", nDocSize) 
            else
                cValEnd := Replicate("z", nDocSize) 
            endif
			cQry := " SELECT MAX(?) MAXDOC "
			cQry += " FROM " + RetSqlName(cAlias)
			cQry += " WHERE		?   = ? "
			cQry += "		AND ?      		BETWEEN  ? AND ? "
			cQry += "		AND D_E_L_E_T_  = ? "

			oBind := FWExecStatement():New( changeQuery(cQry) )
			oBind:setUnsafe(nX++, cField)
			oBind:setUnsafe(nX++, cFldFil)
			oBind:setString(nX++, FWxFilial(cAlias))
			oBind:setUnsafe(nX++, cField)
			oBind:setString(nX++, cValIni)
			oBind:setString(nX++, cValEnd)
			oBind:setString(nX++, ' ')
			cAlsQry := oBind:OpenAlias()
			oBind:destroy()

			while (cAlsQry)->(!EOF())
				cRet := substr((cAlsQry)->MAXDOC,len((cAlsQry)->MAXDOC) - iif(len((cAlsQry)->MAXDOC) == nDocSize,nDocSize,nDocSize - 1), nDocSize)
				if lSoma
					cRet := soma1(cRet)
                    if cRet == "000000"
                        cRet := Replicate("0",nDocSize)
                        cRet := soma1(cRet)
                    endif
				endif
				(cAlsQry)->(dbSkip())
			enddo

			(cAlsQry)->(dbCloseArea())

		endif

		RestArea(aArea)
	
	endif

	FwFreeArray(aArea)
	
Return cRet

//------------------------------------------------------------------
/*/{Protheus.doc} ESTAvSegLt
Avalia se um produto em questão segrega lote e o 
armazem não é CQ, Processo ou Terceiros

@type   Function
@author Jorge Martins / Squad Retail
@since  24/03/2026
@param  cProduto  , character, Código do produto
@param  cArmazem  , character, Código do armazém
@return lRet      , logical, .T. se o produto segrega lote e o armazém não é CQ, Processo ou Terceiros, .F. caso contrário
/*/
//------------------------------------------------------------------
Function ESTAvSegLt(cProduto, cArmazem)
Local aArea    as Array
Local aAreaD4Z as Array
Local cSegLote as Character
Local cLocCQ   as Character
Local cLocProc as Character
Local cLocTerc as Character
Local lRet     as Logical

Default cProduto   := ""
Default cArmazem   := ""

	lRet := .F.

	If FwAliasInDic("D4Z") .And. D4Z->(ColumnPos("D4Z_SEGLOT")) > 0 .And. !Empty(cProduto)

		aArea    := FwGetArea()
		aAreaD4Z := D4Z->(FwGetArea())

		dbSelectArea("D4Z")
		D4Z->(dbSetOrder(1))

		If D4Z->(MsSeek(FWxFilial("D4Z") + cProduto))
			cSegLote := RetFldProd(cProduto, "D4Z_SEGLOT", "D4Z")

			If cSegLote == "1" // "1-Sim"
				cLocCQ   := GetMVNNR("MV_CQ"     , "98") // Armazém do endereçamento CQ
				cLocProc := GetMvNNR("MV_LOCPROC", "99") // Armazém do endereçamento Processo
				cLocTerc := GetMvNNR("MV_ALMTERC", "80") // Armazém do endereçamento Terceiros

				If cArmazem <> cLocCQ .And. cArmazem <> cLocProc .And. cArmazem <> cLocTerc
					lRet := .T.
				EndIf
			EndIf
		EndIf

		FwRestArea(aAreaD4Z)
		FwRestArea(aArea)
	EndIf

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} ESTEndSld
Indica os endereços de estoque com saldo para um produto/lote
em endereço diferente do informado por parâmetro

@type   Static function
@author Jorge Martins / Squad Retail
@since  24/03/2026
@param  cProduto  , character, Código do produto
@param  cLote     , character, Lote do produto
@param  cArmazem  , character, Código do armazém
@param  cEndereco , character, Código do endereço
@return aEnderecos, array, Array com os endereços de estoque disponíveis para o produto/lote
        aEnderecos[1] = Filial do saldo por endereço
        aEnderecos[2] = Código do produto
        aEnderecos[3] = Lote do produto
        aEnderecos[4] = Código do armazém
        aEnderecos[5] = Código do endereço
        aEnderecos[6] = Quantidade disponível nesse endereço
/*/
//------------------------------------------------------------------
Function ESTEndSld(cProduto, cLote, cArmazem, cEndereco)
Local aEnderecos as Array
Local cQuery     as Character
Local cAliasQry  as Character
Local nParam     as Numeric
Local oQuery     as Object

Default cProduto  := ""
Default cLote     := ""
Default cArmazem  := ""
Default cEndereco := ""

	aEnderecos := {}

	cQuery := "SELECT SBF.BF_FILIAL, SBF.BF_PRODUTO, SBF.BF_LOTECTL, SBF.BF_LOCAL, SBF.BF_LOCALIZ, SBF.BF_QUANT"
	cQuery +=  " FROM " + RetSQLName("SBF") + " SBF"
	cQuery += " WHERE SBF.BF_FILIAL = ?"
	cQuery +=   " AND SBF.BF_PRODUTO = ?"
	cQuery +=   " AND SBF.BF_LOTECTL = ?"
	cQuery +=   " AND (SBF.BF_LOCAL <> ? OR SBF.BF_LOCALIZ <> ?)"
	cQuery +=   " AND SBF.D_E_L_E_T_ = ?"

	oQuery := ESTGetQry(cQuery)

	nParam := 1
	oQuery:SetString(nParam++, FwxFilial("SBF"))
	oQuery:SetString(nParam++, cProduto)
	oQuery:SetString(nParam++, cLote)
	oQuery:SetString(nParam++, cArmazem)
	oQuery:SetString(nParam++, cEndereco)
	oQuery:SetString(nParam++, Space(1))

	cAliasQry := GetNextAlias()
	oQuery:OpenAlias(cAliasQry)

	While !(cAliasQry)->(EOF())
		aAdd(aEnderecos, {(cAliasQry)->BF_FILIAL,;
		                  (cAliasQry)->BF_PRODUTO,;
		                  (cAliasQry)->BF_LOTECTL,;
		                  (cAliasQry)->BF_LOCAL,;
		                  (cAliasQry)->BF_LOCALIZ,;
		                  (cAliasQry)->BF_QUANT})
		(cAliasQry)->(DbSkip())
	EndDo

	(cAliasQry)->(DBCloseArea())

Return aEnderecos

//------------------------------------------------------------------
/*/{Protheus.doc} ESTSldDLot
Indica se já existe saldo de outro lote para um produto no endereço 
informado por parâmetro

@type   Static function
@author Jorge Martins / Squad Retail
@since  24/03/2026
@param  cProduto  , character, Código do produto
@param  cLote     , character, Lote do produto
@param  cArmazem  , character, Código do armazém
@param  cEndereco , character, Código do endereço
@return lRet      , logical  , .T. se já existe saldo de outro lote para o produto no endereço, .F. caso contrário
/*/
//------------------------------------------------------------------
Function ESTSldDLot(cProduto, cLote, cArmazem, cEndereco)
Local lRet       as Logical
Local cQuery     as Character
Local cAliasQry  as Character
Local nParam     as Numeric
Local oQuery     as Object

Default cProduto  := ""
Default cLote     := ""
Default cArmazem  := ""
Default cEndereco := ""

	lRet := .F.

	cQuery := "SELECT COUNT(1) QTDLOTES"
	cQuery +=  " FROM " + RetSQLName("SBF") + " SBF"
	cQuery += " WHERE SBF.BF_FILIAL = ?"
	cQuery +=   " AND SBF.BF_PRODUTO = ?"
	cQuery +=   " AND SBF.BF_LOTECTL <> ?"
	cQuery +=   " AND SBF.BF_LOCAL = ?"
	cQuery +=   " AND SBF.BF_LOCALIZ = ?"
	cQuery +=   " AND SBF.D_E_L_E_T_ = ?"

	oQuery := ESTGetQry(cQuery)

	nParam := 1
	oQuery:SetString(nParam++, FwxFilial("SBF"))
	oQuery:SetString(nParam++, cProduto)
	oQuery:SetString(nParam++, cLote)
	oQuery:SetString(nParam++, cArmazem)
	oQuery:SetString(nParam++, cEndereco)
	oQuery:SetString(nParam++, Space(1))

	cAliasQry := GetNextAlias()
	oQuery:OpenAlias(cAliasQry)

	If !(cAliasQry)->(EOF()) .And. (cAliasQry)->QTDLOTES > 0
		lRet := .T.
	EndIf

	(cAliasQry)->(DBCloseArea())

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} ESTGetQry
Obtém o objeto (FwExecStatement) de query preparada para a expressão SQL informada.

@type   Static function
@author SQUAD Entradas
@since  24/03/2026
@param  cQuery    , Character, Expressão SQL
@return oPrepared , Object, Objeto de query preparada
/*/
//------------------------------------------------------------------
Static Function ESTGetQry(cQuery)
	Local oPrepared as Object
	Local nPosPrep  as Numeric
	Local cMD5      as Character
	
	Default cQuery     := ""

	cMD5 := MD5(cQuery)

	If __aPrep == NIL
		__aPrep := {}
	EndIf

	If (nPosPrep := Ascan(__aPrep, {|x| x[2] == cMD5})) == 0
		cQuery := ChangeQuery(cQuery)
		Aadd(__aPrep, {FwExecStatement():New(cQuery), cMD5})
		nPosPrep := Len(__aPrep)
	Endif

	oPrepared := __aPrep[nPosPrep][1]

Return oPrepared

//------------------------------------------------------------------
/*{Protheus.doc} ESTINSPROC()
Faz a Instalação de Procedure sem o Configurador            

@author 
                       
@version P12
@return
*/
//-------------------------------------------------------------------
Function ESTINSPROC (cProcess)
Local cCompany    as character
Local cMsg        as character
//Local cProcess    as character
Local oInstall    as object
Local oMyProcess  as object
Local oRPOProcess as object

cCompany := cEmpAnt

If SPSMigrated() .and. !empty(cProcess)
	cCompany := cEmpAnt

	// Retorna objeto com o status do processo na base de dados
	oMyProcess := EngSPSStatus(cProcess/*processo*/,cCompany/*empresa*/) // código da empresa não é obrigatório - Default = cEmpAnt
	If oMyProcess["status"] == DEF_SPS_NOT_INSTALLED // se não está instalado, possibilita a instalação com o que está no RPO ou TPH
				
		conout(OemToAnsi(I18N(STR0003,{oMyProcess["process"],cCompany}))) //"O processo #1[nn]# nao esta instalado para a empresa #2[xx]#"
		
		oRPOProcess := EngSPSGetProcess(DEF_SPS_FROM_RPO/*origem*/, oMyProcess["process"]/*processo*/, /*empresa*/)
		If oRPOProcess["status"] <> "FALSE"

			conout(OemToAnsi(I18N(STR0004,{oMyProcess["process"],cCompany}))) //"Iniciando a instalação do processo #1[nn]# na empresa #2[xx]# com o pacote do RPO..."
			oInstall := EngSPSInstall(oMyProcess["process"], cCompany, DEF_SPS_FROM_RPO )
			If Empty(oInstall["error"])
				cMsg := OemToAnsi(I18N(STR0005,{oInstall["process"],cCompany,oInstall["idlog"]}))//"Processo instalado corretamente na empresa #2[xx]# - IDLog da opera  o: #3[000001]#"
			Else
				cMsg := OemToAnsi(I18N(STR0006,{oInstall["idlog"],oInstall["error"]}))//"Falha - IDLog da operação: #1[000001]# - Erro: #2[Erro]#"
			EndIf
			conout(cMsg)						
		EndIf
	EndIf
Else	
	AVISO(OemToAnsi(I18N(STR0007)),OemToAnsi(I18N(STR0008))+ cProcess,{'Ok'}, 2 )//"Atenção";"Não foi possivel instalar o processo "
EndIf

Return

/*/{Protheus.doc} EstDark
Função responsavel por retornar se o tema dark esta ativo.
@version 1.0
/*/
//-------------------------------------------------------------------
Function EstDark()
    local lIsDark := .F.
    local cTheme  := ""
   
    cTheme := totvs.framework.css.getNewWebAppTheme()
    lIsDark := iif(!empty(cTheme) .and. cTheme == "DARK", .T., .F.) //Valida se o tema ativo é o dark
Return lIsDark
