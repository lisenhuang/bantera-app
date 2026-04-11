import '../infrastructure/auth_api_client.dart';
import '../l10n/app_localizations.dart';

/// Maps [AuthApiException.code] to localized copy for user-visible surfaces.
String localizeAuthApiError(AppLocalizations l10n, AuthApiException e) {
  switch (e.code) {
    case 'network_unreachable':
      return l10n.errorNetworkUnreachable;
    case 'network_cellular_blocked':
      return l10n.errorNetworkCellularBlocked;
    case 'tls_error':
      return l10n.errorTlsConnection;
    default:
      return e.message;
  }
}
