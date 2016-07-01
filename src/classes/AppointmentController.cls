public with sharing class AppointmentController {
	    
	//TODO
	// jak zaaccesować email    
	
	//  przydatne
	//  get user type: List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
	//  String MyProflieName = PROFILE[0].Name;    
	    
	    
	    
	public Appointment__c appointment {get;set;}
    public Client__c client {get;set;}
    public User dentist {get;set;}
    
    
    public List<Appointment__c> configs {get;set;}
    public String appointmentsToDeleteID {get;set;}
    public String pomS {get;set;}
    public String pomE {get;set;}
    public Decimal ValueToFormat {get;set;}
    public String dentistId {get;set;}
    
    public DateTime d {get;set;}
    public String monthName {get;set;}
    public String year {get;set;}
    public String daynb {get;set;}
    
       
    public AppointmentController(ApexPages.StandardSetController stdController) {   
        String name = ApexPages.currentPage().getParameters().get('id');   
        appointment = (name == null) ? new  Appointment__c():
            [SELECT Id, Name, Client__c, Date__c, Dentist__c, Description__c, 
        Start_time__c, End_time__c, Status__c FROM  Appointment__c];
        dentistID='d1';
        appointment.Description__c = 'tajtjatj';
        // tutaj zrobimy checka chwilowo
        client = [SELECT Id, Name, First_name__c, Second_name__c, Email__c, Phone_number__c from Client__c LIMIT 1][0];
        appointment.Client__c = [SELECT Id, Name, Email__c from Client__c LIMIT 1][0].Id;
        
        if (client.id == appointment.Client__c) {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'client EXISTS1'));
        }
        else {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'client don\'t EXIST'));
        }
        /*
        GregorianCalendar now = new GregorianCalendar();
        Integer month = now.get(Calendar.MONTH); 
		Integer weekday = now.get(Calendar.DAY_OF_WEEK);
        */
        
        // Date dateToday = Date.today;
        d = datetime.now();
		monthName= d.format('MMMMM');
		monthName= d.format('YYYY');
		
		
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,' '+monthName));
        
        Date dd= date.today();
        Date i = dd.toStartOfMonth();
        //String monthName2 = dd.format('YYYY');
        
        //Date z = d;
        
        //daysInMonth(year, month)
        
        //newInstance(2008, 1, 1) 
    }      
    public PageReference save() {
	     if ( 1 == 1 ) {  // validation checks   
	        try {
	        	upsert appointment;
	        	appointment = new Appointment__c();
	        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config saved'));
	        } catch (DmlException e) {
	        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config not saved. One of the following occurred:\n1. The start time is not earlier than the end time.\n2. Config date should be in the future'));
	        	//System.debug('The following exception has occurred: ' + e.getMessage());
	        	return null; 
	        }
	     }
	     return null;
    }
    public List<SelectOption> getDentists () {
    	List<SelectOption> options = new List<SelectOption>();
    	List<User> ul = [SELECT Name FROM User 
    							WHERE profileid IN (SELECT Id FROM Profile WHERE Name=:'Dentist')
    						   ];
        for (User u: ul) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'id= '+u.Id +'name= ' + u.Name));
        	options.add(new SelectOption(u.Id,u.Name));
        }
        return options; 
    }
   
   
   
    public List<Client__c> getClient () { return null;}
    
    public void tm () {
       List<User> ul = [SELECT Name FROM User 
    							WHERE profileid IN (SELECT Id FROM Profile WHERE Name=:'Dentist')
    						   ];
       for (User u: ul) {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'id= '+u.Id +'name= ' + u.Name));
       }
    }
  
	public void tm2 () {
		List<User> ul = [select Name from user];
		// where id=:userinfo.getuserid()
		for( User u: ul) {
			//getUserInfoResult result = u.getUserInfo();
			
			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Cos '+result.getUserFullName()));
		}
	}
  
    
    
    public List<SelectOption> getWorkingHours() {  
        List<SelectOption> options = new List<SelectOption>(); 
        String hour, inminutes;
        options.add(new SelectOption('9999','--:--'));
        for (Integer i = 0 ; i <24 ; i++) {
            hour = string.valueOf(Time.newInstance(i, 0, 0, 0)).substring(0,5);
            inminutes = string.valueOf(  integer.valueOf(hour.substring(0,2))*60 
            		  				   + integer.valueOf(hour.substring(3,5)	 )
                      );
            options.add(new SelectOption(inminutes,hour));  // value bez : label z musi być string  !!!!!!!!!!
        }   
        return options; 
    }
    
    public void removeAppointment(){
        delete [SELECT Id FROM Appointment__c WHERE Id=:appointmentsToDeleteID];
    }
    
	public void checkClientExists () {
    	for ( Client__c cl : [SELECT Email__c from Client__c LIMIT 1]) {
	    	if (client.Email__c == cl.Email__c) {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Client exists'));
	    		
	    	}
	    	else {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Not this client'));
	    	}
    	}
    }
    
    /*
    public Boolean checkClientExists () {
    	for ( Client__c cl : [SELECT Email__c from Client__c LIMIT 1]) {
	    	if (client.Email__c == cl.Email__c) {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Client exists'));
	    		return true;
	    	}
	    	else {
	    		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Not this client'));
	    	}
    	}
    	return false;
    }
    */
    
}