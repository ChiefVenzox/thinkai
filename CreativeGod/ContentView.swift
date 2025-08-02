import SwiftUI
import UIKit // UIActivityViewController ve PDF işlemleri için UIKit'i içe aktarıyoruz

// Uygulamanın ana görünümünü tanımlayan yapı
struct ContentView: View {
    // Kullanıcının gireceği metni tutan durum değişkeni
    @State private var inputPrompt: String = ""

    // Yapay zeka tarafından üretilecek metni tutan durum değişkeni
    @State private var generatedContent: String = "Fikirler burada görünecek..."

    // API çağrısı sırasında yükleme durumunu göstermek için
    @State private var isLoading: Bool = false

    // Hata mesajlarını göstermek için
    @State private var errorMessage: String?

    // Görünümün içeriğini tanımlayan ana kısım
    var body: some View {
        // Dikey bir düzenleyici (elemanları üst üste dizer)
        VStack {
            // Uygulama başlığı
            Text("Yaratıcı Fikir Asistanı")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            // Kullanıcının metin gireceği alan
            TextField("Fikir için anahtar kelimeler girin...", text: $inputPrompt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            // Fikir üretme butonu
            Button("Fikir Üret") {
                // Butona basıldığında asenkron bir görev başlat
                Task {
                    await generateIdea()
                }
            }
            .font(.title2)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding(.bottom, 30)
            // Yükleme durumunda butonu devre dışı bırak
            .disabled(isLoading)

            // Yükleme göstergesi
            if isLoading {
                ProgressView("Fikir Üretiliyor...")
                    .padding()
            } else if let error = errorMessage {
                // Hata mesajı varsa göster
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                // Yapay zeka tarafından üretilen metnin gösterileceği alan
                ScrollView {
                    Text(generatedContent)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                // Paylaşma ve PDF Dışa Aktarma Butonları
                HStack {
                    Spacer() // Butonları ortaya hizalamak için

                    // Paylaşma butonu
                    Button("Paylaş") {
                        shareContent()
                    }
                    .font(.title3)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .disabled(generatedContent == "Fikirler burada görünecek...") // İçerik yoksa devre dışı bırak

                    Spacer()

                    // PDF Olarak Dışa Aktarma butonu
                    Button("PDF Olarak Aktar") {
                        exportToPDF()
                    }
                    .font(.title3)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 3)
                    .disabled(generatedContent == "Fikirler burada görünecek...") // İçerik yoksa devre dışı bırak

                    Spacer()
                }
                .padding(.top, 20)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Gemini API Entegrasyonu

    // Gemini API'sine çağrı yaparak metin üreten asenkron fonksiyon
    func generateIdea() async {
        isLoading = true // Yükleme durumunu başlat
        errorMessage = nil // Önceki hata mesajını temizle

        // API anahtarınız buraya eklendi!
        // Google AI Studio'dan aldığınız API anahtarını çift tırnaklar arasına yapıştırın.
        // Örneğin: let apiKey = "AIzaSyC..."
        let apiKey = APIKeys.geminiAPIKey// <-- API anahtarınız buraya yapıştırıldı

        // Eğer API anahtarı yoksa veya giriş metni boşsa hata ver
        guard !apiKey.isEmpty else {
            errorMessage = "API Anahtarı eksik. Lütfen kodu kendi API anahtarınızla güncelleyin."
            isLoading = false
            return
        }

        guard !inputPrompt.isEmpty else {
            errorMessage = "Lütfen bir fikir için anahtar kelimeler girin."
            isLoading = false
            return
        }

        // Gemini API endpoint'i. Model adı 'gemini-pro' yerine 'gemini-1.5-flash-latest' olarak değiştirildi.
        // Eğer bu model de çalışmazsa, Google AI Studio'dan erişilebilir modelleri kontrol edebilirsiniz.
        let urlString = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Geçersiz URL."
            isLoading = false
            return
        }

        // İstek için JSON payload'ı oluştur
        let payload: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": inputPrompt]
                    ]
                ]
            ]
        ]

        // Payload'ı JSON verisine dönüştür
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            errorMessage = "JSON verisi oluşturulamadı."
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            // API çağrısını yap
            let (data, response) = try await URLSession.shared.data(for: request)

