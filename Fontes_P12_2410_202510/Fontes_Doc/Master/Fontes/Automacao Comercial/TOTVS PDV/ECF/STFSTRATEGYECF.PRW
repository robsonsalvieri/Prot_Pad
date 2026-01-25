#INCLUDE "PROTHEUS.CH"


//-------------------------------------------------------------------
/*{Protheus.doc} STFStrategyECF
Funcao de Configuracao do ECF (Strategy)
@param 
@author  Varejo
@version P11.8
@since   29/03/2012
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------
Function STFStrategyECF()


STFAddEventHandler("*", "STSendSupl", ;
					{|cFunName, cEventName, uData| STWSendSupl( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STCheckPaper", ;
					{|cFunName, cEventName, uData| STWCheckPaper( uData[1] ) })

STFAddEventHandler("*", "STCheckDLL", ;
					{|cFunName, cEventName, uData| STWCheckDLL( uData[1] ) })
					
STFAddEventHandler("*", "STCloseCom", ;
					{|cFunName, cEventName, uData| STWCloseCom( uData[1] ) })
					                                       
STFAddEventHandler("*", "STListPrint", ;
					{|cFunName, cEventName, uData| STWListPrint( @uData[1], uData[2] , uData[3] , uData[4] ) })

STFAddEventHandler("*", "STListINF", ;
					{|cFunName, cEventName, uData| STWListINF( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STReadingX", ;
					{|cFunName, cEventName, uData| STWReadingX() })
					
STFAddEventHandler("*", "STReductZ", ;
					{|cFunName, cEventName, uData| STWReductZ( @uData[1] ) })
					
STFAddEventHandler("*", "STDadoReductZ", ;
					{|cFunName, cEventName, uData| STWDadoReductZ( @uData[1] ) })
					
					
STFAddEventHandler("*", "STOpenReceipt", ;			// Abertura de cupom
					{|cFunName, cEventName, uData| STWOpenReceipt( @uData[1] ,uData[2] ,uData[3] ,@uData[4],;
																	uData[5],uData[6] ) })
					
STFAddEventHandler("*", "STGetReceipt", ;
					{|cFunName, cEventName, uData| STWGetReceipt( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STGetSerie", ;
					{|cFunName, cEventName, uData| STWGetSerie( @uData[1] ) })
					
STFAddEventHandler("*", "STGetPDV", ;
					{|cFunName, cEventName, uData| STWGetPDV( @uData[1] ) })
					
STFAddEventHandler("*", "STItemReg", ;   			// Registro de item
					{|cFunName, cEventName, uData| STWRegItem( uData[1], uData[2], uData[3], uData[4],;
															 	uData[5], uData[6], uData[7], uData[8],;
															 	uData[9]) })
					
STFAddEventHandler("*", "STGetAliq", ;
					{|cFunName, cEventName, uData| STWGetAliq( @uData[1] ) })
				     	
STFAddEventHandler("*", "STGetAliIss", ;
					{|cFunName, cEventName, uData| STWISSGetAli( @uData[1] ) })
					
STFAddEventHandler("*", "STGetConPay", ;
					{|cFunName, cEventName, uData| STWGetConPay( @uData[1] ) })
					
STFAddEventHandler("*", "STRecCondPay", ;
					{|cFunName, cEventName, uData| STWRecCondPay( uData[1] ) })
					
STFAddEventHandler("*", "STCancelItem", ;        	// Cancelar item
					{|cFunName, cEventName, uData| STWCancelItem( uData[1], uData[2], uData[3],uData[4],;
															       uData[5], uData[6],uData[7], uData[8],;
															       uData[9] ) })
															       					
STFAddEventHandler("*", "STCancelReceipt", ;
					{|cFunName, cEventName, uData| STWCancReceipt( uData[1] ) })

STFAddEventHandler("*", "STCancelBound", ;
					{|cFunName, cEventName, uData| STWCancelBound( uData[1], uData[2], uData[3], uData[4], uData[5] ) })
					
STFAddEventHandler("*", "STCloseReceipt", ;
					{|cFunName, cEventName, uData| STWCloseReceipt( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STPayment", ;
					{|cFunName, cEventName, uData| STWPayment( uData[1], uData[2], uData[3], uData[4],;
															    uData[5], uData[6] ) })
					
STFAddEventHandler("*", "STDescTot", ;
					{|cFunName, cEventName, uData| STWDescTot( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STPrintIncrease", ;
					{|cFunName, cEventName, uData| STWAddTot( uData[1] ) })
					
STFAddEventHandler("*", "STMemFisc", ;
					{|cFunName, cEventName, uData| STWMemFisc( uData[1], uData[2], uData[3],uData[4],;
															    uData[5] ) })
					
STFAddEventHandler("*", "STAddAliq", ;
					{|cFunName, cEventName, uData| STWAddAliq( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STOpenNotFiscalReceipt", ;
					{|cFunName, cEventName, uData| STWOpenNotFiscalReceipt( uData[1], uData[2], uData[3],uData[4],;
																		     uData[5] ) })
					
STFAddEventHandler("*", "STTxtNotFiscalReceipt", ;
					{|cFunName, cEventName, uData| STWTxtNotFiscalReceipt( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STCloseNotFiscalReceipt", ;
					{|cFunName, cEventName, uData| STWCloseNotFiscalReceipt() })
					
STFAddEventHandler("*", "STPrinterStatus", ;
					{|cFunName, cEventName, uData| STWPrinterStatus( uData[1], @uData[2] ) })
					
STFAddEventHandler("*", "STNotFiscalTotal", ;
					{|cFunName, cEventName, uData| STWNotFiscalTotal( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STAutentic", ;
					{|cFunName, cEventName, uData| STWAutentic( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STDrawer", ;
						{|cFunName, cEventName, uData| STWDrawer() })
										
STFAddEventHandler("*", "STOpenECF", ;
					{|cFunName, cEventName, uData| STWOpenECF() })
					
STFAddEventHandler("*", "STCloseECF", ;
					{|cFunName, cEventName, uData| STWCloseECF(uData[1]) })
					
STFAddEventHandler("*", "STSupply", ;
					{|cFunName, cEventName, uData| STWSupply( uData[1], uData[2], uData[3],;
															 uData[4], uData[5], uData[6] ) })
					
STFAddEventHandler("*", "STHourSummerAdjust", ;
					{|cFunName, cEventName, uData| STWHourSummerAdjust( uData[1] ) })
					
STFAddEventHandler("*", "STManagReportPrint", ;
					{|cFunName, cEventName, uData| STWManagReportPrint( uData[1], uData[2]) })
					
STFAddEventHandler("*", "STSubTotalReceipt", ;
					{|cFunName, cEventName, uData| STWSubTotalReceipt( @uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STNumItemPrint", ;
					{|cFunName, cEventName, uData| STWNumItemPrint( @uData[1] ) })
					
STFAddEventHandler("*", "STEmulEcf", ;
					{|cFunName, cEventName, uData| STWEmulEcf( uData[1], uData[2], uData[3], uData[4] ) })
					
STFAddEventHandler("*", "STSalesOrder", ;
					{|cFunName, cEventName, uData| STWSalesOrder( uData[1], uData[2], uData[3], uData[4] ) })
					
STFAddEventHandler("*", "STReceiveNotFiscal", ;
					{|cFunName, cEventName, uData| STWReceiveNotFiscal( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STDownMFD", ;
					{|cFunName, cEventName, uData| STWDownMFD( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STExecHsr", ;
					{|cFunName, cEventName, uData| STWExecHsr( uData[1],uData[2]) })
					
STFAddEventHandler("*", "STPinPadList", ;
					{|cFunName, cEventName, uData| STWListPinPad( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STPinPadOpen", ;
					{|cFunName, cEventName, uData| STWPinPadOpen( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STPinPadLeC", ;
					{|cFunName, cEventName, uData| STWLeCPinPad( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STPinPadLeS", ;
					{|cFunName, cEventName, uData| STWPinsSPadLeS( uData[1], uData[2], uData[3], uData[4], uData[5] ) })
					
STFAddEventHandler("*", "STPinPadFin", ;
					{|cFunName, cEventName, uData| STWPinPadFin( uData[1] ) })
					
STFAddEventHandler("*", "STCMC7List", ;
					{|cFunName, cEventName, uData| STWCMC7List( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STCMC7Open", ;
					{|cFunName, cEventName, uData| STWCMC7Open( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STCMC7Close", ;
					{|cFunName, cEventName, uData| STWCMC7Close( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STCMC7DRead", ;
					{|cFunName, cEventName, uData| STWCMC7DRead( uData[1], @uData[2] ) })     
					
STFAddEventHandler("*", "STCMC7DCRead", ;
					{|cFunName, cEventName, uData| STWCMC7DCRead( uData[1], @uData[2] ) })
					
STFAddEventHandler("*", "STDrawerList", ;
					{|cFunName, cEventName, uData| STWDrawerList( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDrawerOpen", ;
					{|cFunName, cEventName, uData| STWDrawerOpen( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STDrawerClose", ;
					{|cFunName, cEventName, uData| STWDrawerClose( uData[1], uData[2], uData[3] ) })       


STFAddEventHandler("*", "STOpDrawer", ;
					{|cFunName, cEventName, uData| STWOpDrawer(  ) })       

					
STFAddEventHandler("*", "STDrawerAci", ;
					{|cFunName, cEventName, uData| STWDrawerAci( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDrawerStatus", ;
					{|cFunName, cEventName, uData| STWDrawerStatus( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STListReceiptPrinters", ;
					{|cFunName, cEventName, uData| STWListReceiptPrinters( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STPrintOpenCommunicationReceipt", ;
					{|cFunName, cEventName, uData| STWPrintOpenCommunicationReceipt( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STPrintCloseCommunicationReceipt", ;
					{|cFunName, cEventName, uData| STWPrintCloseCommunicationReceipt( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STPrintNotFiscalReceipt", ;
					{|cFunName, cEventName, uData| STWPrintNotFiscalReceipt( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STReaderList", ;
					{|cFunName, cEventName, uData| STWReaderList( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STReaderOpen", ;
					{|cFunName, cEventName, uData| STWReaderOpen( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STReaderClose(", ;
					{|cFunName, cEventName, uData| STWReaderClose( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STReaderFocus", ;
					{|cFunName, cEventName, uData| STWReaderFocus( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STBalanceList", ;
					{|cFunName, cEventName, uData| STWBlacList( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STBalanceOpen", ;
					{|cFunName, cEventName, uData| STWBlacOpen( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STBalanceClose", ;
					{|cFunName, cEventName, uData| STWBlacClose( uData[1] ) })
					
STFAddEventHandler("*", "STBalanceGet", ;
					{|cFunName, cEventName, uData| STWBlacGet( @uData[1] ) })
					
STFAddEventHandler("*", "STDisplayList", ;
					{|cFunName, cEventName, uData| STWDisplayList( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDisplayOpen", ;
					{|cFunName, cEventName, uData| STWOpenDisplay( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDisplayClose", ;
					{|cFunName, cEventName, uData| STWCloseDisplay( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDisplayEnv", ;
					{|cFunName, cEventName, uData| STWEnvDisplay( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STMsgDisplay", ;
					{|cFunName, cEventName, uData| STWMsgDisplay( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STCHOpen", ;
					{|cFunName, cEventName, uData| STWCHOpen( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STCHPrints", ;
					{|cFunName, cEventName, uData| STWCHPrints(	uData[1], uData[2], uData[3], uData[4],;
																uData[5], uData[6], uData[7], uData[8],;
														        uData[9] ) })
					
STFAddEventHandler("*", "STChPrinTrans", ;
					{|cFunName, cEventName, uData| STWChTransPrin( uData[1], uData[2], uData[3], uData[4],;
																    uData[5], uData[6], uData[7] ) })
					
STFAddEventHandler("*", "STCHClose", ;
					{|cFunName, cEventName, uData| STWCHClose( uData[1] ) })
					
STFAddEventHandler("*", "STCHList", ;
					{|cFunName, cEventName, uData| STWCHList( @uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDLLVersionControl", ;
					{|cFunName, cEventName, uData| STWDLLVersionControl( uData[1], uData[2]) })
					
STFAddEventHandler("*", "STSelectCountryDevice", ;
					{|cFunName, cEventName, uData| STWSelectCountryDevice( @uData[1], uData[2]) })
					
STFAddEventHandler("*", "STExecDLLRet", ;
					{|cFunName, cEventName, uData| STWExecDLLRet( uData[1], uData[2], @uData[3] ) })
					
STFAddEventHandler("*", "STCodSitef", ;
					{|cFunName, cEventName, uData| STWCodSitef( uData[1] ) })
					
STFAddEventHandler("*", "STDescSitef", ;
					{|cFunName, cEventName, uData| STWDescSitef( uData[1] ) })
					
STFAddEventHandler("*", "STPerceptArg", ;
					{|cFunName, cEventName, uData| STWPerceptArg( uData[1], uData[2], uData[3], uData[4] ) })
					
STFAddEventHandler("*", "STOpenDNFH", ;
					{|cFunName, cEventName, uData| STWOpenDNFH( uData[1], uData[2], uData[3], uData[4],;
															 @uData[5], uData[6], uData[7] ) })
					
STFAddEventHandler("*", "STCloseDNFH", ;
					{|cFunName, cEventName, uData| STWCloseDNFH( @uData[1] ) })
					
STFAddEventHandler("*", "STReprintsLastDocArg", ;
					{|cFunName, cEventName, uData| STWReprintsLastDocArg() })
					
STFAddEventHandler("*", "STPrintLinesReceiptsArg", ;
					{|cFunName, cEventName, uData| STWPrintLinesReceiptsArg( uData[1], @uData[2] ) })
					
STFAddEventHandler("*", "STCapacityArg", ;
					{|cFunName, cEventName, uData| STWCapacityArg( @uData[1] ) })
					
STFAddEventHandler("*", "STOpenDebitNote", ;
					{|cFunName, cEventName, uData| STWOpenDebitNote( @uData[1] ) })
					
STFAddEventHandler("*", "STRestauOpenReceipt", ;
					{|cFunName, cEventName, uData| STWRestauOpenReceipt( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STRestauRegIt", ;
					{|cFunName, cEventName, uData| STWRestauRegIt( uData[1], uData[2], uData[3], uData[4],;
																uData[5], uData[6], uData[7], uData[8]) })
					
STFAddEventHandler("*", "STRestauCancIt", ;
					{|cFunName, cEventName, uData| STWRestauCancIt( uData[1], uData[2], uData[3], uData[4],;
																  uData[5], uData[6], uData[7], uData[8]) })
					
STFAddEventHandler("*", "STRestauConfM", ;
					{|cFunName, cEventName, uData| STWConfMRestau( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STRestauPrintCdp", ;
					{|cFunName, cEventName, uData| STWRestauPrintCdp() })
					
STFAddEventHandler("*", "STRestauGetCdp", ;
					{|cFunName, cEventName, uData| STWRestauGetCdp() })
					
STFAddEventHandler("*", "STRestauGetTable", ;
					{|cFunName, cEventName, uData| STWGetTableRestau( @uData[1]) })
					
STFAddEventHandler("*", "STRestauRepMont(", ;
					{|cFunName, cEventName, uData| STWRepMontRestau( uData[1]) })
					
STFAddEventHandler("*", "STRestauLeRegSal", ;
					{|cFunName, cEventName, uData| STWRestauLeRegSal( uData[1]) })
					
STFAddEventHandler("*", "STRestauCloseReceipt", ;
					{|cFunName, cEventName, uData| STWReceiptRestauClose( uData[1], uData[2], uData[3], uData[4]) })
					
STFAddEventHandler("*", "STRestauFCDiv", ;
					{|cFunName, cEventName, uData| STWRestauFCDiv( uData[1], uData[2], uData[3], uData[4],;
																 uData[5], uData[6] ) })
					
STFAddEventHandler("*", "STRestauTrfTable", ;
					{|cFunName, cEventName, uData| STWRestauTrfTable( uData[1], uData[2], uData[3] ) })
					
STFAddEventHandler("*", "STRestauTrfItem", ;
					{|cFunName, cEventName, uData| STWTrfItemRestau( uData[1], uData[2], uData[3], uData[4],;
																   uData[5], uData[6], uData[7], uData[8],;
																   uData[9]) })
					
STFAddEventHandler("*", "STGerRegTypE", ;
					{|cFunName, cEventName, uData| STWGerRegTypE( uData[1], uData[2], uData[3], uData[4] ) })
					
STFAddEventHandler("*", "STMsgDll", ;
					{|cFunName, cEventName, uData| STWMsgDll( uData[1], uData[2]) })
					
STFAddEventHandler("*", "STJoinList", ;
					{|cFunName, cEventName, uData| STWJoinList( uData[1], uData[2], uData[3]) })
					
STFAddEventHandler("*", "STChkAutocom", ;
					{|cFunName, cEventName, uData| STWChkAutocom() })
					
STFAddEventHandler("*", "STIsAutocom", ;
					{|cFunName, cEventName, uData| STWIsAutocom( uData[1], uData[1]) })
					
STFAddEventHandler("*", "STChkDataMov", ;
					{|cFunName, cEventName, uData| STWChkDataMov() })
					
STFAddEventHandler("*", "STEcfIFDate", ;
					{|cFunName, cEventName, uData| STWEcfIFDate( uData[1], uData[2], uData[3], uData[4],;
															   uData[5] ) })
					
STFAddEventHandler("*", "STDispTorList", ;
					{|cFunName, cEventName, uData| STWDispTorList( @uData[1] ) })
					
STFAddEventHandler("*", "STDispTorOpen", ;
					{|cFunName, cEventName, uData| STWOpeDispTor( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDispTorClose", ;
					{|cFunName, cEventName, uData| STWClosDispTor( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STDispTorEnv", ;
					{|cFunName, cEventName, uData| STWTorEnvDisp( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STMsgDispTor", ;
					{|cFunName, cEventName, uData| STWTorMsgDisp( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STEcfIFCNPJ", ;
					{|cFunName, cEventName, uData| STWEcfIFCNPJ() })
					
STFAddEventHandler("*", "STExistEquip", ;
					{|cFunName, cEventName, uData| STWExistEquip( uData[1], uData[2], @uData[3]) })
					
STFAddEventHandler("*", "STTreatStatus", ;
					{|cFunName, cEventName, uData| STWTreatStatus( uData[1], uData[2], @uData[3]) })
					
STFAddEventHandler("*", "STLoadForm", ;
					{|cFunName, cEventName, uData| STWLoadForm( uData[1] ) })
					
STFAddEventHandler("*", "STTratRedZ", ;
					{|cFunName, cEventName, uData| STWTratRedZ( uData[1] ) })
					
STFAddEventHandler("*", "STPrepReport", ;
					{|cFunName, cEventName, uData| STWPrepReport( uData[1], uData[2]) })
					
STFAddEventHandler("*", "STDscTotaliz", ;
					{|cFunName, cEventName, uData| STWDscTotaliz( uData[1] ) })
					
STFAddEventHandler("*", "STPrepMsgPro", ;
					{|cFunName, cEventName, uData| STWPrepMsgPro( uData[1] ) })
					
STFAddEventHandler("*", "STPrepSupSan", ;
					{|cFunName, cEventName, uData| STWPrepSupSan( uData[1], uData[2]) })
					
STFAddEventHandler("*", "STTreatRet", ;
					{|cFunName, cEventName, uData| STWTreatRet( uData[1], @uData[2]) })
					
STFAddEventHandler("*", "STTreatMd5", ;
					{|cFunName, cEventName, uData| STWTreatMd5() })
					
STFAddEventHandler("*", "STTreatRetMd5", ;
					{|cFunName, cEventName, uData| STWMd5TreatRet() })
					
STFAddEventHandler("*", "STVldEcfPtg", ;
					{|cFunName, cEventName, uData| STWVldEcfPtg( @uData[1] ) })
					
STFAddEventHandler("*", "STTrtStaPtg", ;
					{|cFunName, cEventName, uData| STWTrtStaPtg( uData[1], @uData[2],uData[3] ) })
					
STFAddEventHandler("*", "STOpenPrintCommunication", ;
					{|cFunName, cEventName, uData| STWOpenPrintCommunication( uData[1], uData[2] ) })
					
STFAddEventHandler("*", "STPrintTextNotFiscal", ;
					{|cFunName, cEventName, uData| STWPrintTextNotFiscal( uData[1]) })
					
STFAddEventHandler("*", "STCMC7Direct", ;
					{|cFunName, cEventName, uData| STWCMC7Direct() })
					
STFAddEventHandler("*", "STVldCMC7Dir", ;
					{|cFunName, cEventName, uData| STWVldCMC7Dir( uData[1], uData[2]) })
					
STFAddEventHandler("*", "STComCMC7D", ;
					{|cFunName, cEventName, uData| STWComCMC7D() })   
					
STFAddEventHandler("*", "STReadCmc7", ;
					{|cFunName, cEventName, uData| STWReadCmc7(uData[1]) })					
					
					
STFAddEventHandler("*", "STArqMFD", ;
					{|cFunName, cEventName, uData| STWArqMFD( uData[1], uData[2], uData[3], uData[4],;
															uData[5], uData[6], uData[7], uData[8]) })
															
STFAddEventHandler("*", "STOpenCom", ;
					{|cFunName, cEventName, uData| STWOpenCom(uData[1], uData[2], uData[3]) })
					
STFAddEventHandler("*", "STCheckUse", ;
					{|cFunName, cEventName, uData| STWCheckUse() })
					
STFAddEventHandler("*", "STCMC7Use", ;
					{|cFunName, cEventName, uData| STWCMC7Use() })
					
STFAddEventHandler("*", "STBalanceUse", ;
					{|cFunName, cEventName, uData| STWBlacUse() })	  
					
					
STFAddEventHandler("*", "STReleaseObj", ;
					{|cFunName, cEventName, uData| STWReleaseObj() })		  
					
								
STFAddEventHandler("*", "STGrvMdz", ;
					{|cFunName, cEventName, uData| STDGrvMdz( uData[1], uData[2], uData[3], uData[4],;
															uData[5] ) }) 
															
STFAddEventHandler("*", "STCheckDate", ;
					{|cFunName, cEventName, uData| STWCheckDate( ) })  
					
STFAddEventHandler("*", "STIsTaxPrinter", ;	
					{|cFunName, cEventName, uData| STWIsTaxPrinter() })  
					
STFAddEventHandler("*", "STRecSerie", ;	
					{|cFunName, cEventName, uData| STWRecSerie() }) 	


STFAddEventHandler("*", "STValSerie", ;	
					{|cFunName, cEventName, uData| STWValSerie() }) 	  
					
STFAddEventHandler("*", "STCheckHour", ;	
					{|cFunName, cEventName, uData| STWCheckHour() }) 				
					
STFAddEventHandler("*", "STChkSerie", ;	
					{|cFunName, cEventName, uData| STWChkSerie() })  
					
STFAddEventHandler("*", "STChkRptP", ;	
					{|cFunName, cEventName, uData| STWChkRptP() })	  
					
STFAddEventHandler("*", "STRetTypePrt", ;	
					{|cFunName, cEventName, uData| STWRetTypePrt(@uData[1]) })
									
STFAddEventHandler("*", "STGetNotFiscalTotal", ;
					{|cFunName, cEventName, uData| STWGetNFiscTotal( @uData[1] ) })	 
					
STFAddEventHandler("*", "STListPrintCod", ;
					{|cFunName, cEventName, uData| STWListCodPrint( @uData[1], uData[2] ) })																																						

STFAddEventHandler("*", "STSystemDirectory", ;
					{|cFunName, cEventName, uData| STWSystemDirectory( @uData[1]) })    
					
STFAddEventHandler("*", "STChkZReduction", ;
					{|cFunName, cEventName, uData| STWChkZReduction(@uData[1]) })  
					
STFAddEventHandler("*", "STMenuFiscReport", ;
					{|cFunName, cEventName, uData| STWMenuFiscReport( uData[1], uData[2], uData[3]) })	 
										
STFAddEventHandler("*", "STDownMF", ;
					{|cFunName, cEventName, uData| STWDownMF( uData[1], uData[2], uData[3] ) })	 
					
STFAddEventHandler("*", "STSetAliq", ;
					{|cFunName, cEventName, uData| STWSetAliq(uData[1], @uData[2] ) })			
					
					
STFAddEventHandler("*", "STSetInfoCNPJ", ;
					{|cFunName, cEventName, uData| STWSetInfoCNPJ(uData[1]) })

STFAddEventHandler("*", "STPrntBarCode", ;
					{|cFunName, cEventName, uData| STWPrntBarCode(uData[1], uData[2], uData[3], uData[4]) })						

STFAddEventHandler("*", "STRedZData", ;
					{|cFunName, cEventName, uData| STWRedZDat( @uData[1]  ) })						
					
STFAddEventHandler("*", "STCripArq", ;
					{|cFunName, cEventName, uData| STWCripArq() })

STFAddEventHandler("*", "STIdCliente", ;			//Identificacao do cliente
					{|cFunName, cEventName, uData| STWIdCliente( @uData[1] , @uData[2] ) })
Return Nil
