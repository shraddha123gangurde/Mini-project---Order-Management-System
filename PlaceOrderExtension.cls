public with sharing class PlaceOrderExtension {
    Id idOpportunity;
    Id idQuote;
    public Order objOrder{get;set;}
    
    public PlaceOrderExtension(ApexPages.StandardController controller) {
         idOpportunity = ApexPages.CurrentPage().getparameters().get('oppId');
         idQuote = ApexPages.CurrentPage().getparameters().get('quoteId');
         objOrder = (Order)controller.getRecord();
    }
    public PageReference saveOrderItem() {
        if(objOrder != null) {
            objOrder.OpportunityId = idOpportunity;
            objOrder.QuoteId = idQuote;
            Id PriceBook2Id = [SELECT PriceBook2Id
                               FROM Opportunity
                               WHERE Id = :idOpportunity].PriceBook2Id;
            objOrder.Pricebook2Id = PriceBook2Id;
            insert objOrder;
            System.debug('objOrder-------------->' + objOrder);
            List<OrderItem> listOrderLineItems = new List<OrderItem>();
            
            List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>([SELECT Id,
                                                                                    UnitPrice,
                                                                                    ListPrice,
                                                                                    Discount,
                                                                                    Quantity,
                                                                                    PriceBookEntryId
                                                                             FROM QuoteLineItem
                                                                             WHERE QuoteId = :idQuote]);
            System.debug('listQuoteLineItem--------->' + listQuoteLineItem);
            
            for(QuoteLineItem objQuoteLineItem : listQuoteLineItem) { 
                OrderItem objOrderItem = new OrderItem(Quantity = objQuoteLineItem.Quantity,
                                                       OrderId = objOrder.Id,
                                                       PriceBookEntryId = objQuoteLineItem.PriceBookEntryId,
                                                       UnitPrice = objQuoteLineItem.UnitPrice);
                listOrderLineItems.add(objOrderItem);
            }
            if(listOrderLineItems != null)
            insert listOrderLineItems;
        }
        PageReference objPageReference = Page.AddProduct;
        objPageReference.getParameters().put('Id',idOpportunity);
        objPageReference.setRedirect(true);
        return objPageReference;
    }
}