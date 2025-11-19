String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }

  final emailRegex =
      RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  if (!emailRegex.hasMatch(value.trim())) {
    return 'Please enter a valid email address';
  }

  final blockedDomains = [
    "pecbo.org",
    'mailinator.com',
    '10minutemail.com',
    'guerrillamail.com',
    'tempmail.com',
    'yopmail.com',
    'trashmail.com',
    'fakeinbox.com',
    'getnada.com',
    'dispostable.com',
    'maildrop.cc',
    'mailnesia.com',
    'throwawaymail.com',
    'moakt.com',
    'emailondeck.com',
    'temp-mail.org',
    'temp-mail.io',
    'temp-mail.com',
    'tempmail.net',
    'tempmail.de',
    'tempmailo.com',
    'mintemail.com',
    'mytemp.email',
    'spamgourmet.com',
    'spambog.com',
    'spambog.de',
    'spambog.ru',
    'spambog.com',
    'spambox.us',
    'spamex.com',
    'spamfree24.com',
    'spamfree24.de',
    'spamfree24.eu',
    'spamfree24.info',
    'spamfree24.net',
    'spamfree24.org',
    'spamgourmet.com',
    'mailcatch.com',
    'maildrop.cc',
    'mailnull.com',
    'mohmal.com',
    'nowmymail.com',
    'sharklasers.com',
    'guerrillamailblock.com',
    'guerrillamail.org',
    'guerrillamail.net',
    'guerrillamail.de',
    'guerrillamail.biz',
    'guerrillamail.info',
    'guerrillamail.com',
    'guerrillamailblock.com',
    'discard.email',
    'discardmail.com',
    'discardmail.de',
    'mail-temp.com',
    'mail-temporaire.fr',
    'maildrop.cc',
    'mailinator2.com',
    'mailinator.net',
    'mailinator.org',
    'mailinator.us',
    'mailinator.xyz',
  ];

  final email = value.trim().toLowerCase();
  final domain = email.split('@').length > 1 ? email.split('@').last : '';
  if (blockedDomains.contains(domain)) {
    return 'Disposable email addresses are not allowed';
  }

  return null;
}
