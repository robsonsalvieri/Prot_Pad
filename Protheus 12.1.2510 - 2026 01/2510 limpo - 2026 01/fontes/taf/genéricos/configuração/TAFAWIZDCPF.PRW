#INCLUDE "PROTHEUS.CH"
#INCLUDE "TAFAWIZDCPF.CH" 
#INCLUDE "APWIZARD.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFAWizdCPF

Configura o TSS para o e-Social com certificado CPF 
*Função Original: TAFAWizd

@author Ricardo Lovrenovic
@since 16/08/2018
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
Function TAFAWizdCP() 

	Local aTxtApre   :=	{}
	Local aPaineis   :=	{}
	Local aItens	 := {}
	Local lRet		 :=	.T.
	Local cNomWiz	 := "TAFAWIZDCPF" + StrTran(cEmpAnt," ","") + StrTran(cFilAnt," ","")
	Local cMsgAux	 := ""
	Local cURLTSS	 := IIf( FindFunction( "TafGetUrlTSS" ), TafGetUrlTSS(), PadR(GetNewPar("MV_TAFSURL",""),250) ) // Utiliza funçao padronizada com compertilhamento de empresa
	Local cAmbeSocial:= AllTrim(GetNewPar( "MV_TAFAMBE", "2" ))
	Local dIniEs	 := Stod(AllTrim(GetNewPar( "MV_TAFINIE", Space(8) )) )		
	Local nAmbeSocial:= 0
	
	aAdd ( aTxtApre , STR0047 ) //"Rotina de Configuração do Ambiente TAF - Totvs Automação Fiscal"
	aAdd ( aTxtApre , "" )	
	aAdd ( aTxtApre , STR0002 ) //"Preencha corretamente as informações solicitadas."
	aAdd ( aTxtApre , STR0037 ) //"Esta rotina tem como objetivo ajuda-lo na configuração da integração com o Protheus/TAF com o serviço Totvs Services SOA. "
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montando Wizard ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	aAdd ( aPaineis , {} )
	nPos	:=	Len ( aPaineis )
	aAdd ( aPaineis[nPos] , STR0049 + " - " + STR0002 ) //"Parâmetros de Ambiente - Preencha corretamente as informações solicitadas."
	aAdd ( aPaineis[nPos] , STR0050 ) //"Informe a URL do servidor TSS e o ambiente do RET que o mesmo deve se conectar."
	aAdd ( aPaineis[nPos] , {} )
	 
	aItens:= {STR0011,STR0051} //"1-Produção"#"2-Pré Produção"
	nAmbeSocial	:= aScan( aItens,{ |x| Left(x,1) == AllTrim( cAmbeSocial )} )
	
	If nAmbeSocial	== 0
		nAmbeSocial	:= 2
	EndIf
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {1,STR0033 + " e-Social",,,,,,});		aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,,,,,,,,,,nAmbeSocial}) //Ambiente
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd(aPaineis[nPos][3], {1,STR0056,,,,,,});						aAdd(aPaineis[nPos][3], {2,,,3,,,,,,,,,,,,,,,,,,dIniEs}) //'Data de Inicio da Empresa no eSocial'
	
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd(aPaineis[nPos][3], {1,STR0053,,,,,,});	 					aAdd (aPaineis[nPos][3], {0,"",,,,,,})		//"Url Totvs Service SOA"

	aAdd(aPaineis[nPos][3], {2,,,1,,,,150,,,,{ "xValWizCmp",11,{"",""}},,,,,,.T.,,,,cURLTSS});		aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});							aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	 
	aAdd ( aPaineis , {} )
	nPos := Len (aPaineis)
	aAdd (aPaineis[nPos], STR0002) 
	aAdd (aPaineis[nPos], STR0054)
	aAdd (aPaineis[nPos], {})
	
	aItens:= {STR0014,STR0015,STR0016,"KeyStore"} //"Formato Apache (.pem)"#"Formato PFX (*.pfx ou *.p12)"#"HSM"       
	
	aAdd (aPaineis[nPos][3], {1,STR0013,,,,,,});										aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,, {"xFunVldWiz","CFG-CERTIFICADO"}}) //"Tipo de certificado digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0017,,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 	//"Nome do arquivo do certificado digital"
	aAdd (aPaineis[nPos][3], {2,,,1,,,,,,.T.,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0018,,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,}) 	//"Informe o nome do arquivo do private key"
	aAdd (aPaineis[nPos][3], {2,,,1,,,,,,.T.,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0019,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100}) 	//"Slot do certificado digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0020,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100}) 	//"Label do certificado digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0021,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,,,.T.,.F.}) //"Senha do arquivo digital"
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0022,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,/*{ "xValWizCmp",12,{"",""}}*/,,,,,}) //"Caminho e arquivo do módulo HSM" 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,STR0057,,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,/*{ "xValWizCmp",12,{"",""}}*/,,,,,}) //"ID Hexadecimal" 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,"Hostname",,,,,,});										aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aAdd (aPaineis[nPos][3], {1,"Issuer",,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd (aPaineis[nPos][3], {1,"Subject",,,,,,});										aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {2,,,1,,,,250,,,,,,,,,,.T.});								aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aItens:= {"1-MY","2-Root","3-Trust","4-CA"} 
	aAdd (aPaineis[nPos][3], {1,"Path",,,,,,});											aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aItens:= {"1-LocalMachine","2-Default"} 
	aAdd (aPaineis[nPos][3], {1,"System",,,,,,});										aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	aItens:= {"1-WinStore","2-LinuxStore"} 
	aAdd (aPaineis[nPos][3], {1,"Type",,,,,,});											aAdd( aPaineis[nPos][3], {3,,,,,aClone(aItens),,,,,,,}) 
	aAdd (aPaineis[nPos][3], {0,"",,,,,,});												aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	
	// TAFColumnPos( "C1E_CNPJTR" ) ****** VALIDAR SE EXISTE ESSE CAMPO NO COMEÇO DA WIZARD

	//Obs: Esta validação valida todos os campos no Next da Wizard
	cIniCnpj := Posicione("C1E",3,xFilial( "C1E" ) + PadR( SM0->M0_CODFIL , TamSX3( 'C1E_FILTAF' )[1] ) + '1' ,"C1E_CNPJTR")		
	aAdd (aPaineis[nPos][3], {1,STR0058,,,,,,})	//"CNPJ/CPF Transmissor (Diferente do Empregador)"
	aAdd (aPaineis[nPos][3], {2,,,1,,,,100,,,,{ "xValWizCmp",12,{"",""}},,,,,,,,,,cIniCnpj})

	aAdd (aPaineis[nPos][3], {1,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})
	aAdd (aPaineis[nPos][3], {0,"",,,,,,})

	aAdd ( aPaineis , {} )
	nPos := Len (aPaineis)
	aAdd (aPaineis[nPos], "")
	aAdd (aPaineis[nPos], STR0001)
	aAdd (aPaineis[nPos], {})
	
	cMsgAux := STR0046 //"Você concluíu com sucesso a configuração da integração do Protheus/TAF para o Totvs Services SOA."
	aAdd (aPaineis[nPos][3], {8,,,,,,,,,,,,,,,,,,.F.,.F.,cMsgAux})
	
	lRet	:=	XFUNWizard ( aTxtApre , aPaineis , cNomWiz,,,, { || GrParamAmb(), GrParamIniEs()  } )
	
