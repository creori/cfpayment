<cfcomponent hint="Interacts with the Virtual Merchant Payment Gateway" output="false">
	
	<cffunction name="doProcess" output="true">
		<cfargument name="order" type="struct" required="false" default="">
		<cfargument name="customer" type="struct" default="">
		<cfargument name="merchant_id" type="string" required="true" default="">
		<cfargument name="user_id" type="string" required="true" default="">
		<cfargument name="pin" type="string" required="true" default="">
		<cfargument name="test_mode" type="string" required="false" default="false">
		<cfargument name="show_form" type="string" required="false" default="false">
		<cfargument name="transaction_type" type="string" required="false" default="ccsale">
		
		<cfset var stReturn = StructNew()>
		
		<cfif arguments.test_mode NEQ "false" AND arguments.test_mode NEQ "true">
			<cfset arguments.test_mode = "false">
		</cfif>
		<cfif arguments.show_form NEQ "false" AND arguments.show_form NEQ "true">
			<cfset arguments.show_form = "false">
		</cfif>
		<cfif NOT ListFindNoCase("CCSALE,CCAUTHONLY,CCCREDIT,CCBALINQUIRY",arguments.transaction_type)>
			<cfset arguments.transaction_type = "ccsale">
		</cfif>
		
		<cfhttp method="post" url="https://www.myvirtualmerchant.com/VirtualMerchant/process.do" timeout="60" throwonerror="true">
		
		<cfhttpparam type="formfield" name="ssl_merchant_id" value="#arguments.merchant_id#">
		<cfhttpparam type="formfield" name="ssl_user_id" value="#arguments.user_id#">
		<cfhttpparam type="formfield" name="ssl_pin" value="#arguments.pin#">
		<cfhttpparam type="formfield" name="ssl_show_form" value="#arguments.show_form#">
		<cfhttpparam type="formfield" name="ssl_test_mode" value="#arguments.test_mode#">
		<cfhttpparam type="formfield" name="ssl_transaction_type" value="#arguments.transaction_type#">
		<cfhttpparam type="formfield" name="ssl_customer_code" value="1111">
		
		<cfhttpparam type="formfield" name="ssl_first_name" value="#arguments.customer.firstName#">
		<cfhttpparam type="formfield" name="ssl_last_name" value="#arguments.customer.lastName#">
		<cfhttpparam type="formfield" name="ssl_avs_address" value="#arguments.customer.address1#">
		<cfhttpparam type="formfield" name="ssl_address2" value="#arguments.customer.address2#">
		<cfhttpparam type="formfield" name="ssl_city" value="#arguments.customer.city#">
		<cfhttpparam type="formfield" name="ssl_state" value="#arguments.customer.state#">
		<cfhttpparam type="formfield" name="ssl_avs_zip" value="#arguments.customer.zip#">
		<cfhttpparam type="formfield" name="ssl_phone" value="#arguments.customer.dayPhone#">
		<cfhttpparam type="formfield" name="ssl_email" value="#arguments.customer.email#">
		
		<cfhttpparam type="formfield" name="ssl_ship_to_first_name" value="#arguments.customer.firstName#">
		<cfhttpparam type="formfield" name="ssl_ship_to_last_name" value="#arguments.customer.lastName#">
		<cfhttpparam type="formfield" name="ssl_ship_to_address1" value="#arguments.customer.shipaddress1#">
		<cfhttpparam type="formfield" name="ssl_ship_to_address2" value="#arguments.customer.shipaddress2#">
		<cfhttpparam type="formfield" name="ssl_ship_to_city" value="#arguments.customer.shipcity#">
		<cfhttpparam type="formfield" name="ssl_ship_to_state" value="#arguments.customer.shipstate#">
		<cfhttpparam type="formfield" name="ssl_ship_to_zip" value="#arguments.customer.shipzip#">
		<cfhttpparam type="formfield" name="ssl_ship_to_phone" value="#arguments.customer.shipdayphone#">
		
		
		<cfhttpparam type="formfield" name="ssl_invoice_number" value="#arguments.order.invoice#">
		<cfhttpparam type="formfield" name="ssl_amount" value="#arguments.order.cartTotal#">
		<cfhttpparam type="formfield" name="ssl_salestax" value="#arguments.order.taxvalue1+arguments.order.taxvalue2#">
		<cfhttpparam type="formfield" name="ssl_card_number" value="#arguments.order.ccnumber#">
		<cfhttpparam type="formfield" name="ssl_cvv2cvc2_indicator" value="1">
		<cfhttpparam type="formfield" name="ssl_cvv2cvc2" value="#arguments.order.cccvv2#">
		<cfhttpparam type="formfield" name="ssl_exp_date" value="#arguments.order.ccmonth##Right(arguments.order.ccyear,2)#">
		
		<cfhttpparam type="formfield" name="ssl_result_format" value="ASCII">
		<cfhttpparam type="formfield" name="ssl_receipt_link_method" value="POST">
		</cfhttp>
		
		<cfset stReturn = convertResponse(trim(cfhttp.fileContent))>
		<cfset stReturn.originalFileContent = cfhttp.FileContent>
		<cfreturn stReturn>
	</cffunction>
	
	
	
	<cffunction name="convertResponse" returntype="struct" access="private">
		<cfargument name="response" default="" required="true" type="string">
		
		<cfset var stReturn = StructNew()>
		
		<cfloop from="1" to="#ListLen(response,Chr(10))#" step="1" index="i">
			<cfset stReturn[trim(ListFirst(ListGetAt(response,i,Chr(10)),'='))] = trim(ListLast(ListGetAt(response,i,Chr(10)),'='))/>
		</cfloop>
		
		<cfreturn stReturn/>
	</cffunction>

</cfcomponent>