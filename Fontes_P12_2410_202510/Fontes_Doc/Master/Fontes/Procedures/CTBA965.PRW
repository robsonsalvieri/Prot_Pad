#INCLUDE "PROTHEUS.CH"
#INCLUDE "CTBA965.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} CTBA965
Executa a procedure da API backoffice.accountingclosing.checkbalance.data.protheus
do projeto de Fechamento contábil                         

@author TOTVS
@since 07/01/2024
@obs	 
*/
//-------------------------------------------------------------------  
Function CTBA965(cDatIni as Character, cDatFin as Character, cCurrency as Character, cCodUUID as Character, lMultiFil as Logical, cTpSald as Character)
    Local lCusto    := CtbMovSaldo("CTT")
    Local lItem		:= CtbMovSaldo("CTD")
    Local lCLVL		:= CtbMovSaldo("CTH")
    Local cCTB965   := IIF(FindFunction("GetSPName"), GetSPName("CTB965","29"), "CTB965")

    DEFAULT lMultiFil := .T.
    DEFAULT cTpSald := '*'

    C965PrcCQA()

    If ExistProc(cCTB965, EngSPS29Signature()) 
        TCSPEXEC( xProcedures(cCTB965),;
                    cFilAnt,;
                    Iif(lCusto,'1','0'),;
                    Iif(lItem,'1','0'),;
                    Iif(lClVl,'1','0'),;            
                    cDatIni,;
                    cDatFin,;
                    IIf(cCurrency=="ALL","0","1"),;               // Moeda específica
                    IIf(cCurrency=="ALL"," ",cCurrency),;
                    cTpSald,;               // Tipo de saldo
                    cCodUUID,; 
                    IIf(lMultiFil,"1","0"),;
                    CTBInTrans() )
    EndIf
    
Return

//-------------------------------------------------------------------
/*{Protheus.doc} EngSP29Signature
Identifica a seqUencia de controle do fonte ADVPL com a     
stored procedure, qualquer alteracao que envolva diretamente
a stored procedure a variavel sera incrementada.            
Procedure CTB965                                        

@author TOTVS
@since 07/01/2024
@return  IdProc
@obs	 
*/
//-------------------------------------------------------------------  
Function EngSPS29Signature()    
Return '002'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBInTrans
Indica se está ou não em transação, esta função é para simplicação
para retorna:
0 - Indica NÃO ESTAR em transação 
1 - Indica ESTAR em transação

@author TOTVS
@since 07/01/2024
@version 12
@param
/*/
//-------------------------------------------------------------------
Static Function CTBInTrans
Return IIf(InTransAct(),'1','0')

//-------------------------------------------------------------------
/*/{Protheus.doc} EngPre29Compile
Processo 29 - Divergência de saldos fechamento contábil
Função executada antes da compilação da procedure. ('Pre-Compile')
Cria a tabela temporária do processo
IMPORTANTE: 
- Esse tipo de função deverá ser desenvolvida pelas áreas donas dos processos.
- Essas funções não podem ter interface alguma, nem interação com usuário
- Todo e qualquer erro retornado deverá ser armazenado na variável "cError" que
  é enviada por referência.

@author TOTVS
@since 07/01/2024
@version 12
/*/
//-------------------------------------------------------------------
Function EngPre29Compile(cProcesso as character, cEmpresa as character, cError as character)
  Local cNomeTab As Character 
  Local aCampos  As Array 
  Local lRet     As Logical  

  cNomeTab := "0_SP"
  lRet     := .T.
  
  If AliasInDic("QLJ")
    aCampos  := GetTRZStru()

    If TcCanOpen("TRZ"+cEmpresa+cNomeTab)
      TcDelFile("TRZ"+cEmpresa+cNomeTab)
    EndIf

    EngSPSWorkTable("","TRZ"+cEmpresa+cNomeTab,aCampos,.T.)
	Else
    cError := STR0001//"Seu ambiente ainda não possui a tabela QLJ em seu dicionário de dados, atualize seu ambiente executando o UPDDISTR"
    lRet := .F.
  EndIf

Return lRet

/*/{Protheus.doc} EngPos29Compile
Funções executadas após a compilação da procedure pela MSParse. ('Pos-Compile')
Faz ajustes no código já adaptado ao tipo de banco em uso. Esses ajustes só
podem ser realizados "após" a MSParse traduzir o script original para a linguagem
do banco em uso.
Neste caso se trata do pacote 16 - MATXFUNB envolvendo a funcao CALCEST()
IMPORTANTE:
- Essa função não podem ter interface alguma, nem interação com usuário.
- Todo e qualquer erro retornado deverá ser armazenado na variável "cError" que
  é enviada por referência.

