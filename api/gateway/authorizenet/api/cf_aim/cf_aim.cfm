<!--

###########################################################
#                                                         #
#  D O C U M E N T A T I O N                              #
#                                                         #
#  This code sample has been successfully tested on       #
#  third-party web servers and performed according to     #
#  documented Advanced Integration Method (AIM)           #
#  standards.                                             #
#                                                         #
#  Last updated September 2004.                           #
#                                                         #
#  For complete and freely available documentation,       #
#  please visit the Authorize.Net web site at:            #
#                                                         #
#  http://www.authorizenet.com/support/guides.php         #
#                                                         #
###########################################################

###########################################################
#                                                         #
#  D I S C L A I M E R                                    #
#                                                         #
#  WARNING: ANY USE BY YOU OF THE SAMPLE CODE PROVIDED    #
#  IS AT YOUR OWN RISK.                                   #
#                                                         #
#  Authorize.Net provides this code "as is" without       #
#  warranty of any kind, either express or implied,       #
#  including but not limited to the implied warranties    #
#  of merchantability and/or fitness for a particular     #
#  purpose.                                               #
#                                                         #
#                                                         #
###########################################################

###########################################################
#                                                         #
#  RUNNING COLDFUSION ON AN IIS SERVER?                   #
#  M I S C    C O M P A T I B I L I T Y    I S S U E S    #
#                                                         #
#  This sample code has not been tested on ColdFusion     #
#  installations on IIS.                                  #
#                                                         #
#  The Authorize.Net ColdFusion AIM sample code was       #
#  developed to run on a bona-fide ColdFusion server,     #
#  not on IIS.                                            #
#                                                         #
#  If you are running ColdFusion on IIS, and if you       #
#  encounter error messages that point to a directory     #
#  path that includes "\InetPub\," you will have to deal  #
#  with a number of compatibility issues -- depending on  #
#  the version of Windows and/or IIS you are running.     #
#                                                         #
#=========================================================#
#  In an effort to be up-to-date with the majority of     #
#  ColdFusion developers, our ColdFusion sample code is   #
# based on ColdFusion MX.                                 #
#=========================================================#
#                                                         #
#  This is significant, because different versions of     #
#  ColdFusion, Windows and IIS may cause a number of      #
#  documented and undocumented compatibility issues.      #
#                                                         #
#  To test and verify the ColdFusion implementation,      #
#  access the ColdFusion administration home page on      #
#  your system (typically located at an URL similar to    #
#  http://name_of_your_COLDFUSION_local_host/CFIDE/       #
#  administrator/index.cfm) and then:                     #
#                                                         #
#  1) Verify all Server Settings (located at the top of   #
#  the left column), paying special attention to the      #
#  Mappings section (as your ColdFusion server needs to   #
#  be referenced properly to be recognized by .CFM        #
#  pages).                                                #
#                                                         #
#  2) Analyze and/or troubleshoot the Version Information #
#  (by clicking the link at the top of the page).         #
#                                                         #
#  Since we cannot anticipate every potential             #
#  e-commerce developer's platform, server                #
#  configuration and server versions, we do not provide   #
#  any troubleshooting assistance for any of our code     #
#  samples.                                               #
#                                                         #
#  If you need to get the AIM ColdFusion code sample      #
#  to work on your specific IIS web server, please refer  #
#  to both IIS and ColdFusion reference materials for     #
#  assistance.                                            #
#                                                         #
#                                                         #
###########################################################

###########################################################
#                                                         #
#  C O L D   F U S I O N   D E V E L O P E R S            #
#                                                         #
#  The provided sample code is merely a blue print,       #
#  demonstrating one possible approach to making AIM      #
#  work, by way of performing the required HTTPS POST     #
#  operation.                                             #
#                                                         #
#  1. This sample code is not a tutorial. If you are      #
#  unfamiliar with specific programming functions and     #
#  concepts, please consult the necessary reference       #
#  materials.                                             #
#                                                         #
#  2. This sample code is provided "as is," meaning that  #
#  we will not be able to assist individual e-commerce    #
#  developers with specific programming issues, relating  #
#  to the availability or non-availability of specific    #
#  modules, code libraries or other requirements to make  #
#  this code work on your specific web server             #
#  configuration.                                         #
#                                                         #
#  3. If you cannot get this sample code to work, please  #
#  do not contact Authorize.Net to complain. However, if  #
#  you encounter specific issues and would like to find   #
#  out what you can do to resolve a specific problem, we  #
#  would be happy to help you find a suitable solution    #
#  if time allows and if resources are available. We do   #
#  not promise, however, that we will be able to solve    #
#  your programming problems nor do we make any           #
#  guarantees or promises -- either express or            #
#  implied -- that we will even attempt to address any    #
#  programming issues that anyone encounters using our    #
#  sample code.                                           #
#                                                         #
#  Again, this sample code merely serves as blue print    #
#  for e-commerce developers who either are inexperienced #
#  performing HTTP POST operations or simply want an      #
#  example of how other developers have dealt with this   #
#  challenge in the past.                                 #
#                                                         #
#                                                         #
###########################################################

