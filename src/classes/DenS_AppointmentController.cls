public with sharing class DenS_AppointmentController {
        
    public DenS_AppointmentController() {
    } 
    // lastly - Appointment saved
    // dodałem pole select a dentist do dentists zeby zapisywalo samo dentist id 
    // 1. trzeba zrobic zeby calendar sie pojawial po wybraniu innego dentysty niz z dentistId ==''  
    // innymi słowy brać config od dentistId   
        
    //TODO
    // save button
    // po udanym savie pojawia się strona ApplikationInfo
    // inne wymagania np:
    // latwe:
    // klient wybiera typ wizyty (konsultacja, leczenie), opis pojawia się po wybraniu typu wizyty „leczenie”
    // Każda instancja wizyty powinna mieć unikalną nazwę składającą się z inicjałów dentysty, inicjałów klienta oraz daty z godziną: AB_MK_20160812_1530 – nazwa ta jest tworzona podczas tworzenia wizyty.
    // średnie:
    // 5-minutowa blokada dla innych klientów po kliknięciu terminu
    // mail informujący o konieczności potwierdzenia wizyty, po tym jak lekarz ją ztwierdził otrzymuje drugi email informujący że zatwierdził
    // W przypadku gdy wizyta ma miejsce w niedzielę lub po godzinie 20.00 wymagane jest potwierdzenie zarówny dentysty jak i właściciela salonu dentystycznego. 
    
    //DONE:
    // issues with calendar including daysToDisplay, setFreeTermsFunction, cleaning up the code, making it work dayChosen function with appointment.Date__c saving
    // 
    
    // maybe:
    // automatyczne start time i endtime jako picklisty (bo mamy calendarDay.freeTerms )
    
    //  przydatne
    //  get user type: List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
    //  String MyProflieName = PROFILE[0].Name;    
        
        
        
    public DenS_Appointment__c appointment {get;set;}
    public Client__c client {get;set;}
    public User dentist {get;set;}
    public CalendarDetails calendarDetails {get;set;}
    public String chosenDayDummy {get;set;}
    public CalendarDay chosenCalendarDay {get;set;}
     public CalendarDay calendarDay {get;set;}
    
    public String appointmentsToDeleteID {get;set;}
    public String pomS {get;set;}
    public String pomE {get;set;}
    public String dentistId {get;set;}
    
    public DateTime dateTimeDummy {get;set;}
    public Date dateDummy {get;set;}
    public Date dateToday {get;set;}
    public String yearToday {get;set;}
    public String monthToday {get;set;}
    public String dayOfTheWeekToday {get;set;}
    public Integer dayOfTheMonthToday {get;set;}
    public String styleClass {get;set;}
       
    public List<DenS_Config__c> wconfigs {get;set;}   
    public List<DenS_Config__c> sconfigs {get;set;} 
    
    public String w {get;set;}
    
    public DenS_AppointmentController(ApexPages.StandardSetController stdController) {   
        String name = ApexPages.currentPage().getParameters().get('id');   
        appointment = (name == null) ? new  DenS_Appointment__c():
            [SELECT Id, Name, Client__c, Date__c, Dentist__c, Description__c, 
        Start_time__c, End_time__c, Status__c FROM  DenS_Appointment__c];
        dentistId='00558000000HJSsAAO';  // if of Rzeznik z przychodni - the only one dentist
        // tutaj zrobimy checka chwilowo
        client = [SELECT Id, Name, First_name__c, Second_name__c, Email__c, Phone_number__c from Client__c LIMIT 1][0];
        appointment.Client__c = [SELECT Id, Name, Email__c from Client__c LIMIT 1][0].Id;
        
        if (client.id == appointment.Client__c) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'client EXISTS1'));
        }
        else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'client don\'t EXIST'));
        }
        wconfigs = DenS_ConfigController.getWconfigs(dentistId);
        sconfigs = DenS_ConfigController.getSconfigs(dentistId);
        
        calendarDetails = new CalendarDetails ();
        
        if (dateTimeDummy == null){        
            dateTimeDummy = datetime.now(); //.addMonths(-5); 
            dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), dateTimeDummy.day());
            dateToday = dateDummy;
            monthToday = dateTimeDummy.format('MMMMM');
            yearToday = dateTimeDummy.format('YYYY');
            dayOfTheWeekToday = dateTimeDummy.format('EEE').substring(0,2);
            dayOfTheMonthToday = dateTimeDummy.day();
            
            appointment.Date__c = date.newInstance(2016, 7, 21);
        }     
        
        setDisplayMonthAndYear ();  
    }       
    //==========MODIFIERS========================
    public void setDisplayMonthAndYear () {
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
        for (Integer i=0 ; i < daysToDisplay.size() ; i++) {  //daysToDisplay.size()
	    	CalendarDay cDay = new CalendarDay(String.valueOf(daysToDisplay[i]));
	    	if ( i >= calendarDetails.nbOfNullSpaces1 ) {
	    		cday.cDate = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), i+1 - calendarDetails.nbOfNullSpaces1);
	    		setFreeTerms(cDay); // sets styleClass too
	    	}
	        calendarDetails.calendarDays.add(cDay);
	        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'cDay.cDate=' + cDay.cDate));	
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
    	
         if ( 1 == 1 ) {  // validation checks   
         	//appointment.Client__c =
         	if ( !checkEmailExists () ) {
    			// create new Client
    		}
    		else {
    			// appointment.Client__c =
    		}
    		appointment.Client__c = 	'00358000007DbzkAAC'; //appointment.Client__c = client.id; // 	'00358000007DbzkAAC';  
         	appointment.Dentist__c = dentistId;
         	appointment.Status__c = 'Awaiting acceptance';
         	appointment.Start_time__c = Decimal.valueOf(pomS);
         	appointment.End_time__c = Decimal.valueOf(pomE);
         	// appointment type
            try {
                upsert appointment;
                appointment = new DenS_Appointment__c();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Appointment saved'));
            } catch (DmlException e) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Appointment not saved. One of the following occurred:\n1. The start time is not earlier than the end time.\n2. Config date should be in the future'));
                System.debug('The following exception has occurred: ' + e.getMessage());
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
 
    public void setFreeTerms (CalendarDay calendarDay) {  // if there are no configs on this day no color, if there are configs and available terms -green / no available terms - red
        List<DenS_Appointment__c> appointments = getAppointments ();
        List<List<Decimal>> configTermsInt = new List<List<Decimal>>  ();
        List<List<Decimal>> termsTakenInt = new List<List<Decimal>> ();
        Integer w = 1;
        for ( DenS_Config__c con : sconfigs) {  //getting config terms 
            if ( calendarday.cDate == con.date__c ) { 
                List<Decimal> term = new List<Decimal> ();
                term.add(con.Start_time__c);
                term.add(con.End_time__c);
                configTermsInt.add(term);
                w = 0;
            }
        }
        if( w == 1 ) {  						//getting config terms continuation
            for ( DenS_Config__c con : wconfigs) {   
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
	            	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'drugi for'));
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
        }
        else {
        	calendarDay.styleClass = 'divCal greenBack clickable';
        }
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'teraz' + configTermsInt));
    }
    /*
    public Boolean overlapcheckAppointment (DenS_Appointment__c appointment) { // checks whether the hours chosen do not overlap with other configs
        
       	czy pomS i pomE naleza do dostepnych godzin
        
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
    */
 
    public List<SelectOption> getDentists () {
        List<SelectOption> options = new List<SelectOption>();
        List<User> ul = [SELECT Name FROM User 
                                WHERE profileid IN (SELECT Id FROM Profile WHERE Name=:'Dentist')
                               ];
        //options.add(new SelectOption('','Select a dentist'));
        for (User u: ul) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'id= '+u.Id +'name= ' + u.Name));
            options.add(new SelectOption(u.Id,u.Name));
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
        String[] dayst = new List<String> {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31'}; //{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31};
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
    public static List<DenS_Appointment__c> getAppointments () {
        return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c
                FROM DenS_Appointment__c ORDER BY Date__c, Start_time__c];
    }
    ///=============GETTERS-END========================  

	//==========Setters=============================
	
	public void dayChosen () {
    	appointment.Date__c = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), Integer.valueOf(chosenDayDummy) );
        for (CalendarDay cDay : calendarDetails.calendarDays) {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'day:  ' + cDay.cDate) );
        	if ( cDay.dayToDisplay == chosenDayDummy ) {
        		chosenCalendarDay = cDay;
        	}
        }
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'     chosen day:      ' + chosenDayDummy + chosenCalendarDay  +  appointment.Date__c) );
    }
	
	///=============SETTERS-END========================

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
        for ( Client__c cl : [SELECT Email__c from Client__c LIMIT 1]) {
            if (client.Email__c == cl.Email__c) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Client exists'));
            	return true;
            }
        }
        return false;
    }
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