//
//  VocabularyService.swift
//  Language Immersion Rooms
//
//  Vocabulary and translation service
//

import Foundation

class VocabularyService: VocabularyServiceProtocol {
    // In-memory vocabulary database for MVP
    // In production, this would be in CoreData or a proper database
    private var vocabularyDatabase: [String: VocabularyWord] = [:]

    init() {
        loadSpanishVocabulary()
        print("📚 VocabularyService initialized with \(vocabularyDatabase.count) words")
    }

    // MARK: - Translation

    func translate(_ word: String, to language: Language) async -> String? {
        // Look up in database
        let key = word.lowercased()
        return vocabularyDatabase[key]?.translation
    }

    // MARK: - Get Vocabulary

    func getVocabulary(for category: String, language: Language) -> [VocabularyWord] {
        return vocabularyDatabase.values.filter { $0.category == category && $0.language == language }
    }

    // MARK: - Save Word

    func saveWord(_ word: VocabularyWord) {
        vocabularyDatabase[word.word.lowercased()] = word
    }

    // MARK: - Load Spanish Vocabulary (MVP)

    private func loadSpanishVocabulary() {
        // 100 common household objects in Spanish for MVP
        let vocabulary: [(english: String, spanish: String, category: String)] = [
            // Kitchen (20 words)
            ("table", "mesa", "kitchen"),
            ("chair", "silla", "kitchen"),
            ("refrigerator", "refrigerador", "kitchen"),
            ("stove", "estufa", "kitchen"),
            ("microwave", "microondas", "kitchen"),
            ("oven", "horno", "kitchen"),
            ("sink", "fregadero", "kitchen"),
            ("plate", "plato", "kitchen"),
            ("cup", "taza", "kitchen"),
            ("glass", "vaso", "kitchen"),
            ("fork", "tenedor", "kitchen"),
            ("knife", "cuchillo", "kitchen"),
            ("spoon", "cuchara", "kitchen"),
            ("pot", "olla", "kitchen"),
            ("pan", "sartén", "kitchen"),
            ("bowl", "tazón", "kitchen"),
            ("bottle", "botella", "kitchen"),
            ("kettle", "tetera", "kitchen"),
            ("toaster", "tostadora", "kitchen"),
            ("blender", "licuadora", "kitchen"),

            // Living Room (20 words)
            ("sofa", "sofá", "living_room"),
            ("couch", "sofá", "living_room"),
            ("television", "televisión", "living_room"),
            ("lamp", "lámpara", "living_room"),
            ("book", "libro", "living_room"),
            ("remote", "control remoto", "living_room"),
            ("pillow", "almohada", "living_room"),
            ("cushion", "cojín", "living_room"),
            ("carpet", "alfombra", "living_room"),
            ("rug", "tapete", "living_room"),
            ("curtain", "cortina", "living_room"),
            ("window", "ventana", "living_room"),
            ("door", "puerta", "living_room"),
            ("wall", "pared", "living_room"),
            ("ceiling", "techo", "living_room"),
            ("floor", "piso", "living_room"),
            ("shelf", "estante", "living_room"),
            ("picture", "cuadro", "living_room"),
            ("plant", "planta", "living_room"),
            ("vase", "jarrón", "living_room"),

            // Bedroom (15 words)
            ("bed", "cama", "bedroom"),
            ("mattress", "colchón", "bedroom"),
            ("blanket", "manta", "bedroom"),
            ("sheet", "sábana", "bedroom"),
            ("pillow", "almohada", "bedroom"),
            ("dresser", "cómoda", "bedroom"),
            ("closet", "armario", "bedroom"),
            ("mirror", "espejo", "bedroom"),
            ("alarm", "alarma", "bedroom"),
            ("nightstand", "mesita de noche", "bedroom"),
            ("wardrobe", "guardarropa", "bedroom"),
            ("hanger", "percha", "bedroom"),
            ("drawer", "cajón", "bedroom"),
            ("lamp", "lámpara", "bedroom"),
            ("clock", "reloj", "bedroom"),

            // Bathroom (15 words)
            ("sink", "lavabo", "bathroom"),
            ("toilet", "inodoro", "bathroom"),
            ("shower", "ducha", "bathroom"),
            ("bathtub", "bañera", "bathroom"),
            ("towel", "toalla", "bathroom"),
            ("soap", "jabón", "bathroom"),
            ("shampoo", "champú", "bathroom"),
            ("toothbrush", "cepillo de dientes", "bathroom"),
            ("toothpaste", "pasta de dientes", "bathroom"),
            ("mirror", "espejo", "bathroom"),
            ("faucet", "grifo", "bathroom"),
            ("toilet paper", "papel higiénico", "bathroom"),
            ("brush", "cepillo", "bathroom"),
            ("comb", "peine", "bathroom"),
            ("razor", "navaja", "bathroom"),

            // Office/Study (15 words)
            ("desk", "escritorio", "office"),
            ("chair", "silla", "office"),
            ("computer", "computadora", "office"),
            ("laptop", "portátil", "office"),
            ("keyboard", "teclado", "office"),
            ("mouse", "ratón", "office"),
            ("monitor", "monitor", "office"),
            ("pen", "bolígrafo", "office"),
            ("pencil", "lápiz", "office"),
            ("paper", "papel", "office"),
            ("notebook", "cuaderno", "office"),
            ("book", "libro", "office"),
            ("lamp", "lámpara", "office"),
            ("printer", "impresora", "office"),
            ("phone", "teléfono", "office"),

            // General (15 words)
            ("light", "luz", "general"),
            ("switch", "interruptor", "general"),
            ("outlet", "enchufe", "general"),
            ("cable", "cable", "general"),
            ("bag", "bolsa", "general"),
            ("box", "caja", "general"),
            ("basket", "canasta", "general"),
            ("trash", "basura", "general"),
            ("bin", "papelera", "general"),
            ("key", "llave", "general"),
            ("phone", "teléfono", "general"),
            ("clock", "reloj", "general"),
            ("fan", "ventilador", "general"),
            ("heater", "calentador", "general"),
            ("air conditioner", "aire acondicionado", "general")
        ]

        // Convert to VocabularyWord objects
        for item in vocabulary {
            let word = VocabularyWord(
                word: item.spanish,
                translation: item.english,
                language: .spanish,
                category: item.category
            )
            vocabularyDatabase[item.english.lowercased()] = word
        }
    }

    // MARK: - Helper Methods

    func getAllWords() -> [VocabularyWord] {
        return Array(vocabularyDatabase.values)
    }

    func searchWords(_ query: String, language: Language) -> [VocabularyWord] {
        let lowercaseQuery = query.lowercased()
        return vocabularyDatabase.values.filter {
            $0.language == language &&
            ($0.word.lowercased().contains(lowercaseQuery) ||
             $0.translation.lowercased().contains(lowercaseQuery))
        }
    }

    func getWordsByCategory(_ category: String, language: Language) -> [VocabularyWord] {
        return vocabularyDatabase.values.filter {
            $0.language == language && $0.category == category
        }
    }

    func getCategories(for language: Language) -> [String] {
        let categories = Set(vocabularyDatabase.values
            .filter { $0.language == language }
            .map { $0.category })
        return Array(categories).sorted()
    }
}
