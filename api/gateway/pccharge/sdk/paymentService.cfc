<cfcomponent displayname="paymentService" hint="I wrap PCCharge processing">
	
	<cffunction name="init" access="public" output="false" returntype="paymentService">
	
		<cfscript>
		/*var rslt = doVoidPostAuth(
				ticket = "",
				transactionID = ""
				);*/
		/*	var rslt = doPreAuth(
				member = "TEST USER",
				card = "4111111111111111",
				ExpDate = "1208",
				ticket = "",
				amount = "1.00",
				street = "123 Any Street.",
				zip = "90000",
				CVV2 = "999"
			);*/
		//trace(rslt, "init.rslt");
		</cfscript>

		<cfreturn THIS />
	</cffunction>

	<cffunction name="doSale" access="public" returntype="any">
		<cfargument name="member" type="string" required="yes"/>
		<cfargument name="card" type="string" required="yes"/>
		<cfargument name="ExpDate" type="string" required="yes"/>
		<cfargument name="ticket" type="string" required="yes"/>
		<cfargument name="amount" type="string" required="yes"/>
		<cfargument name="street" type="string" required="yes"/>
		<cfargument name="zip" type="string" required="yes"/>
		<cfargument name="CVV2" type="string" required="yes"/>

		<cfset structInsert(arguments, "action", 1, "yes")/>

		<cfreturn doTransaction(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="doCredit" access="public" returntype="any">
		<cfargument name="ticket" type="string" required="yes"/>
		<cfargument name="card" type="string" required="yes"/>
		<cfargument name="ExpDate" type="string" required="yes"/>
		<cfargument name="amount" type="string" required="yes"/>
		<cfargument name="transactionID" type="string" required="yes"/>

		<cfset structInsert(arguments, "action", 2, "yes")/>

		<cfreturn doTransaction(argumentCollection = arguments)/>
	</cffunction>
	
	<cffunction name="doVoidSale" access="public" returntype="any">
		<cfargument name="ticket" type="string" required="yes"/>
		<cfargument name="transactionID" type="string" required="yes"/>

		<cfset structInsert(arguments, "action", 3, "yes")/>

		<cfreturn doTransaction(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="doPreAuth" access="public" returntype="any">
		<cfargument name="ticket" type="string" required="yes"/>
		<cfargument name="member" type="string" required="yes"/>
		<cfargument name="card" type="string" required="yes"/>
		<cfargument name="ExpDate" type="string" required="yes"/>
		<cfargument name="CVV2" type="string" required="yes"/>
		<cfargument name="amount" type="string" required="yes"/>
		<cfargument name="street" type="string" required="yes"/>
		<cfargument name="zip" type="string" required="yes"/>

		<cfset structInsert(arguments, "action", 4, "yes")/>

		<cfreturn doTransaction(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="doPostAuth" access="public" returntype="any">
		<cfargument name="ticket" type="string" required="yes"/>
		<cfargument name="amount" type="string" required="no"/>
		<cfargument name="transactionID" type="string" required="yes"/>

		<cfset structInsert(arguments, "action", 5, "yes")/>

		<cfreturn doTransaction(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="doVoidPostAuth" access="public" returntype="any">
		<!---<cfargument name="card" type="string" required="yes"/>--->
		<!---<cfargument name="ExpDate" type="string" required="yes"/>--->
		<cfargument name="ticket" type="string" required="yes"/>
		<cfargument name="transactionID" type="string" required="yes"/>
		<!---<cfargument name="AuthCode" type="string" required="yes"/>--->

		<cfset structInsert(arguments, "action", 7, "yes")/>

		<cfreturn doTransaction(argumentCollection = arguments)/>
	</cffunction>

	<cffunction name="doReport" access="public" returntype="any">
		<cfargument name="action" type="string" required="yes" default="83" /><!---Batch Post-Settle report--->

		<cfargument name="startDate" type="string" required="no" />
		<cfargument name="endDate" type="string" required="no" />

		<!---<cfset structInsert(arguments, "action", arguments.action, "yes") /> what was this about?--->

		<cfreturn doTransaction(argumentCollection = arguments) />
	</cffunction>

	<cffunction name="doTransaction" access="public" returntype="any">
		<cfargument name="action" type="numeric" required="yes"/>
		<cfargument name="member" type="string" required="yes" default=""/>
		<cfargument name="card" type="string" required="yes" default=""/>
		<cfargument name="ExpDate" type="string" required="yes" default=""/>
		<cfargument name="CVV2" type="string" required="yes" default=""/>
		<cfargument name="amount" type="string" required="yes" default=""/>
		<cfargument name="street" type="string" required="yes" default=""/>
		<cfargument name="zip" type="string" required="yes" default=""/>
		<cfargument name="ticket" type="string" required="yes" default=""/>
		<cfargument name="transactionID" type="string" required="yes" default=""/>
		<cfargument name="AuthCode" type="string" required="yes" default=""/>
		
		<cfargument name="startDate" type="string" required="no" default=""/>
		<cfargument name="endDate" type="string" required="no" default=""/>
					
		<cfargument name="CommMethod" required="yes" default="1"/><!--- [0|1] File Based, TCP/IP--->
		<cfargument name="Path" required="yes" default="C:\Program Files\Active-Charge\"><!--- Path for file-based communication --->
		<cfargument name="IPAddress" required="yes" default="127.0.0.1"/><!--- PC Charge server IP --->
		<cfargument name="Port" required="yes" default="31419"/><!--- PC Charge server port --->
		<cfargument name="EnableSSL" required="yes" default="false"/><!--- PC Charge connection type (only false supported at this time)--->
		<cfargument name="LastValidDate" required="yes" default="20"/><!--- The last year that will be considered a valid expiration date. If LastValidDate is set to 05, then cards between 06 and 99 are considered to be 1906 to 1999, and cards between 00 and 05 are 2000 to 2005.--->

		<cfargument name="Processor" required="yes" default="NOVA"/>
		<cfargument name="MerchantNumber" required="yes" default="99988836"/><!--- 0008014285590000 <<< ATA ---><!---TEST:99988836--->
		<cfargument name="User" required="yes" default="User1"/>
		
		<cfscript>
			//Create the object 
			var Charge1 = createObject("com", "PSCharge.Charge");
			//Create and Initialize return variables
			var response = structNew();
			//var AuthCode = "";
			var Reference = "";
			//var TransactionID = "";
			var AVS = "";
			//var CVV2 = "";
			var doProcess = true;
			var logMessage = "";
			var reportName = "Report";

			// cleanup inputs
			Arguments.User = Trim(Right(Arguments.User, 8));
			
			Arguments.ExpDate = REReplace(Arguments.ExpDate, "[^0-9]", "", "ALL");
			Arguments.Street = left(trim(Arguments.Street), 20);
			Arguments.Zip = left(REReplace(Arguments.Zip, "[^0-9]", "", "all"), 9);
			
			Arguments.Amount = "1.00"; // FOR TESTING! comment out for live.
			
			if (NOT LEN(Arguments.CVV2))
				Arguments.CVV2 = 0; //0 – Deliberated bypassed, 2 – CVV value illegible, 9 – Card has no CVV value
			
			response.Result 	   = "";
			response.AuthCode    = "";
			response.Reference   = "";
			response.TransactionID	= "";
			response.AVS 	  	   = "";
			response.CVV2        = "";
			response.ChargeError = "TAG NOT CALLED";
			response.ChargeErrorCode = "";
		</cfscript>

		<cftry>
			<cflock type="exclusive" name="PCChargeProcessing" timeout="120"><!--- Ensure Single Instance --->
				<!---<CF_GOCharge
					Processor 		= "NOVA"
					MerchantNumber 	= "99988836"
					User 			= "User1"
					Action			= "#arguments.Action#"
					Card 			= "#arguments.Card#"
					CVV2        	= "#arguments.CVV2#"
					ExpDate 		= "#arguments.ExpDate#"
					Amount 			= "#arguments.amount#"
					Member 			= "#arguments.member#"
					Street 			= "#arguments.street#"
					Zip 			= "#arguments.zip#"
					Ticket 			= "#arguments.ticket#"
					TroutD 			= "#arguments.TransactionID#"
					AuthCode 			= "#arguments.AuthCode#"
				>--->
				
				<cfscript>
					//Perform some cleanup
					Charge1.DeleteUserFiles();
					Charge1.Clear();
					
					//Then, use the form variables from the user entry form to populate a number of properties necessary to create and send the transaction. 
					Charge1.Timeout       = 10;
					Charge1.XMLTrans      = True;
					
					Charge1.CommMethod     = Arguments.CommMethod;
					Charge1.Path           = Arguments.Path;
					Charge1.IPAddress      = Arguments.IPAddress;
					Charge1.Port           = Arguments.Port;
					Charge1.EnableSSL      = Arguments.EnableSSL;
					Charge1.LastValidDate  = Arguments.LastValidDate;
					
					Charge1.User           = Arguments.User;
					Charge1.Action         = Arguments.Action;   //1=Sale, 2=Credit, 3=Void, 4 = Pre-Auth, 5 = Post-Auth, etc. See DevKit Constants section of Chapter 2 in the DevKit Manual 

					switch(Arguments.Action) {
						case "1": //Sale
							Charge1.Processor      = Arguments.Processor;
							Charge1.MerchantNumber = Arguments.MerchantNumber;

							Charge1.CheckCard 	= True;
							Charge1.Card    	= "#Arguments.Card#"; //"F...
							//Charge1.Card 	= #REReplace(Arguments.Card,"","","ALL")# //uncomment if you are using CF 4.0 or earlier and will allow "forced" transactions 
							//Charge1.Card 	= #REReplace(Arguments.Card,"[^0-9]","","ALL")# //uncomment if you are using CF 4.0 or earlier and will not allow "forced" transactions 
							Charge1.ExpDate 	= Arguments.ExpDate;
							Charge1.Amount 		= numberFormat(Arguments.Amount, ".00"); //"1.00"; //
							Charge1.Member 		= Arguments.Member;
							Charge1.Street 		= Arguments.Street;
							Charge1.Zip 		= Arguments.Zip;
							Charge1.Ticket 		= Arguments.Ticket;
							Charge1.CVV2      	= Arguments.CVV2;
							break;
				
						case "2": //Credit
							Charge1.Processor      = Arguments.Processor;
							Charge1.MerchantNumber = Arguments.MerchantNumber;

							Charge1.Ticket		= Arguments.Ticket;
							Charge1.Member		= Arguments.Member;
							Charge1.Card		= "#Arguments.Card#"; //"F...
							Charge1.ExpDate		= Arguments.ExpDate;
							Charge1.Amount		= numberFormat(Arguments.Amount, ".00"); //"2.00";"1.00"; //
							Charge1.TroutD		= Arguments.TransactionID; //TroutD; // Transaction Routing ID for follow-on transaction
							break;
				
						case "3": // Void Sale
							Charge1.Processor      = Arguments.Processor;
							Charge1.MerchantNumber = Arguments.MerchantNumber;

							Charge1.Ticket			= Arguments.Ticket;
							Charge1.TroutD			= Arguments.TransactionID; //TroutD; // Transaction Routing ID for follow-on transaction
							break;
				
						case "4": //Pre-Auth
							Charge1.Processor      = Arguments.Processor;
							Charge1.MerchantNumber = Arguments.MerchantNumber;

							Charge1.CheckCard = True;
							Charge1.Card      = "#Arguments.Card#"; //"F...
							//Charge1.Card      = #REReplace(Arguments.Card,"","","ALL")# //uncomment if you are using CF 4.0 or earlier and will allow "forced" transactions 
							//Charge1.Card      = #REReplace(Arguments.Card,"[^0-9]","","ALL")# //uncomment if you are using CF 4.0 or earlier and will not allow "forced" transactions 
							Charge1.ExpDate   = Arguments.ExpDate;
							Charge1.Amount    = numberFormat(Arguments.Amount, ".00"); //"1.00"; //
							Charge1.Member    = Arguments.Member;
							Charge1.Street    = Arguments.Street;
							Charge1.Zip       = Arguments.Zip;
							Charge1.Ticket    = Arguments.Ticket;
							Charge1.CVV2      = Arguments.CVV2;
							break;
				
						case "5": // Post-Auth
							Charge1.Processor      = Arguments.Processor;
							Charge1.MerchantNumber = Arguments.MerchantNumber;

							Charge1.Amount    = numberFormat(Arguments.Amount, ".00"); //"1.00"; //
							Charge1.Ticket    = Arguments.Ticket;
							Charge1.TroutD    = Arguments.TransactionID; //TroutD; // Transaction Routing ID for follow-on transaction
							break;
				
						case "7": //Void Post-Authorization
							//Charge1.Card    	= "#Arguments.Card#"; //"F...
							//Charge1.AuthCode = Arguments.AuthCode;

							Charge1.Processor      = Arguments.Processor;
							Charge1.MerchantNumber = Arguments.MerchantNumber;

							Charge1.Ticket    = Arguments.Ticket;
							Charge1.TroutD		= Arguments.TransactionID; //TroutD; // Transaction Routing ID for follow-on transaction
							trace(Arguments.TransactionID, "case=7");
							break;
				
						case "81": case "82": case "83": case "84": // Reports 81,82,83,84
							switch(Arguments.Action) {
								case "81":
									reportName = "CreditCardDetailReport";
								break;
								case "82":
									reportName = "BatchPreSettleReport";
								break;
								case "83":
									reportName = "BatchPostSettleReport";
								break;
								case "84":
									reportName = "CheckSummaryReport";
								break;
							}

							//Charge1.Processor      = Arguments.Processor;
							//Charge1.MerchantNumber = Arguments.MerchantNumber;

							Charge1.CheckCard = False;
							Charge1.PeriodicPayment = "1"; // Write to file
							//Charge1.Timeout = 30;
							Charge1.Track = "c:\webroot\ATA\data\Reports\";
							//Charge1.TransID = "#reportName#_#dateFormat(now(), "YYYYMMDD")#.PDF";
							Charge1.TransID = "#reportName#_#dateFormat(arguments.startDate, "MM-DD-YYYY")#-to-#dateFormat(arguments.endDate, "YYYY-MM-DD")#.pdf"; //"rpt.pdf"; //
							if (structKeyExists(arguments, "startDate") and isDate(arguments.startDate))
								Charge1.Street = "#dateFormat(arguments.startDate, "MM/DD/YYYY")# #timeFormat(arguments.startDate, "hh:mm:ss tt")#"; //"01/01/08 12:00:00 AM"; // Starting Date / Time Filter
							if (structKeyExists(arguments, "endDate") and isDate(arguments.endDate))
								Charge1.Member = "#dateFormat(arguments.endDate, "MM/DD/YYYY")# #timeFormat(arguments.endDate, "hh:mm:ss tt")#";//"12/19/08 11:59:59 PM"; // Ending Date / Time Filter
							Charge1.Manual = "0"; // Transaction Result Filter: 0 = all (default); 1 = approved; 2 = declined
							doProcess = true;
							break;
				
						default:
							doProcess = false;
							break;
					}
					
					trace(Charge1.Card, "Charge1.Card");
					//Check for valid input data 
					/*if (listFind("1,4", Arguments.Action)) { // Only Sale and Pre-Auth takes a card number.
						if (Charge1.VerifyCreditCard()) {
							response.ChargeErrorCode = Charge1.GetErrorCode();
							response.ChargeError = Charge1.GetErrorDesc();
							//doProcess = false;
						}
						else if (Charge1.VerifyExpDate()) {
							response.ChargeErrorCode = Charge1.GetErrorCode();
							response.ChargeError = Charge1.GetErrorDesc();
							//doProcess = false;
						}
					}
					if (listFind("1,2,4,5", Arguments.Action)) { // Only Sale, Credit, Pre-Auth, and Post-Auth take a total.
						if (Charge1.VerifyAmount()) {
							response.ChargeErrorCode = Charge1.GetErrorCode();
							response.ChargeError = Charge1.GetErrorDesc();
							//doProcess = false;
						}
					}*/

					// data validity checks
					response.doProcessError = "";

					if (listFind("1,2,4,5", Arguments.Action)) {
						if (NOT Charge1.VerifyAmount()) {
							doProcess = false;
							response.doProcessError &= "VerifyAmount,";
						}
					}

					if (listFind("1,2,4", Arguments.Action)) {
						if (NOT Charge1.VerifyCreditCard()) {
							doProcess = false;
							response.doProcessError &= "VerifyCreditCard,";						
						}
	
						if (NOT Charge1.VerifyExpDate()) {
							doProcess = false;
							response.doProcessError &= "VerifyExpDate,";
						}
					}

					if (Charge1.PccSysExists()){ // to make sure PCCharge is not in use doing something else
						doProcess = false;
						response.doProcessError &= "PccSysExists,";
					}

					response.doProcess = doProcess;
					
					if (doProcess)
						Charge1.Send();//Run the transaction

					trace(Charge1.GetTroutD(), "Charge1.TroutD");
				
					//Return the Error code and message (if any)
					response.ChargeErrorCode	= Charge1.GetErrorCode();
					response.ChargeError		= Charge1.GetErrorDesc();

					//Check the Results
					if (isNumeric(response.ChargeErrorCode) AND response.ChargeErrorCode EQ 0) {
						//If no error, then return the results.
						response.Result = Charge1.GetResult();
						response.AuthCode = Charge1.GetAuth();
						response.Reference = Charge1.GetRefNumber();
						response.TransactionID = Charge1.GetTroutD();
						response.AVS = Charge1.GetAVS();
						response.CVV2 = Charge1.GetCVV2();
						response.TBatch = Charge1.GetTBatch();
					}

					// additional
					response.GetErrorCode = Charge1.GetErrorCode();
						//response.GetXMLRequest = Charge1.GetXMLRequest();
					response.GetXMLResponse = Charge1.GetXMLResponse();
					//response.GetParseData = Charge1.GetParseData();
					
					response.GetTDate = Charge1.GetTDate();
					response.GetTicket = Charge1.GetTicket();
					response.GetTIM = Charge1.GetTIM();
					response.GetCaptured = Charge1.GetCaptured();
					response.GetTICode = Charge1.GetTICode();
					response.GetTransNum = Charge1.GetTransNum();
					
					response.TransID = Charge1.TransID;
					response.Track = Charge1.Track;
					response.Street = Charge1.Street;
					response.Member = Charge1.Member;
					
					response.GetTBatch = Charge1.GetTBatch();
					//response.GetHostType = Charge1.GetHostType();
					
					response.arguments = arguments; //for debugging
					//response.Charge1 = Charge1; //Pass the object back up for debugging - disable for production

					//Perform some cleanup
					Charge1.DeleteUserFiles();
					Charge1.Clear();
					Charge1 = "";
				</cfscript>
			</cflock>

			<cfcatch type="any">
				<cfset response.ChargeErrorCode = "-999"/>
				<cfset response.ChargeError = "Error Calling Processing Tag."/>
				<cfrethrow />
			</cfcatch>
		</cftry>
		
		<cfmail from="jonah@creori.com" to="jonah@creori.com" subject="CCPROC" type="html">
			<cfset logMessage = duplicate(response)/>
			<cfset logMessage.arguments.card = right(logMessage.arguments.card, 4)/>
			<cfset structDelete(logMessage.arguments, "CVV2")/>
			<cfset structDelete(logMessage.arguments, "merchantnumber")/>
			<cfdump var="#logMessage#" label="response"/>
		</cfmail>

		<cfreturn response />
	</cffunction>
	
	
	<cffunction name="trace" output="true" access="public" hint="Script version of CF tag: CFTRACE">
		<cfargument name="variable" required="no" default="" />
		<cfargument name="text" required="no" default="" />
		<cfif isDebugMode()>
			<cfif NOT isSimpleValue(arguments.variable)>
				<cfsavecontent variable="arguments.variable">
					<cfdump var="#arguments.variable#" label="#arguments.text#" />
				</cfsavecontent>
			</cfif>
			<cftrace var="arguments.variable" text="#arguments.text#" />
		</cfif>
	</cffunction>

</cfcomponent>
