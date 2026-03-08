// #include <WiFi.h>
// #include <Firebase_ESP_Client.h>
// #include <Wire.h>
// #include <LiquidCrystal_I2C.h>
// #include <Adafruit_PN532.h>
// #include <Keypad.h>
// #include <ESP32Servo.h>
// #include <ThreeWire.h>  
// #include <RtcDS1302.h>
// #include <TOTP.h>

// // --- THÔNG TIN KẾT NỐI (Cần điền) ---
// #define WIFI_SSID "Ten_Wifi"
// #define WIFI_PASS "Mat_Khau_Wifi"
// #define DATABASE_URL ""
// #define DATABASE_SECRET "Database_Secrets"

// // --- CẤU HÌNH CHÂN (ESP32-S3) ---
// #define SDA_PIN 8
// #define SCL_PIN 9
// #define SERVO_PIN 14
// #define BUZZER_PIN 17
// #define LED_DO 16
// #define LED_XANH 15

// // DS1302
// ThreeWire myWire(11, 10, 12); 
// RtcDS1302<ThreeWire> Rtc(myWire);

// // TOTP Key (Phải khớp với hmacKey trong code cũ của bạn)
// uint8_t hmacKey[] = { 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x30 };
// TOTP totp = TOTP(hmacKey, 20);

// // Keypad
// const byte ROWS = 4, COLS = 4;
// char keys[ROWS][COLS] = { {'1','2','3','A'}, {'4','5','6','B'}, {'7','8','9','C'}, {'*','0','#','D'} };
// byte rowPins[ROWS] = {1, 2, 42, 41};
// byte colPins[COLS] = {40, 39, 38, 37};
// Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

// // Đối tượng Firebase & Thiết bị
// FirebaseData fbdo;
// FirebaseAuth auth;
// FirebaseConfig config;
// Servo doorServo;
// LiquidCrystal_I2C lcd(0x27, 16, 2);
// Adafruit_PN532 nfc(SDA_PIN, SCL_PIN);

// // Biến Logic
// String masterPassword = "123456";
// String inputBuffer = "";
// int failCount = 0;
// unsigned long lockUntil = 0;
// String lastUsedOTP = "";
// const String ADMIN_CARD_UID = "03:AD:13:F8"; // Thay bằng UID thẻ của bạn

// // --- HÀM HỖ TRỢ ---
// void sendLog(String user, String method, String action) {
//     FirebaseJson json;
//     RtcDateTime now = Rtc.GetDateTime();
//     char timeBuf[25];
//     sprintf(timeBuf, "%02d:%02d %02d/%02d/%d", now.Hour(), now.Minute(), now.Day(), now.Month(), now.Year());
    
//     json.add("user", user);
//     json.add("method", method);
//     json.add("action", action);
//     json.add("time", String(timeBuf));
//     Firebase.RTDB.pushJSON(&fbdo, "/logs", &json);
// }

// void openDoor(String user, String method) {
//     lcd.clear(); lcd.print("ACCESS GRANTED");
//     lcd.setCursor(0, 1); lcd.print("Welcome!");
//     sendLog(user, method, "Mo Cua");
    
//     doorServo.write(90); 
//     digitalWrite(LED_XANH, HIGH); tone(BUZZER_PIN, 2000, 200);
//     Firebase.RTDB.setInt(&fbdo, "/device_control/door_status", 1);
    
//     delay(3000); // Cửa mở trong 3 giây
    
//     doorServo.write(0);
//     digitalWrite(LED_XANH, LOW);
//     Firebase.RTDB.setInt(&fbdo, "/device_control/door_status", 0);
//     lcd.clear(); lcd.print("DOOR CLOSED");
//     delay(1000);
//     showNormalScreen();
// }

// void showNormalScreen() {
//     lcd.clear();
//     lcd.print("Scan Card / PIN");
//     lcd.setCursor(0, 1); lcd.print("System Ready");
// }

// // --- SETUP ---
// void setup() {
//     Serial.begin(115200);
//     pinMode(LED_DO, OUTPUT); pinMode(LED_XANH, OUTPUT); pinMode(BUZZER_PIN, OUTPUT);
    
