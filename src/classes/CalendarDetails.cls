public with sharing class CalendarDetails {
	public String yearDisplay {get;set;}
	public String monthDisplay {get;set;}
	public Integer nbOfNullSpaces1 {get;set;}
    public Integer nbOfNullSpaces2 {get;set;} 
    public List<CalendarDay> calendarDays {get;set;}
    public String chosenDay {get;set;}
    
    public CalendarDetails () {
    	this.calendarDays = new List<CalendarDay> ();
    }
}