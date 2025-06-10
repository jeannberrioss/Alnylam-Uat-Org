public class FormField {
    
   /* public FormField(Schema.FieldSetMember f) {
        this.IsRequired = f.DBRequired;
        this.APIName = f.fieldPath;
        this.Label = f.label;
        this.Required = f.required;
        this.Type = String.valueOf(f.getType());
    }*/

   public FormField(Trial_Participant_Request_Setup__mdt f) {
        this.IsRequired = f.Required__c;
        this.APIName = f.DeveloperName;
        this.Label = f.MasterLabel;
        this.Required = f.Required__c;
        this.Column =  f.Column__c;
        this.Order =  f.Order__c;

        if(f.Column__c == 2){
            this.colcss = 'slds-col slds-col slds-size_1-of-1 slds-large-size_1-of-2 slds-medium-size_1-of-2';
        }else{
            this.colcss = 'slds-col slds-size_1-of-1';
        }
        System.debug('>>>Isnull'+String.isBlank(f.Custom_Label__c));
        if(!String.isBlank(f.Custom_Label__c)){
            System.debug('>>>'+f.Custom_Label__c);
            this.IsCustomLabel = true;
            this.customLabel = f.Custom_Label__c;
        }else{
            this.IsCustomLabel = false;
            
        }
       // this.Type = String.valueOf(f.getType());  
    }
    
    public FormField(Boolean required) {
        this.IsRequired = required;
    }
    
    @AuraEnabled
    public Boolean IsRequired { get;set; }    
    @AuraEnabled
    public String APIName { get;set; }    
    @AuraEnabled
    public String Label { get;set; }    
    @AuraEnabled
    public Boolean Required { get;set; } 
    @AuraEnabled
    public Decimal Column { get;set; } 
    @AuraEnabled
    public Decimal Order { get;set; } 
    @AuraEnabled
    public string colcss {get;set;}
    @AuraEnabled
    public Boolean IsCustomLabel {get;set;}
    @AuraEnabled
    public string customLabel {get;set;}
  //  @AuraEnabled
   // public String Type { get; set; }
}