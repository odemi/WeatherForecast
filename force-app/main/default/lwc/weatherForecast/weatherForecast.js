import { LightningElement } from 'lwc';
import getWeatherData from '@salesforce/apex/WeatherForecastController.getWeatherData';

export default class WeatherForecast extends LightningElement {
    weatherData;
    location;
    cityName = '';
    showForecast = false;
    showError = false;

    handleSearch(){
        this.showError = false;
        this.cityName = this.location;
        this.showForecast = false;
        getWeatherData({location : this.location})
            .then(result => {
                this.weatherData = result;
                this.showForecast = true;
            }).catch(error => {
                this.showError = true;
                this.showForecast = false;
        });
    }

    handleChange(event){
        this.location = event.target.value;
    }
}