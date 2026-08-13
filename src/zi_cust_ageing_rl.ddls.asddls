@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'REMOVE L'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CUST_AGEING_RL
  with parameters
    P_Date : datum
  as select from ZI_CUST_AGEING_SUM  (    P_Date: $parameters.P_Date )
{
  key InvoiceReference,
  key InvoiceItemReference,
  key InvoiceReferenceFiscalYear,
  key CompanyCode,
      CompanyCodeCurrency,
      Customer,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      sum(AmountInCompanyCodeCurrency) as received

}
where
  Symbol <> 'L'
group by
  InvoiceReference,
  CompanyCode,
  InvoiceItemReference,
  InvoiceReferenceFiscalYear,
  CompanyCodeCurrency,
  Customer
