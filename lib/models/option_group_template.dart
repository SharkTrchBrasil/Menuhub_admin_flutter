import 'package:totem_pro_admin/models/option_group.dart';
import 'package:totem_pro_admin/models/option_item.dart';
import 'package:uuid/uuid.dart';

import '../core/enums/category_template_type.dart';
import '../core/enums/option_group_type.dart';

/// Contém modelos pré-prontos de grupos de opções para acelerar a criação de categorias.
class CategoryTemplates {
  static final _uuid = const Uuid();

  /// Template para uma categoria de Pizzas.
  static List<OptionGroup> forPizza() {
    return [
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Tamanho',
        minSelection: 1,
        maxSelection: 1,
        groupType: OptionGroupType.size,     // ✅ Definido aqui!
        isConfigurable: false,

        // ✅ TAMANHO
        items: [
          OptionItem(
              localId: _uuid.v4(), name: 'Pequena', slices: 4, maxFlavors: 1),
          OptionItem(
              localId: _uuid.v4(), name: 'Média', slices: 6, maxFlavors: 2),
          OptionItem(
              localId: _uuid.v4(), name: 'Grande', slices: 8, maxFlavors: 3),
          OptionItem(
              localId: _uuid.v4(), name: 'Família', slices: 12, maxFlavors: 4),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Massa',
        minSelection: 1,
        maxSelection: 1,
        groupType: OptionGroupType.generic,  // ✅ Definido aqui!
        isConfigurable: false,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Tradicional'),

        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Borda',
        minSelection: 0,
        maxSelection: 1,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Sem Borda', price: 0),

        ],
      ),

    ];
  }

  /// Template para uma categoria de Açaí.
  static List<OptionGroup> forAcai() {
    return [
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Tamanho do Copo',
        minSelection: 1,
        maxSelection: 1,
        groupType: OptionGroupType.size,
        // ✅ TAMANHO
        items: [
          OptionItem(localId: _uuid.v4(), name: '300ml', ),
          OptionItem(localId: _uuid.v4(), name: '500ml', ),
          OptionItem(localId: _uuid.v4(), name: '700ml', ),
          OptionItem(localId: _uuid.v4(), name: '1 Litro',),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Frutas (Escolha até 3)',
        minSelection: 0,
        maxSelection: 3,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Banana', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Morango', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Kiwi', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Manga', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Blueberry', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Abacaxi', price: 50),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Acompanhamentos (Escolha até 5)',
        minSelection: 0,
        maxSelection: 5,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Leite em pó', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Leite condensado', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Granola', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Paçoca', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Mel', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Castanhas', price: 200),
          OptionItem(
              localId: _uuid.v4(), name: 'Chocolate Granulado', price: 100),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Creme',
        minSelection: 0,
        maxSelection: 1,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Sem creme extra', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Creme de Ninho', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Creme de Morango', price: 200),
          OptionItem(
              localId: _uuid.v4(), name: 'Creme de Chocolate', price: 200),
        ],
      ),
    ];
  }

  /// Template para uma categoria de Lanches.
  static List<OptionGroup> forLanches() {
    return [
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Tipo de Pão',
        minSelection: 1,
        maxSelection: 1,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Pão de Hambúrguer'),
          OptionItem(localId: _uuid.v4(), name: 'Pão Australiano'),
          OptionItem(localId: _uuid.v4(), name: 'Pão Brioche'),
          OptionItem(localId: _uuid.v4(), name: 'Pão Integral'),
          OptionItem(localId: _uuid.v4(), name: 'Sem pão (Low Carb)', price: 0),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Carne Principal',
        minSelection: 1,
        maxSelection: 1,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Hambúrguer Bovino'),
          OptionItem(localId: _uuid.v4(), name: 'Hambúrguer Frango'),
          OptionItem(localId: _uuid.v4(), name: 'Hambúrguer Vegetariano'),
          OptionItem(
              localId: _uuid.v4(), name: 'Hambúrguer de Picanha', price: 500),
          OptionItem(
              localId: _uuid.v4(), name: 'Hambúrguer de Costela', price: 600),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Queijos',
        minSelection: 0,
        maxSelection: 2,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Mussarela', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Prato', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Cheddar', price: 250),
          OptionItem(localId: _uuid.v4(), name: 'Suíço', price: 300),
          OptionItem(localId: _uuid.v4(), name: 'Provolone', price: 300),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Adicionais',
        minSelection: 0,
        maxSelection: 5,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Bacon', price: 300),
          OptionItem(localId: _uuid.v4(), name: 'Ovo', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Alface', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Tomate', price: 0),
          OptionItem(
              localId: _uuid.v4(), name: 'Cebola Caramelizada', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Picles', price: 50),
          OptionItem(localId: _uuid.v4(), name: 'Molho Especial', price: 100),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Acompanhamentos',
        minSelection: 0,
        maxSelection: 2,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Batata Frita', price: 800),
          OptionItem(localId: _uuid.v4(), name: 'Onion Rings', price: 900),
          OptionItem(localId: _uuid.v4(), name: 'Salada', price: 500),
          OptionItem(localId: _uuid.v4(), name: 'Nuggets', price: 1000),
        ],
      ),
    ];
  }

  /// Template para uma categoria de Sushi.
  static List<OptionGroup> forSushi() {
    return [
    OptionGroup(
      localId: _uuid.v4(),
      name: 'Tipo de Combo',
      minSelection: 1,
      maxSelection: 1,
      groupType: OptionGroupType.size,
      // ✅ TAMANHO
      items: [
        OptionItem(
            localId: _uuid.v4(), name: 'Combo Pequeno (20 peças)', price: 3500),
        OptionItem(
            localId: _uuid.v4(), name: 'Combo Médio (30 peças)', price: 5000),
        OptionItem(
            localId: _uuid.v4(), name: 'Combo Grande (40 peças)', price: 6500),
        OptionItem(
            localId: _uuid.v4(), name: 'Combo Família (60 peças)', price: 9000),
      ],
    )
    ,
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Tipo de Sushi',
    minSelection: 1,
    maxSelection: 3,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Hossomaki'),
    OptionItem(localId: _uuid.v4(), name: 'Uramaki'),
    OptionItem(localId: _uuid.v4(), name: 'Hot Roll'),
    OptionItem(localId: _uuid.v4(), name: 'Temaki'),
    OptionItem(localId: _uuid.v4(), name: 'Sashimi', price: 500),
    OptionItem(localId: _uuid.v4(), name: 'Niguiri', price: 300),
    ],
    ),
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Recheios Principais',
    minSelection: 1,
    maxSelection: 4,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Salmão'),
    OptionItem(localId: _uuid.v4(), name: 'Atum'),
    OptionItem(localId: _uuid.v4(), name: 'Kani'),
    OptionItem(localId: _uuid.v4(), name: 'Camarão'),
    OptionItem(localId: _uuid.v4(), name: 'Vegetariano'),
    OptionItem(localId: _uuid.v4(), name: 'Peixe Branco'),
    ],
    ),
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Molhos (Escolha até 2)',
    minSelection: 0,
    maxSelection: 2,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Shoyu', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Molho Tarê', price: 100),
    OptionItem(localId: _uuid.v4(), name: 'Molho Picante', price: 100),
    OptionItem(localId: _uuid.v4(), name: 'Molho Agridoce', price: 100),
    ],
    ),
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Extras',
    minSelection: 0,
    maxSelection: 3,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Wasabi Extra', price: 50),
    OptionItem(localId: _uuid.v4(), name: 'Gengibre Extra', price: 50),
    OptionItem(localId: _uuid.v4(), name: 'Temaki Extra', price: 1200),
    OptionItem(localId: _uuid.v4(), name: 'Salada de Alga', price: 500),
    ],
    ),
    ];
  }

  /// Template para uma categoria de Saladas.
  static List<OptionGroup> forSaladas() {
    return [
    OptionGroup(
      localId: _uuid.v4(),
      name: 'Tamanho',
      minSelection: 1,
      maxSelection: 1,
      groupType: OptionGroupType.size,
      // ✅ TAMANHO
      items: [
        OptionItem(localId: _uuid.v4(), name: 'Pequena', price: 1500),
        OptionItem(localId: _uuid.v4(), name: 'Média', price: 2000),
        OptionItem(localId: _uuid.v4(), name: 'Grande', price: 2500),
      ],
    )
    ,
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Base de Folhas',
    minSelection: 1,
    maxSelection: 2,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Alface Americana'),
    OptionItem(localId: _uuid.v4(), name: 'Alface Crespa'),
    OptionItem(localId: _uuid.v4(), name: 'Rúcula'),
    OptionItem(localId: _uuid.v4(), name: 'Espinafre'),
    OptionItem(localId: _uuid.v4(), name: 'Mix de Folhas'),
    ],
    ),
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Proteínas (Escolha até 2)',
    minSelection: 0,
    maxSelection: 2,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Frango Grelhado', price: 500),
    OptionItem(localId: _uuid.v4(), name: 'Atum', price: 600),
    OptionItem(localId: _uuid.v4(), name: 'Ovo Cozido', price: 200),
    OptionItem(localId: _uuid.v4(), name: 'Queijo Cottage', price: 400),
    OptionItem(localId: _uuid.v4(), name: 'Peito de Peru', price: 450),
    OptionItem(localId: _uuid.v4(), name: 'Grão de Bico', price: 300),
    ],
    ),
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Vegetais e Extras',
    minSelection: 0,
    maxSelection: 5,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Tomate', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Pepino', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Cenoura Ralada', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Milho', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Beterraba', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Azeitonas', price: 100),
    OptionItem(localId: _uuid.v4(), name: 'Cebola Roxa', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Croutons', price: 150),
    OptionItem(localId: _uuid.v4(), name: 'Nozes', price: 200),
    ],
    ),
    OptionGroup(
    localId: _uuid.v4(),
    name: 'Molhos',
    minSelection: 0,
    maxSelection: 1,
    groupType: OptionGroupType.generic, // ✅ GENÉRICO
    items: [
    OptionItem(localId: _uuid.v4(), name: 'Mostarda e Mel', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Iogurte', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Caesar', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Balsâmico', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Molho Ranch', price: 0),
    OptionItem(localId: _uuid.v4(), name: 'Azeite e Limão', price: 0),
    ],
    ),
    ];
    }

  /// Template para uma categoria de Sobremesas.
  static List<OptionGroup> forSobremesas() {
    return [
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Tipo de Sobremesa',
        minSelection: 1,
        maxSelection: 1,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Brownie', price: 1200),
          OptionItem(localId: _uuid.v4(), name: 'Cheesecake', price: 1500),
          OptionItem(
              localId: _uuid.v4(), name: 'Mousse de Chocolate', price: 1000),
          OptionItem(localId: _uuid.v4(), name: 'Pudim', price: 900),
          OptionItem(localId: _uuid.v4(), name: 'Torta de Limão', price: 1300),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Calda e Cobertura',
        minSelection: 0,
        maxSelection: 2,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(
              localId: _uuid.v4(), name: 'Calda de Chocolate', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Calda de Caramelo', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Calda de Morango', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Chantilly', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Sorvete de Creme', price: 300),
          OptionItem(
              localId: _uuid.v4(), name: 'Sorvete de Chocolate', price: 300),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Complementos',
        minSelection: 0,
        maxSelection: 3,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Morango Fresco', price: 200),
          OptionItem(
              localId: _uuid.v4(), name: 'Castanhas Picadas', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Coco Ralado', price: 100),
          OptionItem(
              localId: _uuid.v4(), name: 'Granulado Colorido', price: 50),
          OptionItem(localId: _uuid.v4(), name: 'Farinha Lactea', price: 50),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Temperatura',
        minSelection: 0,
        maxSelection: 1,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Natural', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Gelado', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Aquecido', price: 0),
        ],
      ),
    ];
  }

  /// Template para uma categoria de Bebidas.
  static List<OptionGroup> forBebidas() {
    return [
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Tamanho',
        minSelection: 1,
        maxSelection: 1,
        groupType: OptionGroupType.size,
        // ✅ TAMANHO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Lata 350ml', price: 0),
          OptionItem(localId: _uuid.v4(), name: '600ml', price: 300),
          OptionItem(localId: _uuid.v4(), name: '1 Litro', price: 500),
          OptionItem(localId: _uuid.v4(), name: '2 Litros', price: 900),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Gelo',
        minSelection: 0,
        maxSelection: 1,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Com gelo', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Sem gelo', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Gelo à parte', price: 0),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Adicionais',
        minSelection: 0,
        maxSelection: 2,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Limão Extra', price: 50),
          OptionItem(localId: _uuid.v4(), name: 'Hortelã', price: 50),
          OptionItem(localId: _uuid.v4(), name: 'Canudo', price: 0),
        ],
      ),
    ];
  }

  /// Template para uma categoria de Café da Manhã.
  static List<OptionGroup> forCafeDaManha() {
    return [

      OptionGroup(
        localId: _uuid.v4(),
        name: 'Acompanhamentos',
        minSelection: 0,
        maxSelection: 3,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Pão Francês', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Croissant', price: 500),
          OptionItem(localId: _uuid.v4(), name: 'Bolo', price: 400),
          OptionItem(localId: _uuid.v4(), name: 'Rosca Doce', price: 450),
          OptionItem(localId: _uuid.v4(), name: 'Misto Quente', price: 700),
          OptionItem(localId: _uuid.v4(), name: 'Omelete', price: 800),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Recheios e Adicionais',
        minSelection: 0,
        maxSelection: 3,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Manteiga', price: 0),
          OptionItem(localId: _uuid.v4(), name: 'Geleia', price: 100),
          OptionItem(localId: _uuid.v4(), name: 'Queijo', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Presunto', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Peito de Peru', price: 250),
          OptionItem(localId: _uuid.v4(), name: 'Ricota', price: 200),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Frutas',
        minSelection: 0,
        maxSelection: 2,
        groupType: OptionGroupType.generic,
        // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Banana', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Maçã', price: 150),
          OptionItem(localId: _uuid.v4(), name: 'Mamão', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Melão', price: 200),
          OptionItem(localId: _uuid.v4(), name: 'Uvas', price: 250),
        ],
      ),



      OptionGroup(
        localId: _uuid.v4(),
        name: 'Carboidratos',
        minSelection: 1,
        maxSelection: 2,
        groupType: OptionGroupType.generic, // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Arroz Branco'),
          OptionItem(localId: _uuid.v4(), name: 'Arroz Integral'),
          OptionItem(localId: _uuid.v4(), name: 'Feijão'),
          OptionItem(localId: _uuid.v4(), name: 'Purê de Batata'),
          OptionItem(localId: _uuid.v4(), name: 'Macarrão'),
          OptionItem(localId: _uuid.v4(), name: 'Batata Assada'),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Guarnições',
        minSelection: 0,
        maxSelection: 3,
        groupType: OptionGroupType.generic, // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Salada Verde'),
          OptionItem(localId: _uuid.v4(), name: 'Legumes Cozidos'),
          OptionItem(localId: _uuid.v4(), name: 'Farofa'),
          OptionItem(localId: _uuid.v4(), name: 'Vinagrete'),
          OptionItem(localId: _uuid.v4(), name: 'Ovo Cozido', price: 100),
        ],
      ),
      OptionGroup(
        localId: _uuid.v4(),
        name: 'Molhos Extras',
        minSelection: 0,
        maxSelection: 1,
        groupType: OptionGroupType.generic, // ✅ GENÉRICO
        items: [
          OptionItem(localId: _uuid.v4(), name: 'Molho de Alho', price: 50),
          OptionItem(localId: _uuid.v4(), name: 'Molho de Pimenta', price: 50),
          OptionItem(localId: _uuid.v4(), name: 'Molho Barbecue', price: 100),
        ],
      ),




    ];
  }
}
