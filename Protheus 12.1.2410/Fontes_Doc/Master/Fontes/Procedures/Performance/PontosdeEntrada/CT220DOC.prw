#INCLUDE "RWMAKE.CH"
#Include "PROTHEUS.Ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCT220DOC  บAutor  ณMicrosiga           บ Data ณ  10/01/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEx de rdmake para gerar linhas sempre diferentes no CT2.    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs       ณ   O campo que deverah ser alterado para que a linha gerada บฑฑ
ฑฑบ          ณseja unica deve ser um dos tres: CT2_LOTE, CT2_SBLOTE ou    บฑฑ
ฑฑบ          ณCT2_DOC.                                                    บฑฑ
ฑฑบ          ณ   Este RdMake vai criar uma PROCEDURE no banco que farah   บฑฑ
ฑฑบ          ณos ajustes de geracao de linhas unicas e sera chamado pelo  บฑฑ
ฑฑบ          ณprocesso de Consolidacao Geral de empresas. Apos a execucao บฑฑ
ฑฑบ          ณdo processo a Procedure criada pelo Rdmake e a da Consolida-บฑฑ
ฑฑบ          ณcao serao excluidas do Banco pelo proprio sistema.          บฑฑ
ฑฑบ          ณ   O exemplo abaixo grava no campo CT2_DOC dois caracteres, บฑฑ
ฑฑบ          ณmais a empresa e a dilail origem dos lancamentos.           บฑฑ
ฑฑบ          ณ   A funcao MsParse faz a conversao para os bancos.         บฑฑ
ฑฑบ          ณ   O pto de entrada retorna .T. se executado com sucesso.   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function CT220DOC()
#IFDEF TOP
Local _cEmpAtu    := ParamIxb[1]
Local _cQueryExec
Local _lRet := .F., _cRet

_cQueryExec := "CREATE PROCEDURE CT220DOC_"+_cEmpAtu+CRLF
_cQueryExec +="  (@IN_FILIAL_COR  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_DATA    Char(08),"+CRLF
_cQueryExec +="   @IN_CT2_LINHA   Char(03),"+CRLF
_cQueryExec +="   @IN_CT2_TPSALD  Char(01),"+CRLF
_cQueryExec +="   @IN_CT2_EMPORI  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_FILORI  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_MOEDLC  Char(02),"+CRLF
_cQueryExec +="   @IN_CT2_LOTE    Char(06),"+CRLF
_cQueryExec +="   @IN_CT2_SBLOTE  Char(03),"+CRLF
_cQueryExec +="   @IN_CT2_DOC     Char(06),"+CRLF
_cQueryExec +="   @OUT_CT2_LOTE   Char(06) OutPut,"+CRLF
_cQueryExec +="   @OUT_CT2_SBLOTE Char(06) OutPut,"+CRLF
_cQueryExec +="   @OUT_CT2_DOC    Char(06) OutPut"+CRLF
_cQueryExec +=" )"+CRLF
_cQueryExec +="AS"+CRLF
_cQueryExec +="Declare @cCT2_LOTE     Char(06)"+CRLF
_cQueryExec +="Declare @cCT2_SBLOTE   Char(03)"+CRLF
_cQueryExec +="Declare @cCT2_DOC      Char(06)"+CRLF
_cQueryExec +="BEGIN"+CRLF
_cQueryExec +="   Select @cCT2_LOTE   = @IN_CT2_LOTE"+CRLF
_cQueryExec +="   Select @cCT2_SBLOTE = @IN_CT2_SBLOTE"+CRLF
_cQueryExec +="   Select @cCT2_DOC    = @IN_CT2_DOC"+CRLF
_cQueryExec +="   Select @cCT2_DOC = 'LT'||@IN_CT2_EMPORI||@IN_CT2_FILORI   "+CRLF // monta como quiser
_cQueryExec +="   Select @OUT_CT2_LOTE   = @cCT2_LOTE"+CRLF
_cQueryExec +="   Select @OUT_CT2_SBLOTE = @cCT2_SBLOTE"+CRLF
_cQueryExec +="   Select @OUT_CT2_DOC    = @cCT2_DOC"+CRLF
_cQueryExec +="END"+CRLF

_cQueryExec := MsParse(_cQueryExec,Alltrim(TcGetDB()))
_cRet := TcSqlExec(_cQueryExec)
If _cRet = 0
	_lRet := .T.
Endif
#ENDIF
Return(_lRet)
