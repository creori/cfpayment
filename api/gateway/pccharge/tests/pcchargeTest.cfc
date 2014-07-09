<cfcomponent name="pcchargeTest" extends="mxunit.framework.TestCase" output="false">

<!---
	
	Test transactions can be submitted with the following information:
	
	Visa 4387755555555550 
	MasterCard 5431111111111111 
	DiscoverCard 6011601160116611 
	American Express 341111111111111 

--->
	<cffunction name="setUp" returntype="void" access="public">	

		<cfset var gw = structNew() />

		<cfscript>  
			variables.svc = createObject("component", "cfpayment.api.core");
			
			gw.path = "pccharge.pccharge";
			//gw.MerchantAccount = 0;
			//gw.Username = 'demo';
			//gw.Password = 'password';
			gw.TestMode = true;		// defaults to true anyways

			// create gw and get reference			
			variables.svc.init(gw);
			variables.gw = variables.svc.getGateway();
		</cfscript>
	</cffunction>

	<cffunction name="testPurchase" access="public" returntype="void" output="false">
	
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		<cfset options.orderid = getTickCount() />
		
		<!--- test the purchase method --->
		<cfset response = gw.purchase(money = money, account = createValidCard(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<!--- amounts less than 1.00 generate declines --->
		<!---<cfset response = gw.purchase(money = variables.svc.createMoney(50), account = createValidCard(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />--->

		<!--- this will be rejected by gateway because the card number is not valid --->
		<cfset response = gw.purchase(money = money, account = createInvalidCard(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />


		<cfset response = gw.purchase(money = money, account = createValidCardWithoutCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "P", "No CVV was passed so no answer should be provided but was: '#response.getCVVCode()#'") /><!---JSB was ""--->

		<cfset response = gw.purchase(money = money, account = createValidCardWithBadCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<!---<cfset debug(createValidCardWithBadCVV().getMemento()) />--->
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "M", "Bad CVV was passed so non-matching answer should be provided but was: '#response.getCVVCode()#'") />

		<cfset response = gw.purchase(money = money, account = createValidCardWithoutStreetMatch(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getMemento()) /><!---getAVSMessage--->
		<cfset assertTrue(response.getAVSCode() EQ "Z", "AVS Zip match only should be found") />

		<cfset response = gw.purchase(money = money, account = createValidCardWithoutZipMatch(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "A", "AVS Street match only should be found") />


		<!--- test the purchase method for EFT --->
		<!---JSB: EFT Not implemented yet.--->
		<!---<cfset response = gw.purchase(money = money, account = createValidEFT(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<!--- amounts less than 1.00 generate declines --->
		<cfset response = gw.purchase(money = variables.svc.createMoney(50), account = createValidEFT(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />--->

	</cffunction>


	<cffunction name="testAuthorizeOnly" access="public" returntype="void" output="false">
	
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		<cfset options.orderid = getTickCount() />

		<cfset response = gw.authorize(money = money, account = createValidCard(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "Y", "Exact match (street + zip) should be found") />

		<!--- amounts less than 1.00 generate declines --->
		<!---<cfset response = gw.authorize(money = variables.svc.createMoney(50), account = createValidCard(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />--->

		<!--- this will be rejected by gateway because the card number is not valid --->
		<cfset response = gw.authorize(money = money, account = createInvalidCard(), options = options) />
		<cfset assertTrue(NOT response.getSuccess(), "The authorization did succeed") />


		<cfset response = gw.authorize(money = money, account = createValidCardWithoutCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "P", "No CVV was passed so no answer should be provided but was: '#response.getCVVCode()#'") /><!---JSB was ""--->

		<cfset response = gw.authorize(money = money, account = createValidCardWithBadCVV(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getCVVMessage()) />
		<cfset assertTrue(response.getCVVCode() EQ "N", "Bad CVV was passed so non-matching answer should be provided but was: '#response.getCVVCode()#'") />

		<cfset response = gw.authorize(money = money, account = createValidCardWithoutStreetMatch(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "Z", "AVS Zip match only should be found") />

		<cfset response = gw.authorize(money = money, account = createValidCardWithoutZipMatch(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />
		<cfset debug(response.getAVSMessage()) />
		<cfset assertTrue(response.getAVSCode() EQ "A", "AVS Street match only should be found") />

	</cffunction>


	<!---<cffunction name="testAuthorizeAndStoreThenPurchase" access="public" returntype="void" output="false">
	
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var token = variables.svc.createToken(createUUID()) />
		<cfset var response = "" />
		<cfset var options = structNew() />
		<cfset var vault = structNew() />
		<cfset options.orderid = getTickCount() />
		<cfset options["store"] = token.getID() />
		
		<cfset response = gw.authorize(money = money, account = createValidCard(), options = options) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<cfset response = gw.purchase(money = money, account = token, options = options) />
		<cfset assertTrue(response.getSuccess(), "The token-based purchase did not succeed") />

	</cffunction>--->


	<!--- confirm authorize throws error --->
	<!---<cffunction name="testStoreAndUnstore" access="public" returntype="void" output="false">
	
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		<cfset var token = variables.svc.createToken(createUUID()) />

		<!--- try storing withOUT a populated token value --->
		<cfset response = gw.store(account = createValidCard(), options = options) />
		<cfset token.setID(response.getParsedResult().customer_vault_id) />
		<cfset assertTrue(response.getSuccess(), "The store did not succeed") />
		
		<cfset response = gw.unstore(account = token, options = options) />
		<cfset assertTrue(response.getSuccess(), "The unstore did not succeed") />

		<!--- try storing with a populated token value --->
		<cfset token = variables.svc.createToken(createUUID()) />
		<cfset options["store"] = token.getID() />
		<cfset response = gw.store(account = createValidCard(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The store did not succeed") />
		
		<cfset response = gw.unstore(account = token, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The unstore did not succeed") />

	</cffunction>--->
	

	<!--- confirm authorize throws error --->
	<!---JSB: EFT Not implemented yet.--->
	<!---<cffunction name="testAuthorizeThrowsException" access="public" returntype="void" output="false">
	
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		
		<!--- authorize will throw an error for e-check --->
		<cftry>
			<cfset response = gw.authorize(money = money, account = createValidEFT(), options = options) />
			<cfset assertTrue(false, "EFT authorize() should fail but did not") />
			<cfcatch type="cfpayment.MethodNotImplemented">
				<cfset assertTrue(true, "EFT authorize() threw cfpayment.MethodNotImplemented") />
			</cfcatch>
		</cftry>

	</cffunction>--->


	<cffunction name="testAuthorizeThenCapture" access="public" returntype="void" output="false"><!---ThenReport--->
	
		<cfset var account = createValidCard() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />
		<cfset var tid = "" />
		<cfset options.orderid = getTickCount() />
		

		<cfset response = gw.authorize(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<!--- braintree (like itransact), uses its own transaction/InternalID for capturing an authorization.  Is authorization even used by anyone? --->
		<cfset response = gw.capture(money = money, authorization = response.getTransactionId(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The capture did not succeed") />

		<!--- now run a detail report on this transaction --->
		<!---JSB: not implemented <cfset report = gw.status(transactionid = response.getTransactionID()) />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.getSuccess() AND NOT report.hasError(), "Successful transactionid should have success = true") />--->
		
		<!--- pass a non-existent id to see how error is handled --->
		<!---JSB: not implemented <cfset report = gw.status(transactionid = "11111111") />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.getSuccess() AND arrayLen(report.getParsedResult().xmlRoot.xmlChildren) EQ 0, "Invalid transactionid should result in no returned matches") />--->

		<!--- use a broken request to see how error is handled
		<cfset options["condition"] = 'unknown' />
		<cfset options["cc_number"] = '5454' />
		<cfset options["start_date"] = '2008-03-10' />
		<cfset options["end_date"] = '2008-03-08' />
		<cfset report = gw.status(options = options) />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.hasError(), "Invalid options should trigger a gateway failure (response code 3)") />
		--->

	</cffunction>


	<cffunction name="testAuthorizeThenCredit" access="public" returntype="void" output="false">
	
		<cfset var account = createValidCard() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />
		<cfset options.orderid = getTickCount() />

		
		<cfset response = gw.authorize(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<cfset response = gw.credit(money = money, transactionid = response.getTransactionID(), account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(NOT response.getSuccess(), "You cannot credit a preauth") />

	</cffunction>


	<cffunction name="testAuthorizeThenVoid" access="public" returntype="void" output="false">
	
		<cfset var account = createValidCard() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />
		<cfset options.orderid = getTickCount() />

		
		<cfset response = gw.authorize(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The authorization did not succeed") />

		<cfset response = gw.void(transactionid = response.getTransactionID(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can void a preauth") />

	</cffunction>
	
	
	<cffunction name="testPurchaseThenCredit" access="public" returntype="void" output="false">
	
		<cfset var account = createValidCard() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />
		<cfset options.orderid = getTickCount() />

		
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<cfset response = gw.credit(money = money, transactionid = response.getTransactionID(), account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can credit a purchase") />

	</cffunction>
	

	<cffunction name="testPurchaseThenVoid" access="public" returntype="void" output="false"><!---ThenReport--->
	
		<cfset var account = createValidCard() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />
		<cfset options.orderid = getTickCount() />

		
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<cfset response = gw.void(transactionid = response.getTransactionID(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can void a purchase") />

		<!---JSB: not implemented <cfset report = gw.status(transactionid = response.getTransactionID()) />
		<cfset debug(report.getMemento()) />
		<cfset assertTrue(report.getSuccess() AND arrayLen(report.getParsedResult().xmlRoot.xmlChildren) GT 0, "Transactionid should result in matches") />--->

	</cffunction>	

	<!---JSB: EFT Not implemented yet.--->
	<!---<cffunction name="testDirectDepositEFT" access="public" returntype="void" output="false">
	
		<cfset var account = createValidEFT() />
		<cfset var money = variables.svc.createMoney(500000) /><!--- in cents, $5000.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />

		<cfset response = gw.credit(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The direct deposit did not succeed") />

	</cffunction>--->
	
	<!---JSB: EFT Not implemented yet.--->
	<!---<cffunction name="testPurchaseThenVoidEFT" access="public" returntype="void" output="false">
	
		<cfset var account = createValidEFT() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		
		<!--- validate object --->
		<cfset assertTrue(account.getIsValid(), "EFT is not valid") />

		<!--- first try to purchase --->
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<!--- then try to void transaction --->
		<cfset response = gw.void(transactionid = response.getTransactionID(), options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The void did not succeed") />

	</cffunction>--->


	<!---JSB: EFT Not implemented yet.--->
	<!---<cffunction name="testPurchaseThenCreditEFT" access="public" returntype="void" output="false">
	
		<cfset var account = createValidEFT() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var report = "" />
		<cfset var options = structNew() />

		
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "The purchase did not succeed") />

		<cfset response = gw.credit(account = account, money = money, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "You can credit a purchase") />

	</cffunction>--->

<!---
	<cffunction name="testInvalidPurchases" access="public" returntype="void" output="false">
	
		<cfset var account = variables.svc.createCreditCard() />
		<cfset var money = variables.svc.createMoney(5000) /><!--- in cents, $50.00 --->
		<cfset var response = "" />
		<cfset var options = structNew() />
		
		<cfset account.setAccount(5454545454545451) />
		<cfset account.setMonth(12) />
		<cfset account.setYear(year(now())+1) />
		<cfset account.setVerificationValue(123) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("236 N. Santa Cruz Ave") />
		<cfset account.setPostalCode("95030") />
		
		<cfset options.ExternalID = createUUID() />

		<!--- 5451 card will result in an error --->
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(NOT response.getSuccess(), "The purchase did not fail with invalid CC") />

		<cfset account.setAccount(5454545454545454) />

		<!--- try invalid expiration --->
		<cfset account.setMonth(13) />
		<cfset account.setYear(year(now()) + 1) />
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(NOT response.getSuccess(), "The purchase did not fail with invalid expiration date") />

		<!--- try expired card --->
		<cfset account.setMonth(5) />
		<cfset account.setYear(year(now()) - 1) />
		<cfset response = gw.purchase(money = money, account = account, options = options) />
		<cfset debug(response.getMemento()) />
		<cfset assertTrue(response.getSuccess(), "iTransact gateway does not validate the expiration date so test gateway won't throw error; it is the acquiring bank's responsibility to validate/enforce it") />

	</cffunction>	
--->
	
	<cffunction name="testReport" access="public" returntype="void" output="false">
		<cfscript>
			var response = "";
			var report = "";
			var options = structNew();
			var dir = "";

			options.transactionFilter = 0;
			options.reportFileFormat = "pdf";
			options.reportFilePath = expandPath(".");
			options.reportStartDate = dateAdd("m", -1, now());
			options.reportEndDate = now();
				
			response = gw.report(reportType = "CreditCardDetailReport", options = options);
			debug(response.getMemento());
	
		</cfscript>
		<cfset response = response.getMemento()/>
		<cfif structKeyExists(response, "parsedResult")>
			<cftry>
				<cfdirectory directory="#response.parsedResult.track##response.parsedResult.CustCode#" action="list" name="dir" filter="#response.parsedResult.transID#" recurse="no"/>
				<cfcatch>
					<cfset assertTrue(false, "The report was not generated.") />
				</cfcatch>
			</cftry>

			<cfset assertTrue(dir.recordCount LTE 0, "The report was not found.") />
			<cfset debug("Report Generated as: #response.parsedResult.track##response.parsedResult.CustCode##response.parsedResult.transID#") />
			
			<cfif dir.recordCount>
				<cffile action="delete" file="#response.parsedResult.track##response.parsedResult.CustCode##response.parsedResult.transID#" />
			</cfif>
		<cfelse>
			<cfset assertTrue(false, "The report was NOT generated successfully.") />
		</cfif>
		
	</cffunction>

	<cffunction name="createValidCard" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.svc.createCreditCard() />
		<cfset account.setAccount(4387755555555550) />
		<cfset account.setMonth(12) />
		<cfset account.setYear("09") />
		<cfset account.setVerificationValue(999) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("8320 Main Street") />
		<cfset account.setPostalCode("85284") />

		<cfreturn account />	
	</cffunction>

	<cffunction name="createInvalidCard" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.svc.createCreditCard() />
		<cfset account.setAccount(4100000000000000) />
		<cfset account.setMonth(12) />
		<cfset account.setYear("09") />
		<cfset account.setVerificationValue(123) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("236 N. Santa Cruz") />
		<cfset account.setPostalCode("95030") />

		<cfreturn account />	
	</cffunction>

	<cffunction name="createValidCardWithoutCVV" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.svc.createCreditCard() />
		<cfset account.setAccount(4387755555555550) />
		<cfset account.setMonth(12) />
		<cfset account.setYear("09") />
		<cfset account.setVerificationValue() />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("8320 Main Street") />
		<cfset account.setPostalCode("85284") />

		<cfreturn account />	
	</cffunction>

	<cffunction name="createValidCardWithBadCVV" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.svc.createCreditCard() />
		<cfset account.setAccount(4387755555555550) />
		<cfset account.setMonth(12) />
		<cfset account.setYear("09") />
		<cfset account.setVerificationValue(111) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("8320 Main Street") />
		<cfset account.setPostalCode("85284") />

		<cfreturn account />	
	</cffunction>
	
	<cffunction name="createValidCardWithoutStreetMatch" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.svc.createCreditCard() />
		<cfset account.setAccount(4387755555555550) />
		<cfset account.setMonth(12) />
		<cfset account.setYear("09") />
		<cfset account.setVerificationValue(999) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("236 N. Santa Cruz") />
		<cfset account.setPostalCode("85284") />

		<cfreturn account />	
	</cffunction>

	<cffunction name="createValidCardWithoutZipMatch" access="private" returntype="any">
		<!--- these values simulate a valid card with matching avs/cvv --->
		<cfset var account = variables.svc.createCreditCard() />
		<cfset account.setAccount(4387755555555550) />
		<cfset account.setMonth(12) />
		<cfset account.setYear("09") />
		<cfset account.setVerificationValue(999) />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("8320 Main Street") />
		<cfset account.setPostalCode("95030") />

		<cfreturn account />	
	</cffunction>



	<!---<cffunction name="createValidEFT" access="private" returntype="any">
		<!--- these values simulate a valid eft with matching avs/cvv --->
		<cfset var account = variables.svc.createEFT() />
		<cfset account.setAccount("123123123") />
		<cfset account.setRoutingNumber("123123123") />
		<cfset account.setFirstName("John") />
		<cfset account.setLastName("Doe") />
		<cfset account.setAddress("236 N. Santa Cruz Ave") />
		<cfset account.setPostalCode("95030") />
		<cfset account.setPhoneNumber("415-555-1212") />
		
		<cfset account.setAccountType("checking") />

		<cfreturn account />	
	</cffunction>--->
	

</cfcomponent>
