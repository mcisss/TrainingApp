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
    public String dentistId {get;set;}
    
    public DateTime dateTimeDummy {get;set;}
    public Date dateDummy {get;set;}
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
    
    public String w {get;set;}
    public String chosenDayDummy {get;set;}
    public List<String> daysToDisplay {get;set;}
    public List<String> redDays {get;set;}
    
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
        
        
        if (w == null){        
	        dateTimeDummy = datetime.now(); //.addMonths(-5); 
	        dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), dateTimeDummy.day());
	        monthToday = dateTimeDummy.format('MMMMM');
	        yearToday = dateTimeDummy.format('YYYY');
	        dayOfTheWeekToday = dateTimeDummy.format('EEE').substring(0,2);
	        dayOfTheMonthToday = dateTimeDummy.day();
	        
	        setDisplayMonthAndYear ();
        }         
        Date dd = date.today();
        Date i = dd.toStartOfMonth();
        
        List<String> ff = getDaysToHighlight();
        appointment.Date__c = date.newInstance(2016, 7, 21);
        List<List<Decimal>> ff2 =  getFreeTerms ();
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'' + ff2 ));  //'days to highlight:'+ff + 'month' + dateTimeDummy.month()));
    }      
    //==========MODIFIERS========================
    public void setDisplayMonthAndYear () {
        monthDisplay = dateTimeDummy.format('MMMMM');  
        yearDisplay = dateTimeDummy.format('YYYY');
    	Date myDate = date.newInstance(2000, 10, 2); //Monday
        nbOfNullSpaces1 = getDayOfTheWeek();
        nbOfNullSpaces2 = 31 - date.daysInMonth(dateTimeDummy.year(), dateTimeDummy.month());
        daysToDisplay = getDaysOfTheMonth ();              //calculate daysToDisplay for calendar rendering
        for (Integer i=0 ; i < nbOfNullSpaces1 ; i++) {
        	daysToDisplay.add(0,' ');
        }
        for (Integer i=0 ; i < nbOfNullSpaces2 ; i++) {
        	daysToDisplay.set(daysToDisplay.size()-1-i, null);
        }
        //greendays
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'' +daysToDisplay.get(0)+ daysToDisplay.get(30)+ monthDisplay + + yearDisplay+ ' ' + nbOfNullSpaces1 + ' ' +nbOfNullSpaces2));
    }
    public PageReference addMonth() {
    	dateTimeDummy = dateTimeDummy.addMonths(1);
    	dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), dateTimeDummy.day());
    	setDisplayMonthAndYear();
    	return null;
    }
    public PageReference subtractMonth() {
    	dateTimeDummy = dateTimeDummy.addMonths(-1);
    	dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), dateTimeDummy.day());
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
 
 	public List<String> getDaysToHighlight() {
 		Set<String> days = new Set<String>();
 		List<String> daysl = new List<String> ();
 		for ( DenS_Config__c con : sconfigs) {
 			if ( con.date__c.month() == dateTimeDummy.month() && con.date__c.year() == dateTimeDummy.year() ) {//( startDate <= con.date__c && con.date__c <= date.newinstance(dateTimeDummy.year(), dateTimeDummy.month(), date.daysInMonth(dateTimeDummy.year(), dateTimeDummy.month() )  ) ) {
 				//if ( con.Start_time__c  ) { }
 					//overlapcheck (config);
 					// check czy sa zajete
 					String conDay = String.valueOf( con.date__c.day() + nbOfNullSpaces1 - 1 );
 					days.add(conDay);
 				
 			}
 		}
 		daysl.addall(days);
 		return daysl;
 	}
 	
 	
 	public List<List<Decimal>> getFreeTerms () {
 		List<DenS_Appointment__c> appointments = getAppointments ();
 		List<List<Decimal>> configTermsInt = new List<List<Decimal>>  ();
 		List<List<Decimal>> freeTermsInt = new List<List<Decimal>>  ();
 		List<List<Decimal>> termsTakenInt = new List<List<Decimal>> ();
		Integer w = 1;
 		for ( DenS_Config__c con : sconfigs) {  //getting config terms
 			if ( appointment.Date__c == con.date__c ) { 
 				List<Decimal> term = new List<Decimal> ();
 				term.add(con.Start_time__c);
 				term.add(con.End_time__c);
 				configTermsInt.add(term);
 				w = 0;
 			}
 		}
 		if( w == 1 ) {
	 		for ( DenS_Config__c con : wconfigs) {
	 			Datetime appDatetime = appointment.Date__c; 
	 			if (  appDatetime.format('EEE').substring(0,2) == con.Weekday__c.substring(0,2) ) {
	 				List<Decimal> term = new List<Decimal> ();
	 				term.add(con.Start_time__c);
 					term.add(con.End_time__c);
 					configTermsInt.add(term);
	 			}
	 		}
 		}
 		for (DenS_Appointment__c appoint : appointments) {  //getting appointment terms
 			if ( appointment.Date__c == appoint.Date__c ) {
 				List<Decimal> term = new List<Decimal> ();
 				term.add(appoint.Start_time__c);
 				term.add(appoint.End_time__c);
 				termsTakenInt.add(term);
 			}
 		}
 		for (List<Decimal> configTerm : configTermsInt ) {	//getting free terms on the selected day  term[0] - start time  term[1] - end time
 			for ( List<Decimal> takenTerm : termsTakenInt ) {
 				if ( configTerm[1] > takenTerm[0] ) {
 					if ( configTerm[0] <= takenTerm[0] )	{
 						if ( configTerm[0] == takenTerm[0] ) {
 							configTerm[0] = takenTerm[1];
 							if ( !( configTerm[0] == configTerm[1] ) ) {
 								freeTermsInt.add(configTerm);
	 						}
 						}
	 					else if (configTerm[1] == takenTerm[1] ) { 
	 						configTerm[1] = takenTerm[0];
	 						if ( !( configTerm[0] == configTerm[1] ) ) {
	 							freeTermsInt.add(configTerm);
	 						}
	 					}
	 					else {
	 						List<Decimal> term = new List<Decimal> ();
	 						term[0] = configTerm[0];
	 						term[1] = takenTerm[0];
	 						freeTermsInt.add(term);
	 						configTerm[0] = takenTerm[1];
	 						freeTermsInt.add(configTerm);
 						}
 					}
 				}
 			}
 		}
 		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'freeterms' + freeTermsInt));
 		return configTermsInt;
 	}
 	
 	public Boolean overlapcheckAppointment (DenS_Appointment__c appointment) { // checks whether the hours chosen do not overlap with other configs
        /*
        dostać wconfigi
        sconfigi
        sprawdzic czy są configi ze specific date
        sprawdzic je
        
        jesli ich nie ma sprawdzic wconfigs
        
        sprawdzic dostępne godziny 
        
        możesz wyświetlić wolne godziny
        */
        List<List<Decimal>> freeTerms = getFreeTerms ();
        List<Decimal> appointmentTerm = new List<Decimal>();
     	appointmentTerm.add(appointment.Start_time__c);
        appointmentTerm.add(appointment.End_time__c);
        for (List<Decimal> freeTermTime : freeTerms) {
            if ( appointmentTerm[0] >= freeTermTime[0] && appointmentTerm[1] <= freeTermTime[1] ) {
                return true; 
            }
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Start or end time do not match the currently available terms'));
        return false;
    }
 	
 	
 	public String getDaysToHighlight2() {
 		return getDaysToHighlight().get(0);
 	}
 
 	public List<Integer> getCalendarCells () {
		 Integer[] myList = new List<Integer>();
		 for (Integer i = 1 ; i <36 ; i++) {		  
		 	myList.add(i);
 		 }
 		 return myList;
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
  
    public static String[] getDaysOfTheWeek () {
		String[] dayst = new List<String> {'Mo','Tu','We','Th','Fr','Sa','Su'};
		return dayst;
	}
	public String[] getDaysOfTheMonth () {
		String[] dayst = new List<String> {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'}; //{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};
		return dayst;
	}
	public String[] getDaysToDisplay () {
		return daysToDisplay;
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
    public static List<DenS_Appointment__c> getAppointments () {
    	return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c
         	    FROM DenS_Appointment__c ORDER BY Date__c, Start_time__c];
    }
    ///=============GETTERS-END========================  

    //==========Helpers=============================
    
    public void dayChosen () {
    	appointment.Date__c = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), Integer.valueOf(chosenDayDummy));
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'     chosen day:      ' + appointment.Date__c ) );
    }
    
    public Integer getDayOfTheWeek () {
    	String[] dayss = new List<String> {'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su' };
    	Datetime firstDayOfTheMonth = dateDummy.toStartOfMonth (); 
    	String dayOfTheWeek = firstDayOfTheMonth.format('EEE').substring(0,2);
    	for (Integer i=0 ; i<dayss.size() ; i++){
    		if (dayss[i]==dayOfTheWeek) {
    			return i;	
    		}		
    	}	
    	return 10;
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
    public void getHighlightedLis () {
    	Integer[] availdays = new Integer>() ; 
    	sconfigs = [SELECT Id, Name, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM DenS_Config__c WHERE date__c >=:dateDummy ORDER BY date__c, Start_time__c];
    	List<DenS_Appointment__c> appoints = getAppointments ();
    	
    	for (DenS_Config__c con: sconfigs) {
    		if(dummyDate.toStartOfMonth() <= con.date__c) {
    			availdays.add(con.date__c.day());
    		}
    	}
    }
    */
    public String frommintohoursA(Integer ValueToFormat1) {   // converts from int to String in HH:MM time format
        String hours = string.valueOf(Math.floor(ValueToFormat1/60));
        if (hours.length() == 1) {
            hours = '0' + hours;
        }
        return hours + ':00';
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