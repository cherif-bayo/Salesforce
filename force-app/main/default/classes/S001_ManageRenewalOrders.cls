global class S001_ManageRenewalOrders implements Schedulable {

    global void execute(SchedulableContext sc) {
		
        B001_ManageRenewalOrders b = new B001_ManageRenewalOrders ();
        database.executebatch(b,5);
    }
}