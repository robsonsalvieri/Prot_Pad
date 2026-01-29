#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "NFCA020.CH"

Static _oJsonSup    := JsonObject():New()
Static _lWasLoaded  := .F.
Static _aItems      := {}
Static _oJsonField	:= JsonObject():New()
Static _lInNFCAlt	:= FWIsInCallStack("PGCA010") .or. (IsBlind() .and. FWIsInCallStack("putUpdateQuotation"))
Static _lLegaGrid	:= !_lInNFCAlt .and. type("aCols") == "A" .and. len(aCols) > 0 .and. type("aHeader") == "A" .and. len(aHeader) > 0
Static _lTrbGen		:= IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SC8", "C8_IDTRIB"), .F.)
Static _oHashTCI	:= Nil
Static _lRecalcTrib	:= .F.
Static _cRegIBSMun	:= "000061" //IBS Municipal
Static _cRegIBSEst	:= "000060" //IBS ESTADUAL
Static _cRegCBSFed	:= "000062" //CBS Federal


//-------------------------------------------------------------------
/*/{Protheus.doc} NFCA020()
Esta rotina é responsável por ser a alternativa
da edição da cotação do NFC via MVC
@author Leandro Fini
@since 01/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Function NFCA020()
	Help(nil, nil , 'NFCA020', nil, STR0064, 1, 0, nil, nil, nil, nil, nil, {} ) //-- Não é possível acessar esta rotina diretamente via menu.
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu Funcional da Rotina 

@author Leandro Fini
@since 01/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()   
	Local aRotina := {}

	ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.NFCA020' OPERATION 2 ACCESS 0 //-- Visualizar
	ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.NFCA020' OPERATION 4 ACCESS 0 //-- Editar
	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.NFCA020' OPERATION 8 ACCESS 0 //-- Imprimir
Return(aRotina) 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Estrutura do Modelo de Dados

@author Leandro Fini
@since 01/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef() 

Local oStrDHU    := FWFormStruct( 1, 'DHU' )
Local oStrSC8    := FWFormStruct( 1, 'SC8')
Local oModel 	 := Nil
Local cNFCMoed 	 := SuperGetMV("MV_NFCMOED", .F., "1")
Local aSM0Data   := {}
Local oStruF2D	 := Nil
Local bLoadFil 	 := {}
Local lBrazil	 := cPaisLoc == "BRA"

aSM0Data    := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , { "M0_CIDENT","M0_ENDENT","M0_BAIRENT","M0_CEPENT" } )
_aItems     := {}
_lWasLoaded := .F.
_oJsonField	:= JsonObject():New()
_oHashTCI	:= JsonObject():New()

//------------------------------------------------------------------------------//
// ** CAMPOS DE DADOS DO FORNECEDOR/PARTICIPANTE -----------------------------//

oStrDHU:AddField( 	STR0031,;									// 	[01]  C   Titulo do campo	//"Redist. Val."
					STR0031,;									// 	[02]  C   ToolTip do campo	//"Redistribuição de Valores"
					"DHU_TPFORN",;								// 	[03]  C   Id do Field
					"C",;										// 	[04]  C   Tipo do campo
					1,;											// 	[05]  N   Tamanho do campo
					0,;											// 	[06]  N   Decimal do campo
					{|a,b,c,d| supFldVld(a,b,c,d)},;			// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					{'1='+STR0065,'2='+STR0066},;				//	[09]  A   Lista de valores permitido do campo	//{'1=Sim','2=Não'}
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| GetSupType()},;							//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					IIf(IsBlind(), _oJsonSup['newParticipant'], !_oJsonSup['newParticipant']),;//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0005,;									// 	[01]  C   Titulo do campo
					STR0005,;              				        // 	[02]  C   ToolTip do campo
					 "DHU_CODFOR",;								// 	[03]  C   Id do Field
					 "C",;										// 	[04]  C   Tipo do campo
					 TamSX3("A2_COD")[1],;						// 	[05]  N   Tamanho do campo
					 0,;										// 	[06]  N   Decimal do campo
					 {|a,b,c,d| supFldVld(a,b,c,d)},;           // 	[07]  B   Code-block de validação do campo
					 {|| FwFldGet('DHU_TPFORN') == '1'},;		// 	[08]  B   Code-block de validação When do campo
					 NIL,;										//	[09]  A   Lista de valores permitido do campo
					 .F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|| _oJsonSup['supplierCode'] },;          //	[11]  B   Code-block de inicializacao do campo
					 NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					 IIf(IsBlind(), _oJsonSup['newParticipant'], !_oJsonSup['newParticipant']),;				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0006,;									// 	[01]  C   Titulo do campo
					STR0006,;									// 	[02]  C   ToolTip do campo
					 "DHU_LOJAFOR",;							// 	[03]  C   Id do Field
					 "C",;										// 	[04]  C   Tipo do campo
					 TamSX3("A2_LOJA")[1],;						// 	[05]  N   Tamanho do campo
					 0,;										// 	[06]  N   Decimal do campo
					 {|a,b,c,d| supFldVld(a,b,c,d)},;			// 	[07]  B   Code-block de validação do campo
					 {|| FwFldGet('DHU_TPFORN') == '1'},;		// 	[08]  B   Code-block de validação When do campo
					 NIL,;										//	[09]  A   Lista de valores permitido do campo
					 .F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|| _oJsonSup['supplierStore'] },;         //	[11]  B   Code-block de inicializacao do campo
					 NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					 IIf(IsBlind(), _oJsonSup['newParticipant'], !_oJsonSup['newParticipant']),;				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.)										// 	[14]  L   Indica se o campo é virtual
					 										    

oStrDHU:AddField(	STR0007,;									// 	[01]  C   Titulo do campo
					STR0007,;									// 	[02]  C   ToolTip do campo
					"DHU_NOMFOR",;								// 	[03]  C   Id do Field
					"C",;										// 	[04]  C   Tipo do campo
					TamSX3("A2_NOME")[1],;						// 	[05]  N   Tamanho do campo
					0,;											// 	[06]  N   Decimal do campo
					{|a,b,c,d| supFldVld(a,b,c,d)},;			// 	[07]  B   Code-block de validação do campo
					{|| FwFldGet('DHU_TPFORN') == '2'},;		// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;               						//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| GetSupName() },;                        //	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					IIf(IsBlind(), _oJsonSup['newParticipant'], !_oJsonSup['newParticipant']),;				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)	
																// 	[14]  L   Indica se o campo é virtual
oStrDHU:AddField(	STR0032,;									// 	[01]  C   Titulo do campo
					STR0032,;					    			// 	[02]  C   ToolTip do campo
					"DHU_EMAIL",;								// 	[03]  C   Id do Field
					"C",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_FORMAIL")[1],;					// 	[05]  N   Tamanho do campo
					0,;											// 	[06]  N   Decimal do campo
					{|a,b,c,d| supFldVld(a,b,c,d)},;			// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| ""},;									//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					IIf(IsBlind(), _oJsonSup['newParticipant'], !_oJsonSup['newParticipant']),;				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0033,;									// 	[01]  C   Titulo do campo
					STR0033,;				     				// 	[02]  C   ToolTip do campo
					"DHU_CONTATO",;								// 	[03]  C   Id do Field
					"C",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_CONTATO")[1],;					// 	[05]  N   Tamanho do campo
					0,;											// 	[06]  N   Decimal do campo
					NIL,;										// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| ""},;									//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					IIf(IsBlind(), _oJsonSup['newParticipant'], !_oJsonSup['newParticipant']),;				//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0034,;									// 	[01]  C   Titulo do campo
					STR0034,;									// 	[02]  C   ToolTip do campo
					"DHU_NUMPRO",;								// 	[03]  C   Id do Field
					"C",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_NUMPRO")[1],;					// 	[05]  N   Tamanho do campo
					0,;											// 	[06]  N   Decimal do campo
					NIL,;										// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| _oJsonSup['proposal'] },;				//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

//------------------------------------------------------------------------------//
// ** CAMPOS CABEÇALHO DA COTAÇÃO  --------------------------------------------//

oStrDHU:AddField(	STR0008,;									// 	[01]  C   Titulo do campo
					STR0008,;									// 	[02]  C   ToolTip do campo
					"DHU_DESC",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_DESC")[1],;						// 	[05]  N   Tamanho do campo
					TamSX3("C8_DESC")[2],;						// 	[06]  N   Decimal do campo
					{|| calcDiscount(1)},;                      // 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| 0 },;									//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0009,;									// 	[01]  C   Titulo do campo
					STR0009,;									// 	[02]  C   ToolTip do campo
					"DHU_TOTIT",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_TOTAL")[1],;						// 	[05]  N   Tamanho do campo
					TamSX3("C8_TOTAL")[2],;						// 	[06]  N   Decimal do campo
					nil,;										// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| 0},;				                    //	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)

oStrDHU:AddField(	STR0010,;									// 	[01]  C   Titulo do campo
					STR0010,;									// 	[02]  C   ToolTip do campo
					"DHU_TOTCOT",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_TOTAL")[1],;						// 	[05]  N   Tamanho do campo
					TamSX3("C8_TOTAL")[2],;						// 	[06]  N   Decimal do campo
					NIL,;										// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0011,;									// 	[01]  C   Titulo do campo
					STR0011,;									// 	[02]  C   ToolTip do campo
					"DHU_VLDESC",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_VLDESC")[1],;					// 	[05]  N   Tamanho do campo
					TamSX3("C8_VLDESC")[2],;					// 	[06]  N   Decimal do campo
					{||calcDiscount(2)},;										// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| 0 },;									//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual


oStrDHU:AddField( 	STR0013,;													// 	[01]  C   Titulo do campo	//"Redist. Val."
					STR0013,;													// 	[02]  C   ToolTip do campo	//"Redistribuição de Valores"
					"DHU_FRETE",;												// 	[03]  C   Id do Field
					"C",;														// 	[04]  C   Tipo do campo
					1,;															// 	[05]  N   Tamanho do campo
					0,;															// 	[06]  N   Decimal do campo
					FwBuildFeature( STRUCT_FEATURE_VALID,"NF020TgFre()"),;	// 	[07]  B   Code-block de validação do campo
					{||.T.},;													// 	[08]  B   Code-block de validação When do campo
					{'C=CIF','F=FOB','T='+STR0068,'S='+STR0069, 'R='+STR0093, 'D='+STR0094},;    //	[09]  A   Lista de valores permitido do campo	//{'C=CIF','F=FOB','T=Terceiros', 'S=Sem frete', 'R=Por Conta Remetente', 'D=Por Conta Destinatário'}
					.F.,;														//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| GetAdvFVal("SC8", "C8_TPFRETE" , FWxFilial("SC8") + _oJsonSup['quoteNumber'] + _oJsonSup['supplierCode'] + _oJsonSup['supplierStore'] + _oJsonSup['proposal'] ,1,"",.T.)},;											//	[11]  B   Code-block de inicializacao do campo
					NIL,;														//	[12]  L   Indica se trata-se de um campo chave
					.F.,;														//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)
					
oStrDHU:AddField(	STR0012,;									// 	[01]  C   Titulo do campo
					STR0012,;									// 	[02]  C   ToolTip do campo
					"DHU_VALFRE",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_VALFRE")[1],;					// 	[05]  N   Tamanho do campo
					TamSX3("C8_VALFRE")[2],;					// 	[06]  N   Decimal do campo
					{|| calcExpenses('DHU_VALFRE')},;										// 	[07]  B   Code-block de validação do campo
					{|| FwFldGet('DHU_FRETE') == 'C'},;														// 	[08]  B   Code-block de validação When do campo
					NIL,;														//	[09]  A   Lista de valores permitido do campo
					.F.,;														//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| 0 },;													//	[11]  B   Code-block de inicializacao do campo
					NIL,;														//	[12]  L   Indica se trata-se de um campo chave
					.F.,;														//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)														// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0014,;									// 	[01]  C   Titulo do campo
					STR0014,;									// 	[02]  C   ToolTip do campo
					 "DHU_COND",;								// 	[03]  C   Id do Field
					 "C",;										// 	[04]  C   Tipo do campo
					 TamSX3("C8_COND")[1],;						// 	[05]  N   Tamanho do campo
					 0,;										// 	[06]  N   Decimal do campo
					 {|| VldPayment()},;						//  [07]  B   Code-block de validação do campo
					 NIL,;										// 	[08]  B   Code-block de validação When do campo
					 NIL,;										//	[09]  A   Lista de valores permitido do campo
					 .T.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|| GetAdvFVal("SC8", "C8_COND" , fwxFilial("SC8") + _oJsonSup['quoteNumber'] + _oJsonSup['supplierCode'] + _oJsonSup['supplierStore'] + _oJsonSup['proposal'] ,1,"",.T.)},;									//	[11]  B   Code-block de inicializacao do campo
					 NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					 .F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.)										// 	[14]  L   Indica se o campo é virtual

//Parametro (MV_NFCMOED); 1=CTO(Default);2=MV_MOEDA 
If cNFCMoed == "1"

	oStrDHU:AddField(	STR0015,;									// 	[01]  C   Titulo do campo
						STR0015,;									// 	[02]  C   ToolTip do campo
						"DHU_MOEDA",;								// 	[03]  C   Id do Field
						"C",;										// 	[04]  C   Tipo do campo
						TamSX3("CTO_MOEDA")[1],;					// 	[05]  N   Tamanho do campo
						0,;											// 	[06]  N   Decimal do campo
						{|| NF020VlMoe('DHU_MOEDA')},;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| GetAdvFVal("SC8", "C8_MOEDA" , fwxFilial("SC8") + _oJsonSup['quoteNumber'] + _oJsonSup['supplierCode'] + _oJsonSup['supplierStore'] + _oJsonSup['proposal'] ,1,"",.T.)},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual
Else
	
	oStrDHU:AddField(	STR0015,;									// 	[01]  C   Titulo do campo
						STR0015,;									// 	[02]  C   ToolTip do campo
						"CMOEDAPED",;								// 	[03]  C   Id do Field
						"C",;										// 	[04]  C   Tipo do campo
						1,;											// 	[05]  N   Tamanho do campo
						0,;											// 	[06]  N   Decimal do campo
						{|| NFCDescMoed(1)},;						// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil,;										//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual
	
	oStrDHU:AddField(	STR0091,;								// 	[01]  C   Titulo do campo
						STR0091,;								// 	[02]  C   ToolTip do campo
						"CDESCMOED",;								// 	[03]  C   Id do Field
						"C",;										// 	[04]  C   Tipo do campo
						10,;										// 	[05]  N   Tamanho do campo
						0,;											// 	[06]  N   Decimal do campo
						Nil,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						Nil,;										//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

EndIf

oStrDHU:AddField(	STR0016,;									// 	[01]  C   Titulo do campo
					STR0016,;									// 	[02]  C   ToolTip do campo
					"DHU_TXMOEDA",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_TXMOEDA")[1],;					// 	[05]  N   Tamanho do campo
					TamSX3("C8_TXMOEDA")[2],;					// 	[06]  N   Decimal do campo
					{|| NF020VlMoe('DHU_TXMOEDA')},;			// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| GetAdvFVal("SC8", "C8_TXMOEDA" , fwxFilial("SC8") + _oJsonSup['quoteNumber'] + _oJsonSup['supplierCode'] + _oJsonSup['supplierStore'] + _oJsonSup['proposal'] ,1,"",.T.)},;				//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0017,;									// 	[01]  C   Titulo do campo
					STR0017,;									// 	[02]  C   ToolTip do campo
					"DHU_DESPESA",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_DESPESA")[1],;					// 	[05]  N   Tamanho do campo
					TamSX3("C8_DESPESA")[2],;					// 	[06]  N   Decimal do campo
					{|| calcExpenses('DHU_DESPESA')},;										// 	[07]  B   Code-block de validação do campo
					NIL,;										// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| 0 },;									//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

oStrDHU:AddField(	STR0018,;									// 	[01]  C   Titulo do campo
					STR0018,;									// 	[02]  C   ToolTip do campo
					"DHU_SEGURO",;								// 	[03]  C   Id do Field
					"N",;										// 	[04]  C   Tipo do campo
					TamSX3("C8_SEGURO")[1],;					// 	[05]  N   Tamanho do campo
					TamSX3("C8_SEGURO")[2],;					// 	[06]  N   Decimal do campo
					{|| calcExpenses('DHU_SEGURO')},;										// 	[07]  B   Code-block de validação do campo
					{|| .T.},;									// 	[08]  B   Code-block de validação When do campo
					NIL,;										//	[09]  A   Lista de valores permitido do campo
					.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{|| 0 },;									//	[11]  B   Code-block de inicializacao do campo
					NIL,;										//	[12]  L   Indica se trata-se de um campo chave
					.F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.)										// 	[14]  L   Indica se o campo é virtual

// -------------------------------------------------------------------//
// ** CAMPOS DE INFORMAÇÕES DE ENTREGA ** ---------------------------//

oStrSC8:AddField(	STR0024,;									// 	[01]  C   Titulo do campo  - "Descrição"
					STR0024,;									// 	[02]  C   ToolTip do campo - "Descrição"
					 "C8_ZXDESCR",;								// 	[03]  C   Id do Field
					 "C",;										// 	[04]  C   Tipo do campo
					 TamSX3(NF020FDesc())[1],;					// 	[05]  N   Tamanho do campo
					 0,;										// 	[06]  N   Decimal do campo
					 NIL,;										//	[07]  B   Code-block de validação do campo
					 NIL,;										// 	[08]  B   Code-block de validação When do campo
					 NIL,;										//	[09]  A   Lista de valores permitido do campo
					 .F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 {|| NF020PDesc() },;						//	[11]  B   Code-block de inicializacao do campo
					 .F.,;										//	[12]  L   Indica se trata-se de um campo chave
					 .F.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 .T.)			
					 											// 	[14]  L   Indica se o campo é virtual
												
// -------------------------------------------------------------------//
// ** CAMPOS DE IMPOSTOS TOTAIS ** ----------------------------------//

If (lBrazil)

	oStrDHU:AddField(	STR0041,;							// 	[01]  C   Titulo do campo -- 'Valor IPI'
						STR0041,;							// 	[02]  C   ToolTip do campo
						"DHU_TOTIPI",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_VALIPI")[1],;						// 	[05]  N   Tamanho do campo
						TamSX3("C8_VALIPI")[2],;						// 	[06]  N   Decimal do campo
						NIL,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

	oStrDHU:AddField(	STR0042,;							// 	[01]  C   Titulo do campo -- 'Valor ICMS'
						STR0042,;							// 	[02]  C   ToolTip do campo
						"DHU_TOTICM",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_VALICM")[1],;						// 	[05]  N   Tamanho do campo
						TamSX3("C8_VALICM")[2],;						// 	[06]  N   Decimal do campo
						NIL,;									// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

	oStrDHU:AddField(	STR0043,;							// 	[01]  C   Titulo do campo -- 'Valor ISS'
						STR0043,;							// 	[02]  C   ToolTip do campo
						"DHU_TOTISS",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_VALISS")[1],;						// 	[05]  N   Tamanho do campo
						TamSX3("C8_VALISS")[2],;						// 	[06]  N   Decimal do campo
						NIL,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

	oStrDHU:AddField(	STR0044,;							// 	[01]  C   Titulo do campo -- 'Total ICMS Comp'
						STR0044,;							// 	[02]  C   ToolTip do campo
						"DHU_TOTICO",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_ICMSCOM")[1],;						// 	[05]  N   Tamanho do campo
						TamSX3("C8_ICMSCOM")[2],;						// 	[06]  N   Decimal do campo
						NIL,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

	oStrDHU:AddField(	STR0046,;							// 	[01]  C   Titulo do campo -- 'Total ICMS-Sol'
						STR0046,;							// 	[02]  C   ToolTip do campo
						"DHU_TOTISO",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_VALSOL")[1],;						// 	[05]  N   Tamanho do campo
						TamSX3("C8_VALSOL")[2],;						// 	[06]  N   Decimal do campo
						NIL,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

	oStrDHU:AddField(	STR0102,;									// 	[01]  C   Titulo do campo -- 'IBS Municipal'
						STR0102,;									// 	[02]  C   ToolTip do campo
						"DHU_IBSMUN",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_VALSOL")[1],;					// 	[05]  N   Tamanho do campo
						TamSX3("C8_VALSOL")[2],;					// 	[06]  N   Decimal do campo
						NIL,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

	oStrDHU:AddField(	STR0103,;									// 	[01]  C   Titulo do campo -- 'IBS Estadual'
						STR0103,;									// 	[02]  C   ToolTip do campo
						"DHU_IBSEST",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_VALSOL")[1],;					// 	[05]  N   Tamanho do campo
						TamSX3("C8_VALSOL")[2],;					// 	[06]  N   Decimal do campo
						NIL,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual

	oStrDHU:AddField(	STR0104,;									// 	[01]  C   Titulo do campo -- 'CBS Federal'
						STR0104,;									// 	[02]  C   ToolTip do campo
						"DHU_CBSFED",;								// 	[03]  C   Id do Field
						"N",;										// 	[04]  C   Tipo do campo
						TamSX3("C8_VALSOL")[1],;					// 	[05]  N   Tamanho do campo
						TamSX3("C8_VALSOL")[2],;					// 	[06]  N   Decimal do campo
						NIL,;										// 	[07]  B   Code-block de validação do campo
						NIL,;										// 	[08]  B   Code-block de validação When do campo
						NIL,;										//	[09]  A   Lista de valores permitido do campo
						.F.,;										//	[10]  L   Indica se o campo tem preenchimento obrigatório
						{|| 0},;									//	[11]  B   Code-block de inicializacao do campo
						NIL,;										//	[12]  L   Indica se trata-se de um campo chave
						.T.,;										//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						.T.)										// 	[14]  L   Indica se o campo é virtual


Endif

oModel := MPFormModel():New('NFCA020',/*bPreVld*/, {|oModel| PosValid(oModel)}, {|oModel| CommitData(oModel)}) 

