import '../models/meal_model.dart';

class FoodDatabase {
  static const List<FoodItem> items = [
    // Proteínas
    FoodItem(id:'f001', name:'Frango grelhado', category:'Proteínas', caloriesPer50g:82, proteinPer50g:15.5, carbsPer50g:0, fatPer50g:1.8),
    FoodItem(id:'f002', name:'Carne bovina magra', category:'Proteínas', caloriesPer50g:104, proteinPer50g:14, carbsPer50g:0, fatPer50g:5.2),
    FoodItem(id:'f003', name:'Ovo cozido (2 ovos)', category:'Proteínas', caloriesPer50g:78, proteinPer50g:6.5, carbsPer50g:0.6, fatPer50g:5.4),
    FoodItem(id:'f004', name:'Atum em lata', category:'Proteínas', caloriesPer50g:52, proteinPer50g:11.5, carbsPer50g:0, fatPer50g:0.6),
    FoodItem(id:'f005', name:'Tilápia', category:'Proteínas', caloriesPer50g:52, proteinPer50g:11, carbsPer50g:0, fatPer50g:0.8),
    FoodItem(id:'f006', name:'Peito de peru', category:'Proteínas', caloriesPer50g:55, proteinPer50g:11.5, carbsPer50g:0.5, fatPer50g:0.9),
    FoodItem(id:'f007', name:'Whey protein (1 scoop)', category:'Proteínas', caloriesPer50g:180, proteinPer50g:25, carbsPer50g:3, fatPer50g:2),
    FoodItem(id:'f008', name:'Iogurte grego', category:'Proteínas', caloriesPer50g:59, proteinPer50g:5, carbsPer50g:3.5, fatPer50g:2.5),
    FoodItem(id:'f009', name:'Queijo cottage', category:'Proteínas', caloriesPer50g:49, proteinPer50g:6, carbsPer50g:2.7, fatPer50g:1.1),
    FoodItem(id:'f010', name:'Sardinha', category:'Proteínas', caloriesPer50g:96, proteinPer50g:12, carbsPer50g:0, fatPer50g:5.5),

    // Carboidratos
    FoodItem(id:'c001', name:'Arroz branco cozido', category:'Carboidratos', caloriesPer50g:65, proteinPer50g:1.2, carbsPer50g:14.3, fatPer50g:0.1),
    FoodItem(id:'c002', name:'Arroz integral cozido', category:'Carboidratos', caloriesPer50g:56, proteinPer50g:1.3, carbsPer50g:11.8, fatPer50g:0.4),
    FoodItem(id:'c003', name:'Feijão cozido', category:'Carboidratos', caloriesPer50g:77, proteinPer50g:4.8, carbsPer50g:13.6, fatPer50g:0.5),
    FoodItem(id:'c004', name:'Batata doce cozida', category:'Carboidratos', caloriesPer50g:43, proteinPer50g:0.8, carbsPer50g:10, fatPer50g:0.1),
    FoodItem(id:'c005', name:'Batata inglesa cozida', category:'Carboidratos', caloriesPer50g:43, proteinPer50g:1, carbsPer50g:9.8, fatPer50g:0.1),
    FoodItem(id:'c006', name:'Macarrão cozido', category:'Carboidratos', caloriesPer50g:82, proteinPer50g:2.8, carbsPer50g:16.5, fatPer50g:0.5),
    FoodItem(id:'c007', name:'Aveia', category:'Carboidratos', caloriesPer50g:188, proteinPer50g:6.6, carbsPer50g:33.5, fatPer50g:3.4),
    FoodItem(id:'c008', name:'Pão integral (2 fatias)', category:'Carboidratos', caloriesPer50g:120, proteinPer50g:5, carbsPer50g:22, fatPer50g:1.5),
    FoodItem(id:'c009', name:'Mandioca cozida', category:'Carboidratos', caloriesPer50g:74, proteinPer50g:0.7, carbsPer50g:17.8, fatPer50g:0.1),
    FoodItem(id:'c010', name:'Lentilha cozida', category:'Carboidratos', caloriesPer50g:59, proteinPer50g:4.5, carbsPer50g:10.1, fatPer50g:0.2),

    // Gorduras saudáveis
    FoodItem(id:'g001', name:'Abacate', category:'Gorduras', caloriesPer50g:80, proteinPer50g:0.9, carbsPer50g:2.1, fatPer50g:7.5),
    FoodItem(id:'g002', name:'Amendoim', category:'Gorduras', caloriesPer50g:292, proteinPer50g:12.6, carbsPer50g:9.5, fatPer50g:22.7),
    FoodItem(id:'g003', name:'Castanha do Pará', category:'Gorduras', caloriesPer50g:328, proteinPer50g:7.2, carbsPer50g:6.1, fatPer50g:30.7),
    FoodItem(id:'g004', name:'Azeite de oliva (colher)', category:'Gorduras', caloriesPer50g:442, proteinPer50g:0, carbsPer50g:0, fatPer50g:50),
    FoodItem(id:'g005', name:'Pasta de amendoim', category:'Gorduras', caloriesPer50g:299, proteinPer50g:12.3, carbsPer50g:12, fatPer50g:23),

    // Frutas
    FoodItem(id:'fr001', name:'Banana', category:'Frutas', caloriesPer50g:45, proteinPer50g:0.6, carbsPer50g:11.6, fatPer50g:0.1),
    FoodItem(id:'fr002', name:'Maçã', category:'Frutas', caloriesPer50g:27, proteinPer50g:0.1, carbsPer50g:7, fatPer50g:0.1),
    FoodItem(id:'fr003', name:'Morango', category:'Frutas', caloriesPer50g:16, proteinPer50g:0.4, carbsPer50g:3.7, fatPer50g:0.1),
    FoodItem(id:'fr004', name:'Manga', category:'Frutas', caloriesPer50g:33, proteinPer50g:0.4, carbsPer50g:8.2, fatPer50g:0.1),
    FoodItem(id:'fr005', name:'Melancia', category:'Frutas', caloriesPer50g:16, proteinPer50g:0.3, carbsPer50g:3.8, fatPer50g:0.1),

    // Laticínios
    FoodItem(id:'l001', name:'Leite desnatado', category:'Laticínios', caloriesPer50g:17, proteinPer50g:1.7, carbsPer50g:2.4, fatPer50g:0.1),
    FoodItem(id:'l002', name:'Queijo mussarela', category:'Laticínios', caloriesPer50g:157, proteinPer50g:11.3, carbsPer50g:2.2, fatPer50g:11.5),
    FoodItem(id:'l003', name:'Requeijão light', category:'Laticínios', caloriesPer50g:80, proteinPer50g:6, carbsPer50g:5, fatPer50g:3.5),

    // Legumes e verduras
    FoodItem(id:'v001', name:'Brócolis cozido', category:'Vegetais', caloriesPer50g:14, proteinPer50g:1.5, carbsPer50g:2.1, fatPer50g:0.2),
    FoodItem(id:'v002', name:'Espinafre', category:'Vegetais', caloriesPer50g:12, proteinPer50g:1.5, carbsPer50g:1, fatPer50g:0.2),
    FoodItem(id:'v003', name:'Cenoura', category:'Vegetais', caloriesPer50g:21, proteinPer50g:0.5, carbsPer50g:4.8, fatPer50g:0.1),
    FoodItem(id:'v004', name:'Abobrinha', category:'Vegetais', caloriesPer50g:10, proteinPer50g:0.7, carbsPer50g:1.8, fatPer50g:0.1),
    FoodItem(id:'v005', name:'Tomate', category:'Vegetais', caloriesPer50g:10, proteinPer50g:0.5, carbsPer50g:2.1, fatPer50g:0.1),
  ];

  static List<String> get categories {
    return items.map((f) => f.category).toSet().toList()..sort();
  }

  static List<FoodItem> byCategory(String category) {
    return items.where((f) => f.category == category).toList();
  }

  static List<FoodItem> search(String query) {
    final q = query.toLowerCase();
    return items.where((f) => f.name.toLowerCase().contains(q)).toList();
  }
}
