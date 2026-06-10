import Foundation

enum RecipeCatalog {
    static let recipes: [Recipe] = [
        Recipe(
            id: "r1", title: "Creamy Tomato Pasta",
            description: "A comforting bowl of pasta in rich tomato cream sauce.",
            ingredients: ["400g pasta", "2 cups cherry tomatoes", "1 cup heavy cream", "3 garlic cloves", "Fresh basil", "Olive oil", "Salt & pepper"],
            steps: ["Boil pasta until al dente.", "Sauté garlic in olive oil.", "Add tomatoes and cook until soft.", "Stir in cream and simmer.", "Toss with pasta and basil."],
            cookTimeMinutes: 25, rating: 4.7, category: "Italian", symbolName: "fork.knife", popularity: 920, isRecommended: true,
            addedDate: Date(timeIntervalSince1970: 1_704_067_200), tags: [.vegetarian, .onePot]
        ),
        Recipe(
            id: "r2", title: "Avocado Toast Deluxe",
            description: "Crispy sourdough topped with seasoned avocado and poached egg.",
            ingredients: ["2 slices sourdough", "1 ripe avocado", "2 eggs", "Chili flakes", "Lemon juice", "Sea salt"],
            steps: ["Toast bread until golden.", "Mash avocado with lemon and salt.", "Poach eggs gently.", "Spread avocado, top with egg and chili."],
            cookTimeMinutes: 15, rating: 4.5, category: "Breakfast", symbolName: "sun.max.fill", popularity: 780, isRecommended: true,
            addedDate: Date(timeIntervalSince1970: 1_713_254_400), tags: [.vegetarian, .quick, .highProtein]
        ),
        Recipe(
            id: "r3", title: "Garden Vegetable Stir-Fry",
            description: "Colorful vegetables tossed in a savory ginger-soy glaze.",
            ingredients: ["Broccoli florets", "Bell peppers", "Snap peas", "Carrots", "Soy sauce", "Fresh ginger", "Sesame oil"],
            steps: ["Prep and slice all vegetables.", "Heat sesame oil in a wok.", "Stir-fry vegetables over high heat.", "Add ginger-soy sauce and toss."],
            cookTimeMinutes: 20, rating: 4.4, category: "Asian", symbolName: "leaf.fill", popularity: 650, isRecommended: false,
            addedDate: Date(timeIntervalSince1970: 1_705_939_200), tags: [.vegetarian, .quick, .onePot]
        ),
        Recipe(
            id: "r4", title: "Classic Chicken Soup",
            description: "Hearty homemade soup perfect for any day of the week.",
            ingredients: ["Chicken breast", "Carrots", "Celery", "Onion", "Chicken broth", "Egg noodles", "Thyme"],
            steps: ["Simmer chicken in broth.", "Add chopped vegetables.", "Shred chicken and return to pot.", "Add noodles and cook until tender."],
            cookTimeMinutes: 45, rating: 4.8, category: "Comfort", symbolName: "mug.fill", popularity: 890, isRecommended: true,
            addedDate: Date(timeIntervalSince1970: 1_696_665_600), tags: [.highProtein, .onePot]
        ),
        Recipe(
            id: "r5", title: "Mediterranean Quinoa Bowl",
            description: "Protein-packed bowl with fresh herbs and lemon dressing.",
            ingredients: ["1 cup quinoa", "Cucumber", "Cherry tomatoes", "Feta cheese", "Kalamata olives", "Lemon", "Olive oil"],
            steps: ["Cook quinoa and let cool.", "Dice vegetables.", "Whisk lemon dressing.", "Combine and top with feta and olives."],
            cookTimeMinutes: 30, rating: 4.6, category: "Healthy", symbolName: "heart.fill", popularity: 710, isRecommended: true,
            addedDate: Date(timeIntervalSince1970: 1_714_972_800), tags: [.vegetarian, .highProtein]
        ),
        Recipe(
            id: "r6", title: "Spicy Black Bean Tacos",
            description: "Quick weeknight tacos with smoky spices and fresh toppings.",
            ingredients: ["Black beans", "Tortillas", "Red onion", "Lime", "Cilantro", "Cumin", "Avocado"],
            steps: ["Warm beans with cumin and spices.", "Heat tortillas.", "Fill with beans and toppings.", "Squeeze lime and serve."],
            cookTimeMinutes: 18, rating: 4.3, category: "Mexican", symbolName: "flame.fill", popularity: 620, isRecommended: false,
            addedDate: Date(timeIntervalSince1970: 1_707_110_400), tags: [.vegetarian, .quick, .highProtein]
        ),
        Recipe(
            id: "r7", title: "Honey Garlic Salmon",
            description: "Pan-seared salmon with a sweet and savory glaze.",
            ingredients: ["Salmon fillets", "Honey", "Soy sauce", "Garlic", "Rice vinegar", "Green onions"],
            steps: ["Season salmon fillets.", "Sear skin-side down.", "Prepare honey-garlic glaze.", "Glaze salmon and finish cooking."],
            cookTimeMinutes: 22, rating: 4.9, category: "Seafood", symbolName: "fish.fill", popularity: 950, isRecommended: true,
            addedDate: Date(timeIntervalSince1970: 1_709_798_400), tags: [.quick, .highProtein]
        ),
        Recipe(
            id: "r8", title: "Berry Overnight Oats",
            description: "No-cook breakfast ready when you wake up.",
            ingredients: ["Rolled oats", "Almond milk", "Mixed berries", "Chia seeds", "Maple syrup", "Vanilla"],
            steps: ["Combine oats, milk, and chia.", "Add vanilla and maple syrup.", "Refrigerate overnight.", "Top with berries before serving."],
            cookTimeMinutes: 5, rating: 4.2, category: "Breakfast", symbolName: "cup.and.saucer.fill", popularity: 540, isRecommended: false,
            addedDate: Date(timeIntervalSince1970: 1_716_662_400), tags: [.vegetarian, .quick]
        ),
        Recipe(
            id: "r9", title: "Roasted Sweet Potato Salad",
            description: "Warm roasted roots with a tangy mustard vinaigrette.",
            ingredients: ["Sweet potatoes", "Spinach", "Red onion", "Dijon mustard", "Apple cider vinegar", "Walnuts"],
            steps: ["Roast cubed sweet potatoes.", "Whisk mustard vinaigrette.", "Toss with spinach and onion.", "Top with toasted walnuts."],
            cookTimeMinutes: 35, rating: 4.5, category: "Salads", symbolName: "carrot.fill", popularity: 480, isRecommended: false,
            addedDate: Date(timeIntervalSince1970: 1_711_958_400), tags: [.vegetarian]
        ),
        Recipe(
            id: "r10", title: "Mushroom Risotto",
            description: "Creamy arborio rice with sautéed wild mushrooms.",
            ingredients: ["Arborio rice", "Mixed mushrooms", "Vegetable broth", "Parmesan", "White wine", "Butter", "Shallots"],
            steps: ["Sauté mushrooms and set aside.", "Toast rice with shallots.", "Add wine, then broth gradually.", "Fold in mushrooms and parmesan."],
            cookTimeMinutes: 40, rating: 4.7, category: "Italian", symbolName: "takeoutbag.and.cup.and.straw.fill", popularity: 830, isRecommended: true,
            addedDate: Date(timeIntervalSince1970: 1_698_480_000), tags: [.vegetarian, .onePot]
        ),
        Recipe(
            id: "r11", title: "Lemon Herb Grilled Chicken",
            description: "Juicy chicken with a bright citrus herb marinade.",
            ingredients: ["Chicken thighs", "Lemon", "Rosemary", "Thyme", "Garlic", "Olive oil"],
            steps: ["Marinate chicken for 30 minutes.", "Preheat grill or pan.", "Cook until internal temp is safe.", "Rest and serve with lemon wedges."],
            cookTimeMinutes: 35, rating: 4.6, category: "Grill", symbolName: "flame.circle.fill", popularity: 760, isRecommended: false,
            addedDate: Date(timeIntervalSince1970: 1_703_318_400), tags: [.highProtein]
        ),
        Recipe(
            id: "r12", title: "Coconut Curry Lentils",
            description: "One-pot lentils simmered in aromatic coconut curry.",
            ingredients: ["Red lentils", "Coconut milk", "Curry powder", "Onion", "Garlic", "Spinach", "Tomato paste"],
            steps: ["Sauté onion and garlic.", "Add spices and tomato paste.", "Simmer lentils in coconut milk.", "Stir in spinach before serving."],
            cookTimeMinutes: 28, rating: 4.4, category: "Curry", symbolName: "leaf.circle.fill", popularity: 590, isRecommended: true,
            addedDate: Date(timeIntervalSince1970: 1_715_836_800), tags: [.vegetarian, .onePot, .highProtein]
        )
    ]
}
