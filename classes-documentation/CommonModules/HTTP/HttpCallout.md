---
layout: default
---

# HttpCallout class

Common class to perform HTTP Callouts. Use this class to perform all Http Calls. Do not use standard HttpRequest class directly

## Related

[HttpCalloutModuleMock](/Miscellaneous/HttpCalloutModuleMock.md)

---

## Constructors

### `HttpCallout()`

Default constructor. Use it to create and send Http callout

#### Example

```
new HttpCallout()
    .endPoint('http://www.google.com.br')
    .method('POST')
    .addHeader('Content-Type','application/json')
    .addParameter('parameter1','')
    .addParameter(parameters)
    .addHeader('header1','valueHeader')
    .addHeader(headers)
    .body('body')
    .timeout(10000)
    .send();
```

---

## Properties

### `httpInstance` → `Http`

Instance of standard Http class

### `request` → `HttpRequest`

Instance of standard HttpRequest class

### `response` → `HttpResponse`

Instance of standard HttpResponse class

---

## Methods

### `addHeader(String key, String body)` → `HttpCallout`

Adds a header to the request

#### Parameters

| Param | Description  |
| ----- | ------------ |
| `key` | header Key   |
| `key` | header value |

#### Example

```
HttpCallout callout =  new HttpCallout()
   .addHeader('testKey', 'testValue')
   ...
```

### `addHeader(Map<String, String> collectionHeaders)` → `HttpCallout`

Adds multiple headers to the request

#### Parameters

| Param               | Description                                                |
| ------------------- | ---------------------------------------------------------- |
| `collectionHeaders` | Map<String, String> containing keys and values for headers |

#### Example

```
Map<String, String> headersMap = new Map<String, String>{'key1' => 'value1', 'key2' => 'value2'};
HttpCallout callout =  new HttpCallout()
   .addHeader(headersMap)
   ...
```

### `addParameter(String key, String value)` → `HttpCallout`

Adds a parameter to the URL

#### Parameters

| Param | Description     |
| ----- | --------------- |
| `key` | parameter Key   |
| `key` | parameter value |

#### Example

```
HttpCallout callout =  new HttpCallout()
   .addParameter('testKey', 'testValue')
   ...
```

### `addParameter(Map<String, List<String>> collectionParameters)` → `HttpCallout`

Adds multiple parameters to the request body

#### Parameters

| Param | Description     |
| ----- | --------------- |
| `key` | parameter Key   |
| `key` | parameter value |

#### Example

```
Map<String, String> parametersMap = new Map<String, String>{'key1' => new List<String>{'value1'}, 'key2' => new List<String>{'value2'};
HttpCallout callout =  new HttpCallout()
   .addParameter(parametersMap)
   ...
```

### `addParameterBody(Map<String, List<String>> collectionParameters)` → `HttpCallout`

Adds a parameter to the request body

#### Parameters

| Param                  | Description                                                   |
| ---------------------- | ------------------------------------------------------------- |
| `collectionParameters` | Map<String, String> containing keys and values for parameters |

#### Example

```
Map<String, String> parametersMap = new Map<String, String>{'key1' => new List<String>{'value1'}, 'key2' => new List<String>{'value2'};
HttpCallout callout =  new HttpCallout()
   .addParameterBody(parametersMap)
   ...
```

### `addParameterBody(String key, String value)` → `HttpCallout`

Adds a parameter to the request body

#### Parameters

| Param | Description          |
| ----- | -------------------- |
| `key` | body parameter Key   |
| `key` | body parameter value |

#### Example

```
HttpCallout callout =  new HttpCallout()
   .addParameterBody('testKey', 'testValue')
   ...
```

### `body(String body)` → `HttpCallout`

Specifies the body for this request

#### Parameters

| Param  | Description        |
| ------ | ------------------ |
| `body` | JSON/XML as String |

#### Example

```
HttpCallout callout =  new HttpCallout()
   .body('{"testParam1":"testValue1"}')
   ...
```

### `bodyToJson(Object o)` → `HttpCallout`

Specifies the body for this request

#### Parameters

| Param | Description |
| ----- | ----------- |
| `o`   | Object      |

#### Example

```
public class ExampleBody {
    public String testParam1;
}
ExampleBody body = new ExampleBody();
body.testParam1 = "testValue1";
HttpCallout callout =  new HttpCallout()
   .bodyToJson('{"testParam1":"testValue1"}')
   ...
```

### `builder()` → `HttpCallout`

Constructs the Http Call. Performs the validation of Http Call properties. Its not required to invoke this method explicitly because it is invoked by send() method

#### Example

```
HttpCallout callout =  new HttpCallout()
   ...
   .builder();
```

### `endPoint(String endpoint)` → `HttpCallout`

Specifies the endpoint for this request - Required

#### Parameters

| Param      | Description                                             |
| ---------- | ------------------------------------------------------- |
| `endpoint` | value for endpoint, eg. http://data.fixer.io/api/latest |

#### Example

```
HttpCallout callout =  new HttpCallout()
   .endPoint('http://data.fixer.io/api/latest')
```

### `method(String method)` → `HttpCallout`

Specifies the type of method to be used in the HTTP request - Required

#### Parameters

| Param    | Description                         |
| -------- | ----------------------------------- |
| `method` | GET, POST, PUT, DELETE, TRACE, HEAD |

#### Example

```
Map<String, String> headersMap = new Map<String, String>{'key1' => 'value1', 'key2' => 'value2'};
HttpCallout callout =  new HttpCallout()
   .method('GET')
   ...
```

### `send()` → `HttpResponse`

Constructs the Http Call and performs the call

#### Example

```
HttpCallout callout =  new HttpCallout()
   ...
   .send();
```

### `timeout(Integer timeout)` → `HttpCallout`

Specifies the timeout for this request - default value is 10000 ms

#### Parameters

| Param     | Description          |
| --------- | -------------------- |
| `timeout` | value in miliseconds |

#### Example

```
HttpCallout callout =  new HttpCallout()
   .timeout(5000)
   ...
```

---

## Inner Classes

### HttpCallout.HttpCalloutException class

Exception thrown by HttpCallout class

---
