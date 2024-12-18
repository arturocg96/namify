import 'package:english_words/english_words.dart'; // Generador de palabras aleatorias
import 'package:flutter/material.dart'; // Framework principal de Flutter
import 'package:provider/provider.dart'; // Gestión de estado reactivo

void main() {
  runApp(MyApp());
}

// Aplicación principal: StatelessWidget porque no tiene estado mutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        title: 'Namify',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

// Clase para gestionar el estado de la aplicación
class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Palabra actual generada aleatoriamente.
  var favorites = <WordPair>[]; // Lista de palabras favoritas.

  // Genera una nueva palabra aleatoria.
  void getNext() {
    current = WordPair.random(); // Cambia la palabra actual.
    notifyListeners(); // Notifica a los widgets que el estado cambió.
  }

  // Alterna entre agregar y eliminar la palabra actual de los favoritos.
  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current); // Si ya está en favoritos, la elimina.
    } else {
      favorites.add(current); // Si no está, la agrega.
    }
    notifyListeners(); // Notifica a los widgets que el estado cambió.
  }

  // Elimina una palabra de la lista de favoritos.
  void removeFromFavorites(WordPair pair) {
    favorites.remove(pair); // Elimina la palabra de la lista.
    notifyListeners(); // Notifica a los widgets que el estado cambió.
  }
}

// Página principal con riel de navegación responsivo
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState(); // Crea el estado asociado.
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0; // Índice seleccionado del riel de navegación.

  @override
  Widget build(BuildContext context) {
    // Determina qué página mostrar según el índice seleccionado.
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Página principal de generación de palabras.
        break;
      case 1:
        page = FavoritesPage(); // Página de favoritos.
        break;
      default:
        throw UnimplementedError('No widget for $selectedIndex'); // Error si el índice no es válido.
    }

    // LayoutBuilder ajusta el diseño según el tamaño disponible.
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              // Asegura que los widgets no se solapen con áreas sensibles del dispositivo.
              child: NavigationRail(
                // Riel de navegación lateral.
                extended: constraints.maxWidth >= 600, // Expande etiquetas si el ancho es suficiente.
                destinations: const [
                  // Definición de las opciones del riel.
                  NavigationRailDestination(
                    icon: Icon(Icons.home), // Ícono de la opción "Home".
                    label: Text('Home'), // Etiqueta "Home".
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite), // Ícono de la opción "Favorites".
                    label: Text('Favorites'), // Etiqueta "Favorites".
                  ),
                ],
                selectedIndex: selectedIndex, // Índice seleccionado actualmente.
                onDestinationSelected: (value) {
                  // Acción al seleccionar una opción.
                  setState(() {
                    selectedIndex = value; // Cambia el índice seleccionado.
                  });
                },
              ),
            ),
            Expanded(
              // Ocupa el espacio restante en la pantalla.
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, // Muestra la página seleccionada.
              ),
            ),
          ],
        ),
      );
    });
  }
}

// Página para generar palabras aleatorias.
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtiene el estado global.
    var pair = appState.current; // Palabra actual.
    var isFavorite = appState.favorites.contains(pair); // Verifica si es favorita.

    return Center(
      // Centra el contenido en la pantalla.
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra verticalmente.
        children: [
          BigCard(pair: pair), // Muestra la palabra en un "BigCard".
          const SizedBox(height: 10), // Espaciado vertical.
          Row(
            mainAxisSize: MainAxisSize.min, // Ajusta el tamaño a lo necesario.
            children: [
              ElevatedButton.icon(
                onPressed: appState.toggleFavorite, // Alterna favoritos.
                icon: Icon(isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border), // Ícono dinámico según favorito.
                label: const Text('Like'), // Etiqueta del botón.
              ),
              const SizedBox(width: 10), // Espaciado horizontal.
              ElevatedButton(
                onPressed: appState.getNext, // Genera una nueva palabra.
                child: const Text('Next'), // Etiqueta del botón.
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Página para mostrar la lista de favoritos con opción para eliminarlos.
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtiene el estado global.
    var favorites = appState.favorites; // Lista de favoritos.

    if (favorites.isEmpty) {
      // Muestra un mensaje si no hay favoritos.
      return Center(
        child: Text(
          'No favorites yet.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      );
    }

    // Muestra la lista de favoritos.
    return ListView(
      children: [
        Padding(
          // Espaciado alrededor del texto.
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have ${favorites.length} favorites:',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        for (var pair in favorites)
          ListTile(
            leading: Icon(Icons.favorite, color: Theme.of(context).colorScheme.primary), // Ícono.
            title: Text(pair.asPascalCase), // Muestra la palabra favorita.
            trailing: IconButton(
              // Botón para eliminar de favoritos.
              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
              onPressed: () {
                appState.removeFromFavorites(pair); // Elimina de favoritos.
              },
            ),
          ),
      ],
    );
  }
}

// Widget personalizado para mostrar la palabra actual en un diseño atractivo.
class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.pair}); // Constructor con la palabra.

  final WordPair pair; // Palabra que se mostrará.

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Obtiene el tema actual.
    final textStyle = theme.textTheme.displayMedium!.copyWith(
      // Configura el estilo del texto.
      color: theme.colorScheme.onPrimary, // Color del texto según el tema.
      fontWeight: FontWeight.bold, // Negrita para destacar.
    );

    return Center(
      child: SizedBox(
        width: 350, // Ancho del card.
        child: Card(
          // Tarjeta con fondo y sombra.
          color: theme.colorScheme.primary, // Color del fondo de la tarjeta.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0), // Bordes redondeados.
          ),
          elevation: 5, // Sombra para el efecto de elevación.
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0), // Espaciado interno.
            child: Text(
              pair.asPascalCase, // Muestra la palabra en formato PascalCase.
              style: textStyle, // Aplica el estilo definido.
              textAlign: TextAlign.center, // Centra el texto.
              semanticsLabel: "${pair.first} ${pair.second}", // Etiqueta para lectores de pantalla.
            ),
          ),
        ),
      ),
    );
  }
}
