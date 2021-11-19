global class WeatherForecastController {
    @AuraEnabled(cacheable=true)
    global static List<WeatherData> getWeatherData(String location){
        Weather_Forecast_Settings__mdt wfs = [SELECT Endpoint__c, Key__c FROM Weather_Forecast_Settings__mdt WHERE DeveloperName='API_Info' LIMIT 1];
        String responseBody = getDataFromAPI(wfs.Key__c, wfs.Endpoint__c, location);

        return deserializeJSONResponse(responseBody, location);
    }

    global static String getDataFromAPI(String key, String endpoint, String location){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint + 'key=' + key +'&q=' + location + '&days=7&aqi=no&alerts=no');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);

        return res.getBody();
    }

    global static List<WeatherData> deserializeJSONResponse(String jsonStr, String location){
        List<WeatherData> weathers = new List<WeatherData>();

        Map<String, Object> results= (Map<String, Object>)JSON.deserializeUntyped(jsonStr);
        Map<string,object> resultsForecast = (Map<string,object>)(results.get('forecast'));
        
        List<Object> resultsForecastDay = (List<Object>)(resultsForecast.get('forecastday'));
        
        for(Integer i = 0; i < resultsForecastDay.size(); i++){
            Map<string,object> resultsByDate =( Map<string,object>)(resultsForecastDay[i]);
        	Map<string,object> dayInfo = (Map<string,object>)(resultsByDate.get('day'));
            Map<string,object> conditionMap = (Map<string,object>)(dayInfo.get('condition'));
           	WeatherData w = new WeatherData();
            w.cityName = location;
            w.weatherDate = String.valueOf(resultsByDate.get('date'));
            w.averageTemp = (Decimal)dayInfo.get('avgtemp_c');
            w.precipitation = (Decimal)dayInfo.get('totalprecip_mm');
            w.chanceOfRain = (Decimal)dayInfo.get('daily_chance_of_rain');
            w.chanceOfSnow = (Decimal)dayInfo.get('daily_chance_of_snow');
            w.icon = String.valueOf(conditionMap.get('icon'));
            weathers.add(w);            
        }

        return weathers;
    }

    global class WeatherData {
        @AuraEnabled 
        public String cityName;
        @AuraEnabled
        public String weatherDate;
        @AuraEnabled 
        public Decimal averageTemp;
        @AuraEnabled 
        public Decimal precipitation;
        @AuraEnabled 
        public Decimal chanceOfRain;
        @AuraEnabled 
        public Decimal chanceOfSnow;
        @AuraEnabled 
        public String icon;
    }
}