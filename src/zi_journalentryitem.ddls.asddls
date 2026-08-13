@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entry Item'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_JOURNALENTRYITEM
  as select distinct from I_JournalEntryItem        as _Jou
    left outer join       I_DistributionChannelText as _Distribution on  _Distribution.DistributionChannel = _Jou.DistributionChannel
                                                                     and _Distribution.Language            = 'E'
  //composition of target_data_source_name as _association_name
{
  key _Jou.AccountingDocument,
  key _Jou.CompanyCode,
  key _Jou.FiscalYear,
      _Jou.AccountingDocumentType,
      _Jou.IsReversal,
      _Jou.IsReversed,
      _Jou.DistributionChannel,
      _Distribution.DistributionChannelName
      //  _association_name // Make association public
}
where
      _Jou.Ledger              =  '0L'
  and _Jou.DistributionChannel <> ''
  and _Jou.IsReversal          =  ''
  and _Jou.IsReversed          =  ''
