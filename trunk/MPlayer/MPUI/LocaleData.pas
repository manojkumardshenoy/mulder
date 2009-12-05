// GENERATED FILE. DO NOT EDIT.
unit LocaleData;
interface
uses Windows, Graphics, Locale, Main, About, Options, plist, Log, Help, Info;
const LocaleCount=23;
const StringCount=124;
const FallbackLocale=6;
procedure ApplyLocaleStrings;
const StringNames:string=
'@name'#0'*Title'#0'*Status_Opening'#0'*Status_Closing'#0'*Status_Playing'#0'*Status_Paused'#0'*Status_'+
'Stopped'#0'*Status_Error'#0'Main:BPlaylist.Hint'#0'Main:BStreamInfo.Hint'#0'Main:BFullscreen.Hin'+
't'#0'Main:BCompact.Hint'#0'Main:BMute.Hint'#0'Main:MPFullscreenControls*'#0'Main:OSDMenu*'#0'Main:M'+
'NoOSD*'#0'Main:MDefaultOSD*'#0'Main:MTimeOSD*'#0'Main:MFullOSD*'#0'Main:LEscape*'#0'Main:MFile*'#0'Mai'+
'n:MOpenFile*'#0'Main:MOpenURL*'#0'*OpenURL_Caption'#0'*OpenURL_Prompt'#0'Main:MOpenDrive*'#0'Main:M'+
'Close*'#0'Main:MQuit*'#0'Main:MView*'#0'Main:MSizeAny*'#0'Main:MSize50*'#0'Main:MSize100*'#0'Main:MSiz'+
'e200*'#0'Main:MFullscreen*'#0'Main:MCompact*'#0'Main:MOSD*'#0'Main:MOnTop*'#0'Main:MSeek*'#0'Main:MPla'+
'y*'#0'Main:MPause*'#0'Main:MPrev*'#0'Main:MNext*'#0'Main:MShowPlaylist*'#0'Main:MMute*'#0'Main:MSeekF1'+
'0*'#0'Main:MSeekR10*'#0'Main:MSeekF60*'#0'Main:MSeekR60*'#0'Main:MSeekF600*'#0'Main:MSeekR600*'#0'Main'+
':MExtra*'#0'Main:MAudio*'#0'Main:MSubtitle*'#0'Main:MAspect*'#0'Main:MAutoAspect*'#0'Main:MForce43*'+
#0'Main:MForce169*'#0'Main:MForceCinemascope*'#0'Main:MDeinterlace*'#0'Main:MNoDeint*'#0'Main:MSim'+
'pleDeint*'#0'Main:MAdaptiveDeint*'#0'Main:MOptions*'#0'Main:MLanguage*'#0'Main:MStreamInfo*'#0'Main'+
':MShowOutput*'#0'Main:MHelp*'#0'Main:MKeyHelp*'#0'Main:MAbout*'#0'LogForm*'#0'Log:BClose*'#0'HelpForm*'+
#0'Help:HelpText.Text'#0'Help:BClose*'#0'AboutForm*'#0'About:BClose*'#0'About:LVersionMPUI*'#0'About:'+
'LVersionMPlayer*'#0'OptionsForm*'#0'Options:BOK*'#0'Options:BApply*'#0'Options:BSave*'#0'Options:BC'+
'lose*'#0'Options:LAudioOut*'#0'Options:CAudioOut#0'#0'Options:CAudioOut#1'#0'Options:LAudioDev*'#0+
'Options:LPostproc*'#0'Options:CPostproc#0'#0'Options:CPostproc#1'#0'Options:CPostproc#2'#0'Optio'+
'ns:CLanguage#0'#0'Options:CLanguage#1'#0'Options:CIndex*'#0'Options:CSoftVol*'#0'Options:CPriori'+
'tyBoost*'#0'Options:LParams*'#0'Options:LHelp*'#0'PlaylistForm*'#0'Playlist:BPlay*'#0'Playlist:BAdd'+
'*'#0'Playlist:BMoveUp*'#0'Playlist:BMoveDown*'#0'Playlist:BDelete*'#0'Playlist:CShuffle*'#0'Playlis'+
't:CLoop*'#0'Playlist:BSave*'#0'Playlist:BClose*'#0'InfoForm*'#0'Info:BClose*'#0'*NoInfo'#0'*InfoFileFo'+
'rmat'#0'*InfoPlaybackTime'#0'*InfoTags'#0'*InfoVideo'#0'*InfoAudio'#0'*InfoDecoder'#0'*InfoCodec'#0'*Info'+
'Bitrate'#0'*InfoVideoSize'#0'*InfoVideoFPS'#0'*InfoVideoAspect'#0'*InfoAudioRate'#0'*InfoAudioChann'+
'els'#0;