###########################################################
#                                                         #
#  P R E R E Q U I S I T E S                              #
#                                                         #
#  To submit any kind of transaction (even test           #
#  transactions) to Authorize.Net, you need to provide    #
#  valid Authorize.Net account information (a merchant    #
#  log-in ID and a valid merchant transaction key).       #
#                                                         #
#                                                         #
###########################################################

###########################################################
#                                                         #
#  C O N T A C T    I N F O R M A T I O N                 #
#                                                         #
#  For specific questions,                                #
#  please contact Authorize.Net's Integration Services:   #
#                                                         #
#  integration at authorize dot net                       #
#                                                         #
#  Please remember that we cannot support individual      #
#  e-commerce developers with programming problems and    #
#  other issues that could be easily solved by referring  #
#  to the available reference materials.                  #
#                                                         #
###########################################################

###########################################################
#                                                         #
#  A I M   I N   A   N U T S H E L L                      #
#                                                         #
###########################################################
#                                                         #
#  1. You gather all the required transaction data on     #
#  your secure web site.                                  #
#                                                         #
#  2. The transaction data gets submitted (via HTTPS      #
#  POST) to Authorize.Net as one long string, consisting  #
#  of specific name/value pairs.                          #
#                                                         #
#  3. When performing the HTTPS POST operation, you       #
#  remain on the same web page from which you’ve          #
#  performed the operation.                               #
#                                                         #
#  4. Authorize.Net immediately returns a transaction     #
#  response string to the same web page from which you    #
#  have performed the HTTPS POST operation.               #
#                                                         #
#  5. You may then parse the response string and act      #
#  upon certain response criteria, according to your      #
#  business needs.                                        #
#                                                         #
#                                                         #
###########################################################


