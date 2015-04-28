<% @LANGUAGE="JScript" %>
<!-- #include file="hmac-sha1.js"-->
<!-- #include file="enc-base64-min.js"-->
<!-- #include file="json2.js"-->
<%
// for above js file download
// http://crypto-js.googlecode.com/svn/tags/3.1.2/build/rollups/hmac-sha1.js
// http://crypto-js.googlecode.com/svn/tags/3.1.2/build/components/enc-base64-min.js
// https://github.com/douglascrockford/JSON-js/blob/master/json2.js

//simple URL encode, except for the four characters below
function pctenc(x) {
  var x = String(x);
  x = Server.URLEncode(x);
  x = x.replace(/%2E/ig,".");
  x = x.replace(/%5F/ig,"_");
  x = x.replace(/%3F/ig,"&");
  x = x.replace(/%2D/ig,"-");
  return x;
}

// ==== create base URL components
var base_url = "http://example.com/api/v1/user";
// ==== http authentication, it should be remove on production environment
var http_auth_user = "test";
var http_auth_pass = "test";
// ==== key name value pairs (sans signature)
var oauth_consumer_key = "kuFVJPHwHIcYFA7cv2n3hl76X8pCyX4l"; // app's consumer key
var oauth_nonce = new Date().getTime();
var oauth_signature_method = "HMAC-SHA1";
var oauth_timestamp = String(Math.round(+new Date/1000)); // seconds since 1/1/1970
var oauth_version = "1.0"; // gonna have to do this again for 2.0
var oauth_token = ''; // user's access token
// ==== querystring components (sans signature)
var str_consumer_key = "?oauth_consumer_key=" + oauth_consumer_key;
var str_nonce = "&oauth_nonce=" + oauth_nonce;
var str_signature_method = "&oauth_signature_method=" + oauth_signature_method;
var str_timestamp = "&oauth_timestamp=" + oauth_timestamp;
var str_token = "&oauth_token=" + oauth_token;
var str_version = "&oauth_version=" + oauth_version;
// ==== generate hash encryption key
var Consumer_Secret = "br9nE9BsuigmoLinL33onBXi3Y2RmZUr"; // app's consumer secret
var Access_Token_Secret = ""; // user's access token secret
var hash_key = pctenc(Consumer_Secret) + "&" + pctenc(Access_Token_Secret);
// ==== build base URL for (message) OAUTH key, keys must be in alphabetical order by name
var hash_message = base_url;
hash_message += str_consumer_key;
hash_message += str_nonce;
hash_message += str_signature_method;
hash_message += str_timestamp;
hash_message += str_token;
hash_message += str_version;
// ==== add the leading "GET&" and then URLencode it all 
var hash_message_encoded = "GET&" + pctenc(hash_message); //func above
// ==== create OUATH SIGNATURE, which is a hash of the URLencoded base URL, using the combined secrets as the key...
var oauth_signature = CryptoJS.HmacSHA1(hash_message_encoded, hash_key); // for testing, add anything (... + "1" ) to message or hash to GENERATE ERROR 32!
// ==== ...which is then Base64'd...
oauth_signature = CryptoJS.enc.Base64.stringify(oauth_signature);
// ==== ...and then finally URLencoded.
oauth_signature = pctenc(oauth_signature);
// ==== create the querystring component for the signature
var str_signature = "&oauth_signature=" + oauth_signature;
// ==== build the final request URL
var final_url = base_url
final_url += str_consumer_key;
final_url += str_nonce;
final_url += str_signature;
final_url += str_signature_method;
final_url += str_timestamp;
final_url += str_token;
final_url += str_version;
// ==== make the actual twitter GET request
var http = Server.CreateObject("MSXML2.ServerXMLHTTP.6.0");
http.open('GET', final_url, false, http_auth_user, http_auth_pass);
//Send the proper header information along with the request
http.setRequestHeader("Content-type", "application/json");
try {
  http.send();
  var response = http.responseText;
  var success = true;
  // successful contact and valid response
  if (Response.Status != "200 OK") {
    success = false
  };
  // do we have tweets... or errors?
  //error_code = 0;
  try { // this will fail if we don't have an error
    var error_data = eval('(' + response + ')');
    var error_code = parseInt(error_data.errors[0].code);
    if (!isNaN(error_code)) {
      success = false;
    }
  } catch (err) {
    // success still true
  }
} catch(err) {
  var success = false;
}

if (success) {
  Response.Write(response);
}

%>