const Locales:array[0..LocaleCount-1]of TLocale=(
(Name:'ar'; LangID:LANG_ARABIC; SubID:SUBLANG_DEFAULT; Charset:ARABIC_CHARSET; Data:
'العربية'#0'للويندوز MPlayer'#0'جارى الفتح ...'#0'جارى الاغل�'+
'�ق ...'#0'جارى العرض'#0'ايقاف مؤقت'#0'متوقف'#0'غير قادر على ا'+
'لعرض (اضغط لمزيد من المعلومات)'#0'اظهار/اخفاء ناف�'+
'�ة العرض'#0'اظهار/اخفاء معلومات ملف الفيديو'#0'تشغيل'+
' وضعية الشاشة الكاملة'#0'تفعيل الوضعية المضغوطة'#0'�'+
'�فعيل الوضع الصامت'#0'اظهار ازرار التحكم فى الشاش'+
'ة الكاملة'#0'OSD وضعية'#0'OSDبدون'#0'الافتراضى OSD'#0'اظهار ال�'+
'�من'#0'اظهار الزمن الكلى'#0'اضغط زر اسك للخروج من وضع'+
'ية الشاشة الكاملة'#0'ملف'#0'عرض ملف'#0'فتح عنوان ويب ...'#0'�'+
'�رض عنوان ويب'#0'ما عنوان الانترنت الذى تريد عرضه�'+
'�'#0'عرض CD/DVD'#0'اغلاق'#0'خروج'#0'مظهر'#0'حجم معرف'#0'نصف الحجم'#0'ال�'+
'�جم الاصلى'#0'الحجم مضاعف'#0'الشاشة كلها'#0'الوضعية الم'+
'ضغوطة'#0'تفعيل OSD'#0'دائما على القمة'#0'عرض'#0'عرض'#0'وقف مؤقت'+
#0'Previous title'#0'Next title'#0'لائحة العرض ...'#0'صامت'#0'تقدم عشر ثوا'+
'ن'^I'Right'#0'رجوع عشر ثوان'^I'Left'#0'تقدم دقيقة واحدة'^I'Up'#0'رجوع'+
' دقيقة واحدة'^I'Down'#0'تقدم عشر دقائق'^I'PgUp'#0'رجوع عشر دقا'+
'ئق'^I'PgDn'#0'أدوات'#0'تراك الصوت'#0'تراك الترجمة'#0'نسبة المظ�'+
'�ر'#0'كشف تلقائى'#0'اجبار 4:3'#0'اجبار 16:9'#0'اجبار 2.35:1'#0'Deinterlace'+
#0'مغلق'#0'بسيط'#0'متكيف'#0'خيارات ...'#0'اللغة'#0'اظهار معلومات '+
'الكليب ...'#0'اظهار خرج امبلاير'#0'مساعدة'#0'مساعدة لوحة'+
' المفاتيح ...'#0'عن ...'#0'MPlayer خرج'#0'غلق'#0'مساعدة لوحة المف�'+
'�تيح'#0'مفاتيح الملاحة:'^M^J'Space'^I'عرض/وقف'^M^J'Right'^I'تقدم عشر �'+
'�وان'^M^J'Left'^I'عودة عشر ثوان'^M^J'Up'^I'تقدم دقيقة واحدة'^M^J'Down'^I'�'+
'�ودة دقيقة واحدة'^M^J'PgUp'^I'تقدم عشر دقائق'^M^J'PgDn'^I'عودة عش'+
'ر دقائق'^M^J'مفاتيح اخرى:'^M^J'O'^I'تفعيل OSD'^M^J'F'^I'تفعيل الشاشة'+
' الكاملة'^M^J'C'^I'تفعيل الوضعية المنضغطة'^M^J'T'^I'تفعيل دائ'+
'ما على الاعلى'^M^J'Q'^I'الخروج حالا'^M^J'9/0'^I'تعديل الصوت'^M^J'-/+\'+
'tAdjust audio/video sync'^M^J'1/2'^I'تعديل درجة فتاحية اللون'^M^J'3/4'^I'ت�'+
'�ديل contrast'^M^J'5/6'^I'تعديل hue'^M^J'7/8'^I'تعديل saturation'#0'غلق'#0'عن MPUI'#0'�'+
'�لق'#0'MPUI نسخة:'#0'MPlayerنسخة صميم:'#0'خيارات'#0'نعم'#0'تنفيذ'#0'حفظ'+
#0'غلق'#0'مشغل مخرج الصوت'#0'(لا تفك شفرة الصوت)'#0'(لا تقم '+
'بتشغيل الصوت)'#0'DirectSound جهاز تخريج'#0'بعد المعالجة'#0'م�'+
'�فأ'#0'تلقائى'#0'الكفاءة القصوى'#0'(اختيار تلقائى)'#0#0'اعاد'+
'ة بناء فهرس الملف فى حالة الضرورة'#0'Software volume control'+
' / Volume boost'#0'تشغيل باأولوية عالية'#0'اوامر امبلاير ا�'+
'�افية:'#0'مساعدة'#0'لائحة العرض'#0'عرض'#0'اضف ...'#0'انقل للأعل�'+
'�'#0'انقل للأسفل'#0'ازالة'#0'عشوائى'#0'اعادة'#0'حفظ ...'#0'غلق'#0'معل�'+
'�مات الكليب'#0'غلق'#0'لا توجد معلومات عن الكليب حالي�'+
'�.'#0'النوعية'#0'المدة'#0'معلومات الكليب الاولية'#0'تراك ا�'+
'�صورة'#0'تراك الصوت'#0'مفكك الشفرة'#0'التشفير'#0'معدل الكس'+
'رة'#0'الابعاد'#0'معدل الاطار'#0'نسبة المظهر'#0'معدل العين�'+
'�'#0'القنوات'#0),

(Name:'bg'; LangID:LANG_BULGARIAN; SubID:SUBLANG_DEFAULT; Charset:RUSSIAN_CHARSET; Data:
'Bulgarian'#0'MPlayer за Windows'#0#0#0#0#0#0#0#0#0'На цял екран'#0#0#0#0'Настройки '+
'на OSD стил'#0'Без OSD'#0'OSD по подразбиране'#0'Покажи врем'+
'етраенето'#0'Покажи пълното времетраене'#0#0'Файл'#0'От'+
'вори файл ...'#0'Отвори URL ...'#0'Отвори URL'#0'Кое URL желает�'+
'� да отворите?'#0'Отвори CD/DVD'#0'Затвори'#0'Изход'^I'Q'#0'Изгле'+
'д'#0'Потребителски размер'#0'Размер на половин�'#0'Ори�'+
'�инален размер'#0'Двоен размер'#0'На цял екран'^I'F'#0#0'Раз'+
'реши OSD'^I'O'#0'Винаги най-отгоре'#0'Навигация'#0'Старт'#0'Па�'+
'�з�'#0#0#0#0#0'Напред с 10 секунди'^I'Right'#0'Назад с 10 секунди'^I'L'+
'eft'#0'Напред с 1 минута'^I'Up'#0'Назад с 1 минута'^I'Down'#0'Напре'+
'д с 10 минути'^I'PgUp'#0'Назад с 10 минути'^I'PgDn'#0'Настройки'#0'�'+
'�ву�'#0'Субтитри'#0'Размер на изображението'#0'Автомат�'+
'�чно'#0'Размер 4:3'#0'Размер 16:9'#0'Размер 2.35:1'#0'Деинтерлей�'+
'�'#0'Изключено'#0'Стандартно'#0'Адаптивно'#0'Настройки ...'#0+
'Ези�'#0#0'Покажи резултата от MPlayer'#0'Помощ'#0'Помощ за к�'+
'�авиатурата ...'#0'Относно ...'#0'MPlayer репорт'#0'Затвори'#0'П�'+
'�мощ за клавиатурат�'#0'Клавиши за навигация:'^M^J'Space\'+
'tСтарт/Пауза'^M^J'Right'^I'Напред с 10 секунди'^M^J'Left'^I'Назад �'+
'� 10 секунди'^M^J'Up'^I'Напред с 1 минута'^M^J'Down'^I'Назад с 1 ми�'+
'�ута'^M^J'PgUp'^I'Напред с 10 минути'^M^J'PgDn'^I'Назад с 10 минути\'+
'n'^M^J'Други клавиши:'^M^J'O'^I'Разреши OSD'^M^J'F'^I'На цял екран'^M^J'Q'^I+
'Изход'^M^J'9/0'^I'Намали/увеличи звука'^M^J'-/+'^I'Коригиране �'+
'�а аудио/видео синхронизация'^M^J'1/2'^I'Коригиране на'+
' осветеност'^M^J'3/4'^I'Коригиране на контраст'^M^J'5/6'^I'Кор�'+
'�гиране на цветовете'^M^J'7/8'^I'Коригиране на наситен'+
'ост'#0'Затвори'#0'Относно MPUI'#0'Затвори'#0'Версия на MPUI:'#0'В�'+
'�рсия на ядрото на MPlayer:'#0'Настройки'#0'ДА'#0'Приеми'#0'За�'+
'�амети'#0'Затвори'#0'Драйвер за звук�'#0'(не декодирай з'+
'вука)'#0'(изключи звука)'#0#0'Последваща обработк�'#0'Изк'+
'лючено'#0'Автоматично'#0'Най-добро качество'#0'(автома'+
'тично)'#0#0'Пресъздай файловия индекс, ако е необх�'+
'�димо'#0#0#0'Допълнителни параметри към MPlayer:'#0'Помощ'#0#0+
#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0),

(Name:'by'; LangID:LANG_BELARUSIAN; SubID:SUBLANG_DEFAULT; Charset:RUSSIAN_CHARSET; Data:
'Belarusian'#0'MPlayer for Windows'#0'Адчыненне ...'#0'Зачыненне ...'#0'Пра�'+
'�граванне...'#0'Прыпынены'#0'Стоп'#0'Немагчыма прайграц'+
'ь файл (Націскніце, каб атрымаць больш інфарма'+
'цыі)'#0'Адлюстраваць\схаваць спіс файлаў'#0'Адлюстр'+
'аваць\схаваць інфармацыю пра файл'#0'Перайсці ў �'+
'�оўнаэкранны рэжым'#0#0#0#0'Усталяваць рэжым OSD'#0'Без OSD'+
#0'Дэфолтавае OSD'#0'Адлюстроўваць пазіцыю'#0'Адлюстро'+
'ўваць пазіцыю\працягласць'#0'Націскніце Escape, каб'+
' выйсці з поўнаэкраннага рэжыма'#0'Файл'#0'Адчыніць'+
' файл ...'#0'Адчыніць URL ...'#0'Адчыніць URL'#0'Увядзіце жад�'+
'�емы URL'#0'Прайграць CD/DVD'#0'Зачыніць'#0'Выхад'#0'Выгляд'#0'Ад�'+
'�ольны памер'#0'1/2 памера'#0'Арыгінальны памер'#0'Падво'+
'ены памер'#0'Поўнаэкранный рэжым'#0'Кампактны'#0'Пера�'+
'�лючыць OSD'#0'Заўсёды зверху'#0'Прайграванне'#0'Прайгр�'+
'�ваць'#0'Прыпыніць'#0'Папярэдні трэк'#0'Наступны трэк'#0'�'+
'�піс файлаў ...'#0'Выключыць гук'#0'Наперад на 10 секун'+
'д'^I'Right'#0'Назад на 10 секунд'^I'Left'#0'Наперад на 1 хвіліну'+
^I'Up'#0'Назад на 1 хвіліну'^I'Down'#0'Наперад на 10 хвілін'^I'PgU'+
'p'#0'Назад на 10 хвілін'^I'PgDn'#0'Налады'#0'Аудыётрэк'#0'Субтыт'+
'ры'#0'Суадносіны старон'#0'Аўтавызначэнне'#0'4:3'#0'16:9'#0'2.35:1'#0+
'Дэінтэрлэйс'#0'Выключыць'#0'Просты'#0'Адаптыўны'#0'Опцыі'+
' ...'#0'Мова'#0'Адлюстраваць інфармацыю пра файл ...'#0'Ад'+
'люстроўваць вывад MPlayer'#0'Дапамога'#0'Дапамога па к�'+
'�авіятуры ...'#0'Пра праграму ...'#0'Вывад MPlayer'#0'Зачыніц�'+
'�'#0'Дапамога па клавіятуры'#0'Клавішы навігацыі:'^M^J'П�'+
'�абел'^I'Прайграваць/паўза'^M^J'Управа'^I'Уперад на 10 с�'+
'�кунд'^M^J'Улева'^I'Назад на 10 секунд'^M^J'Уверх'^I'Уперад н�'+
'� 1 хвіліну'^M^J'Уніз'^I'Назад на 1 хвіліну'^M^J'PgUp'^I'Уперад �'+
'�а 10 хвілін'^M^J'PgDn'^I'Назад на 10 хвілін'^M^J^M^J'Іншыя клаві�'+
'�ы:'^M^J'O'^I'Пераключыць OSD'^M^J'F'^I'Переключыць поўнаэкран�'+
'�ы рэжым'^M^J'Q'^I'Выйсці тэрмінова'^M^J'9/0'^I'Наладзіць гучн'+
'асць'^M^J'-/+'^I'Наладзіць аўдыё\відыё сінхранізацыю'^M^J+
'1/2'^I'Наладзіць яркасць'^M^J'3/4'^I'Наладзіць кантраст'^M^J'5/'+
'6'^I'Наладзіць гамму'^M^J'7/8'^I'Наладзіць цветавую насы�'+
'�анасць'#0'Зачыніць'#0'Пра MPUI'#0'Зачыніць'#0'Версія MPUI:'#0'Ве�'+
'�сія MPlayer:'#0'Опцыі'#0'OK'#0'Прымяніць'#0'Захаваць'#0'Зачыніць'#0+
'Драйвер вывада гука'#0'(Не дэкадаваць гук)'#0'(Не пра'+
'йграваць гук)'#0'Прылада DirectSound'#0'Постпрацэсс'#0'Адкл�'+
'�чаны'#0'Аўтаматычны'#0'Найлепшы'#0'(Аўтавызначэнне)'#0#0'П'+
'ерабудаваць табліцу індэксаў AVI, калі неабход�'+
'�а'#0'Праграмная рэгуліроўка гуку'#0'Выконваць з бо�'+
'�ьшым прыарытэтам'#0'Дадатковыя параметры MPlayer:'#0'Д'+
'апамога'#0'Спіс файлаў'#0'Прайграць'#0'Дадаць ...'#0'Уверх'#0+
'Уніз'#0'Выдаліць'#0'Выбіраць адвольны трэк'#0'Паўтара�'+
'�ь'#0'Захаваць ...'#0'Зачыніць'#0'Інфармацыя пра файл'#0'За�'+
'�ыніць'#0'На гэты час няма ніякай інфармацыі пра �'+
'�айл.'#0'Фармат'#0'Працягласць'#0'Метададзеныя файла'#0'В�'+
'�дыётрэк'#0'Аудыётрэк'#0'Дэкодэр'#0'Кодэк'#0'Бітрэйт'#0'Паме'+
'ры'#0'Колькасць кадраў у секунду'#0'Суадносіны стар'+
'он'#0'Якасць сэмпліравання'#0'Колькасць каналаў'#0),

(Name:'cz'; LangID:LANG_CZECH; SubID:SUBLANG_DEFAULT; Charset:EASTEUROPE_CHARSET; Data:
'Cesky'#0'MPlayer pro Windows'#0#0#0#0#0#0#0#0#0'Celá obrazovka'#0#0#0#0'Nastavit OSD Mód'#0'Žádný OSD'#0+
'Standardní OSD'#0'Zobraz odehraný čas'#0'Zobraz celkový čas'#0#0'Soubor'#0'Otevřít ...'#0'Ote'+
'vřít URL ...'#0'Otevřít URL'#0'Zadejte URL, která má být otevřena'#0'Otevřít disk C'+
'D/DVD'#0'Zavřít'#0'Ukončit'#0'Zobrazit'#0'Vlastní velikost'#0'Poloviční velikost'#0'Originální'+
' velikost'#0'Dvojnásobná velikost'#0'Celá obrazovka'#0#0'Přepnout OSD'#0'Vždy nahoře'#0'Přehr'+
'át'#0'Přehrávat'#0'Pozastavit'#0#0#0#0#0'O 10 sekund vpřed'^I'Šipka vpravo'#0'O 10 sekund zpět'^I+
'Šipka vlevo'#0'O 1 minutu vpřed'^I'Šipka nahoru'#0'O 1 minutu zpět'^I'Šipka dolů'#0'O 10 mi'+
'nut vpřed'^I'PgUp'#0'O 10 minut zpět'^I'PgDn'#0'Nastavení'#0'Zvuková stopa'#0'Stopa titulků'#0'For'+
'mát obrazu'#0'Automatický'#0'Vždy 4:3'#0'Vždy 16:9'#0'Vždy 2.35:1'#0'Deinterlacing'#0'Vypnuto'#0'Jed'+
'noduché'#0'Adaptivní'#0'Nastavení ...'#0'Jazyk'#0#0'Zobraz konzoli MPlayeru'#0'Nápověda'#0'Kláves'+
'ové zkratky ...'#0'O programu ...'#0'Výstup Mplayeru'#0'Zavřít'#0'Klávesové zkratky'#0'Naviga'+
'ční klávesy:'^M^J'Mezerník'^I'Přehrávat/Pozastavit'^M^J'Šipka vpravo'^I'O 10 sekund vpře'+
'd'^M^J'Šipka vlevo'^I'O 10 sekund zpět'^M^J'Šipka nahoru'^I'O 1 minutu vpřed'^M^J'Šipka dolů'^I+
'O 1 minutu zpět'^M^J'PgUp'^I'O deset minut vpřed'^M^J'PgDn'^I'O deset minut zpět'^M^J^M^J'Jiné kl�'+
'�vesy:'^M^J'O'^I'Přepnout OSD'^M^J'F'^I'Celá obrazovka'^M^J'Q'^I'Ukončení programu'^M^J'9/0'^I'Nastaven�'+
'� hlasitosti'^M^J'-/+'^I'Nastavení Audio/Video Synchronizace'^M^J'1/2'^I'Nastavení jasu'^M^J'3/4'^I+
'Nastavení kontrastu'^M^J'5/6'^I'Nastavení barev'^M^J'7/8'^I'Nastavení sytosti'#0'Zavřít'#0'O prog'+
'ramu MPUI'#0'Zavřít'#0'Verze MPUI:'#0'Verze Mplayeru:'#0'Nastavení'#0'OK'#0'Použít'#0'Uložit'#0'Zavř�'+
'�t'#0'Výstupní ovladač zvuku'#0'(nedekódovat zvuk)'#0'(nepřehrávat zvuk)'#0#0'Postprocessin'+
'g'#0'Vypnuto'#0'Automatické'#0'Maximální kvalita'#0'Automatický výběr'#0#0'Zrekonstruování i'+
'ndexu souboru, pokud je to nezbytné'#0#0#0'Dodatkové parametry MPlayeru:'#0'Nápověda'#0#0#0#0+
#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0),

(Name:'de'; LangID:LANG_GERMAN; SubID:SUBLANG_DEFAULT; Charset:DEFAULT_CHARSET; Data:
'Deutsch'#0'MPlayer für Windows'#0'Öffne ...'#0'Schließe ...'#0'Wiedergabe'#0'Angehalten'#0'Abgebroc'+
'hen'#0'Abspielen fehlgeschlagen (Klicken für weitere Informationen)'#0'Wiedergabeliste an'+
'zeigen/verbergen'#0'Clip-Informationen anzeigen/verbergen'#0'Vollbildmodus ein/ausschalten'+
#0'Kompakte Darstellung ein/ausschalten'#0'Stummschaltung ein/aus'#0'Steuerelemente im Vollb'+
'ildmodus anzeigen'#0'OSD-Modus'#0'Kein OSD'#0'Standard-OSD'#0'Zeitanzeige'#0'Gesamtzeitanzeige'#0'Esc '+
'drücken, um den Vollbildmodus zu verlassen'#0'Datei'#0'Datei abspielen ...'#0'URL abspielen '+
'...'#0'URL abspielen'#0'Welche URL soll abgespielt werden?'#0'CD/DVD abspielen'#0'Schließen'#0'Bee'+
'nden'#0'Ansicht'#0'Beliebige Größe'#0'Halbe Größe'#0'Originalgröße'#0'Doppelte Größe'#0'Vollbi'+
'ldmodus'#0'Kompakte Darstellung'#0'OSD umschalten'#0'Immer im Vordergrund'#0'Wiedergabe'#0'Abspiele'+
'n'#0'Pause'#0'Voriger Titel'#0'Nächster Titel'#0'Wiedergabeliste ...'#0'Stumm'#0'10 Sekunden vorwärt'+
's'^I'Rechts'#0'10 Sekunden zurück'^I'Links'#0'1 Minute vorwärts'^I'Oben'#0'1 Minute zurück'^I'Unte'+
'n'#0'10 Minuten vorwärts'^I'BildAuf'#0'10 Minuten zurück'^I'BildAb'#0'Extras'#0'Tonspur'#0'Untertitel'+
'spur'#0'Seitenverhältnis'#0'Automatisch'#0'Immer 4:3'#0'Immer 16:9'#0'Immer 2.35:1'#0'Deinterlacing'#0'A'+
'us'#0'Einfach'#0'Adaptiv'#0'Optionen ...'#0'Sprache'#0'Clip-Informationen anzeigen ...'#0'MPlayer-Ausg'+
'abe anzeigen ...'#0'Hilfe'#0'Tastaturhilfe ...'#0'Über ...'#0'MPlayer-Ausgabe'#0'Schließen'#0'Tastat'+
'urhilfe'#0'Navigationstasten:'^M^J'Leertaste'^I'Abspielen/Pause'^M^J'Rechts'^I'10 Sekunden vorwärt'+
's'^M^J'Links'^I'10 Sekunden zurück'^M^J'Oben'^I'1 Minute vorwärts'^M^J'Unten'^I'1 Minute zurück'^M^J'Bi'+
'ldAuf'^I'10 Minuten vorwärts'^M^J'BildAb'^I'10 Minuten zurück'^M^J^M^J'Sonstige Tasten:'^M^J'O'^I'OSD '+
'umschalten'^M^J'F'^I'Vollbildmodus ein/aus'^M^J'C'^I'Kompakte Darstellung ein/aus'^M^J'T'^I'Immer im V'+
'ordergrund ein/aus'^M^J'Q'^I'Sofort beenden'^M^J'9/0'^I'Lautstärke einstellen'^M^J'-/+'^I'Bild/Ton-Sy'+
'nchronisation einstellen'^M^J'1/2'^I'Helligkeit einstellen'^M^J'3/4'^I'Kontrast einstellen'^M^J'5/6\'+
'tFarbton einstellen'^M^J'7/8'^I'Sättigung einstellen'#0'Schließen'#0'Über MPUI'#0'Schließen'#0'MPU'+
'I-Version:'#0'MPlayer-Version:'#0'Optionen'#0'OK'#0'Übernehmen'#0'Speichern'#0'Schließen'#0'Soundausgab'+
'etreiber'#0'(keinen Sound decodieren)'#0'(keinen Sound ausgeben)'#0'DirectSound-Ausgabegerät'+
#0'Postprocessing'#0'Aus'#0'Automatisch'#0'Maximale Qualität'#0'(Automatisch)'#0#0'Dateiindex rekonst'+
'ruieren, wenn notwendig'#0'Software-Lautstärkereglung (ermöglicht höhere Lautstärke'+
')'#0'Höhere Priorität'#0'Zusätzliche MPlayer-Parameter:'#0'Hilfe'#0'Wiedergabeliste'#0'Abspielen'+
#0'Hinzufügen ...'#0'Nach oben'#0'Nach unten'#0'Entfernen'#0'Zufall'#0'Wiederholen'#0'Speichern ...'#0'Sch'+
'ließen'#0'Clip-Informationen'#0'Schließen'#0'Zur Zeit sind keine Informationen verfügbar.'#0+
'Format'#0'Abspieldauer'#0'Metadaten'#0'Videospur'#0'Tonspur'#0'Decoder'#0'Codec'#0'Bitrate'#0'Bildgröße'#0'Fr'+
'amerate'#0'Seitenverhältnis'#0'Samplerate'#0'Kanäle'#0),

(Name:'dk'; LangID:LANG_ENGLISH; SubID:SUBLANG_DEFAULT; Charset:ANSI_CHARSET; Data:
'Dansk'#0'MPlayer til Windows'#0'Åbner ...'#0'Lukker ...'#0'Spiller'#0'Pauset'#0'Stoppet'#0'Kan ikke afsp'+
'ille media  (klik for mere info)'#0'Vis/skjul spilleliste vindue'#0'Vis/skjul klip informa'+
'tion'#0'Skift fuldskærms mode'#0'Kompakt mode til/fra'#0'Lydløs til/fra'#0'Vis fuldskærms con'+
'trols'#0'OSD mode'#0'Ingen OSD'#0'Normal OSD'#0'Vis tid'#0'Vis sammenlagt tid'#0'Tryk Escape for at af'+
'slutte fuldskærms mode.'#0'Filer'#0'Afspil fil ...'#0'Afspil Internetadresse ...'#0'Afspil Inte'+
'rnetadresse'#0'Hvilken Internetadresse vil du gerne afspille?'#0'Afspil CD/DVD'#0'Luk'#0'Afslut'#0+
'Vis'#0'Normal størrelse'#0'Halv størrelse'#0'Original størrelse'#0'Dobbelt størrelse'#0'Fuldsk�'+
'�rm'#0'Kompakt mode'#0'Skift OSD'#0'Altid på toppen'#0'Afspil'#0'Afspil'#0'Pause'#0'Forrige titel'#0'Næste'+
' titel'#0'Afspilningsliste ...'#0'Lydløs'#0'Spol 10 sekunder fremad'^I'højre'#0'Spol 10 Sekunder'+
' tilbage'^I'Venstre'#0'Spol 1 minut fremad'^I'Op'#0'Spol 1 minut tilbage'^I'Ned'#0'Spol 10 minutter'+
' fremad'^I'PgUp'#0'Spol 10 minutter tilbage'^I'PgDn'#0'Værktøjer'#0'Lydspor'#0'Undertextspor'#0'Aspek'+
't Forhold'#0'Opfang Automatisk'#0'Tving 4:3'#0'Tving 16:9'#0'Tving 2.35:1'#0'Fjern Interfacet'#0'Slåe'+
't fra'#0'Simpel'#0'Tilpasselig'#0'Funktioner ...'#0'Sprog'#0'Vis Klip information ...'#0'Vis MPlayer u'+
'dlæsning ...'#0'Hjælp'#0'Tastaturhjælp ...'#0'Om ...'#0'MPlayer udlæsning'#0'Luk'#0'Tastaturhjælp'+
#0'Navigationstast:'^M^J'Mellemrum'^I'Afspil/pause'^M^J'Højre'^I'Spol 10 sekunder fremad'^M^J'Venstre'+
^I'Spol 10 sekunder tilbage'^M^J'Op'^I'Spol 1 minut fremad'^M^J'Ned'^I'Spol 1 minut tilbage'^M^J'PgUp'+
^I'Spol 10 minutter fremad'^M^J'PgDn'^I'Spol 10 minutter Tilbage'^M^J^M^J'Andre taster:'^M^J'O'^I'OSD'^M^J+
'F'^I'Fuldskærm til/fra'^M^J'C'^I'Kompakt mode til/fra'^M^J'T'^I'Altid på toppen til/fra'^M^J'Q'^I'Afsl'+
'ut med det samme'^M^J'9/0'^I'Tilpas lydstyrke'^M^J'-/+'^I'Tilpas lyd/video sync'^M^J'1/2'^I'Tilpas lys'+
'styrke'^M^J'3/4'^I'Tilpas kontrast'^M^J'5/6'^I'Tilpas farve'^M^J'7/8'^I'Tilpas mætning'#0'Luk'#0'Om MPUI'#0'Lu'+
'k'#0'MPUI version:'#0'MPlayer kerne version:'#0'Funktioner'#0'OK'#0'Tilføj'#0'Gem'#0'Luk'#0'Lydudlæsnings '+
'driver'#0'(Lad være med at afkode lyd)'#0'(Lad være med at afspille lyd)'#0'DirectSound udl'+
'æsnings apparat'#0'Efterprocessering'#0'Slået fra'#0'Automatisk'#0'Maksimal kvalitet'#0'(Vælg Au'+
'tomatisk)'#0#0'Genopbyg filindekset hvis det er nødvendigt'#0'Software lydstyrke kontrol /'+
' Forstærk lydstyrken'#0'Kør med højere prioritet'#0'Flere MPlayer parametre:'#0'Hjælp'#0'Spi'+
'lleliste'#0'Afspil'#0'Tilføj ...'#0'Flyt op'#0'Flyt ned'#0'Fjern'#0'Bland'#0'Gentag'#0'Gem ...'#0'Luk'#0'Klip inf'+
'ormation'#0'Luk'#0'Ingen klip information er tilgængelig i øjeblikket.'#0'Format'#0'Varighed'#0'K'+
'lip Metadata'#0'Videospor'#0'Lydspor'#0'Afkoder'#0'Codec'#0'Bithastighed'#0'Dimensioner'#0'Formhastighed'#0+
'Aspekt Forhold'#0'Prøvehastighed'#0'Kanaler'#0),

(Name:'en'; LangID:LANG_ENGLISH; SubID:SUBLANG_DEFAULT; Charset:ANSI_CHARSET; Data:
'English'#0'MPlayer for Windows'#0'Opening ...'#0'Closing ...'#0'Playing'#0'Paused'#0'Stopped'#0'Unable to'+
' play media (Click for more info)'#0'Show/hide playlist window'#0'Show/hide clip informati'+
'on'#0'Toggle fullscreen mode'#0'Toggle compact mode'#0'Toggle Mute'#0'Show fullscreen controls'#0'O'+
'SD mode'#0'No OSD'#0'Default OSD'#0'Show time'#0'Show total time'#0'Press Escape to exit fullscreen'+
' mode.'#0'File'#0'Play file ...'#0'Play URL ...'#0'Play URL'#0'Which URL do you want to play?'#0'Play '+
'CD/DVD'#0'Close'#0'Quit'#0'View'#0'Custom size'#0'Half size'#0'Original size'#0'Double size'#0'Fullscreen'#0'Co'+
'mpact mode'#0'Toggle OSD'#0'Always on top'#0'Play'#0'Play'#0'Pause'#0'Previous title'#0'Next title'#0'Playli'+
'st ...'#0'Mute'#0'Forward 10 seconds'^I'Right'#0'Rewind 10 seconds'^I'Left'#0'Forward 1 minute'^I'Up'#0'R'+
'ewind 1 minute'^I'Down'#0'Forward 10 minutes'^I'PgUp'#0'Rewind 10 minutes'^I'PgDn'#0'Tools'#0'Audio tr'+
'ack'#0'Subtitle track'#0'Aspect ratio'#0'Autodetect'#0'Force 4:3'#0'Force 16:9'#0'Force 2.35:1'#0'Deinter'+
'lace'#0'Off'#0'Simple'#0'Adaptive'#0'Options ...'#0'Language'#0'Show clip information ...'#0'Show MPlayer'+
' output ...'#0'Help'#0'Keyboard help ...'#0'About ...'#0'MPlayer output'#0'Close'#0'Keyboard help'#0'Navi'+
'gation keys:'^M^J'Space'^I'Play/Pause'^M^J'Right'^I'Forward 10 seconds'^M^J'Left'^I'Rewind 10 seconds\'+
'nUp'^I'Forward 1 minute'^M^J'Down'^I'Rewind 1 minute'^M^J'PgUp'^I'Forward 10 minutes'^M^J'PgDn'^I'Rewind'+
' 10 minutes'^M^J^M^J'Other keys:'^M^J'O'^I'Toggle OSD'^M^J'F'^I'Toggle fullscreen'^M^J'C'^I'Toggle compact m'+
'ode'^M^J'T'^I'Toggle always on top'^M^J'Q'^I'Quit immediately'^M^J'9/0'^I'Adjust volume'^M^J'-/+'^I'Adjust a'+
'udio/video sync'^M^J'1/2'^I'Adjust brightness'^M^J'3/4'^I'Adjust contrast'^M^J'5/6'^I'Adjust hue'^M^J'7/8\'+
'tAdjust saturation'#0'Close'#0'About MPUI'#0'Close'#0'MPUI version:'#0'MPlayer core version:'#0'Option'+
's'#0'OK'#0'Apply'#0'Save'#0'Close'#0'Sound output driver'#0'(don'#39't decode sound)'#0'(don'#39't play sound)'#0'Di'+
'rectSound output device'#0'Postprocessing'#0'Off'#0'Automatic'#0'Maximum quality'#0'(Auto-select)'#0'('+
'External file)'#0'Rebuild file index if necessary'#0'Software volume control / Volume boos'+
't'#0'Run with higher priority'#0'Additional MPlayer parameters:'#0'Help'#0'Playlist'#0'Play'#0'Add ...'+
#0'Move up'#0'Move down'#0'Remove'#0'Shuffle'#0'Repeat'#0'Save ...'#0'Close'#0'Clip information'#0'Close'#0'No cl'+
'ip information is available at the moment.'#0'Format'#0'Duration'#0'Clip Metadata'#0'Video Track'+
#0'Audio Track'#0'Decoder'#0'Codec'#0'Bitrate'#0'Dimensions'#0'Frame Rate'#0'Aspect Ratio'#0'Sample Rate'#0'Ch'+
'annels'#0),

(Name:'eo'; LangID:LANG_NEUTRAL; SubID:SUBLANG_DEFAULT; Charset:TURKISH_CHARSET; Data:
'Esperanto'#0'MPlayer por Vindozo'#0'malfermi ...'#0'fermi ...'#0'ludigo'#0'haltigita'#0'rompita'#0'ludigo'+
' malsukcesis (klaku por pli da informoj)'#0'ludigoliston montri/kaŝi'#0'Clip-informoj mon'+
'tri/kaŝi'#0'tutekrano-moduson enŝalti/elŝalti'#0'kompaktan vidaĵon enŝalti/elŝalti'#0'm'+
'utigon enŝalti/elŝalti'#0'montri direktilojn en la tutekrano-moduso'#0'OSD-moduso'#0'sen OS'+
'D'#0'kutima OSD'#0'tempoindiko'#0'tuttempoindiko'#0'Prenu Esc, for forlasi la tutekrano-moduson'#0+
'dosiero'#0'ludi dosieron ...'#0'ludi adreson ...'#0'ludi adreson'#0'Kiun adreson ekludu?'#0'ludi CD'+
'/DVD'#0'fermi'#0'eliro'#0'vidaĵo'#0'ajna grandeco'#0'duona grandeco'#0'ĝusta grandeco'#0'duopla grandec'+
'o'#0'tutekrano-moduso'#0'kompakta vidaĵo'#0'ŝanĝi OSDn'#0'ĉiam antaŭe'#0'ludigo'#0'ludi'#0'paŭzo'#0'an'+
'taŭa titolo'#0'sekva titolo'#0'ludigolisto ...'#0'muta'#0'dek sekundoj antaŭen'^I'dekstre'#0'dek se'+
'kundoj reen'^I'maldekstre'#0'unu minuto antaŭen'^I'supre'#0'unu minuto reen'^I'sube'#0'dek minutoj'+
' antaŭen'^I'BildoSupren'#0'dek minutoj reen'^I'BildoSuben'#0'aliaĵoj'#0'sonoŝpuro'#0'subtitoloŝp'+
'uro'#0'rilato inter la flankoj'#0'aŭtomata'#0'ĉiam 4:3'#0'ĉiam 16:9'#0'ĉiam 2.35:1'#0'Deinterlacin'+
'g'#0'elŝaltita'#0'simpla'#0'Adaptiv'#0'kalibrigoj ...'#0'lingvo'#0'montri Clip-informojn ...'#0'montri M'+
'Player-indikon ...'#0'helpo'#0'klavarohelpo ...'#0'pri ...'#0'MPlayer-indiko'#0'fermi'#0'klavarohelpo'#0+
'navigada klavoj:'^M^J'spacoklavo'^I'ludi/paŭzo'^M^J'dekstre'^I'dek sekundoj antaŭen'^M^J'maldekstr'+
'es'^I'dek sekundoj reen'^M^J'supre'^I'unu minuto antaŭen'^M^J'sube'^I'unu minuto reen'^M^J'BildoSupre'+
'n'^I'dek minutoj antauen'^M^J'BildSuben'^I'dek minutoj reen'^M^J^M^J'aliaj klavoj:'^M^J'O'^I'ŝanĝi OSD'+
^M^J'F'^I'tutekrano-moduson enŝalti/elŝalti'^M^J'C'^I'kompaktan vidaĵon enŝalti/elŝalti'^M^J'T'+
^I'ĉiam antaŭe enŝalti/elŝalti'^M^J'Q'^I'fermi tuj'^M^J'9/0'^I'reguli sonfortecon'^M^J'-/+'^I'regul'+
'i bildo/sono-sinkronigon'^M^J'1/2'^I'reguli helecon'^M^J'3/4'^I'reguli kontraston'^M^J'5/6'^I'reguli k'+
'olortonon'^M^J'7/8'^I'reguli saturitecon'#0'fermi'#0'pri MPUI'#0'fermi'#0'MPUI-versio:'#0'MPlayer-versio:'+
#0'kalibrigoj'#0'okej'#0'akcepti'#0'konservi'#0'fermi'#0'sonoeligilo'#0'(ne malkodadi sonon)'#0'(ne eligi s'+
'onon)'#0'DirectSound-eligilo'#0'Postprocessing'#0'elŝalti'#0'aŭtomata'#0'plej bona kvalito'#0'(aŭto'+
'mata)'#0#0'rekonstrui dosieran indekson, se estas necesa'#0'softvara sonregulado (ebligas p'+
'li laŭta sono)'#0'pli alta prioritato'#0'pliaj MPlayer-parametro:'#0'helpo'#0'ludigolisto'#0'ludi'#0+
'aldoni ...'#0'supren'#0'suben'#0'forigi'#0#0#0#0'fermi'#0'Clip-informoj'#0'fermi'#0'Ĉitempe informoj ne est'+
'as disponebla.'#0'formato'#0'ludodaŭro'#0'informdataoj'#0'videoŝpuro'#0'sonoŝpuro'#0'malkodadilo'#0'Co'+
'dec'#0'bitkvoto'#0'bildograndeco'#0'framokvoto'#0'rilato inter la flankoj'#0'Samplerate'#0'kanaloj'#0),

(Name:'es'; LangID:LANG_SPANISH; SubID:SUBLANG_DEFAULT; Charset:DEFAULT_CHARSET; Data:
'Español'#0'MPlayer para Windows'#0'Abriendo ...'#0'Cerrando ...'#0'Reproduciendo'#0'Pausa'#0'Detenido'+
#0'Imposible leer medio (Click para más información)'#0'Mostrar/esconder ventana de lis'+
'ta de reproducción'#0#0'Cambiar modo pantalla completa'#0#0#0#0'Establecer modo OSD'#0'Sin OSD'#0'O'+
'SD predefinido'#0'Mostrar tiempo'#0'Mostrar tiempo total'#0'Presione Esc para salir del modo '+
'pantalla completa'#0'Archivo'#0'Reproducir archivo ...'#0'Reproducir URL ...'#0'Reproducir URL'#0'�'+
'�Cuál es el URL a reproducir?'#0'Reproducir CD/DVD'#0'Cerrar'#0'Salir'#0'Ver'#0'Tamaño personaliz'+
'ado'#0'Mitad del tamaño'#0'Tamaño original'#0'Doble del tamaño'#0'Pantalla completa'#0#0'Cambiar '+
'OSD'#0'Siempre visible'#0'Reproducción'#0'Reproducir'#0'Pausar'#0'Título anterior'#0'Título siguien'+
'te'#0'Lista de reproducción ...'#0#0'Avanzar 10 segundos'^I'Derecha'#0'Retroceder 10 segundos'^I+
'Izquierda'#0'Avanzar 1 minuto'^I'Arriba'#0'Retroceder 1 minuto'^I'Abajo'#0'Avanzar 10 minutos'^I'Re'+
'Pág'#0'Retroceder 10 minutos'^I'AvPág'#0'Preferencias'#0'Pista de audio'#0'Pista de subtítulo'#0'F'+
'ormato de imagen'#0'Autodetectar'#0'Forzar 4:3'#0'Forzar 16:9'#0'Forzar 2.35:1'#0'Desentrelazado'#0'De'+
'shabilitado'#0'Simple'#0'Adaptativo'#0'Preferencias ...'#0'Idioma'#0#0'Mostrar mensajes de MPlayer'#0'A'+
'yuda'#0'Ayuda de teclado ...'#0'Acerca de ...'#0'Mensajes de MPlayer'#0'Cerrar'#0'Ayuda de teclado'#0+
'Teclas de navegación:'^M^J'Espacio'^I'Reproducir/Pausar'^M^J'Derecha'^I'Avanzar 10 segundos'^M^J'Iz'+
'quierda'^I'Retroceder 10 segundos'^M^J'Arriba'^I'Avanzar 1 minuto'^M^J'Abajo'^I'Retroceder 1 minut'+
'o'^M^J'RePág'^I'Avanzar 10 minutos'^M^J'AvPág'^I'Retroceder 10 minutos'^M^J^M^J'Otras teclas:'^M^J'O'^I'Ca'+
'mbiar OSD'^M^J'F'^I'Cambiar pantalla completa'^M^J'Q'^I'Salir inmediatamente'^M^J'9/0'^I'Ajustar volum'+
'en'^M^J'-/+'^I'Ajustar sincronización de audio/vídeo'^M^J'1/2'^I'Ajustar brillo'^M^J'3/4'^I'Ajustar '+
'contraste'^M^J'5/6'^I'Ajustar tinta'^M^J'7/8'^I'Ajustar saturación'#0'Cerrar'#0'Acerca de MPUI'#0'Cerrar'+
#0'Versión de MPUI:'#0'Versión de MPlayer:'#0'Preferencias'#0'Aceptar'#0'Aplicar'#0'Guardar'#0'Cerrar'#0+
'Controlador de salida de audio'#0'(no decodificar sonido)'#0'(no reproducir sonido)'#0'Dispos'+
'itivo de salida DirectSound'#0'Post-procesado'#0'Deshabilitado'#0'Automático'#0'Máxima calidad'+
#0'(Auto-selección)'#0#0'Reconstruir índice del archivo si es necesario'#0#0#0'Parámetros MP'+
'layer adicionales:'#0'Ayuda'#0'Lista de reproducción'#0'Reproducir'#0'Agregar ...'#0'Mover arriba'#0+
'Mover abajo'#0'Borrar'#0#0#0#0'Cerrar'#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0),

(Name:'fr'; LangID:LANG_FRENCH; SubID:SUBLANG_DEFAULT; Charset:DEFAULT_CHARSET; Data:
'Français'#0'MPlayer pour Windows'#0'Ouverture ...'#0'Fermeture ...'#0'Joue'#0'Suspendu'#0'Arrêté'#0'In'+
'capable de jouer le média (Cliquer pour plus d'#39'information)'#0'Ouvrir/fermer la liste '+
'd'#39'écoute'#0#0'Basculer en mode plein écran'#0#0#0#0'Choisir le mode OSD'#0'Aucun OSD'#0'OSD par d�'+
'�faud'#0'Afficher le temps'#0'Afficher le temps total'#0'Press Escape to exit fullscreen mode'+
'.'#0'Fichier'#0'Jouer un fichier ...'#0'Jouer un URL ...'#0'Jouer un URL'#0'Quel URL voulez-vous jo'+
'uer?'#0'Jouer un CD/DVD'#0'Fermer'#0'Quitter'#0'Affichage'#0'Dimension sur mesure'#0'Demi taille'#0'Taill'+
'e originale'#0'Double taille'#0'Plein écran'#0#0'Cycler les modes OSD'#0'Toujours sur le dessus'#0+
'Visualisation'#0'Jouer'#0'Suspendre'#0'Titre précédent'#0'Titre suivant'#0'Liste d'#39'écoute ...'#0#0'A'+
'vancer 10 secondes'^I'Droite'#0'Reculer 10 secondes'^I'Gauche'#0'Avancer 1 minute'^I'Haut'#0'Recule'+
'r 1 minute'^I'Bas'#0'Avancer 10 minutes'^I'PgHaut'#0'Reculer 10 minutes'^I'PgBas'#0'Préférences'#0'A'+
'udio'#0'Sous-titres'#0'Format de l'#39'image'#0'Auto-détection'#0'Forcer 4:3'#0'Forcer 16:9'#0'Forcer 2.3'+
'5:1'#0'Dé-entrelacer'#0'Aucun'#0'Simple'#0'Adaptatif'#0'Préférences ...'#0'Langue'#0#0'Afficher la sort'+
'ie de MPlayer'#0'Aide'#0'Aide du clavier ...'#0'À propos ...'#0'Sortie MPlayer'#0'Fermer'#0'Aide du c'+
'lavier'#0'Clefs de navigation:'^M^J'Espace'^I'Jouer/Suspendre'^M^J'Droite'^I'Avancer 10 secondes'^M^J'G'+
'auche'^I'Reculer 10 secondes'^M^J'Haut'^I'Avancer 1 minute'^M^J'Bas'^I'Reculer 1 minute'^M^J'PgHaut'^I'A'+
'vancer 10 minutes'^M^J'PgBas'^I'Reculer 10 minutes'^M^J^M^J'Autre clefs:'^M^J'O'^I'Cycler les modes OS'+
'D'^M^J'F'^I'Basculer en plein écran'^M^J'Q'^I'Quitter immediatement'^M^J'9/0'^I'Ajuster le volume'^M^J'-/'+
'+'^I'Ajuster la sync audio/video'^M^J'1/2'^I'Ajuster la luminosité'^M^J'3/4'^I'Ajuster le contras'+
'te'^M^J'5/6'^I'Ajuster la hue'^M^J'7/8'^I'Ajuster la saturation'#0'Fermer'#0'À propos de MPUI'#0'Fermer'#0+
'MPUI version:'#0'MPlayer version:'#0'Préférences'#0'OK'#0'Appliquer'#0'Sauver'#0'Fermer'#0'Pilote de so'+
'rtie audio'#0'(ne pas décoder le son)'#0'(ne pas jouer le son)'#0'Unité de sortie DirectSou'+
'nd'#0'Post-traitement'#0'Aucun'#0'Automatique'#0'Qualité maximum'#0'(Auto-sélection)'#0#0'Reconstruir'+
'e l'#39'index du fichier au besoin'#0#0#0'Paramètres MPlayer additionnels:'#0'Aide'#0'Liste d'#39'éco'+
'ute'#0'Jouer'#0'Ajouter ...'#0'Monter'#0'Descendre'#0'Enlever'#0#0#0#0'Fermer'#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0),

(Name:'hu'; LangID:LANG_HUNGARIAN; SubID:SUBLANG_DEFAULT; Charset:EASTEUROPE_CHARSET; Data:
'Magyar'#0'MPlayer Windowsra'#0'Megnyitás ...'#0'Bezárás ...'#0'Lejátszás'#0'Szünet'#0'Leállítv'+
'a'#0'Nem lejátszható média (Kattints ide több infoért)'#0'Lejátszási lista ablakán'+
'ak mutatása/elrejtése'#0#0'Teljes képernyõ ki/be'#0#0#0#0'OSD mód beállítása'#0'Nincs OSD'+
#0'Alapértelmezett OSD'#0'Idõ kijelzése'#0'Összes idõ kijelzése'#0'Nyomj Escape-t a telje'+
's képernyõs módból való kilépéshez.'#0'File'#0'File lejátszása ...'#0'URL lejátszá'+
'sa ...'#0'URL lejátszása'#0'A lejátszandó URL'#0'CD/DVD lejátszása'#0'Bezárás'#0'Kilépés'#0+
'Nézet'#0'Más méret'#0'Feleakkora méret'#0'Eredeti méret'#0'Dupla méret'#0'Teljes képernyõ'#0#0+
'OSD ki/be'#0'Mindig látható'#0'Navigáció'#0'Lejátszás'#0'Szünet'#0'Elõzõ cím'#0'Következõ '+
'cím'#0'Lejátszási lista ...'#0#0'Elõre 10 másodpercet'^I'Right'#0'Vissza 10 másodpercet'^I'L'+
'eft'#0'Elõre 1 percet'^I'Up'#0'Vissza 1 percet'^I'Down'#0'Elõre 10 percet'^I'PgUp'#0'Vissza 10 perce'+
't'^I'PgDn'#0'Beállítások'#0'Hangsáv'#0'Felirat'#0'Képarány'#0'Automatikus detektálás'#0'Mindig 4'+
':3'#0'Mindig 16:9'#0'Mindig 2.35:1'#0'Deinterlace'#0'Ki'#0'Egyszerû'#0'Adaptív'#0'Beállítások ...'#0'Ny'+
'elv'#0#0'MPlayer kimenet mutatása'#0'Súgó'#0'Billentyûparancsok ...'#0'Névjegy ...'#0'MPlayer k'+
'imenet'#0'Bezárás'#0'Billentyûparancsok'#0'Navigáló billentyûk:'^M^J'Space'^I'Lejátszás/Sz�'+
'�net'^M^J'Right'^I'Elõre 10 másodpercet'^M^J'Left'^I'Vissza 10 másodpercet'^M^J'Up'^I'Elõre 1 perc'+
'et'^M^J'Down'^I'Vissza 1 percet'^M^J'PgUp'^I'Elõre 10 percet'^M^J'PgDn'^I'Vissza 10 percet'^M^J^M^J'Tovább'+
'i billentyûk:'^M^J'O'^I'OSD ki/be'^M^J'F'^I'Teljes képernyõ ki/be'^M^J'Q'^I'Quit immediately'^M^J'9/0'^I+
'Hangerõ beállítása'^M^J'-/+'^I'Hang/videó szinkron beállítása'^M^J'1/2'^I'Fényesség be'+
'állítása'^M^J'3/4'^I'Kontraszt beállítása'^M^J'5/6'^I'Árnyalat beállítása'^M^J'7/8'^I'Telít'+
'ettség beállítása'#0'Bezárás'#0'Az MPUI névjegye'#0'Bezárás'#0'MPUI verzió:'#0'MPlayer co'+
're verzió:'#0'Beállítások'#0'OK'#0'Alkalmaz'#0'Mentés'#0'Bezárás'#0'Hang kimeneti driver'#0'(nincs'+
' hangdekódolás)'#0'(nincs hanglejátszás)'#0'DirectSound output device'#0'Postprocessing'#0'K'+
'i'#0'Automatikus'#0'Maximális minõség'#0'(Automatikus kiválasztás)'#0#0'File index újraép�'+
'�tése, ha szükséges'#0#0#0'További MPlayer paraméterek:'#0'Súgó'#0'Lejátszási lista'#0'Le'+
'játszás'#0'Hozzáadás ...'#0'Felfelé mozgat'#0'Lefelé mozgat'#0'Eltávolít'#0#0#0#0'Bezár'#0#0#0#0#0#0+
#0#0#0#0#0#0#0#0#0#0#0),

(Name:'it'; LangID:LANG_ITALIAN; SubID:SUBLANG_DEFAULT; Charset:ANSI_CHARSET; Data:
'Italiano'#0'MPlayer for Windows'#0'Aprendo ...'#0'Chiudendo ...'#0'In Apertura'#0'Fermato'#0'Interrott'+
'o'#0'Non in grado di mandare in play (Clicca per maggiori info)'#0'Mostra/Nascondi playlis'+
't'#0'Mostra/Nascondi info su clip'#0'Attiva a tutto schermo'#0'Attiva modalita compatta'#0'Impos'+
'ta muto'#0'Mostra controlli di tutto schermo'#0'OSD'#0'NO OSD'#0'Default OSD'#0'Mostra tempo'#0'Mostra'+
' tempo totale'#0'Premi ESC per uscire da tutto schermo.'#0'File'#0'Apri file ...'#0'Apri URL ...'+
#0'Apri URL'#0'Quale URL vuoi vedere?'#0'Apri CD/DVD'#0'Chiudi'#0'Esci'#0'Guarda'#0'Personalizza Dim.'#0'1/'+
'2 dimensione'#0'1/1 diensione'#0'2X dimensione'#0'Tutto Schermo'#0'Modo compatto'#0'Attiva OSD'#0'In p'+
'rimo piano'#0'Clip'#0'Avvia'#0'Pausa'#0'Titolo precedente'#0'Prossimo titolo'#0'Playlist ...'#0'Muto'#0'Avan'+
'za 10 secondi'^I'Destra'#0'Indietro 10 secondi'^I'Sinistra'#0'Avanza 1 minuto'^I'Su'#0'Indietro 1 m'+
'inuto'^I'Giu'#0'Avanza 10 minuti'^I'PgSu'#0'Indietro 10 minuti'^I'PgGiu'#0'Strumenti'#0'Traccia Audio'#0+
'Traccia Sottotitoli'#0'Aspetto (AR)'#0'Automatico'#0'Forza 4:3'#0'Forza 16:9'#0'Forza 2.35:1'#0'Deinte'+
'rlacciatura'#0'Disattivo'#0'Semplice'#0'Adattivo'#0'Opzioni ...'#0'Linguaggio'#0'Mostra info su clip .'+
'..'#0'Mostra MPlayer info ...'#0'Aiuto'#0'Aiuto Tastiera ...'#0'Circa ...'#0'MPlayer output'#0'Chiudi'#0+
'Aiuto Tastiera'#0'Tasti Navigazione:'^M^J'Spazio'^I'Avvia/Pausa'^M^J'Destra'^I'Avanza 10 secondi'^M^J'S'+
'inistra'^I'Indietro 10 secondi'^M^J'Su'^I'Avanza 1 minuto'^M^J'Giu'^I'Indietro 1 minuto'^M^J'PgSu'^I'Ava'+
'nza 10 minuti'^M^J'PgGiu'^I'Indetro 10 minuti'^M^J^M^J'Altri Tasti:'^M^J'O'^I'Attiva OSD'^M^J'F'^I'Attiva tu'+
'tto schermo'^M^J'C'^I'Attiva modalita compatta'^M^J'T'^I'Attiva in primo piano'^M^J'Q'^I'Esci subito'^M^J+
'9/0'^I'Aggiusta volume'^M^J'-/+'^I'Aggiusta sincro audio/video'^M^J'1/2'^I'Aggiusta luminosita'^M^J'3/'+
'4'^I'Aggiusta contrasto'^M^J'5/6'^I'Aggiusta tono'^M^J'7/8'^I'Aggiusta saturazione'#0'Chiudi'#0'Circa MP'+
'UI'#0'Chiudi'#0'Versione MPUI:'#0'Versione MPlayer:'#0'Opzioni'#0'OK'#0'Applica'#0'Salva'#0'Chiudi'#0'Driver so'+
'noro'#0'(non decodificare audio)'#0'(non fare suoni)'#0'Periferica DirectSound'#0'Postprocessing'+
#0'Disattivo'#0'Automatico'#0'Massima qualita'#0'(automatica)'#0#0'Ricostruisci indice se necessari'+
'o'#0'Controllo Soft. del volume / Alza Volume'#0'Avvia in alta priorita'#0'Parametri addizion'+
'ali per MPlayer:'#0'Aiuto'#0'Playlist'#0'Avvia'#0'Aggiungi ...'#0'Alza'#0'Abbassa'#0'Togli'#0#0#0#0'Chiudi'#0'Info'+
'rmzioni sulla Clip'#0'Chiudi'#0'Nessuna informazione disponibile.'#0'Formato'#0'Durata'#0'Clip Meta'+
'data'#0'Traccia video'#0'Traccia audio'#0'Decoder'#0'Codec'#0'Bitrate'#0'Dimensione'#0'Frame Rate'#0'Aspect '+
'Ratio'#0'Frequenza'#0'Canali'#0),

(Name:'jp'; LangID:LANG_JAPANESE; SubID:SUBLANG_DEFAULT; Charset:SHIFTJIS_CHARSET; Data:
'Japanese'#0'MPlayer for Windows'#0'開く ...'#0'閉じる ...'#0'再生'#0'一時停止'#0'停止'#0'再'+
'生不可能です(クリックで詳細)'#0'再生リストウインドウ 表示/非�'+
'��示'#0'クリップ情報 表示/非表示'#0'全画面モードに切り替え'#0'コン�'+
'�クトモードに切り替え'#0'ミュート'#0'全画面時にコントロールを表'+
'示'#0'OSD モード'#0'OSD なし'#0'デフォルト OSD'#0'時間を表示'#0'総計時間を表�'+
'��'#0'Escキーで全画面を終了.'#0'ファイル'#0'ファイルから再生 ...'#0'URLか�'+
'��再生 ...'#0'URLから再生'#0'どのURLから再生しますか?'#0'CD/DVDから再生'#0'�'+
'��じる'#0'終了'#0'表示'#0'カスタムサイズ'#0'1/2 サイズ'#0'オリジナルサイズ'#0+
'X2 サイズ'#0'全画面'#0'コンパクトモード'#0'OSDの切り替え'#0'常に手前に�'+
'�示'#0'再生'#0'再生'#0'一時停止'#0'前のタイトル'#0'次のタイトル'#0'再生リス�'+
'� ...'#0'ミュート'#0'10 秒早送り'^I'Right'#0'10 秒巻き戻す'^I'Left'#0'1 分早送り'^I'U'+
'p'#0'1 分巻き戻す'^I'Down'#0'10 分早送り'^I'PgUp'#0'10 分巻き戻す'^I'PgDn'#0'ツール'#0'�'+
'��声トラック'#0'字幕トラック'#0'アスペクト比'#0'自動検知'#0'4:3 に強制'#0'1'+
'6:9 に強制'#0'2.35:1 に強制'#0'デインターレース'#0'off'#0'Simple'#0'Adaptive'#0'オプ�'+
'�ョン ...'#0'言語'#0'クリップ情報を表示 ...'#0'MPlayer出力を表示 ...'#0'ヘル'+
'プ'#0'キーボードヘルプ ...'#0'MPUIについて ...'#0'MPlayer出力'#0'閉じる'#0'キー'+
'ボードヘルプ'#0'操作キー:'^M^J'Space'^I'再生/一時停止'^M^J'Right'^I'10 秒早送り'+
^M^J'Left'^I'10 秒巻き戻し'^M^J'Up'^I'1 分早送り'^M^J'Down'^I'1 分巻き戻し'^M^J'PgUp'^I'10 �'+
'�早送り'^M^J'PgDn'^I'10 分巻き戻し'^M^J^M^J'その他のキー:'^M^J'O'^I'切り替え OSD'^M^J'F\'+
't切り替え 全画面'^M^J'C'^I'切り替え コンパクト'^M^J'T'^I'切り替え 前面表�'+
'��'^M^J'Q'^I'直ちに終了'^M^J'9/0'^I'調整 音量'^M^J'-/+'^I'調整 音声/映像の同期'^M^J'1/2\'+
't調整 明るさ'^M^J'3/4'^I'調整 コントラスト'^M^J'5/6'^I'調節 色合い'^M^J'7/8'^I'調�'+
'� 彩度'#0'閉じる'#0'MPUIについて'#0'閉じる'#0'MPUIのバージョン:'#0'MPlayerコア�'+
'��バージョン:'#0'オプション'#0'OK'#0'適用'#0'保存'#0'閉じる'#0'サウンド出力ド�'+
'��イバ'#0'(サウンドをデコードしない)'#0'(サウンドを再生しない)'#0'Dir'+
'ectSound出力デバイス'#0'ポストプロセッシング'#0'オフ'#0'自動'#0'最高品質'+
#0'(自動選択)'#0#0'必要ならファイルのインデックスを再構築'#0'ソフト'+
'ウェア音量調整 / 音量ブースト'#0'起動時に優先度を高める'#0'MPlayer'+
'に追加のパラメータ:'#0'ヘルプ'#0'再生リスト'#0'再生'#0'追加 ...'#0'上に移�'+
'�'#0'下に移動'#0'除去'#0'シャッフル'#0'繰り返し'#0'保存 ...'#0'閉じる'#0'クリップ'+
'情報'#0'閉じる'#0'利用可能なクリップ情報がありません.'#0'形式'#0'合計�'+
'��間'#0'クリップのメタデータ'#0'映像トラック'#0'音声トラック'#0'デコー'+
'ダ'#0'コーデック'#0'ビットレート'#0'サイズ'#0'フレームレート'#0'アスペク�'+
'��比'#0'サンプルレート'#0'チャンネル'#0),

(Name:'kr'; LangID:LANG_KOREAN; SubID:SUBLANG_DEFAULT; Charset:HANGEUL_CHARSET; Data:
'한국어'#0'MPlayer'#0'여는 중 ...'#0'닫는 중 ...'#0'재생'#0'멈춤'#0'중지'#0'미디어 재�'+
'� 불가 (정보 얻기 클릭)'#0'재생목록 보임/숨김'#0'클립정보 보임/숨�'+
'�'#0'전체화면 모드'#0'콤팩트 모드'#0'음소거'#0'전체화면시 콘트롤 보이기'+
#0'OSD 선택'#0'OSD 없음'#0'기본 OSD'#0'시간 나타냄'#0'전체시간 나타냄'#0'전체화�'+
'��을 빠져나가려면 ESC 를 누르세요.'#0'파일'#0'파일 재생 ...'#0'URL 재생 .'+
'..'#0'URL 재생'#0'재생할 URL 을 입력하세요.'#0'CD/DVD 재생'#0'닫기'#0'종료'#0'보기'#0+
'사용자 크기'#0'절반 크기'#0'원래 크기'#0'두배 크기'#0'전체화면'#0'콤팩트 �'+
'�드'#0'OSD 변경'#0'항상 위에'#0'탐색'#0'재생'#0'멈춤'#0'이전 제목'#0'다음 제목'#0'재�'+
'�목록 ...'#0'음소거'#0'앞으로 10초 이동'^I'Right'#0'뒤로 10초 이동'^I'Left'#0'앞으'+
'로 1분 이동'^I'Up'#0'뒤로 1분 이동'^I'Down'#0'앞으로 10분 이동'^I'PgUp'#0'뒤로 10�'+
'�� 이동'^I'PgDn'#0'도구'#0'음성언어선택'#0'자막언어선택'#0'화면비율'#0'자동'#0'4:3'+
' 고정'#0'16:9 고정'#0'2.35:1 고정'#0'잔상제거(Deinterlace)'#0'사용안함'#0'Simple'#0'Adap'+
'tive'#0'옵션 ...'#0'언어'#0'클립 정보 보기 ...'#0'MPlayer 출력 보기 ...'#0'도움말'#0+
'단축키 목록 ...'#0'이 프로그램은 ...'#0'MPlayer 출력'#0'닫기'#0'단축키 목록'#0+
'탐색:'^M^J'Space'^I'재생/멈춤'^M^J'Right'^I'앞으로 10초 이동'^M^J'Left'^I'뒤로 10초 이'+
'동'^M^J'Up'^I'앞으로 1분 이동'^M^J'Down'^I'뒤로 1분 이동'^M^J'PgUp'^I'앞으로 10분 이�'+
'��'^M^J'PgDn'^I'뒤로 10분 이동'^M^J^M^J'그외:'^M^J'O'^I'OSD 전환'^M^J'F'^I'전체화면으로 전�'+
'�'^M^J'C'^I'콤팩트 모드로 전환'^M^J'T'^I'항상 위에 놓기'^M^J'Q'^I'종료'^M^J'9/0'^I'볼륨조'+
'절'^M^J'-/+'^I'오디오/비디오 싱크 조정'^M^J'1/2'^I'밝기 조정'^M^J'3/4'^I'선명도 조�'+
'��'^M^J'5/6'^I'색상 조정'^M^J'7/8'^I'채도 조정'#0'닫기'#0'MPUI 정보'#0'닫기'#0'MPUI 버젼:'#0'MP'+
'layer 코어 버젼:'#0'환경설정'#0'확인'#0'적용'#0'저장'#0'닫기'#0'사운드 출력 드�'+
'�이버'#0'(디코딩 않음)'#0'(재생 않음)'#0'다이렉트 사운드 출력 장치'#0'작�'+
'��순위조정'#0'없음'#0'자동'#0'최대'#0'(자동선택)'#0#0'필요시 파일 인덱스를 �'+
'�구성'#0'소프트웨어 볼륨 조정 / 증폭'#0'높은 작업순위로 재생'#0'MPlayer'+
' 파라미터 추가:'#0'도움말(영문)'#0'재생목록'#0'재생'#0'추가 ...'#0'위로 이동'+
#0'밑으로 이동'#0'제거'#0'무작위'#0'반복'#0#0'닫기'#0'클립 정보'#0'닫기'#0'클립 정보'+
' 보기는 현재 불가능 합니다.'#0'포맷'#0'길이'#0'메타데이터'#0'비디오 트�'+
'�'#0'오디오 트랙'#0'디코더'#0'코덱'#0'비트레이트'#0'화면크기'#0'프레임 레이트'+
#0'비율'#0'샘플 레이트'#0'채널'#0),

(Name:'nl'; LangID:LANG_DUTCH; SubID:SUBLANG_DEFAULT; Charset:ANSI_CHARSET; Data:
'Nederlands'#0'MPlayer voor Windows'#0'Openen ...'#0'Sluiten ...'#0'Speelt'#0'Gepauseerd'#0'Gestopt'#0'Med'+
'ia niet afspeelbaar (Klik voor meer info)'#0'Toon/verberg speellijst'#0'Toon/verberg media'+
'-informatie'#0'Beeldvullend afspelen'#0'Compacte modus'#0'Geluid aan/uit'#0'Knoppen in beeldvull'+
'ende modus'#0'OSD (on-screen display) modus'#0'Geen OSD'#0'Standaard OSD'#0'Verstreken speeltijd'+
#0'Totale speeltijd'#0'Druk Escape om beeldvullende modus te verlaten.'#0'Bestand'#0'Bestand la'+
'den ...'#0'URL laden ...'#0'URL afspelen'#0'Welke URL wenst u af te spelen?'#0'Laad CD/DVD'#0'Media'+
' sluiten'#0'Afsluiten'#0'Beeld'#0'Willekeurig formaat'#0'Half formaat'#0'Origineel formaat'#0'Dubbel f'+
'ormaat'#0'Beeldvullend'#0'Compacte modus'#0'OSD-modus wijzigen'#0'Venster altijd zichtbaar'#0'Afspe'+
'len'#0'Afspelen'#0'Pause'#0'Vorig item in speellijst'#0'Volgend item in speellijst'#0'Speellijst ..'+
'.'#0'Geluid aan/uit'#0'10 seconden doorspoelen'^I'Rechts'#0'10 seconden terugspoelen'^I'Links'#0'1 m'+
'inuut doorspoelen'^I'Boven'#0'1 minuut terugspoelen'^I'Beneden'#0'10 minuten doorspoelen'^I'PgUp'+
#0'10 minuten terugspoelen'^I'PgDn'#0'Extra'#0'Audiospoor'#0'Ondertitelspoor'#0'Verhouding'#0'Detectere'+
'n'#0'4:3 forceren'#0'16:9 forceren'#0'2.35:1 Forceren'#0'Deinterlacing'#0'Uit'#0'Eenvoudig'#0'Adaptief'#0'Op'+
'ties ...'#0'Taal'#0'Toon media-informatie ...'#0'Toon MPlayer output ...'#0'Help'#0'Toetsenbord hel'+
'p ...'#0'Info ...'#0'MPlayer output'#0'Sluiten'#0'Toetsenbord help'#0'Navigatietoetsen:'^M^J'Spatie'^I'Af'+
'spelen/Pause'^M^J'Rechts'^I'10 seconden doorspoelen'^M^J'Links'^I'10 seconden terugspoelen'^M^J'Bove'+
'n'^I'1 minuut doorspoelen'^M^J'Beneden'^I'1 minuut terugspoelen'^M^J'PgUp'^I'10 minuten doorspoele'+
'n'^M^J'PgDn'^I'10 minuten terugspoelen'^M^J^M^J'Overige toetsen:'^M^J'O'^I'OSD-modus wijzigen'^M^J'F'^I'Beel'+
'dvullend'^M^J'C'^I'Compact modus'^M^J'T'^I'Venster altijd zichtbaar'^M^J'Q'^I'Afsluiten'^M^J'9/0'^I'Volume a'+
'anpassen'^M^J'-/+'^I'Audio/video sync aanpassen'^M^J'1/2'^I'Helderheid aanpassen'^M^J'3/4'^I'Contrast '+
'aanpassen'^M^J'5/6'^I'Kleurbalans aanpassen'^M^J'7/8'^I'Kleurverzadiging aanpassen'#0'Sluiten'#0'Over '+
'MPUI'#0'Sluiten'#0'MPUI versie:'#0'MPlayer core versie:'#0'Opties'#0'OK'#0'Toepassen'#0'Opslaan'#0'Sluiten'#0'S'+
'tuurprogramma voor geluid'#0'(geluidsspoor niet decoderen)'#0'(geluidsspoor niet afspelen)'+
#0'DirectSound stuurprogramma'#0'Postprocessing'#0'Uit'#0'Automatisch'#0'Beste kwaliteit'#0'(Automati'+
'sch)'#0#0'Video-index hergenereren indien nodig'#0'Softwarematige volumeregeling / Volume b'+
'oost'#0'Afspelen met hogere prioriteit'#0'Additionele MPlayer parameters:'#0'Help'#0'Speellijst'#0+
'Afspelen'#0'Toevoegen ...'#0'Naar boven'#0'Naar beneden'#0'Verwijderen'#0'Shuffle'#0'Herhalen'#0'Opslaan '+
'...'#0'Sluiten'#0'Media-informatie'#0'Sluiten'#0'Momenteel geen media-informatie beschikbaar.'#0'Be'+
'standsformaat'#0'Speelduur'#0'Metadata'#0'Videospoor'#0'Audiospoor'#0'Decoder'#0'Codec'#0'Bitrate'#0'Afmetin'+
'gen'#0'Beelden per seconde'#0'Verhoudingen'#0'Samplerate'#0'Kanalen'#0),

(Name:'pl'; LangID:LANG_POLISH; SubID:SUBLANG_DEFAULT; Charset:EASTEUROPE_CHARSET; Data:
'Polski'#0'MPlayer dla Windows'#0'Otwieranie ...'#0'Zamykanie ...'#0'Odtwarzanie'#0'Pauza'#0'Zatrzymane'+
#0'Brak moźliwości otwarcia pliku (Nacisnij aby uzyskac wiecej informacji)'#0'Pokaź/uk'+
'ryj okno playlisty'#0'Pokaź/ukryj informacje o pliku'#0'Włącz tryb fullscreen'#0'Włącz t'+
'ryb compact'#0'Włącz Mute'#0'Pokaź ustawienia fullscreen'#0'Ustawienia OSD'#0'Wyłącz OSD'#0'Do'+
'myślne OSD'#0'Pokaź czas'#0'Pokaź całkowity czas'#0'Wcisnij Esc aby wyłączyć fullscree'+
'n.'#0'Plik'#0'Otwórz plik ...'#0'Otwórz URL ...'#0'Otwórz URL'#0'Jaki URL chciałbyś otworzyć�'+
'�?'#0'Otwórz CD/DVD'#0'Zamknij'#0'Koniec'#0'Widok'#0'Własna wielkość'#0'Połowa wielkości'#0'Orygina'+
'lna wielkość'#0'Podwójna wielkość'#0'Fullscreen'#0'Tryb Compact'#0'Włącz OSD'#0'Zawsze na wi'+
'erzchu'#0'Film'#0'Play'#0'Pause'#0'Poprzedni tytół'#0'Następny tytół'#0'Playlista ...'#0'Mute'#0'Przewi'+
'ń 10 sekund'^I'Prawo'#0'Cofnij 10 sekund'^I'Lewo'#0'Przewiń 1 minute'^I'Góra'#0'Cofnij 1 min'+
'ute'^I'Dół'#0'Przewiń 10 minut'^I'PgUp'#0'Cofnij 10 minut'^I'PgDn'#0'Ustawienia'#0'Ścieźka d�'+
'�więkowa'#0'Ścieźka napisów'#0'Format obrazu'#0'Automatycznie'#0'Wymuszaj 4:3'#0'Wymuszaj 16:9'#0+
'Wymuszaj 2.35:1'#0'Przeplot'#0'Wyłącz'#0'Prosty'#0'Automatyczny'#0'Ustawienia ...'#0'Język'#0'Pokaź i'+
'nformacje o pliku ...'#0'Pokaź konsole MPlayer'#0'Pomoc'#0'Funkcje klawiatury ...'#0'O programi'+
'e ...'#0'Wyjście MPlayer'#0'Zamknij'#0'Funkcje klawiatury'#0'Klawisze nawigacji:'^M^J'Spacja'^I'Play/'+
'Pause'^M^J'Prawo'^I'Przewiń 10 sekund'^M^J'Lewo'^I'Cofnij 10 sekund'^M^J'Góra'^I'Przewiń 1 minute'^M^J+
'Dół'^I'Cofnij 1 minute'^M^J'PgUp'^I'Przewiń 10 minut'^M^J'PgDn'^I'Cofnij 10 minut'^M^J^M^J'Inne kla'+
'wisze:'^M^J'O'^I'Włącz OSD'^M^J'F'^I'Włącz fullscreen'^M^J'C'^I'Włącz tryb compact'^M^J'T'^I'Ustaw zaw'+
'sze na wierzchu'^M^J'Q'^I'Zakończenie programu'^M^J'9/0'^I'Ustawienie głośności'^M^J'-/+'^I'Ustawi'+
'enie audio/video synchronizacji'^M^J'1/2'^I'Ustawienie jasności'^M^J'3/4'^I'Ustawienie kontrast'+
'u'^M^J'5/6'^I'Ustawienie koloru'^M^J'7/8'^I'Ustawienie nasycenia'#0'Zamknij'#0'O programie MPUI'#0'Zamkni'+
'j'#0'Wersja MPUI:'#0'Wersja jądra MPlayer:'#0'Ustawienia'#0'OK'#0'Zatwierdź'#0'Zapisz'#0'Zamknij'#0'Sterow'+
'nik dźwięku'#0'(nie dekoduj dźwięku)'#0'(nie odtwarzaj dźwięku)'#0'Urządzenie wyjścio'+
'we DirectSound'#0'Postprocessing'#0'Wyłącz'#0'Automatycznie'#0'Maksymalna jakość'#0'(Wybór aut'+
'omaytczny)'#0#0'Przebuduj index pliku jeśli konieczne'#0'Programowe ustawienia głośnośc'+
'i / Głośność zwiększona'#0'Uruchom z wyrzszym priorytetem'#0'Dodatkowe parametry MPla'+
'yer:'#0'Pomoc'#0'Playlist'#0'Play'#0'Dodaj ...'#0'Przesuń do góry'#0'Przesuń w dół'#0'Usuń'#0#0#0#0'Zamkn'+
'ij'#0'Informacje o pliku'#0'Zamknij'#0'Informacje o pilik niedostępne.'#0'Format'#0'Czas trwania'#0'C'+
'lip Metadata'#0'Video Track'#0'Audio Track'#0'Decoder'#0'Codec'#0'Bitrate'#0'Dimensions'#0'Frame Rate'#0'Asp'+
'ect Ratio'#0'Sample Rate'#0'Kanały'#0),

(Name:'pt'; LangID:LANG_PORTUGUESE; SubID:SUBLANG_DEFAULT; Charset:DEFAULT_CHARSET; Data:
'Português'#0'MPlayer para Windows'#0'A abrir...'#0'A fechar...'#0'a reproduzir'#0'Pausa'#0'Parado'#0'Nã'+
'o é possivél ler o filme (Clique para mais detalhes)'#0'Mostrar/Ocultar janela da lis'+
'ta de reprodução'#0'Mostrar/Ocultar detalhes do ficheiro'#0'Alternar modo de écran comp'+
'leto'#0'Alternar modo compacto'#0'Alternar silêncio'#0'Mostrar controlos no modo de écran c'+
'ompleto'#0'Definir modo OSD'#0'Sem OSD'#0'OSD prédefinido'#0'Mostrar tempo'#0'Mostrar tempo total'#0+
'Pressione Esc para sair do modo de écran completo'#0'Ficheiro'#0'Reproduzir ficheiro...'#0'R'+
'eproduzir URL...'#0'Reproduzir URL'#0'Qual o URL a reproduzir?'#0'Reproduzir CD/DVD'#0'Fechar'#0'Sa'+
'ir'#0'Ver'#0'Tamanho personalizado'#0'Metade do tamanho'#0'Tamanho original'#0'Dobro do tamanho'#0'Éc'+
'ran completo'#0#0'Alternar OSD'#0'Sempre visivél'#0'Reprodução'#0'Reproduzir'#0'Pausa'#0'Título ant'+
'erior'#0'Título seguinte'#0'Lista de reprodução...'#0'Silêncio'#0'Avançar 10 segundos'^I'Dire'+
'ita'#0'Retroceder 10 segundos'^I'Esquerda'#0'Avançar 1 minuto'^I'Cima'#0'Retroceder 1 minuto'^I'Ba'+
'ixo'#0'Avançar 10 minutos'^I'PágUp'#0'Retroceder 10 minutos'^I'PágDw'#0'Preferências'#0'Pista de'+
' áudio'#0'Pista de legendas'#0'Formato de imagem'#0'Autodetectar'#0'Forçar 4:3'#0'Forçar 16:9'#0'Fo'+
'rçar 2.35:1'#0'Desentrelaçar'#0'Desabilitado'#0'Simples'#0'Adaptativo'#0'Preferências...'#0'Idioma'#0+
'Mostrar detalhes do filme...'#0'Mostrar mensagens do MPlayer'#0'Ajuda'#0'Ajuda do teclado...'#0+
'Sobre o...'#0'Mensagens do MPlayer'#0'Fechar'#0'Ajuda do teclado'#0'Teclas de navegação:'^M^J'Espa'+
'ço'^I'Reproduzir/Pausa'^M^J'Dereita'^I'Avançar 10 segundos'^M^J'Esquerda'^I'Retroceder 10 segund'+
'os'^M^J'Cima'^I'Avançar 1 minuto'^M^J'Baixo'^I'Retroceder 1 minuto'^M^J'PágUp'^I'Avançar 10 minutos'+
^M^J'PágDw'^I'Retroceder 10 minutos'^M^J^M^J'Outras teclas:'^M^J'O'^I'Alternar OSD'^M^J'F'^I'Alternar modo'+
' de écran completo'^M^J'Q'^I'Sair imediatamente'^M^J'9/0'^I'Ajustar volume'^M^J'-/+'^I'Ajustar sincro'+
'nização de audio/vídeo'^M^J'1/2'^I'Ajustar brilho'^M^J'3/4'^I'Ajustar contraste'^M^J'5/6'^I'Ajustar'+
' cor'^M^J'7/8'^I'Ajustar saturação'#0'Fechar'#0'Sobre o MPUI'#0'Fechar'#0'Versão do MPUI:'#0'Versão d'+
'o MPlayer:'#0'Preferências'#0'Aceitar'#0'Aplicar'#0'Guardar'#0'Fechar'#0'Controlador de saída de áu'+
'dio:'#0'(não descodificar som)'#0'(não reproduzir som)'#0'Dispositivo de saída DirectSound'+
#0'Pós-processamento:'#0'Desabilitado'#0'Automático'#0'Qualidade máxima'#0'(Selecção automát'+
'ica)'#0#0'Reconstruir índice do ficheiro se necessário'#0'Controlo de volume / Aumentar v'+
'olume'#0'Executar com prioridade total'#0'Parâmetros MPlayer adicionais:'#0'Ajuda'#0'Lista de r'+
'eprodução'#0'Reproduzir'#0'Adicionar...'#0'Subir'#0'Descer'#0'Apagar'#0#0#0#0'Fechar'#0'Detalhes do filme'#0+
'Fechar'#0'Não existem informações disponiveis de momento.'#0'Formato'#0'Duração'#0'Metadata'+
' do filme'#0'Pista de video'#0'Pista de áudio'#0'Descodificador'#0'Codec'#0'Bitrate'#0'Dimensões'#0'Tax'+
'a de imagens'#0'Formato de imagem'#0'Taxa de amostragem'#0'Canais'#0),

(Name:'ro'; LangID:LANG_ENGLISH; SubID:SUBLANG_DEFAULT; Charset:EASTEUROPE_CHARSET; Data:
'Română'#0'MPlayer pentru Windows'#0'Se deschide ...'#0'Se inchide ...'#0'Redare'#0'Pauză'#0'Oprit'#0'F'+
'isierul multimedia nu poate fi redat (Click pentru informaţii suplimentare)'#0'Arată/'+
'ascunde lista de redare'#0'Arată/ascunde informaţii despre fişierul curent'#0'Activeaz�'+
'� modul fullscreen'#0'Activează modul compact'#0'Fără sonor'#0'Arată controalele in modul'+
' fullscreen'#0'Mod OSD'#0'Fără OSD'#0'OSD-ul implicit'#0'Arată durata redării'#0'Arată durata '+
'totală'#0'Apasă tasta Escape pentru a ieşi din modul fullscreen.'#0'Fişier'#0'Redă fişi'+
'erul multimedia ...'#0'Redă de la locaţia din Internet ...'#0'Redă de la locaţia din I'+
'nternet'#0'De la care locaţie din Internet doriţi sa se efectueze redarea?'#0'Redă CD/D'+
'VD'#0'Închide'#0'Ieşire'#0'Vizualizare'#0'Mărime particulară'#0'Jumătate din mărimea original'+
'ă'#0'Mărimea originală'#0'Mărime dublă'#0'Fullscreen'#0'Modul compact'#0'Activează OSD'#0'Fereas'+
'tra întotdeauna vizibilă'#0'Redare'#0'Redare'#0'Pauză'#0'Titlul anterior'#0'Titlul următor'#0'List'+
'a de redare ...'#0'Fără sonor'#0'Înainte 10 secunde'^I'Right'#0'Înapoi 10 secunde'^I'Left'#0'În'+
'ainte 1 minut'^I'Up'#0'Înapoi 1 minut'^I'Down'#0'Înainte 10 minute'^I'PgUp'#0'Înapoi 10 minute'^I+
'PgDn'#0'Opţiuni'#0'Canal audio'#0'Canal subtitrări'#0'Aspectul redării'#0'Detectează automat'#0'Fo'+
'rţează 4:3'#0'Forţează 16:9'#0'Forţează 2.35:1'#0'Filtrare de tip deinterlace'#0'Dezactiva'+
'tă'#0'Simplă'#0'Adaptivă'#0'Reglaje ...'#0'Limbă'#0'Arată informaţii despre fişierul multime'+
'dia ...'#0'Arată mesajele de informare de la MPlayer ...'#0'Ajutor'#0'Operare cu tastele ...'+
#0'Despre ...'#0'Mesajele de informare de la MPlayer'#0'Închide'#0'Operare cu tastele'#0'Taste de'+
' navigare:'^M^J'Space'^I'Redare/Pauză'^M^J'Right'^I'Înainte 10 secunde'^M^J'Left'^I'Înapoi 10 secun'+
'de'^M^J'Up'^I'Înainte 1 minut'^M^J'Down'^I'Înapoi 1 minut'^M^J'PgUp'^I'Înainte 10 minute'^M^J'PgDn'^I'În'+
'apoi 10 minute'^M^J^M^J'Alte taste:'^M^J'O'^I'Activează/dezactivează OSD'^M^J'F'^I'Activează/dezact'+
'ivează mod fullscreen'^M^J'C'^I'Activează/dezactivează mod compact'^M^J'T'^I'Activează/dezac'+
'tivează opţiune fereastră întotdeauna vizibilă'^M^J'Q'^I'Abandonare program'^M^J'9/0'^I'Aju'+
'stează volumul'^M^J'-/+'^I'Ajustează sincronizarea audio/video'^M^J'1/2'^I'Ajustează străluc'+
'irea'^M^J'3/4'^I'Ajustează contrastul'^M^J'5/6'^I'Ajustează nuanţele'^M^J'7/8'^I'Ajustează satura�'+
'�ia'#0'Închide'#0'Despre MPUI'#0'Închide'#0'Versiunea MPUI:'#0'Versiunea MPlayer:'#0'Opţiuni'#0'OK'#0'Apl'+
'ică'#0'Salvează'#0'Închide'#0'Driver-ul pentru sunet'#0'(nu decodifica sunetul)'#0'(nu reda sune'+
'tul)'#0'Ieşire DirectSound'#0'Postprocesare'#0'Dezactivată'#0'Automată'#0'Calitate maximă'#0'(Sele'+
'cţie automată)'#0#0'Reconstruieşte indecşii fişierului multimedia dacă este necesa'+
'r'#0'Control software al volumului / Amplificarea Volumului'#0'Execută aplicaţia cu prio'+
'ritate de tip higher'#0'Parametri adiţionali pentru MPlayer:'#0'Ajutor'#0'Lista de redare'#0'Re'+
'dă'#0'Adaugă ...'#0'Deplasează in sus'#0'Deplasează in jos'#0'Elimină'#0'Amestecă'#0'Repetă'#0'Sal'+
'vează ...'#0'Închide'#0'Informaţii despre fişierul multimedia'#0'Închide'#0'Acum nu este di'+
'sponibilă nici o informaţie despre fisierul multimedia.'#0'Format'#0'Întindere'#0'Date sup'+
'limentare'#0'Canalul video'#0'Canalul audio'#0'Decodor'#0'Codec'#0'Rata de transfer'#0'Dimensiuni'#0'Num�'+
'�rul de cadre'#0'Aspect'#0'Rata sample-urilor'#0'Numărul de canale'#0),

(Name:'ru'; LangID:LANG_RUSSIAN; SubID:SUBLANG_DEFAULT; Charset:RUSSIAN_CHARSET; Data:
'Русский'#0'MPlayer for Windows'#0'Открытие ...'#0'Закрытие ...'#0'Про�'+
'�грывание...'#0'Приостановлено'#0'Остановлено'#0'Невоз�'+
'�ожно проиграть носитель (Нажмите чтобы получ�'+
'�ть больше информации)'#0'Показать\скрыть плейли�'+
'�т'#0'Показать\скрыть информацию о файле'#0'Переклю�'+
'�ится в полноэкранный режим'#0#0#0#0'Установить режи�'+
'� OSD'#0'Без OSD'#0'OSD по умолчанию'#0'Показывать позицию'#0'П�'+
'�казывать позицию\длительность'#0'Нажмите Escape чт'+
'обы выйти из полноэкранного режима'#0'Файл'#0'Откры'+
'ть файл ...'#0'Открыть URL ...'#0'Открыть URL'#0'Введите жела�'+
'�мый URL'#0'Проиграть CD/DVD'#0'Закрыть'#0'Выход'#0'Вид'#0'Произв�'+
'�льный размер'#0'1/2 размера'#0'Оригинальный размер'#0'Д'+
'войной размер'#0'Полноэкранный режим'#0'Компактный'+
#0'Переключить OSD'#0'Всегда наверху'#0'Проигрывание'#0'И�'+
'�рать'#0'Приостановить'#0'Предыдущий трек'#0'Следующи�'+
'� трек'#0'Плейлист ...'#0'Выключить звук'#0'Вперёд на 10 с�'+
'�кунд'^I'Right'#0'Назад на 10 секунд'^I'Left'#0'Вперёд на 1 мину�'+
'�у'^I'Up'#0'Назад на 1 минуту'^I'Down'#0'Вперёд на 10 минут'^I'PgUp'#0'�'+
'�азад на 10 минут'^I'PgDn'#0'Настройки'#0'Аудиотрек'#0'Субти�'+
'�ры'#0'Соотношение сторон'#0'Автоопределение'#0'Прину�'+
'�ительно 4:3'#0'Принудительно 16:9'#0'Принудительно 2.35:'+
'1'#0'Деинтерлейс'#0'Отключить'#0'Простой'#0'Адаптивный'#0'Оп'+
'ции ...'#0'Язык'#0'Показать информацию о файле ...'#0'Пока'+
'зывать вывод MPlayer'#0'Помощь'#0'Помощь по клавиатуре '+
'...'#0'О программе ...'#0'Вывод MPlayer'#0'Закрыть'#0'Помощь по к'+
'лавиатуре'#0'Клавиши навигации:'^M^J'Пробел'^I'Играть/п'+
'ауза'^M^J'Вправо'^I'Вперёд на 10 секунд'^M^J'Влево'^I'Назад н'+
'а 10 секунд'^M^J'Вверх'^I'Вперёд на 1 минуту'^M^J'Вниз'^I'Наза'+
'д на 1 минуту'^M^J'PgUp'^I'Вперёд на 10 минут'^M^J'PgDn'^I'Назад на'+
' 10 минут'^M^J^M^J'Другие клавиши:'^M^J'O'^I'Переключить OSD'^M^J'F'^I'П'+
'ереключить полноэкранный режим'^M^J'Q'^I'Выйти немед'+
'ленно'^M^J'9/0'^I'Настроить громкость'^M^J'-/+'^I'Настроить ау'+
'дио\видео синхронизацию'^M^J'1/2'^I'Настроить яркость'+
^M^J'3/4'^I'Настроить контраст'^M^J'5/6'^I'Настроить hue'^M^J'7/8'^I'Нас'+
'троить цветовую насыщенность'#0'Закрыть'#0'О MPUI'#0'Зак'+
'рыть'#0'Версия MPUI:'#0'Версия MPlayer:'#0'Опции'#0'OK'#0'Применить'#0'�'+
'�охранить'#0'Закрыть'#0'Драйвер вывода звука'#0'(Не дек'+
'одировать звук)'#0'(Не проигрывать звук)'#0'Устройст'+
'во DirectSound'#0'Постобработка'#0'Отключена'#0'Автоматиче�'+
'�ки'#0'Наилучшее качество'#0'(Автовыбор)'#0#0'Перестроит'+
'ь таблицу индексов AVI, если необходимо'#0'Програм'+
'ная регулировка громкости'#0'Выполнять с более в'+
'ысоким приоритетом'#0'Дополнительные параметры '+
'MPlayer:'#0'Помощь'#0'Плейлист'#0'Проиграть'#0'Добавить ...'#0'Вв�'+
'�рх'#0'Вниз'#0'Удалить'#0'Выбирать случайную дорожку'#0'П�'+
'�вторять'#0'Сохранить ...'#0'Закрыть'#0'Информация о фай'+
'ле'#0'Закрыть'#0'Информация недоступна на данный мо'+
'мент'#0'Формат'#0'Длительность'#0'Метаданные файла'#0'Ви�'+
'�ео дорожка'#0'Аудио дорожка'#0'Декодер'#0'Кодек'#0'Битрэ�'+
'�т'#0'Размеры'#0'Частота кадров'#0'Отношения сторон'#0'Ка�'+
'�ество сэмплирования'#0'Количество каналов'#0),

(Name:'sk'; LangID:LANG_SLOVAK; SubID:SUBLANG_DEFAULT; Charset:EASTEUROPE_CHARSET; Data:
'Slovenčina'#0'MPlayer pre Windows'#0'Otváranie...'#0'Zatváranie...'#0'Prehrávanie'#0'Pozastaven'+
'é'#0'Zastavené'#0'Nie je možné prehrať (kliknite pre viac informácií)'#0'Zoznam skladi'+
'eb'#0'Informácie o klipe'#0'Celá obrazovka'#0'Kompaktný režim'#0'Stlmiť'#0'Show fullscreen con'+
'trols'#0'Režim OSD'#0'Bez OSD'#0'Štandardné OSD'#0'Zobraziť odohraný čas'#0'Zobraziť celkov�'+
'� čas'#0'Stlačte Escape pre ukončenie celoobrazovkového režimu.'#0'Súbor'#0'Prehrať s�'+
'�bor ...'#0'Prehrať URL ...'#0'Prehrať URL'#0'Zadajte URL, ktoré chcete prehrať'#0'Prehrať '+
'CD/DVD'#0'Zatvoriť'#0'Koniec'#0'Zobraziť'#0'Vlastná veľkosť'#0'Polovičná veľkosť'#0'Pôvodná'+
' veľkosť'#0'Dvojnásobná veľkosť'#0'Celá obrazovka'#0'Kompatný režim'#0'Prepnúť OSD'#0'V�'+
'�dy na vrchu'#0'Prehrať'#0'Prehrávať'#0'Pauza'#0'Predchádzajúci'#0'Nasledujúci'#0'Zoznam skladie'+
'b ...'#0'Stlmiť'#0'Dopredu o 10 sekúnd'^I'Šípka vpravo'#0'Dozadu o 10 sekúnd'^I'Šípka vľa'+
'vo'#0'Dopredu o 1 minútu'^I'Šípka hore'#0'Dozadu o 1 minútu'^I'Šípka dole'#0'Dopredu o 10 m'+
'inút'^I'PgUp'#0'Dozadu o 10 minút'^I'PgDn'#0'Nástroje'#0'Audio stopa'#0'Titulková stopa'#0'Pomer st'+
'rán'#0'Automatický'#0'Vždy 4:3'#0'Vždy 16:9'#0'Vždy 2.35:1'#0'Rozriadkovanie'#0'Vypnuté'#0'Jednoduc'+
'hé'#0'Adaptívne'#0'Nastavenia ...'#0'Jazyk'#0'Zobraziť informácie o klipe ...'#0'Zobraziť výs'+
'tup MPlayeru ...'#0'Pomocník'#0'Klávesové skratky ...'#0'O programe ...'#0'Výstup MPlayeru'#0'Z'+
'atvoriť'#0'Klávesové skratky'#0'Navigačné klávesy:'^M^J'Medzerník'^I'Prehrať/Pauza'^M^J'Ší'+
'pka doprava'^I'Doperdu o 10 sekúnd'^M^J'Šípka doľava'^I'Dozadu o 10 sekúnd'^M^J'Šípka hor'+
'e'^I'Dopredu o 1 minútu'^M^J'Šípka dole'^I'Dozadu o 1 minútu'^M^J'PgUp'^I'Dopredu o 10 minút\'+
'nPgDn'^I'Dozadu o 10 minút'^M^J^M^J'Iné klávesy:'^M^J'O'^I'Prepnúť OSD'^M^J'F'^I'Celá obrazovka'^M^J'C'+
^I'Kompaktný režim'^M^J'T'^I'Vždy na vrchu'^M^J'Q'^I'Koniec'^M^J'9/0'^I'Nastavenie hlasitosti'^M^J'-/+'^I+
'Nastavenie audio/video synchronizácie'^M^J'1/2'^I'Nastavenie jasu'^M^J'3/4'^I'Nastavenie kontra'+
'stu'^M^J'5/6'^I'Nastavenie farieb'^M^J'7/8'^I'Nastavenie sýtosti'#0'Zatvoriť'#0'O programe MPUI'#0'Zatv'+
'oriť'#0'Verzia MPUI:'#0'Verzia MPlayer:'#0'Nastavenie'#0'OK'#0'Použiť'#0'Uložiť'#0'Zatvoriť'#0'Výstup'+
'ný ovládač zvuku'#0'(nedekódovať zvuk)'#0'(neprehrávať zvuk)'#0'Výstupné zariadenie '+
'DirectSound'#0'Postprocessing'#0'Vypnutý'#0'Automatický'#0'Maximálna kvalita'#0'(Automatický v�'+
'�ber)'#0#0'Opraviť index súboru, ak je to nevyhnutné'#0'Softwarové ovládanie hlasitost'+
'i / Volume boost'#0'Spustiť s vyššou prioritou'#0'Dotatočné parametre MPlayera:'#0'Pomoc'+
'ník'#0'Zoznam skladieb'#0'Prehrať'#0'Pridať ...'#0'Presunúť hore'#0'Presunúť dole'#0'Odstráni�'+
'�'#0'Náhodne'#0'Opakovať'#0'Uložiť ...'#0'Zatvoriť'#0'Informácie o klipe'#0'Zatvoriť'#0'V tejto ch'+
'víli nie sú dostupné žiadne informácie.'#0'Formát'#0'Trvanie'#0'Metadáta klipu'#0'Video s'+
'topa'#0'Audio stopa'#0'Dekóder'#0'Kodek'#0'Bitrate'#0'Dimensions'#0'Počet snímkov za sekundu'#0'Pomer '+
'strán'#0'Vzorkovacia frekvencia'#0'Kanály'#0),

(Name:'ua'; LangID:LANG_UKRAINIAN; SubID:SUBLANG_DEFAULT; Charset:RUSSIAN_CHARSET; Data:
'Українська'#0'MPlayer for Windows'#0'Відкриття ...'#0'Закриття ...'+
#0'Відтворення...'#0'Призупинено'#0'Зупинено'#0'Неможлив�'+
'� відтворити носій (Натисніть для отримання до'+
'даткової інформації)'#0'Показати/приховати плей�'+
'�іст'#0'Показати/приховати інформацію про кліп'#0'Н�'+
'� повний екран'#0'До компактного режиму'#0'Вимкнути/'+
'включити зву�'#0'Показати кнопки повноекранного '+
'режиму'#0'Встановлення: OSD режиму'#0'Вимкнути: OSD'#0'За �'+
'�мовчанням: OSD'#0'Показати час'#0'Показати триваліст'+
'ь'#0'Натисніть Escape для виходу з повноекранного р�'+
'�жиму'#0'Файл'#0'Завантажити файл ...'#0'Відтворити інте'+
'рнет ярлик ...'#0'Відтворити URL ...'#0'Який URL Ви хочете '+
'завантажити?'#0'Грати CD/DVD'#0'Закрити'#0'Вийти'#0'Перегляд'+
#0'Довільний розмір'#0'Розмір 50%'#0'Розмір 100%'#0'Розмір 200'+
'%'#0'На повний екран'#0'Компактний режим'#0'Переключен�'+
'�я OSD'#0'Завжди зверху'#0'Команди'#0'Грати'#0'Пауз�'#0'Поперед'+
'ній кліп'#0'Наступний кліп'#0'Плейліст ...'#0'Вимкнути з'+
'ву�'#0'Перейти на + 10 секунд'^I'Right'#0'Перейти на - 10 секу'+
'нд'^I'Left'#0'Перейти на + 1 хвилину'^I'Up'#0'Перейти на - 1 хви'+
'лину'^I'Down'#0'Перейти на + 10 хвилин'^I'PgUp'#0'Перейти на - 10 '+
'хвилин'^I'PgDn'#0'Налаштування'#0'Звукова доріжк�'#0'Доріж�'+
'�а субтитрі�'#0'Пропорції відео'#0'Автовизначення'#0'В�'+
'�тановити як: 4:3'#0'Встановити як:  16:9'#0'Встановити я'+
'к:  2.35:1'#0'Згладжування картинки'#0'Вимкнено'#0'Просте'#0+
'Адаптивне'#0'Налаштування ...'#0'Мова програми (Language)'+
#0'Показати інформацію про кліп'#0'Показати журнал'+
' MPlayer'#0'Допомог�'#0'Клавіатурні команди ...'#0'Про прогр'+
'аму ...'#0'Журнал MPlayer'#0'Закрити'#0'Клавіатурні команди'+
#0'Закрити'#0#0'Про програму MPUI'#0'Закрити'#0'Версія MPUI:'#0'Ве'+
'рсія програвача MPlayer:'#0'Налаштування'#0'OK'#0'Застосув�'+
'�ти'#0'Зберегти'#0'Закрити'#0'Виведення звуку через'#0'(не'+
' декодувати звук)'#0'(не програвати звук)'#0'Пристрі�'+
'� виведення звуку'#0'Допоміжна обробка відео'#0'Від�'+
'�лючено'#0'Автовизначення'#0'Максимальна якість'#0'(Ав'+
'товизначення)'#0#0'Перебудова індексу відео файла'+
' за необхідністю'#0'Програмне регулювання гучно�'+
'�ті звуку'#0'Запускати з підвищеним пріоритетом'#0'�'+
'�опоміжні налаштування MPlayer:'#0'Допомог�'#0'Плейліст'+
#0'Відтворити'#0'Додати ...'#0'Уверх'#0'Донизу'#0'Вилучити'#0'Ви'+
'падково'#0'Повторити'#0'Зберегти ...'#0'Закрити'#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0+
#0#0),

(Name:'zh_CN'; LangID:LANG_CHINESE; SubID:SUBLANG_DEFAULT; Charset:GB2312_CHARSET; Data:
'Chinese (Simplified)'#0'MPlayer for Windows'#0'打开 ...'#0'关闭 ...'#0'播放'#0'暂停'#0'停止'#0+
'无法播放剪辑（点击查看更多信息）'#0'显示/隐藏播放列表'#0'显示/�'+
'�藏剪辑信息'#0'切换全屏幕模式'#0'切换完整模式'#0'切换静音'#0'显示全屏�'+
'��控制'#0'OSD 模式'#0'无 OSD'#0'默认 OSD'#0'显示时间'#0'显示完整时间'#0'使用Escape�'+
'��出全屏幕模式'#0'文件'#0'播放文件 ...'#0'播放 URL ...'#0'播放 URL'#0'请输入你�'+
'��播放的URL'#0'播放 CD/DVD'#0'关闭'#0'退出'#0'查看'#0'自定义尺寸'#0'半尺寸'#0'原始�'+
'�寸'#0'双倍尺寸'#0'全屏幕'#0'完整模式'#0'切换 OSD'#0'保持在窗口最上端'#0'播放'#0+
'播放'#0'暂停'#0'上一个标题'#0'下一个标题'#0'播放列表 ...'#0'静音'#0'快进10秒'^I'R'+
'ight'#0'后退10秒'^I'Left'#0'快进1分'^I'Up'#0'后退1分'^I'Down'#0'快进10分'^I'PgUp'#0'后退10分'+
^I'PgDn'#0'工具'#0'音轨'#0'字幕'#0'外观比例'#0'自动检测'#0'强制 4:3'#0'强制 16:9'#0'强制 '+
'2.35:1'#0'去交错'#0'关闭'#0'简单'#0'适应'#0'设置 ...'#0'语言'#0'显示剪辑信息 ...'#0'显�'+
'� MPlayer 输出 ...'#0'帮助'#0'热键帮助 ...'#0'关于 ...'#0'MPlayer 输出'#0'关闭'#0'热键'+
'帮助'#0'浏览热键'^M^J'Space'^I'播放/暂停'^M^J'Right'^I'快进10秒'^M^J'Left'^I'后退10秒'^M^J'Up'+
^I'快进1分'^M^J'Down'^I'后退1分'^M^J'PgUp'^I'快进10分'^M^J'PgDn'^I'后退10分'^M^J^M^J'其他热键'+
':'^M^J'O'^I'切换 OSD'^M^J'F'^I'切换全屏幕模式'^M^J'C'^I'切换完整模式'^M^J'T'^I'切换静音'^M^J+
'Q'^I'立刻退出'^M^J'9/0'^I'调整音量'^M^J'-/+'^I'调整音频/视频同步'^M^J'1/2'^I'调整亮�'+
'�'^M^J'3/4'^I'调整对比度'^M^J'5/6'^I'调整色调'^M^J'7/8'^I'调整饱和度'#0'关闭'#0'关于 MPUI'#0+
'关闭'#0'MPUI 版本：'#0'MPlayer 核心版本'#0'设置'#0'确认'#0'应用'#0'保存'#0'关闭'#0'音频'+
'输出设备'#0'(不解码音频)'#0'(不播放声音)'#0'DirectSound 输出设备'#0'后处理'#0+
'关闭'#0'自动'#0'最佳质量'#0'(自动选择)'#0#0'如果必要重建剪辑索引'#0'软件音�'+
'��控制/提升'#0'使用更高的运行级别'#0'额外的MPlayer 参数：'#0'帮助'#0'播放'+
'列表'#0'播放'#0'添加 ...'#0'上移'#0'下移'#0'删除'#0'随机'#0'重复'#0'保存 ...'#0'关闭'#0'剪辑'+
'信息'#0'关闭'#0'当前没有可用的剪辑信息'#0'格式'#0'长度'#0'剪辑元数据'#0'视频'+
#0'音频'#0'解码器'#0'编码器'#0'比特率'#0'大小'#0'帧率'#0'外观比例'#0'采样率'#0'声道数'+
#0),

(Name:'zh_TW'; LangID:LANG_CHINESE; SubID:SUBLANG_DEFAULT; Charset:CHINESEBIG5_CHARSET; Data:
'Chinese (Traditional)'#0'MPlayer for Windows'#0'正在開啟 ...'#0'正在關閉 ...'#0'播放�'+
'�'#0'暫停'#0'停止'#0'無法播放媒體（點此查看更多訊息）'#0'顯示/隱藏播放'+
'清單'#0'顯示/隱藏影片資訊'#0'切換全螢幕模式'#0'切換精簡模式'#0'切換靜�'+
'��'#0'顯示全螢幕控制項'#0'OSD 模式'#0'關閉 OSD'#0'預設 OSD'#0'顯示時間'#0'顯示完�'+
'��時間'#0'按 Escape 跳出全螢幕模式'#0'檔案'#0'播放檔案 ...'#0'播放網址 ...'#0'�'+
'��放網址'#0'請輸入您想播放的網址'#0'播放 CD/DVD'#0'關閉'#0'退出'#0'檢視'#0'自訂'+
'畫面大小'#0'一半大小'#0'原始大小'#0'兩倍大小'#0'全螢幕'#0'精簡模式'#0'切換 OS'+
'D'#0'永遠在視窗最上層'#0'播放'#0'播放'#0'暫停'#0'上一個主題'#0'下一個主題'#0'播�'+
'��清單 ...'#0'靜音'#0'向前 10s'^I'Right'#0'向後 10s'^I'Left'#0'向前 1m'^I'Up'#0'向後 1m'^I'Down'+
#0'向前 10m'^I'PgUp'#0'向後 10m'^I'PgDn'#0'工具'#0'聲音軌'#0'字幕軌'#0'顯示比例'#0'自動偵'+
'測'#0'強制使用 4:3'#0'強制使用 16:9'#0'強制使用 2.35:1'#0'去交錯'#0'關閉'#0'簡單�'+
'�式'#0'適應模式'#0'選項 ...'#0'語系'#0'顯示影片訊息 ...'#0'顯示 MPlayer 輸出 ...'+
#0'說明'#0'快速鍵說明 ...'#0'關於 ...'#0'MPlayer 輸出'#0'關閉'#0'快速鍵說明'#0'導覽�'+
'��速鍵'^M^J'Space'^I'播放/暫停'^M^J'Right'^I'向前10秒'^M^J'Left'^I'向後10秒'^M^J'Up'^I'向前1�'+
'�'^M^J'Down'^I'向後1分'^M^J'PgUp'^I'向前10分'^M^J'PgDn'^I'向後10分'^M^J^M^J'其他快速鍵:'^M^J'O'^I'�'+
'�換 OSD'^M^J'F'^I'切換全螢幕模式'^M^J'C'^I'切換精簡模式'^M^J'T'^I'切換視窗最上層\'+
'nQ'^I'立即退出'^M^J'9/0'^I'調整音量'^M^J'-/+'^I'調整音視訊同步'^M^J'1/2'^I'調整亮度'^M^J+
'3/4'^I'調整對比'^M^J'5/6'^I'調整色調'^M^J'7/8'^I'調整飽和度'#0'關閉'#0'關於 MPUI'#0'關閉'+
#0'MPUI 版本:'#0'MPlayer 核心版本'#0'選項'#0'確認'#0'套用'#0'儲存'#0'關閉'#0'音效輸出�'+
'�動程式'#0'(不解碼音效)'#0'(不播放音效)'#0'DirectSound 輸出裝置'#0'後置處理'+
#0'關閉'#0'自動'#0'最佳品質'#0'(自動選擇)'#0#0'必要時重建檔案索引'#0'軟體音量'+
'控制/音量增強'#0'使用更高的優先權'#0'其它 MPlayer 播放參數:'#0'說明'#0'播'+
'放清單'#0'播放'#0'新增 ...'#0'上移'#0'下移'#0'移除'#0'隨機播放'#0'重複播放'#0'儲存為'+
' ...'#0'關閉'#0'影片資訊'#0'關閉'#0'目前沒有可用的影片資訊'#0'影片格式'#0'影�'+
'�長度'#0'影片 metadata'#0'影像軌'#0'聲音軌'#0'解碼器'#0'CODEC'#0'平均流量'#0'畫面大�'+
'�'#0'畫面頻率'#0'顯示比例'#0'取樣率'#0'聲道數'#0)
);
implementation

procedure ApplyLocaleStrings;
begin
  GetNextLocaleString();
  _.Title:=GetNextLocaleString();
  _.Status_Opening:=GetNextLocaleString();
  _.Status_Closing:=GetNextLocaleString();
  _.Status_Playing:=GetNextLocaleString();
  _.Status_Paused:=GetNextLocaleString();
  _.Status_Stopped:=GetNextLocaleString();
  _.Status_Error:=GetNextLocaleString();
  MainForm.BPlaylist.Hint:=GetNextLocaleString();
  MainForm.BStreamInfo.Hint:=GetNextLocaleString();
  MainForm.BFullscreen.Hint:=GetNextLocaleString();
  MainForm.BCompact.Hint:=GetNextLocaleString();
  MainForm.BMute.Hint:=GetNextLocaleString();
  MainForm.MPFullscreenControls.Caption:=GetNextLocaleString();
  MainForm.OSDMenu.Caption:=GetNextLocaleString();
  MainForm.MNoOSD.Caption:=GetNextLocaleString();
  MainForm.MDefaultOSD.Caption:=GetNextLocaleString();
  MainForm.MTimeOSD.Caption:=GetNextLocaleString();
  MainForm.MFullOSD.Caption:=GetNextLocaleString();
  MainForm.LEscape.Caption:=GetNextLocaleString();
  MainForm.MFile.Caption:=GetNextLocaleString();
  MainForm.MOpenFile.Caption:=GetNextLocaleString();
  MainForm.MOpenURL.Caption:=GetNextLocaleString();
  _.OpenURL_Caption:=GetNextLocaleString();
  _.OpenURL_Prompt:=GetNextLocaleString();
  MainForm.MOpenDrive.Caption:=GetNextLocaleString();
  MainForm.MClose.Caption:=GetNextLocaleString();
  MainForm.MQuit.Caption:=GetNextLocaleString();
  MainForm.MView.Caption:=GetNextLocaleString();
  MainForm.MSizeAny.Caption:=GetNextLocaleString();
  MainForm.MSize50.Caption:=GetNextLocaleString();
  MainForm.MSize100.Caption:=GetNextLocaleString();
  MainForm.MSize200.Caption:=GetNextLocaleString();
  MainForm.MFullscreen.Caption:=GetNextLocaleString();
  MainForm.MCompact.Caption:=GetNextLocaleString();
  MainForm.MOSD.Caption:=GetNextLocaleString();
  MainForm.MOnTop.Caption:=GetNextLocaleString();
  MainForm.MSeek.Caption:=GetNextLocaleString();
  MainForm.MPlay.Caption:=GetNextLocaleString();
  MainForm.MPause.Caption:=GetNextLocaleString();
  MainForm.MPrev.Caption:=GetNextLocaleString();
  MainForm.MNext.Caption:=GetNextLocaleString();
  MainForm.MShowPlaylist.Caption:=GetNextLocaleString();
  MainForm.MMute.Caption:=GetNextLocaleString();
  MainForm.MSeekF10.Caption:=GetNextLocaleString();
  MainForm.MSeekR10.Caption:=GetNextLocaleString();
  MainForm.MSeekF60.Caption:=GetNextLocaleString();
  MainForm.MSeekR60.Caption:=GetNextLocaleString();
  MainForm.MSeekF600.Caption:=GetNextLocaleString();
  MainForm.MSeekR600.Caption:=GetNextLocaleString();
  MainForm.MExtra.Caption:=GetNextLocaleString();
  MainForm.MAudio.Caption:=GetNextLocaleString();
  MainForm.MSubtitle.Caption:=GetNextLocaleString();
  MainForm.MAspect.Caption:=GetNextLocaleString();
  MainForm.MAutoAspect.Caption:=GetNextLocaleString();
  MainForm.MForce43.Caption:=GetNextLocaleString();
  MainForm.MForce169.Caption:=GetNextLocaleString();
  MainForm.MForceCinemascope.Caption:=GetNextLocaleString();
  MainForm.MDeinterlace.Caption:=GetNextLocaleString();
  MainForm.MNoDeint.Caption:=GetNextLocaleString();
  MainForm.MSimpleDeint.Caption:=GetNextLocaleString();
  MainForm.MAdaptiveDeint.Caption:=GetNextLocaleString();
  MainForm.MOptions.Caption:=GetNextLocaleString();
  MainForm.MLanguage.Caption:=GetNextLocaleString();
  MainForm.MStreamInfo.Caption:=GetNextLocaleString();
  MainForm.MShowOutput.Caption:=GetNextLocaleString();
  MainForm.MHelp.Caption:=GetNextLocaleString();
  MainForm.MKeyHelp.Caption:=GetNextLocaleString();
  MainForm.MAbout.Caption:=GetNextLocaleString();
  LogForm.Caption:=GetNextLocaleString();
  LogForm.BClose.Caption:=GetNextLocaleString();
  HelpForm.Caption:=GetNextLocaleString();
  HelpForm.HelpText.Text:=GetNextLocaleString();
  HelpForm.BClose.Caption:=GetNextLocaleString();
  AboutForm.Caption:=GetNextLocaleString();
  AboutForm.BClose.Caption:=GetNextLocaleString();
  AboutForm.LVersionMPUI.Caption:=GetNextLocaleString();
  AboutForm.LVersionMPlayer.Caption:=GetNextLocaleString();
  OptionsForm.Caption:=GetNextLocaleString();
  OptionsForm.BOK.Caption:=GetNextLocaleString();
  OptionsForm.BApply.Caption:=GetNextLocaleString();
  OptionsForm.BSave.Caption:=GetNextLocaleString();
  OptionsForm.BClose.Caption:=GetNextLocaleString();
  OptionsForm.LAudioOut.Caption:=GetNextLocaleString();
  OptionsForm.CAudioOut.Items[0]:=GetNextLocaleString();
  OptionsForm.CAudioOut.Items[1]:=GetNextLocaleString();
  OptionsForm.LAudioDev.Caption:=GetNextLocaleString();
  OptionsForm.LPostproc.Caption:=GetNextLocaleString();
  OptionsForm.CPostproc.Items[0]:=GetNextLocaleString();
  OptionsForm.CPostproc.Items[1]:=GetNextLocaleString();
  OptionsForm.CPostproc.Items[2]:=GetNextLocaleString();
  OptionsForm.CLanguage.Items[0]:=GetNextLocaleString();
  OptionsForm.CLanguage.Items[1]:=GetNextLocaleString();
  OptionsForm.CIndex.Caption:=GetNextLocaleString();
  OptionsForm.CSoftVol.Caption:=GetNextLocaleString();
  OptionsForm.CPriorityBoost.Caption:=GetNextLocaleString();
  OptionsForm.LParams.Caption:=GetNextLocaleString();
  OptionsForm.LHelp.Caption:=GetNextLocaleString();
  PlaylistForm.Caption:=GetNextLocaleString();
  PlaylistForm.BPlay.Caption:=GetNextLocaleString();
  PlaylistForm.BAdd.Caption:=GetNextLocaleString();
  PlaylistForm.BMoveUp.Caption:=GetNextLocaleString();
  PlaylistForm.BMoveDown.Caption:=GetNextLocaleString();
  PlaylistForm.BDelete.Caption:=GetNextLocaleString();
  PlaylistForm.CShuffle.Caption:=GetNextLocaleString();
  PlaylistForm.CLoop.Caption:=GetNextLocaleString();
  PlaylistForm.BSave.Caption:=GetNextLocaleString();
  PlaylistForm.BClose.Caption:=GetNextLocaleString();
  InfoForm.Caption:=GetNextLocaleString();
  InfoForm.BClose.Caption:=GetNextLocaleString();
  _.NoInfo:=GetNextLocaleString();
  _.InfoFileFormat:=GetNextLocaleString();
  _.InfoPlaybackTime:=GetNextLocaleString();
  _.InfoTags:=GetNextLocaleString();
  _.InfoVideo:=GetNextLocaleString();
  _.InfoAudio:=GetNextLocaleString();
  _.InfoDecoder:=GetNextLocaleString();
  _.InfoCodec:=GetNextLocaleString();
  _.InfoBitrate:=GetNextLocaleString();
  _.InfoVideoSize:=GetNextLocaleString();
  _.InfoVideoFPS:=GetNextLocaleString();
  _.InfoVideoAspect:=GetNextLocaleString();
  _.InfoAudioRate:=GetNextLocaleString();
  _.InfoAudioChannels:=GetNextLocaleString();
end;

end.