@author TOTVS
@since 12/08/2025
@version 12
/*/
Function EngPos29Compile(cProcesso as character, cEmpresa as character, cProcName as character, cLocalDB as character, cBuffer as character, cError as character)
  If cProcName == "CTB965E"  
    cBuffer := StrTran(cBuffer, "CUR_CTCDEL CURSOR FOR", C965SubPrc())
    cBuffer := StrTran(cBuffer, "DECLARE CUR_CTCDEL insensitive  CURSOR FOR", C965SubPrc())
    cBuffer := StrTran(cBuffer, "CURSOR CUR_CTCDEL IS", C965SubPrc())
    cBuffer := StrTran(cBuffer, "_MOV_DB", "CASE WHEN CT2_DC IN ('1','3') THEN CT2_VALOR ELSE 0 END MOV_DB")
    cBuffer := StrTran(cBuffer, "_MOV_CR", "CASE WHEN CT2_DC IN ('2','3') THEN CT2_VALOR ELSE 0 END MOV_CR")
    cBuffer := StrTran(cBuffer, "_MOV_DG", "CASE WHEN CT2_DC IN ('1','2','3') THEN CT2_VALOR ELSE 0 END MOV_DG")
  EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} EngSPS29Delete
Função executada durante a desinstalação do processo ('On Uninstall')
Faz a exclusão das tabelas da classe "TR". Essas tabelas recebem nomes distintos 
e são usadas apenas por alguns processos.

IMPORTANTE: 
- Esse tipo de função deverá ser desenvolvida pelas áreas donas dos processos.
- Essas funções não podem ter interface alguma, nem interação com usuário.
- Todo e qualquer erro retornado deverá ser armazenado na variável "cError" que
  é enviada por referência.

@return cAssinatura
@author  TOTVS
@since   07/01/2024
@version 12
/*/
//-------------------------------------------------------------------
Function EngSPS29Delete(cProcesso as character, cEmpresa as character, cError as character)
Local cNomeTab   as character

	cNomeTab   := "0_SP"

	If TcCanOpen("TRZ"+cEmpresa+cNomeTab)
		TcDelFile("TRZ"+cEmpresa+cNomeTab)
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetTRCStru
Retorna estrutura de campos para o arquivo temporário TRX 

@author TOTVS
@since 07/01/2024
@version 12
@param
/*/
//-------------------------------------------------------------------
Function GetTRZStru()
Local aCampos  := {}
Local nSizeFil := 2

//-- Atualiza o conteúdo da filial
If FindFunction("FWSizeFilial")
	nSizeFil := FWSizeFilial()
EndIf

AADD(aCampos,{"TRZ_FILIAL","C", nSizeFil, 0 })
AADD(aCampos,{"TRZ_TABLE" ,"C", 3       , 0 })
AADD(aCampos,{"TRZ_UUID"  ,"C", TamSX3("QLJ_UUID")[1], 0 })

Return (aCampos)

/*/{Protheus.doc} C965SetFil
  Grava as filiais do usuário na tabela TRZ

  @type function
  @author totvs
  @since 07/01/2024
  @return cBranchiesCondition, condiciopnais de filiais para query
/*/
Function C965SetFil(cTable as Character, cCodUUID as Character)
Local nI := 0 as Numeric
Local aBranches    := {}
Local lSharedTable := .F.
Local cCodFilGrv   := ""

Default cTable   := ""
Default cCodUUID := ""

C965ProfUsr(@aBranches)

If ValType(cTable) == "C" .And. !Empty(cTable)
  lSharedTable := FWModeAccess(cTable, 1) == "C" .And.; 
                  FWModeAccess(cTable, 2) == "C" .And.;
                  FWModeAccess(cTable, 3) == "C"   

  If !lSharedTable .And. Len(aBranches) > 1  
    For nI := 1 To Len(aBranches)
      cCodFilGrv := FwXFilial(cTable, aBranches[nI])
      C965GrvFil(cCodFilGrv, cTable, cCodUUID)          
    Next              
  Else
    cCodFilGrv := FwXFilial(cTable, cFilAnt)
    C965GrvFil(cCodFilGrv, cTable, cCodUUID)     
  EndIf

EndIf

return

/*/{Protheus.doc} C965GrvFil
  Grava as filiais do usuário na tabela TRZ

  @type function
  @author totvs
  @since 07/01/2024
  @return cBranchiesCondition, condiciopnais de filiais para query
