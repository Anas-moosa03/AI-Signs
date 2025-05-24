import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleStorageKey = '__locale_key__';

class FFLocalizations {
  FFLocalizations(this.locale);

  final Locale locale;

  static FFLocalizations of(BuildContext context) =>
      Localizations.of<FFLocalizations>(context, FFLocalizations)!;

  static List<String> languages() => ['en', 'ar'];

  static late SharedPreferences _prefs;
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();
  static Future storeLocale(String locale) =>
      _prefs.setString(_kLocaleStorageKey, locale);
  static Locale? getStoredLocale() {
    final locale = _prefs.getString(_kLocaleStorageKey);
    return locale != null && locale.isNotEmpty ? createLocale(locale) : null;
  }

  String get languageCode => locale.toString();
  String? get languageShortCode =>
      _languagesWithShortCode.contains(locale.toString())
          ? '${locale.toString()}_short'
          : null;
  int get languageIndex => languages().contains(languageCode)
      ? languages().indexOf(languageCode)
      : 0;

  String getText(String key) =>
      (kTranslationsMap[key] ?? {})[locale.toString()] ?? '';

  String getVariableText({
    String? enText = '',
    String? arText = '',
  }) =>
      [enText, arText][languageIndex] ?? '';

  static const Set<String> _languagesWithShortCode = {
    'ar',
    'az',
    'ca',
    'cs',
    'da',
    'de',
    'dv',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'gr',
    'he',
    'hi',
    'hu',
    'it',
    'km',
    'ku',
    'mn',
    'ms',
    'no',
    'pt',
    'ro',
    'ru',
    'rw',
    'sv',
    'th',
    'uk',
    'vi',
  };
}

/// Used if the locale is not supported by GlobalMaterialLocalizations.
class FallbackMaterialLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(FallbackMaterialLocalizationDelegate old) => false;
}

/// Used if the locale is not supported by GlobalCupertinoLocalizations.
class FallbackCupertinoLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(FallbackCupertinoLocalizationDelegate old) => false;
}

class FFLocalizationsDelegate extends LocalizationsDelegate<FFLocalizations> {
  const FFLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => _isSupportedLocale(locale);

  @override
  Future<FFLocalizations> load(Locale locale) =>
      SynchronousFuture<FFLocalizations>(FFLocalizations(locale));

  @override
  bool shouldReload(FFLocalizationsDelegate old) => false;
}

Locale createLocale(String language) => language.contains('_')
    ? Locale.fromSubtags(
        languageCode: language.split('_').first,
        scriptCode: language.split('_').last,
      )
    : Locale(language);

bool _isSupportedLocale(Locale locale) {
  final language = locale.toString();
  return FFLocalizations.languages().contains(
    language.endsWith('_')
        ? language.substring(0, language.length - 1)
        : language,
  );
}

