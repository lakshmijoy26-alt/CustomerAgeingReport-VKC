@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Ageing Sum'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CUST_AGEING_SUM
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
      //      sum(AmountInCompanyCodeCurrency) as received,
      AmountInCompanyCodeCurrency,
      ClearingDate,

      case when  ClearingDate > $parameters.P_Date
      then
      cast('G' as abap.char( 2 ))
      when ClearingDate = '00000000'
      then
      cast('N' as abap.char( 2 ))
      when ClearingDate < $parameters.P_Date
      then
      cast('L' as abap.char( 2 ))
      end as Symbol
}
where
      InvoiceReference <> ''
  and PostingDate      <=  $parameters.P_Date
//where
//  PostingDate < $parameters.P_Date
//  ClearingJournalEntry = ''

//group by
//  InvoiceReference,
//  CompanyCode,
//  InvoiceItemReference,
//  InvoiceReferenceFiscalYear,
//  CompanyCodeCurrency,
//  Customer
