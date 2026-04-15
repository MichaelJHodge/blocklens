class WalletValidator {
  static final RegExp _ethAddressRegex = RegExp(r'^0x[a-fA-F0-9]{40}$');

  static bool isValidEthereumAddress(String address) {
    return _ethAddressRegex.hasMatch(address.trim());
  }
}