//     Wire.begin(SDA_PIN, SCL_PIN);
//     lcd.init(); lcd.backlight();
//     Rtc.Begin();
//     nfc.begin(); nfc.SAMConfig();
//     doorServo.attach(SERVO_PIN); doorServo.write(0);

//     WiFi.begin(WIFI_SSID, WIFI_PASS);
//     Serial.print("Connecting WiFi");
//     while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
    
//     config.database_url = DATABASE_URL;
//     config.signer.tokens.legacy_token = DATABASE_SECRET;
//     Firebase.begin(&config, &auth);
//     Firebase.reconnectWiFi(true);
    
//     showNormalScreen();
// }

// // --- LOOP ---
// void loop() {
//     if (Firebase.ready()) {
//         // 1. Lắng nghe lệnh từ App Flutter
//         if (Firebase.RTDB.getInt(&fbdo, "/device_control/door_status")) {
//             if (fbdo.intData() == 1) openDoor("Admin", "App Flutter");
//         }
        
//         // 2. Cập nhật mật mã Master từ App (Trang Settings)
//         if (Firebase.RTDB.getString(&fbdo, "/device_control/master_password")) {
//             masterPassword = fbdo.stringData();
//         }
//     }

//     // Xử lý khóa hệ thống nếu nhập sai 3 lần
//     if (lockUntil > 0) {
//         if (millis() < lockUntil) {
//             lcd.setCursor(0, 0); lcd.print("LOCKED! Wait...");
//             return;
//         } else { lockUntil = 0; failCount = 0; showNormalScreen(); }
//     }

//     // 3. XỬ LÝ RFID
//     uint8_t uid[] = { 0, 0, 0, 0, 0, 0, 0 };
//     uint8_t uidLength;
//     if (nfc.readPassiveTargetID(PN532_MIFARE_ISO14443A, uid, &uidLength, 50)) {
//         String uidStr = "";
//         for (uint8_t i = 0; i < uidLength; i++) {
//             uidStr += (uid[i] < 0x10 ? "0" : "") + String(uid[i], HEX) + (i == uidLength - 1 ? "" : ":");
//         }
//         uidStr.toUpperCase();
        
//         if (uidStr == ADMIN_CARD_UID) openDoor("Admin", "The RFID");
//         else {
//             lcd.clear(); lcd.print("INVALID CARD");
//             sendLog("Unknown", "RFID", "Tu choi - Sai the");
//             digitalWrite(LED_DO, HIGH); tone(BUZZER_PIN, 500, 500); delay(1000); digitalWrite(LED_DO, LOW);
//             showNormalScreen();
//         }
//     }

//     // 4. XỬ LÝ KEYPAD
//     char key = keypad.getKey();
//     if (key) {
//         tone(BUZZER_PIN, 3000, 50);
//         if (key == '#') {
//             // Kiểm tra OTP
//             long utcOffset = 7 * 3600;
//             String currentOTP = String(totp.getCode(Rtc.GetDateTime().TotalSeconds() - utcOffset));
//             while (currentOTP.length() < 6) currentOTP = "0" + currentOTP;

//             if (inputBuffer == masterPassword) {
//                 failCount = 0; openDoor("User", "Ban phim (PIN)");
//             } else if (inputBuffer == currentOTP && inputBuffer != lastUsedOTP) {
//                 lastUsedOTP = inputBuffer;
//                 failCount = 0; openDoor("Guest", "Ban phim (OTP)");
//             } else {
//                 failCount++;
//                 lcd.clear(); lcd.print("WRONG PIN!");
//                 sendLog("Unknown", "Keypad", "Tu choi - Sai PIN");
//                 if (failCount >= 3) {
//                     lockUntil = millis() + 30000;
//                     sendLog("System", "Bao mat", "KHOA HE THONG 30s");
//                 }
//                 digitalWrite(LED_DO, HIGH); delay(1000); digitalWrite(LED_DO, LOW);
//                 showNormalScreen();
//             }
//             inputBuffer = "";
//         } else if (key == '*') {
//             inputBuffer = ""; showNormalScreen();
//         } else {
//             inputBuffer += key;
//             lcd.setCursor(0, 1); lcd.print("In: ");
//             for(int i=0; i<inputBuffer.length(); i++) lcd.print("*");
//         }
//     }
// }