oModel:AddFields( 'DHUMASTER', /*cOwner*/ , oStrDHU) 
oModel:AddGrid( 'SC8DETAIL', 'DHUMASTER', oStrSC8)
oModel:SetRelation('SC8DETAIL', { { 'C8_FILIAL', 'FWxFilial("DHU")' }, { 'C8_NUM', 'DHU_NUM' }, { 'C8_FORNECE', 'DHU_CODFOR' }, { 'C8_LOJA', 'DHU_LOJAFOR' },{'C8_FORNOME' , 'DHU_NOMFOR'}, { 'C8_NUMPRO', 'DHU_NUMPRO' } }, SC8->(IndexKey(8)) )

//Grid dos Tributos Genéricos
if (lBrazil)
	bLoadFil := {|| NF020TribGen("I", oModel) }
	oStruF2D := NF020F2DMD()
	oModel:AddGrid( "IMPETRB", 'DHUMASTER', oStruF2D,,,,, bLoadFil)
	oModel:GetModel("IMPETRB"):SetNoInsertLine(.T.)
	oModel:GetModel("IMPETRB"):SetNoDeleteLine(.T.)
	oModel:GetModel('IMPETRB'):SetOptional(.T.)
	oModel:GetModel( 'IMPETRB' ):SetDescription( STR0095 ) //"Tributos Genéricos"
endif

