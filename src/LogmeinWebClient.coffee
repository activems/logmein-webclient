# Using LogmeIn OAuth2.0 client authorization library
# ============================================
#
# The LogmeIn OAuth 2.0 endpoint supports JavaScript-centric
# applications. 
#
# These applications may access the resource owner's data while 
# the user is present by obtaining explicit authorization from it.
#
# One important characteristic of these applications is that they
# cannot keep a secret, which means that the client secret cannot
# be used to stablish the authentication.
#
# This library provides acess to the authentication server so that
# clients like these can make use of the authentication system. It 
# does so by implementing the OAuth 2.0 *[implicit grant](http://tools.ietf.org/html/rfc6749#section-4.2)*
# authentication model.
#
# > *Note:* The implicit grant model involves that the client should provide a callback endpoint on their web infrastructure as explained below.
#
# Here's an illustration of how the whole authorization process
# works using the implicit grant model:
#
# ```html
# +----------+
# | Resource |
# |  Owner   |
# |          | 
# +----------+
#      ^
#      |
#     (B)
# +----|-----+          Client Identifier     +---------------+
# |         -+----(A)-- & Redirection URI --->|               |
# |  User-   |                                | Authorization |
# |  Agent  -|----(B)-- User authenticates -->|     Server    |
# |          |                                |               |
# |          |<---(C)--- Redirection URI ----<|               |
# |          |          with Access Token     +---------------+
# |          |            in Fragment
# |          |                                +---------------+
# |          |----(D)--- Redirection URI ---->|   Web-Hosted  |
# |          |          without Fragment      |     Client    |
# |          |                                |    Resource   |
# |     (F)  |<---(E)------- Script ---------<|               |
# |          |                                +---------------+
# +-|--------+
#   |    |
#  (A)  (G) Access Token
#   |    |
#   ^    v
# +---------+
# |         |
# |  Client |
# |         |
# +---------+
# ```
#
http = require('http')

