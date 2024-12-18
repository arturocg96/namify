import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Punto de entrada principal de la aplicación Flutter
void main() {
  runApp(MyApp()); // Inicia la aplicación y muestra el widget MyApp
}

// Clase principal que representa la aplicación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // Proveedor de estado para que MyAppState esté disponible en todo el árbol de widgets
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namify', // Título de la aplicación
        theme: ThemeData(
          useMaterial3: true, // Habilita el diseño Material 3
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange), // Define un esquema de colores basado en un color base
        ),
        home: MyHomePage(), // Define la página inicial
      ),
    );
  }
}

// Clase que gestiona el estado de la aplicación (nombres, historial, favoritos)
class MyAppState extends ChangeNotifier {
  var current = WordPair.random(); // Genera un par de palabras aleatorias
  var history = <WordPair>[]; // Lista para almacenar el historial de palabras generadas
  GlobalKey? historyListKey; // Llave global para animar la lista de historial

  // Genera un nuevo par de palabras y actualiza el historial
  void getNext() {
    history.insert(0, current); // Inserta el par actual al inicio del historial
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0); // Anima la inserción en la lista
    current = WordPair.random(); // Genera un nuevo par de palabras
    notifyListeners(); // Notifica a los widgets que usan este estado
  }

  var favorites = <WordPair>[]; // Lista de pares de palabras marcados como favoritos

  // Alterna entre agregar o quitar un par de palabras de los favoritos
  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current; // Si no se pasa un par, usa el par actual
    if (favorites.contains(pair)) {
      favorites.remove(pair); // Si ya está en favoritos, lo elimina
    } else {
      favorites.add(pair); // Si no está en favoritos, lo agrega
    }
    notifyListeners(); // Notifica a los widgets que usan este estado
  }

  // Elimina un par específico de la lista de favoritos
  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

// Widget principal que controla la navegación entre páginas
class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // Índice para rastrear la página seleccionada

  @override
  Widget build(BuildContext context) {
    var colorScheme = Theme.of(context).colorScheme; // Esquema de colores del tema actual

    Widget page; // Define qué página mostrar
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage(); // Página de generación de palabras
        break;
      case 1:
        page = FavoritesPage(); // Página de favoritos
        break;
      default:
        throw UnimplementedError('No hay widget para $selectedIndex');
    }

    // Contenedor para la página actual, con fondo y animación
    var mainArea = ColoredBox(
      color: colorScheme.surfaceContainerHighest, // Color de fondo
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200), // Duración de la animación de cambio
        child: page, // Página seleccionada
      ),
    );

    return Scaffold(
      body: LayoutBuilder(
        // Determina el diseño según el ancho de la pantalla
        builder: (context, constraints) {
          if (constraints.maxWidth < 450) {
            // Diseño móvil: barra de navegación inferior
            return Column(
              children: [
                Expanded(child: mainArea), // Área principal
                SafeArea(
                  child: BottomNavigationBar(
                    items: [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.home), // Icono de la página principal
                        label: 'Home',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.favorite), // Icono de favoritos
                        label: 'Favorites',
                      ),
                    ],
                    currentIndex: selectedIndex, // Índice actual
                    onTap: (value) {
                      setState(() {
                        selectedIndex = value; // Cambia la página al tocar
                      });
                    },
                  ),
                )
              ],
            );
          } else {
            // Diseño para pantallas más anchas: barra de navegación lateral
            return Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth >= 600, // Expande si la pantalla es lo suficientemente ancha
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home), // Icono de la página principal
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.favorite), // Icono de favoritos
                        label: Text('Favorites'),
                      ),
                    ],
                    selectedIndex: selectedIndex, // Índice actual
                    onDestinationSelected: (value) {
                      setState(() {
                        selectedIndex = value; // Cambia la página al seleccionar
                      });
                    },
                  ),
                ),
                Expanded(child: mainArea), // Área principal
              ],
            );
          }
        },
      ),
    );
  }
}

