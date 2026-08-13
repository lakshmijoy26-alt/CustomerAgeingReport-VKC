@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Ageing'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CUST_AGEING
  with parameters
    P_Date : datum
  as select from    I_OperationalAcctgDocItem                          as _Opr
    left outer join I_Customer                                         as _Cust     on _Cust.Customer = _Opr.Customer

    left outer join ZI_CUST_AGE_FIN_SUM( P_Date:  $parameters.P_Date ) as _Received on  _Received.InvoiceReference           = _Opr.AccountingDocument
                                                                                    and _Received.CompanyCode                = _Opr.CompanyCode
                                                                                    and _Received.InvoiceItemReference       = _Opr.AccountingDocumentItem
                                                                                    and _Received.InvoiceReferenceFiscalYear = _Opr.FiscalYear
                                                                                    and _Received.Customer                   = _Opr.Customer
  //composition of target_data_source_name as _association_name
{
  key _Opr.AccountingDocument,
  key _Opr.FiscalYear,
  key _Opr.CompanyCode,
      _Opr.PostingDate,
      _Opr.NetDueDate,
      _Opr.AccountingDocumentType,
      _Opr.DocumentItemText,
      _Opr.Region,
      _Opr.BusinessPlace,
      _Opr.Customer,
      _Cust.CustomerName,
      _Opr.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case when _Received.received < 0 then
      _Opr.AmountInCompanyCodeCurrency +  _Received.received
      when _Received.received > 0 then
      _Opr.AmountInCompanyCodeCurrency + _Received.received
      else
      _Opr.AmountInCompanyCodeCurrency
      end as BalanceAmount,
      _Opr.AccountingDocumentItem

      //    _association_name // Make association public
}
where
      _Opr.Customer             <> ''
  and _Opr.FinancialAccountType =  'D'
  and _Opr.ClearingJournalEntry =  ''
//  and  _Opr.AccountingDocumentItem =  '001'
// and  _Opr.AccountingDocument     =  '1600000001'
