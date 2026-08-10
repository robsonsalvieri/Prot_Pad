#INCLUDE "TOTVS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RESTFUL.CH"

Static lNewCtrl  := Nil
Static cUltStmp  := Nil
Static nIndCP    := Nil
Static lCompSA1  := Nil
Static lCompSA2  := Nil
Static lCompC1H  := Nil
Static lAliErp   := Nil
Static lCompar   := Nil
Static nTAMfone  := Nil
Static nTAMEmail := Nil
Static nTAMCompl := Nil

/*/{Protheus.doc} TSIPARTIC
	(Classe que para consula e retorno da mensagem Json )
    @type Class
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Class TSIPARTIC
Data cFinalQuery as String
Data aFilC1H     as String
Data oStatement  as Object
Data cAlias      as String
Data nTotReg     as numeric
Data nSizeMax    as numeric

Method New() Constructor
Method LoadQuery() 
Method JSon()
Method TempTable()
Method FilC1H() 
Method GetJsn()
Method CommitRegs()

EndClass

/*/{Protheus.doc} New
	(Método contrutor da classe TSIPARTIC )
    Fluxo New:
    1º Monta-se a query com LoadQuery()
    2º Instaciar o preparedStatement com LoadQuery() e alimenta a propriedade
    cFinalQuery com a query final já com os parâmetros
	@type Class
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method New(cSourceBr, cTable) Class TSIPARTIC 

If !FwIsInCallStack('RESTGETLISTSERVICE') 

    lNewCtrl := TcCanOpen(RetSqlName('V80')) .And. Findfunction("TSIAtuStamp")
    cUltStmp := iif(lNewCtrl, TsiUltStamp("C1H"),' ')
    nIndCP   := 0
    lCompSA1 := iif(Upper(AllTrim(FWModeAccess("SA1",1)+FWModeAccess("SA1",2)+FWModeAccess("SA1",3))) == 'CCC',.T.,.F.)
    lCompSA2 := iif(Upper(AllTrim(FWModeAccess("SA2",1)+FWModeAccess("SA2",2)+FWModeAccess("SA2",3))) == 'CCC',.T.,.F.)
    lCompC1H := iif(Upper(AllTrim(FWModeAccess("C1H",1)+FWModeAccess("C1H",2)+FWModeAccess("C1H",3))) == 'CCC',.T.,.F.)
    lAliErp  := iif(lNewCtrl,V80->(FieldPos("V80_ALIERP") ) > 0,.F.)
    lCompar  := iif(lNewCtrl, (V80->(FieldPos("V80_COMPAR") ) > 0 .And. lCompSA1  .And. lCompSA2  .And. lCompC1H) ,.F.)

    self:FilC1H(cSourceBr)
    self:nSizeMax := 1000 //Seta limite máximo de execução para ser chamado no TAFA565
    Self:LoadQuery(cTable)
    Self:TempTable()

Endif
    
