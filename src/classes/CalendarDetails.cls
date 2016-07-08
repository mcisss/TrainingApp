public with sharing class CalendarDetails {
	public String yearDisplay {get;set;}
	public String monthDisplay {get;set;}
	public Integer nbOfNullSpaces1 {get;set;}
    public Integer nbOfNullSpaces2 {get;set;} 
    public List<String> daysToDisplay {get;set;}
    public List<String> greenDays {get;set;}
    public List<String> redDays {get;set;}
    public String chosenDay {get;set;}
} 