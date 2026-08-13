@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'distinct'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@Search.searchable: true
@UI.presentationVariant: [
  {
    sortOrder: [
      {
        by: 'AccountingDocument'
      }
    ],
    maxItems: 10000
  }
]
define view entity ZI_CUST_AGEING_NETDUE
  with parameters
    P_Date : datum
  //  as select distinct from I_OperationalAcctgDocItem as _Opr
  as select distinct from ZI_CUST_AGE_FIN  (    P_Date: $parameters.P_Date )  as _Opr
    left outer join       I_Customer                                          as _Cust       on _Cust.Customer = _Opr.Customer
    left outer join       ZI_CUST_AGEING_RL (    P_Date: $parameters.P_Date ) as _Received   on  _Received.InvoiceReference           = _Opr.AccountingDocument
                                                                                             and _Received.CompanyCode                = _Opr.CompanyCode
                                                                                             and _Received.InvoiceItemReference       = _Opr.AccountingDocumentItem
                                                                                             and _Received.InvoiceReferenceFiscalYear = _Opr.FiscalYear
                                                                                             and _Received.Customer                   = _Opr.Customer

    left outer join       ZI_CUST_AGEING  (    P_Date: $parameters.P_Date )   as _CustAgeing on  _CustAgeing.AccountingDocument     = _Opr.AccountingDocument
                                                                                             and _CustAgeing.CompanyCode            = _Opr.CompanyCode
                                                                                             and _CustAgeing.FiscalYear             = _Opr.FiscalYear
                                                                                             and _CustAgeing.Customer               = _Opr.Customer
                                                                                             and _CustAgeing.AccountingDocumentItem = _Opr.AccountingDocumentItem
{
        @Search.defaultSearchElement: true
  key   _Opr.AccountingDocument,
  key   _Opr.FiscalYear,
  key   _Opr.CompanyCode,
  key   _Opr.NetDueDate,
  key   _Opr.AccountingDocumentItem,
        $parameters.P_Date                                       as P_Date1,
        _Opr.Customer,
        _Opr.PostingDate,

        _Opr.AccountingDocumentType,
        _Opr.DocumentItemText,
        _Cust.Region,
        _Opr.BusinessPlace,
        _Cust.CustomerName,

        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        _Opr.TotalAmount                                         as TotalAmount,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        _Opr.ReceivedAmount                                      as ReceivedAmount,
        //        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        //      case when _Received.received  < 0 then
        //      _Opr.AmountInCompanyCodeCurrency +  _Received.received
        //            when _Received.received > 0 then
        //      _Opr.AmountInCompanyCodeCurrency + _Received.received
        //      else
        //      _Opr.AmountInCompanyCodeCurrency
        //      end                                                      as BalanceAmount,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        _Opr.BalanceAmount,
        _Opr.ClearingDate,

        //      case when  _Opr.ClearingDate >= $parameters.P_Date
        //      then
        //      cast('G' as abap.char( 2 ))
        //        when _Opr.ClearingDate is null
        //        then cast('N' as abap.char( 2 ))
        //        when  _Opr.ClearingDate < $parameters.P_Date
        //      then
        //      cast('L' as abap.char( 2 ))
        //      end                                                      as Symbol,

        _Opr.Symbol,

        dats_days_between( _Opr.PostingDate, $parameters.P_Date ) as AgedDays,
        _Opr.CompanyCodeCurrency,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
        when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 0 and 30
        then
        //      _Opr.AmountInCompanyCodeCurrency +  _Received.received
        // _CustAgeing.BalanceAmount
        _Opr.BalanceAmount
        else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_0_30,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
            when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 31 and 45
            then
        //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
        //  _CustAgeing.BalanceAmount
           _Opr.BalanceAmount
            else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_31_45,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
            when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 46 and 60
            then
        //  _CustAgeing.BalanceAmount
        _Opr.BalanceAmount
        //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
            else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_46_60,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
            when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 61 and 90
            then
        //  _CustAgeing.BalanceAmount
        _Opr.BalanceAmount
        //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
            else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_61_90,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
            when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 91 and 120
            then
        //  _CustAgeing.BalanceAmount
        _Opr.BalanceAmount
        //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
            else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_91_120,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
            when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 121 and 180
            then
        //  _CustAgeing.BalanceAmount
        _Opr.BalanceAmount
        //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
            else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_121_180,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
            when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 181 and 360
            then
            _Opr.BalanceAmount
        // _CustAgeing.BalanceAmount
        //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
            else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_181_360,
        @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
        case
            when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) > 360
            then
        //  _CustAgeing.BalanceAmount
        _Opr.BalanceAmount
        //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
            else cast( 0 as abap.curr(15,2) )
        end                                                      as Bucket_360_Above
        //  _association_name // Make association public
}
where
  _Opr.Symbol <> 'L'
//      _Opr.Customer             <> ''
//  and _Opr.FinancialAccountType =  'D'
//  and _Opr.ClearingJournalEntry =  ''
//  and _Opr.ClearingDate         >  '20260101'
//    or _Opr.ClearingDate         is null
//  )
//and _Opr.AccountingDocument   =  _Opr.InvoiceReference
//  and _Opr.AccountingDocumentItem =  '001'