Return Nil

 /*/{Protheus.doc} LoadQuery
	(Método responsável por montar a query para o preparedstatemen
    nos parâmetros variáveis
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/

Method LoadQuery(cTable) Class TSIPARTIC

Local cDbType   := Upper(Alltrim(TCGetDB()))
Local cConcat   := " "
Local cQuery    := " "
Local cConvSA1  := " "
Local cConvSA2  := " "
Local lTemDKE   := .F. 
Local aBind     := {}

// VerIfica o tipo de concatenação para o banco
If "MSSQL" $ cDbType
	cConcat := "+"
Else
	cConcat := "||"
EndIf

lTemDKE := TableInDic("DKE")

cQuery += "SELECT "    //SA1
cQuery += "SA1.A1_COD CODIGO, "
cQuery += "SA1.A1_LOJA LOJA, "
cQuery += "( 'C' " + cConcat + " SA1.A1_COD " + cConcat + " RTRIM(SA1.A1_LOJA) ) COD_PART, "
cQuery += "SA1.A1_NOME NOME, " 
cQuery += "SA1.A1_CODPAIS COD_PAIS, "

DbSelectArea("SA2")
nIndCP := SA2->(FieldPos("A2_INDCP"))
if nIndCP > 0
    cQuery += "	? INDCP, "
    aadd( aBind, { space(1)	   , .F. } )
endif
SA2->(DbCloseArea())

cQuery += "	? SIMPNAC, "
aadd( aBind, { space(1)	   , .F. } )

cQuery += "	? INDRUR, "
aadd( aBind, { space(1)	   , .F. } )

cQuery += "	? CPFRUR, "
aadd( aBind, { space(1)	   , .F. } )

cQuery += "SA1.A1_CGC CGC, "
cQuery += "SA1.A1_INSCR IE, "

cQuery += " CASE WHEN SA1.A1_EST = ? THEN ? ELSE SA1.A1_COD_MUN END COD_MUN, "
aadd( aBind, { "EX"	    , .F. } )
aadd( aBind, { "99999"  , .F. } )

cQuery += "SA1.A1_SUFRAMA SUFRAMA, "
cQuery += "SA1.A1_END ENDERECO, "
cQuery += "SA1.A1_COMPLEM COMPL, "
cQuery += "SA1.A1_BAIRRO BAIRRO, "
cQuery += "SA1.A1_EST UF, "
cQuery += "SA1.A1_CEP CEP, "
cQuery += "SA1.A1_DDD DDD, "
cQuery += "SA1.A1_TEL FONE, "		
cQuery += "SA1.A1_EMAIL EMAIL, "
cQuery += "CASE WHEN SA1.A1_TIPO <> ? AND SA1.A1_PESSOA = ? THEN ? WHEN SA1.A1_TIPO <> ? "
cQuery += "AND SA1.A1_PESSOA = ? THEN ? WHEN SA1.A1_TIPO = ? THEN ? ELSE ? END TP_PESSOA, "
aadd( aBind, { "X"	    , .F. } )
aadd( aBind, { "F"	    , .F. } )
aadd( aBind, { "1"	    , .F. } )
aadd( aBind, { "X"	    , .F. } )
aadd( aBind, { "J"	    , .F. } )
aadd( aBind, { "2"	    , .F. } )
aadd( aBind, { "X"	    , .F. } )
aadd( aBind, { "3"	    , .F. } )
aadd( aBind, { space(1)	, .F. } )

cQuery += " ? RAMO_ATV, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? INDCPRB, "
aadd( aBind, { "0"          , .F. } )

cQuery += "AI0.AI0_INDPAA EXECPAA, "

cQuery += " ? IND_ASSOC_DESPORT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += "SA1.A1_CONTRIB CONTRIBUINTE, "

cQuery += " ? ISENCAO_IMUNIDADE, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? ESTADO_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? TELEFONE_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? NIF," 
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? FORMA_TRIBUTACAO,"
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? COD_PAIS_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? LOGRAD_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? NR_LOGRAD_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? COMPLEM_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? BAIRRO_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? NOME_CIDADE_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? COD_POSTAL_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? REL_FONTE_PAG_RESID_EXTERIOR, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += " ? INDICATIVO_NIF_EXT, "
aadd( aBind, { space(1)	    , .F. } )

cQuery += "	? TIPO_PESSOA_EXTERIOR, "
aadd( aBind, { space(1)     , .F. } )

If cDbType $ "MSSQL/MSSQL7"
    cConvSA1 := " convert(varchar(23), SA1.S_T_A_M_P_ , 21 ) "
Elseif cDbType $ "ORACLE"
    cConvSA1 := " cast( to_char(SA1.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
Elseif cDbType $ "POSTGRES"
    cConvSA1 := " cast( to_char(SA1.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
Endif

cQuery += cConvSA1 + " STAMP, ? TABELA, SA1.R_E_C_N_O_ RECNO, "
aadd( aBind, { "SA1"        , .F. } )

//Tipo de Pessoa Jurídica (1=ME - Micro Empresa;2=EPP - Empresas de Pequeno Porte;3=MEI - Microempreendedor Individual;4=Não Optante)
cQuery += "	? TPJ "
aadd( aBind, { space(1)     , .F. } )

cQuery += "FROM " + RetSqlName("SA1") + " SA1 "

cQuery += "INNER JOIN " 

cQuery += "(SELECT DISTINCT SFT.FT_CLIEFOR CLIEFOR, SFT.FT_LOJA LOJA, SFT.FT_FILIAL FILIAL "
cQuery += "FROM " + cTable + " SFT "
cQuery += "WHERE " 
cQuery += "(( SFT.FT_CFOP >= ? AND SFT.FT_TIPO IN ( ? ) ) "
cQuery += "OR ( SFT.FT_CFOP <= ? AND SFT.FT_TIPO IN ( ? ) )) ) SFTTEMP "
cQuery += "ON SFTTEMP.FILIAL = ? "
cQuery += "AND SFTTEMP.CLIEFOR = SA1.A1_COD "
cQuery += "AND SFTTEMP.LOJA = SA1.A1_LOJA "

aadd( aBind, { "5"						, .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "4"		   				, .F. } )
aadd( aBind, { { 'B', 'D' }				, .F. } )
aadd( aBind, { xFilial( "SFT" )	    	, .F. } )

cQuery += "LEFT JOIN " + RetSqlName("AI0") + " AI0 ON " //AI0_FILIAL, AI0_CODCLI, AI0_LOJA, R_E_C_N_O_, D_E_L_E_T_
cQuery += "AI0.AI0_FILIAL = SA1.A1_FILIAL AND "
cQuery += "AI0.AI0_CODCLI = SA1.A1_COD AND "
cQuery += "AI0.AI0_LOJA = SA1.A1_LOJA  AND "
cQuery += "AI0.D_E_L_E_T_ = ? "
aadd( aBind, { space(1), .F. } )

cQuery += "WHERE SA1.A1_FILIAL = ? "
aadd( aBind, { xFilial( "SA1" ), .F. } )

//Tratamento abaixo, para ignorar clientes que nao constam na SFT ("sem nota"). Atualmente o cliente Sequoia possui um processo de integracao com muitos clientes que nao
//sao necessarios para a geracao da gia. A cada 15 minutos entravam mais de 2.000 registros que nao sao necessarios e demorava mais de 30 minutos para processa-los, depois processava
//o lote de 500 notas, depois tornava a colocar participantes desnecessarios. Fazendo que a gravaçao de nota ficasse bem lenta por causa dessa volumetria desnecessaria, estavam sendo
//processados apenas 1.000 notas a cada 1 hora, so que a volumetria do cliente eh 10x maior por hora.

cQuery += "AND SA1.D_E_L_E_T_ = ? "
aadd( aBind, { space(1), .F. } )

cQuery += "UNION ALL "

cQuery += "SELECT " //SA2
cQuery += "SA2.A2_COD CODIGO, "
cQuery += "SA2.A2_LOJA LOJA, "
cQuery += "( 'F' " + cConcat + " SA2.A2_COD " + cConcat + " SA2.A2_LOJA ) COD_PART, "
cQuery += "SA2.A2_NOME NOME, "
cQuery += "SA2.A2_CODPAIS COD_PAIS, "
if nIndCP > 0
    cQuery += "SA2.A2_INDCP INDCP, "
endif

cQuery += "SA2.A2_SIMPNAC SIMPNAC, "

cQuery += "SA2.A2_INDRUR INDRUR, "

cQuery += "CASE WHEN SA2.A2_TIPO = ? AND SA2.A2_INDRUR IN (?) AND SA2.A2_EST IN (?) THEN SA2.A2_CPFRUR ELSE ? END CPFRUR, "
aadd( aBind, { "F"	        , .F. } )
aadd( aBind, { {'1','2','3'}, .F. } ) //0=Não é prod.rural;1=Seg.Espec.Geral PF;2=Seg.Espec.Ent.PAA PF;3=Ent.PAA PJ
aadd( aBind, { {'SP','MG'}  , .F. } )
aadd( aBind, { space(1)	    , .F. } )

cQuery += "SA2.A2_CGC CGC, "
cQuery += "SA2.A2_INSCR IE, "

cQuery += "CASE WHEN SA2.A2_EST = ? THEN ? ELSE SA2.A2_COD_MUN END COD_MUN, "
aadd( aBind, { "EX"	        , .F. } )
aadd( aBind, { "99999"	    , .F. } )

cQuery += " ? SUFRAMA, "
aadd( aBind, { space(1), .F. } )

cQuery += "SA2.A2_END " + cConcat + " SA2.A2_EST ENDERECO, " 
cQuery += "SA2.A2_COMPLEM COMPL, "
cQuery += "SA2.A2_BAIRRO BAIRRO, "
cQuery += "SA2.A2_EST UF, "
cQuery += "SA2.A2_CEP CEP, "
cQuery += "SA2.A2_DDD DDD, "
cQuery += "SA2.A2_TEL FONE,	"
cQuery += "SA2.A2_EMAIL EMAIL, "

cQuery += "CASE WHEN SA2.A2_TIPO = ? THEN ? WHEN SA2.A2_TIPO = ? THEN ? WHEN SA2.A2_TIPO = ? THEN ? ELSE ? END TP_PESSOA, "
aadd( aBind, { "F"	        , .F. } )
aadd( aBind, { "1"	        , .F. } )
aadd( aBind, { "J"	        , .F. } )
aadd( aBind, { "2"	        , .F. } )
aadd( aBind, { "X"	        , .F. } )
aadd( aBind, { "3"	        , .F. } )
aadd( aBind, { space(1)     , .F. } )

cQuery += "CASE WHEN SA2.A2_TIPORUR <> ? THEN ? ELSE ? END RAMO_ATV, " //J=Juridico;F=Pessoa Fisica;L=Familiar
aadd( aBind, { space(1)     , .F. } )
aadd( aBind, { "4"	        , .F. } )
aadd( aBind, { space(1)     , .F. } )

cQuery += "CASE WHEN SA2.A2_CPRB = ? THEN ? ELSE SA2.A2_CPRB END INDCPRB, "
aadd( aBind, { "2"          , .F. } )
aadd( aBind, { "0"          , .F. } )

cQuery += "? EXECPAA, "
aadd( aBind, { space(1)     , .F. } )

cQuery += "SA2.A2_DESPORT IND_ASSOC_DESPORT, "
cQuery += "SA2.A2_CONTRIB CONTRIBUINTE, "

if lTemDKE
    cQuery += "DKE.DKE_ISEIMU ISENCAO_IMUNIDADE, "
else
    cQuery += " ? ISENCAO_IMUNIDADE, "
    aadd( aBind, { space(1) , .F. } )
endif

cQuery += "SA2.A2_ESTEX ESTADO_EXT, "
cQuery += "SA2.A2_TELRE TELEFONE_EXT, "
cQuery += "SA2.A2_NIFEX NIF, "
cQuery += "SA2.A2_TRBEX FORMA_TRIBUTACAO, "
cQuery += "SA2.A2_PAISEX COD_PAIS_EXT, "
cQuery += "SA2.A2_LOGEX LOGRAD_EXT, "
cQuery += "SA2.A2_NUMEX NR_LOGRAD_EXT, "
cQuery += "SA2.A2_COMPLR COMPLEM_EXT, "
cQuery += "SA2.A2_BAIEX BAIRRO_EXT, "
cQuery += "SA2.A2_CIDEX NOME_CIDADE_EXT, "
cQuery += "SA2.A2_POSEX COD_POSTAL_EXT, "
cQuery += "SA2.A2_BREEX REL_FONTE_PAG_RESID_EXTERIOR, "

cQuery += "CASE WHEN SA2.A2_MOTNIF = ? AND SA2.A2_NIFEX = ? THEN ? WHEN SA2.A2_MOTNIF = ? AND SA2.A2_NIFEX = ? THEN ? "
cQuery += "WHEN SA2.A2_NIFEX <> ? THEN ? ELSE ? END INDICATIVO_NIF_EXT, "
aadd( aBind, { "1"          , .F. } )
aadd( aBind, { space(1)     , .F. } )
aadd( aBind, { "2"          , .F. } )
aadd( aBind, { "2"          , .F. } )
aadd( aBind, { space(1)     , .F. } )
aadd( aBind, { "3"          , .F. } )
aadd( aBind, { space(1)     , .F. } )
aadd( aBind, { "1"          , .F. } )
aadd( aBind, { space(1)     , .F. } )

if lTemDKE
    cQuery += "DKE.DKE_PEEXTE TIPO_PESSOA_EXTERIOR, "
else
    cQuery += " ? TIPO_PESSOA_EXTERIOR, "
    aadd( aBind, { space(1), .F. } )
endif

If cDbType $ "MSSQL/MSSQL7"
    cConvSA2 := " convert(varchar(23), SA2.S_T_A_M_P_ , 21 ) "
Elseif cDbType $ "ORACLE"
    cConvSA2 := " cast( to_char(SA2.S_T_A_M_P_,'DD.MM.YYYY HH24:MI:SS.FF') AS VARCHAR2(23) ) "
Elseif cDbType $ "POSTGRES"
    cConvSA2 := " cast( to_char(SA2.S_T_A_M_P_,'YYYY-MM-DD HH24:MI:SS.MS') AS VARCHAR(23) ) "
Endif

cQuery += cConvSA2 + " STAMP, "

cQuery += " ? TABELA, "
aadd( aBind, { "SA2", .F. } )

cQuery += "SA2.R_E_C_N_O_ RECNO, "

//1=ME - Micro Empresa;2=EPP - Empresas de Pequeno Porte;3=MEI - Microempreendedor Individual;4=Cooperativa;5=Não optante
cQuery += "SA2.A2_TPJ TPJ " //Tipo de Pessoa Jurídica  ( Nao eh necessario proteger campo ja existente ).

cQuery += "FROM " + RetSqlName("SA2") + " SA2 "

cQuery += "INNER JOIN " 

cQuery += "(SELECT DISTINCT SFT.FT_CLIEFOR CLIEFOR, SFT.FT_LOJA LOJA, SFT.FT_FILIAL FILIAL "
cQuery += "FROM " + cTable + " SFT  "
cQuery += "WHERE " 
cQuery += "(( SFT.FT_CFOP <= ? AND SFT.FT_TIPO IN ( ? ) ) "
cQuery += "OR ( SFT.FT_CFOP >= ? AND SFT.FT_TIPO IN ( ? ) )) ) SFTTEMP "
cQuery += "ON SFTTEMP.FILIAL = ? "
cQuery += "AND SFTTEMP.CLIEFOR = SA2.A2_COD "
cQuery += "AND SFTTEMP.LOJA = SA2.A2_LOJA "

aadd( aBind, { "4"						, .F. } )
aadd( aBind, { {' ','C','I','N','S','P'}, .F. } )
aadd( aBind, { "5"		   				, .F. } )
aadd( aBind, { { 'B', 'D' }				, .F. } )
aadd( aBind, { xFilial( "SFT" )	    	, .F. } )

If lTemDKE
    cQuery += "LEFT JOIN " + RetSqlName("DKE") + " DKE ON " //DKE_FILIAL, DKE_COD, DKE_LOJA, R_E_C_N_O_, D_E_L_E_T_
    cQuery += "DKE.DKE_FILIAL = SA2.A2_FILIAL "
    cQuery += "AND DKE.DKE_COD = SA2.A2_COD "
    cQuery += "AND DKE.DKE_LOJA = SA2.A2_LOJA "
    cQuery += "AND DKE.D_E_L_E_T_ = ? "
    aadd( aBind, { space(1)     , .F. } )
Endif

cQuery += " WHERE SA2.A2_FILIAL = ? "
aadd( aBind, { xFilial( "SA2" )   , .F. } )

//Tratamento abaixo, para ignorar fornecedores que nao constam na SFT ("sem nota"). Atualmente o cliente Sequoia possui um processo de integracao com muitos fornecedores que nao 
//sao necessarios para a geracao da gia. A cada 15 minutos entravam mais de 2.000 registros que nao sao necessarios e demorava mais de 30 minutos para processa-los, depois processava 
//o lote de 500 notas, depois tornava a colocar participantes desnecessarios. Fazendo que a gravaçao de nota ficasse bem lenta por causa dessa volumetria desnecessaria, estavam sendo 
//processados apenas 1.000 notas a cada 1 hora, so que a volumetria do cliente eh 10x maior por hora.

cQuery += " AND SA2.D_E_L_E_T_ = ? "
aadd( aBind, { space(1)   , .F. } )

self:oStatement := FwExecStatement():New( cQuery )
TafSetPrepare(self:oStatement,@aBind)
self:cFinalQuery := self:oStatement:GetFixQuery()


Return

 /*/{Protheus.doc} TempTable(
	(Método responsável montar o objeto Json e alimenta a propriedade self:oJObjTSI
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method TempTable() Class TSIPARTIC

    Self:cAlias := getNextAlias()

    TAFConOut("TSILOG00005: Query de busca do cadastro participantes (Cliente / Fornecedor) [ Início query TSILOG00005 " + TIME() + " ]" + self:cFinalQuery, 1, .F., "TSI" )

    self:oStatement:OpenAlias( Self:cAlias )

    TAFConOut("TSILOG00005: Query de busca do cadastro participantes (Cliente / Fornecedor) [ Fim query TSILOG00005 " + TIME(), 1, .F., "TSI" )

    DbSelectArea(Self:cAlias)
    Count to self:nTotReg //necessario devido controle no CommitRegs

Return

 /*/{Protheus.doc} GetJsn 
	(Método responsável retornar a propriedade self:oJObjTSI
	@author Henrique Pereira      
	@since 08/06/2020 
	@return Nil, nulo, não tem retorno.     
/*/
Method GetJsn() Class TSIPARTIC     
    Local oJObjRet   :=  JsonObject( ):New( )
    Local nPos       := 0
    Local cRegTri    := ''
    Local cSimplNaci := ''

	if nTAMfone == Nil
        nTAMfone := GetSx3Cache("C1H_FONE","X3_TAMANHO")
    endif
	if nTAMEmail == Nil
        nTAMEmail := GetSx3Cache("C1H_EMAIL","X3_TAMANHO")
    endif
	if nTAMCompl == Nil
        nTAMCompl := GetSx3Cache("C1H_COMPL","X3_TAMANHO")
    endif

    cRegTri := ''
    if alltrim( ( self:cAlias )->TABELA ) == 'SA2' .And. !Empty((self:cAlias)->TPJ)
        if (self:cAlias)->TPJ == '1' .Or. (self:cAlias)->TPJ == '2' //1=ME - Micro Empresa;2=EPP - Empresas de Pequeno Porte
            cRegTri := '6' //6=Micro. ou Emp. Pequeno Porte
        elseif (self:cAlias)->TPJ == '3' //3=MEI - Microempreendedor Individual
            cRegTri := '5' //5=Micro. Individual (MEI)
        elseif (self:cAlias)->TPJ == '4' //4=Cooperativa
            cRegTri := '4' //4=Cooperativa
        endif
    endif

    cSimplNaci := ''
    if Alltrim((self:cAlias)->SIMPNAC) == '1' //A2_SIMPNAC (1=Sim;2=Não)
        cSimplNaci := '1' //C1H_SIMPLS 0=Não;1=Sim
    elseif Alltrim((self:cAlias)->SIMPNAC) == '2'
        cSimplNaci := '0' //C1H_SIMPLS 0=Não;1=Sim
    endif

    aFisGetEnd := FisGetEnd( ( self:cAlias )->ENDERECO )
    // Campos da Planilha Layout TAF - T003
    oJObjRet["participantId"]        := alltrim( ( self:cAlias )->COD_PART )                               // 02 COD_PART
    oJObjRet["name"]                 := alltrim( ( self:cAlias )->NOME     )                               // 03 NOME
    oJObjRet["countryCode"]          := if(Empty(alltrim( ( self:cAlias )->COD_PAIS )),"01058", alltrim( ( self:cAlias )->COD_PAIS )) // 04 COD_PAIS
    
    if alltrim( ( self:cAlias )->TP_PESSOA ) == '1'
        oJObjRet["registrationCPF"]  := alltrim( ( self:cAlias )->CGC )                                    // 06 CPF
        if alltrim( ( self:cAlias )->TABELA ) = 'SA2' .and. alltrim( ( self:cAlias )->INDRUR ) != '' .and. alltrim( ( self:cAlias )->INDRUR ) != '0' .and. Alltrim(( self:cAlias )->UF) $ "SP|MG"
            oJObjRet["registrationCNPJ"] := alltrim( ( self:cAlias )->CGC )                                // 05 CNPJ
            oJObjRet["registrationCPF"]  := alltrim( ( self:cAlias )->CPFRUR )                             // 06 CPFRUR
        endif
    elseif alltrim( ( self:cAlias )->TP_PESSOA ) == '2'
        oJObjRet["registrationCNPJ"] := alltrim( ( self:cAlias )->CGC )                                    // 05 CNPJ
    else
        if len(alltrim((self:cAlias)->CGC))>11
            oJObjRet["registrationCNPJ"] := alltrim( ( self:cAlias )->CGC )                                // 05 CNPJ
        else
            oJObjRet["registrationCPF"]  := alltrim( ( self:cAlias )->CGC )                                // 06 CPF
        endif
    endif

    oJObjRet["stateRegistration"]    := StrTran( alltrim( ( self:cAlias )->IE ), '.', '' )                 // 07 IE
    oJObjRet["codeCity"]             := alltrim( ( self:cAlias )->COD_MUN )                                // 08 COD_MUN
    oJObjRet["suframa"]              := StrTran( alltrim( ( self:cAlias )->SUFRAMA ), '.', '' )            // 09 SUFRAMA
    oJObjRet["adress"]               := alltrim( aFisGetEnd[1] )                                           // 11 END
    oJObjRet["numberAdress"]         := alltrim( IIf( !Empty( aFisGetEnd[2]), aFisGetEnd[3], "SN" ) )      // 12 NUM
    oJObjRet["complement" ]          := alltrim( SubStr( ( self:cAlias )->COMPL,1,nTAMCompl) )             // 13 COMPL
    oJObjRet["neighborhood"]         := alltrim( ( self:cAlias )->BAIRRO )                                 // 15 BAIRRO
    oJObjRet["unitFederative"]       := alltrim( ( self:cAlias )->UF     )                                 // 16 UF
    oJObjRet["cep"]                  := alltrim( ( self:cAlias )->CEP    )                                 // 17 CEP
    oJObjRet["ddd"]                  := alltrim( ( self:cAlias )->DDD    )                                 // 18 DDD FONE
    // O tratamento abaixo foi feito devido o tamanho do campo Fone não terem o mesmo tamanho na tabela SA1 e C1H.
    oJObjRet["phoneNumber"]          := alltrim( substr( ( self:cAlias )->FONE, 1,nTAMfone ) )             // 19 FONE
    oJObjRet["email"]                := alltrim( substr( ( self:cAlias )->EMAIL,1,nTAMEmail) )             // 22 EMAIL
    oJObjRet["kindOfPerson"]         := alltrim( ( self:cAlias )->TP_PESSOA )                              // 24 TP_PESSOA
    oJObjRet["activity"]             := alltrim( ( self:cAlias )->RAMO_ATV )                               // 25 RAMO_ATV
    oJObjRet["cprb"]                 := alltrim( ( self:cAlias )->INDCPRB )                                // 41 INDCPRB
    oJObjRet["paa"]                  := alltrim( ( self:cAlias )->EXECPAA )                                // 43 EXECPAA
    oJObjRet["sportsAssociationIndicator"] := alltrim( IIF( ( self:cAlias )->IND_ASSOC_DESPORT =="1","1","2" ) ) // 44 IND_ASSOC_DESPORT
    oJObjRet["ctissCode"]            := alltrim( ( self:cAlias )->CONTRIBUINTE )                           // 45 CONTRIBUINTE
    if nIndCP > 0
        oJObjRet["indcp"]            := alltrim( ( self:cAlias )->INDCP)                                   // 46 INDCP
    endif
    oJObjRet["simpleNational"]       := cSimplNaci
    oJObjRet["codCountryExt"]        := alltrim( ( self:cAlias )->COD_PAIS_EXT )                           // 28 COD_PAIS_EXT
    oJObjRet["addressExt"]           := alltrim( ( self:cAlias )->LOGRAD_EXT )                             // 29 LOGRAD_EXT
    oJObjRet["numberExt"]            := alltrim( ( self:cAlias )->NR_LOGRAD_EXT )                          // 30 NR_LOGRAD_EXT
    oJObjRet["complementExt"]        := alltrim( ( self:cAlias )->COMPLEM_EXT )                            // 31 COMPLEM_EXT
    oJObjRet["district"]             := alltrim( ( self:cAlias )->BAIRRO_EXT )                             // 32 BAIRRO_EXT
    oJObjRet["city"]                 := alltrim( ( self:cAlias )->NOME_CIDADE_EXT )                        // 33 NOME_CIDADE_EXT
    oJObjRet["postalCode"]           := alltrim( ( self:cAlias )->COD_POSTAL_EXT )                         // 34 COD_POSTAL_EXT
    oJObjRet["payingSourceReport"]   := alltrim( ( self:cAlias )->REL_FONTE_PAG_RESID_EXTERIOR )           // 36 REL_FONTE_PAG_RESID_EXTERIOR
    oJObjRet["exemptimmune"]         := alltrim( ( self:cAlias )->ISENCAO_IMUNIDADE)                       // 46 ISENTO_IMUNE
    oJObjRet["state"]                := alltrim( ( self:cAlias )->ESTADO_EXT )                             // 48 ESTADO_EXT
    oJObjRet["foneExt"]              := alltrim( ( self:cAlias )->TELEFONE_EXT )                           // 49 TELEFONE_EXT
    oJObjRet["indicativeNif"]        := alltrim( ( self:cAlias )->INDICATIVO_NIF_EXT )                     // 50 INDICATIVO_NIF_EXT
    oJObjRet["nif"]                  := alltrim( ( self:cAlias )->NIF )                                    // 51 NIF
    oJObjRet["formOftaxation"]       := alltrim( ( self:cAlias )->FORMA_TRIBUTACAO )                       // 52 FORMA_TRIBUTACAO
    oJObjRet["kindOfPersonExt"]      := alltrim( ( self:cAlias )->TIPO_PESSOA_EXTERIOR)                    // 53 TIPO_PESSOA_EXTERIOR
    oJObjRet["code"]                 := ( self:cAlias )->CODIGO                                            // 54 CODIGO DO FOR/CLI
    oJObjRet["store"]                := ( self:cAlias )->LOJA                                              // 55 LOJA DO FOR/CLI
    oJObjRet["stamp"]                := ( self:cAlias )->STAMP
    oJObjRet["taxationRegime"]       := cRegTri

    //Grava layout T003AB - Dependentes
    if (self:cAlias)->TABELA == 'SA2'
        if TcCanOpen(RetSqlName('DHT'))
            DHT->(DbSetOrder(1)) //DHT_FILIAL+DHT_FORN+DHT_LOJA+DHT_COD
            if DHT->(DbSeek(xFilial('DHT')+(self:cAlias)->(CODIGO+LOJA)) )
                oJObjRet['dependent'] := {}
                while DHT->(!eof()) .and. xFilial('DHT')+DHT->(DHT_FORN+DHT_LOJA) == xFilial('SA2')+(self:cAlias)->(CODIGO+LOJA)
                    aadd( oJObjRet['dependent'], JsonObject():New() )
                    nPos := len( oJObjRet['dependent'] )
                                                            
                    oJObjRet['dependent'][nPos]['dependentCode']           := DHT->DHT_COD
                    oJObjRet['dependent'][nPos]['document']                := DHT->DHT_CPF
                    oJObjRet['dependent'][nPos]['name']                    := alltrim(DHT->DHT_NOME)
                    oJObjRet['dependent'][nPos]['dependencyRelationship']  := DHT->DHT_RELACA
                    oJObjRet['dependent'][nPos]['descriptionDependency']   := ''
                    DHT->(DbSkip())
                enddo
            endif
        endif
    endif    

Return oJObjRet

 /*/{Protheus.doc} FilC1H
	(Método responsável por montar o conteúdo da filial da C1H
	@author Henrique Pereira
	@since 08/06/2020
	@return Nil, nulo, não tem retorno.
/*/
Method FilC1H(cSourceBr) Class TSIPARTIC        
    self:aFilC1H := TafTSIFil(cSourceBr, 'C1H')       
Return


/*/{Protheus.doc} CommitRegs
    (Método responsável por realizar a gravação dos dados)
    @author user
    @since 26/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    /*/
Method CommitRegs(oHash, cUStamp, aREGxV80 ) Class TSIPARTIC  
    Local nReg      := 0
    Local oJObjRet  := Nil

    Default cUStamp  := ''
    Default aREGxV80 := {}
    
    oJObjRet := JsonObject( ):New( )
    oJObjRet['participants'] := { }
    
    (Self:cAlias)->(dbGoTop())
    while (Self:cAlias)->(!EOF())
        nReg ++
        
        aadd(oJObjRet['participants'], Self:GetJsn())
        
        //Verifico se atingiu o limite de registros por array ou se o registro processado é igual ao ultimo da temp table
        if nReg == self:nSizeMax .or. (Self:cAlias)->(RECNO()) == Self:nTotReg

            TAFConOut("TSILOG00024 Participantes (Cliente / Fornecedor) "+cValtoChar((Self:cAlias)->(RECNO()))+" de "+cValToChar(Self:nTotReg))

            WsTSIProc( oJObjRet, .T., HashPARTIC(), @cUStamp, aREGxV80 )

            ASIZE(oJObjRet['participants'],0)

            nReg := 0
        endif

        (Self:cAlias)->(dbSkip())
    enddo

    FreeObj(oJObjRet)
    if self:oStatement != Nil
        freeobj(self:oStatement)
        self:oStatement := Nil
    endif

Return
