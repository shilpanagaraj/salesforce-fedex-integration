import { LightningElement, wire,track,api  } from 'lwc';
import getShippingRate from '@salesforce/apex/fedexRestCallout.getRate';
export default class FedexRatesLWC extends LightningElement {
   
     @track fromCountryCode;
     @track fromPostalCode;
     @track weightInlbs;
     @track toPostalCode;
     @track toCountryCode;
     @track resMap = [];
     @track resReceived = false; 

     handleClick(event)
    {
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            if(element.name=="fromCountryCode")
            {
                this.fromCountryCode=element.value;               
            }  
            else if(element.name=="fromPostalCode")
            {
                this.fromPostalCode=element.value;
            }
            else if(element.name=="weightInlbs")
            {
                this.weightInlbs=element.value;
            } 
            else if(element.name=="toCountryCode")
            {
                this.toCountryCode=element.value;
            } 
            else if(element.name=="toPostalCode")
            {
                this.toPostalCode=element.value;
            } 
        },this);

        getShippingRate({fromCountryCode:this.fromCountryCode,fromPostalCode:this.fromPostalCode,toCountryCode:this.toCountryCode,toPostalCode:this.toPostalCode,weightInlbs:this.weightInlbs})
		.then(result => {
            console.log('result', result);
            this.resMap = [];
            for (var key in result) {
                this.resMap.push({ key: key, value: result[key] });
                console.log('key', key, result[key]);
            }
            this.resReceived = true;
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
            console.log('response error : '+ error);
			this.response = 'An Error occoured. Please contact Administrator';
		})
        



        
    }



}
