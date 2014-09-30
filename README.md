Using LogmeIn OAuth2.0 JavaScript web client
=======

LogmeIn OAuth 2.0 endpoint supports JavaScript-centric application. 
These applications may access the resource owner's data while the user is present by obtaining explicit authorization from it by using the *OAuth2 implicit grant model* from [RFC 6749](http://tools.ietf.org/html/rfc6749#section-4.2).

One important characteristic of these applications is that the cannot keep a secret, which means that the client secret cannot be used to stablish the authentication.

In order to cirnunvent this issue, the implicit grant model involves that the client should provide a callback endpoint on their web infrastructure.

This library provides support for your client-side code to perform the authentication against the server as well as provides access to all the functionality also provided by [logmein-webclient-be](https://github.com/activems/logmein-webclient-be).

Initializing the client library
-----------

You may install the library via `bower`:

```bash
$ bower install logmein-webclient
```
Make sure you import the javascript into your `html` file:

```html
<script src="libs/logmein-webclient/lib/main.js"></script>
```

To initialize the library you just need to call the constructor, method, which takes as input a configuration object that can contain zero or more of the following fields:

|Name|Value|Description|
|----|-----|-----------|
|`host`|`String`|Authentication server to which the client will connect. Should *NOT* include the URL schema as it should always be `https`. Defaults to `DEFAULT_HOST`.|
|`port`|TCP port number|TCP port from the host to which the client will connect. Defaults to `DEFAULT_PORT`|
|`apiVersion`|`String`|Identifies the version of the API used. Defaults to `DEFAULT_API`|

Example of initialization from a JavaScript client:

```javascript
var client = LogmeWebClient();
```
For clients with nosting their own authorization infrastructure, a custom settings may be also provided:

```javascript
var client = LogmeWebClient({ host: "example.com", port: 8000});
```
A new LogmeIn client instance is returned that can be used to
perform the authentication and access protected resources.

Performing the OAuth 2.0 client authentication
------------
In order for a client to be able to access the resouces that belong to a resource owner, the client should get authenticated, which will request the resource owner confirmation.

If the resource owner grants acess to the client then the client can access to the resources in the granted scope.

> *Note:* The invocation of this method will automatically redirect the browser to an endpoint in the authentication host.

The `authenticate()` function takes as input the client's configuration, which involves the following fields. 

Authenticate the client against the authentication server using the provided client configuration. The client configuration should include the following parameters:

|Name|Value|Description|
|----|-----|-----------|
|`client_id`|`String`|Client ID obtained upon client registration|
|`redirect_uri`|URI|Fully qualified URI containing the callback in a server hosted by the client|
|`scope`|`String`|Space-separated list of the realms to which the client is requesting access. The realms you need to request access depends on which resources the application needs to access|
|`state`||This can be used by the client in order to send optional information to the callback such as a URL to which the browser should be pointing after the authentication has been successful|

Example of client authentication from JavaScript code in the browser:

```javascript
client.authenticate({
    client_id:    "8df683e0-43a7-11e4-916c-0800200c9a1f",
    redirect_uri: "https://client.example.com/oauth2_callback",
    scope:        "profile vault",
    state:        "login.html"
})
```
Whether the resource owner grants access to the client to its data or not,  the authorization server will generate a redirection (HTTP code `302`)response to the provided `redirect_uri`, including the following data in the URI fragment:

|Name|Value|Description|
|----|-----|-----------|
|`access_token`|`String`|Identifier of the access token that grants access to the client to the resource owner's data for the current session|
|`token_type`|`Bearer`||
|`expires_in`|`Integer`|Number of seconds until the provided `access_token` expires|
|`scope`|`String`|Space-separeated list of the realm to which the resource owner has granted access to the client. Should not necessary be the same as the requested so this should be checked|
|`state`|`String`|The same value as the provided in the `authenticate()` method call|
|`error`|`access_denied`|This will be included just when the access is not granted and the value is explicitly the same always|

Here's an example of a response generated when the access is granted:

 ```
HTTP/1.1 302 Found
Location: https://client.example.com/oauth2_callback#access_token=2YotnFZFEjr1zCsicMWpAA&token_type=Bearer&expires_in=60&scope=profile%20vault&state=login.html
```
Otherwise, the response will include an error as follows:

```
HTTP/1.1 302 Found
Location: https://client.example.com/oauth2_callback#error=access_denied&state=login.html
````

The callback endpoint should be able to parse the fragment in the client-side 
and extract the parameters in order to post them to an endpoint at the client's web server so that this can keep the `access_token` in the session or handle the error.
 
A sample implementation of the callback and the functionality for retrieving the token is provided by [logmein-client-callbac](https://github.com/activems/logmein-client-callback) as Node.js web service.

One important thing to take into account is that the client should always validate the `access_token` once retrieved in their server. Failure to do so
makes your application more vulnerable to the [confused deputy problem](http://en.wikipedia.org/wiki/Confused_deputy_problem).