// ----------------------------------------------------
// Retira validações impostas nos campos via X3_VALID
// ----------------------------------------------------
oStrSC8:SetProperty("C8_VLDESC",MODEL_FIELD_VALID,FWBuildFeature(STRUCT_FEATURE_VALID, "Positivo() .and. NF020VlDesc('C8_VLDESC')") )
oStrSC8:SetProperty("C8_SITUAC", MODEL_FIELD_VALUES, {'1', '2', '3'})
oStrSC8:SetProperty("C8_DATPRF", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020VlDtPrev()" + iif( !Empty( GetSx3Cache("C8_DATPRF", "X3_VLDUSER" ) ), " .And. " + AllTrim( GetSx3Cache( "C8_DATPRF", "X3_VLDUSER" ) ), "" )) )

// -- Adiciona validações para soma de impostos totais
If (lBrazil)
	oStrSC8:SetProperty("C8_VALIPI"	, MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_VALIPI',  'DHU_TOTIPI')") )
	oStrSC8:SetProperty("C8_VALICM"	, MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_VALICM',  'DHU_TOTICM')") )
	oStrSC8:SetProperty("C8_VALISS"	, MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_VALISS',  'DHU_TOTISS')") )
	oStrSC8:SetProperty("C8_ICMSCOM", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_ICMSCOM', 'DHU_TOTICO')") )
	oStrSC8:SetProperty("C8_VALSOL"	, MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_VALSOL',  'DHU_TOTISO')") )
	oStrSC8:SetProperty("C8_ALIIPI"	, MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_ALIIPI',  'DHU_TOTIPI')") )
	oStrSC8:SetProperty("C8_ALIQCMP", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_ALIQCMP', 'DHU_TOTICO')") )
	oStrSC8:SetProperty("C8_ALIQISS", MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_ALIQISS', 'DHU_TOTISS')") )
	oStrSC8:SetProperty("C8_PICM"	, MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020ItTax('C8_PICM',    'DHU_TOTICM')") )
	oStrSC8:SetProperty("C8_CODTAB"	, MODEL_FIELD_VALID, FWBuildFeature(STRUCT_FEATURE_VALID, "NF020CobTab(1)") )
EndIf

If cPaisLoc == "ARG"
	oStrSC8:RemoveField("C8_PROVENT")
EndIf

oStrSC8:SetProperty("C8_SITUAC"	, MODEL_FIELD_VALID, {||NF020AtuCmpVal(nil, '1', oModel)})
oStrSC8:SetProperty('*'			, MODEL_FIELD_WHEN , {||fwfldget('C8_SITUAC') $ '1'}) 
oStrSC8:SetProperty('C8_SITUAC' , MODEL_FIELD_WHEN , {||fwfldget('C8_SITUAC') != '8'})
oStrSC8:SetProperty('C8_DATPRF'	, MODEL_FIELD_WHEN , {|| .T.})

// --------------------------------------------
// Não permitir serem inseridas linhas na grid
// --------------------------------------------
oModel:GetModel('SC8DETAIL'):SetNoInsertLine(.T.)

// --------------------------------------------
// Não permite apagar linhas do grid
// --------------------------------------------
oModel:GetModel('SC8DETAIL'):SetNoDeleteLine(.T.)

oModel:SetDescription( STR0025 ) //'Edição cotação'
oModel:GetModel( 'DHUMASTER' ):SetDescription( STR0026 ) //"Cabeçalho cotação"

// --------------------------------------------
// Gatilhos de preço e total
// --------------------------------------------
xAux := FwStruTrigger( 'C8_PRECO', 'C8_TOTAL', 'NF020SVlIt()',.F.)
oStrSC8:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])
xAux := FwStruTrigger( 'C8_QTDISP', 'C8_TOTAL', 'NF020SVlIt()',.F.)
oStrSC8:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

// --------------------------------------------
// Gatilho de desconto por item
// --------------------------------------------
xAux := FwStruTrigger( 'C8_VLDESC', 'DHU_VLDESC', 'M->C8_VLDESC := M->C8_VLDESC',.F.)
oStrSC8:AddTrigger( xAux[1], xAux[2], xAux[3], xAux[4])

oModel:SetVldActivate( {|oModel| validateAct(oModel) } )
oModel:SetActivate({|oModel| ActivateModel(oModel)})
oModel:InstallEvent("EVDEF",, NFCA020EVDEF():New()) //-- Instala eventos do MVC

NF020LdFldExp(oModel)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Estrutura de Visualização

@author Leandro Fini
@since 01/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

Local oModel 	:= FWLoadModel('NFCA020')
Local oStrDHU 	:= FWFormStruct( 2, 'DHU', {|cCampo| !AllTrim(cCampo)$ "DHU_FILIAL|DHU_NUM|DHU_TPDOC|DHU_AVAVEN|DHU_STATUS|DHU_DTEMIS|DHU_AGPCOT|DHU_DTRCOT|DHU_QTDFOR|DHU_QTDPRO|DHU_TPAMR|DHU_CODCOM|DHU_COMPRA"} )  
Local cCpoExcl	:= ""
Local cNFCMoed  := SuperGetMV("MV_NFCMOED", .F., "1")
Local oStrSC8 	:= nil
Local oStruF2D	:= Nil
Local lBrazil	:= cPaisLoc == "BRA"

Private oView := Nil

// -- Campos da SC8 que deverão ser ocultados da view
cCpoExcl := "C8_MSUIDT|C8_ACCITEM|C8_ACCNUM|C8_AVISTA|C8_BASEDES|C8_BASEICM|C8_CODED|C8_CODGRP|C8_CODITE|"
cCpoExcl += "C8_CODORCA|C8_COND|C8_CONTATO|C8_DESC|C8_DESC1|C8_DESC2|C8_DESC3|C8_DESPESA|C8_DTVISTA|C8_EMAILWF|C8_EMISSAO|
cCpoExcl += "C8_FILENT|C8_FILIAL |C8_FORMAIL|C8_FORNECE|C8_FORNOME|C8_GRADE|C8_GRUPCOM|C8_IDENT|C8_IDTRIB|C8_INTCLIC|C8_ITEFOR|C8_ITEMGRD|C8_ITEMPED|
cCpoExcl += "C8_ITEMSC|C8_ITSCGRD|C8_LOJA|C8_MARKAUD|C8_MOEDA|C8_MOTIVO|C8_MOTVENC|C8_MSG|C8_NUM|C8_NUMCON|C8_NUMPED |C8_NUMPR|C8_NUMPRO|C8_NUMSC|C8_OK|C8_ORCFOR|C8_ORIGEM|
cCpoExcl += "C8_PDDES|C8_PDORI|C8_PRAZO|C8_QTDCTR|C8_QTSEGUM|C8_RATFIN|C8_REAJUST|C8_SEGUM|C8_SEGURO|C8_SEQFOR|C8_STATME |C8_TAXAFIN|
cCpoExcl += "C8_TAXAFOR|C8_TOTFRE|C8_TOTPCO|C8_ITEMPCO|C8_TPDOC|C8_TPFRETE|C8_TXMOEDA|C8_VALEMB|C8_VALFRE|C8_VALIDA|C8_WF|C8_XGCT|C8_XREVISA|C8_DIFAL"

oStrSC8 := FWFormStruct( 2, 'SC8' , {|cCampo| !AllTrim(cCampo)$ cCpoExcl .And. cCampo != "C8_PRECOOR" .And. cCampo != "C8_OBSFOR" } )

// ---------------------------------------------------------------------------//
// ** CAMPOS DE INFORMAÇÕES DO FORNECDOR ** ----------------------------------//

oStrDHU:AddField( ;	
						"DHU_TPFORN",;					// [01]  C   Nome do Campo
						"01",;							// [02]  C   Ordem
						STR0031,;						// [03]  C   Titulo do campo	//"Redist. Val."
						STR0031,;						// [04]  C   Descricao do campo	//"Redistribuição de Valores"
						NIL,;							// [05]  A   Array com Help
						"C",;							// [06]  C   Tipo do campo
						"@!",;							// [07]  C   Picture
						NIL,;							// [08]  B   Bloco de Picture Var
						NIL,;							// [09]  C   Consulta F3
						_oJsonSup['newParticipant'],;	// [10]  L   Indica se o campo é alteravel
						NIL,;							// [11]  C   Pasta do campo
						NIL, ;							// [12]  C   Agrupamento do campo
						{'1=Sim','2=Não'},;				// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;							// [15]  C   Inicializador de Browse
						.T.,;							// [16]  L   Indica se o campo é virtual
						NIL)							// [17]  C   Picture Variavel
					
oStrDHU:AddField( ;										// Ord. Tipo Desc.
						"DHU_CODFOR",;					// [01] C Nome do Campo
						"02",;							// [02] C Ordem
						STR0005,;						// [03] C Titulo do campo # "Local" 
						STR0005,;						// [04] C Descrição do campo # "Local" 
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"FOR",;							// [09] C Consulta F3
						_oJsonSup['newParticipant'],;   // [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStrDHU:AddField( ;										// Ord. Tipo Desc.
						"DHU_LOJAFOR",;					// [01] C Nome do Campo
						"03",;							// [02] C Ordem
						STR0006,;						// [03] C Titulo do campo # "Local" 
						STR0006,;						// [04] C Descrição do campo # "Local" 
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						_oJsonSup['newParticipant'],;   // [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStrDHU:AddField( ;										// Ord. Tipo Desc.
						"DHU_NOMFOR",;					// [01] C Nome do Campo
						"04",;							// [02] C Ordem
						STR0007,;						// [03] C Titulo do campo # "Local" 
						STR0007,;						// [04] C Descrição do campo # "Local" 
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						_oJsonSup['newParticipant'],;   // [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStrDHU:AddField( ;									    // Ord. Tipo Desc.
						"DHU_CONTATO",;					// [01] C Nome do Campo
						"05",;							// [02] C Ordem
						STR0033,;						// [03] C Titulo do campo # "Local" 
						STR0033,;						// [04] C Descrição do campo # "Local" 
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						_oJsonSup['newParticipant'],;   // [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável
													
oStrDHU:AddField( ;									    // Ord. Tipo Desc.
						"DHU_EMAIL",;					// [01] C Nome do Campo
						"06",;							// [02] C Ordem
						STR0032,;						// [03] C Titulo do campo # "Local" 
						STR0032,;						// [04] C Descrição do campo # "Local" 
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						_oJsonSup['newParticipant'],;   // [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

oStrDHU:AddField( ;										// Ord. Tipo Desc.
						"DHU_NUMPRO",;					// [01] C Nome do Campo
						"07",;							// [02] C Ordem
						STR0034,;						// [03] C Titulo do campo # "Local" 
						STR0034,;						// [04] C Descrição do campo # "Local" 
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						.T.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

// -------------------------------------------------------------------//
// ** CAMPOS DO CABEÇALHO DA COTAÇÃO ** ------------------------------//

oStrDHU:AddField(	"DHU_TOTIT",;							// [01]  C   Nome do Campo
						"08",;								// [02]  C   Ordem
						STR0009,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0009,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_TOTAL"),;		// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.T.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField(	"DHU_TOTCOT",;							// [01]  C   Nome do Campo
						"09",;								// [02]  C   Ordem
						STR0010,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0010,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_TOTAL"),;		// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.T.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField(	"DHU_DESC",;							// [01]  C   Nome do Campo
						"10",;								// [02]  C   Ordem
						STR0008,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0008,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_DESC"),;			// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.T.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField(	"DHU_VLDESC",;							// [01]  C   Nome do Campo
						"11",;								// [02]  C   Ordem
						STR0011,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0011,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_VLDESC"),;		// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.T.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField(	"DHU_VALFRE",;							// [01]  C   Nome do Campo
						"12",;								// [02]  C   Ordem
						STR0012,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0012,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_VALFRE"),;		// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.T.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField(	"DHU_FRETE",;					// [01]  C   Nome do Campo
					"13",;							// [02]  C   Ordem
					STR0013,;						// [03]  C   Titulo do campo	//"Redist. Val."
					STR0013,;						// [04]  C   Descricao do campo	//"Redistribuição de Valores"
					NIL,;							// [05]  A   Array com Help
					"C",;							// [06]  C   Tipo do campo
					"@!",;							// [07]  C   Picture
					NIL,;							// [08]  B   Bloco de Picture Var
					NIL,;							// [09]  C   Consulta F3
					.T.,;							// [10]  L   Indica se o campo é alteravel
					"4",;							// [11]  C   Pasta do campo
					"GRP4",;						// [12]  C   Agrupamento do campo
					{'C=CIF','F=FOB','T='+STR0068,'S='+STR0069, 'R='+STR0093, 'D='+STR0094},;// [13]  A   Lista de valores permitido do campo	//{'C=CIF','F=FOB','T=Terceiros', 'S=Sem frete', 'R=Por Conta Remetente', 'D=Por Conta Destinatário'}
					NIL,;							// [14]  N   Tamanho maximo da maior opção do combo
					NIL,;							// [15]  C   Inicializador de Browse
					.T.,;							// [16]  L   Indica se o campo é virtual
					NIL,;							// [17]  C   Picture Variavel
					NIL)							// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField( ;										// Ord. Tipo Desc.
						"DHU_COND",;					// [01] C Nome do Campo
						"14",;							// [02] C Ordem
						STR0014,;						// [03] C Titulo do campo # "Local" 
						STR0014,;						// [04] C Descrição do campo # "Local" 
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						"@!",;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"SE4",;							// [09] C Consulta F3
						.T.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável


//Parametro (MV_NFCMOED); 1=CTO(Default);2=MV_MOEDA 
If cNFCMoed == "1"

	oStrDHU:AddField( ;										// Ord. Tipo Desc.
							"DHU_MOEDA",;					// [01] C Nome do Campo
							"15",;							// [02] C Ordem
							STR0015,;						// [03] C Titulo do campo # "Local" 
							STR0015,;						// [04] C Descrição do campo # "Local" 
							Nil,;							// [05] A Array com Help
							"C",;							// [06] C Tipo do campo
							PesqPict("CTO","CTO_MOEDA"),;							// [07] C Picture
							NIL,;							// [08] B Bloco de Picture Var
							"CTO",;							// [09] C Consulta F3
							.T.,;							// [10] L Indica se o campo é editável
							NIL,;							// [11] C Pasta do campo
							NIL,;							// [12] C Agrupamento do campo
							NIL,;							// [13] A Lista de valores permitido do campo (Combo)
							NIL,;							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;							// [15] C Inicializador de Browse
							.T.,;							// [16] L Indica se o campo é virtual
							NIL )							// [17] C Picture Variável
Else
	oStrDHU:AddField( ;										// Ord. Tipo Desc.
							"CMOEDAPED",;					// [01] C Nome do Campo
							"15",;							// [02] C Ordem
							STR0015,;						// [03] C Titulo do campo # "Local" 
							STR0015,;						// [04] C Descrição do campo # "Local" 
							Nil,;							// [05] A Array com Help
							"C",;							// [06] C Tipo do campo
							Nil,;							// [07] C Picture
							NIL,;							// [08] B Bloco de Picture Var
							Nil,;							// [09] C Consulta F3
							.T.,;							// [10] L Indica se o campo é editável
							NIL,;							// [11] C Pasta do campo
							NIL,;							// [12] C Agrupamento do campo
							NIL,;							// [13] A Lista de valores permitido do campo (Combo)
							NIL,;							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;							// [15] C Inicializador de Browse
							.T.,;							// [16] L Indica se o campo é virtual
							NIL )							// [17] C Picture Variável

	oStrDHU:AddField( ;										// Ord. Tipo Desc.
							"CDESCMOED",;					// [01] C Nome do Campo
							"16",;							// [02] C Ordem
							STR0091,;					// [03] C Titulo do campo # "Local" 
							STR0091,;					// [04] C Descrição do campo # "Local" 
							Nil,;							// [05] A Array com Help
							"C",;							// [06] C Tipo do campo
							Nil,;							// [07] C Picture
							NIL,;							// [08] B Bloco de Picture Var
							Nil,;							// [09] C Consulta F3
							.F.,;							// [10] L Indica se o campo é editável
							NIL,;							// [11] C Pasta do campo
							NIL,;							// [12] C Agrupamento do campo
							NIL,;							// [13] A Lista de valores permitido do campo (Combo)
							NIL,;							// [14] N Tamanho Maximo da maior opção do combo
							NIL,;							// [15] C Inicializador de Browse
							.T.,;							// [16] L Indica se o campo é virtual
							NIL )							// [17] C Picture Variável

EndIf

oStrDHU:AddField(	"DHU_TXMOEDA",;							// [01]  C   Nome do Campo
						"17",;								// [02]  C   Ordem
						STR0016,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0016,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_TXMOEDA"),;		// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.F.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField(	"DHU_DESPESA",;							// [01]  C   Nome do Campo
						"18",;								// [02]  C   Ordem
						STR0017,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0017,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_DESPESA"),;		// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.F.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

oStrDHU:AddField(	"DHU_SEGURO",;							// [01]  C   Nome do Campo
						"19",;								// [02]  C   Ordem
						STR0018,;							// [03]  C   Titulo do campo	//"Valor Total"
						STR0018,;							// [04]  C   Descricao do campo	//"Valor Total da Parcela"
						NIL,;								// [05]  A   Array com Help
						"N",;								// [06]  C   Tipo do campo
						PesqPict("SC8","C8_SEGURO"),;		// [07]  C   Picture
						NIL,;								// [08]  B   Bloco de Picture Var
						NIL,;								// [09]  C   Consulta F3
						.F.,;								// [10]  L   Indica se o campo é alteravel
						NIL,;								// [11]  C   Pasta do campo
						NIL,;								// [12]  C   Agrupamento do campo
						NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
						NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
						NIL,;								// [15]  C   Inicializador de Browse
						.T.,;								// [16]  L   Indica se o campo é virtual
						NIL,;								// [17]  C   Picture Variavel
						NIL)								// [18]  L   Indica pulo de linha após o campo

// -------------------------------------------------------------------//
// ** CAMPOS DE INFORMAÇÕES DE ENTREGA ** ----------------------------//

oStrSC8:AddField( ;										// Ord. Tipo Desc.
						"C8_ZXDESCR",;					// [01] C Nome do Campo
						"01",;							// [02] C Ordem
						STR0024,;						// [03] C Titulo do campo 	 //"Descrição"
						STR0024,;						// [04] C Descrição do campo //"Descrição"
						Nil,;							// [05] A Array com Help
						"C",;							// [06] C Tipo do campo
						PesqPict("SB1","B1_DESC"),;							// [07] C Picture
						NIL,;							// [08] B Bloco de Picture Var
						"",;							// [09] C Consulta F3
						.F.,;							// [10] L Indica se o campo é editável
						NIL,;							// [11] C Pasta do campo
						NIL,;							// [12] C Agrupamento do campo
						NIL,;							// [13] A Lista de valores permitido do campo (Combo)
						NIL,;							// [14] N Tamanho Maximo da maior opção do combo
						NIL,;							// [15] C Inicializador de Browse
						.T.,;							// [16] L Indica se o campo é virtual
						NIL )							// [17] C Picture Variável

// -------------------------------------------------------------------//
// ** CAMPOS DE IMPOSTOS TOTAIS ** -----------------------------------//
If (lBrazil)

	oStrDHU:AddField(	"DHU_TOTIPI",;							// [01]  C   Nome do Campo
							"24",;								// [02]  C   Ordem
							STR0041,;					// [03]  C   Titulo do campo	//"Valor IPI"
							STR0041,;						// [04]  C   Descricao do campo	//"Valor IPI"
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_VALIPI"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	oStrDHU:AddField(	"DHU_TOTICM",;							// [01]  C   Nome do Campo
							"25",;								// [02]  C   Ordem
							STR0042,;					// [03]  C   Titulo do campo	//"Valor ICMS"
							STR0043,;						// [04]  C   Descricao do campo	//"Valor ICMS"
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_VALICM"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	oStrDHU:AddField(	"DHU_TOTISS",;							// [01]  C   Nome do Campo
							"26",;								// [02]  C   Ordem
							STR0043,;					// [03]  C   Titulo do campo	//'Valor ISS'
							STR0043,;						// [04]  C   Descricao do campo	//'Valor ISS'
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_VALISS"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	oStrDHU:AddField(	"DHU_TOTICO",;							// [01]  C   Nome do Campo
							"27",;								// [02]  C   Ordem
							STR0044,;					// [03]  C   Titulo do campo	//'Vlr ICMS-Comp'
							STR0044,;						// [04]  C   Descricao do campo	//'Vlr ICMS-Comp'
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_ICMSCOM"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	oStrDHU:AddField(	"DHU_TOTISO",;							// [01]  C   Nome do Campo
							"29",;								// [02]  C   Ordem
							STR0046,;					// [03]  C   Titulo do campo	//'Vlr ICMS-Sol.'
							STR0046,;						// [04]  C   Descricao do campo	//'Vlr ICMS-Sol.'
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_VALSOL"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	oStrDHU:AddField(	"DHU_IBSMUN",;							// [01]  C   Nome do Campo
							"30",;								// [02]  C   Ordem
							STR0102,;							// [03]  C   Titulo do campo	//'IBS Municipal'
							STR0102,;							// [04]  C   Descricao do campo	//'IBS Municipal'
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_VALSOL"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	oStrDHU:AddField(	"DHU_IBSEST",;							// [01]  C   Nome do Campo
							"31",;								// [02]  C   Ordem
							STR0103,;							// [03]  C   Titulo do campo	//'IBS Estadual'
							STR0103,;							// [04]  C   Descricao do campo	//'IBS Estadual'
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_VALSOL"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

	oStrDHU:AddField(	"DHU_CBSFED",;							// [01]  C   Nome do Campo
							"32",;								// [02]  C   Ordem
							STR0104,;							// [03]  C   Titulo do campo	//'CBS Federal'
							STR0104,;							// [04]  C   Descricao do campo	//'CBS Federal'
							NIL,;								// [05]  A   Array com Help
							"N",;								// [06]  C   Tipo do campo
							PesqPict("SC8","C8_VALSOL"),;		// [07]  C   Picture
							NIL,;								// [08]  B   Bloco de Picture Var
							NIL,;								// [09]  C   Consulta F3
							.T.,;								// [10]  L   Indica se o campo é alteravel
							NIL,;								// [11]  C   Pasta do campo
							NIL,;								// [12]  C   Agrupamento do campo
							NIL,;								// [13]  A   Lista de valores permitido do campo (Combo)
							NIL,;								// [14]  N   Tamanho maximo da maior opção do combo
							NIL,;								// [15]  C   Inicializador de Browse
							.T.,;								// [16]  L   Indica se o campo é virtual
							NIL,;								// [17]  C   Picture Variavel
							NIL)								// [18]  L   Indica pulo de linha após o campo

EndIf

oStrDHU:SetProperty("*",MVC_VIEW_CANCHANGE, .T.)

if DHU->(FieldPos("DHU_LEGACY")) > 0
	oStrDHU:SetProperty("DHU_LEGACY",MVC_VIEW_CANCHANGE, .F.)
EndIf

oStrSC8:SetProperty("C8_QUANT",MVC_VIEW_CANCHANGE, .F.)
oStrSC8:SetProperty("C8_TOTAL",MVC_VIEW_CANCHANGE, .F.)
oStrSC8:SetProperty("C8_PRODUTO",MVC_VIEW_CANCHANGE, .F.)
oStrSC8:SetProperty("C8_SITUAC",MVC_VIEW_CANCHANGE, .T.)
oStrSC8:SetProperty("C8_DATPRF",MVC_VIEW_CANCHANGE, .T.)

//Campos Moeda
If cNFCMoed == "2"
	oStrDHU:SetProperty("CDESCMOED",MVC_VIEW_CANCHANGE, .F.)
EndIf

If (lBrazil)
	oStrSC8:SetProperty("C8_VALSOL",MVC_VIEW_CANCHANGE, .T.)
EndIf
oStrSC8:SetProperty("C8_SITUAC", MODEL_FIELD_VALUES, {'1', '2', '3'})

NF020RmOpt(oStrSC8) //-- Remove opções que não são necessárias do campo C8_SITUAC

oView:= FWFormView():New() 

oView:SetModel( oModel )

oStrDHU:SetNoFolder()

oView:AddField( 'VIEW_DHU' , oStrDHU, 'DHUMASTER' ) 
oView:AddGrid ( 'VIEW_SC8' , oStrSC8, 'SC8DETAIL' )
if (lBrazil)
	oStruF2D := NF020F2DVW()
	oView:AddGrid ( 'VIEW_F2D' , oStruF2D, 'IMPETRB' )
endif

oView:CreateHorizontalBox	( 'SUPERIOR'   , 060 )   
oView:CreateHorizontalBox	( 'INFERIOR1'  , 040 )

oView:SetOwnerView( 'VIEW_DHU', 'SUPERIOR'	)

oView:SetUpdateMessage('',STR0028) //-- Cotação editada com sucesso.

if type("nOpcNFC") == "N" .and. nOpcNFC == 4
	oView:AddUserButton(STR0050 ,'',{|| FWMsgRun(, {|| NF020Calc(.F.) }, STR0047, STR0048) } ) //Calcular impostos # Aguarde # Calculando impostos ...
	oView:AddUserButton(STR0072 ,'', {|| NF020UpdDate()} ) //Replicar data de entrega para os itens abaixo.
	oView:AddUserButton(STR0076 ,'', {|| NF020SetTab() }) // -- Tabela de preços
	oView:AddUserButton(STR0084 ,'', {|| NF020UpdTES(.F.) }) // "Replicar TES (Tipo de Entrada/Saída) e CFOP?"
endif

oStrDHU:AddGroup( 'GRP_NFCA020_001', '', '', 1 )
oStrDHU:AddGroup( 'GRP_NFCA020_002', STR0029, '', 2 ) //-- Cotação
oStrDHU:AddGroup( 'GRP_NFCA020_003', STR0030, '', 3 ) //-- Informações entrega

If (lBrazil)
	oStrDHU:AddGroup( 'GRP_NFCA020_004', STR0049, '', 4 )//--'Impostos totais'
EndIf

oStrDHU:SetProperty( '*'          , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_002' )

oStrDHU:SetProperty( 'DHU_TPFORN' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_001' )
oStrDHU:SetProperty( 'DHU_CODFOR' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_001' )
oStrDHU:SetProperty( 'DHU_LOJAFOR', MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_001' )
oStrDHU:SetProperty( 'DHU_NOMFOR' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_001' )
oStrDHU:SetProperty( 'DHU_EMAIL'  , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_001' )
oStrDHU:SetProperty( 'DHU_CONTATO', MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_001' )
oStrDHU:SetProperty( 'DHU_NUMPRO' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_001' )

if DHU->(FieldPos("DHU_ENTREG")) > 0
	oStrDHU:SetProperty( 'DHU_ENTREG' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_003' )
endif

If (lBrazil)
	oStrDHU:SetProperty( 'DHU_TOTIPI' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
	oStrDHU:SetProperty( 'DHU_TOTICM' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
	oStrDHU:SetProperty( 'DHU_TOTISS' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
	oStrDHU:SetProperty( 'DHU_TOTICO' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
	oStrDHU:SetProperty( 'DHU_TOTISO' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
	oStrDHU:SetProperty( 'DHU_IBSMUN' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
	oStrDHU:SetProperty( 'DHU_IBSEST' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
	oStrDHU:SetProperty( 'DHU_CBSFED' , MVC_VIEW_GROUP_NUMBER, 'GRP_NFCA020_004' )
EndIf

oStrSC8:SetProperty('C8_PRODUTO', MVC_VIEW_ORDEM,'01')
oStrSC8:SetProperty('C8_ZXDESCR', MVC_VIEW_ORDEM,'02')
oStrSC8:SetProperty('C8_UM'		, MVC_VIEW_ORDEM,'03')
oStrSC8:SetProperty('C8_SITUAC'	, MVC_VIEW_ORDEM,'04')
oStrSC8:SetProperty('C8_QUANT'	, MVC_VIEW_ORDEM,'05')
oStrSC8:SetProperty('C8_QTDISP'	, MVC_VIEW_ORDEM,'06')
oStrSC8:SetProperty('C8_PRECO'	, MVC_VIEW_ORDEM,'07')
oStrSC8:SetProperty('C8_TOTAL'	, MVC_VIEW_ORDEM,'08')
oStrSC8:SetProperty('C8_VLDESC'	, MVC_VIEW_ORDEM,'09')
oStrSC8:SetProperty('C8_TES'	, MVC_VIEW_ORDEM,'10')
if SC8->(FieldPos("C8_CF")) > 0
	oStrSC8:SetProperty('C8_CF'		, MVC_VIEW_ORDEM,'11')
endif
oStrSC8:SetProperty('C8_OBS'	, MVC_VIEW_ORDEM,'12')
oStrSC8:SetProperty('C8_DATPRF' , MVC_VIEW_TITULO, STR0075) //Data de Entrega

//Ordem dos impostos
If (lBrazil)
	oStrSC8:SetProperty('C8_ALIIPI'	, MVC_VIEW_ORDEM,'13')
	oStrSC8:SetProperty('C8_VALIPI'	, MVC_VIEW_ORDEM,'14')
	oStrSC8:SetProperty('C8_BASEIPI', MVC_VIEW_ORDEM,'15')
	oStrSC8:SetProperty('C8_PICM'	, MVC_VIEW_ORDEM,'16')
	oStrSC8:SetProperty('C8_VALICM'	, MVC_VIEW_ORDEM,'17')
	oStrSC8:SetProperty('C8_VALSOL'	, MVC_VIEW_ORDEM,'18')
	oStrSC8:SetProperty('C8_BASESOL', MVC_VIEW_ORDEM,'19')
	oStrSC8:SetProperty('C8_ALIQCMP', MVC_VIEW_ORDEM,'20')
	oStrSC8:SetProperty('C8_ICMSCOM', MVC_VIEW_ORDEM,'21')
	oStrSC8:SetProperty('C8_ALIQISS', MVC_VIEW_ORDEM,'22')
	oStrSC8:SetProperty('C8_VALISS'	, MVC_VIEW_ORDEM,'23')
	oStrSC8:SetProperty('C8_BASEIPI', MVC_VIEW_TITULO, STR0059) //Base IPI
EndIf

If cPaisLoc == "ARG"
	oStrSC8:RemoveField("C8_PROVENT")
EndIf

//Aba (Folder) Produtos / Impostos Genéricos
//Folders
oView:CreateFolder( 'ABAS', 'INFERIOR1' )
oView:CreateHorizontalBox( 'PRODUTO' , 100,,, 'ABAS', 'V1')
oView:EnableTitleView('VIEW_SC8', STR0027) //-- Itens cotação

if (lBrazil)
	oView:CreateHorizontalBox( 'IMPOSTOS', 100,,, 'ABAS', 'V2')
	oView:EnableTitleView('VIEW_F2D', STR0095) //-- Impostos
endif

//Abas com grids
oView:AddSheet( 'ABAS', 'V1', STR0027) //Itens da cotação
if (lBrazil)
	oView:AddSheet( 'ABAS', 'V2', STR0095) //Impostos
	oView:SetViewProperty("VIEW_SC8", "CHANGELINE", {{|oView| NF020TribGen(, oModel) }})
	oView:SetOwnerView('VIEW_F2D' , 'IMPOSTOS' )
endif

oView:SetOwnerView('VIEW_SC8' , 'PRODUTO' )

Return oView

/*/{Protheus.doc} PosValid
	Bloco de pós-validação
@author juan.felipe
@since 01/2024
/*/
Static Function PosValid(oModel)
	Local lRet 		As Logical
	Local lHasSup 	As Logical
	Local cEmails 	As Character
	Local cMessage 	As Character
	Local cSolution	As Character
	Local oModelDHU As Object
	local oModelSC8 as Object
	local oViewObj	as object 
	local nFor		as numeric
	local nFor2		as numeric
	local nQtdLine	as numeric
	local aCmps		as array
	Local cNFCMoed := SuperGetMV("MV_NFCMOED", .F., "1")
	Default oModel := FwModelActive()

	lRet	  := .T.
	lHasSup   := .F.
	oModelDHU := oModel:GetModel('DHUMASTER')
	oModelSC8 := oModel:GetModel('SC8DETAIL')
	oViewObj  := FwViewActive()
	nQtdLine  := oModelSC8:length()
	aCmps	  := {}

	If _oJsonSup['newParticipant']
		If !Empty(oModelDHU:GetValue('DHU_CODFOR')) .And. !Empty(oModelDHU:GetValue('DHU_LOJAFOR'))
			lHasSup := .T.
		ElseIf Empty(oModelDHU:GetValue('DHU_CODFOR')) .And. Empty(oModelDHU:GetValue('DHU_LOJAFOR')) .And. !Empty(oModelDHU:GetValue('DHU_NOMFOR'))
			lHasSup := .T.
		EndIf

		If !lHasSup
			FwClearHLP() //-- Limpa help anterior para não exibir uma mensagem de erro incorreta.

			If oModelDHU:GetValue('DHU_TPFORN') == '1'
				oModel:SetErrorMessage(,,,, 'NF020OBRIGAT1', STR0035) //-- É obrigatório preencher o código do fornecedor, loja ou somente o nome do fornecedor.
			Else
				oModel:SetErrorMessage(,,,, 'NF020OBRIGAT2', STR0036) //-- É obrigatório preencher o nome do fornecedor.
			EndIf

			lRet := .F.
		EndIf

		If lRet
			cEmails := oModelDHU:GetValue('DHU_EMAIL')

			If !Empty(cEmails) .And. !NFCVldEmail(cEmails, @cMessage, @cSolution) //-- Valida e-mails
				oModel:SetErrorMessage(,,,, 'NF020EMAIL1', cMessage, cSolution)
				lRet := .F.
			EndIf
		EndIf
	EndIf
	
	//Se em qualquer linha tiver campo obrigatório não preenchido, mesmo que não alterado pelo usuário, vai surgir a crítica
	If ValType(oViewObj) == 'O'
		nFor2 := aScan(oViewObj:aViews, {|x| x[1] == "VIEW_SC8"})
		aCmps := oViewObj:aViews[nFor2][3]:aRequiredFields //Esse objeto contêm todos os campos obrigatórios da tabela
		for nFor := 1 to nQtdLine
			oModelSC8:GoLine(nFor)
			for nFor2 := 1 to len(aCmps)
				if empty(oModelSC8:getValue(aCmps[nFor2]))
					lRet := .f.
					Help(nil, nil , STR0053, nil, STR0060 + CRLF + STR0061 + cvaltochar(nFor) + ; //Atenção / Existem campos obrigatórios não preenchidos: / Linha 
						" - " + STR0063 + alltrim(oModelSC8:getValue("C8_PRODUTO")) + CRLF + STR0062 + aCmps[nFor2], 1, 0, nil, nil, nil, nil, nil, {} ) // Produto - Campo obrigatório
					exit
				endif
			next
			if !lRet
				exit
			endif
		next
	EndIf

	//Verifica se o campo de descrição da moeda esta vazio
	If cNFCMoed == "2" 
		If Empty(oModelDHU:GetValue('CDESCMOED'))
			Help(nil, nil , STR0053, nil, STR0092, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / "O código TES e CFOP foi replicado para os demais itens da cotação.
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} CommitData
	Bloco de commit
@author Leandro Fini
@since 01/2024
/*/
Static Function CommitData(oModel)

Local nAverDays := 0
Local lRet := .T.
Local oModelDHU := oModel:GetModel("DHUMASTER")
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
Local nX := 1
Local cSupplier := oModelDHU:GetValue('DHU_CODFOR')
Local cStore := oModelDHU:GetValue('DHU_LOJAFOR')
Local cSupName := oModelDHU:GetValue('DHU_NOMFOR')
Local cNFCMoed := SuperGetMV("MV_NFCMOED", .F., "1")

//-- Calcula a media do prazo de entrega
nAverDays := calcAvrDays(oModel)

for nX := 1 to oModelSC8:Length()
	oModelSC8:GoLine(nX)

	If cNFCMoed == "1"
		oModelSC8:LoadValue("C8_MOEDA", val(oModelDHU:GetValue("DHU_MOEDA")))
	else
		oModelSC8:LoadValue("C8_MOEDA", val(oModelDHU:GetValue("CMOEDAPED")))
	EndIf
	
	oModelSC8:LoadValue("C8_TXMOEDA", oModelDHU:GetValue("DHU_TXMOEDA"))
	oModelSC8:LoadValue("C8_TPFRETE", oModelDHU:GetValue("DHU_FRETE"))
	oModelSC8:LoadValue("C8_COND"   , oModelDHU:GetValue("DHU_COND"))
	oModelSC8:LoadValue("C8_FORMAIL", oModelDHU:GetValue("DHU_EMAIL"))
	oModelSC8:LoadValue("C8_CONTATO", oModelDHU:GetValue("DHU_CONTATO"))
	oModelSC8:LoadValue("C8_DESC"	, oModelDHU:GetValue("DHU_DESC"))
	oModelSC8:LoadValue("C8_FORNOME", oModelDHU:GetValue("DHU_NOMFOR"))

	oModelSC8:SetValue("C8_PRAZO"	, nAverDays)

	If _oJsonSup['newProposal'] .Or. _oJsonSup['newParticipant'] //-- Apenas nova proposta ou novo participante
		oModelSC8:aDataModel[nX][7] := .T. //-- Torna as linhas do grid como alteradas, para que seja possível gravar os dados das novas linhas
		oModelSC8:LoadValue("C8_VALIDA", oModelDHU:GetValue("DHU_DTRCOT"))
	EndIf
next nX

calcExpenses('DHU_VALFRE')
calcExpenses('DHU_SEGURO')
calcExpenses('DHU_DESPESA')

If _oJsonSup['newParticipant'] //-- Incrementa quantidade de fornecedores da cotação
	oModelDHU:SetValue('DHU_QTDFOR', oModelDHU:GetValue('DHU_QTDFOR') += 1)
EndIf

oModelSC8:GoLine(1)

if ( _lRecalcTrib ) //indica que usou o cálculo de impostos. Se não usou, mantém os valores originais
	NF020Calc(.T.) //Gravar na tabela F2D, de impostos genéricos, na hora de salvar
endif

lRet := FwFormCommit( oModel )

If lRet //-- Envia informações do fornecedor para atualização da tela do PO-UI
	PG010Saved(.T., cSupplier, cStore, cSupName)
EndIf

NF020Clean( {}, {_oHashTCI} )
Return lRet

/*/{Protheus.doc} NF020VlDesc
	Calcula o valor do desconto pelo item C8_VLDESC
	leva para o total do cabeçalho
@author Leandro Fini
@since 01/2024
/*/
Function NF020VlDesc()

Local oModel 	:= FwModelActive()
Local oModelDHU := oModel:GetModel("DHUMASTER")
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
Local nX 	   	:= 1
Local nVlrDesc 	:= 0
Local nVlrTotIt := 0
Local nLine 	:= oModelSC8:GetLine()
local lRet		:= .t.
local nDesconto	:= oModelSC8:getvalue("C8_VLDESC")
local nTotal	:= oModelSC8:getvalue("C8_TOTAL")

lRet := VldValues(nTotal, nDesconto, .t.)

if lRet
	For nX := 1 to oModelSC8:Length()

		oModelSC8:SetLine(nX)

		nVlrTotIt += oModelSC8:GetValue("C8_TOTAL")
		nVlrDesc += oModelSC8:GetValue("C8_VLDESC")

	Next nX

	if ( oModelDHU:HasField("DHU_VLDESC") )
		oModelDHU:LoadValue("DHU_VLDESC", nVlrDesc)
	endif
	if ( oModelDHU:HasField("DHU_TOTCOT") )
		oModelDHU:LoadValue("DHU_TOTCOT", nVlrTotIt - nVlrDesc)
	endif
	if ( oModelDHU:HasField("DHU_TOTIT") )
		oModelDHU:LoadValue("DHU_TOTIT"	, nVlrTotIt)
	endif
	if ( oModelDHU:HasField("DHU_DESC") )
		oModelDHU:LoadValue("DHU_DESC" 	, Round( ((nVlrDesc * 100) / nVlrTotIt), 2) )
	endif

	oModelSC8:SetLine(nLine)
	oModelSC8:LoadValue("C8_VLDESC", oModelSC8:GetValue("C8_VLDESC"))
	recalTot(oModel)
else
	Help(nil, nil , STR0053, nil, STR0054, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / O valor informado de Desconto é maior que o total do item."
endif

Return lRet

/*/{Protheus.doc} NF020SVlIt
	Calcula o valor total da cotação DHU_TOTIT, DHU_TOTCOT
@author Leandro Fini
@since 01/2024
/*/
Function NF020SVlIt()

Local oModel 	:= FwModelActive()
Local oModelDHU := oModel:GetModel("DHUMASTER")
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
Local nX 	   	:= 1
Local nVlrDesc 	:= oModelDHU:GetValue("DHU_VLDESC")
Local nVlrTotIt := 0
Local nLine 	:= oModelSC8:GetLine()
Local nVlrIt 	:= oModelSC8:GetValue("C8_PRECO") * oModelSC8:GetValue("C8_QTDISP")
local aFieldVld	:= {'C8_VLDESC', 'C8_VALIPI', 'C8_VALICM', 'C8_VALSOL', 'C8_ICMSCOM', 'C8_VALISS'}
local nVlrTmp	:= 0
local cField    := ''

If cPaisLoc == "BRA"
	oModelSC8:LoadValue("C8_TOTAL", nVlrIt)
	oModelSC8:LoadValue("C8_BASEIPI", nVlrIt)
	oModelSC8:LoadValue("C8_BASESOL", nVlrIt)

	for nX := 1 to Len(aFieldVld)
		cField := aFieldVld[nX]

		if !( VldValues(nVlrIt, oModelSC8:GetValue(cField),.t.) )
			oModelSC8:setValue(cField, 0)
		elseif oModelSC8:CanSetValue(cField)
			nVlrTmp := oModelSC8:GetValue(cField)
			oModelSC8:setValue(cField, 0) //Para indicar que ocorreu mudança no model
			oModelSC8:setValue(cField, nVlrTmp)
		endif
	next
EndIf

For nX := 1 to oModelSC8:Length()

	oModelSC8:SetLine(nX)

	nVlrTotIt += oModelSC8:GetValue("C8_TOTAL")

Next nX

//proteção, pois quando a informação volta do WF, chama essa função e não temos o model DHU com esses campos.
if ( oModelDHU:HasField("DHU_TOTIT") )
	oModelDHU:LoadValue("DHU_TOTIT", nVlrTotIt)
endif
if ( oModelDHU:HasField("DHU_TOTCOT") )
	oModelDHU:LoadValue("DHU_TOTCOT", nVlrTotIt - nVlrDesc)
endif
if ( oModelDHU:HasField("DHU_DESC") )
	oModelDHU:LoadValue("DHU_DESC" 	, Round( ((nVlrDesc * 100) / nVlrTotIt), 2) )
endif

oModelSC8:SetLine(nLine)
recalTot(oModel)

Return nVlrIt

/*/{Protheus.doc} filProdBalance
	Retorna todos os produtos de uma cotação que possui saldo disponivel
@author ali.neto
@since 11/2024
/*/
Static Function filProdBalance(oModel)

	Local cQuery        As character
	Local oQuery        As object
	Local cAliasTmp     As Character
	Local cCodPro 		As Character
	Local cResult		As Character

	cResult := ""
	Default oModel 	 	:= FwModelActive()

	cQuery := " SELECT DHV_CODPRO, DHV_SALDO "
	cQuery += "   FROM " + RetSQLName("SC8") + " SC8"

	cQuery += "	INNER JOIN " + RetSQLName("DHV") + " DHV"
	cQuery += "	   ON DHV.DHV_FILIAL = SC8.C8_FILIAL "
	cQuery += "   AND DHV.DHV_NUM = SC8.C8_NUM "
	cQuery += "   AND DHV.DHV_CODPRO = SC8.C8_PRODUTO "
	cQuery += "   AND DHV.D_E_L_E_T_ = ' ' "

	cQuery += "  WHERE SC8.C8_FILIAL = ? " 
  	cQuery += "    AND SC8.C8_NUM = ? "
	cQuery += "	   AND SC8.C8_FORNECE = ? "
	cQuery += "	   AND SC8.C8_LOJA = ? "
	cQuery += "	   AND SC8.C8_NUMPRO = ? "
  	cQuery += "	   AND DHV.DHV_SALDO > 0 " //-- Busca os produtos que possuem saldo
  	cQuery += "	   AND SC8.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY DHV_CODPRO, DHV_SALDO "

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery:SetString(1, FWxFilial('DHV'))
	oQuery:SetString(2, _oJsonSup['quoteNumber'])
	oQuery:SetString(3, _oJsonSup['supplierCode'])	
	oQuery:SetString(4, _oJsonSup['supplierStore'])
	oQuery:SetString(5, _oJsonSup['proposal']) //Busca na proposta que esta posicionado 				

	cAliasTmp := GetNextAlias()
	cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery())

	While !(cAliasTmp)->(eof())

		cCodPro := (cAliasTmp)->(DHV_CODPRO)

		If !Empty(cResult)
			cResult += ","
		EndIf

		cResult += "'" + cCodPro + "'"
		(cAliasTmp)->(dbSkip())
	EndDo

	(cAliasTmp)->(dbCloseArea())
	oQuery:Destroy()

	If !Empty(cResult)
        cResult := "{" + cResult + "}"
    EndIf
Return cResult


/*/{Protheus.doc} calcQtdDisp
	Obtem o saldo dos itens da cotação 
@author ali.neto
@since 11/2024
/*/
Static Function calcQtdDisp()

	Local oModel 		:= FwModelActive()
	Local oModelSC8 	:= oModel:GetModel('SC8DETAIL')
	Local nRetQtdDisp   := 0 //Quant. Disponivel
	Local cNumCot 		:= oModelSC8:GetValue("C8_NUM") //Numero da cotação
	Local cIdent		:= oModelSC8:GetValue("C8_IDENT") 
	Local cProdut		:= oModelSC8:GetValue("C8_PRODUTO") 

	DbSelectArea("DHV")
	DbSetOrder(1) //-- DHV_FILIAL, DHV_NUM, DHV_ITEM, DHV_CODPRO
	If DHV->(DbSeek(FWxFilial("DHV") + cNumCot + cIdent + cProdut))
		nRetQtdDisp := DHV->DHV_SALDO 
	EndIf
Return nRetQtdDisp


/*/{Protheus.doc} NF020QtdDisp
	Percorre as linhas dos itens setando a quantidade disponivel e recalculando os totais
@author ali.neto
@since 11/2024
/*/
Static Function NF020QtdDisp(oModel)
 
	Local oModelSC8 := oModel:GetModel("SC8DETAIL")
	Local nX 	   	:= 1
	Local nLine 	:= oModelSC8:GetLine()
	Local nQtdDisp  As Numeric
	
	If _oJsonSup['newProposal'] .or. _oJsonSup['newParticipant'] .or. _oJsonSup['editPartial']
		For nX := 1 to oModelSC8:Length()

			oModelSC8:SetLine(nX)

			nQtdDisp := calcQtdDisp()
			oModelSC8:LoadValue("C8_QTDISP", nQtdDisp)
			
			//-- Caso o saldo estiver zerado seta o preço como 0
			If oModelSC8:GetValue("C8_QTDISP") == 0
				oModelSC8:LoadValue("C8_PRECO", 0)
			EndIf
			
			NF020SVlIt()
		Next nX
		oModelSC8:SetLine(nLine)
	EndIf
Return Nil

/*/{Protheus.doc} calcDiscount
	Cálculo do valor do desconto no cabeçalho, por percentual ou valor.
	nOpc == 1 -> disparado pelo percentual
	nOpc == 2 -> disparado pelo valor
@author Leandro Fini
@since 01/2024
/*/
Static Function calcDiscount(nOpc)
	
	Local oModel 		:= FwModelActive()
	Local oModelDHU 	:= oModel:GetModel('DHUMASTER')
	Local oModelSC8 	:= oModel:GetModel('SC8DETAIL')
    Local nRetTotDisc 	As Numeric //Total de desconto
    Local nRetTotValue 	As Numeric//Valor total descontado
    Local nRetPercDisc 	As Numeric//Percentual do valor de desconto
    Local nX           	As Numeric
	Local nVlrDesc		As Numeric
	Local nVlrTotIt		As Numeric
	local lRet 			:= .t.

    Local nPerc := oModelDHU:GetValue("DHU_DESC")
    Local nTotDiscount := oModelDHU:GetValue("DHU_VLDESC")
	Local nTotValue := oModelDHU:GetValue("DHU_TOTIT")

	lRet := (nPerc >= 0 .and. nTotDiscount >= 0 .and. VldValues(nTotValue, nTotDiscount, .t.))

	if lRet
		if nOpc == 1 .and. nPerc > 0 
			nRetTotDisc := ( nTotValue * ( nPerc / 100 ) )
			nRetTotValue := nTotValue - nRetTotDisc
			nRetPercDisc := nPerc
		elseif nOpc == 2 .and. nTotDiscount > 0 
			nRetTotDisc := nTotDiscount
			nRetTotValue := nTotValue - nRetTotDisc
			nRetPercDisc := ( nTotDiscount / nTotValue )  * 100
		else 
			nRetTotDisc  := 0
			nRetTotValue := nTotValue
			nRetPercDisc := 0
		endif
		
		nVlrTotIt := 0
		if nRetPercDisc > 0
			for nX := 1 to oModelSC8:Length()

				oModelSC8:SetLine(nX)

				nVlrDesc := oModelSC8:GetValue("C8_TOTAL") - ( oModelSC8:GetValue("C8_TOTAL") * ( nRetPercDisc / 100 ) )
				nVlrTotIt += oModelSC8:GetValue("C8_TOTAL")
	
				oModelSC8:LoadValue("C8_VLDESC", oModelSC8:GetValue("C8_TOTAL") - nVlrDesc )
				oModelSC8:LoadValue("C8_DESC", nRetPercDisc )
			next nX

				oModelDHU:LoadValue("DHU_DESC", nRetPercDisc)
				oModelDHU:LoadValue("DHU_VLDESC", nRetTotDisc)
				oModelDHU:LoadValue("DHU_TOTIT", nVlrTotIt)
				oModelDHU:LoadValue("DHU_TOTCOT", nVlrTotIt - nRetTotDisc)
		
		elseif nRetPercDisc == 0
			for nX := 1 to oModelSC8:Length()
				
				oModelSC8:SetLine(nX)
				oModelSC8:LoadValue("C8_VLDESC", 0)
				oModelSC8:LoadValue("C8_DESC", 0 )
				nVlrTotIt += oModelSC8:GetValue("C8_TOTAL")
				
			next nX

				oModelDHU:LoadValue("DHU_DESC", 0)
				oModelDHU:LoadValue("DHU_VLDESC", 0)
				oModelDHU:LoadValue("DHU_TOTIT", nVlrTotIt)
				oModelDHU:LoadValue("DHU_TOTCOT", nVlrTotIt)

		endif

		oModelSC8:SetLine(1)
		recalTot(oModel)
	endif

Return lRet

/*/{Protheus.doc} iniFldsDHU
	Inicializador dos campos virtuais do cabeçalho de cotação
@author Leandro Fini
@since 01/2024
/*/
Static Function iniFldsDHU(oModel)
	Local cQuery        as Character
	Local oQuery        as object
	Local oModelDHU	 	As Object
	Local oModelSC8		As Object 
	Local cAliasTmp     as Character
	Local cNumPed		as Character
	Default oModel 	 	:= FwModelActive()

	oModelDHU := oModel:GetModel('DHUMASTER')
	oModelSC8 := oModel:GetModel('SC8DETAIL')

	If  _oJsonSup['cleanProposal']
		oModelDHU:LoadValue('DHU_TOTIT'  , 0)
		oModelDHU:LoadValue('DHU_TOTCOT' , 0)
		oModelDHU:LoadValue('DHU_VLDESC' , 0)
		oModelDHU:LoadValue('DHU_DESC'   , 0)
		oModelDHU:LoadValue('DHU_VALFRE' , 0)
		oModelDHU:LoadValue('DHU_SEGURO' , 0)
		oModelDHU:LoadValue('DHU_DESPESA', 0)

	ElseIf _oJsonSup['newProposal'] .or. _oJsonSup['newParticipant'] .or. _oJsonSup['editPartial'] //-- Nova proposta (considera o saldo)
		
		cNumPed := oModelSC8:GetValue("C8_NUMPED")
		
		If !Empty(cNumPed) .or. _oJsonSup['editPartial']  //-- Não gerou pedido ainda, utilize o C8_TOTAL
			cQuery := " SELECT SUM(DHV_SALDO * C8_PRECO) TOTAL,  SUM(C8_VLDESC) DESCONTO, "
		Else //-- Já foi gerado pedido, utilize o DHV_SALDO
			cQuery := " SELECT SUM(C8_TOTAL) TOTAL, SUM(C8_VLDESC) DESCONTO, "
		EndIf

		cQuery += " COUNT(C8_ITEM) ITENS, SUM(C8_VALFRE) FRETE, SUM(C8_SEGURO) SEGURO, SUM(C8_DESPESA) DESPESA "
		cQuery += " FROM " + RetSQLName("SC8") + " SC8"
		cQuery += " INNER JOIN " + RetSQLName("DHV") + " DHV" 
		cQuery += "  		ON DHV.DHV_FILIAL = SC8.C8_FILIAL"
	    cQuery += " 	   AND DHV.DHV_NUM = SC8.C8_NUM"
		cQuery += " 	   AND DHV.DHV_ITEM = SC8.C8_ITEM
	    cQuery += " 	   AND DHV.D_E_L_E_T_ = ' ' "
		cQuery += "   WHERE "
		cQuery += "     SC8.C8_FILIAL = ? "
		cQuery += "     AND SC8.C8_NUM = ?"
		cQuery += "     AND SC8.C8_FORNECE = ?"
		cQuery += "     AND SC8.C8_LOJA = ?"
		cQuery += "     AND SC8.C8_FORNOME = ?"
		cQuery += "     AND SC8.C8_NUMPRO = ?"
		cQuery += "     AND SC8.D_E_L_E_T_ = ' ' "

		oQuery := FWPreparedStatement():New(cQuery)

		oQuery:SetString(1, FWxFilial('SC8'))
		oQuery:SetString(2, _oJsonSup['quoteNumber'])
		oQuery:SetString(3, _oJsonSup['supplierCode'])
		oQuery:SetString(4, _oJsonSup['supplierStore'])
		oQuery:SetString(5, _oJsonSup['supplierName'])
		oQuery:SetString(6, _oJsonSup['proposal'])

		cAliasTmp := GetNextAlias()
		cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery())

		If !(cAliasTmp)->(eof())
			oModelDHU:LoadValue('DHU_TOTIT'  , (cAliasTmp)->TOTAL)
			oModelDHU:LoadValue('DHU_TOTCOT' , (cAliasTmp)->TOTAL - (cAliasTmp)->DESCONTO)
			oModelDHU:LoadValue('DHU_VLDESC' , (cAliasTmp)->DESCONTO)
			oModelDHU:LoadValue('DHU_DESC'   , Round(( (cAliasTmp)->DESCONTO / (cAliasTmp)->TOTAL ) * 100, 2))
			oModelDHU:LoadValue('DHU_VALFRE' , (cAliasTmp)->FRETE)
			oModelDHU:LoadValue('DHU_SEGURO' , (cAliasTmp)->SEGURO)
			oModelDHU:LoadValue('DHU_DESPESA', (cAliasTmp)->DESPESA)
		EndIf

		(cAliasTmp)->(dbCloseArea())
		oQuery:Destroy()
	Else
		cQuery := " SELECT SUM(C8_TOTAL) TOTAL, SUM(C8_VLDESC) DESCONTO, "
		cQuery += " COUNT(C8_ITEM) ITENS, SUM(C8_VALFRE) FRETE, SUM(C8_SEGURO) SEGURO, SUM(C8_DESPESA) DESPESA "
		cQuery += " FROM " + RetSQLName("SC8") + " SC8"

		cQuery += "   WHERE "
		cQuery += "     SC8.C8_FILIAL = ? "
		cQuery += "     AND SC8.C8_NUM = ?"
		cQuery += "     AND SC8.C8_FORNECE = ?"
		cQuery += "     AND SC8.C8_LOJA = ?"
		cQuery += "     AND SC8.C8_FORNOME = ?"
		cQuery += "     AND SC8.C8_NUMPRO = ?"
		cQuery += "     AND SC8.D_E_L_E_T_ = ' ' "

		oQuery := FWPreparedStatement():New(cQuery)
		oQuery:SetString(1, FWxFilial('SC8'))
		oQuery:SetString(2, _oJsonSup['quoteNumber'])
		oQuery:SetString(3, _oJsonSup['supplierCode'])
		oQuery:SetString(4, _oJsonSup['supplierStore'])
		oQuery:SetString(5, _oJsonSup['supplierName'])
		oQuery:SetString(6, _oJsonSup['proposal'])

		cAliasTmp := GetNextAlias()
		cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery())

		If !(cAliasTmp)->(eof())
			oModelDHU:LoadValue('DHU_TOTIT'  , (cAliasTmp)->TOTAL)
			oModelDHU:LoadValue('DHU_TOTCOT' , (cAliasTmp)->TOTAL - (cAliasTmp)->DESCONTO)
			oModelDHU:LoadValue('DHU_VLDESC' , (cAliasTmp)->DESCONTO)
			oModelDHU:LoadValue('DHU_DESC'   , Round(( (cAliasTmp)->DESCONTO / (cAliasTmp)->TOTAL ) * 100, 2))
			oModelDHU:LoadValue('DHU_VALFRE' , (cAliasTmp)->FRETE)
			oModelDHU:LoadValue('DHU_SEGURO' , (cAliasTmp)->SEGURO)
			oModelDHU:LoadValue('DHU_DESPESA', (cAliasTmp)->DESPESA)
		EndIf

		(cAliasTmp)->(dbCloseArea())
		oQuery:Destroy()
	EndIf
Return Nil

/*/{Protheus.doc} iniFldsTax
	Inicializador dos campos virtuais do cabeçalho de cotação
@author Leandro Fini
@since 01/2024
/*/
Static Function iniFldsTax(oModel)
	local cQuery        as character
	local oQuery        as object
	Local oModelDHU	 	As Object
	local cAliasTmp     as character
	Default oModel 	 	:= FwModelActive()

	oModelDHU := oModel:GetModel('DHUMASTER')

	If _oJsonSup['newParticipant'] .Or. _oJsonSup['cleanProposal']
		oModelDHU:LoadValue('DHU_TOTIPI'  ,0)
		oModelDHU:LoadValue('DHU_TOTISS'  ,0)
		oModelDHU:LoadValue('DHU_TOTICM'  ,0)
		oModelDHU:LoadValue('DHU_TOTICO'  ,0)
		oModelDHU:LoadValue('DHU_TOTISO'  ,0)
		oModelDHU:LoadValue('DHU_IBSMUN'  ,0)
		oModelDHU:LoadValue('DHU_IBSEST'  ,0)
		oModelDHU:LoadValue('DHU_CBSFED'  ,0)
	Else
		cQuery := " SELECT SUM(C8_VALIPI) TOTIPI, SUM(C8_VALISS) TOTISS, "
		cQuery += " SUM(C8_VALICM) TOTICMS, SUM(C8_ICMSCOM) TOTICMSCOM, SUM(C8_VALSOL) TOTICMSSOL "
		cQuery += " FROM " + RetSQLName("SC8") + " SC8"
		cQuery += "   WHERE "
		cQuery += "     SC8.C8_FILIAL = ? "
		cQuery += "     AND SC8.C8_NUM = ?"
		cQuery += "     AND SC8.C8_FORNECE = ?"
		cQuery += "     AND SC8.C8_LOJA = ?"
		cQuery += "     AND SC8.C8_FORNOME = ?"
		cQuery += "     AND SC8.C8_NUMPRO = ?"
		cQuery += "     AND SC8.D_E_L_E_T_ = ' ' "

		oQuery := FWPreparedStatement():New(cQuery)
		oQuery:SetString(1, FWxFilial('SC8'))
		oQuery:SetString(2, _oJsonSup['quoteNumber'])
		oQuery:SetString(3, _oJsonSup['supplierCode'])
		oQuery:SetString(4, _oJsonSup['supplierStore'])
		oQuery:SetString(5, _oJsonSup['supplierName'])
		oQuery:SetString(6, _oJsonSup['proposal'])

		cAliasTmp := GetNextAlias()
		cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery())

		If !(cAliasTmp)->(eof())
			oModelDHU:LoadValue('DHU_TOTIPI' , (cAliasTmp)->TOTIPI)
			oModelDHU:LoadValue('DHU_TOTISS' , (cAliasTmp)->TOTISS)
			oModelDHU:LoadValue('DHU_TOTICM' , (cAliasTmp)->TOTICMS)
			oModelDHU:LoadValue('DHU_TOTICO' , (cAliasTmp)->TOTICMSCOM)
			oModelDHU:LoadValue('DHU_TOTISO' , (cAliasTmp)->TOTICMSSOL)
		EndIf

		(cAliasTmp)->(dbCloseArea())
		oQuery:Destroy()
	EndIf
Return Nil

/*/{Protheus.doc} calcExpenses
	Calcula os valores rateados proporcionais de frete, seguro e despesa
@author Leandro Fini
@since 01/2024
/*/
Static Function calcExpenses(cCpo)

	Local oModel 		  	:= FwModelActive()
	Local oModelDHU 	  	:= oModel:GetModel('DHUMASTER')
	Local oModelSC8 	  	:= oModel:GetModel('SC8DETAIL')
	Local nShipValue 	  	:= 0
	Local nTotalQuoteShip 	:= 0
	Local nInsuranceValue 	:= 0
	Local nExpenseValue	  	:= 0
	Local nQtdItens       	:= oModelSC8:Length()
	Local nX 		      	:= 1
	Local nTotalItem	  	:= 0
	local lRet				:= .t.
	local nTotInsurance		:= 0
	local nTotExpense		:= 0

	if (oModelDHU:getvalue(ccpo) >= 0 )
		if cCpo == "DHU_VALFRE"

		nTotalItem := oModelDHU:GetValue("DHU_VALFRE")

		for nX := 1 to nQtdItens
			oModelSC8:GoLine(nX)
			nShipValue := 0

			If oModelSC8:GetValue("C8_TOTAL") > 0
				nShipValue      := Round((oModelSC8:GetValue("C8_TOTAL")/oModelDHU:GetValue("DHU_TOTIT"))*oModelDHU:GetValue("DHU_VALFRE"), 2) //-- Cáculo de frete proporcional para cada item
				nTotalQuoteShip += nShipValue
			EndIf
			oModelSC8:LoadValue('C8_VALFRE', nShipValue)
			oModelSC8:LoadValue('C8_TOTFRE', oModelDHU:GetValue("DHU_VALFRE"))
		next nX
		nShipValue := NFCDiffValues(nTotalQuoteShip, nTotalItem, oModelSC8:GetValue('C8_VALFRE'))
        oModelSC8:LoadValue('C8_VALFRE', nShipValue)

		elseif cCpo == "DHU_SEGURO"
			nTotalItem := oModelDHU:GetValue("DHU_SEGURO")

			for nX := 1 to nQtdItens
				oModelSC8:GoLine(nX)
				nInsuranceValue := 0

				If oModelSC8:GetValue("C8_TOTAL") > 0
					nInsuranceValue	:= Round((oModelSC8:GetValue("C8_TOTAL")/oModelDHU:GetValue("DHU_TOTIT"))*oModelDHU:GetValue("DHU_SEGURO"), 2) //-- Cáculo de seguro proporcional para cada item
					nTotInsurance	+= nInsuranceValue
				EndIf
				oModelSC8:LoadValue('C8_SEGURO', nInsuranceValue)
			next nX
			nInsuranceValue := NFCDiffValues(nTotInsurance, nTotalItem, oModelSC8:GetValue('C8_SEGURO'))
            oModelSC8:LoadValue('C8_SEGURO', nInsuranceValue)

		elseif cCpo == "DHU_DESPESA"
			nTotalItem := oModelDHU:GetValue("DHU_DESPESA")
	
			for nX := 1 to nQtdItens
				oModelSC8:GoLine(nX)
				nExpenseValue := 0

				If oModelSC8:GetValue("C8_TOTAL") > 0
					nExpenseValue  	:= Round((oModelSC8:GetValue("C8_TOTAL")/oModelDHU:GetValue("DHU_TOTIT"))*oModelDHU:GetValue("DHU_DESPESA"), 2) //-- Cáculo de seguro proporcional para cada item
					nTotExpense		+= nExpenseValue
				EndIf
				oModelSC8:LoadValue('C8_DESPESA', nExpenseValue)
			next nX
			nExpenseValue := NFCDiffValues(nTotExpense, nTotalItem, oModelSC8:GetValue('C8_DESPESA'))
            oModelSC8:LoadValue('C8_DESPESA', nExpenseValue)
		endif

		oModelSC8:SetLine(1)
		recalTot(oModel)
	else
		Help(nil, nil , STR0053, nil, STR0056, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / Informe um valor positivo
		lRet := .f.
	endif
Return lRet

/*/{Protheus.doc} ActivateModel
	Bloco de ativação do modelo.
@author juan.felipe
@since 02/2024
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Function ActivateModel(oModel)
	Local oModelSC8 As object
	Local oModelDHU As object
	Local cFilSB1 As Character
	Local cNFCMoed := SuperGetMV("MV_NFCMOED", .F., "1")

	Default oModel := FwModelActive()

	cFilSB1 := FwFilial('SB1')

	CopyLines(oModel)
	iniFldsDHU(oModel)
	
	if cPaisLoc == "BRA"
		iniFldsTax(oModel)// -- Inicializa os campos totais de impostos
	endif 

	oModelDHU := oModel:GetModel('DHUMASTER')
	oModelSC8 := oModel:GetModel('SC8DETAIL')

	oModelSC8:GoLine(1) //-- Carrega cabeçalho da cotação
	oModelDHU:LoadValue('DHU_EMAIL'  , oModelSC8:GetValue('C8_FORMAIL'))
	oModelDHU:LoadValue('DHU_CONTATO', oModelSC8:GetValue('C8_CONTATO'))
	oModelDHU:LoadValue('DHU_FRETE'  , iif( !empty(oModelSC8:GetValue('C8_TPFRETE')), oModelSC8:GetValue('C8_TPFRETE'), "C") )
	oModelDHU:LoadValue('DHU_COND'   , oModelSC8:GetValue('C8_COND'))
	
	If cNFCMoed == "1"
		oModelDHU:LoadValue('DHU_MOEDA'  , Strzero(oModelSC8:GetValue('C8_MOEDA'),TamSX3('CTO_MOEDA')[1]))
	Else
		oModelDHU:LoadValue('CMOEDAPED'  , Strzero(oModelSC8:GetValue('C8_MOEDA'), 1))
		NFCDescMoed()
	EndIf

	oModelDHU:LoadValue('DHU_TXMOEDA', oModelSC8:GetValue('C8_TXMOEDA'))

	If _oJsonSup['newParticipant'] //-- Limpa dados do fornecedor quando for novo participante
		oModelDHU:LoadValue('DHU_CODFOR', '')
		oModelDHU:LoadValue('DHU_LOJAFOR', '')
		oModelDHU:LoadValue('DHU_NOMFOR', '')
		oModelDHU:LoadValue('DHU_EMAIL', '')
		oModelDHU:LoadValue('DHU_CONTATO', '')
	EndIf

	//verifica quais itens possuem IDTRIB preenchido, para buscar os valores dos tributos r7
	if cPaisLoc == "BRA"
		NF020LCBSIBS(oModel)
	endif

	recaltot(oModel)
	NF020QtdDisp(oModel)
Return Nil

/*/{Protheus.doc} NF020SetSup
	Seta dados do fornecedor para o carregamento dos dados.
@author juan.felipe
@since 02/2024
@param cQuote, character, número da cotação.
@param cSupplier, character, código do fornecedor.
@param cStore, character, loja do forncedor.
@param cSupName, character, nome do fornecedor.
@param cProposal, character, proposta do fornecedor.
@param lNewProp, logical, indica se é nova proposta.
@param lNewPart, logical, indica se é novo participante.
@param lCleanProp, logical, indica se limpa os dados da nova proposta.
@return Nil, nulo.
/*/
Function NF020SetSup(cQuote, cSupplier, cStore, cSupName, cProposal, lNewProp, lNewPart, lCleanProp, lEditPartial)
	Local aAreas As Array
	Default cQuote := ''
	Default cSupplier := ''
	Default cStore := ''
	Default cSupName := ''
	Default cProposal := ''
	Default lNewProp := .F.
	Default lNewPart := .F.
	Default lCleanProp := .F.
	Default lEditPartial := .F.

	DbSelectArea("SA2")
	SA2->(DbSetOrder(1))
	SA2->(MsSeek(fwxFilial("SA2")+cSupplier+cStore))

	aAreas := {SC8->(GetArea()), GetArea()}
	A150SetPGC(.T.)
	
	_oJsonSup['quoteNumber'   ] := PadR(cQuote   , TamSX3('C8_NUM'    )[1], " ")
	_oJsonSup['supplierCode'  ] := PadR(cSupplier, TamSX3('C8_FORNECE')[1], " ")
	_oJsonSup['supplierStore' ] := PadR(cStore   , TamSX3('C8_LOJA'   )[1], " ")
	_oJsonSup['proposal'      ] := PadR(cProposal, TamSX3('C8_NUMPRO' )[1], " ")
	_oJsonSup['supplierName'  ] := PadR(cSupName , TamSX3('C8_FORNOME')[1], " ")
	_oJsonSup['newProposal'   ] := lNewProp
	_oJsonSup['newParticipant'] := lNewPart
	_oJsonSup['cleanProposal' ] := lCleanProp
	_oJsonSup['editPartial'] 	:= lEditPartial

	If lNewPart //-- Pega o primeiro fornecedor para fazer cópia dos itens para o novo participante
		SC8->(DbSetOrder(8))
		If SC8->(DbSeek(FWxFilial('SC8')+cQuote))
			_oJsonSup['quoteNumber'  ] := SC8->C8_NUM
			_oJsonSup['supplierCode' ] := SC8->C8_FORNECE
			_oJsonSup['supplierStore'] := SC8->C8_LOJA
			_oJsonSup['proposal'     ] := SC8->C8_NUMPRO
			_oJsonSup['supplierName' ] := SC8->C8_FORNOME
		EndIf
	EndIf

	aEval(aAreas, {|x| RestArea(x), FwFreeArray(x)})
Return Nil


/*/{Protheus.doc} calcAvrDays
	Calcula a media do prazo de entrega pelo numero de itens
@author ali.neto
@since 09/2024
@param oModel, object, modelo de dados.
@return nAvDays
/*/
Static Function calcAvrDays(oModel)

	Local oModelSC8 := oModel:GetModel('SC8DETAIL')
	Local nItem 	:= 0
	Local nTotDays 	:= 0
	Local nAverDays := 0
	Local nQtdItens := oModelSC8:Length()

	For nItem := 1 To nQtdItens
		oModelSC8:GoLine(nItem)
		
		If !Empty(oModelSC8:GetValue("C8_DATPRF")) .and. oModelSC8:GetValue("C8_DATPRF") >= dDataBase
			nTotDays += DateDiffDay(oModelSC8:GetValue("C8_DATPRF"), dDataBase)
		EndIf
	Next nItem

	//-- Calcula a media dos prazos de entra pelo numero de itens
	nAverDays := round(nTotDays / nQtdItens, 0)

Return nAverDays


/*/{Protheus.doc} CopyLines
	Copia linhas da SC8 para um objeto Json e aciona o bloco de carregamento do modelo.
@author juan.felipe
@since 02/2024
@param oModel, object, modelo de dados.
@return Nil, nulo.
/*/
Static Function CopyLines(oModel)
	Local oModelDHU As object
	Local oModelSC8 As object
	Local nX As Numeric
	Local oJsonData As object
	Local cCopyFields As Character
	Local cProposal As Character
	Local cSituation As Character
	Default oModel := FwModelActive()

	If _oJsonSup['newProposal'] .Or. _oJsonSup['newParticipant'] //-- Apenas nova proposta ou novo participante
		oModelDHU := oModel:GetModel('DHUMASTER')
		oModelSC8 := oModel:GetModel('SC8DETAIL')
		cCopyFields := PGCSC8Copy(.F., _oJsonSup['newParticipant'] .Or. _oJsonSup['cleanProposal'])

		If !_lWasLoaded //-- Copia dados do submodelo da SC8 apenas na primeira execução do activate model
			_lWasLoaded := .T.

			For nX := 1 To oModelSC8:Length()
				oModelSC8:GoLine(nX)
				oJsonData := JsonObject():New()

				oJsonData := NFCLineToJs(oModelSC8, oModelSC8:GetLine(), cCopyFields) //-- Converte linha do grid em Json

				If _oJsonSup['newProposal']
					cProposal := Soma1(_oJsonSup['proposal']) //-- Incrementa número da nova proposta para atribuição no Json
				Else
					cProposal := _oJsonSup['proposal']
				EndIf

				oJsonData['C8_ORIGEM'] := 'NFCA020'
				oJsonData['C8_EMISSAO'] := dDataBase
				oJsonData['C8_WF'] := .F.
				oJsonData['C8_NUMPRO'] := cProposal //-- Adiciona número da proposta

				If _oJsonSup['cleanProposal'] .Or. _oJsonSup['newParticipant']
					oJsonData['C8_QTDISP'] := oJsonData['C8_QUANT']
					oJsonData['C8_SITUAC'] := '1' //-- Reseta status do item da cotação
				EndIf

				cSituation := oJsonData['C8_SITUAC']
				cSituation := IIf(cSituation $ '4/8', '1', cSituation) //-- Se for o status de proposta recusada ou portal do fornecedor, reseta status para considera
				oJsonData['C8_SITUAC'] := cSituation

				Aadd(_aItems, oJsonData) //-- Adiciona Json da linha do grid no array
			Next nX

			oModel:DeActivate() //-- Desativa o modelo para atribuir o bloco de carga da SC8
			oModelSC8:bLoad := {|oModelSC8| loadSC8(oModelSC8)}
			oModel:Activate() //-- Ativa modelo novamente, o que permitirá que seja executada a carga do modelo com os dados dos itens copiados
		ElseIf _oJsonSup['newProposal']
			cProposal := Soma1(_oJsonSup['proposal'])
			oModelDHU:LoadValue('DHU_NUMPRO', cProposal) //-- Na segunda ativação do modelo, incremente o número da proposta no cabeçalho da DHU
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} loadSC8
	Bloco de carga do modelo da SC8.
@author juan.felipe
@since 02/2024
@param oModelSC8, object, modelo da SC8.
@return aLoad, array, dados a serem carregados na SC8.
/*/
Static Function loadSC8(oModelSC8)
	Local aData As Array
	Local aLoad As Array
	Local aNames As Array
	Local nX As Numeric
	Local nY As Numeric
	Default oModelSC8 := FwModelActive():GetModel('SC8DETAIL')

	If _lWasLoaded .And. (_oJsonSup['newProposal'] .Or. _oJsonSup['newParticipant']) //-- Apenas quando nova proposta ou novo participante
		aData := {}
		aLoad := {}

		If Len(_aItems) > 0
			aNames := _aItems[1]:GetNames() //-- Pega propriedades do Json
		EndIf

		For nX := 1 To Len(_aItems) //-- Carrega dados a partir do array de itens
			aData := {}

			For nY := 1 To Len(aNames) //-- Para cada propriedade adiciona os dados o array aDAta
				aAdd(aData, _aItems[nX][aNames[nY]])
			Next nX

			aAdd(aLoad, {0, aClone(aData)}) //-- Copia aData para aLoad informando o RECNO "0"
		Next nX
	EndIf	
Return aLoad

/*/{Protheus.doc} validateAct
	Valida ativação do modelo.
@author juan.felipe
@since 02/2024
@param oModel, object, modelo de dados.
@return lRet, logical, modelo válido.
/*/
Static Function validateAct(oModel)
	Local lRet As Logical
	Local lFound As Logical
	Local cFilSC8 As Character
	Local cSaldoProd As Character 
	Local cQuotCode As Character
	Local cSupCode As Character
	Local cSupStore As Character
	Local cSupName As Character
	Local cProposal As Character
	Local cMessage As Character
	Private l150Auto := .F.
	Default oModel := Nil

	lRet      := .T.
	lFound    := .F.
	cMessage  := ""
	cFilSC8   := FWxFilial('SC8')
	cQuotCode := _oJsonSup['quoteNumber'  ]
	cSupCode  := _oJsonSup['supplierCode' ]
	cSupStore := _oJsonSup['supplierStore']
	cSupName  := _oJsonSup['supplierName' ]
	cProposal := _oJsonSup['proposal'     ]
	_lRecalcTrib := .F.

	SC8->(DbSetOrder(8))
	If lFound := SC8->(DbSeek(cFilSC8+cQuotCode+cSupCode+cSupStore+cSupName)) // Posiciona na Cotação do Fornecedor
		//-- Posiciona na proposta atual do fornecedor
		While SC8->(!Eof()) .And. (cFilSC8+cQuotCode+cSupCode+cSupStore+cSupName+cProposal) <> SC8->(C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_FORNOME+C8_NUMPRO)
			SC8->(DbSkip())
		EndDo

		If lFound := SC8->(!Eof())
			If _oJsonSup['newProposal'] //-- Valida se pode incluir uma nova proposta
				A150SetPGC(.T.)

				If A150Propos(,,,@cMessage) != 1
					lRet := .F.
					Help(" ", 1, "NF020NOSUP",, cMessage,2)
				EndIf

				If _oJsonSup['newProposal']
					//Verifica se algum item possui saldo para abrir a nova proposta
					cSaldoProd := filProdBalance(oModel)
					If Empty(cSaldoProd) 
						Help(" ", 1, "NF020NOSUP",, STR0088 ,2)
						lRet := .F.
					EndIf
				EndIf 
			EndIf
		EndIf
	EndIf

	If !lFound
		PG010Saved(.T.) //-- Atribui valor .T. para que a tela do PO-UI seja atualizada
		Help(" ", 1, "NF020NOSUP",, STR0037 + AllTrim(cSupName) + STR0038,2) //-- A proposta do fornecedor XXXX não foi localizada na base de dados.
		lRet := .F.
	EndIf
	/*Ajuste necessário, pois quando é visualização, preciso adicionar no grid de tributos os impostos que estão atrelados ao item, mas como é visualização,
	ocorria erro no AddLine. Dessa forma, garanto a inclusão dos impostos e nenhum dado é alterado, mantendo em "visualização" */
	if oModel:Getoperation() == 1
		oModel:SetOperation(4)
		oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||.f.})
		oModel:GetModel("DHUMASTER"):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||.f.})
	endif
Return lRet


/*/{Protheus.doc} supFldVld
	Pré-valid dos campos da DHU.
@author juan.felipe
@since 02/2024
@param oModelDHU, object, modelo da DHU.
@param cValue, character, valor inserido no campo.
@param cField, character, campo que recebeu o valor.
@param cOldValue, character, valor anterior do campo.
@return lRet, logical, campo válido.
/*/
Static Function supFldVld(oModelDHU,cField,cValue,cOldValue)
	Local lRet As Logical
	Local lFound As Logical
	Local aAreas As Array
	Local cQuoteCode AS Character
	Local cSupCode As Character
	Local cSupStore As Character
	Local cSupCodeAux As Character
	Local cSupStoreAux As Character
	Local cSupName As Character
	Local cMessage As Character
	Local cSolution As Character
	Local oModel As Object
	Default oModelDHU := FwModelActive():GetModel('DHUMASTER')
	Default cField := ''
	Default cValue := ''
	Default cOldValue := ''

	lRet := .T.
	lFound := .F.
	aAreas := {DHU->(GetArea()),SA2->(GetArea()), SC8->(GetArea())}
	cQuoteCode := oModelDHU:GetValue('DHU_NUM')
	cSupCode := oModelDHU:GetValue('DHU_CODFOR')
	cSupStore := oModelDHU:GetValue('DHU_LOJAFOR')
	cSupName := oModelDHU:GetValue('DHU_NOMFOR')
	oModel := oModelDHU:GetModel()
	
	SC8->(DbSetOrder(8)) //-- C8_FILIAL+C8_NUM+C8_FORNECE+C8_LOJA+C8_FORNOME
	SA2->(DbSetOrder(1)) //-- A2_FILIAL+A2_COD+A2_LOJA

	If cField == 'DHU_TPFORN'
		oModelDHU:LoadValue('DHU_CODFOR' , '')
		oModelDHU:LoadValue('DHU_LOJAFOR', '')
		oModelDHU:LoadValue('DHU_NOMFOR' , '')
		oModelDHU:LoadValue('DHU_CONTATO', '')
		oModelDHU:LoadValue('DHU_EMAIL'  , '')
	ElseIf cField == 'DHU_CODFOR'
		If !Empty(cValue)
			If lRet := ExistCpo("SA2", cValue)
				If SA2->(MsSeek(FWxFilial('SA2') + cValue))
					While !SA2->(Eof()) .And. xFilial("SA2")+cValue == SA2->A2_FILIAL+SA2->A2_COD //-- Posiciona na loja do fornecedor que ainda não foi utilizada em uma proposta
						If RegistroOk("SA2",.F.) .And. Empty(GetAdvFval("SC8","C8_NUM",xFilial("SC8") + cQuoteCode+cValue+SA2->A2_LOJA,8))
							lFound := .T.
							Exit
						Else
							SA2->(DbSkip())
						EndIf
					EndDo

					If lFound
						oModelDHU:SetValue('DHU_LOJAFOR', SA2->A2_LOJA) //-- Define a loja para que seja realizada validação do fornecedor a ser utilizado
						lRet := !oModel:HasErrorMessage()

						If lRet //-- Carrega dados do fornecedor
							oModelDHU:LoadValue('DHU_NOMFOR' , SA2->A2_NOME)
							oModelDHU:LoadValue('DHU_CONTATO', SA2->A2_CONTATO)
							oModelDHU:LoadValue('DHU_EMAIL'  , SA2->A2_EMAIL)
						EndIf
					Else
						oModelDHU:LoadValue('DHU_LOJAFOR', '')
						oModelDHU:LoadValue('DHU_NOMFOR' , '')
						oModelDHU:LoadValue('DHU_CONTATO', '')
						oModelDHU:LoadValue('DHU_EMAIL'  , '')
					EndIf
				EndIf
			EndIf
		EndIf
	ElseIf cField == 'DHU_LOJAFOR'
		If !Empty(cValue)
			If lRet := ExistCpo("SA2", cSupCode + cValue) .And. RegistroOk("SA2")
				If lRet := !SC8->(MsSeek(FWxFilial('SC8') + cQuoteCode + cSupCode + cValue)) //-- Valida se o código e loja do fornecedor já foram utilizados em uma proposta
					If SA2->(MsSeek(FWxFilial('SA2') + cSupCode + cValue)) //-- Carrega dados do fornecedor
						oModelDHU:LoadValue('DHU_NOMFOR' , SA2->A2_NOME)
						oModelDHU:LoadValue('DHU_CONTATO', SA2->A2_CONTATO)
						oModelDHU:LoadValue('DHU_EMAIL'  , SA2->A2_EMAIL)
					EndIf
				Else
					oModelDHU:LoadValue('DHU_LOJAFOR', '')
					oModelDHU:LoadValue('DHU_NOMFOR' , '')
					oModelDHU:LoadValue('DHU_CONTATO', '')
					oModelDHU:LoadValue('DHU_EMAIL'  , '')
					oModel:SetErrorMessage(,,,, 'NF020HASCODE', STR0039) //-- Já existe uma proposta com este código e loja de fornecedor.
				EndIf
			EndIf
		EndIf
	ElseIf cField == 'DHU_NOMFOR'
		cSupCodeAux  := PadR('', TamSX3('C8_FORNECE')[1], " ")
		cSupStoreAux := PadR('', TamSX3('C8_LOJA'   )[1], " ")

		If !Empty(cValue) .And. SC8->(MsSeek(FWxFilial('SC8') + cQuoteCode + cSupCodeAux + cSupStoreAux + cValue)) //-- Valida se o nome do fornecedor já foi utilizado em uma proposta
			oModel:SetErrorMessage(,,,, 'NF020HASNAME', STR0040) //-- Já existe uma proposta com este nome de fornecedor.
			lRet := .F.
		EndIf
	ElseIf cField == 'DHU_EMAIL'
		If !Empty(cValue)
			lRet := NFCVldEmail(cValue, @cMessage, @cSolution) //-- Valida e-mails preenchidos
			oModel:SetErrorMessage(,,,, 'NF020EMAIL2', cMessage, cSolution)
		EndIf
	EndIf

	aEval(aAreas, {|x| RestArea(x), FwFreeArray(x) })
Return lRet

/*/{Protheus.doc} GetSupName
	Obtém nome do fornecedor
@author juan.felipe
@since 02/2024
@return cSupName, character, nome do fornecedor.
/*/
Static Function GetSupName()
	Local cSupName As Character

	cSupName := ''

	If !Empty(_oJsonSup['supplierCode'] + _oJsonSup['supplierStore'])
		cSupName := PGCCarEsp(GetAdvFVal("SA2", "A2_NOME" , fwxFilial("SA2") + _oJsonSup['supplierCode'] + _oJsonSup['supplierStore'] ,1,"",.T.))
	Else
		cSupName := _oJsonSup['supplierName']
	EndIf
Return cSupName

/*/{Protheus.doc} NF020RmOpt
	Remove opções que não sejam 1, 2, 3 ou 8 (se Portal Fornecedor) do campo C8_SITUAC
@author juan.felipe
@since 02/2024
@return aOptions, array, opções do campo C8_SITUAC.
/*/
Function NF020RmOpt(oStructSC8)
	Local aOptions 	As Array
	Local cOption 	As Character
	Local nX 		As Numeric
	Local nLen 		As Numeric
	Local cIncPF 	as Character
	Default oStructSC8 := Nil

	aOptions := oStructSC8:GetProperty("C8_SITUAC", 13) //-- Obtém opções do campo combo
	cOption := ''
	nX := 1
	nLen := Len(aOptions)
	cIncPF := ""
	if ( NF020MxProp() )
		cIncPF := "8="
	endif

	For nX := nLen To 1 Step -1 //-- Percorre o array da última posição para a primeira
        cOption := aOptions[nX]
		
        If !('1=' $ cOption .Or. '2=' $ cOption .Or. '3=' $ cOption .Or. cIncPF $ cOption) //-- Não são as opções 1, 2, 3 e 8
            aDel(aOptions, nX) //-- Remove última opção
			aSize(aOptions, Len(aOptions)-1)
        EndIf
    Next
Return aOptions

/*/{Protheus.doc} GetSupType
	Obtém o tipo do fornecedor, 1= Cadastrado; 2= Não cadastrado
@author juan.felipe
@since 02/2024
@return cType, character, tipo do fornecedor.
/*/
Static Function GetSupType()
	Local cType As Character
	
	If Empty(_oJsonSup['supplierCode'] + _oJsonSup['supplierStore']) .And. !_oJsonSup['newParticipant']
		cType := '2' //-- Fornecedor não cadastrado
	Else
		cType := '1' //-- Fornecedor cadastrado
	EndIf
Return cType

/*/{Protheus.doc} recalTot
	Recalculo o valor total e atualiza a view.
@author renan.martins
@since 02/2024
@param oModel - Modelo de dados
@return Nil, nulo.
/*/
Function recalTot(oModel)
	local oModelDHU := nil
	local oView  	:= FwViewActive()
	local nTotal    := 0
	default oModel	:= FwModelActive()
	
	if oModel == nil //Se continuar como nil, tento recuperar pela View ativa
		oModel := oView:GetModel("DHUMASTER")
	endif

	if oModel != nil .and. oModel:isActive()

		oModelDHU := oModel:GetModel('DHUMASTER')

		If cPaisLoc == "BRA"
			nTotal += oModelDHU:GetValue("DHU_TOTIPI") + oModelDHU:GetValue("DHU_TOTISO") + ;
					  oModelDHU:GetValue("DHU_IBSMUN") + oModelDHU:GetValue("DHU_IBSEST") + oModelDHU:GetValue("DHU_CBSFED")
		EndIf

		nTotal += oModelDHU:GetValue("DHU_TOTIT") + (oModelDHU:GetValue("DHU_VALFRE") +;
				oModelDHU:GetValue("DHU_SEGURO") + oModelDHU:GetValue("DHU_DESPESA")) -;
				oModelDHU:GetValue("DHU_VLDESC")
		
		oModelDHU:LoadValue("DHU_TOTCOT", nTotal) //Para recalcular e exibir o valor total correto.

		NF020RfSC8(oView)
	endif
Return Nil

/*/{Protheus.doc} NF020RfSC8
	Realiza refresh da view da tabela SC8 e do grid de impostos
@author juan.felipe
@since 02/2024
@return logical, .T.
/*/
Function NF020RfSC8(oView, cViewName)
	Default oView 		:= FwViewActive()
	Default cViewName	:= "VIEW_SC8" //padrão de atualização é sempre a SC8

	If ValType(oView) == "O" .And. oView:IsActive() //Atualizar a view
		oView:Refresh(cViewName)
	EndIf
Return .T.

/*/{Protheus.doc} NF020ItTax
	Efetua a soma total de impostos para o cabeçalho.
@author Leandro Fini
@since 02/2024
@return cType, character, tipo do fornecedor.
/*/
Function NF020ItTax(cTaxField,cTotalField)

Local oModel 	as Object
Local oModelDHU as Object
Local oModelSC8 as Object
Local nX 		as numeric
Local nGridLine as numeric
Local nValueTax as numeric
Local lRet		as logical
local nAliIPI	as numeric
local nValIPI	as numeric
local nBaseIPI	as numeric
local aRetImp	as array
local nPosic 	as numeric
local nValImp	as numeric
local nBaseIMP	as numeric
local lNoMax    as logical
Local lCAlqIpi  as logical
Local nValField as numeric

oModel	  	:= FwModelActive()
oModelDHU 	:= oModel:GetModel('DHUMASTER')
oModelSC8 	:= oModel:GetModel('SC8DETAIL')
nGridLine 	:= oModelSC8:GetLine()
nValueTax 	:= 0
lRet 	  	:= .F.
nAliIPI		:= 0
nValIPI		:= 0
nBaseIPI	:= iif( oModelSC8:GetValue("C8_BASEIPI") != 0, oModelSC8:GetValue(cTaxField), oModelSC8:GetValue("C8_PRECO") * oModelSC8:GetValue("C8_QTDISP"))
nBaseIMP 	:= oModelSC8:GetValue("C8_PRECO") * oModelSC8:GetValue("C8_QTDISP")
aRetImp		:= {{"C8_ALIIPI", "C8_VALIPI"}, {"C8_ALIQCMP", "C8_ICMSCOM"}, {"C8_ALIQISS", "C8_VALISS"}, {"C8_PICM", "C8_VALICM"}}
nPosic 		:= 0
nValImp		:= 0
lNoMax      := .f.
lCAlqIpi	:= SuperGetMV("MV_CALQIPI", .F., .F.)
nValField	:= fwfldget(cTaxField)

If !(nValField < 0)

    nPosic := aScan(aRetImp, {|X| X[1] == cTaxField})
    if nPosic > 0
        lNoMax := iif(nValField > 100, .f., .t.)
    endif

	if ( lNoMax .or. VldValues(fwfldget("C8_TOTAL"), nValField, .t.) )

		lRet := .T.

		//Se campos Alíquotas preenchidos
		if nPosic > 0
			If !(aRetImp[nPosic, 1] $ 'C8_ALIIPI' .AND. lCAlqIpi)
				nValImp:= ((nBaseIMP * oModelSC8:GetValue(cTaxField)) /100)
				oModelSC8:LoadValue(aRetImp[nPosic, 2], nValImp)
			endif
			cTaxField := aRetImp[nPosic, 2]
		
		else
			//procuro por valor
			nPosic := aScan(aRetImp, {|X| X[2] == cTaxField}) 
			if nPosic > 0

				//MV_CALQIPI: Parametro que desabilita o calculo automatico da aliquota do IPI
				If !(aRetImp[nPosic, 1] $ 'C8_ALIIPI' .AND. lCAlqIpi)
					nAliImp := round( ((oModelSC8:GetValue(cTaxField) * 100) / nBaseIMP), 2)
					oModelSC8:LoadValue(aRetImp[nPosic, 1], nAliImp)
				EndIf
			endif
			
		endif

		For nX := 1 to oModelSC8:Length()

			oModelSC8:GoLine(nX)

			nValueTax += oModelSC8:GetValue(cTaxField)

		Next nX

		oModelSC8:GoLine(nGridLine)
		oModelDHU:LoadValue(cTotalField,nValueTax)

		If cTaxField $ 'C8_VALIPI|C8_ALIIPI|C8_VALSOL'
			recalTot(oModel)
		EndIf
	else
		Help(nil, nil, STR0053, nil, STR0055, 1, 0, nil, nil, nil, nil, nil, {}) //Atenção / O valor informado de Imposto/Taxa é maior que o total do item.
		lRet := .f.
	endif
else
	Help(nil, nil , STR0053, nil, STR0056, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / Informe um valor positivo
EndIf

NF020Clean( {aRetImp} )

Return lRet

/*/{Protheus.doc} NF020CobTab
	Realiza o preenchimento do preço do produto de acordo
	com a tabela de preço vinculada no produto x fornecedor
@author Leandro Fini
@since 07/2024
@param nOpc = 1 --> Disparado via valid campo C8_CODTAB
			  2 --> Disparado via outras ações preenchimento
			  		em massa
@return lRet
/*/
Function NF020CobTab(nOpc)

Local oModel 	:= FwModelActive()
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
Local oModelDHU	:= oModel:GetModel("DHUMASTER")
Local nVlrTab 	:= 0
Local cForn		:= oModelSC8:GetValue('C8_FORNECE')
Local cLoja 	:= oModelSC8:GetValue('C8_LOJA')
Local cCodTab 	:= oModelSC8:GetValue('C8_CODTAB')
Local cCodProd	:= oModelSC8:GetValue("C8_PRODUTO")
Local nQtdProd	:= oModelSC8:GetValue("C8_QTDISP")
Local cNFCMoed 	:= SuperGetMV("MV_NFCMOED", .F., "1")
Local nMoeda	:= 0
Local nValFrete	:= oModelSC8:GetValue("C8_VALFRE")
Local lRet 		:= .T.
Local nX		:= 1

If cNFCMoed == "1"
	nMoeda := val(oModelDHU:GetValue("DHU_MOEDA"))
else
	nMoeda := val(oModelDHU:GetValue("CMOEDAPED"))
EndIf

if nOpc == 1 // -- Digitando o campo C8_CODTAB
	if NF020VldTab(1,cForn,cLoja,cCodTab)
		nVlrTab := MaTabPrCom(cCodTab, cCodProd, nQtdProd, cForn, cLoja, nMoeda, dDataBase,,nValFrete)
		if nVlrTab > 0
			oModelSC8:SetValue('C8_PRECO', nVlrTab)
		endif
	else
		lRet := .F.
	endif
elseif nOpc == 2 // Alteração em massa via outras ações

	for nX := 1 to oModelSC8:Length()
		oModelSC8:GoLine(nX)
		cCodProd	:= oModelSC8:GetValue("C8_PRODUTO")
		nQtdProd	:= oModelSC8:GetValue("C8_QTDISP")
		nValFrete	:= oModelSC8:GetValue("C8_VALFRE")
		cCodTab := GetAdvFval("SA5","A5_CODTAB",fwxFilial("SA5") + cForn + cLoja + cCodProd, 1)
		if !empty(cCodTab) .and. NF020VldTab(2,cForn,cLoja,cCodTab)
			nVlrTab := MaTabPrCom(cCodTab, cCodProd, nQtdProd, cForn, cLoja, nMoeda, dDataBase,,nValFrete)
			if nVlrTab > 0
				oModelSC8:LoadValue('C8_CODTAB', cCodTab)//-- Utilizo LoadValue para não disparar a validação do campo sem necessidade.
				oModelSC8:SetValue('C8_PRECO'  , nVlrTab)
			endif
		endif
	next nX
	oModelSC8:GoLine(1)
endif

Return lRet

/*/{Protheus.doc} NF020CobTab
	Realiza validação da vigência da tabela de preço.
@author Leandro Fini
@since 07/2024
@return lRet
/*/
Static Function NF020VldTab(nOpc,cForn,cLoja,cCodTab)

Local lRet 		:= .T.
Default cForn	:= ""
Default cLoja	:= ""
Default cCodTab	:= ""
Default nOpc 	:= 1

DbSelectArea("AIA")
AIA->(DbSetOrder(1))

if AIA->(Msseek(fwxFilial("AIA")+cForn+cLoja+cCodTab))
	if dDatabase < AIA->AIA_DATDE .Or. dDatabase > IIF(!Empty(AIA->AIA_DATATE),AIA->AIA_DATATE,dDatabase )
		lRet := .F.
		if nOpc == 1
			Help(nil, nil , STR0053, nil, STR0077 , 1, 0, nil, nil, nil, nil, nil, {STR0078} ) //'Data de vigência da tabela de preço deve ser maior que a data base.'#'Revise a data de vigência da tabela.'
		endif
	endif
else
	if nOpc == 1
		lRet := .F.
		Help(nil, nil , STR0053, nil, STR0079 , 1, 0, nil, nil, nil, nil, nil, {STR0080} ) //Insira um código de tabela de preço válido.#Insira uma tabela de preços existente.
	endif
endif

Return lRet

/*/{Protheus.doc} NF020CobTab
	Realiza a chamada para preenchimento em massa dos preços
	de acordo com tabela vinculada no produto x fornecedor
@author Leandro Fini
@since 07/2024
/*/
Static Function NF020SetTab()

if MsgYesNo(STR0081,STR0076)//Deseja preencher automaticamente os preços dos produtos de acordo com a tabela de preço vinculada no cadastro de Produto x Fornecedor? #Tabela de preços
	FWMsgRun(, {|| NF020CobTab(2) }, STR0047, STR0082)//Aguarde #'Carregando preços...
endif

Return .T.
/*/{Protheus.doc} NF020Calc
	Efetua o cálculo de impostos de acordo com cadastros
@author Leandro Fini
@since 02/2024.
@return cType, character, tipo do fornecedor.
/*/
Function NF020Calc(lSaveF2D)
	Local oModel 		:= FwModelActive()
	Local oModelDHU 	:= oModel:GetModel("DHUMASTER")
	Local oModelSC8 	:= oModel:GetModel("SC8DETAIL")
	Local oView 		:= FwViewActive()
	Local nX 			:= 1
	Local nZ 			:= 1
	Local aCabec 		:= {}
	Local aItens 		:= {}
	Local lExsC8CF		:= SC8->(FieldPos("C8_CF")) > 0
	Local oTypView		:= nil
	Local nTamGrid		:= oModelSC8:Length()
	Local lBrazil		:= cPaisLoc == "BRA"
	Local lCAlqIpi		:= SuperGetMV("MV_CALQIPI", .F., .F.)
	Local lCommit   	:= FwIsInCallStack("CommitData")
	Local lFldSC8		:= .F.

	Local nTamNum 		:= TAMSX3("C8_NUM")[1]
	Local nTamForn 		:= TAMSX3("C8_FORNECE")[1]
	Local nTamLoja 		:= TAMSX3("C8_LOJA"   )[1]
	Local nTamNome 		:= TAMSX3("C8_FORNOME")[1]
	Local nTamCond 		:= TAMSX3("C8_COND"   )[1]
	Local nTamFilen 	:= TAMSX3("C8_FILENT" )[1]

	Local nTamNumPro 	:= TAMSX3("C8_NUMPRO" )[1]
	Local nTamProd 		:= TAMSX3("C8_PRODUTO")[1]
	Local nTamItem 		:= TAMSX3("C8_ITEM"   )[1]
	Local nTamTES 		:= TAMSX3("C8_TES"    )[1]
	Local nTamUM 		:= TAMSX3("C8_UM"     )[1]
	Local nTamCF 		:= 0
	Local nTamIDTrib 	:= 0

	Private aImpVal        As Array
	Private lMsErroAuto    As Logical
	Private lMsHelpAuto    As Logical
	Private lAutoErrNoFile As Logical
	Private oTribProcGen   as Object

	Default lSaveF2D	:= .F.

	If !Empty(oModelDHU:GetValue('DHU_COND'))
		A150SetPGC(.T.)

		aImpVal := {}
		lMsErroAuto := .F.
		lMsHelpAuto := .T.
		lAutoErrNoFile := .T.
		oTribProcGen := JsonObject():New()

		if (lExsC8CF)
			nTamCF := TAMSX3("C8_CF")[1]
		endif
		if (_lTrbGen)
			nTamIDTrib 	:= TAMSX3("C8_IDTRIB")[1]
		endif

		DbSelectArea("SC8")
		SC8->(DbSetOrder(1))
		SC8->(MsSeek(FWxFilial('SC8')+PADR(oModelSC8:GetValue("C8_NUM"), nTamNum)))

		aadd(aCabec ,{"C8_FORNECE"   ,PADR(_oJsonSup['supplierCode']        , nTamForn)})
		aadd(aCabec ,{"C8_LOJA"      ,PADR(_oJsonSup['supplierStore']       , nTamLoja)})
		aadd(aCabec ,{"C8_FORNOME"   ,PADR(_oJsonSup['supplierName' ]   	, nTamNome)})
		aadd(aCabec ,{"C8_COND"      ,PADR(oModelDHU:GetValue("DHU_COND")	, nTamCond)})
		aadd(aCabec ,{"C8_FILENT"    ,PADR(oModelSC8:GetValue("C8_FILENT") 	, nTamFilen)})
		aadd(aCabec ,{"C8_CONTATO"   ,"AUTO"                                	})
		aadd(aCabec ,{"C8_MOEDA"     ,oModelSC8:GetValue("C8_MOEDA")            })
		aadd(aCabec ,{"C8_TXMOEDA"   ,oModelSC8:GetValue("C8_TXMOEDA")          })
		aadd(aCabec ,{"C8_EMISSAO"   ,oModelSC8:GetValue("C8_EMISSAO")       	})
		aadd(aCabec ,{"C8_TPFRETE"   ,oModelDHU:GetValue("DHU_FRETE")          })
		aadd(aCabec ,{"C8_VLDESC"    ,oModelDHU:GetValue("DHU_VLDESC")           })
		aadd(aCabec ,{"C8_DESPESA"   ,oModelDHU:GetValue("DHU_DESPESA")          })
		aadd(aCabec ,{"C8_SEGURO"    ,oModelDHU:GetValue("DHU_SEGURO")           })
		aadd(aCabec ,{"C8_VALFRE"    ,oModelDHU:GetValue("DHU_VALFRE")           })
		/*Se for novo participante e cadastrado na base, como o sistema clona os dados do primeiro posicionado, necessitamos mudar o 
		fornecedor no mata150, para cálculo correto dos tributos */
		if (_oJsonSup['newParticipant'] .and. oModelDHU:GetValue("DHU_TPFORN") == "1")
			aadd(aCabec, {"FORNREALMD", oModelDHU:GetValue("DHU_CODFOR") })
			aadd(aCabec, {"LOJAREALMD", oModelDHU:GetValue("DHU_LOJAFOR") })
		endif

		for nX := 1 to nTamGrid
			oModelSC8:GoLine(nX)
			aadd(aItens,{{"C8_NUMPRO"   ,PADR(oModelSC8:GetValue("C8_NUMPRO")     , nTamNumPro)	,Nil},;
						{"C8_PRODUTO"   ,PADR(oModelSC8:GetValue("C8_PRODUTO")	  , nTamProd)	,Nil},;
						{"C8_ITEM"      ,PADR(oModelSC8:GetValue("C8_ITEM")       , nTamItem)	,Nil},;
						{"C8_TES"       ,PADR(oModelSC8:GetValue("C8_TES")        , nTamTES)	,Nil},;
						{"C8_UM"        ,PADR(oModelSC8:GetValue("C8_UM")     	  , nTamUM)		,Nil},;
						{"C8_QTDISP"    ,oModelSC8:GetValue("C8_QTDISP")          , Nil},;
						{"C8_PRECO"     ,oModelSC8:GetValue("C8_PRECO")           , NIL},;
						{"C8_VLDESC"     ,oModelSC8:GetValue("C8_VLDESC")           , NIL},;
						{"C8_DESPESA"     ,oModelSC8:GetValue("C8_DESPESA")           , NIL},;
						{"C8_SEGURO"     ,oModelSC8:GetValue("C8_SEGURO")           , NIL},;
						{"C8_VALFRE"     ,oModelSC8:GetValue("C8_VALFRE")           , NIL},;
						{"C8_TOTAL"     ,oModelSC8:GetValue("C8_TOTAL")           , NIL}})
			if (lExsC8CF)
				aadd(aItens[nX], {"C8_CF", PADR(oModelSC8:GetValue("C8_CF"), nTamCF), Nil})
			endif

			if (_lTrbGen)
				aadd(aItens[nX], {"C8_IDTRIB", PADR(oModelSC8:GetValue("C8_IDTRIB"), nTamIDTrib), Nil})
			endif
		next nX
		
		MSExecAuto({|v,x,y,k,t| MATA150(v,x,y,,,,k,t)},aCabec,aItens,3,.T.,lSaveF2D)

		If !lMsErroAuto .And. Len(aImpVal) > 0
			oTypView := ValType(oView)
			for nX := 1 to len(aImpVal)
				oModelSC8:GoLine(nX)

				if oModelSC8:GetValue('C8_TOTAL') > 0 //-- Deve definir impostos apenas quando o total do item for maior que zero
					for nZ := 1 to len(aImpVal[nX][2])
						cField	:= aImpVal[nX][2][nZ][2]
						lFldSC8	:= oModelSC8:HasField(cField)

						if ( (oTypView == 'O' .And. oView:HasField("VIEW_SC8", cField)) .Or. (oTypView <> 'O' .And. lFldSC8) .or. (lExsC8CF .and. cField == "C8_IDTRIB") .or.;
							( cField == "C8_BASEICM" .and. lFldSC8) ) //-- Procura se o campo de imposto está na view
							If oModelSC8:CanSetValue(cField)
								If !( lCAlqIpi .And. ( (cField == "C8_ALIIPI" .Or. cField == "C8_VALIPI" ) .And. oModelSC8:GetValue(cField) > 0 ) .And. lCommit  ) // Quando o parametro: MV_CALQIPI estiver ativo e a função for chamada pelo commmit deve persistir o que foi digitado pelo usuario
									oModelSC8:LoadValue(cField, aImpVal[nX][2][nZ][3])
								Endif
							EndIf
						endif
					next nZ
				endIf
			next nX
		Endif

		if ( !lSaveF2D ) //Se for na hora de salvar, não tem necessidade de recalcular esses campos, pois queremos armazenar apenas o C8_IDTRIB
			if lBrazil
				_lRecalcTrib := .T.
				NF020HsMem("C", oTribProcGen)
				NF020TOTTAX()
			endif
			recalTot(oModel)
			oModelSC8:GoLine(1)
		endif
	Else
		Help(nil, nil , STR0053, nil, STR0067, 1, 0, nil, nil, nil, nil, nil, {} ) //-- Atenção / É necessário preencher o campo 'Condição pagamento'.
	EndIf

Return Nil


//-------------------------------------------------------------------
/*/ {Protheus.doc} NF020AtuCmpVal
Atualiza informações dos campos de valores, quando selecionado Não Vende ou sem estoque
@author renan.martins
@since 03/2024
@version P12
/*/
//-------------------------------------------------------------------
function NF020AtuCmpVal(oView, cTipo, oModel)
local oObjSC8   := nil
local lRet		:= .t.
local aCamposP	:= {"C8_QTDISP", "C8_PRECO", "C8_VLDESC"}
local aCamposTx	:= {"C8_VALICM", "C8_VALIPI", "C8_VALSOL", "C8_ICMSCOM", "C8_VALISS", "C8_ALIQCMP", "C8_ALIQISS", "C8_PICM"}
local nFor		:= 0
default oView	:= FwViewActive()

//Verifico se os campos de impostos existem na base, devido ao MI
for nFor := 1 to Len(aCamposTx)
	if _oJsonField[aCamposTx[nFor]] == Nil
		if (SC8->(FieldPos(aCamposTx[nFor])) > 0 )
			_oJsonField[aCamposTx[nFor]] := .t.
			aadd(aCamposP, aCamposTx[nFor])
		endif
	elseif _oJsonField[aCamposTx[nFor]]
		aadd(aCamposP, aCamposTx[nFor])
	endif
next

oObjSC8 := oView:GetModel("SC8DETAIL")

if cTipo == "1"
    if oObjSC8:getvalue("C8_SITUAC") != "1"
		//habilito o when, para zerar os campos
		oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||.t.})
		for nFor := 1 to len(aCamposP)
        	oObjSC8:setValue(aCamposP[nFor], 0)
		next
		//Desabilito o when com a regra padrão, para não editar se diferente de 1
		oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||fwfldget('C8_SITUAC') == '1'})
		NF020RfSC8(oView)
	else
		oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty('*', MODEL_FIELD_WHEN,{||fwfldget('C8_SITUAC') == '1'})
		oObjSC8:setValue("C8_QTDISP", fwfldget('C8_QUANT')) //Para ficar com a Qtd dispnível igual a solicitada na cotação
		NF020RfSC8(oView)
    endif	
endif

oModel:GetModel("SC8DETAIL"):GetStruct():SetProperty( 'C8_SITUAC' , MODEL_FIELD_WHEN,{|| .t.})

return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} VldValues
Atualiza informações dos campos de valores, quando selecionado Não Vende ou sem estoque
@author renan.martins
@since 03/2024
@version P12 
/*/
//-------------------------------------------------------------------
static function VldValues(nRefer, nCompar, lMaior)
local lRet		:= .t.
default nRefer	:= 0
default nCompar	:= 0
default lMaior	:= .t.

if (lMaior .And. QtdComp(nCompar) > QtdComp(nRefer)) .Or. (!lMaior .And. QtdComp(nCompar) < QtdComp(nRefer))
	lRet := .f.
endif

return lRet


/*/{Protheus.doc} NFCDiffValues
	Retorna a diferença no rateio de valores por item. Baseado no método ApportionmentDiffValues
@author juan.felipe
@since 03/2024
@param nTotalValueGenerated, numeric, valor total gerado no rateio dos itens.
@param nRealTotalValue, numeric, valor total real a ser comparado com o total gerado.
@param nItemValue, numeric, valor do item.
@return nRetDiff, numeric, diferença entre os valores.
/*/
static function NFCDiffValues(nTotalValueGenerated, nRealTotalValue, nItemValue)
    Local nDiff As Numeric
    Local nRetDiff As Numeric
	Default nTotalValueGenerated := 0
	Default nRealTotalValue := 0
	Default nItemValue := 0

    nRetDiff := nItemValue

    If nTotalValueGenerated != nRealTotalValue
        nDiff := nTotalValueGenerated - nRealTotalValue
        nRetDiff := nItemValue + (nDiff*-1)
    EndIf
Return nRetDiff


/*/{Protheus.doc} NF020LdFldExp
	Carrega objeto JSON, onde armazena os campos de impostos, taxas e alíquotas que existem no ambiente.
@author renan.martins
@since 03/2024
@param oModel, object, Modelo de dados do MVC.
@return Null, Null, Nulo
/*/
static function NF020LdFldExp(oModel)
local aCampos 	:= {"C8_VALICM", "C8_VALIPI", "C8_VALSOL", "C8_ICMSCOM", "C8_VALISS", "C8_ALIIPI", "C8_BASEIPI", "C8_BASESOL"}
local nFor		:= 0
local nTamArr	:= len(aCampos)
local oModelSC8 := oModel:GetModel("SC8DETAIL")
local aCmpMdl	:= oModelSC8:getstruct():getfields()

for nFor := 1 to nTamArr
	if _oJsonField[aCampos[nFor]] == Nil
		_oJsonField[aCampos[nFor]] := .F.

		if (SC8->(FieldPos(aCampos[nFor])) > 0 .and. aScan(aCmpMdl, {|x| x[3] == aCampos[nFor]}) > 0 )
			_oJsonField[aCampos[nFor]] := .T.
		endif
	endif
next
return


/*/{Protheus.doc} NF020QtDisp
	Validação do campo C8_QTDISP, ao ser preenchido.
@author renan.martins
@since 03/2024
@return lRet, boolean, Retorna se a validação foi verdadeira ou falsa
/*/
function NF020QtDisp()
Local oModel 	:= FwModelActive()
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
local lRet 		:= .t.
local nQtdDisp	:= oModelSC8:getValue("C8_QTDISP")
local nQtdSol	:= oModelSC8:getValue("C8_QUANT")
local nVlrItem	:= oModelSC8:GetValue("C8_PRECO") * nQtdDisp

Local nQtdSaldo := 0

local aMsgError	:= {}

	if(vldCentral(oModelSC8:getValue("C8_NUM"),oModelSC8:getValue("C8_PRODUTO"),oModelSC8:getValue("C8_IDENT")))
		aMsgError := {STR0053, STR0070}//// -- Atenção //"Não é permitido a alteração da quantidade disponível quando o item for proveniente de compra centralizada.
	endif

	if lRet .and. !( VldValues(nQtdSol, nQtdDisp, .t.) )
		aMsgError := {STR0053, STR0057} //Atenção / Valor inserido no campo Qtd. Disponível é maior que a quantidade solicitada.
	EndIf

	if lRet .and. ( oModelSC8:getValue("C8_SITUAC") == "1" .and. nQtdDisp == 0 )
		aMsgError := {STR0053, STR0058} //Atenção / Informe uma quantidade disponível diferente de zero, pois a Situação está como Considera.
	endif

	if (  nVlrItem > 0 .and. !(VldValues(nVlrItem, oModelSC8:GetValue("C8_VLDESC"), .t.)) )
		oModelSC8:setValue("C8_VLDESC", 0)
	endif

	If _oJsonSup['newProposal'] .or. _oJsonSup['newParticipant'] .or. _oJsonSup['editPartial']

		nQtdSaldo := calcQtdDisp()
		If nQtdDisp > nQtdSaldo  
			aMsgError := {STR0053, STR0087} //Atenção / Valor inserido no campo Qtd. Disponível é maior que a quantidade em saldo.
		EndIf
	EndIf

	if Len(aMsgError) > 0
		Help(nil, nil , aMsgError[1], nil, aMsgError[2], 1, 0, nil, nil, nil, nil, nil, {} )
		lRet := .f.
	elseif cPaisLoc == "BRA"
		oModelSC8:LoadValue("C8_BASEIPI", nVlrItem)
		oModelSC8:LoadValue("C8_BASESOL", nVlrItem)
		if ( !empty(oModelSC8:GetValue("C8_CODTAB")) ) //Se tiver tabela de preço, recalcular preço de acordo com a quantidade disponível e faixa correspondente
			NF020CobTab(1)
		endif
	endif

return lRet


/*/{Protheus.doc} NF020VlMoe
	Validação dos campos de Moeda e Taxa Moeda, para evitar números negativos e prover validação correta.
@author renan.martins
@since 03/2024
@return lRet, boolean, Retorna se a validação foi verdadeira ou falsa
/*/
static function NF020VlMoe(cField)
Local oModel    := FwModelActive()
Local oModelDHU := oModel:GetModel("DHUMASTER")
local lRet      := .t.
local cTempVal  := ""
default cField  := "DHU_TXMOEDA"

if ( upper(cField) == "DHU_MOEDA" )
	cTempVal := oModelDHU:getValue(cField)
	if !( ExistCpo("CTO", cTempVal) )
		lRet := .f.
	endif
endif

if lRet .and. cField == "DHU_TXMOEDA" .and. oModelDHU:getValue(cField) < 0
    lRet := .f.
    Help(nil, nil , STR0053, nil, STR0056, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / Informe um valor positivo
endif

return lRet

/*/{Protheus.doc} NF020TgFre
	Validação do campo DHU_FRETE
@author renan.martins
@since 03/2024
@return lRet, boolean, Retorna se a validação foi verdadeira ou falsa
/*/
function NF020TgFre()
Local oModel 	:= FwModelActive()
Local oModelDHU := oModel:GetModel("DHUMASTER")
Local lRet 		:= .t.
Local nTotal    := 0

lRet := oModelDHU:getValue("DHU_FRETE") $ ('CFTSRD')

if lRet .and. oModelDHU:getValue("DHU_FRETE") != "C"
	//Habilito o when, para zerar o conteúdo do campo
	oModel:GetModel("DHUMASTER"):GetStruct():SetProperty('DHU_VALFRE', MODEL_FIELD_WHEN,{|| .t.})
	oModelDHU:setValue("DHU_VALFRE", 0)
	oModel:GetModel("DHUMASTER"):GetStruct():SetProperty('DHU_VALFRE', MODEL_FIELD_WHEN,{|| FwFldGet('DHU_FRETE') == 'C'})

	If cPaisLoc == "BRA"
		nTotal += oModelDHU:GetValue("DHU_TOTIPI") + oModelDHU:GetValue("DHU_TOTISO")
	EndIf

	nTotal += oModelDHU:GetValue("DHU_TOTIT") + (oModelDHU:GetValue("DHU_VALFRE") +;
		      oModelDHU:GetValue("DHU_SEGURO") + oModelDHU:GetValue("DHU_DESPESA")) -;
		      oModelDHU:GetValue("DHU_VLDESC")

	//Por algum motivo, o valor total não era exibido, forço a atualização
	oModelDHU:LoadValue("DHU_TOTCOT", nTotal) //Para recalcular e exibir o valor total correto.
endif

return lRet

/*/{Protheus.doc} VldPayment
	Validação do campo DHU_COND
@author juan.felipe
@since 04/2024
@return lRet, boolean, Retorna se a validação foi verdadeira ou falsa
/*/
Function VldPayment()
	Local lRet := .F.
	Local oModel := FwModelActive()
	Local oModelDHU := oModel:GetModel('DHUMASTER')

	lRet := ExistCpo("SE4", oModelDHU:GetValue('DHU_COND'))
Return lRet

/*/{Protheus.doc} vldCentral
	Validação se o item é de compra centralizada
@author Leandro Fini
@since 04/2024
@return lRet, boolean, Retorna se o item faz parte de compra centralizada.
/*/
Static Function vldCentral(cNumCot, cProduto, cIdent)
    Local cQuery        As character
    Local oQuery        as object
    Local cAliasTemp    as character
	Local lRet 			as logical

    cQuery := " SELECT C1_FILIAL, C1_NUM, C1_SCORI FROM " + RetSqlName("SC1") + " SC1 "
    cQuery += "    WHERE SC1.C1_FILIAL = ? AND "
    cQuery += "          SC1.C1_COTACAO = ? AND "
    cQuery += "          SC1.C1_PRODUTO = ? AND "
    cQuery += "          SC1.C1_IDENT = ?  AND "
	cQuery += "          SC1.C1_SCORI <> ' ' AND "
    cQuery += "   SC1.D_E_L_E_T_ = ' ' "

    oQuery := FWPreparedStatement():New(cQuery)

    oQuery:SetString(1, FWxFilial('SC1'))
    oQuery:SetString(2, cNumCot)
    oQuery:SetString(3, cProduto)
    oQuery:SetString(4, cIdent)

    cAliasTemp := GetNextAlias()
    cAliasTemp := MpSysOpenQuery(oQuery:getFixQuery())
	lRet := .F.

    If !(cAliasTemp)->(Eof())
    	lRet := .T.
		(cAliasTemp)->(DbSkip())
	EndIf

    (cAliasTemp)->(dbCloseArea())
    oQuery:Destroy()
    FreeObj(oQuery)

Return lRet


/*/{Protheus.doc} NF020UpdDate
	Função para atualizar a data de entrega dos itens que estão abaixo da linha posicionada, com o mesmo valor. Atua no campo C8_DATPRF
@author renan.martins
@since 07/2024
@return lRet, boolean, Retorna se a validação foi verdadeira ou falsa
/*/
static function NF020UpdDate()
Local oModel 	:= FwModelActive()
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
Local lRet 		:= .T.
Local nFor		:= 0
Local nLineSel	:= oModelSC8:GetLine()
Local dDateSel	:= oModelSC8:GetValue("C8_DATPRF")

if ( nLineSel > 0 )
	for nFor := nLineSel to oModelSC8:Length()
		oModelSC8:GoLine(nFor)
		oModelSC8:LoadValue("C8_DATPRF", dDateSel)
	next
	NF020RfSC8(nil)
	Help(nil, nil , STR0053, nil, STR0073 + DtoC(dDateSel) + " " + STR0074, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / A data: / foi replicada para os demais itens da cotação.
endif
return lRet


/*/{Protheus.doc} NF020VlDtPrev
Verifica se a data informada no campo C8_DATPRF é menor que a database, pois é inválido
@author renan.martins
@since 07/2024
@return lRet, boolean, Retorna se a validação foi verdadeira ou falsa
/*/
function NF020VlDtPrev()
Local oModel 	:= FwModelActive()
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
Local lRet 		:= .T.

if (oModelSC8:getValue("C8_DATPRF") < dDataBase)
	lRet := .F.
	Help(nil, nil , STR0053, nil, STR0071, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / A data informada deve ser igual ou maior que a data base do sistema.
endif
return lRet


/*/{Protheus.doc} NF020VALCF
Valida o conteúdo do campo C8_CF, tanto no NFC quanto no legado.
@author renan.martins
@since 07/2024
@return lRet, lógico, se a validação do campo ocorreu com sucesso.
/*/
Function NF020VALCF()
Local lRet    	:= .T.
local nPosTes 	:= 0
Local oModel	:= Nil
Local cValCF	:= ""
Local cValTES	:= ""
Local lRetCF	:= .F.

if (_lInNFCAlt)
	oModel	:= FwModelActive()
	cValCF 	:= oModel:GetModel("SC8DETAIL"):getValue("C8_CF")
	cValTES := oModel:GetModel("SC8DETAIL"):getValue("C8_TES")
elseif (!_lInNFCAlt .and. _lLegaGrid)
	nPosTes := GdFieldPos("C8_TES", aHeader)
	cValTES := Acols[n,nPosTes]
	cValCF 	:= M->C8_CF
endif

lRetCF 	:= empty(cValCF)
if !lRetCF .and. empty(cValTES)
	Help(nil, nil , STR0053, nil, STR0083, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / "Preencha primeiro o campo de TES, antes de inserir o CFOP."
	lRet := .f.
	if (!_lInNFCAlt)
		M->C8_CF := ""	
	endif
endif

if (!lRet .or. lRetCF)
	MaFisRef("IT_CF", "MT150", "000") //Sem CFOP
else
	lRet := AvalCfo("SC8", cValCF)
	MaFisRef("IT_CF", "MT150", cValCF)
endif

Return lRet


/*/{Protheus.doc} NF020VALTES
Valida o conteúdo do campo C8_TES, tanto no NFC quanto no legado.
@author renan.martins
@since 07/2024
@return lRet, lógico, se a validação do campo ocorreu com sucesso.
/*/
Function NF020VALTES()
Local lRet    	:= .T.
Local oModel	:= Nil
Local cValTES	:= ""
Local lRetTES	:= .T.

if (_lInNFCAlt)
	oModel	:= FwModelActive()
	cValTES := oModel:GetModel("SC8DETAIL"):getValue("C8_TES")
elseif (!_lInNFCAlt .and. _lLegaGrid)
	cValTES := M->C8_TES
endif

lRetTES := empty(cValTES)

if (lRetTES)
	MaFisRef("IT_TES", "MT150", "000") //Sem TES
else
	lRet := ExistCpo("SF4", cValTES) .and. MaAvalTes("E", cValTES)
	MaFisRef("IT_TES", "MT150", cValTES)
endif

Return lRet


/*/{Protheus.doc} NF020UpdTES
	Chamada para preencher todos os registros com o TES posicionado.
@author renan.martins
@since 08/2024
/*/
Static Function NF020UpdTES(lAutoma)
Local oModel 	:= FwModelActive()
Local oModelSC8 := oModel:GetModel("SC8DETAIL")
Local nFor		:= 0
Local cCodTES	:= oModelSC8:GetValue("C8_TES")
Local lExsC8CF	:= SC8->(FieldPos("C8_CF")) > 0
Local cCodCF	:= iif( (lExsC8CF), oModelSC8:GetValue("C8_CF"), "")
default lAutoma := .F.

if ( lAutoma .or. MsgYesNo(STR0085 + cCodTES,STR0053) )//Deseja replicar o código TES e CFOP para todos os registros? Código TES:  / Atenção
	for nFor := 1 to oModelSC8:Length()
		oModelSC8:GoLine(nFor)
		oModelSC8:LoadValue("C8_TES", cCodTES)
		if (lExsC8CF)
			oModelSC8:LoadValue("C8_CF", cCodCF)
		endif
	next
	NF020RfSC8(nil)
	oModelSC8:GoLine(1)
	Help(nil, nil , STR0053, nil, STR0086, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / "O código TES e CFOP foi replicado para os demais itens da cotação.
endif

Return .T.


/*/{Protheus.doc} NF020TOTTAX
	Função para calcular os totais de impostos, quando a função Calcular Impostos for utilizada, para que esses campos sejam contabilizados
	corretamente, exibindo os valores esperados.
@author renan.martins
@since 10/2024
/*/
Static Function NF020TOTTAX()
	Local oModel 		as Object
	Local oModelDHU 	as Object
	Local oModelSC8 	as Object
	Local nX 			as numeric
	Local nValVALIPI	as numeric
	Local nValVALICM 	as numeric
	Local nValVALISS 	as numeric
	Local nValICMSCOM	as numeric
	Local nValVALSOL	as numeric
	Local nSizeGrid		as numeric

	oModel	  	:= FwModelActive()
	oModelDHU 	:= oModel:GetModel('DHUMASTER')
	oModelSC8 	:= oModel:GetModel('SC8DETAIL')
	nSizeGrid	:= oModelSC8:Length()
	nValVALIPI	:= 0
	nValVALICM 	:= 0
	nValVALISS 	:= 0
	nValICMSCOM := 0
	nValVALSOL	:= 0
	nX			:= 0

	//Percorrer o grid e buscar os valores
	For nX := 1 to nSizeGrid

		oModelSC8:GoLine(nX)

		nValVALIPI	+= oModelSC8:GetValue('C8_VALIPI')
		nValVALICM 	+= oModelSC8:GetValue('C8_VALICM')
		nValVALISS 	+= oModelSC8:GetValue('C8_VALISS')
		nValICMSCOM	+= oModelSC8:GetValue('C8_ICMSCOM')
		nValVALSOL	+= oModelSC8:GetValue('C8_VALSOL')

	Next nX

	//Preencher no campo de totais
	oModelDHU:LoadValue('DHU_TOTIPI', nValVALIPI	)
	oModelDHU:LoadValue('DHU_TOTICM', nValVALICM	)
	oModelDHU:LoadValue('DHU_TOTISS', nValVALISS	)
	oModelDHU:LoadValue('DHU_TOTICO', nValICMSCOM	)
	oModelDHU:LoadValue('DHU_TOTISO', nValVALSOL	)

Return .T.


/*/{Protheus.doc} NF020MxProp
	Função para retornar o C8_SITUAC do campo, para exibir ou não a opção 8 no combo.
@author ali.neto
@since 01/2025
/*/
static function NF020MxProp()
	Local cQuery  	As character
	Local oQuery  	As object
	Local cAliasTmp As character
	Local lRet		as logical

	lRet := .F.

	cQuery := "SELECT C8_SITUAC "
	cQuery += "  FROM " + RetSQLName("SC8") + " SC8 "
	cQuery += "	WHERE SC8.C8_FILIAL = ? "
	cQuery += "	  AND SC8.C8_NUM = ? "
	cQuery += "	  AND SC8.C8_FORNECE = ? "
	cQuery += "	  AND SC8.C8_LOJA = ? "
	cQuery += "   AND SC8.C8_NUMPRO = ?"
	cQuery += "	  AND SC8.D_E_L_E_T_ = ' ' "

	oQuery := FWPreparedStatement():New(cQuery)
	oQuery:SetString(1, FWxFilial('SC8'))
	oQuery:SetString(2, _oJsonSup['quoteNumber'  ])
	oQuery:SetString(3, _oJsonSup['supplierCode' ])	
	oQuery:SetString(4, _oJsonSup['supplierStore'])
	oQuery:SetString(5, _oJsonSup['proposal'     ])

	cAliasTmp := GetNextAlias()
	cAliasTmp := MpSysOpenQuery(oQuery:getFixQuery(), cAliasTmp)
	if !(cAliasTmp)->(Eof())
		lRet := (cAliasTmp)->C8_SITUAC == '8'
	endif
	(cAliasTmp)->(DbCloseArea())
	oQuery:Destroy()
    FreeObj(oQuery)

return lRet


/*/{Protheus.doc} NF020MxProp
	Função para retornar o a descricao na moeda e setar no campo
@author ali.neto
@since 01/2025
/*/
Function NFCDescMoed()
	
	Local oModel 		as Object
	Local oModelDHU 	as Object
	
	Local nMoedaCot 	:= 1
	Local cDescMoed		:= ""

	oModel	  	:= FwModelActive()
	oModelDHU 	:= oModel:GetModel('DHUMASTER')
	
	nMoedaCot := val(oModelDHU:GetValue('CMOEDAPED'))
	cDescMoed := SuperGetMV("MV_MOEDA"+AllTrim(Str(nMoedaCot,2)), .F., "")
	
	If !Empty(cDescMoed)
		oModelDHU:LoadValue('CDESCMOED', cDescMoed)
	Else
		Help(nil, nil , STR0053, nil, STR0092, 1, 0, nil, nil, nil, nil, nil, {} ) //Atenção / "Moeda não localizada no cadastro MV_MOEDA".
		oModelDHU:LoadValue('CDESCMOED', "")
	EndIf

Return .T.


/*/{Protheus.doc} NF020TribGen
	Função que realiza o Load e atualiza o grid de Tributos genéricos
@author renan.martins
@param cTipo, character, Tipo de Load:
	"I" = Inclusão no array (load do model)
	"C" = Cálculo de Impostos
	"V" = Visualização apenas
@param oModel, object, modelo de dados.
@param oTribProcGen, object, json com os dados de impostos dos itens.
@return aLoadFil, array, array com os dados do load do grid.
@since 04/2025
/*/
static function NF020TribGen(cTipo, oModel)
	Local oView			:= FwViewActive()
	Local aLoadFil 		:= {}
	Local lChangeOrc	:= .T.
	Default cTipo		:= "V"
	Default oModel 		:= FwModelActive()

	lChangeOrc := cTipo != "I"

	if (_lTrbGen )
		aLoadFil := NF020ExbF2D(lChangeOrc, cTipo, oModel)
	endif
	
	NF020RfSC8(oView, "VIEW_F2D")

return aLoadFil


/*/{Protheus.doc} NF020F2DMD
	Função que realiza a montagem da struct dos dados da Model, para montar o grid de Tributos Genérico.
@author renan.martins
@return oStructMn, objeto, objeto com a struct dos dados da grid, para a Model.
@since 04/2025
/*/
static function NF020F2DMD()
	Local oStructMn	:= FWFormModelStruct():New()
	Local aSzBase	:= TamSX3("F2D_BASE")
	Local aSzAliq	:= TamSX3("F2D_ALIQ")
	Local aSzValr	:= TamSX3("F2D_VALOR")
	Local aSzFil	:= TamSX3("F2D_FILIAL")
	Local aSzTrib	:= TamSX3("F2D_TRIB")
	Local aSzDesc	:= TamSX3("F2B_DESC")
	
	oStructMn:AddField(STR0097, STR0097, 'FILIAL'  , 'C', aSzFil[1] , aSzFil[2] , , Nil, {}, .F., , .F., .F., .T.) //Filial
	oStructMn:AddField(STR0096, STR0096, 'CODTRIB' , 'C', aSzTrib[1], aSzTrib[2], , Nil, {}, .F., , .F., .F., .T.) //Código Tributo
	oStructMn:AddField(STR0024, STR0024, 'DESCIMP' , 'C', aSzDesc[1], aSzDesc[2], , Nil, {}, .F., , .F., .F., .T.) //Descrição
	oStructMn:AddField(STR0098, STR0098, 'BASEIMP' , 'N', aSzBase[1], aSzBase[2], , Nil, {}, .F., , .F., .F., .T.) //Base Imposto
	oStructMn:AddField(STR0099, STR0099, 'ALIQUOTA', 'N', aSzAliq[1], aSzAliq[2], , Nil, {}, .F., , .F., .F., .T.) //Alíquota
	oStructMn:AddField(STR0100, STR0100, 'VALORIMP', 'N', aSzValr[1], aSzValr[2], , Nil, {}, .F., , .F., .F., .T.) //Valor Imposto
	oStructMn:AddField(STR0101, STR0101, 'IMPRELAC', 'C', aSzDesc[1], aSzDesc[2], , Nil, {}, .F., , .F., .F., .T.) //Imposto relacionado
	NF020Clean( {aSzBase, aSzAliq, aSzValr, aSzFil, aSzTrib, aSzDesc} )
return oStructMn


/*/{Protheus.doc} NF020F2DVW
	Função que realiza a montagem da struct dos dados da View, para montar o grid de Tributos Genérico.
@author renan.martins
@return oStructMn, objeto, objeto com a struct dos dados da grid, para a View.
@since 04/2025
/*/
static function NF020F2DVW()
	Local oStructMn	:= FWFormViewStruct():New()
	oStructMn:AddField('CODTRIB' , '01', STR0096, STR0096,, 'C' , PesqPict("F2D","F2D_TRIB") , , , .F., , , , , , .T., , ) //Código Tributo
	oStructMn:AddField('DESCIMP' , '02', STR0024, STR0024,, 'C' , PesqPict("F2B","F2B_DESC") , , , .F., , , , , , .T., , ) //Descrição
	oStructMn:AddField('BASEIMP' , '03', STR0098, STR0098,, 'N' , PesqPict("F2D","F2D_BASE") , , , .F., , , , , , .T., , ) //Base Imposto
	oStructMn:AddField('ALIQUOTA', '04', STR0099, STR0099,, 'N' , PesqPict("F2D","F2D_ALIQ") , , , .F., , , , , , .T., , ) //Alíquota
	oStructMn:AddField('VALORIMP', '05', STR0100, STR0100,, 'N' , PesqPict("F2D","F2D_VALOR"), , , .F., , , , , , .T., , ) //Valor Imposto
	oStructMn:AddField('IMPRELAC', '06', STR0101, STR0101,, 'C' , PesqPict("F2B","F2B_DESC") , , , .F., , , , , , .T., , ) //Imposto relacionado
return oStructMn


/*/{Protheus.doc} NF020HashImp
	Função que realiza a chamada da TCIWritten, para carregar os tributos genéricos relacionados.
	Além disso, salva o array dos resultados em um objeto Json, para funcionar como hashmap, para carregar a cada mudança de linha no grid,
	sem chamar novamente a função TCIWritten, somente quando for recálculo de impostos.
@author renan.martins
@param cNumIDTrib, character, código do ID de tributos genérico (C8_IDTRIB relaciona com F2D_IDREL)
@param cTipo, character, tipo de operação
	"I" = Inclusão no array (load do model)
	"C" = Cálculo de Impostos
	"V" = Visualização apenas
@return aLoadFil, array, array com os dados de tributos genéricos, para a montagem do grid.
@since 04/2025
/*/
static function NF020HashImp(cNumIDTrib, cTipo)
	Local nFor 			:= 0
	Local aDadosRet		:= {}
	Local cCodeImp		:= ""
	Local cNameImp		:= ""
	Local nBaseIMP		:= ""
	Local nAliquota		:= ""
	Local nValTrib		:= ""
	Local cTrbRel		:= ""
	Local cFilTrib		:= ""
	Local cRetorno		:= ""
	Local oTributos		:= nil
	Local oDadosFin		:= nil
	Local oJsonImp		:= JsonObject():New()
	Local aDadJson		:= {}
	Default cNumIDTrib	:= ""
	Default cTipo		:= "V"
	
	if _oHashTCI[cNumIDTrib] != Nil	.and. cTipo != "C"
		aDadosRet := aClone(_oHashTCI[cNumIDTrib])
	
	else
		oDadosFin := totvs.protheus.backoffice.fiscal.tciclass.TCIWritten():New()
		oDadosFin:SetId({cNumIDTrib})
		cRetorno := oDadosFin:GetDataId()
		oJsonImp:FromJson(cRetorno)

		if oJsonImp:HasProperty("dados_Id")
			if ( !(oJsonImp:HasProperty("Aviso")) .and. !(oJsonImp["dados_Id"][cNumIDTrib]:HasProperty("Aviso")) )
				aDadJson := oJsonImp["dados_Id"][cNumIDTrib]:GetNames()

				for nFor := 1 to Len(aDadJson)
					cCodeImp	:= aDadJson[nFor]
					oTributos 	:= oJsonImp["dados_Id"][cNumIDTrib][cCodeImp]
					cFilTrib 	:= oTributos["filial"]
					nAliquota 	:= oTributos["aliquota_tributo"]
					nBaseIMP 	:= oTributos["base_tributo"]
					cNameImp 	:= oTributos["tributo"]
					nValTrib 	:= oTributos["valor_tributo"]
					cTrbRel  	:= oTributos["descricao_tributo_relacionado"]

					aAdd(aDadosRet, {cFilTrib, cCodeImp, cNameImp, nBaseIMP, nAliquota, nValTrib, cTrbRel})
				next

				_oHashTCI[cNumIDTrib] := aClone(aDadosRet)
			endif
		endif
	endif

	NF020Clean( {aDadJson}, {oTributos, oJsonImp, oDadosFin})

return aDadosRet


/*/{Protheus.doc} NF020HsMem
	Função que armazena o retorno da private oTribGen (que contêm os dados de impostos do Configurador, obtidos em tempo de execução da classe TCIProcess, no MATA150),
	em um objeto JSON, como hashmap, para exibir os valores, conforme se move no grid de itens.
@author renan.martins
@param cTipo, character, tipo de operação
	"I" = Inclusão no array (load do model)
	"C" = Cálculo de Impostos
	"V" = Visualização apenas
@param oTribGen, object, objeto array JSON, private com os dados obtidos no cálculo de impsotos pelo configurador, no MATA150
@param cCodItemHs, character, código do sequencial do item, quando desejamos pesquisar o valor do imposto no JSON de pesquisa.
@return aDadosRet, array, array com os dados de tributos genéricos, para a montagem do grid.
@since 08/2025
/*/
static function NF020HsMem(cTipo, oTribGen, cCodItemHs)
	Local aDadJson		:= {}
	Local aDadosRet		:= {}
	Local cCodeImp		:= ""
	Local cNameImp		:= ""
	Local cNumItem		:= ""
	Local cFilialSC8	:= FWxFilial("SC8")
	Local cSeqItem		:= ""
	Local nFor 			:= 0
	Local nFor2			:= 0
	Local nBaseIMP		:= ""
	Local nAliquota		:= ""
	Local nValTrib		:= ""
	Local oTributos		:= nil
	Local oModel		:= FwModelActive()
	Local oModelSC8 	:= oModel:GetModel('SC8DETAIL')
	Local oModelDHU 	:= oModel:GetModel('DHUMASTER')
	Local nLenGridSC8	:= oModelSC8:Length()
	Local aTotCBSIBS	:= {0, 0, 0} //Municipal / Estadual / Federal
	Default cTipo		:= "V"
	Default cCodItemHs	:= ""
	Default oTribGen	:= Nil
	
	if ( cTipo != "C" .AND. !empty(cCodItemHs))
		if ( _oHashTCI[cCodItemHs] != Nil )
			aDadosRet := aClone(_oHashTCI[cCodItemHs])
		endif
	
	elseif ( oTribGen != Nil )

		for nFor := 1 to nLenGridSC8
			oModelSC8:GoLine(nFor)
			cSeqItem := oModelSC8:GetValue("C8_ITEM")
			cNumItem := cValtoChar(nFor)
			aDadosRet := {}

			if oTribGen[nFor]:HasProperty(cNumItem)
				
				if ( !(oTribGen[nFor][cNumItem]:HasProperty("Aviso")) ) //verifica se tem ou não impostos do configurador
					aDadJson := oTribGen[nFor][cNumItem]:GetNames()

					For nFor2 := 1 to len(aDadJson)
						cCodeImp	:= aDadJson[nFor2]
						oTributos 	:= oTribGen[nFor][cNumItem][cCodeImp]
						nAliquota 	:= oTributos["aliq_trib"]
						nBaseIMP 	:= oTributos["base_trib"]
						cNameImp 	:= oTributos["desc_trib"]
						nValTrib 	:= oTributos["val_trib"]

						aAdd(aDadosRet, {cFilialSC8, cCodeImp, cNameImp, nBaseIMP, nAliquota, nValTrib, cNameImp})

						//Parte que verifico o IBS Estadual, Municipal, e CBS Federal
						if ( Alltrim(oTributos["ident_trib"]) == _cRegIBSMun)
							aTotCBSIBS[1] += nValTrib
						elseif ( Alltrim(oTributos["ident_trib"]) == _cRegIBSEst)
							aTotCBSIBS[2] += nValTrib
						elseif ( Alltrim(oTributos["ident_trib"]) == _cRegCBSFed)
							aTotCBSIBS[3] += nValTrib
						endif
					next
				else
					aAdd(aDadosRet, {cFilialSC8, "", "", 0, 0, 0, ""})
				endif

				_oHashTCI[cSeqItem] := aClone(aDadosRet)
			endif
		next
		oModelSC8:SetLine(1) //retorna o grid para o primeiro item
		NF020TribGen("V", oModel) //Forço a atualização do grid F2D
		oModelDHU:LoadValue("DHU_IBSMUN", aTotCBSIBS[1])
		oModelDHU:LoadValue("DHU_IBSEST", aTotCBSIBS[2])
		oModelDHU:LoadValue("DHU_CBSFED", aTotCBSIBS[3])
	endif

	NF020Clean({aDadJson, aTotCBSIBS}, {oTributos, oTribGen})
	
return aDadosRet


/*/{Protheus.doc} NF020ExbF2D
	Função que centraliza a exibição dos dados no grid de Impostos Genéricos (IMPETRBB), limpando e adicionando dados, conforme item selecionado no grid de itens.  armazena o retorno da private oTribGen (que contêm os dados de impostos do Configurador, obtidos em tempo de execução da classe TCIProcess, no MATA150),
@author renan.martins
@param lChangeOrc, logical, se trata de uma inclusão -no array da F2D, quando o form é aberto pela primeira vez ao alterar.
@param cTipo, character, tipo da operação
	"I" = Inclusão no array (load do model)
	"C" = Cálculo de Impostos
	"V" = Visualização apenas
@param oModel, object, oModel do modelo de dados.
@return aLoadFil, array, array com os dados de tributos genéricos, para a montagem do grid.
@since 08/2025
/*/
static function NF020ExbF2D(lChangeOrc, cTipo, oModel)
	Local aLoadFil 		:= {}
	Local aDadJson 		:= {}
	Local nFor 			:= 1
	Local oObjSC8		:= Nil
	Local oObjF2D		:= Nil
	Local cNumIDTrib	:= ""
	Default lChangeOrc	:= .T.
	Default cTipo		:= "V"
	Default oModel 		:= FwModelActive()

	oObjSC8 	:= oModel:GetModel("SC8DETAIL")
	oObjF2D 	:= oModel:GetModel("IMPETRB")
	cNumIDTrib	:= oObjSC8:GetValue("C8_IDTRIB")

	if ( !_lRecalcTrib .And. !empty(cNumIDTrib) )
		aDadJson := NF020HashImp(cNumIDTrib, cTipo)
	elseif ( lChangeOrc .AND. _oHashTCI != Nil )
		aDadJson := NF020HsMem("V", Nil, oObjSC8:GetValue("C8_ITEM"))
	endif

	if (lChangeOrc) //Se for após atualização de impostos, habilitar inserção e deleção de linhas no grid IMPETRB
		oObjF2D:SetNoDeleteLine(.F.)
		oObjF2D:SetNoInsertLine(.F.)
		oObjF2D:clearData()
	endif

	for nFor := 1 to Len(aDadJson)
		if (!lChangeOrc)
			//Se estou abrindo a rotina, tenho que carregar o bloco do array com os dados
			aAdd(aLoadFil,{0, {aDadJson[nFor][1], aDadJson[nFor][2], aDadJson[nFor][3], aDadJson[nFor][4], aDadJson[nFor][5], aDadJson[nFor][6], aDadJson[nFor][7]}})
		else
			//Se já estou em tela, tenho que preencher os campos do model
			if nFor != 1
				oObjF2D:AddLine()
			endif
			oObjF2D:LoadValue('CODTRIB' , aDadJson[nFor][2])
			oObjF2D:LoadValue('DESCIMP' , aDadJson[nFor][3])
			oObjF2D:LoadValue('BASEIMP' , aDadJson[nFor][4])
			oObjF2D:LoadValue('ALIQUOTA', aDadJson[nFor][5])
			oObjF2D:LoadValue('VALORIMP', aDadJson[nFor][6]) 
			oObjF2D:LoadValue('IMPRELAC', aDadJson[nFor][7])
		endif
	next

	if (lChangeOrc) //Após atualização de impostos, desabilitar a inserção e deleção de linhas no grid IMPETRB
		oObjF2D:GoLine(1)
		oObjF2D:SetNoDeleteLine(.T.)
		oObjF2D:SetNoInsertLine(.T.)
	endif

	if (empty(aLoadFil))
		aAdd(aLoadFil,{0, {'', '', '', 0, 0, 0, ''}})
	endif
	NF020Clean( {aDadJson} )
return aLoadFil


/*/{Protheus.doc} NF020Clean
	Função que centraliza a limpeza de arrays e objetos, para diminuir a verbosidade de FwFreeArray e FwFreeObj
@author renan.martins
@param aArrays, Array, arrays que devem ser tratados
@param aObjects, Array, Objetos que devm ser tratados
@return nil, nil, nulo
@since 08/2025
/*/
static function NF020Clean(aArrays, aObjects)
	Local nFor 			:= 1
	Default aArrays		:= {}
	Default aObjects	:= {}

	For nFor := 1 to len(aArrays)
		FwFreeArray(aArrays[nFor])
	next

	For nFor := 1 to len(aObjects)
		FWFreeObj(aObjects[nFor])
	next
return nil


/*/{Protheus.doc} NF020LCBSIBS
	Função que carrega os valors dos impostos CBS e IBS MUnicipal e Estadual, para exibir na abertura do form, e salvar os dados no hash.
@author renan.martins
@param oModel, object, Modelo de dados
@return Nil, nil, nulo.
@since 08/2025
/*/
static function NF020LCBSIBS(oModel)
	Local aDadJson		:= {}
	Local aDadosRet		:= {}
	Local aTotCBSIBS	:= {0, 0, 0} // Municipal / Estadual / Federal
	Local cCodeImp		:= ""
	Local cNameImp		:= ""
	Local cNumIDTrib	:= ""
	Local cRetorno		:= ""
	Local nFor 			:= 0
	Local nBaseIMP		:= ""
	Local nAliquota		:= ""
	Local nValTrib		:= ""
	Local nLenGridSC8	:= 0
	Local nForJson		:= 0
	Local oTributos		:= Nil
	Local oModelSC8 	:= Nil
	Local oModelDHU 	:= Nil
	Local oGenTax		:= Nil
	Local oJsonImp      := JsonObject():New()
	Default oModel		:= FwModelActive()

	oModelSC8 	:= oModel:GetModel('SC8DETAIL')
	oModelDHU 	:= oModel:GetModel('DHUMASTER')
	nLenGridSC8	:= oModelSC8:Length()
	oGenTax 	:= backoffice.com.generictaxes.generictaxes():New()
	
	For nFor := 1 to nLenGridSC8
		oModelSC8:GoLine(nFor)
		cNumIDTrib 	:= oModelSC8:GetValue("C8_IDTRIB")
		aDadosRet 	:= {}
		
		if !empty(cNumIDTrib)
			cRetorno := oGenTax:getTaxesWritten(cNumIDTrib)

			oJsonImp:FromJson(cRetorno)

			if oJsonImp:HasProperty("dados_Id")
				if ( !(oJsonImp:HasProperty("Aviso")) .and. !(oJsonImp["dados_Id"][cNumIDTrib]:HasProperty("Aviso")) )	
					aDadJson := oJsonImp["dados_Id"][cNumIDTrib]:GetNames()

					For nForJson := 1 to Len(aDadJson)
						cCodeImp	:= aDadJson[nForJson]
						oTributos 	:= oJsonImp["dados_Id"][cNumIDTrib][cCodeImp]
						cFilTrib 	:= oTributos["filial"]
						nAliquota 	:= oTributos["aliquota_tributo"]
						nBaseIMP 	:= oTributos["base_tributo"]
						cNameImp 	:= oTributos["tributo"]
						nValTrib 	:= oTributos["valor_tributo"]
						cTrbRel  	:= oTributos["descricao_tributo_relacionado"]

						aAdd(aDadosRet, {cFilTrib, cCodeImp, cNameImp, nBaseIMP, nAliquota, nValTrib, cTrbRel})

						//Parte que verifico o IBS Estadual, Municipal, e CBS Federal
						if ( Alltrim(oTributos["codigo_tributo_relacionado"]) == _cRegIBSMun)
							aTotCBSIBS[1] += nValTrib
						elseif ( Alltrim(oTributos["codigo_tributo_relacionado"]) == _cRegIBSEst)
							aTotCBSIBS[2] += nValTrib
						elseif ( Alltrim(oTributos["codigo_tributo_relacionado"]) == _cRegCBSFed)
							aTotCBSIBS[3] += nValTrib
						endif
					next nForJson++
				endif
			endif

			_oHashTCI[cNumIDTrib] := aClone(aDadosRet)
		endif

	Next nFor++
			
	oModelDHU:LoadValue("DHU_IBSMUN", aTotCBSIBS[1])
	oModelDHU:LoadValue("DHU_IBSEST", aTotCBSIBS[2])
	oModelDHU:LoadValue("DHU_CBSFED", aTotCBSIBS[3])
	
	NF020Clean({aDadJson, aDadosRet, aTotCBSIBS}, {oTributos, oJsonImp, oGenTax})
	
return Nil


/*/{Protheus.doc} NF020PDesc
	Função que retorna a descrição do produto para o campo C8_ZXDESCR.
@author juan.felipe
@return cRet, character, descrição do produto.
@since 10/2025
/*/
Function NF020PDesc()
	Local cRet As Character
	Local lNFCDesc As Logical
	
	lNFCDesc := FindFunction('NFCProdDesc')

	cRet := Iif(!lNFCDesc, GetAdvFVal("SB1","B1_DESC",fwxFilial("SB1") + if(empty(SC8->C8_PRODUTO),fwfldget("C8_PRODUTO"),SC8->C8_PRODUTO),1), '')

	If lNFCDesc
		cRet := NFCProdDesc(if(empty(SC8->C8_PRODUTO),fwfldget("C8_PRODUTO"),SC8->C8_PRODUTO), if(empty(SC8->C8_NUMSC),fwfldget("C8_NUMSC"),SC8->C8_NUMSC), if(empty(SC8->C8_ITEMSC),fwfldget("C8_ITEMSC"),SC8->C8_ITEMSC))
	EndIf
Return cRet


/*/{Protheus.doc} NF020FDesc
	Função que retorna o campo de descrição do produto, conforme configuração do MV_NFCDESC.
@author juan.felipe
@return cRet, character, descrição do produto.
@since 10/2025
/*/
Function NF020FDesc()
	Local cOption As Character
	Local cField As Character

	cOption := SuperGetMv("MV_NFCDESC", .F., '')
	cField := 'B1_DESC'

	If cOption == '2'
		cField := 'B5_CEME'
	ElseIf cOption == '3' .Or. Empty(cOption)
		cField := 'C1_DESCRI'
	EndIf
Return cField
