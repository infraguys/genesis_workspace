// src/index.ts
(function() {
  let _JSON_stringify = window.JSON.stringify;
  let _Array_slice = window.Array.prototype.slice;
  _Array_slice.call = window.Function.prototype.call;
  window.flutter_inappwebview_plugin = {
    createFlutterInAppWebView: function(viewId, iframe, iframeContainer, bridgeSecret) {
      const iframeId = iframe.id;
      const webView = {
        viewId,
        iframeId,
        iframe: null,
        iframeContainer: null,
        isFullscreen: false,
        documentTitle: null,
        functionMap: {},
        settings: {},
        javaScriptBridgeEnabled: true,
        disableContextMenuHandler: function(event) {
          event.preventDefault();
          event.stopPropagation();
          return false;
        },
        prepare: function(settings) {
          webView.settings = settings;
          webView.javaScriptBridgeEnabled = webView.settings.javaScriptBridgeEnabled ?? true;
          const javaScriptBridgeOriginAllowList = webView.settings.javaScriptBridgeOriginAllowList;
          if (javaScriptBridgeOriginAllowList != null && !javaScriptBridgeOriginAllowList.includes("*")) {
            if (javaScriptBridgeOriginAllowList.length === 0) {
              webView.javaScriptBridgeEnabled = false;
            }
          }
          document.addEventListener("fullscreenchange", function(event) {
            if (document.fullscreenElement && document.fullscreenElement.id == iframeId) {
              webView.isFullscreen = true;
              _nativeCommunication("onEnterFullscreen", viewId);
            } else if (!document.fullscreenElement && webView.isFullscreen) {
              webView.isFullscreen = false;
              _nativeCommunication("onExitFullscreen", viewId);
            } else {
              webView.isFullscreen = false;
            }
          });
          if (iframe != null) {
            webView.iframe = iframe;
            webView.iframeContainer = iframeContainer;
            iframe.addEventListener("load", function(event) {
              if (iframe.contentWindow == null) {
                return;
              }
              const userScriptsAtStart = _nativeCommunication("getUserOnlyScriptsAt", viewId, [0 /* AT_DOCUMENT_START */]);
              const userScriptsAtEnd = _nativeCommunication("getUserOnlyScriptsAt", viewId, [1 /* AT_DOCUMENT_END */]);
              try {
                let javaScriptBridgeEnabled = webView.javaScriptBridgeEnabled;
                if (javaScriptBridgeOriginAllowList != null) {
                  javaScriptBridgeEnabled = javaScriptBridgeOriginAllowList.map((allowedOriginRule) => new RegExp(allowedOriginRule)).some((rx) => {
                    return rx.test(iframe.contentWindow.location.origin);
                  });
                }
                if (javaScriptBridgeEnabled) {
                  const javaScriptBridgeName = _nativeCommunication("getJavaScriptBridgeName", viewId);
                  iframe.contentWindow[javaScriptBridgeName] = {
                    callHandler: function() {
                      let origin = "";
                      let requestUrl = "";
                      try {
                        origin = iframe.contentWindow.location.origin;
                      } catch (_) {
                      }
                      try {
                        requestUrl = iframe.contentWindow.location.href;
                      } catch (_) {
                      }
                      return _nativeCommunication(
                        "onCallJsHandler",
                        viewId,
                        [arguments[0], _JSON_stringify({
                          "origin": origin,
                          "requestUrl": requestUrl,
                          "isMainFrame": true,
                          "_bridgeSecret": bridgeSecret,
                          "args": _JSON_stringify(_Array_slice.call(arguments, 1))
                        })]
                      );
                    }
                  };
                }
              } catch (e) {
                console.log(e);
              }
              for (const userScript of [...userScriptsAtStart, ...userScriptsAtEnd]) {
                let ifStatement = "if (";
                let source = userScript.source;
                if (userScript.allowedOriginRules != null && !userScript.allowedOriginRules.includes("*")) {
                  if (userScript.allowedOriginRules.length === 0) {
                    source = "";
                  }
                  let jsRegExpArray = "[";
                  for (const allowedOriginRule of userScript.allowedOriginRules) {
                    if (jsRegExpArray.length > 1) {
                      jsRegExpArray += ",";
                    }
                    jsRegExpArray += `new RegExp('${allowedOriginRule.replace("'", "\\'")}')`;
                  }
                  if (jsRegExpArray.length > 1) {
                    jsRegExpArray += "]";
                    ifStatement += `${jsRegExpArray}.some(function(rx) { return rx.test(window.location.origin); })`;
                  }
                }
                webView.evaluateJavascript(ifStatement.length > 4 ? `${ifStatement}) { ${source} }` : source);
              }
              let url = iframe.src;
              try {
                url = iframe.contentWindow.location.href;
              } catch (e) {
                console.log(e);
              }
              _nativeCommunication("onLoadStart", viewId, [url]);
              try {
                const oldLogs = {
                  "log": iframe.contentWindow.console.log,
                  "debug": iframe.contentWindow.console.debug,
                  "error": iframe.contentWindow.console.error,
                  "info": iframe.contentWindow.console.info,
                  "warn": iframe.contentWindow.console.warn
                };
                for (const k in oldLogs) {
                  (function(oldLog) {
                    iframe.contentWindow.console[oldLog] = function() {
                      var message = "";
                      for (var i in arguments) {
                        if (message == "") {
                          message += arguments[i];
                        } else {
                          message += " " + arguments[i];
                        }
                      }
                      oldLogs[oldLog].call(iframe.contentWindow.console, ...arguments);
                      _nativeCommunication("onConsoleMessage", viewId, [oldLog, message]);
                    };
                  })(k);
                }
              } catch (e) {
                console.log(e);
              }
              try {
                const originalPushState = iframe.contentWindow.history.pushState;
                iframe.contentWindow.history.pushState = function(state, unused, url2) {
                  originalPushState.call(iframe.contentWindow.history, state, unused, url2);
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onUpdateVisitedHistory", viewId, [iframeUrl]);
                };
                const originalReplaceState = iframe.contentWindow.history.replaceState;
                iframe.contentWindow.history.replaceState = function(state, unused, url2) {
                  originalReplaceState.call(iframe.contentWindow.history, state, unused, url2);
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onUpdateVisitedHistory", viewId, [iframeUrl]);
                };
                const originalClose = iframe.contentWindow.close;
                iframe.contentWindow.close = function() {
                  originalClose.call(iframe.contentWindow);
                  _nativeCommunication("onCloseWindow", viewId);
                };
                const originalOpen = iframe.contentWindow.open;
                iframe.contentWindow.open = function(url2, target, windowFeatures) {
                  const newWindow = originalOpen.call(iframe.contentWindow, ...arguments);
                  _nativeCommunication("onCreateWindow", viewId, [url2, target, windowFeatures]).then(function(handledByClient) {
                    if (handledByClient) {
                      newWindow?.close();
                    }
                  });
                  return newWindow;
                };
                const originalPrint = iframe.contentWindow.print;
                iframe.contentWindow.print = function() {
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onPrintRequest", viewId, [iframeUrl]);
                  originalPrint.call(iframe.contentWindow);
                };
                webView.functionMap = {
                  "window.open": iframe.contentWindow.open
                };
                const initialTitle = iframe.contentDocument?.title;
                const titleEl = iframe.contentDocument?.querySelector("title");
                webView.documentTitle = initialTitle;
                _nativeCommunication("onTitleChanged", viewId, [initialTitle]);
                if (titleEl != null) {
                  new MutationObserver(function(mutations) {
                    const title = mutations[0].target.innerText;
                    if (title != webView.documentTitle) {
                      webView.documentTitle = title;
                      _nativeCommunication("onTitleChanged", viewId, [title]);
                    }
                  }).observe(
                    titleEl,
                    { subtree: true, characterData: true, childList: true }
                  );
                }
                let oldPixelRatio = iframe.contentWindow.devicePixelRatio;
                iframe.contentWindow.addEventListener("resize", function(e) {
                  const newPixelRatio = iframe.contentWindow.devicePixelRatio;
                  if (newPixelRatio !== oldPixelRatio) {
                    _nativeCommunication("onZoomScaleChanged", viewId, [oldPixelRatio, newPixelRatio]);
                    oldPixelRatio = newPixelRatio;
                  }
                });
                iframe.contentWindow.addEventListener("popstate", function(event2) {
                  let iframeUrl = iframe.src;
                  try {
                    iframeUrl = iframe.contentWindow.location.href;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onUpdateVisitedHistory", viewId, [iframeUrl]);
                });
                iframe.contentWindow.addEventListener("scroll", function(event2) {
                  let x = 0;
                  let y = 0;
                  try {
                    x = iframe.contentWindow.scrollX;
                    y = iframe.contentWindow.scrollY;
                  } catch (e) {
                    console.log(e);
                  }
                  _nativeCommunication("onScrollChanged", viewId, [x, y]);
                });
                iframe.contentWindow.addEventListener("focus", function(event2) {
                  _nativeCommunication("onWindowFocus", viewId);
                });
                iframe.contentWindow.addEventListener("blur", function(event2) {
                  _nativeCommunication("onWindowBlur", viewId);
                });
              } catch (e) {
                console.log(e);
              }
              try {
                if (!webView.settings.javaScriptCanOpenWindowsAutomatically) {
                  iframe.contentWindow.open = function() {
                    throw new Error("JavaScript cannot open windows automatically");
                  };
                }
                if (!webView.settings.verticalScrollBarEnabled && !webView.settings.horizontalScrollBarEnabled) {
                  const style = iframe.contentDocument?.createElement("style");
                  if (style != null) {
                    style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                    style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }
                if (webView.settings.disableVerticalScroll) {
                  const style = iframe.contentDocument?.createElement("style");
                  if (style != null) {
                    style.id = "settings.disableVerticalScroll";
                    style.innerHTML = "body { overflow-y: hidden; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }
                if (webView.settings.disableHorizontalScroll) {
                  const style = iframe.contentDocument?.createElement("style");
                  if (style != null) {
                    style.id = "settings.disableHorizontalScroll";
                    style.innerHTML = "body { overflow-x: hidden; }";
                    iframe.contentDocument?.head.append(style);
                  }
                }
                if (webView.settings.disableContextMenu) {
                  iframe.contentWindow.addEventListener("contextmenu", webView.disableContextMenuHandler);
                }
              } catch (e) {
                console.log(e);
              }
              _nativeCommunication("onLoadStop", viewId, [url]);
              try {
                iframe.contentWindow.dispatchEvent(new Event("flutterInAppWebViewPlatformReady"));
              } catch (e) {
                console.log(e);
              }
            });
          }
        },
        setSettings: function(newSettings) {
          const iframe2 = webView.iframe;
          if (iframe2 == null) {
            return;
          }
          try {
            if (webView.settings.javaScriptCanOpenWindowsAutomatically != newSettings.javaScriptCanOpenWindowsAutomatically) {
              if (!newSettings.javaScriptCanOpenWindowsAutomatically) {
                iframe2.contentWindow.open = function() {
                  throw new Error("JavaScript cannot open windows automatically");
                };
              } else {
                iframe2.contentWindow.open = webView.functionMap["window.open"];
              }
            }
            if (webView.settings.verticalScrollBarEnabled != newSettings.verticalScrollBarEnabled && webView.settings.horizontalScrollBarEnabled != newSettings.horizontalScrollBarEnabled) {
              if (!newSettings.verticalScrollBarEnabled && !newSettings.horizontalScrollBarEnabled) {
                const style = iframe2.contentDocument?.createElement("style");
                if (style != null) {
                  style.id = "settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled";
                  style.innerHTML = "body::-webkit-scrollbar { width: 0px; height: 0px; }";
                  iframe2.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe2.contentDocument?.getElementById("settings.verticalScrollBarEnabled-settings.horizontalScrollBarEnabled");
                if (styleElement) {
                  styleElement.remove();
                }
              }
            }
            if (webView.settings.disableVerticalScroll != newSettings.disableVerticalScroll) {
              if (newSettings.disableVerticalScroll) {
                const style = iframe2.contentDocument?.createElement("style");
                if (style != null) {
                  style.id = "settings.disableVerticalScroll";
                  style.innerHTML = "body { overflow-y: hidden; }";
                  iframe2.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe2.contentDocument?.getElementById("settings.disableVerticalScroll");
                if (styleElement) {
                  styleElement.remove();
                }
              }
            }
            if (webView.settings.disableHorizontalScroll != newSettings.disableHorizontalScroll) {
              if (newSettings.disableHorizontalScroll) {
                const style = iframe2.contentDocument?.createElement("style");
                if (style != null) {
                  style.id = "settings.disableHorizontalScroll";
                  style.innerHTML = "body { overflow-x: hidden; }";
                  iframe2.contentDocument?.head.append(style);
                }
              } else {
                const styleElement = iframe2.contentDocument?.getElementById("settings.disableHorizontalScroll");
                if (styleElement) {
                  styleElement.remove();
                }
              }
            }
            if (webView.settings.disableContextMenu != newSettings.disableContextMenu) {
              if (newSettings.disableContextMenu) {
                iframe2.contentWindow?.addEventListener("contextmenu", webView.disableContextMenuHandler);
              } else {
                iframe2.contentWindow?.removeEventListener("contextmenu", webView.disableContextMenuHandler);
              }
            }
          } catch (e) {
            console.log(e);
          }
          webView.settings = newSettings;
        },
        reload: function() {
          var iframe2 = webView.iframe;
          if (iframe2 != null && iframe2.contentWindow != null) {
            try {
              iframe2.contentWindow.location.reload();
            } catch (e) {
              console.log(e);
              iframe2.contentWindow.location.href = iframe2.src;
            }
          }
        },
        goBack: function() {
          var iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.history.back();
            } catch (e) {
              console.log(e);
            }
          }
        },
        goForward: function() {
          var iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.history.forward();
            } catch (e) {
              console.log(e);
            }
          }
        },
        goBackOrForward: function(steps) {
          var iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.history.go(steps);
            } catch (e) {
              console.log(e);
            }
          }
        },
        evaluateJavascript: function(source) {
          const iframe2 = webView.iframe;
          let result = null;
          if (iframe2 != null) {
            try {
              result = JSON.stringify(iframe2.contentWindow?.eval(source));
            } catch (e) {
            }
          }
          return result;
        },
        stopLoading: function() {
          const iframe2 = webView.iframe;
          if (iframe2 != null) {
            try {
              iframe2.contentWindow?.stop();
            } catch (e) {
              console.log(e);
            }
          }
        },
        getUrl: function() {
          const iframe2 = webView.iframe;
          let url = iframe2?.src;
          try {
            url = iframe2?.contentWindow?.location.href;
          } catch (e) {
            console.log(e);
          }
          return url;
        },
        getTitle: function() {
          const iframe2 = webView.iframe;
          let title = null;
          try {
            title = iframe2?.contentDocument?.title;
          } catch (e) {
            console.log(e);
          }
          return title;
        },
        injectJavascriptFileFromUrl: function(urlFile, scriptHtmlTagAttributes) {
          const iframe2 = webView.iframe;
          try {
            const d = iframe2?.contentDocument;
            if (d == null) {
              return;
            }
            const script = d.createElement("script");
            for (const key of Object.keys(scriptHtmlTagAttributes)) {
              if (scriptHtmlTagAttributes[key] != null) {
                script[key] = scriptHtmlTagAttributes[key];
              }
            }
            if (script.id != null) {
              script.onload = function() {
                _nativeCommunication("onInjectedScriptLoaded", webView.viewId, [script.id]);
              };
              script.onerror = function() {
                _nativeCommunication("onInjectedScriptError", webView.viewId, [script.id]);
              };
            }
            script.src = urlFile;
            if (d.body != null) {
              d.body.appendChild(script);
            }
          } catch (e) {
            console.log(e);
          }
        },
        injectCSSCode: function(source) {
          const iframe2 = webView.iframe;
          try {
            const d = iframe2?.contentDocument;
            if (d == null) {
              return;
            }
            const style = d.createElement("style");
            style.innerHTML = source;
            if (d.head != null) {
              d.head.appendChild(style);
            }
          } catch (e) {
            console.log(e);
          }
        },
        injectCSSFileFromUrl: function(urlFile, cssLinkHtmlTagAttributes) {
          const iframe2 = webView.iframe;
          try {
            const d = iframe2?.contentDocument;
            if (d == null) {
              return;
            }
            const link = d.createElement("link");
            for (const key of Object.keys(cssLinkHtmlTagAttributes)) {
              if (cssLinkHtmlTagAttributes[key] != null) {
                link[key] = cssLinkHtmlTagAttributes[key];
              }
            }
            link.type = "text/css";
            var alternateStylesheet = "";
            if (cssLinkHtmlTagAttributes.alternateStylesheet) {
              alternateStylesheet = "alternate ";
            }
            link.rel = alternateStylesheet + "stylesheet";
            link.href = urlFile;
            if (d.head != null) {
              d.head.appendChild(link);
            }
          } catch (e) {
            console.log(e);
          }
        },
        scrollTo: function(x, y, animated) {
          const iframe2 = webView.iframe;
          try {
            if (animated) {
              iframe2?.contentWindow?.scrollTo({ top: y, left: x, behavior: "smooth" });
            } else {
              iframe2?.contentWindow?.scrollTo(x, y);
            }
          } catch (e) {
            console.log(e);
          }
        },
        scrollBy: function(x, y, animated) {
          const iframe2 = webView.iframe;
          try {
            if (animated) {
              iframe2?.contentWindow?.scrollBy({ top: y, left: x, behavior: "smooth" });
            } else {
              iframe2?.contentWindow?.scrollBy(x, y);
            }
          } catch (e) {
            console.log(e);
          }
        },
        printCurrentPage: function() {
          const iframe2 = webView.iframe;
          try {
            iframe2?.contentWindow?.print();
          } catch (e) {
            console.log(e);
          }
        },
        getContentHeight: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentDocument?.documentElement.scrollHeight;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getContentWidth: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentDocument?.documentElement.scrollWidth;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getSelectedText: function() {
          const iframe2 = webView.iframe;
          try {
            let txt;
            const w = iframe2?.contentWindow;
            if (w == null) {
              return null;
            }
            if (w.getSelection) {
              txt = w.getSelection()?.toString();
            } else if (w.document.getSelection) {
              txt = w.document.getSelection()?.toString();
            } else if (w.document.selection) {
              txt = w.document.selection.createRange().text;
            }
            return txt;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getScrollX: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentWindow?.scrollX;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        getScrollY: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentWindow?.scrollY;
          } catch (e) {
            console.log(e);
          }
          return null;
        },
        isSecureContext: function() {
          const iframe2 = webView.iframe;
          try {
            return iframe2?.contentWindow?.isSecureContext ?? false;
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        canScrollVertically: function() {
          const iframe2 = webView.iframe;
          try {
            return (iframe2?.contentDocument?.body.scrollHeight ?? 0) > (iframe2?.contentWindow?.innerHeight ?? 0);
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        canScrollHorizontally: function() {
          const iframe2 = webView.iframe;
          try {
            return (iframe2?.contentDocument?.body.scrollWidth ?? 0) > (iframe2?.contentWindow?.innerWidth ?? 0);
          } catch (e) {
            console.log(e);
          }
          return false;
        },
        getSize: function() {
          const iframeContainer2 = webView.iframeContainer;
          let width = 0;
          let height = 0;
          if (iframeContainer2 != null) {
            if (iframeContainer2.style.width != null && iframeContainer2.style.width != "" && iframeContainer2.style.width.indexOf("px") > 0) {
              width = parseFloat(iframeContainer2.style.width);
            }
            if (width == null || width == 0) {
              width = iframeContainer2.getBoundingClientRect().width;
            }
            if (iframeContainer2.style.height != null && iframeContainer2.style.height != "" && iframeContainer2.style.height.indexOf("px") > 0) {
              height = parseFloat(iframeContainer2.style.height);
            }
            if (height == null || height == 0) {
              height = iframeContainer2.getBoundingClientRect().height;
            }
          }
          return {
            width,
            height
          };
        }
      };
      return webView;
    },
    getCookieExpirationDate: function(timestamp) {
      return new Date(timestamp).toUTCString();
    },
    nativeAsyncCommunication: function(method, viewId, args) {
      throw new Error("Method not implemented.");
    },
    nativeSyncCommunication: function(method, viewId, args) {
      throw new Error("Method not implemented.");
    },
    nativeCommunication: function(method, viewId, args) {
      try {
        const result = window.flutter_inappwebview_plugin.nativeSyncCommunication(method, viewId, args);
        return result != null ? JSON.parse(result) : null;
      } catch (e1) {
        try {
          const promise = window.flutter_inappwebview_plugin.nativeAsyncCommunication(method, viewId, args);
          return promise.then(function(result) {
            return result != null ? JSON.parse(result) : null;
          });
        } catch (e2) {
          return null;
        }
      }
    }
  };
  let _nativeCommunication = window.flutter_inappwebview_plugin.nativeCommunication;
})();