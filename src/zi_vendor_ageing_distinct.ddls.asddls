@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Vendor Ageing'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_VENDOR_AGEING_DISTINCT
  with parameters
    P_Date : datum
  as select distinct from I_OperationalAcctgDocItem                             as _Opr

    left outer join       I_Supplier                                            as _Supplier    on _Supplier.Supplier = _Opr.Supplier
    left outer join       ZI_CUST_AGE_FIN_SUM (    P_Date: $parameters.P_Date ) as _Received    on  _Received.InvoiceReference = _Opr.AccountingDocument
                                                                                                and _Received.CompanyCode      = _Opr.CompanyCode
  //                                                                    and _Received.FiscalYear       = _Opr.FiscalYear
    left outer join       ZI_VENDOR_AGEING    (    P_Date: $parameters.P_Date ) as _CustAgeing  on  _CustAgeing.AccountingDocument = _Opr.AccountingDocument
                                                                                                and _CustAgeing.CompanyCode        = _Opr.CompanyCode
                                                                                                and _CustAgeing.FiscalYear         = _Opr.FiscalYear

    left outer join       I_JournalEntryItem                                    as _JouItem     on  _Opr.AccountingDocument     = _JouItem.AccountingDocument
                                                                                                and _Opr.FiscalYear             = _JouItem.FiscalYear
                                                                                                and _Opr.CompanyCode            = _JouItem.CompanyCode
                                                                                                and _Opr.AccountingDocumentItem = _JouItem.AccountingDocumentItem
                                                                                                and _JouItem.Ledger             = '0L'

  //    left outer join       I_BillingDocument         as _Billing      on _Billing.BillingDocument = _JouItem.ReferenceDocument
  //    left outer join       I_DistributionChannelText as _Distribution on  _Distribution.DistributionChannel = _Billing.DistributionChannel
  //                                                                     and _Distribution.Language            = 'E'
    left outer join       ZI_JOURNALENTRYITEM                                   as _DistinctJou on  _Opr.AccountingDocument = _DistinctJou.AccountingDocument
                                                                                                and _Opr.FiscalYear         = _DistinctJou.FiscalYear
                                                                                                and _Opr.CompanyCode        = _DistinctJou.CompanyCode
  //  composition of target_data_source_name as _association_name
{
      @Search.defaultSearchElement: true
  key _Opr.AccountingDocument,
  key _Opr.FiscalYear,
  key _Opr.CompanyCode,
  key _Opr.NetDueDate,
      $parameters.P_Date                                        as P_Date1,
      _Opr.Supplier,
      _Opr.PostingDate,

      _Opr.AccountingDocumentType,
      _Opr.DocumentItemText,
      _Supplier.Region,
      _Opr.BusinessPlace,
      _Supplier.SupplierName,
      //      case
      //      when _Opr.AccountingDocumentType = 'RV' then
      //      _Distribution.DistributionChannelName
      //      when _Opr.AccountingDocumentType = 'DR' then
      //      _DistinctJou.DistributionChannelName
      //      else
      //      ''
      //      end                                                       as DistributionChannelName,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _Opr.AmountInCompanyCodeCurrency                          as TotalAmount,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      _Received.received                                        as ReceivedAmount,
      @Semantics: { amount : {currencyCode: 'CompanyCodeCurrency'} }
      case when _Received.received  < 0 then
      _Opr.AmountInCompanyCodeCurrency +  _Received.received
      else
      _Opr.AmountInCompanyCodeCurrency
      end                                                       as BalanceAmount,
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
       _Opr.Supplier               <> ''
  and  _Opr.CompanyCode            =  '3000'
  and(
       _Opr.AccountingDocumentType =  'KR'
    or _Opr.AccountingDocumentType =  'RE'
    or _Opr.AccountingDocumentType =  'UE'
  )
  and  _Opr.FinancialAccountType   =  'K'
  and  _Opr.ClearingJournalEntry   =  ''
  and  _Opr.AccountingDocumentItem =  '001'
// and  _Opr.AccountingDocument     =  '1600000001'
