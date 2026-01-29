#INCLUDE "PROTHEUS.CH"
#INCLUDE "RUP_JURI.CH"

Static _lJDepExec   := .F. // Indica se já foi executada atualização para o grupo de empresas
Static _cEmpJDept   := ""

//-------------------------------------------------------------------
/*{Protheus.doc} RUP_JURI
Função para compatibilização do release incremental. 
Esta função é relativa ao módulo Juridico.

@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release del chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA

@Author Wellington Coelho
@since 03/03/2015
@version P12
*/
//-------------------------------------------------------------------
Function RUP_JURI( cVersion, cMode, cRelStart, cRelFinish, cLocaliz)
Local aSX3        := {}
Local aSX3Old     := {}
Local aSX3Estr    := {"X3_ARQUIVO","X3_CAMPO","X3_RELACAO","X3_WHEN","X3_INIBRW"}
Local aNZ6Dados   := {}
Local aNZ6Estr    := {"NZ6_FILIAL","NZ6_TIPOAS","NZ6_CPARAM","NZ6_CONTEU","NZ6_TIPO"}
Local aNUZDados   := {}
Local aNUZEstr    := {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local aNVHDados   := {}
Local aNVHEstr    := {"NVH_FILIAL", "NVH_COD", "NVH_DESC", "NVH_TABELA", "NVH_CAMPO", "NVH_WHERE", "NVH_PROPRI", "NVH_F3DIF", "NVH_F3CONS", "NVH_F3MULT", "NVH_TPPESQ"}
Local aStruct     := {}
Local nRegs       := 0
Local nAux        := 0
Local nI          := 0
Local cUser       := ""
Local cGrupo      := ""

	#IFNDEF TOP
		Return Nil
	#ENDIF

	If _cEmpJDept == cEmpAnt //Controle para permitir a atualização de todas as empresas
		_lJDepExec := .T.
	Else
		//Reinicia as variáveis estáticas a cada mudança de empresa, para alteração de dicionário de dados
		_lJDepExec  := .F.
		_cEmpJDept  := cEmpAnt
	EndIf

	//-------------------------------------------------------------------
	//Atualizações necessárias até release V12.1.3
	//-------------------------------------------------------------------
	If cRelStart < "003" .AND. cRelFinish >= "003"

		//            {        "X3_ARQUIVO"   ,"X3_CAMPO"   , "X3_RELACAO"                                                                               ,"X3_WHEN", "X3_INIBRW"}
		//NSZ
		/*Novo*/  aAdd(aSX3,   {Alltrim('NSZ'), 'NSZ_DCOMAR',"IF(!INCLUI,JUR183CCOM(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CCOMAR')),'')",""       ,"JUR183CCOM(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CCOMAR'))"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IF(!INCLUI,JURA95CCOM(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CCOMAR')),'')","XXXXXXX","JURA95CCOM(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CCOMAR'))"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NSZ'), 'NSZ_DLOC2N',"IF(!INCLUI,JUR183CL2N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC2N')),'')",""       ,"JUR183CL2N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC2N'))"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IF(!INCLUI,JURA95CL2N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC2N')),'')","XXXXXXX","JURA95CL2N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC2N'))"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NSZ'), 'NSZ_DLOC3N',"IF(!INCLUI,JUR183CL3N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC3N')),'')",""       ,"JUR183CL3N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC3N'))"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IF(!INCLUI,JURA95CL3N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC3N')),'')","XXXXXXX","JURA95CL3N(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CLOC3N'))"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NSZ'), 'NSZ_DNATUR',"IF(!INCLUI,JUR183CNAT(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CNATUR')),'')",""       ,"JUR183CNAT(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CNATUR'))"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IF(!INCLUI,JURA95CNAT(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CNATUR')),'')","XXXXXXX","JURA95CNAT(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CNATUR'))"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NSZ'), 'NSZ_DTIPAC',"IF(!INCLUI,JUR183CTPA(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CTIPAC')),'')",""       ,"JUR183CTPA(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CTIPAC'))"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IF(!INCLUI,JURA95CTPA(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CTIPAC')),'')","XXXXXXX","JURA95CTPA(POSICIONE('NUQ',2,XFILIAL('NUQ')+NSZ->NSZ_COD+'1','NUQ_CTIPAC'))"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NSZ'), 'NSZ_CONMES',"IF(!INCLUI,JUR183MES(),'')",""       ,"JUR183MES()"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IF(!INCLUI,JURA95MES(),'')","XXXXXXX","JURA95MES()"})

		//NT9
		//            {        "X3_ARQUIVO"   ,"X3_CAMPO"   , "X3_RELACAO"	,"X3_WHEN"		, "X3_INIBRW"	}
		/*Novo*/  aAdd(aSX3,   {Alltrim('NT9'), 'NT9_CEMPCL',''    			,"J105NT9Cli()"	,""				})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX','XXXX'			,"J095NT9Cli()"	,"XXXX"			})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NT9'), 'NT9_LOJACL',''    			,"J105NT9Cli()"	,""				})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX','XXXX'			,"J095NT9Cli()"	,"XXXX"			})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NT9'), 'NT9_CFORNE',''    			,"J105NT9For()",""				})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX','XXXX'			,"J095NT9For()","XXXX"			})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NT9'), 'NT9_LFORNE',''    			,"J105NT9For()",""				})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX','XXXX'			,"J095NT9For()","XXXX"			})

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	//-------------------------------------------------------------------
	//Atualizações necessárias para o release V12.1.4
	//-------------------------------------------------------------------
	If cRelStart < "004" .AND. cRelFinish >= "004"

		//-------------------------------------------------------------------
		//Atualização de Ordem da NT9
		//-------------------------------------------------------------------
		aSX3     	:= {}
		aSX3Old		:= {}
		aSX3Estr	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}

		Aadd(aSx3, {"NT9", "NT9_CAJURI" , "02"} )
		Aadd(aSx3, {"NT9", "NT9_COD" 	, "03"} )
		Aadd(aSx3, {"NT9", "NT9_ENTIDA" , "04"} )
		Aadd(aSx3, {"NT9", "NT9_CODENT" , "05"} )
		Aadd(aSx3, {"NT9", "NT9_TIPOCL" , "06"} )
		Aadd(aSx3, {"NT9", "NT9_PRINCI" , "07"} )
		Aadd(aSx3, {"NT9", "NT9_TFORNE" , "08"} )
		Aadd(aSx3, {"NT9", "NT9_TIPOEN" , "09"} )
		Aadd(aSx3, {"NT9", "NT9_ISENTO" , "10"} )
		Aadd(aSx3, {"NT9", "NT9_CTPENV" , "11"} )
		Aadd(aSx3, {"NT9", "NT9_DTPENV" , "12"} )
		Aadd(aSx3, {"NT9", "NT9_CEMPCL" , "13"} )
		Aadd(aSx3, {"NT9", "NT9_LOJACL" , "14"} )
		Aadd(aSx3, {"NT9", "NT9_NOME"   , "15"} )
		Aadd(aSx3, {"NT9", "NT9_CFORNE" , "16"} )
		Aadd(aSx3, {"NT9", "NT9_LFORNE" , "17"} )
		Aadd(aSx3, {"NT9", "NT9_RESP"   , "18"} )
		Aadd(aSx3, {"NT9", "NT9_DTNASC" , "19"} )
		Aadd(aSx3, {"NT9", "NT9_TIPOP"  , "20"} )
		Aadd(aSx3, {"NT9", "NT9_CGC"    , "21"} )
		Aadd(aSx3, {"NT9", "NT9_DTADM"  , "22"} )
		Aadd(aSx3, {"NT9", "NT9_DTDEMI" , "23"} )
		Aadd(aSx3, {"NT9", "NT9_CADVPC" , "24"} )
		Aadd(aSx3, {"NT9", "NT9_DADVPC" , "25"} )
		Aadd(aSx3, {"NT9", "NT9_NUMAP"  , "26"} )
		Aadd(aSx3, {"NT9", "NT9_DDD"    , "27"} )
		Aadd(aSx3, {"NT9", "NT9_TELEFO" , "28"} )
		Aadd(aSx3, {"NT9", "NT9_EMAIL"  , "29"} )
		Aadd(aSx3, {"NT9", "NT9_CTPS"   , "30"} )
		Aadd(aSx3, {"NT9", "NT9_SERIE"  , "31"} )
		Aadd(aSx3, {"NT9", "NT9_PIS"    , "32"} )
		Aadd(aSx3, {"NT9", "NT9_CCRGDP" , "34"} )
		Aadd(aSx3, {"NT9", "NT9_DCRGDP" , "35"} )
		Aadd(aSx3, {"NT9", "NT9_CFUNDP" , "36"} )
		Aadd(aSx3, {"NT9", "NT9_DFUNDP" , "37"} )
		Aadd(aSx3, {"NT9", "NT9_CLTDP"  , "38"} )
		Aadd(aSx3, {"NT9", "NT9_DLTDP"  , "39"} )
		Aadd(aSx3, {"NT9", "NT9_OBSERV" , "40"} )
		Aadd(aSx3, {"NT9", "NT9_CCGECL" , "41"} )
		Aadd(aSx3, {"NT9", "NT9_DCGECL" , "42"} )
		Aadd(aSx3, {"NT9", "NT9_CFUNCL" , "43"} )
		Aadd(aSx3, {"NT9", "NT9_DFUNCL" , "44"} )
		Aadd(aSx3, {"NT9", "NT9_CLOCTR" , "45"} )
		Aadd(aSx3, {"NT9", "NT9_DLOCTR" , "46"} )
		Aadd(aSx3, {"NT9", "NT9_DDDCLI" , "47"} )
		Aadd(aSx3, {"NT9", "NT9_TELECL" , "48"} )
		Aadd(aSx3, {"NT9", "NT9_ENDECL" , "49"} )
		Aadd(aSx3, {"NT9", "NT9_BAIRRO" , "50"} )
		Aadd(aSx3, {"NT9", "NT9_ESTADO" , "51"} )
		Aadd(aSx3, {"NT9", "NT9_CMUNIC" , "52"} )
		Aadd(aSx3, {"NT9", "NT9_DMUNIC" , "53"} )
		Aadd(aSx3, {"NT9", "NT9_CEP"    , "54"} )
		Aadd(aSx3, {"NT9", "NT9_EMAICL" , "55"} )
		Aadd(aSx3, {"NT9", "NT9_CNOMEA" , "56"} )
		Aadd(aSx3, {"NT9", "NT9_CNOMEP" , "57"} )
		Aadd(aSx3, {"NT9", "NT9_DTSAID" , "58"} )
		Aadd(aSx3, {"NT9", "NT9_CNOMET" , "59"} )
		Aadd(aSx3, {"NT9", "NT9_RG"     , "60"} )
		Aadd(aSx3, {"NT9", "NT9_INSCR"  , "61"} )
		Aadd(aSx3, {"NT9", "NT9_INSCRM" , "62"} )
		Aadd(aSx3, {"NT9", "NT9_NIRE"   , "63"} )
		Aadd(aSx3, {"NT9", "NT9_CNACIO" , "64"} )
		Aadd(aSx3, {"NT9", "NT9_DNACIO" , "65"} )
		Aadd(aSx3, {"NT9", "NT9_CESTCV" , "66"} )
		Aadd(aSx3, {"NT9", "NT9_DESTCV" , "67"} )
		Aadd(aSx3, {"NT9", "NT9_CNEGOC" , "68"} )
		Aadd(aSx3, {"NT9", "NT9_DNEGOC" , "69"} )
		Aadd(aSx3, {"NT9", "NT9_DATA"   , "70"} )
		Aadd(aSx3, {"NT9", "NT9_CMOEDA" , "71"} )
		Aadd(aSx3, {"NT9", "NT9_DMOEDA" , "72"} )
		Aadd(aSx3, {"NT9", "NT9_PRECO"  , "73"} )
		Aadd(aSx3, {"NT9", "NT9_QTPARC" , "74"} )
		Aadd(aSx3, {"NT9", "NT9_DTENTR" , "75"} )
		Aadd(aSx3, {"NT9", "NT9_CSITUA" , "76"} )
		Aadd(aSx3, {"NT9", "NT9_DSITUA" , "77"} )
		Aadd(aSx3, {"NT9", "NT9_PERCAC" , "78"} )
		Aadd(aSx3, {"NT9", "NT9_OAB"    , "79"} )
		Aadd(aSx3, {"NT9", "NT9_ATOENT" , "80"} )
		Aadd(aSx3, {"NT9", "NT9_ATOSAI" , "81"} )
		Aadd(aSx3, {"NT9", "NT9_TIPOQ"  , "82"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualização inicializador padrão dos campos NSU_CFORNE e NSU_LFORNE
		//-------------------------------------------------------------------
		aSX3     	:= {}
		aSX3Old		:= {}
		aSX3Estr	:= {"X3_ARQUIVO","X3_CAMPO","X3_RELACAO"}

		//Case 1
		/*Novo*/  aAdd(aSX3,   {Alltrim('NSU'), 'NSU_CFORNE',"IIf(IsInCallStack('JURA162'), NUQ->NUQ_CCORRE, '')"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IIf(IsInCallStack('JURA162'), M->NUQ_CCORRE, '')"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NSU'), 'NSU_LFORNE',"IIf(IsInCallStack('JURA162'), NUQ->NUQ_LCORRE, '')"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IIf(IsInCallStack('JURA162'), M->NUQ_LCORRE, '')"})

		//Case 2
		/*Novo*/  aAdd(aSX3,   {Alltrim('NSU'), 'NSU_CFORNE',"IIf(IsInCallStack('JURA162'), NUQ->NUQ_CCORRE, '')"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IIf(IsInCallStack('JURA162'), M->NUQ_CCORRE,'')"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NSU'), 'NSU_LFORNE',"IIf(IsInCallStack('JURA162'), NUQ->NUQ_LCORRE, '')"})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"IIf(IsInCallStack('JURA162'), M->NUQ_LCORRE,'')"})

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		aSX3     := {}
		aSX3Old  := {}
		aSX3Estr := {"X3_ARQUIVO","X3_CAMPO","X3_WHEN"}

		//-------------------------------------------------------------------
		//Limpando o when padrão dos campos NRT_DATAT e NRT_QTDED
		//-------------------------------------------------------------------
		/*Novo*/  aAdd(aSX3,   {Alltrim('NRT'), 'NRT_DATAT',""})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"FwFldGet('NRT_TIPOGF') == '1'"})

		/*Novo*/  aAdd(aSX3,   {Alltrim('NRT'), 'NRT_QTDED',""})
		/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"FwFldGet('NRT_TIPOGF') == '1'"})

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

	EndIf

	//-------------------------------------------------------------------
	//Atualizações necessárias para o release V12.1.5
	//-------------------------------------------------------------------
	If cRelStart < "005" .AND. cRelFinish >= "005"

		//-------------------------------------------------------------------//
		//Exclusão do gatilho do campo de tipo de garantia para movimentação //
		//-------------------------------------------------------------------//
		DbSelectArea("SX7")
		SX7->( dbSetOrder( 1 ) )

		If SX7->( dbSeek( 'NT2_CTPGAR' ) )
			While !SX7->( Eof() ) .And. SX7->X7_CAMPO == "NT2_CTPGAR"
				IF SX7->X7_CDOMIN == "NT2_MOVFIN"
					Reclock( 'SX7', .F. )
					dbDelete()
					MsUnlock()
				Endif
				SX7->( DbSkip() )
			End
		EndIf


		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}

		//---------------------------------------
		//Atualização de Ordem da NT2
		//---------------------------------------
		Aadd(aSX3, {"NT2", "NT2_FILDES", "02" } )
		Aadd(aSX3, {"NT2", "NT2_MOVFIN", "03" } )
		Aadd(aSX3, {"NT2", "NT2_CAJURI", "04" } )
		Aadd(aSX3, {"NT2", "NT2_COD"   , "05" } )
		Aadd(aSX3, {"NT2", "NT2_CTPGAR", "06" } )
		Aadd(aSX3, {"NT2", "NT2_DTPGAR", "07" } )
		Aadd(aSX3, {"NT2", "NT2_CCOMON", "08" } )
		Aadd(aSX3, {"NT2", "NT2_DCOMON", "09" } )
		Aadd(aSX3, {"NT2", "NT2_DATA"  , "10" } )
		Aadd(aSX3, {"NT2", "NT2_DTJURO", "11" } )
		Aadd(aSX3, {"NT2", "NT2_CMOEDA", "12" } )
		Aadd(aSX3, {"NT2", "NT2_DMOEDA", "13" } )
		Aadd(aSX3, {"NT2", "NT2_DTULAT", "14" } )
		Aadd(aSX3, {"NT2", "NT2_DTMULT", "15" } )
		Aadd(aSX3, {"NT2", "NT2_PERMUL", "16" } )
		Aadd(aSX3, {"NT2", "NT2_MULATU", "17" } )
		Aadd(aSX3, {"NT2", "NT2_VALOR" , "18" } )
		Aadd(aSX3, {"NT2", "NT2_VCPROV", "19" } )
		Aadd(aSX3, {"NT2", "NT2_VJPROV", "20" } )
		Aadd(aSX3, {"NT2", "NT2_VLRATU", "21" } )
		Aadd(aSX3, {"NT2", "NT2_AJUCOR", "22" } )
		Aadd(aSX3, {"NT2", "NT2_AJUJUR", "23" } )
		Aadd(aSX3, {"NT2", "NT2_DTFIN" , "24" } )
		Aadd(aSX3, {"NT2", "NT2_PRAZO" , "25" } )
		Aadd(aSX3, {"NT2", "NT2_DTVENC", "26" } )
		Aadd(aSX3, {"NT2", "NT2_CENVOL", "27" } )
		Aadd(aSX3, {"NT2", "NT2_DENVOL", "28" } )
		Aadd(aSX3, {"NT2", "NT2_CGARAN", "29" } )
		Aadd(aSX3, {"NT2", "NT2_CPMF"  , "30" } )
		Aadd(aSX3, {"NT2", "NT2_JUROS" , "31" } )
		Aadd(aSX3, {"NT2", "NT2_IR"    , "32" } )
		Aadd(aSX3, {"NT2", "NT2_TEFBAN", "33" } )
		Aadd(aSX3, {"NT2", "NT2_CREDIT", "34" } )
		Aadd(aSX3, {"NT2", "NT2_DEBITO", "35" } )
		Aadd(aSX3, {"NT2", "NT2_SGARA" , "36" } )
		Aadd(aSX3, {"NT2", "NT2_SAL"   , "37" } )
		Aadd(aSX3, {"NT2", "NT2_SALLIQ", "38" } )
		Aadd(aSX3, {"NT2", "NT2_SJUIZ" , "39" } )
		Aadd(aSX3, {"NT2", "NT2_SJUIZA", "40" } )
		Aadd(aSX3, {"NT2", "NT2_DESC"  , "41" } )
		Aadd(aSX3, {"NT2", "NT2_CCLIEN", "42" } )
		Aadd(aSX3, {"NT2", "NT2_LCLIEN", "43" } )
		Aadd(aSX3, {"NT2", "NT2_DCLIEN", "44" } )
		Aadd(aSX3, {"NT2", "NT2_NUMCAS", "45" } )
		Aadd(aSX3, {"NT2", "NT2_DCASO" , "46" } )
		Aadd(aSX3, {"NT2", "NT2_PATIVO", "47" } )
		Aadd(aSX3, {"NT2", "NT2_PPASSI", "48" } )
		Aadd(aSX3, {"NT2", "NT2_DSITUA", "49" } )
		Aadd(aSX3, {"NT2", "NT2_NUMPRO", "50" } )
		Aadd(aSX3, {"NT2", "NT2_DTDIST", "51" } )
		Aadd(aSX3, {"NT2", "NT2_PREFIX", "52" } )
		Aadd(aSX3, {"NT2", "NT2_CNATUT", "53" } )
		Aadd(aSX3, {"NT2", "NT2_CTIPOT", "54" } )
		Aadd(aSX3, {"NT2", "NT2_CFORNT", "55" } )
		Aadd(aSX3, {"NT2", "NT2_LFORNT", "56" } )
		Aadd(aSX3, {"NT2", "NT2_NOMEFT", "57" } )
		Aadd(aSX3, {"NT2", "NT2_CGRUAP", "58" } )
		Aadd(aSX3, {"NT2", "NT2_CBANCO", "59" } )
		Aadd(aSX3, {"NT2", "NT2_CAGENC", "60" } )
		Aadd(aSX3, {"NT2", "NT2_CCONTA", "61" } )
		Aadd(aSX3, {"NT2", "NT2_DBANCO", "62" } )
		Aadd(aSX3, {"NT2", "NT2_DAGENC", "63" } )
		Aadd(aSX3, {"NT2", "NT2_OK"    , "64" } )
		Aadd(aSX3, {"NT2", "NT2_INTFIN", "65" } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO"}

		//-------------------------------------------------------------------
		//Atualização do campo NT2_CPMF para não usado
		//-------------------------------------------------------------------
		Aadd(aSX3, {"NT2", "NT2_CPMF", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------------------------------
		//Atualiza NZ6 (Tipo de assunto juridico X Parametros com parametro cria parametro MV_JNUMCNJ
		//-------------------------------------------------------------------------------------------
		Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JNUMCNJ", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JNUMCNJ", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JNUMCNJ", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JNUMCNJ", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JNUMCNJ", '2', 'C'} )

		AtuNZ6( aNZ6Estr, aNZ6Dados  )

		//-----------------------------------------------------
		//Adiciona NUQ_NUMANT nas consultas que utilizam a NUQ
		//-----------------------------------------------------
		aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '001' } )
		aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '002' } )
		aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '003' } )
		aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '004' } )
		aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_NUMANT', RetTitle( 'NUQ_NUMANT' ), '009' } )

		AtuNUZ(aNUZEstr, aNUZDados)

		//---------------------------------------------------------------------------------------
		//Atualiza campo Numero de Processo Antigo(NUQ_NUMANT) com o conteudo do campo NUQ_NUMPRO
		//---------------------------------------------------------------------------------------
		AtuNProAnt()

		//---------------------------------------------------------------------------------------
		//Atualiza ordem do campo Numero de Processo Antigo(NUQ_NUMANT)
		//---------------------------------------------------------------------------------------
		AtuOrdem("NUQ", 6, "NUQ_NUMANT")
		AtuOrdem("NUQ", 7, "NUQ_NUMPRO")

		//-------------------------------------------------------------------
		//Exclusão do gatilho do campo de entidade
		//-------------------------------------------------------------------
		DbSelectArea("SX7")
		SX7->( dbSetOrder( 1 ) )

		nRegs := 0

		If SX7->( dbSeek( 'NT9_ENTIDA' ) )
			While !SX7->( Eof() ) .And. SX7->X7_CAMPO == "NT9_ENTIDA"
				nRegs++
				IF SX7->X7_CDOMIN == "NT9_CODENT"
					If Upper(AllTRim(SX7->X7_REGRA)) == "J105GCHAV()"
						Reclock( 'SX7', .F. )
							dbDelete()
						MsUnlock()
					EndIf
				Endif
				SX7->( DbSkip() )
			End
		EndIf

		If nRegs == 1
			aSX3     	:= {}
			aSX3Old		:= {}
			aSX3Estr	:= {"X3_ARQUIVO","X3_CAMPO","X3_TRIGGER"}

			//-------------------------------------------------------------------
			//Limpando o when padrão dos campos NRT_DATAT e NRT_QTDED
			//-------------------------------------------------------------------
			/*Novo*/  aAdd(aSX3,   {Alltrim('NT9'), 'NT9_ENTIDA',""})
			/*antigo*/aAdd(aSX3Old,{Alltrim('XXX'), 'XXXXXXXXXX',"S"})

			//Atualiza o dicionario de dados
			AtuSX3(aSX3, aSX3Estr, aSX3Old)
		EndIf

		//-------------------------------------------------------------------//
		//Atualização do X3_RELAÇÃO E X3_WHEN do campo NSZ_TIPOAS //
		//-------------------------------------------------------------------//
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO","X3_WHEN"}

		Aadd(aSX3	, {"NSZ", "NSZ_TIPOAS", "", ""} )
		Aadd(aSX3Old, {"NSZ", "NSZ_TIPOAS", "IF( (ISINCALLSTACK( 'JURA162' ) .And. INCLUI) , cTipoAJ, IF( (ISINCALLSTACK( 'JA095INC' ) .And. INCLUI) , cTipoAJ, '' ))        ","EMPTY(M->NSZ_TIPOAS)                                        "} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------//
		/* Atualização do X3_WHEN do campo NT9_NOME
			Não há função para WHEN deste campo
		*/
		//-------------------------------------------------------------------//
			aSX3      := {}
			aSX3Old   := {}
			aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_WHEN"}

		/* Novo  Conteudo*/ Aadd(aSX3   , {"NT9", "NT9_NOME", ""} )
		/*Antigo Conteudo*/ Aadd(aSX3Old, {"NT9", "NT9_NOME", "J095WCli()"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------//
		// Altera o agrupamento do campo NSZ_COD para 001
		//-------------------------------------------------------------------//
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_AGRUP"}

		/* Novo  Conteudo*/ Aadd(aSX3   , {"NSZ", "NSZ_COD", "001"} )
		/*Antigo Conteudo*/ Aadd(aSX3Old, {"NSZ", "NSZ_COD", "002"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		// Atualiza X3_RELACAO e X3_INIBRW do NT9_DCRGDP
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO", "X3_INIBRW"}

		Aadd(aSX3, {"NT9", "NT9_DCRGDP", 'IIF(!INCLUI, JURGETDADOS("NRP", 1, xFilial("NRP") + NT9->NT9_CCRGDP, "NRP_DESC"), "")', 'JURGETDADOS("NRP", 1, xFilial("NRP") + NT9->NT9_CCRGDP, "NRP_DESC")' } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

	EndIf


	//-------------------------------------------------------------------
	//Atualizações necessárias para o release V12.1.6
	//-------------------------------------------------------------------
	If cRelStart < "006" .AND. cRelFinish >= "006"

		//--------------------------------------------------------------------
		//Movimenta valores do campo NYP_DATAAL para NYP_DATALT
		//--------------------------------------------------------------------

		TSMNBJ()

		//-------------------------------------------------------------------
		//Atualização do campo NYP_DATAAL para não usado
		//-------------------------------------------------------------------

		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO"}

		Aadd(aSX3, {"NYP", "NYP_DATAAL", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-----------------------------------------------------
		//Apagar NYP_DATAAL da associação Campo x Assuntos
		//-----------------------------------------------------
		DelNUZ('NYP_DATAAL','001')
		DelNUZ('NYP_DATAAL','003')
		DelNUZ('NYP_DATAAL','004')

		//-----------------------------------------------------
		//Adiciona NYP_DATALT nos assuntos que utilizam a NYP
		//-----------------------------------------------------
		aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
		aNUZDados	:={}

		aAdd( aNUZDados, { xFilial("NYP"), 'NYP_DATALT', RetTitle( 'NYP_DATALT' ), '001' } )
		aAdd( aNUZDados, { xFilial("NYP"), 'NYP_DATALT', RetTitle( 'NYP_DATALT' ), '003' } )
		aAdd( aNUZDados, { xFilial("NYP"), 'NYP_DATALT', RetTitle( 'NYP_DATALT' ), '004' } )

		AtuNUZ(aNUZEstr, aNUZDados)
		If FWAliasInDic("NQV")
			DbSelectArea("NQV")	//CAMPOS EXPORTACAO PERSONALIZAD
			NQV->(dbGoTop())

			While NQV->(!Eof())
				If ALLTRIM(NQV->NQV_CAMPO)=="NYP_DATAAL"
					RecLock('NQV',.F.)
					NQV->NQV_CAMPO := "NYP_DATALT"
					MsUnlock()
					DbSkip()
				Else
					DbSkip()
				EndIf
			End
			DbCloseArea()
		Endif
		//-------------------------------------------------------------------
		//Atualiza valor default do campo NTA_ACEITO
		//-------------------------------------------------------------------
		AceiteNTA()

		//-------------------------------------------------------------------
		//Atualiza ordem do campo NUQ_ESTADO para antes do campo de comarca
		//-------------------------------------------------------------------
		AtuOrdem("NUQ", 12, "NUQ_ESTADO")

		//-------------------------------------------------------------------
		//Atualiza contexto, Inic. Padrão e Inic. Browse dos campos
		// NSZ_NUMPRO, NSZ_PATIVO e NSZ_PPASSI
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO", "X3_INIBRW"}

		Aadd(aSX3, {"NSZ", "NSZ_NUMPRO", "", "" } )
		Aadd(aSX3, {"NSZ", "NSZ_PATIVO", "", "" } )
		Aadd(aSX3, {"NSZ", "NSZ_PPASSI", "", "" } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualiza campos NSZ_NUMPRO, NSZ_PATIVO e NSZ_PPASSI com valores
		//vindos na NUQ e NT9
		//-------------------------------------------------------------------
		AtuCpoNSZ()

		//-------------------------------------------------------------------
		//Atualização do campo NYF_COD para remover o inicializador padrão
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

		Aadd(aSX3	, {"NYF", "NYF_COD", "" 							})
		Aadd(aSX3Old, {"NYF", "NYF_COD", "GetSXENum('NYF','NYF_COD')"	})

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualiza ordem de novos campos da negociacao especial
		//-------------------------------------------------------------------
		AtuOrdem("NZD", 10, "NZD_CCOMAR")
		AtuOrdem("NZD", 11, "NZD_DCOMAR")
		AtuOrdem("NZD", 12, "NZD_CFORO"	)
		AtuOrdem("NZD", 13, "NZD_DFORO"	)
		AtuOrdem("NZD", 14, "NZD_CVARA"	)
		AtuOrdem("NZD", 15, "NZD_DVARA"	)

		//-------------------------------------------------------------------
		//Atualização para poder alterar o campo NZG_STATUS
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VISUAL"}

		Aadd(aSX3, {"NZG", "NZG_STATUS", "A"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualização para poder alterar o campo NT4_CFWLP
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VISUAL"}

		Aadd(aSX3, {"NT4", "NT4_CFWLP", "A"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualização para nao poder alterar o campo NZG_CAJURI
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VISUAL"}

		Aadd(aSX3, {"NZG", "NZG_CAJURI", "V"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//---------------------------------------------------------------------------
		//Atualização para mudar titulo e descricao dos campos NZG_CRESPO\NZG_DRESPO
		//---------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO", "X3_DESCRIC"}

		Aadd(aSX3, {"NZG", "NZG_CRESPO", "Cód Preposto"	, "Código do Preposto"	} )
		Aadd(aSX3, {"NZG", "NZG_DRESPO", "Preposto"		, "Nome do Preposto"	} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//----------------------------------
		//Atualiza ordem dos campos da NZG
		//----------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}

		Aadd(aSX3, {"NZG", "NZG_FILIAL", "01"})
		Aadd(aSX3, {"NZG", "NZG_COD"   , "02"})
		Aadd(aSX3, {"NZG", "NZG_CCORRE", "03"})
		Aadd(aSX3, {"NZG", "NZG_LCORRE", "04"})
		Aadd(aSX3, {"NZG", "NZG_CESCRI", "05"})
		Aadd(aSX3, {"NZG", "NZG_CAREA" , "06"})
		Aadd(aSX3, {"NZG", "NZG_CCLIEN", "07"})
		Aadd(aSX3, {"NZG", "NZG_LCLIEN", "08"})
		Aadd(aSX3, {"NZG", "NZG_ITEM"  , "09"})
		Aadd(aSX3, {"NZG", "NZG_INFO"  , "10"})
		Aadd(aSX3, {"NZG", "NZG_STATUS", "11"})
		Aadd(aSX3, {"NZG", "NZG_NUMPRO", "12"})
		Aadd(aSX3, {"NZG", "NZG_CAJURI", "13"})
		Aadd(aSX3, {"NZG", "NZG_CANDAM", "14"})
		Aadd(aSX3, {"NZG", "NZG_CFWLP" , "15"})
		Aadd(aSX3, {"NZG", "NZG_DTAPRO", "16"})
		Aadd(aSX3, {"NZG", "NZG_CATO"  , "17"})
		Aadd(aSX3, {"NZG", "NZG_DATO"  , "18"})
		Aadd(aSX3, {"NZG", "NZG_CTPSER", "19"})
		Aadd(aSX3, {"NZG", "NZG_DTPSER", "20"})
		Aadd(aSX3, {"NZG", "NZG_CRESPO", "21"})
		Aadd(aSX3, {"NZG", "NZG_DRESPO", "22"})
		Aadd(aSX3, {"NZG", "NZG_CCOMAR", "23"})
		Aadd(aSX3, {"NZG", "NZG_DCOMAR", "24"})
		Aadd(aSX3, {"NZG", "NZG_CFORO" , "25"})
		Aadd(aSX3, {"NZG", "NZG_DFORO" , "26"})
		Aadd(aSX3, {"NZG", "NZG_CVARA" , "27"})
		Aadd(aSX3, {"NZG", "NZG_DVARA" , "28"})
		Aadd(aSX3, {"NZG", "NZG_PRODUT", "29"})
		Aadd(aSX3, {"NZG", "NZG_VLCALC", "30"})
		Aadd(aSX3, {"NZG", "NZG_VLPAGA", "31"})
		Aadd(aSX3, {"NZG", "NZG_OBSERV", "32"})
		Aadd(aSX3, {"NZG", "NZG_RECNT4", "33"})
		Aadd(aSX3, {"NZG", "NZG_GERSIS", "34"})

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//---------------------------------------------------------------------------
		//Atualização titulo do campo NZC_DESCRI
		//---------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO"}

		Aadd(aSX3, {"NZC", "NZC_DESCRI", "Nome Escritó"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//---------------------------------------------------------------------------
		//Atualização inicializador padrao dos campo NTA_CFASE e NTA DFASE
		//---------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

		Aadd(aSX3	, {"NT4", "NT4_CFASE", "JA100SGFAS()" })
		Aadd(aSX3	, {"NT4", "NT4_DFASE", "IF(!INCLUI,Posicione('NQG',1,xFilial('NQG')+NT4->NT4_CFASE,'NQG_DESC'),JurGatilho('NT4_CFASE','NQG','NQG_DESC','NT4MASTER'))" })

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualiza ordem do campo de status do item do extrato do correspondente
		//-------------------------------------------------------------------
		AtuOrdem("NZG", 31, "NZG_STATUS")
	EndIf

	//-------------------------------------------------------------------
	//Atualizações necessárias para o release V12.1.7
	//-------------------------------------------------------------------
	If cRelStart < "007" .AND. cRelFinish >= "007"
		//-------------------------------------------------------------------------------------------------------------------------------
		//Atualiza ordem do campo Data do juros da provisao(NSZ_DTJPRO) para uma posicao depois da Data do valor da provisao(NSZ_DTPROV)
		//-------------------------------------------------------------------------------------------------------------------------------
		nAux := NSZ->(FieldPos("NSZ_DTPROV"))
		nAux := IIF( nAux > 0, nAux + 1, 121)
		AtuOrdem("NSZ", nAux, "NSZ_DTJPRO")
	EndIf

	If cRelStart < "007" .And. cRelFinish >= "007"
		//------------------------------------------------------------------
		// Corrige inicializador pardão do campo NSZ_DCASO - Chamado TTVCI1
		//------------------------------------------------------------------
		TTVCI1()
		//------------------------------------------------------------------
		// Corrige Picture do campo NTA_HORA e NTA_DURACA - Chamado TTUOBI
		//------------------------------------------------------------------
		TTUOBI()
		//------------------------------------------------------------------
		// Modifica o Campo de contra dominio do gatiIlho do campo NSZ_CSBPRO - Chamado TUDKTO
		//------------------------------------------------------------------
		TUDKTO()
		//------------------------------------------------------------------
		// Corrige inicializador padrão dos campos NSZ_SIGLA1, NSZ_SIGLA2, NSZ_SIGLA3  - Chamado TULRL2
		//------------------------------------------------------------------
		TULRL2()
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		//------------------------------------------------------------------
		// Corrige o inicializador padrão dos campos NSZ_SIGLA1,NSZ_SIGLA2
		// NSZ_SIGLA3 - Chamado TURLQI
		//------------------------------------------------------------------
		TURLQI()
		//------------------------------------------------------------------
		//-------------------------------------------------------------------//
		// Altera o agrupamento do campo NSZ_COD para 001 - Chamado TVGGPL
		//-------------------------------------------------------------------//
		TVGGPL()

		//------------------------------------------------------------------
		// Modifica a validação e a consulta padrão do campo NT9_CCRGDP
		// para que ao acionar o f3 a consulta busque corretamente o cargo de funcionario
		// - Chamado TVGHA2
		//-------------------------------------------------------------------//
		TVGHA2()

		//-------------------------------------------------------------------//
		// Incluir campo de NT4_CINSTA - Instancia / NT4_CADITI - Aditivo
		// em andamentos de perfis que possuem NUQ ( Instancia ) / Perfil Contrato
		//-------------------------------------------------------------------//
		TVGHP3()
		//-------------------------------------------------------------------//
		// Incluir campo de NUQ_ESTADO nos Perfis na guia de instância
		//-------------------------------------------------------------------//
		TVGHH5()
		//-------------------------------------------------------------------//
		//-------------------------------------------------------------------//
		// Incluir campos na NUZ
		//-------------------------------------------------------------------//
		TWBSV6()
		//------------------------------------------------------------------
		// Altera o campo NUH_UTEBIL para deixar de ser obrigatório
		// - Chamado TUZZPB
		//-------------------------------------------------------------------//
		TUZZPB()
		//------------------------------------------------------------------
		// Altera o campo NUH_UTEBIL para deixar de ser obrigatório
		// - Chamado TUZZPB
		//-------------------------------------------------------------------//
		TVHN41()
		//-------------------------------------------------------------------//
		//	Situação/Requisito:
		//	Alterar forma de correção dos pedidos zerar os campos de valores atualizados. / multa e juros quando existir conforme o calculo.
		//	Solução/Implementação:
		//	Ao mudar a forma de correção os campos valores atualizados, multa e juros são zerados
		// - Chamado TVWGZS
		//-------------------------------------------------------------------//

		TVWGZS()
		//-------------------------------------------------------------------//
		// Ajuste na condição de edição dos campos Cliente? e Fornecedor?
		// na aba de EnvolvidosIncluir campo de NT4_CINSTA - Instancia / NT4_CADITI - Aditivo
		//-------------------------------------------------------------------//
		TVWWJ2()

		//-------------------------------------------------------------------------//
		// Ajuste no gatilho do campo de cargo de envolvido NT9_CCRGDP
		//-------------------------------------------------------------------------//
		MJUR110()
		//-------------------------------------------------------------------------//

		//------------------------------------------------------------------
		// Inclusão de gatilho para o campo NSZ_SITUAC
		//-------------------------------------------------------------------//
		MJUR433()

		If FWAliasInDic("NTE")
			DbSelectArea("NTE")
			If ColumnPos("NTE_CAJURI") > 0
				//-----------------------------------------------------
				//Atualiza ordem do campo de codigo do assunto juridico
				//-----------------------------------------------------
				AtuOrdem("NTE", 2, "NTE_CAJURI")

				//--------------------------------------------------
				//Inclui campo NTE_SIGLA na configuracao de pesquisa
				//--------------------------------------------------
				aNVHDados	:= {}
				aNVHEstr	:= {"NVH_FILIAL", "NVH_COD", "NVH_DESC", "NVH_TABELA", "NVH_CAMPO", "NVH_WHERE", "NVH_PROPRI", "NVH_F3DIF", "NVH_F3CONS", "NVH_F3MULT", "NVH_TPPESQ"}

				aAdd( aNVHDados, {xFilial("NVH"), , RetTitle("NTE_SIGLA"), RetSqlName('NTE'), "NTE_SIGLA", J163Where("NTE_SIGLA"), .F., .F.,  '', .F., '1'} )	//Assunto Juridico
				Aadd( aNVHDados, {xFilial("NVH"), , RetTitle("NTE_SIGLA"), RetSqlName('NTE'), "NTE_SIGLA", J163Where("NTE_SIGLA"), .F., .F.,  '', .F., '2'} )	//Follow-up

				AtuNVH(aNVHEstr, aNVHDados)

				//-------------------------------------
				//Atualiza conteudo do campo NTE_CAJURI
				//-------------------------------------
				NTECajuri()
			EndIf
		Endif

		//-------------------------------------------------------------------
		//Atualiza ordem do campo NT9_DENTID para depois do do campo de Cod. Entida (NT9_CODENT)
		//-------------------------------------------------------------------
		DbSelectArea("SX3")
		SX3->( dbSetOrder( 2 ) )			//X3_CAMPO

		If SX3->( dbSeek( 'NT9_DENTID' ) )
				If SX3->X3_ORDEM <> "06"
					AtuOrdem("NT9", 6, "NT9_DENTID")
				Endif

				//-----------------------------------------------------
				//Adiciona NT9_DENTID nos assuntos que utilizam a NT9 - Envolvidos
				//-----------------------------------------------------
				If FWAliasInDic("NUZ")

					DbSelectArea("NUZ")
					NUZ->( dbSetOrder( 1 ) )

					aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}


					For nI:= 1 To 11
						If nI == 5
							Loop
						ElseIf !NUZ->( dbSeek( xFilial("NUZ") + StrZero(nI, 3) + 'NT9_DENTID' ) )

							aNUZDados	:={}
							aAdd( aNUZDados, { xFilial("NT9"), 'NT9_DENTID', RetTitle( 'NT9_DENTID' ), StrZero(nI, 3) } )

							AtuNUZ(aNUZEstr, aNUZDados)
						Endif
					Next
				Endif
		Endif

		//------------------------------------------------------------------------------------------------
		//Atualiza o contexto do campo de nome do envolvido para virtual na tela de valores em discussão
		//------------------------------------------------------------------------------------------------
		If SX3->( dbSeek( 'NSY_DENVOL' ) )
			If SX3->X3_CONTEXT == "R"
				aSX3      := {}
				aSX3Old   := {}
				aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_CONTEXT", "X3_VISUAL"}

				Aadd(aSX3, {"NSY", "NSY_DENVOL", "V", "V"})

				AtuSX3(aSX3, aSX3Estr, aSX3Old)

			EndIf
		EndIf

		//-------------------------------------------------------------------------------------------------------
		//Atualiza o campo de data de demissão para usado e remove o inicializador padrão por ser um campo real
		//-------------------------------------------------------------------------------------------------------
		If SX3->( dbSeek( 'NT9_DTDEMI' ) )
			aSX3      := {}
			aSX3Old   := {}
			aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO", "X3_USADO"}

			Aadd(aSX3, {"NT9", "NT9_DTDEMI", "", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) })

			AtuSX3(aSX3, aSX3Estr, aSX3Old)

		EndIf

		//-------------------------------------------------------------------------------------------------------
		//Ajustar Inic. Padrão do campo NSZ_CAREAJ
		//-------------------------------------------------------------------------------------------------------
		If SX3->( dbSeek( 'NSZ_CAREAJ' ) )
			aSX3      := {}
			aSX3Old   := {}
			aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

			Aadd(aSX3, {"NSZ", "NSZ_CAREAJ", "IF( (ISINCALLSTACK( 'JA095INC' ) .AND. INCLUI) , CCODAREA, IF(INCLUI,J095AREAC(),''))"})

			AtuSX3(aSX3, aSX3Estr, aSX3Old)

		EndIf

		//---------------------------------------------------------------------------
		//Atualização para mudar titulo de alguns campos (Reestruturação perfil Contencioso)
		//---------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO"}

		Aadd(aSX3, {"NSZ", "NSZ_DCOMAR", "Comarca"      } )
		Aadd(aSX3, {"NSZ", "NSZ_DNATUR", "Natureza"     } )
		Aadd(aSX3, {"NSZ", "NSZ_DAREAJ", "Área"         } )
		Aadd(aSX3, {"NSZ", "NSZ_DRITO" , "Rito"         } )
		Aadd(aSX3, {"NSZ", "NSZ_DOBJET", "Objeto"       } )
		Aadd(aSX3, {"NSZ", "NSZ_DPROGN", "Prognóstico"  } )
		Aadd(aSX3, {"NSZ", "NSZ_DMOCAU", "Moeda Causa"  } )
		Aadd(aSX3, {"NSZ", "NSZ_DMOENV", "Moeda Envolv" } )
		Aadd(aSX3, {"NSZ", "NSZ_DMOPRO", "Moeda Provi"  } )
		Aadd(aSX3, {"NSZ", "NSZ_DTPROV", "Data Provi"   } )
		Aadd(aSX3, {"NSZ", "NSZ_DTENVO", "Data Envolv"  } )
		Aadd(aSX3, {"NSZ", "NSZ_DMOENC", "Motivo"       } )
		Aadd(aSX3, {"NT9", "NT9_DTPENV", "Tipo Envolv"  } )
		Aadd(aSX3, {"NUQ", "NUQ_DNATUR", "Natureza"     } )
		Aadd(aSX3, {"NUQ", "NUQ_DTIPAC", "Tipo de Ação" } )
		Aadd(aSX3, {"NUQ", "NUQ_DCOMAR", "Comarca"      } )
		Aadd(aSX3, {"NUQ", "NUQ_DLOC2N", "Foro/Tri"     } )
		Aadd(aSX3, {"NUQ", "NUQ_DLOC3N", "Vara/Cam"     } )
		Aadd(aSX3, {"NUQ", "NUQ_DDECIS", "Decisão"      } )
		Aadd(aSX3, {"NSY", "NSY_DPEVLR", "Pedido"       } )
		Aadd(aSX3, {"NSY", "NSY_DPROG" , "Prognóstico"  } )
		Aadd(aSX3, {"NSY", "NSY_DDECPE", "Decisão"      } )
		Aadd(aSX3, {"NSY", "NSY_DENVOL", "Envolvido"    } )

		//---------------------------------------------------------------------------
		//Atualização para mudar titulo do campo NSZ_DTADIT (Reestruturação perfil Contratos)
		//---------------------------------------------------------------------------
		Aadd(aSX3, {"NSZ", "NSZ_DTADIT", "Dt Assinatur"} )

		//---------------------------------------------------------------------------
		//Atualização para mudar titulo do campo NSZ_DMOCAP (Reestruturação perfil Societário)
		//---------------------------------------------------------------------------
		Aadd(aSX3, {"NSZ", "NSZ_DMOCAP", "Moed Capital"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------------------------------------------
		//Ajusta a ordem dos campos
		//-------------------------------------------------------------------------------------------------------
		If FWAliasInDic("NSZ")
			DbSelectArea("NSZ")
			If ColumnPos('NSZ_DTCONT') > 0 .And. ColumnPos('NSZ_CMOCON') > 0 .And. ColumnPos('NSZ_VACONT') > 0
				AtuOrdem("NSZ", 217, "NSZ_INDCON")
				AtuOrdem("NSZ", 218, "NSZ_CSTATL")
				AtuOrdem("NSZ", 219, "NSZ_CSITUL")
				AtuOrdem("NSZ", 220, "NSZ_DTINLI")
				AtuOrdem("NSZ", 221, "NSZ_DTFILI")
				AtuOrdem("NSZ", 222, "NSZ_OBSLIV")
				AtuOrdem("NSZ", 223, "NSZ_OBSLIR")
				AtuOrdem("NSZ", 224, "NSZ_VCENVO")
				AtuOrdem("NSZ", 225, "NSZ_VJENVO")
				AtuOrdem("NSZ", 226, "NSZ_DTREAB")
				AtuOrdem("NSZ", 227, "NSZ_DTCONT")
				AtuOrdem("NSZ", 228, "NSZ_CMOCON")
				AtuOrdem("NSZ", 229, "NSZ_DMOCON")
				AtuOrdem("NSZ", 230, "NSZ_VLCONT")
				AtuOrdem("NSZ", 231, "NSZ_VACONT")
				AtuOrdem("NSZ", 232, "NSZ_MULCON")
				AtuOrdem("NSZ", 233, "NSZ_CCPCON")
				AtuOrdem("NSZ", 234, "NSZ_DCPCON")
			EndIf
		Endif
		//-------------------------------------------------------------------------------------------------------
		//Ajusta agrupamentos dos campos NSZ_VLCONT, NSZ_MULCON, NSZ_CCPCON, NSZ_DCPCON
		//-------------------------------------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_AGRUP"}

		Aadd(aSX3   , {"NSZ", "NSZ_VLCONT", "003"} )
		Aadd(aSX3   , {"NSZ", "NSZ_MULCON", "003"} )
		Aadd(aSX3   , {"NSZ", "NSZ_CCPCON", "003"} )
		Aadd(aSX3   , {"NSZ", "NSZ_DCPCON", "003"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

	Endif

	If cRelStart < "007" .And. cRelFinish >= "007"

		//Atualização do campo browse
		DbSelectArea("SX3")
		SX3->( dbSetOrder( 1 ) )			//X3_ARQUIVO+X3_ORDEM
		SX3->( dbGoTop() )			//X3_ARQUIVO+X3_ORDEM

		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_BROWSE"}

		DO While !SX3->(EOF())

			If SX3->X3_ARQUIVO == 'NSY'
				/* Novo  Conteudo*/ Aadd(aSX3   , {SX3->X3_ARQUIVO, SX3->X3_CAMPO, "N"} )
			ENDIF

			SX3->( dbSkip() )

		Enddo

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//Atualização do campo browse e picture
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_PICTURE", "X3_BROWSE"}

		Aadd(aSX3, {"NSY", 'NSY_DPEVLR', "@S20", "S"} )
		Aadd(aSX3, {"NSY", 'NSY_CPROG' , "@S2", "N"} )
		Aadd(aSX3, {"NSY", 'NSY_DPROG' , "@S15", "S"} )
		Aadd(aSX3, {"NSY", 'NSY_CDECPE', "@S4", "N"} )
		Aadd(aSX3, {"NSY", 'NSY_DDECPE', "@S20", "S"} )
		Aadd(aSX3, {"NSY", 'NSY_CJUIZ' , "@S3", "N"} )
		Aadd(aSX3, {"NSY", 'NSY_DJUIZ' , "@S15", "S"} )
		Aadd(aSX3, {"NSY", 'NSY_CENVOL', "@S5", "N"} )
		Aadd(aSX3, {"NSY", 'NSY_DENVOL', "@S20", "S"} )
		Aadd(aSX3, {"NSY", 'NSY_PEDATA', "", "S"} )
		Aadd(aSX3, {"NSY", 'NSY_PEVLR' , "@E 999,999,999.99", "S"} )
		Aadd(aSX3, {"NSY", 'NSY_PEVLRA', "@E 99,999,999,999.99", "S"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)


		//Atualização do campo USADO
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO"}

		Aadd(aSX3, {"NSY", "NSY_CCLIEN", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)} )
		Aadd(aSX3, {"NSY", "NSY_LCLIEN", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)} )
		Aadd(aSX3, {"NSY", "NSY_DCLIEN", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)} )
		Aadd(aSX3, {"NSY", "NSY_NUMCAS", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)} )
		Aadd(aSX3, {"NSY", "NSY_DCASO",  Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		aStruct   	:= {}
		aNVHDados 	:= {}

		SX3->( dbSetOrder( 2 ) )			//X3_CAMPO
		If SX3->( dbSeek( 'NSZ_CODWF' ) )
			If FWAliasInDic("NVH")
				DbSelectArea("NVH")
				NVH->( dbSetOrder( 3 ) )

				If !NVH->( dbSeek( xFilial("NVH") + SX3->X3_CAMPO + '1' ) )

					aAdd( aStruct, 'NVH_FILIAL' )
					aAdd( aStruct, 'NVH_COD'    )
					aAdd( aStruct, 'NVH_DESC'   )
					aAdd( aStruct, 'NVH_TABELA' )
					aAdd( aStruct, 'NVH_CAMPO'  )
					aAdd( aStruct, 'NVH_WHERE'  )
					aAdd( aStruct, 'NVH_PROPRI' )
					aAdd( aStruct, 'NVH_F3DIF'  )
					aAdd( aStruct, 'NVH_F3CONS' )
					aAdd( aStruct, 'NVH_F3MULT' )
					aAdd( aStruct, 'NVH_TPPESQ' )

					aAdd( aNVHDados, { xFilial("NVH"), GetSXENUM( 'NVH', 'NVH_COD' ), SX3->X3_TITULO, RetSqlName('NSZ'), SX3->X3_CAMPO, J163Where("NSZ_CODWF"), .F.    , .F.  ,  ''     , .F.     , '1'} )

					RecLock( 'NVH', .T.  )
					For nI := 1 To Len( aStruct )
						NVH->( FieldPut( FieldPos( aStruct[nI] ) , aNVHDados [1] [nI] ) )
					Next
					NVH->( MsUnLock() )

					If __lSX8
						ConfirmSX8()
						NVH->( dbCommit() )
					Else
						RollBackSX8()
					EndIf

				EndIf
			EndIf
		Endif

		aStruct   	:= {}
		aNVHDados 	:= {}

		If SX3->( dbSeek( 'NTA_CODWF' ) )
			If FWAliasInDic("NVH")
				DbSelectArea("NVH")

				If !NVH->( dbSeek( xFilial("NVH") + SX3->X3_CAMPO + '2' ) )

					aAdd( aStruct, 'NVH_FILIAL' )
					aAdd( aStruct, 'NVH_COD'    )
					aAdd( aStruct, 'NVH_DESC'   )
					aAdd( aStruct, 'NVH_TABELA' )
					aAdd( aStruct, 'NVH_CAMPO'  )
					aAdd( aStruct, 'NVH_WHERE'  )
					aAdd( aStruct, 'NVH_PROPRI' )
					aAdd( aStruct, 'NVH_F3DIF'  )
					aAdd( aStruct, 'NVH_F3CONS' )
					aAdd( aStruct, 'NVH_F3MULT' )
					aAdd( aStruct, 'NVH_TPPESQ' )

					aAdd( aNVHDados, { xFilial("NVH"), GetSXENUM( 'NVH', 'NVH_COD' ), SX3->X3_TITULO, RetSqlName('NTA'), SX3->X3_CAMPO, J163Where("NTA_CODWF"), .F.    , .F.  ,  ''     , .F.     , '2'} )

					RecLock( 'NVH', .T.  )
					For nI := 1 To Len( aStruct )
						NVH->( FieldPut( FieldPos( aStruct[nI] ) , aNVHDados [1] [nI] ) )
					Next
					NVH->( MsUnLock() )

					If __lSX8
						ConfirmSX8()
						NVH->( dbCommit() )
					Else
						RollBackSX8()
					EndIf

				EndIf
			EndIf
		Endif

		//Atualização do campo browse e picture
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_PICTURE"}

		Aadd(aSX3, {"NZ2", 'NZ2_CEP', "@R 99999-999"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Excluindo gatilho dos campo NSZ_SIGLAx
		//-------------------------------------------------------------------
		SX7->( dbSetOrder( 1 ) )		//X7_CAMPO + X7_SEQUENC
		If SX7->( DbSeek("NSZ_SIGLA1" + "001") )
			Reclock( "SX7", .F. )
				SX7->X7_CONDIC := ""
			SX7->( MsUnlock() )
		EndIf
		ExcluiSX7("NSZ_SIGLA1" , "002", "NSZ_CPART1")
		ExcluiSX7("NSZ_SIGLA1" , "003", "NSZ_DPART1")

		SX7->( dbSetOrder( 1 ) )		//X7_CAMPO + X7_SEQUENC
		If SX7->( DbSeek("NSZ_SIGLA2" + "001") )
			Reclock( "SX7", .F. )
				SX7->X7_CONDIC := ""
			SX7->( MsUnlock() )
		EndIf
		ExcluiSX7("NSZ_SIGLA2" , "002", "NSZ_CPART2")
		ExcluiSX7("NSZ_SIGLA2" , "003", "NSZ_DPART2")

		SX7->( dbSetOrder( 1 ) )		//X7_CAMPO + X7_SEQUENC
		If SX7->( DbSeek("NSZ_SIGLA3" + "001") )
			Reclock( "SX7", .F. )
				SX7->X7_CONDIC := ""
			SX7->( MsUnlock() )
		EndIf
		ExcluiSX7("NSZ_SIGLA3" , "002", "NSZ_CPART3")
		ExcluiSX7("NSZ_SIGLA3" , "003", "NSZ_DPART3")

		//-------------------------------------------------------------------
		//Excluindo gatilho dos campo NSZ_CPARTx
		//-------------------------------------------------------------------
		ExcluiSX7("NSZ_CPART1" , "001", "NSZ_DPART1")
		ExcluiSX7("NSZ_CPART2" , "001", "NSZ_DPART2")
		ExcluiSX7("NSZ_CPART3" , "001", "NSZ_DPART3")

		aSX3     	:= {}
		aSX3Old		:= {}
		aSX3Estr	:= {"X3_ARQUIVO","X3_CAMPO","X3_TRIGGER"}

		aAdd(aSX3, {"NSZ", "NSZ_CPART1", ""} )
		aAdd(aSX3, {"NSZ", "NSZ_CPART2", ""} )
		aAdd(aSX3, {"NSZ", "NSZ_CPART3", ""} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Retirando X3_WHEN do campo NZI_CONDPG
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_WHEN"}

		Aadd(aSX3   , {"NZI", "NZI_CONDPG", ""} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//----------------------------------------------------------------------------
		//Excluindo relacionamento dos campo NZC_CONDPG, NZC_NATURE, NZC_TIPOTI na SX9
		//----------------------------------------------------------------------------

		aStruct:= {"NZC_CONDPG","NZC_NATURE","NZC_TIPOTI"}
		DbSelectArea("SX9")
		SX9->( dbSetOrder( 2 ) )			//X9_CDOM+X9_DOM


		For nI:= 1 To Len(aStruct)
			SX9->(dbSeek("NZC"))
			DO While !SX9->(EOF())
				If aStruct[nI] $ SX9->X9_EXPCDOM
					Reclock( 'SX9', .F. )
					SX9->( DbDelete() )
					SX9->( MsUnlock() )
				ENDIF
				IF SX9->X9_CDOM <> "NZC"
					Exit
				Endif
				SX9->( dbSkip() )
			Enddo
		Next nI

		ATUCONFREL() // Atualiza configuração de relatórios que foram alterados para TMSPrinter

		//-------------------------------------------------------------------------------------------
		//Atualiza NZ6 (Tipo de assunto juridico X Parametros com o parametro "MV_JVLRCO" criado na SX6
		//-------------------------------------------------------------------------------------------
		DbSelectArea("SX6")
		SX6->( dbSetOrder( 1 ) )			//X6_VAR

		If SX6->( dbSeek( xFilial("SX6") + 'MV_JVLRCO' ) )
			If FWAliasInDic("NZ6") .AND. FWAliasInDic("NYB")
				DbSelectArea("NZ6")
				NZ6->( dbSetOrder( 1 ) )
				aNZ6Dados := {}

				dbSelectArea("NYB")
				NYB->( DbSetOrder(1) )	//NYB_Filial + NYB_COD

				Do While NYB->( ! EoF() )

					If !NZ6->( dbSeek( xFilial("NZ6") + NYB->NYB_COD  + "MV_JVLRCO" ) )
						Aadd(aNZ6Dados, {xFilial("NZ6"), NYB->NYB_COD, "MV_JVLRCO", '2', 'C'} )
					Endif

					NYB->( DbSkip() )

				Enddo

				If LEN( aNZ6Dados ) <> 0
					AtuNZ6( aNZ6Estr, aNZ6Dados  )
				Endif
			Endif
		Endif

		If SX6->( dbSeek( xFilial("SX6") + 'MV_JALTREG' ) )

			DbSelectArea("NZ6")
			NZ6->( dbSetOrder( 1 ) )
			aNZ6Dados := {}

			dbSelectArea("NYB")
			NYB->( DbSetOrder(1) )	//NYB_Filial + NYB_COD
			NYB->(DbGoTop())

			Do While NYB->( ! EoF() )

				If !NZ6->( dbSeek( xFilial("NZ6") + NYB->NYB_COD  + "MV_JALTREG" ) )
					Aadd(aNZ6Dados, {xFilial("NZ6"), NYB->NYB_COD, "MV_JALTREG", '1', 'C'} )
				Endif

				NYB->( DbSkip() )

			Enddo

			If LEN( aNZ6Dados ) <> 0
				AtuNZ6( aNZ6Estr, aNZ6Dados  )
			Endif
		Endif

		//-------------------------------------------------------------------------------------------
		//Atualização dos campos browse na SX3 (NSY_VLCONT, NSY_SPE, NSY_SAPE,NSY_TOTPED, NSY_TOPEAT, NSY_SLCONT, NSY_SLCONA, NSY_TOTORC, NSY_TOTATC
		//-------------------------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_BROWSE"}
		aStruct   := {"NSY_VLCONT", "NSY_SPE", "NSY_SAPE", "NSY_TOTPED", "NSY_TOPEAT", "NSY_SLCONT", "NSY_SLCONA", "NSY_TOTORC", "NSY_TOTATC" }

		DbSelectArea("SX3")
		SX3->( dbSetOrder( 2 ) )			//X3_CAMPO

		For nI:= 1 To Len(aStruct)
			If SX3->( dbSeek( aStruct[nI] ) )
				Aadd(aSX3, {"NSY", aStruct[nI], "S"} )
			Endif
		Next

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------------------------------------------
		//Ajusta Inic. Padrão (Relação) do campo NW5_COD
		//-------------------------------------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

		Aadd(aSX3   , {"NW5", "NW5_COD", "JA059NEWIND()"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------------------------------------------
		//Ajusta Inic. Padrão (Relação) do campo NQY_CFGJUR
		//-------------------------------------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

		Aadd(aSX3   , {"NQY", "NQY_CFGJUR", ""} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------------------------------------------
		//Ajusta Inic. Padrão (Relação) do campo NQY_CFGJUR
		//-------------------------------------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

		Aadd(aSX3   , {"NQY", "NQY_CFGJUR", ""} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)


		//-------------------------------------------------------------------
		//Chamado TVFXJG - Aumento campo cód entidade de envolvidos
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

		Aadd(aSX3   , {"NT9", "NT9_CODENT", 18} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualização dos campos NT6_DTALT, NT6_CINSTA, NT6_CDECPE,
		//NT6_PEDATA, NT6_DTJURO, NT6_CMOPED e NT6_PEVLR para não Obrigatorio
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO", "X3_RESERV"}

		Aadd(aSX3, {"NT6", "NT6_DTALT" , Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )
		Aadd(aSX3, {"NT6", "NT6_CINSTA",  Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )
		Aadd(aSX3, {"NT6", "NT6_CDECPE",  Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )
		Aadd(aSX3, {"NT6", "NT6_PEDATA",  Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )
		Aadd(aSX3, {"NT6", "NT6_DTJURO",  Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )
		Aadd(aSX3, {"NT6", "NT6_CMOPED",  Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )
		Aadd(aSX3, {"NT6", "NT6_PEVLR" ,  Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Atualização do campo NSZ_CESCRI para não Obrigatorio
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO", "X3_RESERV"}

		Aadd(aSX3, {"NSZ", "NSZ_CESCRI" ,  Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(128)+ Chr(160),  Chr(158)+ Chr(128) } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//------------------------------------------------------------------------------
		//Chamado TVMY50 - Aumento da nomenclatura dos campos no agrupamento de valores
		//------------------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

		Aadd(aSX3   , {"NUZ", "NUZ_DESCPO", 30} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		// PCREQ-10944 - Atualização de Ordem da NVK
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}

		Aadd(aSx3, {"NVK", "NVK_COD"   , "02"} )
		Aadd(aSx3, {"NVK", "NVK_CGRUP" , "03"} )
		Aadd(aSx3, {"NVK", "NVK_DGRUP" , "04"} )
		Aadd(aSx3, {"NVK", "NVK_CUSER" , "05"} )
		Aadd(aSx3, {"NVK", "NVK_DUSER" , "06"} )
		Aadd(aSx3, {"NVK", "NVK_CPESQ" , "07"} )
		Aadd(aSx3, {"NVK", "NVK_PESQ"  , "08"} )
		Aadd(aSx3, {"NVK", "NVK_TIPOA" , "09"} )
		Aadd(aSx3, {"NVK", "NVK_CCORR" , "10"} )
		Aadd(aSx3, {"NVK", "NVK_CLOJA" , "11"} )
		Aadd(aSx3, {"NVK", "NVK_DCORR" , "12"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		// PCREQ-10944 - Migra informações de grupos de usuários do CFG
		// para a configuração de usuário x pesq (NVK), preenchendo o campo
		// de tipo de acesso (NVK_TIPOA) conforme o grupo do usuário. Dessa
		// forma deixará de usar o CFG.
		//-------------------------------------------------------------------
		If FWAliasInDic("NVK")
			DbSelectArea("NVK")

			If ColumnPos("NVK_TIPOA") > 0

				NVK->( dbSetOrder( 2 ) ) //NVK_FILIAL + NVK_CUSER
				NVK->( dbGoTop() )

				While NVK->(!Eof())

					If Empty(NVK->NVK_TIPOA)

						If cUser <> NVK->NVK_CUSER
							cUser  := NVK->NVK_CUSER
							cGrupo := GrpRestCFG(cUser)

							If cGrupo == "MATRIZ" .Or. Empty(cGrupo)
								cGrupo := "1"
							ElseIf cGrupo == "CLIENTES"
								cGrupo := "2"
							ElseIf cGrupo == "CORRESPONDENTES"
								cGrupo := "3"
							EndIf

						EndIf

						If !(Empty(cGrupo))
							RecLock('NVK',.F.)
								NVK->NVK_TIPOA := cGrupo
							NVK->( MsUnlock() )

							NVK->(DbSkip())
						Else
							NVK->(DbSkip())
						EndIf

					Else
						NVK->(DbSkip())
					EndIf

				EndDo

			EndIf
			NVK->(DbCloseArea())
		Endif

		//-------------------------------------------------------------------
		// PCREQ-10944 - Força atualização de consulta padrão e gatilho
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_F3", "X3_TRIGGER"}

		Aadd(aSx3, {"NZY", "NZY_CUSER", "USR", "S"} )

		//-----------------------------------------------
		//PCREQ-7560 - Atualizacoes para cadastro rapido
		//-----------------------------------------------
		AtuNzpTipo()

		AtuNz3Tipo()

		//Altera consulta Consulta padrão, para a consulta que valida restrição
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_F3"}

		Aadd(aSX3Old, {"NTA", "NTA_CAJURI", "JURNSZ"} )
		Aadd(aSX3Old, {"NT2", "NT2_CAJURI", "JURNSZ"} )
		Aadd(aSX3Old, {"NT4", "NT4_CAJURI", "JURNSZ"} )

		Aadd(aSx3, {"NTA", "NTA_CAJURI", "NSZRST"} )
		Aadd(aSx3, {"NT2", "NT2_CAJURI", "NSZRST"} )
		Aadd(aSx3, {"NT4", "NT4_CAJURI", "NSZRST"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Requisito JURJUR002 Cadastro Basico Aumento campo NQU_DESC e NUQ_DTIPAC
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

		Aadd(aSX3, {"NQU", "NQU_DESC", 120} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

		Aadd(aSX3, {"NUQ", "NUQ_DTIPAC", 120} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//Alteração de conulta padrão
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_F3"}

		Aadd(aSX3Old, {"NUQ", "NUQ_CTIPAC", "NQUNUQ"} )
		Aadd(aSx3, {"NUQ", "NUQ_CTIPAC", "NUQCNJ"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------------------------------
		//JURJUR002-13 - Atualizações para Andamentos Automáticos
		//-------------------------------------------------------------------------------------------
		Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JANDAUT", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JANDAUT", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JANDAUT", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JANDAUT", '2', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JANDAUT", '2', 'C'} )

		Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JTPANAU", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JTPANAU", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JTPANAU", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JTPANAU", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JTPANAU", '1', 'C'} )

		Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JATOAUT", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JATOAUT", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JATOAUT", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JATOAUT", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JATOAUT", '' , 'C'} )

		Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JANDEXC", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JANDEXC", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JANDEXC", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JANDEXC", '1', 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JANDEXC", '1', 'C'} )

		Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JAJUENC", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JAJUENC", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JAJUENC", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JAJUENC", '' , 'C'} )
		Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JAJUENC", '' , 'C'} )

		AtuNZ6( aNZ6Estr, aNZ6Dados  )

		//Atualiza inicializado do campo de andamentos automaticos
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO"		, "X3_RELACAO"}

		Aadd(aSX3,	 {"NUQ"		  , "NUQ_ANDAUT", "J183InAnAu()"})

		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------------------------------
		//JURJUR002-4 - Comarca CNJ
		//-------------------------------------------------------------------------------------------

		//Atualiza ordem dos campos na NUQ
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}

		Aadd(aSX3, {"NUQ", "NUQ_INSTAN" , "04"} )
		Aadd(aSX3, {"NUQ", "NUQ_INSATU" , "05"} )
		Aadd(aSX3, {"NUQ", "NUQ_CNATUR" , "06"} )
		Aadd(aSX3, {"NUQ", "NUQ_DNATUR" , "07"} )
		Aadd(aSX3, {"NUQ", "NUQ_NUMPRO" , "08"} )
		Aadd(aSX3, {"NUQ", "NUQ_NUMANT" , "09"} )
		Aadd(aSX3, {"NUQ", "NUQ_CTIPAC" , "10"} )
		Aadd(aSX3, {"NUQ", "NUQ_DTIPAC" , "11"} )

		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//Retira obrigatório e usado do campo NQC_INSTAN
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RESERV", "X3_OBRIGAT", "X3_USADO" }

		Aadd(aSX3, {"NQC", "NQC_INSTAN" , Chr(150) + Chr(192), '' , Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128)} )

		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		//Chamado TVRCJK - Tamanho do usuário de encerramento do processo
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

		Aadd(aSX3   , {"NSZ", "NSZ_USUENC", 25} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//------------------------------------------------------------------
		//Alteração da descrição do campo NSZ_DTADIT
		//-------------------------------------------------------------------//
		MJUR279()

		//------------------------------------------------------------------------------------------
		//Chamado TVYR14 - Atualiza tabela NT6 com a mesma regra de compartilhamento da tabela NSY.
		//------------------------------------------------------------------------------------------
		TVYR14()

	Endif

	If cRelStart < "014" .AND. cRelFinish >= "014"

		//----------------------------------------------
		// JURJUR002-334 - Base de Conhecimento
		//----------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

		Aadd(aSX3   , {"NUM", "NUM_CENTID", 50} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------
		// JURJUR002-95 - Consulta JurF3SXB
		// Atualização de campos para não usado
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO"}

		Aadd(aSX3, {"NUQ", "NUQ_CTPSOC", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_DTPSOC", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_CNAE"  , Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_CMUNIC", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_DMUNIC", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_LOGRAD", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_LOGNUM", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_COMPLE", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_BAIRRO", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_CEP"   , Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_INSEST", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_INSMUN", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_NIRE"  , Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_CCLIEN", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_LCLIEN", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_DCLIEN", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_NOMEFT", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_DENOM" , Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_DTCONS", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
		Aadd(aSX3, {"NUQ", "NUQ_ALVARA", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//-------------------------------------------------------------------//
		// Incluir campo NSZ_NUMCAS na nuz do perfil de licitações
		//-------------------------------------------------------------------//
		MJUR513()

	EndIf

	If cRelStart < "016" .AND. cRelFinish >= "016"

		//--------------------------------------------------------
		// JURJUR002-391 - Alteração do Valid do campo NYJ_LCLIEN
		//--------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID"}

		Aadd(aSX3   , {"NYJ", "NYJ_LCLIEN","Vazio().Or.J95VGCliUn()"} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//---------------------------------------------------------------------------
		// JURJUR002-391 - Exclusão do gatilho do campo NYJ_CCLIEN para o NYJ_LCLIEN
		//---------------------------------------------------------------------------
		DbSelectArea("SX7")
		SX7->( dbSetOrder( 1 ) )

		If SX7->( dbSeek( 'NYJ_CCLIEN' ) )
			While !SX7->( Eof() ) .And. SX7->X7_CAMPO == "NYJ_CCLIEN"
				IF SX7->X7_CDOMIN == "NYJ_LCLIEN" .And. SX7->X7_ALIAS == "SA1"
					Reclock( 'SX7', .F. )
					dbDelete()
					MsUnlock()
				Endif
				SX7->( DbSkip() )
			End
		EndIf

		//----------------------------------------------
		// MJUR-650 - Alteração do usado dos campos do
		// cadastro de Juiz
		//----------------------------------------------
		DbSelectArea("NQH")
		If ColumnPos("NQH_CCOMAR") > 0 .And. ColumnPos("NQH_CLOC2N") > 0 .And. ColumnPos("NQH_CLOC3N") > 0
			aSX3      := {}
			aSX3Old   := {}
			aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_USADO"}

			//--------------------------------------------------------------------------
			//Atualização dos campos NQH_CCOMAR, NQH_CLOC2N e NQH_CLOC3N para não usado
			//--------------------------------------------------------------------------
			Aadd(aSX3, {"NQH", "NQH_CCOMAR", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
			Aadd(aSX3, {"NQH", "NQH_DCOMAR", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
			Aadd(aSX3, {"NQH", "NQH_CLOC2N", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
			Aadd(aSX3, {"NQH", "NQH_DLOC2N", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
			Aadd(aSX3, {"NQH", "NQH_CLOC3N", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )
			Aadd(aSX3, {"NQH", "NQH_DLOC3N", Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) } )

			//Atualiza o dicionario de dados
			AtuSX3(aSX3, aSX3Estr, aSX3Old)
		EndIf

	EndIf

	If cRelStart < "017" .AND. cRelFinish >= "017"

		//-----------------------------------------------------------------------------------------
		// ISSUE JURJUR002-418 - Alteração no  INIC. BROWSE DO CAMPO NSZ_DMUNIC
		//-------------------------------------------------------------------------
		JURJUR002()

		//---------------------------------------------------------------------------------------------
		// ISSUE DJURDEP65() - Ajuste no X3_RELACAO dos campos da NSZ
		//---------------------------------------------------------------------------------------------
		DJURDEP65()

		//---------------------------------------------------------------------------------------------------------
		// ISSUE DJURDEP434() - Modififica Regra de Preenchimento de Empresa/Filial para Cadastro de Escritórios
		//---------------------------------------------------------------------------------------------------------
		DJURDEP434()

		//---------------------------------------------------------------------------------------------------------
		// ISSUE DJURDEP400() - Carrega parâmetros padrões - MV_JVLRCO E MV_JVLPROV
		//---------------------------------------------------------------------------------------------------------
		DJURDEP400()

		//---------------------------------------------------------------------------------------------------------
		// ISSUE DJURDEP539() - Efetua a Limpeza nos grids de movimentação, de garantias, despesas, objetos, andamento e follow-up
		//---------------------------------------------------------------------------------------------------------
		DJURDEP539()

		//------------------------------------------------------------------
		// alterações nos campos para que ao abrir o processo, as informações em resumo apareçam corretamente
		//-------------------------------------------------------------------//
		MJUR215()

		//---------------------------------------------------------------------------------------------
		//Limpeza do X3_RELACAO E X3_WHEN do campo NT4_CATO
		//ISSUE DJURDEP-758
		//---------------------------------------------------------------------------------------------
		DJURDEP758()

		//------------------------------------------------------------------------------------------
		//ISSUE DJURDEP-13 Campo é carregado errado ao selecionar cliente de outra filial
		//------------------------------------------------------------------------------------------
		DJURDEP13()

		//------------------------------------------------------------------------------------------
		//ISSUE DJURDEP-759 Atualiza ordem dos campos na NUQ
		//------------------------------------------------------------------------------------------
		DJURDEP759()

		//------------------------------------------------------------------
		// Altera o campo NUH_UTEBIL para deixar de ser obrigatório
		// - Chamado TUZZPB
		//-------------------------------------------------------------------//
		TVHN41()

		//-------------------------------------------------------------------------------------------
		//Chamado TVVYPF - Função para alterar a obrigatoriedade e o when do campo NTA_DTLIMT e incluir o mesmo na NUZ
		//-------------------------------------------------------------------------------------------
		TVVYPF()

		//----------------------------------------------------------
		//DJURDEP-466 - Atualiza ordem do campo NZJ_COD
		//			  - Retira obrigatoriedaqde do campo NZJ_CRELAC
		//----------------------------------------------------------
		AtuOrdem("NZJ", 3, "NZJ_COD")

		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RESERV", "X3_OBRIGAT"}

		Aadd(aSX3, {"NZJ", "NZJ_CRELAC", Chr(150) + Chr(192), ""} )

		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//--------------------------------------------------------------------------------
		// DJURFAT1-1232 - Vínculo do caso ao contrato na criação do processo no SIGAJURI
		//--------------------------------------------------------------------------------

		// Atualiza ordem do campo de contrato do assunto juridico
		DbSelectArea("NSZ")
		If ColumnPos("NSZ_CCTFAT") > 0
			AtuOrdem("NSZ", 5, "NSZ_CCTFAT")
			AtuOrdem("NSZ", 6, "NSZ_DCTFAT")
		EndIf

		//-------------------------------------------------------------------
		//DJURDEP-875 - Atualização do campo NSZ_TIPOAS do conteudo do inicializador padrão
		//-------------------------------------------------------------------
		aSX3      := {}
		aSX3Old   := {}
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

		Aadd(aSX3	, {"NSZ", "NSZ_TIPOAS", "IIF( Type('cTipoAsJ') == 'C', cTipoAsJ, '')"	})

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		//--------------------------------------------------------------
		//DJURDEP-933 - Atualiza Titulo e Descrição do campo NT4_PCLIEN
		//--------------------------------------------------------------
		DJURDEP933()

		//------------------------------------------------------------------------------------------
		//ISSUE DJURDEP-13 Campo é carregado errado ao selecionar cliente de outra filial
		//------------------------------------------------------------------------------------------
		DJURDEP13()

		//------------------------------------------------------------------------------------------
		//ISSUE DJURDEP-996 e DJURDEP-997 Andamento e Follow-up, por intancias
		//------------------------------------------------------------------------------------------
		DJURDEP996()
		DJURDEP997()

		//------------------------------------------------------------------------------------------
		//ISSUE DJURDEP-1165 Inclusão dos campos NT4_CINSTA e NTA_CINSTA em perfis que existem instancias
		//------------------------------------------------------------------------------------------
		JURDEP1165()

		//------------------------------------------------------------------------------------------
		//ISSUE DJURDEP-1033 Cadastro de Instancia - Permitir multiplas instancias ativas.
		//------------------------------------------------------------------------------------------
		JURDEP1033()

		//-------------------------------------------------------------------------------------------------
		//Defeito DJURDEP-1193 - Corrigir a regra de compartilhamento das tabelas do Fluig (NZK, NZM e NZL)
		//-------------------------------------------------------------------------------------------------
		JURDEP1193()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-1725 - Correção da mascara da O08_NUMPRO
		//------------------------------------------------------------------------------------------
		JURDEP1725()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-1210 - Substituição do termo Valores por Objetos na SX5
		//------------------------------------------------------------------------------------------
		DJURDEP1210()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-2653 - Remoção da condicao de gatilho do campo NT4_CATO  ordem 002.
		//------------------------------------------------------------------------------------------
		DJUR2653()

		//------------------------------------------------------------------------------------------
		//Preenchimento do X3_PICTVAR do campo NSZ_NUMPRO
		//------------------------------------------------------------------------------------------
		DJUR3091()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-2432 - Alteração no iniBrw e o Ini Padrao do campo NSZ_FASEPR e o tamanho do campo NSJ_FUNC
		//------------------------------------------------------------------------------------------
		DJURDEP2432()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-2694 - Altera o valor do novo campo NUV_CLMTAL para 1 que classifica todos os registros da tabela como sendo motivo de Encerramento
		//------------------------------------------------------------------------------------------
		DJURDEP2694()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-2258 - Remoção do X3_WHEN dos campos NSY_PEDATA e NSY_DTCONT e exclusão dos gatilhos NSY_PEINVL (ordem 002) e NSY_INECON (ordem 001)
		//------------------------------------------------------------------------------------------
		DJURDEP2258()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3029 - Removendo o assunto juridico Despesas da carga inicial NYB.
		//------------------------------------------------------------------------------------------
		DJURDEP3029()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3141 - Remover Picture variavel do campo O08_NUMPRO
		//------------------------------------------------------------------------------------------
		DJURDEP3141()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3215 - Ajustes nos dados das formas de correção 04/05/06/07 e alteração de campos
		//------------------------------------------------------------------------------------------
		DJURDEP3215()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3837 - Excluindo Indice 3 da tabela NVJ
		//------------------------------------------------------------------------------------------
		JURDEP3837()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3379 - Inclusão da pesquisa de Solicitação de Documento (O0M/O0N)
		//------------------------------------------------------------------------------------------
		If FWAliasInDic("O0M") .AND. FWAliasInDic("O0N")
			DJURDEP3379()
		EndIf

		//------------------------------------------------------------------------------------------
		//DJURDEP-3557 - Atualiza a ordem dos campos NSY_PEINVL\NSY_INECON
		//------------------------------------------------------------------------------------------
		JURDEP3557()

		//------------------------------------------------------------------------------------------
		//Funções descidas do fonte UMJUR001, onde é feita atualizações que ao migrar da 11 para a 12 o sistema espera que a atualização
		//Já esteja na base, o que não acontece em todos os casos,pois é possivel que a base esteja desatualizada
		//por isso, o RUP fara se não houver atualizações
		//------------------------------------------------------------------------------------------
		DJURDEP3348()

		//------------------------------------------------------------------------------------------
		//DJURDEP-3100 - Ajustando a tabela NW7 (forma de correcao - selic)
		//------------------------------------------------------------------------------------------
		JURDEP3100()

		//------------------------------------------------------------------------------------------
		//DJURDEP-3826 - Removendo Relacao da NUQ para a tabela NTA (campo NTA_CINSTA) pois nao há necessidade.
		//------------------------------------------------------------------------------------------
		JURDEP3826()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3215 - Ajustes nos dados das formas de correção 19/20/21/31
		//------------------------------------------------------------------------------------------
		DJURDEP2349()

		//------------------------------------------------------------------------------------------
		//DJURDEP-3804 - Alterando decimal e picture do campo NW6_VALOR
		//------------------------------------------------------------------------------------------
		JURDEP3804()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3798 - Ajuste no X3_WHEN do campo NSZ_DTENCE
		//------------------------------------------------------------------------------------------
		DJURDEP3798()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-3948 - Assunto Juridico - CONTENCIOSO - ADMINISTRATIVO - PR1396
		//------------------------------------------------------------------------------------------
		DJURDEP3948()

		//------------------------------------------------------------------------------------------
		//DJURDEP-3884 - Alterando o retorno da consulta padrão NYCSX2
		//------------------------------------------------------------------------------------------
		JURDEP3884()

		//------------------------------------------------------------------------------------------
		//Issue     DJURDEP-3862 - Ajuste de dados RUP_JURI da base de conhecimento
		//------------------------------------------------------------------------------------------
		DbSelectArea("NUM")
		If NUM->( FieldPos("NUM_SUBPAS") ) > 0
			JURDEP3862()
		EndIf

		//------------------------------------------------------------------------------------------
		//DJURDEP-3766 - Ordens alteradas dos campos O0S_DTINLI \ O0S_DTFILI \ O0T_DTTERM
		//------------------------------------------------------------------------------------------
		If FWAliasInDic("O0S") .AND. FWAliasInDic("O0T")
			AtuOrdem("O0S", 6, "O0S_DTINLI")
			AtuOrdem("O0S", 7, "O0S_DTFILI")
			AtuOrdem("O0T", 5, "O0T_DTTERM")
		EndIf

		//------------------------------------------------------------------------------------------
		//DJURDEP-4374 - Ajuste do CENTID para os registros da NSY com a ordem 3 (filial + codigo + cajuri)
		//------------------------------------------------------------------------------------------
		DbSelectArea("NUM")
		If !NUM->( FieldPos("NUM_SUBPAS") ) > 0
			JURDEP4374()
		EndIf

		//------------------------------------------------------------------------------------------
		//DJURDEP-4490 - Ajuste Tamanho Campo e Mascara dos campos NWB_VALOR e NWB_VALORA
		//------------------------------------------------------------------------------------------
		DJURDEP4490()

		//------------------------------------------------------------------------------------------
		//DJURDEP-4552 - Remoção do relacionamento entre a NZD e a SB1
		//------------------------------------------------------------------------------------------
		JURDEP4552()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-4447 - Ajustes nos dados das formas de correção 08/15/24/25/27/28/29/31/33/37
		//------------------------------------------------------------------------------------------
		JURDEP4447()

		//------------------------------------------------------------------------------------------
		//DJURDEP-3766 - Ordens alteradas dos campos O0S_DTINLI \ O0S_DTFILI \ O0T_DTTERM
		//------------------------------------------------------------------------------------------
		AtuOrdem("O0S", 6, "O0S_DTINLI")
		AtuOrdem("O0S", 7, "O0S_DTFILI")
		AtuOrdem("O0T", 5, "O0T_DTTERM")

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-4586 - Reordenação dos campos Ato e Fase na tela de Andamentos
		//------------------------------------------------------------------------------------------
		DJRDEP4586()

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-4720 - Alteração da restrição de acesso a despesas com título gerado
		//------------------------------------------------------------------------------------------
		DJRDEP4720()

		//------------------------------------------------------------------------------------------
		//Issue DJRDEP6195 - Gerar pedido de compras via garantia
		//------------------------------------------------------------------------------------------
		DJRDEP6195()

		//------------------------------------------------------------------------------------------
		//Issue DJRDEP4347 - Remover Picture dos campos O0U_WSDL E O0U_OPERAC
		//------------------------------------------------------------------------------------------
		DJRDEP4347()

		//------------------------------------------------------------------------------------------
		//Issue JURDEP6721 - Ajusta o valid e o campo relação
		//------------------------------------------------------------------------------------------
		JURDEP6721()

		If (FWX2Unico('NUM') == "NUM_FILIAL+NUM_COD+NUM_DOC")
			JURDEP4374()

			//------------------------------------------------------------------------------------------
			//Issue DJURDEP-8623 - Inclui o grid de causa raiz
			//------------------------------------------------------------------------------------------
			JURDEP8623()
		EndIf

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-6579 - PESQUISA AVANÇADA COM F3
		//------------------------------------------------------------------------------------------
		If !_lJDepExec
			JURDEP6579()
		EndIf

		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-8741 - Ajuste dos fundamentos que estão sem a chave do CAJURI
		//------------------------------------------------------------------------------------------
		JURDEP8741()
	EndIf

	If cRelStart < "023" .AND. cRelFinish >= "023"
		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-6422 - Ajuste na forma de correção 17 - AutEst-RJ
		//---------------------------------------------------------------------------- --------------
		DJURDEP6422()
		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-6437 - Ajuste na forma de correção 38 - SELIC-MG
		//------------------------------------------------------------------------------------------
		DJURDEP6437()
		//------------------------------------------------------------------------------------------
		//Issue DJURDEP-6497 - Ajuste na forma de correção 22 - JF-CGeral e 33 - JF-CondGeJ
		//------------------------------------------------------------------------------------------
		DJURDEP6497()

	EndIf

	If cRelStart < "027" .AND. cRelFinish >= "027"
		If cMode == "2"
			//------------------------------------------------------------------------------------------
			//Issue DJURDEP-7189 - Filial de Destino Garantias e Despesa
			//------------------------------------------------------------------------------------------
			JURDEP7189()
			
			//------------------------------------------------------------------------------------------
			//Issue DJURDEP-7325 - Sugestão de Levantamento
			//------------------------------------------------------------------------------------------
			JURDEP7325()

			//------------------------------------------------------------------------------------------
			//Issue DJURDEP-7157 - Carga inicial dos valores atualizaveis (VALOR CONTRATO)
			//------------------------------------------------------------------------------------------
			If FWAliasInDic("NW8")
				JURDEP7157()
			EndIf

			//--Ajuste no X3_VISUAL dos campos de distribuicao (NZZ_STATUS e NZZ_CAJURI).
			JURDEP8214()

			//------------------------------------------------------------------------------------------
			//Issue DJURDEP-7994 - Ajuste no tamanho do campo NUM_NUMERO (Para Docs do FLUIG)
			//------------------------------------------------------------------------------------------
			aSX3      := {}
			aSX3Old   := {}
			aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

			Aadd(aSX3   , { "NUM", "NUM_NUMERO",30 } )

			//Atualiza o dicionario de dados
			AtuSX3(aSX3, aSX3Estr, aSX3Old)

			// DJURDEP-7994 - Ajuste nos dados do campo NUM_NUMERO
			JURDEP7994()

			// DJURDEP-8134 - Ajuste no inicializador padrão dos campos de natureza da Despesa e Garantia 
			JURDEP8134()

			// DJURDEP-8740 - Remoção do relacionamento entre a CC2 e a NSZ
			JURDEP8740()

			// DJURDEP-8958 - (DÉBITOS) (SX9) Sugestão de relacionamentos
			JURDEP8958()

			// DJURDEP-9132 - (DÉBITOS) (SX9) Sugestão de relacionamentos
			JURDEP9132()

			// DJURDEP-9418 - (Débitos) Revisão final dos itens
			JURDEP9418()

			// DJURDEP-9548 - Elaboração da resposta da NIP - Modelo de Resposta
			JURDEP9548()

			// DJURDEP-9736 - Recebimento de NIPs
			JURDEP9736()

			// DJURDEP-9891 - Ajustes para NIPs
			JURDEP9891()

			// DJURDEP-11229 - Ajuste tamanho dos campos de descrição de forma de correção
			JDEP11229()
		EndIf
	EndIf

	If cRelStart < "2210" .And. cRelFinish >= "2210"
		If cMode == "1" // Execução na troca de Grupo de Empresa
			// DJURDEP-9915 - Removendo Relacao da NUQ para a tabela NSU (Campo NUQ_CAJURI+NUQ_INSTAN)
			JURDEP9915()

			// DJURDEP-10059 - Removendo relacionamentos inutilizados 
			JDEP10059()

			// DJURDEP-10267 - Removendo relacionamento inutilizado NVJ
			JDEP10267()
			
			// DJURDEP-11683 - Habilitando o auto recno da tabela NQ3
			JDEP11683()

			// DJURDEP-12037 - Removendo relacionamento inutilizado NY0
			JDEP12037()

		Else // Execução na troca de Filiais
			// DJURDEP-9435 - Inclui assunto juridico novo (NIP) e seus campos
			JURDEP9435()
		EndIf
	EndIf

	dbCommit()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSX3(aSX3)
Função para verificar quais arquivos foram alterados, e chama function de atualização.

Uso Geral

@Param aSX3 Array com alterações do arquivo SX3

@Return

@author Wellington Coelho
@since 03/03/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSX3(aSX3, aSX3Estr, aSX3Old)
Local nI	:= 0
Local nJ	:= 0
Local cKey	:= ""
/*
aSX3Estr/aSX3
[1]X3_ARQUIVO
[2]X3_CAMPO
[3]X3_RELACAO
[4]X3_WHEN
[5]X3_INIBRW
*/

	DbSelectArea("SX3")
	SX3->( DbSetOrder(2) )		//X3_CAMPO

	For nI:= 1 To Len(aSX3)

		//Posiciona no alias
		If !Empty(aSX3[nI][1])

			cKey := PadR( aSX3[nI][2], 10)

			//Procura campo
			If SX3->( DbSeek(cKey) )

				RecLock("SX3",.F.)

				For nJ:=3 To Len(aSX3[nI])		//Inicia na 3 posição porque as 2 primeiras são sempre tabela e campo
					If FieldPos(aSX3Estr[nJ]) > 0

						//Só altera se não tiver conteudo anterior ou o conteudo do campo X3_XXX atual for igual ao conteudo do release 12.1.2. Para não alterar customizações.
						If Len(aSX3Old) == 0 .OR. ( Upper(Alltrim(SX3->&(aSX3Estr[nJ]))) == Upper(Alltrim(aSX3Old[nI][nJ])) )
							//Adiciona novo valor no X3_XXX do campo
							FieldPut( FieldPos( Alltrim(CpoLingua(aSX3Estr[nJ])) ), aSX3[nI,nJ])
						EndIf
					EndIf
				Next nJ

				MsUnLock("SX3")
				dbCommit()
			EndIf
		EndIf
	Next nI

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNProAnt()
Função para preencher o campo NUQ_NUMANT, com o valor do campo NUQ_NUMPRO.
RUP_JURI

@author Rafael Tenorio da Costa
@since 01/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
	Static Function AtuNProAnt()

		Local aArea 	:= GetArea()
		Local cUpdate	:= ""
		Local cMensagem	:= ""

		DbSelectArea("SX3")
		SX3->( DbSetOrder(2) )
		If SX3->( DbSeek("NUQ_NUMANT") )

			cUpdate := "UPDATE " + RetSqlName("NUQ")
			cUpdate	+= " SET NUQ_NUMANT = NUQ_NUMPRO"
			cUpdate	+= " WHERE NUQ_FILIAL = '" + xFilial("NUQ") + "' AND NUQ_NUMANT = ' ' AND D_E_L_E_T_ = ' '"

			If TcSqlExec(cUpdate) < 0

				cMensagem := STR0003 + "NUQ_NUMANT" + Chr(13)		//"Não foi possível atualizar o campo: "
				cMensagem += STR0004 + TcSqlError()					//"Retorno do banco de dados: "

			//Verificar futuramente como adicionar mensagens de erro no UPDDISTR.
			//JurMsgErro( cMensagem )
			EndIf
		EndIf

		RestArea( aArea )

		Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNZ6( aStruct, aDadosNZ6 )
Atualiza NZ6 (Tipo de assunto juridico X Parametros)
RUP_JURI

@param	aStruct 	- Estrutura dos campos que seram atualizados
@param	aDadosNZ6	- Conteudo dos campos atualizados

@author Rafael Tenorio da Costa
@since 02/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
	Static Function AtuNZ6( aStruct, aDadosNZ6 )

		Local aArea		:= GetArea()
		Local aChave    := {}
		Local cChave    := ''
		Local cTabela   := "NZ6"
		Local nReg		:= 0
		Local nI		:= 0

		DbSelectArea("SX2")
		SX2->( DbSetOrder(1) )		//X2_CHAVE
		If SX2->( dbSeek( cTabela ) )

			aChave := StrTokArr( AllTrim(SX2->X2_UNICO), '+' )

			DbSelectArea(cTabela)
			(cTabela)->( DbSetOrder(1) )

			For nReg := 1 To Len( aDadosNZ6 )

				cChave := ''
				For nI := 1 To Len( aChave )
					cChave += aDadosNZ6[nReg][aScan( aStruct, aChave[nI] ) ]
				Next nI

				(cTabela)->( dbSetOrder(1) )
				If !(cTabela)->( dbSeek(cChave) )
					RecLock(cTabela, .T.)
						For nI := 1 To Len(aStruct)
							(cTabela)->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNZ6[nReg][nI] ) )
						Next nI
					(cTabela)->( MsUnLock() )
				EndIf
			Next nReg
		EndIf

		RestArea( aArea )

		Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNUZ( aStruct, aDadosNUZ)
Atualiza NUZ
RUP_JURI

@param	aStruct 	- Estrutura dos campos que seram atualizados
@param	aDadosNUZ	- Conteudo dos campos que seram atualizados

@author Rafael Tenorio da Costa
@since 08/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
	Static Function AtuNUZ( aStruct, aDadosNUZ)

	Local aArea		:= GetArea()
	Local aChave   	:= {}
	Local cChave   	:= ""
	Local cAlias   	:= "NUZ"
	Local nReg		:= 0
	Local nI		:= 0
	Local nPos    := 0
	Local lNUZInDic := FWAliasInDic("NUZ")

	IF lNUZInDic
		DbSelectArea("SX2")
		SX2->( DbSetOrder(1) )		//X2_CHAVE
		SX2->( dbSeek( cAlias ) )
		aChave := StrTokArr( SX2->X2_UNICO, "+" )

		DbSelectArea( cAlias )
		( cAlias )->( dbSetOrder( 1 ) )
		If !Empty(aDadosNUZ)
			For nReg := 1 To Len( aDadosNUZ )

				cChave := ''
				For nI := 1 To Len( aChave )
					If (nPos := aScan( aStruct, {|x| AllTrim(x) == AllTrim(aChave[nI])} )) > 0
						cChave += aDadosNUZ[nReg][nPos]
					EndIf
				Next nI

				( cAlias )->( dbSetOrder( 1 ) )
				If !( cAlias )->( dbSeek ( cChave ) )
					RecLock( cAlias, .T. )
					For nI := 1 To Len( aStruct )
						( cAlias )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosNUZ[nReg][nI] ) )
					Next nI
					MsUnLock()
				EndIf
			Next nReg
		EndIf
	EndIf

	RestArea( aArea )

	Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DelNUZ(cCampo,cAssunto)
Apaga registro da NUZ
RUP_JURI

@param	cCampo 		- Campo a que será deletado
@param	cAssunto	- Assunto Jurídico do campo a ser deletado

@author Marcelo Araujo Dente
@since 17/06/15
@version 1.0
/*/
//-------------------------------------------------------------------

	Static Function DelNUZ(cCampo,cAssunto)

	if FWAliasInDic("NUZ")
		DbSelectArea("NUZ")
		DbSetOrder(1)

		If DbSeek(xFilial('NUZ')+cAssunto+cCampo)
			RecLock('NUZ', .F.)
			dbDelete()
			MsUnlock()
		EndIf

		dbCommit()
	EndIf

	Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuOrdem
Libera a ordem dos campos das tabelas passadas como parametro e atualiza a ordem no SX3.
Funcao como basee da versao 11 - JurcOrdem

@author Rafael Tenorio da Costa
@since 27/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuOrdem(cTabela, nOrdem, cCampo)

	Local aArea		:= GetArea()
	Local aSX3Area	:= SX3->( GetArea() )
	Local aOrdem	:= {}
	Local aSX3Estr	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_ORDEM"}
	Local aCampos	:= {}
	Local nOldOrder	:= 0
	Local nPasso	:= 0
	Local aCpo		:= {}
	Local nX		:= 0
	Local cNewOrder := ""

	SX3->( DbSetOrder(2) )	//X3_CAMPO
	If SX3->( DbSeek( cCampo ) )

		//Carrega todos os campos da tabela
		SX3->( DbSetOrder(1) )	//X3_ARQUIVO + X3_ORDEM
		SX3->( DbSeek( cTabela ) )
		Do While SX3->( ! EoF() ) .And. SX3->X3_ARQUIVO == cTabela

			Aadd(aCampos, {SX3->X3_CAMPO, SX3->X3_ORDEM} )
			SX3->( DbSkip() )
		EndDo

		//Acerta todas as ordens caso tenha pulado alguma ou tenha ordem iguais
		For nX:= 1 To Len(aCampos)

			cNewOrder := RetAsc(Str(nX),2,.T.)

			If cNewOrder <> aCampos[nX][2]

				SX3->( DbSetOrder(2) )	//X3_CAMPO
				If SX3->( DbSeek( aCampos[nX][1] ) )

					RecLock("SX3", .F.)
					SX3->X3_ORDEM	:= cNewOrder
					aCampos[nX][2]	:= cNewOrder
					SX3->( MsUnLock() )
				EndIf
			EndIf
		Next nX

		//Pega ordem atual do campo na base
		SX3->( DbSetOrder(2) )	//X3_CAMPO
		If SX3->( DbSeek( cCampo ) )
			nOldOrder 	:= Val( RetAsc(SX3->X3_ORDEM, 2, .F.) )
			nPasso 		:= IIF(nOrdem > nOldOrder, 1, -1)
			aCpo		:= aClone( aCampos[nOldOrder] )
		EndIf

		//Carrega novas ordens
		For nX := nOldOrder To nOrdem Step nPasso

			cNewOrder := RetAsc(Str(nX),2,.T.)

			If nX == nOrdem
				aCampos[nX]   := aClone(aCpo)
				aCampos[nX,2] := cNewOrder
			Else
				If nX+nPasso <= Len(aCampos) .And. nX+nPasso >= 1
					aCampos[nX] := aClone(aCampos[nX+nPasso])
					aCampos[nX,2] := cNewOrder
				EndIf
			EndIf

			//Novas ordens
			AAdd(aOrdem, {cTabela, aCampos[nX][1], aCampos[nX][2]} )
		Next nX

		If Len( aOrdem ) > 0

			//Ordena array
			aOrdem := aSort(aOrdem,,,{|x,y| x[3] < y[3] })

			//Reposiciona os campos
			AtuSX3(aOrdem, aSX3Estr, {})
		EndIf

	EndIf

	RestArea(aSX3Area)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TSMNBJ
Função ajusta campo NYP_DATAAL, substituindo suas funcionalidades e configurações em todo seu
rastro de configuração
@author Marcelo Araujo Dente
@since 16/06/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TSMNBJ()
	If FWAliasInDic("NYP")
		DbSelectArea("NYP")
		NYP->(dbGoTop())

		While NYP->(!Eof())
			If !(Empty(NYP->NYP_DATAAL))
				RecLock('NYP',.F.)
				If CToD(NYP->NYP_DATAAL+Right(Year2Str(NYP->NYP_DATAIN),2)) > NYP->NYP_DATAIN
					NYP->NYP_DATALT := IIF( CToD(LEFT(NYP->NYP_DATAAL,6) + Year2Str(NYP->NYP_DATAIN)) > Date(), Date(), CToD( LEFT(NYP->NYP_DATAAL,6) + Year2Str(NYP->NYP_DATAIN)))
				Else
					NYP->NYP_DATALT := CToD(NYP->NYP_DATAAL+Right(Year2Str(NYP->NYP_DATAIN),2))
				Endif
				MsUnlock()
				DbSkip()
			Else
				DbSkip()
			EndIf
		End

		DbCloseArea()
	Endif
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AceiteNTA()
Atualiza valor default do campo NTA_ACEITO
RUP_JURI

@author Rafael Tenorio da Costa
@since 26/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
	Static Function AceiteNTA()

		Local aArea 	:= GetArea()
		Local cUpdate	:= ""
		Local cMensagem	:= ""

		DbSelectArea("SX3")
		SX3->( DbSetOrder(2) )		//X3_CAMPO
		If SX3->( DbSeek("NTA_ACEITO") )

			cUpdate := "UPDATE " + RetSqlName("NTA")
			cUpdate	+= " SET NTA_ACEITO = '3'"
			cUpdate	+= " WHERE NTA_FILIAL = '" + xFilial("NTA") + "' AND NTA_ACEITO = ' ' AND D_E_L_E_T_ = ' '"

			If TcSqlExec(cUpdate) < 0

				cMensagem := STR0003 + "NTA_ACEITO" + Chr(13)		//"Não foi possível atualizar o campo: "
				cMensagem += STR0004 + TcSqlError()					//"Retorno do banco de dados: "

			//Verificar futuramente como adicionar mensagens de erro no UPDDISTR.
			//JurMsgErro( cMensagem )
			EndIf
		EndIf

		RestArea( aArea )

		Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCpoNSZ()
Atualiza valores dos campos NSZ_NUMPRO, NSZ_PATIVO e NSZ_PPASSI
RUP_JURI

@author Jorge Luis Branco Martins Junior
@since 06/07/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuCpoNSZ()

	Local aArea 	:= GetArea()
	Local cTabela 	:= GetNextAlias()
	Local cQuery	:= ""

	If FWAliasInDic("NSZ")

		DbSelectArea("NSZ")
		NSZ->( DbSetOrder(1) )

		cQuery := " SELECT R_E_C_N_O_ RECNO"
		cQuery += " FROM " + RetSqlName("NSZ")
		cQuery += " WHERE NSZ_FILIAL = '" + xFilial("NSZ") + "'"
		cQuery += 	" AND NSZ_NUMPRO = '" + Space( TamSx3("NSZ_NUMPRO")[1] ) + "'"
		cQuery += 	" AND NSZ_PATIVO = '" + Space( TamSx3("NSZ_PATIVO")[1] ) + "'"
		cQuery += 	" AND NSZ_PPASSI = '" + Space( TamSx3("NSZ_PPASSI")[1] ) + "'"
		cQuery += 	" AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

		While !(cTabela)->( Eof() )

			NSZ->( DbGoTo( (cTabela)->RECNO ) )

			If !NSZ->( Eof() )
				RecLock("NSZ", .F.)
					NSZ->NSZ_NUMPRO := Posicione("NUQ", 2, xFilial("NUQ") + NSZ->NSZ_COD + "1"      , "NUQ_NUMPRO")
					NSZ->NSZ_PATIVO := Posicione("NT9", 3, xFilial("NT9") + NSZ->NSZ_COD + "1" + "1", "NT9_NOME"  )
					NSZ->NSZ_PPASSI := Posicione("NT9", 3, xFilial("NT9") + NSZ->NSZ_COD + "2" + "1", "NT9_NOME"  )
				NSZ->( MsUnlock() )
			EndIf

			(cTabela)->( DbSkip() )
		EndDo

		(cTabela)->( DbCloseArea() )
	Endif

	RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} NTECajuri
Atualiza conteudo do campo NT3_CAJURI quando o mesmo estiver vazio.
RUP_JURI

@author Reginaldo N Soares
@since 21/12/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function NTECajuri()

	Local aArea   := GetArea()
	Local cTabela := GetNextAlias()
	Local cQuery  := ""

	If FWAliasInDic("NTE")

		DbSelectArea("NTE")
		NTE->( DbSetOrder(1) )

		cQuery := " SELECT NTE.R_E_C_N_O_ RECNO, NTA.NTA_CAJURI "
		cQuery += " FROM " + RetSqlName("NTE") + " NTE INNER JOIN " + RetSqlName("NTA") + " NTA "
		cQuery += 	" ON NTE_FILIAL = NTA_FILIAL AND NTE_CFLWP = NTA_COD AND NTE.D_E_L_E_T_ = NTA.D_E_L_E_T_ "
		cQuery += " WHERE NTE_FILIAL = '" + xFilial("NTE") + "'"
		cQuery +=	" AND NTE_CAJURI = '" + Space( TamSx3("NTE_CAJURI")[1] ) + "'"
		cQuery +=	" AND NTE.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)

		While !(cTabela)->( Eof() )

			NTE->( DbGoTo( (cTabela)->RECNO ) )

			If !NTE->( Eof() )
				Reclock("NTE", .F.)
					NTE->NTE_CAJURI := (cTabela)->NTA_CAJURI
				NTE->( MsUnlock() )
			EndIf

			(cTabela)->( DbSkip() )
		EndDo

		(cTabela)->( DbCloseArea() )
	Endif

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluiSX7()
Exclui os gatilhos
RUP_JURI

@author Rafael Tenorio da costa
@since 08/12/15
@version 1.0
/*/
//-------------------------------------------------------------------
	Static Function ExcluiSX7(cCampo , cSequenc, cCDomin)

		Local aArea		:= GetArea()
		Local lRetorno 	:= .F.

		SX7->( dbSetOrder( 1 ) )		//X7_CAMPO + X7_SEQUENC

		If SX7->( DbSeek(cCampo + cSequenc) ) .And. AllTrim(SX7->X7_CDOMIN) == AllTrim(cCDomin)
			Reclock( 'SX7', .F. )
			SX7->( DbDelete() )
			SX7->( MsUnlock() )
			lRetorno := .T.
		EndIf

		RestArea( aArea )

		Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} TTVCI1()
Substituí inicializador padrão Brownser do campo NSZ_DCASO


@author Marcelo Araujo Dente
@since 28/12/15
@version 1.0
/*/
//-------------------------------------------------------------------


	Static Function TTVCI1()

		Local	aSX3      	:= {}
		Local	aSX3Old   	:= {}
		Local 	aSX3Estr  	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_INIBRW"}
		Local	lRet		:= .T.

		Aadd(aSX3, {"NSZ", "NSZ_DCASO", "JA095CASO(NSZ->NSZ_CCLIEN,NSZ->NSZ_LCLIEN,NSZ->NSZ_NUMCAS)"} )

	//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} TTUOBI()
Modifica Picture dos Campos NTA_HORA e NTA_DURACA para correta exibição em tela


@author Marcelo Araujo Dente
@since 28/12/15
@version 1.0
/*/
//-------------------------------------------------------------------


	Static Function TTUOBI()

		Local	aSX3      	:= {}
		Local	aSX3Old   	:= {}
		Local 	aSX3Estr  	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_PICTURE"}
		Local	lRet		:= .T.

		Aadd(aSX3, {"NTA", "NTA_HORA", "@R !!:!!"} )
		Aadd(aSX3, {"NTA", "NTA_DURACA", "@R !!:!!"} )

	//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TUDKTO()
Modifica o Campo de contra dominio do gatilho do campo NSZ_CSBPRO para correta exibição em tela


@author Beatriz Gomes
@since 15/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
	Static Function TUDKTO()

		Local	lRet		:= .T.

		DbSelectArea("SX7")
		SX7->( dbSetOrder( 1 ) )

		If SX7->( dbSeek( 'NSZ_CSBPRO' + '001' ) )

			Reclock( 'SX7', .F. )
			SX7->X7_CDOMIN := "NSZ_DSBPRO"
			MsUnlock()
		Endif
		SX7->( DbSkip() )


		Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TULRL2()
Substituí inicializador padrão Brownser do campo NSZ_DCASO


@author Beatriz Gomes Alves
@since 19/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------


	Static Function TULRL2()

		Local	aSX3      	:= {}
		Local	aSX3Old   	:= {}
		Local 	aSX3Estr  	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}
		Local	lRet		:= .T.

		Aadd(aSX3, {"NSZ", "NSZ_SIGLA1", "IF(!Empty(FWFldGet('NSZ_CCLIEN')),POSICIONE('RD0',1,XFILIAL('RD0')+NSZ->NSZ_CPART1,'RD0_SIGLA'),'')"} )
		Aadd(aSX3, {"NSZ", "NSZ_SIGLA2", "IF(!Empty(FWFldGet('NSZ_CCLIEN')),POSICIONE('RD0',1,XFILIAL('RD0')+NSZ->NSZ_CPART2,'RD0_SIGLA'),'')"} )
		Aadd(aSX3, {"NSZ", "NSZ_SIGLA3", "IF(!Empty(FWFldGet('NSZ_CCLIEN')),POSICIONE('RD0',1,XFILIAL('RD0')+NSZ->NSZ_CPART3,'RD0_SIGLA'),'')"} )


	//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

		Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TURLQI()
Modifica Picture dos Campos NTA_HORA e NTA_DURACA para correta exibição em tela


@author Marcelo Araujo Dente
@since 28/12/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TURLQI()

Local	aSX3      	:= {}
Local	aSX3Old   	:= {}
Local 	aSX3Estr  	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}
Local	lRet		:= .T.

Aadd(aSX3, {"NSZ", "NSZ_SIGLA1", "IIF(!EMPTY(M->NSZ_CCLIEN),POSICIONE('RD0',1,XFILIAL('RD0')+NSZ->NSZ_CPART1,'RD0_SIGLA'),'')"} )
Aadd(aSX3, {"NSZ", "NSZ_SIGLA2", "IIF(!EMPTY(M->NSZ_CCLIEN),POSICIONE('RD0',1,XFILIAL('RD0')+NSZ->NSZ_CPART2,'RD0_SIGLA'),'')"} )
Aadd(aSX3, {"NSZ", "NSZ_SIGLA3", "IIF(!EMPTY(M->NSZ_CCLIEN),POSICIONE('RD0',1,XFILIAL('RD0')+NSZ->NSZ_CPART3,'RD0_SIGLA'),'')"} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATUCONFREL()
Atualiza configuração de relatórios que foram alterados para TMSPrinter

@author Wellington Coelho
@since 16/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ATUCONFREL()
Local aTipoAs := {}
Local nI
Local lCriaConf := .T.
Local cDescNQY
//Altera configurações de relatório, campo NQY_CFGJUR de branco para não
If FWAliasInDic("NQY")
	DbSelectArea("NQY")
	NQY->(dbGoTop())
	While NQY->(!Eof())
		If NQY->NQY_CFGJUR == " " .AND. JurGetDados("NQR", 1, xFilial("NQR")+ NQY->NQY_CRPT, "NQR_EXTENS") <> '3'
			RecLock('NQY',.F.)
			NQY->NQY_CFGJUR := '2'
			MsUnlock()
		EndIf
		NQY->(DbSkip())
	EndDo
	NQY->(DbCloseArea())
EndIf


//Criar o novo relatório JURR095.PRW
If FWAliasInDic("NQR") .AND. EMPTY(JA014CODRE('JURR095' , '3'))
	DbSelectArea("NQR")
	RecLock('NQR',.T.)
	NQR->NQR_FILIAL := xFilial('NQR')
	NQR->NQR_COD    := GETSXENUM("NQR","NQR_COD")
	NQR->NQR_NOMRPT := "JURR095"
	NQR->NQR_EXTENS := '3'
	MsUnlock()
	ConfirmSX8()
	NQR->(DbCloseArea())
EndIf

If FWAliasInDic("NQR") .AND. EMPTY(JA014CODRE('JURR095M' , '3'))
	DbSelectArea("NQR")
	RecLock('NQR',.T.)
	NQR->NQR_FILIAL := xFilial('NQR')
	NQR->NQR_COD    := GETSXENUM("NQR","NQR_COD")
	NQR->NQR_NOMRPT := "JURR095M"
	NQR->NQR_EXTENS := '3'
	MsUnlock()
	ConfirmSX8()
	NQR->(DbCloseArea())
EndIf

If FWAliasInDic("NQR") .AND. EMPTY(JA014CODRE('JURR095S' , '3'))
	DbSelectArea("NQR")
	RecLock('NQR',.T.)
	NQR->NQR_FILIAL := xFilial('NQR')
	NQR->NQR_COD    := GETSXENUM("NQR","NQR_COD")
	NQR->NQR_NOMRPT := "JURR095S"
	NQR->NQR_EXTENS := '3'
	MsUnlock()
	ConfirmSX8()
	NQR->(DbCloseArea())
EndIf

If FWAliasInDic("NQR") .AND. EMPTY(JA014CODRE('JURR124' , '3'))
	DbSelectArea("NQR")
	RecLock('NQR',.T.)
	NQR->NQR_FILIAL := xFilial('NQR')
	NQR->NQR_COD    := GETSXENUM("NQR","NQR_COD")
	NQR->NQR_NOMRPT := "JURR124"
	NQR->NQR_EXTENS := '3'
	MsUnlock()
	ConfirmSX8()
	NQR->(DbCloseArea())
EndIf

//Criar a configuração do relatório

If FWAliasInDic("NQY")
	If FWAliasInDic("NQR")
		DbSelectArea("NQR")
		NQR->(dbGoTop())
		While NQR->(!Eof())
			If NQR->NQR_EXTENS == '3'
				lCriaConf := .T.
				If Alltrim(NQR->NQR_NOMRPT) == Alltrim("JURR095")
					aTipoAs := {'001','002','003','004','005','009'}
					cDescNQY := "ASSUNTOS JURIDICOS"
				ElseIf Alltrim(NQR->NQR_NOMRPT) == Alltrim("JURR095M")
					aTipoAs := {'011'}
					cDescNQY := "MARCAS E PATENTES"
				ElseIf Alltrim(NQR->NQR_NOMRPT) == Alltrim("JURR095S")
					aTipoAs := {'008'}
					cDescNQY := "SOCIETÁRIO"
				ElseIf Alltrim(NQR->NQR_NOMRPT) == Alltrim("JURR124")
					aTipoAs := {'008'}
					cDescNQY := "CONCESSÕES"
				Else
					aTipoAs := {'001'}
				EndIf

				DbSelectArea("NQY")
				NQY->(dbGoTop())
				While NQY->(!Eof())
					If NQY->NQY_CRPT == NQR->NQR_COD
						lCriaConf := .F.
					EndIf
					NQY->(DbSkip())
				EndDo

				If lCriaConf
					RecLock('NQY',.T.)
					NQY->NQY_FILIAL := xFilial('NQY')
					NQY->NQY_COD    := GETSXENUM("NQY","NQY_COD")
					NQY->NQY_DESC   := cDescNQY //Nome da configuração
					NQY->NQY_CRPT   := NQR->NQR_COD
					NQY->NQY_CFGJUR := ''

					For nI := 1 To Len(aTipoAs)
						DbSelectArea("NVL")
						RecLock('NVL',.T.)
						NVL->NVL_FILIAL := xFilial('NVL')
						NVL->NVL_CODCON := NQY->NQY_COD
						NVL->NVL_CTIPOA := aTipoAs[nI]
						NVL->(MsUnlock())
						ConfirmSX8()
					Next nI
					NQY->(MsUnlock())
					ConfirmSX8()
				EndIf
			EndIf
			NQR->(DbSkip())
		EndDo
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TVGGPL()
Modifica o agrupamento do campo NSZ_DTULAT, para que possa aparecer do agrup. de valores


@author Beatriz Gomes
@since 01/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
	Static Function TVGGPL()

	aSX3      := {}
	aSX3Old   := {}
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_AGRUP"}
	lRet 	   := .T.

	/* Novo  Conteudo*/ Aadd(aSX3   , {"NSZ", "NSZ_DTULAT", "003"} )
	/*Antigo Conteudo*/ Aadd(aSX3Old, {"NSZ", "NSZ_DTULAT", "002"} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)


	Return lRet


//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} GrpRestCFG
Verifica no configurador o grupo de acesso para restrição do SIGAJURI.

Antiga função JurGrpRest

Uso Geral.

@Return cTipo Clientes
                Correspondentes
                Matriz

@author Jorge Luis Branco Martins Junior
@since 07/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GrpRestCFG(cUser)
Local aArea  := GetArea()
Local aRet   := {}
Local nCt    := 0
Local cGrupo := ''
Local lRest  := .F.

Default cUser := __CUSERID

If !Empty(cUser)

	aRet := FWSFUsrGrps(cUser)

	For nCt:= 1 to Len(aRet)
		cGrupo:= Upper(AllTrim(FWGetNameGrp(aRet[nCt])))
		If !Empty(cGrupo)
			If cGrupo $ 'CLIENTES|CORRESPONDENTES|MATRIZ'
				lRest := .T.
				Exit
			EndIf
		EndIf
	Next
EndIf

If !lRest
	cGrupo := ''
EndIf

RestArea(aArea)

Return cGrupo

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNzpTipo()
Função para preencher o campo NZP_TIPO.

@author Rafael Tenorio da Costa
@since 	17/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuNzpTipo()

	Local aArea 	:= GetArea()
	Local cUpdate	:= ""
	Local cMensagem	:= ""

	If FWAliasInDic("NZP")

		DbSelectArea("NZP")
		If ColumnPos("NZP_TIPO") > 0

			cUpdate := " UPDATE " + RetSqlName("NZP")
			cUpdate	+= " SET NZP_TIPO = '1'"	//1=Publicacao
			cUpdate	+= " WHERE NZP_FILIAL = '" + xFilial("NZP") + "' AND NZP_TIPO = ' ' AND D_E_L_E_T_ = ' '"

			If TcSqlExec(cUpdate) < 0

				cMensagem := STR0003 + "NZP_TIPO" + Chr(13)		//"Não foi possível atualizar o campo: "
				cMensagem += STR0004 + TcSqlError()				//"Retorno do banco de dados: "

				//Verificar futuramente como adicionar mensagens de erro no UPDDISTR.
				//JurMsgErro( cMensagem )
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------

/*/{Protheus.doc} TVGHA2()
Modifica a validação e a consulta padrão do campo NT9_CCRGDP, para que ao acionar o f3 a consulta busque corretamente o cargo de funcionario


@author Beatriz Gomes
@since 10/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVGHA2()

aSX3      := {}
aSX3Old   := {}
aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID","X3_F3"}
lRet 	   := .T.

/* Novo  Conteudo*/ Aadd(aSX3   , {"NT9", "NT9_CCRGDP","Vazio().OR.( ExistCpo('SQ3',M->NT9_CCRGDP,1))", "SQ3_01"} )
/*Antigo Conteudo*/ Aadd(aSX3Old, {"NT9", "NT9_CCRGDP", "Vazio().OR.( ExistCpo('NRP',M->NT9_CCRGDP,1))", "NRP1"} )

//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuNz3Tipo()
Função para preencher o campo NZ3_TIPO.

@author Rafael Tenorio da Costa
@since 	24/06/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuNz3Tipo()

	Local aArea 	:= GetArea()
	Local cUpdate	:= ""
	Local cMensagem	:= ""

	If FWAliasInDic("NZ3")

		DbSelectArea("NZ3")
		If ColumnPos("NZ3_TIPO") > 0

			cUpdate := " UPDATE " + RetSqlName("NZ3")
			cUpdate	+= " SET NZ3_TIPO = '1'"	//1=Assunto Juridico
			cUpdate	+= " WHERE NZ3_FILIAL = '" + xFilial("NZ3") + "' AND NZ3_TIPO = ' ' AND D_E_L_E_T_ = ' '"

			If TcSqlExec(cUpdate) < 0

				cMensagem := STR0003 + "NZ3_TIPO" + Chr(13)		//"Não foi possível atualizar o campo: "
				cMensagem += STR0004 + TcSqlError()				//"Retorno do banco de dados: "

				//Verificar futuramente como adicionar mensagens de erro no UPDDISTR.
				//JurMsgErro( cMensagem )
			EndIf
		EndIf
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------

/*/{Protheus.doc} TUZZPB()
Altera o campo NUH_UTEBIL para deixar de ser obrigatório


@author Beatriz Gomes
@since 28/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TUZZPB()

aSX3      := {}
aSX3Old   := {}
aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RESERV","X3_OBRIGAT"}
lRet 	   := .T.

Aadd(aSX3   , {"NUH", "NUH_UTEBIL",Chr(150) + Chr(192),''} )

//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)


Return lRet
//-------------------------------------------------------------------

/*/{Protheus.doc} TVHN41()
Altera o campo NUH_UTEBIL para deixar de ser obrigatório


@author Beatriz Gomes
@since 28/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVHN41()
Local lRet := .T.
aSX3      := {}
aSX3Old   := {}
aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO","X3_DESCRIC"}
aSXB      := {}
aSXBEstr  := {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"}
aNUZDados := {}
aNUZEstr := {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
aNVHDados   := {}
aNVHEstr    := {"NVH_FILIAL","NVH_DESC","NVH_TABELA", "NVH_CAMPO", "NVH_TPPESQ"}

Aadd(aSX3   , {"NSZ", "NSZ_COBJET",STR0006,STR0007} )
Aadd(aSX3   , {"NSZ", "NSZ_DOBJET",STR0008,STR0009} )
Aadd(aSX3   , {"NSZ", "NSZ_DETALH",STR0010,STR0011} )
Aadd(aSx3   , {"NSZ", "NSZ_DTIPAS",STR0012,STR0013})

Aadd(aSX3   , {"NQJ", "NQJ_COBJET",STR0006,STR0007} )
Aadd(aSX3   , {"NQJ", "NQJ_DOBJET",STR0008,STR0009} )
//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)
//Atualiza SXB
Aadd(aSXB ,{"NQ4",'1','01','DB',STR0008})

AtuSXB(aSXB,aSXBEstr)

//Atualizando a descrição dos campos da NVH
DbSelectArea("NVH")
NVH->(dbGoTop())
While !NVH->(Eof())
	RecLock("NVH",.F.)
	If NVH_CAMPO == "NSZ_COBJET"
		NVH_DESC := STR0006
	ElseIF NVH_CAMPO == "NSZ_DOBJET"
		NVH_DESC := STR0008
	ElseIf NVH_CAMPO == "NSZ_DETALH"
		NVH_DESC := STR0010
	Endif
	NVH->(DbSkip())
EndDo

//atualizando a descrição dos campos da NUZ
If FWAliasInDic("NUZ")
	DbSelectArea("NUZ")
	NUZ->(dbGoTop())
	While !NUZ->(Eof())
		RecLock("NUZ",.F.)
		If NUZ_CAMPO == "NSZ_COBJET"
			NUZ_DESCPO := STR0006
		ElseIF NUZ_CAMPO == "NSZ_DOBJET"
			NUZ_DESCPO := STR0008
		ElseIf NUZ_CAMPO == "NSZ_DETALH"
			NUZ_DESCPO := STR0010
		ElseIf NUZ_CAMPO == "NSZ_DTIPAS"
			NUZ_DESCPO := STR0012
		Endif
		NUZ->(DbSkip())
	EndDo
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CpoLingua(cCampo)
Função para verificar qual linguagem está sendo utilizada

Uso Geral

@Param cCampo  campo a ser verificado

@Return

@author Beatriz Gomes
@since 03/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CpoLingua(cCampo)
Local cRet := ""
Local lSpa := __Language == 'SPANISH'
Local lEng := __Language == 'ENGLISH'

Do Case
Case cCampo $ 'X3_TITULO|X3_TITENG|X3_TITSPA'
	cRet :=  Iif(lSpa,'X3_TITSPA',Iif(lEng,'X3_TITENG','X3_TITULO'))
Case cCampo $ 'X3_DESCRIC|X3_DESCENG|X3_DESCSPA'
	cRet :=  Iif(lSpa,'X3_DESCSPA',Iif(lEng,'X3_DESCENG','X3_DESCRIC'))
	//SXB
Case cCampo $ 'XB_DESCRI|XB_DESCENG|XB_DESCSPA'
	cRet :=  Iif(lSpa,'XB_DESCSPA',Iif(lEng,'XB_DESCENG','XB_DESCRI'))
OtherWise
	cRet := cCampo
EndCase

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuSXB(aSxb,aSXBEstr)
Função para verificar quais arquivos foram alterados, e efetua a atualização.

Uso Geral

@Param aSXB Array com alterações do arquivo SXB
@Param aSXBEstr estrutura para a alteração

@Return

@author Beatriz Gomes
@since 03/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuSXB(aSXB,aSXBEstr)

Local i         := 0
Local j         := 0
Local lSXB      := .F.
Local cPergSxb  := Space(06)

dbSelectArea("SXB")
dbSetOrder(1) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA
For i:= 1 To Len(aSXB)
	If !Empty(aSXB[i][1])
		cPergSxb := aSXB[i,1] + Space(Len(XB_ALIAS) - Len(aSXB[i,1]))

		If !dbSeek(cPergSxb+aSXB[i,2]+aSXB[i,3]+aSXB[i,4])
			RecLock("SXB",.T.)
		Else
			RecLock("SXB",.F.)
		Endif

		For j:=1 To Len(aSXB[i])
			If !Empty(FieldName(FieldPos(aSXBEstr[j])))
				FieldPut(FieldPos(CpoLingua(aSXBEstr[j])),aSXB[i,j])
			EndIf
		Next j
		SXB->(dbCommit())
		SXB->(MsUnLock())
		lSXB := .T.
	EndIf
Next i

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TVGHP3 ()
Incluir campo de NT4_CINSTA - Instancia em andamentos de perfis que possuem NUQ ( Instancia )

@author Marcelo Araujo Dente
@since 	24/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVGHP3()
Local aNUZDados	:= {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet 	   := .T.
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '009' } )

	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CADITI', RetTitle( 'NT4_CADITI' ), '006' } )

	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CUNIDA', RetTitle( 'NT4_CUNIDA' ), '008' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CCONCE', RetTitle( 'NT4_CCONCE' ), '008' } )


AtuNUZ(aNUZEstr, aNUZDados)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TVGHH5 ()
Incluir campo UF no padrão nos perfis na guia de instância
@author Beatriz Gomes Alves
@since 	22/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVGHH5()
Local aNUZDados	:= {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet 	   := .T.
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_ESTADO', RetTitle( 'NUQ_ESTADO' ), '009' } )

AtuNUZ(aNUZEstr, aNUZDados)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TWBSV6 ()
Incluir campos na NUZ
@author Beatriz Gomes Alves
@since 	22/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TWBSV6()
Local aNUZDados	:= {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet 	   := .T.
//criminal
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '002' } )

//Administrativo
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT9_CODENT', RetTitle( 'NT9_CODENT' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '003' } )

//CADE
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '004' } )

//Oficios
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CATO'  , RetTitle( 'NT4_CATO' )  , '009' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DATO'  , RetTitle( 'NT4_DATO' )  , '009' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CFASE' , RetTitle( 'NT4_CFASE' ) , '009' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DFASE' , RetTitle( 'NT4_DFASE' ) , '009' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CPERIT', RetTitle( 'NT4_CPERIT' ), '009' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_DPERIT', RetTitle( 'NT4_DPERIT' ), '009' } )


AtuNUZ(aNUZEstr, aNUZDados)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} MJUR513 ()
Incluir campo NSZ_NUMCAS na nuz do perfil de licitações
@author Beatriz Gomes Alves
@since 	23/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MJUR513()
Local aNUZDados	:= {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet 	   := .T.

	aAdd( aNUZDados, { xFilial("NUZ"), 'NSZ_NUMCAS'  , RetTitle( 'NSZ_NUMCAS' )  , '010' } )

AtuNUZ(aNUZEstr, aNUZDados)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TVWWJ2()
Ajuste na condição de edição dos campos Cliente? e Fornecedor? na aba de Envolvidos


@author Marcelo Araujo Dente
@since 26/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVWWJ2()

aSX3      := {}
aSX3Old   := {}
aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_WHEN","X3_RELACAO"}
lRet 	   := .T.

/* Novo  Conteudo*/ Aadd(aSX3   , {"NT9", "NT9_TFORNE","FwFldGet('NT9_TIPOCL') == '2'",'2'} )
/*Antigo Conteudo*/ Aadd(aSX3Old, {"NT9", "NT9_TFORNE","",""} )

/* Novo  Conteudo*/ Aadd(aSX3   , {"NT9", "NT9_TIPOCL","FwFldGet('NT9_TFORNE') == '2'",'2'} )
/*Antigo Conteudo*/ Aadd(aSX3Old, {"NT9", "NT9_TIPOCL","",""} )



//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)


Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TVWGZS()

Situação/Requisito:
Alterar forma de correção dos pedidos zerar os campos de valores atualizados. / multa e juros quando existir conforme o calculo.
Solução/Implementação:
Ao mudar a forma de correção os campos valores atualizados, multa e juros são zerados


@author Marcelo Araujo Dente
@since 14/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVWGZS()
Local	aSX3      	:= {}
Local	aSX3Old   	:= {}
Local 	aSX3Estr  	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID"}
Local	lRet		:= .T.


Aadd(aSX3,{"NSY","NSY_CCOMON","(ExistCpo('NW7',M->NSY_CCOMON,1).And.JurValNW7(FwFldGet('NSY_CCOMON'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFCOR1","(ExistCpo('NW7',M->NSY_CFCOR1,1).And.JurValNW7(FwFldGet('NSY_CFCOR1'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFCOR2","(ExistCpo('NW7',M->NSY_CFCOR2,1).And.JurValNW7(FwFldGet('NSY_CFCOR2'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFCORT","(ExistCpo('NW7',M->NSY_CFCORT,1).And.JurValNW7(FwFldGet('NSY_CFCORT'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFCORC","(ExistCpo('NW7',M->NSY_CFCORC,1).And.JurValNW7(FwFldGet('NSY_CFCORC'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFCMUL","(ExistCpo('NW7',M->NSY_CFCMUL,1).And.JurValNW7(FwFldGet('NSY_CFCMUL'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_FCJURO","(ExistCpo('NW7',M->NSY_FCJURO,1).And.JurValNW7(FwFldGet('NSY_FCJURO'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFJUR1","(ExistCpo('NW7',M->NSY_CFJUR1,1).And.JurValNW7(FwFldGet('NSY_CFJUR1'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_FCJUR1","(ExistCpo('NW7',M->NSY_FCJUR1,1).And.JurValNW7(FwFldGet('NSY_FCJUR1'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFMUL2","(ExistCpo('NW7',M->NSY_CFMUL2,1).And.JurValNW7(FwFldGet('NSY_CFMUL2'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_FCJUR2","(ExistCpo('NW7',M->NSY_FCJUR2,1).And.JurValNW7(FwFldGet('NSY_FCJUR2'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFMULT","(ExistCpo('NW7',M->NSY_CFMULT,1).And.JurValNW7(FwFldGet('NSY_CFMULT'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_FCJURT","(ExistCpo('NW7',M->NSY_FCJURT,1).And.JurValNW7(FwFldGet('NSY_FCJURT'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_CFMULC","(ExistCpo('NW7',M->NSY_CFMULC,1).And.JurValNW7(FwFldGet('NSY_CFMULC'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSY","NSY_FCJURC","(ExistCpo('NW7',M->NSY_FCJURC,1).And.JurValNW7(FwFldGet('NSY_FCJURC'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NSZ","NSZ_CFCORR","(ExistCpo('NW7',M->NSZ_CFCORR,1).And.JurValNW7(FwFldGet('NSZ_CFCORR'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NT2","NT2_CCOMON","(ExistCpo('NW7',M->NT2_CCOMON,1).And.JurValNW7(FwFldGet('NT2_CCOMON'))).OR.(Vazio().And. J002ClrAtu())"})
Aadd(aSX3,{"NXY","NXY_CFCORR","(Vazio().And. J002ClrAtu()).OR.(ExistCpo('NW7',M->NXY_CFCORR,1).And.JurValNW7(M->NXY_CFCORR))"         })

//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MJUR279()
Alteração da descrição do campo NSZ_DTADIT

@author Ricardo Neves
@since 	26/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MJUR279()
	//--------------------------------------------------------------------
	//Issue MJUR-279 - Alteração da descrição do campo NSZ_DTADIT
	//---------------------------------------------------------------------------
	aSX3      := {}
	aSX3Old   := {}
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_DESCRIC"}

	Aadd(aSX3, {"NSZ", "NSZ_DTADIT", "Data assinatura contrato"	} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MJUR110()
Ajuste no gatilho do campo de cargo de envolvido NT9_CCRGDP

@author Andreia Lima
@since 	30/11/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MJUR110()
Local lRet     := .T.
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {"X3_ARQUIVO","X3_CAMPO","X3_RELACAO","X3_INIBRW"}

	DbSelectArea("SX7")
	SX7->( dbSetOrder( 1 ) )

	If SX7->( dbSeek( 'NT9_CCRGDP' + '001' ) )
		Reclock( 'SX7', .F. )
		SX7->X7_ALIAS := "SQ3"
		SX7->X7_REGRA := "SQ3->Q3_DESCSUM"
		SX7->X7_CHAVE := "xFilial('SQ3')+M->NT9_CCRGDP"
		MsUnlock()
	Endif
	SX7->( DbSkip() )

	Aadd(aSX3, {"NT9", "NT9_DCRGDP", 'IIF(!INCLUI, JURGETDADOS("SQ3", 1, xFilial("SQ3") + NT9->NT9_CCRGDP, "Q3_DESCSUM"), "")', 'JURGETDADOS("SQ3", 1, xFilial("SQ3") + NT9->NT9_CCRGDP, "Q3_DESCSUM")' } )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TVYR14()
Atualiza tabela NT6 com a mesma regra de compartilhamento da tabela NSY.

@author Rafael Tenorio da Costa
@since  21/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVYR14()

	Local aArea	    := GetArea()
	Local aAreaSX2  := SX2->( GetArea() )
	Local cModo		:= ""
	Local cModoUn	:= ""
	Local cModoEmp	:= ""

	SX2->( DbSetOrder(1) )
	If SX2->( DbSeek("NSY") )

		cModo	 := SX2->X2_MODO
		cModoUn	 := SX2->X2_MODOUN
		cModoEmp := SX2->X2_MODOEMP

		If SX2->( DbSeek("NT6") )

			RecLock("SX2", .F.)
				SX2->X2_MODO	:= cModo
				SX2->X2_MODOUN	:= cModoUn
				SX2->X2_MODOEMP	:= cModoEmp
			SX2->( MsUnLock() )
		EndIf
	EndIf

	RestArea( aAreaSX2 )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MJUR433()
Inclusão de gatilho para o campo NSZ_SITUAC

@author Beatriz Gomes
@since 	10/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MJUR433()

	DbSelectArea("SX7")
	SX7->( dbSetOrder( 1 ) )

	If !SX7->( dbSeek( 'NSZ_SITUAC' + '008' ) )
		Reclock( 'SX7', .T. )
		SX7->X7_CAMPO   := "NSZ_SITUAC"
		SX7->X7_SEQUENC := "008"
		SX7->X7_REGRA   := '""'
		SX7->X7_CDOMIN  := "NSZ_DMOENC"
		SX7->X7_CONDIC  := "M->NSZ_SITUAC == '1'"

		SX7->(MsUnlock())
	Endif
	SX7->( DbSkip() )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURJUR002()
Alteração no  INIC. BROWSE DO CAMPO NSZ_DMUNIC

@author Beatriz Gomes
@since 	13/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURJUR002()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {"X3_ARQUIVO","X3_CAMPO","X3_INIBRW"}




	Aadd(aSX3, {"NSZ", "NSZ_DMUNIC", 'Posicione("CC2",1,xFilial("CC2")+NSZ->NSZ_ESTADO+NSZ->NSZ_CMUNIC,"CC2->CC2_MUN")' } )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)




Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP65()
Ajuste no X3_RELACAO dos campos da NSZ, limpando a referência a função de incidentes


@author Beatriz Gomes Alves
@since 10/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP65()

Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO","X3_RELACAO"}
Local lRet 	   := .T.

Aadd(aSX3   , {"NSZ", 'NSZ_CAREAJ','IF(INCLUI,J095AreaC(),"")'} )
Aadd(aSX3   , {"NSZ", "NSZ_CCLIEN",""} )
Aadd(aSX3   , {"NSZ", "NSZ_LCLIEN",""} )
Aadd(aSX3   , {"NSZ", "NSZ_NUMCAS",""} )
Aadd(aSX3   , {"NSZ", "NSZ_CGRCLI",""} )
Aadd(aSX3   , {"NSZ", "NSZ_CESCRI",""} )
Aadd(aSX3   , {"NSZ", "NSZ_CSUBAR",""} )
Aadd(aSX3   , {"NSZ", "NSZ_CPART1",""} )
Aadd(aSX3   , {"NSZ", "NSZ_CPART2",""} )
Aadd(aSX3   , {"NSZ", "NSZ_CPART3",""} )



//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)


Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP434()
Modififica Regra de Preenchimento de Empresa/Filial para Cadastro de Escritórios

@return lRet
@author Marcelo Araujo Dente
@since 18/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP434()
Local lRet      := .F.
Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO","X3_VALID"}

Aadd(aSX3   , {"NS7", "NS7_CFILIA","Vazio().Or.JA068FILIA()"} )

//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP400()
Carrega parâmetros padrões

@return lRet
@author Marcelo Araujo Dente
@since 19/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP400()
Local aNZ6Dados := {}
Local aNZ6Estr  := {"NZ6_FILIAL","NZ6_TIPOAS","NZ6_CPARAM","NZ6_CONTEU","NZ6_TIPO"}
Local lRet      := .F.
Local cMVJVLRCO  := SuperGetMV("MV_JVLRCO",, "1")
Local cMVJVLPROV := SuperGetMV("MV_JVLPROV",, "1")

	Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JVLRCO" , cMVJVLRCO , 'C'} )
	Aadd(aNZ6Dados, {xFilial("NZ6"), '001', "MV_JVLPROV", cMVJVLPROV, 'C'} )

	Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JVLRCO" , cMVJVLRCO , 'C'} )
	Aadd(aNZ6Dados, {xFilial("NZ6"), '002', "MV_JVLPROV", cMVJVLPROV, 'C'} )

	Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JVLRCO" , cMVJVLRCO , 'C'} )
	Aadd(aNZ6Dados, {xFilial("NZ6"), '003', "MV_JVLPROV", cMVJVLPROV, 'C'} )

	Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JVLRCO" , cMVJVLRCO , 'C'} )
	Aadd(aNZ6Dados, {xFilial("NZ6"), '004', "MV_JVLPROV", cMVJVLPROV, 'C'} )

	Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JVLRCO" , cMVJVLRCO , 'C'} )
	Aadd(aNZ6Dados, {xFilial("NZ6"), '009', "MV_JVLPROV", cMVJVLPROV, 'C'} )

	lRet := AtuNZ6( aNZ6Estr, aNZ6Dados  )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP539(aSxb,aSXBEstr)
Função para efetuar a Limpeza nos grids de movimentação, de garantias, despesas, objetos, andamento e follow-up

@Return

@author Beatriz Gomes
@since 29/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP539()

	Local aArea     := GetArea()
	Local aAreaSX3  := SX3->( GetArea() )
	Local aTab      := {"NT2", "NT3", "NT4", "NTA", "NSY"}
	Local nTab		:= 0
	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_BROWSE"}

	Aadd(aSX3, {'NT2', "NT2_MOVFIN", "S"} )
	Aadd(aSX3, {'NT2', "NT2_DTPGAR", "S"} )
	Aadd(aSX3, {'NT2', "NT2_DATA"  , "S"} )
	Aadd(aSX3, {'NT2', "NT2_VALOR" , "S"} )
	Aadd(aSX3, {'NT2', "NT2_PATIVO", "S"} )
	Aadd(aSX3, {'NT2', "NT2_PPASSI", "S"} )
	Aadd(aSX3, {'NT2', "NT2_NUMPRO", "S"} )
	Aadd(aSX3, {'NT2', "NT2_DESC"  , "S"} )
	Aadd(aSX3, {'NT3', "NT3_DTPDES", "S"} )
	Aadd(aSX3, {'NT3', "NT3_DATA"  , "S"} )
	Aadd(aSX3, {'NT3', "NT3_VALOR" , "S"} )
	Aadd(aSX3, {'NT3', "NT3_PATIVO", "S"} )
	Aadd(aSX3, {'NT3', "NT3_PPASSI", "S"} )
	Aadd(aSX3, {'NT3', "NT3_NUMPRO", "S"} )
	Aadd(aSX3, {'NT3', "NT3_DESC"  , "S"} )
	Aadd(aSX3, {'NT4', "NT4_DTANDA", "S"} )
	Aadd(aSX3, {'NT4', "NT4_DFASE" , "S"} )
	Aadd(aSX3, {'NT4', "NT4_DATO"  , "S"} )
	Aadd(aSX3, {'NT4', "NT4_PATIVO", "S"} )
	Aadd(aSX3, {'NT4', "NT4_PPASSI", "S"} )
	Aadd(aSX3, {'NT4', "NT4_NUMPRO", "S"} )
	Aadd(aSX3, {'NT4', "NT4_DESC"  , "S"} )
	Aadd(aSX3, {'NTA', "NTA_DTORIG", "S"} )
	Aadd(aSX3, {'NTA', "NTA_DTFLWP", "S"} )
	Aadd(aSX3, {'NTA', "NTA_DPREPO", "S"} )
	Aadd(aSX3, {'NTA', "NTA_DRESUL", "S"} )
	Aadd(aSX3, {'NTA', "NTA_PATIVO", "S"} )
	Aadd(aSX3, {'NTA', "NTA_PPASSI", "S"} )
	Aadd(aSX3, {'NTA', "NTA_NUMPRO", "S"} )
	Aadd(aSX3, {'NTA', "NTA_DESC"  , "S"} )
	Aadd(aSX3, {'NTA', 'NTA_DTIPO' , "S"} )
	Aadd(aSX3, {'NTA', 'NTA_HORA'  , "S"} )
	Aadd(aSX3, {'NSY', "NSY_DPEVLR", "S"} )
	Aadd(aSX3, {'NSY', "NSY_PEDATA", "S"} )
	Aadd(aSX3, {'NSY', "NSY_PATIVO", "S"} )
	Aadd(aSX3, {'NSY', "NSY_PPASSI", "S"} )
	Aadd(aSX3, {'NSY', "NSY_NUMPRO", "S"} )
	Aadd(aSX3, {'NSY', "NSY_PEVLRA", "S"} )
	Aadd(aSX3, {'NSY', "NSY_DESC"  , "S"} )
	Aadd(aSX3, {'NSY', 'NSY_DPROG' , "S"} )
	Aadd(aSX3, {'NSY', 'NSY_PEVLR' , "S"} )
	Aadd(aSX3, {'NSY', 'NSY_TOTPED', "S"} )
	Aadd(aSX3, {'NSY', 'NSY_DBASED', "S"} )

	//Carrea campos com X3_BROWSE = N
	DbSelectArea("SX3")
	SX3->( DbSetOrder(1) )	//X3_ARQUIVO+X3_ORDEM
	For nTab:=1 To Len(aTab)

		If SX3->( DbSeek(aTab[nTab]) )

			Do While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == aTab[nTab]

				If SX3->X3_BROWSE <> "N" .And. Ascan(aSX3, {|x| x[2] == AllTrim(SX3->X3_CAMPO)}) == 0
					Aadd(aSX3, {SX3->X3_ARQUIVO, SX3->X3_CAMPO, "N"} )
				EndIf

				SX3->( dbSkip() )
			Enddo
		EndIf
	Next nTab

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

	aSX3     	:= {}
	aSX3Old		:= {}
	aSX3Estr	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_INIBRW"}

	Aadd(aSX3, {'NSY', 'NSY_TOTPED', 'JurCalcTotal(NSY->NSY_PEVLR,NSY->NSY_VLRMUL,NSY->NSY_VLRJUR)'} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

	RestArea(aAreaSX3)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MJUR215 ()
Alterações nos campos para que ao abrir o processo, as informações em resumo apareçam corretamente
@author Beatriz Gomes Alves
@since 	22/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MJUR215()
Local aSX3     	:= {}
Local aSX3Old		:= {}
Local aSX3Estr	:= {"X3_ARQUIVO","X3_CAMPO","X3_RELACAO","X3_INIBRW"}

//            {        "X3_ARQUIVO"   ,"X3_CAMPO"   , "X3_RELACAO"                                                                           , "X3_INIBRW"}
	//NSZ
	aAdd(aSX3,   {"NSZ", "NSZ_DCOMAR","IF(!INCLUI,JUR183CCOM(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CCOMAR')),'')","JUR183CCOM(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CCOMAR'))"})
	aAdd(aSX3,   {"NSZ", "NSZ_DLOC2N","IF(!INCLUI,JUR183CL2N(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CLOC2N')),'')","JUR183CL2N(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CLOC2N'))"})
	aAdd(aSX3,   {"NSZ", "NSZ_DLOC3N","IF(!INCLUI,JUR183CL3N(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CLOC3N')),'')","JUR183CL3N(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CLOC3N'))"})
	aAdd(aSX3,   {"NSZ", "NSZ_DNATUR","IF(!INCLUI,JUR183CNAT(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CNATUR')),'')","JUR183CNAT(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CNATUR'))"})
	aAdd(aSX3,   {"NSZ", "NSZ_DTIPAC","IF(!INCLUI,JUR183CTPA(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CTIPAC')),'')","JUR183CTPA(POSICIONE('NUQ',2,NSZ->NSZ_FILIAL+NSZ->NSZ_COD+'1','NUQ_CTIPAC'))"})

	//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP13
Campo é carregado errado ao selecionar cliente de outra filial

@author Marcelo Araujo Dente
@since  05/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP13()
Local aGatCamp := {{'NYJ_LCLIEN','001'},{'NYJ_LCLIEN','002'},{'NYJ_LCLIEN','003'},{'NYJ_LCLIEN','004'},{'NYJ_CMUNIC','001'} }
Local nI := 1

DbSelectArea("SX7")
SX7->( dbSetOrder( 1 ) )
While nI <= Len(aGatCamp)
	If SX7->( dbSeek( aGatCamp[nI][1] + aGatCamp[nI][2]))
		Reclock( 'SX7', .F. )
		SX7->X7_SEEK := 'S'
		MsUnlock()
	Endif
	SX7->( DbSkip() )
	nI++
EndDo

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP-758 ()
Limpeza do X3_RELACAO E X3_WHEN do campo NT4_CATO
@author Beatriz Gomes Alves
@since 	27/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP758()
Local aSX3     	:= {}
Local aSX3Old		:= {}
Local aSX3Estr	:= {"X3_ARQUIVO","X3_CAMPO","X3_RELACAO","X3_WHEN"}

	aAdd(aSX3,   {"NT4", "NT4_CATO","",""})

//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP759
//Atualiza ordem dos campos na NUQ

@author Beatriz Gomes
@since  20/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP759()

	AtuOrdem("NUQ",04, "NUQ_INSTAN")
	AtuOrdem("NUQ",05, "NUQ_INSATU")
	AtuOrdem("NUQ",06, "NUQ_CNATUR")
	AtuOrdem("NUQ",07, "NUQ_DNATUR")
	AtuOrdem("NUQ",08, "NUQ_NUMPRO")
	AtuOrdem("NUQ",09, "NUQ_NUMANT")
	AtuOrdem("NUQ",10, "NUQ_CTIPAC")
	AtuOrdem("NUQ",11, "NUQ_DTIPAC")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP933
Atualiza Titulo e Descrição do campo NT4_PCLIEN

@author  Rafael Tenorio da Costa
@since   28/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP933()

	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO"	, "X3_TITULO", "X3_DESCRIC", "X3_RELACAO"																		}
	Local aSX3Old   := {{"NT4"		, "NT4_PCLIEN"	, STR0014	 , STR0015	   , '"2"'		   																		}}	//"P/ Cliente?"		//"Aparece Para Cliente?"
	Local aSX3      := {{"NT4"		, "NT4_PCLIEN"	, STR0016	 , STR0017	   , "IIF( 'CLIENTES' $ JurGrpRest() .Or. 'CORRESPONDENTES' $ JurGrpRest(), '1', '2')"	}}	//"Público ?"		//"Andamento será Público ?"

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP996 ()
Incluir campo de NT4_NMPROC- Numero de processo de acordo com a Instancia
seleconada, em andamentos de perfis que possuem NUQ ( Instancia )


@author Beatriz Gomes
@since 	20/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP996()
Local aNUZDados	:= {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet 	   := .T.


	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_NMPROC', RetTitle( 'NT4_NMPROC' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_NMPROC', RetTitle( 'NT4_NMPROC' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_NMPROC', RetTitle( 'NT4_NMPROC' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_NMPROC', RetTitle( 'NT4_NMPROC' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_NMPROC', RetTitle( 'NT4_NMPROC' ), '009' } )

	AtuNUZ(aNUZEstr, aNUZDados)

	AtuOrdem("NT4", 46, "NT4_NMPROC")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP997 ()
Incluir campo de NTA_NMPROC- Numero de processo de acordo com a Instancia
seleconada, em follow-ups de perfis que possuem NUQ ( Instancia )


@author Beatriz Gomes
@since 	20/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP997()
Local aNUZDados	:= {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet 	   := .T.


	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_NMPROC', RetTitle( 'NTA_NMPROC' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_NMPROC', RetTitle( 'NTA_NMPROC' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_NMPROC', RetTitle( 'NTA_NMPROC' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_NMPROC', RetTitle( 'NTA_NMPROC' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_NMPROC', RetTitle( 'NTA_NMPROC' ), '009' } )


AtuNUZ(aNUZEstr, aNUZDados)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP1165()
Incluir campo NTA_CINSTA E NT4_CINSTA - Codigo Instancia nos perfis que possuem NUQ ( Instancia )


@author Beatriz Gomes
@since 	20/07/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP1165()
Local aNUZDados	:= {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet 	   := .T.


	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NT4_CINSTA', RetTitle( 'NT4_CINSTA' ), '009' } )

	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_CINSTA', RetTitle( 'NTA_CINSTA' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_CINSTA', RetTitle( 'NTA_CINSTA' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_CINSTA', RetTitle( 'NTA_CINSTA' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_CINSTA', RetTitle( 'NTA_CINSTA' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_CINSTA', RetTitle( 'NTA_CINSTA' ), '009' } )


AtuNUZ(aNUZEstr, aNUZDados)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP1033 ()
Cadastro de Instancia - Permitir multiplas instancias ativas.


@author Beatriz Gomes
@since 	07/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP1033()

	Local aNUZDados	:= {}
	Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
	Local lRet 	    := .T.
	Local aSX3     	:= {}
	Local aSX3Old	:= {}
	Local aSX3Estr	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO", "X3_DESCRIC"}

	//-	Alteração do descritivo do campo NUQ_INSATU
	aAdd(aSX3, {"NUQ", "NUQ_INSATU", "Instân Ori", "Instância Origem"})

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

	//Atualização da ordem dos campos
	AtuOrdem("NUQ", 10, "NUQ_DTDIST")
	AtuOrdem("NUQ", 11, "NUQ_DTENC")
	AtuOrdem("NUQ", 12, "NUQ_STATUS")

	//Inclusão do campo na nuz
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_DTENC', RetTitle( 'NUQ_DTENC' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_DTENC', RetTitle( 'NUQ_DTENC' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_DTENC', RetTitle( 'NUQ_DTENC' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_DTENC', RetTitle( 'NUQ_DTENC' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_DTENC', RetTitle( 'NUQ_DTENC' ), '009' } )

	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_STATUS', RetTitle( 'NUQ_STATUS' ), '001' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_STATUS', RetTitle( 'NUQ_STATUS' ), '002' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_STATUS', RetTitle( 'NUQ_STATUS' ), '003' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_STATUS', RetTitle( 'NUQ_STATUS' ), '004' } )
	aAdd( aNUZDados, { xFilial("NUZ"), 'NUQ_STATUS', RetTitle( 'NUQ_STATUS' ), '009' } )

	AtuNUZ(aNUZEstr, aNUZDados)

	//Atualiza o inicializadores do campo NUQ_STATUS
	aSX3      := {}
	aSX3Old   := {}
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO", "X3_INIBRW"}

	Aadd(aSX3, {"NUQ", "NUQ_STATUS", "J183StaIns()", "J183StaIns()"} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TVVYPF()
Função para alterar a obrigatoriedade do campo NTA_DTLIMT e incluir o mesmo na NUZ

@author Beatriz Gomes Alves
@since 	31/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TVVYPF()
Local lRet 		:= .T.
Local aNUZDados := {}
Local aNUZEstr	:= {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local aSX3Old   := {}
Local aSX3 		:= {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO","X3_WHEN"}

//Alteração de obrigatoriedade do campo NTA_DTLIMT
Aadd(aSX3, {"NTA", "NTA_DTLIMT" ,' '} )

//Atualiza o dicionario de dados
AtuSX3(aSX3, aSX3Estr, aSX3Old)

dbSelectArea("NYB")
NYB->(dbGoTop())

While NYB->(!Eof())
//verifica se é contencioso ou filho do contencioso para colocar na NUZ pois ele deixa de ser obrigatorio
	If NYB->NYB_COD == '001' .OR. NYB->NYB_CORIG =='001'
		DbSelectArea("NUZ")
		NUZ->( dbSetOrder( 1 ) )
		If NUZ->(dbSeek('NTA_DTLIMT'))
			lRet := .F.
		endif
		if lRet
			aAdd( aNUZDados, { xFilial("NUZ"), 'NTA_DTLIMT', RetTitle( 'NTA_DTLIMT' ),NYB->NYB_COD } )
			AtuNUZ(aNUZEstr, aNUZDados)
		endif
		NUZ ->( DbSkip() )
	EndIf
	NYB->(DbSkip())
EndDo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP1193()
Atualiza regra de ccompartilhamento das tabelas NZK, NKM e NZL a partir da NTA e NT4.
@since   21/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP1193()

	Local aArea	    := GetArea()
	Local aAreaSX2  := SX2->( GetArea() )
	Local cModo		:= ""
	Local cModoUn	:= ""
	Local cModoEmp	:= ""

	SX2->( DbSetOrder(1) )
	If SX2->( DbSeek("NTA") )

		cModo	 := SX2->X2_MODO
		cModoUn	 := SX2->X2_MODOUN
		cModoEmp := SX2->X2_MODOEMP

		If SX2->( DbSeek("NZK") )

			RecLock("SX2", .F.)
				SX2->X2_MODO	:= cModo
				SX2->X2_MODOUN	:= cModoUn
				SX2->X2_MODOEMP	:= cModoEmp
			SX2->( MsUnLock() )
		EndIf

		If SX2->( DbSeek("NZM") )

			RecLock("SX2", .F.)
				SX2->X2_MODO	:= cModo
				SX2->X2_MODOUN	:= cModoUn
				SX2->X2_MODOEMP	:= cModoEmp
			SX2->( MsUnLock() )
		EndIf
	EndIf

	SX2->( DbSetOrder(1) )
	If SX2->( DbSeek("NT4") )

		cModo	 := SX2->X2_MODO
		cModoUn	 := SX2->X2_MODOUN
		cModoEmp := SX2->X2_MODOEMP

		If SX2->( DbSeek("NZL") )

			RecLock("SX2", .F.)
				SX2->X2_MODO	:= cModo
				SX2->X2_MODOUN	:= cModoUn
				SX2->X2_MODOEMP	:= cModoEmp
			SX2->( MsUnLock() )
		EndIf
	EndIf

	RestArea( aAreaSX2 )
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP1725()
Correção da mascara da O08_NUMPRO
@since   24/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP1725()

	Local aSX3     	:= {}
	Local aSX3Old	:= {}
	Local aSX3Estr	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO", "X3_DESCRIC"}

	//Atualiza o inicializador do campo O08_NUMPRO
	aSX3      := {}
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO", "X3_PICTVAR"}

	Aadd(aSX3, {"O08", "O08_NUMPRO", "", "J233PRO()"} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

	//Atualiza oS inicializadores dos campos O08_UFVARA e O08_IDVARA
	aSX3      := {}
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

	Aadd(aSX3, {"O08", "O08_UFVARA", ""} )
	Aadd(aSX3, {"O08", "O08_IDVARA", ""} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP1210
Substituição de termo na tabela genérica JX da SX5
@since   05/12/2017
@version 1.0

Função X5DESCRIC

//Atualiza a descrição na tabela genérica JX da SX5 na chave 06 que passa a ter a denominação Objetos (antigo Valores)
/*/
//-------------------------------------------------------------------
Static Function DJURDEP1210()
Local aArea	    := GetArea()
Local aAreaSX5  := SX5->( GetArea() )

DbSelectArea("SX5")
SX5->( DbSetOrder(1) )
If SX5->(dbSeek(xFilial("SX5")+"JX"+"06"))

	RecLock("SX5", .F.)

	SX5->X5_DESCSPA := "Objetos"
	SX5->X5_DESCENG := "Objects"
	SX5->X5_DESCRI  := "Objetos"

	SX5->( MsUnLock() )

EndIf

RestArea( aAreaSX5 )
RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP-2653()
Remoção da condicao de gatilho do campo NT4_CATO ordem 002.

@author  Rafael Tenorio da Costa
@since 	 06/03/18
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function DJUR2653()

	Local aArea    := GetArea()
	Local aAreaSX7 := SX7->( GetArea() )

	DbSelectArea("SX7")
	SX7->( DbSetOrder(1) )	//X7_CAMPO + X7_SEQUENC

	If SX7->( DbSeek(PadR("NT4_CATO", 10) + "002") ) .And. AllTrim(SX7->X7_CDOMIN) == "NT4_CFASE"
		Reclock("SX7", .F.)
			SX7->X7_CONDIC := ""
		SX7->( MsUnlock() )
	Endif

	RestArea(aAreaSX7)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP-3091()
Preenchimento do X3_PICTVAR do campo NSZ_NUMPRO

@author  leandro.silva
@since 	 07/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJUR3091()

      Local aArea    := GetArea()
      Local aAreaSX3 := SX3->( GetArea() )

      DbSelectArea("SX3")
      SX3->( dbSetOrder( 2 ) )                 //X3_CAMPO

      If SX3->( dbSeek( 'NSZ_NUMPRO' ) )
            Reclock("SX3", .F.)
                  SX3->X3_PICTVAR := "JU183MNPRO()"
            SX3->( MsUnlock() )
      Endif

      RestArea(aAreaSX3)
      RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP2432()
Exibição da fase processual na tela principal de Assunto Jurídico.


@author Beatriz Gomes
@since 	08/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP2432()

	Local lRet      := .T.
	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO", "X3_INIBRW"}

	//Atualiza o IniBrw e o IniPadrao do campo NSZ_FASEPR
	Aadd(aSX3, {"NSZ", "NSZ_FASEPR", "JURA100Fase()", "JURA100Fase()"} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

	//Atualiza o tamanho do campo NSJ_FUNC
	aSX3      := {}
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

	Aadd(aSX3, {"NZJ", "NZJ_FUNC", 10} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP2694()
Aletara o conteudo do campo NUV_CLMTAL para "1".

@author Reginaldo Soares
@since 	22/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP2694()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {"X3_ARQUIVO","X3_CAMPO","X3_BROWSE"}

//Preenche o campo NUV_CLMTAL e NQX_CLMTAL com o valor 1 que classifica o motivo da alteração como de Encerramento;
//pois o motivo 2 que se refere a valor envolvido até implantação dessa issue não existia

	DbSelectArea("NUV")
	If ColumnPos("NUV_CLMTAL") > 0
		NUV->(dbGoTop())

		While NUV->(!Eof())

			RecLock('NUV',.F.)
				NUV->NUV_CLMTAL := IIf (Empty(NUV->NUV_CLMTAL),'1',NUV->NUV_CLMTAL)
			MsUnlock()

			NUV->(DbSkip())
		EndDo

		//Atualiza ordem do campo NUV_CLMTAL para antes do campo de CAJURI
		AtuOrdem("NUV", 03, "NUV_CLMTAL")

	Endif

	//Atribue "N" para X3_BROWSE DOS CAMPOS
	//-------------------------------------------------------------------
	Aadd(aSX3, {"NUV", "NUV_COD", "N"} )
	Aadd(aSX3, {"NUV", "NUV_CAJURI", "N"} )
	Aadd(aSX3, {"NUV", "NUV_CMOTIV", "N"} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

	DbSelectArea("NQX")
	If ColumnPos("NQX_CLMTAL") > 0
		NQX->(dbGoTop())

		While NQX->(!Eof())
				RecLock('NQX',.F.)
				NQX->NQX_CLMTAL := IIf (Empty(NQX->NQX_CLMTAL),'1',NQX->NQX_CLMTAL)
			MsUnlock()

			NQX->(DbSkip())
		EndDo
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP2258()
Retirando X3_WHEN do campo NSY_PEDATA e NSY_DTCONT e exclusao de gatilhos

@author leandro.silva
@since 	02/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP2258()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {"X3_ARQUIVO","X3_CAMPO","X3_WHEN"}
Local lRet 	   := .T.

	//Retirando X3_WHEN do campo NSY_PEDATA e NSY_DTCONT
	Aadd(aSX3   , {"NSY", "NSY_PEDATA", ""} )
	Aadd(aSX3   , {"NSY", "NSY_DTCONT", ""} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

	//exclusao do gatilho do campo NSY_PEINVL (ordem 002)
	SX7->( dbSetOrder( 1 ) )		//X7_CAMPO + X7_SEQUENC
	If SX7->( DbSeek("NSY_PEINVL" + "002") )
		Reclock( "SX7", .F. )
			SX7->X7_CONDIC := ""
		SX7->( MsUnlock() )
	EndIf
	ExcluiSX7("NSY_PEINVL" , "002", "NSY_PEDATA")            //(cCampo , cSequenc, cCDomin)

	//exclusao do gatilho do campo NSY_INECON (ordem 001)
	SX7->( dbSetOrder( 1 ) )		//X7_CAMPO + X7_SEQUENC
	If SX7->( DbSeek("NSY_INECON" + "001") )
		Reclock( "SX7", .F. )
			SX7->X7_CONDIC := ""
		SX7->( MsUnlock() )
	EndIf
	ExcluiSX7("NSY_INECON" , "001", "NSY_DTCONT")            //(cCampo , cSequenc, cCDomin)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3029()
Removendo o assunto juridico Despesas da carga inicial NYB.

@author  Rafael Tenorio da Costa
@since 	 14/03/2018
@version 2.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP3029()

	Local aArea := GetArea()

	DbSelectArea("NYB")
	NYB->( DbSetOrder(1) )	//NYB_FILIAL+NYB_COD

	If NYB->( DbSeek(xFilial("NYB") + "012") )	//Despesas
		Reclock("NYB", .F.)
			NYB->( dbDelete() )
		NYB->( MsUnlock() )
	Endif

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3141()
Remover Picture variavel do campo O08_NUMPRO

@author marcelo.dente
@since 	06/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function  DJURDEP3141()
Local lRet 	   := .T.
Local aArea	    := GetArea()

DbSelectArea("SX3")
SX3->( dbSetOrder( 2 ) )			//X3_CAMPO
If SX3->( dbSeek( 'O08_NUMPRO' ) )
	Reclock( 'SX3', .F. )
	SX3->X3_PICTVAR :=''
	MsUnlock()
Endif

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3215()
Ajustando a tabela NW7 E NWS de correção monetária, para o padrão.

@author Beatriz Gomes
@since 	06/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP3215()

	Local aArea := GetArea()
	Local aCorr := {}
	Local nI := 0
	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {}

	DbSelectArea("NWS")
	If NWS->( FieldPos("NWS_TIPJUR") ) > 0

		aAdd( aCorr, {'05'/*For Corr*/,/*Percentual*/ 1.0,CTOD('')        ,CTOD(''),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
		aAdd( aCorr, {'06'/*For Corr*/,/*Percentual*/ 0.5,CTOD('')        ,STOD('20030110'),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
		aAdd( aCorr, {'06'/*For Corr*/,/*Percentual*/ 1.0,STOD('20030111'),CTOD(''),/*Tp Juros*/"1",/*Pro-rata*/"1"} )
		aAdd( aCorr, {'07'/*For Corr*/,/*Percentual*/ 1.0,CTOD('')        ,CTOD(''),/*Tp Juros*/"2",/*Pro-rata*/"1"} )

		//Ajustando a formula das correçoes monetárias que usam a função VALORPTJ
		dbSelectArea("NW7")
		NW7->( dbSetOrder( 1 ) )
		dbSelectArea("NWS")
		NWS->( dbSetOrder( 1 ) )

		For nI := 1 To Len(aCorr)
			//EXCLUI O REGISTRO QUE JÁ EXISTE
			If NWS->( DbSeek(xFilial("NWS") + aCorr[nI][1]) )
				Reclock( 'NWS', .F. )
				NWS->( dbDelete() )
				NWS-> (MsUnLock())
			EndIF
		Next
		For nI := 1 To Len(aCorr)
			If NW7->( DbSeek(xFilial("NW7") + aCorr[nI][1]) )

				Reclock( 'NW7', .F. )
					NW7->NW7_FORMUL := "FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',#DTJUROS)"
				NW7->( MsUnLock() )

				//Incluindo o novo registro no grid
				Reclock( 'NWS', .T. )
					NWS->NWS_FILIAL := xFilial("NWS")
					NWS->NWS_CFCORR := aCorr[nI][1]
					NWS->NWS_PERCEN := aCorr[nI][2]
					NWS->NWS_DTINI  := aCorr[nI][3]
					NWS->NWS_DTFIM  := aCorr[nI][4]
					NWS->NWS_TIPJUR := aCorr[nI][5]
					NWS->NWS_PRORAT := '1'
				NWS-> ( MsUnLock() )

			Endif
		Next

		//Limpando o X3_WHEN da tabela NWS
		aSX3Estr := {"X3_ARQUIVO","X3_CAMPO","X3_WHEN"}

		aAdd(aSX3,   {'NWS', 'NWS_CFCORR',""})
		aAdd(aSX3,   {'NWS', 'NWS_PERCEN',""})
		aAdd(aSX3,   {'NWS', 'NWS_DTINI' ,""})
		aAdd(aSX3,   {'NWS', 'NWS_DTFIM' ,""})

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
		aSX3 := {}

		//Alterando o campo NWS_PERCEN
		aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO","X3_DECIMAL","X3_PICTURE"}

		Aadd(aSX3, {"NWS", "NWS_PERCEN", 15, 4, '@E 999,999,999.9999'} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	aSize(aCorr, 0)
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JurDep3379()
Inclusão da Pesquisa da Solicitação de Documentos

@since 	 21/03/2018
@author willian.kazahaya
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP3379()
Local aArea          := GetArea()
Local aChave         := {}
Local cFilTab        := '        ' // 'D MG 01 ' (08) Espaços
Local nLins          := 0
Local aCols, aAssJur := {}
Local aNomAssJur     := {}
Local cStrSolic      := STR0030 //S.Doctos
Local cNomTabO0M     := RetSqlName('O0M')
Local cNomTabO0N     := RetSqlName('O0N')
Local cNomTab        := ''
Local nTam           := Len(SX3->X3_CAMPO)
Local cCPesq         := ''
Local cAlias         := ''
Local cNVJCPesq      := ''

// Dados e Estruturas
Local aDadosNVH   := {}
Local aDadosNVG   := {}
Local aDadosNVJ   := {}
Local aStructNVH  := {}
Local aStructNVG  := {}
Local aStructNVJ  := {}

	// Campos a serem inseridos
	aCols 		:= {'O0M_CAJURI','O0M_COD   ','O0M_DTSOLI','O0N_CTPDOC','O0N_STATUS'}

	// Assuntos Juridicos
	//aNomAssJur ={Contencioso,Criminal,Administrativo,Cade   ,Consultivo,Contratos,Procurações,Societário,Ofícios,Licitações,Marcas e Patentes}
	aNomAssJur	:= 	{STR0018    ,STR0019 ,STR0020       ,STR0021,STR0022   ,STR0023  ,STR0024    ,STR0025   ,STR0026,STR0027   ,STR0028          }
	aAssJur 	:= {'001','002','003','004','005','006','007','008','009','010','011'}

	// Index a ser usado
	SX2->( dbSetOrder( 1 ) )

	//------------------------------------------------------------
	// Configuraçao da Tela e Campos da Pesquisa de Processos
	//------------------------------------------------------------
	cAlias := 'NVH'
	DbSelectArea(cAlias)
	SX2->( dbSeek( cAlias ) )
	aChave := StrToArray( SX2->X2_UNICO, '+' )
	cFilTab := xFilial(cAlias)

	aAdd( aStructNVH, 'NVH_FILIAL' )
	aAdd( aStructNVH, 'NVH_COD'    )
	aAdd( aStructNVH, 'NVH_DESC'   )
	aAdd( aStructNVH, 'NVH_TABELA' )
	aAdd( aStructNVH, 'NVH_CAMPO'  )
	aAdd( aStructNVH, 'NVH_WHERE'  )
	aAdd( aStructNVH, 'NVH_PROPRI' )
	aAdd( aStructNVH, 'NVH_F3DIF'  )
	aAdd( aStructNVH, 'NVH_F3CONS' )
	aAdd( aStructNVH, 'NVH_F3MULT' )
	aAdd( aStructNVH, 'NVH_TPPESQ' )

	For nLins := 1 To Len(aCols)
		If 'O0M' $ aCols[nLins]
			cNomTab := cNomTabO0M
		Else
			cNomTab := cNomTabO0N
		EndIf
		If !VerExtPesq(cAlias, 3, cFilTab + aCols[nLins] + '6')
			//                 FILIAL   COD    DESC                      TABELA   CAMPO         WHERE                    PROPRI   F3DIF   F3CONS  F3MULT   TPPESQ
			aAdd( aDadosNVH, { cFilTab,      , RetTitle( aCols[nLins] ), cNomTab, aCols[nLins], J163Where(aCols[nLins]), .F.    , .F.  ,  ''     , .F.     , '6'    } )
		EndIf
	Next

	GravaPesq( 'NVH', 'NVH_COD', aChave , aDadosNVH, aStructNVH)

	//------------------------------------------------------------
	// Layout dos campos de Pesquisa
	//------------------------------------------------------------
	cAlias := 'NVG'
	DbSelectArea(cAlias)
	SX2->( dbSeek( cAlias ) )
	aChave 	:= StrToArray( SX2->X2_UNICO, '+' )
	cFilTab 	:= xFilial(cAlias)
	cCPesq		:= JA163NewCPq()

	aAdd( aStructNVG, 'NVG_FILIAL' )
	aAdd( aStructNVG, 'NVG_COD'    )
	aAdd( aStructNVG, 'NVG_CPESQ'  )
	aAdd( aStructNVG, 'NVG_DESC'   )
	aAdd( aStructNVG, 'NVG_CCAMPO' )
	aAdd( aStructNVG, 'NVG_SUGEST' )
	aAdd( aStructNVG, 'NVG_VISIVE' )
	aAdd( aStructNVG, 'NVG_ENABLE' )
	aAdd( aStructNVG, 'NVG_TPPESQ' )

	For nLins := 1 To Len(aAssJur)
		If !VerExtPesq(cAlias, 5, cFilTab + aNomAssJur[nLins]+'-'+cStrSolic)
			cCPesq := PadL( ( Val(cCPesq) + 1),3,'0')
			//                 FILIAL   COD    CPESQ   DESC     							   CCAMPO                                                                  SUGEST   VISIVE   ENABLE   TPPESQ
			aAdd( aDadosNVG, { cFilTab,      , cCPesq, aNomAssJur[nLins]+'-'+cStrSolic, JurGetDados("NVH", 3, cFilTab + Padr(aCols[1], nTam) + "6", "NVH_COD" ), ''     , .T.    , .T.    , '6' } ) //'Contencioso-S.Doctos'
			aAdd( aDadosNVG, { cFilTab,      , cCPesq, aNomAssJur[nLins]+'-'+cStrSolic, JurGetDados("NVH", 3, cFilTab + Padr(aCols[2], nTam) + "6", "NVH_COD" ), ''     , .T.    , .T.    , '6' } ) //'Contencioso-S.Doctos'
			aAdd( aDadosNVG, { cFilTab,      , cCPesq, aNomAssJur[nLins]+'-'+cStrSolic, JurGetDados("NVH", 3, cFilTab + Padr(aCols[3], nTam) + "6", "NVH_COD" ), ''     , .T.    , .T.    , '6' } ) //'Contencioso-S.Doctos'
			aAdd( aDadosNVG, { cFilTab,      , cCPesq, aNomAssJur[nLins]+'-'+cStrSolic, JurGetDados("NVH", 3, cFilTab + Padr(aCols[4], nTam) + "6", "NVH_COD" ), ''     , .T.    , .T.    , '6' } ) //'Contencioso-S.Doctos'
			aAdd( aDadosNVG, { cFilTab,      , cCPesq, aNomAssJur[nLins]+'-'+cStrSolic, JurGetDados("NVH", 3, cFilTab + Padr(aCols[5], nTam) + "6", "NVH_COD" ), ''     , .T.    , .T.    , '6' } ) //'Contencioso-S.Doctos'
		EndIf
	Next

	GravaPesq( 'NVG', 'NVG_COD', aChave, aDadosNVG, aStructNVG, 2)

	//------------------------------------------------------------
	// Relacionamento Assunto Jurídico x Usuários
	//------------------------------------------------------------
	cAlias := 'NVJ'
	DbSelectArea(cAlias)
	SX2->( dbSeek( cAlias ) )
	aChave 	:= StrToArray( SX2->X2_UNICO, '+' )
	cFilTab 	:= xFilial(cAlias)

	// Estrutura
	aAdd( aStructNVJ, 'NVJ_FILIAL' )
	aAdd( aStructNVJ, 'NVJ_CASJUR' )
	aAdd( aStructNVJ, 'NVJ_CPESQ'  )

	cNVJCPesq := GetMaxNVJ()
	// Dados
	For nLins := 1 To Len(aAssJur)
		(cAlias)->(dbSetOrder(1))
		If (cAlias)->(DbSeek(cFilTab + aAssJur[nLins] + cNVJCPesq ))
			cNVJCPesq := PadL( ( Val(cNVJCPesq) + 1),3,'0')
			aAdd( aDadosNVJ, { cFilTab, aAssJur[nLins] , cNVJCPesq } )
		EndIf
	Next

	GravaPesq( 'NVJ', '', aChave, aDadosNVJ, aStructNVJ)

	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GravaPesq( cNomTab, cCodTab, aChave, aDadosTab, aStruct, nOrdem)
Gravação da Pesquisa. Funcionamento genérico para as tabelas.

@Param - cNomTab - Nome da Tabela
@Param - cCodTab - Coluna de Código da Tabela
@Param - aChave  - Array com o X2_UNICO da tabela separado por "+"
@Param - aDatasTab - Array com os dados a serem adicionados
@Param - aStruct   - Array com a estrutura da tabela a ser incluida os dados
@Param - nOrdem    - Indica a ordem do indice para indicar no GetSxEnum

@Return - lRet - Retorna se a operação foi bem sucedida ou não ".T./.F."

@since 	 21/03/2018
@author willian.kazahaya
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GravaPesq( cNomTab, cCodTab, aChave, aDadosTab, aStruct, nOrdem)
Local nI,nReg	:= 0
Local cChave	:= ''
Local nProxCod  := 0
Default nOrdem  := 1

	DbSelectArea(cNomTab)

	For nReg := 1 To Len( aDadosTab )
		If aDadosTab[nReg][1] == xFilial( cNomTab )
			// ID da tabela
			If Empty(aDadosTab[nReg][2]) .AND. !Empty(cCodTab)
				nProxCod  := GetProxCod(cCodTab,cNomTab)
				aDadosTab[nReg][2] := GetSXENUM( cNomTab, cCodTab,, nOrdem )
				While val(aDadosTab[nReg][2]) < nProxCod //valida se a numeração fornecida esta correta
					ConfirmSX8()
					aDadosTab[nReg][2] := GetSXENUM( cNomTab, cCodTab,, nOrdem )
				End
			EndIf

			cChave := ''
			For nI := 1 To Len( aChave )
				cChave += aDadosTab[nReg][aScan( aStruct, { | x | x == aChave[nI] } ) ]
			Next

			( cNomTab )->( dbSetOrder( 1 ) )
			If !( cNomTab )->( dbSeek ( cChave ) )
				RecLock( cNomTab, .T.  )
				For nI := 1 To Len( aStruct )
					( cNomTab )->( FieldPut( FieldPos( aStruct[nI] ) , aDadosTab[nReg][nI] ) )
				Next
				MsUnLock()
				If __lSX8
					ConfirmSX8()
				Else
					RollBackSX8()
				EndIf
			EndIf
		EndIf
	Next
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetMaxNVJ()
Busca o ID Maximo da NVJ

@Return - cRet - Código da NVJ

@since 	 21/03/2018
@author willian.kazahaya
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function GetMaxNVJ()
Local cQuery		:= ""
Local cAliasNvj	:= GetNextAlias()
Local cRet			:= "000"
Local cQrySel, cQryFrm, cQryWhr, cQryOrd := ''

	cQrySel := " SELECT MAX(NVJ_CPESQ) NVJ_CPESQ "
	cQryFrm := " FROM " + RetSqlName("NVJ") + " "
	cQryWhr := " WHERE NVJ_FILIAL = '" + xFilial("NVJ") + "'"

	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNvj, .F., .F. )

	If (cAliasNvj)->( !Eof() )
		If !Empty((cAliasNvj)->NVJ_CPESQ)
			cRet := (cAliasNvj)->NVJ_CPESQ
		EndIf
	EndIf

	(cAliasNvj)->(DbCloseArea())

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VerExtPesq(cTab, nIndice, cValor)
Verifica se existe a configuração da pesquisa

@Param cTab - Tabela de Referência
@Param nIndice - Indice para o DbSetOrder
@Param cValor - Valor a ser procurado

@Sample VerExtPesq(cAlias, 3, cFilTab + aCols[nLins] + '6')

@return lRet - Foi encontrado a informação ou não

@author  Willian.Kazahaya
@since 	 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VerExtPesq(cTab, nIndice, cValor)
Local lRet 	:= .F.
	(cTab)-> (dbSetOrder(nIndice))
	lRet := (cTab)->(DbSeek(cValor))

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP3557()
Atualiza a ordem dos campos NSY_PEINVL\NSY_INECON, para antes dos
campos NSY_CMOPED\NSY_CMOCON.

@author  Rafael Tenorio da Costa
@since 	 27/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP3557()

	Local aArea	 := GetArea()
	Local nOrdem := 0

	DbSelectArea("SX3")

	SX3->( dbSetOrder(2) )			//X3_CAMPO
	If SX3->( DbSeek("NSY_CMOPED") )
		nOrdem := Val(SX3->X3_ORDEM) - 1
		AtuOrdem("NSY", nOrdem, "NSY_PEINVL")
	EndIf

	SX3->( dbSetOrder(2) )			//X3_CAMPO
	If SX3->( DbSeek("NSY_CMOCON") )
		nOrdem := Val(SX3->X3_ORDEM) - 1
		AtuOrdem("NSY", nOrdem, "NSY_INECON")
	EndIf

	RestArea(aArea)

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3348()
Função que ajusta o código de assunto jurídico das tabelas, passando de
tamanho 2 para 3 colocando um 0 a esquerda / Ajuste no Tipo de pesquisa, colocando no padrão esperado na versão 12

Uso Geral
@author Jorge Luis Branco Martins Junior
@since 17/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP3348()

	Local aArea       := GetArea()
	Local cQuery      := ""
	Local cAliasPesq  := GetNextAlias()
	Local cTpNovo     := ""

	//Altera campos de assunto juridico, se ele for menor que 3 colocando um 0 a esquerda
	DbSelectArea("NSZ")
	NSZ->(DbGoTop())
		Do While NSZ->(!Eof())
			If Len(AllTrim(NSZ->NSZ_TIPOAS)) < 3
				RecLock("NSZ",.F.)
				NSZ->NSZ_TIPOAS := '0' + NSZ->NSZ_TIPOAS
				NSZ->(MsUnlock())
			EndIf
			NSZ->(DbSkip())
		End
	NSZ->(DbCloseArea())

	DbSelectArea("NVJ")
	NVJ->(DbGoTop())
		Do While NVJ->(!Eof())
			If Len(AllTrim(NVJ->NVJ_CASJUR)) < 3
				RecLock("NVJ",.F.)
				NVJ->NVJ_CASJUR := '0' + NVJ->NVJ_CASJUR
				NVJ->(MsUnlock())
			EndIf
			NVJ->(DbSkip())
		End
	NVJ->(DbCloseArea())

	DbSelectArea("NVL")
	NVL->(DbGoTop())
		Do While NVL->(!Eof())
			If Len(AllTrim(NVL->NVL_CTIPOA)) < 3
				RecLock("NVL",.F.)
				NVL->NVL_CTIPOA := '0' + NVL->NVL_CTIPOA
				NVL->(MsUnlock())
			EndIf
			NVL->(DbSkip())
		End
	NVL->(DbCloseArea())

	DbSelectArea("NUZ")
	NUZ->(DbGoTop())
		Do While NUZ->(!Eof())
			If Len(AllTrim(NUZ->NUZ_CTAJUR)) < 3
				RecLock("NUZ",.F.)
				NUZ->NUZ_CTAJUR := '0' + NUZ->NUZ_CTAJUR
				NUZ->(MsUnlock())
			EndIf
			NUZ->(DbSkip())
		End
	NUZ->(DbCloseArea())

	cQuery := " SELECT NVG.R_E_C_N_O_ RECNO, NVG_COD COD, NVG_TPPESQ PESQ,'NVG' TABELA  "
	cQuery += " FROM "+ RetSQLName("NVG") + " NVG "
	cQuery += " WHERE NVG.NVG_FILIAL = '" + xFilial( 'NVG' ) +"' "
	cQuery += " AND NVG.NVG_TPPESQ IN ('A','P','G','F') "
	cQuery += " AND NVG.D_E_L_E_T_ = ' ' "
	cQuery += " UNION "
	cQuery += " SELECT NVH.R_E_C_N_O_ RECNO, NVH_COD COD, NVH_TPPESQ PESQ,'NVH' TABELA  "
	cQuery += " FROM "+ RetSQLName("NVH") + " NVH "
	cQuery += " WHERE NVH.NVH_FILIAL = '" + xFilial( 'NVH' ) +"' "
	cQuery += " AND NVH.NVH_TPPESQ IN ('A','P','G','F') "
	cQuery += " AND NVH.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAliasPesq, .T., .F. )

	(cAliasPesq)->( dbGoTop() )

	Do while !(cAliasPesq)->( Eof() )

		If (cAliasPesq)->PESQ == "P"
			cTpNovo := "1"
		ElseIf (cAliasPesq)->PESQ == "F"
			cTpNovo := "2"
		ElseIf (cAliasPesq)->PESQ == "G"
			cTpNovo := "3"
		Else
			cTpNovo := "4"
		EndIf

		If ((cAliasPesq)->TABELA) == "NVH"
			NVH->(dbGoTo( (cAliasPesq)->RECNO) )
			If RecLock("NVH",.F.)
				NVH->NVH_TPPESQ := cTpNovo
				NVH->(MsUnlock())
			EndIf
		Else
			NVG->(dbGoTo( (cAliasPesq)->RECNO) )
			If RecLock("NVG",.F.)
				NVG->NVG_TPPESQ := cTpNovo
				NVG->(MsUnlock())
			EndIf
		EndIf
		(cAliasPesq)->( dbSkip() )
	Enddo

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP3100()
Ajustando a tabela NW7 (forma de correcao - selic)

@author leandro.silva
@since 	05/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP3100()

	Local aArea    := GetArea()

	//Ajustando a formula das correçoes monetárias que usam a função VALORPTJ
	DbSelectArea("NW7")
	NW7->( dbSetOrder( 1 ) )     //NW7_FILIAL + NW7_COD

	If NW7->( DbSeek(xFilial("NW7") + '09' ) )
		Reclock( 'NW7', .F. )
		    NW7->NW7_FORMUL := "FN_VALORAF(#DTINI,#VALOR,'05',#DTFIM,0,#VLRMULTA,0,AF,#DTJUROS,#DTMULTA)"
	    NW7->( MsUnLock() )
	Endif

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP3826()
Removendo Relacao da NUQ para a tabela NTA (campo NTA_CINSTA)

@author leandro.silva
@since 	25/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP3826()

	Local aArea := GetArea()

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) )                 //X9_CDOM+X9_DOM

	If SX9->( dbSeek('NUQ' + 'NTA') ) .And. Alltrim(SX9->X9_EXPDOM) == "NTA_CINSTA"
		Reclock( 'SX9', .F. )
			SX9->( DbDelete() )
		SX9->( MsUnlock() )
	EndIf

	RestArea(aArea)

 Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP3804()
Alterando decimal e picture do campo NW6_VALOR

@author  Rafael tenorio da Costa
@since 	 27/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP3804()

	Local aSX3 		:= {}
	Local aSX3Estr 	:= {}
	Local aSX3Old 	:= []

	//Alterando o campo NW6_VALOR
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO", "X3_DECIMAL", "X3_PICTURE"}

	Aadd(aSX3, {"NW6", "NW6_VALOR", 16, 6, "@E 999,999,999.999999"} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3837()
Excluindo Indice 3 da tabela NVJ

@author Beatriz Gomes
@since 	07/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP3837()

Local aArea    := GetArea()
Local aAreaSIX := SIX->( GetArea() )

	dbSelectArea("SIX")
	DbSetOrder(1)

	If SIX->(DbSeek( 'NVJ'+'3')) .AND. Alltrim(SIX->CHAVE) == "NVJ_FILIAL+NVJ_CASJUR+NVJ_PESQUI"
		Reclock( 'SIX', .F. )
		dbDelete()
		SIX->(MsUnlock())
	Endif
	SIX->( DbSkip() )

RestArea(aAreaSIX)
RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3884()
Alterando o retorno da consulta padrão NYCSX2

@author Beatriz Gomes
@since 	14/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP3884()
local aSXB        := {}
local aSXBEstr    := {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}

aAdd (aSXB,{'NYCSX2','5','01','','','','','J158GChav()'})

AtuSXB(aSXB,aSXBEstr)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP2349()
Ajustando a tabela NW7 E NWS de correção monetária, para o padrão atual.

ADEQUAÇÃO DA FUNÇÃO FN_COMPOSTO

@author Beatriz Gomes
@since 	06/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP2349()

	Local aArea   := GetArea()
	Local aCorr   := {}
	Local nI      := 0

	DbSelectArea("NWS")
	If NWS->( FieldPos("NWS_TIPJUR") ) > 0

		aAdd( aCorr, {'19'/*For Corr*/,/*Percentual*/ 0.25,CTOD(''),CTOD(''),/*Tp Juros*/"2",/*Pro-rata*/"2"} )
		aAdd( aCorr, {'20'/*For Corr*/,/*Percentual*/ 0.5 ,CTOD(''),CTOD(''),/*Tp Juros*/"2",/*Pro-rata*/"2"} )
		aAdd( aCorr, {'21'/*For Corr*/,/*Percentual*/ 1.0 ,CTOD(''),CTOD(''),/*Tp Juros*/"2",/*Pro-rata*/"2"} )

		//Ajustando a formula das correçoes monetárias que usam a função VALORPTJ
		dbSelectArea("NW7")
		NW7->( dbSetOrder( 1 ) )
		dbSelectArea("NWS")
		NWS->( dbSetOrder( 1 ) )

		For nI := 1 To Len(aCorr)
			//EXCLUI O REGISTRO QUE JÁ EXISTE
			If NWS->( DbSeek(xFilial("NWS") + aCorr[nI][1]) )
				Reclock( 'NWS', .F. )
				NWS->( dbDelete() )
				NWS-> (MsUnLock())
			EndIF
		Next
		For nI := 1 To Len(aCorr)
			If NW7->( DbSeek(xFilial("NW7") + aCorr[nI][1]) )

				Reclock( 'NW7', .F. )
					NW7->NW7_FORMUL := "FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',#DTJUROS)"
				NW7->( MsUnLock() )

				//Incluindo o novo registro no grid
				Reclock( 'NWS', .T. )
					NWS->NWS_FILIAL := xFilial("NWS")
					NWS->NWS_CFCORR := aCorr[nI][1]
					NWS->NWS_PERCEN := aCorr[nI][2]
					NWS->NWS_DTINI  := aCorr[nI][3]
					NWS->NWS_DTFIM  := aCorr[nI][4]
					NWS->NWS_TIPJUR := aCorr[nI][5]
					NWS->NWS_PRORAT := aCorr[nI][6]
				NWS-> ( MsUnLock() )

			Endif
		Next

	EndIf
	aSize(aCorr,0)
	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3798()
Ajuste no X3_WHEN do campo NSZ_DTENCE


@author Beatriz Gomes
@since 	10/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP3798()

	Local lRet      := .T.
	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_WHEN"}

	Aadd(aSX3, {"NSZ", "NSZ_DTENCE", "FwFldGet( 'NSZ_SITUAC' ) == '2'"} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP3948()
Ajuste no X3_RELACAO da NSZ_DTIPAS


@author Willian Kazahaya
@since 	15/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP3948()

	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

	Aadd(aSX3, {"NSZ", "NSZ_DTIPAS", " POSICIONE('NYB', 1, XFILIAL('NYB') + M->NSZ_TIPOAS, 'NYB_DESC')"} )

	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP3862()
Ajuste nas colunas da NUM para que, independente do parâmetro de Documentos,
os dados estejam normalizados

@since 	 17/05/2018
@author Willian.Kazahaya
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURDEP3862()
Local cParam  := SuperGetMV("MV_JDOCUME",,"2")
Local cQrySel := ""
Local cQryFrm := ""
Local cQryWhr := ""
Local cQryOrd := ""
Local cQuery  := ""
Local cAlias  := GetNextAlias()
Local cAliNUM := ""
Local lRet    := FWX2Unico("NUM") == "NUM_FILIAL+NUM_COD"

	DbSelectArea('NUM')

	If lRet

		cQrySel := " SELECT NUM_COD "
		cQrySel +=       " ,NUM_FILIAL "
		cQrySel +=       " ,NUM_EXTEN "
		cQrySel +=       " ,NUM_DESC "
		cQrySel +=       " ,NUM_DOC "

		cQryFrm := " FROM " + RetSqlName("NUM") + " NUM "

		cQryWhr := " WHERE SUBSTRING(NUM_CENTID,1," + cValToChar(Len(xFilial("NUM"))) + ") = NUM_FILENT "

		If cParam == "2"
			cQryWhr += " AND NUM_DESC = '' "
			cQryWhr += " AND NUM_SUBPAS = '' "

		ElseIf cParam == "3"
			cQryWhr += " AND NUM_NUMERO = '' "
			cQryWhr += " AND NUM_EXTEN = '' "
		EndIf

		cQryOrd := " ORDER BY NUM_COD "

		cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd
		cQuery := ChangeQuery(cQuery)

		DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAlias, .F., .F.)

		lRet := (cAlias)->(!Eof())

		If lRet

			//-- Query para buscar os dados que não estão normalizados - coluna NUM_CENTID
			cAliNUM := GetNextAlias()
			cQrySel := " SELECT NUM_COD "
			cQrySel +=       " ,NUM_FILIAL "
			cQrySel +=       " ,NUM_CENTID "
			cQrySel +=       " ,NUM_FILENT "
			cQrySel +=       " ,NUM_EXTEN "
			cQrySel +=       " ,NUM_DESC "
			cQrySel +=       " ,NUM_DOC "
			cQrySel +=       " ,NUM_NUMERO "
			cQrySel +=       " ,R_E_C_N_O_ RECNONUM"

			cQryFrm := " FROM " + RetSqlName("NUM") + " NUM "
			cQryWhr := " WHERE SUBSTRING(NUM_CENTID,1," + CVALTOCHAR( TamSX3('NUM_FILENT')[1] ) + ") = NUM_FILENT  "
			cQryWhr +=   " AND NUM_CENTID <> ' ' "

			cQryOrd := " ORDER BY NUM_COD "

			cQuery := cQrySel + cQryFrm + cQryWhr +  cQryOrd
			cQuery := ChangeQuery(cQuery)

			DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliNUM, .F., .F.)

			Begin Transaction
			While (cAliNUM)->(!Eof())

				NUM->( dbSetOrder( 1 ) )
				NUM->(DbGoTop())
				NUM->(DbGoTo( (cAliNUM)->RECNONUM ))
				lRet := NUM->(RecLock( "NUM", .F. ))

				If cParam == "2" // Base de Conhecimento
					// Alterar o NUM_SUBPAS com o nome da pasta (NUM_DESC)
					// Alterar o NUM_DESC com dados do NUM_DOC + NUM_EXTEN
					NUM->NUM_CENTID := StrTran((cAliNUM)->NUM_CENTID,(cAliNUM)->NUM_FILENT, "",1,1)
					NUM->NUM_SUBPAS := (cAliNUM)->NUM_DESC
					NUM->NUM_DESC   := AllTrim((cAliNUM)->NUM_DOC) + AllTrim((cAliNUM)->NUM_EXTEN)

				ElseIf cParam == "3" // Fluig
					// Alterar o NUM_NUMERO com dados do NUM_DOC
					// E alterar o NUM_EXTEN com a extensão do NUM_DESC
					If Empty((cAliNUM)->NUM_NUMERO)
						NUM->NUM_CENTID := StrTran((cAliNUM)->NUM_CENTID,(cAliNUM)->NUM_FILENT, "",1,1)
						NUM->NUM_NUMERO := (cAliNUM)->NUM_DOC
						NUM->NUM_EXTEN  := SubStr((cAliNUM)->NUM_DESC, Rat(".", (cAliNUM)->NUM_DESC), Len((cAliNUM)->NUM_DESC) - Rat(".", (cAliNUM)->NUM_DESC))
					EndIf
				EndIf

				NUM->( MsUnLock() )

				(cAliNUM)->(DbSkip())
			EndDo

			End Transaction
			(cAliNUM)->(DbCloseArea())
		EndIf

		(cAlias)->(DbCloseArea())
	EndIf

	NUM->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP4374()
Ajuste do CENTID para os registros da NSY com a ordem 3 (filial + codigo + cajuri)

@author leandro.silva
@since 	22/01/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP4374()
Local lRet        := .T.
Local cQuery      := ""
Local aRetorno    := {}
Local cNumFil     := ""
Local cCentId     := ""
Local cCodEnt     := ""
Local nI          := 0
Local aGetDados   := {}
Local cQrySel     := ""
Local cQryFrm     := ""
Local cQryWhr     := ""

	// Query para encontrar os anexos que estão cadastrados com o index NSY_FILIAL + NSY_COD
	cQuery := " SELECT NSY.NSY_FILIAL "
	cQuery +=       " ,NSY.NSY_COD "
	cQuery += " FROM " + RetSqlName("NSZ") + " NSZ INNER JOIN " + RetSqlName("NSY") + " NSY ON (NSY.NSY_CAJURI = NSZ.NSZ_COD) "
	cQuery +=                                    " INNER JOIN " + RetSqlName("NUM") + " NUM ON (NUM.NUM_CENTID = NSY.NSY_FILIAL || NSY.NSY_COD) "
	cQuery += " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NSY.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND NUM.NUM_ENTIDA = 'NSY' "
	cQuery += " GROUP BY NSY.NSY_COD,NSY.NSY_FILIAL,NUM.NUM_CENTID "
	cQuery += " ORDER BY NUM.NUM_CENTID "

	cQuery := ChangeQuery(cQuery)

	aRetorno := JurSql(cQuery, {"NSY_FILIAL", "NSY_COD"})

	// Verifica todos os itens
	For nI := 1 To Len(aRetorno)
		cNumFil   := aRetorno[nI][1] // Filial
		cCodEnt   := aRetorno[nI][2] // Código Objeto

		cQrySel := " SELECT NSY_FILIAL "
		cQrySel +=       " ,NSY_COD "
		cQrySel +=       " ,NSY_CAJURI "

		cQryFrm := " FROM " + RetSqlName("NSY") + " NSY "

		cQryWhr := " WHERE NSY_COD = '" + cCodEnt  + "'"
		cQryWhr +=   " AND NSY_FILIAL = '" + cNumFil + "'"

		cQuery := cQrySel + cQryFrm + cQryWhr

		cQuery := ChangeQuery(cQuery)

		aGetDados := JurSQL(cQuery, {"NSY_FILIAL", "NSY_COD", "NSY_CAJURI"})

		// Somente irá ajustar os dados quando somente houver 1 Objeto cadastrado com o ID do CENTID
		If Len(aGetDados) == 1
			DbSelectArea("NUM")
			NUM->(dbSetOrder(3))
			// Index 3: Filial + Entidade + CentId
			While NUM->( dbSeek(cNumFil + "NSY" + cNumFil + cCodEnt + Space( TamSx3("NSZ_COD")[1] )) )
				cCentId := aGetDados[1][1] + aGetDados[1][2] + aGetDados[1][3]

				RecLock("NUM",.F.)
				NUM->NUM_CENTID := cCentId
				MsUnlock()
			EndDo
		EndIf
	Next

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP4490()
DJURDEP-4490 - Ajuste Tamanho Campo e Mascara dos campos NWB_VALOR e NWB_VALORA

@author Simone Oliveira
@since 11/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP4490()

Local	aSX3      	:= {}
Local	aSX3Old   	:= {}
Local 	aSX3Estr  	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO","X3_DECIMAL","X3_PICTURE"}
Local	lRet		:= .T.

	Aadd(aSX3, {"NWB", "NWB_VALOR" , 16, 2, '@E 9,999,999,999,999.99'} )
	Aadd(aSX3, {"NWB", "NWB_VALORA", 16, 2, '@E 9,999,999,999,999.99'} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP4552()
DJURDEP-4552 - Remoção do relacionamento entre a NZD e a SB1

@author Willian.Kazahaya
@since 19/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURDEP4552()

	Local aArea := GetArea()

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) )                 //X9_CDOM+X9_DOM

	If SX9->( dbSeek('NZD' + 'SB1') ) .And. Alltrim(SX9->X9_EXPCDOM) == "NZD_PRODUT"
		Reclock( 'SX9', .F. )
			SX9->( DbDelete() )
		SX9->( MsUnlock() )
	EndIf

	RestArea(aArea)

 Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP4447()
Ajustando a tabela NW7 E NWS de correção monetária, para o padrão atual.

ADEQUAÇÃO DA FUNÇÃO FN_VALORPRO

@author Beatriz Gomes
@since 	06/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP4447()

	Local aArea   := GetArea()
	Local aCorr   := {}
	Local nI      := 0
	Local aDados  := {}
	Local nX      := {}

	DbSelectArea("NWS")
	If NWS->( FieldPos("NWS_TIPJUR") ) > 0

		aAdd( aCorr, {'04',0  ,,,"1","1"} )
		aAdd( aCorr, {'08',0.5,,,"1","1"} )
		aAdd( aCorr, {'15',1.0,,,"1","1"} )
		aAdd( aCorr, {'24',0.5,,,"1","1"} )
		aAdd( aCorr, {'25',0.5,,,"1","1"} )
		aAdd( aCorr, {'27',1.0,,,"1","1"} )
		aAdd( aCorr, {'28',1.0,,,"1","1"} )
		aAdd( aCorr, {'29',1.0,,,"1","1"} )
		aAdd( aCorr, {'31',0  ,,,"1","1"} )
		aAdd( aCorr, {'33',0.5,,,"1","1"} )
		aAdd( aCorr, {'37',1.0,,,"1","1"} )

		aAdd( aDados, {'04', 'TJ'        ,"FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'01',#DTJUROS)"} )
		aAdd( aDados, {'08', 'TST'       ,"(#VALOR*(FN_INDICEPLUS('06',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'06',0,#DTJUROS))"} )
		aAdd( aDados, {'15', 'IPCA-E c/J',"{13}+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'09',0,#DTJUROS))"} )
		aAdd( aDados, {'24', 'JF-Previd ',"(#VALOR*(FN_VALORINDICE('15',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'15',0,#DTJUROS))"} )
		aAdd( aDados, {'25', 'JF-Desapro',"(#VALOR*(FN_VALORINDICE('16',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'16',0,#DTJUROS))"} )
		aAdd( aDados, {'27', 'INPC/IBGE' ,"(#VALOR*(FN_INDICEPLUS('18',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'18',0,#DTJUROS))"})
		aAdd( aDados, {'28', 'IGPM-Acum' ,"(#VALOR*(FN_INDICEPLUS('19',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'19',0,#DTJUROS))"})
		aAdd( aDados, {'29', 'IPCA-Acum' ,"(#VALOR*(FN_INDICEPLUS('23',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'23',0,#DTJUROS))"})
		aAdd( aDados, {'31', 'TR' ,"FN_COMPOSTO(#DTINI,#VALOR,#DTFIM,'03',#DTJUROS)"})
		aAdd( aDados, {'33', 'JF-CondGeJ',"(#VALOR*(FN_VALORINDICE('11',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'11',0,#DTJUROS))"})
		aAdd( aDados, {'37', 'IGP-DI-1%' ,"(#VALOR*(FN_INDICEPLUS('27',#DTINI,0)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'27',0,#DTJUROS))"})

		//Ajustando a formula das correçoes monetárias que usam a função VALORPTJ
		dbSelectArea("NW7")
		NW7->( dbSetOrder( 1 ) )
		dbSelectArea("NWS")
		NWS->( dbSetOrder( 1 ) )

		For nI := 1 To Len(aCorr)
			//EXCLUI O REGISTRO QUE JÁ EXISTE
			If NWS->( DbSeek(xFilial("NWS") + aCorr[nI][1]) )
				Reclock( 'NWS', .F. )
				NWS->( dbDelete() )
				NWS-> (MsUnLock())
			EndIF
		Next
		For nI := 1 To Len(aCorr)
			If NW7->( DbSeek(xFilial("NW7") + aCorr[nI][1]) )
				For nX := 1 To Len(aDados)
					If aDados[nX][1] == aCorr[nI][1]
						Reclock( 'NW7', .F. )
							NW7->NW7_FORMUL := aDados[nX][3]
						NW7->( MsUnLock() )
					EndIf
				Next

				//Incluindo o novo registro no grid
				Reclock( 'NWS', .T. )
					NWS->NWS_FILIAL := xFilial("NWS")
					NWS->NWS_CFCORR := aCorr[nI][1]
					NWS->NWS_PERCEN := aCorr[nI][2]
					NWS->NWS_DTINI  := aCorr[nI][3]
					NWS->NWS_DTFIM  := aCorr[nI][4]
					NWS->NWS_TIPJUR := aCorr[nI][5]
					NWS->NWS_PRORAT := aCorr[nI][6]
				NWS-> ( MsUnLock() )

			Endif
		Next

	EndIf
	aSize(aCorr,0)
	aSize(aDados,0)
	RestArea( aArea )

Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP4586
//Atualiza ordem dos campos na NT4

@author Brenno Gomes
@since  26/12/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJRDEP4586()

	AtuOrdem("NT4",09, "NT4_CATO")
	AtuOrdem("NT4",10, "NT4_DATO")
	AtuOrdem("NT4",11, "NT4_CFASE")
	AtuOrdem("NT4",12, "NT4_DFASE")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP4586
//Atualiza o X3_WHEN da NT3

@author nishizaka.cristiane
@since  15/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJRDEP4720()

	Local aSX3      := {}
	Local aSX3Old   := {}
	Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_WHEN"}

	Aadd(aSX3	, {"NT3", "NT3_FILDES", "Iif(ALTERA,JA099Opc(),.T.)"} )
	Aadd(aSX3	, {"NT3", "NT3_DTFIN", "Iif(ALTERA,JA099Opc(),.T.)"} )
	Aadd(aSX3	, {"NT3", "NT3_CRATEI", "Iif(ALTERA,JA099Opc(),.T.)"} )

	Aadd(aSX3Old, {"NT3", "NT3_FILDES", ""} )
	Aadd(aSX3Old, {"NT3", "NT3_DTFIN", ""} )
	Aadd(aSX3Old, {"NT3", "NT3_CRATEI", ""} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP4586
//Atualiza o X3_TITULO e X3_DESCRIC dos campos NT2_INTFIN e NT2_CGRUAP

@author sigajuri
@since  07/05/19
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJRDEP6195()
Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TITULO", "X3_DESCRIC"}

	Aadd(aSX3, {"NT2", "NT2_CGRUAP", "Grupo Fin."  , "Grp. Aprov. - Financeiro" } )
	Aadd(aSX3, {"NT2", "NT2_INTFIN", "Integração?" , "Garantia faz Integração?" } )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP6422()

(17 - AutEst-RJ)
Ajuste da forma de correção nas tabelas NW7 e NWS.

@author sigajuri
@since 	04/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP6422()

Local aArea  := GetArea()

	DbSelectArea('NW7')
	NW7->( dbSetOrder( 1 ) )  //-- NW7_FILIAL + NW7_COD

	DbSelectArea('NWS')
	NWS->( dbSetOrder( 1 ) )  //-- NWS_FILIAL + NWS_CFCORR

	If NW7->(DbSeek(xFilial('NW7') + '17'))	.AND. !(NWS->( DbSeek(xFilial('NWS') + '17') ))
		If NW7->NW7_FORMUL == "FN_VALORAF(#DTINI,#VALOR,'22',#DTFIM,0,#VLRMULTA,0.01,RJ,#DTJUROS,#DTMULTA)"
			Begin Transaction
			//-- NW7 - Forma de Correção
			NW7->( Reclock('NW7', .F.) )
			    NW7->NW7_FORMUL := "FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'22',#DTJUROS)"
		    NW7->( MsUnLock() )

		    //-- NSW - Juros
			NWS->( Reclock('NWS', .T.) )
				NWS->NWS_FILIAL := xFilial('NWS')
				NWS->NWS_CFCORR := '17'
				NWS->NWS_PERCEN := 1.0
				NWS->NWS_TIPJUR := '1'
				NWS->NWS_PRORAT := '1'
				NWS->NWS_DECMES := 0
			NWS->( MsUnLock() )

			End Transaction
	    EndIf
	EndIf

	RestArea(aArea)


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP6437()

(38 - SELIC MG)
Ajuste da forma de correção na tabela NW7.

@author sigajuri
@since 	06/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP6437()

Local aArea  := GetArea()

	DbSelectArea('NW7')
	NW7->( dbSetOrder( 1 ) )  //-- NW7_FILIAL + NW7_COD

	If NW7->(DbSeek(xFilial('NW7') + '38'))
		If NW7->NW7_FORMUL == "(#VALOR*(FN_VALORINDICE('28',#DTINI)))+#VALOR+#VLRMULTA"

			Begin Transaction
				NW7->( Reclock('NW7', .F.) )
				    NW7->NW7_FORMUL := "FN_VALORAF(#DTINI,#VALOR,'28',#DTFIM,0,#VLRMULTA,0,MG,#DTJUROS,#DTMULTA)"
			    NW7->( MsUnLock() )
		    End Transaction
	    EndIf
	EndIf
	If NW7->(DbSeek(xFilial('NW7') + '12'))
		If NW7->NW7_FORMUL == "FN_SE_TEXTO(#DTINI >= '20000101',#VALOR*(1+ (FN_VALORINDICE('08',#DTINI)/100)),#VALOR)"

			Begin Transaction
				NW7->( Reclock('NW7', .F.) )
				    NW7->NW7_FORMUL := "FN_SE_TEXTO(#DTINI >= '20000101',#VALOR*(FN_VALORINDICE('08',#DTINI)),#VALOR)"
			    NW7->( MsUnLock() )
			End Transaction
	    EndIf
	EndIf

	RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP6497()

(22 - JF-CGeral e 33 - JF-CondGeJ )
Ajuste da forma de correção na tabela NW7.

@author sigajuri
@since 	13/06/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DJURDEP6497()

Local aArea  := GetArea()

	DbSelectArea('NW7')
	NW7->( dbSetOrder( 1 ) )  //-- NW7_FILIAL + NW7_COD

	If NW7->(DbSeek(xFilial('NW7') + '22'))
		If NW7->NW7_FORMUL == "(#VALOR*(FN_VALORINDICE('11',#DTINI)))"

			Begin Transaction
			NW7->( Reclock('NW7', .F.) )
			    NW7->NW7_FORMUL := "FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'11',#DTJUROS,RJ)"
		    NW7->( MsUnLock() )
		    End Transaction
	    EndIf
	EndIf
	If NW7->(DbSeek(xFilial('NW7') + '33'))
		If NW7->NW7_FORMUL == "(#VALOR*(FN_VALORINDICE('11',#DTINI)))+(FN_VALORPRO(#DTINI,#VALOR,#DTFIM,'11',0,#DTJUROS))"

			Begin Transaction
			NW7->( Reclock('NW7', .F.) )
			    NW7->NW7_FORMUL := "FN_VALORPTJ(#DTINI,#VALOR,#DTFIM,'11',#DTJUROS,RJ)"
		    NW7->( MsUnLock() )
		    End Transaction
	    EndIf
	EndIf

	RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} DJURDEP4347()
Remover Picture dos campos O0U_WSDL E O0U_OPERAC

@since 	25/07/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function  DJRDEP4347()
Local	aSX3      	:= {}
Local	aSX3Old   	:= {}
Local 	aSX3Estr  	:= {"X3_ARQUIVO", "X3_CAMPO", "X3_PICTURE"}
Local	lRet		:= .T.

	If FWAliasInDic("O0U")

		Aadd(aSX3, {"O0U", "O0U_WSDL", ""} )
		Aadd(aSX3, {"O0U", "O0U_OPERAC", ""} )

		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)

	EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP6721()
Ajusta o valid e o campo relação, se na base tiver o indice 6 (NVG_FILIAL+NVG_COD)

@author Breno Gomes
@since 	01/08/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP6721()
Local aSX3        := {}
Local aSX3Old     := {}
Local aSX3Estr    := {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID","X3_RELACAO"}

	Aadd(aSX3	, {"NVG", "NVG_COD", "ExistChav('NVG',M->NVG_COD,2)", "GetSXENum('NVG','NVG_COD',,2)"} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GetProxCod()
Retorn o próximo código da tbela para proteger o controle de numeração.

@Return - cRet - Código da NVJ

@since 	 14/08/2019
@author willian.kazahaya
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetProxCod(cCampo,cTabela)
Local cQuery		:= ""
Local cAliasNvj	:= GetNextAlias()
Local nRet			:= 1
Local cQrySel, cQryFrm, cQryWhr, cQryOrd := ''

	cQrySel := " SELECT MAX(" + cCampo + ") VALOR "
	cQryFrm := " FROM " + RetSqlName(cTabela) + " "
	cQryWhr := " WHERE " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' AND D_E_L_E_T_ = ' '"

	cQuery := cQrySel + cQryFrm + cQryWhr + cQryOrd

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasNvj, .F., .F. )

	If (cAliasNvj)->( !Eof() )
		If !Empty((cAliasNvj)->VALOR)
			nRet := val((cAliasNvj)->VALOR)+1
		EndIf
	EndIf

	(cAliasNvj)->(DbCloseArea())

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP6579()
COMPLEMENTA A NVH COM CHAVE E LABEL PARA UTILIZAR NO CAMPO F3 FO TOTVS LEGAL

@since 	09/09/2019
/*/
//-------------------------------------------------------------------
Static Function JURDEP6579()

	JNVHLABEL()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP7189()
Função responsável por ajustar o valid dos campos e consulta padrão.

@since 14/11/2019
/*/
//-------------------------------------------------------------------
static Function JURDEP7189()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID", "X3_F3"}

	Aadd(aSX3,{"NT2", "NT2_CBANCO", "Vazio() .OR. J98ValBan(M->NT2_FILDES, M->NT2_CBANCO)"                                , "SA6NT2"})
	Aadd(aSX3,{"NT2", "NT2_CAGENC", "Vazio() .OR. J98ValBan(M->NT2_FILDES, M->NT2_CBANCO + M->NT2_CAGENC)"                , ""      })
	Aadd(aSX3,{"NT2", "NT2_CCONTA", "Vazio() .OR. J98ValBan(M->NT2_FILDES, M->NT2_CBANCO + M->NT2_CAGENC + M->NT2_CCONTA)", ""      })

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP7157()
Remove o campo "NSZ_VACONT" do campo de Histórico do Valor do Contrato

@since 21/11/2019
/*/
//-------------------------------------------------------------------
Static Function JURDEP7157()
Local aArea := GetArea()
	DbSelectArea("NW8")
	NW8->( dbSetOrder(1) )
	If (NW8->( dbSeek(xFilial('NW8') + 'NSZ' + 'NSZ_VLCONT') ) .And. AllTrim(NW8->NW8_CAMPH) == 'NSZ_VACONT')
		RecLock('NW8',.F.)
		NW8->NW8_CAMPH := ''
		NW8->( MsUnLock() )
	EndIf
	RestArea(aArea)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP7325()
Função responsável por ajustar o valid dos campos

@since 14/11/2019
/*/
//-------------------------------------------------------------------
static Function JURDEP7325()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {"X3_ARQUIVO", "X3_CAMPO", "X3_VALID"}

	Aadd(aSX3,{"NT2", "NT2_DATA", "VAZIO() .OR. VlDtMoeda({M->NT2_DATA, M->NT2_CMOEDA}) .AND. J098SetVal()"})

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP7994()
Função responsável por ajustar os dados no campo NUM_NUMERO, quando 
o conteudo estiver diferente do campo NUM_DOC. Utilizada para integração 
de anexos com FLUIG.

@since 06/05/2020
/*/
//-------------------------------------------------------------------
Static Function JURDEP7994()

Local cQuery     := "" 
Local cNumDoc    := ""
Local cNumNumero := ""
Local aArea      := GetArea()
Local cAliasNUM  := ""
Local cIntAnexos := SuperGetMV("MV_JDOCUME",,"2")

	//-- Valida se possui integracao de anexos com FLUIG
	If cIntAnexos == "3"

		cQuery := " SELECT NUM_NUMERO, "
		cQuery +=         " NUM_DOC, "
		cQuery +=         " R_E_C_N_O_ RECNONUM "
		cQuery += " FROM " + RetSqlName("NUM") + " NUM "
		cQuery += " WHERE NUM.D_E_L_E_T_ = ' ' "
		cQuery += " ORDER BY R_E_C_N_O_ "

		cAliasNUM  := GetNextAlias()

		cQuery := ChangeQuery(cQuery)
		DbUseArea( .T., "TOPCONN", TCGenQry(,, cQuery), cAliasNUM, .F., .F.)

		DbSelectArea("NUM")
		NUM->( dbSetOrder( 1 ) )
		NUM->( DbGoTop() )

		While (cAliasNUM)->(!Eof())

			cNumDoc    := AllTrim( (cAliasNUM)->NUM_DOC    )
			cNumNumero := Alltrim( (cAliasNUM)->NUM_NUMERO )

			//-- Se o dado possui mais de 10 caracteres no NUM_DOC ajusta no campo NUM_NUMERO.
			If (Len( cNumDoc ) > 10) .AND. (Len(cNumNumero) < Len(cNumDoc)) .AND. (cNumNumero $ cNumDoc)
				
				NUM->( DbGoTo( (cAliasNUM)->RECNONUM ) )

				NUM->(RecLock( "NUM", .F. ))
					NUM->NUM_NUMERO := cNumDoc
				NUM->( MsUnLock() )
				
			EndIf

			(cAliasNUM)->(DbSkip())
		End
		
		NUM->(DbCloseArea())
		(cAliasNUM)->(DbCloseArea())
	EndIf
	
	RestArea( aArea )

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP8134()
Função responsável por ajustar o inicializador padrão dos campos de natureza
da Despesa e Garantia (NT2_CNATUT e NT3_CNATUT).

@since 12/06/2020
/*/
//-------------------------------------------------------------------
Static Function JURDEP8134()
Local aSX3     := {}
Local aSX3Old  := {}
Local aSX3Estr := {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"}

	Aadd(aSX3,{"NT2", "NT2_CNATUT", "JA098NatuTit()"})
	Aadd(aSX3,{"NT3", "NT3_CNATUT", "JA099NatuTit()"})

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP8214()
Função responsável por ajustar o X3_VISUAL 
dos campos de distribuicao (NZZ_STATUS e NZZ_CAJURI).
Para que possamos alterar esses campos via modelo

@since 10/07/2020
/*/
//-------------------------------------------------------------------
Static Function JURDEP8214()
	aSX3      := {}
	aSX3Old   := {}
	aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_VISUAL"}

	Aadd(aSX3, {"NZZ", "NZZ_STATUS", "A"} )
	Aadd(aSX3, {"NZZ", "NZZ_CAJURI", "A"} )

	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP8741()

Ajuste dos fundamentos que estão sem a chave do CAJURI, 
e alteração da consulta especifica da JURCTT
@author breno.gomes
@since 	02/12/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP8741()
Local aArea    := GetArea()
Local aAreaO07 := O07->( GetArea() )
Local aAreaSX2 := SX2->( GetArea() )
Local lRet     := .T.
Local cQuery   := ""
Local aRetorno := {}
Local nI       := 0
Local lCajuri  := .F.
local aSXB     := {}
local aSXBEstr := {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"}
Local cLastNSY := ""

	//Ajusta a consulta especifica da JURCTT
	aAdd (aSXB,{'JURCTT','2','01','01','','','','JURSXB("CTT","JURCTT",{"CTT_CUSTO","CTT_DESC01","CTT_RES"},.T.,.T.,,"CTBA030")'})
	AtuSXB(aSXB,aSXBEstr)

	If Select("O07") > 0
		lCajuri := O07->(FieldPos("O07_CAJURI")) > 0
	else
		DBSelectArea("O07")
			lCajuri := O07->(FieldPos("O07_CAJURI")) > 0
		O07->( DBCloseArea() )
	EndIf
	
	If lCajuri
		cQuery := " SELECT NSY.NSY_FILIAL "
		cQuery +=       " ,NSY.NSY_COD "
		cQuery +=       " ,NSY.NSY_CAJURI "
		cQuery +=       " ,O07.O07_CFUPRO "
		cQuery +=       " ,O07.O07_CCLFUN "
		cQuery += " FROM " + RetSqlName("NSZ") + " NSZ INNER JOIN " + RetSqlName("NSY") + " NSY ON ( NSY.NSY_CAJURI = NSZ.NSZ_COD "
		cQuery +=                                                                                  " AND NSZ.NSZ_FILIAL = NSY.NSY_FILIAL) "
		cQuery +=                                    " INNER JOIN " + RetSqlName("O07") + " O07 ON ( O07.O07_FILIAL = NSY.NSY_FILIAL "
		cQuery +=                                                                                  " AND O07.O07_COBJET = NSY.NSY_COD) "
		cQuery += " WHERE NSZ.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND NSY.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND O07.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND O07.O07_CAJURI = '' "
		cQuery += " GROUP BY NSY.NSY_FILIAL,NSY.NSY_COD, O07_CFUPRO, O07_CCLFUN, NSY.NSY_CAJURI"

		cQuery := ChangeQuery(cQuery)

		aRetorno := JurSql(cQuery, {"NSY_FILIAL", "NSY_COD", "O07_CFUPRO","O07_CCLFUN", "NSY_CAJURI"})
		Begin Transaction
			If FWX2Unico("O07") == "O07_FILIAL+O07_COBJET+O07_CFUPRO+O07_CCLFUN+O07_CAJURI"

				DbSelectArea("O07")
				O07->(dbSetOrder(1))//O07_FILIAL+O07_COBJET+O07_CFUPRO+O07_CCLFUN

				For nI := 1 To Len(aRetorno)
					If cLastNSY <> aRetorno[nI][2] 
						If O07->( dbSeek(aRetorno[nI][1] + aRetorno[nI][2] + aRetorno[nI][3] + aRetorno[nI][4]) )
							O07->(RecLock("O07",.F.))
								O07->O07_CAJURI := aRetorno[nI][5]
							O07->(MsUnlock())
						EndIf
					Else
						O07->(RecLock("O07",.T.))
								O07->O07_FILIAL := aRetorno[nI][1]
								O07->O07_CAJURI := aRetorno[nI][5]
								O07->O07_COBJET := aRetorno[nI][2]
								O07->O07_CFUPRO := aRetorno[nI][3]
								O07->O07_CCLFUN := aRetorno[nI][4]
						O07->(MsUnlock())
					EndIf
					cLastNSY := aRetorno[nI][2]
				Next

				O07->( DBCloseArea() )
			EndIf

		End Transaction
	EndIf

	
	
	RestArea(aAreaSX2)
	RestArea(aAreaO07)
	RestArea(aArea)
Return lRet
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP8740()
DJURDEP-8740 - Remoção do relacionamento entre a CC2 e a NSZ

@author Breno.gomes
@since 11/12/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURDEP8740()

	Local aArea := GetArea()

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) ) //X9_CDOM+X9_DOM

	If SX9->( dbSeek('NSZ' + 'CC2') ) .And. Alltrim(SX9->X9_EXPCDOM) == "NSZ_CMUNIC";
		.And. Alltrim(SX9->X9_EXPDOM) == "CC2_CODMUN"
		Reclock( 'SX9', .F. )
			SX9->( DbDelete() )
		SX9->( MsUnlock() )
	EndIf

	RestArea(aArea)

 Return Nil
 
//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP8623()
Incluir grid de causa raiz no perfil contencioso

@since 28/12/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP8623()
Local aDados   := {}
Local aNUZEstr := {'NUZ_FILIAL','NUZ_CAMPO','NUZ_DESCPO','NUZ_CTAJUR'}
Local lRet 	   := .T.
	
	If FWAliasInDic("O05")

		DbSelectArea("NYC")
		NYC->( dbSetOrder( 1 ) ) // NYC_FILIAL+NYC_CTPASJ+NYC_TABELA

		// Inclui o grid de Causa raiz caso não tenha
	
		//Contencioso
		If !NYC->( dbSeek ( xFilial('NYC') + '001' + 'O05' ) )
			NYC->(RecLock("NYC",.T.))
				NYC->NYC_FILIAL := xFilial('NYC')
				NYC->NYC_CTPASJ := '001'
				NYC->NYC_TABELA := 'O05'
				NYC->NYC_DTABEL := 'Causas Raizes do Processo'
			NYC->(MsUnlock())
		EndIf

		//Criminal
		If !NYC->( dbSeek ( xFilial('NYC') + '002' + 'O05' ) )
			NYC->(RecLock("NYC",.T.))
				NYC->NYC_FILIAL := xFilial('NYC')
				NYC->NYC_CTPASJ := '002'
				NYC->NYC_TABELA := 'O05'
				NYC->NYC_DTABEL := 'Causas Raizes do Processo'
			NYC->(MsUnlock())
		EndIf

		//Administrativo
		If !NYC->( dbSeek ( xFilial('NYC') + '003' + 'O05' ) )
			NYC->(RecLock("NYC",.T.))
				NYC->NYC_FILIAL := xFilial('NYC')
				NYC->NYC_CTPASJ := '003'
				NYC->NYC_TABELA := 'O05'
				NYC->NYC_DTABEL := 'Causas Raizes do Processo'
			NYC->(MsUnlock())
		EndIf

		//Cade
		If !NYC->( dbSeek ( xFilial('NYC') + '004' + 'O05' ) )
			NYC->(RecLock("NYC",.T.))
				NYC->NYC_FILIAL := xFilial('NYC')
				NYC->NYC_CTPASJ := '004'
				NYC->NYC_TABELA := 'O05'
				NYC->NYC_DTABEL := 'Causas Raizes do Processo'
			NYC->(MsUnlock())
		EndIf

		// Inclui os campos do grid na NUZ
		//Contencioso
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCAUSA', RetTitle( 'O05_DCAUSA' ), '001' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_CCLACA', RetTitle( 'O05_CCLACA' ), '001' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCLACA', RetTitle( 'O05_DCLACA' ), '001' } )
		//Criminal
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCAUSA', RetTitle( 'O05_DCAUSA' ), '002' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_CCLACA', RetTitle( 'O05_CCLACA' ), '002' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCLACA', RetTitle( 'O05_DCLACA' ), '002' } )
		//Administrativo
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCAUSA', RetTitle( 'O05_DCAUSA' ), '003' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_CCLACA', RetTitle( 'O05_CCLACA' ), '003' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCLACA', RetTitle( 'O05_DCLACA' ), '003' } )
		//Cade
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCAUSA', RetTitle( 'O05_DCAUSA' ), '004' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_CCLACA', RetTitle( 'O05_CCLACA' ), '004' } )
		aAdd( aDados, { xFilial('NUZ'), 'O05_DCLACA', RetTitle( 'O05_DCLACA' ), '004' } )

		AtuNUZ(aNUZEstr, aDados)

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP8958()
DJURDEP-8958 - (DÉBITOS) (SX9) Sugestão de relacionamentos

@since 05/04/2020
/*/
//-------------------------------------------------------------------
Static Function JURDEP8958()

	Local aArea := GetArea()

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) ) //X9_CDOM+X9_DOM

	If SX9->( dbSeek('NWU' + 'CC2') ) .And. Alltrim(SX9->X9_EXPCDOM) == "NWU_CMUNIC";
		.And. Alltrim(SX9->X9_EXPDOM) == "CC2_CODMUN"
		Reclock( 'SX9', .F. )
			SX9->( DbDelete() )
		SX9->( MsUnlock() )
	EndIf

	RestArea(aArea)

 Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP9132()
DJURDEP-9132 - (DÉBITOS) (SX9) Sugestão de relacionamentos

@since 27/04/2020
/*/
//-------------------------------------------------------------------
Static Function JURDEP9132()
Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

	Aadd(aSX3   , {"NT2", "NT2_CGRUAP", TamSx3("FRP_COD")[1] } )
	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP9418()
DJURDEP-9418 - (Débitos) Revisão final dos itens

@since 02/06/2021
/*/
//-------------------------------------------------------------------
Function JURDEP9418()

	DbSelectArea("SX7")
	ExcluiSX7("NTF_CADVCR" , "001", "NTF_DADVCR")
	ExcluiSX7("NTF_CADVCR" , "002", "NTF_EMAIL ")
	ExcluiSX7("NTF_CADVCR" , "003", "NTF_TELEFO")
	ExcluiSX7("NSZ_CPRORI" , "001", "NSZ_NPRORI")
	ExcluiSX7("NU6_CAJURI" , "007", "NU6_DCLIEN")

Return nil
//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP9435 ()
Inclui assunto juridico novo (NIP) e seus campos 

@author Breno.gomes
@since 	11/06/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP9435()
Local aArea     := GetArea()
Local aNUZDados := {}
Local aNUZEstr  := {"NUZ_FILIAL","NUZ_CAMPO","NUZ_DESCPO","NUZ_CTAJUR"}
Local lRet      := .T.
Local cFilTab   := xFilial('NUZ')

	DbSelectArea("NYB")
	NYB->( DbSetOrder(1) )//NYB_FILIAL+NYB_COD

	If !NYB->( DbSeek(xFilial("NYB") + "013") ) //NIP
		Reclock("NYB", .T.)
			NYB->NYB_COD = '013'
			NYB->NYB_DESC = STR0041
		NYB->( MsUnlock() )
	EndIf

	NYB->(DbCloseArea())

	DbSelectArea("NYC")
	NYC->( dbSetOrder( 1 ) ) // NYC_FILIAL+NYC_CTPASJ+NYC_TABELA

	If !NYC->( dbSeek ( xFilial('NYC') + '013' + 'NT9' ) )//Grid NIP
		NYC->(RecLock("NYC",.T.))
			NYC->NYC_FILIAL := xFilial('NYC')
			NYC->NYC_CTPASJ := '013'
			NYC->NYC_TABELA := 'NT9'
			NYC->NYC_DTABEL := 'Envolvidos'
		NYC->(MsUnlock())
	EndIf
	NYC->(DbCloseArea())
	RestArea(aArea)

	aAdd( aNUZDados, { cFilTab, 'NSZ_FILIAL', JA160X3Des( 'NSZ_FILIAL' ), '013' } ) // "Filial"
	aAdd( aNUZDados, { cFilTab, 'NSZ_COD '  , STR0031                   , '013' } ) // "Protocolo Interno"
	aAdd( aNUZDados, { cFilTab, 'NSZ_DTCERT', STR0032                   , '013' } ) // "Data da Notificação"
	aAdd( aNUZDados, { cFilTab, 'NSZ_DTEMIS', STR0033                   , '013' } ) // "Data da RVE"
	aAdd( aNUZDados, { cFilTab, 'NSZ_DTCONC', STR0042                   , '013' } ) // "Data Prazo"
	aAdd( aNUZDados, { cFilTab, 'NSZ_IDENTI', STR0034                   , '013' } ) // "Número da Demanda"
	aAdd( aNUZDados, { cFilTab, 'NSZ_NIRE'  , STR0035                   , '013' } ) // "Protocolo"
	aAdd( aNUZDados, { cFilTab, 'NSZ_NUMPED', STR0036                   , '013' } ) // "Prazo"
	aAdd( aNUZDados, { cFilTab, 'NSZ_DETALH', STR0037                   , '013' } ) // "Reclamação"
	aAdd( aNUZDados, { cFilTab, 'NSZ_TOMBO' , STR0038                   , '013' } ) // "Assunto"
	aAdd( aNUZDados, { cFilTab, 'NSZ_OBJSOC', STR0039                   , '013' } ) // "Natureza"
	aAdd( aNUZDados, { cFilTab, 'NSZ_ULTCON', STR0040                   , '013' } ) // "Status ANS"
	aAdd( aNUZDados, { cFilTab, 'NSZ_CESCRI', RetTitle( 'NSZ_CESCRI' )  , '013' } ) // "Cód Unidade"
	aAdd( aNUZDados, { cFilTab, 'NSZ_DESCRI', RetTitle( 'NSZ_DESCRI' )  , '013' } ) // "Unidade"
	aAdd( aNUZDados, { cFilTab, 'NSZ_NUMREG', RetTitle( 'NSZ_NUMREG' )  , '013' } ) // "Plano contratado"
	aAdd( aNUZDados, { cFilTab, 'NSZ_CPART2', RetTitle( 'NSZ_CPART2' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_CAREAJ', RetTitle( 'NSZ_CAREAJ' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_DAREAJ', RetTitle( 'NSZ_DAREAJ' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_SIGLA1', RetTitle( 'NSZ_SIGLA1' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_DPART1', RetTitle( 'NSZ_DPART1' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_SIGLA2', RetTitle( 'NSZ_SIGLA2' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_DPART2', RetTitle( 'NSZ_DPART2' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_OBSERV', RetTitle( 'NSZ_OBSERV' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_NUMCAS', RetTitle( 'NSZ_NUMCAS' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_SITUAC', JA160X3Des( 'NSZ_SITUAC' ), '013' } ) // "Status Interno"
	aAdd( aNUZDados, { cFilTab, 'NSZ_DTENCE', RetTitle( 'NSZ_DTENCE' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_CMOENC', RetTitle( 'NSZ_CMOENC' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_DMOENC', RetTitle( 'NSZ_DMOENC' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NSZ_DETENC', RetTitle( 'NSZ_DETENC' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NT9_CTPENV', RetTitle( 'NT9_CTPENV' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NT9_DTPENV', RetTitle( 'NT9_DTPENV' )  , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NTA_HORA'  , RetTitle( 'NTA_HORA' )    , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NTA_DESC'  , RetTitle( 'NTA_DESC' )    , '013' } )
	aAdd( aNUZDados, { cFilTab, 'NT9_NOME'  , JA160X3Des( 'NT9_NOME' )  , '013' } ) // "Nome do beneficiario"
	
	DbSelectArea("NT9")
	If NT9->( FieldPos("NT9_CODBEN") ) > 0
		aAdd( aNUZDados, { cFilTab, 'NT9_CODBEN', JA160X3Des( 'NT9_CODBEN' ), '013' } ) // "Código beneficiario"
	EndIf
	NT9->(DbCloseArea())
	AtuNUZ(aNUZEstr, aNUZDados)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP9548()
Altera o tamanho do campo NQR_NOMRPT

@since 02/08/2021
/*/
//-------------------------------------------------------------------
Static Function JURDEP9548()

Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

	Aadd(aSX3 , { "NQR", "NQR_NOMRPT", 100 } )
	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP9736()
Altera o tamanho do campo NT4_RESUMO

@since 28/09/2021
/*/
//-------------------------------------------------------------------
Static Function JURDEP9736()

Local aArea     := GetArea()
Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

	DbSelectArea("NT4")

	If NT4->( FieldPos("NT4_RESUMO") ) > 0
		Aadd(aSX3 , { "NT4", "NT4_RESUMO", 200 } )
		//Atualiza o dicionario de dados
		AtuSX3(aSX3, aSX3Estr, aSX3Old)
	EndIf

	NT4->( DbCloseArea() )
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP9891()
Altera o tamanho do campo NSZ_TOMBO

@since 28/09/2021
/*/
//-------------------------------------------------------------------
Static Function JURDEP9891()

Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

	Aadd(aSX3 , { "NSZ", "NSZ_TOMBO", 200 } )
	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURDEP9915()
Removendo Relacao da NSU para a tabela NUQ (campo NUQ_CAJURI+NUQ_INSTAN)

@since 	21/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JURDEP9915()

Local aArea := GetArea()

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) )                 //X9_CDOM+X9_DOM

	If SX9->( dbSeek('NSU' + 'NUQ') ) .And. Alltrim(SX9->X9_EXPDOM) == "NUQ_CAJURI+NUQ_INSTAN"
		Reclock( 'SX9', .F. )
			SX9->( DbDelete() )
		SX9->( MsUnlock() )
	EndIf

	RestArea(aArea)

 Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} JDEP10059()
DJURDEP-10059 - Removendo relacionamentos inutilizados

@since 	21/10/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDEP10059()

Local aArea    := GetArea()
Local aAreaSx9 := SX9->(GetArea())
Local aDelSx9  := {}
Local n1       := 0

	//X9_DOM,X9_CDOM,X9_EXPDOM,X9_EXPCDOM
	aAdd(aDelSx9,{'NQ9','NQR','NQ9_CODRPT'           ,'NQR_COD'               })
	aAdd(aDelSx9,{'CC2','NT9','CC2_CODMUN'           ,'NT9_CMUNIC'            })
	aAdd(aDelSx9,{'NQE','NTD','NQE_COD'              ,'NTD_CVARA'             })
	aAdd(aDelSx9,{'SA1','NU8','A1_COD'               ,'NU8_CCLIEN'            })
	aAdd(aDelSx9,{'CC2','NUQ','CC2_CODMUN'           ,'NUQ_CMUNIC'            })

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) )//X9_CDOM+X9_DOM

	For n1 := 1 To Len(aDelSx9)
		If SX9->( DbSeek(aDelSx9[n1][2] + aDelSx9[n1][1]) )
			While SX9->(!Eof()) .and. SX9->X9_DOM == aDelSx9[n1][1] .and. SX9->X9_CDOM == aDelSx9[n1][2]
				IF AllTrim(SX9->X9_EXPDOM) == aDelSx9[n1][3] .and. AllTrim(SX9->X9_EXPCDOM) == aDelSx9[n1][4]
					Reclock( 'SX9', .F. )
						SX9->( DbDelete() )
					SX9->( MsUnlock() )
				Endif
				SX9->(DbSkip())
			End
		EndIf
	Next
	
	RestArea(aArea)
	RestArea(aAreaSx9)

 Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JDEP10267()
DJURDEP-10267 - Removendo relacionamento inutilizado NVJ

@since 	16/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDEP10267()

Local aArea    := GetArea()
Local aAreaSx9 := SX9->(GetArea())

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) ) //X9_CDOM+X9_DOM

	If SX9->( dbSeek('NVJ' + 'SX5' ) ) .And. Alltrim(SX9->X9_EXPCDOM) == "'JW'+NVJ_CASJUR";
		.And. Alltrim(SX9->X9_EXPDOM) == "X5_TABELA+X5_CHAVE"
		
		Reclock( 'SX9', .F. )
			SX9->( DbDelete() )
		SX9->( MsUnlock() )
	EndIf

	RestArea(aArea)
	RestArea(aAreaSx9)

 Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} JDEP11229()
//-- Ajuste tamanho dos campos de descrição de forma de correção

@since 31/10/2022
/*/
//-------------------------------------------------------------------
Static Function JDEP11229()

Local aSX3      := {}
Local aSX3Old   := {}
Local aSX3Estr  := {"X3_ARQUIVO", "X3_CAMPO", "X3_TAMANHO"}

	Aadd(aSX3 , { "NSY", "NSY_DCOMON", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCJU1", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCJU2", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCJUC", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCJUR", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCJUT", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCMU1", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCMU2", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCMUC", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCMUL", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCMUT", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCOR1", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCOR2", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCORC", 20 } )
	Aadd(aSX3 , { "NSY", "NSY_DFCORT", 20 } )
	Aadd(aSX3 , { "NSZ", "NSZ_DFCORR", 20 } )
	Aadd(aSX3 , { "NXY", "NXY_DFCORR", 20 } )
	Aadd(aSX3 , { "O0W", "O0W_DFRCOR", 20 } )
	Aadd(aSX3 , { "NT2", "NT2_DCOMON", 20 } )

	Aadd(aSX3 , { "NYZ", "NYZ_DFCORR", 20 } )
	Aadd(aSX3 , { "NZ0", "NZ0_DCOMON", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DCOMON", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCJU1", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCJU2", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCJUC", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCJUR", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCJUT", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCMUL", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCOR1", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCOR2", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCORC", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFCORT", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFJUR1", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFMULC", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFMULT", 20 } )
	Aadd(aSX3 , { "NZ1", "NZ1_DFMUL2", 20 } )
 
	//Atualiza o dicionario de dados
	AtuSX3(aSX3, aSX3Estr, aSX3Old )

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} JDEP11683()
Dropa e recria a tabela NQ3 (Fila de impressão)
DJURDEP-11683 - Ativa o auto recno da NQ3

@since 	30/03/2023
/*/
//-------------------------------------------------------------------
Function JDEP11683()
Local aArea	    := GetArea()
Local aAreaSX2  := SX2->( GetArea() )

	// Força a habiliação do Recno auto incremento
	SX2->( DbSetOrder(1) )

	If SX2->( DbSeek("NQ3") )
		RecLock("SX2", .F.)
			SX2->X2_AUTREC	:= '1'
		SX2->( MsUnLock() )
	EndIf

	// Recria a tabela
	TCLink()
	If TCCanOpen( RetSqlName("NQ3", .T.)) .AND. TCDelFile( RetSqlName("NQ3", .T.) )
		Chkfile("NQ3")
	EndIf
	TCUnlink()

	RestArea( aAreaSX2 )
	RestArea( aArea )

 Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JDEP12037()
DJURDEP-12037 - Removendo relacionamento inutilizado

@since 	10/10/2023
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JDEP12037()

Local aArea    := GetArea()
Local aAreaSx9 := SX9->(GetArea())

	DbSelectArea("SX9")
	SX9->( dbSetOrder( 2 ) ) // X9_CDOM + X9_DOM

	If SX9->( dbSeek('NY0' + 'NSZ' ) ) .And. Alltrim(SX9->X9_EXPCDOM) == "NY0_COD";
			.And. Alltrim(SX9->X9_EXPDOM) == "NSZ_CODCON"
		Reclock( 'SX9', .F. )
		SX9->( DbDelete() )
		SX9->( MsUnlock() )
	EndIf

	RestArea(aArea)
	RestArea(aAreaSx9)

 Return Nil
