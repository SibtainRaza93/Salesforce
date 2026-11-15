public with sharing class CountryService {

    public class UserDto {
        @AuraEnabled public Integer id;
        @AuraEnabled public String name;
        @AuraEnabled public String email;
        @AuraEnabled public String city;
        @AuraEnabled public String company;
        @AuraEnabled public String website;
    }

    @AuraEnabled
    public static List<UserDto> getUsers() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://jsonplaceholder.typicode.com/users');
        req.setMethod('GET');
        req.setTimeout(20000);

        HttpResponse res;
        try {
            res = new Http().send(req);
        } catch (Exception e) {
            throw new AuraHandledException('Unable to reach the API: ' + e.getMessage());
        }

        if (res.getStatusCode() != 200) {
            throw new AuraHandledException('API returned status ' + res.getStatusCode());
        }

        List<UserDto> result = new List<UserDto>();
        Object parsed = JSON.deserializeUntyped(res.getBody());
        if (!(parsed instanceof List<Object>)) {
            throw new AuraHandledException('Unexpected response format from API');
        }

        for (Object item : (List<Object>) parsed) {
            Map<String, Object> m = (Map<String, Object>) item;
            UserDto dto = new UserDto();
            dto.id = Integer.valueOf(String.valueOf(m.get('id')));
            dto.name = (String) m.get('name');
            dto.email = (String) m.get('email');
            dto.website = (String) m.get('website');

            Map<String, Object> addr = (Map<String, Object>) m.get('address');
            dto.city = addr != null ? (String) addr.get('city') : '-';

            Map<String, Object> comp = (Map<String, Object>) m.get('company');
            dto.company = comp != null ? (String) comp.get('name') : '-';

            result.add(dto);
        }
        return result;
    }
}