            // HTTP yanıtını kontrol et
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "API yanıtı başarısız oldu: \( (response as? HTTPURLResponse)?.statusCode ?? 0)"
                isLoading = false
                return
            }

            // JSON yanıtını ayrıştır
            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let candidates = jsonResponse["candidates"] as? [[String: Any]],
               let firstCandidate = candidates.first,
               let content = firstCandidate["content"] as? [String: Any],
               let parts = content["parts"] as? [[String: Any]],
               let firstPart = parts.first,
               let text = firstPart["text"] as? String {
                generatedContent = text // Üretilen metni güncelle
            } else {
                errorMessage = "API yanıtı beklenenden farklı formatta."
            }
        } catch {
            errorMessage = "API çağrısı sırasında hata oluştu: \(error.localizedDescription)"
        }

        isLoading = false // Yükleme durumunu bitir
    }

    // MARK: - Paylaşma Fonksiyonu

    // Üretilen içeriği paylaşmak için UIActivityViewController kullanır
    func shareContent() {
        // Paylaşılacak içerik yoksa veya varsayılan metinse uyarı ver
        guard !generatedContent.isEmpty, generatedContent != "Fikirler burada görünecek..." else {
            errorMessage = "Paylaşılacak bir içerik yok."
            return
        }

        // Paylaşım ekranını oluşturan UIActivityViewController
        let activityViewController = UIActivityViewController(activityItems: [generatedContent], applicationActivities: nil)

        // iPad'de paylaşım ekranının düzgün çalışması için popover kaynağını belirtmek gerekebilir
        // Bu kod, uygulamanın en üstteki görünüm denetleyicisini bulmaya çalışır
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityViewController, animated: true, completion: nil)
        }
    }

    // MARK: - PDF Dışa Aktarma Fonksiyonu

    // Üretilen içeriği PDF olarak dışa aktarır ve paylaşım ekranını açar
    func exportToPDF() {
        // PDF'e dönüştürülecek içerik yoksa veya varsayılan metinse uyarı ver
        guard !generatedContent.isEmpty, generatedContent != "Fikirler burada görünecek..." else {
            errorMessage = "PDF'e dönüştürülecek bir içerik yok."
            return
        }

        // PDF meta verileri (yazar, başlık vb.)
        let pdfMetaData = [
            kCGPDFContextCreator: "Yaratıcı Fikir Asistanı",
            kCGPDFContextAuthor: "Kullanıcı Adı", // Buraya isterseniz dinamik bir kullanıcı adı ekleyebilirsiniz
            kCGPDFContextTitle: "Üretilen Fikir"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]

        // PDF sayfa boyutu (ABD Letter boyutu: 8.5 x 11 inç)
        let pageWidth = 8.5 * 72.0 // 1 inç = 72 nokta
        let pageHeight = 11 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        // PDF verisini oluştur
        let data = renderer.pdfData { (context) in
            context.beginPage() // Yeni bir sayfa başlat

            // Metin için font ve renk ayarları
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12), // Metin boyutu
                .foregroundColor: UIColor.black // Metin rengi
            ]
            // Üretilen metni NSAttributedString'e dönüştür
            let attributedString = NSAttributedString(string: generatedContent, attributes: attributes)

            // Metnin PDF sayfasında çizileceği alan (kenar boşlukları ile)
            let textRect = CGRect(x: 36, y: 36, width: pageWidth - 72, height: pageHeight - 72) // Her kenardan 0.5 inç (36 nokta) boşluk
            attributedString.draw(in: textRect) // Metni belirtilen alana çiz
        }

        // PDF'i geçici bir dosyaya kaydet ve paylaşım ekranını aç
        // Uygulamanın doküman dizininde geçici bir dosya yolu oluştururuz
        let filename = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("YaratıcıFikirAsistani_Fikir.pdf")
        do {
            try data.write(to: filename) // PDF verisini dosyaya yaz

            // Oluşturulan PDF dosyasını paylaşım ekranı ile aç
            let activityViewController = UIActivityViewController(activityItems: [filename], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityViewController, animated: true, completion: nil)
            }
        } catch {
            errorMessage = "PDF kaydedilemedi veya paylaşılamadı: \(error.localizedDescription)"
        }
    }
}

// Xcode önizlemesi için gerekli kod
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
