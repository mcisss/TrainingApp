public with sharing class DenS_AppointmentController {
        
    public DenS_AppointmentController() {
    } 
    // lastly - Appointment saved
    
    //TODO
    // before learn triggers to schedule this task in 5 min
    // 5-minutowa blokada dla innych klientów po kliknięciu terminu
    // jak sie zmienia strone w visualforce
    // po udanym savie pojawia się strona ApplikationInfo
    // średnie:
    // 
    // mail informujący o konieczności potwierdzenia wizyty, po tym jak lekarz ją ztwierdził otrzymuje drugi email informujący że zatwierdził
    // W przypadku gdy wizyta ma miejsce w niedzielę lub po godzinie 20.00 wymagane jest potwierdzenie zarówny dentysty jak i właściciela salonu dentystycznego. 
    
    //DONE:
    // save button
    // redirection after saving
    // wybor z dostępnych terminow na pickliscie
    // taking configs by dentistId   
    // latwe:
    // klient wybiera typ wizyty (konsultacja, leczenie), opis pojawia się po wybraniu typu wizyty „leczenie”
    // Każda instancja wizyty powinna mieć unikalną nazwę składającą się z inicjałów dentysty, inicjałów klienta oraz daty z godziną: AB_MK_20160812_1530 – nazwa ta jest tworzona podczas tworzenia wizyty.
    // issues with calendar including daysToDisplay, setFreeTermsFunction, cleaning up the code, making it work dayChosen function with appointment.Date__c saving
    // 
    
    // maybe:
    // 
    
    //  przydatne
    //  get user id: List<Profile> PROFILE = [SELECT Id FROM Profile WHERE Id=:userinfo.getProfileId().Id];
    //  String MyProflieName = PROFILE[0].Name;    
        
    
    public DenS_Config__c config { get; set; }
    public String pomSConfig {get;set;}
    public String pomEConfig {get;set;}
    public String pomW {get;set;}
    public String configsToDeleteID {get;set;}
    public Decimal ValueToFormat {get;set;}
    public String dentistId {get;set;}
	      
    public String userProfile {get;set;}
        
    public DenS_Appointment__c appointment {get;set;}
    public Contact client {get;set;}
    public User dentist {get;set;}
    public CalendarDetails calendarDetails {get;set;}
    public String chosenDayDummy {get;set;}
    public CalendarDay chosenCalendarDay {get;set;}
    
    public String appointmentsToDeleteID {get;set;}
    public String pomS {get;set;}
    public String appointmentType {get;set;}
    public String description {get;set;}
    
    public List<DenS_Config__c> wconfigsLocal {get;set;}   
    public List<DenS_Config__c> sconfigsLocal {get;set;} 
    
    public DateTime dateTimeDummy {get;set;}
    public Date dateDummy {get;set;}
       
    public String w {get;set;}
    
    public Boolean showAppDetails {get;set;}
    
	
	// for site AppointmentListDentis:
	public String[] searchCriteria {get;set;}
	public String[] pickListsAL {get;set;}
	
	//for DenS_Config
	
    
	/*    
    final Handler handler = new Handler();
	final long delay = 5 * 60 * 1000;
	
	public void executeSomething(){
	    handler.postDelayed(new Runnable(){
	        public void run(){
	            // do your work
	
	            if (continueToExecute){
	                executeSoemthing();
	            }
	        }
	    }, delay);
	}
    */
  	public DenS_AppointmentController(ApexPages.StandardController stdController) { 
    	
    }
    public DenS_AppointmentController(ApexPages.StandardSetController stdController) {  
        userProfile = 'Dentist'; //  SHOULD BE userProfile = [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileId()][0].Name;
    	// System Adminitrator // Dentist // Owner
    	// Contact nie ma Usera - jak to zrobic? 
    	if (userProfile =='Dentist') {
    		dentistId=userinfo.getUserId();
    		dentistId='00558000000HJSsAAO'; // TEMP Id Rzeznika
    	}
    	if (userProfile =='Owner') {
    		dentistId='no';
    	}
    	if (userProfile =='Client') {
    		dentistId='no';
    	}
    	
    	
    	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'teraz' + userProfile));
    	
    	String name = ApexPages.currentPage().getParameters().get('id');   
        
		//config
        config = (Name == null) ? new DenS_Config__c():
            [SELECT Id, Name, Active__c, date__c, 
        Start_time__c, End_time__c, Weekday__c, Dentist__c FROM DenS_Config__c];
        dentistId = '00558000000HJSsAAO';
        
    	
        appointment = (name == null) ? new  DenS_Appointment__c():
            [SELECT Id, Name, Client__c, Date__c, Dentist__c, Description__c, 
        Start_time__c, End_time__c, Status__c FROM  DenS_Appointment__c];
		
		chosenCalendarDay = new CalendarDay();
        client = new Contact (); 
        
        calendarDetails = new CalendarDetails ();
       
        
        //AL
        pickListsAL = new List<String> ();
        pickListsAL.add('');
        pickListsAL.add('');
        pickListsAL.add('');
        //
        
        if (dateTimeDummy == null){        
            dateTimeDummy = datetime.now(); //.addMonths(-5); 
            dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), dateTimeDummy.day());
        }
        setDisplayMonthAndYear ();
    }      
    
    
      public void setDisplayMonthAndYear () {
    	showAppDetails = false;
    	calendarDetails.styles='';
        calendarDetails.monthDisplay = dateTimeDummy.format('MMMMM');  
        calendarDetails.yearDisplay = dateTimeDummy.format('YYYY');
        Date myDate = date.newInstance(2000, 10, 2); //Monday
        calendarDetails.nbOfNullSpaces1 = getDayOfTheWeek();
        calendarDetails.nbOfNullSpaces2 = 31 - date.daysInMonth(dateTimeDummy.year(), dateTimeDummy.month());
        List<String> daysToDisplay;
        daysToDisplay = getDaysOfTheMonth ();              //calculate daysToDisplay for calendar rendering
        for (Integer i=0 ; i < calendarDetails.nbOfNullSpaces1 ; i++) {
            daysToDisplay.add(0,' ');
        }
        for (Integer i=0 ; i < calendarDetails.nbOfNullSpaces2 ; i++) {
            daysToDisplay.remove(daysToDisplay.size()-1-i);
        }
        calendarDetails.calendarDays.clear();
        wconfigsLocal = getWconfigs();
        sconfigsLocal = getSconfigs();
        for (Integer i=0 ; i < daysToDisplay.size() ; i++) {  //daysToDisplay.size()
	    	CalendarDay cDay = new CalendarDay(String.valueOf(daysToDisplay[i]));
	    	cDay.styleClass = 'divCal';
	    	if ( i >= calendarDetails.nbOfNullSpaces1 ) {
	    		cday.cDate = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), i+1 - calendarDetails.nbOfNullSpaces1);
	    		setFreeTerms(cDay); // sets styleClass too
	    	}
	    	else {
	    		calendarDetails.styles+=',0';
	    	}
	        calendarDetails.calendarDays.add(cDay);
        }
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
     	if ( !checkEmailExists () ) {  // create new Client if does not exist in the Contact database
			if ( client.LastName == null || client.FirstName == null || client.Phone == null  ) {
     		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter	 your first name, last name and the phone number'));
     		return null;
     		} 
			insert client; 
		}
		Contact clientPom = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email =: client.Email][0];
		User dentistPom = [SELECT Id, FirstName, LastName FROM User WHERE Id=:dentistId][0];
		appointment.Client__c = clientPom.Id;
     	appointment.Dentist__c = dentistId;
     	appointment.Status__c = 'Awaiting acceptance';
     	appointment.Start_time__c = Decimal.valueOf(pomS);
     	appointment.End_time__c = Decimal.valueOf(pomS)+60;
     	appointment.Name = '' + dentistPom.FirstName.substring(0,1) + dentistPom.LastName.substring(0,1) + '_'
     				       + clientPom.FirstName.substring(0,1) + clientPom.LastName.substring(0,1) + '_' 
     				       + String.ValueOf(dateTimeDummy.year()) + String.ValueOf(dateTimeDummy.month()) + String.ValueOf(dateTimeDummy.day()) + '_'
     				       + fromMinToHoursA(Decimal.valueOf(pomS)).substring(0,2) + fromMinToHoursA(Decimal.valueOf(pomS)).substring(3);
     	if ( appointmentType == 'Treatment') {
     		appointment.RecordTypeId = '012580000000o0yAAA';  // get recordtypesid po Name
     		appointment.Description__c = description; 
     	}
     	else {
     		appointment.RecordTypeId = '012580000000o13AAA'; 
     	}
        try {
            upsert appointment;
            appointment = new DenS_Appointment__c();
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Appointment saved'));
            PageReference pageRef = new PageReference('/apex/DenS_AppointmentView');
            pageRef.setRedirect(false);
            return pageRef;
        } catch (DmlException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Appointment date should be in the future'));
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        } 
        return null;
    }
    public void removeAppointment(){
        delete [SELECT Id FROM DenS_Appointment__c WHERE Id=:appointmentsToDeleteID];
    }
    
    ///=============MODIFIERS-END========================  
    //==========SETTERS========================   
 
    public void setFreeTerms (CalendarDay calendarDay) {  // if there are no configs on this day no color, if there are configs and available terms -green / no available terms - red
        List<DenS_Appointment__c> appointments = getAppointments ( dentistId );
        List<List<Decimal>> configTermsInt = new List<List<Decimal>>  ();
        List<List<Decimal>> termsTakenInt = new List<List<Decimal>> ();
        Integer w = 1;
        calendarDay.showAppDetailsAndDayToDisplay = ' ' + calendarDay.dayToDisplay;
        if ( calendarday.cDate <= date.today() ) {
        	calendarDay.styleClass = 'divCal';
        	calendarDetails.styles+=',0';
        }
        else {
	        for ( DenS_Config__c con : sconfigsLocal) {  //getting config terms 
	            if ( calendarday.cDate == con.date__c ) { 
	                List<Decimal> term = new List<Decimal> ();
	                term.add(con.Start_time__c);
	                term.add(con.End_time__c);
	                configTermsInt.add(term);
	                w = 0;
	            }
	        }
	        if( w == 1 ) {  						//getting config terms continuation
	            for ( DenS_Config__c con : wconfigsLocal) {   
	                Datetime appDatetime = calendarday.cDate; 
	                if (  appDatetime.format('EEE').substring(0,2) == con.Weekday__c.substring(0,2) ) {
	                    List<Decimal> term = new List<Decimal> ();
	                    term.add(con.Start_time__c);
	                    term.add(con.End_time__c);
	                    configTermsInt.add(term);
	                }
	            }
	        }
	        if ( configTermsInt.isEmpty() ) {
	        	calendarDay.styleClass = 'divCal';
	        	calendarDay.showAppDetailsAndDayToDisplay = '0';
	        	calendarDetails.styles+=',0';
	        	return;
	        }
	        for (DenS_Appointment__c appoint : appointments) {  //getting appointment terms
	            if ( calendarday.cDate == appoint.Date__c ) {
	                List<Decimal> term = new List<Decimal> ();
	                term.add(appoint.Start_time__c);
	                term.add(appoint.End_time__c);
	                termsTakenInt.add(term);
	            }
	        }
	        if ( termsTakenInt.isEmpty () ) {
	            	calendarDay.freeTerms = configTermsInt;
	        }
	        else {
	        	// for loop does refresh the condition so it works properly BTW it would work properly anyway since configs are sorted ascendingly by time
		        for ( Integer i = 0 ; i < configTermsInt.size() ; i++) {  //getting free terms on the selected day  term[0] - start time  term[1] - end time
		            for ( List<Decimal> takenTerm : termsTakenInt ) {
		                if ( configTermsInt[i][1] <= takenTerm[0] || configTermsInt[i][0] >= takenTerm[1] ) {   // appointment outside of config
		                }
		                else {																					// appointment inside config 
		                	if ( configTermsInt[i][0] == takenTerm[0] && configTermsInt[i][1] == takenTerm[1] ) {   
		                		configTermsInt.remove(i);
		                	}
	                        else if ( configTermsInt[i][0] == takenTerm[0] ) {
	                            configTermsInt[i][0] = takenTerm[1];
	                        }
	                        else if (configTermsInt[i][1] == takenTerm[1] ) { 
	                            configTermsInt[i][1] = takenTerm[0];
	                        }
	                        else {
	                            List<Decimal> term = new List<Decimal> ();
	                            term.add(configTermsInt[i][0]);
	                            term.add(takenTerm[0]);
	                            configTermsInt[i][0] = takenTerm[1];
	                            configTermsInt.add(i, term);
	                        }
		                }
		            }
		        }
	        }
	        calendarDay.freeTerms = configTermsInt;
	        if( calendarDay.freeTerms.isEmpty() ) {
	        	calendarDay.styleClass = 'divCal redBack';
	        	calendarDay.showAppDetailsAndDayToDisplay = '0'; 
	        	calendarDetails.styles+=',2';
	        }
	        else {
	        	calendarDay.styleClass = 'divCal greenBack clickable';
	        	calendarDay.showAppDetailsAndDayToDisplay = '1' + calendarDay.showAppDetailsAndDayToDisplay;
	        	calendarDetails.styles+=',1'; 
	        }
        }
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'teraz' + configTermsInt));
    }
    
    public void dayChosen () {
    	if( chosenDayDummy.substring(0,1).equals( '1' ) ) {
    		showAppDetails = true;
    		chosenDayDummy = chosenDayDummy.substring(2);
    		appointment.Date__c = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), Integer.valueOf(chosenDayDummy) );
        	for (CalendarDay cDay : calendarDetails.calendarDays) {
        		if ( cDay.dayToDisplay == chosenDayDummy ) {
        			chosenCalendarDay = cDay;
        		}
       		}
    	}
    }
    
 	///=============SETTERS-END========================

 	//==========GETTERS========================   
 
    public List<SelectOption> getDentists () {
        List<SelectOption> options = new List<SelectOption>();
        List<User> ul = [SELECT Name FROM User 
                                WHERE profileid IN (SELECT Id FROM Profile WHERE Name=:'Dentist')
                               ];
        options.add(new SelectOption('no','Select a dentist'));
        for (User u: ul) {
            options.add(new SelectOption(u.Id,u.Name));
        }
        return options; 
    }
    public List<SelectOption> getAppointmentTypes () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Consultation','Consultation'));
        options.add(new SelectOption('Treatment','Treatment'));
        return options; 
    }
    public List<SelectOption> getPossibleTerms () {  //only hours
    	List<SelectOption> options = new List<SelectOption>();
        for ( Integer i = 0 ; i < chosenCalendarDay.freeTerms.size() ; i++ ) {
        	Integer k = (chosenCalendarDay.freeTerms[i][1]-chosenCalendarDay.freeTerms[i][0]).intValue() /60;
        	for (Integer j = 0 ; j < k ; j++) {
        		options.add(new SelectOption(String.valueOf(chosenCalendarDay.freeTerms[i][0]),
        									 fromMinToHoursA(chosenCalendarDay.freeTerms[i][0] +j*60)+' - '+fromMinToHoursA(chosenCalendarDay.freeTerms[i][0]+(j+1)*60)));
        	}
        }
        return options; 
    }
    public List<Client__c> getClient () { 
    	//TODO
    	return null;
    }
    public static String[] getDaysOfTheWeek () {
        String[] dayst = new List<String> {'Mo','Tu','We','Th','Fr','Sa','Su'};
        return dayst;
    }
    public String[] getDaysOfTheMonth () {
        String[] dayst = new List<String> ();
        for (Integer i=1 ; i<32 ; i++) {
        	dayst.add( String.valueOf(i) );
        }
        return dayst;
    }
    public static List<DenS_Appointment__c> getAppointments () {   //
        return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c
                FROM DenS_Appointment__c ORDER BY Date__c, Start_time__c];
    }
    public static List<DenS_Appointment__c> getAppointments (String dentisttId ) {   //
        return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c
                FROM DenS_Appointment__c WHERE Dentist__c =: dentisttId ORDER BY Date__c, Start_time__c];
    }
    public static List<DenS_Appointment__c> getHistoricAppointments () {   //
        return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c
                FROM DenS_Appointment__c WHERE Date__c <: date.Today() ORDER BY Date__c, Start_time__c];
    }
    public static List<DenS_Appointment__c> getHistoricAppointments (String dentisttId) {   //
        return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c
                FROM DenS_Appointment__c WHERE Date__c <: date.Today() AND Dentist__c =: dentisttId ORDER BY Date__c, Start_time__c];
    }
    public List<SelectOption> getSearchCrits () {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Date','Date'));
        options.add(new SelectOption('Status','Status'));
        options.add(new SelectOption('Client','Client'));
        options.add(new SelectOption('Appointment type','Appointment type'));
        return options; 
    }
    
    
    //AL
    public String[] getStatuses () {
    	List<String> statuses = new List<String> ();
    	return statuses;
    }
    public List<String> getClients () {
    	List<String> clients = new List<String> ();
			//select ids from contacts     	
    	return clients;
    }
    
    public List<DenS_Appointment__c> getAppsForView () {
    	List<DenS_Appointment__c> apps = new List<DenS_Appointment__c> ();
    	List<DenS_Appointment__c> apps2 = new List<DenS_Appointment__c> ();
    	Integer w = 0; 
    	for ( String i : searchCriteria ) {
    		if ( i == 'Date' ){
    			apps = [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c, RecordTypeId
               			FROM DenS_Appointment__c WHERE Date__c =: appointment.Date__c ORDER BY Date__c, Start_time__c];
    		}
    		if ( i == 'Status' ) {
    			if ( w==0 ) {
    				apps = [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c, RecordTypeId
           			FROM DenS_Appointment__c WHERE Date__c =: appointment.Date__c ORDER BY Date__c, Start_time__c];
    			}
    			else {
    				for (DenS_Appointment__c app : apps) {
    					if ( app.Status__c == pickListsAL[0] ) {
    						apps2.add(app);
    					}
    				} 
    			}
    		}
    	}
    	return apps;
    }
    
    ///=============GETTERS-END========================  

    //==========Helpers=============================
    
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
    public Boolean checkEmailExists () { 
        for ( Contact cl : [SELECT Email from Contact]) {
            if (client.Email == cl.Email) {
            	return true;
            }
        }
        return false;
    }
    public static String fromMinToHoursA(Decimal ValueToFormat1) {   // converts from int to String in HH:MM time format
        String hours = string.valueOf(Math.floor(ValueToFormat1/60));
        if (hours.length() == 1) {
            hours = '0' + hours;
        }
        return hours + ':00';
    }
    
    public void doNothing() {
    }
    
    
    /*==================================================================================================================
    
    
    
    		                                               CONFIG PAGE
    
    
    
    ====================================================================================================================*/
    
    
    
    public PageReference saveConfig() {
        if (pomW == 'Choose weekday' && config.date__c == null) {    // Default Weekday__c selection option - 'Choose weekday' - denotes the Specific day type of config. In other cases the config type is Weekday
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Config not saved. Please specify the weekday or date'));
        	return null;
        }
        config.Dentist__c = dentistId;
        config.Start_time__c = Decimal.valueOf(pomSConfig);
        config.End_time__c = Decimal.valueOf(pomEConfig);
  		config.Weekday__c = pomW;
        if ( !overlapcheck() ) {   // validation checks  
        	try {
        	upsert config;
        	config = new DenS_Config__c();
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
        delete [SELECT Id FROM DenS_Config__c WHERE Id=:configsToDeleteID];
    }
    public List<SelectOption> getWeekdaysConfig() // provides Weekdays selection options
    {
       List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = DenS_Config__c.Weekday__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }     
    public List<SelectOption> getWorkingHours() {    // provides Hours selection options
        List<SelectOption> options = new List<SelectOption>(); 
        String hour, inminutes;
        options.add(new SelectOption('0000','--:--'));
        for (Integer i = 0 ; i <24 ; i++) {
            hour = string.valueOf(Time.newInstance(i, 0, 0, 0)).substring(0,5);
            inminutes = string.valueOf(  integer.valueOf(hour.substring(0,2))*60 
            		  				   + integer.valueOf(hour.substring(3,5)	 )
                      );
            options.add(new SelectOption(inminutes,hour));
        }   
        return options; 
    }  
    public String getFrommintohours2() {   // converts from int to String in HH:MM time format
        String hours = string.valueOf(Math.floor(ValueToFormat/60));
        if (hours.length() == 1) {
        	hours = '0' + hours;
        }
        return hours + ':00';
    }
    public List<DenS_Config__c> getWconfigs () {   // provides weekday configs
        if (dentistId=='no') {
        	return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
                Weekday__c, Dentist__c, Delete__c FROM DenS_Config__c WHERE date__c =:null ORDER BY Weekday__c, Start_time__c];
        }
        return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM DenS_Config__c WHERE date__c =:null AND Dentist__c =: dentistId ORDER BY Weekday__c, Start_time__c];
    }
     public List<DenS_Config__c> getSconfigs () {   // provides specific day configs
        if (dentistId=='no') {
        	return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM DenS_Config__c WHERE date__c !=:null ORDER BY date__c, Start_time__c];
        }
        return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM DenS_Config__c WHERE date__c !=:null AND Dentist__c =: dentistId ORDER BY date__c, Start_time__c];
    }
     public Boolean overlapcheck () { // checks whether the hours chosen do not overlap with other configs
        List<DenS_Config__c> w_or_s_configs = new List<DenS_Config__c>();  
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
    public Boolean overinside(List<DenS_Config__c> w_or_s_configs, String config_type) {  // called in overlapcheck
        for (DenS_Config__c con : w_or_s_configs) {      
            if( config_type == 'w') {
                if( config.Weekday__c == con.Weekday__c) {
                    if (overinsidepom (con) ) {
                    	return true;
                    }
                }    
            } else if (config_type == 's') { 
            	if(config.date__c == con.date__c) {
            		if (overinsidepom (con) ) {
                    	return true;
                    }
            	}
            }
        }
        return false;
    }
    public Boolean overinsidepom (DenS_Config__c con) {  // called in overlapcheck
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
    public PageReference ChangeConfigTypeW () {   // performed when the config type changes
    	config.date__c = null;
    	return null;
    }
    public PageReference ChangeConfigTypeS () {   // performed when the config type changes
    	pomW = 'Choose weekday';
    	return null;
    }
}