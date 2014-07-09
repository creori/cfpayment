<!--- Authorize.net AIM wrapper. --->
<!--- by j.blossom, creori, inc. --->

<!---
Sample call:
		<cf_authorizenet
			mode="LIVE"
			login="6YMf8r2v"
			transKey="6A2p2W6jvQ895B3Q"
			method="CC"
			type="AUTH_CAPTURE"
			amount="#NumberFormat(getorder.total,"_______.__")#"
			cardNum="#Decrypt(getorder.cardnum,"@w1n3$5Tadsf^$BKJDF877good_wine+870r3!")#"
			cardExp="#right(getorder.expmonth, 2)#/#right(getorder.expyear, 2)#"
			
			invoiceNum="#getorder.order_id#"
			description="WineCask Online Store"
			custNum="#getcore.core_id#"
		>
--->

<!--- setup custom tag props --->
<!--- Required --->
<cfparam name="attributes.mode" default="test" />
<cfparam name="attributes.login" default="" />
<cfparam name="attributes.transKey" default="" />
<cfparam name="attributes.method" default="CC" />
<cfparam name="attributes.type" default="AUTH_CAPTURE" />
<cfparam name="attributes.amount" default="0" />
<cfparam name="attributes.cardNum" default="4111111111111111" />
<cfparam name="attributes.cardExp" default="05/09" />
<!--- Optional --->
<cfparam name="attributes.invoiceNum" default="0" />
<cfparam name="attributes.description" default="" />
<cfparam name="attributes.custNum" default="0" />
<cfparam name="attributes.phone" default="" />
<!--- Config Values. (Optional) --->
<cfparam name="attributes.useDelimeter" default="true" />
<cfparam name="attributes.delimeter" default="|" />
<cfparam name="attributes.relayUserInfo" default="false" />

<cfhttp url="https://#iif(attributes.mode EQ "LIVE", de("secure"), de("test"))#.authorize.net/gateway/transact.dll" method="post" delimiter="," resolveurl="no">
	<!---
		Uncomment the line ABOVE for test accounts or BELOW for live merchant accounts
		<cfhttp method="post" url="https://secure.authorize.net/gateway/transact.dll">
		First, we pass the required fields for this particular transaction type (CC/AUTH_CAPTURE)
	--->
	<cfhttpparam name="x_login" type="formfield" value="#attributes.login#">
	<cfhttpparam name="x_tran_key" type="formfield" value="#attributes.transKey#">
	<cfhttpparam name="x_method" type="formfield" value="#attributes.method#">
	<cfhttpparam name="x_type" type="formfield" value="#attributes.type#">
	<cfhttpparam name="x_amount" type="formfield" value="#attributes.amount#">
	<cfhttpparam name="x_delim_data" type="formfield" value="#attributes.useDelimeter#">
	<cfhttpparam name="x_delim_char" type="formfield" value="#attributes.delimeter#">
	<cfhttpparam name="x_relay_response" type="formfield" value="#attributes.relayUserInfo#">
	<cfhttpparam name="x_card_num" type="formfield" value="#attributes.cardNum#">
	<cfhttpparam name="x_exp_date" type="formfield" value="#attributes.cardExp#">

	<!---
		Now we can add any of the optional-but-not-required fields.
	
		IMPORTANT: Although you could -- in theory --  set x_version to "3.0"
		we strongly urge you not to do so. By default, x_version is set to "3.1"
		(and that corresponds to the most recent documentation).
	
		If you change x_version, the following code will not produce the
		expected results, since the gateway response structure will be
		very different.
	
		For specific information about the 3.1 gateway response API, please
		see the AIM Guide at:
			http://www.authorizenet.com/support/AIM_guide.pdf
		or
			http://www.authorizenet.com/support/AIM_guide_SCC.pdf
			(specifically for shopping cart solutions)
	--->
	<cfhttpparam name="x_version" type="formfield" value="3.1">
	
	<cfhttpparam name="x_invoice_num" type="formfield" value="#attributes.invoiceNum#">
	<cfhttpparam name="x_description" type="formfield" value="#attributes.description#">
	<cfhttpparam name="x_cust_id" type="formfield" value="#attributes.custNum#">
	<cfhttpparam name="x_phone" type="formfield" value="#attributes.phone#">
	
	<!---
		And we can also pass merchant-defined fields.
	
		NOTE: Only the values of merchant-defined fields will be returned
		in the Authorize.Net gateway response "as is" -- meaning, only the
		value of those fields will get returned WITHOUT the name.
		Therefore, it's a good idea to add the description (or some kind
		of code) to the value, since that will help you identify the
		response for further processing.
	
		Of course, since YOU are passing the merchant-defined fields, you
		might as well capture their values BEFORE submitting the transaction
		(and thereby keep the passed string as "slim and trim" as possible).
	
		IMPORTANT: On the e-mail receipt for this transaction, however, the
		name of the merchant-defined field, as well as the value will be listed.
	--->
	<!--- <cfhttpparam name="custField_01" type="formfield" value="Promotion: Spring Sale">
	<cfhttpparam name="custField_02" type="formfield" value="Custom Data String: abcdefghijklmnopqrstuvwxyz0123456789"> --->
