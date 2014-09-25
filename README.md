Using LogmeIn OAuth2.0 client authorization library
=======

LogmeIn OAuth 2.0 endpoint supports JavaScript-centric application. 
These applications may access the resource owner's data while the user is present by obtaining explicit authorization from it.

One important characteristic of these applications is that the cannot keep a secret, which means that the client secret cannot be used to stablish the authentication.

This library provides acess to the authentication server so that clients like these can make use of the authentication system. It  does so by implementing the OAuth 2.0 *[implicit grant](http://tools.ietf.org/html/rfc6749#section-4.2)* authentication model.

> *Note:* The implicit grant model involves that the client should provide a callback endpoint on their web infrastructure as explained below.

Here's an illustration of how the whole authorization process
works using the implicit grant model:

```html
+----------+
| Resource |
|  Owner   |
|          | 
+----------+
     ^
     |
    (B)
+----|-----+          Client Identifier     +---------------+
|         -+----(A)-- & Redirection URI --->|               |
|  User-   |                                | Authorization |
|  Agent  -|----(B)-- User authenticates -->|     Server    |
|          |                                |               |
|          |<---(C)--- Redirection URI ----<|               |
|          |          with Access Token     +---------------+
|          |            in Fragment
|          |                                +---------------+
|          |----(D)--- Redirection URI ---->|   Web-Hosted  |
|          |          without Fragment      |     Client    |
|          |                                |    Resource   |
|     (F)  |<---(E)------- Script ---------<|               |
|          |                                +---------------+
+-|--------+
  |    |
 (A)  (G) Access Token
  |    |
  ^    v
+---------+
|         |
|  Client |
|         |
+---------+
```

Initializing the client library
-----------

To initialize the library you just need to call the constructor, method, which takes as input a configuration object that can contain zero or more of the following fields:

|Name|Value|Description|
|----|-----|-----------|
|`host`|`String`|Authentication server to which the client will connect. Should not include the URL schema. Defaults to `DEFAULT_HOST`.|
|`port`|TCP port number|TCP port from the host to which the client will connect. Defaults to `DEFAULT_PORT`|
|`apiVersion`|`String`|Identifies the version of the API used. Defaults to `DEFAULT_API`|

Example of initialization from a JavaScript client:

```javascript
var client = LogmeInClientAuth();
```
For clients with nosting their own authorization infrastructure, a custom settings may be also provided:

```javascript
var client = LogmeInClientAuth({ host: "example.com", port: 8000});
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

Accessing resource owner's data
------------

Once the client has been granted access to the resource owner's resources, it can access it by means of the `getResource()` method.

Each resource is belongs to one or more realms. Assuming your client has requested authorization, which has been granted by the user, to access the real a given resource belongs to, then your application has now access to such resource.

Every time a client needs to access a resource, it needs to specify a valid `access_token`.

As a way of example, here's the JavaScript code in the browser to access the resource owner's profile data:

```javascript
client.getResource(myAcessToken, "/user/profile", null, 
    function(request) {
        alert("User profile data: " + JSON.stringify(request));
    },
    function(request) {
        alert("An error occurred");
    }
);
```
> *Note:* `myAccessToken` is the `access_token` obtained during the authentication stage. It is out of the scope of this document and depends on your web application how the token is sent to the client code from your server.

Optional: Validating an access token
-------------------

The token validation will usually take place in your web server. However, this can also be done from your client code by calling the `validateToken()` method as follows:

```javascript
client.validateToken(myAcessToken, 
    function(request) {
       alert("Token is valid :)");
    },
    function(request) {
       alert("Token is NOT valid");
    },
    function(request) {
        alert("An error occurred");
    }
);
```