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

 
 	//TODO: times viewed as a String, validation - the times cannot overlap  jquerry - prościej łapiesz fileldy do pojawienia show hide   javascirpt onchange   wszystko możesz ukrywać w locie na stronie
 	//		kurs z jquery: https://www.codeschool.com/courses/try-jquery
 
    
    public Config__c config { get; set; }
    public List<Config__c> configs {get;set;}
    public String configsToDeleteID {get;set;}
    public Boolean rend {get;set;}
    public String pomS {get;set;}
    public String pomE {get;set;}
    public Decimal timePom {get;set;}
    //public List<String> lpomS {get;set;}
    //public Config__c config2 { get; set; }
    
    
    public ConfigController(ApexPages.StandardSetController stdController) {   
        String name = ApexPages.currentPage().getParameters().get('id');   
        pomE = 'fkfa';
        config = (Name == null) ? new Config__c():
            [SELECT Id, Name, Active__c, Config_type__c, date__c, 
        Start_time__c, End_time__c, Weekday__c, Dentist__c FROM Config__c];
    }      
    
    public PageReference save() {

                	/*
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Error Message.');
                    ApexPages.addMessage(myMsg); 
                    return null;  //  ok to override?  delete and upsert
                    }
                    */
	    config.Start_time__c = Decimal.valueOf(pomS);
	    config.End_time__c = Decimal.valueOf(pomE);
        upsert config;
        config = new Config__c();
        return null;       
    }
    
    public void removeConfig(){
        delete [SELECT Id FROM Config__c WHERE Id=:configsToDeleteID];
    }
    
    public PageReference commandLinkAction() {
        rend = true;
        return null;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('Weekday','Weekday')); 
        options.add(new SelectOption('Specific day','Specific day'));
        return options; 
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
    	options.add(new SelectOption('9999','--:--'));
		for (Integer i = 0 ; i <24 ; i++) {
			hour = string.valueOf(Time.newInstance(i, 0, 0, 0)).substring(0,5);
			inminutes = string.valueOf(integer.valueOf(hour.substring(0,2))*60 + 
					  integer.valueOf(hour.substring(3,5))
			          );
			options.add(new SelectOption(inminutes,hour));  // value bez : label z musi być string  !!!!!!!!!!
		}	
        return options; 
    }  
     
    public List<Config__c> getWconfigs () {
        return [SELECT Id, Name, Active__c, Config_type__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM Config__c WHERE Config_type__c =:'Weekday' ORDER BY Weekday__c];
    }
     public List<Config__c> getSconfigs () {
        return [SELECT Id, Name, Active__c, Config_type__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM Config__c WHERE Config_type__c !=:'Weekday'ORDER BY date__c];
    }
    public String dTime () {
    	return null;
    }
       
    public Boolean getExists () {    // checks whether a config for the chosen weekday already exists
   	 	for (Config__c con : getWconfigs()) {
            if (config.Weekday__c.equals(con.Weekday__c)) {  // to powinno być w save - 
                return true;                   
            }
   	 	}
        return false;
        	// działa
        	//  "if({!exists}) {if(!confirm('Are you sure?')) return false;}"
    }  
    public Decimal getDispTime () { 
    	return timePom;
    }
        public String getDispTime2 () { 
    	String w1 = string.valueof(timePom.intValue());
   		return w1; 
    }
    public String getSTime () { 
    	integer.valueof(pomS);
    	return pomS;
    }
    public String getETime () {}
    public String getDispSTime () {             //custom componnent -  i przekażesz w atrybucie taga
    	// Decimal s = [SELECT Start_time__c FROM Config__c WHERE Id=:configsToDeleteID][0].Start_time__c;
    	List<Config__c> s = [SELECT Id, Start_time__c FROM Config__c WHERE Id=:configsToDeleteID];
    	if (s.isEmpty())
    		return hoursDecimaltoString(1245);
    		return 'nulll';
    	// return '1';
    	// return hoursDecimaltoString(s);
    }
    public String hoursDecimaltoString (Decimal inminutes) {
    	String temp = string.valueOf(Math.floor(inminutes.intValue()/60)).leftpad(2)
    				+ string.valueOf(Math.mod(inminutes.intValue(),60));
    	return temp;  // zrób na minuty leftpad  
    }
    public Integer hourStringtoInt (String shour) { 
    	shour = shour.reverse();
 		shour = shour.substring(0,2)+shour.substring(3);
    	shour = shour.reverse();
    	return integer.valueof(shour);
    }
    public void pomS() {
    	//if( !overlapcheck ("Start time") ) {
    		config.Start_time__c = hourStringtoInt(pomS);
    	//}
    }
    public void pomE() {
    	//if( !overlapcheck ("End time") ) {
    		config.End_time__c = hourStringtoInt(pomE);
    	//}
    }
    /*
    public Boolean overlapcheck (String S_or_End_time) { // checks wherther the hours chosen do not overlap with other config
    	List<Config__c> w_or_s_configs = new List<Config__c>();  
        String config_type;
        if ( config.Config_type__c == 'Weekday' ) {
        	w_or_s_configs = getWconfigs();	
        	config_type = 'w';
       	}   else {
       		w_or_s_configs = getSconfigs();
       		config_type = 's';
       	}
		if (S_or_End_time == 'Start time' && config_type == 'w' ) {
			overlapcheckstart (w_or_s_configs, S_or_End_time);
			return 
		}
		if (S_or_End_time == 'End time') {
			return overlapcheckone (w_or_s_configs, S_or_End_time);
		}
		
		
    }
    
    public Boolean overlapcheckStart (List<Config__c> w_or_s_configs, Decimal workingHour) {
    	for (Config__c con : w_or_s_configs) {      
	        if( config.Weekday__c == con.Weekday__c) {
	        	if (s_or_e_time < con.Start_time__c && s_or_e_time < con.End_time__c ) {
        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Start time within the scope of other config'));
        			return false; // starttime znajduje się w przedziale czasu con.
	        	}
	        }
		}
		return true;
    }
    public Boolean endoverlapcheck (List<Config__c> w_or_s_configs) {
        for (Config__c con : w_or_s_configs) {      
	        if( config.Weekday__c == con.Weekday__c) {
	        	if (config.Start_time__c < con.End_time__c) {
	        		if (config.End_time__c < con.Start_time__c) {
	        			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Start time within the scope of other config'));
	        			return false; // starttime znajduje się w przedziale czasu con.
	        		}
	        		else {
	        			if(config.End_time__c > con.Start_time__c) {
	        				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'End time within the scope of other config'));
	        				return false;   // endtime znajduje się w przedziale czasu con. 
	        			}
	        		}
	        	}
	        }
		}
    }
    */
    
    public void init() {
    	config.Start_time__c = hourStringtoInt(pomS);
    	config.End_time__c = hourStringtoInt(pomE);
    	//Config_type__c = 
    }
}