/*/
Static Function C965GrvFil(cCodFil as Character, cTable as Character, cCodUUID as Character)
Local cTableTmp  := "TRZ"+cEmpAnt+"0_SP"
Local cQryInsert := ""

DEFAULT cCodFil  := ""
DEFAULT cTable   := "" 
DEFAULT cCodUUID := ""

cQryInsert := "INSERT INTO "+cTableTmp+" (TRZ_FILIAL, TRZ_TABLE, TRZ_UUID) values('"+cCodFil+"','"+cTable+"','"+cCodUUID+"')"

If TcSqlExec(cQryInsert) <> 0
  UserException(STR0002 + CRLF + STR0003 + CRLF + TCSqlError() ) //"Erro na preparacao do arquivo de trabalho TRZ." //"Efetuar o Reprocessamento dos saldos"
EndIf

return

/*/{Protheus.doc} C965Prof
  Busca o profile do usuário

  @type function
  @author totvs
  @since 07/01/2024
  @return cBranchiesCondition, condiciopnais de filiais para query
/*/
Static Function C965ProfUsr(aBranches)

Local oProfile  := FWProfile():New() as Object
Local cUserPrf  := RetCodUsr() as Character

DEFAULT aBranches := {}

oProfile:SetUser(cUserPrf) 
oProfile:SetProgram("CTBA960")
oProfile:SetTask("CONFIG") 
oProfile:SetType("FECHAMENT")

If oProfile:Exists()
    oProfile:Load()    
    aBranches := aClone(oProfile:GetProfile())
EndIf

oProfile:Destroy()

return

/*/{Protheus.doc} C965DelFil
  Busca o profile do usuário

  @type function
  @author totvs
  @since 07/01/2024
  @return cBranchiesCondition, condiciopnais de filiais para query
/*/
Function C965DelFil(cCodUUID as Character)
Local cTableTmp  := "TRZ"+cEmpAnt+"0_SP"
Local cQryDelete := ""

cQryDelete := "DELETE FROM "+cTableTmp+" WHERE TRZ_UUID = '"+cCodUUID+"'"

If TcSqlExec(cQryDelete) <> 0
  UserException(STR0004 + CRLF + TCSqlError() ) //"Erro na deleção do arquivo de trabalho TRZ."
EndIf

return

/*/{Protheus.doc} C965PrcCQA
  Se tiver CQA pendente de processamento, forço a atualização via CTBA193
  
  @type function
  @author totvs
  @since 05/08/2025
  @return cBranchiesCondition, condiciopnais de filiais para query
/*/
Static Function C965PrcCQA()
  If IsCtbJob() .And. C965VldCQA()    
    StartJob("C965JOB193",GetEnvServer(),.T.,cEmpAnt,cFilAnt)    
  EndIf
Return 

/*/{Protheus.doc} C965VldCQA
  Verifica se existe CQA pendente de atualização na fila
  
  @type function
  @author totvs
  @since 05/08/2025
  @return cBranchiesCondition, condiciopnais de filiais para query
/*/
Static Function C965VldCQA()
  Local cQuery  := ""
  Local nTamFil := FWSizeFilial()	
  Local lRet    := .F.
  Local oQryCQA := Nil

  cQuery := "SELECT COUNT(1) QTD_CQA "
  cQuery += " FROM "+RetSQLName("CQA")
  cQuery += " WHERE CQA_FILIAL BETWEEN ? AND ? "
  cQuery += " AND D_E_L_E_T_ = ?"			

  oQryCQA := FwExecStatement():New(cQuery)		
  oQryCQA:SetString(1, Space(nTamFil))
  oQryCQA:SetString(2, Replicate('z', nTamFil))
  oQryCQA:SetString(3, Space(1))

  lRet := oQryCQA:ExecScalar('QTD_CQA') > 0 

  oQryCQA:Destroy()
Return lRet

/*/{Protheus.doc} C965JOB193
  Job para chamar o CTBA193 de uma outra thread, pois a thread da requisição (MPP)
  aparentemente, em alguns casos, fica ativa e não solta o lockbyname da tabela QLG
  QLG_CHVLCK
  
  @type function
  @author totvs
  @since 08/08/2025
  @return cBranchiesCondition, condiciopnais de filiais para query
