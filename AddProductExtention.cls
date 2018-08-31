/**
*   This is the extention created for the vf page AddProducts.
*   
*   =======================================================================================
*      Version     Date            Author          Comment
*   =======================================================================================
*       1.0      August-22-2018     Shraddha     This class works around data model for
*                                   Gangurde     HOT1.
*  
**/
public with sharing class AddProductExtention {
    public Id idOpportunity{get;set;}
    public String Str{get;set;}
    public List<PricebookEntry> listPricebookEntries{get;set;}
    public List<String> listOpportunityProducts{get;set;}
    public Integer Quantity{get;set;}
    public Double Discount{get;set;}
    public Double unitPrice{get;set;}
    public List<OpportunityLineItem> listOpportunityLineItems{get;set;}
    public String stringProductName{get;set;}
    public Order Order{get;set;}
    public String ProductName{get;set;}
    public List<Order> listOrders{get;set;}
    public String OrderNumber{get;set;}
    public Id idOrder{get;set;}
    public boolean displayaddALI{get;set;}
    public List<Wrapper> listWrapper{get;set;}
    
    Opportunity objOpportunity;
    Quote objQuote;
    public integer intTotalRecords = 0;
    public integer intOffsetSize = 0;
    public integer intLimitSize= 5;
    List<String> listNames = new List<String>();
    Map<String,Id> mapPriceBookEntries = new Map<String,Id>(); //This map will store PricebookEntry
/*                                                               Name with its Id.
=================================================================================
This is the constructor for the extention which brings all the products from
the pricebook of the opportunity.
=================================================================================
*/
    public AddProductExtention(ApexPages.StandardController controller) {
        
      listOpportunityProducts = new List<String>();
      listWrapper = new List<Wrapper>();
      displayaddALI = false;
      listOrders = new List<Order>();
      listOpportunityLineItems = new List<OpportunityLineItem>();
      idOpportunity = ApexPages.CurrentPage().getparameters().get('id');
      System.debug('idOpportunity----->' + idOpportunity);
      
      
    }
/*
=======================================================
This function gets selected product names by the user.
=======================================================
*/
  public void createOppLineItem() {
      displayaddALI = true;
      System.debug('stringProductName----------->' + stringProductName);
      listOpportunityProducts.add(stringProductName);
      PricebookEntry objProduct = [SELECT Product2Id
                                   FROM PricebookEntry
                                   WHERE Id = :mapPriceBookEntries.get(stringProductName)];
      System.debug('UnitPrice=============>' + UnitPrice);
      OpportunityLineItem objOpportunityLineItem = new
      OpportunityLineItem(PricebookEntryId = mapPriceBookEntries.get(stringProductName),
                          OpportunityId = idOpportunity,
                          Product2Id = objProduct.Id,
                          Quantity = Quantity,
                          Discount = Discount,
                          UnitPrice = unitPrice);
      System.debug('objOpportunityLineItem--------->' + objOpportunityLineItem);
      listOpportunityLineItems.add(objOpportunityLineItem);
      System.debug('listOpportunityLineItems--------->' + listOpportunityLineItems);
      
      if(objOpportunityLineItem != null && stringProductName != null) {
          Wrapper objWrapper = new Wrapper(stringProductName,objOpportunityLineItem);
          listWrapper.add(objWrapper);
          System.debug('objWrapper---------->' + objWrapper);
      }
  }
/*
=====================================================================
This function insert the list of OpportunityLineItem fetched from
function createOppLineItem.
=====================================================================
*/
  public PageReference saveOpportunityLineItem() {
      try {
          if(!listOpportunityLineItems.isempty())
          insert listOpportunityLineItems;
          System.debug('listOpportunityLineItems----------->' + listOpportunityLineItems);
      }
      catch(DMLException e) {
          System.debug('***---Having problem while inserting listOpportunityLineItems---***');
      }
      
      PageReference objPageReference = Page.PlaceOrder;
      objPageReference.setRedirect(true);
      System.debug('idOpportunity------------>' + idOpportunity);
      objPageReference.getParameters().put('oppId',idOpportunity);
      System.debug('objQuote.Id------------>' + objQuote.Id);
      objPageReference.getParameters().put('quoteId',objQuote.Id);
      return objPageReference;
  }
  
    public Id getOpportunityId() {
        System.debug('idOpportunity------------>' + idOpportunity);
        return idOpportunity;
   }
/*
=========================================================================
This function will redirect the user to the first page of the pagination.
=========================================================================
*/
  public void FirstPage() {
       intOffsetSize = 0;
       fetchListPricebookEntries();
    }
/*
=============================================================================
This function will redirect the user to the previous page of the pagination.
=============================================================================
*/
  public void previous() {
       intOffsetSize = intOffsetSize - intLimitSize;
       fetchListPricebookEntries();
    }
/*
=============================================================================
This function will redirect the user to the next page of the pagination.
=============================================================================
*/
    public void next() {
       intOffsetSize = intOffsetSize + intLimitSize;
       fetchListPricebookEntries();
    }
/*
=============================================================================
This function will redirect the user to the Last page of the pagination.
=============================================================================
*/
    public void LastPage() {
       intOffsetSize = intTotalRecords - math.mod(intTotalRecords,intLimitSize);
       fetchListPricebookEntries();
    }
    
    public boolean getprev() {
        if(intOffsetSize == 0)
        return true;
        else
        return false;
    }
    
    public boolean getnxt() {
        if((intOffsetSize + intLimitSize) > intTotalRecords)
        return true;
        else
        return false;
    }
/*
=============================================================================
This function takes value provided in search input text and returns products 
whose names matches with that search input.
=============================================================================
*/
    public void searchProduct() {
        Id idPriceBook2 = objOpportunity.Pricebook2.Id;
        System.debug('ProductName------------>' + ProductName);
        System.debug('objOpportunity.Pricebook2.Id--------->' + objOpportunity.Pricebook2.Id);
        listPricebookEntries = Database.query('SELECT Name,UnitPrice,ProductCode FROM PricebookEntry WHERE Pricebook2Id = :idPriceBook2 AND Name LIKE \'%'+String.escapeSingleQuotes(ProductName)+'%\' LIMIT :intLimitSize OFFSET :intOffsetSize');
    }
/*
=============================================================================
This function creates new Quote onclick of generate Quote button and adds 
Quote line items to that quote.
=============================================================================
*/
    public void generateQuote() {

        List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
        System.debug('*********present in generateQuote***********');
        objQuote = new Quote(OpportunityId = idOpportunity,
                             Name = 'Quote for ' + objOpportunity.Name,
                             PriceBook2Id = objOpportunity.Pricebook2.Id);
        if(objQuote != null)
        insert objQuote;
        //PageReference objPageReference = Page.PlaceOrder;
        //objPageReference.getParameters().put('QuoteId',objQuote.Id);
        List<OpportunityLineItem> listOpportunityLineItem = ([SELECT Id,
                                                              PricebookEntryId,
                                                              Product2ID,
                                                              Quantity,
                                                              UnitPrice,
                                                              Discount
                                                              FROM OpportunityLineItem
                                                              WHERE OpportunityId = :idOpportunity]);
                                                              
        for(OpportunityLineItem objOpportunityLineItem : listOpportunityLineItem) {
            QuoteLineItem objQuoteLineItem = new QuoteLineItem(QuoteId = objQuote.Id,
                                                               PricebookEntryId = objOpportunityLineItem.PricebookEntryId,
                                                               Quantity = objOpportunityLineItem.Quantity,
                                                               UnitPrice = objOpportunityLineItem.UnitPrice,
                                                               Discount = objOpportunityLineItem.Discount);
            try {
                listQuoteLineItem.add(objQuoteLineItem);
            
            System.debug('objQuoteLineItem------------>' + objQuoteLineItem);
            System.debug('objOpportunityLineItem------------>' + objOpportunityLineItem);
            }
            catch(DMLException e) {
                System.debug('Problem while inserting objQuoteLineItem');
            }
        }
        if(!listQuoteLineItem.isempty())
        insert listQuoteLineItem;
    }
    
    public void saveQuotePDF() {
        
        /*
        Id QuoteID = '0Q06F000002kMeA';
        String templateID = '0EH6F000003eiEw';
        String quoteUrl = '/quote/quoteTemplateDataViewer.apexp?id=';
        quoteUrl +=QuoteID;
        quoteUrl +='&headerHeight=190&footerHeight=188&summlid=';
        quoteUrl +=templateID ;
        quoteUrl +='#toolbar=1&navpanes=0&zoom=90';
        PageReference pg = new PageReference(quoteUrl);
        QuoteDocument quotedoc = new QuoteDocument(); 
        Blob b = pg.getContentAsPDF() ;
        quotedoc.Document = b;
        quotedoc.QuoteId = QuoteID ;
        insert quotedoc; 
        */
    }
/*
=============================================================================
This function takes value provided in search input text and returns orders 
whose names matches with that search input.
=============================================================================
*/
    public void searchOrder() {
       System.debug('OrderNumber------------>' + OrderNumber);
        listOrders = Database.query('SELECT Name,Status,TotalAmount, OrderNumber FROM Order WHERE OpportunityId = :idOpportunity AND OrderNumber  LIKE \'%'+String.escapeSingleQuotes(OrderNumber)+'%\'');
        //listOrders = Database.query('SELECT Name,Status,TotalAmount, OrderNumber FROM Order WHERE OpportunityId = :idOpportunity AND OrderNumber  LIKE \'%000%\'');
    }
/*
=============================================================================
This function deletes the order on delete button click
=============================================================================
*/
    public void deleteOrder() {
        /*
        Order objOrder = [SELECT Id
                          FROM Order
                          WHERE Id = :idOrder];*/
        if(idOrder != null) {
            Order objOrder = [SELECT Id
                              FROM Order
                              WHERE Id = :idOrder];
            
            if(objOrder != null)
            try {
                delete objOrder;
            }
            catch(DMLException e) {}
    }
    }
/*
===============================================================================
This function is called on the action attribute of apex page to fetch the data
at the time of vf Page loading.
===============================================================================
*/
    public void onPageLoad() {
        objOpportunity = [SELECT Opportunity.Pricebook2Id,Name,
                               Opportunity.Pricebook2.Name 
                        FROM Opportunity 
                        WHERE id = :idOpportunity];
                        
      System.debug('priceBookId---->' + objOpportunity.Pricebook2.Id);
      
      listPricebookEntries = [SELECT Name,
                                     UnitPrice,
                                     ProductCode
                              FROM PricebookEntry
                              WHERE Pricebook2Id = :objOpportunity.Pricebook2.Id
                              LIMIT :intLimitSize
                              OFFSET :intOffsetSize];
                              
      intTotalRecords = listPricebookEntries.size();
      System.debug('PricebookEntries---->' + listPricebookEntries);
      
      for(PricebookEntry objPricebookEntry : [SELECT Name,
                                                     UnitPrice,
                                                     ProductCode
                                              FROM PricebookEntry
                                              WHERE Pricebook2Id = :objOpportunity.Pricebook2.Id]) {
                                                  
          if(!(mapPriceBookEntries.containsKey(objPricebookEntry.Name)))
          mapPriceBookEntries.put(objPricebookEntry.Name,objPricebookEntry.Id);
          else
          mapPriceBookEntries.put(objPricebookEntry.Name,objPricebookEntry.Id);
      }
      
      listOrders = [SELECT Name,
                           Status,
                           TotalAmount,
                           OrderNumber
                    FROM Order
                    WHERE OpportunityId = :idOpportunity];
    }
    
    public void fetchListPricebookEntries() {
        listPricebookEntries = [SELECT Name,
                                     UnitPrice,
                                     ProductCode
                               FROM PricebookEntry
                               WHERE Pricebook2Id = :objOpportunity.Pricebook2.Id
                               LIMIT :intLimitSize
                               OFFSET :intOffsetSize];
    }
     public class Wrapper {
        public OpportunityLineItem objOpportunityLineItems{get;set;}
        public String strOpportunityProducts{get;set;}
        
        public Wrapper(String strOpportunityProducts, OpportunityLineItem objOpportunityLineItems) {
            this.objOpportunityLineItems = objOpportunityLineItems;
            this.strOpportunityProducts = strOpportunityProducts;
        }
     }
}