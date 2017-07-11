global class DailyLeadProcessor  implements Schedulable{

	global void execute(SchedulableContext ctx) {
		list<Lead> leads = [SELECT Id, Name, Description, LeadSource 
            FROM Lead 
            WHERE LeadSource = null
            LIMIT 200];
			
			for (Lead l :leads){
				l.LeadSource = 'Dreamforce';
			}
			
			update leads;
    }

}