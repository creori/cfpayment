<!---

	Copyright 2008-2009 Jonah Blossom (http://www.creori.com/)
	
	Licensed under the Apache License, Version 2.0 (the "License"); you 
	may not use this file except in compliance with the License. You may 
	obtain a copy of the License at:
	 
		http://www.apache.org/licenses/LICENSE-2.0
		 
	Unless required by applicable law or agreed to in writing, software 
	distributed under the License is distributed on an "AS IS" BASIS, 
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
	See the License for the specific language governing permissions and 
	limitations under the License.
--->
<cfcomponent displayname="PCCharge Gateway Interface" extends="cfpayment.api.gateway.base" hint="VeriFone PCCharge Gateway - communicates using VeriFone's PSCharge.Charge COM object." output="false">

	<cfscript>
		//structInsert(variables, "pccharge", structNew(), "yes");
		
		variables.cfpayment.GATEWAY_NAME = "PCCharge";
		variables.cfpayment.GATEWAY_VERSION = "1.0";

		// Assume some logical defaults.
		variables.cfpayment.GATEWAY_ComObjectName = "PSCharge.Charge"; // Name if the COM Object to connect to.
		variables.cfpayment.GATEWAY_CommMethod = "1"; // [0|1] File Based, TCP/IP
		variables.cfpayment.GATEWAY_Path = "C:\Program Files\Active-Charge\"; // Path for file-based communication
		variables.cfpayment.GATEWAY_IPAddress = "127.0.0.1"; // PC Charge server IP
		variables.cfpayment.GATEWAY_Port = "31419"; // PC Charge server port
		variables.cfpayment.GATEWAY_EnableSSL = "false"; // PC Charge connection type (only false supported at this time)
		variables.cfpayment.GATEWAY_LastValidDate = "20"; // The last year that will be considered a valid expiration date. If LastValidDate is set to 05, then cards between 06 and 99 are considered to be 1906 to 1999, and cards between 00 and 05 are 2000 to 2005.
		variables.cfpayment.GATEWAY_Timeout = "20";
														  
		variables.cfpayment.GATEWAY_TEST_Processor = "NOVA"; // Test/Default processor.
		variables.cfpayment.GATEWAY_LIVE_Processor = "";

		variables.cfpayment.GATEWAY_TEST_MerchantAccount = "99988836"; // Test account number.
		variables.cfpayment.GATEWAY_LIVE_MerchantAccount = "";
		
		variables.cfpayment.GATEWAY_User = "User1"; // Required value - leave it at the default unless you need to change it.

		addResponseReasonCodes(); // Sets up the response code lookup struct.
	</cfscript>

	<cffunction name="process" output="false" access="private" returntype="any" hint="PCCharge payment process - not HTTP, does not use super.process()">
		<cfargument name="payload" type="struct" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />

		<!---<cfargument name="action" type="numeric" required="yes"/>
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

		<cfargument name="startDate" type="string" required="no" default="" hint="Start date for Report Period" />
		<cfargument name="endDate" type="string" required="no" default="" hint="End date for Report Period"/>
		var reportName = "Report";--->

		<cfscript>
			// var for COM object 
			var Charge1 = "";

			var timeout = getTimeout();

			var results = structNew(); // populated with response fields pulled from the API COM object then added to the cfcharge response objects.
			
			var response = getService().createResponse();
			
			var logMessage = "";
			var itm = "";
			
			var p = arguments.payload;
			var o = arguments.options;

			if (structKeyExists(p, "cvv2") AND NOT structKeyExists(p, "cvv"))
				p.cvv = p.cvv2;

			if (NOT structKeyExists(p, "cvv") OR NOT LEN(p.cvv))
				p.cvv = 0; //0 – Deliberated bypassed, 2 – CVV value illegible, 9 – Card has no CVV value

			// add in any optional data
			structAppend(p, o, true);

			if (getTestMode())
				p.amount = "1.00"; // PCCharge only wants transactions of $1.00 for testing.
				
			if (structKeyExists(p, "amount"))
				p.amount = numberFormat(p.amount, ".00");

			if (NOT structKeyExists(p, "orderId"))
				p.orderId = "";
			
			if (listFindNoCase("81,82,83,84", p.type))
				timeout = timeout * 4;
			
			response.setRequestData(duplicate(p));
			
			response.setTest(getTestMode());
			
			results.doProcess = true;
			results.Result = "";
			results.AuthCode = "";
			results.Reference = "";
			results.TransactionID = "";
			results.AVS = "";
			results.CVV = "";
			results.ChargeError = "TAG NOT CALLED";
			results.ChargeErrorCode = "";
		</cfscript>

		<cftry>
			<cfsetting requesttimeout="#timeout + 15#" /><!--- enable a little extra time past the lock timeout so error handlers can run --->
			<cflock type="exclusive" name="PCChargeProcessing" timeout="#timeout + 10#"><!--- Ensure Single Instance --->
				<cfscript>
					response.setStatus(getService().getStatusPending()); // Change status to pending
				
					// Create COM Object
					Charge1 = createObject("com", getComObjectName());

					// Perform some cleanup
					Charge1.DeleteUserFiles();
					Charge1.Clear();
					
					// Then, use the form variables from the user entry form to populate a number of properties necessary to create and send the transaction. 
					Charge1.Timeout       = timeout;
					Charge1.XMLTrans      = True;
					
					Charge1.CommMethod    = getCommMethod();
					Charge1.Path          = getPath();
					Charge1.IPAddress     = getIPAddress();
					Charge1.Port          = getPort();
					Charge1.EnableSSL     = getEnableSSL();
					Charge1.LastValidDate = getLastValidDate();
					
					Charge1.Processor      = getProcessor();
					Charge1.MerchantNumber = getMerchantAccount();
					
					Charge1.User          = getGatewayUser();
					
					// 1=Sale, 2=Credit, 3=Void, 4=Pre-Auth, 5=Post-Auth, etc.
					// See DevKit Constants section of Chapter 2 in the DevKit Manual 
					Charge1.Action        = p.type;

					switch(p.type) {
						case "1": { //Sale
							Charge1.CheckCard 	= True;
							Charge1.Ticket 		= p.orderId;
							Charge1.Member 		= p.firstname & " " & p.lastname;
							Charge1.Street 		= p.address1;
							Charge1.Zip 		= p.zip;
							
							Charge1.Amount 		= p.amount;
							
							Charge1.Card    	= p.ccnumber; //"F...
							//Charge1.Card 	= #REReplace(Arguments.Card,"","","ALL")# //uncomment if you are using CF 4.0 or earlier and will allow "forced" transactions 
							//Charge1.Card 	= #REReplace(Arguments.Card,"[^0-9]","","ALL")# //uncomment if you are using CF 4.0 or earlier and will not allow "forced" transactions 
							Charge1.ExpDate 	= p.ccexp;
							Charge1.CVV2      	= p.cvv;
							break;
						}
						case "2": { //Credit
							Charge1.Ticket 		= p.orderId;
							Charge1.Member 		= p.firstname & " " & p.lastname;
							Charge1.Card    	= p.ccnumber; //"F...
							Charge1.ExpDate		= p.ccexp;
							Charge1.Amount 		= p.amount;
							Charge1.TroutD		= p.TransactionID; // Transaction Routing ID for follow-on transaction
							break;
						}
						case "3": { // Void Sale
							Charge1.Ticket 			= p.orderId;
							Charge1.TroutD			= p.TransactionID; // Transaction Routing ID for follow-on transaction
							break;
						}
						case "4": { //Pre-Auth
							Charge1.CheckCard 	= True;
							Charge1.Card    	= p.ccnumber;
							Charge1.ExpDate 	= p.ccexp;
							Charge1.CVV2      	= p.cvv;

							Charge1.Amount 		= p.amount;

							Charge1.Ticket 		= p.orderId;
							Charge1.Member 		= p.firstname & " " & p.lastname;
							Charge1.Street 		= p.address1;
							Charge1.Zip 		= p.zip;
							break;
						}
						case "5": { // Post-Auth
							Charge1.Amount 			= p.amount;
							Charge1.Ticket 			= p.orderId;
							Charge1.TroutD			= p.TransactionID; // Transaction Routing ID for follow-on transaction
							break;
						}
						case "7": { //Void Post-Authorization
							Charge1.Ticket 			= p.orderId;
							Charge1.TroutD			= p.TransactionID; // Transaction Routing ID for follow-on transaction
							//trace(p.TransactionID, "case=7");
							break;
						}
						case "81": case "82": case "83": case "84": {// Reports
							if (structKeyExists(p, "reportStartDate") and isDate(p.reportStartDate))
								p.reportName = p.reportName & "_from_#dateFormat(p.reportStartDate, "MM-DD-YYYY")#";
							if (structKeyExists(p, "reportEndDate") and isDate(p.reportEndDate))
								p.reportName = p.reportName & "_to_#dateFormat(p.reportEndDate, "MM-DD-YYYY")#";

							Charge1.CheckCard = False;
							Charge1.PeriodicPayment = "1"; // Write to file

							Charge1.Track = left(p.reportFilePath, 40);
							if (len(p.reportFilePath) GT 40)
								Charge1.CustCode = mid(p.reportFilePath, 41, 25); // Split the output path field if necessary.

							Charge1.TransID = "#p.reportName#.#p.reportFileFormat#";
							if (structKeyExists(p, "reportStartDate") and isDate(p.reportStartDate))
								Charge1.Street = "#dateFormat(p.reportStartDate, "MM/DD/YYYY")# #timeFormat(p.reportStartDate, "hh:mm:ss tt")#"; // Format "01/01/08 12:00:00 AM"
							if (structKeyExists(p, "reportEndDate") and isDate(p.reportEndDate))
								Charge1.Member = "#dateFormat(p.reportEndDate, "MM/DD/YYYY")# #timeFormat(p.reportEndDate, "hh:mm:ss tt")#"; // Format "12/19/08 11:59:59 PM";
							Charge1.Manual = o.transactionFilter; // Transaction Result Filter: 0 = all (default); 1 = approved; 2 = declined
							results.doProcess = true;
							break;
						}
						default: {
							results.doProcess = false;
							break;
						}
					}

					// data validity checks
					results.doProcessError = "";

					if (listFind("1,2,4,5", p.type)) {
						if (NOT Charge1.VerifyAmount()) {
							results.doProcess = false;
							results.doProcessError = listAppend(results.doProcessError, "VerifyAmount");
						}
					}

					if (listFind("1,2,4", p.type)) {
						if (NOT Charge1.VerifyCreditCard()) {
							results.doProcess = false;
							results.doProcessError = listAppend(results.doProcessError, "VerifyCreditCard");
						}

						if (NOT Charge1.VerifyExpDate()) {
							results.doProcess = false;
							results.doProcessError = listAppend(results.doProcessError, "VerifyExpDate");
						}
					}

					if (Charge1.PccSysExists()) { // Make sure PCCharge is not in use doing something else.
						// The lock should take care of this, but maybe someone's using the console?
						results.doProcess = false;
						results.doProcessError = listAppend(results.doProcessError, "PccSysExists");
					}

					if (results.doProcess)
						Charge1.Send(); //Run the transaction
					else {
						response.setStatus(getService().getStatusUnprocessed()); //change status to un-processed.
						response.setMessage("Not Processed: #Charge1.GetErrorDesc()# [#Charge1.GetErrorCode()#]");
					}

					// Extract the error code and message (if any)
					results.ChargeErrorCode	= Charge1.GetErrorCode();
					results.ChargeError		= Charge1.GetErrorDesc();					

					// Extract some core transaction results
					results.Result = Charge1.GetResult();
					results.AuthCode = Charge1.GetAuth();
					results.Reference = Charge1.GetRefNumber();
					results.TransactionID = Charge1.GetTroutD();
					results.AVS = Charge1.GetAVS();
					results.CVV = Charge1.GetCVV2();
					results.TBatch = Charge1.GetTBatch();

					// Check the Results
					if (isNumeric(results.ChargeErrorCode) AND results.ChargeErrorCode EQ 0) { // Success response
						switch (results.AuthCode) {
							case "Duplicate Trans" : {
								response.setStatus(getService().getStatusFailure());
								response.setMessage(response.getMessage() & ": Duplicate Transaction");
								break;
							}
							case "INVALID CARD" : case "Invalid Card Num" : {
								response.setStatus(getService().getStatusFailure());
								response.setMessage(response.getMessage() & ": Invalid Card Number");
								break;
							}
							case "SERV NOT ALLOWED" : {
								response.setStatus(getService().getStatusFailure());
								response.setMessage(response.getMessage() & ": Service Not Allowed");
								break;
							}
							case "Invalid Data" : {
								response.setStatus(getService().getStatusFailure());
								response.setMessage(response.getMessage() & ": Invalid Data");
								break;
							}
							case "DECLINED" : {
								response.setStatus(getService().getStatusFailure());
								response.setMessage(response.getMessage() & ": Declined");
								break;
							}
							case "DECLINED CVV2" : {
								response.setStatus(getService().getStatusFailure());
								response.setMessage(response.getMessage() & ": Declined due to CVV");
								break;
							}
							default: {
								response.setStatus(getService().getStatusSuccessful());
								response.setMessage(response.getMessage());
								break;
							}
						
						}
					}
					else {
						response.setStatus(getService().getStatusFailure());
					}

					// handle common response fields
					if (structKeyExists(variables.pccharge, results.ChargeErrorCode) AND results.ChargeErrorCode NEQ 0)
						response.setMessage(variables.pccharge[results.ChargeErrorCode]);

					if (len(results.ChargeError))
						response.setMessage(response.getMessage() & ": " & results.ChargeError);

					response.setTransactionID(results.transactionid);
					response.setAuthorization(results.authcode);

					// handle common "success" fields
					response.setAVSCode(results.avs);
					response.setCVVCode(results.cvv);

					// Extract some additional (optional) informational fields 
					results.XMLresults = Charge1.GetXMLResponse();
					results.TDate = Charge1.GetTDate();
					results.Ticket = Charge1.GetTicket();
					results.TIM = Charge1.GetTIM();
					results.Captured = Charge1.GetCaptured();
					results.TICode = Charge1.GetTICode();
					results.TransNum = Charge1.GetTransNum();				
					results.TBatch = Charge1.GetTBatch();
					
					results.TransID = Charge1.TransID;
					results.Track = Charge1.Track; // For report file path response
					results.CustCode = Charge1.CustCode; // For report file path response
					results.Street = Charge1.Street;
					results.Member = Charge1.Member;	

					//results.arguments = arguments; //for debugging
					
					//Additionaly
					structInsert(results, "Additional", "Gateway=" & getGatewayName(), "yes");  // Reply with the gateway used.
					
					// Add the results to the response object
					//response.setResult(Charge1); // Pass the COM object back up if wanted for debugging - not necessary for production
					response.setParsedResult(results); // Struct of useful values
					
					// Perform some COM object cleanup
					Charge1.DeleteUserFiles();
					Charge1.Clear();
					Charge1 = "";
				</cfscript>
			</cflock>

			<cfcatch type="any">
				<cfset response.setStatus(getService().getStatusFailure()) />
				<cfset response.setMessage("Error Calling PCCharge COM Object.") />
				<cfrethrow />
			</cfcatch>
		</cftry>

		<cfreturn response />
	</cffunction>

	<!--- ------------------------------------------------------------------------------
		  PUBLIC METHODS
		  ------------------------------------------------------------------------- --->
	<cffunction name="purchase" output="false" access="public" returntype="any" hint="Authorize + Capture in one step">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />

		<cfset var post = structNew() />
		
		<!--- set general values --->
		<cfset post["amount"] = arguments.money.getAmount() />
		<cfset post["type"] = "1" /><!---sale--->

		<cfswitch expression="#lcase(listLast(getMetaData(arguments.account).fullname, "."))#">
			<cfcase value="creditcard">
				<!--- copy in name and customer details --->
				<cfset post = addCustomer(post = post, account = arguments.account) />
				<cfset post = addCreditCard(post = post, account = arguments.account, options = arguments.options) />
			</cfcase>
			<cfdefaultcase>
				<cfthrow type="cfpayment.InvalidAccount" message="The account type #lcase(listLast(getMetaData(arguments.account).fullname, "."))# is not supported by this gateway." />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn process(payload = post, options = arguments.options) />
	</cffunction>

	<cffunction name="authorize" output="false" access="public" returntype="any" hint="Authorize (only) a credit card">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<cfset var post = structNew() />
		
		<!--- set general values --->
		<cfset post["amount"] = arguments.money.getAmount() />
		<cfset post["type"] = "4" /><!---auth--->


		<cfswitch expression="#lcase(listLast(getMetaData(arguments.account).fullname, "."))#">
			<cfcase value="creditcard">
				<!--- copy in name and customer details --->
				<cfset post = addCustomer(post = post, account = arguments.account) />
				<cfset post = addCreditCard(post = post, account = arguments.account, options = arguments.options) />
			</cfcase>
			<cfdefaultcase>
				<cfthrow type="cfpayment.Invalid.AccountType" message="The account type #lcase(listLast(getMetaData(arguments.account).fullname, "."))# is not supported by this gateway." />
			</cfdefaultcase>
		</cfswitch>

		<cfreturn process(payload = post, options = arguments.options) />
	</cffunction>	

	<cffunction name="capture" output="false" access="public" returntype="any" hint="Add a previous authorization to be settled">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="authorization" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<cfset var post = structNew() />
		
		<!--- set general values --->
		<cfset post["amount"] = arguments.money.getAmount() />
		<cfset post["type"] = "5" /><!---capture--->
		<cfset post["transactionid"] = arguments.authorization />

		<!--- capture can also take the following options values:
			descriptor (optional) 
			descriptor_phone (optional) 
			type (required) 
			amount (required) Format: x.xx 
			transactionid (required) 
			tracking_number (optional) 
			shipping_carrier (optional) Format: ups / fedex / dhl / usps 
			orderid (optional) 
		--->

		<cfreturn process(payload = post, options = arguments.options) />
	</cffunction>

	<!--- refund all or part of a previous settled transaction --->
	<cffunction name="credit" output="false" access="public" returntype="any" hint="Credit all or part of a previous transaction">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="transactionid" type="any" required="false" />
		<cfargument name="account" type="any" required="false" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<cfset var post = structNew() />
		
		<!--- set general values --->
		<cfset post["amount"] = arguments.money.getAmount() />

		<cfif structKeyExists(arguments, "account")>
			<cfswitch expression="#lcase(listLast(getMetaData(arguments.account).fullname, "."))#">
				<cfcase value="creditcard">
					<!--- copy in name and customer details --->
					<cfset post["type"] = "2" /><!---credit--->
					<cfset post["transactionid"] = arguments.transactionid />
					<cfset post = addCustomer(post = post, account = arguments.account) />
					<cfset post = addCreditCard(post = post, account = arguments.account, options = arguments.options) />
				</cfcase>
			</cfswitch>
		</cfif>

		<cfreturn process(payload = post, options = arguments.options) />
	</cffunction>


	<cffunction name="void" output="false" access="public" returntype="any" hint="">
		<cfargument name="transactionid" type="any" required="true" />
		<cfargument name="options" type="struct" required="true" />
		<cfset var post = structNew() />
		
		<!--- set general values --->
		<cfset post["type"] = "3" /><!---void--->
		<cfset post["transactionid"] = arguments.transactionid />

		<cfreturn process(payload = post, options = arguments.options) />
	</cffunction>

	<cffunction name="report" output="false" access="public" returntype="any" hint="">
		<cfargument name="reportType" type="any" required="true" />
		<cfargument name="options" type="struct" required="true" />
		<cfscript>
			var post = structNew();
			var type = "";
		
			switch(Arguments.reportType) {
				case "CreditCardDetailReport":
					type = "81";
				break;
				case "BatchPreSettleReport":
					type = "82";
				break;
				case "BatchPostSettleReport":
					type = "83";
				break;
				case "CheckSummaryReport":
					type = "84";
				break;
				default: {
					arguments.reportType = "CreditCardDetailReport";
					type = 81;
					break;
				}
			}
			//set general values
			structInsert(post, "type", type, "yes");
			structInsert(post, "reportName", arguments.reportType, "yes");
			
			if (NOT structKeyExists(arguments.options, "reportStartDate"))
				structInsert(arguments.options, "reportStartDate", now(), "yes");
				
			if (NOT structKeyExists(arguments.options, "reportEndDate"))
				structInsert(arguments.options, "reportEndDate", now(), "yes");

			// Transaction Result Filter: 0 = all (default); 1 = approved; 2 = declined
			if (NOT (structKeyExists(arguments.options, "transactionFilter") AND listFind("0,1,2", arguments.options.transactionFilter)))
				structInsert(arguments.options, "transactionFilter", 0, "yes"); // Default to all transactions
				
			if (NOT (structKeyExists(arguments.options, "reportFileFormat") AND listFindNoCase("pdf,rtf,txt", arguments.options.reportFileFormat)))
				structInsert(arguments.options, "reportFileFormat", "pdf", "yes");
			
			if (NOT (structKeyExists(arguments.options, "reportFilePath") AND len(arguments.options.reportFilePath)))
				throw("An Report file output path is required.", "", "cfpayment.InvalidReportOutputPath");
			
			return process(payload = post, options = arguments.options);
		</cfscript>
	</cffunction>

	<!--- override super.getGatewayURL to inject the extra URL method per gateway method --->
	<cffunction name="getGatewayURL" access="public" output="false" returntype="any" hint="">
		<!--- argumentcollection will include method and payload --->
		<cfargument name="payload" type="struct" required="true" />
		
		<cfif structKeyExists(arguments.payload, "type") AND arguments.payload.type EQ "query">
			<cfreturn variables.cfpayment.GATEWAY_REPORT_URL />
		<cfelse>
			<cfreturn variables.cfpayment.GATEWAY_LIVE_URL />
		</cfif>
	</cffunction>

	<!--- ------------------------------------------------------------------------------
		  CUSTOM GETTERS/SETTERS
		  ------------------------------------------------------------------------- --->
	<cffunction name="getComObjectName" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_ComObjectName />
	</cffunction>
	<cffunction name="setComObjectName" access="package" output="false" returntype="void">
		<cfargument name="ComObjectName" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_ComObjectName = arguments.ComObjectName />
	</cffunction>

	<cffunction name="getProcessor" access="package" output="false" returntype="any">
		<cfif getTestMode()>
			<cfreturn variables.cfpayment.GATEWAY_TEST_Processor />
		<cfelse>
			<cfreturn variables.cfpayment.GATEWAY_LIVE_Processor />
		</cfif>
	</cffunction>
	<cffunction name="setProcessor" access="package" output="false" returntype="void">
		<cfargument name="Processor" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_LIVE_Processor = arguments.Processor />
	</cffunction>

	<cffunction name="getMerchantAccount" access="package" output="false" returntype="any">
		<cfif getTestMode()>
			<cfreturn variables.cfpayment.GATEWAY_TEST_MerchantAccount />
		<cfelse>
			<cfreturn variables.cfpayment.GATEWAY_LIVE_MerchantAccount />
		</cfif>
	</cffunction>
	<!--- setMerchantAccount() unchanged from base.cfc --->
	
	<cffunction name="getCommMethod" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_CommMethod />
	</cffunction>
	<cffunction name="setCommMethod" access="package" output="false" returntype="void">
		<cfargument name="CommMethod" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_CommMethod = arguments.CommMethod />
	</cffunction>

	<cffunction name="getPath" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_Path />
	</cffunction>
	<cffunction name="setPath" access="package" output="false" returntype="void">
		<cfargument name="Path" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_Path = arguments.Path />
	</cffunction>

	<cffunction name="getIPAddress" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_IPAddress />
	</cffunction>
	<cffunction name="setIPAddress" access="package" output="false" returntype="void">
		<cfargument name="IPAddress" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_IPAddress = arguments.IPAddress />
	</cffunction>

	<cffunction name="getPort" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_Port />
	</cffunction>
	<cffunction name="setPort" access="package" output="false" returntype="void">
		<cfargument name="Port" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_Port = arguments.Port />
	</cffunction>

	<cffunction name="getEnableSSL" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_EnableSSL />
	</cffunction>
	<cffunction name="setEnableSSL" access="package" output="false" returntype="void">
		<cfargument name="EnableSSL" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_EnableSSL = arguments.EnableSSL />
	</cffunction>
	
	<cffunction name="getGatewayUser" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_User />
	</cffunction>
	<cffunction name="setGatewayUser" access="package" output="false" returntype="void">
		<cfargument name="User" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_User = arguments.User />
	</cffunction>

	<cffunction name="getLastValidDate" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_LastValidDate />
	</cffunction>
	<cffunction name="setLastValidDate" access="package" output="false" returntype="void">
		<cfargument name="LastValidDate" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_LastValidDate = arguments.LastValidDate />
	</cffunction>

	<cffunction name="getTimeout" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_Timeout />
	</cffunction>
	<cffunction name="setTimeout" access="package" output="false" returntype="void">
		<cfargument name="timeout" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_Timeout = arguments.timeout />
	</cffunction>

	<!--- ------------------------------------------------------------------------------
		  PRIVATE HELPER METHODS
		  ------------------------------------------------------------------------- --->
	<cffunction name="addCustomer" output="false" access="private" returntype="any" hint="Add customer contact details to the request object">
		<cfargument name="post" type="struct" required="true" />
		<cfargument name="account" type="any" required="true" />
		
		<cfset arguments.post["firstname"] = arguments.account.getFirstName() />
		<cfset arguments.post["lastname"] = arguments.account.getLastName() />
		<cfset arguments.post["address1"] = arguments.account.getAddress() />
		<cfset arguments.post["city"] = arguments.account.getCity() />
		<cfset arguments.post["state"] = arguments.account.getRegion() />
		<cfset arguments.post["zip"] = arguments.account.getPostalCode() />
		<cfset arguments.post["country"] = arguments.account.getCountry() />
	
		<cfreturn arguments.post />
	</cffunction>

	<cffunction name="addCreditCard" output="false" access="private" returntype="any" hint="Add payment source fields to the request object">
		<cfargument name="post" type="struct" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="true" />
		
		<cfset post["payment"] = "creditcard" />
		<cfset post["ccnumber"] = arguments.account.getAccount() />
		<cfset post["ccexp"] = numberFormat(arguments.account.getMonth(), "00") & right(arguments.account.getYear(), 2) />
		<cfset post["cvv"] = arguments.account.getVerificationValue() />

		<!--- if we want to save the instrument to the vault; check if we have an optional vault id --->
		<cfif structKeyExists(arguments.options, "store")>
			<cfset post["customer_vault"] = "add_customer" />
			<cfif NOT isBoolean(arguments.options.store)>
				<cfset post["customer_vault_id"] = arguments.options.store />
			</cfif>
		</cfif>

		<cfreturn arguments.post />
	</cffunction>

	<cfscript>
		// Helper function for addResponseReasonCodes();
		function addResponseReasonCode(respCode, respReasonCode, respReasonText, notes) {
			var resp = structNew();
			structInsert(resp, "respCode", arguments.respCode);
			structInsert(resp, "respReasonCode", arguments.respReasonCode);
			structInsert(resp, "respReasonText", arguments.respReasonText);
			structInsert(resp, "notes", arguments.notes);

			structInsert(variables.pccharge.respReasonCodes, arguments.respReasonCode, resp, "no");
			
			return variables.pccharge.respReasonCodes;
		}
		
		function getResponseReasonCode(respReasonCode) {
			var resp = structNew();
			if (structKeyExists(variables.pccharge.respReasonCodes, arguments.respReasonCode)) {
				resp = variables.pccharge.respReasonCodes[arguments.respReasonCode];
			}
			else {
				structInsert(resp, "respCode", "");
				structInsert(resp, "respReasonCode", "");
				structInsert(resp, "respReasonText", "");
				structInsert(resp, "notes", "");				
			}
			return resp;
		}
		
		// Called when this CFC is created to setup the response code lookup structure.
		function addResponseReasonCodes() {
			
			if (NOT structKeyExists(variables, "pccharge"))
				structInsert(variables, "pccharge", structNew());
			
			if (NOT structKeyExists(variables.pccharge, "respReasonCodes"))
				structInsert(variables.pccharge, "respReasonCodes", structNew());
			
			//addResponseReasonCode("1", "1", "This transaction has been approved.", "");

			structInsert(variables.pccharge.respReasonCodes, "-14", ""); //A valid tid.pcc file does not exist in the directory provided in the Path property.
			//structInsert(variables.pccharge.respReasonCodes, "-1", "PC-Charge not running"); //If an error occurred while calling PccSysExists (and PccSysExists did not set the error code), this error code will be set.
			structInsert(variables.pccharge.respReasonCodes, "-1", "PC-Charge not running / Invalid Card Number"); // When processing a credit card transaction, if the Send is called and the CheckCard property is set to TRUE, Send will attempt to verify the credit card. If the card fails that test, this error code will be set.
			structInsert(variables.pccharge.respReasonCodes, "", "File Error"); //If there was an error while using the DeleteUserFiles method, “File Error” will be placed in the Error Description field (GetErrorDesc).
			structInsert(variables.pccharge.respReasonCodes, "0", "No Error"); //Indicates that there were no errors while the function was being performed.
			structInsert(variables.pccharge.respReasonCodes, "1", "PC-Charge not running"); //This error will occur if PCCharge is not running.
			structInsert(variables.pccharge.respReasonCodes, "2", "Batch function in progress"); //This error will occur If PCCharge is running a batch function (close/inquire/settle).
			structInsert(variables.pccharge.respReasonCodes, "3", "Repair/Compact in progress"); //This error will occur if PCCharge is running a repair or compact
			structInsert(variables.pccharge.respReasonCodes, "4", "Backup or restore in progress"); //This error will occur If PCCharge is in the process of backing up or restoring its system files.
			structInsert(variables.pccharge.respReasonCodes, "5", "Unable to initialize Modem"); //If PCCharge was unable to initialize the modem, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "6", "Timeout"); //If the transaction times out waiting for a reply from PCCharge, a timeout error will occur.
			structInsert(variables.pccharge.respReasonCodes, "7", "Database backup in progress"); //This error w ill occur if a database backup is in progress in PCCharge.
			structInsert(variables.pccharge.respReasonCodes, "8", "Invalid Credit Card Number"); //If the credit card is not a valid credit card and VerifyCreditCard is called, VerifyCreditCard will set the error code and description to Invalid Credit Card Number (f or the OCX Method, it will not fire the error event.)
			structInsert(variables.pccharge.respReasonCodes, "9", "Check Service not supported"); //If the Service property is set to a service that the processor specified does not support, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "10", "Invalid Expiration Date"); //If the expiration date is not a valid date and VerifyExpDate is called, VerifyExpDate will set the error code and description to invalid expiration date (for the OCX Method, it will not fire the error event.)
			structInsert(variables.pccharge.respReasonCodes, "11", "Invalid Amount"); // If the amount is set to a negative amount or no decimal is provided and VerifyAmount is called, VerifyAmount will set the error code and description to invalid amount (for the OCX Method, it will not fire the error event.)
			structInsert(variables.pccharge.respReasonCodes, "12", "Invalid Last Valid Date"); //If the LastValidDate property is set to an invalid format the Charge.OCX will set the error code and description (for the OCX Method, it will not fire the error event).
			structInsert(variables.pccharge.respReasonCodes, "13", "Settlement File Locked"); //This error will occur if a settlement file in PCCharge is locked.
			structInsert(variables.pccharge.respReasonCodes, "14", "Configuration Change"); //This error will occur if there is a configuration change in progress.
			structInsert(variables.pccharge.respReasonCodes, "15", "Unable to erase system files"); //If the files cannot be erased before processing the function, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "16", "Sys.pcc unknown state"); //This error will occur if the sys.pcc file is an unknown state.
			structInsert(variables.pccharge.respReasonCodes, "17", "Transaction Canceled"); //If the .pro file is deleted while the function is being processed and the class never receives an .oux file, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "18", "Invalid Birth Date"); //If the Birth_Date property is set to an invalid format (Example: 11/02), this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "19", "Invalid Format"); //If the Amount property is set to an invalid format, “.2”, (for the OCX Method, the ERROR event will fire).
			structInsert(variables.pccharge.respReasonCodes, "50", "Need to enter Driver’s License"); //when transaction amount is greater than $XX.XX For SPS check, the Driver’s License number must be supplied when the amount of the sale transaction is greater than the DL Limit amount specified in the PCCharge SPS settings.
			structInsert(variables.pccharge.respReasonCodes, "51", "Need to enter State Code"); //when transaction amount is greater than $XX.XX For SPS check, the State Code (GA, CA, NY , FL, etc) must be supplied when the amount of the sale transaction is greater than the DL Limit amount specified in the PCCharge SPS settings.
			structInsert(variables.pccharge.respReasonCodes, "52", "Need to enter Date of Birth"); //when transaction amount is For SPS check, the Date of Birth must be supplied when the amount of the sale transaction is greater than the DL Limit amount specified in the PCCharge SPS greater than $XX.XX settings.
			structInsert(variables.pccharge.respReasonCodes, "53", "Need to enter Phone Number"); //For SPS check, the Phone number must be supplied on all transactions.
			structInsert(variables.pccharge.respReasonCodes, "100", "Invalid File Name"); //If no file name or merchant number are provided before calling a method that accesses a file in the PSCharge.Offline class, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "110", "File Not Found"); //If the file name that was provided is not a valid file name, and a method in the PSCharge.Offline class tries to access the file, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "120", "Invalid Record Number"); //If attempting to void a record in a .bch file and that record does not exist, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "150", "Invalid Pccw Path"); //If PccwPath was not provided while performing the ProcessFile method, this error will occur.
			structInsert(variables.pccharge.respReasonCodes, "200", "Error Erasing TMP File"); //If there is a problem sending the .tmp file to the Recycle Bin while performing the Compact method, this error will occur.
			
		}
	</cfscript>

	<cffunction name="throw" output="true" access="private" hint="Script version of CF tag: CFTHROW">
		<cfargument name="message" required="no" default="" />
		<cfargument name="detail" required="no" default="" />
		<cfargument name="type" required="no" />
		<cfif not isSimpleValue(arguments.message)>
			<cfsavecontent variable="arguments.message">
				<cfdump var="#arguments.message#" />
			</cfsavecontent>
		</cfif>
		<cfif not isSimpleValue(arguments.detail)>
			<cfsavecontent variable="arguments.detail">
				<cfdump var="#arguments.detail#" />
			</cfsavecontent>
		</cfif>
		<cfif structKeyExists(arguments, "type")>
			<cfthrow message="#arguments.message#" detail="#arguments.detail#" type="#arguments.type#" />
		<cfelse>
			<cfthrow message="#arguments.message#" detail="#arguments.detail#" />
		</cfif>
	</cffunction>

</cfcomponent>
