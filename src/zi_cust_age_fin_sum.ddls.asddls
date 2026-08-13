@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Ageing Final Sum'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CUST_AGE_FIN_SUM
  with parameters
    P_Date : datum
  as select from I_OperationalAcctgDocItem
{
  key InvoiceReference,
  key InvoiceItemReference,
  key InvoiceReferenceFiscalYear,
  key CompanyCode,
      //  key FiscalYear,
      CompanyCodeCurrency,
      Customer,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum(AmountInCompanyCodeCurrency) as received
}
where
  PostingDate < $parameters.P_Date
//  ClearingJournalEntry = ''

group by
  InvoiceReference,
  CompanyCode,
  InvoiceItemReference,
  InvoiceReferenceFiscalYear,
  CompanyCodeCurrency,
  Customer
