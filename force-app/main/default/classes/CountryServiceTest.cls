@isTest
private class CountryServiceTest {

    private class MockOk implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('[{"id":1,"name":"Leanne Graham","email":"demo@example.com","website":"example.org","address":{"city":"Gwenborough"},"company":{"name":"Romaguera-Crona"}}]');
            return res;
        }
    }

    private class MockFail implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('error');
            return res;
        }
    }

    @isTest static void testSuccess() {
        Test.setMock(HttpCalloutMock.class, new MockOk());
        Test.startTest();
        List<CountryService.UserDto> data = CountryService.getUsers();
        Test.stopTest();
        System.assertEquals(1, data.size());
        System.assertEquals('Leanne Graham', data[0].name);
        System.assertEquals('Gwenborough', data[0].city);
    }

    @isTest static void testFailure() {
        Test.setMock(HttpCalloutMock.class, new MockFail());
        try {
            CountryService.getUsers();
            System.assert(false, 'Expected exception');
        } catch (AuraHandledException e) {
            System.assert(true);
        }
    }
}