# The Client class  
# ----------------
#
# The Client class is the entry point to the authentication
# library.
# It provides with all the necessary functionality to perform 
# the authentication, token validation and access to the resource
# owner's data.
#
class LogmeinWebClient 

    # Client settings  
    # ----------------

    # `DEFAULT_HOST` specifies the default host used by the 
    # client as authentication server if no `host` configuration
    # is specified during the library initialization. By default,
    # the host points to the Gipsy-Danger API web server.
    #
    DEFAULT_HOST : 'api.actisec.com'

    # `DEFAULT_PORT` specifies the default TCP port in the 
    # authentication server used by the client if no `port` configuration
    # is specified during the library initialization.
    #
    DEFAULT_PORT : 443

    # `DEFAULT_API` specifies the default API version used 
    # to interface with the server if no `apiVersion` configuration
    # is specified during the library initialization.
    #
    DEFAULT_API  : "v1"

    # Initializing the client library
    # ----------------------------------------------------
    # 
    # To initialize the library you need to call the constructor,
    # method, which takes as input a configuration object that
    # can contain zero or more of the following fields:
    #
    # |Name|Value|Description|
    # |----|-----|-----------|
    # |`host`|`String`|Authentication server to which the client will connect. Should *NOT* include the URL schema as it should always be `https`. Defaults to `DEFAULT_HOST`.|
    # |`port`|TCP port number|TCP port from the host to which the client will connect. Defaults to `DEFAULT_PORT`|
    # |`apiVersion`|`String`|Identifies the version of the API used. Defaults to `DEFAULT_API`|
    # 
    # Example of initialization from a JavaScript client:
    #
    # ```javascript
    # var client = LogmeInClientAuth();
    # ```
    #
    # For clients with nosting their own authorization infrastructure, a custom
    # settings may be also provided:
    #
    # ```javascript
    # var client = LogmeInClientAuth({ host: "example.com", port: 8000});
    # ```
    #
    # A new client instance is returned that can be used to
    # perform the authentication and acess protected resources.
    #
    constructor: (config) ->
        { @host, @port, @apiVersion } = config if config?
        @host       ?= @DEFAULT_HOST
        @port       ?= @DEFAULT_PORT
        @apiVersion ?= @DEFAULT_API
        

    # Accessing the settings
    # ----------------------------------------------------

    # By calling `getHost()` the caller can retrieve the 
    # configured `host` used by the library
    #
    # ```javascript
    # var host = client.getHost();
    # ```
    #
    getHost: () ->
      return @host

    # By calling `getPort()` the caller can retrieve the 
    # configured `host` used by the library
    #
    # ```javascript
    # var port = client.getPort();
    # ```
    #
    getPort: () ->
      return @port


    # By calling `getApiVersion()` the caller can retrieve the 
    # configured `apiVersion` used by the library
    #
    # ```javascript
    # var api = client.getApiVersion();
    # ```
    #
    getApiVersion: () ->
      return @apiVersion

    _getResourcePath: (resource) ->
      return '/' + @getApiVersion() + '/oauth2/' + resource 

    _redirect: (destination) ->
        window.location = destination


    # Performing the client authentication
    # ----------------------------------------------------
    #
    # In order for a client to be able to access the resouces
    # that belong to a resource owner, the client should get
    # authenticated, which will request the resource owner 
    # confirmation.
    #
    # If the resource owner grants acess to the client then
    # the client can access to the resources in the granted 
    # scope.
    #
    # > *Note:* The invocation of this method will automatically
    # redirect the browser to an endpoint in the authentication 
    # host.
    # 
    # The `authenticate()` function takes as input the client's
    # configuration, which involves the following fields. 
    #
    # Authenticate the client against the authentication
    # server using the provided client configuration. The
    # client configuration should include the following
    # parameters:
    #
    # |Name|Value|Description|
    # |----|-----|-----------|
    # |`client_id`|`String`|Client ID obtained upon client registration|
    # |`redirect_uri`|URI|Fully qualified URI containing the callback in a server hosted by the client|
    # |`scope`|`String`|Space-separated list of the realms to which the client is requesting access|
    # |`state`||This can be used by the client in order to send optional information to the callback such as a URL to which the browser should be pointing after the authentication has been successful|
    #
    #
    # This webservice should provide a means to extract the `access_token`
    # Example of client authentication from JavaScript:
    # ```javascript
    # client.authenticate({
    #   client_id:    "8df683e0-43a7-11e4-916c-0800200c9a1f",
    #   redirect_uri: "https://client.example.com/oauth2_callback",
    #   scope:        "profile vault",
    #   state:        "login.html"
    # })
    # ```
    #
    # Whether the resource owner grants access to the client to its data or not, 
    # the authorization server will generate a redirection (HTTP code `302`)response to the 
    # provided `redirect_uri`, including the following data in the URI fragment:
    # 
    # |Name|Value|Description|
    # |----|-----|-----------|
    # |`access_token`|`String`|Identifier of the access token that grants access to the client to the resource owner's data for the current session|
    # |`token_type`|`Bearer`||
    # |`expires_in`|`Integer`|Number of seconds until the provided `access_token` expires|
    # |`scope`|`String`|Space-separeated list of the realm to which the resource owner has granted access to the client. Should not necessary be the same as the requested so this should be checked|
    # |`state`|`String`|The same value as the provided in the `authenticate()` method call|
    # |`error`|`access_denied`|This will be included just when the access is not granted and the value is explicitly the same always|
    #
    # Here's an example of a response generated when the access is granted:
    #
    # ```
    # HTTP/1.1 302 Found
    # Location: https://client.example.com/oauth2_callback#access_token=2YotnFZFEjr1zCsicMWpAA&token_type=Bearer&expires_in=60&scope=profile%20vault&state=login.html
    # ```
    #
    # Otherwise, the response will include an error such as:
    #
    # ```
    # HTTP/1.1 302 Found
    # Location: https://client.example.com/oauth2_callback#error=access_denied&state=login.html
    # ```
    #
    # The callback endpoint should be able to parse the fragment in the client-side 
    # and extract the parameters in order to post them to an endpoint at the client's web server
    # so that this can keep the `access_token` in the session or handle the error.
    # 
    # In order to be able to do so, this JavaScript code is provided as an example 
    # and can be used as the payload served by the `redirect_uri` callback.
    #
    # ```html
    # <script type="text/javascript">
    # // First, parse the query string
    # var params = {}, queryString = location.hash.substring(1), regex = /([^&=]+)=([^&]*)/g, m;
    # while (m = regex.exec(queryString)) {
    #   params[decodeURIComponent(m[1])] = decodeURIComponent(m[2]);
    # }
    #
    # // And send the token over to the server
    # var req = new XMLHttpRequest();
    # 
    # req.open('POST', 'http://' + window.location.host + '/catchtoken?' + queryString, true);
    # req.onreadystatechange = function (e) {
    #   if (req.readyState == 4) {
    #     if(req.status == 200){
    #       window.location = params["state"]
    #     } 
    #     else if(req.status == 400) {
    #       alert('There was an error processing the token.')
    #     }
    #     else {
    #       alert('something else other than 200 was returned')
    #     }
    #   }
    # };
    # req.send(null);
    # </script>
    # ```
    #
    # This script parses the fragment from the URI and generates 
    # a query string which is passed to the `catchtoken` endpoint 
    # in the same host as the `redirect_uri`.
    #
    # > *Note:* This script is just an implementation example so you can choose to implement it differently.
    #
    # In this case, once the `catchtoken` endpoint receives the 
    # parameters in the query string it has access to the `access_token`,
    # which should be validated against the authentication server, and the 
    # rest of parameters.
    # 
    authenticate: (client) ->
      
      toQueryString = (data) =>
     
        map = (hash, prefix='') =>
          result = []
       
          for key, value of hash
            key = if prefix is '' then key else "#{prefix}[#{key}]"
       
            if typeof(value) is 'object'
              if value instanceof Array
                for v in value
                  result.push(["#{key}[]", v])
              else if value # assuming it's an object
                for entry in map(value, key)
                  result.push(entry)
       
            else
              result.push([key, "#{value}"])
       
          result
       
        data = for e in map(data)
          "#{encodeURIComponent(e[0])}=#{encodeURIComponent(e[1])}"
     
        data.join('&')

      queryString = "?response_type=token&" + toQueryString(client)
      redirectLocation = "https://" + @getHost() + ":" + @getPort() + 
        @_getResourcePath('auth') + queryString
     
      @_redirect redirectLocation

      
exports.LogmeinWebClient = LogmeinWebClient

module.exports = (config) -> 
     return new LogmeinWebClient(config) 