/*/
Function C965JOB193(cEmpAnt, cFilAnt)
  RpcSetType(3)
  RpcClearEnv()  
  RpcSetEnv( cEmpAnt, cFilAnt,,,'CTB','CTB193')  

  CTBA193()
  
  RpcClearEnv()
Return 

/*/{Protheus.doc} C965SubPrc
  Retorna trecho da procedure para evitar erro no Parse
  
  @type function
  @author totvs
  @since 12/08/2025
  @return cQuery
/*/
Static Function C965SubPrc()
  Local cQuery    := ""
  Local cTableTmp := "TRZ"+cEmpAnt+"0_SP"
  Local cSGBD     := AllTrim(TcGetDb())
  Local cPrefVar  := ""

  If "SQL"$cSGBD
    cQuery := " DECLARE CUR_CTCDEL insensitive  CURSOR FOR "+CRLF
    cPrefVar := "@"
  ElseIf cSGBD=="POSTGRES"
    cQuery := " CUR_CTCDEL CURSOR FOR "+CRLF
  ElseIf cSGBD=="ORACLE"    
    cQuery := " CURSOR CUR_CTCDEL IS "+CRLF
  EndIf

  cQuery += " WITH CT2TRB AS ( "+CRLF+;
              " SELECT CT2.CT2_FILIAL, CT2.CT2_LOTE, CT2.CT2_SBLOTE, CT2.CT2_DOC, CT2.CT2_DATA, CT2.CT2_MOEDLC, CT2.CT2_TPSALD, CT2.CT2_DC,"+CRLF+;
                " COALESCE(CT2.CT2_VALOR, 0) AS CT2_VALOR,"+CRLF+;
                " COALESCE(CTC.CTC_DEBITO, 0) AS CTC_DEBITO,"+CRLF+;
                " COALESCE(CTC.CTC_CREDIT, 0) AS CTC_CREDIT,"+CRLF+;
                " COALESCE(CTC.CTC_DIG, 0) AS CTC_DIG"+CRLF+;
              " FROM "+RetSQLName("CT2")+" CT2"+CRLF+;
              " LEFT JOIN "+RetSQLName("CTC")+" CTC"+CRLF+;
                "  ON CTC.CTC_FILIAL  = CT2.CT2_FILIAL"+CRLF+;
                " AND CTC.CTC_DATA   = CT2.CT2_DATA"+CRLF+;
                " AND CTC.CTC_LOTE   = CT2.CT2_LOTE"+CRLF+;
                " AND CTC.CTC_SBLOTE = CT2.CT2_SBLOTE"+CRLF+;
                " AND CTC.CTC_DOC    = CT2.CT2_DOC"+CRLF+;
                " AND CTC.CTC_MOEDA  = CT2.CT2_MOEDLC"+CRLF+;
                " AND CTC.CTC_TPSALD = CT2.CT2_TPSALD"+CRLF+;
                " AND CTC.D_E_L_E_T_ = ' '"+CRLF+;
              " WHERE (("+cPrefVar+"IN_LMULTIFIL = '0' AND CT2_FILIAL = "+cPrefVar+"IN_FILIAL) OR (CT2_FILIAL IN(SELECT TRZ_FILIAL FROM "+cTableTmp+" WHERE TRZ_TABLE = 'CT2' AND TRZ_UUID = "+cPrefVar+"IN_UUID))) AND"+CRLF+;
                    " CT2_DATA BETWEEN "+cPrefVar+"IN_DATADE AND "+cPrefVar+"IN_DATAATE AND"+CRLF+;
                    " ((CT2_MOEDLC = "+cPrefVar+"IN_MOEDA AND "+cPrefVar+"IN_LMOEDAESP = '1') OR "+cPrefVar+"IN_LMOEDAESP = '0') AND"+CRLF+;
                    " CT2.D_E_L_E_T_ = ' ')"
Return cQuery
