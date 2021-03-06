public with sharing class DenS_AppointmentController {
        
    public DenS_AppointmentController() {
    } 
    public Boolean isDentist {get;set;}
	public Boolean isOwner {get;set;}
	public Boolean isClient {get;set;}
    
    public Boolean AL {get;set;}
    public Boolean C {get;set;}
    public Boolean CV {get;set;}
    public Boolean CL {get;set;}
    
    public Id ownerId {get;set;}
    public DenS_Config__c config { get; set; }
    public String pomSConfig {get;set;}
    public String pomEConfig {get;set;}
    public String pomW {get;set;}
    public String configsToDeleteID {get;set;}
    public Decimal ValueToFormat {get;set;}
    public String dentistId {get;set;}
    public Set<Id> allDentistsIds {get;set;}
    public Set<Id> dentistsIds {get;set;}
	      
    public String userProfile {get;set;}
        
    public DenS_Appointment__c appointment {get;set;}
    public Contact client {get;set;}
    public CalendarDetails calendarDetails {get;set;}
    public String chosenDayDummy {get;set;}
    public CalendarDay chosenCalendarDay {get;set;}
    
    public String appointmentID {get;set;}
    public String pomS {get;set;}
    public String description {get;set;}
    
    public List<DenS_Config__c> wconfigsLocal {get;set;}   
    public List<DenS_Config__c> sconfigsLocal {get;set;} 
    
    public DateTime dateTimeDummy {get;set;}
    public Date dateDummy {get;set;}
       
    public String w {get;set;}
    
    public Boolean showAppDetails {get;set;}
    
	
	// for site AppointmentListDentis:
	public String[] searchCriteria {get;set;}
	public String searchCriteriaString {get;set;}
	public Boolean appView {get;set;}
	public Boolean treatment {get;set;}
	public DenS_Appointment__c appointmentView {get;set;}
	public DenS_Appointment__c appointmentViewV {get;set;}
    public String dentistTypeAl {get;set;}
    public String appointmentType {get;set;}
    public String appointmentStatus {get;set;}
	public List<Boolean> showFields {get;set;}
	//for DenS_Config
	//CV
	public Contact contactView {get;set;}
	public Id searchedId {get;set;}
	public String userOrContactt {get;set;}
	
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
        ownerId = [SELECT Id FROM User 
                                WHERE profileid IN (SELECT Id FROM Profile WHERE Name=:'Dentist')  // should be 'Name=: 'Owner'
                               ][0].Id;
        
        userProfile = 'Owner'; //  SHOULD BE userProfile = [SELECT Name FROM Profile WHERE Id =: userinfo.getProfileId()][0].Name;
    	// System Adminitrator // Dentist // Owner
    	// Contact nie ma Usera - jak to zrobic? 
    	allDentistsIds = new Set<id>();
    	dentistsIds = new Set<Id>();
    	if (userProfile =='Dentist') {
    		isOwner = false;
    		isClient = false;
    		isDentist = true;
    		// should be dentistId=userinfo.getUserId();
    		dentistId='00558000000HJSsAAO'; // TEMP Id Bob Toothinski
    		dentistsIds.add( dentistId );
    		AL = true;
    		C = false;
    	}
    	else if (userProfile =='Owner') {
    		isOwner = true;
    		isDentist = false;
    		isClient = false;
    		List<User> dentists = [SELECT Id FROM User 
                         WHERE profileid IN (SELECT Id FROM Profile WHERE Name='Dentist')
                         ];
            for ( User d : dentists ) {
            	allDentistsIds.add(d.Id);
            }
            dentistId=getDentists().get(0).getValue();
    		AL = true;
    	}
    	else {
    		isClient = true;
    		isDentist = false;
    		isOwner = false;
    		dentistId=getDentists().get(0).getValue();
    		
    	}
    	appView = false;
		CV = false;
		CL = false;
    	
    	searchCriteria = new List<String> ();
    	showFields = new List<Boolean>();
    	for (Integer i=0 ; i<6 ; i++) {
    	 	showFields.add(false);
    	}
    	searchCriteriaString = 'Date__c';
    	
    	String name = ApexPages.currentPage().getParameters().get('id');   
        
		//config
        config = (Name == null) ? new DenS_Config__c():
            [SELECT Id, Name, Active__c, date__c, 
        Start_time__c, End_time__c, Weekday__c, Dentist__c FROM DenS_Config__c];
        
    	
        appointment =  new  DenS_Appointment__c();
		
		chosenCalendarDay = new CalendarDay();
        client = new Contact (); 
        
        calendarDetails = new CalendarDetails ();
        
        if (dateTimeDummy == null){        
            dateTimeDummy = datetime.now(); //.addMonths(-5); 
            dateDummy = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), dateTimeDummy.day());
        }
        
        //AL
        appointmentView = new DenS_Appointment__c ();
        if (appointmentView.Date__c == null) {
        	appointmentView.Date__c = date.today();
        }
        //
        
        setDisplayMonthAndYear ();
    }      
    public void setDisplayMonthAndYear () {
      	setDentistsIds ();
    	showAppDetails = true;
        calendarDetails.monthDisplay = dateTimeDummy.format('MMMMM');  
        calendarDetails.yearDisplay = dateTimeDummy.format('YYYY');
        Date myDate = date.newInstance(2000, 10, 2); //Monday
        calendarDetails.nbOfNullSpaces1 = getDayOfTheWeekMonthStart();
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
	    	if ( i >= calendarDetails.nbOfNullSpaces1 ) {
	    		 cday.cDate = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), i+1 - calendarDetails.nbOfNullSpaces1);
				 if ( getDayOfTheWeek(cday.cDate) ==6) {    
					 cday.sunday = 'sunday';
				 }
				 setFreeTerms(cDay); // sets freeTerms and styleClass too
	    	}
	    	else {
	    		 cday.cDate = date.newInstance(1970, 1, 1);
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
     		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please enter your first name, last name and the phone number'));
     		return null;
     		} 
			insert client; 
		}
		Contact clientPom = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email =: client.Email][0];
		if ( [SELECT Id, FirstName, LastName FROM User WHERE Id=:dentistId].isEmpty() ) {   //not needed but safe
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Please choose your dentist'));
			return null;
		} 
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
     	appointment.RecordTypeId = appointmentType;
     	appointment.Description__c = description;
        try {
            upsert appointment;
            submitForApproval(appointment);
            appointment = new DenS_Appointment__c();
            showAppDetails = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Appointment saved'));
            /*
            PageReference pageRef = new PageReference('/apex/DenS_AppointmentView');
            pageRef.setRedirect(false);
            return pageRef;
            */
            return null;
        } catch (DmlException e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Appointment date should be in the future'));
            System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
        } 
        return null;
    }
    public void removeAppointment(){
        delete [SELECT Id FROM DenS_Appointment__c WHERE Id=:appointmentID];
    }
    
    ///=============MODIFIERS-END========================  
    //==========SETTERS========================   
 
    public void setFreeTerms (CalendarDay calendarDay) {  // if there are no configs on this day no color, if there are configs and available terms -green / no available terms - red
        List<DenS_Appointment__c> appointments = new List<DenS_Appointment__c>();
        if (isClient) {
        	appointments = getAppointments ();
        }
        else {
        	appointments = getAppsForViewP1 ();
        }
        List<List<Decimal>> configTermsInt = new List<List<Decimal>>  ();
        List<List<Decimal>> termsTakenInt = new List<List<Decimal>> ();
        Integer w = 1;
        if ( calendarday.cDate > date.today() || isOwner ) {
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
	        	calendarDay.showAppDetailsAndDayToDisplay = '0';
	        	return;
	        }
	        for (DenS_Appointment__c appoint : appointments) {  //getting appointment terms
	            if ( calendarday.cDate == appoint.Date__c ) {
	                List<Decimal> term = new List<Decimal> ();
	                term.add(appoint.Start_time__c);
	                term.add(appoint.End_time__c);
	                termsTakenInt.add(term);
	                if ( isOwner || isDentist ) {
        				calendarDay.styleClass = '11';
        				calendarDay.showAppDetailsAndDayToDisplay = '1' + ' ' + calendarDay.dayToDisplay;
        			} 
	            }
	        }
	        if ( isOwner || isDentist ) {
        		return;
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
	        	calendarDay.styleClass = '2';
	        	calendarDay.showAppDetailsAndDayToDisplay = '0';
	        }
	        else {
	        	calendarDay.styleClass = '1';
	        	calendarDay.showAppDetailsAndDayToDisplay = '1' + ' ' + calendarDay.dayToDisplay;
	        }
        }
        else {
        	calendarDay.showAppDetailsAndDayToDisplay = '0';
        }
    }
    
    public void dayChosen () {
    	showAppDetails = false;
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
    public void dayChosenView () {
    	appointmentView.Date__c = date.newInstance(dateTimeDummy.year(), dateTimeDummy.month(), Integer.valueOf(chosenDayDummy) );
    }
    public void updateAStatus () {
    	DenS_Appointment__c ap = [SELECT Status__c FROM DenS_Appointment__c
							 WHERE Id =: appointmentID.substring(0,18)][0];
		ap.Status__c = 	'accepted'; //appointmentID.substring(19);
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'teraz' + appointmentID + 'appointmentStatus' + appointmentStatus));
		update ap;						 
    }
    public void submitForApproval(DenS_Appointment__c app){
    	Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments( 'Processing approval of a visit' );
        req1.setObjectId(app.id);
        req1.setProcessDefinitionNameOrId( 'DenS_Appointment_Approval_Process' );
        req1.setSkipEntryCriteria(false);
        req1.setNextApproverIds(new Id[] {app.Dentist__c});
        Approval.ProcessResult result = Approval.process(req1);
        System.assert(result.isSuccess());
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status' + result.getInstanceStatus() );
    }
    public Approval.ProcessWorkitemRequest approvalPart () {
    	DenS_Appointment__c app = [SELECT Id, Dentist__c, whileOwnerApproval__c FROM DenS_Appointment__c WHERE Id =: appointmentId][0];
        Id approverId; 
        if (app.whileOwnerApproval__c) {
        	approverId = ownerId;
        }
        else {
        	approverId = app.Dentist__c;
        	app.whileOwnerApproval__c = true;
        	update app;
        }
        Approval.ProcessWorkitemRequest req = 
            new Approval.ProcessWorkitemRequest();
        req.setNextApproverIds(new Id[] {approverId});
        req.setWorkitemId(getWorkItemId(appointmentId));
        return req;
    }
    public Id getWorkItemId(Id targetObjectId)
    {
        Id retVal = [Select Id from ProcessInstanceWorkitem
            where ProcessInstanceId IN ( SELECT Id FROM ProcessInstance
            WHERE TargetObjectId =: targetObjectId) 
            ][0].Id;
        return retVal;
    }
    public void approveAppointment() {
        Approval.ProcessWorkitemRequest req = approvalPart();
        req.setComments('Approving request.');
        req.setAction('Approve');
        Approval.ProcessResult result =  Approval.process(req);
        if ( result.getInstanceStatus() != 'Pending' ) {
        	System.assertEquals(
            'Approved', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());
        }
    }
    public void rejectAppointment() {
    	Approval.ProcessWorkitemRequest req = approvalPart();
        req.setComments('Rejecting request.');
        req.setAction('Reject');
        Approval.ProcessResult result =  Approval.process(req);
        System.assert(result.isSuccess(), 'Result Status:'+result.isSuccess());
        System.assertEquals(
            'Rejected', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());
    }
    public Approval.ProcessWorkitemRequest processVisitApprovalRequest(Id dentisttId) {
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments( 'Processing approval of a visit' );
        req1.setObjectId( appointmentId ); // appointmentId
        req1.setSubmitterId( userinfo.getUserId() ); // '00558000000H9l1AAC' ); 
        req1.setProcessDefinitionNameOrId( 'DenS_Appointment_Approval_Process' );
        req1.setSkipEntryCriteria(false);
        req1.setNextApproverIds(new Id[] {dentisttId});
        Approval.ProcessResult result = Approval.process(req1);        // request info ends here
        System.assert(result.isSuccess());
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status' + result.getInstanceStatus() );
        List<Id> newWorkItemIds = result.getNewWorkitemIds();		   // 0 or 1 Ids of submitted approval requests 
        Approval.ProcessWorkitemRequest req2 = 						   // ProcessWorkitemRequest is used to process the approval request after it is submitted 
            new Approval.ProcessWorkitemRequest();
        req2.setNextApproverIds(new Id[] {dentisttId});
        req2.setWorkitemId(newWorkItemIds.get(0));
        return req2;
    }
    
 	///=============SETTERS-END========================

 	//==========GETTERS========================   
 
    public List<SelectOption> getDentists () {
        List<SelectOption> options = new List<SelectOption>();
        List<User> ul = [SELECT Name FROM User 
                                WHERE profileid IN (SELECT Id FROM Profile WHERE Name=:'Dentist')
                               ];
        options.add(new SelectOption('000000000000000000','Select a dentist'));
        for (User u: ul) {
            options.add(new SelectOption(u.Id,u.Name));
        }
        return options; 
    }
    public List<SelectOption> getDentistTypes () {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Stomatologist','Stomatologist'));
        options.add(new SelectOption('Orthodontist','Orthodontist'));
        options.add(new SelectOption('Orthognathic surgeon','Orthognathic surgeon'));
        return options; 
    }
    public List<SelectOption> getAppointmentTypes () {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Consultation','Consultation'));
        options.add(new SelectOption('Treatment','Treatment'));
        return options; 
    }
    public List<SelectOption> getRecordIds () {
        List<SelectOption> options = new List<SelectOption>();
        String recordId = [Select Id From RecordType WHERE sobjecttype = 'MBart__DenS_Appointment__c' AND Name = 'Treatment'][0].Id;
        options.add(new SelectOption( recordId, 'Treatment' ));
        recordId = [Select Id From RecordType WHERE sobjecttype = 'MBart__DenS_Appointment__c' AND Name = 'Consultation'][0].Id;
        options.add(new SelectOption( recordId, 'Consultation' ));
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
    public List<DenS_Appointment__c> getAppointments () {   //
        return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c, Status__c, whileOwnerApproval__c
                FROM DenS_Appointment__c WHERE Date__c >=: date.Today() AND Dentist__c IN :dentistsIds ORDER BY Date__c, Start_time__c];
    }
    public List<DenS_Appointment__c> getHistoricAppointments () {   //
        return [SELECT Id, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c, Status__c, whileOwnerApproval__c
                FROM DenS_Appointment__c WHERE Date__c <: date.Today() AND Dentist__c IN :dentistsIds ORDER BY Date__c, Start_time__c];
    }
    public List<SelectOption> getSearchCrits () {
    	List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Date','Date'));
        options.add(new SelectOption('Status','Status'));
        options.add(new SelectOption('Client','Client'));
        options.add(new SelectOption('Dentist','Dentist'));
        if ( isOwner ) {
        	options.add(new SelectOption('Dentist type','Dentist type'));
        	options.add(new SelectOption('Appointment type','Appointment type')); 
        }
        return options; 
    }
    //AL
    public List<SelectOption> getStatuses () {
    	List<SelectOption> options = new List<SelectOption>();
       Schema.DescribeFieldResult fieldResult = DenS_Appointment__c.Status__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    public List<SelectOption> getClients () { 
    	List<SelectOption> options = new List<SelectOption>();
    	List<Contact> clients = [SELECT Id, Name from Contact ORDER BY Name];
    	for (Contact c : clients) {
    		options.add(new SelectOption(c.Id, c.Name));
    	}
    	return options;
    }
    public List<Contact> getContacts () { 
    	List<Contact> clients = [SELECT Id, Name, Email, Phone from Contact ORDER BY Name];
    	return clients;
    }
    public List<DenS_Appointment__c> getAppsForViewP1 () {   // returns appointments for view on AL (AppointmentList)  on page: apex:outputPanel of Id="pageAL"
	    if (appView) {
	    	return [SELECT Id, Name, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c, RecordTypeId, Status__c, whileOwnerApproval__c, description__c FROM DenS_Appointment__c WHERE Id=:appointmentId];
	    }
	    else if (CV) {
	    	return [SELECT Id, Name, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c, RecordTypeId, Status__c, whileOwnerApproval__c	FROM DenS_Appointment__c  WHERE Client__c =: searchedId];
	    }
	    else {
	    	Date datetoday =  date.Today();
	    	String month = ('0' + datetoday.month()).reverse().substring(0,2).reverse();
			String day = ('0' + datetoday.day()).reverse().substring(0,2).reverse();
	    	String qryString = 'SELECT Id, Name, Client__c, Date__c, Dentist__c, Start_time__c, End_time__c, RecordTypeId, Status__c, whileOwnerApproval__c	FROM DenS_Appointment__c  WHERE Date__c >= '
	    		+ datetoday.year() + '-'+ month + '-' + day + ' '; //SOQL date format YYYY-MM-DD	
	    	String addition = '';
			if ( showFields[1] ) {
				if ( appointmentView.Status__c !=null ) {
					addition = addAnd(addition);
					addition += 'Status__c = \'' + appointmentView.Status__c + '\' ';
				}
			}
			if ( showFields[2] ) {
				if ( appointmentView.Client__c !=null ) {
					addition = addAnd(addition);
					addition += 'Client__c = \'' + appointmentView.Client__c + '\' ';
				}
			}
			if ( showFields[4] ) {
				if ( dentistId !=null ) {
					addition = addAnd(addition);
					addition += 'Dentist__c = \'' + dentistId + '\' ';
				}
			}
			if ( showFields[5] ) {
				if ( dentistTypeAl !=null ) {
					addition = addAnd(addition);
					addition += 'Dentist__c IN (SELECT Id FROM User WHERE Dentist_type__c =\'' + dentistTypeAl + '\') ';
				}
			}
			if ( showFields[3] ) {
				if ( appointmentView.RecordTypeId !=null ) {
					addition = addAnd(addition);
					addition += 'RecordTypeId = \'' + appointmentView.RecordTypeId + '\' ';
				}
			}
	    	if ( addition != '' ) {
	    		qryString += ' AND ' + addition;
	    	}
	    	qryString += ' ORDER BY Date__c, Start_time__c';
	    	return Database.query(qryString);
	    }
    }
    public List<DenS_Appointment__c> getAppsForView() {
    	List<DenS_Appointment__c> appsForView = getAppsForViewP1();	
		if ( showFields[0] ){
			for ( Integer i=appsForView.size()-1 ; i >=0 ; i-- ) {
				if ( appsForView[i].Date__c != appointmentView.Date__c ) {
					appsForView.remove(i);
				}
			}
		}
		return appsForView;
    }
    public String addAnd (String addition2) {
    	if ( addition2 != '') {
			addition2 += ' AND ';
		}
		return addition2;
    }
    public void appView () {
    	appointmentViewV = [SELECT RecordTypeId, description__c, Client__c FROM DenS_Appointment__c WHERE Id=:appointmentId][0];
    	appView = true;
    	String treatmentRecordId = [Select Id From RecordType WHERE sobjecttype = 'MBart__DenS_Appointment__c' AND Name = 'Treatment'][0].Id;
    	if ( appointmentViewV.RecordTypeId == treatmentRecordId ) {
    		treatment = true;
    	}
    	String phone = [SELECT Phone FROM Contact WHERE ID =: appointmentViewV.Client__c ][0].phone;
    	appointmentView.Description__c = phone;
    }
    public void listView () {
    	appView = false;
    	AL = true;
    	C = false;
    	CV = false;
    	CL = false;
    }
    ///=============GETTERS-END========================  

    //==========Helpers=============================
    public void setDentistsIds () {
    	if ( !isOwner || dentistId!=getDentists().get(0).getValue() ) {
    		dentistsIds.clear();
      		dentistsIds.add(dentistId);
    	} 
    	else {
    		dentistsIds = allDentistsIds;
      	}
    }
    public Integer getDayOfTheWeek (Date adate) {
    	Datetime adatetime = datetime.newinstance(adate.year(), adate.month(), adate.day());
    	String dayOfTheWeek = adatetime.format('EEE').substring(0,2);
    	for (Integer i=0 ; i<7 ; i++){
            if (getDaysOfTheWeek()[i]==dayOfTheWeek) {
                return i;   
            }       
        }  
    	return 10; 
    }
    
    public Integer getDayOfTheWeekMonthStart () {
        Datetime firstDayOfTheMonth = dateDummy.toStartOfMonth (); 
        String dayOfTheWeek = firstDayOfTheMonth.format('EEE').substring(0,2);
        for (Integer i=0 ; i<7 ; i++){
            if (getDaysOfTheWeek()[i]==dayOfTheWeek) {
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
    //==========Navigation=============================
    
    public void showConfig () {
    	AL = false;
    	C = true;
    	CV = false;
    }
    public void showContactView () {
    	AL = true;
    	C = false;
    	CV = true;
    	CL = false;
    }
    public void showClientList () {
    	CL = true;
    	AL = false;
    	CV = false;
    }
    
    //==========Navigation Helpers=============================
    public void showContactOrUser () {
    	if (userOrContactt == 'Contact') {
    		
    		
    	}
    	contactView = [SELECT Name, FirstName, LastName, Phone, Email FROM Contact WHERE Id=:searchedId][0];
    	showContactView();
    }
    public String getUserOrContactName () {
    	if (userOrContactt == 'Contact') {
    		return [SELECT Name FROM Contact WHERE Id=:searchedId][0].Name;
    	}
    	else {
    		return [SELECT Name FROM User WHERE Id=:searchedId][0].Name;
    	}
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
        return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM DenS_Config__c WHERE date__c =:null AND Dentist__c IN :dentistsIds ORDER BY Weekday__c, Start_time__c];
    }
     public List<DenS_Config__c> getSconfigs () {   // provides specific day configs
        return [SELECT Id, Name, Active__c, date__c, Start_time__c, End_time__c,
            Weekday__c, Dentist__c, Delete__c FROM DenS_Config__c WHERE date__c !=:null AND Dentist__c IN :dentistsIds ORDER BY date__c, Start_time__c];
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