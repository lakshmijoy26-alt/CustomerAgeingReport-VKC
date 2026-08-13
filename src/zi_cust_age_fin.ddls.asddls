@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Ageing Final'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_CUST_AGE_FIN
  with parameters
    P_Date : datum
  as select distinct from I_OperationalAcctgDocItem                        as _Opr

    left outer join       I_Customer                                       as _Cust       on _Cust.Customer = _Opr.Customer
    left outer join       ZI_CUST_AGEING_RL( P_Date:  $parameters.P_Date ) as _Received   on  _Received.InvoiceReference           = _Opr.AccountingDocument
                                                                                          and _Received.CompanyCode                = _Opr.CompanyCode
                                                                                          and _Received.InvoiceItemReference       = _Opr.AccountingDocumentItem
                                                                                          and _Received.InvoiceReferenceFiscalYear = _Opr.FiscalYear
                                                                                          and _Received.Customer                   = _Opr.Customer

    left outer join       ZI_CUST_AGEING ( P_Date:  $parameters.P_Date )   as _CustAgeing on  _CustAgeing.AccountingDocument     = _Opr.AccountingDocument
                                                                                          and _CustAgeing.CompanyCode            = _Opr.CompanyCode
                                                                                          and _CustAgeing.FiscalYear             = _Opr.FiscalYear
                                                                                          and _CustAgeing.Customer               = _Opr.Customer
                                                                                          and _CustAgeing.AccountingDocumentItem = _Opr.AccountingDocumentItem
{
      @Search.defaultSearchElement: true
  key _Opr.AccountingDocument,
  key _Opr.FiscalYear,
  key _Opr.CompanyCode,
  key _Opr.NetDueDate,
      $parameters.P_Date                                        as P_Date1,
      _Opr.Customer,
      _Opr.PostingDate,
      _Opr.AccountingDocumentItem,
      _Opr.AccountingDocumentType,
      _Opr.DocumentItemText,
      _Cust.Region,
      _Opr.BusinessPlace,
      _Cust.CustomerName,

      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _Opr.AmountInCompanyCodeCurrency                          as TotalAmount,
      ///////////////////////////////////////////////////
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _Received.received                                        as ReceivedAmount,
      ///////////////////////////////////////
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case when _Received.received  < 0 then
      _Opr.AmountInCompanyCodeCurrency +  _Received.received
            when _Received.received > 0 then
      _Opr.AmountInCompanyCodeCurrency + _Received.received
      else
      _Opr.AmountInCompanyCodeCurrency
      end                                                       as BalanceAmount,
      _Opr.ClearingDate,

      case when  _Opr.ClearingDate > $parameters.P_Date
      then

      cast('G' as abap.char( 2 ))
      when _Opr.ClearingDate = '00000000'
      then
      cast('N' as abap.char( 2 ))
      when  _Opr.ClearingDate < $parameters.P_Date
      then
      cast('L' as abap.char( 2 ))
      end                                                       as Symbol,
      dats_days_between( _Opr.PostingDate, $parameters.P_Date ) as AgedDays,
      _Opr.CompanyCodeCurrency,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
      when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 0 and 30
      then
      //      _Opr.AmountInCompanyCodeCurrency +  _Received.received
      _CustAgeing.BalanceAmount
      else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_0_30,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
          when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 31 and 45
          then
      //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
          _CustAgeing.BalanceAmount
          else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_31_45,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
          when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 46 and 60
          then
          _CustAgeing.BalanceAmount
      //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
          else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_46_60,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
          when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 61 and 90
          then
          _CustAgeing.BalanceAmount
      //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
          else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_61_90,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
          when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 91 and 120
          then
          _CustAgeing.BalanceAmount
      //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
          else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_91_120,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
          when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 121 and 180
          then
          _CustAgeing.BalanceAmount
      //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
          else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_121_180,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
          when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) between 181 and 360
          then
          _CustAgeing.BalanceAmount
      //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
          else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_181_360,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case
          when dats_days_between( _Opr.PostingDate, $parameters.P_Date ) > 360
          then
          _CustAgeing.BalanceAmount
      //          _Opr.AmountInCompanyCodeCurrency +  _Received.received
          else cast( 0 as abap.curr(15,2) )
      end                                                       as Bucket_360_Above
      //  _association_name // Make association public
}
where
       _Opr.Customer             <> ''
  and  _Opr.PostingDate          <= $parameters.P_Date
  and  _Opr.FinancialAccountType =  'D'
  and(
       _Opr.InvoiceReference     =  ''
    or _Opr.InvoiceReference     =  'V'
  )
