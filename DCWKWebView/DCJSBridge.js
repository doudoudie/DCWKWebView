
(function() {

    var _CUSTOM_PROTOCOL_SCHEME = 'DCSimpleBridge',
        callbacksCount = 1,
        callbacks = {};

    function getOS() {
        var userAgent = navigator.userAgent;
        return userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/) ? 'ios' : userAgent.match(/Android/i) ? 'android' : '';
    }

    function _jsBridgeHandler(functionName, message, callback) {
        if (!(getOS())) return false;
        var hasCallback = callback && typeof callback == "function";
        var callbackId = hasCallback ? callbacksCount++ : 0;

        if (hasCallback) {
            callbacks[callbackId] = callback;
        }
        var messageDic = {
            functionName: functionName,
            message: message,
            callbackId: callbackId
        }
        try {
            console.log(messageDic);
            window.webkit.messageHandlers.DCJSBridge.postMessage(messageDic)
            console.log(666);
        } catch (e) {}
                               
    }

     function _call(message) {
           console.log(888);
          window.webkit.messageHandlers.DCJSBridge.postMessage(message)
      }
                               
    function _init(callback) {
        callback && callback();
    }

    var __DCJSBridge = {
        init: _init,
        bridgeHandler: _jsBridgeHandler,
        call:_call
    };

    window.DCJSBridge = __DCJSBridge;
                               
})();
