import Foundation

public struct Configuration {
    public let separator: String
    public let adjectiveCapitalized: Bool
    public let nameCapitalized: Bool

    public static var snakeCased: Self { .init(separator: "_", adjectiveCapitalized: false, nameCapitalized: false) }

    public static var kebapCased: Self { .init(separator: "-", adjectiveCapitalized: false, nameCapitalized: false) }

    public static var camelCased: Self { .init(separator: "", adjectiveCapitalized: false, nameCapitalized: true) }

    public static var capitalizedCamelCased: Self { .init(separator: "", adjectiveCapitalized: true, nameCapitalized: true) }
}

func formatted(_ adjective: String, _ name: String, configuration: Configuration = .camelCased) -> String {
    let a = adjective
        .components(separatedBy: "-")
        .map { configuration.adjectiveCapitalized ? $0.capitalized : $0.lowercased() }
        .joined(separator: configuration.separator)

    let b = name
        .components(separatedBy: .whitespaces)
        .map { configuration.nameCapitalized ? $0.capitalized : $0.lowercased() }
        .joined(separator: configuration.separator)

    return "\(a)\(configuration.separator)\(b)"
}

public func randomName(_ configuration: Configuration = .capitalizedCamelCased) -> String {
    guard let adjective = StaticContent.adjectives.randomElement(), let name = StaticContent.animals.randomElement() else { return UUID().uuidString.replacingOccurrences(of: "-", with: "").lowercased() }

    return formatted(adjective, name, configuration: configuration)
}

// MARK: -

enum StaticContent {
    static let adjectives = ["adorable", "adventurous", "aggressive", "agreeable", "alert", "alive", "amused", "angry", "annoyed", "annoying", "anxious", "arrogant", "ashamed", "attractive", "average", "beautiful", "better", "bewildered", "black", "blue", "blue-eyed", "blushing", "bored", "brainy", "brave", "breakable", "bright", "busy", "calm", "careful", "cautious", "charming", "cheerful", "clean", "clear", "clever", "cloudy", "clumsy", "colorful", "combative", "comfortable", "concerned", "condemned", "confused", "cooperative", "courageous", "crazy", "creepy", "crowded", "cruel", "curious", "cute", "dangerous", "dark", "defeated", "defiant", "delightful", "depressed", "determined", "different", "difficult", "disgusted", "distinct", "disturbed", "dizzy", "doubtful", "drab", "dull", "eager", "easy", "elated", "elegant", "embarrassed", "enchanting", "encouraging", "energetic", "enthusiastic", "envious", "evil", "excited", "expensive", "exuberant", "fair", "faithful", "famous", "fancy", "fantastic", "fierce", "fine", "foolish", "fragile", "frail", "frantic", "friendly", "frightened", "funny", "gentle", "gifted", "glamorous", "gleaming", "glorious", "good", "gorgeous", "graceful", "grieving", "grotesque", "grumpy", "handsome", "happy", "healthy", "helpful", "helpless", "hilarious", "homely", "hungry", "hurt", "ill", "important", "impossible", "inexpensive", "innocent", "inquisitive", "itchy", "jealous", "jittery", "jolly", "joyous", "kind", "lazy", "light", "lively", "lonely", "long", "lovely", "lucky", "magnificent", "misty", "modern", "motionless", "muddy", "mushy", "mysterious", "nervous", "nice", "nutty", "obedient", "obnoxious", "odd", "old-fashioned", "open", "outrageous", "outstanding", "panicky", "perfect", "plain", "pleasant", "poised", "poor", "powerful", "precious", "prickly", "proud", "putrid", "puzzled", "quaint", "real", "relieved", "repulsive", "rich", "scary", "selfish", "shiny", "shy", "silly", "sleepy", "smiling", "smoggy", "sore", "sparkling", "splendid", "spotless", "stormy", "strange", "stupid", "successful", "super", "talented", "tame", "tasty", "tender", "tense", "terrible", "thankful", "thoughtful", "thoughtless", "tired", "tough", "troubled", "uninterested", "unsightly", "unusual", "upset", "uptight", "vast", "victorious", "vivacious", "wandering", "weary", "wicked", "wide-eyed", "wild", "witty", "worried", "worrisome", "wrong", "zany", "zealous"]

    static let animals = ["Aardvark", "Alligator", "Alpaca", "Anaconda", "Ant", "Antelope", "Ape", "Aphid", "Armadillo", "Asp", "Ass", "Baboon", "Badger", "Bald Eagle", "Barracuda", "Bass", "Basset Hound", "Bat", "Bear", "Beaver", "Bedbug", "Bee", "Beetle", "Bird", "Bison", "Black panther", "Black Widow Spider", "Blue Jay", "Blue Whale", "Bobcat", "Buffalo", "Butterfly", "Buzzard", "Camel", "Caribou", "Carp", "Cat", "Caterpillar", "Catfish", "Cheetah", "Chicken", "Chimpanzee", "Chipmunk", "Cobra", "Cod", "Condor", "Cougar", "Cow", "Coyote", "Crab", "Crane", "Cricket", "Crocodile", "Crow", "Cuckoo", "Deer", "Dinosaur", "Dog", "Dolphin", "Donkey", "Dove", "Dragonfly", "Duck", "Eagle", "Eel", "Elephant", "Emu", "Falcon", "Ferret", "Finch", "Fish", "Flamingo", "Flea", "Fly", "Fox", "Frog", "Goat", "Goose", "Gopher", "Gorilla", "Grasshopper", "Hamster", "Hare", "Hawk", "Hippopotamus", "Horse", "Hummingbird", "Humpback Whale", "Husky", "Iguana", "Impala", "Kangaroo", "Ladybug", "Leopard", "Lion", "Lizard", "Llama", "Lobster", "Mongoose", "Monitor lizard", "Monkey", "Moose", "Mosquito", "Moth", "Mountain goat", "Mouse", "Mule", "Octopus", "Orca", "Ostrich", "Otter", "Owl", "Ox", "Oyster", "Panda", "Parrot", "Peacock", "Pelican", "Penguin", "Perch", "Pheasant", "Pig", "Pigeon", "Polar bear", "Porcupine", "Quail", "Rabbit", "Raccoon", "Rat", "Rattlesnake", "Raven", "Rooster", "Sea lion", "Sheep", "Shrew", "Skunk", "Snail", "Snake", "Spider", "Tiger", "Walrus", "Whale", "Wolf", "Zebra"]
}