-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Basic AIM Example in ColdFusion</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css" media="all">
<!--
BODY {
	background-color: #ffffff;
	font-family: Arial, Verdana, Helvetica, Geneva, sans-serif;
	font-size: 8pt;
}
TD {
	font-family: Arial, Verdana, Helvetica, Geneva, sans-serif;
	font-size: 12px;
}
.small {
	font-family: Arial, Verdana, Helvetica, Geneva, sans-serif;
	font-size: 10px;
}
.copy {
	font-family: Arial, Verdana, Helvetica, Geneva, sans-serif;
	font-size: 12px;
}
-->
</style>
</head>
<body marginheight="0" marginwidth="10" topmargin="10" leftmargin="10" rightmargin="10" link="#73757B" vlink="#73757B" alink="#73757B" bgcolor="#ffffff">
<center>
	<div align="center">
	<!---  TABLE 01  --->
	<table width="700" border="0" cellpadding="1" cellspacing="0">
		<tr>
		
		<td>
		
		<!---  INTERRUPT TABLE 01  --->
		<!---  TABLE 02  --->
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td background="images/dash_gray_h.gif" colspan="3"><img src="images/z.gif" width="1" height="1" alt="" /></td>
			</tr>
			<tr>
			
			<td background="images/dash_gray_v.gif"><img src="images/z.gif" width="1" height="55" alt="" /></td>
			<td bgcolor="#ffffff">
			
			<!---  INTERRUPT TABLE 02  --->
			<!---  TABLE 03  --->
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#ffffff">
				<tr>
					<td><img src="images/background_01_999.gif" width="64" height="55" alt="" /></td>
					<td bgcolor="#DADADA"><img src="images/z.gif" width="1" height="55" alt="" /></td>
					<td><img src="images/background_02_999.gif" width="149" height="55" alt="" /></td>
					<td bgcolor="#DADADA"><img src="images/z.gif" width="1" height="55" alt="" /></td>
					<td><img src="images/z.gif" width="385" height="55" alt="" /></td>
				</tr>
				<tr>
					<td colspan="5" bgcolor="#F7941D"><img src="images/z.gif" width="600" height="1" alt="" /></td>
				</tr>
			</table>
			<!---  END OF TABLE 03  --->
			<!--- --------------------------------------------------------------------------------------------------------------------  --->
			<!---  TABLE 04  --->
			<table cellpadding="10" cellspacing="0" border="0" width="100%">
				<tr valign="top">
					<td><img src="images/sb_intro.gif" width="150" height="20" border="0" alt=""></td>
					<td><!---  INTERRUPT TABLE 04  --->
						<div class="copy">
							<p class="copy"><strong>ColdFusion Example:</strong><br>
								Advanced Integration Method (AIM)<br>
								Last updated: April 2003<br>
								<br>
								This is a working example of a basic Authorize.Net Advanced Integration Method (AIM) transaction, using ColdFusion.<br>
								<br>
								<strong>The premise:</strong><br>
								Let's jump right in. For the purpose of this demonstration, we presume that the order information (which products did the customer purchase, what's the total price, etc.) and the payment information (what's the credit card number and expiration date) has already been collected elsewhere on a secure web site.<br>
								<br>
								<strong>The task at hand:</strong><br>
								All that's left to do is to submit that information to Authorize.Net for payment processing.<br>
							</p>
							<!--- --------------------------------------------------------------------------- --->
						</div></td>
				</tr>
				<tr valign="top">
					<td><img src="images/sb_howto.gif" width="150" height="20" border="0" alt=""></td>
					<td class="copy"><div class="copy">
							<!--- --------------------------------------------------------------------------- --->
							<strong>How do I do that?</strong><br>
							Here's an example of how to do just that, using an Authorize.Net Credit Card AUTH_CAPTURE transaction, according to the Advanced Integration Method (AIM).<br>
							<br>
							<br>
						</div>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#006600">&lt;!-- <br>
							ColdFusion has a built-in tag (CFHTTP) to do HTTP POST operations &#8212; and that tag accommodates the AIM requirements<br>
							--&gt;</font><br>
							<br>
							<font color="#990000"><b>&lt;cfhttp method="post" url="https://test.authorize.net/gateway/transact.dll"&gt;</b></font><br>
							<br>
							<font color="#006600">&lt;!-- <br>
							First, we pass the required fields for this particular transaction type (CC/AUTH_CAPTURE), using the CFHTTPPARAM tag for each value<br>
							--&gt;</font><br>
							<br>
							<font color="#990000"><strong>&lt;cfhttpparam name="x_login"
							type="formfield" value="enter_your_login_ID"&gt;<br>
							&lt;cfhttpparam name="x_tran_key" type="formfield" value="doXaEm2QUnz2OiyQ"&gt;<br>
							&lt;cfhttpparam name="x_method" type="formfield" value="CC"&gt;<br>
							&lt;cfhttpparam name="x_type" type="formfield" value="AUTH_CAPTURE"&gt;<br>
							&lt;cfhttpparam name="x_amount" type="formfield" value="19.99"&gt;<br>
							&lt;cfhttpparam name="x_delim_data" type="formfield" value="TRUE"&gt;<br>
							&lt;cfhttpparam name="x_delim_char" type="formfield" value="|"&gt;<br>
							&lt;cfhttpparam name="x_relay_response" type="formfield" value="FALSE"&gt;<br>
							&lt;cfhttpparam name="x_card_num" type="formfield" value="4111111111111111"&gt;<br>
							&lt;cfhttpparam name="x_exp_date" type="formfield" value="05/09"&gt;<br>
							</strong></font> <br>
							<font color="#006600">&lt;!-- <br>
							NOTE: The transaction key in this code example is (for security reasons) not a current transaction key.<br>
							--&gt;</font><br>
							<br>
							<font color="#006600">&lt;!-- <br>
							Now we can add any of the optional-but-not-required fields. <br>
							<br>
							IMPORTANT: Although you could -- in theory -- set x_version to "3.0" we strongly urge you not to do so. By default, x_version should be set to "3.1" (please, check the Authorize.Net Merchant Interface for your account -- even if it is "only" a test account). <br>
							<br>
							If you change x_version to anything other than 3.1, the following code will not produce the expected results, since the gateway response structure will be very different. For specific information about the 3.1 gateway response API, please see the AIM Guide at:<br>
							<br>
							http://www.authorizenet.com/support/AIM_guide.pdf<br>
							<br>
							or<br>
							<br>
							http://www.authorizenet.com/support/AIM_guide_SCC.pdf <br>
							(this guide is specifically for shopping cart solutions)<br>
							--&gt;</font><br>
							<br>
							<font color="#990000"><strong>&lt;cfhttpparam name="x_version" type="formfield" value="3.1"&gt;<br>
							&lt;cfhttpparam name="x_invoice_num" type="formfield" value="041803-001"&gt; <br>
							&lt;cfhttpparam name="x_description" type="formfield" value="ColdFusion: Simple AIM Example"&gt;<br>
							&lt;cfhttpparam name="x_cust_id" type="formfield" value="SuperStore 007"&gt; <br>
							</strong></font> <br>
							<font color="#006600">&lt;!-- <br>
							And we can also pass merchant-defined fields.<br>
							<br>
							NOTE: Only the values of merchant-defined fields will be returned in the Authorize.Net gateway response WITHOUT the name. Therefore, if you plan on evaluating those values in your resonse processing script, it would be a good idea to do one of two things:<br>
							<br>
							1) Add a description (or some kind of code) to the value, so that you can identify the returned response for further processing.<br>
							2) Adhere to some kind of standard, so that you know precisely in which order your merchant-defined fields get sent to (and consequently returned from) the Authorize.Net gateway. <br>
							<br>
							Of course, since YOU are passing the merchant-defined fields, you might as well capture their values BEFORE submitting the transaction (and thereby keep the passed string as "slim and trim" as possible).<br>
							<br>
							IMPORTANT: On the e-mail receipt for this transaction, however, the name of the merchant-defined field, as well as the value will be listed.<br>
							<br>
							--&gt;</font><br>
							<br>
							<font color="#990000"><strong>&lt;cfhttpparam name="custField_01" type="formfield" value="Promotion: Spring Sale"&gt;<br>
							&lt;cfhttpparam name="custField_02" type="formfield" value="Custom Data String: abcdefghijklmnopqrstuvwxyz0123456789"&gt;</strong></font><br>
							<br>
							<font color="#006600">&lt;!--- <br>
							Close the CFHTTP tag<br>
							---&gt;</font> <br>
							<font color="#990000"><strong>&lt;/cfhttp&gt;</strong></font><br>
							<br>
							<font color="#006600">&lt;!--- <br>
							Capture the Authorize.Net Gateway Response in a variable for further processing:<br>
							---&gt;<br>
							</font> <font color="#990000"><strong>&lt;cfset api_response=cfhttp.fileContent&gt;</strong></font><br>
							<br>
							</CODE> </div>
						<br>
						<br>
						<cfhttp method="post" url="https://test.authorize.net/gateway/transact.dll">
							<!--- Uncomment the line ABOVE for test accounts or BELOW for live merchant accounts --->
							<!--- <cfhttp method="post" url="https://secure.authorize.net/gateway/transact.dll"> --->
							<!--
								First, we pass the required fields for this particular transaction type (CC/AUTH_CAPTURE)
							-->
							<cfhttpparam name="x_login" type="formfield" value="enter_your_login_ID">
							<cfhttpparam name="x_tran_key" type="formfield" value="eoXaEm2LUnz2OiyQ">
							<cfhttpparam name="x_method" type="formfield" value="CC">
							<cfhttpparam name="x_type" type="formfield" value="AUTH_CAPTURE">
							<cfhttpparam name="x_amount" type="formfield" value="19.99">
							<cfhttpparam name="x_delim_data" type="formfield" value="TRUE">
							<cfhttpparam name="x_delim_char" type="formfield" value="|">
							<cfhttpparam name="x_relay_response" type="formfield" value="FALSE">
							<cfhttpparam name="x_card_num" type="formfield" value="4111111111111111">
							<cfhttpparam name="x_exp_date" type="formfield" value="05/05">
							<!--
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
							
							-->
							<cfhttpparam name="x_version" type="formfield" value="3.1">
							<cfhttpparam name="x_invoice_num" type="formfield" value="041803-001">
							<cfhttpparam name="x_description" type="formfield" value="ColdFusion: Simple AIM Example">
							<cfhttpparam name="x_cust_id" type="formfield" value="SuperStore 007">
							<!--
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
							
							-->
							<cfhttpparam name="custField_01" type="formfield" value="Promotion: Spring Sale">
							<cfhttpparam name="custField_02" type="formfield" value="Custom Data String: abcdefghijklmnopqrstuvwxyz0123456789">
						</cfhttp>
						<!--- -   Process the Authorize.Net Gateway Response:   - --->
						<cfset api_response = cfhttp.fileContent>
						<!--- --------------------------------------------------------------------------- --->
				</div>
				
				</td>
				
				</tr>
				
				<tr valign="top">
					<td><img src="images/sb_httpost.gif" width="150" height="20" border="0" alt=""></td>
					<td class="copy"><div class="copy">
							<!--- --------------------------------------------------------------------------- --->
							<p class="copy"> <strong>Now what?</strong><br>
								When executing a POST operation by way of HTTP, Authorize.Net will immediately process the transaction. If all of the submitted information is valid and can be verified, Authorize.Net will process the payment information accordingly. As soon as that's done (usually after a few seconds), Authorize.Net will send back &#8212; by way of HTTP &#8212; a gateway response string.<br>
								<br>
								If there is a problem, you'll get some indication of the problem's cause in the gateway response as well.<br>
								<br>
								<strong>What is the Authorize.Net Gateway Response string?</strong><br>
								Basically, the gateway response string is a text string, separated by a character that you can define when you submit payment information to Authorize.Net.<br>
								<br>
							<table width="100%" border="0" cellspacing="0" cellpadding="1" bgcolor="#eeeeee">
								<tr>
									<td colspan="2">The string contains:<br></td>
								</tr>
								<tr>
									<td colspan="2" bgcolor="#ffffff" align="center"><img src="images/z.gif" width="100" height="3" alt="" /></td>
								</tr>
								<tr>
									<td>&#8226;&nbsp;</td>
									<td>some standard information that Authorize.Net uses to inform you of the status of the transaction (values 1 through 7)</td>
								</tr>
								<tr>
									<td colspan="2" bgcolor="#ffffff" align="center"><img src="images/z.gif" width="100" height="1" alt="" /></td>
								</tr>
								<tr>
									<td>&#8226;&nbsp;</td>
									<td>"echoes" of transaction-specific information you submitted (values 8 through 37)</td>
								</tr>
								<tr>
									<td colspan="2" bgcolor="#ffffff" align="center"><img src="images/z.gif" width="100" height="1" alt="" /></td>
								</tr>
								<tr>
									<td>&#8226;&nbsp;</td>
									<td>a system-generated MD5 hash that merchants can use to authenticate transactions (value 38)</td>
								</tr>
								<tr>
									<td colspan="2" bgcolor="#ffffff" align="center"><img src="images/z.gif" width="100" height="1" alt="" /></td>
								</tr>
								<tr>
									<td>&#8226;&nbsp;</td>
									<td>the results of the card-code verification (value 39)</td>
								</tr>
								<tr>
									<td colspan="2" bgcolor="#ffffff" align="center"><img src="images/z.gif" width="100" height="1" alt="" /></td>
								</tr>
								<tr>
									<td>&#8226;&nbsp;</td>
									<td>values (currently blank) that are reserved for future use (values 40 through 68)</td>
								</tr>
								<tr>
									<td colspan="2" bgcolor="#ffffff" align="center"><img src="images/z.gif" width="100" height="1" alt="" /></td>
								</tr>
								<tr>
									<td>&#8226;&nbsp;</td>
									<td>"echoes" of merchant-defined fields (values 69+)</td>
								</tr>
							</table>
							<br>
							</p>
							<!--- --------------------------------------------------------------------------- --->
						</div></td>
				</tr>
				<tr valign="top">
				
				<td><img src="images/sb_response.gif" width="150" height="20" border="0" alt=""></td>
				<td class="copy"><div class="copy">
						<!--- --------------------------------------------------------------------------- --->
						<p class="copy"> <strong>Example of an actual Authorize.Net Gateway Response:</strong><br>
							<br>
							<cfoutput>#api_response#</cfoutput> </p>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#006600">&lt;!-- <br>
							Authorize.Net Gateway Response &#8212; output from a CF variable:<br>
							--&gt;</font><br>
							<br>
							<font color="#990000"><strong>&lt;cfoutput&gt;#api_response#&lt;/cfoutput&gt;</strong></font><br>
							<br>
							</CODE> </div>
						<br>
						<br>
						<strong>Parsing the returned Authorize.Net gateway response string:</strong><br>
						There are several ways in which you can display and process the returned string from the Authorize.Net Gateway.<br>
						<br>
						One very simple way to parse through the string and list all values, is to use a simple <strong><font color="#990000">CFLOOP</font></strong> function with the <strong>ListElement</strong> value for the <strong>INDEX</strong> parameter: <br>
						<br>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#990000"><b>&lt;CFLOOP INDEX="ListElement" LIST="#api_response#" DELIMITERS="|"&gt;<br>
							&lt;cfoutput&gt;#ListElement#&lt;/cfoutput&gt;&lt;BR&gt;<br>
							&lt;/CFLOOP&gt;</b></font><br>
							</CODE> </div>
						<br>
						<CFLOOP INDEX="ListElement" LIST="#api_response#" DELIMITERS="|">
							<cfoutput>#ListElement#</cfoutput><br>
						</CFLOOP>
						<br>
						<strong>Note:</strong> Blank values will be ignored. <br>
						<br>
						<br>
						We can also count the length of the string that was returned from Authorize.Net:<br>
						<br>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#990000"><b>&lt;cfset strLen=Len(api_response)&gt;</b></font><br>
							</CODE> </div>
						<br>
						Length of the entire string: <strong><cfoutput>
							<!--- Count the length of the entire string (as a reference point) --->
							<cfset strLen=Len(api_response)>
							#strLen#</cfoutput></strong> <br>
						<br>
						<br>
						Through ColdFusion's List functions, you can also count the number of elements (as listed in the previous example) that were found in the string from Authorize.Net:<br>
						<br>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#990000"><b>&lt;cfset numberDelims = ListLen(api_response, "|")&gt;</b></font><br>
							</CODE> </div>
						<br>
						<!--- Search for the actual number of response items with values that were returned -- NOT counting values with no data --->
						<cfoutput>
							<cfset numberDelims = ListLen(api_response, "|")>
							Number of delimited items: <strong>#numberDelims#</strong></cfoutput><br>
						<br>
						<br>
						<br>
						Additionally, using ColdFusion's List functions, you can also count the number of delimiting characters (set through x_delim_char) that were used to separate values in the string from Authorize.Net:<br>
						<br>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#990000"><b>&lt;cfset numberDelims = ListLen(api_response, "|")&gt;</b></font><br>
							</CODE> </div>
						<br>
						<cfoutput>
							<!--- Search for every occurrence of the delimiting character (case insensitive) --->
							<cfset myString = api_response>
							<cfset numOfDelims = Evaluate(Len(myString) - Len(Replace(myString,"|","","ALL")))>
							Number of delimiting characters: <strong>#numOfDelims#</strong></cfoutput><br>
						<br>
						<br>
						<br>
						Furthermore, you can get at additional (possibly useful) information, such as:<br>
						<br>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#990000"><b>&lt;cfset occurrence=(findoneof(api_response, "|", 0)+1)&gt;</b></font><br>
							</CODE> </div>
						<br>
						<!--- Find the first occurrence of the delimiting character --->
						<!--- Zero-based --->
						<cfoutput>
							<cfset occurrence=(findoneof(api_response, "|", 0)+1)>
							First occurence of the x_delim_char = <b>#occurrence#</b></cfoutput><br>
						<br>
						<br>
						<br>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#990000"><b>&#35;gettoken(api_response, 1, "|")&#35;</b></font><br>
							</CODE> </div>
						<br>
						<!--- Based on the position of the first occurrence of the delimiting character, grab the first actual value --->
						First value in the returned string = <b><cfoutput>#gettoken(api_response, 1, "|")#</cfoutput></b><br>
						<br>
						<br>
						<br>
						<cfset MyList = api_response>
						<cfset MyArray = ListToArray(MyList, "|")>
						<strong>Simple parsing of the actual values in the returned string:</strong><br>
						<br>
						<div style="background-color:#eeeeee; padding-top:2px; padding-bottom:2px; padding-left:10px; padding-right:10px;border-color: #c0c0c0; border-width: 1px;border-style: dotted;"> <CODE> <font color="#990000"><b>&lt;cfloop index="Element" from="1" to="#ArrayLen(MyArray)#"&gt;<br>
							&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&lt;cfoutput>Element #Element#: #MyArray[Element]#&lt;br&gt;&lt;/cfoutput&gt;<br>
							&lt;/cfloop&gt;</b></font><br>
							</CODE> </div>
						<br>
						<cfloop index="Element" from="1" to="#ArrayLen(MyArray)#">
							<cfoutput>Element #Element#: #MyArray[Element]#<br>
							</cfoutput>
						</cfloop>
						<br>
						<br>
						<b>Note:</b> Again, blank values are ignored and skipped over. <br>
						<br>
						<br>
						<strong>Explicit parsing of the actual values in the returned string:</strong><br>
						<!--- We need to add 1 to account for the last item (in the response string) which has no delimiting character afterward --->
						<cfset numOfDelims = IncrementValue(numOfDelims)>
						<cfset newText = Replace(api_response, "|", " |","ALL")>
						<!---  TABLE 05  --->
						<table width="100%" border="0" cellspacing="0" cellpadding="1">
							<cfloop index="Element" from="1" to="#numOfDelims#">
								<!--
	The first item is the Response Code
	ColdFusion has a special routine to get at the first item in a delimited list