Return Nil  

//-------------------------------------------------------------------
/*/{Protheus.doc} GrParamAmb
O objetivo da function é gravar o valor configurado na wizard para 
o parâmetro de ambiente do eSocial. 

@author Vitor Siqueira
@since 06/02/2017
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
Static Function GrParamAmb() 
	Local aWizard := {}	
	Local cConteudo := ""
	Local cNomWiz := "TAFAWIZDCPF" + StrTran(cEmpAnt," ","") + StrTran(cFilAnt," ","")
		
	//Carrega os dados preenchidos na wizard
	XFUNLoadProf( cNomWiz , @aWizard )	
	If Len( aWizard ) > 0 .And. Len( aWizard[1] ) > 0
		cConteudo := SubStr(aWizard[1][1],1,1)

		//Altera o conteudo do parâmetro
		PUTMV( "MV_TAFAMBE", cConteudo )
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GrParamIniEs
O objetivo da function é gravar o valor configurado na wizard para 
o parâmetro de data de inicio da empresa no eSocial

@author Luccas Curcio
@since 26/05/2017
@version 1.0	

@return Nil 
/*/
//-------------------------------------------------------------------
Static function GrParamIniEs() 

	Local aWizard	
	Local cConteudo	
	Local cNomWiz	

	aWizard := {}	
	cConteudo := ""
	cNomWiz := "TAFAWIZDCPF" + StrTran(cEmpAnt," ","") + StrTran(cFilAnt," ","")
		
	//Carrega os dados preenchidos na wizard
	XFUNLoadProf( cNomWiz , @aWizard )	

	If Len( aWizard ) > 0 .And. Len( aWizard[1] ) > 1

		cConteudo := allTrim( Dtos(aWizard[ 1 , 2 ]) )

		//Altera o conteudo do parâmetro
		PUTMV( 'MV_TAFINIE', cConteudo )
	EndIf
Return nil