</cfhttp>

<!--- Process the Authorize.Net Gateway Response: --->
<cfscript>
	// Do the Bit.
	caller.res = cfhttp;
	caller.aim_response = cfhttp.FileContent;
	caller.results = parseResponse(cfhttp.FileContent);

	// Make a pretty struct from the response fields.
	function parseResponse(response) {
		var results = structNew();
		
		response = JavaCast('string', response).split("\|");
		
		results = insertResult(results, response, "1", "Response Code", "x_resp_code", "Error");
		results = insertResult(results, response, "2", "Response Subcode", "x_resp_subcode", "-1");
		results = insertResult(results, response, "3", "Response Reason Code:", "x_reason_code", "-1");
		results = insertResult(results, response, "4", "Response Reason Text", "x_reason_text", "There was an unknown parsing or processing error.");
		results = insertResult(results, response, "5", "Approval Code", "x_approval_code", "");
		results = insertResult(results, response, "6", "AVS Result Code", "x_AVS_code", "");
		results = insertResult(results, response, "7", "Transaction ID", "x_trans_ID", "-1");
		results = insertResult(results, response, "8", "Invoice Number", "x_invoice_num", "");
		results = insertResult(results, response, "9", "Description", "x_description", "");
		results = insertResult(results, response, "10", "Amount", "x_amount", "");
		results = insertResult(results, response, "11", "Method", "x_method", "");
		results = insertResult(results, response, "12", "Transaction Type", "x_type", "");
		results = insertResult(results, response, "13", "Customer ID", "x_cust_id", "");
		results = insertResult(results, response, "14", "Cardholder First Name", "x_first_name", "");
		results = insertResult(results, response, "15", "Cardholder Last Name", "x_last_name", "");
		results = insertResult(results, response, "16", "Company", "x_company", "");
		results = insertResult(results, response, "17", "Billing Address", "x_address", "");
		results = insertResult(results, response, "18", "City", "x_city", "");
		results = insertResult(results, response, "19", "State", "x_state", "");
		results = insertResult(results, response, "20", "ZIP", "x_zip", "");
		results = insertResult(results, response, "21", "Country", "x_country", "");
		results = insertResult(results, response, "22", "Phone", "x_phone", "");
		results = insertResult(results, response, "23", "Fax", "x_fax", "");
		results = insertResult(results, response, "24", "E-Mail", "x_email", "");
		results = insertResult(results, response, "25", "Ship-to First Name", "x_ship_to_first_name", "");
		results = insertResult(results, response, "26", "Ship-to Last Name", "x_ship_to_last_name", "");
		results = insertResult(results, response, "27", "Ship-to Company", "x_ship_to_company", "");
		results = insertResult(results, response, "28", "Ship-to Address", "x_ship_to_address", "");
		results = insertResult(results, response, "29", "Ship-to City", "x_ship_to_city", "");
		results = insertResult(results, response, "30", "Ship-to State", "x_ship_to_state", "");
		results = insertResult(results, response, "31", "Ship-to ZIP", "x_ship_to_zip", "");
		results = insertResult(results, response, "32", "Ship-to Country", "x_ship_to_country", "");
		results = insertResult(results, response, "33", "Tax Amount", "x_tax", "");
		results = insertResult(results, response, "34", "Duty Amount", "x_duty", "");
		results = insertResult(results, response, "35", "Freight Amount", "x_freight", "");
		results = insertResult(results, response, "36", "Tax Exempt Flag", "x_tx_exempt", "");
		results = insertResult(results, response, "37", "PO Number", "x_po_num", "");
		results = insertResult(results, response, "38", "MD5 Hash:", "x_MD5_Hash", "");
		results = insertResult(results, response, "39", "Card Code Response", "x_card_code_resp", "");
		/*results = insertResult(results, response, "40", "Reserved for future use", "x_future_40", "");
		results = insertResult(results, response, "41", "Reserved for future use", "x_future_41", "");
		results = insertResult(results, response, "42", "Reserved for future use", "x_future_42", "");
		results = insertResult(results, response, "43", "Reserved for future use", "x_future_43", "");
		results = insertResult(results, response, "44", "Reserved for future use", "x_future_44", "");
		results = insertResult(results, response, "45", "Reserved for future use", "x_future_45", "");
		results = insertResult(results, response, "46", "Reserved for future use", "x_future_46", "");
		results = insertResult(results, response, "47", "Reserved for future use", "x_future_47", "");
		results = insertResult(results, response, "48", "Reserved for future use", "x_future_48", "");
		results = insertResult(results, response, "49", "Reserved for future use", "x_future_49", "");
		results = insertResult(results, response, "50", "Reserved for future use", "x_future_50", "");
		results = insertResult(results, response, "51", "Reserved for future use", "x_future_51", "");
		results = insertResult(results, response, "52", "Reserved for future use", "x_future_52", "");
		results = insertResult(results, response, "53", "Reserved for future use", "x_future_53", "");
		results = insertResult(results, response, "54", "Reserved for future use", "x_future_54", "");
		results = insertResult(results, response, "55", "Reserved for future use", "x_future_55", "");
		results = insertResult(results, response, "56", "Reserved for future use", "x_future_56", "");
		results = insertResult(results, response, "57", "Reserved for future use", "x_future_57", "");
		results = insertResult(results, response, "58", "Reserved for future use", "x_future_58", "");
		results = insertResult(results, response, "59", "Reserved for future use", "x_future_59", "");
		results = insertResult(results, response, "60", "Reserved for future use", "x_future_60", "");
		results = insertResult(results, response, "61", "Reserved for future use", "x_future_61", "");
		results = insertResult(results, response, "62", "Reserved for future use", "x_future_62", "");
		results = insertResult(results, response, "63", "Reserved for future use", "x_future_63", "");
		results = insertResult(results, response, "64", "Reserved for future use", "x_future_64", "");
		results = insertResult(results, response, "65", "Reserved for future use", "x_future_65", "");
		results = insertResult(results, response, "66", "Reserved for future use", "x_future_66", "");
		results = insertResult(results, response, "67", "Reserved for future use", "x_future_67", "");
		results = insertResult(results, response, "68", "Reserved for future use", "x_future_68", "");*/
		results = insertResult(results, response, "69", "Merchant defined value", "x_merchant_69", "");
		results = insertResult(results, response, "70", "Merchant defined value", "x_merchant_70", "");
	
		return results;	
	}


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
</cfscript>

