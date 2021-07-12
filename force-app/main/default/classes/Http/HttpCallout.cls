/**
 * @description Common class to perform HTTP Callouts. Use this class to perform all Http Calls.
 * Do not use standard HttpRequest class directly
 * @author Adam Osiecki
 * @date 2021-09-11
 */
public virtual class HttpCallout {

    public HttpRequest request;
    public Http httpInstance;

    public HttpResponse response;
    private String endpoint; 
    private String method;
    private String body;
    private Integer timeout;
    private Map<String, String> headers;
    private Map<String, List<String>> parameters;
    private Map<String, List<String>> parametersBody;

    public HttpCallout() {
        response = new HttpResponse();
        httpInstance = new Http();
        headers = new Map<String, String>();
        parameters = new Map<String, List<String>>();
        parametersBody = new Map<String, List<String>>();
    }

    public virtual HttpCallout endpoint(String endpoint) {
        this.endpoint = endpoint;
        return this;
    }

    public virtual HttpCallout body(String body) {
        this.body = body;
        return this;
    }

    public virtual HttpCallout bodyToJson(Object o) {
        this.body = JSON.serialize(o);
        return this;
    }

    public virtual HttpCallout timeout(Integer timeout) {
        this.timeout = timeout;
        return this;
    }

    public virtual HttpCallout addHeader(String key, String body) {
        this.headers.put(key, body);
        return this;
    }


    public virtual HttpCallout addHeader(Map<String, String> collectionHeaders) {
        for (String header : collectionHeaders.keySet()) {
            this.headers.put(header, collectionHeaders.get(header));
        }
        return this;
    }

    public virtual HttpCallout method(String method) {
        this.method = method;
        return this;
    }

    public virtual HttpCallout addParameter(String key, String value) {
        if (parameters.get(key) == null) {
            parameters.put(key, new List<String>());
        }
        parameters.get(key).add(value);
        return this;
    }

    public virtual HttpCallout addParameterBody(Map<String, List<String>> collectionParameters) {
        for (String parameter : collectionParameters.keySet()) {
            this.parametersBody.put(parameter, collectionParameters.get(parameter));
        }
        return this;
    }

    public virtual HttpCallout addParameterBody(String key, String value) {
        if (parametersBody.get(key) == null) {
            parametersBody.put(key, new List<String>());
        }

        parametersBody.get(key).add(value);
        return this;
    }

    public virtual HttpCallout addParameter(Map<String, List<String>> collectionParameters) {
        for (String parameter : collectionParameters.keySet()) {
            this.parameters.put(parameter, collectionParameters.get(parameter));
        }
        return this;
    }

    public virtual HttpCallout builder() {
        if (!String.isNotBlank(this.method) || String.isEmpty(this.method)) {
            throw new HttpCalloutException('Method not found!');
        }

        if (!String.isNotBlank(this.endpoint) || String.isEmpty(this.endpoint)) {
            throw new HttpCalloutException('Endpoint not found!');
        }

        if (this.timeout != null && this.timeout > 120000) {
            throw new HttpCalloutException('Timeout maximum exceeded!');
        }

        this.request = new HttpRequest();
        this.request.setEndpoint(this.endpoint);
        this.request.setMethod(this.method);

        if (this.body != null) {
            this.request.setBody(this.body);
        }

        if (this.timeout != null) {
            this.request.setTimeout(this.timeout);
        }

        if (!headers.isEmpty()) {
            for (String header : headers.keySet()) {
                request.setHeader(header, headers.get(header));
            }
        }

        if (!parameters.isEmpty()) {
            this.request.setEndpoint(buildQueryStringParameter());
        }

        if (!parametersBody.isEmpty()) {
            this.request.setBody(buildBodyParameter());
        }

        return this;
    }

    public virtual HttpResponse send() {
        try {
            this.builder();
            response = httpInstance.send(this.request);
        } catch (HttpCalloutException ex) {
            throw new HttpCalloutException(ex.getMessage());
        }
        return response;
    }

    private virtual String buildStringParameter(String value, Map<String, List<String>> parameters) {
        Integer count = 0;
        for (String key : parameters.keySet()) {
            if (count == 0) {
                value += key + '=' + buildParameter(key, parameters.get(key));
            } else {
                value += '&' + key + '=' + buildParameter(key, parameters.get(key));
            }
            count++;
        }

        return value;
    }

    private virtual String buildQueryStringParameter() {
        String queryString = this.endpoint;

        if (!parameters.isEmpty()) {
            queryString += '?';
            queryString = buildStringParameter(queryString, parameters);
        }

        return queryString;
    }

    private virtual String buildParameter(String key, List<String> values) {
        String parameter = '';
        Integer count = 0;
        for (String value : values) {
            count++;
            parameter += value;
            parameter += (count == values.size()) ? '' : ',';
        }
        return parameter;
    }

    private virtual String buildBodyParameter() {
        String bodyParameters = '';

        if (!parametersBody.isEmpty()) {
            bodyParameters = buildStringParameter(bodyParameters, parametersBody);
        }

        return bodyParameters;
    }

    public class HttpCalloutException extends Exception {
    }
}