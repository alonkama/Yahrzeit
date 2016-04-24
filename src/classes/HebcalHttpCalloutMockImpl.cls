@IsTest
public class HebcalHttpCalloutMockImpl implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
    	
    	System.assert(req.getEndpoint().contains('www.hebcal.com'));
        System.assertEquals('GET', req.getMethod());
        
        // Create a fake response     
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        res.setBody('{"gy":2011,"gm":6,"gd":2,"hy":5771,"hm":"Iyyar","hd":29,"hebrew":"כ״ט בְּאִיָיר תשע״א"}');
        res.setStatusCode(200);
        return res;    
    }
}