// Página para generar nuevos pares de palabras
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>(); // Obtiene el estado de la aplicación
    var pair = appState.current; // Par de palabras actual

    IconData icon; // Define el ícono para el botón de favoritos
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite; // Ícono de favorito activado
    } else {
      icon = Icons.favorite_border; // Ícono de favorito desactivado
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido verticalmente
        children: [
          Expanded(
            flex: 3,
            child: HistoryListView(), // Muestra el historial de palabras generadas
          ),
          SizedBox(height: 10),
          BigCard(pair: pair), // Muestra el par de palabras actual
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite(); // Alterna el estado de favorito
                },
                icon: Icon(icon), // Ícono según el estado de favorito
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext(); // Genera un nuevo par de palabras
                },
                child: Text('Next'),
              ),
            ],
          ),
          Spacer(flex: 2), // Espaciador para centrar el contenido
        ],
      ),
    );
  }
}

// Widget que muestra una tarjeta con el par de palabras actual
class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.pair,
  }) : super(key: key);

  final WordPair pair; // Par de palabras a mostrar

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context); // Tema actual
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary, // Color del texto sobre el fondo primario
    );

    return Card(
      color: theme.colorScheme.primary, // Color de la tarjeta
      child: Padding(
        padding: const EdgeInsets.all(20), // Espaciado interno
        child: AnimatedSize(
          duration: Duration(milliseconds: 200), // Animación para cambios de tamaño
          child: MergeSemantics(
            child: Wrap(
              children: [
                Text(
                  pair.first, // Primera palabra
                  style: style.copyWith(fontWeight: FontWeight.w200),
                ),
                Text(
                  pair.second, // Segunda palabra
                  style: style.copyWith(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Página para mostrar y gestionar los favoritos
class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context); // Tema actual
    var appState = context.watch<MyAppState>(); // Estado de la aplicación

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'), // Mensaje si no hay favoritos
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Alinea los widgets al lado izquierdo
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'), // Muestra el número de favoritos
        ),
        Expanded(
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400, // Ancho máximo de cada celda
              childAspectRatio: 400 / 80, // Proporción de las celdas
            ),
            children: [
              for (var pair in appState.favorites)
                ListTile(
                  leading: IconButton(
                    icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
                    color: theme.colorScheme.primary, // Color del ícono
                    onPressed: () {
                      appState.removeFavorite(pair); // Elimina un favorito
                    },
                  ),
                  title: Text(
                    pair.asLowerCase, // Muestra el par de palabras en minúsculas
                    semanticsLabel: pair.asPascalCase, // Lectura en formato PascalCase
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

// Lista animada que muestra el historial de pares generados
class HistoryListView extends StatefulWidget {
  const HistoryListView({Key? key}) : super(key: key);

  @override
  State<HistoryListView> createState() => _HistoryListViewState();
}

class _HistoryListViewState extends State<HistoryListView> {
  final _key = GlobalKey(); // Llave global para el manejo del historial

  // Gradiente para dar un efecto de desvanecimiento en la lista
  static const Gradient _maskingGradient = LinearGradient(
    colors: [Colors.transparent, Colors.black],
    stops: [0.0, 0.5],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>(); // Obtiene el estado de la aplicación
    appState.historyListKey = _key; // Vincula la llave con el estado

    return ShaderMask(
      shaderCallback: (bounds) => _maskingGradient.createShader(bounds), // Aplica el gradiente
      blendMode: BlendMode.dstIn, // Combina el gradiente con la lista
      child: AnimatedList(
        key: _key, // Usa la llave para gestionar animaciones
        reverse: true, // Invierte el orden de la lista (elementos nuevos arriba)
        padding: EdgeInsets.only(top: 100), // Espaciado superior
        initialItemCount: appState.history.length, // Número inicial de elementos
        itemBuilder: (context, index, animation) {
          final pair = appState.history[index]; // Par de palabras en la posición actual
          return SizeTransition(
            sizeFactor: animation, // Animación de tamaño al aparecer
            child: Center(
              child: TextButton.icon(
                onPressed: () {
                  appState.toggleFavorite(pair); // Alterna el estado de favorito
                },
                icon: appState.favorites.contains(pair)
                    ? Icon(Icons.favorite, size: 12) // Ícono si es favorito
                    : SizedBox(), // Sin ícono si no es favorito
                label: Text(
                  pair.asLowerCase, // Muestra el par de palabras en minúsculas
                  semanticsLabel: pair.asPascalCase, // Lectura en PascalCase
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
