
import 'package:get/get_navigation/src/root/internacionalization.dart';
import 'package:maktrogps/getx_localization/en_us.dart';
import 'package:maktrogps/getx_localization/fr_CA.dart';

import 'ar_EG.dart';
import 'ar_SA.dart';

class languages extends  Translations{


  Map<String ,Map<String,String>> get keys => {
    'en_US':en_US,
// french
    'fr_CA':fr_CA,

    // saudi arbia arabic
    'ar_SA':ar_SA,
  // moroco arabic
    'ar_EG':ar_EG,
    'ur_PK':{
      // login screen
      'Username':'صارف کا نام',
      'Password':'پاس ورڈ',
//map screen
      'RUNNING':'چل رہا ہے',
      'STOPED':'روک دیا گیا',
      'IDLE':'فارغ',
      'INACTIVE':'غیر فعال',
      'EXPIRED':'میعاد ختم',

//bottom navigation bar
      'List':'فہرست',
      'Map':'نقشہ',
      'Dashboard':'ڈیش بورڈ',
      'Events':'واقعات',
      'Menu':'مینو',

//list screen
      'All Vehicles':'تمام گاڑیاں',
      'Running':'چل رہا ہے',
      'Stopped':'روک دیا گیا',
      'Idle':'فارغ',
      'InActive':'غیر فعال',
      'Expired':'میعاد ختم',
      'NotConnected':'مربوط نہیں',
      'LastPacket':'آخری پیکٹ',
      'TotalMI':'کل میل',
      'EngineHours':'انجن کے گھنٹے',
      'Speed':'رفتار',
      'Since':'سے',
//list dialog
      'LiveMap':'لائیو نقشہ',
      'Mileage':'میلیج',
      'Playback':'پلے بیک',
      'Reports':'رپورٹس',
      'Lock':'تالا',
      'VehicleInfo':'گاڑی کی معلومات',
      'Trips':'سفر',
      'Share':'شیئر کریں',
      'NearBy':'قریبی',

//live screen
      'ViewAddress':'پتہ دیکھیں',
      'Odometer':'اوڈومیٹر',
      'Tracking':'ٹریکنگ',
      'Dashboard':'ڈیش بورڈ',
      'Playback':'پلے بیک',
      'Lock':'تالا',
      'VehicleSetting':'گاڑی کی ترتیبات',
      'Analytics':'تجزیات',
      'Alerts':'الرٹس',

//dashboard
      'TodayAlerts':'آج کے الرٹس',
      'Geofence':'جیوفینس',
      'Overspeed':'تیز رفتاری',
      'ExcessIdle':'زیادہ فارغ',
      'Parked':'پارک کیا گیا',
      'IgnitionOn':'اگنیشن آن',
      'IgnitionOff':'اگنیشن آف',

//playback & km detail
      'Yesterday':'گزشتہ روز',
      'Last7Days':'پچھلے 7 دن',
      'ViewMIDetial':'میل کی تفصیل دیکھیں',
      'ViewPlaybackHistory':'پلے بیک کی تاریخ دیکھیں',

//setting screen
      'More':'مزید',
      'PayNow':'ابھی ادا کریں',
      'Support':'سپورٹ',
      'Alerts':'الرٹس',
      'GeofenceSetting':'جیوفینس کی ترتیبات',
      'Overspeeding':'تیز رفتاری',
      'ChangeLanguage':'زبان تبدیل کریں',
      'ChangeDeviceSetting':'ڈیوائس کی ترتیبات تبدیل کریں',
      'RegisterANewDevice':'نئی ڈیوائس رجسٹر کریں',
      'ChangeLanguage':'زبان تبدیل کریں',

      'NotificationSetting':'اطلاعات کی ترتیبات',

      'ChangePassword':'پاس ورڈ تبدیل کریں',
      'SignOut':'سائن آؤٹ',
    }  ,


    'bn_BD':{
      'email_hint':'Email UR'
    }  ,


    'spa_SV':{
      'RUNNING':'CORRIENDO',
      'STOPED':'DETENIDO',
      'IDLE':'RALENTY',
      'INACTIVE':'INACTIVO',
      'EXPIRED':'EXPIRADO'
    },

    // Germany
    'de_DE':{
      /// login screen : Anmeldebildschirm
      'Username':'Benutzername',
      'Password':'Passwort',
      //map screen : Kartenansicht
      'RUNNING':'Fahrende',
      'STOPED':'Stehende',
      'IDLE':'Leerlauf',
      'INACTIVE':'Kein Signal',
      'EXPIRED':'Abo Abgelaufen',

      //bottom naviigation bar :Untere Navigationsleiste
      'List':'Fahrezeuge',
      'Map':'Karte',
      'Dashboard':'Berichte',
      'Events':'Alarme',
      'Menu':'Menu',

      //list screen: Listenbildschirm
      'All Vehicles':'Alle',
      'Running':'Fahrende',
      'Stopped':'Stehende',
      'Idle':'Leerlauf',
      'InActive':'Kein Signal',
      'Expired':'Abo Abgelaufen',
      'NotConnected':'Nicht verbunden',
      'LastPacket':'Letzte Verbindung',
      'TotalMI':'Tägl.Kilometerstand ',
      'EngineHours':'Zündungszeit',
      'Speed':'Geschwindigkeit',
      'Since':'Seit',
      //list dialog :Infoboard
      'LiveMap':'Live Orten',
      'Mileage':'Reise info',
      'Playback':'Reise Bericht',
      'Reports':'Fahrtenbuch',
      'Lock':'Fahrzeug Stoppen',
      'VehicleInfo':'Fahrzeug-info',
      'Trips':'Reisen',
      'Share':'Standort Senden',
      'NearBy':'Reisebedarf',
      //live screen: Live-Bildschirm
      'ViewAddress':'Adresse anzeigen',
      'Odometer':'Gesamtkilometer',
      'Tracking':'Verfolgung',
      'Dashboard':'Mehr',
      'Playback':'Wiedergabe',
      'Lock':'Sperren',
      'VehicleSetting':'Fahrzeugeinstellung',
      'Analytics':'Analytics',
      'Alerts':'Alarme',
      //dashboard: Gesamt Berichte
      'TodayAlerts':'Tägliche Benachrichtigungen',
      'Geofence':'Definierte Zone',
      'Overspeed':'Übergeschwindigkeit',
      'ExcessIdle':'Übermäßiger Leerlauf',
      'Parked':'Geparkt',
      'IgnitionOn':'Zündung an',
      'IgnitionOff':'Zündung aus',
      //Playback & Km Detail: Reise Bericht und Km-Details
      'Yesterday':'Gestern',
      'Last7Days':'Letzten 7 Tage',
      'ViewMIDetial':'Km-Details anzeigen',
      'ViewPlaybackHistory':'Reise Details',

      //Setting screen: Einstellungs Bildschirm
      'More':'Mehr',
      'PayNow':'Zahlen Sie jetzt',
      'Support':'Support',
      'Alerts':'Alarme / Warnungen',
      'GeofenceSetting':'Definierte Zone Einstellung',
      'Overspeeding':'Übergeschwindigkeit',
      'ChangeLanguage':'Sprache ändern',
      'ChangeDeviceSetting':'Geräteeinstellung ändern',
      'RegisterANewDevice':'Geräte Hinzufügen',
      'ChangeLanguage':'Sprache ändern',

      'NotificationSetting':'Benachrichtigung Ein / Aus',

      'ChangePassword':'Kennwort ändern',
      'SignOut':'Abmelden',
      'Send Command':'Send Command',

    },
    //turkish
    'tr_TR':{
      /// login screen : Giriş ekranı
      'Username':'Kullanıcı adı',
      'Password':'Şifre',
      //map screen : Harita Görünümü
      'RUNNING':'Hareketli',
      'STOPED':'Duran',
      'IDLE':'Rölanti',
      'INACTIVE':'Sinyal Yok',
      'EXPIRED':'Abonelik Yok',

      //bottom naviigation bar : Alt Kategoriler
      'List':'Araçlarım',
      'Map':'Harita',
      'Dashboard':'Rapor Yönetimi',
      'Events':'Bildirimler',
      'Menu':'Menü',

      //list screen: Liste ekranı
      'All Vehicles':'Tümü',
      'Running':'Hareketli',
      'Stopped':'Duran',
      'Idle':'Rölanti',
      'InActive':'Sinyal Yok',
      'Expired':'Abonelik Yok',
      'NotConnected':'Bağlı değil',
      'LastPacket':'Son Bağlantı',
      'TotalMI':'Günlük Km ',
      'EngineHours':'Kontak Süresi',
      'Speed':'Hiz',
      'Since':'Son Bilgi',
      //list dialog :Bilgi panosu
      'LiveMap':'Canli izle',
      'Mileage':'Seyahat Bilgileri',
      'Playback':'Seyahat Özet Raporu',
      'Reports':'Aktivite Raporu',
      'Lock':'Araci Bloke et!',
      'VehicleInfo':'Araç Bilgisi',
      'Trips':'Seyahat',
      'Share':'Konum Gönder',
      'NearBy':'Seyahat Yardimi',
      //live screen: Ana ekran
      'ViewAddress':'Adresi Göster',
      'Odometer':'Km Göstergesi',
      'Tracking':'İzlemek',
      'Dashboard':'Menü',
      'Playback':'Seyahat Özet Raporu',
      'Lock':'Bloke Et',
      'VehicleSetting':'Arac Yönetimi',
      'Analytics':'Analiz',
      'Alerts':'Bildirimler',
      //dashboard: Toplam Raporlar
      'TodayAlerts':'Günlük Bildirimler',
      'Geofence':'Tanımlanmış Bölge',
      'Overspeed':'Aşırı Hız',
      'ExcessIdle':'Aşırı Rölanti',
      'Parked':'Park Halinde',
      'IgnitionOn':'Kontak Acik',
      'IgnitionOff':'Kontak Kapali',
      //Playback & Km Detail: Seyahat Raporu ve Km Ayrıntıları
      'Yesterday':'Dün',
      'Last7Days':' Son 7 Gün',
      'ViewMIDetial':'Km Detaylari Görüntüle',
      'ViewPlaybackHistory':'Seyahat Detaylari',

      //Setting screen: Ayarlar Ekranı
      'More':'Daha Fazla',
      'PayNow':'Fatura Öde €',
      'Support':'Müşteri Hizmetleri',
      'Alerts':'Bildirimler',
      'GeofenceSetting':'Özel Bölge ayarı',
      'Overspeeding':'Aşırı hız Bildirimleri',
      'ChangeLanguage':'Dili Değiştir',
      'ChangeDeviceSetting':'Cihaz Ayarlarini Değiştir ',
      'RegisterANewDevice':'Cihaz Ekle',
      'ChangeLanguage':'Dil seçimi',

      'NotificationSetting':'Bildirimleri Aç /Kapat',

      'ChangePassword':'Şifre Değiştir',
      'SignOut':'Çıkış Yap',
    },
  //pt-BR	Portuguese (Brazil)
  'pt_BR':{
  /// login screen
  'Username':'Nome de usuário',
  'Password':'Senha',
  //map screen
  'RUNNING':'CORRENDO',
  'STOPED':'PARADO',
  'IDLE':'DORMINDO',
  'INACTIVE':'INATIVO',
  'EXPIRED':'EXPIRADO',

  //bottom naviigation bar
  'List':'Lista',
  'Map':'Mapa',
  'Dashboard':'Painel',
  'Events':'Eventos',
  'Menu':'Menu',

  //list screen
  'All Vehicles':'Todos Veículos',
  'Running':'Correndo',
  'Stopped':'Parado',
  'Idle':'Inativo',
  'InActive':'Ativo',
  'Expired':'Expirado',
  'NotConnected':'Não Connectado',
  'LastPacket':'Ultimo Pacote',
  'TotalMI':'MeuTotal',
  'EngineHours':'Motor Horas',
  'Speed':'velocidade',
  'Since':'Desde',
  //list dialog
  'LiveMap':'Mapa ao vivo',
  'Mileage':'Quilometragem',
  'Playback':'Reprodução',
  'Reports':'Relatorio',
  'Lock':'Bloquear',
  'VehicleInfo':'Veiculo informação',
  'Trips':'Viagens',
  'Share':'Compatilhe',
  'NearBy':'Perto',
  //live screen
  'ViewAddress':'Ver Endereço',
  'Odometer':'Odometro',
  'Tracking':'Rastreamento',
  'Dashboard':'Painel',
  'Playback':'Reprodução',
  'Lock':'Bloquear',
  'VehicleSetting':'Configuração do veículo',
  'Analytics':'Analítica',
  'Alerts':'Alertas',
  //dashboard
  'TodayAlerts':'Today Alertas',
  'Geofence':'Cerca geográfica',
  'Overspeed':'Overspeed',
  'ExcessIdle':'Excesso de inatividade',
  'Parked':'Estacionado',
  'IgnitionOn':'Ignição ligada',
  'IgnitionOff':'Ignição Desligada',
  //playback & km detail
  'Yesterday':'Ontem',
  'Last7Days':'Últimos 7 Dias',
  'ViewMIDetial':'Ver MI Detial',
  'ViewPlaybackHistory':'Ver histórico de reprodução',

  //settign screen
  'More':'Mais',
  'PayNow':'Pay Now',
  'Support':'Suporte',
  'Alerts':'Alertas',
  'GeofenceSetting':'Configuração de cerca geográfica',
  'Overspeeding':'Overspeeding',
  'ChangeLanguage':'Excesso de velocidade',
  'ChangeDeviceSetting':'Alterar configuração do dispositivo',
  'RegisterANewDevice':'Registrar um novo dispositivo',
  'ChangeLanguage':'Alterar pais',

  'NotificationSetting':'Configuração de notificação',

  'ChangePassword':'Configuração de notificação',
  'SignOut':'Sair',
}
  };
}