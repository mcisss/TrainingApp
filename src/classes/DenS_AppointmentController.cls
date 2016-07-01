public with sharing class DenS_AppointmentController {
        
    public DenS_AppointmentController() {
    }
        
        
    //TODO
    // nie mysle, najpierw css
    // wyświetla się czerwiec a potem się wykrzacza, czemu? tak jakby redercaledar nie wypalilo badz wypalilo za wczesnie
    // rozgryz to metoda sprawdz male potem duze
    
    //  przydatne
    //  get user type: List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    //  String MyProflieName = PROFILE[0].Name;    
        
        
        
    public DenS_Appointment__c appointment {get;set;}
    public Client__c client {get;set;}
    public User dentist {get;set;}
    
    
    public List<DenS_Appointment__c> configs {get;set;}
    public String appointmentsToDeleteID {get;set;}
    public String pomS {get;set;}
    public String pomE {get;set;}
    public Decimal ValueToFormat {get;set;}
    public String dentistId {get;set;}
    
    public DateTime dateTimeDummy {get;set;}
    public String yearToday {get;set;}
    public String monthToday {get;set;}
    public String dayOfTheWeekToday {get;set;}
    public Integer dayOfTheMonthToday {get;set;}    
    public Integer nbOfNullSpaces1 {get;set;}
    public Integer nbOfNullSpaces2 {get;set;}
    
    public String monthDisplay {get;set;}
    public String yearDisplay {get;set;}
       
    public List<DenS_Config__c> wconfigs {get;set;}   
    public List<DenS_Config__c> sconfigs {get;set;} 
       
    public DenS_AppointmentController(ApexPages.StandardSetController stdController) {   
        String name = ApexPages.currentPage().getParameters().get('id');   
        appointment = (name == null) ? new  DenS_Appointment__c():
            [SELECT Id, Name, Client__c, Date__c, Dentist__c, Description__c, 
        Start_time__c, End_time__c, Status__c FROM  DenS_Appointment__c];
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
        wconfigs = DenS_ConfigController.getWconfigs();
        sconfigs = DenS_ConfigController.getSconfigs();
        
                
        dateTimeDummy = datetime.now().addMonths(3);
        monthToday = dateTimeDummy.format('MMMMM');
        yearToday = dateTimeDummy.format('YYYY');
        dayOfTheWeekToday = dateTimeDummy.format('EEE').substring(0,2);
        dayOfTheMonthToday = dateTimeDummy.day();
        
        setDisplayMonthAndYear ();
                 
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'' + nbOfNullSpaces1+' ' + nbOfNullSpaces2 + ' '));
        
        Date dd= date.today();
        Date i = dd.toStartOfMonth();
        
        Set<String> sss = getLiToHighlight();
        //String monthName2 = dd.format('YYYY');
        
        //Date z = d;
        
        //daysInMonth(year, month)
    }      
    //==========MODIFIERS========================
    public void setDisplayMonthAndYear () {
        monthDisplay = dateTimeDummy.format('MMMMM');  
        yearDisplay = dateTimeDummy.format('YYYY');
        Date dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), dateTimeDummy.day());
    	Date myDate = date.newInstance(2016, 6, 20); //Monday
        nbOfNullSpaces1 = Math.mod(myDate.daysBetween(dateDummy), 7); 
        nbOfNullSpaces2 = 31 - date.daysInMonth(dateTimeDummy.year(), dateTimeDummy.month());
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'' + monthDisplay +' ' + yearDisplay+ ' ' +nbOfNullSpaces2));
    }
    public PageReference addMonth() {
    	dateTimeDummy = dateTimeDummy.addMonths(1);
    	setDisplayMonthAndYear();
    	return null;
    }
    public PageReference subtractMonth() {
    	dateTimeDummy = dateTimeDummy.addMonths(-1);
    	setDisplayMonthAndYear();
    	return null;
    }
    public PageReference save() {
         if ( 1 == 1 ) {  // validation checks   
            try {
                upsert appointment;
                appointment = new DenS_Appointment__c();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config saved'));
            } catch (DmlException e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config not saved. One of the following occurred:\n1. The start time is not earlier than the end time.\n2. Config date should be in the future'));
                //System.debug('The following exception has occurred: ' + e.getMessage());
                return null; 
            }
         }
         return null;
    }
    public void removeAppointment(){
        delete [SELECT Id FROM DenS_Appointment__c WHERE Id=:appointmentsToDeleteID];
    }
    
    ///=============MODIFIERS-END========================  
    //==========GETTERS========================   
 
 	public Set<String> getLiToHighlight() {
 		Set<String> lis = new Set<String>();
 		Date dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), 1);
 		for ( DenS_Config__c con : sconfigs) {
 			if ( dateDummy <= con.date__c && con.date__c <= date.newinstance(dateTimeDummy.year(), dateTimeDummy.month(), date.daysInMonth(dateTimeDummy.year(), dateTimeDummy.month() )  ) ) {
 				Date temp = date.newInstance(con.date__c.year(),con.date__c.month(),con.date__c.day() );
 				String a = String.valueOf(temp).substring(0,3);
 				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,''+a));
 				lis.add(a);
 			}
 		}
 		
 		
 		return lis;
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
  
    public String[] getDaysOfTheWeek () {
		String[] dayst = new String[] {'Mo','Tu','We','Th','Fr','Sa','Su'};
		return dayst;
	}
    public List<SelectOption> getWorkingHours() {  
        List<SelectOption> options = new List<SelectOption>(); 
        String hour, inminutes;
        options.add(new SelectOption('9999','--:--'));
        for (Integer i = 0 ; i <24 ; i++) {
            hour = string.valueOf(Time.newInstance(i, 0, 0, 0)).substring(0,5);
            inminutes = string.valueOf(  integer.valueOf(hour.substring(0,2))*60 
                                       + integer.valueOf(hour.substring(3,5)     )
                      );
            options.add(new SelectOption(inminutes,hour));  // value bez : label z musi być string  !!!!!!!!!!
        }   
        return options; 
    }
    
    ///=============GETTERS-END========================  
    //==========Helpers=============================
    
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
     public void doNothing() {
    }
    
    ///=============Helpers-END=============================
    
    //==========TMP======================================  
    
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
    ///===========TMP-END======================================
}