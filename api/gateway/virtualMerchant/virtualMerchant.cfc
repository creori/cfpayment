<!---

	Copyright 2010 Jonah Blossom (http://www.creori.com/)
	
	Based on VirtualMerchant.cfc by Rey Nacho and Authorize.net gateway by Jonah Blossom.
	
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
<cfcomponent displayname="VirtualMerchant Interface" extends="cfpayment.api.gateway.base" hint="VirtualMerchant Gateway" output="false">

	<cfscript>
		variables.cfpayment.GATEWAY_NAME = "VirtualMerchant";
		variables.cfpayment.GATEWAY_VERSION = "1.0";

		// The test URL requires a separate developer transKey and login
		variables.cfpayment.GATEWAY_TEST_URL = "https://demo.myvirtualmerchant.com/VirtualMerchantDemo/process.do";
		variables.cfpayment.GATEWAY_LIVE_URL = "https://www.myVirtualMerchant.com/VirtualMerchant/process.do";
		//variables.cfpayment.GATEWAY_responseDelimeter = "|"; // For x_delim_char - Any valid character overrides merchant interface setting if defined.		

		structInsert(variables, "VirtualMerchant", structNew());
		structInsert(variables.VirtualMerchant, "respReasonCodes", structNew());

		addResponseReasonCodes(); // Sets up the response code lookup struct.		
	</cfscript>

	<cffunction name="sendEmail" output="false" access="private" returntype="any">
		<cfmail from="info@ergomousa.com" to="jonah@creori.com,jeff@ergomousa.com" subject="ergomo processing" type="html">
			<cfoutput>
				<cfdump var="#arguments#"/>
			</cfoutput>
		</cfmail>
	</cffunction>

	<!--- ------------------------------------------------------------------------------
		  process wrapper with gateway/transaction error handling
		  ------------------------------------------------------------------------- --->
	<cffunction name="process" output="false" access="private" returntype="any">
		<cfargument name="payload" type="struct" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<!---
			Minimum Requirements for Virtual Merchant API: 
			
			The following is the minimum set of NAME/VALUE pairs that must be submitted to the payment gateway for each credit card transaction.
			
			ssl_merchant_id  -  Merchant�s Login ID
			ssl_pin  -  Merchant�s Transaction Key
	
			x_delim_data  -  TRUE
			x_delim_char  -  Any valid character
			x_version  -  3.1
			//x_relay_response  -  FALSE
	
			cc_method  -  Payment method (CC)
			ssl_transaction_type  -  Type of transaction (ccsale, ccauthonly, cccredit, ccforce, ccavsonly, ccbalinquiry, ccvoid, ccdelete, ccsignature)
			ssl_amount  -  Amount of purchase inclusive of tax
			ssl_card_number  -  Customer's credit card number
			ssl_exp_date  -  Customer's credit card expiration date
			ssl_cvv2cvc2  -  Any valid CVV2, CVC2, or CID value
			ssl_first_name  -  Customer�s first name
			ssl_last_name  -  Customer�s last name
			ssl_avs_address  -  Customer�s street address
			ssl_city  -  City for the customer�s address
			ssl_state  -  State for the customer�s address
			ssl_avs_zip  -  ZIP code for the customer�s address
			ssl_country  -  Country for the customer�s address
			ssl_phone  -  Customer�s phone number
			ssl_email  -  Customer�s e-mail address
			customer_ip  -  Customer�s IP address
		--->
		<cfscript>
			var response = "";
			var results = structNew();
			var pairs = "";
			var ii = 1;
			var numPairs = 0;
			var requestData = "";
			
			var p = arguments.payload; // shortcut (by reference)
	
			//fold in any optional data
			structAppend(p, arguments.options, true);
			
			if (structKeyExists(p, "ssl_amount")) {
				if (getTestMode())
					p.ssl_amount = "1.00";
				
				p.ssl_amount = trim(numberFormat(p.ssl_amount, "0.00"));
			}
		
			// Translate to Virtual Merchant specific name.
			if (structKeyExists(arguments.options, "orderID")) {
				structInsert(p, "ssl_invoice_number", arguments.options.orderID, "yes");
				structInsert(p, "ssl_invoice_guid", CreateUUID(), "yes");
				structInsert(p, "invoice_guid", p.ssl_invoice_guid, "yes");
			}
		
			// Configure the gateway environment variables.
			structInsert(p, "ssl_merchant_id", getMerchantAccount(), "yes");
			structInsert(p, "ssl_user_id", getUsername(), "yes");
			structInsert(p, "ssl_pin", getPassword(), "yes");
			structInsert(p, "ssl_show_form", "false", "yes");
			structInsert(p, "ssl_result_format", "ASCII", "yes");
			structInsert(p, "ssl_customer_code", "0", "yes");
			structInsert(p, "ssl_receipt_link_method", "POST", "yes");
			/*if (!len(p.ssl_cvv2cvc2)) {
				p.ssl_cvv2cvc2 = 999;
			}
			else {
				structInsert(p, "ssl_cvv2cvc2_indicator", 1, "yes"); //iif(len(p.ssl_cvv2cvc2), 1, 0)
			}*/
			if (structKeyExists(p, "ssl_cvv2cvc2"))
				structInsert(p, "ssl_cvv2cvc2_indicator", iif(len(p.ssl_cvv2cvc2), 1, 0), "yes");
			
			// Sets account to test mode. Set to TRUE for testing and development.
			structInsert(p, "ssl_test_mode", "false", "yes"); //getTestMode()
			
			//structInsert(p, "x_relay_response", "FALSE", "yes"); // All AIM transactions are direct response, a value of FALSE is required.

			//sendEmail("pre-process", p);

			// send it over the wire using the base gateway's transport function.
			response = super.process(payload = p);

			//sendEmail("post-process", response.getParsedResult(), response.getResult(), response.getParsedResult(), response.getMemento());
			
			// do some meta-checks for gateway-level errors (as opposed to auth/decline errors)
			if (NOT response.hasError()) {
		
				// we need to have a result; otherwise that's an error in itself
				if (len(response.getResult())) {
				
					results = parseResponse(response.getResult());
					
					// handle common response fields
					if (structKeyExists(results, "ssl_result"))
						response.setMessage(results.ssl_result);
					else if (structKeyExists(results, "errorCode"))
						response.setMessage(results.errorCode);

					if (structKeyExists(results, "ssl_result_message"))
						response.setMessage(response.getMessage() & ": " & results.ssl_result_message);
					else if (structKeyExists(results, "errorMessage"))
						response.setMessage(response.getMessage() & ": " & results.errorMessage);
					
					if (structKeyExists(results, "ssl_txn_id"))
						response.setTransactionID(results.ssl_txn_id);

					if (structKeyExists(results, "ssl_approval_code"))
						response.setAuthorization(results.ssl_approval_code);

					//tthrow(results, "results");
					// handle common "success" fields
					if (structKeyExists(results, "ssl_avs_response") AND len(trim(results.ssl_avs_response)))
						response.setAVSCode(results.ssl_avs_response);
					else 
						response.setAVSCode("I"); // TODO: results.ssl_avs_response was returning " " on an capture.

					if (structKeyExists(results, "ssl_cvv2_response"))// AND results.ssl_cvv2_response NEQ "P"
						response.setCVVCode(results.ssl_cvv2_response);					

					// see if the response was successful
					if (structKeyExists(results, "ssl_result")) {
						switch (results.ssl_result) {
							case "0": {
								response.setStatus(getService().getStatusSuccessful());
								break;
							}
							case "1": {
								response.setStatus(getService().getStatusDeclined());
								break;
							}
							case "2": {
								response.setStatus(5); // On hold (this status value is not currently defined in core.cfc)
								break;
							}
							default: {
								response.setStatus(getService().getStatusFailure()); // only other known state is 3 meaning, "error in transaction data or system error"
							}
						}
					}
					else {
						response.setStatus(getService().getStatusFailure()); // only other known state is 3 meaning, "error in transaction data or system error"
					}
				}
				else {
					response.setStatus(getService().getStatusUnknown()); // Virtual Merchant didn't return a response
				}
			}

			if (response.getStatus() EQ getService().getStatusSuccessful()) {
				if (p.ssl_transaction_type EQ "ccauthonly")
					structInsert(results, "result", "APPROVED", "yes");
				else
					structInsert(results, "result", "CAPTURED", "yes");
			}
			else if (response.getStatus() EQ getService().getStatusDeclined()) {
				if (p.ssl_transaction_type EQ "ccauthonly")
					structInsert(results, "result", "NOT APPROVED", "yes");
				else
					structInsert(results, "result", "NOT CAPTURED", "yes");
			}
			else {
				structInsert(results, "result", "ERROR", "yes");
			}

			structInsert(results, "Reference", response.getMessage(), "yes");
			structInsert(results, "Additional", "Gateway=" & getGatewayName(), "yes"); // Reply with the gateway used.

			// store parsed result
			response.setParsedResult(results);
			
			// Remove secure details...
			/*requestData = response.getRequestData();

			if (structKeyExists(requestData, "ssl_cvv2cvc2"))
				requestData.ssl_cvv2cvc2 = "...";
			if (structKeyExists(requestData, "card"))
				requestData.card = "..." & right(requestData.card, 4);
			if (structKeyExists(requestData, "expMonth"))
				requestData.expMonth = "...";
			if (structKeyExists(requestData, "expYear"))
				requestData.expYear = "...";
			if (structKeyExists(requestData, "ssl_merchant_id"))
				requestData.ssl_merchant_id = left(requestData.ssl_merchant_id, 3) & "...";
			if (structKeyExists(requestData, "ssl_user_id"))
				requestData.ssl_user_id = left(requestData.ssl_user_id, 3) & "...";
			if (structKeyExists(requestData, "ssl_pin"))
				requestData.ssl_pin = left(requestData.ssl_pin, 3) & "...";*/

			/*savecontent variable="responseMemento" {
				writeDump(response.getMemento());
			}
			trace(var="responseMemento", text="responseMemento");*/

			sendEmail("end-of-process", response.getParsedResult(), response.getResult(), response.getRequestData(), response.getMemento());

			return response;
		</cfscript>
	</cffunction>

	<!--- ------------------------------------------------------------------------------
		  PUBLIC METHODS
		  ------------------------------------------------------------------------- --->
	<cffunction name="purchase" output="false" access="public" returntype="any" hint="Authorize + Capture in one step">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<cfscript>
			var post = structNew();
		
			// set general values
			structInsert(post, "ssl_amount", arguments.money.getAmount(), "yes");

			if (structKeyExists(arguments.options, "tax"))
				structInsert(post, "ssl_salestax", trim(arguments.options.tax.getAmount()), "yes");
			else
				structInsert(post, "ssl_salestax", 0, "yes");

			structInsert(post, "ssl_transaction_type", "ccsale", "yes");

			switch (lcase(listLast(getMetaData(arguments.account).fullname, "."))) {
				case "creditcard": {
					// copy in name and customer details
					post = addCustomer(post = post, account = arguments.account, options = arguments.options);
					post = addCreditCard(post = post, account = arguments.account, options = arguments.options);
					break;
				}
				default: {
					throw("The account type #lcase(listLast(getMetaData(arguments.account).fullname, "."))# is not supported by this gateway.", "", "cfpayment.InvalidAccount");
					break;
				}
			}
	
			return process(payload = post, options = arguments.options);
		</cfscript>
	</cffunction>

	<cffunction name="authorize" output="false" access="public" returntype="any" hint="Authorize (only) a credit card">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<cfscript>
			var post = structNew();
		
			// set general values
			structInsert(post, "ssl_amount", arguments.money.getAmount(), "yes");

			if (structKeyExists(arguments.options, "tax"))
				structInsert(post, "ssl_salestax", trim(arguments.options.tax.getAmount()), "yes");
			else
				structInsert(post, "ssl_salestax", 0, "yes");

			structInsert(post, "ssl_transaction_type", "ccauthonly", "yes");

			switch (lcase(listLast(getMetaData(arguments.account).fullname, "."))) {
				case "creditcard": {
					// copy in name and customer details
					post = addCustomer(post = post, account = arguments.account, options = arguments.options);
					post = addCreditCard(post = post, account = arguments.account, options = arguments.options);
					break;
				}
				default: {
					throw("The account type #lcase(listLast(getMetaData(arguments.account).fullname, "."))# is not supported by this gateway.", "", "cfpayment.InvalidAccount");
					break;
				}			
			}
	
			return process(payload = post, options = arguments.options);
		</cfscript>
	</cffunction>

	<cffunction name="capture" output="false" access="public" returntype="any" hint="Capture a prior authorization - set it to be settled.">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="transactionID" type="any" required="false" />
		<cfargument name="authCode" type="any" required="false" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<cfscript>
			var post = structNew();
		
			// set required values
			structInsert(post, "ssl_transaction_type", "ccforce", "yes");
			structInsert(post, "ssl_amount", arguments.money.getAmount(), "yes");

			if (structKeyExists(arguments.options, "tax"))
				structInsert(post, "ssl_salestax", trim(arguments.options.tax.getAmount()), "yes");
			else
				structInsert(post, "ssl_salestax", 0, "yes");

			structInsert(post, "ssl_approval_code", arguments.authCode, "yes");

			switch (lcase(listLast(getMetaData(arguments.account).fullname, "."))) {
				case "creditcard": {
					// copy in name and customer details
					post = addCustomer(post = post, account = arguments.account, options = arguments.options);
					post = addCreditCard(post = post, account = arguments.account, options = arguments.options);
					break;
				}
				default: {
					throw("The account type #lcase(listLast(getMetaData(arguments.account).fullname, "."))# is not supported by this gateway.", "", "cfpayment.InvalidAccount");
					break;
				}			
			}
			// capture can also take optional values:
			// TODO: define optional values

			return process(payload = post, options = arguments.options);
		</cfscript>
	</cffunction>

	<cffunction name="credit" output="false" access="public" returntype="any" hint="Refund all or part of a previous transaction">
		<cfargument name="money" type="any" required="true" />
		<cfargument name="transactionid" type="any" required="false" />
		<cfargument name="account" type="any" required="false" />
		<cfargument name="options" type="struct" required="false" default="#structNew()#" />
		<cfscript>
			var post = structNew();
		
			// set required values
			structInsert(post, "ssl_amount", arguments.money.getAmount(), "yes");

			if (structKeyExists(arguments.options, "tax"))
				structInsert(post, "ssl_salestax", trim(arguments.options.tax.getAmount()), "yes");
			else
				structInsert(post, "ssl_salestax", 0, "yes");

			structInsert(post, "ssl_transaction_type", "cccredit", "yes");
			structInsert(post, "ssl_pin", arguments.transactionid, "yes");

			switch (lcase(listLast(getMetaData(arguments.account).fullname, "."))) {
				case "creditcard": {
					// copy in name and customer details
					post = addCustomer(post = post, account = arguments.account, options = arguments.options);
					post = addCreditCard(post = post, account = arguments.account, options = arguments.options);
					break;
				}
				default: {
					throw("The account type #lcase(listLast(getMetaData(arguments.account).fullname, "."))# is not supported by this gateway.", "", "cfpayment.InvalidAccount");
					break;
				}
			}

			// credit can also take optional values:
			// TODO: define optional values

			return process(payload = post, options = arguments.options);
		</cfscript>
	</cffunction>

	<cffunction name="void" output="false" access="public" returntype="any" hint="Cancel a pending transaction - must be called on an un-settled transaction.">
		<cfargument name="transactionid" type="any" required="true" />
		<cfargument name="options" type="struct" required="true" />
		<cfscript>
			var post = structNew();
		
			// set required values
			structInsert(post, "ssl_transaction_type", "ccvoid", "yes");
			structInsert(post, "ssl_txn_id", arguments.transactionid, "yes");

			//void can also take optional values:
			// TODO: define optional values

			return process(payload = post, options = arguments.options);
		</cfscript>
	</cffunction>

	<!--- ------------------------------------------------------------------------------
		  CUSTOM GETTERS/SETTERS
		  ------------------------------------------------------------------------- --->
	<cffunction name="getResponseDelimeter" access="package" output="false" returntype="any">
		<cfreturn variables.cfpayment.GATEWAY_responseDelimeter />
	</cffunction>
	<cffunction name="setResponseDelimeter" access="package" output="false" returntype="void">
		<cfargument name="responseDelimeter" type="any" required="true" />
		<cfset variables.cfpayment.GATEWAY_responseDelimeter = arguments.responseDelimeter />
	</cffunction>

	<!--- ------------------------------------------------------------------------------
		  PRIVATE HELPER METHODS
		  ------------------------------------------------------------------------- --->
	<cffunction name="addCustomer" output="false" access="private" returntype="any" hint="Add customer contact details to the request object">
		<cfargument name="post" type="struct" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="true" />		
		<cfscript>
			structInsert(arguments.post, "ssl_first_name", arguments.account.getFirstName()); // Customer�s first name
			structInsert(arguments.post, "ssl_last_name", arguments.account.getLastName()); // Customer�s last name
			structInsert(arguments.post, "ssl_name_on_card", arguments.post.ssl_first_name & " " & arguments.post.ssl_last_name); // Customer�s full name
			structInsert(arguments.post, "ssl_avs_address", arguments.account.getAddress()); // Customer�s street address
			structInsert(arguments.post, "ssl_address2", arguments.account.getAddress2()); // Customer�s street address
			structInsert(arguments.post, "ssl_city", arguments.account.getCity()); // City for the customer�s address
			structInsert(arguments.post, "ssl_state", arguments.account.getRegion()); // State for the customer�s address
			structInsert(arguments.post, "ssl_avs_zip", arguments.account.getPostalCode()); // ZIP code for the customer�s address
			//structInsert(arguments.post, "ssl_country", arguments.account.getCountry()); // Country for the customer�s address

			if (structKeyExists(arguments.options, "phone"))
				structInsert(arguments.post, "ssl_phone", options.phone, true); // Customer�s phone number
			else if (structKeyExists(arguments.options, "address") AND structKeyExists(arguments.options.address, "phone"))
				structInsert(arguments.post, "ssl_phone", options.address.phone, true); // Customer�s phone number
			else
				structInsert(arguments.post, "ssl_phone", "", true); // No phone number

			if (structKeyExists(arguments.options, "email"))
				structInsert(arguments.post, "ssl_email", arguments.options.email, true); // Customer�s e-mail address
			else
				structInsert(arguments.post, "ssl_email", "", true); // No email

			if (structKeyExists(arguments.options, "IPAddress"))
				structInsert(arguments.post, "customer_ip", arguments.options.IPAddress, true); // Customer�s IP address
			else
				structInsert(arguments.post, "customer_ip", "", true); // No IP Address
			
			return arguments.post;
		</cfscript>
	</cffunction>

	<cffunction name="addCreditCard" output="false" access="private" returntype="any" hint="Add payment source fields to the request object">
		<cfargument name="post" type="struct" required="true" />
		<cfargument name="account" type="any" required="true" />
		<cfargument name="options" type="struct" required="true" />
		<cfscript>
			structInsert(arguments.post, "cc_method", "CC"); // Payment method (CC)
			structInsert(arguments.post, "ssl_card_number", arguments.account.getAccount()); // credit card number
			structInsert(arguments.post, "ssl_exp_date", numberFormat(arguments.account.getMonth(), "00") & right(arguments.account.getYear(), 2)); // credit card expiration date
			structInsert(arguments.post, "ssl_cvv2cvc2", arguments.account.getVerificationValue()); // Any valid CVV2, CVC2, or CID value

			return arguments.post;
		</cfscript>
	</cffunction>

	<cffunction name="tthrow" output="true" access="public" hint="Script version of CF tag: CFTHROW">
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

	<cfscript>
		
		// Parse the delimited gateway response.
		function parseResponse(gatewayResponse) {
			var results = structNew();
			var i = 1;
			// Use Java's split because we have empty list elements which CF doesn't natively handle.
			var response = JavaCast('string', arguments.gatewayResponse).split("\n");
			var responseCount = arrayLen(response);
			var row = "";
			
			for (; i LTE responseCount; i++) {
				row = listToArrayInclEmpty(response[i], "=");
				structInsert(results, row[1], row[2]);
			}

			// Alternatively, if you don't want to or can't use JavaCast() and split(), use this custom function:
			//var response = listToArrayInclEmpty(arguments.gatewayResponse);
			
			/*insertResult(results, response, "1", "Response Code", "x_resp_code", "Error");
			insertResult(results, response, "2", "Response Subcode", "x_resp_subcode", "-1");
			insertResult(results, response, "3", "Response Reason Code:", "x_reason_code", "-1");
			insertResult(results, response, "4", "Response Reason Text", "x_reason_text", "There was an unknown parsing or processing error.");
			insertResult(results, response, "5", "Approval Code", "x_approval_code", "");
			insertResult(results, response, "6", "AVS Result Code", "x_AVS_code", "");
			insertResult(results, response, "7", "Transaction ID", "x_trans_ID", "-1");
			insertResult(results, response, "8", "Invoice Number", "x_invoice_num", "");
			insertResult(results, response, "9", "Description", "x_description", "");
			insertResult(results, response, "10", "Amount", "ssl_amount", "");
			insertResult(results, response, "11", "Method", "cc_method", "");
			insertResult(results, response, "12", "Transaction Type", "ssl_transaction_type", "");
			insertResult(results, response, "13", "Customer ID", "x_cust_id", "");
			insertResult(results, response, "14", "Cardholder First Name", "ssl_first_name", "");
			insertResult(results, response, "15", "Cardholder Last Name", "ssl_last_name", "");
			insertResult(results, response, "16", "Company", "x_company", "");
			insertResult(results, response, "17", "Billing Address", "ssl_avs_address", "");
			insertResult(results, response, "18", "City", "ssl_city", "");
			insertResult(results, response, "19", "State", "ssl_state", "");
			insertResult(results, response, "20", "ZIP", "ssl_avs_zip", "");
			insertResult(results, response, "21", "Country", "ssl_country", "");
			insertResult(results, response, "22", "Phone", "ssl_phone", "");
			insertResult(results, response, "23", "Fax", "x_fax", "");
			insertResult(results, response, "24", "E-Mail", "ssl_email", "");
			insertResult(results, response, "25", "Ship-to First Name", "x_ship_to_first_name", "");
			insertResult(results, response, "26", "Ship-to Last Name", "x_ship_to_last_name", "");
			insertResult(results, response, "27", "Ship-to Company", "x_ship_to_company", "");
			insertResult(results, response, "28", "Ship-to Address", "x_ship_to_address", "");
			insertResult(results, response, "29", "Ship-to City", "x_ship_to_city", "");
			insertResult(results, response, "30", "Ship-to State", "x_ship_to_state", "");
			insertResult(results, response, "31", "Ship-to ZIP", "x_ship_to_zip", "");
			insertResult(results, response, "32", "Ship-to Country", "x_ship_to_country", "");
			insertResult(results, response, "33", "Tax Amount", "ssl_salestax", "");
			insertResult(results, response, "34", "Duty Amount", "x_duty", "");
			insertResult(results, response, "35", "Freight Amount", "x_freight", "");
			insertResult(results, response, "36", "Tax Exempt Flag", "x_tx_exempt", "");
			insertResult(results, response, "37", "PO Number", "x_po_num", "");
			insertResult(results, response, "38", "MD5 Hash:", "x_MD5_Hash", "");
			insertResult(results, response, "39", "Card Code Response", "ssl_cvv2cvc2_resp", "");*/

			/*insertResult(results, response, "40", "Reserved for future use", "x_future_40", "");
			insertResult(results, response, "41", "Reserved for future use", "x_future_41", "");
			insertResult(results, response, "42", "Reserved for future use", "x_future_42", "");
			insertResult(results, response, "43", "Reserved for future use", "x_future_43", "");
			insertResult(results, response, "44", "Reserved for future use", "x_future_44", "");
			insertResult(results, response, "45", "Reserved for future use", "x_future_45", "");
			insertResult(results, response, "46", "Reserved for future use", "x_future_46", "");
			insertResult(results, response, "47", "Reserved for future use", "x_future_47", "");
			insertResult(results, response, "48", "Reserved for future use", "x_future_48", "");
			insertResult(results, response, "49", "Reserved for future use", "x_future_49", "");
			insertResult(results, response, "50", "Reserved for future use", "x_future_50", "");
			insertResult(results, response, "51", "Reserved for future use", "x_future_51", "");
			insertResult(results, response, "52", "Reserved for future use", "x_future_52", "");
			insertResult(results, response, "53", "Reserved for future use", "x_future_53", "");
			insertResult(results, response, "54", "Reserved for future use", "x_future_54", "");
			insertResult(results, response, "55", "Reserved for future use", "x_future_55", "");
			insertResult(results, response, "56", "Reserved for future use", "x_future_56", "");
			insertResult(results, response, "57", "Reserved for future use", "x_future_57", "");
			insertResult(results, response, "58", "Reserved for future use", "x_future_58", "");
			insertResult(results, response, "59", "Reserved for future use", "x_future_59", "");
			insertResult(results, response, "60", "Reserved for future use", "x_future_60", "");
			insertResult(results, response, "61", "Reserved for future use", "x_future_61", "");
			insertResult(results, response, "62", "Reserved for future use", "x_future_62", "");
			insertResult(results, response, "63", "Reserved for future use", "x_future_63", "");
			insertResult(results, response, "64", "Reserved for future use", "x_future_64", "");
			insertResult(results, response, "65", "Reserved for future use", "x_future_65", "");
			insertResult(results, response, "66", "Reserved for future use", "x_future_66", "");
			insertResult(results, response, "67", "Reserved for future use", "x_future_67", "");
			insertResult(results, response, "68", "Reserved for future use", "x_future_68", "");*/
			/*insertResult(results, response, "69", "Merchant defined value", "x_merchant_69", "");
			insertResult(results, response, "70", "Merchant defined value", "x_merchant_70", "");*/
		
			return results;	
		}	

		// Helper function for parseResponse();
		function insertResult(results, response, listPosition, FieldName, fieldKey, defaultValue) {
			var value = arguments.defaultValue;
	
			if (arrayLen(arguments.response) GTE arguments.listPosition AND len(arguments.response[arguments.listPosition]))
				value = arguments.response[arguments.listPosition];
	
			if (len(arguments.fieldKey)) {
				if (structKeyExists(arguments.results, arguments.fieldKey))
					structInsert(arguments.results, "#arguments.fieldKey##arguments.listPosition#", value);
				else
					structInsert(arguments.results, "#arguments.fieldKey#", value);
			}
			else if (len(arguments.FieldName)) {
				if (structKeyExists(arguments.results, arguments.FieldName))
					structInsert(arguments.results, "#arguments.FieldName##arguments.listPosition#", value);
				else
					structInsert(arguments.results, "#arguments.FieldName#", value);
			}
			return arguments.results;
		}
		
		// Helper function for addResponseReasonCodes();
		function addResponseReasonCode(respCode, respReasonCode, respReasonText, notes) {
			var resp = structNew();
			structInsert(resp, "respCode", arguments.respCode);
			structInsert(resp, "respReasonCode", arguments.respReasonCode);
			structInsert(resp, "respReasonText", arguments.respReasonText);
			structInsert(resp, "notes", arguments.notes);

			structInsert(variables.VirtualMerchant.respReasonCodes, arguments.respReasonCode, resp, "no");
			
			return variables.VirtualMerchant.respReasonCodes;
		}
		
		function getResponseReasonCode(respReasonCode) {
			var resp = structNew();
			if (structKeyExists(variables.VirtualMerchant.respReasonCodes, arguments.respReasonCode)) {
				resp = variables.VirtualMerchant.respReasonCodes[arguments.respReasonCode];
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
			
			addResponseReasonCode("1", "1", "This transaction has been approved.", "");
			
			addResponseReasonCode("2", "2", "This transaction has been declined.", "");
			addResponseReasonCode("2", "3", "This transaction has been declined.", "");
			addResponseReasonCode("2", "4", "This transaction has been declined.", "The code returned from the processor indicating that the card used needs to be picked up. ");
			addResponseReasonCode("2", "27", "The transaction resulted in an AVS mismatch. The address provided does not match billing address of cardholder.", "");
			addResponseReasonCode("2", "41", "This transaction has been declined.", "Only merchants set up for the FraudScreen.Net service would receive this decline. This code will be returned if a given transaction�s fraud score is higher than the threshold set by the merchant. ");
			addResponseReasonCode("2", "44", "This transaction has been declined.", "The merchant would receive this error if the Card Code filter has been set in the Merchant Interface and the transaction received an error code from the processor that matched the rejection criteria set by the merchant. ");
			addResponseReasonCode("2", "45", "This transaction has been declined.", "This error would be returned if the transaction received a code from the processor that matched the rejection criteria set by the merchant for boththe AVS and Card Code filters. ");
			addResponseReasonCode("2", "65", "This transaction has been declined.", "The transaction was declined because the merchant configured their account through the Merchant Interface to reject transactions with certain values for a Card Code mismatch. ");
			addResponseReasonCode("2", "127", "The transaction resulted in an AVS mismatch. The address provided does not match billing address of cardholder.", "The system-generated void for the original AVS-rejected transaction failed. ");
			addResponseReasonCode("2", "141", "This transaction has been declined.", "The system-generated void for the original FraudScreen-rejected transaction failed. ");
			addResponseReasonCode("2", "145", "This transaction has been declined.", "The system-generated void for the original card code-rejected and AVS-rejected transaction failed. ");
			addResponseReasonCode("2", "165", "This transaction has been declined.", "The system-generated void for the original card code-rejected transaction failed. ");
			addResponseReasonCode("2", "200", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The credit card number is invalid. ");
			addResponseReasonCode("2", "201", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The expiration date is invalid. ");
			addResponseReasonCode("2", "202", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The transaction type is invalid. ");
			addResponseReasonCode("2", "203", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The value submitted in the amount field is invalid. ");
			addResponseReasonCode("2", "204", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The department code is invalid. ");
			addResponseReasonCode("2", "205", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The value submitted in the merchant number field is invalid. ");
			addResponseReasonCode("2", "206", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The merchant is not on file. ");
			addResponseReasonCode("2", "207", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The merchant account is closed. ");
			addResponseReasonCode("2", "208", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The merchant is not on file. ");
			addResponseReasonCode("2", "209", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. Communication with the processor could not be established.");
			addResponseReasonCode("2", "210", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The merchant type is incorrect. ");
			addResponseReasonCode("2", "211", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The cardholder is not on file. ");
			addResponseReasonCode("2", "212", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The bank configuration is not on file ");
			addResponseReasonCode("2", "213", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The merchant assessment code is incorrect. ");
			addResponseReasonCode("2", "214", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. This function is currently unavailable. ");
			addResponseReasonCode("2", "215", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The encrypted PIN field format is invalid. ");
			addResponseReasonCode("2", "216", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The ATM term ID is invalid. ");
			addResponseReasonCode("2", "217", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. This transaction experienced a general message format problem. ");
			addResponseReasonCode("2", "218", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The PIN block format or PIN availability value is invalid. ");
			addResponseReasonCode("2", "219", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The ETC void is unmatched. ");
			addResponseReasonCode("2", "220", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The primary CPU is not available. ");
			addResponseReasonCode("2", "221", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. The SE number is invalid. ");
			addResponseReasonCode("2", "222", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. Duplicate auth request (from INAS). ");
			addResponseReasonCode("2", "223", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. This transaction experienced an unspecified error. ");
			addResponseReasonCode("2", "224", "This transaction has been declined.", "This error code applies only to merchants on FDC Omaha. Please re-enter the transaction. ");
			addResponseReasonCode("2", "250", "This transaction has been declined.", "This transaction was submitted from a blocked IP address.  ");
			addResponseReasonCode("2", "251", "This transaction has been declined.", "The transaction was declined as a result of triggering a Fraud Detection Suite filter. ");
			addResponseReasonCode("2", "254", "Your transaction has been declined.", "The transaction was declined after manual review. ");
			
			
			addResponseReasonCode("3", "5", "A valid amount is required.", "The value submitted in the amount field did not pass validation for a number. ");
			addResponseReasonCode("3", "6", "The credit card number is invalid.", "");
			addResponseReasonCode("3", "7", "The credit card expiration date is invalid.", "The format of the date submitted was incorrect. ");
			addResponseReasonCode("3", "8", "The credit card has expired.", "");
			addResponseReasonCode("3", "9", "The ABA code is invalid.", "The value submitted in the x_bank_aba_code field did not pass validation or was not for a valid financial institution. ");
			addResponseReasonCode("3", "10", "The account number is invalid.", "The value submitted in the x_bank_acct_num field did not pass validation. ");
			addResponseReasonCode("3", "11", "A duplicate transaction has been submitted.", "A transaction with identical amount and credit card information was submitted two minutes prior. ");
			addResponseReasonCode("3", "12", "An authorization code is required but not present.", "A transaction that required x_auth_code to be present was submitted without a value. ");
			addResponseReasonCode("3", "13", "The merchant Login ID is invalid or the account is inactive.", "");
			addResponseReasonCode("3", "14", "The Referrer or Relay Response URL is invalid.", "Applicable only to SIM and WebLink APIs. The Relay Response or Referrer URL does not matchthe merchant�s configured value(s) or is absent. ");
			addResponseReasonCode("3", "15", "The transaction ID is invalid.", "The transaction ID value is non-numeric or was not present for a transaction that requires it (i.e., ccvoid, ccbalinquiry, and cccredit). ");
			addResponseReasonCode("3", "16", "The transaction was not found.", "The transaction ID sent in was properly formatted but the gateway had no record of the transaction. ");
			addResponseReasonCode("3", "17", "The merchant does not accept this type of credit card.", "The merchant was not configured to accept the credit card submitted in the transaction. ");
			addResponseReasonCode("3", "18", "ACH transactions are not accepted by this merchant.", "The merchant does not accept electronic checks. ");
			addResponseReasonCode("3", "19", "An error occurred during processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "20", "An error occurred during processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "21", "An error occurred during processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "22", "An error occurred during processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "23", "An error occurred during processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "24", "The Nova Bank Number or Terminal ID is incorrect. Call Merchant Service Provider.", "");
			addResponseReasonCode("3", "25", "An error occurred during processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "26", "An error occurred during processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "28", "The merchant does not accept this type of credit card.", "The Merchant ID at the processor was not configured to accept this card type. ");
			addResponseReasonCode("3", "29", "The PaymentTech identification numbers are incorrect. Call Merchant Service Provider.", "");
			addResponseReasonCode("3", "30", "The configuration with the processor is invalid. Call Merchant Service Provider.", "");
			addResponseReasonCode("3", "31", "The FDC Merchant ID or Terminal ID is incorrect. Call Merchant Service Provider.", "The merchant was incorrectly set up at the processor. ");
			addResponseReasonCode("3", "32", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "33", "FIELD cannot be left blank.", "The word FIELD will be replaced by an actual field name. This error indicates that a field the merchant specified as required was not filled in.");
			addResponseReasonCode("3", "34", "The VITAL identification numbers are incorrect. Call Merchant Service Provider.", "The merchant was incorrectly set up at the processor. ");
			addResponseReasonCode("3", "35", "An error occurred during processing. Call Merchant Service Provider.", "The merchant was incorrectly set up at the processor. ");
			addResponseReasonCode("3", "36", "The authorization was approved, but settlement failed.", "");
			addResponseReasonCode("3", "37", "The credit card number is invalid.", "");
			addResponseReasonCode("3", "38", "The Global Payment System identification numbers are incorrect. Call Merchant Service Provider.", "The merchant was incorrectly set up at the processor. ");
			addResponseReasonCode("3", "39", "The supplied currency code is either invalid, not supported, not allowed for this merchant or doesn�t have an exchange rate.", "");
			addResponseReasonCode("3", "40", "This transaction must be encrypted.", "");
			addResponseReasonCode("3", "43", "The merchant was incorrectly set up at the processor. Call your Merchant Service Provider.", "The merchant was incorrectly set up at the processor. ");
			addResponseReasonCode("3", "46", "Your session has expired or does not exist. You must log in to continue working.", "");
			addResponseReasonCode("3", "47", "The amount requested for settlement may not be greater than the original amount authorized.", "This occurs if the merchant tries to capture fundsgreater than the amount of the original authorization-only transaction. ");
			addResponseReasonCode("3", "48", "This processor does not accept partial reversals.", "The merchant attempted to settle for less than the originally authorized amount. ");
			addResponseReasonCode("3", "49", "A transaction amount greater than $99,999 will not be accepted.", "");
			addResponseReasonCode("3", "50", "This transaction is awaiting settlement and cannot be refunded.", "Credits or refunds may only be performed against settled transactions. The transaction against which the credit/refund was submitted has not been settled, so a credit cannot be issued.");
			addResponseReasonCode("3", "51", "The sum of all credits against this transaction is greater than the original transaction amount.", "");
			addResponseReasonCode("3", "52", "The transaction was authorized, but the client could not be notified; the transaction will not be settled.", "");
			addResponseReasonCode("3", "53", "The transaction type was invalid for ACH transactions.", "If cc_method = ECHECK, ssl_transaction_type cannot be set to CAPTURE_ONLY. ");
			addResponseReasonCode("3", "54", "The referenced transaction does not meet the criteria for issuing a credit.", "");
			addResponseReasonCode("3", "55", "The sum of credits against the referenced transaction would exceed the original debit amount.", "The transaction is rejected if the sum of this credit and prior credits exceeds the original debitamount. ");
			addResponseReasonCode("3", "56", "This merchant accepts ACH transactions only; no credit card transactions are accepted.", "The merchant processes eCheck.Net transactionsonly and does not accept credit cards. ");
			addResponseReasonCode("3", "57", "An error occurred in processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "58", "An error occurred in processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "59", "An error occurred in processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "60", "An error occurred in processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "61", "An error occurred in processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "62", "An error occurred in processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "63", "An error occurred in processing. Please try again in 5 minutes.", "");
			addResponseReasonCode("3", "66", "This transaction cannot be accepted for processing.", "The transaction did not meet gateway security guidelines. ");
			addResponseReasonCode("3", "68", "The version parameter is invalid.", "The value submitted in x_version was invalid. ");
			addResponseReasonCode("3", "69", "The transaction type is invalid.", "The value submitted in ssl_transaction_type was invalid. ");
			addResponseReasonCode("3", "70", "The transaction method is invalid.", "The value submitted in cc_method was invalid. ");
			addResponseReasonCode("3", "71", "The bank account type is invalid.", "The value submitted in x_bank_acct_type was invalid. ");
			addResponseReasonCode("3", "72", "The authorization code is invalid.", "The value submitted in x_auth_code was more than six characters in length. ");
			addResponseReasonCode("3", "73", "The driver�s license date of birth is invalid.", "The format of the value submitted in x_drivers_license_num was invalid. ");
			addResponseReasonCode("3", "74", "The duty amount is invalid.", "The value submitted in x_duty failed format validation. ");
			addResponseReasonCode("3", "75", "The freight amount is invalid.", "The value submitted in x_freight failed format validation. ");
			addResponseReasonCode("3", "76", "The tax amount is invalid.", "The value submitted in ssl_salestax failed format validation. ");
			addResponseReasonCode("3", "77", "The SSN or tax ID is invalid.", "The value submitted in x_customer_tax_id failedvalidation. ");
			addResponseReasonCode("3", "78", "The card code (CVV2/CVC2/CID) is invalid.", "The value submitted in ssl_cvv2cvc2 failed format validation. ");
			addResponseReasonCode("3", "79", "The driver�s license number is invalid.", "The value submitted in x_drivers_license_num failed format validation. ");
			addResponseReasonCode("3", "80", "The driver�s license state is invalid.", "The value submitted in x_drivers_license_state failed format validation. ");
			addResponseReasonCode("3", "81", "The requested form type is invalid.", "The merchant requested an integration method not compatible with the AIM API. ");
			addResponseReasonCode("3", "82", "Scripts are only supported in version 2.5.", "The system no longer supports version 2.5; requests cannot be posted to scripts. ");
			addResponseReasonCode("3", "83", "The requested script is either invalid or no longer supported.", "The system no longer supports version 2.5; requests cannot be posted to scripts.");
			addResponseReasonCode("3", "84", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "85", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "86", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "87", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "88", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "89", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "90", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "91", "Version 2.5 is no longer supported.", "");
			addResponseReasonCode("3", "92", "The gateway no longer supports the requested method of integration.", "");
			addResponseReasonCode("3", "97", "This transaction cannot be accepted.", "Applicable only to SIM API. Fingerprints are only valid for a short period of time. This code indicates that the transaction fingerprint has expired. ");
			addResponseReasonCode("3", "98", "This transaction cannot be accepted.", "Applicable only to SIM API. The transaction fingerprint has already been used. ");
			addResponseReasonCode("3", "99", "This transaction cannot be accepted.", "Applicable only to SIM API. The server-generated fingerprint does not match the merchant-specified fingerprint in the x_fp_hash field. ");
			addResponseReasonCode("3", "100", "The eCheck.Net type is invalid.", "Applicable only to eCheck.Net. The value specified in the x_echeck_type field is invalid. ");
			addResponseReasonCode("3", "101", "The given name on the account and/or the account type does not match the actual account.", "Applicable only to eCheck.Net. The specified name on the account and/or the account type do not match the NOC record for this account. ");
			addResponseReasonCode("3", "102", "This request cannot be accepted. ", "A transaction key was submitted with this WebLink request. ");
			addResponseReasonCode("3", "103", "This transaction cannot be accepted.", "A valid fingerprint, or transaction key is requiredfor this transaction. ");
			addResponseReasonCode("3", "104", "This transaction is currently under review.", "Applicable only to eCheck.Net. The value submitted for country failed validation. ");
			addResponseReasonCode("3", "105", "This transaction is currently under review.", "Applicable only to eCheck.Net. The values submitted for city and country failed validation. ");
			addResponseReasonCode("3", "106", "This transaction is currently under review.", "Applicable only to eCheck.Net. The value submitted for company failed validation. ");
			addResponseReasonCode("3", "107", "This transaction is currently under review.", "Applicable only to eCheck.Net. The value submitted for bank account name failed validation. ");
			addResponseReasonCode("3", "108", "This transaction is currently under review.", "Applicable only to eCheck.Net. The values submitted for first name and last name failed validation. ");
			addResponseReasonCode("3", "109", "This transaction is currently under review.", "Applicable only to eCheck.Net. The values submitted for first name and last name failed validation. ");
			addResponseReasonCode("3", "110", "This transaction is currently under review.", "The value submitted for bank account name doesnot contain valid characters. ");
			addResponseReasonCode("3", "116", "The authentication indicator is invalid.", "This code is applicable only to merchants that include the x_authentication_indicator in the transaction request. The ECI value for a Visa transaction; or the UCAF indicator for a MasterCard transaction submitted in the x_authentication_indicator field is invalid. ");
			addResponseReasonCode("3", "117", "The cardholder authentication value is invalid.", "This code is applicable only to merchants that include the x_cardholder_authentication_value in the transaction request. The CAVV for a Visa transaction; or the AVV/UCAF for a MasterCardtransaction is invalid. ");
			addResponseReasonCode("3", "118", "The combination of authentication indicator and cardholder authentication value is invalid.", "This code is applicable only to merchants that include the x_authentication_indicator and x_authentication_value in the transaction request. The combination of authentication indicator and cardholder authentication value for a Visa or MasterCard transaction is invalid. ");
			addResponseReasonCode("3", "119", "Transactions having cardholder authentication values cannot be marked as recurring.", "This code is applicable only to merchants that include the x_authentication_indicator and x_recurring_billing in the transaction request. Transactions submitted with a value in x_authentication_indicator AND x_recurring_billing =YES will be rejected. ");
			addResponseReasonCode("3", "120", "An error occurred during processing. Please try again.", "The system-generated void for the original timed-out transaction failed. (The original transaction timed out while waiting for a response from the authorizer.) ");
			addResponseReasonCode("3", "121", "An error occurred during processing. Please try again.", "The system-generated void for the original errored transaction failed. (The original transaction experienced a database error.) ");
			addResponseReasonCode("3", "122", "An error occurred during processing. Please try again.", "The system-generated void for the original errored transaction failed. (The original transaction experienced a processing error.) ");
			addResponseReasonCode("3", "128", "This transaction cannot be processed.", "The customer�s financial institution does not currently allow transactions for this account. ");
			addResponseReasonCode("3", "152", "The transaction was authorized, but the client could not be notified; the transaction will not be settled.", "The system-generated void for the original transaction failed. The response for the original transaction could not be communicated to the client. ");
			addResponseReasonCode("3", "170", "An error occurred during processing. Please contact the merchant.", "Concord EFS � Provisioning at the processor hasnot been completed. ");
			addResponseReasonCode("3", "171", "An error occurred during processing. Please contact the merchant.", "Concord EFS � This request is invalid. ");
			addResponseReasonCode("3", "172", "An error occurred during processing. Please contact the merchant.", "Concord EFS � The store ID is invalid. ");
			addResponseReasonCode("3", "173", "An error occurred during processing. Please contact the merchant.", "Concord EFS � The store key is invalid. ");
			addResponseReasonCode("3", "174", "The transaction type is invalid. Please contact the merchant.", "Concord EFS � This transaction type is not accepted by the processor. ");
			addResponseReasonCode("3", "175", "The processor does not allow voiding of credits.", "Concord EFS � This transaction is not allowed. The Concord EFS processing platform does not support voiding credit transactions. Please debit the credit card instead of voiding the credit. ");
			addResponseReasonCode("3", "180", "An error occurred during processing. Please try again.", "The processor response format is invalid. ");
			addResponseReasonCode("3", "181", "An error occurred during processing. Please try again.", "The system-generated void for the original invalid transaction failed. (The original transaction included an invalid processor response format.) ");
			addResponseReasonCode("3", "185", "This reason code is reserved or not applicable to this API.", "");
			addResponseReasonCode("3", "243", "Recurring billing is not allowed for this eCheck.Net type.", "The combination of values submitted for x_recurring_billing and x_echeck_type is not allowed. ");
			addResponseReasonCode("3", "244", "This eCheck.Net type is not allowed for this Bank Account Type.", "The combination of values submitted for x_bank_acct_type and x_echeck_type is not allowed. ");
			addResponseReasonCode("3", "245", "This eCheck.Net type is not allowed when using the payment gateway hosted payment form.", "The value submitted for x_echeck_type is not allowed when using the payment gateway hostedpayment form. ");
			addResponseReasonCode("3", "246", "This eCheck.Net type is not allowed.", "The merchant�s payment gateway account is not enabled to submit the eCheck.Net type. ");
			addResponseReasonCode("3", "247", "This eCheck.Net type is not allowed.", "The combination of values submitted for ssl_transaction_type and x_echeck_type is not allowed. ");
			addResponseReasonCode("3", "261", "An error occurred during processing. Please try again.", "The transaction experienced an error during sensitive data encryption and was not processed. Please try again. ");
			addResponseReasonCode("3", "270", "The line item [item number] is invalid.", "A value submitted in x_line_item for the item referenced is invalid. ");
			addResponseReasonCode("3", "271", "The number of line items submitted is not allowed. A maximum of 30 line items can be submitted.", "The number of line items submitted in x_line_item exceeds the allowed maximum of 30. ");
			
			
			addResponseReasonCode("4", "193", "The transaction is currently under review.", "The transaction was placed under review by the risk management system. ");
			addResponseReasonCode("4", "252", "Your order has been received. Thank you for your business!", "The transaction was accepted, but is being held for merchant review. The merchant may customize the customer response in the Merchant Interface. ");
			addResponseReasonCode("4", "253", "Your order has been received. Thank you for your business!", "The transaction was accepted and was authorized, but is being held for merchant review. The merchant may customize the customer response in the Merchant Interface. ");
		}

		// Coyright Jonah Blossom (info@creori.com)
		// Helper function for parseResponse();
		function listToArrayInclEmpty(list) {
			var delim = iif(arrayLen(arguments) gt 1, de("#arguments[2]#"), de(","));

			var strlen = len(arguments.list);
			var ary = arrayNew(1);
			var i = 0;
			var p = 1;

			arguments.list = arguments.list & delim;
			
			while(i LTE strlen) {
				i = i + 1;
				l = find(delim, arguments.list, i);
				if (l) {
					arrayAppend(ary, mid(arguments.list, i, l - i));
					i = l;
				}
			}
			return ary;
		}
	</cfscript>
</cfcomponent>