-->
								<cfswitch expression = "#Element#">
									<cfcase value = "1">
									<tr class="small" bgcolor="#EEEEEE">
										<cfset rc = RTrim(ListFirst(newText, "|"))>
										<td class="small"><cfoutput>#Element# - </cfoutput> </td>
										<td class="small"> Response Code </td>
										<td class="small">&nbsp;</td>
										<td class="small"><cfif #rc# IS "1">
												Approved<br>
												<cfset newList = ListDeleteAt(newText, 1, "|")>
												<cfelseif #rc# IS "2">
												Declined<br>
												<cfset newList = ListDeleteAt(newText, 1, "|")>
												<cfelseif #rc# IS "3">
												Error<br>
												<cfset newList = ListDeleteAt(newText, 1, "|")>
												<cfelse>
												undefined<br>
												<cfset newList = ListDeleteAt(newText, 1, "|")>
											</cfif>
										</td>
									</tr>
									</cfcase>
									<cfcase value = "2">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Response Subcode </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Response Subcode </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "3">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Response Reason Code: </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Response Reason Code: </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "4">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Response Reason Text </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Response Reason Text </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</tr>
									
									</cfcase>
									<cfcase value = "5">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Approval Code </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Approval Code </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "6">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> AVS Result Code </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> AVS Result Code </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "7">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Transaction ID </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Transaction ID </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "8">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Invoice Number&nbsp; </td>
											<td class="small"> (x_invoice_num) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Invoice Number&nbsp; </td>
											<td class="small"> (x_invoice_num) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "9">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Description&nbsp; </td>
											<td class="small"> (x_description) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Description&nbsp; </td>
											<td class="small"> (x_description) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "10">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Amount&nbsp; </td>
											<td class="small"> (x_amount) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Amount&nbsp; </td>
											<td class="small"> (x_amount) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "11">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Method&nbsp; </td>
											<td class="small"> (x_method) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Method&nbsp; </td>
											<td class="small"> (x_method) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "12">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Transaction Type&nbsp; </td>
											<td class="small"> (x_type) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Transaction Type&nbsp; </td>
											<td class="small"> (x_type) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "13">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Customer ID&nbsp; </td>
											<td class="small"> (x_cust_id) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Customer ID&nbsp; </td>
											<td class="small"> (x_cust_id) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "14">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Cardholder First Name&nbsp; </td>
											<td class="small"> (x_first_name) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Cardholder First Name&nbsp; </td>
											<td class="small"> (x_first_name) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "15">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Cardholder Last Name&nbsp; </td>
											<td class="small"> (x_last_name) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Cardholder Last Name&nbsp; </td>
											<td class="small"> (x_last_name) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "16">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Company&nbsp; </td>
											<td class="small"> (x_company) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Company&nbsp; </td>
											<td class="small"> (x_company) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "17">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Billing Address&nbsp; </td>
											<td class="small"> (x_address) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Billing Address&nbsp; </td>
											<td class="small"> (x_address) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "18">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> City&nbsp; </td>
											<td class="small"> (x_city) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> City&nbsp; </td>
											<td class="small"> (x_city) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "19">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> State&nbsp; </td>
											<td class="small"> (x_state) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> State&nbsp; </td>
											<td class="small"> (x_state) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "20">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> ZIP&nbsp; </td>
											<td class="small"> (x_zip) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> ZIP&nbsp; </td>
											<td class="small"> (x_zip) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "21">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Country&nbsp; </td>
											<td class="small"> (x_country) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Country&nbsp; </td>
											<td class="small"> (x_country) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "22">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Phone&nbsp; </td>
											<td class="small"> (x_phone) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Phone&nbsp; </td>
											<td class="small"> (x_phone) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "23">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Fax&nbsp; </td>
											<td class="small"> (x_fax) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Fax&nbsp; </td>
											<td class="small"> (x_fax) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "24">
									<tr>
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> E-Mail&nbsp; </td>
											<td class="small"> (x_email) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> E-Mail&nbsp; </td>
											<td class="small"> (x_email) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "25">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to First Name&nbsp; </td>
											<td class="small"> (x_ship_to_first_name) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to First Name&nbsp; </td>
											<td class="small"> (x_ship_to_first_name) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "26">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Last Name&nbsp; </td>
											<td class="small"> (x_ship_to_last_name) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Last Name&nbsp; </td>
											<td class="small"> (x_ship_to_last_name) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "27">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Company&nbsp; </td>
											<td class="small"> (x_ship_to_company) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Company&nbsp; </td>
											<td class="small"> (x_ship_to_company) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "28">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Address&nbsp; </td>
											<td class="small"> (x_ship_to_address) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Address&nbsp; </td>
											<td class="small"> (x_ship_to_address) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "29">
									<tr class="small" bgcolor="#EEEEEE">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to City&nbsp; </td>
											<td class="small"> (x_ship_to_city) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to City&nbsp; </td>
											<td class="small"> (x_ship_to_city) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "30">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to State&nbsp; </td>
											<td class="small"> (x_ship_to_state) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to State </td>
											<td class="small"> (x_ship_to_state) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "31">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to ZIP&nbsp; </td>
											<td class="small"> (x_ship_to_zip) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to ZIP&nbsp; </td>
											<td class="small"> (x_ship_to_zip) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "32">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Country&nbsp; </td>
											<td class="small"> (x_ship_to_country) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Ship-to Country&nbsp; </td>
											<td class="small"> (x_ship_to_country) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "33">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Tax Amount&nbsp; </td>
											<td class="small"> (x_tax) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Tax Amount&nbsp; </td>
											<td class="small"> (x_tax) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "34">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Duty Amount&nbsp; </td>
											<td class="small"> (x_duty) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Duty Amount&nbsp; </td>
											<td class="small"> (x_duty) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "35">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Freight Amount&nbsp; </td>
											<td class="small"> (x_freight) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Freight Amount&nbsp; </td>
											<td class="small"> (x_freight) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "36">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Tax Exempt Flag&nbsp; </td>
											<td class="small"> (x_tx_exempt) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Tax Exempt Flag&nbsp; </td>
											<td class="small"> (x_tx_exempt) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "37">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> PO Number&nbsp; </td>
											<td class="small"> (x_po_num) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> PO Number&nbsp; </td>
											<td class="small"> (x_po_num) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "38">
									<tr class="small" bgcolor="#ffffff">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> MD5 Hash: </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> MD5 Hash: </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "39">
									<tr class="small" bgcolor="#eeeeee">
										<cfset nextResp = RTrim(ListFirst(newList, "|"))>
										<cfif #nextResp# IS "" OR #nextResp# IS " ">
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Card Code Response&nbsp; </td>
											<td class="small"> (CVV2, CVC2, CID) </td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Card Code Response&nbsp; </td>
											<td class="small"> (CVV2, CVC2, CID) </td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
										</cfif>
									</tr>
									</cfcase>
									<cfcase value = "40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68">
									<cfif #Element# MOD 2 IS 1>
										<tr class="small" bgcolor="#eeeeee">
											<cfelse>
										<tr class="small" bgcolor="#ffffff">
										
									</cfif>
									<cfset nextResp = RTrim(ListFirst(newList, "|"))>
									<cfif #nextResp# IS "" OR #nextResp# IS " ">
										<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Reserved for future use&nbsp; </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Reserved for future use&nbsp; </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
									</cfif>
									</tr>
									
									</cfcase>
									<!--- ----------------------------------------------------  --->
									<cfdefaultcase>
									<!---   Creating alternating table row background colors    --->
									<cfif #Element# MOD 2 IS 1>
										<tr class="small" bgcolor="#eeeeee">
											<cfelse>
										<tr class="small" bgcolor="#ffffff">
										
									</cfif>
									<cfset nextResp = RTrim(ListFirst(newList, "|"))>
									<cfif #nextResp# IS "" OR #nextResp# IS " ">
										<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Merchant defined value </td>
											<td class="small">&nbsp;</td>
											<td class="small"> no value returned<br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
											<cfelse>
											<td class="small"><cfoutput>#Element# - </cfoutput> </td>
											<td class="small"> Merchant defined value </td>
											<td class="small">&nbsp;</td>
											<td class="small"><cfoutput>#nextResp#</cfoutput><br>
											</td>
											<cfset newList = ListDeleteAt(newList, 1, "|")>
									</cfif>
									</tr>
									
									</cfdefaultcase>
									<!--- ----------------------------------------------------------  --->
								</cfswitch>
							</cfloop>
						</table>
						<!---  END OF TABLE 05  --->
						<hr>
						<p>End of the response processing demo.</p>
					</div>
					<!---  CONTINUE TABLE 04  --->
				</td>
				</tr>
				
			</table>
			<!---  END OF TABLE 04  --->
			<!---  CONTINUE TABLE 02  --->
			</td>
			
			<td background="images/dash_gray_v.gif"><img src="images/z.gif" width="1" height="55" alt="" /></td>
			</tr>
			<tr>
				<td background="images/dash_gray_h.gif" colspan="3"><img src="images/z.gif" width="1" height="1" alt="" /></td>
			</tr>
		</table>
		<!---  END OF TABLE 02  --->
		<!---  CONTINUE TABLE 01  --->
		</td>
		
		</tr>
		
	</table>
	<!---  END TABLE 01  --->
	</div>
</center>
</body>
</html>
