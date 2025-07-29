import 'package:bar_code_market/core/models/product.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  List<Product> products = []; // Lista de productos
  double totalPrice = 0.0; // Total de
  double sobrante = 0.0; // Total de
  String barcodeScanRes = "";
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Agregar listener al controlador para calcular automáticamente al cambiar el texto
    _controller.addListener(updateSobrante);
  }

  @override
  void dispose() {
    _controller.dispose(); // Limpia el controlador
    _focusNode.dispose(); // Limpia el FocusNode
    super.dispose();
  }

  void _removeFocus() {
    _focusNode.unfocus(); // Quita el foco del TextField
  }

  Future<void> scanBarcode() async {
    try {
      var result = await BarcodeScanner.scan();
      setState(() {
        barcodeScanRes = result.rawContent;
      });
    } catch (e) {
      barcodeScanRes = 'Error al escanear';
    }
  }

  void addProductManually(String name, double price, int quantity) {
    setState(() {
      products.add(Product(name, price, quantity));
      totalPrice += price * quantity;
    });
    updateSobrante();
  }

  void updateSobrante() {
    if (_controller.text.isNotEmpty) {
      sobrante = double.parse(_controller.text) - totalPrice;
    } else {
      sobrante = 0.0;
    }
    setState(() {});
  }

  // Muestra un cuadro de diálogo para agregar productos manualmente
  void showAddProductDialog() {
    String name = '';
    double price = 0.0;
    int quantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar Producto Manualmente'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Nombre del producto'),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  price = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addProductManually(name, price, quantity);
                Navigator.pop(context);
              },
              child: const Text('Agregar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void showEditProductDialog(Product product, int index) {
    String name = product.name;
    double price = product.price;
    int quantity = product.quantity;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Nombre del producto'),
                controller: TextEditingController(text: name),
                onChanged: (value) {
                  name = value;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: price.toString()),
                onChanged: (value) {
                  price = double.tryParse(value) ?? 0.0;
                },
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                controller: TextEditingController(text: quantity.toString()),
                onChanged: (value) {
                  quantity = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Actualiza la lista de productos
                updateProduct(index, name, price, quantity);
                Navigator.pop(context);
              },
              child: const Text('Actualizar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Eliminar producto
                deleteProduct(index);
                Navigator.pop(context);
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void updateProduct(int index, String name, double price, int quantity) {
    setState(() {
      totalPrice -= products[index].price *
          products[index].quantity; // Resta el precio anterior
      products[index] = Product(name, price, quantity); // Actualiza el producto
      totalPrice += price * quantity; // Suma el nuevo precio
    });
    updateSobrante();
  }

  void deleteProduct(int index) {
    setState(() {
      totalPrice -= products[index].price *
          products[index]
              .quantity; // Resta el precio del producto que se elimina
      products.removeAt(index); // Elimina el producto de la lista
    });
    updateSobrante();
  }

  void undoDelete(Product product, int index) {
    setState(() {
      products.insert(index, product); // Reagrega el producto eliminado
      totalPrice += product.price * product.quantity; // Restaura el total
    });
    updateSobrante();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bar Code Market'),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: showAddProductDialog,
          backgroundColor: Colors.blue,
          shape: CircleBorder(),
          child: Icon(Icons.add, color: Colors.white)),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await scanBarcode();
            },
            child: const Text('Escanear Código de Barras'),
          ),
          Text("Barcode: $barcodeScanRes"),
          ElevatedButton(
            onPressed: showAddProductDialog,
            child: const Text('Agregar Producto Manualmente'),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    focusNode: _focusNode,
                    decoration: InputDecoration(
                      labelText: 'Presupuesto',
                      labelStyle: TextStyle(fontSize: 12),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0), // Ajusta el padding
                    ),
                    style: TextStyle(
                        fontSize: 16.0), // Ajusta el tamaño de la fuente
                  ),
                ),
                Text('Total: \$${totalPrice.toStringAsFixed(2)}'),
                Text('Sobrante: \$${sobrante.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(
                      products[index].name), // Clave única para cada elemento
                  background: Container(
                    color: Colors.red,
                    alignment: AlignmentDirectional.centerEnd,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Icon(Icons.delete_forever, color: Colors.white),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('¿Confirmar eliminación?'),
                        content: const Text(
                            '¿Estás seguro de que quieres eliminar este producto?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(true), // Confirmar
                            child: const Text('Sí'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(context).pop(false), // Cancelar
                            child: const Text('No'),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) {
                    final productToDelete =
                        products[index]; // Guarda el producto a eliminar
                    final deletedIndex =
                        index; // Guarda el índice del producto eliminado
                    deleteProduct(index); // Elimina el producto

                    // Muestra un SnackBar con opción de deshacer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Producto eliminado"),
                        action: SnackBarAction(
                          label: 'Deshacer',
                          onPressed: () {
                            undoDelete(productToDelete,
                                deletedIndex); // Reagrega el producto
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: ListTile(
                      title: Text(products[index].name),
                      subtitle: Text(
                          'Precio: \$${products[index].price} - Cantidad: ${products[index].quantity}'),
                      trailing: Text(
                          'Subtotal: \$${(products[index].price * products[index].quantity).toStringAsFixed(2)}'),
                      onTap: () => showEditProductDialog(products[index],
                          index), // Abre el diálogo al tocar el producto
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