final kTranslationsMap = <Map<String, Map<String, String>>>[
  // Landing
  {
    'rl2gukvo': {
      'en': 'AI Signs',
      'ar': 'علامات الذكاء الاصطناعي',
    },
    'ezgxwoin': {
      'en': 'Communicate Without Barriers!',
      'ar': 'التواصل بدون حواجز!',
    },
    '6o2y2gxp': {
      'en': 'Get Started',
      'ar': 'البدء',
    },
    'tymg8nua': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // CreateAccount
  {
    'wwz3d5zi': {
      'en': 'AI Signs',
      'ar': 'علامات الذكاء الاصطناعي',
    },
    'vkbjywxc': {
      'en': 'Create an account',
      'ar': 'إنشاء حساب',
    },
    'e4v21uuy': {
      'en': 'Let\'s get started by filling out the form below.',
      'ar': 'لنبدأ بملء النموذج أدناه.',
    },
    'fmwq8ocv': {
      'en': 'display_name',
      'ar': 'اسم العرض',
    },
    'yb4z9u8p': {
      'en': 'email',
      'ar': 'بريد إلكتروني',
    },
    'fpvlp8e6': {
      'en': 'password',
      'ar': 'كلمة المرور',
    },
    'f2xd1eln': {
      'en': 'Confirm Password',
      'ar': 'تأكيد كلمة المرور',
    },
    'g12s8r82': {
      'en': 'Create Account',
      'ar': 'إنشاء حساب',
    },
    's7jty985': {
      'en': 'OR',
      'ar': 'أو',
    },
    'yduvj2ah': {
      'en': 'Back To Sign In',
      'ar': 'العودة إلى تسجيل الدخول',
    },
    '65hqwcm8': {
      'en': 'UserName',
      'ar': 'اسم المستخدم',
    },
    '5t1gvxvw': {
      'en': 'Overall',
      'ar': 'إجمالي',
    },
    '3m8aqay5': {
      'en': '5',
      'ar': '5',
    },
    '12y7854m': {
      'en':
          'Nice outdoor courts, solid concrete and good hoops for the neighborhood.',
      'ar': 'ملاعب خارجية جميلة، وخرسانة صلبة، وأطواق جيدة للجيران.',
    },
    'pa8l8ccv': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // SignLanguageTR
  {
    'nrlcqho6': {
      'en': 'Sign Language Translation',
      'ar': 'ترجمة لغة الإشارة',
    },
    '74rxgakg': {
      'en':
          'Experience the power of real-time Arabic text translation from sign language',
      'ar': 'استمتع بقوة ترجمة النصوص العربية في الوقت الفعلي من لغة الإشارة',
    },
    'v52zbkbx': {
      'en':
          'It\'s simple and intuitive—just step into the frame that appears, press \'Start Translating,\' and begin signing. Let our technology handle the rest for you!',
      'ar':
          'إنه أمر بسيط وسهل الاستخدام، فقط ادخل إلى الإطار الذي يظهر، واضغط على \"بدء الترجمة\"، وابدأ في التوقيع. دع تقنيتنا تتولى الباقي نيابة عنك!',
    },
    'ni0x90al': {
      'en': 'Camera Preview',
      'ar': 'معاينة الكاميرا',
    },
    '3i1e76ah': {
      'en': 'Start Translating',
      'ar': 'ابدأ الترجمة',
    },
    'x8tcherv': {
      'en': 'Share Your Experience',
      'ar': 'شارك تجربتك',
    },
    'z2uwem5a': {
      'en': 'Help us improve by providing your feedback',
      'ar': 'ساعدنا على التحسين من خلال تقديم ملاحظاتك',
    },
    'wha7m600': {
      'en': 'Your feedback',
      'ar': 'تعليقاتك',
    },
    'cc1lhua8': {
      'en': 'Submit Feedback',
      'ar': 'إرسال التعليقات',
    },
  },
  // HelpUs
  {
    'iubwmjw9': {
      'en': 'Help Us!',
      'ar': 'ساعدونا!',
    },
    'jf384qm1': {
      'en':
          'Your support can make a huge difference! Contribute to enhancing our app by adding new signs to our database. It\'s easy and rewarding:',
      'ar':
          'يمكن أن يحدث دعمك فرقًا كبيرًا! ساهم في تحسين تطبيقنا من خلال إضافة علامات جديدة إلى قاعدة بياناتنا. الأمر سهل ومجزٍ:',
    },
    'thecd6km': {
      'en':
          '1. Tap the \"Add Data\" button below.\n2. Upload a photo or video, or record yourself performing a sign that isn\'t included in our app.\n3. Provide a label or meaning for the sign in the designated text box.',
      'ar':
          '1. انقر على زر \"إضافة بيانات\" أدناه.\n2. قم بتحميل صورة أو مقطع فيديو، أو سجّل نفسك أثناء أداء علامة غير مدرجة في تطبيقنا.\n3. أدخل تسمية أو معنى للعلامة في مربع النص المخصص لذلك.',
    },
    'pwy75ko8': {
      'en':
          'By sharing your knowledge, you help us create a more inclusive tool that serves a wider audience. Thank you for being part of our journey!',
      'ar':
          'من خلال مشاركة معرفتك، فإنك تساعدنا في إنشاء أداة أكثر شمولاً تخدم جمهورًا أوسع. شكرًا لك على كونك جزءًا من رحلتنا!',
    },
    'apf5gxcy': {
      'en': 'Add Your New Sign Here',
      'ar': 'أضف اشارتك الجديدة هنا',
    },
    '7xqiivzd': {
      'en': 'Add your new sign here:',
      'ar': 'أضف اشارتك الجديدة هنا:',
    },
    'klko827d': {
      'en': 'Add Data',
      'ar': 'إضافة البيانات',
    },
    '51z736m5': {
      'en': 'The Meaning of the Sign',
      'ar': 'معنى العلامة',
    },
    'x04pi20s': {
      'en': 'The meaning of the sign:',
      'ar': 'معنى العلامة:',
    },
    '5y9j52dg': {
      'en': 'Enter the meaning here',
      'ar': 'أدخل المعنى هنا',
    },
    'e29jq0f5': {
      'en': 'Submit',
      'ar': 'يُقدِّم',
    },
  },
  // Login1
  {
    'voaoi39b': {
      'en': 'AI Signs',
      'ar': 'علامات الذكاء الاصطناعي',
    },
    'y9pjzdb2': {
      'en': 'Welcome!',
      'ar': 'مرحباً!',
    },
    'e8jadyy0': {
      'en': 'Let\'s get started by filling out the form below.',
      'ar': 'لنبدأ بملء النموذج أدناه.',
    },
    'fshi9o3w': {
      'en': 'Email',
      'ar': 'بريد إلكتروني',
    },
    'v74e5ssa': {
      'en': 'Password',
      'ar': 'كلمة المرور',
    },
    'qd0mewza': {
      'en': 'Forget Your Password? ',
      'ar': 'هل نسيت كلمة المرور؟',
    },
    '8fz2pc69': {
      'en': ' Recover Your Password',
      'ar': 'استعادة كلمة المرور الخاصة بك',
    },
    '88za5muf': {
      'en': 'Sign In',
      'ar': 'تسجيل الدخول',
    },
    'uua3ldd0': {
      'en': 'Don\'t have an account? ',
      'ar': 'ليس لديك حساب؟',
    },
    'kdkxrnk8': {
      'en': ' Sign Up here',
      'ar': 'سجل هنا',
    },
    'gl3sd4ff': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // editProfile
  {
    '6esx4irr': {
      'en': 'Edit Profile',
      'ar': 'تعديل الملف الشخصي',
    },
    '5reh7cv8': {
      'en': 'Your information',
      'ar': 'معلوماتك',
    },
    'gidzwghf': {
      'en': 'Your Name',
      'ar': 'اسمك',
    },
    'cve029x7': {
      'en': 'Email',
      'ar': 'بريد إلكتروني',
    },
    '5ccztg6k': {
      'en': 'Email',
      'ar': 'بريد إلكتروني',
    },
    '2gotjt1b': {
      'en': 'Save Changes',
      'ar': 'حفظ التغييرات',
    },
    't67en8ay': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // passwordChange
  {
    'boi0la1l': {
      'en': 'Back',
      'ar': 'العودة',
    },
    'l8jd3x4b': {
      'en': 'Change Password',
      'ar': 'تغيير كلمة المرور',
    },
    '96k3dv3m': {
      'en':
          'We will send you an email with a link to reset your password, please enter the email associated with your account below.',
      'ar':
          'سنرسل لك بريدًا إلكترونيًا به رابط لإعادة تعيين كلمة المرور الخاصة بك، يرجى إدخال البريد الإلكتروني المرتبط بحسابك أدناه.',
    },
    'g0dpnj2y': {
      'en': 'Your email address...',
      'ar': 'عنوان بريدك  الإلكتروني...',
    },
    '732vssvh': {
      'en': 'Enter your email...',
      'ar': 'أدخل بريدك الإلكتروني...',
    },
    'uihurfds': {
      'en': 'Send Link',
      'ar': 'إرسال الرابط',
    },
    'tq8aut5i': {
      'en': 'Back',
      'ar': 'العودة',
    },
    'eqqb8hda': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // thankyou-data
  {
    'tpv52n3g': {
      'en': 'Thank you!',
      'ar': 'شكرًا لك!',
    },
    '4uplt9lo': {
      'en': 'your help is appreciated',
      'ar': 'مساعدتك موضع تقدير',
    },
    'm08nxz57': {
      'en': 'Back To Home',
      'ar': 'العودة إلى الصفحة الرئيسية',
    },
    'mvf65prx': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // thankyou-feedback
  {
    '56kj9qej': {
      'en': 'Thank you!',
      'ar': 'شكرًا لك!',
    },
    'tvjf3x7q': {
      'en':
          'Thank you for your valuable feedback; it helps us improve and enhance your experience.',
      'ar': 'نشكرك على تعليقاتك القيمة؛ فهي تساعدنا على تحسين وتعزيز تجربتك.',
    },
    'l47f0013': {
      'en': 'Back To Home',
      'ar': 'العودة إلى الصفحة الرئيسية',
    },
    'vdloikv4': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // Terms-Services
  {
    '7zxadplq': {
      'en':
          '1. Acceptance of Terms\n\nBy using the AI Signs application, you agree to comply with and be bound by these terms and conditions. If you do not agree with any part of these terms, you are advised to discontinue using the application.\n\n2. Service Overview\n\nAI Signs is a platform designed to assist users in translating Arabic sign language to text and vice versa. It also offers features to contribute data and provide feedback to enhance the platform. All functionalities are intended for personal, non-commercial use only.\n\n3. User Responsibilities\n\n- Use the application solely for its intended purpose.\n\n- Avoid uploading inappropriate, offensive, or harmful content.\n\n- Provide accurate information when contributing data or providing feedback.\n\n\n4. Data Contribution\n\nUsers contributing data (e.g., videos, photos, or textual labels) grant AI Signs a non-exclusive, royalty-free license to use the content for improving the application\'s performance and expanding its database. AI Signs will not use this data for any purposes outside its scope.\n\n5. Privacy Policy\n\nAI Signs respects your privacy and handles your data responsibly. Collected data will only be used to enhance application functionality and will not be shared with third parties without your consent. For more details, refer to our Privacy Policy.\n\n6. Limitation of Liability\n\nAI Signs is provided on an \"as-is\" basis. While we strive to ensure accurate translations and smooth functionality, we do not guarantee the application\'s performance at all times. AI Signs will not be liable for any damages or losses resulting from the use or inability to use the application.\n\n7. Updates and Changes\n\nAI Signs reserves the right to modify these terms and the application\'s features at any time. Users will be notified of significant changes through the application or other communication channels.\n\n8. Contact Us\n\nIf you have any questions, concerns, or feedback regarding these terms or the application, please reach out to us at:\n\nEmail: support@aisigns.com\nPhone: 0799000000\n',
      'ar':
          '1. قبول الشروط\n\nباستخدام تطبيق AI Signs، فإنك توافق على الامتثال لهذه الشروط والأحكام والالتزام بها. إذا كنت لا توافق على أي جزء من هذه الشروط، فننصحك بالتوقف عن استخدام التطبيق.\n\n2. نظرة عامة على الخدمة\n\nAI Signs عبارة عن منصة مصممة لمساعدة المستخدمين في ترجمة لغة الإشارة العربية إلى نص والعكس صحيح. كما تقدم ميزات للمساهمة بالبيانات وتقديم الملاحظات لتحسين المنصة. جميع الوظائف مخصصة للاستخدام الشخصي غير التجاري فقط.\n\n3. مسؤوليات المستخدم\n\n- استخدم التطبيق فقط للغرض المقصود منه.\n\n- تجنب تحميل محتوى غير مناسب أو مسيء أو ضار.\n\n- تقديم معلومات دقيقة عند المساهمة بالبيانات أو تقديم الملاحظات.\n\n4. مساهمة البيانات\n\nيمنح المستخدمون الذين يساهمون بالبيانات (مثل مقاطع الفيديو أو الصور أو العلامات النصية) AI Signs ترخيصًا غير حصري وخاليًا من حقوق الملكية لاستخدام المحتوى لتحسين أداء التطبيق وتوسيع قاعدة بياناته. لن تستخدم AI Signs هذه البيانات لأي غرض خارج نطاقها.\n\n5. سياسة الخصوصية\n\nتحترم AI Signs خصوصيتك وتتعامل مع بياناتك بمسؤولية. لن تُستخدم البيانات المجمعة إلا لتحسين وظائف التطبيق ولن تتم مشاركتها مع أطراف ثالثة دون موافقتك. لمزيد من التفاصيل، راجع سياسة الخصوصية الخاصة بنا.\n\n6. الحد من المسؤولية\n\nيتم تقديم AI Signs على أساس \"كما هي\". وبينما نسعى جاهدين لضمان الترجمات الدقيقة والوظائف السلسة، فإننا لا نضمن أداء التطبيق في جميع الأوقات. لن تكون AI Signs مسؤولة عن أي أضرار أو خسائر ناجمة عن استخدام التطبيق أو عدم القدرة على استخدامه.\n\n7. التحديثات والتغييرات\n\nتحتفظ AI Signs بالحق في تعديل هذه الشروط وميزات التطبيق في أي وقت. سيتم إخطار المستخدمين بالتغييرات المهمة من خلال التطبيق أو قنوات الاتصال الأخرى.\n\n8. اتصل بنا\n\nإذا كانت لديك أي أسئلة أو مخاوف أو تعليقات بخصوص هذه الشروط أو التطبيق، يرجى التواصل معنا على:\n\nالبريد الإلكتروني: support@aisigns.com\nالهاتف: 0799000000',
    },
    '0aww1z53': {
      'en': 'Terms & Services',
      'ar': 'الشروط والخدمات',
    },
  },
  // JordanSLC
  {
    'dv68365e': {
      'en': 'Jordanian Deaf Community',
      'ar': 'مجتمع الصم الأردني',
    },
    'v53y5hiy': {
      'en': 'Understanding & Supporting Our Community',
      'ar': 'فهم ودعم مجتمعنا',
    },
    'em6o6uzd': {
      'en': 'Demographics',
      'ar': 'التركيبة السكانية',
    },
    'berhkvpk': {
      'en': '57,000',
      'ar': '57000',
    },
    'wckth5p1': {
      'en': 'Deaf Community Members',
      'ar': 'أعضاء مجتمع الصم',
    },
    's3xz8as2': {
      'en': 'ARSL',
      'ar': 'لغة الاشارة العربية',
    },
    'shzpijne': {
      'en': 'Arabic SL',
      'ar': 'لغة الاشارة العربية',
    },
    '1ptayx3i': {
      'en': 'Faith & Beliefs',
      'ar': 'الإيمان والمعتقدات',
    },
    '2q3caloe': {
      'en':
          'The majority of Jordanian Deaf families are Sunni Muslims (95%), with a small Christian minority (5%). The community shows particular receptivity to ideas presented in sign language.',
      'ar':
          'أغلبية أسر الصم الأردنية من المسلمين السنة (95%)، مع أقلية مسيحية صغيرة (5%). ويظهر المجتمع تقبلاً خاصاً للأفكار المقدمة بلغة الإشارة.',
    },
    'tkn27ngs': {
      'en': 'Community Needs',
      'ar': 'احتياجات المجتمع',
    },
    'lihdha3u': {
      'en':
          'The Deaf community in Jordan needs continued access to education, resources, and acceptance. Supporting their growth through understanding and inclusive practices is essential for their well-being.',
      'ar':
          'يحتاج مجتمع الصم في الأردن إلى استمرار الوصول إلى التعليم والموارد والقبول. إن دعم نموهم من خلال الفهم والممارسات الشاملة أمر ضروري لرفاهتهم.',
    },
    'zoglot6p': {
      'en': 'Explore Deaf Community services in Jordan',
      'ar': 'اكتشف خدمات مجتمع الصم في الأردن',
    },
    'bw7tjn1u': {
      'en': 'For more information, Click Here',
      'ar': 'لمزيد من المعلومات، انقر هنا',
    },
  },
  // Jplaces
  {
    'v10gdqav': {
      'en': 'Discover key services supporting Jordan\'s Deaf community',
      'ar': 'اكتشف الخدمات الرئيسية التي تدعم مجتمع الصم في الأردن',
    },
    '12anqq46': {
      'en': 'Amman,Irbid Jordan',
      'ar': 'عمان،اربد،الاردن',
    },
    'ypenawcz': {
      'en': 'Prince Ali Club for the Deaf',
      'ar': 'نادي الأمير علي للصم',
    },
    'hn87f7dk': {
      'en':
          'A vibrant hub offering cultural, social, sports, and charitable services for the Deaf community. The club focuses on enhancing self-esteem and providing educational and professional development opportunities.',
      'ar':
          'مركز نابض بالحياة يقدم خدمات ثقافية واجتماعية ورياضية وخيرية لمجتمع الصم. يركز النادي على تعزيز احترام الذات وتوفير فرص التطوير التعليمي والمهني.',
    },
    'dhsf2u9g': {
      'en': 'Learn More',
      'ar': 'يتعلم أكثر',
    },
    '1c8a5tcb': {
      'en': 'Salt, Jordan',
      'ar': 'السلط، الأردن',
    },
    'o9axm3iq': {
      'en': 'Holy Land Institute for the Deaf',
      'ar': 'معهد الأرض المقدسة للصم',
    },
    'ovi6d2h2': {
      'en':
          'A sanctuary for 150 children and young adults, offering therapeutic services, K-12 academic programs, and vocational training for the hearing-impaired, Deaf, and Deaf-blind communities.',
      'ar':
          'محمية لـ 150 طفلاً وشابًا، تقدم خدمات علاجية وبرامج أكاديمية للأطفال من رياض الأطفال حتى الصف الثاني عشر، وتدريبًا مهنيًا لمجتمعات ضعاف السمع والصم والصم المكفوفين.',
    },
    '80dcjgm1': {
      'en': 'Learn More',
      'ar': 'المزيد من المعلومات',
    },
    '8ycom8kg': {
      'en': 'Digital Platform',
      'ar': 'المنصة الرقمية',
    },
    'tbav3202': {
      'en': 'Masmou3',
      'ar': 'مسموع',
    },
    'th2cquhj': {
      'en':
          'Jordan\'s first digital platform dedicated to the hearing-impaired, created with the British Council and Prince Ali Club. Advocating for sign language integration in schools and fostering digital inclusion.',
      'ar':
          'أول منصة رقمية في الأردن مخصصة للأشخاص ذوي الإعاقة السمعية، تم إنشاؤها بالتعاون مع المجلس الثقافي البريطاني ونادي الأمير علي. تهدف إلى الدعوة إلى دمج لغة الإشارة في المدارس وتعزيز الشمول الرقمي.',
    },
    '6wbl6146': {
      'en': 'Visit Instagram',
      'ar': 'قم بزيارة الانستغرام',
    },
    'pu7xeb4q': {
      'en': 'Deaf Community Services',
      'ar': 'خدمات مجتمع الصم',
    },
  },
  // LearnARSL
  {
    'qclb04v8': {
      'en': 'Learn ARSL',
      'ar': 'تعلم لغة الاشارة العربية',
    },
    'iincu5hl': {
      'en': 'Begin your journey to mastering\n Arabic Sign Language',
      'ar': 'ابدأ رحلتك لإتقان لغة الإشارة العربية',
    },
    '9babc2i5': {
      'en': 'Arabic Letters Signs',
      'ar': 'اشارات الحروف العربية',
    },
    'vfvq9r6i': {
      'en':
          'Learn how to sign the 28 Arabic letters \nwith this clear and comprehensive guide.',
      'ar':
          'تعلم كيفية الاشارة بالحروف العربية الـ 28 مع هذا الدليل الواضح والشامل.',
    },
    'wqbhkf4a': {
      'en': 'ARSL Letters In Videos',
      'ar': 'حروف اللغة العربية في مقاطع الفيديو',
    },
    'bbzuo8gi': {
      'en': 'Verbs in ARSL',
      'ar': 'الأفعال في اللغة العربية الحديثة',
    },
    '907eu2r3': {
      'en':
          'Explore a YouTube playlist\n to learn more than 70 verbs in ARSL.\n',
      'ar':
          'استكشف قائمة تشغيل YouTube\nلتعلم أكثر من 70 فعلًا في لغة لغة الاشارة العربية.',
    },
    'wzjsx9nb': {
      'en': 'Explore ARSL Verbs ',
      'ar': 'استكشاف أفعال لغة الاشارة العربية',
    },
    '8ut25uk5': {
      'en': 'University Majors in ARSL',
      'ar': 'التخصصات الجامعية في لغة الاشارة العربية',
    },
    'no2tg13z': {
      'en':
          'Explore a YouTube playlist\n to learn Up to 30 University Majors in ARSL.\n',
      'ar':
          'استكشف قائمة تشغيل على YouTube لتتعرف على ما يصل إلى 30 تخصصًا جامعيًا في لغة الاشارة العربية.',
    },
    '1ovm6f6k': {
      'en': 'Explore ARSL University Majors',
      'ar': 'استكشف التخصصات الرئيسية في لغة الاشارة العربية',
    },
    '7mu06cb4': {
      'en': 'Jobs in ARSL',
      'ar': 'الوظائف في لغة الاشارة العربية',
    },
    'y838z6nx': {
      'en':
          'Explore a YouTube playlist\n to learn more than 30 Jobs in ARSL.\n',
      'ar':
          'استكشف قائمة تشغيل YouTube لمعرفة أكثر من 30 وظيفة في لغة الاشارة العربية.',
    },
    'x8cdruqn': {
      'en': 'Explore Jobs in ARSL',
      'ar': 'استكشف الوظائف في لغة الاشارة العربية',
    },
  },
  // PasswordRecovery
  {
    'fh1cc5pg': {
      'en': 'Back',
      'ar': 'خلف',
    },
    'p9zdppg9': {
      'en': 'Recover Password',
      'ar': 'استعادة كلمة المرور',
    },
    'hfij5b5z': {
      'en':
          'We will send you an email with a link to reset your password, please enter the email associated with your account below.',
      'ar':
          'سنرسل لك بريدًا إلكترونيًا به رابط لإعادة تعيين كلمة المرور الخاصة بك، يرجى إدخال البريد الإلكتروني المرتبط بحسابك أدناه.',
    },
    'cnlgts2v': {
      'en': 'Your email address...',
      'ar': 'عنوان بريدك  الإلكتروني...',
    },
    'skzh6vn7': {
      'en': 'Enter your email...',
      'ar': 'أدخل بريدك الإلكتروني...',
    },
    'iu52cz25': {
      'en': 'Send Link',
      'ar': 'إرسال الرابط',
    },
    'cotsqtg2': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // EmailSentPage
  {
    'bhjtv0t2': {
      'en': 'Email Sent Succesfully!',
      'ar': 'تم إرسال البريد الإلكتروني بنجاح!',
    },
    'iyjnr2sf': {
      'en':
          'We have sent a password recovery email to your registered email address. Please check your inbox',
      'ar':
          'لقد أرسلنا لك رسالة بريد إلكتروني لاستعادة كلمة المرور إلى عنوان بريدك الإلكتروني المسجل. يرجى التحقق من صندوق الوارد الخاص بك',
    },
    'd3q6zqwk': {
      'en':
          'if you dont see the email, check you span folder or click the button below to resend.',
      'ar':
          'إذا لم تتمكن من رؤية البريد الإلكتروني، فتحقق من مجلد SPA أو انقر فوق الزر أدناه لإعادة الإرسال.',
    },
    '65jv15mw': {
      'en': 'Resend Email',
      'ar': 'إعادة إرسال البريد الإلكتروني',
    },
    'un6i4s6c': {
      'en': 'Back to Login',
      'ar': 'العودة إلى تسجيل الدخول',
    },
    '40y6h3l1': {
      'en': 'Home',
      'ar': 'بيت',
    },
  },
  // Home2
  {
    'vd0hp4t6': {
      'en': 'Welcome to AI Signs!',
      'ar': 'مرحباً بكم في AI Signs!',
    },
    'awvtyeje': {
      'en': 'Break Barriers, Communicate Freely!',
      'ar': 'اكسر الحواجز، وتواصل بحرية!',
    },
    'mabunmo3': {
      'en': 'Key Features',
      'ar': 'الميزات الرئيسية',
    },
    'bs5tw9hj': {
      'en': 'Sign Language Translation',
      'ar': 'ترجمة لغة الإشارة',
    },
    'sielo06b': {
      'en': 'Convert sign language to text in real-time',
      'ar': 'تحويل لغة الإشارة إلى نص في الوقت الحقيقي',
    },
    'wmhm61zd': {
      'en': 'Learn Arsl',
      'ar': 'تعلم اللغة العربية',
    },
    '3x3prxtz': {
      'en':
          'Learn Arabic Sign Language By Accessing Images and Videos of Different Signs',
      'ar':
          'تعلم لغة الإشارة العربية من خلال الاطلاع على صور وفيديوهات لإشارات مختلفة',
    },
    'ujuhjpol': {
      'en': 'Help Us',
      'ar': 'ساعدنا',
    },
    'urrfl5l4': {
      'en': 'Help us expand and improve our project by adding new data.',
      'ar': 'ساعدنا على توسيع وتحسين مشروعنا عن طريق إضافة بيانات جديدة.',
    },
    '5vzi5e3y': {
      'en': 'Jordanian Deaf Community',
      'ar': 'مجتمع الصم الأردني',
    },
    '0qfjcux6': {
      'en': 'Learn More',
      'ar': 'يتعلم أكثر',
    },
  },
  // EmailVerf
  {
    '5uycsykn': {
      'en': 'Verify your email',
      'ar': 'التحقق من بريدك الإلكتروني',
    },
    'gd1ufqj7': {
      'en': 'We\'ve sent a verification link to:',
      'ar': 'لقد أرسلنا رابط التحقق إلى:',
    },
    'ewe2jk6e': {
      'en': 'Didn\'t receive the email?',
      'ar': 'لم تتلق البريد الإلكتروني؟',
    },
    '3ahqqisn': {
      'en': '• Check your spam folder',
      'ar': '• تحقق من مجلد البريد العشوائي الخاص بك',
    },
    'f1j947j1': {
      'en': '• Make sure the email address is correct',
      'ar': '• تأكد من صحة عنوان البريد الإلكتروني',
    },
    '1zkqa7rd': {
      'en': 'Resend Verification Email',
      'ar': 'إعادة إرسال بريد إلكتروني للتحقق',
    },
    '1h870p2l': {
      'en': 'I Have Verified My Email',
      'ar': 'لقد قمت بالتحقق من بريدي الإلكتروني',
    },
  },
  // Profile1
  {
    'l6w2oyxc': {
      'en': 'Account Settings',
      'ar': 'إعدادات الحساب',
    },
    'f9v54rkt': {
      'en': 'Edit Profile',
      'ar': 'تعديل الملف الشخصي',
    },
    'udt1fgod': {
      'en': 'Change Password',
      'ar': 'تغيير كلمة المرور',
    },
    'm753u27q': {
      'en': 'Help & Support',
      'ar': 'المساعدة والدعم',
    },
    '2o8w1bk0': {
      'en': 'Terms of Service',
      'ar': 'شروط الخدمة',
    },
    '4a2e9jno': {
      'en': 'Privacy Policy',
      'ar': 'سياسة الخصوصية',
    },
    'ts6ycyc6': {
      'en': 'Sign Out',
      'ar': 'تسجيل الخروج',
    },
    'x09dq3vd': {
      'en': 'Light Mode',
      'ar': 'وضع الضوء',
    },
    'tqy8zpso': {
      'en': 'Dark Mode',
      'ar': 'الوضع المظلم',
    },
  },
  // PrivacyPolicy
  {
    'yd4t51vy': {
      'en': 'Privacy Policy',
      'ar': '',
    },
    '3cbgcxv6': {
      'en': 'Introduction',
      'ar': '',
    },
    '1isxzout': {
      'en':
          'At AI Signs, we are committed to protecting your privacy and ensuring the security of your personal data. This policy explains how we collect, use, and safeguard your information while using our sign language translation and educational services.',
      'ar': '',
    },
    '16bpvh44': {
      'en': 'Sign Language Translation',
      'ar': '',
    },
    'yzz8dco7': {
      'en': 'Video Processing & Storage',
      'ar': '',
    },
    'iy4819x3': {
      'en':
          '• Videos are processed in real-time for translation\n• No permanent storage unless explicitly saved by user\n• Zero sharing with third parties\n• Automatic deletion after translation completion',
      'ar': '',
    },
    'b7d44jkd': {
      'en': 'Security Measures',
      'ar': '',
    },
    'mq7uaubr': {
      'en':
          '• End-to-end encryption for video transmission\n• Secure cloud processing\n• Temporary data handling\n• Regular security audits',
      'ar': '',
    },
    '7sli0y5o': {
      'en': 'Learning Arabic Sign Language',
      'ar': '',
    },
    'k8qhf0dy': {
      'en': 'Educational Content',
      'ar': '',
    },
    'hilxef68': {
      'en':
          '• Progress tracking stored locally\n• Optional cloud sync for multi-device access\n• Personal learning data remains private\n• No advertising or third-party sharing',
      'ar': '',
    },
    'sy59w9l4': {
      'en': 'User Progress',
      'ar': '',
    },
    '2zosx311': {
      'en':
          '• Encrypted progress tracking\n• Personalized learning paths\n• Data deletion available on request\n• Regular backup options',
      'ar': '',
    },
    'dlw1zodk': {
      'en': 'Contributing New Signs',
      'ar': '',
    },
    'fqbkxj36': {
      'en': 'User Submissions',
      'ar': '',
    },
    'ekr6hejb': {
      'en':
          '• Secure storage of contributed content\n• Educational use only\n• User attribution optional\n• Deletion rights preserved',
      'ar': '',
    },
    'we2e0z3e': {
      'en': 'Content Usage',
      'ar': '',
    },
    'enzrpmab': {
      'en':
          '• Community benefit focus\n• Quality review process\n• Clear usage guidelines\n• User acknowledgment options',
      'ar': '',
    },
    '1anq3rzf': {
      'en': 'Community Services Access',
      'ar': '',
    },
    'vdk1olat': {
      'en': 'Public Information',
      'ar': '',
    },
    'kipe2y3z': {
      'en':
          '• No personal data required for browsing\n• Optional location services\n• Anonymous access supported\n• Community resource directory',
      'ar': '',
    },
    'njjgl5ba': {
      'en': 'Your Rights & Controls',
      'ar': '',
    },
    'ihlvklew': {
      'en': 'You have the right to:',
      'ar': '',
    },
    '5f6yv15g': {
      'en':
          '• Request account deletion\n• Access your personal data\n• Modify permissions\n• Export your data\n• Opt-out of features',
      'ar': '',
    },
  },
  // NotVerified
  {
    '03h914bb': {
      'en': 'Email Not Verified',
      'ar': 'البريد الإلكتروني غير محقق',
    },
    '6cutd865': {
      'en':
          'Please check your email to verify your account. Don\'t forget to check your spam folder if you can\'t find the verification email.',
      'ar':
          'يرجى التحقق من بريدك الإلكتروني للتحقق من حسابك. لا تنس التحقق من مجلد البريد العشوائي إذا لم تتمكن من العثور على رسالة التحقق.',
    },
    '20xvoqba': {
      'en': 'Resend Verification Email',
      'ar': 'إعادة إرسال بريد إلكتروني للتحقق',
    },
  },
  // dark
  {
    'teitmxf5': {
      'en': 'Light Mode',
      'ar': 'وضع الضوء',
    },
    'sl5piaie': {
      'en': 'Dark Mode',
      'ar': 'الوضع المظلم',
    },
  },
  // Miscellaneous
  {
    'fmtvkkni': {
      'en': '',
      'ar': '',
    },
    'uga1nl8z': {
      'en': '',
      'ar': '',
    },
    '1grdfgul': {
      'en': '',
      'ar': '',
    },
    '4fj1t976': {
      'en': '',
      'ar': '',
    },
    '0r58difc': {
      'en': '',
      'ar': '',
    },
    'nuiqekzw': {
      'en': '',
      'ar': '',
    },
    'x7uqoly8': {
      'en': '',
      'ar': '',
    },
    '0ucc8b1f': {
      'en': '',
      'ar': '',
    },
    'lgql7t71': {
      'en': '',
      'ar': '',
    },
    '2li5wz0w': {
      'en': '',
      'ar': '',
    },
    '9gcwur7r': {
      'en': '',
      'ar': '',
    },
    'm7y7r9vd': {
      'en': '',
      'ar': '',
    },
    'gb9ytr6j': {
      'en': '',
      'ar': '',
    },
    '6cdmx1wb': {
      'en': '',
      'ar': '',
    },
    'af5yej5v': {
      'en': '',
      'ar': '',
    },
    'y3pzpjv0': {
      'en': '',
      'ar': '',
    },
    '07rdq25x': {
      'en': '',
      'ar': '',
    },
    'wp9oem1s': {
      'en': '',
      'ar': '',
    },
    'kr6fzdan': {
      'en': '',
      'ar': '',
    },
    '8tpf6c0y': {
      'en': '',
      'ar': '',
    },
    '7aeyuny8': {
      'en': '',
      'ar': '',
    },
    'fw4lcalh': {
      'en': '',
      'ar': '',
    },
    'w7t3r33w': {
      'en': '',
      'ar': '',
    },
    'iqo4ofl4': {
      'en': '',
      'ar': '',
    },
    'pq8qfxcu': {
      'en': '',
      'ar': '',
    },
    'evwz6k5j': {
      'en': '',
      'ar': '',
    },
    'i7ckzu8t': {
      'en': '',
      'ar': '',
    },
    'rcukq7vx': {
      'en': '',
      'ar': '',
    },
  },
].reduce((a, b) => a..addAll(b));
