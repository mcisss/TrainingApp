/**********************************************************************
*Dentist's working hours cofiguration                                  
***********************************************************************
*Description:                                                          
*There are two pickable types of working hours:
*assigned to weekdays and assigned to specified date.
*
*
*Created by: Marcin Bartosiak
***********************************************************************/

public class ConfigController {

    public ConfigController() {

    }
    
	//commit 28.06
	
	//Strategy: first done good, then beauty
 
    //TODO:
    
    //      sprawdzić rozwiązanie 2 DatePicker.pickDate  https://developer.salesforce.com/forums/?id=906F000000097bvIAA
	//      on the other site - don't let non-dentists to access the config page
	
    // optionally: do not show old configs i.e. those with date < NOW();
    
    
    public Config__c config { get; set; }
    public List<Config__c> configs {get;set;}
    public String configsToDeleteID {get;set;}
    public String pomS {get;set;}
    public String pomE {get;set;}
    public Decimal ValueToFormat {get;set;}
    

    public ConfigController(ApexPages.StandardSetController stdController) {   
        String name = ApexPages.currentPage().getParameters().get('id');   
        config = (Name == null) ? new Config__c():
            [SELECT Id, Name, Active__c, date__c, 
        Start_time__c, End_time__c, Weekday__c, Dentist__c FROM Config__c];
    }      
    
    public PageReference save() {
        config.Start_time__c = Decimal.valueOf(pomS);
        config.End_time__c = Decimal.valueOf(pomE);
        if (config.Weekday__c == 'Choose weekday' && config.date__c == null) {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config not saved. Please specify the weekday or date'));
        	return null;
        }
  
        if ( !overlapcheck() ) {   // validation checks  
        	try {
        	upsert config;
        	config = new Config__c();
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Config saved'));
        	} catch (DmlException e) {
        		//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config not saved. One of the following occurred:\n1. The start time is not earlier than the end time.\n2. Config date should be in the future'));
        		//System.debug('The following exception has occurred: ' + e.getMessage());
        	return null; 
        	}
        }
        return null;       
    }

    public void removeConfig(){
        delete [SELECT Id FROM Config__c WHERE Id=:configsToDeleteID];
    }
    public List<SelectOption> getWeekdays()
    {
       List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = Config__c.Weekday__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }     
    public List<SelectOption> getWorkingHours() {  
        List<SelectOption> options = new List<SelectOption>(); 
        String hour, inminutes;
        options.add(new SelectOption('0000','--:--'));
        for (Integer i = 0 ; i <24 ; i++) {
            hour = string.valueOf(Time.newInstance(i, 0, 0, 0)).substring(0,5);
            inminutes = string.valueOf(  integer.valueOf(hour.substring(0,2))*60 
            		  				   + integer.valueOf(hour.substring(3,5)	 )
                      );
            options.add(new SelectOption(inminutes,hour));  // value bez : label z musi być string  !!!!!!!!!!
        }   
        return options; 
    }  
    public String getFrommintohours2() {
        String hours = string.valueOf(Math.floor(ValueToFormat/60));
        if (hours.length() == 1) {
        	hours = '0' + hours;
        }
        return hours + ':00';
    }
    public List<Config__c> getWconfigs () {
        return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM Config__c WHERE date__c =:null ORDER BY Weekday__c, Start_time__c];
    }
     public List<Config__c> getSconfigs () {
        return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM Config__c WHERE date__c !=:null ORDER BY date__c, Start_time__c];
    }
 
    public Boolean overlapcheck () { // checks whether the hours chosen do not overlap with other configs
        List<Config__c> w_or_s_configs = new List<Config__c>();  
        String config_type;
        if ( config.date__c == null ) {
            w_or_s_configs = getWconfigs(); 
            config_type = 'w';
        }   else {
            w_or_s_configs = getSconfigs();
            config_type = 's';
        }
        return overinside(w_or_s_configs, config_type);
    }
    public Boolean overinside(List<Config__c> w_or_s_configs, String config_type) {  // called in overlapcheck
        for (Config__c con : w_or_s_configs) {      
            if( config_type == 'w') {
                if( config.Weekday__c == con.Weekday__c) {
                    return overinsidepom (con);
                }    
            } else if (config_type == 's') { 
            	if(config.date__c == con.date__c) {
            		return overinsidepom (con);
            	}
            }
        }
        return false;
    }
    public Boolean overinsidepom (Config__c con) {  // called in overlapcheck
        List<Decimal> timee = new List<Decimal>();
    	timee.add(config.Start_time__c);
        timee.add(config.End_time__c);
    	for (Decimal itime : timee) {
            if (itime > con.Start_time__c && itime < con.End_time__c ) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Start or end time within the scope of other config\'s working hours'));
                return true; 
            }
        }
        if ( timee[0] <= con.Start_time__c && timee[1] >= con.End_time__c ) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The chosen working hours encapsulate the other config\'s hours on the selected day'));
            return true; 
        }
        return false;
    }
    public void ChangeConfigTypeW () {
    	config.date__c = null;
    	config.Weekday__c = 'Choose weekday';
    }
    public void ChangeConfigTypeS () {
    	config.Weekday__c = 'Choose weekday';
    }
	public void doNothing() {
	}
}