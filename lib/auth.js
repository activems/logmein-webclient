(function() {
  require(['cs!http'], function(http) {
    var LogmeInClientAuth;
    return LogmeInClientAuth = (function() {
      LogmeInClientAuth.DEFAULT_HOST = 'https://api.actisec.com';

      LogmeInClientAuth.DEFAULT_PORT = 80;

      LogmeInClientAuth.DEFAULT_API = "v1";

      function LogmeInClientAuth(config) {
        this.config = config;
      }

      LogmeInClientAuth.prototype.getHost = function() {
        if ((this.config != null) && (this.config.host != null)) {
          return this.config.host;
        } else {
          return this.DEFAULT_HOST;
        }
      };

      LogmeInClientAuth.prototype.getPort = function() {
        if ((this.config != null) && (this.config.port != null)) {
          return this.config.port;
        } else {
          return this.DEFAULT_PORT;
        }
      };

      LogmeInClientAuth.prototype.getApiVersion = function() {
        if ((this.config != null) && (this.config.apiVersion != null)) {
          return this.config.apiVersion;
        } else {
          return this.DEFAULT_API;
        }
      };

      LogmeInClientAuth.prototype._getResourcePath = function(resource) {
        return '/' + this.getApiVersion() + '/oauth2/' + resource;
      };

      LogmeInClientAuth.prototype.authenticate = function(client) {
        var queryString, redirectLocation, toQueryString;
        toQueryString = (function(_this) {
          return function(data) {
            var e, map;
            map = function(hash, prefix) {
              var entry, key, result, v, value, _i, _j, _len, _len1, _ref;
              if (prefix == null) {
                prefix = '';
              }
              result = [];
              for (key in hash) {
                value = hash[key];
                key = prefix === '' ? key : "" + prefix + "[" + key + "]";
                if (typeof value === 'object') {
                  if (value instanceof Array) {
                    for (_i = 0, _len = value.length; _i < _len; _i++) {
                      v = value[_i];
                      result.push(["" + key + "[]", v]);
                    }
                  } else if (value) {
                    _ref = map(value, key);
                    for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
                      entry = _ref[_j];
                      result.push(entry);
                    }
                  }
                } else {
                  result.push([key, "" + value]);
                }
              }
              return result;
            };
            data = (function() {
              var _i, _len, _ref, _results;
              _ref = map(data);
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                e = _ref[_i];
                _results.push("" + (encodeURIComponent(e[0])) + "=" + (encodeURIComponent(e[1])));
              }
              return _results;
            })();
            return data.join('&');
          };
        })(this);
        queryString = "?response_type=token&" + toQueryString(client);
        redirectLocation = "https://" + this.getHost() + ":" + this.getPort() + this._getResourcePath('auth') + queryString;
        return window.location = redirectLocation;
      };

      LogmeInClientAuth.prototype.getResource = function(accessToken, resourcePath, params, onSuccess, onError) {
        var options;
        if (accessToken == null) {
          throw 'Access token is undefined';
        }
        if (typeof path === "undefined" || path === null) {
          throw 'Resource path is undefined';
        }
        options = {
          host: this.getHost(),
          port: this.getPort(),
          path: this.getApiVersion() + resourcePath,
          acess_token: accessToken,
          headers: params
        };
        return http.request(options, (function(_this) {
          return function(response) {
            if (onSuccess != null) {
              return response.on('data', function(chunk) {
                if (onSuccess != null) {
                  return onSuccess(response);
                }
              });
            }
          };
        })(this)).on('error', function(e) {
          if (onError != null) {
            return onError(e);
          }
        }).end();
      };

      LogmeInClientAuth.prototype.validateToken = function(accessToken, onValidToken, onInvalidToken, onError) {
        var options;
        options = {
          host: this.getHost(),
          port: this.getPort(),
          path: this._getResourcePath('validatetoken'),
          access_token: accessToken
        };
        return http.request(options, (function(_this) {
          return function(response) {
            if (typeof onSuccess !== "undefined" && onSuccess !== null) {
              return response.on('data', function(chunk) {
                switch (response.statusCode) {
                  case 200:
                    if (onValidToken != null) {
                      return onValidToken(response);
                    }
                    break;
                  case 200:
                    if (onInvalidToken != null) {
                      return onInvalidToken(response);
                    }
                    break;
                  default:
                    if (onError != null) {
                      return onError(new Error("Unexpected response staus code " + response.statusCode));
                    }
                }
              });
            }
          };
        })(this)).on('error', function(e) {
          if (onError != null) {
            return onError(e);
          }
        }).end();
      };

      return LogmeInClientAuth;

    })();
  });

  exports.LogmeInClientAuth = LogmeInClientAuth;

  module.exports = function(config) {
    return new LogmeInClientAuth(config);
  };

}).call(this);
